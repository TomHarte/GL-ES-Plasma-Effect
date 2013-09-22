attribute vec4 position;
attribute vec2 texCoord;

uniform mediump float time;

varying highp vec2 texCoordVarying1, texCoordVarying2, texCoordVarying3;

void main()
{
	mediump float radiansTime = time * 3.141592654 * 2.0;

	/*
		So, coordinates here are of the form:

			texCoord + vec2(something, variant of same thing)

		Where something is:

			<linear offset> + sin(<angular offset> + radiansTime * <multiplier>)


		What we're looking to do is to act as though moving three separate sheets across
		the surface. Each has its own texCoordVarying. Each moves according to a
		sinusoidal pattern. Note that the multiplier is always a whole number so
		that all patterns repeat properly as time goes from 0 to 1 and then back to 0,
		hence radiansTime goes from 0 to 2pi and then back to 0.

		The various constants aren't sourced from anything. Just play around with them.

	*/

	texCoordVarying1 = texCoord + vec2(0.0 + sin(0.0 + radiansTime * 1.0) * 0.2, 0.0 + sin(1.9 + radiansTime * 8.0) * 0.4);
	texCoordVarying2 = texCoord - vec2(0.2 - sin(0.8 + radiansTime * 2.0) * 0.2, 0.6 - sin(1.3 + radiansTime * 3.0) * 0.8);
	texCoordVarying3 = texCoord + vec2(0.4 + sin(0.7 + radiansTime * 5.0) * 0.2, 0.5 + sin(0.2 + radiansTime * 9.0) * 0.1);

	gl_Position = position;
}
