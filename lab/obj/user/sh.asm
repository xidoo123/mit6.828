
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
  80005b:	68 a0 36 80 00       	push   $0x8036a0
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
  80007f:	68 af 36 80 00       	push   $0x8036af
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
  8000ab:	68 bd 36 80 00       	push   $0x8036bd
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
  8000d8:	68 c2 36 80 00       	push   $0x8036c2
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
  8000f6:	68 d3 36 80 00       	push   $0x8036d3
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
  800126:	68 c7 36 80 00       	push   $0x8036c7
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
  80014c:	68 cf 36 80 00       	push   $0x8036cf
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
  80017b:	68 db 36 80 00       	push   $0x8036db
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
  800273:	68 e5 36 80 00       	push   $0x8036e5
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
  8002a7:	68 24 38 80 00       	push   $0x803824
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
  8002c1:	e8 ed 1f 00 00       	call   8022b3 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 17                	jns    8002e6 <runcmd+0xdd>
				cprintf("open failed in input redirection\n");
  8002cf:	83 ec 0c             	sub    $0xc,%esp
  8002d2:	68 4c 38 80 00       	push   $0x80384c
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
  8002f4:	e8 50 1a 00 00       	call   801d49 <dup>
				close(fd);
  8002f9:	89 3c 24             	mov    %edi,(%esp)
  8002fc:	e8 f8 19 00 00       	call   801cf9 <close>
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
  80031f:	68 70 38 80 00       	push   $0x803870
  800324:	e8 c1 07 00 00       	call   800aea <cprintf>
				exit();
  800329:	e8 c9 06 00 00       	call   8009f7 <exit>
  80032e:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 01 03 00 00       	push   $0x301
  800339:	ff 75 a4             	pushl  -0x5c(%ebp)
  80033c:	e8 72 1f 00 00       	call   8022b3 <open>
  800341:	89 c7                	mov    %eax,%edi
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 19                	jns    800363 <runcmd+0x15a>
				cprintf("open %s for write: %e", t, fd);
  80034a:	83 ec 04             	sub    $0x4,%esp
  80034d:	50                   	push   %eax
  80034e:	ff 75 a4             	pushl  -0x5c(%ebp)
  800351:	68 f9 36 80 00       	push   $0x8036f9
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
  800372:	e8 d2 19 00 00       	call   801d49 <dup>
				close(fd);
  800377:	89 3c 24             	mov    %edi,(%esp)
  80037a:	e8 7a 19 00 00       	call   801cf9 <close>
  80037f:	83 c4 10             	add    $0x10,%esp
  800382:	e9 a3 fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800387:	83 ec 0c             	sub    $0xc,%esp
  80038a:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800390:	50                   	push   %eax
  800391:	e8 97 28 00 00       	call   802c2d <pipe>
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	85 c0                	test   %eax,%eax
  80039b:	79 16                	jns    8003b3 <runcmd+0x1aa>
				cprintf("pipe: %e", r);
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	50                   	push   %eax
  8003a1:	68 0f 37 80 00       	push   $0x80370f
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
  8003cb:	68 18 37 80 00       	push   $0x803718
  8003d0:	e8 15 07 00 00       	call   800aea <cprintf>
  8003d5:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003d8:	e8 71 14 00 00       	call   80184e <fork>
  8003dd:	89 c7                	mov    %eax,%edi
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	79 16                	jns    8003f9 <runcmd+0x1f0>
				cprintf("fork: %e", r);
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	50                   	push   %eax
  8003e7:	68 25 37 80 00       	push   $0x803725
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
  80040d:	e8 37 19 00 00       	call   801d49 <dup>
					close(p[0]);
  800412:	83 c4 04             	add    $0x4,%esp
  800415:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041b:	e8 d9 18 00 00       	call   801cf9 <close>
  800420:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800423:	83 ec 0c             	sub    $0xc,%esp
  800426:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80042c:	e8 c8 18 00 00       	call   801cf9 <close>
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
  80044a:	e8 fa 18 00 00       	call   801d49 <dup>
					close(p[1]);
  80044f:	83 c4 04             	add    $0x4,%esp
  800452:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800458:	e8 9c 18 00 00       	call   801cf9 <close>
  80045d:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800460:	83 ec 0c             	sub    $0xc,%esp
  800463:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800469:	e8 8b 18 00 00       	call   801cf9 <close>
				goto runit;
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb 17                	jmp    80048a <runcmd+0x281>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800473:	50                   	push   %eax
  800474:	68 2e 37 80 00       	push   $0x80372e
  800479:	6a 7b                	push   $0x7b
  80047b:	68 4a 37 80 00       	push   $0x80374a
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
  80049e:	68 54 37 80 00       	push   $0x803754
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
  8004f8:	68 63 37 80 00       	push   $0x803763
  8004fd:	e8 e8 05 00 00       	call   800aea <cprintf>
  800502:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	eb 11                	jmp    80051b <runcmd+0x312>
			cprintf(" %s", argv[i]);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	50                   	push   %eax
  80050e:	68 eb 37 80 00       	push   $0x8037eb
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
  800528:	68 c0 36 80 00       	push   $0x8036c0
  80052d:	e8 b8 05 00 00       	call   800aea <cprintf>
  800532:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053b:	50                   	push   %eax
  80053c:	ff 75 a8             	pushl  -0x58(%ebp)
  80053f:	e8 23 1f 00 00       	call   802467 <spawn>
  800544:	89 c3                	mov    %eax,%ebx
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 c0                	test   %eax,%eax
  80054b:	0f 89 c3 00 00 00    	jns    800614 <runcmd+0x40b>
		cprintf("spawn %s: %e\n", argv[0], r);
  800551:	83 ec 04             	sub    $0x4,%esp
  800554:	50                   	push   %eax
  800555:	ff 75 a8             	pushl  -0x58(%ebp)
  800558:	68 71 37 80 00       	push   $0x803771
  80055d:	e8 88 05 00 00       	call   800aea <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800562:	e8 bd 17 00 00       	call   801d24 <close_all>
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
  800579:	68 7f 37 80 00       	push   $0x80377f
  80057e:	e8 67 05 00 00       	call   800aea <cprintf>
  800583:	83 c4 10             	add    $0x10,%esp
		wait(r);
  800586:	83 ec 0c             	sub    $0xc,%esp
  800589:	53                   	push   %ebx
  80058a:	e8 24 28 00 00       	call   802db3 <wait>
		if (debug)
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800599:	0f 84 8c 00 00 00    	je     80062b <runcmd+0x422>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80059f:	a1 28 54 80 00       	mov    0x805428,%eax
  8005a4:	8b 40 48             	mov    0x48(%eax),%eax
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	50                   	push   %eax
  8005ab:	68 94 37 80 00       	push   $0x803794
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
  8005d2:	68 aa 37 80 00       	push   $0x8037aa
  8005d7:	e8 0e 05 00 00       	call   800aea <cprintf>
  8005dc:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	57                   	push   %edi
  8005e3:	e8 cb 27 00 00       	call   802db3 <wait>
		if (debug)
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f2:	74 19                	je     80060d <runcmd+0x404>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f4:	a1 28 54 80 00       	mov    0x805428,%eax
  8005f9:	8b 40 48             	mov    0x48(%eax),%eax
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	50                   	push   %eax
  800600:	68 94 37 80 00       	push   $0x803794
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
  800614:	e8 0b 17 00 00       	call   801d24 <close_all>
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
  80063f:	68 98 38 80 00       	push   $0x803898
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
  800668:	e8 98 13 00 00       	call   801a05 <argstart>
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
  8006b4:	e8 7c 13 00 00       	call   801a35 <argnext>
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
  8006d6:	e8 1e 16 00 00       	call   801cf9 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006db:	83 c4 08             	add    $0x8,%esp
  8006de:	6a 00                	push   $0x0
  8006e0:	ff 77 04             	pushl  0x4(%edi)
  8006e3:	e8 cb 1b 00 00       	call   8022b3 <open>
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	79 1b                	jns    80070a <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006ef:	83 ec 0c             	sub    $0xc,%esp
  8006f2:	50                   	push   %eax
  8006f3:	ff 77 04             	pushl  0x4(%edi)
  8006f6:	68 c7 37 80 00       	push   $0x8037c7
  8006fb:	68 2b 01 00 00       	push   $0x12b
  800700:	68 4a 37 80 00       	push   $0x80374a
  800705:	e8 07 03 00 00       	call   800a11 <_panic>
		assert(r == 0);
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 19                	je     800727 <umain+0xd4>
  80070e:	68 d3 37 80 00       	push   $0x8037d3
  800713:	68 da 37 80 00       	push   $0x8037da
  800718:	68 2c 01 00 00       	push   $0x12c
  80071d:	68 4a 37 80 00       	push   $0x80374a
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
  800742:	bf ef 37 80 00       	mov    $0x8037ef,%edi
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
  800768:	68 f2 37 80 00       	push   $0x8037f2
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
  800787:	68 fb 37 80 00       	push   $0x8037fb
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
  8007a3:	68 05 38 80 00       	push   $0x803805
  8007a8:	e8 a4 1c 00 00       	call   802451 <printf>
  8007ad:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b7:	74 10                	je     8007c9 <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007b9:	83 ec 0c             	sub    $0xc,%esp
  8007bc:	68 0b 38 80 00       	push   $0x80380b
  8007c1:	e8 24 03 00 00       	call   800aea <cprintf>
  8007c6:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007c9:	e8 80 10 00 00       	call   80184e <fork>
  8007ce:	89 c6                	mov    %eax,%esi
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	79 15                	jns    8007e9 <umain+0x196>
			panic("fork: %e", r);
  8007d4:	50                   	push   %eax
  8007d5:	68 25 37 80 00       	push   $0x803725
  8007da:	68 43 01 00 00       	push   $0x143
  8007df:	68 4a 37 80 00       	push   $0x80374a
  8007e4:	e8 28 02 00 00       	call   800a11 <_panic>
		if (debug)
  8007e9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f0:	74 11                	je     800803 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	50                   	push   %eax
  8007f6:	68 18 38 80 00       	push   $0x803818
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
  800821:	e8 8d 25 00 00       	call   802db3 <wait>
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
  80083e:	68 b9 38 80 00       	push   $0x8038b9
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
  80090e:	e8 22 15 00 00       	call   801e35 <read>
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
  800938:	e8 92 12 00 00       	call   801bcf <fd_lookup>
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
  800961:	e8 1a 12 00 00       	call   801b80 <fd_alloc>
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
  8009a3:	e8 b1 11 00 00       	call   801b59 <fd2num>
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
  8009fd:	e8 22 13 00 00       	call   801d24 <close_all>
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
  800a2f:	68 d0 38 80 00       	push   $0x8038d0
  800a34:	e8 b1 00 00 00       	call   800aea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a39:	83 c4 18             	add    $0x18,%esp
  800a3c:	53                   	push   %ebx
  800a3d:	ff 75 10             	pushl  0x10(%ebp)
  800a40:	e8 54 00 00 00       	call   800a99 <vcprintf>
	cprintf("\n");
  800a45:	c7 04 24 c0 36 80 00 	movl   $0x8036c0,(%esp)
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
  800b4d:	e8 be 28 00 00       	call   803410 <__udivdi3>
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
  800b90:	e8 ab 29 00 00       	call   803540 <__umoddi3>
  800b95:	83 c4 14             	add    $0x14,%esp
  800b98:	0f be 80 f3 38 80 00 	movsbl 0x8038f3(%eax),%eax
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
  800c94:	ff 24 85 40 3a 80 00 	jmp    *0x803a40(,%eax,4)
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
  800d58:	8b 14 85 a0 3b 80 00 	mov    0x803ba0(,%eax,4),%edx
  800d5f:	85 d2                	test   %edx,%edx
  800d61:	75 18                	jne    800d7b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d63:	50                   	push   %eax
  800d64:	68 0b 39 80 00       	push   $0x80390b
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
  800d7c:	68 ec 37 80 00       	push   $0x8037ec
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
  800da0:	b8 04 39 80 00       	mov    $0x803904,%eax
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
  80104a:	68 ec 37 80 00       	push   $0x8037ec
  80104f:	6a 01                	push   $0x1
  801051:	e8 e4 13 00 00       	call   80243a <fprintf>
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
  80108a:	68 ff 3b 80 00       	push   $0x803bff
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
  80150e:	68 0f 3c 80 00       	push   $0x803c0f
  801513:	6a 23                	push   $0x23
  801515:	68 2c 3c 80 00       	push   $0x803c2c
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
  80158f:	68 0f 3c 80 00       	push   $0x803c0f
  801594:	6a 23                	push   $0x23
  801596:	68 2c 3c 80 00       	push   $0x803c2c
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
  8015d1:	68 0f 3c 80 00       	push   $0x803c0f
  8015d6:	6a 23                	push   $0x23
  8015d8:	68 2c 3c 80 00       	push   $0x803c2c
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
  801613:	68 0f 3c 80 00       	push   $0x803c0f
  801618:	6a 23                	push   $0x23
  80161a:	68 2c 3c 80 00       	push   $0x803c2c
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
  801655:	68 0f 3c 80 00       	push   $0x803c0f
  80165a:	6a 23                	push   $0x23
  80165c:	68 2c 3c 80 00       	push   $0x803c2c
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
  801697:	68 0f 3c 80 00       	push   $0x803c0f
  80169c:	6a 23                	push   $0x23
  80169e:	68 2c 3c 80 00       	push   $0x803c2c
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
  8016d9:	68 0f 3c 80 00       	push   $0x803c0f
  8016de:	6a 23                	push   $0x23
  8016e0:	68 2c 3c 80 00       	push   $0x803c2c
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
  80173d:	68 0f 3c 80 00       	push   $0x803c0f
  801742:	6a 23                	push   $0x23
  801744:	68 2c 3c 80 00       	push   $0x803c2c
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

