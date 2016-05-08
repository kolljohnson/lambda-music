defmodule LambdaMusic do
	@moduledoc """ 
	Computes the lambda encoding of a given musical score, then sends the computed
	notation to a PCM module for playback.
	"""
	require :music_lexer
	require :music_parser
	require Record

	@doc""" 
	Takes in a lambda expression and note sequence and computes it. 
	Lambda expressions should use \\ for lambda, for example \\x.x
	"""
	def compute(expr) when is_binary(expr) do
		expr = expr
		|> String.replace("λ", "\\")
		|> String.to_char_list
		encode(expr)
	end
	
	defp encode(expr) do
		{:ok, tokens, _} = :music_lexer.string(expr)
		{:ok, ast} = :music_parser.parse(tokens)
		IO.puts(to_string(expr) <> " ->")
		#bound_ast = no_free(ast)
		#bound_ast
		notes = beta(ast)
		#IO.inspect(notes)
		sequence = note_string(notes)
		IO.puts(sequence)
		sequence
	end

	# note beta-redex
  defp beta({:app, {:lambda, x, y}, {:notes, head, tail}}) do
		lambda = {:lambda, x, y}
		bound = x
	  beta_redex = Tuple.append({:app, eval(lambda, head, bound)}, tail)
		str_redex = print_term(beta_redex)
		IO.puts(str_redex <> " ->")
		beta(beta_redex)
		#|> beta
		#beta(beta_redex, tail)
	end

	# non-note beta-redex
	defp beta({:app, {:lambda, x, y}, term2}) do
#		cond no_free({:app, {:lambda, x, y}, z}) do
#			true -> alpha({:app, {:lambda, x, y}, z})
#												|> eval
#			_ -> 	eval({:app, {:lambda, x, y}, z})  
#		end
    
		beta_redex = eval({:lambda, x, y}, term2, x)
	end

	# return var
	defp beta({:variable, variable}) do
		{:variable, variable}
	end

	# return note
	defp beta({:note, _note}) do
      {:note, _note}
	end

	# check for redexs in app then return 
	defp beta({:app, {:app, x, y}, term2}) do
		b_term1 = beta({:app, x, y})
		b_term2 = beta(term2)
		{:app, b_term1, b_term2}
	end
	
	#evaluates the Beta reduction by substituting the term with every occurence of a bound variable.
  defp eval({:lambda, x,  term}, z, bound) do
		if (x == bound) do
			beta_term = eval(term, z, bound)
			#IO.inspect(beta_term)
		else
			beta_term = {:lambda, x, eval(term, z, bound)}
		end
		beta_term
	end
	
	
	defp eval({:app, {_term1, var}, {_term2, var2}}, z, bound) do

		if (var == bound && var2 == bound) do
			{:app, z, z}
		else
			cond do
				(var == bound) -> {:app, z, {_term2, var2}}
				(var2 == bound) -> {:app, {_term1, var}, z}
				true -> {:app, {_term1, var}, {_term2, var2}}
			end
		end
	end

	defp eval({_term, term1, term2}, z, bound) do
		b_term1 = eval(term1, z, bound)
		b_term2 = eval(term2, z, bound)
		{_term, b_term1, b_term2}
	end

	defp eval({_term, var}, beta_var, bound)  do
		if (var == bound) do
			beta_var
		else
			{_term, var}
		end		
	end

#	defp eval({_term, _, term}, beta_var, bound) do
 #   beta_term = eval(term, beta_var)
	#	{_term, beta_var, beta_term}
	#end

	#defp eval({:notes, _note, _notes}, _) do
	#	{:notes, _note, _notes}
	#end

	

	@doc """
	Checks whether there are any free variables within the term.
	"""
	
#	def no_free({_term, term1, term2}) do
#		case {_term, term1, term2} do
#			term1 when free?(term1) -> {_term, term1, term2}
#			term2 when free?(term2) -> {_term, term1, term2}
#			true -> alpha({_, term1, term2})
#		end
		
