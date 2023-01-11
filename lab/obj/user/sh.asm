
obj/user/sh.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 80 09 00 00       	call   8009b1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 20 37 80 00       	push   $0x803720
  800060:	e8 85 0a 00 00       	call   800aea <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 2f 37 80 00       	push   $0x80372f
  800084:	e8 61 0a 00 00       	call   800aea <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 3d 37 80 00       	push   $0x80373d
  8000b0:	e8 b5 11 00 00       	call   80126a <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 42 37 80 00       	push   $0x803742
  8000dd:	e8 08 0a 00 00       	call   800aea <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 53 37 80 00       	push   $0x803753
  8000fb:	e8 6a 11 00 00       	call   80126a <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 47 37 80 00       	push   $0x803747
  80012b:	e8 ba 09 00 00       	call   800aea <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 4f 37 80 00       	push   $0x80374f
  800151:	e8 14 11 00 00       	call   80126a <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 5b 37 80 00       	push   $0x80375b
  800180:	e8 65 09 00 00       	call   800aea <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 c8 00 00 00    	je     800309 <runcmd+0x100>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 37 02 00 00    	je     800485 <runcmd+0x27c>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1b 02 00 00       	jmp    800473 <runcmd+0x26a>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 21 01 00 00    	je     800387 <runcmd+0x17e>
  800266:	e9 08 02 00 00       	jmp    800473 <runcmd+0x26a>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 65 37 80 00       	push   $0x803765
  800278:	e8 6d 08 00 00       	call   800aea <cprintf>
				exit();
  80027d:	e8 75 07 00 00       	call   8009f7 <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 a4 38 80 00       	push   $0x8038a4
  8002ac:	e8 39 08 00 00       	call   800aea <cprintf>
				exit();
  8002b1:	e8 41 07 00 00       	call   8009f7 <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then close the original 'fd'.

			// LAB 5: Your code here.
			// panic("< redirection not implemented");

			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 71 20 00 00       	call   802337 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 17                	jns    8002e6 <runcmd+0xdd>
				cprintf("open failed in input redirection\n");
  8002cf:	83 ec 0c             	sub    $0xc,%esp
  8002d2:	68 cc 38 80 00       	push   $0x8038cc
  8002d7:	e8 0e 08 00 00       	call   800aea <cprintf>
				exit();
  8002dc:	e8 16 07 00 00       	call   8009f7 <exit>
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	eb 08                	jmp    8002ee <runcmd+0xe5>
			}

			if (fd != 0) {
  8002e6:	85 c0                	test   %eax,%eax
  8002e8:	0f 84 3c ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002ee:	83 ec 08             	sub    $0x8,%esp
  8002f1:	6a 00                	push   $0x0
  8002f3:	57                   	push   %edi
  8002f4:	e8 d4 1a 00 00       	call   801dcd <dup>
				close(fd);
  8002f9:	89 3c 24             	mov    %edi,(%esp)
  8002fc:	e8 7c 1a 00 00       	call   801d7d <close>
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	e9 21 ff ff ff       	jmp    80022a <runcmd+0x21>

			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	53                   	push   %ebx
  80030d:	6a 00                	push   $0x0
  80030f:	e8 8a fe ff ff       	call   80019e <gettoken>
  800314:	83 c4 10             	add    $0x10,%esp
  800317:	83 f8 77             	cmp    $0x77,%eax
  80031a:	74 15                	je     800331 <runcmd+0x128>
				cprintf("syntax error: > not followed by word\n");
  80031c:	83 ec 0c             	sub    $0xc,%esp
  80031f:	68 f0 38 80 00       	push   $0x8038f0
  800324:	e8 c1 07 00 00       	call   800aea <cprintf>
				exit();
  800329:	e8 c9 06 00 00       	call   8009f7 <exit>
  80032e:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 01 03 00 00       	push   $0x301
  800339:	ff 75 a4             	pushl  -0x5c(%ebp)
  80033c:	e8 f6 1f 00 00       	call   802337 <open>
  800341:	89 c7                	mov    %eax,%edi
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 19                	jns    800363 <runcmd+0x15a>
				cprintf("open %s for write: %e", t, fd);
  80034a:	83 ec 04             	sub    $0x4,%esp
  80034d:	50                   	push   %eax
  80034e:	ff 75 a4             	pushl  -0x5c(%ebp)
  800351:	68 79 37 80 00       	push   $0x803779
  800356:	e8 8f 07 00 00       	call   800aea <cprintf>
				exit();
  80035b:	e8 97 06 00 00       	call   8009f7 <exit>
  800360:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800363:	83 ff 01             	cmp    $0x1,%edi
  800366:	0f 84 be fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	6a 01                	push   $0x1
  800371:	57                   	push   %edi
  800372:	e8 56 1a 00 00       	call   801dcd <dup>
				close(fd);
  800377:	89 3c 24             	mov    %edi,(%esp)
  80037a:	e8 fe 19 00 00       	call   801d7d <close>
  80037f:	83 c4 10             	add    $0x10,%esp
  800382:	e9 a3 fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800387:	83 ec 0c             	sub    $0xc,%esp
  80038a:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800390:	50                   	push   %eax
  800391:	e8 82 2d 00 00       	call   803118 <pipe>
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	85 c0                	test   %eax,%eax
  80039b:	79 16                	jns    8003b3 <runcmd+0x1aa>
				cprintf("pipe: %e", r);
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	50                   	push   %eax
  8003a1:	68 8f 37 80 00       	push   $0x80378f
  8003a6:	e8 3f 07 00 00       	call   800aea <cprintf>
				exit();
  8003ab:	e8 47 06 00 00       	call   8009f7 <exit>
  8003b0:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003ba:	74 1c                	je     8003d8 <runcmd+0x1cf>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003bc:	83 ec 04             	sub    $0x4,%esp
  8003bf:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c5:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cb:	68 98 37 80 00       	push   $0x803798
  8003d0:	e8 15 07 00 00       	call   800aea <cprintf>
  8003d5:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003d8:	e8 f5 14 00 00       	call   8018d2 <fork>
  8003dd:	89 c7                	mov    %eax,%edi
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	79 16                	jns    8003f9 <runcmd+0x1f0>
				cprintf("fork: %e", r);
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	50                   	push   %eax
  8003e7:	68 a5 37 80 00       	push   $0x8037a5
  8003ec:	e8 f9 06 00 00       	call   800aea <cprintf>
				exit();
  8003f1:	e8 01 06 00 00       	call   8009f7 <exit>
  8003f6:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003f9:	85 ff                	test   %edi,%edi
  8003fb:	75 3c                	jne    800439 <runcmd+0x230>
				if (p[0] != 0) {
  8003fd:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	74 1c                	je     800423 <runcmd+0x21a>
					dup(p[0], 0);
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	6a 00                	push   $0x0
  80040c:	50                   	push   %eax
  80040d:	e8 bb 19 00 00       	call   801dcd <dup>
					close(p[0]);
  800412:	83 c4 04             	add    $0x4,%esp
  800415:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041b:	e8 5d 19 00 00       	call   801d7d <close>
  800420:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800423:	83 ec 0c             	sub    $0xc,%esp
  800426:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80042c:	e8 4c 19 00 00       	call   801d7d <close>
				goto again;
  800431:	83 c4 10             	add    $0x10,%esp
  800434:	e9 ec fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800439:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80043f:	83 f8 01             	cmp    $0x1,%eax
  800442:	74 1c                	je     800460 <runcmd+0x257>
					dup(p[1], 1);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	6a 01                	push   $0x1
  800449:	50                   	push   %eax
  80044a:	e8 7e 19 00 00       	call   801dcd <dup>
					close(p[1]);
  80044f:	83 c4 04             	add    $0x4,%esp
  800452:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800458:	e8 20 19 00 00       	call   801d7d <close>
  80045d:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800460:	83 ec 0c             	sub    $0xc,%esp
  800463:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800469:	e8 0f 19 00 00       	call   801d7d <close>
				goto runit;
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb 17                	jmp    80048a <runcmd+0x281>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800473:	50                   	push   %eax
  800474:	68 ae 37 80 00       	push   $0x8037ae
  800479:	6a 7b                	push   $0x7b
  80047b:	68 ca 37 80 00       	push   $0x8037ca
  800480:	e8 8c 05 00 00       	call   800a11 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800485:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048a:	85 f6                	test   %esi,%esi
  80048c:	75 22                	jne    8004b0 <runcmd+0x2a7>
		if (debug)
  80048e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800495:	0f 84 96 01 00 00    	je     800631 <runcmd+0x428>
			cprintf("EMPTY COMMAND\n");
  80049b:	83 ec 0c             	sub    $0xc,%esp
  80049e:	68 d4 37 80 00       	push   $0x8037d4
  8004a3:	e8 42 06 00 00       	call   800aea <cprintf>
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	e9 81 01 00 00       	jmp    800631 <runcmd+0x428>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b0:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b3:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004b6:	74 23                	je     8004db <runcmd+0x2d2>
		argv0buf[0] = '/';
  8004b8:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	50                   	push   %eax
  8004c3:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004c9:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004cf:	50                   	push   %eax
  8004d0:	e8 8d 0c 00 00       	call   801162 <strcpy>
		argv[0] = argv0buf;
  8004d5:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004d8:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004db:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e2:	00 

	// Print the command.
	if (debug) {
  8004e3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ea:	74 49                	je     800535 <runcmd+0x32c>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004ec:	a1 28 54 80 00       	mov    0x805428,%eax
  8004f1:	8b 40 48             	mov    0x48(%eax),%eax
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	50                   	push   %eax
  8004f8:	68 e3 37 80 00       	push   $0x8037e3
  8004fd:	e8 e8 05 00 00       	call   800aea <cprintf>
  800502:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	eb 11                	jmp    80051b <runcmd+0x312>
			cprintf(" %s", argv[i]);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	50                   	push   %eax
  80050e:	68 6b 38 80 00       	push   $0x80386b
  800513:	e8 d2 05 00 00       	call   800aea <cprintf>
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  80051e:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800521:	85 c0                	test   %eax,%eax
  800523:	75 e5                	jne    80050a <runcmd+0x301>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800525:	83 ec 0c             	sub    $0xc,%esp
  800528:	68 40 37 80 00       	push   $0x803740
  80052d:	e8 b8 05 00 00       	call   800aea <cprintf>
  800532:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053b:	50                   	push   %eax
  80053c:	ff 75 a8             	pushl  -0x58(%ebp)
  80053f:	e8 a7 1f 00 00       	call   8024eb <spawn>
  800544:	89 c3                	mov    %eax,%ebx
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 c0                	test   %eax,%eax
  80054b:	0f 89 c3 00 00 00    	jns    800614 <runcmd+0x40b>
		cprintf("spawn %s: %e\n", argv[0], r);
  800551:	83 ec 04             	sub    $0x4,%esp
  800554:	50                   	push   %eax
  800555:	ff 75 a8             	pushl  -0x58(%ebp)
  800558:	68 f1 37 80 00       	push   $0x8037f1
  80055d:	e8 88 05 00 00       	call   800aea <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800562:	e8 41 18 00 00       	call   801da8 <close_all>
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	eb 4c                	jmp    8005b8 <runcmd+0x3af>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80056c:	a1 28 54 80 00       	mov    0x805428,%eax
  800571:	8b 40 48             	mov    0x48(%eax),%eax
  800574:	53                   	push   %ebx
  800575:	ff 75 a8             	pushl  -0x58(%ebp)
  800578:	50                   	push   %eax
  800579:	68 ff 37 80 00       	push   $0x8037ff
  80057e:	e8 67 05 00 00       	call   800aea <cprintf>
  800583:	83 c4 10             	add    $0x10,%esp
		wait(r);
  800586:	83 ec 0c             	sub    $0xc,%esp
  800589:	53                   	push   %ebx
  80058a:	e8 0f 2d 00 00       	call   80329e <wait>
		if (debug)
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800599:	0f 84 8c 00 00 00    	je     80062b <runcmd+0x422>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80059f:	a1 28 54 80 00       	mov    0x805428,%eax
  8005a4:	8b 40 48             	mov    0x48(%eax),%eax
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	50                   	push   %eax
  8005ab:	68 14 38 80 00       	push   $0x803814
  8005b0:	e8 35 05 00 00       	call   800aea <cprintf>
  8005b5:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005b8:	85 ff                	test   %edi,%edi
  8005ba:	74 51                	je     80060d <runcmd+0x404>
		if (debug)
  8005bc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c3:	74 1a                	je     8005df <runcmd+0x3d6>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c5:	a1 28 54 80 00       	mov    0x805428,%eax
  8005ca:	8b 40 48             	mov    0x48(%eax),%eax
  8005cd:	83 ec 04             	sub    $0x4,%esp
  8005d0:	57                   	push   %edi
  8005d1:	50                   	push   %eax
  8005d2:	68 2a 38 80 00       	push   $0x80382a
  8005d7:	e8 0e 05 00 00       	call   800aea <cprintf>
  8005dc:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	57                   	push   %edi
  8005e3:	e8 b6 2c 00 00       	call   80329e <wait>
		if (debug)
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f2:	74 19                	je     80060d <runcmd+0x404>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f4:	a1 28 54 80 00       	mov    0x805428,%eax
  8005f9:	8b 40 48             	mov    0x48(%eax),%eax
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	50                   	push   %eax
  800600:	68 14 38 80 00       	push   $0x803814
  800605:	e8 e0 04 00 00       	call   800aea <cprintf>
  80060a:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  80060d:	e8 e5 03 00 00       	call   8009f7 <exit>
  800612:	eb 1d                	jmp    800631 <runcmd+0x428>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800614:	e8 8f 17 00 00       	call   801da8 <close_all>
	if (r >= 0) {
		if (debug)
  800619:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800620:	0f 84 60 ff ff ff    	je     800586 <runcmd+0x37d>
  800626:	e9 41 ff ff ff       	jmp    80056c <runcmd+0x363>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062b:	85 ff                	test   %edi,%edi
  80062d:	75 b0                	jne    8005df <runcmd+0x3d6>
  80062f:	eb dc                	jmp    80060d <runcmd+0x404>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800631:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800634:	5b                   	pop    %ebx
  800635:	5e                   	pop    %esi
  800636:	5f                   	pop    %edi
  800637:	5d                   	pop    %ebp
  800638:	c3                   	ret    

00800639 <usage>:
}


void
usage(void)
{
  800639:	55                   	push   %ebp
  80063a:	89 e5                	mov    %esp,%ebp
  80063c:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  80063f:	68 18 39 80 00       	push   $0x803918
  800644:	e8 a1 04 00 00       	call   800aea <cprintf>
	exit();
  800649:	e8 a9 03 00 00       	call   8009f7 <exit>
}
  80064e:	83 c4 10             	add    $0x10,%esp
  800651:	c9                   	leave  
  800652:	c3                   	ret    

00800653 <umain>:

void
umain(int argc, char **argv)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
  800656:	57                   	push   %edi
  800657:	56                   	push   %esi
  800658:	53                   	push   %ebx
  800659:	83 ec 30             	sub    $0x30,%esp
  80065c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80065f:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800662:	50                   	push   %eax
  800663:	57                   	push   %edi
  800664:	8d 45 08             	lea    0x8(%ebp),%eax
  800667:	50                   	push   %eax
  800668:	e8 1c 14 00 00       	call   801a89 <argstart>
	while ((r = argnext(&args)) >= 0)
  80066d:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800670:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  800677:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  80067c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80067f:	eb 2f                	jmp    8006b0 <umain+0x5d>
		switch (r) {
  800681:	83 f8 69             	cmp    $0x69,%eax
  800684:	74 25                	je     8006ab <umain+0x58>
  800686:	83 f8 78             	cmp    $0x78,%eax
  800689:	74 07                	je     800692 <umain+0x3f>
  80068b:	83 f8 64             	cmp    $0x64,%eax
  80068e:	75 14                	jne    8006a4 <umain+0x51>
  800690:	eb 09                	jmp    80069b <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800692:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  800699:	eb 15                	jmp    8006b0 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069b:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a2:	eb 0c                	jmp    8006b0 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a4:	e8 90 ff ff ff       	call   800639 <usage>
  8006a9:	eb 05                	jmp    8006b0 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006ab:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	e8 00 14 00 00       	call   801ab9 <argnext>
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	79 c1                	jns    800681 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c0:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c4:	7e 05                	jle    8006cb <umain+0x78>
		usage();
  8006c6:	e8 6e ff ff ff       	call   800639 <usage>
	if (argc == 2) {
  8006cb:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006cf:	75 56                	jne    800727 <umain+0xd4>
		close(0);
  8006d1:	83 ec 0c             	sub    $0xc,%esp
  8006d4:	6a 00                	push   $0x0
  8006d6:	e8 a2 16 00 00       	call   801d7d <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006db:	83 c4 08             	add    $0x8,%esp
  8006de:	6a 00                	push   $0x0
  8006e0:	ff 77 04             	pushl  0x4(%edi)
  8006e3:	e8 4f 1c 00 00       	call   802337 <open>
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	79 1b                	jns    80070a <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006ef:	83 ec 0c             	sub    $0xc,%esp
  8006f2:	50                   	push   %eax
  8006f3:	ff 77 04             	pushl  0x4(%edi)
  8006f6:	68 47 38 80 00       	push   $0x803847
  8006fb:	68 2b 01 00 00       	push   $0x12b
  800700:	68 ca 37 80 00       	push   $0x8037ca
  800705:	e8 07 03 00 00       	call   800a11 <_panic>
		assert(r == 0);
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 19                	je     800727 <umain+0xd4>
  80070e:	68 53 38 80 00       	push   $0x803853
  800713:	68 5a 38 80 00       	push   $0x80385a
  800718:	68 2c 01 00 00       	push   $0x12c
  80071d:	68 ca 37 80 00       	push   $0x8037ca
  800722:	e8 ea 02 00 00       	call   800a11 <_panic>
	}
	if (interactive == '?')
  800727:	83 fe 3f             	cmp    $0x3f,%esi
  80072a:	75 0f                	jne    80073b <umain+0xe8>
		interactive = iscons(0);
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	6a 00                	push   $0x0
  800731:	e8 f5 01 00 00       	call   80092b <iscons>
  800736:	89 c6                	mov    %eax,%esi
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 f6                	test   %esi,%esi
  80073d:	b8 00 00 00 00       	mov    $0x0,%eax
  800742:	bf 6f 38 80 00       	mov    $0x80386f,%edi
  800747:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074a:	83 ec 0c             	sub    $0xc,%esp
  80074d:	57                   	push   %edi
  80074e:	e8 e3 08 00 00       	call   801036 <readline>
  800753:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	85 c0                	test   %eax,%eax
  80075a:	75 1e                	jne    80077a <umain+0x127>
			if (debug)
  80075c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800763:	74 10                	je     800775 <umain+0x122>
				cprintf("EXITING\n");
  800765:	83 ec 0c             	sub    $0xc,%esp
  800768:	68 72 38 80 00       	push   $0x803872
  80076d:	e8 78 03 00 00       	call   800aea <cprintf>
  800772:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800775:	e8 7d 02 00 00       	call   8009f7 <exit>
		}
		if (debug)
  80077a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800781:	74 11                	je     800794 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	53                   	push   %ebx
  800787:	68 7b 38 80 00       	push   $0x80387b
  80078c:	e8 59 03 00 00       	call   800aea <cprintf>
  800791:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800794:	80 3b 23             	cmpb   $0x23,(%ebx)
  800797:	74 b1                	je     80074a <umain+0xf7>
			continue;
		if (echocmds)
  800799:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80079d:	74 11                	je     8007b0 <umain+0x15d>
			printf("# %s\n", buf);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	68 85 38 80 00       	push   $0x803885
  8007a8:	e8 28 1d 00 00       	call   8024d5 <printf>
  8007ad:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b7:	74 10                	je     8007c9 <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007b9:	83 ec 0c             	sub    $0xc,%esp
  8007bc:	68 8b 38 80 00       	push   $0x80388b
  8007c1:	e8 24 03 00 00       	call   800aea <cprintf>
  8007c6:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007c9:	e8 04 11 00 00       	call   8018d2 <fork>
  8007ce:	89 c6                	mov    %eax,%esi
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	79 15                	jns    8007e9 <umain+0x196>
			panic("fork: %e", r);
  8007d4:	50                   	push   %eax
  8007d5:	68 a5 37 80 00       	push   $0x8037a5
  8007da:	68 43 01 00 00       	push   $0x143
  8007df:	68 ca 37 80 00       	push   $0x8037ca
  8007e4:	e8 28 02 00 00       	call   800a11 <_panic>
		if (debug)
  8007e9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f0:	74 11                	je     800803 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	50                   	push   %eax
  8007f6:	68 98 38 80 00       	push   $0x803898
  8007fb:	e8 ea 02 00 00       	call   800aea <cprintf>
  800800:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800803:	85 f6                	test   %esi,%esi
  800805:	75 16                	jne    80081d <umain+0x1ca>
			runcmd(buf);
  800807:	83 ec 0c             	sub    $0xc,%esp
  80080a:	53                   	push   %ebx
  80080b:	e8 f9 f9 ff ff       	call   800209 <runcmd>
			exit();
  800810:	e8 e2 01 00 00       	call   8009f7 <exit>
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	e9 2d ff ff ff       	jmp    80074a <umain+0xf7>
		} else
			wait(r);
  80081d:	83 ec 0c             	sub    $0xc,%esp
  800820:	56                   	push   %esi
  800821:	e8 78 2a 00 00       	call   80329e <wait>
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	e9 1c ff ff ff       	jmp    80074a <umain+0xf7>

0080082e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800831:	b8 00 00 00 00       	mov    $0x0,%eax
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80083e:	68 39 39 80 00       	push   $0x803939
  800843:	ff 75 0c             	pushl  0xc(%ebp)
  800846:	e8 17 09 00 00       	call   801162 <strcpy>
	return 0;
}
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	57                   	push   %edi
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80085e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800863:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800869:	eb 2d                	jmp    800898 <devcons_write+0x46>
		m = n - tot;
  80086b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80086e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800870:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800873:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800878:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087b:	83 ec 04             	sub    $0x4,%esp
  80087e:	53                   	push   %ebx
  80087f:	03 45 0c             	add    0xc(%ebp),%eax
  800882:	50                   	push   %eax
  800883:	57                   	push   %edi
  800884:	e8 6b 0a 00 00       	call   8012f4 <memmove>
		sys_cputs(buf, m);
  800889:	83 c4 08             	add    $0x8,%esp
  80088c:	53                   	push   %ebx
  80088d:	57                   	push   %edi
  80088e:	e8 16 0c 00 00       	call   8014a9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800893:	01 de                	add    %ebx,%esi
  800895:	83 c4 10             	add    $0x10,%esp
  800898:	89 f0                	mov    %esi,%eax
  80089a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80089d:	72 cc                	jb     80086b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80089f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5f                   	pop    %edi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	83 ec 08             	sub    $0x8,%esp
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008b6:	74 2a                	je     8008e2 <devcons_read+0x3b>
  8008b8:	eb 05                	jmp    8008bf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008ba:	e8 87 0c 00 00       	call   801546 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008bf:	e8 03 0c 00 00       	call   8014c7 <sys_cgetc>
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	74 f2                	je     8008ba <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	78 16                	js     8008e2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008cc:	83 f8 04             	cmp    $0x4,%eax
  8008cf:	74 0c                	je     8008dd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d4:	88 02                	mov    %al,(%edx)
	return 1;
  8008d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8008db:	eb 05                	jmp    8008e2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f0:	6a 01                	push   $0x1
  8008f2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f5:	50                   	push   %eax
  8008f6:	e8 ae 0b 00 00       	call   8014a9 <sys_cputs>
}
  8008fb:	83 c4 10             	add    $0x10,%esp
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <getchar>:

int
getchar(void)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800906:	6a 01                	push   $0x1
  800908:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090b:	50                   	push   %eax
  80090c:	6a 00                	push   $0x0
  80090e:	e8 a6 15 00 00       	call   801eb9 <read>
	if (r < 0)
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	85 c0                	test   %eax,%eax
  800918:	78 0f                	js     800929 <getchar+0x29>
		return r;
	if (r < 1)
  80091a:	85 c0                	test   %eax,%eax
  80091c:	7e 06                	jle    800924 <getchar+0x24>
		return -E_EOF;
	return c;
  80091e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800922:	eb 05                	jmp    800929 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800924:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800931:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800934:	50                   	push   %eax
  800935:	ff 75 08             	pushl  0x8(%ebp)
  800938:	e8 16 13 00 00       	call   801c53 <fd_lookup>
  80093d:	83 c4 10             	add    $0x10,%esp
  800940:	85 c0                	test   %eax,%eax
  800942:	78 11                	js     800955 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800947:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80094d:	39 10                	cmp    %edx,(%eax)
  80094f:	0f 94 c0             	sete   %al
  800952:	0f b6 c0             	movzbl %al,%eax
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <opencons>:

int
opencons(void)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80095d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800960:	50                   	push   %eax
  800961:	e8 9e 12 00 00       	call   801c04 <fd_alloc>
  800966:	83 c4 10             	add    $0x10,%esp
		return r;
  800969:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096b:	85 c0                	test   %eax,%eax
  80096d:	78 3e                	js     8009ad <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80096f:	83 ec 04             	sub    $0x4,%esp
  800972:	68 07 04 00 00       	push   $0x407
  800977:	ff 75 f4             	pushl  -0xc(%ebp)
  80097a:	6a 00                	push   $0x0
  80097c:	e8 e4 0b 00 00       	call   801565 <sys_page_alloc>
  800981:	83 c4 10             	add    $0x10,%esp
		return r;
  800984:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800986:	85 c0                	test   %eax,%eax
  800988:	78 23                	js     8009ad <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800990:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800993:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800995:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800998:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80099f:	83 ec 0c             	sub    $0xc,%esp
  8009a2:	50                   	push   %eax
  8009a3:	e8 35 12 00 00       	call   801bdd <fd2num>
  8009a8:	89 c2                	mov    %eax,%edx
  8009aa:	83 c4 10             	add    $0x10,%esp
}
  8009ad:	89 d0                	mov    %edx,%eax
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009bc:	e8 66 0b 00 00       	call   801527 <sys_getenvid>
  8009c1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009c6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009c9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009ce:	a3 28 54 80 00       	mov    %eax,0x805428

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d3:	85 db                	test   %ebx,%ebx
  8009d5:	7e 07                	jle    8009de <libmain+0x2d>
		binaryname = argv[0];
  8009d7:	8b 06                	mov    (%esi),%eax
  8009d9:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009de:	83 ec 08             	sub    $0x8,%esp
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	e8 6b fc ff ff       	call   800653 <umain>

	// exit gracefully
	exit();
  8009e8:	e8 0a 00 00 00       	call   8009f7 <exit>
}
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8009fd:	e8 a6 13 00 00       	call   801da8 <close_all>
	sys_env_destroy(0);
  800a02:	83 ec 0c             	sub    $0xc,%esp
  800a05:	6a 00                	push   $0x0
  800a07:	e8 da 0a 00 00       	call   8014e6 <sys_env_destroy>
}
  800a0c:	83 c4 10             	add    $0x10,%esp
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a16:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a19:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a1f:	e8 03 0b 00 00       	call   801527 <sys_getenvid>
  800a24:	83 ec 0c             	sub    $0xc,%esp
  800a27:	ff 75 0c             	pushl  0xc(%ebp)
  800a2a:	ff 75 08             	pushl  0x8(%ebp)
  800a2d:	56                   	push   %esi
  800a2e:	50                   	push   %eax
  800a2f:	68 50 39 80 00       	push   $0x803950
  800a34:	e8 b1 00 00 00       	call   800aea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a39:	83 c4 18             	add    $0x18,%esp
  800a3c:	53                   	push   %ebx
  800a3d:	ff 75 10             	pushl  0x10(%ebp)
  800a40:	e8 54 00 00 00       	call   800a99 <vcprintf>
	cprintf("\n");
  800a45:	c7 04 24 40 37 80 00 	movl   $0x803740,(%esp)
  800a4c:	e8 99 00 00 00       	call   800aea <cprintf>
  800a51:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a54:	cc                   	int3   
  800a55:	eb fd                	jmp    800a54 <_panic+0x43>

00800a57 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	83 ec 04             	sub    $0x4,%esp
  800a5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a61:	8b 13                	mov    (%ebx),%edx
  800a63:	8d 42 01             	lea    0x1(%edx),%eax
  800a66:	89 03                	mov    %eax,(%ebx)
  800a68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a6f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a74:	75 1a                	jne    800a90 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a76:	83 ec 08             	sub    $0x8,%esp
  800a79:	68 ff 00 00 00       	push   $0xff
  800a7e:	8d 43 08             	lea    0x8(%ebx),%eax
  800a81:	50                   	push   %eax
  800a82:	e8 22 0a 00 00       	call   8014a9 <sys_cputs>
		b->idx = 0;
  800a87:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a8d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a90:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aa9:	00 00 00 
	b.cnt = 0;
  800aac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ab6:	ff 75 0c             	pushl  0xc(%ebp)
  800ab9:	ff 75 08             	pushl  0x8(%ebp)
  800abc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac2:	50                   	push   %eax
  800ac3:	68 57 0a 80 00       	push   $0x800a57
  800ac8:	e8 54 01 00 00       	call   800c21 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800acd:	83 c4 08             	add    $0x8,%esp
  800ad0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ad6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800adc:	50                   	push   %eax
  800add:	e8 c7 09 00 00       	call   8014a9 <sys_cputs>

	return b.cnt;
}
  800ae2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800ae8:	c9                   	leave  
  800ae9:	c3                   	ret    

00800aea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af3:	50                   	push   %eax
  800af4:	ff 75 08             	pushl  0x8(%ebp)
  800af7:	e8 9d ff ff ff       	call   800a99 <vcprintf>
	va_end(ap);

	return cnt;
}
  800afc:	c9                   	leave  
  800afd:	c3                   	ret    

00800afe <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	83 ec 1c             	sub    $0x1c,%esp
  800b07:	89 c7                	mov    %eax,%edi
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b11:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b14:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b17:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b1f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b22:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b25:	39 d3                	cmp    %edx,%ebx
  800b27:	72 05                	jb     800b2e <printnum+0x30>
  800b29:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b2c:	77 45                	ja     800b73 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	ff 75 18             	pushl  0x18(%ebp)
  800b34:	8b 45 14             	mov    0x14(%ebp),%eax
  800b37:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3a:	53                   	push   %ebx
  800b3b:	ff 75 10             	pushl  0x10(%ebp)
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b44:	ff 75 e0             	pushl  -0x20(%ebp)
  800b47:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4a:	ff 75 d8             	pushl  -0x28(%ebp)
  800b4d:	e8 3e 29 00 00       	call   803490 <__udivdi3>
  800b52:	83 c4 18             	add    $0x18,%esp
  800b55:	52                   	push   %edx
  800b56:	50                   	push   %eax
  800b57:	89 f2                	mov    %esi,%edx
  800b59:	89 f8                	mov    %edi,%eax
  800b5b:	e8 9e ff ff ff       	call   800afe <printnum>
  800b60:	83 c4 20             	add    $0x20,%esp
  800b63:	eb 18                	jmp    800b7d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b65:	83 ec 08             	sub    $0x8,%esp
  800b68:	56                   	push   %esi
  800b69:	ff 75 18             	pushl  0x18(%ebp)
  800b6c:	ff d7                	call   *%edi
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	eb 03                	jmp    800b76 <printnum+0x78>
  800b73:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b76:	83 eb 01             	sub    $0x1,%ebx
  800b79:	85 db                	test   %ebx,%ebx
  800b7b:	7f e8                	jg     800b65 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b7d:	83 ec 08             	sub    $0x8,%esp
  800b80:	56                   	push   %esi
  800b81:	83 ec 04             	sub    $0x4,%esp
  800b84:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b87:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8a:	ff 75 dc             	pushl  -0x24(%ebp)
  800b8d:	ff 75 d8             	pushl  -0x28(%ebp)
  800b90:	e8 2b 2a 00 00       	call   8035c0 <__umoddi3>
  800b95:	83 c4 14             	add    $0x14,%esp
  800b98:	0f be 80 73 39 80 00 	movsbl 0x803973(%eax),%eax
  800b9f:	50                   	push   %eax
  800ba0:	ff d7                	call   *%edi
}
  800ba2:	83 c4 10             	add    $0x10,%esp
  800ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bb0:	83 fa 01             	cmp    $0x1,%edx
  800bb3:	7e 0e                	jle    800bc3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bb5:	8b 10                	mov    (%eax),%edx
  800bb7:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bba:	89 08                	mov    %ecx,(%eax)
  800bbc:	8b 02                	mov    (%edx),%eax
  800bbe:	8b 52 04             	mov    0x4(%edx),%edx
  800bc1:	eb 22                	jmp    800be5 <getuint+0x38>
	else if (lflag)
  800bc3:	85 d2                	test   %edx,%edx
  800bc5:	74 10                	je     800bd7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bc7:	8b 10                	mov    (%eax),%edx
  800bc9:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bcc:	89 08                	mov    %ecx,(%eax)
  800bce:	8b 02                	mov    (%edx),%eax
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	eb 0e                	jmp    800be5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bd7:	8b 10                	mov    (%eax),%edx
  800bd9:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bdc:	89 08                	mov    %ecx,(%eax)
  800bde:	8b 02                	mov    (%edx),%eax
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf1:	8b 10                	mov    (%eax),%edx
  800bf3:	3b 50 04             	cmp    0x4(%eax),%edx
  800bf6:	73 0a                	jae    800c02 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bf8:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bfb:	89 08                	mov    %ecx,(%eax)
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	88 02                	mov    %al,(%edx)
}
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c0d:	50                   	push   %eax
  800c0e:	ff 75 10             	pushl  0x10(%ebp)
  800c11:	ff 75 0c             	pushl  0xc(%ebp)
  800c14:	ff 75 08             	pushl  0x8(%ebp)
  800c17:	e8 05 00 00 00       	call   800c21 <vprintfmt>
	va_end(ap);
}
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 2c             	sub    $0x2c,%esp
  800c2a:	8b 75 08             	mov    0x8(%ebp),%esi
  800c2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c30:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c33:	eb 12                	jmp    800c47 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c35:	85 c0                	test   %eax,%eax
  800c37:	0f 84 89 03 00 00    	je     800fc6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c3d:	83 ec 08             	sub    $0x8,%esp
  800c40:	53                   	push   %ebx
  800c41:	50                   	push   %eax
  800c42:	ff d6                	call   *%esi
  800c44:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c47:	83 c7 01             	add    $0x1,%edi
  800c4a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c4e:	83 f8 25             	cmp    $0x25,%eax
  800c51:	75 e2                	jne    800c35 <vprintfmt+0x14>
  800c53:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c57:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c5e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c65:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c71:	eb 07                	jmp    800c7a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c73:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c76:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7a:	8d 47 01             	lea    0x1(%edi),%eax
  800c7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c80:	0f b6 07             	movzbl (%edi),%eax
  800c83:	0f b6 c8             	movzbl %al,%ecx
  800c86:	83 e8 23             	sub    $0x23,%eax
  800c89:	3c 55                	cmp    $0x55,%al
  800c8b:	0f 87 1a 03 00 00    	ja     800fab <vprintfmt+0x38a>
  800c91:	0f b6 c0             	movzbl %al,%eax
  800c94:	ff 24 85 c0 3a 80 00 	jmp    *0x803ac0(,%eax,4)
  800c9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c9e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800ca2:	eb d6                	jmp    800c7a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800caf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cb2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cb6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cb9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cbc:	83 fa 09             	cmp    $0x9,%edx
  800cbf:	77 39                	ja     800cfa <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cc1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cc4:	eb e9                	jmp    800caf <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cc6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc9:	8d 48 04             	lea    0x4(%eax),%ecx
  800ccc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800ccf:	8b 00                	mov    (%eax),%eax
  800cd1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cd7:	eb 27                	jmp    800d00 <vprintfmt+0xdf>
  800cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce3:	0f 49 c8             	cmovns %eax,%ecx
  800ce6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cec:	eb 8c                	jmp    800c7a <vprintfmt+0x59>
  800cee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cf1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cf8:	eb 80                	jmp    800c7a <vprintfmt+0x59>
  800cfa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cfd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d00:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d04:	0f 89 70 ff ff ff    	jns    800c7a <vprintfmt+0x59>
				width = precision, precision = -1;
  800d0a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d10:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d17:	e9 5e ff ff ff       	jmp    800c7a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d1c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d22:	e9 53 ff ff ff       	jmp    800c7a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d27:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2a:	8d 50 04             	lea    0x4(%eax),%edx
  800d2d:	89 55 14             	mov    %edx,0x14(%ebp)
  800d30:	83 ec 08             	sub    $0x8,%esp
  800d33:	53                   	push   %ebx
  800d34:	ff 30                	pushl  (%eax)
  800d36:	ff d6                	call   *%esi
			break;
  800d38:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d3e:	e9 04 ff ff ff       	jmp    800c47 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d43:	8b 45 14             	mov    0x14(%ebp),%eax
  800d46:	8d 50 04             	lea    0x4(%eax),%edx
  800d49:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4c:	8b 00                	mov    (%eax),%eax
  800d4e:	99                   	cltd   
  800d4f:	31 d0                	xor    %edx,%eax
  800d51:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d53:	83 f8 0f             	cmp    $0xf,%eax
  800d56:	7f 0b                	jg     800d63 <vprintfmt+0x142>
  800d58:	8b 14 85 20 3c 80 00 	mov    0x803c20(,%eax,4),%edx
  800d5f:	85 d2                	test   %edx,%edx
  800d61:	75 18                	jne    800d7b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d63:	50                   	push   %eax
  800d64:	68 8b 39 80 00       	push   $0x80398b
  800d69:	53                   	push   %ebx
  800d6a:	56                   	push   %esi
  800d6b:	e8 94 fe ff ff       	call   800c04 <printfmt>
  800d70:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d76:	e9 cc fe ff ff       	jmp    800c47 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d7b:	52                   	push   %edx
  800d7c:	68 6c 38 80 00       	push   $0x80386c
  800d81:	53                   	push   %ebx
  800d82:	56                   	push   %esi
  800d83:	e8 7c fe ff ff       	call   800c04 <printfmt>
  800d88:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d8e:	e9 b4 fe ff ff       	jmp    800c47 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d93:	8b 45 14             	mov    0x14(%ebp),%eax
  800d96:	8d 50 04             	lea    0x4(%eax),%edx
  800d99:	89 55 14             	mov    %edx,0x14(%ebp)
  800d9c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800d9e:	85 ff                	test   %edi,%edi
  800da0:	b8 84 39 80 00       	mov    $0x803984,%eax
  800da5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800da8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dac:	0f 8e 94 00 00 00    	jle    800e46 <vprintfmt+0x225>
  800db2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800db6:	0f 84 98 00 00 00    	je     800e54 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dbc:	83 ec 08             	sub    $0x8,%esp
  800dbf:	ff 75 d0             	pushl  -0x30(%ebp)
  800dc2:	57                   	push   %edi
  800dc3:	e8 79 03 00 00       	call   801141 <strnlen>
  800dc8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dcb:	29 c1                	sub    %eax,%ecx
  800dcd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800dd0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800dd3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800dd7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dda:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800ddd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ddf:	eb 0f                	jmp    800df0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800de1:	83 ec 08             	sub    $0x8,%esp
  800de4:	53                   	push   %ebx
  800de5:	ff 75 e0             	pushl  -0x20(%ebp)
  800de8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800dea:	83 ef 01             	sub    $0x1,%edi
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	85 ff                	test   %edi,%edi
  800df2:	7f ed                	jg     800de1 <vprintfmt+0x1c0>
  800df4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800df7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800dfa:	85 c9                	test   %ecx,%ecx
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800e01:	0f 49 c1             	cmovns %ecx,%eax
  800e04:	29 c1                	sub    %eax,%ecx
  800e06:	89 75 08             	mov    %esi,0x8(%ebp)
  800e09:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e0c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e0f:	89 cb                	mov    %ecx,%ebx
  800e11:	eb 4d                	jmp    800e60 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e13:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e17:	74 1b                	je     800e34 <vprintfmt+0x213>
  800e19:	0f be c0             	movsbl %al,%eax
  800e1c:	83 e8 20             	sub    $0x20,%eax
  800e1f:	83 f8 5e             	cmp    $0x5e,%eax
  800e22:	76 10                	jbe    800e34 <vprintfmt+0x213>
					putch('?', putdat);
  800e24:	83 ec 08             	sub    $0x8,%esp
  800e27:	ff 75 0c             	pushl  0xc(%ebp)
  800e2a:	6a 3f                	push   $0x3f
  800e2c:	ff 55 08             	call   *0x8(%ebp)
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	eb 0d                	jmp    800e41 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	ff 75 0c             	pushl  0xc(%ebp)
  800e3a:	52                   	push   %edx
  800e3b:	ff 55 08             	call   *0x8(%ebp)
  800e3e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e41:	83 eb 01             	sub    $0x1,%ebx
  800e44:	eb 1a                	jmp    800e60 <vprintfmt+0x23f>
  800e46:	89 75 08             	mov    %esi,0x8(%ebp)
  800e49:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e4c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e4f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e52:	eb 0c                	jmp    800e60 <vprintfmt+0x23f>
  800e54:	89 75 08             	mov    %esi,0x8(%ebp)
  800e57:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e5a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e5d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e60:	83 c7 01             	add    $0x1,%edi
  800e63:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e67:	0f be d0             	movsbl %al,%edx
  800e6a:	85 d2                	test   %edx,%edx
  800e6c:	74 23                	je     800e91 <vprintfmt+0x270>
  800e6e:	85 f6                	test   %esi,%esi
  800e70:	78 a1                	js     800e13 <vprintfmt+0x1f2>
  800e72:	83 ee 01             	sub    $0x1,%esi
  800e75:	79 9c                	jns    800e13 <vprintfmt+0x1f2>
  800e77:	89 df                	mov    %ebx,%edi
  800e79:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e7f:	eb 18                	jmp    800e99 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e81:	83 ec 08             	sub    $0x8,%esp
  800e84:	53                   	push   %ebx
  800e85:	6a 20                	push   $0x20
  800e87:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e89:	83 ef 01             	sub    $0x1,%edi
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	eb 08                	jmp    800e99 <vprintfmt+0x278>
  800e91:	89 df                	mov    %ebx,%edi
  800e93:	8b 75 08             	mov    0x8(%ebp),%esi
  800e96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e99:	85 ff                	test   %edi,%edi
  800e9b:	7f e4                	jg     800e81 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ea0:	e9 a2 fd ff ff       	jmp    800c47 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ea5:	83 fa 01             	cmp    $0x1,%edx
  800ea8:	7e 16                	jle    800ec0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800eaa:	8b 45 14             	mov    0x14(%ebp),%eax
  800ead:	8d 50 08             	lea    0x8(%eax),%edx
  800eb0:	89 55 14             	mov    %edx,0x14(%ebp)
  800eb3:	8b 50 04             	mov    0x4(%eax),%edx
  800eb6:	8b 00                	mov    (%eax),%eax
  800eb8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ebb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ebe:	eb 32                	jmp    800ef2 <vprintfmt+0x2d1>
	else if (lflag)
  800ec0:	85 d2                	test   %edx,%edx
  800ec2:	74 18                	je     800edc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800ec4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec7:	8d 50 04             	lea    0x4(%eax),%edx
  800eca:	89 55 14             	mov    %edx,0x14(%ebp)
  800ecd:	8b 00                	mov    (%eax),%eax
  800ecf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ed2:	89 c1                	mov    %eax,%ecx
  800ed4:	c1 f9 1f             	sar    $0x1f,%ecx
  800ed7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800eda:	eb 16                	jmp    800ef2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800edc:	8b 45 14             	mov    0x14(%ebp),%eax
  800edf:	8d 50 04             	lea    0x4(%eax),%edx
  800ee2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ee5:	8b 00                	mov    (%eax),%eax
  800ee7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eea:	89 c1                	mov    %eax,%ecx
  800eec:	c1 f9 1f             	sar    $0x1f,%ecx
  800eef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ef2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ef8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800efd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f01:	79 74                	jns    800f77 <vprintfmt+0x356>
				putch('-', putdat);
  800f03:	83 ec 08             	sub    $0x8,%esp
  800f06:	53                   	push   %ebx
  800f07:	6a 2d                	push   $0x2d
  800f09:	ff d6                	call   *%esi
				num = -(long long) num;
  800f0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f11:	f7 d8                	neg    %eax
  800f13:	83 d2 00             	adc    $0x0,%edx
  800f16:	f7 da                	neg    %edx
  800f18:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f1b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f20:	eb 55                	jmp    800f77 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f22:	8d 45 14             	lea    0x14(%ebp),%eax
  800f25:	e8 83 fc ff ff       	call   800bad <getuint>
			base = 10;
  800f2a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f2f:	eb 46                	jmp    800f77 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800f31:	8d 45 14             	lea    0x14(%ebp),%eax
  800f34:	e8 74 fc ff ff       	call   800bad <getuint>
			base = 8;
  800f39:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f3e:	eb 37                	jmp    800f77 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f40:	83 ec 08             	sub    $0x8,%esp
  800f43:	53                   	push   %ebx
  800f44:	6a 30                	push   $0x30
  800f46:	ff d6                	call   *%esi
			putch('x', putdat);
  800f48:	83 c4 08             	add    $0x8,%esp
  800f4b:	53                   	push   %ebx
  800f4c:	6a 78                	push   $0x78
  800f4e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f50:	8b 45 14             	mov    0x14(%ebp),%eax
  800f53:	8d 50 04             	lea    0x4(%eax),%edx
  800f56:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f59:	8b 00                	mov    (%eax),%eax
  800f5b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f60:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f63:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f68:	eb 0d                	jmp    800f77 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f6a:	8d 45 14             	lea    0x14(%ebp),%eax
  800f6d:	e8 3b fc ff ff       	call   800bad <getuint>
			base = 16;
  800f72:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f77:	83 ec 0c             	sub    $0xc,%esp
  800f7a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800f7e:	57                   	push   %edi
  800f7f:	ff 75 e0             	pushl  -0x20(%ebp)
  800f82:	51                   	push   %ecx
  800f83:	52                   	push   %edx
  800f84:	50                   	push   %eax
  800f85:	89 da                	mov    %ebx,%edx
  800f87:	89 f0                	mov    %esi,%eax
  800f89:	e8 70 fb ff ff       	call   800afe <printnum>
			break;
  800f8e:	83 c4 20             	add    $0x20,%esp
  800f91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f94:	e9 ae fc ff ff       	jmp    800c47 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f99:	83 ec 08             	sub    $0x8,%esp
  800f9c:	53                   	push   %ebx
  800f9d:	51                   	push   %ecx
  800f9e:	ff d6                	call   *%esi
			break;
  800fa0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fa3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fa6:	e9 9c fc ff ff       	jmp    800c47 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	53                   	push   %ebx
  800faf:	6a 25                	push   $0x25
  800fb1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fb3:	83 c4 10             	add    $0x10,%esp
  800fb6:	eb 03                	jmp    800fbb <vprintfmt+0x39a>
  800fb8:	83 ef 01             	sub    $0x1,%edi
  800fbb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fbf:	75 f7                	jne    800fb8 <vprintfmt+0x397>
  800fc1:	e9 81 fc ff ff       	jmp    800c47 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 18             	sub    $0x18,%esp
  800fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fdd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fe1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fe4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	74 26                	je     801015 <vsnprintf+0x47>
  800fef:	85 d2                	test   %edx,%edx
  800ff1:	7e 22                	jle    801015 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ff3:	ff 75 14             	pushl  0x14(%ebp)
  800ff6:	ff 75 10             	pushl  0x10(%ebp)
  800ff9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	68 e7 0b 80 00       	push   $0x800be7
  801002:	e8 1a fc ff ff       	call   800c21 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801007:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80100a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80100d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	eb 05                	jmp    80101a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801015:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801022:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801025:	50                   	push   %eax
  801026:	ff 75 10             	pushl  0x10(%ebp)
  801029:	ff 75 0c             	pushl  0xc(%ebp)
  80102c:	ff 75 08             	pushl  0x8(%ebp)
  80102f:	e8 9a ff ff ff       	call   800fce <vsnprintf>
	va_end(ap);

	return rc;
}
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801042:	85 c0                	test   %eax,%eax
  801044:	74 13                	je     801059 <readline+0x23>
		fprintf(1, "%s", prompt);
  801046:	83 ec 04             	sub    $0x4,%esp
  801049:	50                   	push   %eax
  80104a:	68 6c 38 80 00       	push   $0x80386c
  80104f:	6a 01                	push   $0x1
  801051:	e8 68 14 00 00       	call   8024be <fprintf>
  801056:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	6a 00                	push   $0x0
  80105e:	e8 c8 f8 ff ff       	call   80092b <iscons>
  801063:	89 c7                	mov    %eax,%edi
  801065:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  801068:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80106d:	e8 8e f8 ff ff       	call   800900 <getchar>
  801072:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801074:	85 c0                	test   %eax,%eax
  801076:	79 29                	jns    8010a1 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801078:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80107d:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801080:	0f 84 9b 00 00 00    	je     801121 <readline+0xeb>
				cprintf("read error: %e\n", c);
  801086:	83 ec 08             	sub    $0x8,%esp
  801089:	53                   	push   %ebx
  80108a:	68 7f 3c 80 00       	push   $0x803c7f
  80108f:	e8 56 fa ff ff       	call   800aea <cprintf>
  801094:	83 c4 10             	add    $0x10,%esp
			return NULL;
  801097:	b8 00 00 00 00       	mov    $0x0,%eax
  80109c:	e9 80 00 00 00       	jmp    801121 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010a1:	83 f8 08             	cmp    $0x8,%eax
  8010a4:	0f 94 c2             	sete   %dl
  8010a7:	83 f8 7f             	cmp    $0x7f,%eax
  8010aa:	0f 94 c0             	sete   %al
  8010ad:	08 c2                	or     %al,%dl
  8010af:	74 1a                	je     8010cb <readline+0x95>
  8010b1:	85 f6                	test   %esi,%esi
  8010b3:	7e 16                	jle    8010cb <readline+0x95>
			if (echoing)
  8010b5:	85 ff                	test   %edi,%edi
  8010b7:	74 0d                	je     8010c6 <readline+0x90>
				cputchar('\b');
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	6a 08                	push   $0x8
  8010be:	e8 21 f8 ff ff       	call   8008e4 <cputchar>
  8010c3:	83 c4 10             	add    $0x10,%esp
			i--;
  8010c6:	83 ee 01             	sub    $0x1,%esi
  8010c9:	eb a2                	jmp    80106d <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010cb:	83 fb 1f             	cmp    $0x1f,%ebx
  8010ce:	7e 26                	jle    8010f6 <readline+0xc0>
  8010d0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010d6:	7f 1e                	jg     8010f6 <readline+0xc0>
			if (echoing)
  8010d8:	85 ff                	test   %edi,%edi
  8010da:	74 0c                	je     8010e8 <readline+0xb2>
				cputchar(c);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	53                   	push   %ebx
  8010e0:	e8 ff f7 ff ff       	call   8008e4 <cputchar>
  8010e5:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010e8:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8010ee:	8d 76 01             	lea    0x1(%esi),%esi
  8010f1:	e9 77 ff ff ff       	jmp    80106d <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8010f6:	83 fb 0a             	cmp    $0xa,%ebx
  8010f9:	74 09                	je     801104 <readline+0xce>
  8010fb:	83 fb 0d             	cmp    $0xd,%ebx
  8010fe:	0f 85 69 ff ff ff    	jne    80106d <readline+0x37>
			if (echoing)
  801104:	85 ff                	test   %edi,%edi
  801106:	74 0d                	je     801115 <readline+0xdf>
				cputchar('\n');
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	6a 0a                	push   $0xa
  80110d:	e8 d2 f7 ff ff       	call   8008e4 <cputchar>
  801112:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801115:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80111c:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801121:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
  801134:	eb 03                	jmp    801139 <strlen+0x10>
		n++;
  801136:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801139:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80113d:	75 f7                	jne    801136 <strlen+0xd>
		n++;
	return n;
}
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801147:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80114a:	ba 00 00 00 00       	mov    $0x0,%edx
  80114f:	eb 03                	jmp    801154 <strnlen+0x13>
		n++;
  801151:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801154:	39 c2                	cmp    %eax,%edx
  801156:	74 08                	je     801160 <strnlen+0x1f>
  801158:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80115c:	75 f3                	jne    801151 <strnlen+0x10>
  80115e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	53                   	push   %ebx
  801166:	8b 45 08             	mov    0x8(%ebp),%eax
  801169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	83 c2 01             	add    $0x1,%edx
  801171:	83 c1 01             	add    $0x1,%ecx
  801174:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801178:	88 5a ff             	mov    %bl,-0x1(%edx)
  80117b:	84 db                	test   %bl,%bl
  80117d:	75 ef                	jne    80116e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80117f:	5b                   	pop    %ebx
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    