00801775 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80177d:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  80177f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801783:	75 25                	jne    8017aa <pgfault+0x35>
  801785:	89 d8                	mov    %ebx,%eax
  801787:	c1 e8 0c             	shr    $0xc,%eax
  80178a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801791:	f6 c4 08             	test   $0x8,%ah
  801794:	75 14                	jne    8017aa <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  801796:	83 ec 04             	sub    $0x4,%esp
  801799:	68 3c 3c 80 00       	push   $0x803c3c
  80179e:	6a 1e                	push   $0x1e
  8017a0:	68 d0 3c 80 00       	push   $0x803cd0
  8017a5:	e8 67 f2 ff ff       	call   800a11 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  8017aa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  8017b0:	e8 72 fd ff ff       	call   801527 <sys_getenvid>
  8017b5:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	6a 07                	push   $0x7
  8017bc:	68 00 f0 7f 00       	push   $0x7ff000
  8017c1:	50                   	push   %eax
  8017c2:	e8 9e fd ff ff       	call   801565 <sys_page_alloc>
	if (r < 0)
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	79 12                	jns    8017e0 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  8017ce:	50                   	push   %eax
  8017cf:	68 68 3c 80 00       	push   $0x803c68
  8017d4:	6a 33                	push   $0x33
  8017d6:	68 d0 3c 80 00       	push   $0x803cd0
  8017db:	e8 31 f2 ff ff       	call   800a11 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  8017e0:	83 ec 04             	sub    $0x4,%esp
  8017e3:	68 00 10 00 00       	push   $0x1000
  8017e8:	53                   	push   %ebx
  8017e9:	68 00 f0 7f 00       	push   $0x7ff000
  8017ee:	e8 69 fb ff ff       	call   80135c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  8017f3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8017fa:	53                   	push   %ebx
  8017fb:	56                   	push   %esi
  8017fc:	68 00 f0 7f 00       	push   $0x7ff000
  801801:	56                   	push   %esi
  801802:	e8 a1 fd ff ff       	call   8015a8 <sys_page_map>
	if (r < 0)
  801807:	83 c4 20             	add    $0x20,%esp
  80180a:	85 c0                	test   %eax,%eax
  80180c:	79 12                	jns    801820 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  80180e:	50                   	push   %eax
  80180f:	68 8c 3c 80 00       	push   $0x803c8c
  801814:	6a 3b                	push   $0x3b
  801816:	68 d0 3c 80 00       	push   $0x803cd0
  80181b:	e8 f1 f1 ff ff       	call   800a11 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	68 00 f0 7f 00       	push   $0x7ff000
  801828:	56                   	push   %esi
  801829:	e8 bc fd ff ff       	call   8015ea <sys_page_unmap>
	if (r < 0)
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	79 12                	jns    801847 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  801835:	50                   	push   %eax
  801836:	68 b0 3c 80 00       	push   $0x803cb0
  80183b:	6a 40                	push   $0x40
  80183d:	68 d0 3c 80 00       	push   $0x803cd0
  801842:	e8 ca f1 ff ff       	call   800a11 <_panic>
}
  801847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801857:	68 75 17 80 00       	push   $0x801775
  80185c:	e8 08 1a 00 00       	call   803269 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801861:	b8 07 00 00 00       	mov    $0x7,%eax
  801866:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	85 c0                	test   %eax,%eax
  80186d:	0f 88 64 01 00 00    	js     8019d7 <fork+0x189>
  801873:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801878:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80187d:	85 c0                	test   %eax,%eax
  80187f:	75 21                	jne    8018a2 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801881:	e8 a1 fc ff ff       	call   801527 <sys_getenvid>
  801886:	25 ff 03 00 00       	and    $0x3ff,%eax
  80188b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80188e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801893:	a3 28 54 80 00       	mov    %eax,0x805428
        return 0;
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	e9 3f 01 00 00       	jmp    8019e1 <fork+0x193>
  8018a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018a5:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8018a7:	89 d8                	mov    %ebx,%eax
  8018a9:	c1 e8 16             	shr    $0x16,%eax
  8018ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018b3:	a8 01                	test   $0x1,%al
  8018b5:	0f 84 bd 00 00 00    	je     801978 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  8018bb:	89 d8                	mov    %ebx,%eax
  8018bd:	c1 e8 0c             	shr    $0xc,%eax
  8018c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018c7:	f6 c2 01             	test   $0x1,%dl
  8018ca:	0f 84 a8 00 00 00    	je     801978 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  8018d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d7:	a8 04                	test   $0x4,%al
  8018d9:	0f 84 99 00 00 00    	je     801978 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  8018df:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8018e6:	f6 c4 04             	test   $0x4,%ah
  8018e9:	74 17                	je     801902 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	68 07 0e 00 00       	push   $0xe07
  8018f3:	53                   	push   %ebx
  8018f4:	57                   	push   %edi
  8018f5:	53                   	push   %ebx
  8018f6:	6a 00                	push   $0x0
  8018f8:	e8 ab fc ff ff       	call   8015a8 <sys_page_map>
  8018fd:	83 c4 20             	add    $0x20,%esp
  801900:	eb 76                	jmp    801978 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801902:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801909:	a8 02                	test   $0x2,%al
  80190b:	75 0c                	jne    801919 <fork+0xcb>
  80190d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801914:	f6 c4 08             	test   $0x8,%ah
  801917:	74 3f                	je     801958 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801919:	83 ec 0c             	sub    $0xc,%esp
  80191c:	68 05 08 00 00       	push   $0x805
  801921:	53                   	push   %ebx
  801922:	57                   	push   %edi
  801923:	53                   	push   %ebx
  801924:	6a 00                	push   $0x0
  801926:	e8 7d fc ff ff       	call   8015a8 <sys_page_map>
		if (r < 0)
  80192b:	83 c4 20             	add    $0x20,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	0f 88 a5 00 00 00    	js     8019db <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	68 05 08 00 00       	push   $0x805
  80193e:	53                   	push   %ebx
  80193f:	6a 00                	push   $0x0
  801941:	53                   	push   %ebx
  801942:	6a 00                	push   $0x0
  801944:	e8 5f fc ff ff       	call   8015a8 <sys_page_map>
  801949:	83 c4 20             	add    $0x20,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801953:	0f 4f c1             	cmovg  %ecx,%eax
  801956:	eb 1c                	jmp    801974 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	6a 05                	push   $0x5
  80195d:	53                   	push   %ebx
  80195e:	57                   	push   %edi
  80195f:	53                   	push   %ebx
  801960:	6a 00                	push   $0x0
  801962:	e8 41 fc ff ff       	call   8015a8 <sys_page_map>
  801967:	83 c4 20             	add    $0x20,%esp
  80196a:	85 c0                	test   %eax,%eax
  80196c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801971:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801974:	85 c0                	test   %eax,%eax
  801976:	78 67                	js     8019df <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801978:	83 c6 01             	add    $0x1,%esi
  80197b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801981:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801987:	0f 85 1a ff ff ff    	jne    8018a7 <fork+0x59>
  80198d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801990:	83 ec 04             	sub    $0x4,%esp
  801993:	6a 07                	push   $0x7
  801995:	68 00 f0 bf ee       	push   $0xeebff000
  80199a:	57                   	push   %edi
  80199b:	e8 c5 fb ff ff       	call   801565 <sys_page_alloc>
	if (r < 0)
  8019a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a3:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 38                	js     8019e1 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	68 b0 32 80 00       	push   $0x8032b0
  8019b1:	57                   	push   %edi
  8019b2:	e8 f9 fc ff ff       	call   8016b0 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8019b7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ba:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 21                	js     8019e1 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8019c0:	83 ec 08             	sub    $0x8,%esp
  8019c3:	6a 02                	push   $0x2
  8019c5:	57                   	push   %edi
  8019c6:	e8 61 fc ff ff       	call   80162c <sys_env_set_status>
	if (r < 0)
  8019cb:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	0f 48 f8             	cmovs  %eax,%edi
  8019d3:	89 fa                	mov    %edi,%edx
  8019d5:	eb 0a                	jmp    8019e1 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8019d7:	89 c2                	mov    %eax,%edx
  8019d9:	eb 06                	jmp    8019e1 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8019db:	89 c2                	mov    %eax,%edx
  8019dd:	eb 02                	jmp    8019e1 <fork+0x193>
  8019df:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8019e1:	89 d0                	mov    %edx,%eax
  8019e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e6:	5b                   	pop    %ebx
  8019e7:	5e                   	pop    %esi
  8019e8:	5f                   	pop    %edi
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <sfork>:

// Challenge!
int
sfork(void)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8019f1:	68 db 3c 80 00       	push   $0x803cdb
  8019f6:	68 c9 00 00 00       	push   $0xc9
  8019fb:	68 d0 3c 80 00       	push   $0x803cd0
  801a00:	e8 0c f0 ff ff       	call   800a11 <_panic>

00801a05 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	8b 55 08             	mov    0x8(%ebp),%edx
  801a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a0e:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a11:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a13:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a16:	83 3a 01             	cmpl   $0x1,(%edx)
  801a19:	7e 09                	jle    801a24 <argstart+0x1f>
  801a1b:	ba c1 36 80 00       	mov    $0x8036c1,%edx
  801a20:	85 c9                	test   %ecx,%ecx
  801a22:	75 05                	jne    801a29 <argstart+0x24>
  801a24:	ba 00 00 00 00       	mov    $0x0,%edx
  801a29:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a2c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <argnext>:

int
argnext(struct Argstate *args)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 04             	sub    $0x4,%esp
  801a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801a3f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801a46:	8b 43 08             	mov    0x8(%ebx),%eax
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	74 6f                	je     801abc <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801a4d:	80 38 00             	cmpb   $0x0,(%eax)
  801a50:	75 4e                	jne    801aa0 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801a52:	8b 0b                	mov    (%ebx),%ecx
  801a54:	83 39 01             	cmpl   $0x1,(%ecx)
  801a57:	74 55                	je     801aae <argnext+0x79>
		    || args->argv[1][0] != '-'
  801a59:	8b 53 04             	mov    0x4(%ebx),%edx
  801a5c:	8b 42 04             	mov    0x4(%edx),%eax
  801a5f:	80 38 2d             	cmpb   $0x2d,(%eax)
  801a62:	75 4a                	jne    801aae <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801a64:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801a68:	74 44                	je     801aae <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801a6a:	83 c0 01             	add    $0x1,%eax
  801a6d:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801a70:	83 ec 04             	sub    $0x4,%esp
  801a73:	8b 01                	mov    (%ecx),%eax
  801a75:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801a7c:	50                   	push   %eax
  801a7d:	8d 42 08             	lea    0x8(%edx),%eax
  801a80:	50                   	push   %eax
  801a81:	83 c2 04             	add    $0x4,%edx
  801a84:	52                   	push   %edx
  801a85:	e8 6a f8 ff ff       	call   8012f4 <memmove>
		(*args->argc)--;
  801a8a:	8b 03                	mov    (%ebx),%eax
  801a8c:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801a8f:	8b 43 08             	mov    0x8(%ebx),%eax
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	80 38 2d             	cmpb   $0x2d,(%eax)
  801a98:	75 06                	jne    801aa0 <argnext+0x6b>
  801a9a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801a9e:	74 0e                	je     801aae <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801aa0:	8b 53 08             	mov    0x8(%ebx),%edx
  801aa3:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801aa6:	83 c2 01             	add    $0x1,%edx
  801aa9:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801aac:	eb 13                	jmp    801ac1 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801aae:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801aba:	eb 05                	jmp    801ac1 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801abc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801ac1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 04             	sub    $0x4,%esp
  801acd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801ad0:	8b 43 08             	mov    0x8(%ebx),%eax
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	74 58                	je     801b2f <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801ad7:	80 38 00             	cmpb   $0x0,(%eax)
  801ada:	74 0c                	je     801ae8 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801adc:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801adf:	c7 43 08 c1 36 80 00 	movl   $0x8036c1,0x8(%ebx)
  801ae6:	eb 42                	jmp    801b2a <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801ae8:	8b 13                	mov    (%ebx),%edx
  801aea:	83 3a 01             	cmpl   $0x1,(%edx)
  801aed:	7e 2d                	jle    801b1c <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801aef:	8b 43 04             	mov    0x4(%ebx),%eax
  801af2:	8b 48 04             	mov    0x4(%eax),%ecx
  801af5:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801af8:	83 ec 04             	sub    $0x4,%esp
  801afb:	8b 12                	mov    (%edx),%edx
  801afd:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b04:	52                   	push   %edx
  801b05:	8d 50 08             	lea    0x8(%eax),%edx
  801b08:	52                   	push   %edx
  801b09:	83 c0 04             	add    $0x4,%eax
  801b0c:	50                   	push   %eax
  801b0d:	e8 e2 f7 ff ff       	call   8012f4 <memmove>
		(*args->argc)--;
  801b12:	8b 03                	mov    (%ebx),%eax
  801b14:	83 28 01             	subl   $0x1,(%eax)
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	eb 0e                	jmp    801b2a <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b1c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b23:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b2a:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b2d:	eb 05                	jmp    801b34 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 08             	sub    $0x8,%esp
  801b3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801b42:	8b 51 0c             	mov    0xc(%ecx),%edx
  801b45:	89 d0                	mov    %edx,%eax
  801b47:	85 d2                	test   %edx,%edx
  801b49:	75 0c                	jne    801b57 <argvalue+0x1e>
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	51                   	push   %ecx
  801b4f:	e8 72 ff ff ff       	call   801ac6 <argnextvalue>
  801b54:	83 c4 10             	add    $0x10,%esp
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5f:	05 00 00 00 30       	add    $0x30000000,%eax
  801b64:	c1 e8 0c             	shr    $0xc,%eax
}
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6f:	05 00 00 00 30       	add    $0x30000000,%eax
  801b74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801b79:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b86:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801b8b:	89 c2                	mov    %eax,%edx
  801b8d:	c1 ea 16             	shr    $0x16,%edx
  801b90:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b97:	f6 c2 01             	test   $0x1,%dl
  801b9a:	74 11                	je     801bad <fd_alloc+0x2d>
  801b9c:	89 c2                	mov    %eax,%edx
  801b9e:	c1 ea 0c             	shr    $0xc,%edx
  801ba1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ba8:	f6 c2 01             	test   $0x1,%dl
  801bab:	75 09                	jne    801bb6 <fd_alloc+0x36>
			*fd_store = fd;
  801bad:	89 01                	mov    %eax,(%ecx)
			return 0;
  801baf:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb4:	eb 17                	jmp    801bcd <fd_alloc+0x4d>
  801bb6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801bbb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801bc0:	75 c9                	jne    801b8b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801bc2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801bc8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801bd5:	83 f8 1f             	cmp    $0x1f,%eax
  801bd8:	77 36                	ja     801c10 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801bda:	c1 e0 0c             	shl    $0xc,%eax
  801bdd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801be2:	89 c2                	mov    %eax,%edx
  801be4:	c1 ea 16             	shr    $0x16,%edx
  801be7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bee:	f6 c2 01             	test   $0x1,%dl
  801bf1:	74 24                	je     801c17 <fd_lookup+0x48>
  801bf3:	89 c2                	mov    %eax,%edx
  801bf5:	c1 ea 0c             	shr    $0xc,%edx
  801bf8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bff:	f6 c2 01             	test   $0x1,%dl
  801c02:	74 1a                	je     801c1e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c07:	89 02                	mov    %eax,(%edx)
	return 0;
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0e:	eb 13                	jmp    801c23 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c15:	eb 0c                	jmp    801c23 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c1c:	eb 05                	jmp    801c23 <fd_lookup+0x54>
  801c1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 08             	sub    $0x8,%esp
  801c2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2e:	ba 70 3d 80 00       	mov    $0x803d70,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801c33:	eb 13                	jmp    801c48 <dev_lookup+0x23>
  801c35:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801c38:	39 08                	cmp    %ecx,(%eax)
  801c3a:	75 0c                	jne    801c48 <dev_lookup+0x23>
			*dev = devtab[i];
  801c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c41:	b8 00 00 00 00       	mov    $0x0,%eax
  801c46:	eb 2e                	jmp    801c76 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c48:	8b 02                	mov    (%edx),%eax
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	75 e7                	jne    801c35 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801c4e:	a1 28 54 80 00       	mov    0x805428,%eax
  801c53:	8b 40 48             	mov    0x48(%eax),%eax
  801c56:	83 ec 04             	sub    $0x4,%esp
  801c59:	51                   	push   %ecx
  801c5a:	50                   	push   %eax
  801c5b:	68 f4 3c 80 00       	push   $0x803cf4
  801c60:	e8 85 ee ff ff       	call   800aea <cprintf>
	*dev = 0;
  801c65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    

00801c78 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	56                   	push   %esi
  801c7c:	53                   	push   %ebx
  801c7d:	83 ec 10             	sub    $0x10,%esp
  801c80:	8b 75 08             	mov    0x8(%ebp),%esi
  801c83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801c86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c89:	50                   	push   %eax
  801c8a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801c90:	c1 e8 0c             	shr    $0xc,%eax
  801c93:	50                   	push   %eax
  801c94:	e8 36 ff ff ff       	call   801bcf <fd_lookup>
  801c99:	83 c4 08             	add    $0x8,%esp
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 05                	js     801ca5 <fd_close+0x2d>
	    || fd != fd2)
  801ca0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801ca3:	74 0c                	je     801cb1 <fd_close+0x39>
		return (must_exist ? r : 0);
  801ca5:	84 db                	test   %bl,%bl
  801ca7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cac:	0f 44 c2             	cmove  %edx,%eax
  801caf:	eb 41                	jmp    801cf2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801cb1:	83 ec 08             	sub    $0x8,%esp
  801cb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb7:	50                   	push   %eax
  801cb8:	ff 36                	pushl  (%esi)
  801cba:	e8 66 ff ff ff       	call   801c25 <dev_lookup>
  801cbf:	89 c3                	mov    %eax,%ebx
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 1a                	js     801ce2 <fd_close+0x6a>
		if (dev->dev_close)
  801cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ccb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801cce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	74 0b                	je     801ce2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801cd7:	83 ec 0c             	sub    $0xc,%esp
  801cda:	56                   	push   %esi
  801cdb:	ff d0                	call   *%eax
  801cdd:	89 c3                	mov    %eax,%ebx
  801cdf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ce2:	83 ec 08             	sub    $0x8,%esp
  801ce5:	56                   	push   %esi
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 fd f8 ff ff       	call   8015ea <sys_page_unmap>
	return r;
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	89 d8                	mov    %ebx,%eax
}
  801cf2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf5:	5b                   	pop    %ebx
  801cf6:	5e                   	pop    %esi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d02:	50                   	push   %eax
  801d03:	ff 75 08             	pushl  0x8(%ebp)
  801d06:	e8 c4 fe ff ff       	call   801bcf <fd_lookup>
  801d0b:	83 c4 08             	add    $0x8,%esp
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 10                	js     801d22 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d12:	83 ec 08             	sub    $0x8,%esp
  801d15:	6a 01                	push   $0x1
  801d17:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1a:	e8 59 ff ff ff       	call   801c78 <fd_close>
  801d1f:	83 c4 10             	add    $0x10,%esp
}
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    

00801d24 <close_all>:

void
close_all(void)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	53                   	push   %ebx
  801d28:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801d30:	83 ec 0c             	sub    $0xc,%esp
  801d33:	53                   	push   %ebx
  801d34:	e8 c0 ff ff ff       	call   801cf9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d39:	83 c3 01             	add    $0x1,%ebx
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	83 fb 20             	cmp    $0x20,%ebx
  801d42:	75 ec                	jne    801d30 <close_all+0xc>
		close(i);
}
  801d44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    