#	end

	def no_free({:lambda, variable, term}) do
		if free?(term, variable) do
			alpha({:lambda, variable, term})
		else
			{:lambda, variable, term}
		end
	end
	
	def no_free({:app, term1, term2}) do
		cond do
			free?(term1) -> alpha(term1)
			free?(term2) -> alpha(term2)
			free?({:app, term1, term2}) -> alpha({:app, term1, term2})
			true -> {:app, term1, term2}
		end
		
		#if free?({:app, term1, term2}) do
		#		 alpha({:app, term1, term2})
		#		else
		#			{:app, term1, term2}					
		#end
	end
	
	def no_free({:notes, note, notes}) do
		{:notes, note, notes}
	end
	
	def no_free({:note, note}) do
		{:note, note}
	end
	
	def no_free({:variable, variable}) do
		{:variable, variable}
	end
	
	# Checks whether there are any free variables in a given term
	defp free?({:notes, _, _}, _variable) do
		false
	end
	
	defp free?({:note, _}, _variable) do
		false
	end
	
	defp free?({:variable, bound_variable}, variable) do
		if bound_variable == variable do
			true
		else
			false
		end
	end

	defp free?({:lambda, bound_var, term}) do
		if free?(term, bound_var) do
			true
		else
			false
		end																		
	end

	defp free?({:lambda, bound_var, term}, variable) do
		if variable == bound_var do
			true
		else
			free?(term, variable)
		end
	end

	defp free?({:app, term1, term2}) do
    cond do
			lambda?(term1) -> free?(term1)
			lambda?(term2) -> free?(term2)
			true -> {:app, term1, term2}
		end
	end
	
	defp free?({:app, term1, term2}, variable) do
		cond do
		  free?(term1, variable) -> true
		  free?(term2, variable) -> true
			true -> false
		end
	end

	# check if the first term in an application is a lambda
	defp lambda?({:lambda, _, _}), do: true
  defp lambda?({_terms, _, _}), do: false
	defp lambda?({_term, _}), do: false
	
	defp alpha({:lambda, bound_var, term}) do
		#	String.to_integer(to_string(bound_var))
		#alpha_var = to_char_list(String.to_integer(to_string(bound_var) + 1))
	  #alpha_term = alpha(term, alpha_var)
	  # {:lambda, alpha_var, alpha_term}	

	end

	defp alpha({:lambda, _var, term}, alpha_var) do
		alpha_term = alpha(term, alpha_var)
		{:lambda, alpha_var, alpha_term}
	end

	defp alpha({:app, term1, term2}, alpha_var) do
		a_term1 = alpha(term1, alpha_var)
		a_term2 = alpha(term2, alpha_var)
		{:app, a_term1, a_term2}
	end
	
	defp alpha({:notes, _note, _notes}, _alpha_var) do
		{:notes, _note, _notes}
	end
	
	defp alpha({:note, _note}, _alpha_var) do
		{:note, _note}
	end
	
	defp alpha({:variable, _}, alpha_var) do
		{:variable, alpha_var} 
	end

  def note_string({_term, {:note, note}, term}) do
		if (_term == :chord) do
			"[" <> to_string(note) <> note_string(term) <> "]"
		else
		  to_string(note) <> note_string(term)
		end
	end
	
	def note_string({_term, _term1, _term2}) do
		note_string(_term1) <> note_string(_term2)
	end

	def note_string({:note, note}) do
    to_string(note)
	end

  @doc """
	Takes in a term and converts it into a printable string
	"""
	def print_term({term, var}) do
		to_string(var)
	end

	def print_term({:chord, note1, note2}) do
		print_term(note1) <> print_term(note2)
	end

	def print_term({term, term1, term2}) when (term == :lambda) do
		"\\#{to_string(term1)}." <> print_term(term2)
	end
	
	def print_term({term, term1, term2}) do
		cond do
	#	lambda?(term1) && chord?(term2) -> "(" <> print_term(term1) <> ")" <> "[" <> print_term(2) <> "]" 
			lambda?(term1) -> "(" <> print_term(term1) <> ")" <> print_term(term2)
			chord?(term2) -> "(" <> print_term(term1) <> ")" <> "[" <> print_term(term2) <> "]"
			true -> "(" <> print_term(term1) <> print_term(term2) <> ")" 
		end
	end

	#checks to see if the second term in application is a chord
	defp chord?({:chord, _, _}), do: true
	defp chord?({_term, _, _}), do: false
	defp chord?({_term, _}), do: false
end