00801182 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	53                   	push   %ebx
  801186:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801189:	53                   	push   %ebx
  80118a:	e8 9a ff ff ff       	call   801129 <strlen>
  80118f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801192:	ff 75 0c             	pushl  0xc(%ebp)
  801195:	01 d8                	add    %ebx,%eax
  801197:	50                   	push   %eax
  801198:	e8 c5 ff ff ff       	call   801162 <strcpy>
	return dst;
}
  80119d:	89 d8                	mov    %ebx,%eax
  80119f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011af:	89 f3                	mov    %esi,%ebx
  8011b1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011b4:	89 f2                	mov    %esi,%edx
  8011b6:	eb 0f                	jmp    8011c7 <strncpy+0x23>
		*dst++ = *src;
  8011b8:	83 c2 01             	add    $0x1,%edx
  8011bb:	0f b6 01             	movzbl (%ecx),%eax
  8011be:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011c1:	80 39 01             	cmpb   $0x1,(%ecx)
  8011c4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011c7:	39 da                	cmp    %ebx,%edx
  8011c9:	75 ed                	jne    8011b8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011cb:	89 f0                	mov    %esi,%eax
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011dc:	8b 55 10             	mov    0x10(%ebp),%edx
  8011df:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011e1:	85 d2                	test   %edx,%edx
  8011e3:	74 21                	je     801206 <strlcpy+0x35>
  8011e5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8011e9:	89 f2                	mov    %esi,%edx
  8011eb:	eb 09                	jmp    8011f6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8011ed:	83 c2 01             	add    $0x1,%edx
  8011f0:	83 c1 01             	add    $0x1,%ecx
  8011f3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011f6:	39 c2                	cmp    %eax,%edx
  8011f8:	74 09                	je     801203 <strlcpy+0x32>
  8011fa:	0f b6 19             	movzbl (%ecx),%ebx
  8011fd:	84 db                	test   %bl,%bl
  8011ff:	75 ec                	jne    8011ed <strlcpy+0x1c>
  801201:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801203:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801206:	29 f0                	sub    %esi,%eax
}
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801212:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801215:	eb 06                	jmp    80121d <strcmp+0x11>
		p++, q++;
  801217:	83 c1 01             	add    $0x1,%ecx
  80121a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80121d:	0f b6 01             	movzbl (%ecx),%eax
  801220:	84 c0                	test   %al,%al
  801222:	74 04                	je     801228 <strcmp+0x1c>
  801224:	3a 02                	cmp    (%edx),%al
  801226:	74 ef                	je     801217 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801228:	0f b6 c0             	movzbl %al,%eax
  80122b:	0f b6 12             	movzbl (%edx),%edx
  80122e:	29 d0                	sub    %edx,%eax
}
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	53                   	push   %ebx
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123c:	89 c3                	mov    %eax,%ebx
  80123e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801241:	eb 06                	jmp    801249 <strncmp+0x17>
		n--, p++, q++;
  801243:	83 c0 01             	add    $0x1,%eax
  801246:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801249:	39 d8                	cmp    %ebx,%eax
  80124b:	74 15                	je     801262 <strncmp+0x30>
  80124d:	0f b6 08             	movzbl (%eax),%ecx
  801250:	84 c9                	test   %cl,%cl
  801252:	74 04                	je     801258 <strncmp+0x26>
  801254:	3a 0a                	cmp    (%edx),%cl
  801256:	74 eb                	je     801243 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801258:	0f b6 00             	movzbl (%eax),%eax
  80125b:	0f b6 12             	movzbl (%edx),%edx
  80125e:	29 d0                	sub    %edx,%eax
  801260:	eb 05                	jmp    801267 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801267:	5b                   	pop    %ebx
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	8b 45 08             	mov    0x8(%ebp),%eax
  801270:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801274:	eb 07                	jmp    80127d <strchr+0x13>
		if (*s == c)
  801276:	38 ca                	cmp    %cl,%dl
  801278:	74 0f                	je     801289 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80127a:	83 c0 01             	add    $0x1,%eax
  80127d:	0f b6 10             	movzbl (%eax),%edx
  801280:	84 d2                	test   %dl,%dl
  801282:	75 f2                	jne    801276 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801295:	eb 03                	jmp    80129a <strfind+0xf>
  801297:	83 c0 01             	add    $0x1,%eax
  80129a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80129d:	38 ca                	cmp    %cl,%dl
  80129f:	74 04                	je     8012a5 <strfind+0x1a>
  8012a1:	84 d2                	test   %dl,%dl
  8012a3:	75 f2                	jne    801297 <strfind+0xc>
			break;
	return (char *) s;
}
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	57                   	push   %edi
  8012ab:	56                   	push   %esi
  8012ac:	53                   	push   %ebx
  8012ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012b3:	85 c9                	test   %ecx,%ecx
  8012b5:	74 36                	je     8012ed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012bd:	75 28                	jne    8012e7 <memset+0x40>
  8012bf:	f6 c1 03             	test   $0x3,%cl
  8012c2:	75 23                	jne    8012e7 <memset+0x40>
		c &= 0xFF;
  8012c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012c8:	89 d3                	mov    %edx,%ebx
  8012ca:	c1 e3 08             	shl    $0x8,%ebx
  8012cd:	89 d6                	mov    %edx,%esi
  8012cf:	c1 e6 18             	shl    $0x18,%esi
  8012d2:	89 d0                	mov    %edx,%eax
  8012d4:	c1 e0 10             	shl    $0x10,%eax
  8012d7:	09 f0                	or     %esi,%eax
  8012d9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012db:	89 d8                	mov    %ebx,%eax
  8012dd:	09 d0                	or     %edx,%eax
  8012df:	c1 e9 02             	shr    $0x2,%ecx
  8012e2:	fc                   	cld    
  8012e3:	f3 ab                	rep stos %eax,%es:(%edi)
  8012e5:	eb 06                	jmp    8012ed <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ea:	fc                   	cld    
  8012eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012ed:	89 f8                	mov    %edi,%eax
  8012ef:	5b                   	pop    %ebx
  8012f0:	5e                   	pop    %esi
  8012f1:	5f                   	pop    %edi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    

008012f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	57                   	push   %edi
  8012f8:	56                   	push   %esi
  8012f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801302:	39 c6                	cmp    %eax,%esi
  801304:	73 35                	jae    80133b <memmove+0x47>
  801306:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801309:	39 d0                	cmp    %edx,%eax
  80130b:	73 2e                	jae    80133b <memmove+0x47>
		s += n;
		d += n;
  80130d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801310:	89 d6                	mov    %edx,%esi
  801312:	09 fe                	or     %edi,%esi
  801314:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80131a:	75 13                	jne    80132f <memmove+0x3b>
  80131c:	f6 c1 03             	test   $0x3,%cl
  80131f:	75 0e                	jne    80132f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801321:	83 ef 04             	sub    $0x4,%edi
  801324:	8d 72 fc             	lea    -0x4(%edx),%esi
  801327:	c1 e9 02             	shr    $0x2,%ecx
  80132a:	fd                   	std    
  80132b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80132d:	eb 09                	jmp    801338 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80132f:	83 ef 01             	sub    $0x1,%edi
  801332:	8d 72 ff             	lea    -0x1(%edx),%esi
  801335:	fd                   	std    
  801336:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801338:	fc                   	cld    
  801339:	eb 1d                	jmp    801358 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80133b:	89 f2                	mov    %esi,%edx
  80133d:	09 c2                	or     %eax,%edx
  80133f:	f6 c2 03             	test   $0x3,%dl
  801342:	75 0f                	jne    801353 <memmove+0x5f>
  801344:	f6 c1 03             	test   $0x3,%cl
  801347:	75 0a                	jne    801353 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801349:	c1 e9 02             	shr    $0x2,%ecx
  80134c:	89 c7                	mov    %eax,%edi
  80134e:	fc                   	cld    
  80134f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801351:	eb 05                	jmp    801358 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801353:	89 c7                	mov    %eax,%edi
  801355:	fc                   	cld    
  801356:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801358:	5e                   	pop    %esi
  801359:	5f                   	pop    %edi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80135f:	ff 75 10             	pushl  0x10(%ebp)
  801362:	ff 75 0c             	pushl  0xc(%ebp)
  801365:	ff 75 08             	pushl  0x8(%ebp)
  801368:	e8 87 ff ff ff       	call   8012f4 <memmove>
}
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	8b 45 08             	mov    0x8(%ebp),%eax
  801377:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137a:	89 c6                	mov    %eax,%esi
  80137c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80137f:	eb 1a                	jmp    80139b <memcmp+0x2c>
		if (*s1 != *s2)
  801381:	0f b6 08             	movzbl (%eax),%ecx
  801384:	0f b6 1a             	movzbl (%edx),%ebx
  801387:	38 d9                	cmp    %bl,%cl
  801389:	74 0a                	je     801395 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80138b:	0f b6 c1             	movzbl %cl,%eax
  80138e:	0f b6 db             	movzbl %bl,%ebx
  801391:	29 d8                	sub    %ebx,%eax
  801393:	eb 0f                	jmp    8013a4 <memcmp+0x35>
		s1++, s2++;
  801395:	83 c0 01             	add    $0x1,%eax
  801398:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80139b:	39 f0                	cmp    %esi,%eax
  80139d:	75 e2                	jne    801381 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80139f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013af:	89 c1                	mov    %eax,%ecx
  8013b1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013b4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013b8:	eb 0a                	jmp    8013c4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013ba:	0f b6 10             	movzbl (%eax),%edx
  8013bd:	39 da                	cmp    %ebx,%edx
  8013bf:	74 07                	je     8013c8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013c1:	83 c0 01             	add    $0x1,%eax
  8013c4:	39 c8                	cmp    %ecx,%eax
  8013c6:	72 f2                	jb     8013ba <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013c8:	5b                   	pop    %ebx
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	57                   	push   %edi
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013d7:	eb 03                	jmp    8013dc <strtol+0x11>
		s++;
  8013d9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013dc:	0f b6 01             	movzbl (%ecx),%eax
  8013df:	3c 20                	cmp    $0x20,%al
  8013e1:	74 f6                	je     8013d9 <strtol+0xe>
  8013e3:	3c 09                	cmp    $0x9,%al
  8013e5:	74 f2                	je     8013d9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013e7:	3c 2b                	cmp    $0x2b,%al
  8013e9:	75 0a                	jne    8013f5 <strtol+0x2a>
		s++;
  8013eb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8013f3:	eb 11                	jmp    801406 <strtol+0x3b>
  8013f5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8013fa:	3c 2d                	cmp    $0x2d,%al
  8013fc:	75 08                	jne    801406 <strtol+0x3b>
		s++, neg = 1;
  8013fe:	83 c1 01             	add    $0x1,%ecx
  801401:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801406:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80140c:	75 15                	jne    801423 <strtol+0x58>
  80140e:	80 39 30             	cmpb   $0x30,(%ecx)
  801411:	75 10                	jne    801423 <strtol+0x58>
  801413:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801417:	75 7c                	jne    801495 <strtol+0xca>
		s += 2, base = 16;
  801419:	83 c1 02             	add    $0x2,%ecx
  80141c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801421:	eb 16                	jmp    801439 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801423:	85 db                	test   %ebx,%ebx
  801425:	75 12                	jne    801439 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801427:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80142c:	80 39 30             	cmpb   $0x30,(%ecx)
  80142f:	75 08                	jne    801439 <strtol+0x6e>
		s++, base = 8;
  801431:	83 c1 01             	add    $0x1,%ecx
  801434:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801439:	b8 00 00 00 00       	mov    $0x0,%eax
  80143e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801441:	0f b6 11             	movzbl (%ecx),%edx
  801444:	8d 72 d0             	lea    -0x30(%edx),%esi
  801447:	89 f3                	mov    %esi,%ebx
  801449:	80 fb 09             	cmp    $0x9,%bl
  80144c:	77 08                	ja     801456 <strtol+0x8b>
			dig = *s - '0';
  80144e:	0f be d2             	movsbl %dl,%edx
  801451:	83 ea 30             	sub    $0x30,%edx
  801454:	eb 22                	jmp    801478 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801456:	8d 72 9f             	lea    -0x61(%edx),%esi
  801459:	89 f3                	mov    %esi,%ebx
  80145b:	80 fb 19             	cmp    $0x19,%bl
  80145e:	77 08                	ja     801468 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801460:	0f be d2             	movsbl %dl,%edx
  801463:	83 ea 57             	sub    $0x57,%edx
  801466:	eb 10                	jmp    801478 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801468:	8d 72 bf             	lea    -0x41(%edx),%esi
  80146b:	89 f3                	mov    %esi,%ebx
  80146d:	80 fb 19             	cmp    $0x19,%bl
  801470:	77 16                	ja     801488 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801472:	0f be d2             	movsbl %dl,%edx
  801475:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801478:	3b 55 10             	cmp    0x10(%ebp),%edx
  80147b:	7d 0b                	jge    801488 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80147d:	83 c1 01             	add    $0x1,%ecx
  801480:	0f af 45 10          	imul   0x10(%ebp),%eax
  801484:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801486:	eb b9                	jmp    801441 <strtol+0x76>

	if (endptr)
  801488:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80148c:	74 0d                	je     80149b <strtol+0xd0>
		*endptr = (char *) s;
  80148e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801491:	89 0e                	mov    %ecx,(%esi)
  801493:	eb 06                	jmp    80149b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801495:	85 db                	test   %ebx,%ebx
  801497:	74 98                	je     801431 <strtol+0x66>
  801499:	eb 9e                	jmp    801439 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	f7 da                	neg    %edx
  80149f:	85 ff                	test   %edi,%edi
  8014a1:	0f 45 c2             	cmovne %edx,%eax
}
  8014a4:	5b                   	pop    %ebx
  8014a5:	5e                   	pop    %esi
  8014a6:	5f                   	pop    %edi
  8014a7:	5d                   	pop    %ebp
  8014a8:	c3                   	ret    

008014a9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	57                   	push   %edi
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014af:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ba:	89 c3                	mov    %eax,%ebx
  8014bc:	89 c7                	mov    %eax,%edi
  8014be:	89 c6                	mov    %eax,%esi
  8014c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014c2:	5b                   	pop    %ebx
  8014c3:	5e                   	pop    %esi
  8014c4:	5f                   	pop    %edi
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	57                   	push   %edi
  8014cb:	56                   	push   %esi
  8014cc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d7:	89 d1                	mov    %edx,%ecx
  8014d9:	89 d3                	mov    %edx,%ebx
  8014db:	89 d7                	mov    %edx,%edi
  8014dd:	89 d6                	mov    %edx,%esi
  8014df:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014e1:	5b                   	pop    %ebx
  8014e2:	5e                   	pop    %esi
  8014e3:	5f                   	pop    %edi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    

008014e6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	57                   	push   %edi
  8014ea:	56                   	push   %esi
  8014eb:	53                   	push   %ebx
  8014ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8014f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fc:	89 cb                	mov    %ecx,%ebx
  8014fe:	89 cf                	mov    %ecx,%edi
  801500:	89 ce                	mov    %ecx,%esi
  801502:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801504:	85 c0                	test   %eax,%eax
  801506:	7e 17                	jle    80151f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801508:	83 ec 0c             	sub    $0xc,%esp
  80150b:	50                   	push   %eax
  80150c:	6a 03                	push   $0x3
  80150e:	68 8f 3c 80 00       	push   $0x803c8f
  801513:	6a 23                	push   $0x23
  801515:	68 ac 3c 80 00       	push   $0x803cac
  80151a:	e8 f2 f4 ff ff       	call   800a11 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80151f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801522:	5b                   	pop    %ebx
  801523:	5e                   	pop    %esi
  801524:	5f                   	pop    %edi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	57                   	push   %edi
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80152d:	ba 00 00 00 00       	mov    $0x0,%edx
  801532:	b8 02 00 00 00       	mov    $0x2,%eax
  801537:	89 d1                	mov    %edx,%ecx
  801539:	89 d3                	mov    %edx,%ebx
  80153b:	89 d7                	mov    %edx,%edi
  80153d:	89 d6                	mov    %edx,%esi
  80153f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5f                   	pop    %edi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    

00801546 <sys_yield>:

void
sys_yield(void)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	57                   	push   %edi
  80154a:	56                   	push   %esi
  80154b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80154c:	ba 00 00 00 00       	mov    $0x0,%edx
  801551:	b8 0b 00 00 00       	mov    $0xb,%eax
  801556:	89 d1                	mov    %edx,%ecx
  801558:	89 d3                	mov    %edx,%ebx
  80155a:	89 d7                	mov    %edx,%edi
  80155c:	89 d6                	mov    %edx,%esi
  80155e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801560:	5b                   	pop    %ebx
  801561:	5e                   	pop    %esi
  801562:	5f                   	pop    %edi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	57                   	push   %edi
  801569:	56                   	push   %esi
  80156a:	53                   	push   %ebx
  80156b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80156e:	be 00 00 00 00       	mov    $0x0,%esi
  801573:	b8 04 00 00 00       	mov    $0x4,%eax
  801578:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157b:	8b 55 08             	mov    0x8(%ebp),%edx
  80157e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801581:	89 f7                	mov    %esi,%edi
  801583:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801585:	85 c0                	test   %eax,%eax
  801587:	7e 17                	jle    8015a0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801589:	83 ec 0c             	sub    $0xc,%esp
  80158c:	50                   	push   %eax
  80158d:	6a 04                	push   $0x4
  80158f:	68 8f 3c 80 00       	push   $0x803c8f
  801594:	6a 23                	push   $0x23
  801596:	68 ac 3c 80 00       	push   $0x803cac
  80159b:	e8 71 f4 ff ff       	call   800a11 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a3:	5b                   	pop    %ebx
  8015a4:	5e                   	pop    %esi
  8015a5:	5f                   	pop    %edi
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    

008015a8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	57                   	push   %edi
  8015ac:	56                   	push   %esi
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8015b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8015bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015c2:	8b 75 18             	mov    0x18(%ebp),%esi
  8015c5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	7e 17                	jle    8015e2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015cb:	83 ec 0c             	sub    $0xc,%esp
  8015ce:	50                   	push   %eax
  8015cf:	6a 05                	push   $0x5
  8015d1:	68 8f 3c 80 00       	push   $0x803c8f
  8015d6:	6a 23                	push   $0x23
  8015d8:	68 ac 3c 80 00       	push   $0x803cac
  8015dd:	e8 2f f4 ff ff       	call   800a11 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e5:	5b                   	pop    %ebx
  8015e6:	5e                   	pop    %esi
  8015e7:	5f                   	pop    %edi
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    

008015ea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	57                   	push   %edi
  8015ee:	56                   	push   %esi
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8015fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801600:	8b 55 08             	mov    0x8(%ebp),%edx
  801603:	89 df                	mov    %ebx,%edi
  801605:	89 de                	mov    %ebx,%esi
  801607:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801609:	85 c0                	test   %eax,%eax
  80160b:	7e 17                	jle    801624 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80160d:	83 ec 0c             	sub    $0xc,%esp
  801610:	50                   	push   %eax
  801611:	6a 06                	push   $0x6
  801613:	68 8f 3c 80 00       	push   $0x803c8f
  801618:	6a 23                	push   $0x23
  80161a:	68 ac 3c 80 00       	push   $0x803cac
  80161f:	e8 ed f3 ff ff       	call   800a11 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801624:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801627:	5b                   	pop    %ebx
  801628:	5e                   	pop    %esi
  801629:	5f                   	pop    %edi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    