00801d49 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 2c             	sub    $0x2c,%esp
  801d52:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d55:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d58:	50                   	push   %eax
  801d59:	ff 75 08             	pushl  0x8(%ebp)
  801d5c:	e8 6e fe ff ff       	call   801bcf <fd_lookup>
  801d61:	83 c4 08             	add    $0x8,%esp
  801d64:	85 c0                	test   %eax,%eax
  801d66:	0f 88 c1 00 00 00    	js     801e2d <dup+0xe4>
		return r;
	close(newfdnum);
  801d6c:	83 ec 0c             	sub    $0xc,%esp
  801d6f:	56                   	push   %esi
  801d70:	e8 84 ff ff ff       	call   801cf9 <close>

	newfd = INDEX2FD(newfdnum);
  801d75:	89 f3                	mov    %esi,%ebx
  801d77:	c1 e3 0c             	shl    $0xc,%ebx
  801d7a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801d80:	83 c4 04             	add    $0x4,%esp
  801d83:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d86:	e8 de fd ff ff       	call   801b69 <fd2data>
  801d8b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801d8d:	89 1c 24             	mov    %ebx,(%esp)
  801d90:	e8 d4 fd ff ff       	call   801b69 <fd2data>
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801d9b:	89 f8                	mov    %edi,%eax
  801d9d:	c1 e8 16             	shr    $0x16,%eax
  801da0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801da7:	a8 01                	test   $0x1,%al
  801da9:	74 37                	je     801de2 <dup+0x99>
  801dab:	89 f8                	mov    %edi,%eax
  801dad:	c1 e8 0c             	shr    $0xc,%eax
  801db0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801db7:	f6 c2 01             	test   $0x1,%dl
  801dba:	74 26                	je     801de2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801dbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dc3:	83 ec 0c             	sub    $0xc,%esp
  801dc6:	25 07 0e 00 00       	and    $0xe07,%eax
  801dcb:	50                   	push   %eax
  801dcc:	ff 75 d4             	pushl  -0x2c(%ebp)
  801dcf:	6a 00                	push   $0x0
  801dd1:	57                   	push   %edi
  801dd2:	6a 00                	push   $0x0
  801dd4:	e8 cf f7 ff ff       	call   8015a8 <sys_page_map>
  801dd9:	89 c7                	mov    %eax,%edi
  801ddb:	83 c4 20             	add    $0x20,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 2e                	js     801e10 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801de2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	c1 e8 0c             	shr    $0xc,%eax
  801dea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801df1:	83 ec 0c             	sub    $0xc,%esp
  801df4:	25 07 0e 00 00       	and    $0xe07,%eax
  801df9:	50                   	push   %eax
  801dfa:	53                   	push   %ebx
  801dfb:	6a 00                	push   $0x0
  801dfd:	52                   	push   %edx
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 a3 f7 ff ff       	call   8015a8 <sys_page_map>
  801e05:	89 c7                	mov    %eax,%edi
  801e07:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e0a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e0c:	85 ff                	test   %edi,%edi
  801e0e:	79 1d                	jns    801e2d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e10:	83 ec 08             	sub    $0x8,%esp
  801e13:	53                   	push   %ebx
  801e14:	6a 00                	push   $0x0
  801e16:	e8 cf f7 ff ff       	call   8015ea <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e1b:	83 c4 08             	add    $0x8,%esp
  801e1e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e21:	6a 00                	push   $0x0
  801e23:	e8 c2 f7 ff ff       	call   8015ea <sys_page_unmap>
	return r;
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	89 f8                	mov    %edi,%eax
}
  801e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e30:	5b                   	pop    %ebx
  801e31:	5e                   	pop    %esi
  801e32:	5f                   	pop    %edi
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    

00801e35 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	53                   	push   %ebx
  801e39:	83 ec 14             	sub    $0x14,%esp
  801e3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e42:	50                   	push   %eax
  801e43:	53                   	push   %ebx
  801e44:	e8 86 fd ff ff       	call   801bcf <fd_lookup>
  801e49:	83 c4 08             	add    $0x8,%esp
  801e4c:	89 c2                	mov    %eax,%edx
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 6d                	js     801ebf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e52:	83 ec 08             	sub    $0x8,%esp
  801e55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e58:	50                   	push   %eax
  801e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e5c:	ff 30                	pushl  (%eax)
  801e5e:	e8 c2 fd ff ff       	call   801c25 <dev_lookup>
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	85 c0                	test   %eax,%eax
  801e68:	78 4c                	js     801eb6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801e6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e6d:	8b 42 08             	mov    0x8(%edx),%eax
  801e70:	83 e0 03             	and    $0x3,%eax
  801e73:	83 f8 01             	cmp    $0x1,%eax
  801e76:	75 21                	jne    801e99 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801e78:	a1 28 54 80 00       	mov    0x805428,%eax
  801e7d:	8b 40 48             	mov    0x48(%eax),%eax
  801e80:	83 ec 04             	sub    $0x4,%esp
  801e83:	53                   	push   %ebx
  801e84:	50                   	push   %eax
  801e85:	68 35 3d 80 00       	push   $0x803d35
  801e8a:	e8 5b ec ff ff       	call   800aea <cprintf>
		return -E_INVAL;
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801e97:	eb 26                	jmp    801ebf <read+0x8a>
	}
	if (!dev->dev_read)
  801e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9c:	8b 40 08             	mov    0x8(%eax),%eax
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	74 17                	je     801eba <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ea3:	83 ec 04             	sub    $0x4,%esp
  801ea6:	ff 75 10             	pushl  0x10(%ebp)
  801ea9:	ff 75 0c             	pushl  0xc(%ebp)
  801eac:	52                   	push   %edx
  801ead:	ff d0                	call   *%eax
  801eaf:	89 c2                	mov    %eax,%edx
  801eb1:	83 c4 10             	add    $0x10,%esp
  801eb4:	eb 09                	jmp    801ebf <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801eb6:	89 c2                	mov    %eax,%edx
  801eb8:	eb 05                	jmp    801ebf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801eba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801ebf:	89 d0                	mov    %edx,%eax
  801ec1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec4:	c9                   	leave  
  801ec5:	c3                   	ret    

00801ec6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	57                   	push   %edi
  801eca:	56                   	push   %esi
  801ecb:	53                   	push   %ebx
  801ecc:	83 ec 0c             	sub    $0xc,%esp
  801ecf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ed5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eda:	eb 21                	jmp    801efd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801edc:	83 ec 04             	sub    $0x4,%esp
  801edf:	89 f0                	mov    %esi,%eax
  801ee1:	29 d8                	sub    %ebx,%eax
  801ee3:	50                   	push   %eax
  801ee4:	89 d8                	mov    %ebx,%eax
  801ee6:	03 45 0c             	add    0xc(%ebp),%eax
  801ee9:	50                   	push   %eax
  801eea:	57                   	push   %edi
  801eeb:	e8 45 ff ff ff       	call   801e35 <read>
		if (m < 0)
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	78 10                	js     801f07 <readn+0x41>
			return m;
		if (m == 0)
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	74 0a                	je     801f05 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801efb:	01 c3                	add    %eax,%ebx
  801efd:	39 f3                	cmp    %esi,%ebx
  801eff:	72 db                	jb     801edc <readn+0x16>
  801f01:	89 d8                	mov    %ebx,%eax
  801f03:	eb 02                	jmp    801f07 <readn+0x41>
  801f05:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5f                   	pop    %edi
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	53                   	push   %ebx
  801f13:	83 ec 14             	sub    $0x14,%esp
  801f16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	53                   	push   %ebx
  801f1e:	e8 ac fc ff ff       	call   801bcf <fd_lookup>
  801f23:	83 c4 08             	add    $0x8,%esp
  801f26:	89 c2                	mov    %eax,%edx
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 68                	js     801f94 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f2c:	83 ec 08             	sub    $0x8,%esp
  801f2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f32:	50                   	push   %eax
  801f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f36:	ff 30                	pushl  (%eax)
  801f38:	e8 e8 fc ff ff       	call   801c25 <dev_lookup>
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 47                	js     801f8b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f47:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f4b:	75 21                	jne    801f6e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801f4d:	a1 28 54 80 00       	mov    0x805428,%eax
  801f52:	8b 40 48             	mov    0x48(%eax),%eax
  801f55:	83 ec 04             	sub    $0x4,%esp
  801f58:	53                   	push   %ebx
  801f59:	50                   	push   %eax
  801f5a:	68 51 3d 80 00       	push   $0x803d51
  801f5f:	e8 86 eb ff ff       	call   800aea <cprintf>
		return -E_INVAL;
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f6c:	eb 26                	jmp    801f94 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801f6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f71:	8b 52 0c             	mov    0xc(%edx),%edx
  801f74:	85 d2                	test   %edx,%edx
  801f76:	74 17                	je     801f8f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801f78:	83 ec 04             	sub    $0x4,%esp
  801f7b:	ff 75 10             	pushl  0x10(%ebp)
  801f7e:	ff 75 0c             	pushl  0xc(%ebp)
  801f81:	50                   	push   %eax
  801f82:	ff d2                	call   *%edx
  801f84:	89 c2                	mov    %eax,%edx
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	eb 09                	jmp    801f94 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f8b:	89 c2                	mov    %eax,%edx
  801f8d:	eb 05                	jmp    801f94 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801f8f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801f94:	89 d0                	mov    %edx,%eax
  801f96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <seek>:

int
seek(int fdnum, off_t offset)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801fa4:	50                   	push   %eax
  801fa5:	ff 75 08             	pushl  0x8(%ebp)
  801fa8:	e8 22 fc ff ff       	call   801bcf <fd_lookup>
  801fad:	83 c4 08             	add    $0x8,%esp
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 0e                	js     801fc2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801fb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801fbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    

00801fc4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	53                   	push   %ebx
  801fc8:	83 ec 14             	sub    $0x14,%esp
  801fcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fd1:	50                   	push   %eax
  801fd2:	53                   	push   %ebx
  801fd3:	e8 f7 fb ff ff       	call   801bcf <fd_lookup>
  801fd8:	83 c4 08             	add    $0x8,%esp
  801fdb:	89 c2                	mov    %eax,%edx
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	78 65                	js     802046 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fe1:	83 ec 08             	sub    $0x8,%esp
  801fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe7:	50                   	push   %eax
  801fe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801feb:	ff 30                	pushl  (%eax)
  801fed:	e8 33 fc ff ff       	call   801c25 <dev_lookup>
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	78 44                	js     80203d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ff9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ffc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802000:	75 21                	jne    802023 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802002:	a1 28 54 80 00       	mov    0x805428,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802007:	8b 40 48             	mov    0x48(%eax),%eax
  80200a:	83 ec 04             	sub    $0x4,%esp
  80200d:	53                   	push   %ebx
  80200e:	50                   	push   %eax
  80200f:	68 14 3d 80 00       	push   $0x803d14
  802014:	e8 d1 ea ff ff       	call   800aea <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802021:	eb 23                	jmp    802046 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802023:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802026:	8b 52 18             	mov    0x18(%edx),%edx
  802029:	85 d2                	test   %edx,%edx
  80202b:	74 14                	je     802041 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80202d:	83 ec 08             	sub    $0x8,%esp
  802030:	ff 75 0c             	pushl  0xc(%ebp)
  802033:	50                   	push   %eax
  802034:	ff d2                	call   *%edx
  802036:	89 c2                	mov    %eax,%edx
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	eb 09                	jmp    802046 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80203d:	89 c2                	mov    %eax,%edx
  80203f:	eb 05                	jmp    802046 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802041:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802046:	89 d0                	mov    %edx,%eax
  802048:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80204b:	c9                   	leave  
  80204c:	c3                   	ret    

0080204d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	53                   	push   %ebx
  802051:	83 ec 14             	sub    $0x14,%esp
  802054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802057:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80205a:	50                   	push   %eax
  80205b:	ff 75 08             	pushl  0x8(%ebp)
  80205e:	e8 6c fb ff ff       	call   801bcf <fd_lookup>
  802063:	83 c4 08             	add    $0x8,%esp
  802066:	89 c2                	mov    %eax,%edx
  802068:	85 c0                	test   %eax,%eax
  80206a:	78 58                	js     8020c4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80206c:	83 ec 08             	sub    $0x8,%esp
  80206f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802072:	50                   	push   %eax
  802073:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802076:	ff 30                	pushl  (%eax)
  802078:	e8 a8 fb ff ff       	call   801c25 <dev_lookup>
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	85 c0                	test   %eax,%eax
  802082:	78 37                	js     8020bb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802084:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802087:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80208b:	74 32                	je     8020bf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80208d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802090:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802097:	00 00 00 
	stat->st_isdir = 0;
  80209a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020a1:	00 00 00 
	stat->st_dev = dev;
  8020a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8020aa:	83 ec 08             	sub    $0x8,%esp
  8020ad:	53                   	push   %ebx
  8020ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b1:	ff 50 14             	call   *0x14(%eax)
  8020b4:	89 c2                	mov    %eax,%edx
  8020b6:	83 c4 10             	add    $0x10,%esp
  8020b9:	eb 09                	jmp    8020c4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020bb:	89 c2                	mov    %eax,%edx
  8020bd:	eb 05                	jmp    8020c4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8020bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8020c4:	89 d0                	mov    %edx,%eax
  8020c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020c9:	c9                   	leave  
  8020ca:	c3                   	ret    

008020cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	56                   	push   %esi
  8020cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8020d0:	83 ec 08             	sub    $0x8,%esp
  8020d3:	6a 00                	push   $0x0
  8020d5:	ff 75 08             	pushl  0x8(%ebp)
  8020d8:	e8 d6 01 00 00       	call   8022b3 <open>
  8020dd:	89 c3                	mov    %eax,%ebx
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	78 1b                	js     802101 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8020e6:	83 ec 08             	sub    $0x8,%esp
  8020e9:	ff 75 0c             	pushl  0xc(%ebp)
  8020ec:	50                   	push   %eax
  8020ed:	e8 5b ff ff ff       	call   80204d <fstat>
  8020f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8020f4:	89 1c 24             	mov    %ebx,(%esp)
  8020f7:	e8 fd fb ff ff       	call   801cf9 <close>
	return r;
  8020fc:	83 c4 10             	add    $0x10,%esp
  8020ff:	89 f0                	mov    %esi,%eax
}
  802101:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    

00802108 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	56                   	push   %esi
  80210c:	53                   	push   %ebx
  80210d:	89 c6                	mov    %eax,%esi
  80210f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802111:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802118:	75 12                	jne    80212c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80211a:	83 ec 0c             	sub    $0xc,%esp
  80211d:	6a 01                	push   $0x1
  80211f:	e8 6b 12 00 00       	call   80338f <ipc_find_env>
  802124:	a3 20 54 80 00       	mov    %eax,0x805420
  802129:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80212c:	6a 07                	push   $0x7
  80212e:	68 00 60 80 00       	push   $0x806000
  802133:	56                   	push   %esi
  802134:	ff 35 20 54 80 00    	pushl  0x805420
  80213a:	e8 fc 11 00 00       	call   80333b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80213f:	83 c4 0c             	add    $0xc,%esp
  802142:	6a 00                	push   $0x0
  802144:	53                   	push   %ebx
  802145:	6a 00                	push   $0x0
  802147:	e8 88 11 00 00       	call   8032d4 <ipc_recv>
}
  80214c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    

00802153 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
  80215c:	8b 40 0c             	mov    0xc(%eax),%eax
  80215f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802164:	8b 45 0c             	mov    0xc(%ebp),%eax
  802167:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80216c:	ba 00 00 00 00       	mov    $0x0,%edx
  802171:	b8 02 00 00 00       	mov    $0x2,%eax
  802176:	e8 8d ff ff ff       	call   802108 <fsipc>
}
  80217b:	c9                   	leave  
  80217c:	c3                   	ret    

0080217d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80217d:	55                   	push   %ebp
  80217e:	89 e5                	mov    %esp,%ebp
  802180:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802183:	8b 45 08             	mov    0x8(%ebp),%eax
  802186:	8b 40 0c             	mov    0xc(%eax),%eax
  802189:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80218e:	ba 00 00 00 00       	mov    $0x0,%edx
  802193:	b8 06 00 00 00       	mov    $0x6,%eax
  802198:	e8 6b ff ff ff       	call   802108 <fsipc>
}
  80219d:	c9                   	leave  
  80219e:	c3                   	ret    

0080219f <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80219f:	55                   	push   %ebp
  8021a0:	89 e5                	mov    %esp,%ebp
  8021a2:	53                   	push   %ebx
  8021a3:	83 ec 04             	sub    $0x4,%esp
  8021a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8021af:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8021b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8021b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8021be:	e8 45 ff ff ff       	call   802108 <fsipc>
  8021c3:	85 c0                	test   %eax,%eax
  8021c5:	78 2c                	js     8021f3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8021c7:	83 ec 08             	sub    $0x8,%esp
  8021ca:	68 00 60 80 00       	push   $0x806000
  8021cf:	53                   	push   %ebx
  8021d0:	e8 8d ef ff ff       	call   801162 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8021d5:	a1 80 60 80 00       	mov    0x806080,%eax
  8021da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8021e0:	a1 84 60 80 00       	mov    0x806084,%eax
  8021e5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8021eb:	83 c4 10             	add    $0x10,%esp
  8021ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021f6:	c9                   	leave  
  8021f7:	c3                   	ret    

008021f8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	83 ec 0c             	sub    $0xc,%esp
  8021fe:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802201:	8b 55 08             	mov    0x8(%ebp),%edx
  802204:	8b 52 0c             	mov    0xc(%edx),%edx
  802207:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  80220d:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802212:	50                   	push   %eax
  802213:	ff 75 0c             	pushl  0xc(%ebp)
  802216:	68 08 60 80 00       	push   $0x806008
  80221b:	e8 d4 f0 ff ff       	call   8012f4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  802220:	ba 00 00 00 00       	mov    $0x0,%edx
  802225:	b8 04 00 00 00       	mov    $0x4,%eax
  80222a:	e8 d9 fe ff ff       	call   802108 <fsipc>

}
  80222f:	c9                   	leave  
  802230:	c3                   	ret    

