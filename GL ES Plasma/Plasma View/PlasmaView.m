//
//  PlasmaView.m
//  GL ES Plasma
//
//  Created by Thomas Harte on 21/09/2013.
//  Copyright (c) Thomas Harte. All rights reserved.
//

#import "PlasmaView.h"
#import <GLKit/GLKit.h>

typedef enum
{
	ESPPlasmaViewGLAttributePosition,
	ESPPlasmaViewGLAttributeTexCoord
} ESPPlasmaViewGLAttribute;

@interface ESPPlasmaView () <GLKViewDelegate>
@end

@implementation ESPPlasmaView
{
	GLKView *_glView;
	GLuint _program;

	GLint _timeUniform;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(![self plasmaViewCommonInit]) return nil;
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(![self plasmaViewCommonInit]) return nil;
	return self;
}

- (BOOL)plasmaViewCommonInit
{
	// GLKViews require a delegate to draw anything; I don't want to subclass one
	// and set delegate to self so I'm going to create one that always covers this
	// view entirely. It's not fantastic from a compositing point of view but will
	// have to do based on the constraints.

	_glView = [[GLKView alloc] initWithFrame:self.bounds];
	[self addSubview:_glView];
	_glView.delegate = self;
	_glView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	EAGLContext *glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	_glView.context = glContext;
	_glView.enableSetNeedsDisplay = YES;

	[EAGLContext setCurrentContext:glContext];

	// load our shader program code
	NSString *fragmentShaderSource =
		[NSString
			stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"plasma" ofType:@"fsh"]
			encoding:NSUTF8StringEncoding
			error:nil];

	NSString *vertexShaderSource =
		[NSString
			stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"plasma" ofType:@"vsh"]
			encoding:NSUTF8StringEncoding
			error:nil];
	
	// compile and link the shader program
	_program = glCreateProgram();

	GLuint vertexShader = [self compileShader:vertexShaderSource shaderType:GL_VERTEX_SHADER];
	GLuint fragmentShader = [self compileShader:fragmentShaderSource shaderType:GL_FRAGMENT_SHADER];
	glAttachShader(_program, vertexShader);
	glAttachShader(_program, fragmentShader);

	glBindAttribLocation(_program, ESPPlasmaViewGLAttributePosition, "position");
	glBindAttribLocation(_program, ESPPlasmaViewGLAttributeTexCoord, "texCoord");

	glLinkProgram(_program);

	// grab the two uniforms and set the initial viewport
	_timeUniform = glGetUniformLocation(_program, "time");
	glViewport(0, 0, (GLsizei)self.bounds.size.width, (GLsizei)self.bounds.size.height);

	// this is the only program we're going to use, so we can
	// start using it here
	glUseProgram(_program);

	glEnableVertexAttribArray(ESPPlasmaViewGLAttributePosition);
	glEnableVertexAttribArray(ESPPlasmaViewGLAttributeTexCoord);

	// these are clip coordinates that cover the entire viewport
	const GLfloat billboardVertexData[] =
	{
		-1.0f,	-1.0f,	1.0f, 1.0f,
		1.0f,	-1.0f,	1.0f, 1.0f,
		-1.0f,	1.0f,	1.0f, 1.0f,
		1.0f,	1.0f,	1.0f, 1.0f,
	};
	glVertexAttribPointer(ESPPlasmaViewGLAttributePosition, 4, GL_FLOAT, GL_FALSE, 0, (const GLvoid *)billboardVertexData);

	GLfloat texCoordData[] =
	{
		0.0f, 1.0f,
		1.0f, 1.0f,
		0.0f, 0.0f,
		1.0f, 0.0f
	};
	glVertexAttribPointer(ESPPlasmaViewGLAttributeTexCoord, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid *)texCoordData);

	return YES;
}

- (void)dealloc
{
	if(_program)
	{
		glDeleteProgram(_program);
		_program = 0;
	}
}

// very quick shader compiling function; more helpful code would actually
// check the log if a compiling error occurs
- (GLuint)compileShader:(NSString *)source shaderType:(GLenum)shaderType
{
	const char *sourceCString = [source UTF8String];
	
	GLuint shader = glCreateShader(shaderType);
	glShaderSource(shader, 1, &sourceCString, NULL);
	glCompileShader(shader);

	GLint status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);

	if(!status)
	{
		glDeleteShader(shader);
		return 0;
	}

	return shader;
}

- (void)setFrame:(CGRect)frame
{
	// we don't want the GL view to animate during rotations/etc,
	[super setFrame:frame];
	[self setGLViewFrame:frame];
	[_glView.layer removeAllAnimations];
}

- (void)setGLViewFrame:(CGRect)frame
{
	// setFrame: may be called during init for all we know, and glViewport
	// is a vanilla C call so we can't rely on messages to nil being safe
	if(_glView)
	{
		[EAGLContext setCurrentContext:_glView.context];
		glViewport(0, 0, (GLsizei)self.bounds.size.width, (GLsizei)self.bounds.size.height);
		[_glView setNeedsDisplay];
	}
}

- (void)setTime:(NSTimeInterval)time
{
	_time = fmod(time, 1.0);
	[_glView setNeedsDisplay];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	// we also need to push the latest bias
	glUniform1f(_timeUniform, _time);

	// as I'm being a little lazy, we'll just fit a full 0 to 1 range quad
	// to the display area, regardless of the aspect ratio
	GLfloat texCoordData[] =
	{
		0.0f, 1.0f,
		1.0f, 1.0f,
		0.0f, 0.0f,
		1.0f, 0.0f
	};
	glVertexAttribPointer(ESPPlasmaViewGLAttributeTexCoord, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid *)texCoordData);

	// drawing is trivial
	glUseProgram(_program);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