0080162c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	57                   	push   %edi
  801630:	56                   	push   %esi
  801631:	53                   	push   %ebx
  801632:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801635:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163a:	b8 08 00 00 00       	mov    $0x8,%eax
  80163f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801642:	8b 55 08             	mov    0x8(%ebp),%edx
  801645:	89 df                	mov    %ebx,%edi
  801647:	89 de                	mov    %ebx,%esi
  801649:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80164b:	85 c0                	test   %eax,%eax
  80164d:	7e 17                	jle    801666 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80164f:	83 ec 0c             	sub    $0xc,%esp
  801652:	50                   	push   %eax
  801653:	6a 08                	push   $0x8
  801655:	68 8f 3c 80 00       	push   $0x803c8f
  80165a:	6a 23                	push   $0x23
  80165c:	68 ac 3c 80 00       	push   $0x803cac
  801661:	e8 ab f3 ff ff       	call   800a11 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801669:	5b                   	pop    %ebx
  80166a:	5e                   	pop    %esi
  80166b:	5f                   	pop    %edi
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	57                   	push   %edi
  801672:	56                   	push   %esi
  801673:	53                   	push   %ebx
  801674:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801677:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167c:	b8 09 00 00 00       	mov    $0x9,%eax
  801681:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801684:	8b 55 08             	mov    0x8(%ebp),%edx
  801687:	89 df                	mov    %ebx,%edi
  801689:	89 de                	mov    %ebx,%esi
  80168b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80168d:	85 c0                	test   %eax,%eax
  80168f:	7e 17                	jle    8016a8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801691:	83 ec 0c             	sub    $0xc,%esp
  801694:	50                   	push   %eax
  801695:	6a 09                	push   $0x9
  801697:	68 8f 3c 80 00       	push   $0x803c8f
  80169c:	6a 23                	push   $0x23
  80169e:	68 ac 3c 80 00       	push   $0x803cac
  8016a3:	e8 69 f3 ff ff       	call   800a11 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5f                   	pop    %edi
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	57                   	push   %edi
  8016b4:	56                   	push   %esi
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c9:	89 df                	mov    %ebx,%edi
  8016cb:	89 de                	mov    %ebx,%esi
  8016cd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	7e 17                	jle    8016ea <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	50                   	push   %eax
  8016d7:	6a 0a                	push   $0xa
  8016d9:	68 8f 3c 80 00       	push   $0x803c8f
  8016de:	6a 23                	push   $0x23
  8016e0:	68 ac 3c 80 00       	push   $0x803cac
  8016e5:	e8 27 f3 ff ff       	call   800a11 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5f                   	pop    %edi
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	57                   	push   %edi
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016f8:	be 00 00 00 00       	mov    $0x0,%esi
  8016fd:	b8 0c 00 00 00       	mov    $0xc,%eax
  801702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801705:	8b 55 08             	mov    0x8(%ebp),%edx
  801708:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80170b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80170e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801710:	5b                   	pop    %ebx
  801711:	5e                   	pop    %esi
  801712:	5f                   	pop    %edi
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	57                   	push   %edi
  801719:	56                   	push   %esi
  80171a:	53                   	push   %ebx
  80171b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80171e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801723:	b8 0d 00 00 00       	mov    $0xd,%eax
  801728:	8b 55 08             	mov    0x8(%ebp),%edx
  80172b:	89 cb                	mov    %ecx,%ebx
  80172d:	89 cf                	mov    %ecx,%edi
  80172f:	89 ce                	mov    %ecx,%esi
  801731:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801733:	85 c0                	test   %eax,%eax
  801735:	7e 17                	jle    80174e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801737:	83 ec 0c             	sub    $0xc,%esp
  80173a:	50                   	push   %eax
  80173b:	6a 0d                	push   $0xd
  80173d:	68 8f 3c 80 00       	push   $0x803c8f
  801742:	6a 23                	push   $0x23
  801744:	68 ac 3c 80 00       	push   $0x803cac
  801749:	e8 c3 f2 ff ff       	call   800a11 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80174e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801751:	5b                   	pop    %ebx
  801752:	5e                   	pop    %esi
  801753:	5f                   	pop    %edi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	57                   	push   %edi
  80175a:	56                   	push   %esi
  80175b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80175c:	ba 00 00 00 00       	mov    $0x0,%edx
  801761:	b8 0e 00 00 00       	mov    $0xe,%eax
  801766:	89 d1                	mov    %edx,%ecx
  801768:	89 d3                	mov    %edx,%ebx
  80176a:	89 d7                	mov    %edx,%edi
  80176c:	89 d6                	mov    %edx,%esi
  80176e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801770:	5b                   	pop    %ebx
  801771:	5e                   	pop    %esi
  801772:	5f                   	pop    %edi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	57                   	push   %edi
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
  80177b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80177e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801783:	b8 0f 00 00 00       	mov    $0xf,%eax
  801788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178b:	8b 55 08             	mov    0x8(%ebp),%edx
  80178e:	89 df                	mov    %ebx,%edi
  801790:	89 de                	mov    %ebx,%esi
  801792:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801794:	85 c0                	test   %eax,%eax
  801796:	7e 17                	jle    8017af <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801798:	83 ec 0c             	sub    $0xc,%esp
  80179b:	50                   	push   %eax
  80179c:	6a 0f                	push   $0xf
  80179e:	68 8f 3c 80 00       	push   $0x803c8f
  8017a3:	6a 23                	push   $0x23
  8017a5:	68 ac 3c 80 00       	push   $0x803cac
  8017aa:	e8 62 f2 ff ff       	call   800a11 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8017af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5f                   	pop    %edi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	57                   	push   %edi
  8017bb:	56                   	push   %esi
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8017ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d0:	89 df                	mov    %ebx,%edi
  8017d2:	89 de                	mov    %ebx,%esi
  8017d4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	7e 17                	jle    8017f1 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017da:	83 ec 0c             	sub    $0xc,%esp
  8017dd:	50                   	push   %eax
  8017de:	6a 10                	push   $0x10
  8017e0:	68 8f 3c 80 00       	push   $0x803c8f
  8017e5:	6a 23                	push   $0x23
  8017e7:	68 ac 3c 80 00       	push   $0x803cac
  8017ec:	e8 20 f2 ff ff       	call   800a11 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8017f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	5f                   	pop    %edi
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    

008017f9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	56                   	push   %esi
  8017fd:	53                   	push   %ebx
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801801:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  801803:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801807:	75 25                	jne    80182e <pgfault+0x35>
  801809:	89 d8                	mov    %ebx,%eax
  80180b:	c1 e8 0c             	shr    $0xc,%eax
  80180e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801815:	f6 c4 08             	test   $0x8,%ah
  801818:	75 14                	jne    80182e <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	68 bc 3c 80 00       	push   $0x803cbc
  801822:	6a 1e                	push   $0x1e
  801824:	68 50 3d 80 00       	push   $0x803d50
  801829:	e8 e3 f1 ff ff       	call   800a11 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  80182e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  801834:	e8 ee fc ff ff       	call   801527 <sys_getenvid>
  801839:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  80183b:	83 ec 04             	sub    $0x4,%esp
  80183e:	6a 07                	push   $0x7
  801840:	68 00 f0 7f 00       	push   $0x7ff000
  801845:	50                   	push   %eax
  801846:	e8 1a fd ff ff       	call   801565 <sys_page_alloc>
	if (r < 0)
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	79 12                	jns    801864 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  801852:	50                   	push   %eax
  801853:	68 e8 3c 80 00       	push   $0x803ce8
  801858:	6a 33                	push   $0x33
  80185a:	68 50 3d 80 00       	push   $0x803d50
  80185f:	e8 ad f1 ff ff       	call   800a11 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  801864:	83 ec 04             	sub    $0x4,%esp
  801867:	68 00 10 00 00       	push   $0x1000
  80186c:	53                   	push   %ebx
  80186d:	68 00 f0 7f 00       	push   $0x7ff000
  801872:	e8 e5 fa ff ff       	call   80135c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  801877:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80187e:	53                   	push   %ebx
  80187f:	56                   	push   %esi
  801880:	68 00 f0 7f 00       	push   $0x7ff000
  801885:	56                   	push   %esi
  801886:	e8 1d fd ff ff       	call   8015a8 <sys_page_map>
	if (r < 0)
  80188b:	83 c4 20             	add    $0x20,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	79 12                	jns    8018a4 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  801892:	50                   	push   %eax
  801893:	68 0c 3d 80 00       	push   $0x803d0c
  801898:	6a 3b                	push   $0x3b
  80189a:	68 50 3d 80 00       	push   $0x803d50
  80189f:	e8 6d f1 ff ff       	call   800a11 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	68 00 f0 7f 00       	push   $0x7ff000
  8018ac:	56                   	push   %esi
  8018ad:	e8 38 fd ff ff       	call   8015ea <sys_page_unmap>
	if (r < 0)
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	79 12                	jns    8018cb <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  8018b9:	50                   	push   %eax
  8018ba:	68 30 3d 80 00       	push   $0x803d30
  8018bf:	6a 40                	push   $0x40
  8018c1:	68 50 3d 80 00       	push   $0x803d50
  8018c6:	e8 46 f1 ff ff       	call   800a11 <_panic>
}
  8018cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ce:	5b                   	pop    %ebx
  8018cf:	5e                   	pop    %esi
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	57                   	push   %edi
  8018d6:	56                   	push   %esi
  8018d7:	53                   	push   %ebx
  8018d8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  8018db:	68 f9 17 80 00       	push   $0x8017f9
  8018e0:	e8 08 1a 00 00       	call   8032ed <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018e5:	b8 07 00 00 00       	mov    $0x7,%eax
  8018ea:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	0f 88 64 01 00 00    	js     801a5b <fork+0x189>
  8018f7:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8018fc:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  801901:	85 c0                	test   %eax,%eax
  801903:	75 21                	jne    801926 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801905:	e8 1d fc ff ff       	call   801527 <sys_getenvid>
  80190a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80190f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801912:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801917:	a3 28 54 80 00       	mov    %eax,0x805428
        return 0;
  80191c:	ba 00 00 00 00       	mov    $0x0,%edx
  801921:	e9 3f 01 00 00       	jmp    801a65 <fork+0x193>
  801926:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801929:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80192b:	89 d8                	mov    %ebx,%eax
  80192d:	c1 e8 16             	shr    $0x16,%eax
  801930:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801937:	a8 01                	test   $0x1,%al
  801939:	0f 84 bd 00 00 00    	je     8019fc <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80193f:	89 d8                	mov    %ebx,%eax
  801941:	c1 e8 0c             	shr    $0xc,%eax
  801944:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80194b:	f6 c2 01             	test   $0x1,%dl
  80194e:	0f 84 a8 00 00 00    	je     8019fc <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801954:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80195b:	a8 04                	test   $0x4,%al
  80195d:	0f 84 99 00 00 00    	je     8019fc <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801963:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80196a:	f6 c4 04             	test   $0x4,%ah
  80196d:	74 17                	je     801986 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80196f:	83 ec 0c             	sub    $0xc,%esp
  801972:	68 07 0e 00 00       	push   $0xe07
  801977:	53                   	push   %ebx
  801978:	57                   	push   %edi
  801979:	53                   	push   %ebx
  80197a:	6a 00                	push   $0x0
  80197c:	e8 27 fc ff ff       	call   8015a8 <sys_page_map>
  801981:	83 c4 20             	add    $0x20,%esp
  801984:	eb 76                	jmp    8019fc <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801986:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80198d:	a8 02                	test   $0x2,%al
  80198f:	75 0c                	jne    80199d <fork+0xcb>
  801991:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801998:	f6 c4 08             	test   $0x8,%ah
  80199b:	74 3f                	je     8019dc <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	68 05 08 00 00       	push   $0x805
  8019a5:	53                   	push   %ebx
  8019a6:	57                   	push   %edi
  8019a7:	53                   	push   %ebx
  8019a8:	6a 00                	push   $0x0
  8019aa:	e8 f9 fb ff ff       	call   8015a8 <sys_page_map>
		if (r < 0)
  8019af:	83 c4 20             	add    $0x20,%esp
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	0f 88 a5 00 00 00    	js     801a5f <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	68 05 08 00 00       	push   $0x805
  8019c2:	53                   	push   %ebx
  8019c3:	6a 00                	push   $0x0
  8019c5:	53                   	push   %ebx
  8019c6:	6a 00                	push   $0x0
  8019c8:	e8 db fb ff ff       	call   8015a8 <sys_page_map>
  8019cd:	83 c4 20             	add    $0x20,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019d7:	0f 4f c1             	cmovg  %ecx,%eax
  8019da:	eb 1c                	jmp    8019f8 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	6a 05                	push   $0x5
  8019e1:	53                   	push   %ebx
  8019e2:	57                   	push   %edi
  8019e3:	53                   	push   %ebx
  8019e4:	6a 00                	push   $0x0
  8019e6:	e8 bd fb ff ff       	call   8015a8 <sys_page_map>
  8019eb:	83 c4 20             	add    $0x20,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019f5:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 67                	js     801a63 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8019fc:	83 c6 01             	add    $0x1,%esi
  8019ff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a05:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801a0b:	0f 85 1a ff ff ff    	jne    80192b <fork+0x59>
  801a11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801a14:	83 ec 04             	sub    $0x4,%esp
  801a17:	6a 07                	push   $0x7
  801a19:	68 00 f0 bf ee       	push   $0xeebff000
  801a1e:	57                   	push   %edi
  801a1f:	e8 41 fb ff ff       	call   801565 <sys_page_alloc>
	if (r < 0)
  801a24:	83 c4 10             	add    $0x10,%esp
		return r;
  801a27:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 38                	js     801a65 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801a2d:	83 ec 08             	sub    $0x8,%esp
  801a30:	68 34 33 80 00       	push   $0x803334
  801a35:	57                   	push   %edi
  801a36:	e8 75 fc ff ff       	call   8016b0 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801a3b:	83 c4 10             	add    $0x10,%esp
		return r;
  801a3e:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 21                	js     801a65 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	6a 02                	push   $0x2
  801a49:	57                   	push   %edi
  801a4a:	e8 dd fb ff ff       	call   80162c <sys_env_set_status>
	if (r < 0)
  801a4f:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801a52:	85 c0                	test   %eax,%eax
  801a54:	0f 48 f8             	cmovs  %eax,%edi
  801a57:	89 fa                	mov    %edi,%edx
  801a59:	eb 0a                	jmp    801a65 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801a5b:	89 c2                	mov    %eax,%edx
  801a5d:	eb 06                	jmp    801a65 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801a5f:	89 c2                	mov    %eax,%edx
  801a61:	eb 02                	jmp    801a65 <fork+0x193>
  801a63:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801a65:	89 d0                	mov    %edx,%eax
  801a67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5f                   	pop    %edi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <sfork>:

// Challenge!
int
sfork(void)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a75:	68 5b 3d 80 00       	push   $0x803d5b
  801a7a:	68 c9 00 00 00       	push   $0xc9
  801a7f:	68 50 3d 80 00       	push   $0x803d50
  801a84:	e8 88 ef ff ff       	call   800a11 <_panic>

00801a89 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	8b 55 08             	mov    0x8(%ebp),%edx
  801a8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a92:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a95:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a97:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a9a:	83 3a 01             	cmpl   $0x1,(%edx)
  801a9d:	7e 09                	jle    801aa8 <argstart+0x1f>
  801a9f:	ba 41 37 80 00       	mov    $0x803741,%edx
  801aa4:	85 c9                	test   %ecx,%ecx
  801aa6:	75 05                	jne    801aad <argstart+0x24>
  801aa8:	ba 00 00 00 00       	mov    $0x0,%edx
  801aad:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801ab0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <argnext>:

int
argnext(struct Argstate *args)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	53                   	push   %ebx
  801abd:	83 ec 04             	sub    $0x4,%esp
  801ac0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801ac3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801aca:	8b 43 08             	mov    0x8(%ebx),%eax
  801acd:	85 c0                	test   %eax,%eax
  801acf:	74 6f                	je     801b40 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801ad1:	80 38 00             	cmpb   $0x0,(%eax)
  801ad4:	75 4e                	jne    801b24 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801ad6:	8b 0b                	mov    (%ebx),%ecx
  801ad8:	83 39 01             	cmpl   $0x1,(%ecx)
  801adb:	74 55                	je     801b32 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801add:	8b 53 04             	mov    0x4(%ebx),%edx
  801ae0:	8b 42 04             	mov    0x4(%edx),%eax
  801ae3:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ae6:	75 4a                	jne    801b32 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801ae8:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801aec:	74 44                	je     801b32 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801aee:	83 c0 01             	add    $0x1,%eax
  801af1:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801af4:	83 ec 04             	sub    $0x4,%esp
  801af7:	8b 01                	mov    (%ecx),%eax
  801af9:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b00:	50                   	push   %eax
  801b01:	8d 42 08             	lea    0x8(%edx),%eax
  801b04:	50                   	push   %eax
  801b05:	83 c2 04             	add    $0x4,%edx
  801b08:	52                   	push   %edx
  801b09:	e8 e6 f7 ff ff       	call   8012f4 <memmove>
		(*args->argc)--;
  801b0e:	8b 03                	mov    (%ebx),%eax
  801b10:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b13:	8b 43 08             	mov    0x8(%ebx),%eax
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b1c:	75 06                	jne    801b24 <argnext+0x6b>
  801b1e:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b22:	74 0e                	je     801b32 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b24:	8b 53 08             	mov    0x8(%ebx),%edx
  801b27:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b2a:	83 c2 01             	add    $0x1,%edx
  801b2d:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b30:	eb 13                	jmp    801b45 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b32:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b3e:	eb 05                	jmp    801b45 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    

00801b4a <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	53                   	push   %ebx
  801b4e:	83 ec 04             	sub    $0x4,%esp
  801b51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b54:	8b 43 08             	mov    0x8(%ebx),%eax
  801b57:	85 c0                	test   %eax,%eax
  801b59:	74 58                	je     801bb3 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b5b:	80 38 00             	cmpb   $0x0,(%eax)
  801b5e:	74 0c                	je     801b6c <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b60:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b63:	c7 43 08 41 37 80 00 	movl   $0x803741,0x8(%ebx)
  801b6a:	eb 42                	jmp    801bae <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b6c:	8b 13                	mov    (%ebx),%edx
  801b6e:	83 3a 01             	cmpl   $0x1,(%edx)
  801b71:	7e 2d                	jle    801ba0 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b73:	8b 43 04             	mov    0x4(%ebx),%eax
  801b76:	8b 48 04             	mov    0x4(%eax),%ecx
  801b79:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b7c:	83 ec 04             	sub    $0x4,%esp
  801b7f:	8b 12                	mov    (%edx),%edx
  801b81:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b88:	52                   	push   %edx
  801b89:	8d 50 08             	lea    0x8(%eax),%edx
  801b8c:	52                   	push   %edx
  801b8d:	83 c0 04             	add    $0x4,%eax
  801b90:	50                   	push   %eax
  801b91:	e8 5e f7 ff ff       	call   8012f4 <memmove>
		(*args->argc)--;
  801b96:	8b 03                	mov    (%ebx),%eax
  801b98:	83 28 01             	subl   $0x1,(%eax)
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	eb 0e                	jmp    801bae <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801ba0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801ba7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801bae:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bb1:	eb 05                	jmp    801bb8 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bb3:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801bb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 08             	sub    $0x8,%esp
  801bc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bc6:	8b 51 0c             	mov    0xc(%ecx),%edx
  801bc9:	89 d0                	mov    %edx,%eax
  801bcb:	85 d2                	test   %edx,%edx
  801bcd:	75 0c                	jne    801bdb <argvalue+0x1e>
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	51                   	push   %ecx
  801bd3:	e8 72 ff ff ff       	call   801b4a <argnextvalue>
  801bd8:	83 c4 10             	add    $0x10,%esp
}
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801be0:	8b 45 08             	mov    0x8(%ebp),%eax
  801be3:	05 00 00 00 30       	add    $0x30000000,%eax
  801be8:	c1 e8 0c             	shr    $0xc,%eax
}
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	05 00 00 00 30       	add    $0x30000000,%eax
  801bf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801bfd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c0f:	89 c2                	mov    %eax,%edx
  801c11:	c1 ea 16             	shr    $0x16,%edx
  801c14:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c1b:	f6 c2 01             	test   $0x1,%dl
  801c1e:	74 11                	je     801c31 <fd_alloc+0x2d>
  801c20:	89 c2                	mov    %eax,%edx
  801c22:	c1 ea 0c             	shr    $0xc,%edx
  801c25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c2c:	f6 c2 01             	test   $0x1,%dl
  801c2f:	75 09                	jne    801c3a <fd_alloc+0x36>
			*fd_store = fd;
  801c31:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c33:	b8 00 00 00 00       	mov    $0x0,%eax
  801c38:	eb 17                	jmp    801c51 <fd_alloc+0x4d>
  801c3a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c3f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c44:	75 c9                	jne    801c0f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c46:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c4c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c59:	83 f8 1f             	cmp    $0x1f,%eax
  801c5c:	77 36                	ja     801c94 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c5e:	c1 e0 0c             	shl    $0xc,%eax
  801c61:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c66:	89 c2                	mov    %eax,%edx
  801c68:	c1 ea 16             	shr    $0x16,%edx
  801c6b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c72:	f6 c2 01             	test   $0x1,%dl
  801c75:	74 24                	je     801c9b <fd_lookup+0x48>
  801c77:	89 c2                	mov    %eax,%edx
  801c79:	c1 ea 0c             	shr    $0xc,%edx
  801c7c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c83:	f6 c2 01             	test   $0x1,%dl
  801c86:	74 1a                	je     801ca2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8b:	89 02                	mov    %eax,(%edx)
	return 0;
  801c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c92:	eb 13                	jmp    801ca7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c99:	eb 0c                	jmp    801ca7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ca0:	eb 05                	jmp    801ca7 <fd_lookup+0x54>
  801ca2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	83 ec 08             	sub    $0x8,%esp
  801caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb2:	ba f0 3d 80 00       	mov    $0x803df0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cb7:	eb 13                	jmp    801ccc <dev_lookup+0x23>
  801cb9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801cbc:	39 08                	cmp    %ecx,(%eax)
  801cbe:	75 0c                	jne    801ccc <dev_lookup+0x23>
			*dev = devtab[i];
  801cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc3:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cca:	eb 2e                	jmp    801cfa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ccc:	8b 02                	mov    (%edx),%eax
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	75 e7                	jne    801cb9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cd2:	a1 28 54 80 00       	mov    0x805428,%eax
  801cd7:	8b 40 48             	mov    0x48(%eax),%eax
  801cda:	83 ec 04             	sub    $0x4,%esp
  801cdd:	51                   	push   %ecx
  801cde:	50                   	push   %eax
  801cdf:	68 74 3d 80 00       	push   $0x803d74
  801ce4:	e8 01 ee ff ff       	call   800aea <cprintf>
	*dev = 0;
  801ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801cfa:	c9                   	leave  
  801cfb:	c3                   	ret    

00801cfc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	83 ec 10             	sub    $0x10,%esp
  801d04:	8b 75 08             	mov    0x8(%ebp),%esi
  801d07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0d:	50                   	push   %eax
  801d0e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d14:	c1 e8 0c             	shr    $0xc,%eax
  801d17:	50                   	push   %eax
  801d18:	e8 36 ff ff ff       	call   801c53 <fd_lookup>
  801d1d:	83 c4 08             	add    $0x8,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 05                	js     801d29 <fd_close+0x2d>
	    || fd != fd2)
  801d24:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d27:	74 0c                	je     801d35 <fd_close+0x39>
		return (must_exist ? r : 0);
  801d29:	84 db                	test   %bl,%bl
  801d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d30:	0f 44 c2             	cmove  %edx,%eax
  801d33:	eb 41                	jmp    801d76 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d35:	83 ec 08             	sub    $0x8,%esp
  801d38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d3b:	50                   	push   %eax
  801d3c:	ff 36                	pushl  (%esi)
  801d3e:	e8 66 ff ff ff       	call   801ca9 <dev_lookup>
  801d43:	89 c3                	mov    %eax,%ebx
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 1a                	js     801d66 <fd_close+0x6a>
		if (dev->dev_close)
  801d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d52:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d57:	85 c0                	test   %eax,%eax
  801d59:	74 0b                	je     801d66 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	56                   	push   %esi
  801d5f:	ff d0                	call   *%eax
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d66:	83 ec 08             	sub    $0x8,%esp
  801d69:	56                   	push   %esi
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 79 f8 ff ff       	call   8015ea <sys_page_unmap>
	return r;
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	89 d8                	mov    %ebx,%eax
}
  801d76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d86:	50                   	push   %eax
  801d87:	ff 75 08             	pushl  0x8(%ebp)
  801d8a:	e8 c4 fe ff ff       	call   801c53 <fd_lookup>
  801d8f:	83 c4 08             	add    $0x8,%esp
  801d92:	85 c0                	test   %eax,%eax
  801d94:	78 10                	js     801da6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d96:	83 ec 08             	sub    $0x8,%esp
  801d99:	6a 01                	push   $0x1
  801d9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9e:	e8 59 ff ff ff       	call   801cfc <fd_close>
  801da3:	83 c4 10             	add    $0x10,%esp
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <close_all>:

void
close_all(void)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	53                   	push   %ebx
  801dac:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801daf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801db4:	83 ec 0c             	sub    $0xc,%esp
  801db7:	53                   	push   %ebx
  801db8:	e8 c0 ff ff ff       	call   801d7d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801dbd:	83 c3 01             	add    $0x1,%ebx
  801dc0:	83 c4 10             	add    $0x10,%esp
  801dc3:	83 fb 20             	cmp    $0x20,%ebx
  801dc6:	75 ec                	jne    801db4 <close_all+0xc>
		close(i);
}
  801dc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dcb:	c9                   	leave  
  801dcc:	c3                   	ret    

