SumArithmeticSeries(start, stop, step := 1)
{
	if not IsInteger(RoundT(stop / start))
	{
		return "Invalid values entered"
	}
	
	return RoundT((stop + start) * (stop - start + step) / (step * 2))
}

IsInteger(value)
{
	if value is integer
	{
		return true
	}
}

RoundT(number)
{
	return RTrim(RTrim(Format("{}", number), 0), ".")
}
