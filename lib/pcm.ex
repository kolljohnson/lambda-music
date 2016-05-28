#Built using knewter's PCM_Playground library to construct sine waves through PCM 

defmodule SineWave do
	defstruct amplitude: 1, frequency: 440

	def value_at(%__MODULE__{amplitude: a, frequency: f}, time) do
	  angular_frequency = 2 * f * :math.pi
		a * :math.sin(angular_frequency * time)
	end
end

defmodule Chord do
	defstruct note1: %SineWave{}, note2: %SineWave{}, note3: %SineWave{}
end

defmodule PCMSampler do
	@sample_rate 16_000
	@channels 1
	@max_amplitude 32_767

	def sample(oscillator=%SineWave{}, duration) do
	  num_samples = trunc(@sample_rate * duration)
		pre_data = for sample_number <- 1..num_samples do
			value = @max_amplitude * SineWave.value_at(oscillator, sample_number/@sample_rate)
			|> trunc
			<< value :: big-signed-integer-size(16) >>
		end

		IO.iodata_to_binary(pre_data)
	end

	def sample(oscillator=%Chord{}, duration) do
		sample1 = sample(oscillator.note1, duration)
		sample2 = sample(oscillator.note2, duration)
		sample3 = sample(oscillator.note3, duration)
		IO.iodata_to_binary([sample1, sample2, sample3])
	  #data = zip_sample([sample1, sample2, sample3])
		#IO.iodata_to_binary(data)
	end

		#def zip_sample([[head|tail], [head2|tail2], [head3|tail3]]) do
		#	  data = [(head + head2 + head3) ++ zip_sample([tail, tail2, tail3])]
	#end
	#def zip_sample([<<head :: size(16), rest :: binary>>,
	#								<<head2 :: size(16), rest :: binary>>,
	#								<<head3 :: size(16), rest :: binary>>]) do
	#	new_head = <<head + head2 + head3 :: big-signed-integer-size(16)>>
	#	new_head ++ zip_sample([[rest], [rest], [rest]])
	#end
	
	#def zip_sample([head, head2, head3]) do
	#	head + head2 + head3
	#end
	
end