00802231 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	56                   	push   %esi
  802235:	53                   	push   %ebx
  802236:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802239:	8b 45 08             	mov    0x8(%ebp),%eax
  80223c:	8b 40 0c             	mov    0xc(%eax),%eax
  80223f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802244:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80224a:	ba 00 00 00 00       	mov    $0x0,%edx
  80224f:	b8 03 00 00 00       	mov    $0x3,%eax
  802254:	e8 af fe ff ff       	call   802108 <fsipc>
  802259:	89 c3                	mov    %eax,%ebx
  80225b:	85 c0                	test   %eax,%eax
  80225d:	78 4b                	js     8022aa <devfile_read+0x79>
		return r;
	assert(r <= n);
  80225f:	39 c6                	cmp    %eax,%esi
  802261:	73 16                	jae    802279 <devfile_read+0x48>
  802263:	68 84 3d 80 00       	push   $0x803d84
  802268:	68 da 37 80 00       	push   $0x8037da
  80226d:	6a 7c                	push   $0x7c
  80226f:	68 8b 3d 80 00       	push   $0x803d8b
  802274:	e8 98 e7 ff ff       	call   800a11 <_panic>
	assert(r <= PGSIZE);
  802279:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80227e:	7e 16                	jle    802296 <devfile_read+0x65>
  802280:	68 96 3d 80 00       	push   $0x803d96
  802285:	68 da 37 80 00       	push   $0x8037da
  80228a:	6a 7d                	push   $0x7d
  80228c:	68 8b 3d 80 00       	push   $0x803d8b
  802291:	e8 7b e7 ff ff       	call   800a11 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802296:	83 ec 04             	sub    $0x4,%esp
  802299:	50                   	push   %eax
  80229a:	68 00 60 80 00       	push   $0x806000
  80229f:	ff 75 0c             	pushl  0xc(%ebp)
  8022a2:	e8 4d f0 ff ff       	call   8012f4 <memmove>
	return r;
  8022a7:	83 c4 10             	add    $0x10,%esp
}
  8022aa:	89 d8                	mov    %ebx,%eax
  8022ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022af:	5b                   	pop    %ebx
  8022b0:	5e                   	pop    %esi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    

008022b3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	53                   	push   %ebx
  8022b7:	83 ec 20             	sub    $0x20,%esp
  8022ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8022bd:	53                   	push   %ebx
  8022be:	e8 66 ee ff ff       	call   801129 <strlen>
  8022c3:	83 c4 10             	add    $0x10,%esp
  8022c6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8022cb:	7f 67                	jg     802334 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8022cd:	83 ec 0c             	sub    $0xc,%esp
  8022d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d3:	50                   	push   %eax
  8022d4:	e8 a7 f8 ff ff       	call   801b80 <fd_alloc>
  8022d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8022dc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8022de:	85 c0                	test   %eax,%eax
  8022e0:	78 57                	js     802339 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8022e2:	83 ec 08             	sub    $0x8,%esp
  8022e5:	53                   	push   %ebx
  8022e6:	68 00 60 80 00       	push   $0x806000
  8022eb:	e8 72 ee ff ff       	call   801162 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8022f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f3:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8022f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022fb:	b8 01 00 00 00       	mov    $0x1,%eax
  802300:	e8 03 fe ff ff       	call   802108 <fsipc>
  802305:	89 c3                	mov    %eax,%ebx
  802307:	83 c4 10             	add    $0x10,%esp
  80230a:	85 c0                	test   %eax,%eax
  80230c:	79 14                	jns    802322 <open+0x6f>
		fd_close(fd, 0);
  80230e:	83 ec 08             	sub    $0x8,%esp
  802311:	6a 00                	push   $0x0
  802313:	ff 75 f4             	pushl  -0xc(%ebp)
  802316:	e8 5d f9 ff ff       	call   801c78 <fd_close>
		return r;
  80231b:	83 c4 10             	add    $0x10,%esp
  80231e:	89 da                	mov    %ebx,%edx
  802320:	eb 17                	jmp    802339 <open+0x86>
	}

	return fd2num(fd);
  802322:	83 ec 0c             	sub    $0xc,%esp
  802325:	ff 75 f4             	pushl  -0xc(%ebp)
  802328:	e8 2c f8 ff ff       	call   801b59 <fd2num>
  80232d:	89 c2                	mov    %eax,%edx
  80232f:	83 c4 10             	add    $0x10,%esp
  802332:	eb 05                	jmp    802339 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802334:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802339:	89 d0                	mov    %edx,%eax
  80233b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80233e:	c9                   	leave  
  80233f:	c3                   	ret    

00802340 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802346:	ba 00 00 00 00       	mov    $0x0,%edx
  80234b:	b8 08 00 00 00       	mov    $0x8,%eax
  802350:	e8 b3 fd ff ff       	call   802108 <fsipc>
}
  802355:	c9                   	leave  
  802356:	c3                   	ret    

00802357 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802357:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80235b:	7e 37                	jle    802394 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80235d:	55                   	push   %ebp
  80235e:	89 e5                	mov    %esp,%ebp
  802360:	53                   	push   %ebx
  802361:	83 ec 08             	sub    $0x8,%esp
  802364:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802366:	ff 70 04             	pushl  0x4(%eax)
  802369:	8d 40 10             	lea    0x10(%eax),%eax
  80236c:	50                   	push   %eax
  80236d:	ff 33                	pushl  (%ebx)
  80236f:	e8 9b fb ff ff       	call   801f0f <write>
		if (result > 0)
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	85 c0                	test   %eax,%eax
  802379:	7e 03                	jle    80237e <writebuf+0x27>
			b->result += result;
  80237b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80237e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802381:	74 0d                	je     802390 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802383:	85 c0                	test   %eax,%eax
  802385:	ba 00 00 00 00       	mov    $0x0,%edx
  80238a:	0f 4f c2             	cmovg  %edx,%eax
  80238d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802390:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802393:	c9                   	leave  
  802394:	f3 c3                	repz ret 

00802396 <putch>:

static void
putch(int ch, void *thunk)
{
  802396:	55                   	push   %ebp
  802397:	89 e5                	mov    %esp,%ebp
  802399:	53                   	push   %ebx
  80239a:	83 ec 04             	sub    $0x4,%esp
  80239d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8023a0:	8b 53 04             	mov    0x4(%ebx),%edx
  8023a3:	8d 42 01             	lea    0x1(%edx),%eax
  8023a6:	89 43 04             	mov    %eax,0x4(%ebx)
  8023a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ac:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8023b0:	3d 00 01 00 00       	cmp    $0x100,%eax
  8023b5:	75 0e                	jne    8023c5 <putch+0x2f>
		writebuf(b);
  8023b7:	89 d8                	mov    %ebx,%eax
  8023b9:	e8 99 ff ff ff       	call   802357 <writebuf>
		b->idx = 0;
  8023be:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8023c5:	83 c4 04             	add    $0x4,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5d                   	pop    %ebp
  8023ca:	c3                   	ret    

008023cb <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8023d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d7:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8023dd:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8023e4:	00 00 00 
	b.result = 0;
  8023e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8023ee:	00 00 00 
	b.error = 1;
  8023f1:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8023f8:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8023fb:	ff 75 10             	pushl  0x10(%ebp)
  8023fe:	ff 75 0c             	pushl  0xc(%ebp)
  802401:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802407:	50                   	push   %eax
  802408:	68 96 23 80 00       	push   $0x802396
  80240d:	e8 0f e8 ff ff       	call   800c21 <vprintfmt>
	if (b.idx > 0)
  802412:	83 c4 10             	add    $0x10,%esp
  802415:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80241c:	7e 0b                	jle    802429 <vfprintf+0x5e>
		writebuf(&b);
  80241e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802424:	e8 2e ff ff ff       	call   802357 <writebuf>

	return (b.result ? b.result : b.error);
  802429:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80242f:	85 c0                	test   %eax,%eax
  802431:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802438:	c9                   	leave  
  802439:	c3                   	ret    

0080243a <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80243a:	55                   	push   %ebp
  80243b:	89 e5                	mov    %esp,%ebp
  80243d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802440:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802443:	50                   	push   %eax
  802444:	ff 75 0c             	pushl  0xc(%ebp)
  802447:	ff 75 08             	pushl  0x8(%ebp)
  80244a:	e8 7c ff ff ff       	call   8023cb <vfprintf>
	va_end(ap);

	return cnt;
}
  80244f:	c9                   	leave  
  802450:	c3                   	ret    

00802451 <printf>:

int
printf(const char *fmt, ...)
{
  802451:	55                   	push   %ebp
  802452:	89 e5                	mov    %esp,%ebp
  802454:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802457:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80245a:	50                   	push   %eax
  80245b:	ff 75 08             	pushl  0x8(%ebp)
  80245e:	6a 01                	push   $0x1
  802460:	e8 66 ff ff ff       	call   8023cb <vfprintf>
	va_end(ap);

	return cnt;
}
  802465:	c9                   	leave  
  802466:	c3                   	ret    

