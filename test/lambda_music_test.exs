defmodule LambdaMusicTest do
  use ExUnit.Case
  doctest LambdaMusic

  test "computes beta reductions" do
    assert LambdaMusic.compute("(\\x.x)A")
  end

	test "computes chords" do
		assert LambdaMusic.compute("(\\x.x)[ABC]")
	end

	test "note_string" do
    notes = LambdaMusic.compute("(\\x.\\y.(y x))AB")
		assert notes == "BA"
	end
	
end
