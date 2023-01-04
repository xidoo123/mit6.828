
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
  80002c:	e8 47 09 00 00       	call   800978 <libmain>
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
  80005b:	68 e0 31 80 00       	push   $0x8031e0
  800060:	e8 4c 0a 00 00       	call   800ab1 <cprintf>
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
  80007f:	68 ef 31 80 00       	push   $0x8031ef
  800084:	e8 28 0a 00 00       	call   800ab1 <cprintf>
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
  8000ab:	68 fd 31 80 00       	push   $0x8031fd
  8000b0:	e8 7c 11 00 00       	call   801231 <strchr>
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
  8000d8:	68 02 32 80 00       	push   $0x803202
  8000dd:	e8 cf 09 00 00       	call   800ab1 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 13 32 80 00       	push   $0x803213
  8000fb:	e8 31 11 00 00       	call   801231 <strchr>
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
  800126:	68 07 32 80 00       	push   $0x803207
  80012b:	e8 81 09 00 00       	call   800ab1 <cprintf>
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
  80014c:	68 0f 32 80 00       	push   $0x80320f
  800151:	e8 db 10 00 00       	call   801231 <strchr>
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
  80017b:	68 1b 32 80 00       	push   $0x80321b
  800180:	e8 2c 09 00 00       	call   800ab1 <cprintf>
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
  80023b:	0f 84 8f 00 00 00    	je     8002d0 <runcmd+0xc7>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 fe 01 00 00    	je     80044c <runcmd+0x243>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 e2 01 00 00       	jmp    80043a <runcmd+0x231>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 e8 00 00 00    	je     80034e <runcmd+0x145>
  800266:	e9 cf 01 00 00       	jmp    80043a <runcmd+0x231>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 25 32 80 00       	push   $0x803225
  800278:	e8 34 08 00 00       	call   800ab1 <cprintf>
				exit();
  80027d:	e8 3c 07 00 00       	call   8009be <exit>
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
  800294:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  800297:	50                   	push   %eax
  800298:	6a 00                	push   $0x0
  80029a:	e8 ff fe ff ff       	call   80019e <gettoken>
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	83 f8 77             	cmp    $0x77,%eax
  8002a5:	74 15                	je     8002bc <runcmd+0xb3>
				cprintf("syntax error: < not followed by word\n");
  8002a7:	83 ec 0c             	sub    $0xc,%esp
  8002aa:	68 80 33 80 00       	push   $0x803380
  8002af:	e8 fd 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002b4:	e8 05 07 00 00       	call   8009be <exit>
  8002b9:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			panic("< redirection not implemented");
  8002bc:	83 ec 04             	sub    $0x4,%esp
  8002bf:	68 39 32 80 00       	push   $0x803239
  8002c4:	6a 3a                	push   $0x3a
  8002c6:	68 57 32 80 00       	push   $0x803257
  8002cb:	e8 08 07 00 00       	call   8009d8 <_panic>
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	53                   	push   %ebx
  8002d4:	6a 00                	push   $0x0
  8002d6:	e8 c3 fe ff ff       	call   80019e <gettoken>
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	83 f8 77             	cmp    $0x77,%eax
  8002e1:	74 15                	je     8002f8 <runcmd+0xef>
				cprintf("syntax error: > not followed by word\n");
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	68 a8 33 80 00       	push   $0x8033a8
  8002eb:	e8 c1 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002f0:	e8 c9 06 00 00       	call   8009be <exit>
  8002f5:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  8002f8:	83 ec 08             	sub    $0x8,%esp
  8002fb:	68 01 03 00 00       	push   $0x301
  800300:	ff 75 a4             	pushl  -0x5c(%ebp)
  800303:	e8 56 1f 00 00       	call   80225e <open>
  800308:	89 c7                	mov    %eax,%edi
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 19                	jns    80032a <runcmd+0x121>
				cprintf("open %s for write: %e", t, fd);
  800311:	83 ec 04             	sub    $0x4,%esp
  800314:	50                   	push   %eax
  800315:	ff 75 a4             	pushl  -0x5c(%ebp)
  800318:	68 61 32 80 00       	push   $0x803261
  80031d:	e8 8f 07 00 00       	call   800ab1 <cprintf>
				exit();
  800322:	e8 97 06 00 00       	call   8009be <exit>
  800327:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  80032a:	83 ff 01             	cmp    $0x1,%edi
  80032d:	0f 84 f7 fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800333:	83 ec 08             	sub    $0x8,%esp
  800336:	6a 01                	push   $0x1
  800338:	57                   	push   %edi
  800339:	e8 b6 19 00 00       	call   801cf4 <dup>
				close(fd);
  80033e:	89 3c 24             	mov    %edi,(%esp)
  800341:	e8 5e 19 00 00       	call   801ca4 <close>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 dc fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800357:	50                   	push   %eax
  800358:	e8 7b 28 00 00       	call   802bd8 <pipe>
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	85 c0                	test   %eax,%eax
  800362:	79 16                	jns    80037a <runcmd+0x171>
				cprintf("pipe: %e", r);
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	50                   	push   %eax
  800368:	68 77 32 80 00       	push   $0x803277
  80036d:	e8 3f 07 00 00       	call   800ab1 <cprintf>
				exit();
  800372:	e8 47 06 00 00       	call   8009be <exit>
  800377:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  80037a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800381:	74 1c                	je     80039f <runcmd+0x196>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800383:	83 ec 04             	sub    $0x4,%esp
  800386:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80038c:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800392:	68 80 32 80 00       	push   $0x803280
  800397:	e8 15 07 00 00       	call   800ab1 <cprintf>
  80039c:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  80039f:	e8 52 14 00 00       	call   8017f6 <fork>
  8003a4:	89 c7                	mov    %eax,%edi
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	79 16                	jns    8003c0 <runcmd+0x1b7>
				cprintf("fork: %e", r);
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	50                   	push   %eax
  8003ae:	68 8d 32 80 00       	push   $0x80328d
  8003b3:	e8 f9 06 00 00       	call   800ab1 <cprintf>
				exit();
  8003b8:	e8 01 06 00 00       	call   8009be <exit>
  8003bd:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003c0:	85 ff                	test   %edi,%edi
  8003c2:	75 3c                	jne    800400 <runcmd+0x1f7>
				if (p[0] != 0) {
  8003c4:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	74 1c                	je     8003ea <runcmd+0x1e1>
					dup(p[0], 0);
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	6a 00                	push   $0x0
  8003d3:	50                   	push   %eax
  8003d4:	e8 1b 19 00 00       	call   801cf4 <dup>
					close(p[0]);
  8003d9:	83 c4 04             	add    $0x4,%esp
  8003dc:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003e2:	e8 bd 18 00 00       	call   801ca4 <close>
  8003e7:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  8003ea:	83 ec 0c             	sub    $0xc,%esp
  8003ed:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003f3:	e8 ac 18 00 00       	call   801ca4 <close>
				goto again;
  8003f8:	83 c4 10             	add    $0x10,%esp
  8003fb:	e9 25 fe ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800400:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800406:	83 f8 01             	cmp    $0x1,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[1], 1);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 01                	push   $0x1
  800410:	50                   	push   %eax
  800411:	e8 de 18 00 00       	call   801cf4 <dup>
					close(p[1]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80041f:	e8 80 18 00 00       	call   801ca4 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800430:	e8 6f 18 00 00       	call   801ca4 <close>
				goto runit;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	eb 17                	jmp    800451 <runcmd+0x248>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  80043a:	50                   	push   %eax
  80043b:	68 96 32 80 00       	push   $0x803296
  800440:	6a 70                	push   $0x70
  800442:	68 57 32 80 00       	push   $0x803257
  800447:	e8 8c 05 00 00       	call   8009d8 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  80044c:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800451:	85 f6                	test   %esi,%esi
  800453:	75 22                	jne    800477 <runcmd+0x26e>
		if (debug)
  800455:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80045c:	0f 84 96 01 00 00    	je     8005f8 <runcmd+0x3ef>
			cprintf("EMPTY COMMAND\n");
  800462:	83 ec 0c             	sub    $0xc,%esp
  800465:	68 b2 32 80 00       	push   $0x8032b2
  80046a:	e8 42 06 00 00       	call   800ab1 <cprintf>
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	e9 81 01 00 00       	jmp    8005f8 <runcmd+0x3ef>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  800477:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80047a:	80 38 2f             	cmpb   $0x2f,(%eax)
  80047d:	74 23                	je     8004a2 <runcmd+0x299>
		argv0buf[0] = '/';
  80047f:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	50                   	push   %eax
  80048a:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  800490:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  800496:	50                   	push   %eax
  800497:	e8 8d 0c 00 00       	call   801129 <strcpy>
		argv[0] = argv0buf;
  80049c:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004a2:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004a9:	00 

	// Print the command.
	if (debug) {
  8004aa:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004b1:	74 49                	je     8004fc <runcmd+0x2f3>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004b3:	a1 24 54 80 00       	mov    0x805424,%eax
  8004b8:	8b 40 48             	mov    0x48(%eax),%eax
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	50                   	push   %eax
  8004bf:	68 c1 32 80 00       	push   $0x8032c1
  8004c4:	e8 e8 05 00 00       	call   800ab1 <cprintf>
  8004c9:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	eb 11                	jmp    8004e2 <runcmd+0x2d9>
			cprintf(" %s", argv[i]);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	50                   	push   %eax
  8004d5:	68 49 33 80 00       	push   $0x803349
  8004da:	e8 d2 05 00 00       	call   800ab1 <cprintf>
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  8004e5:	8b 43 fc             	mov    -0x4(%ebx),%eax
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	75 e5                	jne    8004d1 <runcmd+0x2c8>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  8004ec:	83 ec 0c             	sub    $0xc,%esp
  8004ef:	68 00 32 80 00       	push   $0x803200
  8004f4:	e8 b8 05 00 00       	call   800ab1 <cprintf>
  8004f9:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800502:	50                   	push   %eax
  800503:	ff 75 a8             	pushl  -0x58(%ebp)
  800506:	e8 07 1f 00 00       	call   802412 <spawn>
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	0f 89 c3 00 00 00    	jns    8005db <runcmd+0x3d2>
		cprintf("spawn %s: %e\n", argv[0], r);
  800518:	83 ec 04             	sub    $0x4,%esp
  80051b:	50                   	push   %eax
  80051c:	ff 75 a8             	pushl  -0x58(%ebp)
  80051f:	68 cf 32 80 00       	push   $0x8032cf
  800524:	e8 88 05 00 00       	call   800ab1 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800529:	e8 a1 17 00 00       	call   801ccf <close_all>
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 4c                	jmp    80057f <runcmd+0x376>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800533:	a1 24 54 80 00       	mov    0x805424,%eax
  800538:	8b 40 48             	mov    0x48(%eax),%eax
  80053b:	53                   	push   %ebx
  80053c:	ff 75 a8             	pushl  -0x58(%ebp)
  80053f:	50                   	push   %eax
  800540:	68 dd 32 80 00       	push   $0x8032dd
  800545:	e8 67 05 00 00       	call   800ab1 <cprintf>
  80054a:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	53                   	push   %ebx
  800551:	e8 08 28 00 00       	call   802d5e <wait>
		if (debug)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800560:	0f 84 8c 00 00 00    	je     8005f2 <runcmd+0x3e9>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800566:	a1 24 54 80 00       	mov    0x805424,%eax
  80056b:	8b 40 48             	mov    0x48(%eax),%eax
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	50                   	push   %eax
  800572:	68 f2 32 80 00       	push   $0x8032f2
  800577:	e8 35 05 00 00       	call   800ab1 <cprintf>
  80057c:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80057f:	85 ff                	test   %edi,%edi
  800581:	74 51                	je     8005d4 <runcmd+0x3cb>
		if (debug)
  800583:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80058a:	74 1a                	je     8005a6 <runcmd+0x39d>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  80058c:	a1 24 54 80 00       	mov    0x805424,%eax
  800591:	8b 40 48             	mov    0x48(%eax),%eax
  800594:	83 ec 04             	sub    $0x4,%esp
  800597:	57                   	push   %edi
  800598:	50                   	push   %eax
  800599:	68 08 33 80 00       	push   $0x803308
  80059e:	e8 0e 05 00 00       	call   800ab1 <cprintf>
  8005a3:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	57                   	push   %edi
  8005aa:	e8 af 27 00 00       	call   802d5e <wait>
		if (debug)
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005b9:	74 19                	je     8005d4 <runcmd+0x3cb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005bb:	a1 24 54 80 00       	mov    0x805424,%eax
  8005c0:	8b 40 48             	mov    0x48(%eax),%eax
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	50                   	push   %eax
  8005c7:	68 f2 32 80 00       	push   $0x8032f2
  8005cc:	e8 e0 04 00 00       	call   800ab1 <cprintf>
  8005d1:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  8005d4:	e8 e5 03 00 00       	call   8009be <exit>
  8005d9:	eb 1d                	jmp    8005f8 <runcmd+0x3ef>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  8005db:	e8 ef 16 00 00       	call   801ccf <close_all>
	if (r >= 0) {
		if (debug)
  8005e0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005e7:	0f 84 60 ff ff ff    	je     80054d <runcmd+0x344>
  8005ed:	e9 41 ff ff ff       	jmp    800533 <runcmd+0x32a>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005f2:	85 ff                	test   %edi,%edi
  8005f4:	75 b0                	jne    8005a6 <runcmd+0x39d>
  8005f6:	eb dc                	jmp    8005d4 <runcmd+0x3cb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  8005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fb:	5b                   	pop    %ebx
  8005fc:	5e                   	pop    %esi
  8005fd:	5f                   	pop    %edi
  8005fe:	5d                   	pop    %ebp
  8005ff:	c3                   	ret    

00800600 <usage>:
}


void
usage(void)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800606:	68 d0 33 80 00       	push   $0x8033d0
  80060b:	e8 a1 04 00 00       	call   800ab1 <cprintf>
	exit();
  800610:	e8 a9 03 00 00       	call   8009be <exit>
}
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	c9                   	leave  
  800619:	c3                   	ret    

0080061a <umain>:

void
umain(int argc, char **argv)
{
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	57                   	push   %edi
  80061e:	56                   	push   %esi
  80061f:	53                   	push   %ebx
  800620:	83 ec 30             	sub    $0x30,%esp
  800623:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800626:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800629:	50                   	push   %eax
  80062a:	57                   	push   %edi
  80062b:	8d 45 08             	lea    0x8(%ebp),%eax
  80062e:	50                   	push   %eax
  80062f:	e8 7c 13 00 00       	call   8019b0 <argstart>
	while ((r = argnext(&args)) >= 0)
  800634:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800637:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80063e:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800643:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800646:	eb 2f                	jmp    800677 <umain+0x5d>
		switch (r) {
  800648:	83 f8 69             	cmp    $0x69,%eax
  80064b:	74 25                	je     800672 <umain+0x58>
  80064d:	83 f8 78             	cmp    $0x78,%eax
  800650:	74 07                	je     800659 <umain+0x3f>
  800652:	83 f8 64             	cmp    $0x64,%eax
  800655:	75 14                	jne    80066b <umain+0x51>
  800657:	eb 09                	jmp    800662 <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800659:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  800660:	eb 15                	jmp    800677 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  800662:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  800669:	eb 0c                	jmp    800677 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  80066b:	e8 90 ff ff ff       	call   800600 <usage>
  800670:	eb 05                	jmp    800677 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800672:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800677:	83 ec 0c             	sub    $0xc,%esp
  80067a:	53                   	push   %ebx
  80067b:	e8 60 13 00 00       	call   8019e0 <argnext>
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	79 c1                	jns    800648 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  800687:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  80068b:	7e 05                	jle    800692 <umain+0x78>
		usage();
  80068d:	e8 6e ff ff ff       	call   800600 <usage>
	if (argc == 2) {
  800692:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800696:	75 56                	jne    8006ee <umain+0xd4>
		close(0);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	6a 00                	push   $0x0
  80069d:	e8 02 16 00 00       	call   801ca4 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006a2:	83 c4 08             	add    $0x8,%esp
  8006a5:	6a 00                	push   $0x0
  8006a7:	ff 77 04             	pushl  0x4(%edi)
  8006aa:	e8 af 1b 00 00       	call   80225e <open>
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	79 1b                	jns    8006d1 <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	50                   	push   %eax
  8006ba:	ff 77 04             	pushl  0x4(%edi)
  8006bd:	68 25 33 80 00       	push   $0x803325
  8006c2:	68 20 01 00 00       	push   $0x120
  8006c7:	68 57 32 80 00       	push   $0x803257
  8006cc:	e8 07 03 00 00       	call   8009d8 <_panic>
		assert(r == 0);
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	74 19                	je     8006ee <umain+0xd4>
  8006d5:	68 31 33 80 00       	push   $0x803331
  8006da:	68 38 33 80 00       	push   $0x803338
  8006df:	68 21 01 00 00       	push   $0x121
  8006e4:	68 57 32 80 00       	push   $0x803257
  8006e9:	e8 ea 02 00 00       	call   8009d8 <_panic>
	}
	if (interactive == '?')
  8006ee:	83 fe 3f             	cmp    $0x3f,%esi
  8006f1:	75 0f                	jne    800702 <umain+0xe8>
		interactive = iscons(0);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	6a 00                	push   $0x0
  8006f8:	e8 f5 01 00 00       	call   8008f2 <iscons>
  8006fd:	89 c6                	mov    %eax,%esi
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	85 f6                	test   %esi,%esi
  800704:	b8 00 00 00 00       	mov    $0x0,%eax
  800709:	bf 4d 33 80 00       	mov    $0x80334d,%edi
  80070e:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	57                   	push   %edi
  800715:	e8 e3 08 00 00       	call   800ffd <readline>
  80071a:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	75 1e                	jne    800741 <umain+0x127>
			if (debug)
  800723:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80072a:	74 10                	je     80073c <umain+0x122>
				cprintf("EXITING\n");
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	68 50 33 80 00       	push   $0x803350
  800734:	e8 78 03 00 00       	call   800ab1 <cprintf>
  800739:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  80073c:	e8 7d 02 00 00       	call   8009be <exit>
		}
		if (debug)
  800741:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800748:	74 11                	je     80075b <umain+0x141>
			cprintf("LINE: %s\n", buf);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	68 59 33 80 00       	push   $0x803359
  800753:	e8 59 03 00 00       	call   800ab1 <cprintf>
  800758:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  80075b:	80 3b 23             	cmpb   $0x23,(%ebx)
  80075e:	74 b1                	je     800711 <umain+0xf7>
			continue;
		if (echocmds)
  800760:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800764:	74 11                	je     800777 <umain+0x15d>
			printf("# %s\n", buf);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	68 63 33 80 00       	push   $0x803363
  80076f:	e8 88 1c 00 00       	call   8023fc <printf>
  800774:	83 c4 10             	add    $0x10,%esp
		if (debug)
  800777:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80077e:	74 10                	je     800790 <umain+0x176>
			cprintf("BEFORE FORK\n");
  800780:	83 ec 0c             	sub    $0xc,%esp
  800783:	68 69 33 80 00       	push   $0x803369
  800788:	e8 24 03 00 00       	call   800ab1 <cprintf>
  80078d:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  800790:	e8 61 10 00 00       	call   8017f6 <fork>
  800795:	89 c6                	mov    %eax,%esi
  800797:	85 c0                	test   %eax,%eax
  800799:	79 15                	jns    8007b0 <umain+0x196>
			panic("fork: %e", r);
  80079b:	50                   	push   %eax
  80079c:	68 8d 32 80 00       	push   $0x80328d
  8007a1:	68 38 01 00 00       	push   $0x138
  8007a6:	68 57 32 80 00       	push   $0x803257
  8007ab:	e8 28 02 00 00       	call   8009d8 <_panic>
		if (debug)
  8007b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b7:	74 11                	je     8007ca <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	50                   	push   %eax
  8007bd:	68 76 33 80 00       	push   $0x803376
  8007c2:	e8 ea 02 00 00       	call   800ab1 <cprintf>
  8007c7:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  8007ca:	85 f6                	test   %esi,%esi
  8007cc:	75 16                	jne    8007e4 <umain+0x1ca>
			runcmd(buf);
  8007ce:	83 ec 0c             	sub    $0xc,%esp
  8007d1:	53                   	push   %ebx
  8007d2:	e8 32 fa ff ff       	call   800209 <runcmd>
			exit();
  8007d7:	e8 e2 01 00 00       	call   8009be <exit>
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	e9 2d ff ff ff       	jmp    800711 <umain+0xf7>
		} else
			wait(r);
  8007e4:	83 ec 0c             	sub    $0xc,%esp
  8007e7:	56                   	push   %esi
  8007e8:	e8 71 25 00 00       	call   802d5e <wait>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	e9 1c ff ff ff       	jmp    800711 <umain+0xf7>

008007f5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800805:	68 f1 33 80 00       	push   $0x8033f1
  80080a:	ff 75 0c             	pushl  0xc(%ebp)
  80080d:	e8 17 09 00 00       	call   801129 <strcpy>
	return 0;
}
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	57                   	push   %edi
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800825:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80082a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800830:	eb 2d                	jmp    80085f <devcons_write+0x46>
		m = n - tot;
  800832:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800835:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800837:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80083a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80083f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800842:	83 ec 04             	sub    $0x4,%esp
  800845:	53                   	push   %ebx
  800846:	03 45 0c             	add    0xc(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	57                   	push   %edi
  80084b:	e8 6b 0a 00 00       	call   8012bb <memmove>
		sys_cputs(buf, m);
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	53                   	push   %ebx
  800854:	57                   	push   %edi
  800855:	e8 16 0c 00 00       	call   801470 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80085a:	01 de                	add    %ebx,%esi
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	89 f0                	mov    %esi,%eax
  800861:	3b 75 10             	cmp    0x10(%ebp),%esi
  800864:	72 cc                	jb     800832 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800866:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800869:	5b                   	pop    %ebx
  80086a:	5e                   	pop    %esi
  80086b:	5f                   	pop    %edi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800879:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80087d:	74 2a                	je     8008a9 <devcons_read+0x3b>
  80087f:	eb 05                	jmp    800886 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800881:	e8 87 0c 00 00       	call   80150d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800886:	e8 03 0c 00 00       	call   80148e <sys_cgetc>
  80088b:	85 c0                	test   %eax,%eax
  80088d:	74 f2                	je     800881 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80088f:	85 c0                	test   %eax,%eax
  800891:	78 16                	js     8008a9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800893:	83 f8 04             	cmp    $0x4,%eax
  800896:	74 0c                	je     8008a4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	88 02                	mov    %al,(%edx)
	return 1;
  80089d:	b8 01 00 00 00       	mov    $0x1,%eax
  8008a2:	eb 05                	jmp    8008a9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008b7:	6a 01                	push   $0x1
  8008b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008bc:	50                   	push   %eax
  8008bd:	e8 ae 0b 00 00       	call   801470 <sys_cputs>
}
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <getchar>:

int
getchar(void)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8008cd:	6a 01                	push   $0x1
  8008cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008d2:	50                   	push   %eax
  8008d3:	6a 00                	push   $0x0
  8008d5:	e8 06 15 00 00       	call   801de0 <read>
	if (r < 0)
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 0f                	js     8008f0 <getchar+0x29>
		return r;
	if (r < 1)
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	7e 06                	jle    8008eb <getchar+0x24>
		return -E_EOF;
	return c;
  8008e5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8008e9:	eb 05                	jmp    8008f0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8008eb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008fb:	50                   	push   %eax
  8008fc:	ff 75 08             	pushl  0x8(%ebp)
  8008ff:	e8 76 12 00 00       	call   801b7a <fd_lookup>
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	85 c0                	test   %eax,%eax
  800909:	78 11                	js     80091c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80090b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800914:	39 10                	cmp    %edx,(%eax)
  800916:	0f 94 c0             	sete   %al
  800919:	0f b6 c0             	movzbl %al,%eax
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <opencons>:

int
opencons(void)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800927:	50                   	push   %eax
  800928:	e8 fe 11 00 00       	call   801b2b <fd_alloc>
  80092d:	83 c4 10             	add    $0x10,%esp
		return r;
  800930:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800932:	85 c0                	test   %eax,%eax
  800934:	78 3e                	js     800974 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800936:	83 ec 04             	sub    $0x4,%esp
  800939:	68 07 04 00 00       	push   $0x407
  80093e:	ff 75 f4             	pushl  -0xc(%ebp)
  800941:	6a 00                	push   $0x0
  800943:	e8 e4 0b 00 00       	call   80152c <sys_page_alloc>
  800948:	83 c4 10             	add    $0x10,%esp
		return r;
  80094b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80094d:	85 c0                	test   %eax,%eax
  80094f:	78 23                	js     800974 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800951:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800966:	83 ec 0c             	sub    $0xc,%esp
  800969:	50                   	push   %eax
  80096a:	e8 95 11 00 00       	call   801b04 <fd2num>
  80096f:	89 c2                	mov    %eax,%edx
  800971:	83 c4 10             	add    $0x10,%esp
}
  800974:	89 d0                	mov    %edx,%eax
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800980:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800983:	e8 66 0b 00 00       	call   8014ee <sys_getenvid>
  800988:	25 ff 03 00 00       	and    $0x3ff,%eax
  80098d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800990:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800995:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80099a:	85 db                	test   %ebx,%ebx
  80099c:	7e 07                	jle    8009a5 <libmain+0x2d>
		binaryname = argv[0];
  80099e:	8b 06                	mov    (%esi),%eax
  8009a0:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	e8 6b fc ff ff       	call   80061a <umain>

	// exit gracefully
	exit();
  8009af:	e8 0a 00 00 00       	call   8009be <exit>
}
  8009b4:	83 c4 10             	add    $0x10,%esp
  8009b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8009c4:	e8 06 13 00 00       	call   801ccf <close_all>
	sys_env_destroy(0);
  8009c9:	83 ec 0c             	sub    $0xc,%esp
  8009cc:	6a 00                	push   $0x0
  8009ce:	e8 da 0a 00 00       	call   8014ad <sys_env_destroy>
}
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8009dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8009e0:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8009e6:	e8 03 0b 00 00       	call   8014ee <sys_getenvid>
  8009eb:	83 ec 0c             	sub    $0xc,%esp
  8009ee:	ff 75 0c             	pushl  0xc(%ebp)
  8009f1:	ff 75 08             	pushl  0x8(%ebp)
  8009f4:	56                   	push   %esi
  8009f5:	50                   	push   %eax
  8009f6:	68 08 34 80 00       	push   $0x803408
  8009fb:	e8 b1 00 00 00       	call   800ab1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a00:	83 c4 18             	add    $0x18,%esp
  800a03:	53                   	push   %ebx
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	e8 54 00 00 00       	call   800a60 <vcprintf>
	cprintf("\n");
  800a0c:	c7 04 24 00 32 80 00 	movl   $0x803200,(%esp)
  800a13:	e8 99 00 00 00       	call   800ab1 <cprintf>
  800a18:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a1b:	cc                   	int3   
  800a1c:	eb fd                	jmp    800a1b <_panic+0x43>

00800a1e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	53                   	push   %ebx
  800a22:	83 ec 04             	sub    $0x4,%esp
  800a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a28:	8b 13                	mov    (%ebx),%edx
  800a2a:	8d 42 01             	lea    0x1(%edx),%eax
  800a2d:	89 03                	mov    %eax,(%ebx)
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a36:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a3b:	75 1a                	jne    800a57 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	68 ff 00 00 00       	push   $0xff
  800a45:	8d 43 08             	lea    0x8(%ebx),%eax
  800a48:	50                   	push   %eax
  800a49:	e8 22 0a 00 00       	call   801470 <sys_cputs>
		b->idx = 0;
  800a4e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a54:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a57:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800a69:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800a70:	00 00 00 
	b.cnt = 0;
  800a73:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800a7a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800a7d:	ff 75 0c             	pushl  0xc(%ebp)
  800a80:	ff 75 08             	pushl  0x8(%ebp)
  800a83:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800a89:	50                   	push   %eax
  800a8a:	68 1e 0a 80 00       	push   $0x800a1e
  800a8f:	e8 54 01 00 00       	call   800be8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800a94:	83 c4 08             	add    $0x8,%esp
  800a97:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800a9d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aa3:	50                   	push   %eax
  800aa4:	e8 c7 09 00 00       	call   801470 <sys_cputs>

	return b.cnt;
}
  800aa9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800ab7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800aba:	50                   	push   %eax
  800abb:	ff 75 08             	pushl  0x8(%ebp)
  800abe:	e8 9d ff ff ff       	call   800a60 <vcprintf>
	va_end(ap);

	return cnt;
}
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 1c             	sub    $0x1c,%esp
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800adb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ae1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ae6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800ae9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800aec:	39 d3                	cmp    %edx,%ebx
  800aee:	72 05                	jb     800af5 <printnum+0x30>
  800af0:	39 45 10             	cmp    %eax,0x10(%ebp)
  800af3:	77 45                	ja     800b3a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	ff 75 18             	pushl  0x18(%ebp)
  800afb:	8b 45 14             	mov    0x14(%ebp),%eax
  800afe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b01:	53                   	push   %ebx
  800b02:	ff 75 10             	pushl  0x10(%ebp)
  800b05:	83 ec 08             	sub    $0x8,%esp
  800b08:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b0b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b0e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b11:	ff 75 d8             	pushl  -0x28(%ebp)
  800b14:	e8 37 24 00 00       	call   802f50 <__udivdi3>
  800b19:	83 c4 18             	add    $0x18,%esp
  800b1c:	52                   	push   %edx
  800b1d:	50                   	push   %eax
  800b1e:	89 f2                	mov    %esi,%edx
  800b20:	89 f8                	mov    %edi,%eax
  800b22:	e8 9e ff ff ff       	call   800ac5 <printnum>
  800b27:	83 c4 20             	add    $0x20,%esp
  800b2a:	eb 18                	jmp    800b44 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b2c:	83 ec 08             	sub    $0x8,%esp
  800b2f:	56                   	push   %esi
  800b30:	ff 75 18             	pushl  0x18(%ebp)
  800b33:	ff d7                	call   *%edi
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	eb 03                	jmp    800b3d <printnum+0x78>
  800b3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b3d:	83 eb 01             	sub    $0x1,%ebx
  800b40:	85 db                	test   %ebx,%ebx
  800b42:	7f e8                	jg     800b2c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b44:	83 ec 08             	sub    $0x8,%esp
  800b47:	56                   	push   %esi
  800b48:	83 ec 04             	sub    $0x4,%esp
  800b4b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4e:	ff 75 e0             	pushl  -0x20(%ebp)
  800b51:	ff 75 dc             	pushl  -0x24(%ebp)
  800b54:	ff 75 d8             	pushl  -0x28(%ebp)
  800b57:	e8 24 25 00 00       	call   803080 <__umoddi3>
  800b5c:	83 c4 14             	add    $0x14,%esp
  800b5f:	0f be 80 2b 34 80 00 	movsbl 0x80342b(%eax),%eax
  800b66:	50                   	push   %eax
  800b67:	ff d7                	call   *%edi
}
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b77:	83 fa 01             	cmp    $0x1,%edx
  800b7a:	7e 0e                	jle    800b8a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b7c:	8b 10                	mov    (%eax),%edx
  800b7e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b81:	89 08                	mov    %ecx,(%eax)
  800b83:	8b 02                	mov    (%edx),%eax
  800b85:	8b 52 04             	mov    0x4(%edx),%edx
  800b88:	eb 22                	jmp    800bac <getuint+0x38>
	else if (lflag)
  800b8a:	85 d2                	test   %edx,%edx
  800b8c:	74 10                	je     800b9e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b8e:	8b 10                	mov    (%eax),%edx
  800b90:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b93:	89 08                	mov    %ecx,(%eax)
  800b95:	8b 02                	mov    (%edx),%eax
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	eb 0e                	jmp    800bac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b9e:	8b 10                	mov    (%eax),%edx
  800ba0:	8d 4a 04             	lea    0x4(%edx),%ecx
  800ba3:	89 08                	mov    %ecx,(%eax)
  800ba5:	8b 02                	mov    (%edx),%eax
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bb4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bb8:	8b 10                	mov    (%eax),%edx
  800bba:	3b 50 04             	cmp    0x4(%eax),%edx
  800bbd:	73 0a                	jae    800bc9 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bbf:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bc2:	89 08                	mov    %ecx,(%eax)
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	88 02                	mov    %al,(%edx)
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800bd1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800bd4:	50                   	push   %eax
  800bd5:	ff 75 10             	pushl  0x10(%ebp)
  800bd8:	ff 75 0c             	pushl  0xc(%ebp)
  800bdb:	ff 75 08             	pushl  0x8(%ebp)
  800bde:	e8 05 00 00 00       	call   800be8 <vprintfmt>
	va_end(ap);
}
  800be3:	83 c4 10             	add    $0x10,%esp
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 2c             	sub    $0x2c,%esp
  800bf1:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf7:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bfa:	eb 12                	jmp    800c0e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	0f 84 89 03 00 00    	je     800f8d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c04:	83 ec 08             	sub    $0x8,%esp
  800c07:	53                   	push   %ebx
  800c08:	50                   	push   %eax
  800c09:	ff d6                	call   *%esi
  800c0b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c0e:	83 c7 01             	add    $0x1,%edi
  800c11:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c15:	83 f8 25             	cmp    $0x25,%eax
  800c18:	75 e2                	jne    800bfc <vprintfmt+0x14>
  800c1a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c1e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c25:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c2c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	eb 07                	jmp    800c41 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c3d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c41:	8d 47 01             	lea    0x1(%edi),%eax
  800c44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c47:	0f b6 07             	movzbl (%edi),%eax
  800c4a:	0f b6 c8             	movzbl %al,%ecx
  800c4d:	83 e8 23             	sub    $0x23,%eax
  800c50:	3c 55                	cmp    $0x55,%al
  800c52:	0f 87 1a 03 00 00    	ja     800f72 <vprintfmt+0x38a>
  800c58:	0f b6 c0             	movzbl %al,%eax
  800c5b:	ff 24 85 60 35 80 00 	jmp    *0x803560(,%eax,4)
  800c62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c65:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800c69:	eb d6                	jmp    800c41 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c76:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800c79:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800c7d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800c80:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800c83:	83 fa 09             	cmp    $0x9,%edx
  800c86:	77 39                	ja     800cc1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c88:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c8b:	eb e9                	jmp    800c76 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c90:	8d 48 04             	lea    0x4(%eax),%ecx
  800c93:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c96:	8b 00                	mov    (%eax),%eax
  800c98:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c9e:	eb 27                	jmp    800cc7 <vprintfmt+0xdf>
  800ca0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800caa:	0f 49 c8             	cmovns %eax,%ecx
  800cad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb3:	eb 8c                	jmp    800c41 <vprintfmt+0x59>
  800cb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cb8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cbf:	eb 80                	jmp    800c41 <vprintfmt+0x59>
  800cc1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cc4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800cc7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ccb:	0f 89 70 ff ff ff    	jns    800c41 <vprintfmt+0x59>
				width = precision, precision = -1;
  800cd1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800cd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800cd7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800cde:	e9 5e ff ff ff       	jmp    800c41 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800ce3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ce9:	e9 53 ff ff ff       	jmp    800c41 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cee:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf1:	8d 50 04             	lea    0x4(%eax),%edx
  800cf4:	89 55 14             	mov    %edx,0x14(%ebp)
  800cf7:	83 ec 08             	sub    $0x8,%esp
  800cfa:	53                   	push   %ebx
  800cfb:	ff 30                	pushl  (%eax)
  800cfd:	ff d6                	call   *%esi
			break;
  800cff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d05:	e9 04 ff ff ff       	jmp    800c0e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0d:	8d 50 04             	lea    0x4(%eax),%edx
  800d10:	89 55 14             	mov    %edx,0x14(%ebp)
  800d13:	8b 00                	mov    (%eax),%eax
  800d15:	99                   	cltd   
  800d16:	31 d0                	xor    %edx,%eax
  800d18:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d1a:	83 f8 0f             	cmp    $0xf,%eax
  800d1d:	7f 0b                	jg     800d2a <vprintfmt+0x142>
  800d1f:	8b 14 85 c0 36 80 00 	mov    0x8036c0(,%eax,4),%edx
  800d26:	85 d2                	test   %edx,%edx
  800d28:	75 18                	jne    800d42 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d2a:	50                   	push   %eax
  800d2b:	68 43 34 80 00       	push   $0x803443
  800d30:	53                   	push   %ebx
  800d31:	56                   	push   %esi
  800d32:	e8 94 fe ff ff       	call   800bcb <printfmt>
  800d37:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d3d:	e9 cc fe ff ff       	jmp    800c0e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d42:	52                   	push   %edx
  800d43:	68 4a 33 80 00       	push   $0x80334a
  800d48:	53                   	push   %ebx
  800d49:	56                   	push   %esi
  800d4a:	e8 7c fe ff ff       	call   800bcb <printfmt>
  800d4f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d55:	e9 b4 fe ff ff       	jmp    800c0e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5d:	8d 50 04             	lea    0x4(%eax),%edx
  800d60:	89 55 14             	mov    %edx,0x14(%ebp)
  800d63:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800d65:	85 ff                	test   %edi,%edi
  800d67:	b8 3c 34 80 00       	mov    $0x80343c,%eax
  800d6c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800d6f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d73:	0f 8e 94 00 00 00    	jle    800e0d <vprintfmt+0x225>
  800d79:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800d7d:	0f 84 98 00 00 00    	je     800e1b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d83:	83 ec 08             	sub    $0x8,%esp
  800d86:	ff 75 d0             	pushl  -0x30(%ebp)
  800d89:	57                   	push   %edi
  800d8a:	e8 79 03 00 00       	call   801108 <strnlen>
  800d8f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800d92:	29 c1                	sub    %eax,%ecx
  800d94:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800d97:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800d9a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800d9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800da1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800da4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800da6:	eb 0f                	jmp    800db7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	53                   	push   %ebx
  800dac:	ff 75 e0             	pushl  -0x20(%ebp)
  800daf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800db1:	83 ef 01             	sub    $0x1,%edi
  800db4:	83 c4 10             	add    $0x10,%esp
  800db7:	85 ff                	test   %edi,%edi
  800db9:	7f ed                	jg     800da8 <vprintfmt+0x1c0>
  800dbb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dbe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800dc1:	85 c9                	test   %ecx,%ecx
  800dc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc8:	0f 49 c1             	cmovns %ecx,%eax
  800dcb:	29 c1                	sub    %eax,%ecx
  800dcd:	89 75 08             	mov    %esi,0x8(%ebp)
  800dd0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800dd3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800dd6:	89 cb                	mov    %ecx,%ebx
  800dd8:	eb 4d                	jmp    800e27 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800dda:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800dde:	74 1b                	je     800dfb <vprintfmt+0x213>
  800de0:	0f be c0             	movsbl %al,%eax
  800de3:	83 e8 20             	sub    $0x20,%eax
  800de6:	83 f8 5e             	cmp    $0x5e,%eax
  800de9:	76 10                	jbe    800dfb <vprintfmt+0x213>
					putch('?', putdat);
  800deb:	83 ec 08             	sub    $0x8,%esp
  800dee:	ff 75 0c             	pushl  0xc(%ebp)
  800df1:	6a 3f                	push   $0x3f
  800df3:	ff 55 08             	call   *0x8(%ebp)
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	eb 0d                	jmp    800e08 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800dfb:	83 ec 08             	sub    $0x8,%esp
  800dfe:	ff 75 0c             	pushl  0xc(%ebp)
  800e01:	52                   	push   %edx
  800e02:	ff 55 08             	call   *0x8(%ebp)
  800e05:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e08:	83 eb 01             	sub    $0x1,%ebx
  800e0b:	eb 1a                	jmp    800e27 <vprintfmt+0x23f>
  800e0d:	89 75 08             	mov    %esi,0x8(%ebp)
  800e10:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e13:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e16:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e19:	eb 0c                	jmp    800e27 <vprintfmt+0x23f>
  800e1b:	89 75 08             	mov    %esi,0x8(%ebp)
  800e1e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e21:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e24:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e27:	83 c7 01             	add    $0x1,%edi
  800e2a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e2e:	0f be d0             	movsbl %al,%edx
  800e31:	85 d2                	test   %edx,%edx
  800e33:	74 23                	je     800e58 <vprintfmt+0x270>
  800e35:	85 f6                	test   %esi,%esi
  800e37:	78 a1                	js     800dda <vprintfmt+0x1f2>
  800e39:	83 ee 01             	sub    $0x1,%esi
  800e3c:	79 9c                	jns    800dda <vprintfmt+0x1f2>
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	8b 75 08             	mov    0x8(%ebp),%esi
  800e43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e46:	eb 18                	jmp    800e60 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	53                   	push   %ebx
  800e4c:	6a 20                	push   $0x20
  800e4e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e50:	83 ef 01             	sub    $0x1,%edi
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	eb 08                	jmp    800e60 <vprintfmt+0x278>
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800e5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e60:	85 ff                	test   %edi,%edi
  800e62:	7f e4                	jg     800e48 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e67:	e9 a2 fd ff ff       	jmp    800c0e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e6c:	83 fa 01             	cmp    $0x1,%edx
  800e6f:	7e 16                	jle    800e87 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800e71:	8b 45 14             	mov    0x14(%ebp),%eax
  800e74:	8d 50 08             	lea    0x8(%eax),%edx
  800e77:	89 55 14             	mov    %edx,0x14(%ebp)
  800e7a:	8b 50 04             	mov    0x4(%eax),%edx
  800e7d:	8b 00                	mov    (%eax),%eax
  800e7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e82:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800e85:	eb 32                	jmp    800eb9 <vprintfmt+0x2d1>
	else if (lflag)
  800e87:	85 d2                	test   %edx,%edx
  800e89:	74 18                	je     800ea3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800e8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e8e:	8d 50 04             	lea    0x4(%eax),%edx
  800e91:	89 55 14             	mov    %edx,0x14(%ebp)
  800e94:	8b 00                	mov    (%eax),%eax
  800e96:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e99:	89 c1                	mov    %eax,%ecx
  800e9b:	c1 f9 1f             	sar    $0x1f,%ecx
  800e9e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ea1:	eb 16                	jmp    800eb9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ea3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea6:	8d 50 04             	lea    0x4(%eax),%edx
  800ea9:	89 55 14             	mov    %edx,0x14(%ebp)
  800eac:	8b 00                	mov    (%eax),%eax
  800eae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eb1:	89 c1                	mov    %eax,%ecx
  800eb3:	c1 f9 1f             	sar    $0x1f,%ecx
  800eb6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800eb9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ebc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ebf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ec4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ec8:	79 74                	jns    800f3e <vprintfmt+0x356>
				putch('-', putdat);
  800eca:	83 ec 08             	sub    $0x8,%esp
  800ecd:	53                   	push   %ebx
  800ece:	6a 2d                	push   $0x2d
  800ed0:	ff d6                	call   *%esi
				num = -(long long) num;
  800ed2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ed5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ed8:	f7 d8                	neg    %eax
  800eda:	83 d2 00             	adc    $0x0,%edx
  800edd:	f7 da                	neg    %edx
  800edf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ee2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ee7:	eb 55                	jmp    800f3e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ee9:	8d 45 14             	lea    0x14(%ebp),%eax
  800eec:	e8 83 fc ff ff       	call   800b74 <getuint>
			base = 10;
  800ef1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ef6:	eb 46                	jmp    800f3e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800ef8:	8d 45 14             	lea    0x14(%ebp),%eax
  800efb:	e8 74 fc ff ff       	call   800b74 <getuint>
			base = 8;
  800f00:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f05:	eb 37                	jmp    800f3e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	53                   	push   %ebx
  800f0b:	6a 30                	push   $0x30
  800f0d:	ff d6                	call   *%esi
			putch('x', putdat);
  800f0f:	83 c4 08             	add    $0x8,%esp
  800f12:	53                   	push   %ebx
  800f13:	6a 78                	push   $0x78
  800f15:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f17:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1a:	8d 50 04             	lea    0x4(%eax),%edx
  800f1d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f20:	8b 00                	mov    (%eax),%eax
  800f22:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f27:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f2a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f2f:	eb 0d                	jmp    800f3e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f31:	8d 45 14             	lea    0x14(%ebp),%eax
  800f34:	e8 3b fc ff ff       	call   800b74 <getuint>
			base = 16;
  800f39:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800f45:	57                   	push   %edi
  800f46:	ff 75 e0             	pushl  -0x20(%ebp)
  800f49:	51                   	push   %ecx
  800f4a:	52                   	push   %edx
  800f4b:	50                   	push   %eax
  800f4c:	89 da                	mov    %ebx,%edx
  800f4e:	89 f0                	mov    %esi,%eax
  800f50:	e8 70 fb ff ff       	call   800ac5 <printnum>
			break;
  800f55:	83 c4 20             	add    $0x20,%esp
  800f58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f5b:	e9 ae fc ff ff       	jmp    800c0e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f60:	83 ec 08             	sub    $0x8,%esp
  800f63:	53                   	push   %ebx
  800f64:	51                   	push   %ecx
  800f65:	ff d6                	call   *%esi
			break;
  800f67:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800f6d:	e9 9c fc ff ff       	jmp    800c0e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	53                   	push   %ebx
  800f76:	6a 25                	push   $0x25
  800f78:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	eb 03                	jmp    800f82 <vprintfmt+0x39a>
  800f7f:	83 ef 01             	sub    $0x1,%edi
  800f82:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800f86:	75 f7                	jne    800f7f <vprintfmt+0x397>
  800f88:	e9 81 fc ff ff       	jmp    800c0e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800f8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 18             	sub    $0x18,%esp
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fa1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fa4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fa8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	74 26                	je     800fdc <vsnprintf+0x47>
  800fb6:	85 d2                	test   %edx,%edx
  800fb8:	7e 22                	jle    800fdc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800fba:	ff 75 14             	pushl  0x14(%ebp)
  800fbd:	ff 75 10             	pushl  0x10(%ebp)
  800fc0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	68 ae 0b 80 00       	push   $0x800bae
  800fc9:	e8 1a fc ff ff       	call   800be8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800fce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fd1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	eb 05                	jmp    800fe1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800fdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    