00802467 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802467:	55                   	push   %ebp
  802468:	89 e5                	mov    %esp,%ebp
  80246a:	57                   	push   %edi
  80246b:	56                   	push   %esi
  80246c:	53                   	push   %ebx
  80246d:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802473:	6a 00                	push   $0x0
  802475:	ff 75 08             	pushl  0x8(%ebp)
  802478:	e8 36 fe ff ff       	call   8022b3 <open>
  80247d:	89 c7                	mov    %eax,%edi
  80247f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802485:	83 c4 10             	add    $0x10,%esp
  802488:	85 c0                	test   %eax,%eax
  80248a:	0f 88 97 04 00 00    	js     802927 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802490:	83 ec 04             	sub    $0x4,%esp
  802493:	68 00 02 00 00       	push   $0x200
  802498:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80249e:	50                   	push   %eax
  80249f:	57                   	push   %edi
  8024a0:	e8 21 fa ff ff       	call   801ec6 <readn>
  8024a5:	83 c4 10             	add    $0x10,%esp
  8024a8:	3d 00 02 00 00       	cmp    $0x200,%eax
  8024ad:	75 0c                	jne    8024bb <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8024af:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8024b6:	45 4c 46 
  8024b9:	74 33                	je     8024ee <spawn+0x87>
		close(fd);
  8024bb:	83 ec 0c             	sub    $0xc,%esp
  8024be:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8024c4:	e8 30 f8 ff ff       	call   801cf9 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8024c9:	83 c4 0c             	add    $0xc,%esp
  8024cc:	68 7f 45 4c 46       	push   $0x464c457f
  8024d1:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8024d7:	68 a2 3d 80 00       	push   $0x803da2
  8024dc:	e8 09 e6 ff ff       	call   800aea <cprintf>
		return -E_NOT_EXEC;
  8024e1:	83 c4 10             	add    $0x10,%esp
  8024e4:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8024e9:	e9 ec 04 00 00       	jmp    8029da <spawn+0x573>
  8024ee:	b8 07 00 00 00       	mov    $0x7,%eax
  8024f3:	cd 30                	int    $0x30
  8024f5:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8024fb:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802501:	85 c0                	test   %eax,%eax
  802503:	0f 88 29 04 00 00    	js     802932 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802509:	89 c6                	mov    %eax,%esi
  80250b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802511:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802514:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80251a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802520:	b9 11 00 00 00       	mov    $0x11,%ecx
  802525:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802527:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80252d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802533:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802538:	be 00 00 00 00       	mov    $0x0,%esi
  80253d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802540:	eb 13                	jmp    802555 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802542:	83 ec 0c             	sub    $0xc,%esp
  802545:	50                   	push   %eax
  802546:	e8 de eb ff ff       	call   801129 <strlen>
  80254b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80254f:	83 c3 01             	add    $0x1,%ebx
  802552:	83 c4 10             	add    $0x10,%esp
  802555:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80255c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80255f:	85 c0                	test   %eax,%eax
  802561:	75 df                	jne    802542 <spawn+0xdb>
  802563:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802569:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80256f:	bf 00 10 40 00       	mov    $0x401000,%edi
  802574:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802576:	89 fa                	mov    %edi,%edx
  802578:	83 e2 fc             	and    $0xfffffffc,%edx
  80257b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802582:	29 c2                	sub    %eax,%edx
  802584:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80258a:	8d 42 f8             	lea    -0x8(%edx),%eax
  80258d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802592:	0f 86 b0 03 00 00    	jbe    802948 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802598:	83 ec 04             	sub    $0x4,%esp
  80259b:	6a 07                	push   $0x7
  80259d:	68 00 00 40 00       	push   $0x400000
  8025a2:	6a 00                	push   $0x0
  8025a4:	e8 bc ef ff ff       	call   801565 <sys_page_alloc>
  8025a9:	83 c4 10             	add    $0x10,%esp
  8025ac:	85 c0                	test   %eax,%eax
  8025ae:	0f 88 9e 03 00 00    	js     802952 <spawn+0x4eb>
  8025b4:	be 00 00 00 00       	mov    $0x0,%esi
  8025b9:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8025bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8025c2:	eb 30                	jmp    8025f4 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8025c4:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8025ca:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8025d0:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8025d3:	83 ec 08             	sub    $0x8,%esp
  8025d6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8025d9:	57                   	push   %edi
  8025da:	e8 83 eb ff ff       	call   801162 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8025df:	83 c4 04             	add    $0x4,%esp
  8025e2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8025e5:	e8 3f eb ff ff       	call   801129 <strlen>
  8025ea:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8025ee:	83 c6 01             	add    $0x1,%esi
  8025f1:	83 c4 10             	add    $0x10,%esp
  8025f4:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8025fa:	7f c8                	jg     8025c4 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8025fc:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802602:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  802608:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80260f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802615:	74 19                	je     802630 <spawn+0x1c9>
  802617:	68 2c 3e 80 00       	push   $0x803e2c
  80261c:	68 da 37 80 00       	push   $0x8037da
  802621:	68 f2 00 00 00       	push   $0xf2
  802626:	68 bc 3d 80 00       	push   $0x803dbc
  80262b:	e8 e1 e3 ff ff       	call   800a11 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802630:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802636:	89 f8                	mov    %edi,%eax
  802638:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80263d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802640:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802646:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802649:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80264f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802655:	83 ec 0c             	sub    $0xc,%esp
  802658:	6a 07                	push   $0x7
  80265a:	68 00 d0 bf ee       	push   $0xeebfd000
  80265f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802665:	68 00 00 40 00       	push   $0x400000
  80266a:	6a 00                	push   $0x0
  80266c:	e8 37 ef ff ff       	call   8015a8 <sys_page_map>
  802671:	89 c3                	mov    %eax,%ebx
  802673:	83 c4 20             	add    $0x20,%esp
  802676:	85 c0                	test   %eax,%eax
  802678:	0f 88 4a 03 00 00    	js     8029c8 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80267e:	83 ec 08             	sub    $0x8,%esp
  802681:	68 00 00 40 00       	push   $0x400000
  802686:	6a 00                	push   $0x0
  802688:	e8 5d ef ff ff       	call   8015ea <sys_page_unmap>
  80268d:	89 c3                	mov    %eax,%ebx
  80268f:	83 c4 10             	add    $0x10,%esp
  802692:	85 c0                	test   %eax,%eax
  802694:	0f 88 2e 03 00 00    	js     8029c8 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80269a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8026a0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8026a7:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8026ad:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8026b4:	00 00 00 
  8026b7:	e9 8a 01 00 00       	jmp    802846 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  8026bc:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8026c2:	83 38 01             	cmpl   $0x1,(%eax)
  8026c5:	0f 85 6d 01 00 00    	jne    802838 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8026cb:	89 c7                	mov    %eax,%edi
  8026cd:	8b 40 18             	mov    0x18(%eax),%eax
  8026d0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8026d6:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8026d9:	83 f8 01             	cmp    $0x1,%eax
  8026dc:	19 c0                	sbb    %eax,%eax
  8026de:	83 e0 fe             	and    $0xfffffffe,%eax
  8026e1:	83 c0 07             	add    $0x7,%eax
  8026e4:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8026ea:	89 f8                	mov    %edi,%eax
  8026ec:	8b 7f 04             	mov    0x4(%edi),%edi
  8026ef:	89 f9                	mov    %edi,%ecx
  8026f1:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8026f7:	8b 78 10             	mov    0x10(%eax),%edi
  8026fa:	8b 70 14             	mov    0x14(%eax),%esi
  8026fd:	89 f3                	mov    %esi,%ebx
  8026ff:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  802705:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802708:	89 f0                	mov    %esi,%eax
  80270a:	25 ff 0f 00 00       	and    $0xfff,%eax
  80270f:	74 14                	je     802725 <spawn+0x2be>
		va -= i;
  802711:	29 c6                	sub    %eax,%esi
		memsz += i;
  802713:	01 c3                	add    %eax,%ebx
  802715:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  80271b:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80271d:	29 c1                	sub    %eax,%ecx
  80271f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802725:	bb 00 00 00 00       	mov    $0x0,%ebx
  80272a:	e9 f7 00 00 00       	jmp    802826 <spawn+0x3bf>
		if (i >= filesz) {
  80272f:	39 df                	cmp    %ebx,%edi
  802731:	77 27                	ja     80275a <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802733:	83 ec 04             	sub    $0x4,%esp
  802736:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80273c:	56                   	push   %esi
  80273d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802743:	e8 1d ee ff ff       	call   801565 <sys_page_alloc>
  802748:	83 c4 10             	add    $0x10,%esp
  80274b:	85 c0                	test   %eax,%eax
  80274d:	0f 89 c7 00 00 00    	jns    80281a <spawn+0x3b3>
  802753:	89 c3                	mov    %eax,%ebx
  802755:	e9 09 02 00 00       	jmp    802963 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80275a:	83 ec 04             	sub    $0x4,%esp
  80275d:	6a 07                	push   $0x7
  80275f:	68 00 00 40 00       	push   $0x400000
  802764:	6a 00                	push   $0x0
  802766:	e8 fa ed ff ff       	call   801565 <sys_page_alloc>
  80276b:	83 c4 10             	add    $0x10,%esp
  80276e:	85 c0                	test   %eax,%eax
  802770:	0f 88 e3 01 00 00    	js     802959 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802776:	83 ec 08             	sub    $0x8,%esp
  802779:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80277f:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802785:	50                   	push   %eax
  802786:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80278c:	e8 0a f8 ff ff       	call   801f9b <seek>
  802791:	83 c4 10             	add    $0x10,%esp
  802794:	85 c0                	test   %eax,%eax
  802796:	0f 88 c1 01 00 00    	js     80295d <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80279c:	83 ec 04             	sub    $0x4,%esp
  80279f:	89 f8                	mov    %edi,%eax
  8027a1:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8027a7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8027ac:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8027b1:	0f 47 c1             	cmova  %ecx,%eax
  8027b4:	50                   	push   %eax
  8027b5:	68 00 00 40 00       	push   $0x400000
  8027ba:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027c0:	e8 01 f7 ff ff       	call   801ec6 <readn>
  8027c5:	83 c4 10             	add    $0x10,%esp
  8027c8:	85 c0                	test   %eax,%eax
  8027ca:	0f 88 91 01 00 00    	js     802961 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8027d0:	83 ec 0c             	sub    $0xc,%esp
  8027d3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027d9:	56                   	push   %esi
  8027da:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027e0:	68 00 00 40 00       	push   $0x400000
  8027e5:	6a 00                	push   $0x0
  8027e7:	e8 bc ed ff ff       	call   8015a8 <sys_page_map>
  8027ec:	83 c4 20             	add    $0x20,%esp
  8027ef:	85 c0                	test   %eax,%eax
  8027f1:	79 15                	jns    802808 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  8027f3:	50                   	push   %eax
  8027f4:	68 c8 3d 80 00       	push   $0x803dc8
  8027f9:	68 25 01 00 00       	push   $0x125
  8027fe:	68 bc 3d 80 00       	push   $0x803dbc
  802803:	e8 09 e2 ff ff       	call   800a11 <_panic>
			sys_page_unmap(0, UTEMP);
  802808:	83 ec 08             	sub    $0x8,%esp
  80280b:	68 00 00 40 00       	push   $0x400000
  802810:	6a 00                	push   $0x0
  802812:	e8 d3 ed ff ff       	call   8015ea <sys_page_unmap>
  802817:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80281a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802820:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802826:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80282c:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802832:	0f 87 f7 fe ff ff    	ja     80272f <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802838:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80283f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802846:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80284d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802853:	0f 8c 63 fe ff ff    	jl     8026bc <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802859:	83 ec 0c             	sub    $0xc,%esp
  80285c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802862:	e8 92 f4 ff ff       	call   801cf9 <close>
  802867:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80286a:	bb 00 08 00 00       	mov    $0x800,%ebx
  80286f:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  802875:	89 d8                	mov    %ebx,%eax
  802877:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80287a:	89 c2                	mov    %eax,%edx
  80287c:	c1 ea 16             	shr    $0x16,%edx
  80287f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802886:	f6 c2 01             	test   $0x1,%dl
  802889:	74 4b                	je     8028d6 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80288b:	89 c2                	mov    %eax,%edx
  80288d:	c1 ea 0c             	shr    $0xc,%edx
  802890:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  802897:	f6 c1 01             	test   $0x1,%cl
  80289a:	74 3a                	je     8028d6 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  80289c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8028a3:	f6 c6 04             	test   $0x4,%dh
  8028a6:	74 2e                	je     8028d6 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  8028a8:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  8028af:	8b 0d 28 54 80 00    	mov    0x805428,%ecx
  8028b5:	8b 49 48             	mov    0x48(%ecx),%ecx
  8028b8:	83 ec 0c             	sub    $0xc,%esp
  8028bb:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8028c1:	52                   	push   %edx
  8028c2:	50                   	push   %eax
  8028c3:	56                   	push   %esi
  8028c4:	50                   	push   %eax
  8028c5:	51                   	push   %ecx
  8028c6:	e8 dd ec ff ff       	call   8015a8 <sys_page_map>
					if (r < 0)
  8028cb:	83 c4 20             	add    $0x20,%esp
  8028ce:	85 c0                	test   %eax,%eax
  8028d0:	0f 88 ae 00 00 00    	js     802984 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8028d6:	83 c3 01             	add    $0x1,%ebx
  8028d9:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8028df:	75 94                	jne    802875 <spawn+0x40e>
  8028e1:	e9 b3 00 00 00       	jmp    802999 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8028e6:	50                   	push   %eax
  8028e7:	68 e5 3d 80 00       	push   $0x803de5
  8028ec:	68 86 00 00 00       	push   $0x86
  8028f1:	68 bc 3d 80 00       	push   $0x803dbc
  8028f6:	e8 16 e1 ff ff       	call   800a11 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8028fb:	83 ec 08             	sub    $0x8,%esp
  8028fe:	6a 02                	push   $0x2
  802900:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802906:	e8 21 ed ff ff       	call   80162c <sys_env_set_status>
  80290b:	83 c4 10             	add    $0x10,%esp
  80290e:	85 c0                	test   %eax,%eax
  802910:	79 2b                	jns    80293d <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  802912:	50                   	push   %eax
  802913:	68 ff 3d 80 00       	push   $0x803dff
  802918:	68 89 00 00 00       	push   $0x89
  80291d:	68 bc 3d 80 00       	push   $0x803dbc
  802922:	e8 ea e0 ff ff       	call   800a11 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802927:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80292d:	e9 a8 00 00 00       	jmp    8029da <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802932:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802938:	e9 9d 00 00 00       	jmp    8029da <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80293d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802943:	e9 92 00 00 00       	jmp    8029da <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802948:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80294d:	e9 88 00 00 00       	jmp    8029da <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802952:	89 c3                	mov    %eax,%ebx
  802954:	e9 81 00 00 00       	jmp    8029da <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802959:	89 c3                	mov    %eax,%ebx
  80295b:	eb 06                	jmp    802963 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80295d:	89 c3                	mov    %eax,%ebx
  80295f:	eb 02                	jmp    802963 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802961:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802963:	83 ec 0c             	sub    $0xc,%esp
  802966:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80296c:	e8 75 eb ff ff       	call   8014e6 <sys_env_destroy>
	close(fd);
  802971:	83 c4 04             	add    $0x4,%esp
  802974:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80297a:	e8 7a f3 ff ff       	call   801cf9 <close>
	return r;
  80297f:	83 c4 10             	add    $0x10,%esp
  802982:	eb 56                	jmp    8029da <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802984:	50                   	push   %eax
  802985:	68 16 3e 80 00       	push   $0x803e16
  80298a:	68 82 00 00 00       	push   $0x82
  80298f:	68 bc 3d 80 00       	push   $0x803dbc
  802994:	e8 78 e0 ff ff       	call   800a11 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802999:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8029a0:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8029a3:	83 ec 08             	sub    $0x8,%esp
  8029a6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8029ac:	50                   	push   %eax
  8029ad:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029b3:	e8 b6 ec ff ff       	call   80166e <sys_env_set_trapframe>
  8029b8:	83 c4 10             	add    $0x10,%esp
  8029bb:	85 c0                	test   %eax,%eax
  8029bd:	0f 89 38 ff ff ff    	jns    8028fb <spawn+0x494>
  8029c3:	e9 1e ff ff ff       	jmp    8028e6 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8029c8:	83 ec 08             	sub    $0x8,%esp
  8029cb:	68 00 00 40 00       	push   $0x400000
  8029d0:	6a 00                	push   $0x0
  8029d2:	e8 13 ec ff ff       	call   8015ea <sys_page_unmap>
  8029d7:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8029da:	89 d8                	mov    %ebx,%eax
  8029dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029df:	5b                   	pop    %ebx
  8029e0:	5e                   	pop    %esi
  8029e1:	5f                   	pop    %edi
  8029e2:	5d                   	pop    %ebp
  8029e3:	c3                   	ret    

008029e4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8029e4:	55                   	push   %ebp
  8029e5:	89 e5                	mov    %esp,%ebp
  8029e7:	56                   	push   %esi
  8029e8:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029e9:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8029ec:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029f1:	eb 03                	jmp    8029f6 <spawnl+0x12>
		argc++;
  8029f3:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029f6:	83 c2 04             	add    $0x4,%edx
  8029f9:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8029fd:	75 f4                	jne    8029f3 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8029ff:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a06:	83 e2 f0             	and    $0xfffffff0,%edx
  802a09:	29 d4                	sub    %edx,%esp
  802a0b:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a0f:	c1 ea 02             	shr    $0x2,%edx
  802a12:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a19:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a1e:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a25:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a2c:	00 
  802a2d:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  802a34:	eb 0a                	jmp    802a40 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a36:	83 c0 01             	add    $0x1,%eax
  802a39:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802a3d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a40:	39 d0                	cmp    %edx,%eax
  802a42:	75 f2                	jne    802a36 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802a44:	83 ec 08             	sub    $0x8,%esp
  802a47:	56                   	push   %esi
  802a48:	ff 75 08             	pushl  0x8(%ebp)
  802a4b:	e8 17 fa ff ff       	call   802467 <spawn>
}
  802a50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a53:	5b                   	pop    %ebx
  802a54:	5e                   	pop    %esi
  802a55:	5d                   	pop    %ebp
  802a56:	c3                   	ret    

00802a57 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802a57:	55                   	push   %ebp
  802a58:	89 e5                	mov    %esp,%ebp
  802a5a:	56                   	push   %esi
  802a5b:	53                   	push   %ebx
  802a5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802a5f:	83 ec 0c             	sub    $0xc,%esp
  802a62:	ff 75 08             	pushl  0x8(%ebp)
  802a65:	e8 ff f0 ff ff       	call   801b69 <fd2data>
  802a6a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802a6c:	83 c4 08             	add    $0x8,%esp
  802a6f:	68 54 3e 80 00       	push   $0x803e54
  802a74:	53                   	push   %ebx
  802a75:	e8 e8 e6 ff ff       	call   801162 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802a7a:	8b 46 04             	mov    0x4(%esi),%eax
  802a7d:	2b 06                	sub    (%esi),%eax
  802a7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802a85:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802a8c:	00 00 00 
	stat->st_dev = &devpipe;
  802a8f:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802a96:	40 80 00 
	return 0;
}
  802a99:	b8 00 00 00 00       	mov    $0x0,%eax
  802a9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802aa1:	5b                   	pop    %ebx
  802aa2:	5e                   	pop    %esi
  802aa3:	5d                   	pop    %ebp
  802aa4:	c3                   	ret    

00802aa5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802aa5:	55                   	push   %ebp
  802aa6:	89 e5                	mov    %esp,%ebp
  802aa8:	53                   	push   %ebx
  802aa9:	83 ec 0c             	sub    $0xc,%esp
  802aac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802aaf:	53                   	push   %ebx
  802ab0:	6a 00                	push   $0x0
  802ab2:	e8 33 eb ff ff       	call   8015ea <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802ab7:	89 1c 24             	mov    %ebx,(%esp)
  802aba:	e8 aa f0 ff ff       	call   801b69 <fd2data>
  802abf:	83 c4 08             	add    $0x8,%esp
  802ac2:	50                   	push   %eax
  802ac3:	6a 00                	push   $0x0
  802ac5:	e8 20 eb ff ff       	call   8015ea <sys_page_unmap>
}
  802aca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802acd:	c9                   	leave  
  802ace:	c3                   	ret    

00802acf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802acf:	55                   	push   %ebp
  802ad0:	89 e5                	mov    %esp,%ebp
  802ad2:	57                   	push   %edi
  802ad3:	56                   	push   %esi
  802ad4:	53                   	push   %ebx
  802ad5:	83 ec 1c             	sub    $0x1c,%esp
  802ad8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802adb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802add:	a1 28 54 80 00       	mov    0x805428,%eax
  802ae2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802ae5:	83 ec 0c             	sub    $0xc,%esp
  802ae8:	ff 75 e0             	pushl  -0x20(%ebp)
  802aeb:	e8 d8 08 00 00       	call   8033c8 <pageref>
  802af0:	89 c3                	mov    %eax,%ebx
  802af2:	89 3c 24             	mov    %edi,(%esp)
  802af5:	e8 ce 08 00 00       	call   8033c8 <pageref>
  802afa:	83 c4 10             	add    $0x10,%esp
  802afd:	39 c3                	cmp    %eax,%ebx
  802aff:	0f 94 c1             	sete   %cl
  802b02:	0f b6 c9             	movzbl %cl,%ecx
  802b05:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802b08:	8b 15 28 54 80 00    	mov    0x805428,%edx
  802b0e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b11:	39 ce                	cmp    %ecx,%esi
  802b13:	74 1b                	je     802b30 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802b15:	39 c3                	cmp    %eax,%ebx
  802b17:	75 c4                	jne    802add <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b19:	8b 42 58             	mov    0x58(%edx),%eax
  802b1c:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b1f:	50                   	push   %eax
  802b20:	56                   	push   %esi
  802b21:	68 5b 3e 80 00       	push   $0x803e5b
  802b26:	e8 bf df ff ff       	call   800aea <cprintf>
  802b2b:	83 c4 10             	add    $0x10,%esp
  802b2e:	eb ad                	jmp    802add <_pipeisclosed+0xe>
	}
}
  802b30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b36:	5b                   	pop    %ebx
  802b37:	5e                   	pop    %esi
  802b38:	5f                   	pop    %edi
  802b39:	5d                   	pop    %ebp
  802b3a:	c3                   	ret    

00802b3b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b3b:	55                   	push   %ebp
  802b3c:	89 e5                	mov    %esp,%ebp
  802b3e:	57                   	push   %edi
  802b3f:	56                   	push   %esi
  802b40:	53                   	push   %ebx
  802b41:	83 ec 28             	sub    $0x28,%esp
  802b44:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802b47:	56                   	push   %esi
  802b48:	e8 1c f0 ff ff       	call   801b69 <fd2data>
  802b4d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b4f:	83 c4 10             	add    $0x10,%esp
  802b52:	bf 00 00 00 00       	mov    $0x0,%edi
  802b57:	eb 4b                	jmp    802ba4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802b59:	89 da                	mov    %ebx,%edx
  802b5b:	89 f0                	mov    %esi,%eax
  802b5d:	e8 6d ff ff ff       	call   802acf <_pipeisclosed>
  802b62:	85 c0                	test   %eax,%eax
  802b64:	75 48                	jne    802bae <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802b66:	e8 db e9 ff ff       	call   801546 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802b6b:	8b 43 04             	mov    0x4(%ebx),%eax
  802b6e:	8b 0b                	mov    (%ebx),%ecx
  802b70:	8d 51 20             	lea    0x20(%ecx),%edx
  802b73:	39 d0                	cmp    %edx,%eax
  802b75:	73 e2                	jae    802b59 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b7a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802b7e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802b81:	89 c2                	mov    %eax,%edx
  802b83:	c1 fa 1f             	sar    $0x1f,%edx
  802b86:	89 d1                	mov    %edx,%ecx
  802b88:	c1 e9 1b             	shr    $0x1b,%ecx
  802b8b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802b8e:	83 e2 1f             	and    $0x1f,%edx
  802b91:	29 ca                	sub    %ecx,%edx
  802b93:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802b97:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802b9b:	83 c0 01             	add    $0x1,%eax
  802b9e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ba1:	83 c7 01             	add    $0x1,%edi
  802ba4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802ba7:	75 c2                	jne    802b6b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802ba9:	8b 45 10             	mov    0x10(%ebp),%eax
  802bac:	eb 05                	jmp    802bb3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802bae:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bb6:	5b                   	pop    %ebx
  802bb7:	5e                   	pop    %esi
  802bb8:	5f                   	pop    %edi
  802bb9:	5d                   	pop    %ebp
  802bba:	c3                   	ret    