00801dcd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	57                   	push   %edi
  801dd1:	56                   	push   %esi
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 2c             	sub    $0x2c,%esp
  801dd6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801dd9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ddc:	50                   	push   %eax
  801ddd:	ff 75 08             	pushl  0x8(%ebp)
  801de0:	e8 6e fe ff ff       	call   801c53 <fd_lookup>
  801de5:	83 c4 08             	add    $0x8,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	0f 88 c1 00 00 00    	js     801eb1 <dup+0xe4>
		return r;
	close(newfdnum);
  801df0:	83 ec 0c             	sub    $0xc,%esp
  801df3:	56                   	push   %esi
  801df4:	e8 84 ff ff ff       	call   801d7d <close>

	newfd = INDEX2FD(newfdnum);
  801df9:	89 f3                	mov    %esi,%ebx
  801dfb:	c1 e3 0c             	shl    $0xc,%ebx
  801dfe:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e04:	83 c4 04             	add    $0x4,%esp
  801e07:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e0a:	e8 de fd ff ff       	call   801bed <fd2data>
  801e0f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e11:	89 1c 24             	mov    %ebx,(%esp)
  801e14:	e8 d4 fd ff ff       	call   801bed <fd2data>
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e1f:	89 f8                	mov    %edi,%eax
  801e21:	c1 e8 16             	shr    $0x16,%eax
  801e24:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e2b:	a8 01                	test   $0x1,%al
  801e2d:	74 37                	je     801e66 <dup+0x99>
  801e2f:	89 f8                	mov    %edi,%eax
  801e31:	c1 e8 0c             	shr    $0xc,%eax
  801e34:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e3b:	f6 c2 01             	test   $0x1,%dl
  801e3e:	74 26                	je     801e66 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e40:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e47:	83 ec 0c             	sub    $0xc,%esp
  801e4a:	25 07 0e 00 00       	and    $0xe07,%eax
  801e4f:	50                   	push   %eax
  801e50:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e53:	6a 00                	push   $0x0
  801e55:	57                   	push   %edi
  801e56:	6a 00                	push   $0x0
  801e58:	e8 4b f7 ff ff       	call   8015a8 <sys_page_map>
  801e5d:	89 c7                	mov    %eax,%edi
  801e5f:	83 c4 20             	add    $0x20,%esp
  801e62:	85 c0                	test   %eax,%eax
  801e64:	78 2e                	js     801e94 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e69:	89 d0                	mov    %edx,%eax
  801e6b:	c1 e8 0c             	shr    $0xc,%eax
  801e6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e75:	83 ec 0c             	sub    $0xc,%esp
  801e78:	25 07 0e 00 00       	and    $0xe07,%eax
  801e7d:	50                   	push   %eax
  801e7e:	53                   	push   %ebx
  801e7f:	6a 00                	push   $0x0
  801e81:	52                   	push   %edx
  801e82:	6a 00                	push   $0x0
  801e84:	e8 1f f7 ff ff       	call   8015a8 <sys_page_map>
  801e89:	89 c7                	mov    %eax,%edi
  801e8b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e8e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e90:	85 ff                	test   %edi,%edi
  801e92:	79 1d                	jns    801eb1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e94:	83 ec 08             	sub    $0x8,%esp
  801e97:	53                   	push   %ebx
  801e98:	6a 00                	push   $0x0
  801e9a:	e8 4b f7 ff ff       	call   8015ea <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e9f:	83 c4 08             	add    $0x8,%esp
  801ea2:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ea5:	6a 00                	push   $0x0
  801ea7:	e8 3e f7 ff ff       	call   8015ea <sys_page_unmap>
	return r;
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	89 f8                	mov    %edi,%eax
}
  801eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb4:	5b                   	pop    %ebx
  801eb5:	5e                   	pop    %esi
  801eb6:	5f                   	pop    %edi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	53                   	push   %ebx
  801ebd:	83 ec 14             	sub    $0x14,%esp
  801ec0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ec3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ec6:	50                   	push   %eax
  801ec7:	53                   	push   %ebx
  801ec8:	e8 86 fd ff ff       	call   801c53 <fd_lookup>
  801ecd:	83 c4 08             	add    $0x8,%esp
  801ed0:	89 c2                	mov    %eax,%edx
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	78 6d                	js     801f43 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ed6:	83 ec 08             	sub    $0x8,%esp
  801ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edc:	50                   	push   %eax
  801edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee0:	ff 30                	pushl  (%eax)
  801ee2:	e8 c2 fd ff ff       	call   801ca9 <dev_lookup>
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	78 4c                	js     801f3a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801eee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ef1:	8b 42 08             	mov    0x8(%edx),%eax
  801ef4:	83 e0 03             	and    $0x3,%eax
  801ef7:	83 f8 01             	cmp    $0x1,%eax
  801efa:	75 21                	jne    801f1d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801efc:	a1 28 54 80 00       	mov    0x805428,%eax
  801f01:	8b 40 48             	mov    0x48(%eax),%eax
  801f04:	83 ec 04             	sub    $0x4,%esp
  801f07:	53                   	push   %ebx
  801f08:	50                   	push   %eax
  801f09:	68 b5 3d 80 00       	push   $0x803db5
  801f0e:	e8 d7 eb ff ff       	call   800aea <cprintf>
		return -E_INVAL;
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f1b:	eb 26                	jmp    801f43 <read+0x8a>
	}
	if (!dev->dev_read)
  801f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f20:	8b 40 08             	mov    0x8(%eax),%eax
  801f23:	85 c0                	test   %eax,%eax
  801f25:	74 17                	je     801f3e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f27:	83 ec 04             	sub    $0x4,%esp
  801f2a:	ff 75 10             	pushl  0x10(%ebp)
  801f2d:	ff 75 0c             	pushl  0xc(%ebp)
  801f30:	52                   	push   %edx
  801f31:	ff d0                	call   *%eax
  801f33:	89 c2                	mov    %eax,%edx
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	eb 09                	jmp    801f43 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f3a:	89 c2                	mov    %eax,%edx
  801f3c:	eb 05                	jmp    801f43 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f3e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f43:	89 d0                	mov    %edx,%eax
  801f45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f48:	c9                   	leave  
  801f49:	c3                   	ret    

00801f4a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	57                   	push   %edi
  801f4e:	56                   	push   %esi
  801f4f:	53                   	push   %ebx
  801f50:	83 ec 0c             	sub    $0xc,%esp
  801f53:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f56:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f59:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f5e:	eb 21                	jmp    801f81 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f60:	83 ec 04             	sub    $0x4,%esp
  801f63:	89 f0                	mov    %esi,%eax
  801f65:	29 d8                	sub    %ebx,%eax
  801f67:	50                   	push   %eax
  801f68:	89 d8                	mov    %ebx,%eax
  801f6a:	03 45 0c             	add    0xc(%ebp),%eax
  801f6d:	50                   	push   %eax
  801f6e:	57                   	push   %edi
  801f6f:	e8 45 ff ff ff       	call   801eb9 <read>
		if (m < 0)
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	85 c0                	test   %eax,%eax
  801f79:	78 10                	js     801f8b <readn+0x41>
			return m;
		if (m == 0)
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	74 0a                	je     801f89 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f7f:	01 c3                	add    %eax,%ebx
  801f81:	39 f3                	cmp    %esi,%ebx
  801f83:	72 db                	jb     801f60 <readn+0x16>
  801f85:	89 d8                	mov    %ebx,%eax
  801f87:	eb 02                	jmp    801f8b <readn+0x41>
  801f89:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8e:	5b                   	pop    %ebx
  801f8f:	5e                   	pop    %esi
  801f90:	5f                   	pop    %edi
  801f91:	5d                   	pop    %ebp
  801f92:	c3                   	ret    

00801f93 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	53                   	push   %ebx
  801f97:	83 ec 14             	sub    $0x14,%esp
  801f9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fa0:	50                   	push   %eax
  801fa1:	53                   	push   %ebx
  801fa2:	e8 ac fc ff ff       	call   801c53 <fd_lookup>
  801fa7:	83 c4 08             	add    $0x8,%esp
  801faa:	89 c2                	mov    %eax,%edx
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 68                	js     802018 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fb0:	83 ec 08             	sub    $0x8,%esp
  801fb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb6:	50                   	push   %eax
  801fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fba:	ff 30                	pushl  (%eax)
  801fbc:	e8 e8 fc ff ff       	call   801ca9 <dev_lookup>
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	78 47                	js     80200f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fcb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fcf:	75 21                	jne    801ff2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fd1:	a1 28 54 80 00       	mov    0x805428,%eax
  801fd6:	8b 40 48             	mov    0x48(%eax),%eax
  801fd9:	83 ec 04             	sub    $0x4,%esp
  801fdc:	53                   	push   %ebx
  801fdd:	50                   	push   %eax
  801fde:	68 d1 3d 80 00       	push   $0x803dd1
  801fe3:	e8 02 eb ff ff       	call   800aea <cprintf>
		return -E_INVAL;
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ff0:	eb 26                	jmp    802018 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ff2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ff5:	8b 52 0c             	mov    0xc(%edx),%edx
  801ff8:	85 d2                	test   %edx,%edx
  801ffa:	74 17                	je     802013 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ffc:	83 ec 04             	sub    $0x4,%esp
  801fff:	ff 75 10             	pushl  0x10(%ebp)
  802002:	ff 75 0c             	pushl  0xc(%ebp)
  802005:	50                   	push   %eax
  802006:	ff d2                	call   *%edx
  802008:	89 c2                	mov    %eax,%edx
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	eb 09                	jmp    802018 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80200f:	89 c2                	mov    %eax,%edx
  802011:	eb 05                	jmp    802018 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802013:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802018:	89 d0                	mov    %edx,%eax
  80201a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    

0080201f <seek>:

int
seek(int fdnum, off_t offset)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802025:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802028:	50                   	push   %eax
  802029:	ff 75 08             	pushl  0x8(%ebp)
  80202c:	e8 22 fc ff ff       	call   801c53 <fd_lookup>
  802031:	83 c4 08             	add    $0x8,%esp
  802034:	85 c0                	test   %eax,%eax
  802036:	78 0e                	js     802046 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802038:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80203b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802041:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802046:	c9                   	leave  
  802047:	c3                   	ret    

00802048 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	53                   	push   %ebx
  80204c:	83 ec 14             	sub    $0x14,%esp
  80204f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802052:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802055:	50                   	push   %eax
  802056:	53                   	push   %ebx
  802057:	e8 f7 fb ff ff       	call   801c53 <fd_lookup>
  80205c:	83 c4 08             	add    $0x8,%esp
  80205f:	89 c2                	mov    %eax,%edx
  802061:	85 c0                	test   %eax,%eax
  802063:	78 65                	js     8020ca <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802065:	83 ec 08             	sub    $0x8,%esp
  802068:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206b:	50                   	push   %eax
  80206c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80206f:	ff 30                	pushl  (%eax)
  802071:	e8 33 fc ff ff       	call   801ca9 <dev_lookup>
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 44                	js     8020c1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80207d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802080:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802084:	75 21                	jne    8020a7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802086:	a1 28 54 80 00       	mov    0x805428,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80208b:	8b 40 48             	mov    0x48(%eax),%eax
  80208e:	83 ec 04             	sub    $0x4,%esp
  802091:	53                   	push   %ebx
  802092:	50                   	push   %eax
  802093:	68 94 3d 80 00       	push   $0x803d94
  802098:	e8 4d ea ff ff       	call   800aea <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020a5:	eb 23                	jmp    8020ca <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020aa:	8b 52 18             	mov    0x18(%edx),%edx
  8020ad:	85 d2                	test   %edx,%edx
  8020af:	74 14                	je     8020c5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020b1:	83 ec 08             	sub    $0x8,%esp
  8020b4:	ff 75 0c             	pushl  0xc(%ebp)
  8020b7:	50                   	push   %eax
  8020b8:	ff d2                	call   *%edx
  8020ba:	89 c2                	mov    %eax,%edx
  8020bc:	83 c4 10             	add    $0x10,%esp
  8020bf:	eb 09                	jmp    8020ca <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020c1:	89 c2                	mov    %eax,%edx
  8020c3:	eb 05                	jmp    8020ca <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020ca:	89 d0                	mov    %edx,%eax
  8020cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020cf:	c9                   	leave  
  8020d0:	c3                   	ret    

008020d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020d1:	55                   	push   %ebp
  8020d2:	89 e5                	mov    %esp,%ebp
  8020d4:	53                   	push   %ebx
  8020d5:	83 ec 14             	sub    $0x14,%esp
  8020d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020de:	50                   	push   %eax
  8020df:	ff 75 08             	pushl  0x8(%ebp)
  8020e2:	e8 6c fb ff ff       	call   801c53 <fd_lookup>
  8020e7:	83 c4 08             	add    $0x8,%esp
  8020ea:	89 c2                	mov    %eax,%edx
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	78 58                	js     802148 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020f0:	83 ec 08             	sub    $0x8,%esp
  8020f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f6:	50                   	push   %eax
  8020f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020fa:	ff 30                	pushl  (%eax)
  8020fc:	e8 a8 fb ff ff       	call   801ca9 <dev_lookup>
  802101:	83 c4 10             	add    $0x10,%esp
  802104:	85 c0                	test   %eax,%eax
  802106:	78 37                	js     80213f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80210f:	74 32                	je     802143 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802111:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802114:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80211b:	00 00 00 
	stat->st_isdir = 0;
  80211e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802125:	00 00 00 
	stat->st_dev = dev;
  802128:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80212e:	83 ec 08             	sub    $0x8,%esp
  802131:	53                   	push   %ebx
  802132:	ff 75 f0             	pushl  -0x10(%ebp)
  802135:	ff 50 14             	call   *0x14(%eax)
  802138:	89 c2                	mov    %eax,%edx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	eb 09                	jmp    802148 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80213f:	89 c2                	mov    %eax,%edx
  802141:	eb 05                	jmp    802148 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802143:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802148:	89 d0                	mov    %edx,%eax
  80214a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80214d:	c9                   	leave  
  80214e:	c3                   	ret    

0080214f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802154:	83 ec 08             	sub    $0x8,%esp
  802157:	6a 00                	push   $0x0
  802159:	ff 75 08             	pushl  0x8(%ebp)
  80215c:	e8 d6 01 00 00       	call   802337 <open>
  802161:	89 c3                	mov    %eax,%ebx
  802163:	83 c4 10             	add    $0x10,%esp
  802166:	85 c0                	test   %eax,%eax
  802168:	78 1b                	js     802185 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80216a:	83 ec 08             	sub    $0x8,%esp
  80216d:	ff 75 0c             	pushl  0xc(%ebp)
  802170:	50                   	push   %eax
  802171:	e8 5b ff ff ff       	call   8020d1 <fstat>
  802176:	89 c6                	mov    %eax,%esi
	close(fd);
  802178:	89 1c 24             	mov    %ebx,(%esp)
  80217b:	e8 fd fb ff ff       	call   801d7d <close>
	return r;
  802180:	83 c4 10             	add    $0x10,%esp
  802183:	89 f0                	mov    %esi,%eax
}
  802185:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    

0080218c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	56                   	push   %esi
  802190:	53                   	push   %ebx
  802191:	89 c6                	mov    %eax,%esi
  802193:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802195:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  80219c:	75 12                	jne    8021b0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80219e:	83 ec 0c             	sub    $0xc,%esp
  8021a1:	6a 01                	push   $0x1
  8021a3:	e8 6b 12 00 00       	call   803413 <ipc_find_env>
  8021a8:	a3 20 54 80 00       	mov    %eax,0x805420
  8021ad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021b0:	6a 07                	push   $0x7
  8021b2:	68 00 60 80 00       	push   $0x806000
  8021b7:	56                   	push   %esi
  8021b8:	ff 35 20 54 80 00    	pushl  0x805420
  8021be:	e8 fc 11 00 00       	call   8033bf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021c3:	83 c4 0c             	add    $0xc,%esp
  8021c6:	6a 00                	push   $0x0
  8021c8:	53                   	push   %ebx
  8021c9:	6a 00                	push   $0x0
  8021cb:	e8 88 11 00 00       	call   803358 <ipc_recv>
}
  8021d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5d                   	pop    %ebp
  8021d6:	c3                   	ret    

008021d7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021d7:	55                   	push   %ebp
  8021d8:	89 e5                	mov    %esp,%ebp
  8021da:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8021e3:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8021e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021eb:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f5:	b8 02 00 00 00       	mov    $0x2,%eax
  8021fa:	e8 8d ff ff ff       	call   80218c <fsipc>
}
  8021ff:	c9                   	leave  
  802200:	c3                   	ret    

00802201 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802207:	8b 45 08             	mov    0x8(%ebp),%eax
  80220a:	8b 40 0c             	mov    0xc(%eax),%eax
  80220d:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802212:	ba 00 00 00 00       	mov    $0x0,%edx
  802217:	b8 06 00 00 00       	mov    $0x6,%eax
  80221c:	e8 6b ff ff ff       	call   80218c <fsipc>
}
  802221:	c9                   	leave  
  802222:	c3                   	ret    

00802223 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
  802226:	53                   	push   %ebx
  802227:	83 ec 04             	sub    $0x4,%esp
  80222a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80222d:	8b 45 08             	mov    0x8(%ebp),%eax
  802230:	8b 40 0c             	mov    0xc(%eax),%eax
  802233:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802238:	ba 00 00 00 00       	mov    $0x0,%edx
  80223d:	b8 05 00 00 00       	mov    $0x5,%eax
  802242:	e8 45 ff ff ff       	call   80218c <fsipc>
  802247:	85 c0                	test   %eax,%eax
  802249:	78 2c                	js     802277 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80224b:	83 ec 08             	sub    $0x8,%esp
  80224e:	68 00 60 80 00       	push   $0x806000
  802253:	53                   	push   %ebx
  802254:	e8 09 ef ff ff       	call   801162 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802259:	a1 80 60 80 00       	mov    0x806080,%eax
  80225e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802264:	a1 84 60 80 00       	mov    0x806084,%eax
  802269:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80226f:	83 c4 10             	add    $0x10,%esp
  802272:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80227a:	c9                   	leave  
  80227b:	c3                   	ret    

0080227c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	83 ec 0c             	sub    $0xc,%esp
  802282:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802285:	8b 55 08             	mov    0x8(%ebp),%edx
  802288:	8b 52 0c             	mov    0xc(%edx),%edx
  80228b:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  802291:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802296:	50                   	push   %eax
  802297:	ff 75 0c             	pushl  0xc(%ebp)
  80229a:	68 08 60 80 00       	push   $0x806008
  80229f:	e8 50 f0 ff ff       	call   8012f4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8022a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a9:	b8 04 00 00 00       	mov    $0x4,%eax
  8022ae:	e8 d9 fe ff ff       	call   80218c <fsipc>

}
  8022b3:	c9                   	leave  
  8022b4:	c3                   	ret    

008022b5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
  8022b8:	56                   	push   %esi
  8022b9:	53                   	push   %ebx
  8022ba:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8022c3:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022c8:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8022d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8022d8:	e8 af fe ff ff       	call   80218c <fsipc>
  8022dd:	89 c3                	mov    %eax,%ebx
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	78 4b                	js     80232e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8022e3:	39 c6                	cmp    %eax,%esi
  8022e5:	73 16                	jae    8022fd <devfile_read+0x48>
  8022e7:	68 04 3e 80 00       	push   $0x803e04
  8022ec:	68 5a 38 80 00       	push   $0x80385a
  8022f1:	6a 7c                	push   $0x7c
  8022f3:	68 0b 3e 80 00       	push   $0x803e0b
  8022f8:	e8 14 e7 ff ff       	call   800a11 <_panic>
	assert(r <= PGSIZE);
  8022fd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802302:	7e 16                	jle    80231a <devfile_read+0x65>
  802304:	68 16 3e 80 00       	push   $0x803e16
  802309:	68 5a 38 80 00       	push   $0x80385a
  80230e:	6a 7d                	push   $0x7d
  802310:	68 0b 3e 80 00       	push   $0x803e0b
  802315:	e8 f7 e6 ff ff       	call   800a11 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80231a:	83 ec 04             	sub    $0x4,%esp
  80231d:	50                   	push   %eax
  80231e:	68 00 60 80 00       	push   $0x806000
  802323:	ff 75 0c             	pushl  0xc(%ebp)
  802326:	e8 c9 ef ff ff       	call   8012f4 <memmove>
	return r;
  80232b:	83 c4 10             	add    $0x10,%esp
}
  80232e:	89 d8                	mov    %ebx,%eax
  802330:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802333:	5b                   	pop    %ebx
  802334:	5e                   	pop    %esi
  802335:	5d                   	pop    %ebp
  802336:	c3                   	ret    

00802337 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802337:	55                   	push   %ebp
  802338:	89 e5                	mov    %esp,%ebp
  80233a:	53                   	push   %ebx
  80233b:	83 ec 20             	sub    $0x20,%esp
  80233e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802341:	53                   	push   %ebx
  802342:	e8 e2 ed ff ff       	call   801129 <strlen>
  802347:	83 c4 10             	add    $0x10,%esp
  80234a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80234f:	7f 67                	jg     8023b8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802351:	83 ec 0c             	sub    $0xc,%esp
  802354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802357:	50                   	push   %eax
  802358:	e8 a7 f8 ff ff       	call   801c04 <fd_alloc>
  80235d:	83 c4 10             	add    $0x10,%esp
		return r;
  802360:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802362:	85 c0                	test   %eax,%eax
  802364:	78 57                	js     8023bd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802366:	83 ec 08             	sub    $0x8,%esp
  802369:	53                   	push   %ebx
  80236a:	68 00 60 80 00       	push   $0x806000
  80236f:	e8 ee ed ff ff       	call   801162 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802374:	8b 45 0c             	mov    0xc(%ebp),%eax
  802377:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80237c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80237f:	b8 01 00 00 00       	mov    $0x1,%eax
  802384:	e8 03 fe ff ff       	call   80218c <fsipc>
  802389:	89 c3                	mov    %eax,%ebx
  80238b:	83 c4 10             	add    $0x10,%esp
  80238e:	85 c0                	test   %eax,%eax
  802390:	79 14                	jns    8023a6 <open+0x6f>
		fd_close(fd, 0);
  802392:	83 ec 08             	sub    $0x8,%esp
  802395:	6a 00                	push   $0x0
  802397:	ff 75 f4             	pushl  -0xc(%ebp)
  80239a:	e8 5d f9 ff ff       	call   801cfc <fd_close>
		return r;
  80239f:	83 c4 10             	add    $0x10,%esp
  8023a2:	89 da                	mov    %ebx,%edx
  8023a4:	eb 17                	jmp    8023bd <open+0x86>
	}

	return fd2num(fd);
  8023a6:	83 ec 0c             	sub    $0xc,%esp
  8023a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ac:	e8 2c f8 ff ff       	call   801bdd <fd2num>
  8023b1:	89 c2                	mov    %eax,%edx
  8023b3:	83 c4 10             	add    $0x10,%esp
  8023b6:	eb 05                	jmp    8023bd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023b8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023bd:	89 d0                	mov    %edx,%eax
  8023bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023c2:	c9                   	leave  
  8023c3:	c3                   	ret    

008023c4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8023cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8023d4:	e8 b3 fd ff ff       	call   80218c <fsipc>
}
  8023d9:	c9                   	leave  
  8023da:	c3                   	ret    

008023db <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8023db:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023df:	7e 37                	jle    802418 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	53                   	push   %ebx
  8023e5:	83 ec 08             	sub    $0x8,%esp
  8023e8:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023ea:	ff 70 04             	pushl  0x4(%eax)
  8023ed:	8d 40 10             	lea    0x10(%eax),%eax
  8023f0:	50                   	push   %eax
  8023f1:	ff 33                	pushl  (%ebx)
  8023f3:	e8 9b fb ff ff       	call   801f93 <write>
		if (result > 0)
  8023f8:	83 c4 10             	add    $0x10,%esp
  8023fb:	85 c0                	test   %eax,%eax
  8023fd:	7e 03                	jle    802402 <writebuf+0x27>
			b->result += result;
  8023ff:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802402:	3b 43 04             	cmp    0x4(%ebx),%eax
  802405:	74 0d                	je     802414 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802407:	85 c0                	test   %eax,%eax
  802409:	ba 00 00 00 00       	mov    $0x0,%edx
  80240e:	0f 4f c2             	cmovg  %edx,%eax
  802411:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802417:	c9                   	leave  
  802418:	f3 c3                	repz ret 

0080241a <putch>:

static void
putch(int ch, void *thunk)
{
  80241a:	55                   	push   %ebp
  80241b:	89 e5                	mov    %esp,%ebp
  80241d:	53                   	push   %ebx
  80241e:	83 ec 04             	sub    $0x4,%esp
  802421:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802424:	8b 53 04             	mov    0x4(%ebx),%edx
  802427:	8d 42 01             	lea    0x1(%edx),%eax
  80242a:	89 43 04             	mov    %eax,0x4(%ebx)
  80242d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802430:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802434:	3d 00 01 00 00       	cmp    $0x100,%eax
  802439:	75 0e                	jne    802449 <putch+0x2f>
		writebuf(b);
  80243b:	89 d8                	mov    %ebx,%eax
  80243d:	e8 99 ff ff ff       	call   8023db <writebuf>
		b->idx = 0;
  802442:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802449:	83 c4 04             	add    $0x4,%esp
  80244c:	5b                   	pop    %ebx
  80244d:	5d                   	pop    %ebp
  80244e:	c3                   	ret    

0080244f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
  802452:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802458:	8b 45 08             	mov    0x8(%ebp),%eax
  80245b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802461:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802468:	00 00 00 
	b.result = 0;
  80246b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802472:	00 00 00 
	b.error = 1;
  802475:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80247c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80247f:	ff 75 10             	pushl  0x10(%ebp)
  802482:	ff 75 0c             	pushl  0xc(%ebp)
  802485:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80248b:	50                   	push   %eax
  80248c:	68 1a 24 80 00       	push   $0x80241a
  802491:	e8 8b e7 ff ff       	call   800c21 <vprintfmt>
	if (b.idx > 0)
  802496:	83 c4 10             	add    $0x10,%esp
  802499:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024a0:	7e 0b                	jle    8024ad <vfprintf+0x5e>
		writebuf(&b);
  8024a2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024a8:	e8 2e ff ff ff       	call   8023db <writebuf>

	return (b.result ? b.result : b.error);
  8024ad:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024b3:	85 c0                	test   %eax,%eax
  8024b5:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024bc:	c9                   	leave  
  8024bd:	c3                   	ret    

008024be <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024be:	55                   	push   %ebp
  8024bf:	89 e5                	mov    %esp,%ebp
  8024c1:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024c4:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024c7:	50                   	push   %eax
  8024c8:	ff 75 0c             	pushl  0xc(%ebp)
  8024cb:	ff 75 08             	pushl  0x8(%ebp)
  8024ce:	e8 7c ff ff ff       	call   80244f <vfprintf>
	va_end(ap);

	return cnt;
}
  8024d3:	c9                   	leave  
  8024d4:	c3                   	ret    

008024d5 <printf>:

int
printf(const char *fmt, ...)
{
  8024d5:	55                   	push   %ebp
  8024d6:	89 e5                	mov    %esp,%ebp
  8024d8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024de:	50                   	push   %eax
  8024df:	ff 75 08             	pushl  0x8(%ebp)
  8024e2:	6a 01                	push   $0x1
  8024e4:	e8 66 ff ff ff       	call   80244f <vfprintf>
	va_end(ap);

	return cnt;
}
  8024e9:	c9                   	leave  
  8024ea:	c3                   	ret    