00800fe3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800fe9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800fec:	50                   	push   %eax
  800fed:	ff 75 10             	pushl  0x10(%ebp)
  800ff0:	ff 75 0c             	pushl  0xc(%ebp)
  800ff3:	ff 75 08             	pushl  0x8(%ebp)
  800ff6:	e8 9a ff ff ff       	call   800f95 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801009:	85 c0                	test   %eax,%eax
  80100b:	74 13                	je     801020 <readline+0x23>
		fprintf(1, "%s", prompt);
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	50                   	push   %eax
  801011:	68 4a 33 80 00       	push   $0x80334a
  801016:	6a 01                	push   $0x1
  801018:	e8 c8 13 00 00       	call   8023e5 <fprintf>
  80101d:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	6a 00                	push   $0x0
  801025:	e8 c8 f8 ff ff       	call   8008f2 <iscons>
  80102a:	89 c7                	mov    %eax,%edi
  80102c:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80102f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801034:	e8 8e f8 ff ff       	call   8008c7 <getchar>
  801039:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80103b:	85 c0                	test   %eax,%eax
  80103d:	79 29                	jns    801068 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80103f:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801044:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801047:	0f 84 9b 00 00 00    	je     8010e8 <readline+0xeb>
				cprintf("read error: %e\n", c);
  80104d:	83 ec 08             	sub    $0x8,%esp
  801050:	53                   	push   %ebx
  801051:	68 1f 37 80 00       	push   $0x80371f
  801056:	e8 56 fa ff ff       	call   800ab1 <cprintf>
  80105b:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80105e:	b8 00 00 00 00       	mov    $0x0,%eax
  801063:	e9 80 00 00 00       	jmp    8010e8 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801068:	83 f8 08             	cmp    $0x8,%eax
  80106b:	0f 94 c2             	sete   %dl
  80106e:	83 f8 7f             	cmp    $0x7f,%eax
  801071:	0f 94 c0             	sete   %al
  801074:	08 c2                	or     %al,%dl
  801076:	74 1a                	je     801092 <readline+0x95>
  801078:	85 f6                	test   %esi,%esi
  80107a:	7e 16                	jle    801092 <readline+0x95>
			if (echoing)
  80107c:	85 ff                	test   %edi,%edi
  80107e:	74 0d                	je     80108d <readline+0x90>
				cputchar('\b');
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	6a 08                	push   $0x8
  801085:	e8 21 f8 ff ff       	call   8008ab <cputchar>
  80108a:	83 c4 10             	add    $0x10,%esp
			i--;
  80108d:	83 ee 01             	sub    $0x1,%esi
  801090:	eb a2                	jmp    801034 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801092:	83 fb 1f             	cmp    $0x1f,%ebx
  801095:	7e 26                	jle    8010bd <readline+0xc0>
  801097:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80109d:	7f 1e                	jg     8010bd <readline+0xc0>
			if (echoing)
  80109f:	85 ff                	test   %edi,%edi
  8010a1:	74 0c                	je     8010af <readline+0xb2>
				cputchar(c);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	53                   	push   %ebx
  8010a7:	e8 ff f7 ff ff       	call   8008ab <cputchar>
  8010ac:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010af:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8010b5:	8d 76 01             	lea    0x1(%esi),%esi
  8010b8:	e9 77 ff ff ff       	jmp    801034 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8010bd:	83 fb 0a             	cmp    $0xa,%ebx
  8010c0:	74 09                	je     8010cb <readline+0xce>
  8010c2:	83 fb 0d             	cmp    $0xd,%ebx
  8010c5:	0f 85 69 ff ff ff    	jne    801034 <readline+0x37>
			if (echoing)
  8010cb:	85 ff                	test   %edi,%edi
  8010cd:	74 0d                	je     8010dc <readline+0xdf>
				cputchar('\n');
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	6a 0a                	push   $0xa
  8010d4:	e8 d2 f7 ff ff       	call   8008ab <cputchar>
  8010d9:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8010dc:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  8010e3:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8010f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fb:	eb 03                	jmp    801100 <strlen+0x10>
		n++;
  8010fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801100:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801104:	75 f7                	jne    8010fd <strlen+0xd>
		n++;
	return n;
}
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801111:	ba 00 00 00 00       	mov    $0x0,%edx
  801116:	eb 03                	jmp    80111b <strnlen+0x13>
		n++;
  801118:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80111b:	39 c2                	cmp    %eax,%edx
  80111d:	74 08                	je     801127 <strnlen+0x1f>
  80111f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801123:	75 f3                	jne    801118 <strnlen+0x10>
  801125:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	53                   	push   %ebx
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
  801130:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801133:	89 c2                	mov    %eax,%edx
  801135:	83 c2 01             	add    $0x1,%edx
  801138:	83 c1 01             	add    $0x1,%ecx
  80113b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80113f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801142:	84 db                	test   %bl,%bl
  801144:	75 ef                	jne    801135 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801146:	5b                   	pop    %ebx
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	53                   	push   %ebx
  80114d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801150:	53                   	push   %ebx
  801151:	e8 9a ff ff ff       	call   8010f0 <strlen>
  801156:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801159:	ff 75 0c             	pushl  0xc(%ebp)
  80115c:	01 d8                	add    %ebx,%eax
  80115e:	50                   	push   %eax
  80115f:	e8 c5 ff ff ff       	call   801129 <strcpy>
	return dst;
}
  801164:	89 d8                	mov    %ebx,%eax
  801166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801169:	c9                   	leave  
  80116a:	c3                   	ret    

0080116b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	8b 75 08             	mov    0x8(%ebp),%esi
  801173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801176:	89 f3                	mov    %esi,%ebx
  801178:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80117b:	89 f2                	mov    %esi,%edx
  80117d:	eb 0f                	jmp    80118e <strncpy+0x23>
		*dst++ = *src;
  80117f:	83 c2 01             	add    $0x1,%edx
  801182:	0f b6 01             	movzbl (%ecx),%eax
  801185:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801188:	80 39 01             	cmpb   $0x1,(%ecx)
  80118b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80118e:	39 da                	cmp    %ebx,%edx
  801190:	75 ed                	jne    80117f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801192:	89 f0                	mov    %esi,%eax
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a3:	8b 55 10             	mov    0x10(%ebp),%edx
  8011a6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011a8:	85 d2                	test   %edx,%edx
  8011aa:	74 21                	je     8011cd <strlcpy+0x35>
  8011ac:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8011b0:	89 f2                	mov    %esi,%edx
  8011b2:	eb 09                	jmp    8011bd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8011b4:	83 c2 01             	add    $0x1,%edx
  8011b7:	83 c1 01             	add    $0x1,%ecx
  8011ba:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011bd:	39 c2                	cmp    %eax,%edx
  8011bf:	74 09                	je     8011ca <strlcpy+0x32>
  8011c1:	0f b6 19             	movzbl (%ecx),%ebx
  8011c4:	84 db                	test   %bl,%bl
  8011c6:	75 ec                	jne    8011b4 <strlcpy+0x1c>
  8011c8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8011ca:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8011cd:	29 f0                	sub    %esi,%eax
}
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8011dc:	eb 06                	jmp    8011e4 <strcmp+0x11>
		p++, q++;
  8011de:	83 c1 01             	add    $0x1,%ecx
  8011e1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8011e4:	0f b6 01             	movzbl (%ecx),%eax
  8011e7:	84 c0                	test   %al,%al
  8011e9:	74 04                	je     8011ef <strcmp+0x1c>
  8011eb:	3a 02                	cmp    (%edx),%al
  8011ed:	74 ef                	je     8011de <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8011ef:	0f b6 c0             	movzbl %al,%eax
  8011f2:	0f b6 12             	movzbl (%edx),%edx
  8011f5:	29 d0                	sub    %edx,%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	53                   	push   %ebx
  8011fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801200:	8b 55 0c             	mov    0xc(%ebp),%edx
  801203:	89 c3                	mov    %eax,%ebx
  801205:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801208:	eb 06                	jmp    801210 <strncmp+0x17>
		n--, p++, q++;
  80120a:	83 c0 01             	add    $0x1,%eax
  80120d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801210:	39 d8                	cmp    %ebx,%eax
  801212:	74 15                	je     801229 <strncmp+0x30>
  801214:	0f b6 08             	movzbl (%eax),%ecx
  801217:	84 c9                	test   %cl,%cl
  801219:	74 04                	je     80121f <strncmp+0x26>
  80121b:	3a 0a                	cmp    (%edx),%cl
  80121d:	74 eb                	je     80120a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80121f:	0f b6 00             	movzbl (%eax),%eax
  801222:	0f b6 12             	movzbl (%edx),%edx
  801225:	29 d0                	sub    %edx,%eax
  801227:	eb 05                	jmp    80122e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801229:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80122e:	5b                   	pop    %ebx
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
  801237:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80123b:	eb 07                	jmp    801244 <strchr+0x13>
		if (*s == c)
  80123d:	38 ca                	cmp    %cl,%dl
  80123f:	74 0f                	je     801250 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801241:	83 c0 01             	add    $0x1,%eax
  801244:	0f b6 10             	movzbl (%eax),%edx
  801247:	84 d2                	test   %dl,%dl
  801249:	75 f2                	jne    80123d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80124b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	8b 45 08             	mov    0x8(%ebp),%eax
  801258:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80125c:	eb 03                	jmp    801261 <strfind+0xf>
  80125e:	83 c0 01             	add    $0x1,%eax
  801261:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801264:	38 ca                	cmp    %cl,%dl
  801266:	74 04                	je     80126c <strfind+0x1a>
  801268:	84 d2                	test   %dl,%dl
  80126a:	75 f2                	jne    80125e <strfind+0xc>
			break;
	return (char *) s;
}
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	8b 7d 08             	mov    0x8(%ebp),%edi
  801277:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80127a:	85 c9                	test   %ecx,%ecx
  80127c:	74 36                	je     8012b4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80127e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801284:	75 28                	jne    8012ae <memset+0x40>
  801286:	f6 c1 03             	test   $0x3,%cl
  801289:	75 23                	jne    8012ae <memset+0x40>
		c &= 0xFF;
  80128b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80128f:	89 d3                	mov    %edx,%ebx
  801291:	c1 e3 08             	shl    $0x8,%ebx
  801294:	89 d6                	mov    %edx,%esi
  801296:	c1 e6 18             	shl    $0x18,%esi
  801299:	89 d0                	mov    %edx,%eax
  80129b:	c1 e0 10             	shl    $0x10,%eax
  80129e:	09 f0                	or     %esi,%eax
  8012a0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012a2:	89 d8                	mov    %ebx,%eax
  8012a4:	09 d0                	or     %edx,%eax
  8012a6:	c1 e9 02             	shr    $0x2,%ecx
  8012a9:	fc                   	cld    
  8012aa:	f3 ab                	rep stos %eax,%es:(%edi)
  8012ac:	eb 06                	jmp    8012b4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b1:	fc                   	cld    
  8012b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012b4:	89 f8                	mov    %edi,%eax
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	57                   	push   %edi
  8012bf:	56                   	push   %esi
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8012c9:	39 c6                	cmp    %eax,%esi
  8012cb:	73 35                	jae    801302 <memmove+0x47>
  8012cd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8012d0:	39 d0                	cmp    %edx,%eax
  8012d2:	73 2e                	jae    801302 <memmove+0x47>
		s += n;
		d += n;
  8012d4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012d7:	89 d6                	mov    %edx,%esi
  8012d9:	09 fe                	or     %edi,%esi
  8012db:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8012e1:	75 13                	jne    8012f6 <memmove+0x3b>
  8012e3:	f6 c1 03             	test   $0x3,%cl
  8012e6:	75 0e                	jne    8012f6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8012e8:	83 ef 04             	sub    $0x4,%edi
  8012eb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8012ee:	c1 e9 02             	shr    $0x2,%ecx
  8012f1:	fd                   	std    
  8012f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8012f4:	eb 09                	jmp    8012ff <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8012f6:	83 ef 01             	sub    $0x1,%edi
  8012f9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8012fc:	fd                   	std    
  8012fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8012ff:	fc                   	cld    
  801300:	eb 1d                	jmp    80131f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801302:	89 f2                	mov    %esi,%edx
  801304:	09 c2                	or     %eax,%edx
  801306:	f6 c2 03             	test   $0x3,%dl
  801309:	75 0f                	jne    80131a <memmove+0x5f>
  80130b:	f6 c1 03             	test   $0x3,%cl
  80130e:	75 0a                	jne    80131a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801310:	c1 e9 02             	shr    $0x2,%ecx
  801313:	89 c7                	mov    %eax,%edi
  801315:	fc                   	cld    
  801316:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801318:	eb 05                	jmp    80131f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80131a:	89 c7                	mov    %eax,%edi
  80131c:	fc                   	cld    
  80131d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801326:	ff 75 10             	pushl  0x10(%ebp)
  801329:	ff 75 0c             	pushl  0xc(%ebp)
  80132c:	ff 75 08             	pushl  0x8(%ebp)
  80132f:	e8 87 ff ff ff       	call   8012bb <memmove>
}
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	56                   	push   %esi
  80133a:	53                   	push   %ebx
  80133b:	8b 45 08             	mov    0x8(%ebp),%eax
  80133e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801341:	89 c6                	mov    %eax,%esi
  801343:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801346:	eb 1a                	jmp    801362 <memcmp+0x2c>
		if (*s1 != *s2)
  801348:	0f b6 08             	movzbl (%eax),%ecx
  80134b:	0f b6 1a             	movzbl (%edx),%ebx
  80134e:	38 d9                	cmp    %bl,%cl
  801350:	74 0a                	je     80135c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801352:	0f b6 c1             	movzbl %cl,%eax
  801355:	0f b6 db             	movzbl %bl,%ebx
  801358:	29 d8                	sub    %ebx,%eax
  80135a:	eb 0f                	jmp    80136b <memcmp+0x35>
		s1++, s2++;
  80135c:	83 c0 01             	add    $0x1,%eax
  80135f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801362:	39 f0                	cmp    %esi,%eax
  801364:	75 e2                	jne    801348 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801366:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80136b:	5b                   	pop    %ebx
  80136c:	5e                   	pop    %esi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	53                   	push   %ebx
  801373:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801376:	89 c1                	mov    %eax,%ecx
  801378:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80137b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80137f:	eb 0a                	jmp    80138b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801381:	0f b6 10             	movzbl (%eax),%edx
  801384:	39 da                	cmp    %ebx,%edx
  801386:	74 07                	je     80138f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801388:	83 c0 01             	add    $0x1,%eax
  80138b:	39 c8                	cmp    %ecx,%eax
  80138d:	72 f2                	jb     801381 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80138f:	5b                   	pop    %ebx
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	57                   	push   %edi
  801396:	56                   	push   %esi
  801397:	53                   	push   %ebx
  801398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80139e:	eb 03                	jmp    8013a3 <strtol+0x11>
		s++;
  8013a0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013a3:	0f b6 01             	movzbl (%ecx),%eax
  8013a6:	3c 20                	cmp    $0x20,%al
  8013a8:	74 f6                	je     8013a0 <strtol+0xe>
  8013aa:	3c 09                	cmp    $0x9,%al
  8013ac:	74 f2                	je     8013a0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013ae:	3c 2b                	cmp    $0x2b,%al
  8013b0:	75 0a                	jne    8013bc <strtol+0x2a>
		s++;
  8013b2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013b5:	bf 00 00 00 00       	mov    $0x0,%edi
  8013ba:	eb 11                	jmp    8013cd <strtol+0x3b>
  8013bc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8013c1:	3c 2d                	cmp    $0x2d,%al
  8013c3:	75 08                	jne    8013cd <strtol+0x3b>
		s++, neg = 1;
  8013c5:	83 c1 01             	add    $0x1,%ecx
  8013c8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8013cd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8013d3:	75 15                	jne    8013ea <strtol+0x58>
  8013d5:	80 39 30             	cmpb   $0x30,(%ecx)
  8013d8:	75 10                	jne    8013ea <strtol+0x58>
  8013da:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8013de:	75 7c                	jne    80145c <strtol+0xca>
		s += 2, base = 16;
  8013e0:	83 c1 02             	add    $0x2,%ecx
  8013e3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8013e8:	eb 16                	jmp    801400 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8013ea:	85 db                	test   %ebx,%ebx
  8013ec:	75 12                	jne    801400 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8013ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8013f3:	80 39 30             	cmpb   $0x30,(%ecx)
  8013f6:	75 08                	jne    801400 <strtol+0x6e>
		s++, base = 8;
  8013f8:	83 c1 01             	add    $0x1,%ecx
  8013fb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
  801405:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801408:	0f b6 11             	movzbl (%ecx),%edx
  80140b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80140e:	89 f3                	mov    %esi,%ebx
  801410:	80 fb 09             	cmp    $0x9,%bl
  801413:	77 08                	ja     80141d <strtol+0x8b>
			dig = *s - '0';
  801415:	0f be d2             	movsbl %dl,%edx
  801418:	83 ea 30             	sub    $0x30,%edx
  80141b:	eb 22                	jmp    80143f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80141d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801420:	89 f3                	mov    %esi,%ebx
  801422:	80 fb 19             	cmp    $0x19,%bl
  801425:	77 08                	ja     80142f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801427:	0f be d2             	movsbl %dl,%edx
  80142a:	83 ea 57             	sub    $0x57,%edx
  80142d:	eb 10                	jmp    80143f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80142f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801432:	89 f3                	mov    %esi,%ebx
  801434:	80 fb 19             	cmp    $0x19,%bl
  801437:	77 16                	ja     80144f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801439:	0f be d2             	movsbl %dl,%edx
  80143c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80143f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801442:	7d 0b                	jge    80144f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801444:	83 c1 01             	add    $0x1,%ecx
  801447:	0f af 45 10          	imul   0x10(%ebp),%eax
  80144b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80144d:	eb b9                	jmp    801408 <strtol+0x76>

	if (endptr)
  80144f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801453:	74 0d                	je     801462 <strtol+0xd0>
		*endptr = (char *) s;
  801455:	8b 75 0c             	mov    0xc(%ebp),%esi
  801458:	89 0e                	mov    %ecx,(%esi)
  80145a:	eb 06                	jmp    801462 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80145c:	85 db                	test   %ebx,%ebx
  80145e:	74 98                	je     8013f8 <strtol+0x66>
  801460:	eb 9e                	jmp    801400 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801462:	89 c2                	mov    %eax,%edx
  801464:	f7 da                	neg    %edx
  801466:	85 ff                	test   %edi,%edi
  801468:	0f 45 c2             	cmovne %edx,%eax
}
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5f                   	pop    %edi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	57                   	push   %edi
  801474:	56                   	push   %esi
  801475:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801476:	b8 00 00 00 00       	mov    $0x0,%eax
  80147b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147e:	8b 55 08             	mov    0x8(%ebp),%edx
  801481:	89 c3                	mov    %eax,%ebx
  801483:	89 c7                	mov    %eax,%edi
  801485:	89 c6                	mov    %eax,%esi
  801487:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5f                   	pop    %edi
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <sys_cgetc>:

int
sys_cgetc(void)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	57                   	push   %edi
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 01 00 00 00       	mov    $0x1,%eax
  80149e:	89 d1                	mov    %edx,%ecx
  8014a0:	89 d3                	mov    %edx,%ebx
  8014a2:	89 d7                	mov    %edx,%edi
  8014a4:	89 d6                	mov    %edx,%esi
  8014a6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5f                   	pop    %edi
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	57                   	push   %edi
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c3:	89 cb                	mov    %ecx,%ebx
  8014c5:	89 cf                	mov    %ecx,%edi
  8014c7:	89 ce                	mov    %ecx,%esi
  8014c9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	7e 17                	jle    8014e6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	50                   	push   %eax
  8014d3:	6a 03                	push   $0x3
  8014d5:	68 2f 37 80 00       	push   $0x80372f
  8014da:	6a 23                	push   $0x23
  8014dc:	68 4c 37 80 00       	push   $0x80374c
  8014e1:	e8 f2 f4 ff ff       	call   8009d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5f                   	pop    %edi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014fe:	89 d1                	mov    %edx,%ecx
  801500:	89 d3                	mov    %edx,%ebx
  801502:	89 d7                	mov    %edx,%edi
  801504:	89 d6                	mov    %edx,%esi
  801506:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    

0080150d <sys_yield>:

void
sys_yield(void)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	57                   	push   %edi
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801513:	ba 00 00 00 00       	mov    $0x0,%edx
  801518:	b8 0b 00 00 00       	mov    $0xb,%eax
  80151d:	89 d1                	mov    %edx,%ecx
  80151f:	89 d3                	mov    %edx,%ebx
  801521:	89 d7                	mov    %edx,%edi
  801523:	89 d6                	mov    %edx,%esi
  801525:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	57                   	push   %edi
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
  801532:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801535:	be 00 00 00 00       	mov    $0x0,%esi
  80153a:	b8 04 00 00 00       	mov    $0x4,%eax
  80153f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801542:	8b 55 08             	mov    0x8(%ebp),%edx
  801545:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801548:	89 f7                	mov    %esi,%edi
  80154a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80154c:	85 c0                	test   %eax,%eax
  80154e:	7e 17                	jle    801567 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801550:	83 ec 0c             	sub    $0xc,%esp
  801553:	50                   	push   %eax
  801554:	6a 04                	push   $0x4
  801556:	68 2f 37 80 00       	push   $0x80372f
  80155b:	6a 23                	push   $0x23
  80155d:	68 4c 37 80 00       	push   $0x80374c
  801562:	e8 71 f4 ff ff       	call   8009d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801567:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5f                   	pop    %edi
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    

0080156f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	57                   	push   %edi
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801578:	b8 05 00 00 00       	mov    $0x5,%eax
  80157d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801580:	8b 55 08             	mov    0x8(%ebp),%edx
  801583:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801586:	8b 7d 14             	mov    0x14(%ebp),%edi
  801589:	8b 75 18             	mov    0x18(%ebp),%esi
  80158c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80158e:	85 c0                	test   %eax,%eax
  801590:	7e 17                	jle    8015a9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	50                   	push   %eax
  801596:	6a 05                	push   $0x5
  801598:	68 2f 37 80 00       	push   $0x80372f
  80159d:	6a 23                	push   $0x23
  80159f:	68 4c 37 80 00       	push   $0x80374c
  8015a4:	e8 2f f4 ff ff       	call   8009d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5f                   	pop    %edi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    

008015b1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	57                   	push   %edi
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8015c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ca:	89 df                	mov    %ebx,%edi
  8015cc:	89 de                	mov    %ebx,%esi
  8015ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	7e 17                	jle    8015eb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	50                   	push   %eax
  8015d8:	6a 06                	push   $0x6
  8015da:	68 2f 37 80 00       	push   $0x80372f
  8015df:	6a 23                	push   $0x23
  8015e1:	68 4c 37 80 00       	push   $0x80374c
  8015e6:	e8 ed f3 ff ff       	call   8009d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8015eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5f                   	pop    %edi
  8015f1:	5d                   	pop    %ebp
  8015f2:	c3                   	ret    

008015f3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	57                   	push   %edi
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801601:	b8 08 00 00 00       	mov    $0x8,%eax
  801606:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801609:	8b 55 08             	mov    0x8(%ebp),%edx
  80160c:	89 df                	mov    %ebx,%edi
  80160e:	89 de                	mov    %ebx,%esi
  801610:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801612:	85 c0                	test   %eax,%eax
  801614:	7e 17                	jle    80162d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801616:	83 ec 0c             	sub    $0xc,%esp
  801619:	50                   	push   %eax
  80161a:	6a 08                	push   $0x8
  80161c:	68 2f 37 80 00       	push   $0x80372f
  801621:	6a 23                	push   $0x23
  801623:	68 4c 37 80 00       	push   $0x80374c
  801628:	e8 ab f3 ff ff       	call   8009d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80162d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801630:	5b                   	pop    %ebx
  801631:	5e                   	pop    %esi
  801632:	5f                   	pop    %edi
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	57                   	push   %edi
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
  80163b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80163e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801643:	b8 09 00 00 00       	mov    $0x9,%eax
  801648:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80164b:	8b 55 08             	mov    0x8(%ebp),%edx
  80164e:	89 df                	mov    %ebx,%edi
  801650:	89 de                	mov    %ebx,%esi
  801652:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801654:	85 c0                	test   %eax,%eax
  801656:	7e 17                	jle    80166f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	50                   	push   %eax
  80165c:	6a 09                	push   $0x9
  80165e:	68 2f 37 80 00       	push   $0x80372f
  801663:	6a 23                	push   $0x23
  801665:	68 4c 37 80 00       	push   $0x80374c
  80166a:	e8 69 f3 ff ff       	call   8009d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80166f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5f                   	pop    %edi
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	57                   	push   %edi
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
  80167d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801680:	bb 00 00 00 00       	mov    $0x0,%ebx
  801685:	b8 0a 00 00 00       	mov    $0xa,%eax
  80168a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80168d:	8b 55 08             	mov    0x8(%ebp),%edx
  801690:	89 df                	mov    %ebx,%edi
  801692:	89 de                	mov    %ebx,%esi
  801694:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801696:	85 c0                	test   %eax,%eax
  801698:	7e 17                	jle    8016b1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80169a:	83 ec 0c             	sub    $0xc,%esp
  80169d:	50                   	push   %eax
  80169e:	6a 0a                	push   $0xa
  8016a0:	68 2f 37 80 00       	push   $0x80372f
  8016a5:	6a 23                	push   $0x23
  8016a7:	68 4c 37 80 00       	push   $0x80374c
  8016ac:	e8 27 f3 ff ff       	call   8009d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5e                   	pop    %esi
  8016b6:	5f                   	pop    %edi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	57                   	push   %edi
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016bf:	be 00 00 00 00       	mov    $0x0,%esi
  8016c4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8016c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016d5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8016d7:	5b                   	pop    %ebx
  8016d8:	5e                   	pop    %esi
  8016d9:	5f                   	pop    %edi
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	57                   	push   %edi
  8016e0:	56                   	push   %esi
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016ea:	b8 0d 00 00 00       	mov    $0xd,%eax
  8016ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f2:	89 cb                	mov    %ecx,%ebx
  8016f4:	89 cf                	mov    %ecx,%edi
  8016f6:	89 ce                	mov    %ecx,%esi
  8016f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	7e 17                	jle    801715 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	50                   	push   %eax
  801702:	6a 0d                	push   $0xd
  801704:	68 2f 37 80 00       	push   $0x80372f
  801709:	6a 23                	push   $0x23
  80170b:	68 4c 37 80 00       	push   $0x80374c
  801710:	e8 c3 f2 ff ff       	call   8009d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5f                   	pop    %edi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801725:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  801727:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80172b:	75 25                	jne    801752 <pgfault+0x35>
  80172d:	89 d8                	mov    %ebx,%eax
  80172f:	c1 e8 0c             	shr    $0xc,%eax
  801732:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801739:	f6 c4 08             	test   $0x8,%ah
  80173c:	75 14                	jne    801752 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	68 5c 37 80 00       	push   $0x80375c
  801746:	6a 1e                	push   $0x1e
  801748:	68 f0 37 80 00       	push   $0x8037f0
  80174d:	e8 86 f2 ff ff       	call   8009d8 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  801752:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  801758:	e8 91 fd ff ff       	call   8014ee <sys_getenvid>
  80175d:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  80175f:	83 ec 04             	sub    $0x4,%esp
  801762:	6a 07                	push   $0x7
  801764:	68 00 f0 7f 00       	push   $0x7ff000
  801769:	50                   	push   %eax
  80176a:	e8 bd fd ff ff       	call   80152c <sys_page_alloc>
	if (r < 0)
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	85 c0                	test   %eax,%eax
  801774:	79 12                	jns    801788 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  801776:	50                   	push   %eax
  801777:	68 88 37 80 00       	push   $0x803788
  80177c:	6a 31                	push   $0x31
  80177e:	68 f0 37 80 00       	push   $0x8037f0
  801783:	e8 50 f2 ff ff       	call   8009d8 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  801788:	83 ec 04             	sub    $0x4,%esp
  80178b:	68 00 10 00 00       	push   $0x1000
  801790:	53                   	push   %ebx
  801791:	68 00 f0 7f 00       	push   $0x7ff000
  801796:	e8 88 fb ff ff       	call   801323 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  80179b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8017a2:	53                   	push   %ebx
  8017a3:	56                   	push   %esi
  8017a4:	68 00 f0 7f 00       	push   $0x7ff000
  8017a9:	56                   	push   %esi
  8017aa:	e8 c0 fd ff ff       	call   80156f <sys_page_map>
	if (r < 0)
  8017af:	83 c4 20             	add    $0x20,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	79 12                	jns    8017c8 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  8017b6:	50                   	push   %eax
  8017b7:	68 ac 37 80 00       	push   $0x8037ac
  8017bc:	6a 39                	push   $0x39
  8017be:	68 f0 37 80 00       	push   $0x8037f0
  8017c3:	e8 10 f2 ff ff       	call   8009d8 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	68 00 f0 7f 00       	push   $0x7ff000
  8017d0:	56                   	push   %esi
  8017d1:	e8 db fd ff ff       	call   8015b1 <sys_page_unmap>
	if (r < 0)
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	79 12                	jns    8017ef <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  8017dd:	50                   	push   %eax
  8017de:	68 d0 37 80 00       	push   $0x8037d0
  8017e3:	6a 3e                	push   $0x3e
  8017e5:	68 f0 37 80 00       	push   $0x8037f0
  8017ea:	e8 e9 f1 ff ff       	call   8009d8 <_panic>
}
  8017ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f2:	5b                   	pop    %ebx
  8017f3:	5e                   	pop    %esi
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    

008017f6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	57                   	push   %edi
  8017fa:	56                   	push   %esi
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  8017ff:	68 1d 17 80 00       	push   $0x80171d
  801804:	e8 a4 15 00 00       	call   802dad <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801809:	b8 07 00 00 00       	mov    $0x7,%eax
  80180e:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	0f 88 67 01 00 00    	js     801982 <fork+0x18c>
  80181b:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801820:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  801825:	85 c0                	test   %eax,%eax
  801827:	75 21                	jne    80184a <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801829:	e8 c0 fc ff ff       	call   8014ee <sys_getenvid>
  80182e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801833:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801836:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80183b:	a3 24 54 80 00       	mov    %eax,0x805424
        return 0;
  801840:	ba 00 00 00 00       	mov    $0x0,%edx
  801845:	e9 42 01 00 00       	jmp    80198c <fork+0x196>
  80184a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80184d:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80184f:	89 d8                	mov    %ebx,%eax
  801851:	c1 e8 16             	shr    $0x16,%eax
  801854:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80185b:	a8 01                	test   $0x1,%al
  80185d:	0f 84 c0 00 00 00    	je     801923 <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801863:	89 d8                	mov    %ebx,%eax
  801865:	c1 e8 0c             	shr    $0xc,%eax
  801868:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80186f:	f6 c2 01             	test   $0x1,%dl
  801872:	0f 84 ab 00 00 00    	je     801923 <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  801878:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80187f:	a9 02 08 00 00       	test   $0x802,%eax
  801884:	0f 84 99 00 00 00    	je     801923 <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  80188a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801891:	f6 c4 04             	test   $0x4,%ah
  801894:	74 17                	je     8018ad <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	68 07 0e 00 00       	push   $0xe07
  80189e:	53                   	push   %ebx
  80189f:	57                   	push   %edi
  8018a0:	53                   	push   %ebx
  8018a1:	6a 00                	push   $0x0
  8018a3:	e8 c7 fc ff ff       	call   80156f <sys_page_map>
  8018a8:	83 c4 20             	add    $0x20,%esp
  8018ab:	eb 76                	jmp    801923 <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8018ad:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8018b4:	a8 02                	test   $0x2,%al
  8018b6:	75 0c                	jne    8018c4 <fork+0xce>
  8018b8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8018bf:	f6 c4 08             	test   $0x8,%ah
  8018c2:	74 3f                	je     801903 <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8018c4:	83 ec 0c             	sub    $0xc,%esp
  8018c7:	68 05 08 00 00       	push   $0x805
  8018cc:	53                   	push   %ebx
  8018cd:	57                   	push   %edi
  8018ce:	53                   	push   %ebx
  8018cf:	6a 00                	push   $0x0
  8018d1:	e8 99 fc ff ff       	call   80156f <sys_page_map>
		if (r < 0)
  8018d6:	83 c4 20             	add    $0x20,%esp
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	0f 88 a5 00 00 00    	js     801986 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	68 05 08 00 00       	push   $0x805
  8018e9:	53                   	push   %ebx
  8018ea:	6a 00                	push   $0x0
  8018ec:	53                   	push   %ebx
  8018ed:	6a 00                	push   $0x0
  8018ef:	e8 7b fc ff ff       	call   80156f <sys_page_map>
  8018f4:	83 c4 20             	add    $0x20,%esp
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018fe:	0f 4f c1             	cmovg  %ecx,%eax
  801901:	eb 1c                	jmp    80191f <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	6a 05                	push   $0x5
  801908:	53                   	push   %ebx
  801909:	57                   	push   %edi
  80190a:	53                   	push   %ebx
  80190b:	6a 00                	push   $0x0
  80190d:	e8 5d fc ff ff       	call   80156f <sys_page_map>
  801912:	83 c4 20             	add    $0x20,%esp
  801915:	85 c0                	test   %eax,%eax
  801917:	b9 00 00 00 00       	mov    $0x0,%ecx
  80191c:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 67                	js     80198a <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801923:	83 c6 01             	add    $0x1,%esi
  801926:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80192c:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801932:	0f 85 17 ff ff ff    	jne    80184f <fork+0x59>
  801938:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80193b:	83 ec 04             	sub    $0x4,%esp
  80193e:	6a 07                	push   $0x7
  801940:	68 00 f0 bf ee       	push   $0xeebff000
  801945:	57                   	push   %edi
  801946:	e8 e1 fb ff ff       	call   80152c <sys_page_alloc>
	if (r < 0)
  80194b:	83 c4 10             	add    $0x10,%esp
		return r;
  80194e:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801950:	85 c0                	test   %eax,%eax
  801952:	78 38                	js     80198c <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	68 f4 2d 80 00       	push   $0x802df4
  80195c:	57                   	push   %edi
  80195d:	e8 15 fd ff ff       	call   801677 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801962:	83 c4 10             	add    $0x10,%esp
		return r;
  801965:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801967:	85 c0                	test   %eax,%eax
  801969:	78 21                	js     80198c <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	6a 02                	push   $0x2
  801970:	57                   	push   %edi
  801971:	e8 7d fc ff ff       	call   8015f3 <sys_env_set_status>
	if (r < 0)
  801976:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801979:	85 c0                	test   %eax,%eax
  80197b:	0f 48 f8             	cmovs  %eax,%edi
  80197e:	89 fa                	mov    %edi,%edx
  801980:	eb 0a                	jmp    80198c <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801982:	89 c2                	mov    %eax,%edx
  801984:	eb 06                	jmp    80198c <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801986:	89 c2                	mov    %eax,%edx
  801988:	eb 02                	jmp    80198c <fork+0x196>
  80198a:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  80198c:	89 d0                	mov    %edx,%eax
  80198e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801991:	5b                   	pop    %ebx
  801992:	5e                   	pop    %esi
  801993:	5f                   	pop    %edi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    

00801996 <sfork>:

// Challenge!
int
sfork(void)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80199c:	68 fb 37 80 00       	push   $0x8037fb
  8019a1:	68 c6 00 00 00       	push   $0xc6
  8019a6:	68 f0 37 80 00       	push   $0x8037f0
  8019ab:	e8 28 f0 ff ff       	call   8009d8 <_panic>

008019b0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8019b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b9:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8019bc:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8019be:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8019c1:	83 3a 01             	cmpl   $0x1,(%edx)
  8019c4:	7e 09                	jle    8019cf <argstart+0x1f>
  8019c6:	ba 01 32 80 00       	mov    $0x803201,%edx
  8019cb:	85 c9                	test   %ecx,%ecx
  8019cd:	75 05                	jne    8019d4 <argstart+0x24>
  8019cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d4:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8019d7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <argnext>:

int
argnext(struct Argstate *args)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 04             	sub    $0x4,%esp
  8019e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8019ea:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8019f1:	8b 43 08             	mov    0x8(%ebx),%eax
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	74 6f                	je     801a67 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  8019f8:	80 38 00             	cmpb   $0x0,(%eax)
  8019fb:	75 4e                	jne    801a4b <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8019fd:	8b 0b                	mov    (%ebx),%ecx
  8019ff:	83 39 01             	cmpl   $0x1,(%ecx)
  801a02:	74 55                	je     801a59 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801a04:	8b 53 04             	mov    0x4(%ebx),%edx
  801a07:	8b 42 04             	mov    0x4(%edx),%eax
  801a0a:	80 38 2d             	cmpb   $0x2d,(%eax)
  801a0d:	75 4a                	jne    801a59 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801a0f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801a13:	74 44                	je     801a59 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801a15:	83 c0 01             	add    $0x1,%eax
  801a18:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801a1b:	83 ec 04             	sub    $0x4,%esp
  801a1e:	8b 01                	mov    (%ecx),%eax
  801a20:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801a27:	50                   	push   %eax
  801a28:	8d 42 08             	lea    0x8(%edx),%eax
  801a2b:	50                   	push   %eax
  801a2c:	83 c2 04             	add    $0x4,%edx
  801a2f:	52                   	push   %edx
  801a30:	e8 86 f8 ff ff       	call   8012bb <memmove>
		(*args->argc)--;
  801a35:	8b 03                	mov    (%ebx),%eax
  801a37:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801a3a:	8b 43 08             	mov    0x8(%ebx),%eax
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	80 38 2d             	cmpb   $0x2d,(%eax)
  801a43:	75 06                	jne    801a4b <argnext+0x6b>
  801a45:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801a49:	74 0e                	je     801a59 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801a4b:	8b 53 08             	mov    0x8(%ebx),%edx
  801a4e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801a51:	83 c2 01             	add    $0x1,%edx
  801a54:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801a57:	eb 13                	jmp    801a6c <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801a59:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801a60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801a65:	eb 05                	jmp    801a6c <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801a67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801a6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	53                   	push   %ebx
  801a75:	83 ec 04             	sub    $0x4,%esp
  801a78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801a7b:	8b 43 08             	mov    0x8(%ebx),%eax
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	74 58                	je     801ada <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801a82:	80 38 00             	cmpb   $0x0,(%eax)
  801a85:	74 0c                	je     801a93 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801a87:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801a8a:	c7 43 08 01 32 80 00 	movl   $0x803201,0x8(%ebx)
  801a91:	eb 42                	jmp    801ad5 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801a93:	8b 13                	mov    (%ebx),%edx
  801a95:	83 3a 01             	cmpl   $0x1,(%edx)
  801a98:	7e 2d                	jle    801ac7 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801a9a:	8b 43 04             	mov    0x4(%ebx),%eax
  801a9d:	8b 48 04             	mov    0x4(%eax),%ecx
  801aa0:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	8b 12                	mov    (%edx),%edx
  801aa8:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801aaf:	52                   	push   %edx
  801ab0:	8d 50 08             	lea    0x8(%eax),%edx
  801ab3:	52                   	push   %edx
  801ab4:	83 c0 04             	add    $0x4,%eax
  801ab7:	50                   	push   %eax
  801ab8:	e8 fe f7 ff ff       	call   8012bb <memmove>
		(*args->argc)--;
  801abd:	8b 03                	mov    (%ebx),%eax
  801abf:	83 28 01             	subl   $0x1,(%eax)
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	eb 0e                	jmp    801ad5 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801ac7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801ace:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801ad5:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ad8:	eb 05                	jmp    801adf <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801ada:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801adf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 08             	sub    $0x8,%esp
  801aea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801aed:	8b 51 0c             	mov    0xc(%ecx),%edx
  801af0:	89 d0                	mov    %edx,%eax
  801af2:	85 d2                	test   %edx,%edx
  801af4:	75 0c                	jne    801b02 <argvalue+0x1e>
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	51                   	push   %ecx
  801afa:	e8 72 ff ff ff       	call   801a71 <argnextvalue>
  801aff:	83 c4 10             	add    $0x10,%esp
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0a:	05 00 00 00 30       	add    $0x30000000,%eax
  801b0f:	c1 e8 0c             	shr    $0xc,%eax
}
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801b17:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1a:	05 00 00 00 30       	add    $0x30000000,%eax
  801b1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801b24:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b31:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801b36:	89 c2                	mov    %eax,%edx
  801b38:	c1 ea 16             	shr    $0x16,%edx
  801b3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b42:	f6 c2 01             	test   $0x1,%dl
  801b45:	74 11                	je     801b58 <fd_alloc+0x2d>
  801b47:	89 c2                	mov    %eax,%edx
  801b49:	c1 ea 0c             	shr    $0xc,%edx
  801b4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b53:	f6 c2 01             	test   $0x1,%dl
  801b56:	75 09                	jne    801b61 <fd_alloc+0x36>
			*fd_store = fd;
  801b58:	89 01                	mov    %eax,(%ecx)
			return 0;
  801b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5f:	eb 17                	jmp    801b78 <fd_alloc+0x4d>
  801b61:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801b66:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801b6b:	75 c9                	jne    801b36 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801b6d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801b73:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801b80:	83 f8 1f             	cmp    $0x1f,%eax
  801b83:	77 36                	ja     801bbb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801b85:	c1 e0 0c             	shl    $0xc,%eax
  801b88:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801b8d:	89 c2                	mov    %eax,%edx
  801b8f:	c1 ea 16             	shr    $0x16,%edx
  801b92:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b99:	f6 c2 01             	test   $0x1,%dl
  801b9c:	74 24                	je     801bc2 <fd_lookup+0x48>
  801b9e:	89 c2                	mov    %eax,%edx
  801ba0:	c1 ea 0c             	shr    $0xc,%edx
  801ba3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801baa:	f6 c2 01             	test   $0x1,%dl
  801bad:	74 1a                	je     801bc9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801baf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb2:	89 02                	mov    %eax,(%edx)
	return 0;
  801bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb9:	eb 13                	jmp    801bce <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801bbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bc0:	eb 0c                	jmp    801bce <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801bc2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bc7:	eb 05                	jmp    801bce <fd_lookup+0x54>
  801bc9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	83 ec 08             	sub    $0x8,%esp
  801bd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd9:	ba 90 38 80 00       	mov    $0x803890,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801bde:	eb 13                	jmp    801bf3 <dev_lookup+0x23>
  801be0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801be3:	39 08                	cmp    %ecx,(%eax)
  801be5:	75 0c                	jne    801bf3 <dev_lookup+0x23>
			*dev = devtab[i];
  801be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bea:	89 01                	mov    %eax,(%ecx)
			return 0;
  801bec:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf1:	eb 2e                	jmp    801c21 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801bf3:	8b 02                	mov    (%edx),%eax
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	75 e7                	jne    801be0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801bf9:	a1 24 54 80 00       	mov    0x805424,%eax
  801bfe:	8b 40 48             	mov    0x48(%eax),%eax
  801c01:	83 ec 04             	sub    $0x4,%esp
  801c04:	51                   	push   %ecx
  801c05:	50                   	push   %eax
  801c06:	68 14 38 80 00       	push   $0x803814
  801c0b:	e8 a1 ee ff ff       	call   800ab1 <cprintf>
	*dev = 0;
  801c10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801c21:	c9                   	leave  
  801c22:	c3                   	ret    