00802bbb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802bbb:	55                   	push   %ebp
  802bbc:	89 e5                	mov    %esp,%ebp
  802bbe:	57                   	push   %edi
  802bbf:	56                   	push   %esi
  802bc0:	53                   	push   %ebx
  802bc1:	83 ec 18             	sub    $0x18,%esp
  802bc4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802bc7:	57                   	push   %edi
  802bc8:	e8 9c ef ff ff       	call   801b69 <fd2data>
  802bcd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bcf:	83 c4 10             	add    $0x10,%esp
  802bd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bd7:	eb 3d                	jmp    802c16 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802bd9:	85 db                	test   %ebx,%ebx
  802bdb:	74 04                	je     802be1 <devpipe_read+0x26>
				return i;
  802bdd:	89 d8                	mov    %ebx,%eax
  802bdf:	eb 44                	jmp    802c25 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802be1:	89 f2                	mov    %esi,%edx
  802be3:	89 f8                	mov    %edi,%eax
  802be5:	e8 e5 fe ff ff       	call   802acf <_pipeisclosed>
  802bea:	85 c0                	test   %eax,%eax
  802bec:	75 32                	jne    802c20 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802bee:	e8 53 e9 ff ff       	call   801546 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802bf3:	8b 06                	mov    (%esi),%eax
  802bf5:	3b 46 04             	cmp    0x4(%esi),%eax
  802bf8:	74 df                	je     802bd9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802bfa:	99                   	cltd   
  802bfb:	c1 ea 1b             	shr    $0x1b,%edx
  802bfe:	01 d0                	add    %edx,%eax
  802c00:	83 e0 1f             	and    $0x1f,%eax
  802c03:	29 d0                	sub    %edx,%eax
  802c05:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c0d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802c10:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c13:	83 c3 01             	add    $0x1,%ebx
  802c16:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c19:	75 d8                	jne    802bf3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c1b:	8b 45 10             	mov    0x10(%ebp),%eax
  802c1e:	eb 05                	jmp    802c25 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c28:	5b                   	pop    %ebx
  802c29:	5e                   	pop    %esi
  802c2a:	5f                   	pop    %edi
  802c2b:	5d                   	pop    %ebp
  802c2c:	c3                   	ret    

00802c2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c2d:	55                   	push   %ebp
  802c2e:	89 e5                	mov    %esp,%ebp
  802c30:	56                   	push   %esi
  802c31:	53                   	push   %ebx
  802c32:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c38:	50                   	push   %eax
  802c39:	e8 42 ef ff ff       	call   801b80 <fd_alloc>
  802c3e:	83 c4 10             	add    $0x10,%esp
  802c41:	89 c2                	mov    %eax,%edx
  802c43:	85 c0                	test   %eax,%eax
  802c45:	0f 88 2c 01 00 00    	js     802d77 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c4b:	83 ec 04             	sub    $0x4,%esp
  802c4e:	68 07 04 00 00       	push   $0x407
  802c53:	ff 75 f4             	pushl  -0xc(%ebp)
  802c56:	6a 00                	push   $0x0
  802c58:	e8 08 e9 ff ff       	call   801565 <sys_page_alloc>
  802c5d:	83 c4 10             	add    $0x10,%esp
  802c60:	89 c2                	mov    %eax,%edx
  802c62:	85 c0                	test   %eax,%eax
  802c64:	0f 88 0d 01 00 00    	js     802d77 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802c6a:	83 ec 0c             	sub    $0xc,%esp
  802c6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c70:	50                   	push   %eax
  802c71:	e8 0a ef ff ff       	call   801b80 <fd_alloc>
  802c76:	89 c3                	mov    %eax,%ebx
  802c78:	83 c4 10             	add    $0x10,%esp
  802c7b:	85 c0                	test   %eax,%eax
  802c7d:	0f 88 e2 00 00 00    	js     802d65 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c83:	83 ec 04             	sub    $0x4,%esp
  802c86:	68 07 04 00 00       	push   $0x407
  802c8b:	ff 75 f0             	pushl  -0x10(%ebp)
  802c8e:	6a 00                	push   $0x0
  802c90:	e8 d0 e8 ff ff       	call   801565 <sys_page_alloc>
  802c95:	89 c3                	mov    %eax,%ebx
  802c97:	83 c4 10             	add    $0x10,%esp
  802c9a:	85 c0                	test   %eax,%eax
  802c9c:	0f 88 c3 00 00 00    	js     802d65 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802ca2:	83 ec 0c             	sub    $0xc,%esp
  802ca5:	ff 75 f4             	pushl  -0xc(%ebp)
  802ca8:	e8 bc ee ff ff       	call   801b69 <fd2data>
  802cad:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802caf:	83 c4 0c             	add    $0xc,%esp
  802cb2:	68 07 04 00 00       	push   $0x407
  802cb7:	50                   	push   %eax
  802cb8:	6a 00                	push   $0x0
  802cba:	e8 a6 e8 ff ff       	call   801565 <sys_page_alloc>
  802cbf:	89 c3                	mov    %eax,%ebx
  802cc1:	83 c4 10             	add    $0x10,%esp
  802cc4:	85 c0                	test   %eax,%eax
  802cc6:	0f 88 89 00 00 00    	js     802d55 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ccc:	83 ec 0c             	sub    $0xc,%esp
  802ccf:	ff 75 f0             	pushl  -0x10(%ebp)
  802cd2:	e8 92 ee ff ff       	call   801b69 <fd2data>
  802cd7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802cde:	50                   	push   %eax
  802cdf:	6a 00                	push   $0x0
  802ce1:	56                   	push   %esi
  802ce2:	6a 00                	push   $0x0
  802ce4:	e8 bf e8 ff ff       	call   8015a8 <sys_page_map>
  802ce9:	89 c3                	mov    %eax,%ebx
  802ceb:	83 c4 20             	add    $0x20,%esp
  802cee:	85 c0                	test   %eax,%eax
  802cf0:	78 55                	js     802d47 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802cf2:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cfb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d00:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d07:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d10:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d15:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d1c:	83 ec 0c             	sub    $0xc,%esp
  802d1f:	ff 75 f4             	pushl  -0xc(%ebp)
  802d22:	e8 32 ee ff ff       	call   801b59 <fd2num>
  802d27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d2a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d2c:	83 c4 04             	add    $0x4,%esp
  802d2f:	ff 75 f0             	pushl  -0x10(%ebp)
  802d32:	e8 22 ee ff ff       	call   801b59 <fd2num>
  802d37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d3a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802d3d:	83 c4 10             	add    $0x10,%esp
  802d40:	ba 00 00 00 00       	mov    $0x0,%edx
  802d45:	eb 30                	jmp    802d77 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802d47:	83 ec 08             	sub    $0x8,%esp
  802d4a:	56                   	push   %esi
  802d4b:	6a 00                	push   $0x0
  802d4d:	e8 98 e8 ff ff       	call   8015ea <sys_page_unmap>
  802d52:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802d55:	83 ec 08             	sub    $0x8,%esp
  802d58:	ff 75 f0             	pushl  -0x10(%ebp)
  802d5b:	6a 00                	push   $0x0
  802d5d:	e8 88 e8 ff ff       	call   8015ea <sys_page_unmap>
  802d62:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802d65:	83 ec 08             	sub    $0x8,%esp
  802d68:	ff 75 f4             	pushl  -0xc(%ebp)
  802d6b:	6a 00                	push   $0x0
  802d6d:	e8 78 e8 ff ff       	call   8015ea <sys_page_unmap>
  802d72:	83 c4 10             	add    $0x10,%esp
  802d75:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802d77:	89 d0                	mov    %edx,%eax
  802d79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d7c:	5b                   	pop    %ebx
  802d7d:	5e                   	pop    %esi
  802d7e:	5d                   	pop    %ebp
  802d7f:	c3                   	ret    

00802d80 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802d80:	55                   	push   %ebp
  802d81:	89 e5                	mov    %esp,%ebp
  802d83:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d89:	50                   	push   %eax
  802d8a:	ff 75 08             	pushl  0x8(%ebp)
  802d8d:	e8 3d ee ff ff       	call   801bcf <fd_lookup>
  802d92:	83 c4 10             	add    $0x10,%esp
  802d95:	85 c0                	test   %eax,%eax
  802d97:	78 18                	js     802db1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802d99:	83 ec 0c             	sub    $0xc,%esp
  802d9c:	ff 75 f4             	pushl  -0xc(%ebp)
  802d9f:	e8 c5 ed ff ff       	call   801b69 <fd2data>
	return _pipeisclosed(fd, p);
  802da4:	89 c2                	mov    %eax,%edx
  802da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802da9:	e8 21 fd ff ff       	call   802acf <_pipeisclosed>
  802dae:	83 c4 10             	add    $0x10,%esp
}
  802db1:	c9                   	leave  
  802db2:	c3                   	ret    

00802db3 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802db3:	55                   	push   %ebp
  802db4:	89 e5                	mov    %esp,%ebp
  802db6:	56                   	push   %esi
  802db7:	53                   	push   %ebx
  802db8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802dbb:	85 f6                	test   %esi,%esi
  802dbd:	75 16                	jne    802dd5 <wait+0x22>
  802dbf:	68 73 3e 80 00       	push   $0x803e73
  802dc4:	68 da 37 80 00       	push   $0x8037da
  802dc9:	6a 09                	push   $0x9
  802dcb:	68 7e 3e 80 00       	push   $0x803e7e
  802dd0:	e8 3c dc ff ff       	call   800a11 <_panic>
	e = &envs[ENVX(envid)];
  802dd5:	89 f3                	mov    %esi,%ebx
  802dd7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ddd:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802de0:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802de6:	eb 05                	jmp    802ded <wait+0x3a>
		sys_yield();
  802de8:	e8 59 e7 ff ff       	call   801546 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ded:	8b 43 48             	mov    0x48(%ebx),%eax
  802df0:	39 c6                	cmp    %eax,%esi
  802df2:	75 07                	jne    802dfb <wait+0x48>
  802df4:	8b 43 54             	mov    0x54(%ebx),%eax
  802df7:	85 c0                	test   %eax,%eax
  802df9:	75 ed                	jne    802de8 <wait+0x35>
		sys_yield();
}
  802dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dfe:	5b                   	pop    %ebx
  802dff:	5e                   	pop    %esi
  802e00:	5d                   	pop    %ebp
  802e01:	c3                   	ret    

00802e02 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802e02:	55                   	push   %ebp
  802e03:	89 e5                	mov    %esp,%ebp
  802e05:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802e08:	68 89 3e 80 00       	push   $0x803e89
  802e0d:	ff 75 0c             	pushl  0xc(%ebp)
  802e10:	e8 4d e3 ff ff       	call   801162 <strcpy>
	return 0;
}
  802e15:	b8 00 00 00 00       	mov    $0x0,%eax
  802e1a:	c9                   	leave  
  802e1b:	c3                   	ret    

00802e1c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802e1c:	55                   	push   %ebp
  802e1d:	89 e5                	mov    %esp,%ebp
  802e1f:	53                   	push   %ebx
  802e20:	83 ec 10             	sub    $0x10,%esp
  802e23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802e26:	53                   	push   %ebx
  802e27:	e8 9c 05 00 00       	call   8033c8 <pageref>
  802e2c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802e2f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802e34:	83 f8 01             	cmp    $0x1,%eax
  802e37:	75 10                	jne    802e49 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802e39:	83 ec 0c             	sub    $0xc,%esp
  802e3c:	ff 73 0c             	pushl  0xc(%ebx)
  802e3f:	e8 c0 02 00 00       	call   803104 <nsipc_close>
  802e44:	89 c2                	mov    %eax,%edx
  802e46:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802e49:	89 d0                	mov    %edx,%eax
  802e4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e4e:	c9                   	leave  
  802e4f:	c3                   	ret    

00802e50 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802e50:	55                   	push   %ebp
  802e51:	89 e5                	mov    %esp,%ebp
  802e53:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802e56:	6a 00                	push   $0x0
  802e58:	ff 75 10             	pushl  0x10(%ebp)
  802e5b:	ff 75 0c             	pushl  0xc(%ebp)
  802e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  802e61:	ff 70 0c             	pushl  0xc(%eax)
  802e64:	e8 78 03 00 00       	call   8031e1 <nsipc_send>
}
  802e69:	c9                   	leave  
  802e6a:	c3                   	ret    

00802e6b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802e6b:	55                   	push   %ebp
  802e6c:	89 e5                	mov    %esp,%ebp
  802e6e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802e71:	6a 00                	push   $0x0
  802e73:	ff 75 10             	pushl  0x10(%ebp)
  802e76:	ff 75 0c             	pushl  0xc(%ebp)
  802e79:	8b 45 08             	mov    0x8(%ebp),%eax
  802e7c:	ff 70 0c             	pushl  0xc(%eax)
  802e7f:	e8 f1 02 00 00       	call   803175 <nsipc_recv>
}
  802e84:	c9                   	leave  
  802e85:	c3                   	ret    

00802e86 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802e86:	55                   	push   %ebp
  802e87:	89 e5                	mov    %esp,%ebp
  802e89:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802e8c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802e8f:	52                   	push   %edx
  802e90:	50                   	push   %eax
  802e91:	e8 39 ed ff ff       	call   801bcf <fd_lookup>
  802e96:	83 c4 10             	add    $0x10,%esp
  802e99:	85 c0                	test   %eax,%eax
  802e9b:	78 17                	js     802eb4 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ea0:	8b 0d 58 40 80 00    	mov    0x804058,%ecx
  802ea6:	39 08                	cmp    %ecx,(%eax)
  802ea8:	75 05                	jne    802eaf <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802eaa:	8b 40 0c             	mov    0xc(%eax),%eax
  802ead:	eb 05                	jmp    802eb4 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802eaf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802eb4:	c9                   	leave  
  802eb5:	c3                   	ret    

00802eb6 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802eb6:	55                   	push   %ebp
  802eb7:	89 e5                	mov    %esp,%ebp
  802eb9:	56                   	push   %esi
  802eba:	53                   	push   %ebx
  802ebb:	83 ec 1c             	sub    $0x1c,%esp
  802ebe:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802ec0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ec3:	50                   	push   %eax
  802ec4:	e8 b7 ec ff ff       	call   801b80 <fd_alloc>
  802ec9:	89 c3                	mov    %eax,%ebx
  802ecb:	83 c4 10             	add    $0x10,%esp
  802ece:	85 c0                	test   %eax,%eax
  802ed0:	78 1b                	js     802eed <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802ed2:	83 ec 04             	sub    $0x4,%esp
  802ed5:	68 07 04 00 00       	push   $0x407
  802eda:	ff 75 f4             	pushl  -0xc(%ebp)
  802edd:	6a 00                	push   $0x0
  802edf:	e8 81 e6 ff ff       	call   801565 <sys_page_alloc>
  802ee4:	89 c3                	mov    %eax,%ebx
  802ee6:	83 c4 10             	add    $0x10,%esp
  802ee9:	85 c0                	test   %eax,%eax
  802eeb:	79 10                	jns    802efd <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802eed:	83 ec 0c             	sub    $0xc,%esp
  802ef0:	56                   	push   %esi
  802ef1:	e8 0e 02 00 00       	call   803104 <nsipc_close>
		return r;
  802ef6:	83 c4 10             	add    $0x10,%esp
  802ef9:	89 d8                	mov    %ebx,%eax
  802efb:	eb 24                	jmp    802f21 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802efd:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f06:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802f12:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802f15:	83 ec 0c             	sub    $0xc,%esp
  802f18:	50                   	push   %eax
  802f19:	e8 3b ec ff ff       	call   801b59 <fd2num>
  802f1e:	83 c4 10             	add    $0x10,%esp
}
  802f21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f24:	5b                   	pop    %ebx
  802f25:	5e                   	pop    %esi
  802f26:	5d                   	pop    %ebp
  802f27:	c3                   	ret    

00802f28 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802f28:	55                   	push   %ebp
  802f29:	89 e5                	mov    %esp,%ebp
  802f2b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  802f31:	e8 50 ff ff ff       	call   802e86 <fd2sockid>
		return r;
  802f36:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f38:	85 c0                	test   %eax,%eax
  802f3a:	78 1f                	js     802f5b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802f3c:	83 ec 04             	sub    $0x4,%esp
  802f3f:	ff 75 10             	pushl  0x10(%ebp)
  802f42:	ff 75 0c             	pushl  0xc(%ebp)
  802f45:	50                   	push   %eax
  802f46:	e8 12 01 00 00       	call   80305d <nsipc_accept>
  802f4b:	83 c4 10             	add    $0x10,%esp
		return r;
  802f4e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802f50:	85 c0                	test   %eax,%eax
  802f52:	78 07                	js     802f5b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802f54:	e8 5d ff ff ff       	call   802eb6 <alloc_sockfd>
  802f59:	89 c1                	mov    %eax,%ecx
}
  802f5b:	89 c8                	mov    %ecx,%eax
  802f5d:	c9                   	leave  
  802f5e:	c3                   	ret    

