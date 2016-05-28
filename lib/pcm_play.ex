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
		?G => 783.99
	}

	duration = 0.5
	if chord?(note_string) do
		#will play notes and chords
		chord_list = Regex.scan(~r/\[[A-G]{3}\]|[A-G]+/, note_string)		
		
		for note <- chord_list  do
			if chord?(List.first(note)) do
				c_note = List.first(note)
				IO.inspect(c_note)
				<<note1 :: utf8>> = String.at(c_note, 1)
				n1_freq = notes[note1]
				n1 = %SineWave{frequency: n1_freq}
				<<note2 :: utf8>> = String.at(c_note, 2)
				n2_freq = notes[note2]
				n2 = %SineWave{frequency: n2_freq}
				<<note3 :: utf8>> = String.at(c_note, 3)
				n3_freq = notes[note3]
				n3 = %SineWave{frequency: n3_freq}
			  chord = %Chord{note1: n1, note2: n2, note3: n3}
				data = PCMSampler.sample(chord, duration)
				send(port, {self, {:command, data}})
			else
			  frequency = notes[List.first(note)]
			  w = %SineWave{frequency: frequency}
			  data = PCMSampler.sample(w, duration)
			  send(port, {self, {:command, data}})
			end
  	end
		
	else
		#will play simply notes
		for <<note <- note_string>> do
      frequency = notes[note]
			w = %SineWave{frequency: frequency}
			data = PCMSampler.sample(w, duration)
			send(port, {self, {:command, data}})
		end
	end	
	end

	#def chord?(string) when (String.length(string) > 6), do: Regex.match?(~r/\[[A-G]{3}\]/, string)
	def chord?(string) do
		length = String.length(string) 
		if (length <= 5) do
			Regex.match?(~r/\[[A-G]{3}\]/, string)
		else
			Regex.match?(~r/\[[A-G]{3}\]|[A-G]+/, string)
		end
	end
end

