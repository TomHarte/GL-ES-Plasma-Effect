varying highp vec2 texCoordVarying1, texCoordVarying2, texCoordVarying3;

void main()
{
	/*
		Each sheet is coloured individually to look like ripples on
		the surface of a pond after a stone has been thrown in. So it's
		a sine function on distance from the centre. We adjust the ripple
		size with a quick multiplier.

		Rule of thumb: bigger multiplier = smaller details on screen.

	*/
	mediump vec3 distances =
		vec3(
			sin(length(texCoordVarying1) * 18.0),
			sin(length(texCoordVarying2) * 14.2),
			sin(length(texCoordVarying3) * 11.9)
		);

	/*
		We work out outputColour in the range 0.0 to 1.0 by adding them,
		and using the sine of that.
	*/
	mediump float outputColour = 0.5 + sin(dot(distances, vec3(1.0, 1.0, 1.0)))*0.5;

	/*
		Finally the fragment colour is created by linearly interpolating
		in the range of the selected start and end colours 48 36 208
	*/
	gl_FragColor =
		mix( vec4(0.37, 0.5, 1.0, 1.0), vec4(0.17, 0.1, 0.8, 1.0), outputColour);
}

/*
	Implementation notes:

		it'd be smarter to adjust the two vectors passed to mix so as not
		to have to scale the outputColour, leaving it in the range -1.0 to 1.0
		but this way makes it clearer overall what's going on with the colours
*/
