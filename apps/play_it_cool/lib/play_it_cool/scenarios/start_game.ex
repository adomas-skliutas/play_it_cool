defmodule PlayItCool.Scenarios.StartGame do
  @moduledoc """
  Starts new game in an existing lobby
  It's a bit of a mess...
  TODO: clean this module
  """
  import Ecto.Query

  alias PlayItCool.{Repo, Game, Lobby, Subject, Event, Player, Question, Word}

  @spec start_game(any, any) :: :ok | {:error, any}
  def start_game(lobby_token, subject) do
    case fetch_lobby(lobby_token) do
      {:error, message} ->
        {:error, message}

      lobby ->
        fetch_subject(subject)
        |> create_game(lobby)
        |> fetch_lobby_owner_player()
        |> add_game_start_event()
        |> set_lobby_status_to_playing()
        |> get_game_word()
        |> get_game_questions()
        |> send_data_to_game_lobby_process()
    end
  end

  defp create_game(%Subject{id: subject_id}, %Lobby{id: lobby_id} = lobby) do
    game =
      %Game{}
      |> Game.changeset(%{subject_id: subject_id, lobby_id: lobby_id})
      |> Repo.insert!()

    {lobby, game}
  end

  defp get_game_questions(
         {%Lobby{id: lobby_id, lobby_token: lobby_token}, %Game{subject_id: subject_id} = game,
          word, guessable_words}
       ) do
    questions =
      from(question in Question, where: question.subject_id == ^subject_id)
      |> Repo.all()

    players =
      from(player in Player, where: player.lobby_id == ^lobby_id)
      |> Repo.all()

    game_questions =
      questions
      |> Enum.take_random(length(players) * 2)

    {game, game_questions, lobby_token, word, guessable_words}
  end

  defp get_game_word({lobby, %Game{subject_id: subject_id} = game}) do
    [word | guessable_words] =
      from(w in Word, where: w.subject_id == ^subject_id)
      |> Repo.all()
      |> Enum.shuffle()
      |> Enum.take(5)
      |> Enum.map(& &1.word)

    {lobby, game, word, guessable_words}
  end

  defp add_game_start_event(
         {%Lobby{id: lobby_id} = lobby, %Game{id: game_id} = game, %Player{id: player_id}}
       ) do
    %Event{}
    |> Event.changeset(%{
      event_type: "START_GAME",
      game_id: game_id,
      lobby_id: lobby_id,
      player_id: player_id
    })
    |> Repo.insert!()

    {lobby, game}
  end

  defp set_lobby_status_to_playing({lobby, game}) do
    lobby
    |> Lobby.changeset(%{state: "PLAYING"})
    |> Repo.update!()

    {lobby, game}
  end

  defp send_data_to_game_lobby_process(
         {%Game{id: game_id}, questions, lobby_token, word, guessable_words}
       ) do
    %{
      questions: Enum.map(questions, fn q -> %{question: q.question, id: q.id} end),
      id: game_id,
      word: word,
      guessable_words: guessable_words
    }
    |> PlayItCool.GameLobby.start_new_game(Integer.to_string(lobby_token))
  end

  # TODO: move this and join_lobby.ex function to a separate module for reuse
  defp fetch_lobby(lobby_token) do
    case from(lobby in Lobby,
           where: lobby.lobby_token == ^lobby_token,
           where: lobby.state in ["INIT", "WAITING"]
         )
         |> Repo.one() do
      nil ->
        {:error, "No lobby with this token"}

      lobby ->
        lobby
    end
  end

  defp fetch_subject(subject) do
    from(subject in Subject, where: subject.label == ^subject)
    |> Repo.one!()
  end

  defp fetch_lobby_owner_player({%Lobby{owner_id: user_id, id: lobby_id} = lobby, game}) do
    player =
      from(player in Player,
        where: player.user_id == ^user_id,
        where: player.lobby_id == ^lobby_id
      )
      |> Repo.one!()

    {lobby, game, player}
  end
end