00802f5f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802f5f:	55                   	push   %ebp
  802f60:	89 e5                	mov    %esp,%ebp
  802f62:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f65:	8b 45 08             	mov    0x8(%ebp),%eax
  802f68:	e8 19 ff ff ff       	call   802e86 <fd2sockid>
  802f6d:	85 c0                	test   %eax,%eax
  802f6f:	78 12                	js     802f83 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802f71:	83 ec 04             	sub    $0x4,%esp
  802f74:	ff 75 10             	pushl  0x10(%ebp)
  802f77:	ff 75 0c             	pushl  0xc(%ebp)
  802f7a:	50                   	push   %eax
  802f7b:	e8 2d 01 00 00       	call   8030ad <nsipc_bind>
  802f80:	83 c4 10             	add    $0x10,%esp
}
  802f83:	c9                   	leave  
  802f84:	c3                   	ret    

00802f85 <shutdown>:

int
shutdown(int s, int how)
{
  802f85:	55                   	push   %ebp
  802f86:	89 e5                	mov    %esp,%ebp
  802f88:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  802f8e:	e8 f3 fe ff ff       	call   802e86 <fd2sockid>
  802f93:	85 c0                	test   %eax,%eax
  802f95:	78 0f                	js     802fa6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802f97:	83 ec 08             	sub    $0x8,%esp
  802f9a:	ff 75 0c             	pushl  0xc(%ebp)
  802f9d:	50                   	push   %eax
  802f9e:	e8 3f 01 00 00       	call   8030e2 <nsipc_shutdown>
  802fa3:	83 c4 10             	add    $0x10,%esp
}
  802fa6:	c9                   	leave  
  802fa7:	c3                   	ret    

00802fa8 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802fa8:	55                   	push   %ebp
  802fa9:	89 e5                	mov    %esp,%ebp
  802fab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802fae:	8b 45 08             	mov    0x8(%ebp),%eax
  802fb1:	e8 d0 fe ff ff       	call   802e86 <fd2sockid>
  802fb6:	85 c0                	test   %eax,%eax
  802fb8:	78 12                	js     802fcc <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802fba:	83 ec 04             	sub    $0x4,%esp
  802fbd:	ff 75 10             	pushl  0x10(%ebp)
  802fc0:	ff 75 0c             	pushl  0xc(%ebp)
  802fc3:	50                   	push   %eax
  802fc4:	e8 55 01 00 00       	call   80311e <nsipc_connect>
  802fc9:	83 c4 10             	add    $0x10,%esp
}
  802fcc:	c9                   	leave  
  802fcd:	c3                   	ret    

00802fce <listen>:

int
listen(int s, int backlog)
{
  802fce:	55                   	push   %ebp
  802fcf:	89 e5                	mov    %esp,%ebp
  802fd1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  802fd7:	e8 aa fe ff ff       	call   802e86 <fd2sockid>
  802fdc:	85 c0                	test   %eax,%eax
  802fde:	78 0f                	js     802fef <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802fe0:	83 ec 08             	sub    $0x8,%esp
  802fe3:	ff 75 0c             	pushl  0xc(%ebp)
  802fe6:	50                   	push   %eax
  802fe7:	e8 67 01 00 00       	call   803153 <nsipc_listen>
  802fec:	83 c4 10             	add    $0x10,%esp
}
  802fef:	c9                   	leave  
  802ff0:	c3                   	ret    

00802ff1 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802ff1:	55                   	push   %ebp
  802ff2:	89 e5                	mov    %esp,%ebp
  802ff4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802ff7:	ff 75 10             	pushl  0x10(%ebp)
  802ffa:	ff 75 0c             	pushl  0xc(%ebp)
  802ffd:	ff 75 08             	pushl  0x8(%ebp)
  803000:	e8 3a 02 00 00       	call   80323f <nsipc_socket>
  803005:	83 c4 10             	add    $0x10,%esp
  803008:	85 c0                	test   %eax,%eax
  80300a:	78 05                	js     803011 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80300c:	e8 a5 fe ff ff       	call   802eb6 <alloc_sockfd>
}
  803011:	c9                   	leave  
  803012:	c3                   	ret    

00803013 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803013:	55                   	push   %ebp
  803014:	89 e5                	mov    %esp,%ebp
  803016:	53                   	push   %ebx
  803017:	83 ec 04             	sub    $0x4,%esp
  80301a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80301c:	83 3d 24 54 80 00 00 	cmpl   $0x0,0x805424
  803023:	75 12                	jne    803037 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  803025:	83 ec 0c             	sub    $0xc,%esp
  803028:	6a 02                	push   $0x2
  80302a:	e8 60 03 00 00       	call   80338f <ipc_find_env>
  80302f:	a3 24 54 80 00       	mov    %eax,0x805424
  803034:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803037:	6a 07                	push   $0x7
  803039:	68 00 70 80 00       	push   $0x807000
  80303e:	53                   	push   %ebx
  80303f:	ff 35 24 54 80 00    	pushl  0x805424
  803045:	e8 f1 02 00 00       	call   80333b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80304a:	83 c4 0c             	add    $0xc,%esp
  80304d:	6a 00                	push   $0x0
  80304f:	6a 00                	push   $0x0
  803051:	6a 00                	push   $0x0
  803053:	e8 7c 02 00 00       	call   8032d4 <ipc_recv>
}
  803058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80305b:	c9                   	leave  
  80305c:	c3                   	ret    

0080305d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80305d:	55                   	push   %ebp
  80305e:	89 e5                	mov    %esp,%ebp
  803060:	56                   	push   %esi
  803061:	53                   	push   %ebx
  803062:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803065:	8b 45 08             	mov    0x8(%ebp),%eax
  803068:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80306d:	8b 06                	mov    (%esi),%eax
  80306f:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803074:	b8 01 00 00 00       	mov    $0x1,%eax
  803079:	e8 95 ff ff ff       	call   803013 <nsipc>
  80307e:	89 c3                	mov    %eax,%ebx
  803080:	85 c0                	test   %eax,%eax
  803082:	78 20                	js     8030a4 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803084:	83 ec 04             	sub    $0x4,%esp
  803087:	ff 35 10 70 80 00    	pushl  0x807010
  80308d:	68 00 70 80 00       	push   $0x807000
  803092:	ff 75 0c             	pushl  0xc(%ebp)
  803095:	e8 5a e2 ff ff       	call   8012f4 <memmove>
		*addrlen = ret->ret_addrlen;
  80309a:	a1 10 70 80 00       	mov    0x807010,%eax
  80309f:	89 06                	mov    %eax,(%esi)
  8030a1:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8030a4:	89 d8                	mov    %ebx,%eax
  8030a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8030a9:	5b                   	pop    %ebx
  8030aa:	5e                   	pop    %esi
  8030ab:	5d                   	pop    %ebp
  8030ac:	c3                   	ret    

008030ad <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8030ad:	55                   	push   %ebp
  8030ae:	89 e5                	mov    %esp,%ebp
  8030b0:	53                   	push   %ebx
  8030b1:	83 ec 08             	sub    $0x8,%esp
  8030b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8030b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8030ba:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8030bf:	53                   	push   %ebx
  8030c0:	ff 75 0c             	pushl  0xc(%ebp)
  8030c3:	68 04 70 80 00       	push   $0x807004
  8030c8:	e8 27 e2 ff ff       	call   8012f4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8030cd:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8030d3:	b8 02 00 00 00       	mov    $0x2,%eax
  8030d8:	e8 36 ff ff ff       	call   803013 <nsipc>
}
  8030dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030e0:	c9                   	leave  
  8030e1:	c3                   	ret    

008030e2 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8030e2:	55                   	push   %ebp
  8030e3:	89 e5                	mov    %esp,%ebp
  8030e5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8030e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8030eb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8030f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030f3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8030f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8030fd:	e8 11 ff ff ff       	call   803013 <nsipc>
}
  803102:	c9                   	leave  
  803103:	c3                   	ret    

00803104 <nsipc_close>:

int
nsipc_close(int s)
{
  803104:	55                   	push   %ebp
  803105:	89 e5                	mov    %esp,%ebp
  803107:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80310a:	8b 45 08             	mov    0x8(%ebp),%eax
  80310d:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  803112:	b8 04 00 00 00       	mov    $0x4,%eax
  803117:	e8 f7 fe ff ff       	call   803013 <nsipc>
}
  80311c:	c9                   	leave  
  80311d:	c3                   	ret    

0080311e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80311e:	55                   	push   %ebp
  80311f:	89 e5                	mov    %esp,%ebp
  803121:	53                   	push   %ebx
  803122:	83 ec 08             	sub    $0x8,%esp
  803125:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  803128:	8b 45 08             	mov    0x8(%ebp),%eax
  80312b:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803130:	53                   	push   %ebx
  803131:	ff 75 0c             	pushl  0xc(%ebp)
  803134:	68 04 70 80 00       	push   $0x807004
  803139:	e8 b6 e1 ff ff       	call   8012f4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80313e:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  803144:	b8 05 00 00 00       	mov    $0x5,%eax
  803149:	e8 c5 fe ff ff       	call   803013 <nsipc>
}
  80314e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803151:	c9                   	leave  
  803152:	c3                   	ret    

00803153 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803153:	55                   	push   %ebp
  803154:	89 e5                	mov    %esp,%ebp
  803156:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  803159:	8b 45 08             	mov    0x8(%ebp),%eax
  80315c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  803161:	8b 45 0c             	mov    0xc(%ebp),%eax
  803164:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  803169:	b8 06 00 00 00       	mov    $0x6,%eax
  80316e:	e8 a0 fe ff ff       	call   803013 <nsipc>
}
  803173:	c9                   	leave  
  803174:	c3                   	ret    

00803175 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803175:	55                   	push   %ebp
  803176:	89 e5                	mov    %esp,%ebp
  803178:	56                   	push   %esi
  803179:	53                   	push   %ebx
  80317a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80317d:	8b 45 08             	mov    0x8(%ebp),%eax
  803180:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  803185:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80318b:	8b 45 14             	mov    0x14(%ebp),%eax
  80318e:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803193:	b8 07 00 00 00       	mov    $0x7,%eax
  803198:	e8 76 fe ff ff       	call   803013 <nsipc>
  80319d:	89 c3                	mov    %eax,%ebx
  80319f:	85 c0                	test   %eax,%eax
  8031a1:	78 35                	js     8031d8 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8031a3:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8031a8:	7f 04                	jg     8031ae <nsipc_recv+0x39>
  8031aa:	39 c6                	cmp    %eax,%esi
  8031ac:	7d 16                	jge    8031c4 <nsipc_recv+0x4f>
  8031ae:	68 95 3e 80 00       	push   $0x803e95
  8031b3:	68 da 37 80 00       	push   $0x8037da
  8031b8:	6a 62                	push   $0x62
  8031ba:	68 aa 3e 80 00       	push   $0x803eaa
  8031bf:	e8 4d d8 ff ff       	call   800a11 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8031c4:	83 ec 04             	sub    $0x4,%esp
  8031c7:	50                   	push   %eax
  8031c8:	68 00 70 80 00       	push   $0x807000
  8031cd:	ff 75 0c             	pushl  0xc(%ebp)
  8031d0:	e8 1f e1 ff ff       	call   8012f4 <memmove>
  8031d5:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8031d8:	89 d8                	mov    %ebx,%eax
  8031da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031dd:	5b                   	pop    %ebx
  8031de:	5e                   	pop    %esi
  8031df:	5d                   	pop    %ebp
  8031e0:	c3                   	ret    

008031e1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8031e1:	55                   	push   %ebp
  8031e2:	89 e5                	mov    %esp,%ebp
  8031e4:	53                   	push   %ebx
  8031e5:	83 ec 04             	sub    $0x4,%esp
  8031e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8031eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8031ee:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8031f3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8031f9:	7e 16                	jle    803211 <nsipc_send+0x30>
  8031fb:	68 b6 3e 80 00       	push   $0x803eb6
  803200:	68 da 37 80 00       	push   $0x8037da
  803205:	6a 6d                	push   $0x6d
  803207:	68 aa 3e 80 00       	push   $0x803eaa
  80320c:	e8 00 d8 ff ff       	call   800a11 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803211:	83 ec 04             	sub    $0x4,%esp
  803214:	53                   	push   %ebx
  803215:	ff 75 0c             	pushl  0xc(%ebp)
  803218:	68 0c 70 80 00       	push   $0x80700c
  80321d:	e8 d2 e0 ff ff       	call   8012f4 <memmove>
	nsipcbuf.send.req_size = size;
  803222:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  803228:	8b 45 14             	mov    0x14(%ebp),%eax
  80322b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  803230:	b8 08 00 00 00       	mov    $0x8,%eax
  803235:	e8 d9 fd ff ff       	call   803013 <nsipc>
}
  80323a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80323d:	c9                   	leave  
  80323e:	c3                   	ret    

0080323f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80323f:	55                   	push   %ebp
  803240:	89 e5                	mov    %esp,%ebp
  803242:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  803245:	8b 45 08             	mov    0x8(%ebp),%eax
  803248:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80324d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803250:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  803255:	8b 45 10             	mov    0x10(%ebp),%eax
  803258:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80325d:	b8 09 00 00 00       	mov    $0x9,%eax
  803262:	e8 ac fd ff ff       	call   803013 <nsipc>
}
  803267:	c9                   	leave  
  803268:	c3                   	ret    

00803269 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803269:	55                   	push   %ebp
  80326a:	89 e5                	mov    %esp,%ebp
  80326c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80326f:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  803276:	75 2e                	jne    8032a6 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  803278:	e8 aa e2 ff ff       	call   801527 <sys_getenvid>
  80327d:	83 ec 04             	sub    $0x4,%esp
  803280:	68 07 0e 00 00       	push   $0xe07
  803285:	68 00 f0 bf ee       	push   $0xeebff000
  80328a:	50                   	push   %eax
  80328b:	e8 d5 e2 ff ff       	call   801565 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  803290:	e8 92 e2 ff ff       	call   801527 <sys_getenvid>
  803295:	83 c4 08             	add    $0x8,%esp
  803298:	68 b0 32 80 00       	push   $0x8032b0
  80329d:	50                   	push   %eax
  80329e:	e8 0d e4 ff ff       	call   8016b0 <sys_env_set_pgfault_upcall>
  8032a3:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8032a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8032a9:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8032ae:	c9                   	leave  
  8032af:	c3                   	ret    

008032b0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8032b0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8032b1:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8032b6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8032b8:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8032bb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8032bf:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8032c3:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8032c6:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8032c9:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8032ca:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8032cd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8032ce:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8032cf:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8032d3:	c3                   	ret    

008032d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8032d4:	55                   	push   %ebp
  8032d5:	89 e5                	mov    %esp,%ebp
  8032d7:	56                   	push   %esi
  8032d8:	53                   	push   %ebx
  8032d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8032dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8032e2:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8032e4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8032e9:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8032ec:	83 ec 0c             	sub    $0xc,%esp
  8032ef:	50                   	push   %eax
  8032f0:	e8 20 e4 ff ff       	call   801715 <sys_ipc_recv>

	if (from_env_store != NULL)
  8032f5:	83 c4 10             	add    $0x10,%esp
  8032f8:	85 f6                	test   %esi,%esi
  8032fa:	74 14                	je     803310 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8032fc:	ba 00 00 00 00       	mov    $0x0,%edx
  803301:	85 c0                	test   %eax,%eax
  803303:	78 09                	js     80330e <ipc_recv+0x3a>
  803305:	8b 15 28 54 80 00    	mov    0x805428,%edx
  80330b:	8b 52 74             	mov    0x74(%edx),%edx
  80330e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  803310:	85 db                	test   %ebx,%ebx
  803312:	74 14                	je     803328 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  803314:	ba 00 00 00 00       	mov    $0x0,%edx
  803319:	85 c0                	test   %eax,%eax
  80331b:	78 09                	js     803326 <ipc_recv+0x52>
  80331d:	8b 15 28 54 80 00    	mov    0x805428,%edx
  803323:	8b 52 78             	mov    0x78(%edx),%edx
  803326:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  803328:	85 c0                	test   %eax,%eax
  80332a:	78 08                	js     803334 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80332c:	a1 28 54 80 00       	mov    0x805428,%eax
  803331:	8b 40 70             	mov    0x70(%eax),%eax
}
  803334:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803337:	5b                   	pop    %ebx
  803338:	5e                   	pop    %esi
  803339:	5d                   	pop    %ebp
  80333a:	c3                   	ret    

