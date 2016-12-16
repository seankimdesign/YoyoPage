package ;

/**
 * ...
 * @author ...
 */
class Calculate
{

	public function new() 
	{
	}
	
	public function pyth(A:Float = 0, B:Float = 0, C:Float = 0):Float
	{
		if (A == 0)
		{
			return (Math.sqrt(C * C - B * B));
		}
		if (B == 0)
		{
			return (Math.sqrt(C * C - A * A));
		}
		if (C == 0)
		{
			return (Math.sqrt(A * A + B * B));
		}
		return 0;
	}
	
}