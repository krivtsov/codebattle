defmodule Play.Fsm do
  @moduledoc false

  use Fsm, initial_state: :initial,
    initial_data: %{
      game_id: nil,
      first_player: nil,
      second_player: nil,
      game_over: false,
      winner: nil,
      loser: nil
    }

  defstate initial do
    defevent create(params), data: data do
      next_state(:waiting_opponent, %{data | game_id: params.game_id, first_player: params.user})
    end
  end

  defstate waiting_opponent do
    defevent join(params), data: data do
      next_state(:playing, %{data | second_player: params.user})
    end
  end

  defstate playing do
    defevent complete(params), data: data do
      next_state(:player_won, %{data | winner: params.user})
    end

    defevent join(_) do
      respond({:error, "Game is already playing"})
    end
  end

  defstate player_won do
    defevent complete(params), data: data do
      next_state(:game_over, %{data | loser: params.user, game_over: true})
    end

    defevent join(_) do
      respond({:error, "Game is already playing"})
    end
  end

  defstate game_over do
    defevent _ do
      respond({:error, "Game is over"})
    end
  end
end