00801c23 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	56                   	push   %esi
  801c27:	53                   	push   %ebx
  801c28:	83 ec 10             	sub    $0x10,%esp
  801c2b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c34:	50                   	push   %eax
  801c35:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801c3b:	c1 e8 0c             	shr    $0xc,%eax
  801c3e:	50                   	push   %eax
  801c3f:	e8 36 ff ff ff       	call   801b7a <fd_lookup>
  801c44:	83 c4 08             	add    $0x8,%esp
  801c47:	85 c0                	test   %eax,%eax
  801c49:	78 05                	js     801c50 <fd_close+0x2d>
	    || fd != fd2)
  801c4b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801c4e:	74 0c                	je     801c5c <fd_close+0x39>
		return (must_exist ? r : 0);
  801c50:	84 db                	test   %bl,%bl
  801c52:	ba 00 00 00 00       	mov    $0x0,%edx
  801c57:	0f 44 c2             	cmove  %edx,%eax
  801c5a:	eb 41                	jmp    801c9d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801c5c:	83 ec 08             	sub    $0x8,%esp
  801c5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c62:	50                   	push   %eax
  801c63:	ff 36                	pushl  (%esi)
  801c65:	e8 66 ff ff ff       	call   801bd0 <dev_lookup>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 1a                	js     801c8d <fd_close+0x6a>
		if (dev->dev_close)
  801c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c76:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801c79:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	74 0b                	je     801c8d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801c82:	83 ec 0c             	sub    $0xc,%esp
  801c85:	56                   	push   %esi
  801c86:	ff d0                	call   *%eax
  801c88:	89 c3                	mov    %eax,%ebx
  801c8a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801c8d:	83 ec 08             	sub    $0x8,%esp
  801c90:	56                   	push   %esi
  801c91:	6a 00                	push   $0x0
  801c93:	e8 19 f9 ff ff       	call   8015b1 <sys_page_unmap>
	return r;
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	89 d8                	mov    %ebx,%eax
}
  801c9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    

00801ca4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801caa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cad:	50                   	push   %eax
  801cae:	ff 75 08             	pushl  0x8(%ebp)
  801cb1:	e8 c4 fe ff ff       	call   801b7a <fd_lookup>
  801cb6:	83 c4 08             	add    $0x8,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 10                	js     801ccd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801cbd:	83 ec 08             	sub    $0x8,%esp
  801cc0:	6a 01                	push   $0x1
  801cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc5:	e8 59 ff ff ff       	call   801c23 <fd_close>
  801cca:	83 c4 10             	add    $0x10,%esp
}
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    

00801ccf <close_all>:

void
close_all(void)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	53                   	push   %ebx
  801cd3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801cdb:	83 ec 0c             	sub    $0xc,%esp
  801cde:	53                   	push   %ebx
  801cdf:	e8 c0 ff ff ff       	call   801ca4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801ce4:	83 c3 01             	add    $0x1,%ebx
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	83 fb 20             	cmp    $0x20,%ebx
  801ced:	75 ec                	jne    801cdb <close_all+0xc>
		close(i);
}
  801cef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf2:	c9                   	leave  
  801cf3:	c3                   	ret    

00801cf4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	57                   	push   %edi
  801cf8:	56                   	push   %esi
  801cf9:	53                   	push   %ebx
  801cfa:	83 ec 2c             	sub    $0x2c,%esp
  801cfd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d00:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d03:	50                   	push   %eax
  801d04:	ff 75 08             	pushl  0x8(%ebp)
  801d07:	e8 6e fe ff ff       	call   801b7a <fd_lookup>
  801d0c:	83 c4 08             	add    $0x8,%esp
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	0f 88 c1 00 00 00    	js     801dd8 <dup+0xe4>
		return r;
	close(newfdnum);
  801d17:	83 ec 0c             	sub    $0xc,%esp
  801d1a:	56                   	push   %esi
  801d1b:	e8 84 ff ff ff       	call   801ca4 <close>

	newfd = INDEX2FD(newfdnum);
  801d20:	89 f3                	mov    %esi,%ebx
  801d22:	c1 e3 0c             	shl    $0xc,%ebx
  801d25:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801d2b:	83 c4 04             	add    $0x4,%esp
  801d2e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d31:	e8 de fd ff ff       	call   801b14 <fd2data>
  801d36:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801d38:	89 1c 24             	mov    %ebx,(%esp)
  801d3b:	e8 d4 fd ff ff       	call   801b14 <fd2data>
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801d46:	89 f8                	mov    %edi,%eax
  801d48:	c1 e8 16             	shr    $0x16,%eax
  801d4b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d52:	a8 01                	test   $0x1,%al
  801d54:	74 37                	je     801d8d <dup+0x99>
  801d56:	89 f8                	mov    %edi,%eax
  801d58:	c1 e8 0c             	shr    $0xc,%eax
  801d5b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d62:	f6 c2 01             	test   $0x1,%dl
  801d65:	74 26                	je     801d8d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801d67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d6e:	83 ec 0c             	sub    $0xc,%esp
  801d71:	25 07 0e 00 00       	and    $0xe07,%eax
  801d76:	50                   	push   %eax
  801d77:	ff 75 d4             	pushl  -0x2c(%ebp)
  801d7a:	6a 00                	push   $0x0
  801d7c:	57                   	push   %edi
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 eb f7 ff ff       	call   80156f <sys_page_map>
  801d84:	89 c7                	mov    %eax,%edi
  801d86:	83 c4 20             	add    $0x20,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 2e                	js     801dbb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d90:	89 d0                	mov    %edx,%eax
  801d92:	c1 e8 0c             	shr    $0xc,%eax
  801d95:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d9c:	83 ec 0c             	sub    $0xc,%esp
  801d9f:	25 07 0e 00 00       	and    $0xe07,%eax
  801da4:	50                   	push   %eax
  801da5:	53                   	push   %ebx
  801da6:	6a 00                	push   $0x0
  801da8:	52                   	push   %edx
  801da9:	6a 00                	push   $0x0
  801dab:	e8 bf f7 ff ff       	call   80156f <sys_page_map>
  801db0:	89 c7                	mov    %eax,%edi
  801db2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801db5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801db7:	85 ff                	test   %edi,%edi
  801db9:	79 1d                	jns    801dd8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801dbb:	83 ec 08             	sub    $0x8,%esp
  801dbe:	53                   	push   %ebx
  801dbf:	6a 00                	push   $0x0
  801dc1:	e8 eb f7 ff ff       	call   8015b1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801dc6:	83 c4 08             	add    $0x8,%esp
  801dc9:	ff 75 d4             	pushl  -0x2c(%ebp)
  801dcc:	6a 00                	push   $0x0
  801dce:	e8 de f7 ff ff       	call   8015b1 <sys_page_unmap>
	return r;
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	89 f8                	mov    %edi,%eax
}
  801dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5f                   	pop    %edi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	53                   	push   %ebx
  801de4:	83 ec 14             	sub    $0x14,%esp
  801de7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801dea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ded:	50                   	push   %eax
  801dee:	53                   	push   %ebx
  801def:	e8 86 fd ff ff       	call   801b7a <fd_lookup>
  801df4:	83 c4 08             	add    $0x8,%esp
  801df7:	89 c2                	mov    %eax,%edx
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	78 6d                	js     801e6a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dfd:	83 ec 08             	sub    $0x8,%esp
  801e00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e07:	ff 30                	pushl  (%eax)
  801e09:	e8 c2 fd ff ff       	call   801bd0 <dev_lookup>
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	85 c0                	test   %eax,%eax
  801e13:	78 4c                	js     801e61 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801e15:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e18:	8b 42 08             	mov    0x8(%edx),%eax
  801e1b:	83 e0 03             	and    $0x3,%eax
  801e1e:	83 f8 01             	cmp    $0x1,%eax
  801e21:	75 21                	jne    801e44 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801e23:	a1 24 54 80 00       	mov    0x805424,%eax
  801e28:	8b 40 48             	mov    0x48(%eax),%eax
  801e2b:	83 ec 04             	sub    $0x4,%esp
  801e2e:	53                   	push   %ebx
  801e2f:	50                   	push   %eax
  801e30:	68 55 38 80 00       	push   $0x803855
  801e35:	e8 77 ec ff ff       	call   800ab1 <cprintf>
		return -E_INVAL;
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801e42:	eb 26                	jmp    801e6a <read+0x8a>
	}
	if (!dev->dev_read)
  801e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e47:	8b 40 08             	mov    0x8(%eax),%eax
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	74 17                	je     801e65 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801e4e:	83 ec 04             	sub    $0x4,%esp
  801e51:	ff 75 10             	pushl  0x10(%ebp)
  801e54:	ff 75 0c             	pushl  0xc(%ebp)
  801e57:	52                   	push   %edx
  801e58:	ff d0                	call   *%eax
  801e5a:	89 c2                	mov    %eax,%edx
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	eb 09                	jmp    801e6a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e61:	89 c2                	mov    %eax,%edx
  801e63:	eb 05                	jmp    801e6a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801e65:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801e6a:	89 d0                	mov    %edx,%eax
  801e6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	57                   	push   %edi
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e7d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e85:	eb 21                	jmp    801ea8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801e87:	83 ec 04             	sub    $0x4,%esp
  801e8a:	89 f0                	mov    %esi,%eax
  801e8c:	29 d8                	sub    %ebx,%eax
  801e8e:	50                   	push   %eax
  801e8f:	89 d8                	mov    %ebx,%eax
  801e91:	03 45 0c             	add    0xc(%ebp),%eax
  801e94:	50                   	push   %eax
  801e95:	57                   	push   %edi
  801e96:	e8 45 ff ff ff       	call   801de0 <read>
		if (m < 0)
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 10                	js     801eb2 <readn+0x41>
			return m;
		if (m == 0)
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	74 0a                	je     801eb0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ea6:	01 c3                	add    %eax,%ebx
  801ea8:	39 f3                	cmp    %esi,%ebx
  801eaa:	72 db                	jb     801e87 <readn+0x16>
  801eac:	89 d8                	mov    %ebx,%eax
  801eae:	eb 02                	jmp    801eb2 <readn+0x41>
  801eb0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801eb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5f                   	pop    %edi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	53                   	push   %ebx
  801ebe:	83 ec 14             	sub    $0x14,%esp
  801ec1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ec4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ec7:	50                   	push   %eax
  801ec8:	53                   	push   %ebx
  801ec9:	e8 ac fc ff ff       	call   801b7a <fd_lookup>
  801ece:	83 c4 08             	add    $0x8,%esp
  801ed1:	89 c2                	mov    %eax,%edx
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	78 68                	js     801f3f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ed7:	83 ec 08             	sub    $0x8,%esp
  801eda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edd:	50                   	push   %eax
  801ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee1:	ff 30                	pushl  (%eax)
  801ee3:	e8 e8 fc ff ff       	call   801bd0 <dev_lookup>
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 47                	js     801f36 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ef2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ef6:	75 21                	jne    801f19 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ef8:	a1 24 54 80 00       	mov    0x805424,%eax
  801efd:	8b 40 48             	mov    0x48(%eax),%eax
  801f00:	83 ec 04             	sub    $0x4,%esp
  801f03:	53                   	push   %ebx
  801f04:	50                   	push   %eax
  801f05:	68 71 38 80 00       	push   $0x803871
  801f0a:	e8 a2 eb ff ff       	call   800ab1 <cprintf>
		return -E_INVAL;
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f17:	eb 26                	jmp    801f3f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801f19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f1c:	8b 52 0c             	mov    0xc(%edx),%edx
  801f1f:	85 d2                	test   %edx,%edx
  801f21:	74 17                	je     801f3a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801f23:	83 ec 04             	sub    $0x4,%esp
  801f26:	ff 75 10             	pushl  0x10(%ebp)
  801f29:	ff 75 0c             	pushl  0xc(%ebp)
  801f2c:	50                   	push   %eax
  801f2d:	ff d2                	call   *%edx
  801f2f:	89 c2                	mov    %eax,%edx
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	eb 09                	jmp    801f3f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f36:	89 c2                	mov    %eax,%edx
  801f38:	eb 05                	jmp    801f3f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801f3a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801f3f:	89 d0                	mov    %edx,%eax
  801f41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <seek>:

int
seek(int fdnum, off_t offset)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801f4f:	50                   	push   %eax
  801f50:	ff 75 08             	pushl  0x8(%ebp)
  801f53:	e8 22 fc ff ff       	call   801b7a <fd_lookup>
  801f58:	83 c4 08             	add    $0x8,%esp
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	78 0e                	js     801f6d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801f5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801f62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f65:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801f68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	53                   	push   %ebx
  801f73:	83 ec 14             	sub    $0x14,%esp
  801f76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	53                   	push   %ebx
  801f7e:	e8 f7 fb ff ff       	call   801b7a <fd_lookup>
  801f83:	83 c4 08             	add    $0x8,%esp
  801f86:	89 c2                	mov    %eax,%edx
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	78 65                	js     801ff1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f8c:	83 ec 08             	sub    $0x8,%esp
  801f8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f92:	50                   	push   %eax
  801f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f96:	ff 30                	pushl  (%eax)
  801f98:	e8 33 fc ff ff       	call   801bd0 <dev_lookup>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 44                	js     801fe8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fab:	75 21                	jne    801fce <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801fad:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801fb2:	8b 40 48             	mov    0x48(%eax),%eax
  801fb5:	83 ec 04             	sub    $0x4,%esp
  801fb8:	53                   	push   %ebx
  801fb9:	50                   	push   %eax
  801fba:	68 34 38 80 00       	push   $0x803834
  801fbf:	e8 ed ea ff ff       	call   800ab1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801fcc:	eb 23                	jmp    801ff1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801fce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fd1:	8b 52 18             	mov    0x18(%edx),%edx
  801fd4:	85 d2                	test   %edx,%edx
  801fd6:	74 14                	je     801fec <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801fd8:	83 ec 08             	sub    $0x8,%esp
  801fdb:	ff 75 0c             	pushl  0xc(%ebp)
  801fde:	50                   	push   %eax
  801fdf:	ff d2                	call   *%edx
  801fe1:	89 c2                	mov    %eax,%edx
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	eb 09                	jmp    801ff1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fe8:	89 c2                	mov    %eax,%edx
  801fea:	eb 05                	jmp    801ff1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801fec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801ff1:	89 d0                	mov    %edx,%eax
  801ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff6:	c9                   	leave  
  801ff7:	c3                   	ret    

00801ff8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	53                   	push   %ebx
  801ffc:	83 ec 14             	sub    $0x14,%esp
  801fff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802002:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802005:	50                   	push   %eax
  802006:	ff 75 08             	pushl  0x8(%ebp)
  802009:	e8 6c fb ff ff       	call   801b7a <fd_lookup>
  80200e:	83 c4 08             	add    $0x8,%esp
  802011:	89 c2                	mov    %eax,%edx
  802013:	85 c0                	test   %eax,%eax
  802015:	78 58                	js     80206f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802017:	83 ec 08             	sub    $0x8,%esp
  80201a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201d:	50                   	push   %eax
  80201e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802021:	ff 30                	pushl  (%eax)
  802023:	e8 a8 fb ff ff       	call   801bd0 <dev_lookup>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	78 37                	js     802066 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802032:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802036:	74 32                	je     80206a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802038:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80203b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802042:	00 00 00 
	stat->st_isdir = 0;
  802045:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80204c:	00 00 00 
	stat->st_dev = dev;
  80204f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802055:	83 ec 08             	sub    $0x8,%esp
  802058:	53                   	push   %ebx
  802059:	ff 75 f0             	pushl  -0x10(%ebp)
  80205c:	ff 50 14             	call   *0x14(%eax)
  80205f:	89 c2                	mov    %eax,%edx
  802061:	83 c4 10             	add    $0x10,%esp
  802064:	eb 09                	jmp    80206f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802066:	89 c2                	mov    %eax,%edx
  802068:	eb 05                	jmp    80206f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80206a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80206f:	89 d0                	mov    %edx,%eax
  802071:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802074:	c9                   	leave  
  802075:	c3                   	ret    

00802076 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	56                   	push   %esi
  80207a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80207b:	83 ec 08             	sub    $0x8,%esp
  80207e:	6a 00                	push   $0x0
  802080:	ff 75 08             	pushl  0x8(%ebp)
  802083:	e8 d6 01 00 00       	call   80225e <open>
  802088:	89 c3                	mov    %eax,%ebx
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	85 c0                	test   %eax,%eax
  80208f:	78 1b                	js     8020ac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802091:	83 ec 08             	sub    $0x8,%esp
  802094:	ff 75 0c             	pushl  0xc(%ebp)
  802097:	50                   	push   %eax
  802098:	e8 5b ff ff ff       	call   801ff8 <fstat>
  80209d:	89 c6                	mov    %eax,%esi
	close(fd);
  80209f:	89 1c 24             	mov    %ebx,(%esp)
  8020a2:	e8 fd fb ff ff       	call   801ca4 <close>
	return r;
  8020a7:	83 c4 10             	add    $0x10,%esp
  8020aa:	89 f0                	mov    %esi,%eax
}
  8020ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    

008020b3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	89 c6                	mov    %eax,%esi
  8020ba:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8020bc:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8020c3:	75 12                	jne    8020d7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8020c5:	83 ec 0c             	sub    $0xc,%esp
  8020c8:	6a 01                	push   $0x1
  8020ca:	e8 04 0e 00 00       	call   802ed3 <ipc_find_env>
  8020cf:	a3 20 54 80 00       	mov    %eax,0x805420
  8020d4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8020d7:	6a 07                	push   $0x7
  8020d9:	68 00 60 80 00       	push   $0x806000
  8020de:	56                   	push   %esi
  8020df:	ff 35 20 54 80 00    	pushl  0x805420
  8020e5:	e8 95 0d 00 00       	call   802e7f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8020ea:	83 c4 0c             	add    $0xc,%esp
  8020ed:	6a 00                	push   $0x0
  8020ef:	53                   	push   %ebx
  8020f0:	6a 00                	push   $0x0
  8020f2:	e8 21 0d 00 00       	call   802e18 <ipc_recv>
}
  8020f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    

008020fe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802104:	8b 45 08             	mov    0x8(%ebp),%eax
  802107:	8b 40 0c             	mov    0xc(%eax),%eax
  80210a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80210f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802112:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802117:	ba 00 00 00 00       	mov    $0x0,%edx
  80211c:	b8 02 00 00 00       	mov    $0x2,%eax
  802121:	e8 8d ff ff ff       	call   8020b3 <fsipc>
}
  802126:	c9                   	leave  
  802127:	c3                   	ret    

00802128 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80212e:	8b 45 08             	mov    0x8(%ebp),%eax
  802131:	8b 40 0c             	mov    0xc(%eax),%eax
  802134:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802139:	ba 00 00 00 00       	mov    $0x0,%edx
  80213e:	b8 06 00 00 00       	mov    $0x6,%eax
  802143:	e8 6b ff ff ff       	call   8020b3 <fsipc>
}
  802148:	c9                   	leave  
  802149:	c3                   	ret    

0080214a <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	53                   	push   %ebx
  80214e:	83 ec 04             	sub    $0x4,%esp
  802151:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802154:	8b 45 08             	mov    0x8(%ebp),%eax
  802157:	8b 40 0c             	mov    0xc(%eax),%eax
  80215a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80215f:	ba 00 00 00 00       	mov    $0x0,%edx
  802164:	b8 05 00 00 00       	mov    $0x5,%eax
  802169:	e8 45 ff ff ff       	call   8020b3 <fsipc>
  80216e:	85 c0                	test   %eax,%eax
  802170:	78 2c                	js     80219e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802172:	83 ec 08             	sub    $0x8,%esp
  802175:	68 00 60 80 00       	push   $0x806000
  80217a:	53                   	push   %ebx
  80217b:	e8 a9 ef ff ff       	call   801129 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802180:	a1 80 60 80 00       	mov    0x806080,%eax
  802185:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80218b:	a1 84 60 80 00       	mov    0x806084,%eax
  802190:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802196:	83 c4 10             	add    $0x10,%esp
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80219e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021a1:	c9                   	leave  
  8021a2:	c3                   	ret    