008024eb <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024eb:	55                   	push   %ebp
  8024ec:	89 e5                	mov    %esp,%ebp
  8024ee:	57                   	push   %edi
  8024ef:	56                   	push   %esi
  8024f0:	53                   	push   %ebx
  8024f1:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024f7:	6a 00                	push   $0x0
  8024f9:	ff 75 08             	pushl  0x8(%ebp)
  8024fc:	e8 36 fe ff ff       	call   802337 <open>
  802501:	89 c7                	mov    %eax,%edi
  802503:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802509:	83 c4 10             	add    $0x10,%esp
  80250c:	85 c0                	test   %eax,%eax
  80250e:	0f 88 97 04 00 00    	js     8029ab <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802514:	83 ec 04             	sub    $0x4,%esp
  802517:	68 00 02 00 00       	push   $0x200
  80251c:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802522:	50                   	push   %eax
  802523:	57                   	push   %edi
  802524:	e8 21 fa ff ff       	call   801f4a <readn>
  802529:	83 c4 10             	add    $0x10,%esp
  80252c:	3d 00 02 00 00       	cmp    $0x200,%eax
  802531:	75 0c                	jne    80253f <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802533:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80253a:	45 4c 46 
  80253d:	74 33                	je     802572 <spawn+0x87>
		close(fd);
  80253f:	83 ec 0c             	sub    $0xc,%esp
  802542:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802548:	e8 30 f8 ff ff       	call   801d7d <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80254d:	83 c4 0c             	add    $0xc,%esp
  802550:	68 7f 45 4c 46       	push   $0x464c457f
  802555:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80255b:	68 22 3e 80 00       	push   $0x803e22
  802560:	e8 85 e5 ff ff       	call   800aea <cprintf>
		return -E_NOT_EXEC;
  802565:	83 c4 10             	add    $0x10,%esp
  802568:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80256d:	e9 ec 04 00 00       	jmp    802a5e <spawn+0x573>
  802572:	b8 07 00 00 00       	mov    $0x7,%eax
  802577:	cd 30                	int    $0x30
  802579:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80257f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802585:	85 c0                	test   %eax,%eax
  802587:	0f 88 29 04 00 00    	js     8029b6 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80258d:	89 c6                	mov    %eax,%esi
  80258f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802595:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802598:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80259e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025a4:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025ab:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025b1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025bc:	be 00 00 00 00       	mov    $0x0,%esi
  8025c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025c4:	eb 13                	jmp    8025d9 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025c6:	83 ec 0c             	sub    $0xc,%esp
  8025c9:	50                   	push   %eax
  8025ca:	e8 5a eb ff ff       	call   801129 <strlen>
  8025cf:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025d3:	83 c3 01             	add    $0x1,%ebx
  8025d6:	83 c4 10             	add    $0x10,%esp
  8025d9:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8025e0:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025e3:	85 c0                	test   %eax,%eax
  8025e5:	75 df                	jne    8025c6 <spawn+0xdb>
  8025e7:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8025ed:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025f3:	bf 00 10 40 00       	mov    $0x401000,%edi
  8025f8:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025fa:	89 fa                	mov    %edi,%edx
  8025fc:	83 e2 fc             	and    $0xfffffffc,%edx
  8025ff:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802606:	29 c2                	sub    %eax,%edx
  802608:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80260e:	8d 42 f8             	lea    -0x8(%edx),%eax
  802611:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802616:	0f 86 b0 03 00 00    	jbe    8029cc <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80261c:	83 ec 04             	sub    $0x4,%esp
  80261f:	6a 07                	push   $0x7
  802621:	68 00 00 40 00       	push   $0x400000
  802626:	6a 00                	push   $0x0
  802628:	e8 38 ef ff ff       	call   801565 <sys_page_alloc>
  80262d:	83 c4 10             	add    $0x10,%esp
  802630:	85 c0                	test   %eax,%eax
  802632:	0f 88 9e 03 00 00    	js     8029d6 <spawn+0x4eb>
  802638:	be 00 00 00 00       	mov    $0x0,%esi
  80263d:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802646:	eb 30                	jmp    802678 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802648:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80264e:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802654:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802657:	83 ec 08             	sub    $0x8,%esp
  80265a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80265d:	57                   	push   %edi
  80265e:	e8 ff ea ff ff       	call   801162 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802663:	83 c4 04             	add    $0x4,%esp
  802666:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802669:	e8 bb ea ff ff       	call   801129 <strlen>
  80266e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802672:	83 c6 01             	add    $0x1,%esi
  802675:	83 c4 10             	add    $0x10,%esp
  802678:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80267e:	7f c8                	jg     802648 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802680:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802686:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  80268c:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802693:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802699:	74 19                	je     8026b4 <spawn+0x1c9>
  80269b:	68 ac 3e 80 00       	push   $0x803eac
  8026a0:	68 5a 38 80 00       	push   $0x80385a
  8026a5:	68 f2 00 00 00       	push   $0xf2
  8026aa:	68 3c 3e 80 00       	push   $0x803e3c
  8026af:	e8 5d e3 ff ff       	call   800a11 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026b4:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8026ba:	89 f8                	mov    %edi,%eax
  8026bc:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026c1:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026c4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026ca:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026cd:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8026d3:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026d9:	83 ec 0c             	sub    $0xc,%esp
  8026dc:	6a 07                	push   $0x7
  8026de:	68 00 d0 bf ee       	push   $0xeebfd000
  8026e3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026e9:	68 00 00 40 00       	push   $0x400000
  8026ee:	6a 00                	push   $0x0
  8026f0:	e8 b3 ee ff ff       	call   8015a8 <sys_page_map>
  8026f5:	89 c3                	mov    %eax,%ebx
  8026f7:	83 c4 20             	add    $0x20,%esp
  8026fa:	85 c0                	test   %eax,%eax
  8026fc:	0f 88 4a 03 00 00    	js     802a4c <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802702:	83 ec 08             	sub    $0x8,%esp
  802705:	68 00 00 40 00       	push   $0x400000
  80270a:	6a 00                	push   $0x0
  80270c:	e8 d9 ee ff ff       	call   8015ea <sys_page_unmap>
  802711:	89 c3                	mov    %eax,%ebx
  802713:	83 c4 10             	add    $0x10,%esp
  802716:	85 c0                	test   %eax,%eax
  802718:	0f 88 2e 03 00 00    	js     802a4c <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80271e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802724:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80272b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802731:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802738:	00 00 00 
  80273b:	e9 8a 01 00 00       	jmp    8028ca <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  802740:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802746:	83 38 01             	cmpl   $0x1,(%eax)
  802749:	0f 85 6d 01 00 00    	jne    8028bc <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80274f:	89 c7                	mov    %eax,%edi
  802751:	8b 40 18             	mov    0x18(%eax),%eax
  802754:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80275a:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80275d:	83 f8 01             	cmp    $0x1,%eax
  802760:	19 c0                	sbb    %eax,%eax
  802762:	83 e0 fe             	and    $0xfffffffe,%eax
  802765:	83 c0 07             	add    $0x7,%eax
  802768:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80276e:	89 f8                	mov    %edi,%eax
  802770:	8b 7f 04             	mov    0x4(%edi),%edi
  802773:	89 f9                	mov    %edi,%ecx
  802775:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80277b:	8b 78 10             	mov    0x10(%eax),%edi
  80277e:	8b 70 14             	mov    0x14(%eax),%esi
  802781:	89 f3                	mov    %esi,%ebx
  802783:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  802789:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80278c:	89 f0                	mov    %esi,%eax
  80278e:	25 ff 0f 00 00       	and    $0xfff,%eax
  802793:	74 14                	je     8027a9 <spawn+0x2be>
		va -= i;
  802795:	29 c6                	sub    %eax,%esi
		memsz += i;
  802797:	01 c3                	add    %eax,%ebx
  802799:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  80279f:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027a1:	29 c1                	sub    %eax,%ecx
  8027a3:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027ae:	e9 f7 00 00 00       	jmp    8028aa <spawn+0x3bf>
		if (i >= filesz) {
  8027b3:	39 df                	cmp    %ebx,%edi
  8027b5:	77 27                	ja     8027de <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027b7:	83 ec 04             	sub    $0x4,%esp
  8027ba:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027c0:	56                   	push   %esi
  8027c1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027c7:	e8 99 ed ff ff       	call   801565 <sys_page_alloc>
  8027cc:	83 c4 10             	add    $0x10,%esp
  8027cf:	85 c0                	test   %eax,%eax
  8027d1:	0f 89 c7 00 00 00    	jns    80289e <spawn+0x3b3>
  8027d7:	89 c3                	mov    %eax,%ebx
  8027d9:	e9 09 02 00 00       	jmp    8029e7 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027de:	83 ec 04             	sub    $0x4,%esp
  8027e1:	6a 07                	push   $0x7
  8027e3:	68 00 00 40 00       	push   $0x400000
  8027e8:	6a 00                	push   $0x0
  8027ea:	e8 76 ed ff ff       	call   801565 <sys_page_alloc>
  8027ef:	83 c4 10             	add    $0x10,%esp
  8027f2:	85 c0                	test   %eax,%eax
  8027f4:	0f 88 e3 01 00 00    	js     8029dd <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027fa:	83 ec 08             	sub    $0x8,%esp
  8027fd:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802803:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802809:	50                   	push   %eax
  80280a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802810:	e8 0a f8 ff ff       	call   80201f <seek>
  802815:	83 c4 10             	add    $0x10,%esp
  802818:	85 c0                	test   %eax,%eax
  80281a:	0f 88 c1 01 00 00    	js     8029e1 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802820:	83 ec 04             	sub    $0x4,%esp
  802823:	89 f8                	mov    %edi,%eax
  802825:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80282b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802830:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802835:	0f 47 c1             	cmova  %ecx,%eax
  802838:	50                   	push   %eax
  802839:	68 00 00 40 00       	push   $0x400000
  80283e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802844:	e8 01 f7 ff ff       	call   801f4a <readn>
  802849:	83 c4 10             	add    $0x10,%esp
  80284c:	85 c0                	test   %eax,%eax
  80284e:	0f 88 91 01 00 00    	js     8029e5 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802854:	83 ec 0c             	sub    $0xc,%esp
  802857:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80285d:	56                   	push   %esi
  80285e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802864:	68 00 00 40 00       	push   $0x400000
  802869:	6a 00                	push   $0x0
  80286b:	e8 38 ed ff ff       	call   8015a8 <sys_page_map>
  802870:	83 c4 20             	add    $0x20,%esp
  802873:	85 c0                	test   %eax,%eax
  802875:	79 15                	jns    80288c <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  802877:	50                   	push   %eax
  802878:	68 48 3e 80 00       	push   $0x803e48
  80287d:	68 25 01 00 00       	push   $0x125
  802882:	68 3c 3e 80 00       	push   $0x803e3c
  802887:	e8 85 e1 ff ff       	call   800a11 <_panic>
			sys_page_unmap(0, UTEMP);
  80288c:	83 ec 08             	sub    $0x8,%esp
  80288f:	68 00 00 40 00       	push   $0x400000
  802894:	6a 00                	push   $0x0
  802896:	e8 4f ed ff ff       	call   8015ea <sys_page_unmap>
  80289b:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80289e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028a4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028aa:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028b0:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8028b6:	0f 87 f7 fe ff ff    	ja     8027b3 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028bc:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028c3:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028ca:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028d1:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8028d7:	0f 8c 63 fe ff ff    	jl     802740 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028dd:	83 ec 0c             	sub    $0xc,%esp
  8028e0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028e6:	e8 92 f4 ff ff       	call   801d7d <close>
  8028eb:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8028ee:	bb 00 08 00 00       	mov    $0x800,%ebx
  8028f3:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  8028f9:	89 d8                	mov    %ebx,%eax
  8028fb:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8028fe:	89 c2                	mov    %eax,%edx
  802900:	c1 ea 16             	shr    $0x16,%edx
  802903:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80290a:	f6 c2 01             	test   $0x1,%dl
  80290d:	74 4b                	je     80295a <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80290f:	89 c2                	mov    %eax,%edx
  802911:	c1 ea 0c             	shr    $0xc,%edx
  802914:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80291b:	f6 c1 01             	test   $0x1,%cl
  80291e:	74 3a                	je     80295a <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  802920:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802927:	f6 c6 04             	test   $0x4,%dh
  80292a:	74 2e                	je     80295a <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  80292c:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  802933:	8b 0d 28 54 80 00    	mov    0x805428,%ecx
  802939:	8b 49 48             	mov    0x48(%ecx),%ecx
  80293c:	83 ec 0c             	sub    $0xc,%esp
  80293f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802945:	52                   	push   %edx
  802946:	50                   	push   %eax
  802947:	56                   	push   %esi
  802948:	50                   	push   %eax
  802949:	51                   	push   %ecx
  80294a:	e8 59 ec ff ff       	call   8015a8 <sys_page_map>
					if (r < 0)
  80294f:	83 c4 20             	add    $0x20,%esp
  802952:	85 c0                	test   %eax,%eax
  802954:	0f 88 ae 00 00 00    	js     802a08 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80295a:	83 c3 01             	add    $0x1,%ebx
  80295d:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  802963:	75 94                	jne    8028f9 <spawn+0x40e>
  802965:	e9 b3 00 00 00       	jmp    802a1d <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  80296a:	50                   	push   %eax
  80296b:	68 65 3e 80 00       	push   $0x803e65
  802970:	68 86 00 00 00       	push   $0x86
  802975:	68 3c 3e 80 00       	push   $0x803e3c
  80297a:	e8 92 e0 ff ff       	call   800a11 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80297f:	83 ec 08             	sub    $0x8,%esp
  802982:	6a 02                	push   $0x2
  802984:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80298a:	e8 9d ec ff ff       	call   80162c <sys_env_set_status>
  80298f:	83 c4 10             	add    $0x10,%esp
  802992:	85 c0                	test   %eax,%eax
  802994:	79 2b                	jns    8029c1 <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  802996:	50                   	push   %eax
  802997:	68 7f 3e 80 00       	push   $0x803e7f
  80299c:	68 89 00 00 00       	push   $0x89
  8029a1:	68 3c 3e 80 00       	push   $0x803e3c
  8029a6:	e8 66 e0 ff ff       	call   800a11 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029ab:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8029b1:	e9 a8 00 00 00       	jmp    802a5e <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029b6:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029bc:	e9 9d 00 00 00       	jmp    802a5e <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029c1:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029c7:	e9 92 00 00 00       	jmp    802a5e <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029cc:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8029d1:	e9 88 00 00 00       	jmp    802a5e <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8029d6:	89 c3                	mov    %eax,%ebx
  8029d8:	e9 81 00 00 00       	jmp    802a5e <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8029dd:	89 c3                	mov    %eax,%ebx
  8029df:	eb 06                	jmp    8029e7 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8029e1:	89 c3                	mov    %eax,%ebx
  8029e3:	eb 02                	jmp    8029e7 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8029e5:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8029e7:	83 ec 0c             	sub    $0xc,%esp
  8029ea:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029f0:	e8 f1 ea ff ff       	call   8014e6 <sys_env_destroy>
	close(fd);
  8029f5:	83 c4 04             	add    $0x4,%esp
  8029f8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8029fe:	e8 7a f3 ff ff       	call   801d7d <close>
	return r;
  802a03:	83 c4 10             	add    $0x10,%esp
  802a06:	eb 56                	jmp    802a5e <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802a08:	50                   	push   %eax
  802a09:	68 96 3e 80 00       	push   $0x803e96
  802a0e:	68 82 00 00 00       	push   $0x82
  802a13:	68 3c 3e 80 00       	push   $0x803e3c
  802a18:	e8 f4 df ff ff       	call   800a11 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802a1d:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802a24:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a27:	83 ec 08             	sub    $0x8,%esp
  802a2a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a30:	50                   	push   %eax
  802a31:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a37:	e8 32 ec ff ff       	call   80166e <sys_env_set_trapframe>
  802a3c:	83 c4 10             	add    $0x10,%esp
  802a3f:	85 c0                	test   %eax,%eax
  802a41:	0f 89 38 ff ff ff    	jns    80297f <spawn+0x494>
  802a47:	e9 1e ff ff ff       	jmp    80296a <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a4c:	83 ec 08             	sub    $0x8,%esp
  802a4f:	68 00 00 40 00       	push   $0x400000
  802a54:	6a 00                	push   $0x0
  802a56:	e8 8f eb ff ff       	call   8015ea <sys_page_unmap>
  802a5b:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a5e:	89 d8                	mov    %ebx,%eax
  802a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a63:	5b                   	pop    %ebx
  802a64:	5e                   	pop    %esi
  802a65:	5f                   	pop    %edi
  802a66:	5d                   	pop    %ebp
  802a67:	c3                   	ret    

00802a68 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a68:	55                   	push   %ebp
  802a69:	89 e5                	mov    %esp,%ebp
  802a6b:	56                   	push   %esi
  802a6c:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a6d:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a70:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a75:	eb 03                	jmp    802a7a <spawnl+0x12>
		argc++;
  802a77:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a7a:	83 c2 04             	add    $0x4,%edx
  802a7d:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802a81:	75 f4                	jne    802a77 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a83:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a8a:	83 e2 f0             	and    $0xfffffff0,%edx
  802a8d:	29 d4                	sub    %edx,%esp
  802a8f:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a93:	c1 ea 02             	shr    $0x2,%edx
  802a96:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a9d:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802aa2:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802aa9:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802ab0:	00 
  802ab1:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  802ab8:	eb 0a                	jmp    802ac4 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802aba:	83 c0 01             	add    $0x1,%eax
  802abd:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802ac1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802ac4:	39 d0                	cmp    %edx,%eax
  802ac6:	75 f2                	jne    802aba <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802ac8:	83 ec 08             	sub    $0x8,%esp
  802acb:	56                   	push   %esi
  802acc:	ff 75 08             	pushl  0x8(%ebp)
  802acf:	e8 17 fa ff ff       	call   8024eb <spawn>
}
  802ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ad7:	5b                   	pop    %ebx
  802ad8:	5e                   	pop    %esi
  802ad9:	5d                   	pop    %ebp
  802ada:	c3                   	ret    

00802adb <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802adb:	55                   	push   %ebp
  802adc:	89 e5                	mov    %esp,%ebp
  802ade:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802ae1:	68 d4 3e 80 00       	push   $0x803ed4
  802ae6:	ff 75 0c             	pushl  0xc(%ebp)
  802ae9:	e8 74 e6 ff ff       	call   801162 <strcpy>
	return 0;
}
  802aee:	b8 00 00 00 00       	mov    $0x0,%eax
  802af3:	c9                   	leave  
  802af4:	c3                   	ret    

00802af5 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802af5:	55                   	push   %ebp
  802af6:	89 e5                	mov    %esp,%ebp
  802af8:	53                   	push   %ebx
  802af9:	83 ec 10             	sub    $0x10,%esp
  802afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802aff:	53                   	push   %ebx
  802b00:	e8 47 09 00 00       	call   80344c <pageref>
  802b05:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802b08:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802b0d:	83 f8 01             	cmp    $0x1,%eax
  802b10:	75 10                	jne    802b22 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802b12:	83 ec 0c             	sub    $0xc,%esp
  802b15:	ff 73 0c             	pushl  0xc(%ebx)
  802b18:	e8 c0 02 00 00       	call   802ddd <nsipc_close>
  802b1d:	89 c2                	mov    %eax,%edx
  802b1f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802b22:	89 d0                	mov    %edx,%eax
  802b24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b27:	c9                   	leave  
  802b28:	c3                   	ret    

00802b29 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802b29:	55                   	push   %ebp
  802b2a:	89 e5                	mov    %esp,%ebp
  802b2c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802b2f:	6a 00                	push   $0x0
  802b31:	ff 75 10             	pushl  0x10(%ebp)
  802b34:	ff 75 0c             	pushl  0xc(%ebp)
  802b37:	8b 45 08             	mov    0x8(%ebp),%eax
  802b3a:	ff 70 0c             	pushl  0xc(%eax)
  802b3d:	e8 78 03 00 00       	call   802eba <nsipc_send>
}
  802b42:	c9                   	leave  
  802b43:	c3                   	ret    

00802b44 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802b44:	55                   	push   %ebp
  802b45:	89 e5                	mov    %esp,%ebp
  802b47:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802b4a:	6a 00                	push   $0x0
  802b4c:	ff 75 10             	pushl  0x10(%ebp)
  802b4f:	ff 75 0c             	pushl  0xc(%ebp)
  802b52:	8b 45 08             	mov    0x8(%ebp),%eax
  802b55:	ff 70 0c             	pushl  0xc(%eax)
  802b58:	e8 f1 02 00 00       	call   802e4e <nsipc_recv>
}
  802b5d:	c9                   	leave  
  802b5e:	c3                   	ret    

00802b5f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802b5f:	55                   	push   %ebp
  802b60:	89 e5                	mov    %esp,%ebp
  802b62:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802b65:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802b68:	52                   	push   %edx
  802b69:	50                   	push   %eax
  802b6a:	e8 e4 f0 ff ff       	call   801c53 <fd_lookup>
  802b6f:	83 c4 10             	add    $0x10,%esp
  802b72:	85 c0                	test   %eax,%eax
  802b74:	78 17                	js     802b8d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b79:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  802b7f:	39 08                	cmp    %ecx,(%eax)
  802b81:	75 05                	jne    802b88 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802b83:	8b 40 0c             	mov    0xc(%eax),%eax
  802b86:	eb 05                	jmp    802b8d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802b88:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802b8d:	c9                   	leave  
  802b8e:	c3                   	ret    

00802b8f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802b8f:	55                   	push   %ebp
  802b90:	89 e5                	mov    %esp,%ebp
  802b92:	56                   	push   %esi
  802b93:	53                   	push   %ebx
  802b94:	83 ec 1c             	sub    $0x1c,%esp
  802b97:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802b99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b9c:	50                   	push   %eax
  802b9d:	e8 62 f0 ff ff       	call   801c04 <fd_alloc>
  802ba2:	89 c3                	mov    %eax,%ebx
  802ba4:	83 c4 10             	add    $0x10,%esp
  802ba7:	85 c0                	test   %eax,%eax
  802ba9:	78 1b                	js     802bc6 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802bab:	83 ec 04             	sub    $0x4,%esp
  802bae:	68 07 04 00 00       	push   $0x407
  802bb3:	ff 75 f4             	pushl  -0xc(%ebp)
  802bb6:	6a 00                	push   $0x0
  802bb8:	e8 a8 e9 ff ff       	call   801565 <sys_page_alloc>
  802bbd:	89 c3                	mov    %eax,%ebx
  802bbf:	83 c4 10             	add    $0x10,%esp
  802bc2:	85 c0                	test   %eax,%eax
  802bc4:	79 10                	jns    802bd6 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802bc6:	83 ec 0c             	sub    $0xc,%esp
  802bc9:	56                   	push   %esi
  802bca:	e8 0e 02 00 00       	call   802ddd <nsipc_close>
		return r;
  802bcf:	83 c4 10             	add    $0x10,%esp
  802bd2:	89 d8                	mov    %ebx,%eax
  802bd4:	eb 24                	jmp    802bfa <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802bd6:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bdf:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802be4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802beb:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802bee:	83 ec 0c             	sub    $0xc,%esp
  802bf1:	50                   	push   %eax
  802bf2:	e8 e6 ef ff ff       	call   801bdd <fd2num>
  802bf7:	83 c4 10             	add    $0x10,%esp
}
  802bfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802bfd:	5b                   	pop    %ebx
  802bfe:	5e                   	pop    %esi
  802bff:	5d                   	pop    %ebp
  802c00:	c3                   	ret    

00802c01 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802c01:	55                   	push   %ebp
  802c02:	89 e5                	mov    %esp,%ebp
  802c04:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c07:	8b 45 08             	mov    0x8(%ebp),%eax
  802c0a:	e8 50 ff ff ff       	call   802b5f <fd2sockid>
		return r;
  802c0f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c11:	85 c0                	test   %eax,%eax
  802c13:	78 1f                	js     802c34 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802c15:	83 ec 04             	sub    $0x4,%esp
  802c18:	ff 75 10             	pushl  0x10(%ebp)
  802c1b:	ff 75 0c             	pushl  0xc(%ebp)
  802c1e:	50                   	push   %eax
  802c1f:	e8 12 01 00 00       	call   802d36 <nsipc_accept>
  802c24:	83 c4 10             	add    $0x10,%esp
		return r;
  802c27:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802c29:	85 c0                	test   %eax,%eax
  802c2b:	78 07                	js     802c34 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802c2d:	e8 5d ff ff ff       	call   802b8f <alloc_sockfd>
  802c32:	89 c1                	mov    %eax,%ecx
}
  802c34:	89 c8                	mov    %ecx,%eax
  802c36:	c9                   	leave  
  802c37:	c3                   	ret    

00802c38 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802c38:	55                   	push   %ebp
  802c39:	89 e5                	mov    %esp,%ebp
  802c3b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  802c41:	e8 19 ff ff ff       	call   802b5f <fd2sockid>
  802c46:	85 c0                	test   %eax,%eax
  802c48:	78 12                	js     802c5c <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802c4a:	83 ec 04             	sub    $0x4,%esp
  802c4d:	ff 75 10             	pushl  0x10(%ebp)
  802c50:	ff 75 0c             	pushl  0xc(%ebp)
  802c53:	50                   	push   %eax
  802c54:	e8 2d 01 00 00       	call   802d86 <nsipc_bind>
  802c59:	83 c4 10             	add    $0x10,%esp
}
  802c5c:	c9                   	leave  
  802c5d:	c3                   	ret    