0080333b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80333b:	55                   	push   %ebp
  80333c:	89 e5                	mov    %esp,%ebp
  80333e:	57                   	push   %edi
  80333f:	56                   	push   %esi
  803340:	53                   	push   %ebx
  803341:	83 ec 0c             	sub    $0xc,%esp
  803344:	8b 7d 08             	mov    0x8(%ebp),%edi
  803347:	8b 75 0c             	mov    0xc(%ebp),%esi
  80334a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80334d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80334f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  803354:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  803357:	ff 75 14             	pushl  0x14(%ebp)
  80335a:	53                   	push   %ebx
  80335b:	56                   	push   %esi
  80335c:	57                   	push   %edi
  80335d:	e8 90 e3 ff ff       	call   8016f2 <sys_ipc_try_send>

		if (err < 0) {
  803362:	83 c4 10             	add    $0x10,%esp
  803365:	85 c0                	test   %eax,%eax
  803367:	79 1e                	jns    803387 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  803369:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80336c:	75 07                	jne    803375 <ipc_send+0x3a>
				sys_yield();
  80336e:	e8 d3 e1 ff ff       	call   801546 <sys_yield>
  803373:	eb e2                	jmp    803357 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  803375:	50                   	push   %eax
  803376:	68 c2 3e 80 00       	push   $0x803ec2
  80337b:	6a 49                	push   $0x49
  80337d:	68 cf 3e 80 00       	push   $0x803ecf
  803382:	e8 8a d6 ff ff       	call   800a11 <_panic>
		}

	} while (err < 0);

}
  803387:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80338a:	5b                   	pop    %ebx
  80338b:	5e                   	pop    %esi
  80338c:	5f                   	pop    %edi
  80338d:	5d                   	pop    %ebp
  80338e:	c3                   	ret    

0080338f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80338f:	55                   	push   %ebp
  803390:	89 e5                	mov    %esp,%ebp
  803392:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803395:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80339a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80339d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8033a3:	8b 52 50             	mov    0x50(%edx),%edx
  8033a6:	39 ca                	cmp    %ecx,%edx
  8033a8:	75 0d                	jne    8033b7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8033aa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8033ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8033b2:	8b 40 48             	mov    0x48(%eax),%eax
  8033b5:	eb 0f                	jmp    8033c6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8033b7:	83 c0 01             	add    $0x1,%eax
  8033ba:	3d 00 04 00 00       	cmp    $0x400,%eax
  8033bf:	75 d9                	jne    80339a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8033c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8033c6:	5d                   	pop    %ebp
  8033c7:	c3                   	ret    

008033c8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8033c8:	55                   	push   %ebp
  8033c9:	89 e5                	mov    %esp,%ebp
  8033cb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8033ce:	89 d0                	mov    %edx,%eax
  8033d0:	c1 e8 16             	shr    $0x16,%eax
  8033d3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8033da:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8033df:	f6 c1 01             	test   $0x1,%cl
  8033e2:	74 1d                	je     803401 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8033e4:	c1 ea 0c             	shr    $0xc,%edx
  8033e7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8033ee:	f6 c2 01             	test   $0x1,%dl
  8033f1:	74 0e                	je     803401 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8033f3:	c1 ea 0c             	shr    $0xc,%edx
  8033f6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8033fd:	ef 
  8033fe:	0f b7 c0             	movzwl %ax,%eax
}
  803401:	5d                   	pop    %ebp
  803402:	c3                   	ret    
  803403:	66 90                	xchg   %ax,%ax
  803405:	66 90                	xchg   %ax,%ax
  803407:	66 90                	xchg   %ax,%ax
  803409:	66 90                	xchg   %ax,%ax
  80340b:	66 90                	xchg   %ax,%ax
  80340d:	66 90                	xchg   %ax,%ax
  80340f:	90                   	nop

00803410 <__udivdi3>:
  803410:	55                   	push   %ebp
  803411:	57                   	push   %edi
  803412:	56                   	push   %esi
  803413:	53                   	push   %ebx
  803414:	83 ec 1c             	sub    $0x1c,%esp
  803417:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80341b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80341f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803427:	85 f6                	test   %esi,%esi
  803429:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80342d:	89 ca                	mov    %ecx,%edx
  80342f:	89 f8                	mov    %edi,%eax
  803431:	75 3d                	jne    803470 <__udivdi3+0x60>
  803433:	39 cf                	cmp    %ecx,%edi
  803435:	0f 87 c5 00 00 00    	ja     803500 <__udivdi3+0xf0>
  80343b:	85 ff                	test   %edi,%edi
  80343d:	89 fd                	mov    %edi,%ebp
  80343f:	75 0b                	jne    80344c <__udivdi3+0x3c>
  803441:	b8 01 00 00 00       	mov    $0x1,%eax
  803446:	31 d2                	xor    %edx,%edx
  803448:	f7 f7                	div    %edi
  80344a:	89 c5                	mov    %eax,%ebp
  80344c:	89 c8                	mov    %ecx,%eax
  80344e:	31 d2                	xor    %edx,%edx
  803450:	f7 f5                	div    %ebp
  803452:	89 c1                	mov    %eax,%ecx
  803454:	89 d8                	mov    %ebx,%eax
  803456:	89 cf                	mov    %ecx,%edi
  803458:	f7 f5                	div    %ebp
  80345a:	89 c3                	mov    %eax,%ebx
  80345c:	89 d8                	mov    %ebx,%eax
  80345e:	89 fa                	mov    %edi,%edx
  803460:	83 c4 1c             	add    $0x1c,%esp
  803463:	5b                   	pop    %ebx
  803464:	5e                   	pop    %esi
  803465:	5f                   	pop    %edi
  803466:	5d                   	pop    %ebp
  803467:	c3                   	ret    
  803468:	90                   	nop
  803469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803470:	39 ce                	cmp    %ecx,%esi
  803472:	77 74                	ja     8034e8 <__udivdi3+0xd8>
  803474:	0f bd fe             	bsr    %esi,%edi
  803477:	83 f7 1f             	xor    $0x1f,%edi
  80347a:	0f 84 98 00 00 00    	je     803518 <__udivdi3+0x108>
  803480:	bb 20 00 00 00       	mov    $0x20,%ebx
  803485:	89 f9                	mov    %edi,%ecx
  803487:	89 c5                	mov    %eax,%ebp
  803489:	29 fb                	sub    %edi,%ebx
  80348b:	d3 e6                	shl    %cl,%esi
  80348d:	89 d9                	mov    %ebx,%ecx
  80348f:	d3 ed                	shr    %cl,%ebp
  803491:	89 f9                	mov    %edi,%ecx
  803493:	d3 e0                	shl    %cl,%eax
  803495:	09 ee                	or     %ebp,%esi
  803497:	89 d9                	mov    %ebx,%ecx
  803499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80349d:	89 d5                	mov    %edx,%ebp
  80349f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8034a3:	d3 ed                	shr    %cl,%ebp
  8034a5:	89 f9                	mov    %edi,%ecx
  8034a7:	d3 e2                	shl    %cl,%edx
  8034a9:	89 d9                	mov    %ebx,%ecx
  8034ab:	d3 e8                	shr    %cl,%eax
  8034ad:	09 c2                	or     %eax,%edx
  8034af:	89 d0                	mov    %edx,%eax
  8034b1:	89 ea                	mov    %ebp,%edx
  8034b3:	f7 f6                	div    %esi
  8034b5:	89 d5                	mov    %edx,%ebp
  8034b7:	89 c3                	mov    %eax,%ebx
  8034b9:	f7 64 24 0c          	mull   0xc(%esp)
  8034bd:	39 d5                	cmp    %edx,%ebp
  8034bf:	72 10                	jb     8034d1 <__udivdi3+0xc1>
  8034c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8034c5:	89 f9                	mov    %edi,%ecx
  8034c7:	d3 e6                	shl    %cl,%esi
  8034c9:	39 c6                	cmp    %eax,%esi
  8034cb:	73 07                	jae    8034d4 <__udivdi3+0xc4>
  8034cd:	39 d5                	cmp    %edx,%ebp
  8034cf:	75 03                	jne    8034d4 <__udivdi3+0xc4>
  8034d1:	83 eb 01             	sub    $0x1,%ebx
  8034d4:	31 ff                	xor    %edi,%edi
  8034d6:	89 d8                	mov    %ebx,%eax
  8034d8:	89 fa                	mov    %edi,%edx
  8034da:	83 c4 1c             	add    $0x1c,%esp
  8034dd:	5b                   	pop    %ebx
  8034de:	5e                   	pop    %esi
  8034df:	5f                   	pop    %edi
  8034e0:	5d                   	pop    %ebp
  8034e1:	c3                   	ret    
  8034e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8034e8:	31 ff                	xor    %edi,%edi
  8034ea:	31 db                	xor    %ebx,%ebx
  8034ec:	89 d8                	mov    %ebx,%eax
  8034ee:	89 fa                	mov    %edi,%edx
  8034f0:	83 c4 1c             	add    $0x1c,%esp
  8034f3:	5b                   	pop    %ebx
  8034f4:	5e                   	pop    %esi
  8034f5:	5f                   	pop    %edi
  8034f6:	5d                   	pop    %ebp
  8034f7:	c3                   	ret    
  8034f8:	90                   	nop
  8034f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803500:	89 d8                	mov    %ebx,%eax
  803502:	f7 f7                	div    %edi
  803504:	31 ff                	xor    %edi,%edi
  803506:	89 c3                	mov    %eax,%ebx
  803508:	89 d8                	mov    %ebx,%eax
  80350a:	89 fa                	mov    %edi,%edx
  80350c:	83 c4 1c             	add    $0x1c,%esp
  80350f:	5b                   	pop    %ebx
  803510:	5e                   	pop    %esi
  803511:	5f                   	pop    %edi
  803512:	5d                   	pop    %ebp
  803513:	c3                   	ret    
  803514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803518:	39 ce                	cmp    %ecx,%esi
  80351a:	72 0c                	jb     803528 <__udivdi3+0x118>
  80351c:	31 db                	xor    %ebx,%ebx
  80351e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803522:	0f 87 34 ff ff ff    	ja     80345c <__udivdi3+0x4c>
  803528:	bb 01 00 00 00       	mov    $0x1,%ebx
  80352d:	e9 2a ff ff ff       	jmp    80345c <__udivdi3+0x4c>
  803532:	66 90                	xchg   %ax,%ax
  803534:	66 90                	xchg   %ax,%ax
  803536:	66 90                	xchg   %ax,%ax
  803538:	66 90                	xchg   %ax,%ax
  80353a:	66 90                	xchg   %ax,%ax
  80353c:	66 90                	xchg   %ax,%ax
  80353e:	66 90                	xchg   %ax,%ax

00803540 <__umoddi3>:
  803540:	55                   	push   %ebp
  803541:	57                   	push   %edi
  803542:	56                   	push   %esi
  803543:	53                   	push   %ebx
  803544:	83 ec 1c             	sub    $0x1c,%esp
  803547:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80354b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80354f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803557:	85 d2                	test   %edx,%edx
  803559:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80355d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803561:	89 f3                	mov    %esi,%ebx
  803563:	89 3c 24             	mov    %edi,(%esp)
  803566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80356a:	75 1c                	jne    803588 <__umoddi3+0x48>
  80356c:	39 f7                	cmp    %esi,%edi
  80356e:	76 50                	jbe    8035c0 <__umoddi3+0x80>
  803570:	89 c8                	mov    %ecx,%eax
  803572:	89 f2                	mov    %esi,%edx
  803574:	f7 f7                	div    %edi
  803576:	89 d0                	mov    %edx,%eax
  803578:	31 d2                	xor    %edx,%edx
  80357a:	83 c4 1c             	add    $0x1c,%esp
  80357d:	5b                   	pop    %ebx
  80357e:	5e                   	pop    %esi
  80357f:	5f                   	pop    %edi
  803580:	5d                   	pop    %ebp
  803581:	c3                   	ret    
  803582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803588:	39 f2                	cmp    %esi,%edx
  80358a:	89 d0                	mov    %edx,%eax
  80358c:	77 52                	ja     8035e0 <__umoddi3+0xa0>
  80358e:	0f bd ea             	bsr    %edx,%ebp
  803591:	83 f5 1f             	xor    $0x1f,%ebp
  803594:	75 5a                	jne    8035f0 <__umoddi3+0xb0>
  803596:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80359a:	0f 82 e0 00 00 00    	jb     803680 <__umoddi3+0x140>
  8035a0:	39 0c 24             	cmp    %ecx,(%esp)
  8035a3:	0f 86 d7 00 00 00    	jbe    803680 <__umoddi3+0x140>
  8035a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8035ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8035b1:	83 c4 1c             	add    $0x1c,%esp
  8035b4:	5b                   	pop    %ebx
  8035b5:	5e                   	pop    %esi
  8035b6:	5f                   	pop    %edi
  8035b7:	5d                   	pop    %ebp
  8035b8:	c3                   	ret    
  8035b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035c0:	85 ff                	test   %edi,%edi
  8035c2:	89 fd                	mov    %edi,%ebp
  8035c4:	75 0b                	jne    8035d1 <__umoddi3+0x91>
  8035c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8035cb:	31 d2                	xor    %edx,%edx
  8035cd:	f7 f7                	div    %edi
  8035cf:	89 c5                	mov    %eax,%ebp
  8035d1:	89 f0                	mov    %esi,%eax
  8035d3:	31 d2                	xor    %edx,%edx
  8035d5:	f7 f5                	div    %ebp
  8035d7:	89 c8                	mov    %ecx,%eax
  8035d9:	f7 f5                	div    %ebp
  8035db:	89 d0                	mov    %edx,%eax
  8035dd:	eb 99                	jmp    803578 <__umoddi3+0x38>
  8035df:	90                   	nop
  8035e0:	89 c8                	mov    %ecx,%eax
  8035e2:	89 f2                	mov    %esi,%edx
  8035e4:	83 c4 1c             	add    $0x1c,%esp
  8035e7:	5b                   	pop    %ebx
  8035e8:	5e                   	pop    %esi
  8035e9:	5f                   	pop    %edi
  8035ea:	5d                   	pop    %ebp
  8035eb:	c3                   	ret    
  8035ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035f0:	8b 34 24             	mov    (%esp),%esi
  8035f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8035f8:	89 e9                	mov    %ebp,%ecx
  8035fa:	29 ef                	sub    %ebp,%edi
  8035fc:	d3 e0                	shl    %cl,%eax
  8035fe:	89 f9                	mov    %edi,%ecx
  803600:	89 f2                	mov    %esi,%edx
  803602:	d3 ea                	shr    %cl,%edx
  803604:	89 e9                	mov    %ebp,%ecx
  803606:	09 c2                	or     %eax,%edx
  803608:	89 d8                	mov    %ebx,%eax
  80360a:	89 14 24             	mov    %edx,(%esp)
  80360d:	89 f2                	mov    %esi,%edx
  80360f:	d3 e2                	shl    %cl,%edx
  803611:	89 f9                	mov    %edi,%ecx
  803613:	89 54 24 04          	mov    %edx,0x4(%esp)
  803617:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80361b:	d3 e8                	shr    %cl,%eax
  80361d:	89 e9                	mov    %ebp,%ecx
  80361f:	89 c6                	mov    %eax,%esi
  803621:	d3 e3                	shl    %cl,%ebx
  803623:	89 f9                	mov    %edi,%ecx
  803625:	89 d0                	mov    %edx,%eax
  803627:	d3 e8                	shr    %cl,%eax
  803629:	89 e9                	mov    %ebp,%ecx
  80362b:	09 d8                	or     %ebx,%eax
  80362d:	89 d3                	mov    %edx,%ebx
  80362f:	89 f2                	mov    %esi,%edx
  803631:	f7 34 24             	divl   (%esp)
  803634:	89 d6                	mov    %edx,%esi
  803636:	d3 e3                	shl    %cl,%ebx
  803638:	f7 64 24 04          	mull   0x4(%esp)
  80363c:	39 d6                	cmp    %edx,%esi
  80363e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803642:	89 d1                	mov    %edx,%ecx
  803644:	89 c3                	mov    %eax,%ebx
  803646:	72 08                	jb     803650 <__umoddi3+0x110>
  803648:	75 11                	jne    80365b <__umoddi3+0x11b>
  80364a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80364e:	73 0b                	jae    80365b <__umoddi3+0x11b>
  803650:	2b 44 24 04          	sub    0x4(%esp),%eax
  803654:	1b 14 24             	sbb    (%esp),%edx
  803657:	89 d1                	mov    %edx,%ecx
  803659:	89 c3                	mov    %eax,%ebx
  80365b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80365f:	29 da                	sub    %ebx,%edx
  803661:	19 ce                	sbb    %ecx,%esi
  803663:	89 f9                	mov    %edi,%ecx
  803665:	89 f0                	mov    %esi,%eax
  803667:	d3 e0                	shl    %cl,%eax
  803669:	89 e9                	mov    %ebp,%ecx
  80366b:	d3 ea                	shr    %cl,%edx
  80366d:	89 e9                	mov    %ebp,%ecx
  80366f:	d3 ee                	shr    %cl,%esi
  803671:	09 d0                	or     %edx,%eax
  803673:	89 f2                	mov    %esi,%edx
  803675:	83 c4 1c             	add    $0x1c,%esp
  803678:	5b                   	pop    %ebx
  803679:	5e                   	pop    %esi
  80367a:	5f                   	pop    %edi
  80367b:	5d                   	pop    %ebp
  80367c:	c3                   	ret    
  80367d:	8d 76 00             	lea    0x0(%esi),%esi
  803680:	29 f9                	sub    %edi,%ecx
  803682:	19 d6                	sbb    %edx,%esi
  803684:	89 74 24 04          	mov    %esi,0x4(%esp)
  803688:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80368c:	e9 18 ff ff ff       	jmp    8035a9 <__umoddi3+0x69>