008021a3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	83 ec 0c             	sub    $0xc,%esp
  8021a9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8021ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8021af:	8b 52 0c             	mov    0xc(%edx),%edx
  8021b2:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  8021b8:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8021bd:	50                   	push   %eax
  8021be:	ff 75 0c             	pushl  0xc(%ebp)
  8021c1:	68 08 60 80 00       	push   $0x806008
  8021c6:	e8 f0 f0 ff ff       	call   8012bb <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8021cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8021d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8021d5:	e8 d9 fe ff ff       	call   8020b3 <fsipc>

}
  8021da:	c9                   	leave  
  8021db:	c3                   	ret    

008021dc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	56                   	push   %esi
  8021e0:	53                   	push   %ebx
  8021e1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8021e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8021ea:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8021ef:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8021f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8021fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8021ff:	e8 af fe ff ff       	call   8020b3 <fsipc>
  802204:	89 c3                	mov    %eax,%ebx
  802206:	85 c0                	test   %eax,%eax
  802208:	78 4b                	js     802255 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80220a:	39 c6                	cmp    %eax,%esi
  80220c:	73 16                	jae    802224 <devfile_read+0x48>
  80220e:	68 a0 38 80 00       	push   $0x8038a0
  802213:	68 38 33 80 00       	push   $0x803338
  802218:	6a 7c                	push   $0x7c
  80221a:	68 a7 38 80 00       	push   $0x8038a7
  80221f:	e8 b4 e7 ff ff       	call   8009d8 <_panic>
	assert(r <= PGSIZE);
  802224:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802229:	7e 16                	jle    802241 <devfile_read+0x65>
  80222b:	68 b2 38 80 00       	push   $0x8038b2
  802230:	68 38 33 80 00       	push   $0x803338
  802235:	6a 7d                	push   $0x7d
  802237:	68 a7 38 80 00       	push   $0x8038a7
  80223c:	e8 97 e7 ff ff       	call   8009d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802241:	83 ec 04             	sub    $0x4,%esp
  802244:	50                   	push   %eax
  802245:	68 00 60 80 00       	push   $0x806000
  80224a:	ff 75 0c             	pushl  0xc(%ebp)
  80224d:	e8 69 f0 ff ff       	call   8012bb <memmove>
	return r;
  802252:	83 c4 10             	add    $0x10,%esp
}
  802255:	89 d8                	mov    %ebx,%eax
  802257:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225a:	5b                   	pop    %ebx
  80225b:	5e                   	pop    %esi
  80225c:	5d                   	pop    %ebp
  80225d:	c3                   	ret    

0080225e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80225e:	55                   	push   %ebp
  80225f:	89 e5                	mov    %esp,%ebp
  802261:	53                   	push   %ebx
  802262:	83 ec 20             	sub    $0x20,%esp
  802265:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802268:	53                   	push   %ebx
  802269:	e8 82 ee ff ff       	call   8010f0 <strlen>
  80226e:	83 c4 10             	add    $0x10,%esp
  802271:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802276:	7f 67                	jg     8022df <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802278:	83 ec 0c             	sub    $0xc,%esp
  80227b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227e:	50                   	push   %eax
  80227f:	e8 a7 f8 ff ff       	call   801b2b <fd_alloc>
  802284:	83 c4 10             	add    $0x10,%esp
		return r;
  802287:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802289:	85 c0                	test   %eax,%eax
  80228b:	78 57                	js     8022e4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80228d:	83 ec 08             	sub    $0x8,%esp
  802290:	53                   	push   %ebx
  802291:	68 00 60 80 00       	push   $0x806000
  802296:	e8 8e ee ff ff       	call   801129 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80229b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8022a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	e8 03 fe ff ff       	call   8020b3 <fsipc>
  8022b0:	89 c3                	mov    %eax,%ebx
  8022b2:	83 c4 10             	add    $0x10,%esp
  8022b5:	85 c0                	test   %eax,%eax
  8022b7:	79 14                	jns    8022cd <open+0x6f>
		fd_close(fd, 0);
  8022b9:	83 ec 08             	sub    $0x8,%esp
  8022bc:	6a 00                	push   $0x0
  8022be:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c1:	e8 5d f9 ff ff       	call   801c23 <fd_close>
		return r;
  8022c6:	83 c4 10             	add    $0x10,%esp
  8022c9:	89 da                	mov    %ebx,%edx
  8022cb:	eb 17                	jmp    8022e4 <open+0x86>
	}

	return fd2num(fd);
  8022cd:	83 ec 0c             	sub    $0xc,%esp
  8022d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8022d3:	e8 2c f8 ff ff       	call   801b04 <fd2num>
  8022d8:	89 c2                	mov    %eax,%edx
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	eb 05                	jmp    8022e4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8022df:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8022e4:	89 d0                	mov    %edx,%eax
  8022e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022e9:	c9                   	leave  
  8022ea:	c3                   	ret    

008022eb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8022f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8022fb:	e8 b3 fd ff ff       	call   8020b3 <fsipc>
}
  802300:	c9                   	leave  
  802301:	c3                   	ret    

00802302 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802302:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802306:	7e 37                	jle    80233f <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802308:	55                   	push   %ebp
  802309:	89 e5                	mov    %esp,%ebp
  80230b:	53                   	push   %ebx
  80230c:	83 ec 08             	sub    $0x8,%esp
  80230f:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802311:	ff 70 04             	pushl  0x4(%eax)
  802314:	8d 40 10             	lea    0x10(%eax),%eax
  802317:	50                   	push   %eax
  802318:	ff 33                	pushl  (%ebx)
  80231a:	e8 9b fb ff ff       	call   801eba <write>
		if (result > 0)
  80231f:	83 c4 10             	add    $0x10,%esp
  802322:	85 c0                	test   %eax,%eax
  802324:	7e 03                	jle    802329 <writebuf+0x27>
			b->result += result;
  802326:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802329:	3b 43 04             	cmp    0x4(%ebx),%eax
  80232c:	74 0d                	je     80233b <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80232e:	85 c0                	test   %eax,%eax
  802330:	ba 00 00 00 00       	mov    $0x0,%edx
  802335:	0f 4f c2             	cmovg  %edx,%eax
  802338:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80233b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80233e:	c9                   	leave  
  80233f:	f3 c3                	repz ret 

00802341 <putch>:

static void
putch(int ch, void *thunk)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	53                   	push   %ebx
  802345:	83 ec 04             	sub    $0x4,%esp
  802348:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80234b:	8b 53 04             	mov    0x4(%ebx),%edx
  80234e:	8d 42 01             	lea    0x1(%edx),%eax
  802351:	89 43 04             	mov    %eax,0x4(%ebx)
  802354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802357:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80235b:	3d 00 01 00 00       	cmp    $0x100,%eax
  802360:	75 0e                	jne    802370 <putch+0x2f>
		writebuf(b);
  802362:	89 d8                	mov    %ebx,%eax
  802364:	e8 99 ff ff ff       	call   802302 <writebuf>
		b->idx = 0;
  802369:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802370:	83 c4 04             	add    $0x4,%esp
  802373:	5b                   	pop    %ebx
  802374:	5d                   	pop    %ebp
  802375:	c3                   	ret    

00802376 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802376:	55                   	push   %ebp
  802377:	89 e5                	mov    %esp,%ebp
  802379:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80237f:	8b 45 08             	mov    0x8(%ebp),%eax
  802382:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802388:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80238f:	00 00 00 
	b.result = 0;
  802392:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802399:	00 00 00 
	b.error = 1;
  80239c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8023a3:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8023a6:	ff 75 10             	pushl  0x10(%ebp)
  8023a9:	ff 75 0c             	pushl  0xc(%ebp)
  8023ac:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8023b2:	50                   	push   %eax
  8023b3:	68 41 23 80 00       	push   $0x802341
  8023b8:	e8 2b e8 ff ff       	call   800be8 <vprintfmt>
	if (b.idx > 0)
  8023bd:	83 c4 10             	add    $0x10,%esp
  8023c0:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8023c7:	7e 0b                	jle    8023d4 <vfprintf+0x5e>
		writebuf(&b);
  8023c9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8023cf:	e8 2e ff ff ff       	call   802302 <writebuf>

	return (b.result ? b.result : b.error);
  8023d4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8023da:	85 c0                	test   %eax,%eax
  8023dc:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8023e3:	c9                   	leave  
  8023e4:	c3                   	ret    

008023e5 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8023eb:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8023ee:	50                   	push   %eax
  8023ef:	ff 75 0c             	pushl  0xc(%ebp)
  8023f2:	ff 75 08             	pushl  0x8(%ebp)
  8023f5:	e8 7c ff ff ff       	call   802376 <vfprintf>
	va_end(ap);

	return cnt;
}
  8023fa:	c9                   	leave  
  8023fb:	c3                   	ret    

008023fc <printf>:

int
printf(const char *fmt, ...)
{
  8023fc:	55                   	push   %ebp
  8023fd:	89 e5                	mov    %esp,%ebp
  8023ff:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802402:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802405:	50                   	push   %eax
  802406:	ff 75 08             	pushl  0x8(%ebp)
  802409:	6a 01                	push   $0x1
  80240b:	e8 66 ff ff ff       	call   802376 <vfprintf>
	va_end(ap);

	return cnt;
}
  802410:	c9                   	leave  
  802411:	c3                   	ret    

00802412 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802412:	55                   	push   %ebp
  802413:	89 e5                	mov    %esp,%ebp
  802415:	57                   	push   %edi
  802416:	56                   	push   %esi
  802417:	53                   	push   %ebx
  802418:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80241e:	6a 00                	push   $0x0
  802420:	ff 75 08             	pushl  0x8(%ebp)
  802423:	e8 36 fe ff ff       	call   80225e <open>
  802428:	89 c7                	mov    %eax,%edi
  80242a:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802430:	83 c4 10             	add    $0x10,%esp
  802433:	85 c0                	test   %eax,%eax
  802435:	0f 88 97 04 00 00    	js     8028d2 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80243b:	83 ec 04             	sub    $0x4,%esp
  80243e:	68 00 02 00 00       	push   $0x200
  802443:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802449:	50                   	push   %eax
  80244a:	57                   	push   %edi
  80244b:	e8 21 fa ff ff       	call   801e71 <readn>
  802450:	83 c4 10             	add    $0x10,%esp
  802453:	3d 00 02 00 00       	cmp    $0x200,%eax
  802458:	75 0c                	jne    802466 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80245a:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802461:	45 4c 46 
  802464:	74 33                	je     802499 <spawn+0x87>
		close(fd);
  802466:	83 ec 0c             	sub    $0xc,%esp
  802469:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80246f:	e8 30 f8 ff ff       	call   801ca4 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802474:	83 c4 0c             	add    $0xc,%esp
  802477:	68 7f 45 4c 46       	push   $0x464c457f
  80247c:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802482:	68 be 38 80 00       	push   $0x8038be
  802487:	e8 25 e6 ff ff       	call   800ab1 <cprintf>
		return -E_NOT_EXEC;
  80248c:	83 c4 10             	add    $0x10,%esp
  80248f:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  802494:	e9 ec 04 00 00       	jmp    802985 <spawn+0x573>
  802499:	b8 07 00 00 00       	mov    $0x7,%eax
  80249e:	cd 30                	int    $0x30
  8024a0:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8024a6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8024ac:	85 c0                	test   %eax,%eax
  8024ae:	0f 88 29 04 00 00    	js     8028dd <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8024b4:	89 c6                	mov    %eax,%esi
  8024b6:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8024bc:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8024bf:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8024c5:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8024cb:	b9 11 00 00 00       	mov    $0x11,%ecx
  8024d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8024d2:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8024d8:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8024de:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8024e3:	be 00 00 00 00       	mov    $0x0,%esi
  8024e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024eb:	eb 13                	jmp    802500 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8024ed:	83 ec 0c             	sub    $0xc,%esp
  8024f0:	50                   	push   %eax
  8024f1:	e8 fa eb ff ff       	call   8010f0 <strlen>
  8024f6:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8024fa:	83 c3 01             	add    $0x1,%ebx
  8024fd:	83 c4 10             	add    $0x10,%esp
  802500:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802507:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80250a:	85 c0                	test   %eax,%eax
  80250c:	75 df                	jne    8024ed <spawn+0xdb>
  80250e:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802514:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80251a:	bf 00 10 40 00       	mov    $0x401000,%edi
  80251f:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802521:	89 fa                	mov    %edi,%edx
  802523:	83 e2 fc             	and    $0xfffffffc,%edx
  802526:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80252d:	29 c2                	sub    %eax,%edx
  80252f:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802535:	8d 42 f8             	lea    -0x8(%edx),%eax
  802538:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80253d:	0f 86 b0 03 00 00    	jbe    8028f3 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802543:	83 ec 04             	sub    $0x4,%esp
  802546:	6a 07                	push   $0x7
  802548:	68 00 00 40 00       	push   $0x400000
  80254d:	6a 00                	push   $0x0
  80254f:	e8 d8 ef ff ff       	call   80152c <sys_page_alloc>
  802554:	83 c4 10             	add    $0x10,%esp
  802557:	85 c0                	test   %eax,%eax
  802559:	0f 88 9e 03 00 00    	js     8028fd <spawn+0x4eb>
  80255f:	be 00 00 00 00       	mov    $0x0,%esi
  802564:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80256a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80256d:	eb 30                	jmp    80259f <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80256f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802575:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80257b:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80257e:	83 ec 08             	sub    $0x8,%esp
  802581:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802584:	57                   	push   %edi
  802585:	e8 9f eb ff ff       	call   801129 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80258a:	83 c4 04             	add    $0x4,%esp
  80258d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802590:	e8 5b eb ff ff       	call   8010f0 <strlen>
  802595:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802599:	83 c6 01             	add    $0x1,%esi
  80259c:	83 c4 10             	add    $0x10,%esp
  80259f:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8025a5:	7f c8                	jg     80256f <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8025a7:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8025ad:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  8025b3:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8025ba:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8025c0:	74 19                	je     8025db <spawn+0x1c9>
  8025c2:	68 48 39 80 00       	push   $0x803948
  8025c7:	68 38 33 80 00       	push   $0x803338
  8025cc:	68 f2 00 00 00       	push   $0xf2
  8025d1:	68 d8 38 80 00       	push   $0x8038d8
  8025d6:	e8 fd e3 ff ff       	call   8009d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8025db:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8025e1:	89 f8                	mov    %edi,%eax
  8025e3:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8025e8:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8025eb:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8025f1:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8025f4:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8025fa:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802600:	83 ec 0c             	sub    $0xc,%esp
  802603:	6a 07                	push   $0x7
  802605:	68 00 d0 bf ee       	push   $0xeebfd000
  80260a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802610:	68 00 00 40 00       	push   $0x400000
  802615:	6a 00                	push   $0x0
  802617:	e8 53 ef ff ff       	call   80156f <sys_page_map>
  80261c:	89 c3                	mov    %eax,%ebx
  80261e:	83 c4 20             	add    $0x20,%esp
  802621:	85 c0                	test   %eax,%eax
  802623:	0f 88 4a 03 00 00    	js     802973 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802629:	83 ec 08             	sub    $0x8,%esp
  80262c:	68 00 00 40 00       	push   $0x400000
  802631:	6a 00                	push   $0x0
  802633:	e8 79 ef ff ff       	call   8015b1 <sys_page_unmap>
  802638:	89 c3                	mov    %eax,%ebx
  80263a:	83 c4 10             	add    $0x10,%esp
  80263d:	85 c0                	test   %eax,%eax
  80263f:	0f 88 2e 03 00 00    	js     802973 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802645:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80264b:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802652:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802658:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80265f:	00 00 00 
  802662:	e9 8a 01 00 00       	jmp    8027f1 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  802667:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80266d:	83 38 01             	cmpl   $0x1,(%eax)
  802670:	0f 85 6d 01 00 00    	jne    8027e3 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802676:	89 c7                	mov    %eax,%edi
  802678:	8b 40 18             	mov    0x18(%eax),%eax
  80267b:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802681:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802684:	83 f8 01             	cmp    $0x1,%eax
  802687:	19 c0                	sbb    %eax,%eax
  802689:	83 e0 fe             	and    $0xfffffffe,%eax
  80268c:	83 c0 07             	add    $0x7,%eax
  80268f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802695:	89 f8                	mov    %edi,%eax
  802697:	8b 7f 04             	mov    0x4(%edi),%edi
  80269a:	89 f9                	mov    %edi,%ecx
  80269c:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8026a2:	8b 78 10             	mov    0x10(%eax),%edi
  8026a5:	8b 70 14             	mov    0x14(%eax),%esi
  8026a8:	89 f3                	mov    %esi,%ebx
  8026aa:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8026b0:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8026b3:	89 f0                	mov    %esi,%eax
  8026b5:	25 ff 0f 00 00       	and    $0xfff,%eax
  8026ba:	74 14                	je     8026d0 <spawn+0x2be>
		va -= i;
  8026bc:	29 c6                	sub    %eax,%esi
		memsz += i;
  8026be:	01 c3                	add    %eax,%ebx
  8026c0:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  8026c6:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8026c8:	29 c1                	sub    %eax,%ecx
  8026ca:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8026d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026d5:	e9 f7 00 00 00       	jmp    8027d1 <spawn+0x3bf>
		if (i >= filesz) {
  8026da:	39 df                	cmp    %ebx,%edi
  8026dc:	77 27                	ja     802705 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8026de:	83 ec 04             	sub    $0x4,%esp
  8026e1:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8026e7:	56                   	push   %esi
  8026e8:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8026ee:	e8 39 ee ff ff       	call   80152c <sys_page_alloc>
  8026f3:	83 c4 10             	add    $0x10,%esp
  8026f6:	85 c0                	test   %eax,%eax
  8026f8:	0f 89 c7 00 00 00    	jns    8027c5 <spawn+0x3b3>
  8026fe:	89 c3                	mov    %eax,%ebx
  802700:	e9 09 02 00 00       	jmp    80290e <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802705:	83 ec 04             	sub    $0x4,%esp
  802708:	6a 07                	push   $0x7
  80270a:	68 00 00 40 00       	push   $0x400000
  80270f:	6a 00                	push   $0x0
  802711:	e8 16 ee ff ff       	call   80152c <sys_page_alloc>
  802716:	83 c4 10             	add    $0x10,%esp
  802719:	85 c0                	test   %eax,%eax
  80271b:	0f 88 e3 01 00 00    	js     802904 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802721:	83 ec 08             	sub    $0x8,%esp
  802724:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80272a:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802730:	50                   	push   %eax
  802731:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802737:	e8 0a f8 ff ff       	call   801f46 <seek>
  80273c:	83 c4 10             	add    $0x10,%esp
  80273f:	85 c0                	test   %eax,%eax
  802741:	0f 88 c1 01 00 00    	js     802908 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802747:	83 ec 04             	sub    $0x4,%esp
  80274a:	89 f8                	mov    %edi,%eax
  80274c:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802752:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802757:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80275c:	0f 47 c1             	cmova  %ecx,%eax
  80275f:	50                   	push   %eax
  802760:	68 00 00 40 00       	push   $0x400000
  802765:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80276b:	e8 01 f7 ff ff       	call   801e71 <readn>
  802770:	83 c4 10             	add    $0x10,%esp
  802773:	85 c0                	test   %eax,%eax
  802775:	0f 88 91 01 00 00    	js     80290c <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80277b:	83 ec 0c             	sub    $0xc,%esp
  80277e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802784:	56                   	push   %esi
  802785:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80278b:	68 00 00 40 00       	push   $0x400000
  802790:	6a 00                	push   $0x0
  802792:	e8 d8 ed ff ff       	call   80156f <sys_page_map>
  802797:	83 c4 20             	add    $0x20,%esp
  80279a:	85 c0                	test   %eax,%eax
  80279c:	79 15                	jns    8027b3 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  80279e:	50                   	push   %eax
  80279f:	68 e4 38 80 00       	push   $0x8038e4
  8027a4:	68 25 01 00 00       	push   $0x125
  8027a9:	68 d8 38 80 00       	push   $0x8038d8
  8027ae:	e8 25 e2 ff ff       	call   8009d8 <_panic>
			sys_page_unmap(0, UTEMP);
  8027b3:	83 ec 08             	sub    $0x8,%esp
  8027b6:	68 00 00 40 00       	push   $0x400000
  8027bb:	6a 00                	push   $0x0
  8027bd:	e8 ef ed ff ff       	call   8015b1 <sys_page_unmap>
  8027c2:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8027cb:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8027d1:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8027d7:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8027dd:	0f 87 f7 fe ff ff    	ja     8026da <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027e3:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8027ea:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8027f1:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8027f8:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8027fe:	0f 8c 63 fe ff ff    	jl     802667 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802804:	83 ec 0c             	sub    $0xc,%esp
  802807:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80280d:	e8 92 f4 ff ff       	call   801ca4 <close>
  802812:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  802815:	bb 00 08 00 00       	mov    $0x800,%ebx
  80281a:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  802820:	89 d8                	mov    %ebx,%eax
  802822:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  802825:	89 c2                	mov    %eax,%edx
  802827:	c1 ea 16             	shr    $0x16,%edx
  80282a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802831:	f6 c2 01             	test   $0x1,%dl
  802834:	74 4b                	je     802881 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  802836:	89 c2                	mov    %eax,%edx
  802838:	c1 ea 0c             	shr    $0xc,%edx
  80283b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  802842:	f6 c1 01             	test   $0x1,%cl
  802845:	74 3a                	je     802881 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  802847:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80284e:	f6 c6 04             	test   $0x4,%dh
  802851:	74 2e                	je     802881 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  802853:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  80285a:	8b 0d 24 54 80 00    	mov    0x805424,%ecx
  802860:	8b 49 48             	mov    0x48(%ecx),%ecx
  802863:	83 ec 0c             	sub    $0xc,%esp
  802866:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80286c:	52                   	push   %edx
  80286d:	50                   	push   %eax
  80286e:	56                   	push   %esi
  80286f:	50                   	push   %eax
  802870:	51                   	push   %ecx
  802871:	e8 f9 ec ff ff       	call   80156f <sys_page_map>
					if (r < 0)
  802876:	83 c4 20             	add    $0x20,%esp
  802879:	85 c0                	test   %eax,%eax
  80287b:	0f 88 ae 00 00 00    	js     80292f <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  802881:	83 c3 01             	add    $0x1,%ebx
  802884:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80288a:	75 94                	jne    802820 <spawn+0x40e>
  80288c:	e9 b3 00 00 00       	jmp    802944 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802891:	50                   	push   %eax
  802892:	68 01 39 80 00       	push   $0x803901
  802897:	68 86 00 00 00       	push   $0x86
  80289c:	68 d8 38 80 00       	push   $0x8038d8
  8028a1:	e8 32 e1 ff ff       	call   8009d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8028a6:	83 ec 08             	sub    $0x8,%esp
  8028a9:	6a 02                	push   $0x2
  8028ab:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8028b1:	e8 3d ed ff ff       	call   8015f3 <sys_env_set_status>
  8028b6:	83 c4 10             	add    $0x10,%esp
  8028b9:	85 c0                	test   %eax,%eax
  8028bb:	79 2b                	jns    8028e8 <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  8028bd:	50                   	push   %eax
  8028be:	68 1b 39 80 00       	push   $0x80391b
  8028c3:	68 89 00 00 00       	push   $0x89
  8028c8:	68 d8 38 80 00       	push   $0x8038d8
  8028cd:	e8 06 e1 ff ff       	call   8009d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8028d2:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8028d8:	e9 a8 00 00 00       	jmp    802985 <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8028dd:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8028e3:	e9 9d 00 00 00       	jmp    802985 <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8028e8:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8028ee:	e9 92 00 00 00       	jmp    802985 <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8028f3:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8028f8:	e9 88 00 00 00       	jmp    802985 <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8028fd:	89 c3                	mov    %eax,%ebx
  8028ff:	e9 81 00 00 00       	jmp    802985 <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802904:	89 c3                	mov    %eax,%ebx
  802906:	eb 06                	jmp    80290e <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802908:	89 c3                	mov    %eax,%ebx
  80290a:	eb 02                	jmp    80290e <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80290c:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  80290e:	83 ec 0c             	sub    $0xc,%esp
  802911:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802917:	e8 91 eb ff ff       	call   8014ad <sys_env_destroy>
	close(fd);
  80291c:	83 c4 04             	add    $0x4,%esp
  80291f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802925:	e8 7a f3 ff ff       	call   801ca4 <close>
	return r;
  80292a:	83 c4 10             	add    $0x10,%esp
  80292d:	eb 56                	jmp    802985 <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  80292f:	50                   	push   %eax
  802930:	68 32 39 80 00       	push   $0x803932
  802935:	68 82 00 00 00       	push   $0x82
  80293a:	68 d8 38 80 00       	push   $0x8038d8
  80293f:	e8 94 e0 ff ff       	call   8009d8 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802944:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80294b:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80294e:	83 ec 08             	sub    $0x8,%esp
  802951:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802957:	50                   	push   %eax
  802958:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80295e:	e8 d2 ec ff ff       	call   801635 <sys_env_set_trapframe>
  802963:	83 c4 10             	add    $0x10,%esp
  802966:	85 c0                	test   %eax,%eax
  802968:	0f 89 38 ff ff ff    	jns    8028a6 <spawn+0x494>
  80296e:	e9 1e ff ff ff       	jmp    802891 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802973:	83 ec 08             	sub    $0x8,%esp
  802976:	68 00 00 40 00       	push   $0x400000
  80297b:	6a 00                	push   $0x0
  80297d:	e8 2f ec ff ff       	call   8015b1 <sys_page_unmap>
  802982:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802985:	89 d8                	mov    %ebx,%eax
  802987:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80298a:	5b                   	pop    %ebx
  80298b:	5e                   	pop    %esi
  80298c:	5f                   	pop    %edi
  80298d:	5d                   	pop    %ebp
  80298e:	c3                   	ret    

0080298f <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80298f:	55                   	push   %ebp
  802990:	89 e5                	mov    %esp,%ebp
  802992:	56                   	push   %esi
  802993:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802994:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802997:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80299c:	eb 03                	jmp    8029a1 <spawnl+0x12>
		argc++;
  80299e:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029a1:	83 c2 04             	add    $0x4,%edx
  8029a4:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8029a8:	75 f4                	jne    80299e <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8029aa:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8029b1:	83 e2 f0             	and    $0xfffffff0,%edx
  8029b4:	29 d4                	sub    %edx,%esp
  8029b6:	8d 54 24 03          	lea    0x3(%esp),%edx
  8029ba:	c1 ea 02             	shr    $0x2,%edx
  8029bd:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8029c4:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8029c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029c9:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8029d0:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8029d7:	00 
  8029d8:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8029da:	b8 00 00 00 00       	mov    $0x0,%eax
  8029df:	eb 0a                	jmp    8029eb <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8029e1:	83 c0 01             	add    $0x1,%eax
  8029e4:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8029e8:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8029eb:	39 d0                	cmp    %edx,%eax
  8029ed:	75 f2                	jne    8029e1 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8029ef:	83 ec 08             	sub    $0x8,%esp
  8029f2:	56                   	push   %esi
  8029f3:	ff 75 08             	pushl  0x8(%ebp)
  8029f6:	e8 17 fa ff ff       	call   802412 <spawn>
}
  8029fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029fe:	5b                   	pop    %ebx
  8029ff:	5e                   	pop    %esi
  802a00:	5d                   	pop    %ebp
  802a01:	c3                   	ret    