00802c5e <shutdown>:

int
shutdown(int s, int how)
{
  802c5e:	55                   	push   %ebp
  802c5f:	89 e5                	mov    %esp,%ebp
  802c61:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c64:	8b 45 08             	mov    0x8(%ebp),%eax
  802c67:	e8 f3 fe ff ff       	call   802b5f <fd2sockid>
  802c6c:	85 c0                	test   %eax,%eax
  802c6e:	78 0f                	js     802c7f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802c70:	83 ec 08             	sub    $0x8,%esp
  802c73:	ff 75 0c             	pushl  0xc(%ebp)
  802c76:	50                   	push   %eax
  802c77:	e8 3f 01 00 00       	call   802dbb <nsipc_shutdown>
  802c7c:	83 c4 10             	add    $0x10,%esp
}
  802c7f:	c9                   	leave  
  802c80:	c3                   	ret    

00802c81 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802c81:	55                   	push   %ebp
  802c82:	89 e5                	mov    %esp,%ebp
  802c84:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c87:	8b 45 08             	mov    0x8(%ebp),%eax
  802c8a:	e8 d0 fe ff ff       	call   802b5f <fd2sockid>
  802c8f:	85 c0                	test   %eax,%eax
  802c91:	78 12                	js     802ca5 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802c93:	83 ec 04             	sub    $0x4,%esp
  802c96:	ff 75 10             	pushl  0x10(%ebp)
  802c99:	ff 75 0c             	pushl  0xc(%ebp)
  802c9c:	50                   	push   %eax
  802c9d:	e8 55 01 00 00       	call   802df7 <nsipc_connect>
  802ca2:	83 c4 10             	add    $0x10,%esp
}
  802ca5:	c9                   	leave  
  802ca6:	c3                   	ret    

00802ca7 <listen>:

int
listen(int s, int backlog)
{
  802ca7:	55                   	push   %ebp
  802ca8:	89 e5                	mov    %esp,%ebp
  802caa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802cad:	8b 45 08             	mov    0x8(%ebp),%eax
  802cb0:	e8 aa fe ff ff       	call   802b5f <fd2sockid>
  802cb5:	85 c0                	test   %eax,%eax
  802cb7:	78 0f                	js     802cc8 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802cb9:	83 ec 08             	sub    $0x8,%esp
  802cbc:	ff 75 0c             	pushl  0xc(%ebp)
  802cbf:	50                   	push   %eax
  802cc0:	e8 67 01 00 00       	call   802e2c <nsipc_listen>
  802cc5:	83 c4 10             	add    $0x10,%esp
}
  802cc8:	c9                   	leave  
  802cc9:	c3                   	ret    

00802cca <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802cca:	55                   	push   %ebp
  802ccb:	89 e5                	mov    %esp,%ebp
  802ccd:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802cd0:	ff 75 10             	pushl  0x10(%ebp)
  802cd3:	ff 75 0c             	pushl  0xc(%ebp)
  802cd6:	ff 75 08             	pushl  0x8(%ebp)
  802cd9:	e8 3a 02 00 00       	call   802f18 <nsipc_socket>
  802cde:	83 c4 10             	add    $0x10,%esp
  802ce1:	85 c0                	test   %eax,%eax
  802ce3:	78 05                	js     802cea <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802ce5:	e8 a5 fe ff ff       	call   802b8f <alloc_sockfd>
}
  802cea:	c9                   	leave  
  802ceb:	c3                   	ret    

00802cec <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802cec:	55                   	push   %ebp
  802ced:	89 e5                	mov    %esp,%ebp
  802cef:	53                   	push   %ebx
  802cf0:	83 ec 04             	sub    $0x4,%esp
  802cf3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802cf5:	83 3d 24 54 80 00 00 	cmpl   $0x0,0x805424
  802cfc:	75 12                	jne    802d10 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802cfe:	83 ec 0c             	sub    $0xc,%esp
  802d01:	6a 02                	push   $0x2
  802d03:	e8 0b 07 00 00       	call   803413 <ipc_find_env>
  802d08:	a3 24 54 80 00       	mov    %eax,0x805424
  802d0d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802d10:	6a 07                	push   $0x7
  802d12:	68 00 70 80 00       	push   $0x807000
  802d17:	53                   	push   %ebx
  802d18:	ff 35 24 54 80 00    	pushl  0x805424
  802d1e:	e8 9c 06 00 00       	call   8033bf <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802d23:	83 c4 0c             	add    $0xc,%esp
  802d26:	6a 00                	push   $0x0
  802d28:	6a 00                	push   $0x0
  802d2a:	6a 00                	push   $0x0
  802d2c:	e8 27 06 00 00       	call   803358 <ipc_recv>
}
  802d31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d34:	c9                   	leave  
  802d35:	c3                   	ret    

00802d36 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802d36:	55                   	push   %ebp
  802d37:	89 e5                	mov    %esp,%ebp
  802d39:	56                   	push   %esi
  802d3a:	53                   	push   %ebx
  802d3b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  802d41:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802d46:	8b 06                	mov    (%esi),%eax
  802d48:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802d4d:	b8 01 00 00 00       	mov    $0x1,%eax
  802d52:	e8 95 ff ff ff       	call   802cec <nsipc>
  802d57:	89 c3                	mov    %eax,%ebx
  802d59:	85 c0                	test   %eax,%eax
  802d5b:	78 20                	js     802d7d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802d5d:	83 ec 04             	sub    $0x4,%esp
  802d60:	ff 35 10 70 80 00    	pushl  0x807010
  802d66:	68 00 70 80 00       	push   $0x807000
  802d6b:	ff 75 0c             	pushl  0xc(%ebp)
  802d6e:	e8 81 e5 ff ff       	call   8012f4 <memmove>
		*addrlen = ret->ret_addrlen;
  802d73:	a1 10 70 80 00       	mov    0x807010,%eax
  802d78:	89 06                	mov    %eax,(%esi)
  802d7a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802d7d:	89 d8                	mov    %ebx,%eax
  802d7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d82:	5b                   	pop    %ebx
  802d83:	5e                   	pop    %esi
  802d84:	5d                   	pop    %ebp
  802d85:	c3                   	ret    

00802d86 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802d86:	55                   	push   %ebp
  802d87:	89 e5                	mov    %esp,%ebp
  802d89:	53                   	push   %ebx
  802d8a:	83 ec 08             	sub    $0x8,%esp
  802d8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802d90:	8b 45 08             	mov    0x8(%ebp),%eax
  802d93:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802d98:	53                   	push   %ebx
  802d99:	ff 75 0c             	pushl  0xc(%ebp)
  802d9c:	68 04 70 80 00       	push   $0x807004
  802da1:	e8 4e e5 ff ff       	call   8012f4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802da6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802dac:	b8 02 00 00 00       	mov    $0x2,%eax
  802db1:	e8 36 ff ff ff       	call   802cec <nsipc>
}
  802db6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802db9:	c9                   	leave  
  802dba:	c3                   	ret    

00802dbb <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802dbb:	55                   	push   %ebp
  802dbc:	89 e5                	mov    %esp,%ebp
  802dbe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  802dc4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  802dcc:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802dd1:	b8 03 00 00 00       	mov    $0x3,%eax
  802dd6:	e8 11 ff ff ff       	call   802cec <nsipc>
}
  802ddb:	c9                   	leave  
  802ddc:	c3                   	ret    

00802ddd <nsipc_close>:

int
nsipc_close(int s)
{
  802ddd:	55                   	push   %ebp
  802dde:	89 e5                	mov    %esp,%ebp
  802de0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802de3:	8b 45 08             	mov    0x8(%ebp),%eax
  802de6:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802deb:	b8 04 00 00 00       	mov    $0x4,%eax
  802df0:	e8 f7 fe ff ff       	call   802cec <nsipc>
}
  802df5:	c9                   	leave  
  802df6:	c3                   	ret    

00802df7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802df7:	55                   	push   %ebp
  802df8:	89 e5                	mov    %esp,%ebp
  802dfa:	53                   	push   %ebx
  802dfb:	83 ec 08             	sub    $0x8,%esp
  802dfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802e01:	8b 45 08             	mov    0x8(%ebp),%eax
  802e04:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802e09:	53                   	push   %ebx
  802e0a:	ff 75 0c             	pushl  0xc(%ebp)
  802e0d:	68 04 70 80 00       	push   $0x807004
  802e12:	e8 dd e4 ff ff       	call   8012f4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802e17:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802e1d:	b8 05 00 00 00       	mov    $0x5,%eax
  802e22:	e8 c5 fe ff ff       	call   802cec <nsipc>
}
  802e27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e2a:	c9                   	leave  
  802e2b:	c3                   	ret    

00802e2c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802e2c:	55                   	push   %ebp
  802e2d:	89 e5                	mov    %esp,%ebp
  802e2f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802e32:	8b 45 08             	mov    0x8(%ebp),%eax
  802e35:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e3d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802e42:	b8 06 00 00 00       	mov    $0x6,%eax
  802e47:	e8 a0 fe ff ff       	call   802cec <nsipc>
}
  802e4c:	c9                   	leave  
  802e4d:	c3                   	ret    

00802e4e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802e4e:	55                   	push   %ebp
  802e4f:	89 e5                	mov    %esp,%ebp
  802e51:	56                   	push   %esi
  802e52:	53                   	push   %ebx
  802e53:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802e56:	8b 45 08             	mov    0x8(%ebp),%eax
  802e59:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802e5e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802e64:	8b 45 14             	mov    0x14(%ebp),%eax
  802e67:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802e6c:	b8 07 00 00 00       	mov    $0x7,%eax
  802e71:	e8 76 fe ff ff       	call   802cec <nsipc>
  802e76:	89 c3                	mov    %eax,%ebx
  802e78:	85 c0                	test   %eax,%eax
  802e7a:	78 35                	js     802eb1 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802e7c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802e81:	7f 04                	jg     802e87 <nsipc_recv+0x39>
  802e83:	39 c6                	cmp    %eax,%esi
  802e85:	7d 16                	jge    802e9d <nsipc_recv+0x4f>
  802e87:	68 e0 3e 80 00       	push   $0x803ee0
  802e8c:	68 5a 38 80 00       	push   $0x80385a
  802e91:	6a 62                	push   $0x62
  802e93:	68 f5 3e 80 00       	push   $0x803ef5
  802e98:	e8 74 db ff ff       	call   800a11 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802e9d:	83 ec 04             	sub    $0x4,%esp
  802ea0:	50                   	push   %eax
  802ea1:	68 00 70 80 00       	push   $0x807000
  802ea6:	ff 75 0c             	pushl  0xc(%ebp)
  802ea9:	e8 46 e4 ff ff       	call   8012f4 <memmove>
  802eae:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802eb1:	89 d8                	mov    %ebx,%eax
  802eb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802eb6:	5b                   	pop    %ebx
  802eb7:	5e                   	pop    %esi
  802eb8:	5d                   	pop    %ebp
  802eb9:	c3                   	ret    

00802eba <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802eba:	55                   	push   %ebp
  802ebb:	89 e5                	mov    %esp,%ebp
  802ebd:	53                   	push   %ebx
  802ebe:	83 ec 04             	sub    $0x4,%esp
  802ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  802ec7:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802ecc:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802ed2:	7e 16                	jle    802eea <nsipc_send+0x30>
  802ed4:	68 01 3f 80 00       	push   $0x803f01
  802ed9:	68 5a 38 80 00       	push   $0x80385a
  802ede:	6a 6d                	push   $0x6d
  802ee0:	68 f5 3e 80 00       	push   $0x803ef5
  802ee5:	e8 27 db ff ff       	call   800a11 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802eea:	83 ec 04             	sub    $0x4,%esp
  802eed:	53                   	push   %ebx
  802eee:	ff 75 0c             	pushl  0xc(%ebp)
  802ef1:	68 0c 70 80 00       	push   $0x80700c
  802ef6:	e8 f9 e3 ff ff       	call   8012f4 <memmove>
	nsipcbuf.send.req_size = size;
  802efb:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802f01:	8b 45 14             	mov    0x14(%ebp),%eax
  802f04:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802f09:	b8 08 00 00 00       	mov    $0x8,%eax
  802f0e:	e8 d9 fd ff ff       	call   802cec <nsipc>
}
  802f13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f16:	c9                   	leave  
  802f17:	c3                   	ret    

00802f18 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802f18:	55                   	push   %ebp
  802f19:	89 e5                	mov    %esp,%ebp
  802f1b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  802f21:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802f26:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f29:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802f2e:	8b 45 10             	mov    0x10(%ebp),%eax
  802f31:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802f36:	b8 09 00 00 00       	mov    $0x9,%eax
  802f3b:	e8 ac fd ff ff       	call   802cec <nsipc>
}
  802f40:	c9                   	leave  
  802f41:	c3                   	ret    

00802f42 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802f42:	55                   	push   %ebp
  802f43:	89 e5                	mov    %esp,%ebp
  802f45:	56                   	push   %esi
  802f46:	53                   	push   %ebx
  802f47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802f4a:	83 ec 0c             	sub    $0xc,%esp
  802f4d:	ff 75 08             	pushl  0x8(%ebp)
  802f50:	e8 98 ec ff ff       	call   801bed <fd2data>
  802f55:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802f57:	83 c4 08             	add    $0x8,%esp
  802f5a:	68 0d 3f 80 00       	push   $0x803f0d
  802f5f:	53                   	push   %ebx
  802f60:	e8 fd e1 ff ff       	call   801162 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802f65:	8b 46 04             	mov    0x4(%esi),%eax
  802f68:	2b 06                	sub    (%esi),%eax
  802f6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802f70:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802f77:	00 00 00 
	stat->st_dev = &devpipe;
  802f7a:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  802f81:	40 80 00 
	return 0;
}
  802f84:	b8 00 00 00 00       	mov    $0x0,%eax
  802f89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f8c:	5b                   	pop    %ebx
  802f8d:	5e                   	pop    %esi
  802f8e:	5d                   	pop    %ebp
  802f8f:	c3                   	ret    

00802f90 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802f90:	55                   	push   %ebp
  802f91:	89 e5                	mov    %esp,%ebp
  802f93:	53                   	push   %ebx
  802f94:	83 ec 0c             	sub    $0xc,%esp
  802f97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802f9a:	53                   	push   %ebx
  802f9b:	6a 00                	push   $0x0
  802f9d:	e8 48 e6 ff ff       	call   8015ea <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802fa2:	89 1c 24             	mov    %ebx,(%esp)
  802fa5:	e8 43 ec ff ff       	call   801bed <fd2data>
  802faa:	83 c4 08             	add    $0x8,%esp
  802fad:	50                   	push   %eax
  802fae:	6a 00                	push   $0x0
  802fb0:	e8 35 e6 ff ff       	call   8015ea <sys_page_unmap>
}
  802fb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fb8:	c9                   	leave  
  802fb9:	c3                   	ret    

00802fba <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802fba:	55                   	push   %ebp
  802fbb:	89 e5                	mov    %esp,%ebp
  802fbd:	57                   	push   %edi
  802fbe:	56                   	push   %esi
  802fbf:	53                   	push   %ebx
  802fc0:	83 ec 1c             	sub    $0x1c,%esp
  802fc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802fc6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802fc8:	a1 28 54 80 00       	mov    0x805428,%eax
  802fcd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802fd0:	83 ec 0c             	sub    $0xc,%esp
  802fd3:	ff 75 e0             	pushl  -0x20(%ebp)
  802fd6:	e8 71 04 00 00       	call   80344c <pageref>
  802fdb:	89 c3                	mov    %eax,%ebx
  802fdd:	89 3c 24             	mov    %edi,(%esp)
  802fe0:	e8 67 04 00 00       	call   80344c <pageref>
  802fe5:	83 c4 10             	add    $0x10,%esp
  802fe8:	39 c3                	cmp    %eax,%ebx
  802fea:	0f 94 c1             	sete   %cl
  802fed:	0f b6 c9             	movzbl %cl,%ecx
  802ff0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802ff3:	8b 15 28 54 80 00    	mov    0x805428,%edx
  802ff9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802ffc:	39 ce                	cmp    %ecx,%esi
  802ffe:	74 1b                	je     80301b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803000:	39 c3                	cmp    %eax,%ebx
  803002:	75 c4                	jne    802fc8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803004:	8b 42 58             	mov    0x58(%edx),%eax
  803007:	ff 75 e4             	pushl  -0x1c(%ebp)
  80300a:	50                   	push   %eax
  80300b:	56                   	push   %esi
  80300c:	68 14 3f 80 00       	push   $0x803f14
  803011:	e8 d4 da ff ff       	call   800aea <cprintf>
  803016:	83 c4 10             	add    $0x10,%esp
  803019:	eb ad                	jmp    802fc8 <_pipeisclosed+0xe>
	}
}
  80301b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80301e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803021:	5b                   	pop    %ebx
  803022:	5e                   	pop    %esi
  803023:	5f                   	pop    %edi
  803024:	5d                   	pop    %ebp
  803025:	c3                   	ret    

00803026 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803026:	55                   	push   %ebp
  803027:	89 e5                	mov    %esp,%ebp
  803029:	57                   	push   %edi
  80302a:	56                   	push   %esi
  80302b:	53                   	push   %ebx
  80302c:	83 ec 28             	sub    $0x28,%esp
  80302f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803032:	56                   	push   %esi
  803033:	e8 b5 eb ff ff       	call   801bed <fd2data>
  803038:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80303a:	83 c4 10             	add    $0x10,%esp
  80303d:	bf 00 00 00 00       	mov    $0x0,%edi
  803042:	eb 4b                	jmp    80308f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803044:	89 da                	mov    %ebx,%edx
  803046:	89 f0                	mov    %esi,%eax
  803048:	e8 6d ff ff ff       	call   802fba <_pipeisclosed>
  80304d:	85 c0                	test   %eax,%eax
  80304f:	75 48                	jne    803099 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803051:	e8 f0 e4 ff ff       	call   801546 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803056:	8b 43 04             	mov    0x4(%ebx),%eax
  803059:	8b 0b                	mov    (%ebx),%ecx
  80305b:	8d 51 20             	lea    0x20(%ecx),%edx
  80305e:	39 d0                	cmp    %edx,%eax
  803060:	73 e2                	jae    803044 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803062:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803065:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803069:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80306c:	89 c2                	mov    %eax,%edx
  80306e:	c1 fa 1f             	sar    $0x1f,%edx
  803071:	89 d1                	mov    %edx,%ecx
  803073:	c1 e9 1b             	shr    $0x1b,%ecx
  803076:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803079:	83 e2 1f             	and    $0x1f,%edx
  80307c:	29 ca                	sub    %ecx,%edx
  80307e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803082:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803086:	83 c0 01             	add    $0x1,%eax
  803089:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80308c:	83 c7 01             	add    $0x1,%edi
  80308f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803092:	75 c2                	jne    803056 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803094:	8b 45 10             	mov    0x10(%ebp),%eax
  803097:	eb 05                	jmp    80309e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803099:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80309e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030a1:	5b                   	pop    %ebx
  8030a2:	5e                   	pop    %esi
  8030a3:	5f                   	pop    %edi
  8030a4:	5d                   	pop    %ebp
  8030a5:	c3                   	ret    

008030a6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8030a6:	55                   	push   %ebp
  8030a7:	89 e5                	mov    %esp,%ebp
  8030a9:	57                   	push   %edi
  8030aa:	56                   	push   %esi
  8030ab:	53                   	push   %ebx
  8030ac:	83 ec 18             	sub    $0x18,%esp
  8030af:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8030b2:	57                   	push   %edi
  8030b3:	e8 35 eb ff ff       	call   801bed <fd2data>
  8030b8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030ba:	83 c4 10             	add    $0x10,%esp
  8030bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8030c2:	eb 3d                	jmp    803101 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8030c4:	85 db                	test   %ebx,%ebx
  8030c6:	74 04                	je     8030cc <devpipe_read+0x26>
				return i;
  8030c8:	89 d8                	mov    %ebx,%eax
  8030ca:	eb 44                	jmp    803110 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8030cc:	89 f2                	mov    %esi,%edx
  8030ce:	89 f8                	mov    %edi,%eax
  8030d0:	e8 e5 fe ff ff       	call   802fba <_pipeisclosed>
  8030d5:	85 c0                	test   %eax,%eax
  8030d7:	75 32                	jne    80310b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8030d9:	e8 68 e4 ff ff       	call   801546 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8030de:	8b 06                	mov    (%esi),%eax
  8030e0:	3b 46 04             	cmp    0x4(%esi),%eax
  8030e3:	74 df                	je     8030c4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8030e5:	99                   	cltd   
  8030e6:	c1 ea 1b             	shr    $0x1b,%edx
  8030e9:	01 d0                	add    %edx,%eax
  8030eb:	83 e0 1f             	and    $0x1f,%eax
  8030ee:	29 d0                	sub    %edx,%eax
  8030f0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8030f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030f8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8030fb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030fe:	83 c3 01             	add    $0x1,%ebx
  803101:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803104:	75 d8                	jne    8030de <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803106:	8b 45 10             	mov    0x10(%ebp),%eax
  803109:	eb 05                	jmp    803110 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80310b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803113:	5b                   	pop    %ebx
  803114:	5e                   	pop    %esi
  803115:	5f                   	pop    %edi
  803116:	5d                   	pop    %ebp
  803117:	c3                   	ret    

00803118 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803118:	55                   	push   %ebp
  803119:	89 e5                	mov    %esp,%ebp
  80311b:	56                   	push   %esi
  80311c:	53                   	push   %ebx
  80311d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803123:	50                   	push   %eax
  803124:	e8 db ea ff ff       	call   801c04 <fd_alloc>
  803129:	83 c4 10             	add    $0x10,%esp
  80312c:	89 c2                	mov    %eax,%edx
  80312e:	85 c0                	test   %eax,%eax
  803130:	0f 88 2c 01 00 00    	js     803262 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803136:	83 ec 04             	sub    $0x4,%esp
  803139:	68 07 04 00 00       	push   $0x407
  80313e:	ff 75 f4             	pushl  -0xc(%ebp)
  803141:	6a 00                	push   $0x0
  803143:	e8 1d e4 ff ff       	call   801565 <sys_page_alloc>
  803148:	83 c4 10             	add    $0x10,%esp
  80314b:	89 c2                	mov    %eax,%edx
  80314d:	85 c0                	test   %eax,%eax
  80314f:	0f 88 0d 01 00 00    	js     803262 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803155:	83 ec 0c             	sub    $0xc,%esp
  803158:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80315b:	50                   	push   %eax
  80315c:	e8 a3 ea ff ff       	call   801c04 <fd_alloc>
  803161:	89 c3                	mov    %eax,%ebx
  803163:	83 c4 10             	add    $0x10,%esp
  803166:	85 c0                	test   %eax,%eax
  803168:	0f 88 e2 00 00 00    	js     803250 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80316e:	83 ec 04             	sub    $0x4,%esp
  803171:	68 07 04 00 00       	push   $0x407
  803176:	ff 75 f0             	pushl  -0x10(%ebp)
  803179:	6a 00                	push   $0x0
  80317b:	e8 e5 e3 ff ff       	call   801565 <sys_page_alloc>
  803180:	89 c3                	mov    %eax,%ebx
  803182:	83 c4 10             	add    $0x10,%esp
  803185:	85 c0                	test   %eax,%eax
  803187:	0f 88 c3 00 00 00    	js     803250 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80318d:	83 ec 0c             	sub    $0xc,%esp
  803190:	ff 75 f4             	pushl  -0xc(%ebp)
  803193:	e8 55 ea ff ff       	call   801bed <fd2data>
  803198:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80319a:	83 c4 0c             	add    $0xc,%esp
  80319d:	68 07 04 00 00       	push   $0x407
  8031a2:	50                   	push   %eax
  8031a3:	6a 00                	push   $0x0
  8031a5:	e8 bb e3 ff ff       	call   801565 <sys_page_alloc>
  8031aa:	89 c3                	mov    %eax,%ebx
  8031ac:	83 c4 10             	add    $0x10,%esp
  8031af:	85 c0                	test   %eax,%eax
  8031b1:	0f 88 89 00 00 00    	js     803240 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031b7:	83 ec 0c             	sub    $0xc,%esp
  8031ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8031bd:	e8 2b ea ff ff       	call   801bed <fd2data>
  8031c2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8031c9:	50                   	push   %eax
  8031ca:	6a 00                	push   $0x0
  8031cc:	56                   	push   %esi
  8031cd:	6a 00                	push   $0x0
  8031cf:	e8 d4 e3 ff ff       	call   8015a8 <sys_page_map>
  8031d4:	89 c3                	mov    %eax,%ebx
  8031d6:	83 c4 20             	add    $0x20,%esp
  8031d9:	85 c0                	test   %eax,%eax
  8031db:	78 55                	js     803232 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8031dd:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8031e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031e6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8031e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031eb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8031f2:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8031f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031fb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8031fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803200:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803207:	83 ec 0c             	sub    $0xc,%esp
  80320a:	ff 75 f4             	pushl  -0xc(%ebp)
  80320d:	e8 cb e9 ff ff       	call   801bdd <fd2num>
  803212:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803215:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803217:	83 c4 04             	add    $0x4,%esp
  80321a:	ff 75 f0             	pushl  -0x10(%ebp)
  80321d:	e8 bb e9 ff ff       	call   801bdd <fd2num>
  803222:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803225:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803228:	83 c4 10             	add    $0x10,%esp
  80322b:	ba 00 00 00 00       	mov    $0x0,%edx
  803230:	eb 30                	jmp    803262 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803232:	83 ec 08             	sub    $0x8,%esp
  803235:	56                   	push   %esi
  803236:	6a 00                	push   $0x0
  803238:	e8 ad e3 ff ff       	call   8015ea <sys_page_unmap>
  80323d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803240:	83 ec 08             	sub    $0x8,%esp
  803243:	ff 75 f0             	pushl  -0x10(%ebp)
  803246:	6a 00                	push   $0x0
  803248:	e8 9d e3 ff ff       	call   8015ea <sys_page_unmap>
  80324d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803250:	83 ec 08             	sub    $0x8,%esp
  803253:	ff 75 f4             	pushl  -0xc(%ebp)
  803256:	6a 00                	push   $0x0
  803258:	e8 8d e3 ff ff       	call   8015ea <sys_page_unmap>
  80325d:	83 c4 10             	add    $0x10,%esp
  803260:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803262:	89 d0                	mov    %edx,%eax
  803264:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803267:	5b                   	pop    %ebx
  803268:	5e                   	pop    %esi
  803269:	5d                   	pop    %ebp
  80326a:	c3                   	ret    

