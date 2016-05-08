defmodule PCM_Play do
  #use SineWave
	#import PCMSampler
	
	@moduledoc """
	Plays musical notes using PCM
	"""

	@doc """
	Plays a given string of notes
	"""	
	def play(note_string, port) do
	#frequencies for the notes
  notes = %{
		?A => 440,
		?B => 493.88,
		?C => 523.25,
		?D => 587.33,
		?E => 659.25,
		?F => 698.46,
		?G => 783.99, 
	}

	duration = 0.5
		
		for <<note <- note_string>> do
      frequency = notes[note]
			w = %SineWave{frequency: frequency}
			data = PCMSampler.sample(w, duration)
			send(port, {self, {:command, data}})
		end
	end
end