00802a02 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802a02:	55                   	push   %ebp
  802a03:	89 e5                	mov    %esp,%ebp
  802a05:	56                   	push   %esi
  802a06:	53                   	push   %ebx
  802a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802a0a:	83 ec 0c             	sub    $0xc,%esp
  802a0d:	ff 75 08             	pushl  0x8(%ebp)
  802a10:	e8 ff f0 ff ff       	call   801b14 <fd2data>
  802a15:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802a17:	83 c4 08             	add    $0x8,%esp
  802a1a:	68 70 39 80 00       	push   $0x803970
  802a1f:	53                   	push   %ebx
  802a20:	e8 04 e7 ff ff       	call   801129 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802a25:	8b 46 04             	mov    0x4(%esi),%eax
  802a28:	2b 06                	sub    (%esi),%eax
  802a2a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802a30:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802a37:	00 00 00 
	stat->st_dev = &devpipe;
  802a3a:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802a41:	40 80 00 
	return 0;
}
  802a44:	b8 00 00 00 00       	mov    $0x0,%eax
  802a49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a4c:	5b                   	pop    %ebx
  802a4d:	5e                   	pop    %esi
  802a4e:	5d                   	pop    %ebp
  802a4f:	c3                   	ret    

00802a50 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802a50:	55                   	push   %ebp
  802a51:	89 e5                	mov    %esp,%ebp
  802a53:	53                   	push   %ebx
  802a54:	83 ec 0c             	sub    $0xc,%esp
  802a57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802a5a:	53                   	push   %ebx
  802a5b:	6a 00                	push   $0x0
  802a5d:	e8 4f eb ff ff       	call   8015b1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802a62:	89 1c 24             	mov    %ebx,(%esp)
  802a65:	e8 aa f0 ff ff       	call   801b14 <fd2data>
  802a6a:	83 c4 08             	add    $0x8,%esp
  802a6d:	50                   	push   %eax
  802a6e:	6a 00                	push   $0x0
  802a70:	e8 3c eb ff ff       	call   8015b1 <sys_page_unmap>
}
  802a75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a78:	c9                   	leave  
  802a79:	c3                   	ret    

00802a7a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802a7a:	55                   	push   %ebp
  802a7b:	89 e5                	mov    %esp,%ebp
  802a7d:	57                   	push   %edi
  802a7e:	56                   	push   %esi
  802a7f:	53                   	push   %ebx
  802a80:	83 ec 1c             	sub    $0x1c,%esp
  802a83:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802a86:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802a88:	a1 24 54 80 00       	mov    0x805424,%eax
  802a8d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802a90:	83 ec 0c             	sub    $0xc,%esp
  802a93:	ff 75 e0             	pushl  -0x20(%ebp)
  802a96:	e8 71 04 00 00       	call   802f0c <pageref>
  802a9b:	89 c3                	mov    %eax,%ebx
  802a9d:	89 3c 24             	mov    %edi,(%esp)
  802aa0:	e8 67 04 00 00       	call   802f0c <pageref>
  802aa5:	83 c4 10             	add    $0x10,%esp
  802aa8:	39 c3                	cmp    %eax,%ebx
  802aaa:	0f 94 c1             	sete   %cl
  802aad:	0f b6 c9             	movzbl %cl,%ecx
  802ab0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802ab3:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802ab9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802abc:	39 ce                	cmp    %ecx,%esi
  802abe:	74 1b                	je     802adb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802ac0:	39 c3                	cmp    %eax,%ebx
  802ac2:	75 c4                	jne    802a88 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802ac4:	8b 42 58             	mov    0x58(%edx),%eax
  802ac7:	ff 75 e4             	pushl  -0x1c(%ebp)
  802aca:	50                   	push   %eax
  802acb:	56                   	push   %esi
  802acc:	68 77 39 80 00       	push   $0x803977
  802ad1:	e8 db df ff ff       	call   800ab1 <cprintf>
  802ad6:	83 c4 10             	add    $0x10,%esp
  802ad9:	eb ad                	jmp    802a88 <_pipeisclosed+0xe>
	}
}
  802adb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ae1:	5b                   	pop    %ebx
  802ae2:	5e                   	pop    %esi
  802ae3:	5f                   	pop    %edi
  802ae4:	5d                   	pop    %ebp
  802ae5:	c3                   	ret    

00802ae6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802ae6:	55                   	push   %ebp
  802ae7:	89 e5                	mov    %esp,%ebp
  802ae9:	57                   	push   %edi
  802aea:	56                   	push   %esi
  802aeb:	53                   	push   %ebx
  802aec:	83 ec 28             	sub    $0x28,%esp
  802aef:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802af2:	56                   	push   %esi
  802af3:	e8 1c f0 ff ff       	call   801b14 <fd2data>
  802af8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802afa:	83 c4 10             	add    $0x10,%esp
  802afd:	bf 00 00 00 00       	mov    $0x0,%edi
  802b02:	eb 4b                	jmp    802b4f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802b04:	89 da                	mov    %ebx,%edx
  802b06:	89 f0                	mov    %esi,%eax
  802b08:	e8 6d ff ff ff       	call   802a7a <_pipeisclosed>
  802b0d:	85 c0                	test   %eax,%eax
  802b0f:	75 48                	jne    802b59 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802b11:	e8 f7 e9 ff ff       	call   80150d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802b16:	8b 43 04             	mov    0x4(%ebx),%eax
  802b19:	8b 0b                	mov    (%ebx),%ecx
  802b1b:	8d 51 20             	lea    0x20(%ecx),%edx
  802b1e:	39 d0                	cmp    %edx,%eax
  802b20:	73 e2                	jae    802b04 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b25:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802b29:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802b2c:	89 c2                	mov    %eax,%edx
  802b2e:	c1 fa 1f             	sar    $0x1f,%edx
  802b31:	89 d1                	mov    %edx,%ecx
  802b33:	c1 e9 1b             	shr    $0x1b,%ecx
  802b36:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802b39:	83 e2 1f             	and    $0x1f,%edx
  802b3c:	29 ca                	sub    %ecx,%edx
  802b3e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802b42:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802b46:	83 c0 01             	add    $0x1,%eax
  802b49:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b4c:	83 c7 01             	add    $0x1,%edi
  802b4f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802b52:	75 c2                	jne    802b16 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802b54:	8b 45 10             	mov    0x10(%ebp),%eax
  802b57:	eb 05                	jmp    802b5e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b59:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b61:	5b                   	pop    %ebx
  802b62:	5e                   	pop    %esi
  802b63:	5f                   	pop    %edi
  802b64:	5d                   	pop    %ebp
  802b65:	c3                   	ret    

00802b66 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802b66:	55                   	push   %ebp
  802b67:	89 e5                	mov    %esp,%ebp
  802b69:	57                   	push   %edi
  802b6a:	56                   	push   %esi
  802b6b:	53                   	push   %ebx
  802b6c:	83 ec 18             	sub    $0x18,%esp
  802b6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802b72:	57                   	push   %edi
  802b73:	e8 9c ef ff ff       	call   801b14 <fd2data>
  802b78:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b7a:	83 c4 10             	add    $0x10,%esp
  802b7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b82:	eb 3d                	jmp    802bc1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802b84:	85 db                	test   %ebx,%ebx
  802b86:	74 04                	je     802b8c <devpipe_read+0x26>
				return i;
  802b88:	89 d8                	mov    %ebx,%eax
  802b8a:	eb 44                	jmp    802bd0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802b8c:	89 f2                	mov    %esi,%edx
  802b8e:	89 f8                	mov    %edi,%eax
  802b90:	e8 e5 fe ff ff       	call   802a7a <_pipeisclosed>
  802b95:	85 c0                	test   %eax,%eax
  802b97:	75 32                	jne    802bcb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802b99:	e8 6f e9 ff ff       	call   80150d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802b9e:	8b 06                	mov    (%esi),%eax
  802ba0:	3b 46 04             	cmp    0x4(%esi),%eax
  802ba3:	74 df                	je     802b84 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802ba5:	99                   	cltd   
  802ba6:	c1 ea 1b             	shr    $0x1b,%edx
  802ba9:	01 d0                	add    %edx,%eax
  802bab:	83 e0 1f             	and    $0x1f,%eax
  802bae:	29 d0                	sub    %edx,%eax
  802bb0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bb8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802bbb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bbe:	83 c3 01             	add    $0x1,%ebx
  802bc1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802bc4:	75 d8                	jne    802b9e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802bc6:	8b 45 10             	mov    0x10(%ebp),%eax
  802bc9:	eb 05                	jmp    802bd0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802bcb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bd3:	5b                   	pop    %ebx
  802bd4:	5e                   	pop    %esi
  802bd5:	5f                   	pop    %edi
  802bd6:	5d                   	pop    %ebp
  802bd7:	c3                   	ret    

00802bd8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802bd8:	55                   	push   %ebp
  802bd9:	89 e5                	mov    %esp,%ebp
  802bdb:	56                   	push   %esi
  802bdc:	53                   	push   %ebx
  802bdd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802be0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802be3:	50                   	push   %eax
  802be4:	e8 42 ef ff ff       	call   801b2b <fd_alloc>
  802be9:	83 c4 10             	add    $0x10,%esp
  802bec:	89 c2                	mov    %eax,%edx
  802bee:	85 c0                	test   %eax,%eax
  802bf0:	0f 88 2c 01 00 00    	js     802d22 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bf6:	83 ec 04             	sub    $0x4,%esp
  802bf9:	68 07 04 00 00       	push   $0x407
  802bfe:	ff 75 f4             	pushl  -0xc(%ebp)
  802c01:	6a 00                	push   $0x0
  802c03:	e8 24 e9 ff ff       	call   80152c <sys_page_alloc>
  802c08:	83 c4 10             	add    $0x10,%esp
  802c0b:	89 c2                	mov    %eax,%edx
  802c0d:	85 c0                	test   %eax,%eax
  802c0f:	0f 88 0d 01 00 00    	js     802d22 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802c15:	83 ec 0c             	sub    $0xc,%esp
  802c18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c1b:	50                   	push   %eax
  802c1c:	e8 0a ef ff ff       	call   801b2b <fd_alloc>
  802c21:	89 c3                	mov    %eax,%ebx
  802c23:	83 c4 10             	add    $0x10,%esp
  802c26:	85 c0                	test   %eax,%eax
  802c28:	0f 88 e2 00 00 00    	js     802d10 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c2e:	83 ec 04             	sub    $0x4,%esp
  802c31:	68 07 04 00 00       	push   $0x407
  802c36:	ff 75 f0             	pushl  -0x10(%ebp)
  802c39:	6a 00                	push   $0x0
  802c3b:	e8 ec e8 ff ff       	call   80152c <sys_page_alloc>
  802c40:	89 c3                	mov    %eax,%ebx
  802c42:	83 c4 10             	add    $0x10,%esp
  802c45:	85 c0                	test   %eax,%eax
  802c47:	0f 88 c3 00 00 00    	js     802d10 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802c4d:	83 ec 0c             	sub    $0xc,%esp
  802c50:	ff 75 f4             	pushl  -0xc(%ebp)
  802c53:	e8 bc ee ff ff       	call   801b14 <fd2data>
  802c58:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c5a:	83 c4 0c             	add    $0xc,%esp
  802c5d:	68 07 04 00 00       	push   $0x407
  802c62:	50                   	push   %eax
  802c63:	6a 00                	push   $0x0
  802c65:	e8 c2 e8 ff ff       	call   80152c <sys_page_alloc>
  802c6a:	89 c3                	mov    %eax,%ebx
  802c6c:	83 c4 10             	add    $0x10,%esp
  802c6f:	85 c0                	test   %eax,%eax
  802c71:	0f 88 89 00 00 00    	js     802d00 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c77:	83 ec 0c             	sub    $0xc,%esp
  802c7a:	ff 75 f0             	pushl  -0x10(%ebp)
  802c7d:	e8 92 ee ff ff       	call   801b14 <fd2data>
  802c82:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802c89:	50                   	push   %eax
  802c8a:	6a 00                	push   $0x0
  802c8c:	56                   	push   %esi
  802c8d:	6a 00                	push   $0x0
  802c8f:	e8 db e8 ff ff       	call   80156f <sys_page_map>
  802c94:	89 c3                	mov    %eax,%ebx
  802c96:	83 c4 20             	add    $0x20,%esp
  802c99:	85 c0                	test   %eax,%eax
  802c9b:	78 55                	js     802cf2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802c9d:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ca6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802cb2:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cbb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cc0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802cc7:	83 ec 0c             	sub    $0xc,%esp
  802cca:	ff 75 f4             	pushl  -0xc(%ebp)
  802ccd:	e8 32 ee ff ff       	call   801b04 <fd2num>
  802cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802cd5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802cd7:	83 c4 04             	add    $0x4,%esp
  802cda:	ff 75 f0             	pushl  -0x10(%ebp)
  802cdd:	e8 22 ee ff ff       	call   801b04 <fd2num>
  802ce2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ce5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802ce8:	83 c4 10             	add    $0x10,%esp
  802ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  802cf0:	eb 30                	jmp    802d22 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802cf2:	83 ec 08             	sub    $0x8,%esp
  802cf5:	56                   	push   %esi
  802cf6:	6a 00                	push   $0x0
  802cf8:	e8 b4 e8 ff ff       	call   8015b1 <sys_page_unmap>
  802cfd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802d00:	83 ec 08             	sub    $0x8,%esp
  802d03:	ff 75 f0             	pushl  -0x10(%ebp)
  802d06:	6a 00                	push   $0x0
  802d08:	e8 a4 e8 ff ff       	call   8015b1 <sys_page_unmap>
  802d0d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802d10:	83 ec 08             	sub    $0x8,%esp
  802d13:	ff 75 f4             	pushl  -0xc(%ebp)
  802d16:	6a 00                	push   $0x0
  802d18:	e8 94 e8 ff ff       	call   8015b1 <sys_page_unmap>
  802d1d:	83 c4 10             	add    $0x10,%esp
  802d20:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802d22:	89 d0                	mov    %edx,%eax
  802d24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d27:	5b                   	pop    %ebx
  802d28:	5e                   	pop    %esi
  802d29:	5d                   	pop    %ebp
  802d2a:	c3                   	ret    

00802d2b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802d2b:	55                   	push   %ebp
  802d2c:	89 e5                	mov    %esp,%ebp
  802d2e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d34:	50                   	push   %eax
  802d35:	ff 75 08             	pushl  0x8(%ebp)
  802d38:	e8 3d ee ff ff       	call   801b7a <fd_lookup>
  802d3d:	83 c4 10             	add    $0x10,%esp
  802d40:	85 c0                	test   %eax,%eax
  802d42:	78 18                	js     802d5c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802d44:	83 ec 0c             	sub    $0xc,%esp
  802d47:	ff 75 f4             	pushl  -0xc(%ebp)
  802d4a:	e8 c5 ed ff ff       	call   801b14 <fd2data>
	return _pipeisclosed(fd, p);
  802d4f:	89 c2                	mov    %eax,%edx
  802d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d54:	e8 21 fd ff ff       	call   802a7a <_pipeisclosed>
  802d59:	83 c4 10             	add    $0x10,%esp
}
  802d5c:	c9                   	leave  
  802d5d:	c3                   	ret    