0080326b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80326b:	55                   	push   %ebp
  80326c:	89 e5                	mov    %esp,%ebp
  80326e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803274:	50                   	push   %eax
  803275:	ff 75 08             	pushl  0x8(%ebp)
  803278:	e8 d6 e9 ff ff       	call   801c53 <fd_lookup>
  80327d:	83 c4 10             	add    $0x10,%esp
  803280:	85 c0                	test   %eax,%eax
  803282:	78 18                	js     80329c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803284:	83 ec 0c             	sub    $0xc,%esp
  803287:	ff 75 f4             	pushl  -0xc(%ebp)
  80328a:	e8 5e e9 ff ff       	call   801bed <fd2data>
	return _pipeisclosed(fd, p);
  80328f:	89 c2                	mov    %eax,%edx
  803291:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803294:	e8 21 fd ff ff       	call   802fba <_pipeisclosed>
  803299:	83 c4 10             	add    $0x10,%esp
}
  80329c:	c9                   	leave  
  80329d:	c3                   	ret    

0080329e <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80329e:	55                   	push   %ebp
  80329f:	89 e5                	mov    %esp,%ebp
  8032a1:	56                   	push   %esi
  8032a2:	53                   	push   %ebx
  8032a3:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8032a6:	85 f6                	test   %esi,%esi
  8032a8:	75 16                	jne    8032c0 <wait+0x22>
  8032aa:	68 2c 3f 80 00       	push   $0x803f2c
  8032af:	68 5a 38 80 00       	push   $0x80385a
  8032b4:	6a 09                	push   $0x9
  8032b6:	68 37 3f 80 00       	push   $0x803f37
  8032bb:	e8 51 d7 ff ff       	call   800a11 <_panic>
	e = &envs[ENVX(envid)];
  8032c0:	89 f3                	mov    %esi,%ebx
  8032c2:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8032c8:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8032cb:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8032d1:	eb 05                	jmp    8032d8 <wait+0x3a>
		sys_yield();
  8032d3:	e8 6e e2 ff ff       	call   801546 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8032d8:	8b 43 48             	mov    0x48(%ebx),%eax
  8032db:	39 c6                	cmp    %eax,%esi
  8032dd:	75 07                	jne    8032e6 <wait+0x48>
  8032df:	8b 43 54             	mov    0x54(%ebx),%eax
  8032e2:	85 c0                	test   %eax,%eax
  8032e4:	75 ed                	jne    8032d3 <wait+0x35>
		sys_yield();
}
  8032e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032e9:	5b                   	pop    %ebx
  8032ea:	5e                   	pop    %esi
  8032eb:	5d                   	pop    %ebp
  8032ec:	c3                   	ret    

008032ed <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8032ed:	55                   	push   %ebp
  8032ee:	89 e5                	mov    %esp,%ebp
  8032f0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8032f3:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8032fa:	75 2e                	jne    80332a <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8032fc:	e8 26 e2 ff ff       	call   801527 <sys_getenvid>
  803301:	83 ec 04             	sub    $0x4,%esp
  803304:	68 07 0e 00 00       	push   $0xe07
  803309:	68 00 f0 bf ee       	push   $0xeebff000
  80330e:	50                   	push   %eax
  80330f:	e8 51 e2 ff ff       	call   801565 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  803314:	e8 0e e2 ff ff       	call   801527 <sys_getenvid>
  803319:	83 c4 08             	add    $0x8,%esp
  80331c:	68 34 33 80 00       	push   $0x803334
  803321:	50                   	push   %eax
  803322:	e8 89 e3 ff ff       	call   8016b0 <sys_env_set_pgfault_upcall>
  803327:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80332a:	8b 45 08             	mov    0x8(%ebp),%eax
  80332d:	a3 00 80 80 00       	mov    %eax,0x808000
}
  803332:	c9                   	leave  
  803333:	c3                   	ret    

00803334 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803334:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803335:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80333a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80333c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80333f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  803343:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  803347:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80334a:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80334d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80334e:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  803351:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  803352:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  803353:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  803357:	c3                   	ret    

00803358 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803358:	55                   	push   %ebp
  803359:	89 e5                	mov    %esp,%ebp
  80335b:	56                   	push   %esi
  80335c:	53                   	push   %ebx
  80335d:	8b 75 08             	mov    0x8(%ebp),%esi
  803360:	8b 45 0c             	mov    0xc(%ebp),%eax
  803363:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  803366:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  803368:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80336d:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  803370:	83 ec 0c             	sub    $0xc,%esp
  803373:	50                   	push   %eax
  803374:	e8 9c e3 ff ff       	call   801715 <sys_ipc_recv>

	if (from_env_store != NULL)
  803379:	83 c4 10             	add    $0x10,%esp
  80337c:	85 f6                	test   %esi,%esi
  80337e:	74 14                	je     803394 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  803380:	ba 00 00 00 00       	mov    $0x0,%edx
  803385:	85 c0                	test   %eax,%eax
  803387:	78 09                	js     803392 <ipc_recv+0x3a>
  803389:	8b 15 28 54 80 00    	mov    0x805428,%edx
  80338f:	8b 52 74             	mov    0x74(%edx),%edx
  803392:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  803394:	85 db                	test   %ebx,%ebx
  803396:	74 14                	je     8033ac <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  803398:	ba 00 00 00 00       	mov    $0x0,%edx
  80339d:	85 c0                	test   %eax,%eax
  80339f:	78 09                	js     8033aa <ipc_recv+0x52>
  8033a1:	8b 15 28 54 80 00    	mov    0x805428,%edx
  8033a7:	8b 52 78             	mov    0x78(%edx),%edx
  8033aa:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8033ac:	85 c0                	test   %eax,%eax
  8033ae:	78 08                	js     8033b8 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8033b0:	a1 28 54 80 00       	mov    0x805428,%eax
  8033b5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8033b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8033bb:	5b                   	pop    %ebx
  8033bc:	5e                   	pop    %esi
  8033bd:	5d                   	pop    %ebp
  8033be:	c3                   	ret    

008033bf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8033bf:	55                   	push   %ebp
  8033c0:	89 e5                	mov    %esp,%ebp
  8033c2:	57                   	push   %edi
  8033c3:	56                   	push   %esi
  8033c4:	53                   	push   %ebx
  8033c5:	83 ec 0c             	sub    $0xc,%esp
  8033c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8033cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8033ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8033d1:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8033d3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8033d8:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8033db:	ff 75 14             	pushl  0x14(%ebp)
  8033de:	53                   	push   %ebx
  8033df:	56                   	push   %esi
  8033e0:	57                   	push   %edi
  8033e1:	e8 0c e3 ff ff       	call   8016f2 <sys_ipc_try_send>

		if (err < 0) {
  8033e6:	83 c4 10             	add    $0x10,%esp
  8033e9:	85 c0                	test   %eax,%eax
  8033eb:	79 1e                	jns    80340b <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8033ed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8033f0:	75 07                	jne    8033f9 <ipc_send+0x3a>
				sys_yield();
  8033f2:	e8 4f e1 ff ff       	call   801546 <sys_yield>
  8033f7:	eb e2                	jmp    8033db <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8033f9:	50                   	push   %eax
  8033fa:	68 42 3f 80 00       	push   $0x803f42
  8033ff:	6a 49                	push   $0x49
  803401:	68 4f 3f 80 00       	push   $0x803f4f
  803406:	e8 06 d6 ff ff       	call   800a11 <_panic>
		}

	} while (err < 0);

}
  80340b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80340e:	5b                   	pop    %ebx
  80340f:	5e                   	pop    %esi
  803410:	5f                   	pop    %edi
  803411:	5d                   	pop    %ebp
  803412:	c3                   	ret    

00803413 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803413:	55                   	push   %ebp
  803414:	89 e5                	mov    %esp,%ebp
  803416:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803419:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80341e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  803421:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803427:	8b 52 50             	mov    0x50(%edx),%edx
  80342a:	39 ca                	cmp    %ecx,%edx
  80342c:	75 0d                	jne    80343b <ipc_find_env+0x28>
			return envs[i].env_id;
  80342e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  803431:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  803436:	8b 40 48             	mov    0x48(%eax),%eax
  803439:	eb 0f                	jmp    80344a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80343b:	83 c0 01             	add    $0x1,%eax
  80343e:	3d 00 04 00 00       	cmp    $0x400,%eax
  803443:	75 d9                	jne    80341e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803445:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80344a:	5d                   	pop    %ebp
  80344b:	c3                   	ret    

0080344c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80344c:	55                   	push   %ebp
  80344d:	89 e5                	mov    %esp,%ebp
  80344f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803452:	89 d0                	mov    %edx,%eax
  803454:	c1 e8 16             	shr    $0x16,%eax
  803457:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80345e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803463:	f6 c1 01             	test   $0x1,%cl
  803466:	74 1d                	je     803485 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803468:	c1 ea 0c             	shr    $0xc,%edx
  80346b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803472:	f6 c2 01             	test   $0x1,%dl
  803475:	74 0e                	je     803485 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803477:	c1 ea 0c             	shr    $0xc,%edx
  80347a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803481:	ef 
  803482:	0f b7 c0             	movzwl %ax,%eax
}
  803485:	5d                   	pop    %ebp
  803486:	c3                   	ret    
  803487:	66 90                	xchg   %ax,%ax
  803489:	66 90                	xchg   %ax,%ax
  80348b:	66 90                	xchg   %ax,%ax
  80348d:	66 90                	xchg   %ax,%ax
  80348f:	90                   	nop

00803490 <__udivdi3>:
  803490:	55                   	push   %ebp
  803491:	57                   	push   %edi
  803492:	56                   	push   %esi
  803493:	53                   	push   %ebx
  803494:	83 ec 1c             	sub    $0x1c,%esp
  803497:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80349b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80349f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8034a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8034a7:	85 f6                	test   %esi,%esi
  8034a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8034ad:	89 ca                	mov    %ecx,%edx
  8034af:	89 f8                	mov    %edi,%eax
  8034b1:	75 3d                	jne    8034f0 <__udivdi3+0x60>
  8034b3:	39 cf                	cmp    %ecx,%edi
  8034b5:	0f 87 c5 00 00 00    	ja     803580 <__udivdi3+0xf0>
  8034bb:	85 ff                	test   %edi,%edi
  8034bd:	89 fd                	mov    %edi,%ebp
  8034bf:	75 0b                	jne    8034cc <__udivdi3+0x3c>
  8034c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8034c6:	31 d2                	xor    %edx,%edx
  8034c8:	f7 f7                	div    %edi
  8034ca:	89 c5                	mov    %eax,%ebp
  8034cc:	89 c8                	mov    %ecx,%eax
  8034ce:	31 d2                	xor    %edx,%edx
  8034d0:	f7 f5                	div    %ebp
  8034d2:	89 c1                	mov    %eax,%ecx
  8034d4:	89 d8                	mov    %ebx,%eax
  8034d6:	89 cf                	mov    %ecx,%edi
  8034d8:	f7 f5                	div    %ebp
  8034da:	89 c3                	mov    %eax,%ebx
  8034dc:	89 d8                	mov    %ebx,%eax
  8034de:	89 fa                	mov    %edi,%edx
  8034e0:	83 c4 1c             	add    $0x1c,%esp
  8034e3:	5b                   	pop    %ebx
  8034e4:	5e                   	pop    %esi
  8034e5:	5f                   	pop    %edi
  8034e6:	5d                   	pop    %ebp
  8034e7:	c3                   	ret    
  8034e8:	90                   	nop
  8034e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8034f0:	39 ce                	cmp    %ecx,%esi
  8034f2:	77 74                	ja     803568 <__udivdi3+0xd8>
  8034f4:	0f bd fe             	bsr    %esi,%edi
  8034f7:	83 f7 1f             	xor    $0x1f,%edi
  8034fa:	0f 84 98 00 00 00    	je     803598 <__udivdi3+0x108>
  803500:	bb 20 00 00 00       	mov    $0x20,%ebx
  803505:	89 f9                	mov    %edi,%ecx
  803507:	89 c5                	mov    %eax,%ebp
  803509:	29 fb                	sub    %edi,%ebx
  80350b:	d3 e6                	shl    %cl,%esi
  80350d:	89 d9                	mov    %ebx,%ecx
  80350f:	d3 ed                	shr    %cl,%ebp
  803511:	89 f9                	mov    %edi,%ecx
  803513:	d3 e0                	shl    %cl,%eax
  803515:	09 ee                	or     %ebp,%esi
  803517:	89 d9                	mov    %ebx,%ecx
  803519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80351d:	89 d5                	mov    %edx,%ebp
  80351f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803523:	d3 ed                	shr    %cl,%ebp
  803525:	89 f9                	mov    %edi,%ecx
  803527:	d3 e2                	shl    %cl,%edx
  803529:	89 d9                	mov    %ebx,%ecx
  80352b:	d3 e8                	shr    %cl,%eax
  80352d:	09 c2                	or     %eax,%edx
  80352f:	89 d0                	mov    %edx,%eax
  803531:	89 ea                	mov    %ebp,%edx
  803533:	f7 f6                	div    %esi
  803535:	89 d5                	mov    %edx,%ebp
  803537:	89 c3                	mov    %eax,%ebx
  803539:	f7 64 24 0c          	mull   0xc(%esp)
  80353d:	39 d5                	cmp    %edx,%ebp
  80353f:	72 10                	jb     803551 <__udivdi3+0xc1>
  803541:	8b 74 24 08          	mov    0x8(%esp),%esi
  803545:	89 f9                	mov    %edi,%ecx
  803547:	d3 e6                	shl    %cl,%esi
  803549:	39 c6                	cmp    %eax,%esi
  80354b:	73 07                	jae    803554 <__udivdi3+0xc4>
  80354d:	39 d5                	cmp    %edx,%ebp
  80354f:	75 03                	jne    803554 <__udivdi3+0xc4>
  803551:	83 eb 01             	sub    $0x1,%ebx
  803554:	31 ff                	xor    %edi,%edi
  803556:	89 d8                	mov    %ebx,%eax
  803558:	89 fa                	mov    %edi,%edx
  80355a:	83 c4 1c             	add    $0x1c,%esp
  80355d:	5b                   	pop    %ebx
  80355e:	5e                   	pop    %esi
  80355f:	5f                   	pop    %edi
  803560:	5d                   	pop    %ebp
  803561:	c3                   	ret    
  803562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803568:	31 ff                	xor    %edi,%edi
  80356a:	31 db                	xor    %ebx,%ebx
  80356c:	89 d8                	mov    %ebx,%eax
  80356e:	89 fa                	mov    %edi,%edx
  803570:	83 c4 1c             	add    $0x1c,%esp
  803573:	5b                   	pop    %ebx
  803574:	5e                   	pop    %esi
  803575:	5f                   	pop    %edi
  803576:	5d                   	pop    %ebp
  803577:	c3                   	ret    
  803578:	90                   	nop
  803579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803580:	89 d8                	mov    %ebx,%eax
  803582:	f7 f7                	div    %edi
  803584:	31 ff                	xor    %edi,%edi
  803586:	89 c3                	mov    %eax,%ebx
  803588:	89 d8                	mov    %ebx,%eax
  80358a:	89 fa                	mov    %edi,%edx
  80358c:	83 c4 1c             	add    $0x1c,%esp
  80358f:	5b                   	pop    %ebx
  803590:	5e                   	pop    %esi
  803591:	5f                   	pop    %edi
  803592:	5d                   	pop    %ebp
  803593:	c3                   	ret    
  803594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803598:	39 ce                	cmp    %ecx,%esi
  80359a:	72 0c                	jb     8035a8 <__udivdi3+0x118>
  80359c:	31 db                	xor    %ebx,%ebx
  80359e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8035a2:	0f 87 34 ff ff ff    	ja     8034dc <__udivdi3+0x4c>
  8035a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8035ad:	e9 2a ff ff ff       	jmp    8034dc <__udivdi3+0x4c>
  8035b2:	66 90                	xchg   %ax,%ax
  8035b4:	66 90                	xchg   %ax,%ax
  8035b6:	66 90                	xchg   %ax,%ax
  8035b8:	66 90                	xchg   %ax,%ax
  8035ba:	66 90                	xchg   %ax,%ax
  8035bc:	66 90                	xchg   %ax,%ax
  8035be:	66 90                	xchg   %ax,%ax

008035c0 <__umoddi3>:
  8035c0:	55                   	push   %ebp
  8035c1:	57                   	push   %edi
  8035c2:	56                   	push   %esi
  8035c3:	53                   	push   %ebx
  8035c4:	83 ec 1c             	sub    $0x1c,%esp
  8035c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8035cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8035cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8035d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8035d7:	85 d2                	test   %edx,%edx
  8035d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8035dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8035e1:	89 f3                	mov    %esi,%ebx
  8035e3:	89 3c 24             	mov    %edi,(%esp)
  8035e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8035ea:	75 1c                	jne    803608 <__umoddi3+0x48>
  8035ec:	39 f7                	cmp    %esi,%edi
  8035ee:	76 50                	jbe    803640 <__umoddi3+0x80>
  8035f0:	89 c8                	mov    %ecx,%eax
  8035f2:	89 f2                	mov    %esi,%edx
  8035f4:	f7 f7                	div    %edi
  8035f6:	89 d0                	mov    %edx,%eax
  8035f8:	31 d2                	xor    %edx,%edx
  8035fa:	83 c4 1c             	add    $0x1c,%esp
  8035fd:	5b                   	pop    %ebx
  8035fe:	5e                   	pop    %esi
  8035ff:	5f                   	pop    %edi
  803600:	5d                   	pop    %ebp
  803601:	c3                   	ret    
  803602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803608:	39 f2                	cmp    %esi,%edx
  80360a:	89 d0                	mov    %edx,%eax
  80360c:	77 52                	ja     803660 <__umoddi3+0xa0>
  80360e:	0f bd ea             	bsr    %edx,%ebp
  803611:	83 f5 1f             	xor    $0x1f,%ebp
  803614:	75 5a                	jne    803670 <__umoddi3+0xb0>
  803616:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80361a:	0f 82 e0 00 00 00    	jb     803700 <__umoddi3+0x140>
  803620:	39 0c 24             	cmp    %ecx,(%esp)
  803623:	0f 86 d7 00 00 00    	jbe    803700 <__umoddi3+0x140>
  803629:	8b 44 24 08          	mov    0x8(%esp),%eax
  80362d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803631:	83 c4 1c             	add    $0x1c,%esp
  803634:	5b                   	pop    %ebx
  803635:	5e                   	pop    %esi
  803636:	5f                   	pop    %edi
  803637:	5d                   	pop    %ebp
  803638:	c3                   	ret    
  803639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803640:	85 ff                	test   %edi,%edi
  803642:	89 fd                	mov    %edi,%ebp
  803644:	75 0b                	jne    803651 <__umoddi3+0x91>
  803646:	b8 01 00 00 00       	mov    $0x1,%eax
  80364b:	31 d2                	xor    %edx,%edx
  80364d:	f7 f7                	div    %edi
  80364f:	89 c5                	mov    %eax,%ebp
  803651:	89 f0                	mov    %esi,%eax
  803653:	31 d2                	xor    %edx,%edx
  803655:	f7 f5                	div    %ebp
  803657:	89 c8                	mov    %ecx,%eax
  803659:	f7 f5                	div    %ebp
  80365b:	89 d0                	mov    %edx,%eax
  80365d:	eb 99                	jmp    8035f8 <__umoddi3+0x38>
  80365f:	90                   	nop
  803660:	89 c8                	mov    %ecx,%eax
  803662:	89 f2                	mov    %esi,%edx
  803664:	83 c4 1c             	add    $0x1c,%esp
  803667:	5b                   	pop    %ebx
  803668:	5e                   	pop    %esi
  803669:	5f                   	pop    %edi
  80366a:	5d                   	pop    %ebp
  80366b:	c3                   	ret    
  80366c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803670:	8b 34 24             	mov    (%esp),%esi
  803673:	bf 20 00 00 00       	mov    $0x20,%edi
  803678:	89 e9                	mov    %ebp,%ecx
  80367a:	29 ef                	sub    %ebp,%edi
  80367c:	d3 e0                	shl    %cl,%eax
  80367e:	89 f9                	mov    %edi,%ecx
  803680:	89 f2                	mov    %esi,%edx
  803682:	d3 ea                	shr    %cl,%edx
  803684:	89 e9                	mov    %ebp,%ecx
  803686:	09 c2                	or     %eax,%edx
  803688:	89 d8                	mov    %ebx,%eax
  80368a:	89 14 24             	mov    %edx,(%esp)
  80368d:	89 f2                	mov    %esi,%edx
  80368f:	d3 e2                	shl    %cl,%edx
  803691:	89 f9                	mov    %edi,%ecx
  803693:	89 54 24 04          	mov    %edx,0x4(%esp)
  803697:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80369b:	d3 e8                	shr    %cl,%eax
  80369d:	89 e9                	mov    %ebp,%ecx
  80369f:	89 c6                	mov    %eax,%esi
  8036a1:	d3 e3                	shl    %cl,%ebx
  8036a3:	89 f9                	mov    %edi,%ecx
  8036a5:	89 d0                	mov    %edx,%eax
  8036a7:	d3 e8                	shr    %cl,%eax
  8036a9:	89 e9                	mov    %ebp,%ecx
  8036ab:	09 d8                	or     %ebx,%eax
  8036ad:	89 d3                	mov    %edx,%ebx
  8036af:	89 f2                	mov    %esi,%edx
  8036b1:	f7 34 24             	divl   (%esp)
  8036b4:	89 d6                	mov    %edx,%esi
  8036b6:	d3 e3                	shl    %cl,%ebx
  8036b8:	f7 64 24 04          	mull   0x4(%esp)
  8036bc:	39 d6                	cmp    %edx,%esi
  8036be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8036c2:	89 d1                	mov    %edx,%ecx
  8036c4:	89 c3                	mov    %eax,%ebx
  8036c6:	72 08                	jb     8036d0 <__umoddi3+0x110>
  8036c8:	75 11                	jne    8036db <__umoddi3+0x11b>
  8036ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8036ce:	73 0b                	jae    8036db <__umoddi3+0x11b>
  8036d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8036d4:	1b 14 24             	sbb    (%esp),%edx
  8036d7:	89 d1                	mov    %edx,%ecx
  8036d9:	89 c3                	mov    %eax,%ebx
  8036db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8036df:	29 da                	sub    %ebx,%edx
  8036e1:	19 ce                	sbb    %ecx,%esi
  8036e3:	89 f9                	mov    %edi,%ecx
  8036e5:	89 f0                	mov    %esi,%eax
  8036e7:	d3 e0                	shl    %cl,%eax
  8036e9:	89 e9                	mov    %ebp,%ecx
  8036eb:	d3 ea                	shr    %cl,%edx
  8036ed:	89 e9                	mov    %ebp,%ecx
  8036ef:	d3 ee                	shr    %cl,%esi
  8036f1:	09 d0                	or     %edx,%eax
  8036f3:	89 f2                	mov    %esi,%edx
  8036f5:	83 c4 1c             	add    $0x1c,%esp
  8036f8:	5b                   	pop    %ebx
  8036f9:	5e                   	pop    %esi
  8036fa:	5f                   	pop    %edi
  8036fb:	5d                   	pop    %ebp
  8036fc:	c3                   	ret    
  8036fd:	8d 76 00             	lea    0x0(%esi),%esi
  803700:	29 f9                	sub    %edi,%ecx
  803702:	19 d6                	sbb    %edx,%esi
  803704:	89 74 24 04          	mov    %esi,0x4(%esp)
  803708:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80370c:	e9 18 ff ff ff       	jmp    803629 <__umoddi3+0x69>