00802d5e <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802d5e:	55                   	push   %ebp
  802d5f:	89 e5                	mov    %esp,%ebp
  802d61:	56                   	push   %esi
  802d62:	53                   	push   %ebx
  802d63:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802d66:	85 f6                	test   %esi,%esi
  802d68:	75 16                	jne    802d80 <wait+0x22>
  802d6a:	68 8f 39 80 00       	push   $0x80398f
  802d6f:	68 38 33 80 00       	push   $0x803338
  802d74:	6a 09                	push   $0x9
  802d76:	68 9a 39 80 00       	push   $0x80399a
  802d7b:	e8 58 dc ff ff       	call   8009d8 <_panic>
	e = &envs[ENVX(envid)];
  802d80:	89 f3                	mov    %esi,%ebx
  802d82:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802d88:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802d8b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802d91:	eb 05                	jmp    802d98 <wait+0x3a>
		sys_yield();
  802d93:	e8 75 e7 ff ff       	call   80150d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802d98:	8b 43 48             	mov    0x48(%ebx),%eax
  802d9b:	39 c6                	cmp    %eax,%esi
  802d9d:	75 07                	jne    802da6 <wait+0x48>
  802d9f:	8b 43 54             	mov    0x54(%ebx),%eax
  802da2:	85 c0                	test   %eax,%eax
  802da4:	75 ed                	jne    802d93 <wait+0x35>
		sys_yield();
}
  802da6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802da9:	5b                   	pop    %ebx
  802daa:	5e                   	pop    %esi
  802dab:	5d                   	pop    %ebp
  802dac:	c3                   	ret    

00802dad <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802dad:	55                   	push   %ebp
  802dae:	89 e5                	mov    %esp,%ebp
  802db0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802db3:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802dba:	75 2e                	jne    802dea <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802dbc:	e8 2d e7 ff ff       	call   8014ee <sys_getenvid>
  802dc1:	83 ec 04             	sub    $0x4,%esp
  802dc4:	68 07 0e 00 00       	push   $0xe07
  802dc9:	68 00 f0 bf ee       	push   $0xeebff000
  802dce:	50                   	push   %eax
  802dcf:	e8 58 e7 ff ff       	call   80152c <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802dd4:	e8 15 e7 ff ff       	call   8014ee <sys_getenvid>
  802dd9:	83 c4 08             	add    $0x8,%esp
  802ddc:	68 f4 2d 80 00       	push   $0x802df4
  802de1:	50                   	push   %eax
  802de2:	e8 90 e8 ff ff       	call   801677 <sys_env_set_pgfault_upcall>
  802de7:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802dea:	8b 45 08             	mov    0x8(%ebp),%eax
  802ded:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802df2:	c9                   	leave  
  802df3:	c3                   	ret    

00802df4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802df4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802df5:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802dfa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802dfc:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802dff:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802e03:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802e07:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802e0a:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802e0d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802e0e:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802e11:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802e12:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802e13:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802e17:	c3                   	ret    

00802e18 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802e18:	55                   	push   %ebp
  802e19:	89 e5                	mov    %esp,%ebp
  802e1b:	56                   	push   %esi
  802e1c:	53                   	push   %ebx
  802e1d:	8b 75 08             	mov    0x8(%ebp),%esi
  802e20:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802e26:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802e28:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802e2d:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802e30:	83 ec 0c             	sub    $0xc,%esp
  802e33:	50                   	push   %eax
  802e34:	e8 a3 e8 ff ff       	call   8016dc <sys_ipc_recv>

	if (from_env_store != NULL)
  802e39:	83 c4 10             	add    $0x10,%esp
  802e3c:	85 f6                	test   %esi,%esi
  802e3e:	74 14                	je     802e54 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802e40:	ba 00 00 00 00       	mov    $0x0,%edx
  802e45:	85 c0                	test   %eax,%eax
  802e47:	78 09                	js     802e52 <ipc_recv+0x3a>
  802e49:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802e4f:	8b 52 74             	mov    0x74(%edx),%edx
  802e52:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802e54:	85 db                	test   %ebx,%ebx
  802e56:	74 14                	je     802e6c <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802e58:	ba 00 00 00 00       	mov    $0x0,%edx
  802e5d:	85 c0                	test   %eax,%eax
  802e5f:	78 09                	js     802e6a <ipc_recv+0x52>
  802e61:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802e67:	8b 52 78             	mov    0x78(%edx),%edx
  802e6a:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802e6c:	85 c0                	test   %eax,%eax
  802e6e:	78 08                	js     802e78 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802e70:	a1 24 54 80 00       	mov    0x805424,%eax
  802e75:	8b 40 70             	mov    0x70(%eax),%eax
}
  802e78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e7b:	5b                   	pop    %ebx
  802e7c:	5e                   	pop    %esi
  802e7d:	5d                   	pop    %ebp
  802e7e:	c3                   	ret    

00802e7f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802e7f:	55                   	push   %ebp
  802e80:	89 e5                	mov    %esp,%ebp
  802e82:	57                   	push   %edi
  802e83:	56                   	push   %esi
  802e84:	53                   	push   %ebx
  802e85:	83 ec 0c             	sub    $0xc,%esp
  802e88:	8b 7d 08             	mov    0x8(%ebp),%edi
  802e8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  802e8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802e91:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802e93:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802e98:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802e9b:	ff 75 14             	pushl  0x14(%ebp)
  802e9e:	53                   	push   %ebx
  802e9f:	56                   	push   %esi
  802ea0:	57                   	push   %edi
  802ea1:	e8 13 e8 ff ff       	call   8016b9 <sys_ipc_try_send>

		if (err < 0) {
  802ea6:	83 c4 10             	add    $0x10,%esp
  802ea9:	85 c0                	test   %eax,%eax
  802eab:	79 1e                	jns    802ecb <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802ead:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802eb0:	75 07                	jne    802eb9 <ipc_send+0x3a>
				sys_yield();
  802eb2:	e8 56 e6 ff ff       	call   80150d <sys_yield>
  802eb7:	eb e2                	jmp    802e9b <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802eb9:	50                   	push   %eax
  802eba:	68 a5 39 80 00       	push   $0x8039a5
  802ebf:	6a 49                	push   $0x49
  802ec1:	68 b2 39 80 00       	push   $0x8039b2
  802ec6:	e8 0d db ff ff       	call   8009d8 <_panic>
		}

	} while (err < 0);

}
  802ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ece:	5b                   	pop    %ebx
  802ecf:	5e                   	pop    %esi
  802ed0:	5f                   	pop    %edi
  802ed1:	5d                   	pop    %ebp
  802ed2:	c3                   	ret    

00802ed3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802ed3:	55                   	push   %ebp
  802ed4:	89 e5                	mov    %esp,%ebp
  802ed6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802ed9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802ede:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802ee1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802ee7:	8b 52 50             	mov    0x50(%edx),%edx
  802eea:	39 ca                	cmp    %ecx,%edx
  802eec:	75 0d                	jne    802efb <ipc_find_env+0x28>
			return envs[i].env_id;
  802eee:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802ef1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802ef6:	8b 40 48             	mov    0x48(%eax),%eax
  802ef9:	eb 0f                	jmp    802f0a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802efb:	83 c0 01             	add    $0x1,%eax
  802efe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802f03:	75 d9                	jne    802ede <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802f05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f0a:	5d                   	pop    %ebp
  802f0b:	c3                   	ret    

00802f0c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f0c:	55                   	push   %ebp
  802f0d:	89 e5                	mov    %esp,%ebp
  802f0f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f12:	89 d0                	mov    %edx,%eax
  802f14:	c1 e8 16             	shr    $0x16,%eax
  802f17:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802f1e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f23:	f6 c1 01             	test   $0x1,%cl
  802f26:	74 1d                	je     802f45 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802f28:	c1 ea 0c             	shr    $0xc,%edx
  802f2b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802f32:	f6 c2 01             	test   $0x1,%dl
  802f35:	74 0e                	je     802f45 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802f37:	c1 ea 0c             	shr    $0xc,%edx
  802f3a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802f41:	ef 
  802f42:	0f b7 c0             	movzwl %ax,%eax
}
  802f45:	5d                   	pop    %ebp
  802f46:	c3                   	ret    
  802f47:	66 90                	xchg   %ax,%ax
  802f49:	66 90                	xchg   %ax,%ax
  802f4b:	66 90                	xchg   %ax,%ax
  802f4d:	66 90                	xchg   %ax,%ax
  802f4f:	90                   	nop

00802f50 <__udivdi3>:
  802f50:	55                   	push   %ebp
  802f51:	57                   	push   %edi
  802f52:	56                   	push   %esi
  802f53:	53                   	push   %ebx
  802f54:	83 ec 1c             	sub    $0x1c,%esp
  802f57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802f5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802f5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802f67:	85 f6                	test   %esi,%esi
  802f69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802f6d:	89 ca                	mov    %ecx,%edx
  802f6f:	89 f8                	mov    %edi,%eax
  802f71:	75 3d                	jne    802fb0 <__udivdi3+0x60>
  802f73:	39 cf                	cmp    %ecx,%edi
  802f75:	0f 87 c5 00 00 00    	ja     803040 <__udivdi3+0xf0>
  802f7b:	85 ff                	test   %edi,%edi
  802f7d:	89 fd                	mov    %edi,%ebp
  802f7f:	75 0b                	jne    802f8c <__udivdi3+0x3c>
  802f81:	b8 01 00 00 00       	mov    $0x1,%eax
  802f86:	31 d2                	xor    %edx,%edx
  802f88:	f7 f7                	div    %edi
  802f8a:	89 c5                	mov    %eax,%ebp
  802f8c:	89 c8                	mov    %ecx,%eax
  802f8e:	31 d2                	xor    %edx,%edx
  802f90:	f7 f5                	div    %ebp
  802f92:	89 c1                	mov    %eax,%ecx
  802f94:	89 d8                	mov    %ebx,%eax
  802f96:	89 cf                	mov    %ecx,%edi
  802f98:	f7 f5                	div    %ebp
  802f9a:	89 c3                	mov    %eax,%ebx
  802f9c:	89 d8                	mov    %ebx,%eax
  802f9e:	89 fa                	mov    %edi,%edx
  802fa0:	83 c4 1c             	add    $0x1c,%esp
  802fa3:	5b                   	pop    %ebx
  802fa4:	5e                   	pop    %esi
  802fa5:	5f                   	pop    %edi
  802fa6:	5d                   	pop    %ebp
  802fa7:	c3                   	ret    
  802fa8:	90                   	nop
  802fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802fb0:	39 ce                	cmp    %ecx,%esi
  802fb2:	77 74                	ja     803028 <__udivdi3+0xd8>
  802fb4:	0f bd fe             	bsr    %esi,%edi
  802fb7:	83 f7 1f             	xor    $0x1f,%edi
  802fba:	0f 84 98 00 00 00    	je     803058 <__udivdi3+0x108>
  802fc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802fc5:	89 f9                	mov    %edi,%ecx
  802fc7:	89 c5                	mov    %eax,%ebp
  802fc9:	29 fb                	sub    %edi,%ebx
  802fcb:	d3 e6                	shl    %cl,%esi
  802fcd:	89 d9                	mov    %ebx,%ecx
  802fcf:	d3 ed                	shr    %cl,%ebp
  802fd1:	89 f9                	mov    %edi,%ecx
  802fd3:	d3 e0                	shl    %cl,%eax
  802fd5:	09 ee                	or     %ebp,%esi
  802fd7:	89 d9                	mov    %ebx,%ecx
  802fd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802fdd:	89 d5                	mov    %edx,%ebp
  802fdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  802fe3:	d3 ed                	shr    %cl,%ebp
  802fe5:	89 f9                	mov    %edi,%ecx
  802fe7:	d3 e2                	shl    %cl,%edx
  802fe9:	89 d9                	mov    %ebx,%ecx
  802feb:	d3 e8                	shr    %cl,%eax
  802fed:	09 c2                	or     %eax,%edx
  802fef:	89 d0                	mov    %edx,%eax
  802ff1:	89 ea                	mov    %ebp,%edx
  802ff3:	f7 f6                	div    %esi
  802ff5:	89 d5                	mov    %edx,%ebp
  802ff7:	89 c3                	mov    %eax,%ebx
  802ff9:	f7 64 24 0c          	mull   0xc(%esp)
  802ffd:	39 d5                	cmp    %edx,%ebp
  802fff:	72 10                	jb     803011 <__udivdi3+0xc1>
  803001:	8b 74 24 08          	mov    0x8(%esp),%esi
  803005:	89 f9                	mov    %edi,%ecx
  803007:	d3 e6                	shl    %cl,%esi
  803009:	39 c6                	cmp    %eax,%esi
  80300b:	73 07                	jae    803014 <__udivdi3+0xc4>
  80300d:	39 d5                	cmp    %edx,%ebp
  80300f:	75 03                	jne    803014 <__udivdi3+0xc4>
  803011:	83 eb 01             	sub    $0x1,%ebx
  803014:	31 ff                	xor    %edi,%edi
  803016:	89 d8                	mov    %ebx,%eax
  803018:	89 fa                	mov    %edi,%edx
  80301a:	83 c4 1c             	add    $0x1c,%esp
  80301d:	5b                   	pop    %ebx
  80301e:	5e                   	pop    %esi
  80301f:	5f                   	pop    %edi
  803020:	5d                   	pop    %ebp
  803021:	c3                   	ret    
  803022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803028:	31 ff                	xor    %edi,%edi
  80302a:	31 db                	xor    %ebx,%ebx
  80302c:	89 d8                	mov    %ebx,%eax
  80302e:	89 fa                	mov    %edi,%edx
  803030:	83 c4 1c             	add    $0x1c,%esp
  803033:	5b                   	pop    %ebx
  803034:	5e                   	pop    %esi
  803035:	5f                   	pop    %edi
  803036:	5d                   	pop    %ebp
  803037:	c3                   	ret    
  803038:	90                   	nop
  803039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803040:	89 d8                	mov    %ebx,%eax
  803042:	f7 f7                	div    %edi
  803044:	31 ff                	xor    %edi,%edi
  803046:	89 c3                	mov    %eax,%ebx
  803048:	89 d8                	mov    %ebx,%eax
  80304a:	89 fa                	mov    %edi,%edx
  80304c:	83 c4 1c             	add    $0x1c,%esp
  80304f:	5b                   	pop    %ebx
  803050:	5e                   	pop    %esi
  803051:	5f                   	pop    %edi
  803052:	5d                   	pop    %ebp
  803053:	c3                   	ret    
  803054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803058:	39 ce                	cmp    %ecx,%esi
  80305a:	72 0c                	jb     803068 <__udivdi3+0x118>
  80305c:	31 db                	xor    %ebx,%ebx
  80305e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803062:	0f 87 34 ff ff ff    	ja     802f9c <__udivdi3+0x4c>
  803068:	bb 01 00 00 00       	mov    $0x1,%ebx
  80306d:	e9 2a ff ff ff       	jmp    802f9c <__udivdi3+0x4c>
  803072:	66 90                	xchg   %ax,%ax
  803074:	66 90                	xchg   %ax,%ax
  803076:	66 90                	xchg   %ax,%ax
  803078:	66 90                	xchg   %ax,%ax
  80307a:	66 90                	xchg   %ax,%ax
  80307c:	66 90                	xchg   %ax,%ax
  80307e:	66 90                	xchg   %ax,%ax

00803080 <__umoddi3>:
  803080:	55                   	push   %ebp
  803081:	57                   	push   %edi
  803082:	56                   	push   %esi
  803083:	53                   	push   %ebx
  803084:	83 ec 1c             	sub    $0x1c,%esp
  803087:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80308b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80308f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803097:	85 d2                	test   %edx,%edx
  803099:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80309d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8030a1:	89 f3                	mov    %esi,%ebx
  8030a3:	89 3c 24             	mov    %edi,(%esp)
  8030a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8030aa:	75 1c                	jne    8030c8 <__umoddi3+0x48>
  8030ac:	39 f7                	cmp    %esi,%edi
  8030ae:	76 50                	jbe    803100 <__umoddi3+0x80>
  8030b0:	89 c8                	mov    %ecx,%eax
  8030b2:	89 f2                	mov    %esi,%edx
  8030b4:	f7 f7                	div    %edi
  8030b6:	89 d0                	mov    %edx,%eax
  8030b8:	31 d2                	xor    %edx,%edx
  8030ba:	83 c4 1c             	add    $0x1c,%esp
  8030bd:	5b                   	pop    %ebx
  8030be:	5e                   	pop    %esi
  8030bf:	5f                   	pop    %edi
  8030c0:	5d                   	pop    %ebp
  8030c1:	c3                   	ret    
  8030c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8030c8:	39 f2                	cmp    %esi,%edx
  8030ca:	89 d0                	mov    %edx,%eax
  8030cc:	77 52                	ja     803120 <__umoddi3+0xa0>
  8030ce:	0f bd ea             	bsr    %edx,%ebp
  8030d1:	83 f5 1f             	xor    $0x1f,%ebp
  8030d4:	75 5a                	jne    803130 <__umoddi3+0xb0>
  8030d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8030da:	0f 82 e0 00 00 00    	jb     8031c0 <__umoddi3+0x140>
  8030e0:	39 0c 24             	cmp    %ecx,(%esp)
  8030e3:	0f 86 d7 00 00 00    	jbe    8031c0 <__umoddi3+0x140>
  8030e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8030ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8030f1:	83 c4 1c             	add    $0x1c,%esp
  8030f4:	5b                   	pop    %ebx
  8030f5:	5e                   	pop    %esi
  8030f6:	5f                   	pop    %edi
  8030f7:	5d                   	pop    %ebp
  8030f8:	c3                   	ret    
  8030f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803100:	85 ff                	test   %edi,%edi
  803102:	89 fd                	mov    %edi,%ebp
  803104:	75 0b                	jne    803111 <__umoddi3+0x91>
  803106:	b8 01 00 00 00       	mov    $0x1,%eax
  80310b:	31 d2                	xor    %edx,%edx
  80310d:	f7 f7                	div    %edi
  80310f:	89 c5                	mov    %eax,%ebp
  803111:	89 f0                	mov    %esi,%eax
  803113:	31 d2                	xor    %edx,%edx
  803115:	f7 f5                	div    %ebp
  803117:	89 c8                	mov    %ecx,%eax
  803119:	f7 f5                	div    %ebp
  80311b:	89 d0                	mov    %edx,%eax
  80311d:	eb 99                	jmp    8030b8 <__umoddi3+0x38>
  80311f:	90                   	nop
  803120:	89 c8                	mov    %ecx,%eax
  803122:	89 f2                	mov    %esi,%edx
  803124:	83 c4 1c             	add    $0x1c,%esp
  803127:	5b                   	pop    %ebx
  803128:	5e                   	pop    %esi
  803129:	5f                   	pop    %edi
  80312a:	5d                   	pop    %ebp
  80312b:	c3                   	ret    
  80312c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803130:	8b 34 24             	mov    (%esp),%esi
  803133:	bf 20 00 00 00       	mov    $0x20,%edi
  803138:	89 e9                	mov    %ebp,%ecx
  80313a:	29 ef                	sub    %ebp,%edi
  80313c:	d3 e0                	shl    %cl,%eax
  80313e:	89 f9                	mov    %edi,%ecx
  803140:	89 f2                	mov    %esi,%edx
  803142:	d3 ea                	shr    %cl,%edx
  803144:	89 e9                	mov    %ebp,%ecx
  803146:	09 c2                	or     %eax,%edx
  803148:	89 d8                	mov    %ebx,%eax
  80314a:	89 14 24             	mov    %edx,(%esp)
  80314d:	89 f2                	mov    %esi,%edx
  80314f:	d3 e2                	shl    %cl,%edx
  803151:	89 f9                	mov    %edi,%ecx
  803153:	89 54 24 04          	mov    %edx,0x4(%esp)
  803157:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80315b:	d3 e8                	shr    %cl,%eax
  80315d:	89 e9                	mov    %ebp,%ecx
  80315f:	89 c6                	mov    %eax,%esi
  803161:	d3 e3                	shl    %cl,%ebx
  803163:	89 f9                	mov    %edi,%ecx
  803165:	89 d0                	mov    %edx,%eax
  803167:	d3 e8                	shr    %cl,%eax
  803169:	89 e9                	mov    %ebp,%ecx
  80316b:	09 d8                	or     %ebx,%eax
  80316d:	89 d3                	mov    %edx,%ebx
  80316f:	89 f2                	mov    %esi,%edx
  803171:	f7 34 24             	divl   (%esp)
  803174:	89 d6                	mov    %edx,%esi
  803176:	d3 e3                	shl    %cl,%ebx
  803178:	f7 64 24 04          	mull   0x4(%esp)
  80317c:	39 d6                	cmp    %edx,%esi
  80317e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803182:	89 d1                	mov    %edx,%ecx
  803184:	89 c3                	mov    %eax,%ebx
  803186:	72 08                	jb     803190 <__umoddi3+0x110>
  803188:	75 11                	jne    80319b <__umoddi3+0x11b>
  80318a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80318e:	73 0b                	jae    80319b <__umoddi3+0x11b>
  803190:	2b 44 24 04          	sub    0x4(%esp),%eax
  803194:	1b 14 24             	sbb    (%esp),%edx
  803197:	89 d1                	mov    %edx,%ecx
  803199:	89 c3                	mov    %eax,%ebx
  80319b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80319f:	29 da                	sub    %ebx,%edx
  8031a1:	19 ce                	sbb    %ecx,%esi
  8031a3:	89 f9                	mov    %edi,%ecx
  8031a5:	89 f0                	mov    %esi,%eax
  8031a7:	d3 e0                	shl    %cl,%eax
  8031a9:	89 e9                	mov    %ebp,%ecx
  8031ab:	d3 ea                	shr    %cl,%edx
  8031ad:	89 e9                	mov    %ebp,%ecx
  8031af:	d3 ee                	shr    %cl,%esi
  8031b1:	09 d0                	or     %edx,%eax
  8031b3:	89 f2                	mov    %esi,%edx
  8031b5:	83 c4 1c             	add    $0x1c,%esp
  8031b8:	5b                   	pop    %ebx
  8031b9:	5e                   	pop    %esi
  8031ba:	5f                   	pop    %edi
  8031bb:	5d                   	pop    %ebp
  8031bc:	c3                   	ret    
  8031bd:	8d 76 00             	lea    0x0(%esi),%esi
  8031c0:	29 f9                	sub    %edi,%ecx
  8031c2:	19 d6                	sbb    %edx,%esi
  8031c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8031cc:	e9 18 ff ff ff       	jmp    8030e9 <__umoddi3+0x69>
