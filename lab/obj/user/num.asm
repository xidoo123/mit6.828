
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 80 24 80 00       	push   $0x802480
  800062:	e8 e7 16 00 00       	call   80174e <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 8b 11 00 00       	call   80120c <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 85 24 80 00       	push   $0x802485
  800095:	6a 13                	push   $0x13
  800097:	68 a0 24 80 00       	push   $0x8024a0
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 75 10 00 00       	call   801132 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 ab 24 80 00       	push   $0x8024ab
  8000d8:	6a 18                	push   $0x18
  8000da:	68 a0 24 80 00       	push   $0x8024a0
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 c0 	movl   $0x8024c0,0x803004
  8000fb:	24 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 c4 24 80 00       	push   $0x8024c4
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 7c 14 00 00       	call   8015b0 <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 cc 24 80 00       	push   $0x8024cc
  80014b:	6a 27                	push   $0x27
  80014d:	68 a0 24 80 00       	push   $0x8024a0
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 8c 0e 00 00       	call   800ff6 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800190:	e8 73 0a 00 00       	call   800c08 <sys_getenvid>
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
}
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 4b 0e 00 00       	call   801021 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 e7 09 00 00       	call   800bc7 <sys_env_destroy>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 10 0a 00 00       	call   800c08 <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 e8 24 80 00       	push   $0x8024e8
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 0b 29 80 00 	movl   $0x80290b,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 2f 09 00 00       	call   800b8a <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 54 01 00 00       	call   8003f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 d4 08 00 00       	call   800b8a <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f9:	39 d3                	cmp    %edx,%ebx
  8002fb:	72 05                	jb     800302 <printnum+0x30>
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	77 45                	ja     800347 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 18             	pushl  0x18(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	53                   	push   %ebx
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 ba 1e 00 00       	call   8021e0 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 18                	jmp    800351 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	eb 03                	jmp    80034a <printnum+0x78>
  800347:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	7f e8                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	56                   	push   %esi
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035b:	ff 75 e0             	pushl  -0x20(%ebp)
  80035e:	ff 75 dc             	pushl  -0x24(%ebp)
  800361:	ff 75 d8             	pushl  -0x28(%ebp)
  800364:	e8 a7 1f 00 00       	call   802310 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 0b 25 80 00 	movsbl 0x80250b(%eax),%eax
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
}
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800384:	83 fa 01             	cmp    $0x1,%edx
  800387:	7e 0e                	jle    800397 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	8b 52 04             	mov    0x4(%edx),%edx
  800395:	eb 22                	jmp    8003b9 <getuint+0x38>
	else if (lflag)
  800397:	85 d2                	test   %edx,%edx
  800399:	74 10                	je     8003ab <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 02                	mov    (%edx),%eax
  8003a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a9:	eb 0e                	jmp    8003b9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b0:	89 08                	mov    %ecx,(%eax)
  8003b2:	8b 02                	mov    (%edx),%eax
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ca:	73 0a                	jae    8003d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	88 02                	mov    %al,(%edx)
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 10             	pushl  0x10(%ebp)
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 05 00 00 00       	call   8003f5 <vprintfmt>
	va_end(ap);
}
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 2c             	sub    $0x2c,%esp
  8003fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800401:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800404:	8b 7d 10             	mov    0x10(%ebp),%edi
  800407:	eb 12                	jmp    80041b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800409:	85 c0                	test   %eax,%eax
  80040b:	0f 84 89 03 00 00    	je     80079a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	50                   	push   %eax
  800416:	ff d6                	call   *%esi
  800418:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041b:	83 c7 01             	add    $0x1,%edi
  80041e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800422:	83 f8 25             	cmp    $0x25,%eax
  800425:	75 e2                	jne    800409 <vprintfmt+0x14>
  800427:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80042b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800432:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800439:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
  800445:	eb 07                	jmp    80044e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80044a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8d 47 01             	lea    0x1(%edi),%eax
  800451:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800454:	0f b6 07             	movzbl (%edi),%eax
  800457:	0f b6 c8             	movzbl %al,%ecx
  80045a:	83 e8 23             	sub    $0x23,%eax
  80045d:	3c 55                	cmp    $0x55,%al
  80045f:	0f 87 1a 03 00 00    	ja     80077f <vprintfmt+0x38a>
  800465:	0f b6 c0             	movzbl %al,%eax
  800468:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800472:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800476:	eb d6                	jmp    80044e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800483:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800486:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80048a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80048d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800490:	83 fa 09             	cmp    $0x9,%edx
  800493:	77 39                	ja     8004ce <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800495:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800498:	eb e9                	jmp    800483 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ab:	eb 27                	jmp    8004d4 <vprintfmt+0xdf>
  8004ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	0f 49 c8             	cmovns %eax,%ecx
  8004ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c0:	eb 8c                	jmp    80044e <vprintfmt+0x59>
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004cc:	eb 80                	jmp    80044e <vprintfmt+0x59>
  8004ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d8:	0f 89 70 ff ff ff    	jns    80044e <vprintfmt+0x59>
				width = precision, precision = -1;
  8004de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004eb:	e9 5e ff ff ff       	jmp    80044e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f6:	e9 53 ff ff ff       	jmp    80044e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	ff 30                	pushl  (%eax)
  80050a:	ff d6                	call   *%esi
			break;
  80050c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800512:	e9 04 ff ff ff       	jmp    80041b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 00                	mov    (%eax),%eax
  800522:	99                   	cltd   
  800523:	31 d0                	xor    %edx,%eax
  800525:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800527:	83 f8 0f             	cmp    $0xf,%eax
  80052a:	7f 0b                	jg     800537 <vprintfmt+0x142>
  80052c:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	75 18                	jne    80054f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800537:	50                   	push   %eax
  800538:	68 23 25 80 00       	push   $0x802523
  80053d:	53                   	push   %ebx
  80053e:	56                   	push   %esi
  80053f:	e8 94 fe ff ff       	call   8003d8 <printfmt>
  800544:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054a:	e9 cc fe ff ff       	jmp    80041b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054f:	52                   	push   %edx
  800550:	68 d9 28 80 00       	push   $0x8028d9
  800555:	53                   	push   %ebx
  800556:	56                   	push   %esi
  800557:	e8 7c fe ff ff       	call   8003d8 <printfmt>
  80055c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 b4 fe ff ff       	jmp    80041b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800572:	85 ff                	test   %edi,%edi
  800574:	b8 1c 25 80 00       	mov    $0x80251c,%eax
  800579:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80057c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800580:	0f 8e 94 00 00 00    	jle    80061a <vprintfmt+0x225>
  800586:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058a:	0f 84 98 00 00 00    	je     800628 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 d0             	pushl  -0x30(%ebp)
  800596:	57                   	push   %edi
  800597:	e8 86 02 00 00       	call   800822 <strnlen>
  80059c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059f:	29 c1                	sub    %eax,%ecx
  8005a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	eb 0f                	jmp    8005c4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	83 ef 01             	sub    $0x1,%edi
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f ed                	jg     8005b5 <vprintfmt+0x1c0>
  8005c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005cb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d5:	0f 49 c1             	cmovns %ecx,%eax
  8005d8:	29 c1                	sub    %eax,%ecx
  8005da:	89 75 08             	mov    %esi,0x8(%ebp)
  8005dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e3:	89 cb                	mov    %ecx,%ebx
  8005e5:	eb 4d                	jmp    800634 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005eb:	74 1b                	je     800608 <vprintfmt+0x213>
  8005ed:	0f be c0             	movsbl %al,%eax
  8005f0:	83 e8 20             	sub    $0x20,%eax
  8005f3:	83 f8 5e             	cmp    $0x5e,%eax
  8005f6:	76 10                	jbe    800608 <vprintfmt+0x213>
					putch('?', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	ff 75 0c             	pushl  0xc(%ebp)
  8005fe:	6a 3f                	push   $0x3f
  800600:	ff 55 08             	call   *0x8(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	eb 0d                	jmp    800615 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	ff 75 0c             	pushl  0xc(%ebp)
  80060e:	52                   	push   %edx
  80060f:	ff 55 08             	call   *0x8(%ebp)
  800612:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800615:	83 eb 01             	sub    $0x1,%ebx
  800618:	eb 1a                	jmp    800634 <vprintfmt+0x23f>
  80061a:	89 75 08             	mov    %esi,0x8(%ebp)
  80061d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800620:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800623:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800626:	eb 0c                	jmp    800634 <vprintfmt+0x23f>
  800628:	89 75 08             	mov    %esi,0x8(%ebp)
  80062b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800631:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800634:	83 c7 01             	add    $0x1,%edi
  800637:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063b:	0f be d0             	movsbl %al,%edx
  80063e:	85 d2                	test   %edx,%edx
  800640:	74 23                	je     800665 <vprintfmt+0x270>
  800642:	85 f6                	test   %esi,%esi
  800644:	78 a1                	js     8005e7 <vprintfmt+0x1f2>
  800646:	83 ee 01             	sub    $0x1,%esi
  800649:	79 9c                	jns    8005e7 <vprintfmt+0x1f2>
  80064b:	89 df                	mov    %ebx,%edi
  80064d:	8b 75 08             	mov    0x8(%ebp),%esi
  800650:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800653:	eb 18                	jmp    80066d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 20                	push   $0x20
  80065b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065d:	83 ef 01             	sub    $0x1,%edi
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb 08                	jmp    80066d <vprintfmt+0x278>
  800665:	89 df                	mov    %ebx,%edi
  800667:	8b 75 08             	mov    0x8(%ebp),%esi
  80066a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066d:	85 ff                	test   %edi,%edi
  80066f:	7f e4                	jg     800655 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800674:	e9 a2 fd ff ff       	jmp    80041b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800679:	83 fa 01             	cmp    $0x1,%edx
  80067c:	7e 16                	jle    800694 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 08             	lea    0x8(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 50 04             	mov    0x4(%eax),%edx
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800692:	eb 32                	jmp    8006c6 <vprintfmt+0x2d1>
	else if (lflag)
  800694:	85 d2                	test   %edx,%edx
  800696:	74 18                	je     8006b0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a6:	89 c1                	mov    %eax,%ecx
  8006a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ae:	eb 16                	jmp    8006c6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 04             	lea    0x4(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006be:	89 c1                	mov    %eax,%ecx
  8006c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d5:	79 74                	jns    80074b <vprintfmt+0x356>
				putch('-', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	6a 2d                	push   $0x2d
  8006dd:	ff d6                	call   *%esi
				num = -(long long) num;
  8006df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e5:	f7 d8                	neg    %eax
  8006e7:	83 d2 00             	adc    $0x0,%edx
  8006ea:	f7 da                	neg    %edx
  8006ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f4:	eb 55                	jmp    80074b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 83 fc ff ff       	call   800381 <getuint>
			base = 10;
  8006fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800703:	eb 46                	jmp    80074b <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
  800708:	e8 74 fc ff ff       	call   800381 <getuint>
			base = 8;
  80070d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800712:	eb 37                	jmp    80074b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 30                	push   $0x30
  80071a:	ff d6                	call   *%esi
			putch('x', putdat);
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 78                	push   $0x78
  800722:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800734:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800737:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80073c:	eb 0d                	jmp    80074b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073e:	8d 45 14             	lea    0x14(%ebp),%eax
  800741:	e8 3b fc ff ff       	call   800381 <getuint>
			base = 16;
  800746:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074b:	83 ec 0c             	sub    $0xc,%esp
  80074e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800752:	57                   	push   %edi
  800753:	ff 75 e0             	pushl  -0x20(%ebp)
  800756:	51                   	push   %ecx
  800757:	52                   	push   %edx
  800758:	50                   	push   %eax
  800759:	89 da                	mov    %ebx,%edx
  80075b:	89 f0                	mov    %esi,%eax
  80075d:	e8 70 fb ff ff       	call   8002d2 <printnum>
			break;
  800762:	83 c4 20             	add    $0x20,%esp
  800765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800768:	e9 ae fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	51                   	push   %ecx
  800772:	ff d6                	call   *%esi
			break;
  800774:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80077a:	e9 9c fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 25                	push   $0x25
  800785:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	eb 03                	jmp    80078f <vprintfmt+0x39a>
  80078c:	83 ef 01             	sub    $0x1,%edi
  80078f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800793:	75 f7                	jne    80078c <vprintfmt+0x397>
  800795:	e9 81 fc ff ff       	jmp    80041b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80079a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5f                   	pop    %edi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 18             	sub    $0x18,%esp
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	74 26                	je     8007e9 <vsnprintf+0x47>
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	7e 22                	jle    8007e9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c7:	ff 75 14             	pushl  0x14(%ebp)
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	68 bb 03 80 00       	push   $0x8003bb
  8007d6:	e8 1a fc ff ff       	call   8003f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	eb 05                	jmp    8007ee <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f9:	50                   	push   %eax
  8007fa:	ff 75 10             	pushl  0x10(%ebp)
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	ff 75 08             	pushl  0x8(%ebp)
  800803:	e8 9a ff ff ff       	call   8007a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	eb 03                	jmp    80081a <strlen+0x10>
		n++;
  800817:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80081a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081e:	75 f7                	jne    800817 <strlen+0xd>
		n++;
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800828:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	ba 00 00 00 00       	mov    $0x0,%edx
  800830:	eb 03                	jmp    800835 <strnlen+0x13>
		n++;
  800832:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800835:	39 c2                	cmp    %eax,%edx
  800837:	74 08                	je     800841 <strnlen+0x1f>
  800839:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80083d:	75 f3                	jne    800832 <strnlen+0x10>
  80083f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084d:	89 c2                	mov    %eax,%edx
  80084f:	83 c2 01             	add    $0x1,%edx
  800852:	83 c1 01             	add    $0x1,%ecx
  800855:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800859:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085c:	84 db                	test   %bl,%bl
  80085e:	75 ef                	jne    80084f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086a:	53                   	push   %ebx
  80086b:	e8 9a ff ff ff       	call   80080a <strlen>
  800870:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800873:	ff 75 0c             	pushl  0xc(%ebp)
  800876:	01 d8                	add    %ebx,%eax
  800878:	50                   	push   %eax
  800879:	e8 c5 ff ff ff       	call   800843 <strcpy>
	return dst;
}
  80087e:	89 d8                	mov    %ebx,%eax
  800880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
  80088a:	8b 75 08             	mov    0x8(%ebp),%esi
  80088d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800890:	89 f3                	mov    %esi,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800895:	89 f2                	mov    %esi,%edx
  800897:	eb 0f                	jmp    8008a8 <strncpy+0x23>
		*dst++ = *src;
  800899:	83 c2 01             	add    $0x1,%edx
  80089c:	0f b6 01             	movzbl (%ecx),%eax
  80089f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a8:	39 da                	cmp    %ebx,%edx
  8008aa:	75 ed                	jne    800899 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ac:	89 f0                	mov    %esi,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c2:	85 d2                	test   %edx,%edx
  8008c4:	74 21                	je     8008e7 <strlcpy+0x35>
  8008c6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ca:	89 f2                	mov    %esi,%edx
  8008cc:	eb 09                	jmp    8008d7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	83 c1 01             	add    $0x1,%ecx
  8008d4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d7:	39 c2                	cmp    %eax,%edx
  8008d9:	74 09                	je     8008e4 <strlcpy+0x32>
  8008db:	0f b6 19             	movzbl (%ecx),%ebx
  8008de:	84 db                	test   %bl,%bl
  8008e0:	75 ec                	jne    8008ce <strlcpy+0x1c>
  8008e2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e7:	29 f0                	sub    %esi,%eax
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f6:	eb 06                	jmp    8008fe <strcmp+0x11>
		p++, q++;
  8008f8:	83 c1 01             	add    $0x1,%ecx
  8008fb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fe:	0f b6 01             	movzbl (%ecx),%eax
  800901:	84 c0                	test   %al,%al
  800903:	74 04                	je     800909 <strcmp+0x1c>
  800905:	3a 02                	cmp    (%edx),%al
  800907:	74 ef                	je     8008f8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800909:	0f b6 c0             	movzbl %al,%eax
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	29 d0                	sub    %edx,%eax
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091d:	89 c3                	mov    %eax,%ebx
  80091f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800922:	eb 06                	jmp    80092a <strncmp+0x17>
		n--, p++, q++;
  800924:	83 c0 01             	add    $0x1,%eax
  800927:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092a:	39 d8                	cmp    %ebx,%eax
  80092c:	74 15                	je     800943 <strncmp+0x30>
  80092e:	0f b6 08             	movzbl (%eax),%ecx
  800931:	84 c9                	test   %cl,%cl
  800933:	74 04                	je     800939 <strncmp+0x26>
  800935:	3a 0a                	cmp    (%edx),%cl
  800937:	74 eb                	je     800924 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800939:	0f b6 00             	movzbl (%eax),%eax
  80093c:	0f b6 12             	movzbl (%edx),%edx
  80093f:	29 d0                	sub    %edx,%eax
  800941:	eb 05                	jmp    800948 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800948:	5b                   	pop    %ebx
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	eb 07                	jmp    80095e <strchr+0x13>
		if (*s == c)
  800957:	38 ca                	cmp    %cl,%dl
  800959:	74 0f                	je     80096a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	0f b6 10             	movzbl (%eax),%edx
  800961:	84 d2                	test   %dl,%dl
  800963:	75 f2                	jne    800957 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800976:	eb 03                	jmp    80097b <strfind+0xf>
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097e:	38 ca                	cmp    %cl,%dl
  800980:	74 04                	je     800986 <strfind+0x1a>
  800982:	84 d2                	test   %dl,%dl
  800984:	75 f2                	jne    800978 <strfind+0xc>
			break;
	return (char *) s;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800991:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800994:	85 c9                	test   %ecx,%ecx
  800996:	74 36                	je     8009ce <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800998:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099e:	75 28                	jne    8009c8 <memset+0x40>
  8009a0:	f6 c1 03             	test   $0x3,%cl
  8009a3:	75 23                	jne    8009c8 <memset+0x40>
		c &= 0xFF;
  8009a5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a9:	89 d3                	mov    %edx,%ebx
  8009ab:	c1 e3 08             	shl    $0x8,%ebx
  8009ae:	89 d6                	mov    %edx,%esi
  8009b0:	c1 e6 18             	shl    $0x18,%esi
  8009b3:	89 d0                	mov    %edx,%eax
  8009b5:	c1 e0 10             	shl    $0x10,%eax
  8009b8:	09 f0                	or     %esi,%eax
  8009ba:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009bc:	89 d8                	mov    %ebx,%eax
  8009be:	09 d0                	or     %edx,%eax
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
  8009c3:	fc                   	cld    
  8009c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c6:	eb 06                	jmp    8009ce <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	fc                   	cld    
  8009cc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ce:	89 f8                	mov    %edi,%eax
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e3:	39 c6                	cmp    %eax,%esi
  8009e5:	73 35                	jae    800a1c <memmove+0x47>
  8009e7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ea:	39 d0                	cmp    %edx,%eax
  8009ec:	73 2e                	jae    800a1c <memmove+0x47>
		s += n;
		d += n;
  8009ee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f1:	89 d6                	mov    %edx,%esi
  8009f3:	09 fe                	or     %edi,%esi
  8009f5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fb:	75 13                	jne    800a10 <memmove+0x3b>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 0e                	jne    800a10 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a02:	83 ef 04             	sub    $0x4,%edi
  800a05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a08:	c1 e9 02             	shr    $0x2,%ecx
  800a0b:	fd                   	std    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 09                	jmp    800a19 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a10:	83 ef 01             	sub    $0x1,%edi
  800a13:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a16:	fd                   	std    
  800a17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a19:	fc                   	cld    
  800a1a:	eb 1d                	jmp    800a39 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1c:	89 f2                	mov    %esi,%edx
  800a1e:	09 c2                	or     %eax,%edx
  800a20:	f6 c2 03             	test   $0x3,%dl
  800a23:	75 0f                	jne    800a34 <memmove+0x5f>
  800a25:	f6 c1 03             	test   $0x3,%cl
  800a28:	75 0a                	jne    800a34 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a2a:	c1 e9 02             	shr    $0x2,%ecx
  800a2d:	89 c7                	mov    %eax,%edi
  800a2f:	fc                   	cld    
  800a30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a32:	eb 05                	jmp    800a39 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a34:	89 c7                	mov    %eax,%edi
  800a36:	fc                   	cld    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a40:	ff 75 10             	pushl  0x10(%ebp)
  800a43:	ff 75 0c             	pushl  0xc(%ebp)
  800a46:	ff 75 08             	pushl  0x8(%ebp)
  800a49:	e8 87 ff ff ff       	call   8009d5 <memmove>
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5b:	89 c6                	mov    %eax,%esi
  800a5d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a60:	eb 1a                	jmp    800a7c <memcmp+0x2c>
		if (*s1 != *s2)
  800a62:	0f b6 08             	movzbl (%eax),%ecx
  800a65:	0f b6 1a             	movzbl (%edx),%ebx
  800a68:	38 d9                	cmp    %bl,%cl
  800a6a:	74 0a                	je     800a76 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a6c:	0f b6 c1             	movzbl %cl,%eax
  800a6f:	0f b6 db             	movzbl %bl,%ebx
  800a72:	29 d8                	sub    %ebx,%eax
  800a74:	eb 0f                	jmp    800a85 <memcmp+0x35>
		s1++, s2++;
  800a76:	83 c0 01             	add    $0x1,%eax
  800a79:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7c:	39 f0                	cmp    %esi,%eax
  800a7e:	75 e2                	jne    800a62 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	53                   	push   %ebx
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a90:	89 c1                	mov    %eax,%ecx
  800a92:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a95:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a99:	eb 0a                	jmp    800aa5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a9b:	0f b6 10             	movzbl (%eax),%edx
  800a9e:	39 da                	cmp    %ebx,%edx
  800aa0:	74 07                	je     800aa9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	39 c8                	cmp    %ecx,%eax
  800aa7:	72 f2                	jb     800a9b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab8:	eb 03                	jmp    800abd <strtol+0x11>
		s++;
  800aba:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abd:	0f b6 01             	movzbl (%ecx),%eax
  800ac0:	3c 20                	cmp    $0x20,%al
  800ac2:	74 f6                	je     800aba <strtol+0xe>
  800ac4:	3c 09                	cmp    $0x9,%al
  800ac6:	74 f2                	je     800aba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac8:	3c 2b                	cmp    $0x2b,%al
  800aca:	75 0a                	jne    800ad6 <strtol+0x2a>
		s++;
  800acc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad4:	eb 11                	jmp    800ae7 <strtol+0x3b>
  800ad6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800adb:	3c 2d                	cmp    $0x2d,%al
  800add:	75 08                	jne    800ae7 <strtol+0x3b>
		s++, neg = 1;
  800adf:	83 c1 01             	add    $0x1,%ecx
  800ae2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aed:	75 15                	jne    800b04 <strtol+0x58>
  800aef:	80 39 30             	cmpb   $0x30,(%ecx)
  800af2:	75 10                	jne    800b04 <strtol+0x58>
  800af4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af8:	75 7c                	jne    800b76 <strtol+0xca>
		s += 2, base = 16;
  800afa:	83 c1 02             	add    $0x2,%ecx
  800afd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b02:	eb 16                	jmp    800b1a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b04:	85 db                	test   %ebx,%ebx
  800b06:	75 12                	jne    800b1a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b08:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b10:	75 08                	jne    800b1a <strtol+0x6e>
		s++, base = 8;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b22:	0f b6 11             	movzbl (%ecx),%edx
  800b25:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b28:	89 f3                	mov    %esi,%ebx
  800b2a:	80 fb 09             	cmp    $0x9,%bl
  800b2d:	77 08                	ja     800b37 <strtol+0x8b>
			dig = *s - '0';
  800b2f:	0f be d2             	movsbl %dl,%edx
  800b32:	83 ea 30             	sub    $0x30,%edx
  800b35:	eb 22                	jmp    800b59 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b37:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b3a:	89 f3                	mov    %esi,%ebx
  800b3c:	80 fb 19             	cmp    $0x19,%bl
  800b3f:	77 08                	ja     800b49 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b41:	0f be d2             	movsbl %dl,%edx
  800b44:	83 ea 57             	sub    $0x57,%edx
  800b47:	eb 10                	jmp    800b59 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b49:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b4c:	89 f3                	mov    %esi,%ebx
  800b4e:	80 fb 19             	cmp    $0x19,%bl
  800b51:	77 16                	ja     800b69 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b53:	0f be d2             	movsbl %dl,%edx
  800b56:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b59:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5c:	7d 0b                	jge    800b69 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b5e:	83 c1 01             	add    $0x1,%ecx
  800b61:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b65:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b67:	eb b9                	jmp    800b22 <strtol+0x76>

	if (endptr)
  800b69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6d:	74 0d                	je     800b7c <strtol+0xd0>
		*endptr = (char *) s;
  800b6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b72:	89 0e                	mov    %ecx,(%esi)
  800b74:	eb 06                	jmp    800b7c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b76:	85 db                	test   %ebx,%ebx
  800b78:	74 98                	je     800b12 <strtol+0x66>
  800b7a:	eb 9e                	jmp    800b1a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b7c:	89 c2                	mov    %eax,%edx
  800b7e:	f7 da                	neg    %edx
  800b80:	85 ff                	test   %edi,%edi
  800b82:	0f 45 c2             	cmovne %edx,%eax
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b90:	b8 00 00 00 00       	mov    $0x0,%eax
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	89 c3                	mov    %eax,%ebx
  800b9d:	89 c7                	mov    %eax,%edi
  800b9f:	89 c6                	mov    %eax,%esi
  800ba1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb8:	89 d1                	mov    %edx,%ecx
  800bba:	89 d3                	mov    %edx,%ebx
  800bbc:	89 d7                	mov    %edx,%edi
  800bbe:	89 d6                	mov    %edx,%esi
  800bc0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 cb                	mov    %ecx,%ebx
  800bdf:	89 cf                	mov    %ecx,%edi
  800be1:	89 ce                	mov    %ecx,%esi
  800be3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 03                	push   $0x3
  800bef:	68 ff 27 80 00       	push   $0x8027ff
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 1c 28 80 00       	push   $0x80281c
  800bfb:	e8 e5 f5 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 02 00 00 00       	mov    $0x2,%eax
  800c18:	89 d1                	mov    %edx,%ecx
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_yield>:

void
sys_yield(void)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c32:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c37:	89 d1                	mov    %edx,%ecx
  800c39:	89 d3                	mov    %edx,%ebx
  800c3b:	89 d7                	mov    %edx,%edi
  800c3d:	89 d6                	mov    %edx,%esi
  800c3f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	be 00 00 00 00       	mov    $0x0,%esi
  800c54:	b8 04 00 00 00       	mov    $0x4,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c62:	89 f7                	mov    %esi,%edi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 04                	push   $0x4
  800c70:	68 ff 27 80 00       	push   $0x8027ff
  800c75:	6a 23                	push   $0x23
  800c77:	68 1c 28 80 00       	push   $0x80281c
  800c7c:	e8 64 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	b8 05 00 00 00       	mov    $0x5,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 05                	push   $0x5
  800cb2:	68 ff 27 80 00       	push   $0x8027ff
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 1c 28 80 00       	push   $0x80281c
  800cbe:	e8 22 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 06                	push   $0x6
  800cf4:	68 ff 27 80 00       	push   $0x8027ff
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 1c 28 80 00       	push   $0x80281c
  800d00:	e8 e0 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 17                	jle    800d47 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 08                	push   $0x8
  800d36:	68 ff 27 80 00       	push   $0x8027ff
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 1c 28 80 00       	push   $0x80281c
  800d42:	e8 9e f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 17                	jle    800d89 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	50                   	push   %eax
  800d76:	6a 09                	push   $0x9
  800d78:	68 ff 27 80 00       	push   $0x8027ff
  800d7d:	6a 23                	push   $0x23
  800d7f:	68 1c 28 80 00       	push   $0x80281c
  800d84:	e8 5c f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	89 df                	mov    %ebx,%edi
  800dac:	89 de                	mov    %ebx,%esi
  800dae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db0:	85 c0                	test   %eax,%eax
  800db2:	7e 17                	jle    800dcb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 0a                	push   $0xa
  800dba:	68 ff 27 80 00       	push   $0x8027ff
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 1c 28 80 00       	push   $0x80281c
  800dc6:	e8 1a f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	be 00 00 00 00       	mov    $0x0,%esi
  800dde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800def:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e04:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	89 cb                	mov    %ecx,%ebx
  800e0e:	89 cf                	mov    %ecx,%edi
  800e10:	89 ce                	mov    %ecx,%esi
  800e12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 17                	jle    800e2f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 0d                	push   $0xd
  800e1e:	68 ff 27 80 00       	push   $0x8027ff
  800e23:	6a 23                	push   $0x23
  800e25:	68 1c 28 80 00       	push   $0x80281c
  800e2a:	e8 b6 f3 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e42:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e47:	89 d1                	mov    %edx,%ecx
  800e49:	89 d3                	mov    %edx,%ebx
  800e4b:	89 d7                	mov    %edx,%edi
  800e4d:	89 d6                	mov    %edx,%esi
  800e4f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e61:	c1 e8 0c             	shr    $0xc,%eax
}
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e76:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e83:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e88:	89 c2                	mov    %eax,%edx
  800e8a:	c1 ea 16             	shr    $0x16,%edx
  800e8d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e94:	f6 c2 01             	test   $0x1,%dl
  800e97:	74 11                	je     800eaa <fd_alloc+0x2d>
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	c1 ea 0c             	shr    $0xc,%edx
  800e9e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea5:	f6 c2 01             	test   $0x1,%dl
  800ea8:	75 09                	jne    800eb3 <fd_alloc+0x36>
			*fd_store = fd;
  800eaa:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb1:	eb 17                	jmp    800eca <fd_alloc+0x4d>
  800eb3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ebd:	75 c9                	jne    800e88 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ebf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ec5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ed2:	83 f8 1f             	cmp    $0x1f,%eax
  800ed5:	77 36                	ja     800f0d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed7:	c1 e0 0c             	shl    $0xc,%eax
  800eda:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800edf:	89 c2                	mov    %eax,%edx
  800ee1:	c1 ea 16             	shr    $0x16,%edx
  800ee4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eeb:	f6 c2 01             	test   $0x1,%dl
  800eee:	74 24                	je     800f14 <fd_lookup+0x48>
  800ef0:	89 c2                	mov    %eax,%edx
  800ef2:	c1 ea 0c             	shr    $0xc,%edx
  800ef5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efc:	f6 c2 01             	test   $0x1,%dl
  800eff:	74 1a                	je     800f1b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f04:	89 02                	mov    %eax,(%edx)
	return 0;
  800f06:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0b:	eb 13                	jmp    800f20 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f12:	eb 0c                	jmp    800f20 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f19:	eb 05                	jmp    800f20 <fd_lookup+0x54>
  800f1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 08             	sub    $0x8,%esp
  800f28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2b:	ba ac 28 80 00       	mov    $0x8028ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f30:	eb 13                	jmp    800f45 <dev_lookup+0x23>
  800f32:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f35:	39 08                	cmp    %ecx,(%eax)
  800f37:	75 0c                	jne    800f45 <dev_lookup+0x23>
			*dev = devtab[i];
  800f39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f43:	eb 2e                	jmp    800f73 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f45:	8b 02                	mov    (%edx),%eax
  800f47:	85 c0                	test   %eax,%eax
  800f49:	75 e7                	jne    800f32 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f4b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800f50:	8b 40 48             	mov    0x48(%eax),%eax
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	51                   	push   %ecx
  800f57:	50                   	push   %eax
  800f58:	68 2c 28 80 00       	push   $0x80282c
  800f5d:	e8 5c f3 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800f62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
  800f7a:	83 ec 10             	sub    $0x10,%esp
  800f7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f86:	50                   	push   %eax
  800f87:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f8d:	c1 e8 0c             	shr    $0xc,%eax
  800f90:	50                   	push   %eax
  800f91:	e8 36 ff ff ff       	call   800ecc <fd_lookup>
  800f96:	83 c4 08             	add    $0x8,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 05                	js     800fa2 <fd_close+0x2d>
	    || fd != fd2)
  800f9d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fa0:	74 0c                	je     800fae <fd_close+0x39>
		return (must_exist ? r : 0);
  800fa2:	84 db                	test   %bl,%bl
  800fa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa9:	0f 44 c2             	cmove  %edx,%eax
  800fac:	eb 41                	jmp    800fef <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fae:	83 ec 08             	sub    $0x8,%esp
  800fb1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	ff 36                	pushl  (%esi)
  800fb7:	e8 66 ff ff ff       	call   800f22 <dev_lookup>
  800fbc:	89 c3                	mov    %eax,%ebx
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 1a                	js     800fdf <fd_close+0x6a>
		if (dev->dev_close)
  800fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	74 0b                	je     800fdf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fd4:	83 ec 0c             	sub    $0xc,%esp
  800fd7:	56                   	push   %esi
  800fd8:	ff d0                	call   *%eax
  800fda:	89 c3                	mov    %eax,%ebx
  800fdc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	56                   	push   %esi
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 e1 fc ff ff       	call   800ccb <sys_page_unmap>
	return r;
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	89 d8                	mov    %ebx,%eax
}
  800fef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ffc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	ff 75 08             	pushl  0x8(%ebp)
  801003:	e8 c4 fe ff ff       	call   800ecc <fd_lookup>
  801008:	83 c4 08             	add    $0x8,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	78 10                	js     80101f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	6a 01                	push   $0x1
  801014:	ff 75 f4             	pushl  -0xc(%ebp)
  801017:	e8 59 ff ff ff       	call   800f75 <fd_close>
  80101c:	83 c4 10             	add    $0x10,%esp
}
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <close_all>:

void
close_all(void)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	53                   	push   %ebx
  801025:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801028:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	53                   	push   %ebx
  801031:	e8 c0 ff ff ff       	call   800ff6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801036:	83 c3 01             	add    $0x1,%ebx
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	83 fb 20             	cmp    $0x20,%ebx
  80103f:	75 ec                	jne    80102d <close_all+0xc>
		close(i);
}
  801041:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801044:	c9                   	leave  
  801045:	c3                   	ret    

00801046 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	57                   	push   %edi
  80104a:	56                   	push   %esi
  80104b:	53                   	push   %ebx
  80104c:	83 ec 2c             	sub    $0x2c,%esp
  80104f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801052:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801055:	50                   	push   %eax
  801056:	ff 75 08             	pushl  0x8(%ebp)
  801059:	e8 6e fe ff ff       	call   800ecc <fd_lookup>
  80105e:	83 c4 08             	add    $0x8,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	0f 88 c1 00 00 00    	js     80112a <dup+0xe4>
		return r;
	close(newfdnum);
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	56                   	push   %esi
  80106d:	e8 84 ff ff ff       	call   800ff6 <close>

	newfd = INDEX2FD(newfdnum);
  801072:	89 f3                	mov    %esi,%ebx
  801074:	c1 e3 0c             	shl    $0xc,%ebx
  801077:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80107d:	83 c4 04             	add    $0x4,%esp
  801080:	ff 75 e4             	pushl  -0x1c(%ebp)
  801083:	e8 de fd ff ff       	call   800e66 <fd2data>
  801088:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80108a:	89 1c 24             	mov    %ebx,(%esp)
  80108d:	e8 d4 fd ff ff       	call   800e66 <fd2data>
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801098:	89 f8                	mov    %edi,%eax
  80109a:	c1 e8 16             	shr    $0x16,%eax
  80109d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a4:	a8 01                	test   $0x1,%al
  8010a6:	74 37                	je     8010df <dup+0x99>
  8010a8:	89 f8                	mov    %edi,%eax
  8010aa:	c1 e8 0c             	shr    $0xc,%eax
  8010ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b4:	f6 c2 01             	test   $0x1,%dl
  8010b7:	74 26                	je     8010df <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c8:	50                   	push   %eax
  8010c9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cc:	6a 00                	push   $0x0
  8010ce:	57                   	push   %edi
  8010cf:	6a 00                	push   $0x0
  8010d1:	e8 b3 fb ff ff       	call   800c89 <sys_page_map>
  8010d6:	89 c7                	mov    %eax,%edi
  8010d8:	83 c4 20             	add    $0x20,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 2e                	js     80110d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010e2:	89 d0                	mov    %edx,%eax
  8010e4:	c1 e8 0c             	shr    $0xc,%eax
  8010e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ee:	83 ec 0c             	sub    $0xc,%esp
  8010f1:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f6:	50                   	push   %eax
  8010f7:	53                   	push   %ebx
  8010f8:	6a 00                	push   $0x0
  8010fa:	52                   	push   %edx
  8010fb:	6a 00                	push   $0x0
  8010fd:	e8 87 fb ff ff       	call   800c89 <sys_page_map>
  801102:	89 c7                	mov    %eax,%edi
  801104:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801107:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801109:	85 ff                	test   %edi,%edi
  80110b:	79 1d                	jns    80112a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80110d:	83 ec 08             	sub    $0x8,%esp
  801110:	53                   	push   %ebx
  801111:	6a 00                	push   $0x0
  801113:	e8 b3 fb ff ff       	call   800ccb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801118:	83 c4 08             	add    $0x8,%esp
  80111b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111e:	6a 00                	push   $0x0
  801120:	e8 a6 fb ff ff       	call   800ccb <sys_page_unmap>
	return r;
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	89 f8                	mov    %edi,%eax
}
  80112a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	53                   	push   %ebx
  801136:	83 ec 14             	sub    $0x14,%esp
  801139:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80113c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113f:	50                   	push   %eax
  801140:	53                   	push   %ebx
  801141:	e8 86 fd ff ff       	call   800ecc <fd_lookup>
  801146:	83 c4 08             	add    $0x8,%esp
  801149:	89 c2                	mov    %eax,%edx
  80114b:	85 c0                	test   %eax,%eax
  80114d:	78 6d                	js     8011bc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114f:	83 ec 08             	sub    $0x8,%esp
  801152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801155:	50                   	push   %eax
  801156:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801159:	ff 30                	pushl  (%eax)
  80115b:	e8 c2 fd ff ff       	call   800f22 <dev_lookup>
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	78 4c                	js     8011b3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801167:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80116a:	8b 42 08             	mov    0x8(%edx),%eax
  80116d:	83 e0 03             	and    $0x3,%eax
  801170:	83 f8 01             	cmp    $0x1,%eax
  801173:	75 21                	jne    801196 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801175:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80117a:	8b 40 48             	mov    0x48(%eax),%eax
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	53                   	push   %ebx
  801181:	50                   	push   %eax
  801182:	68 70 28 80 00       	push   $0x802870
  801187:	e8 32 f1 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801194:	eb 26                	jmp    8011bc <read+0x8a>
	}
	if (!dev->dev_read)
  801196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801199:	8b 40 08             	mov    0x8(%eax),%eax
  80119c:	85 c0                	test   %eax,%eax
  80119e:	74 17                	je     8011b7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	ff 75 10             	pushl  0x10(%ebp)
  8011a6:	ff 75 0c             	pushl  0xc(%ebp)
  8011a9:	52                   	push   %edx
  8011aa:	ff d0                	call   *%eax
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	eb 09                	jmp    8011bc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	eb 05                	jmp    8011bc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011bc:	89 d0                	mov    %edx,%eax
  8011be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c1:	c9                   	leave  
  8011c2:	c3                   	ret    

008011c3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	57                   	push   %edi
  8011c7:	56                   	push   %esi
  8011c8:	53                   	push   %ebx
  8011c9:	83 ec 0c             	sub    $0xc,%esp
  8011cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d7:	eb 21                	jmp    8011fa <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d9:	83 ec 04             	sub    $0x4,%esp
  8011dc:	89 f0                	mov    %esi,%eax
  8011de:	29 d8                	sub    %ebx,%eax
  8011e0:	50                   	push   %eax
  8011e1:	89 d8                	mov    %ebx,%eax
  8011e3:	03 45 0c             	add    0xc(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	57                   	push   %edi
  8011e8:	e8 45 ff ff ff       	call   801132 <read>
		if (m < 0)
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 10                	js     801204 <readn+0x41>
			return m;
		if (m == 0)
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	74 0a                	je     801202 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f8:	01 c3                	add    %eax,%ebx
  8011fa:	39 f3                	cmp    %esi,%ebx
  8011fc:	72 db                	jb     8011d9 <readn+0x16>
  8011fe:	89 d8                	mov    %ebx,%eax
  801200:	eb 02                	jmp    801204 <readn+0x41>
  801202:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801207:	5b                   	pop    %ebx
  801208:	5e                   	pop    %esi
  801209:	5f                   	pop    %edi
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	53                   	push   %ebx
  801210:	83 ec 14             	sub    $0x14,%esp
  801213:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801216:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	53                   	push   %ebx
  80121b:	e8 ac fc ff ff       	call   800ecc <fd_lookup>
  801220:	83 c4 08             	add    $0x8,%esp
  801223:	89 c2                	mov    %eax,%edx
  801225:	85 c0                	test   %eax,%eax
  801227:	78 68                	js     801291 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801233:	ff 30                	pushl  (%eax)
  801235:	e8 e8 fc ff ff       	call   800f22 <dev_lookup>
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 47                	js     801288 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801244:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801248:	75 21                	jne    80126b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80124a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80124f:	8b 40 48             	mov    0x48(%eax),%eax
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	53                   	push   %ebx
  801256:	50                   	push   %eax
  801257:	68 8c 28 80 00       	push   $0x80288c
  80125c:	e8 5d f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801269:	eb 26                	jmp    801291 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80126b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126e:	8b 52 0c             	mov    0xc(%edx),%edx
  801271:	85 d2                	test   %edx,%edx
  801273:	74 17                	je     80128c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801275:	83 ec 04             	sub    $0x4,%esp
  801278:	ff 75 10             	pushl  0x10(%ebp)
  80127b:	ff 75 0c             	pushl  0xc(%ebp)
  80127e:	50                   	push   %eax
  80127f:	ff d2                	call   *%edx
  801281:	89 c2                	mov    %eax,%edx
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	eb 09                	jmp    801291 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801288:	89 c2                	mov    %eax,%edx
  80128a:	eb 05                	jmp    801291 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80128c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801291:	89 d0                	mov    %edx,%eax
  801293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <seek>:

int
seek(int fdnum, off_t offset)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 08             	pushl  0x8(%ebp)
  8012a5:	e8 22 fc ff ff       	call   800ecc <fd_lookup>
  8012aa:	83 c4 08             	add    $0x8,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 0e                	js     8012bf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 14             	sub    $0x14,%esp
  8012c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ce:	50                   	push   %eax
  8012cf:	53                   	push   %ebx
  8012d0:	e8 f7 fb ff ff       	call   800ecc <fd_lookup>
  8012d5:	83 c4 08             	add    $0x8,%esp
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 65                	js     801343 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e4:	50                   	push   %eax
  8012e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e8:	ff 30                	pushl  (%eax)
  8012ea:	e8 33 fc ff ff       	call   800f22 <dev_lookup>
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 44                	js     80133a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fd:	75 21                	jne    801320 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ff:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801304:	8b 40 48             	mov    0x48(%eax),%eax
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	53                   	push   %ebx
  80130b:	50                   	push   %eax
  80130c:	68 4c 28 80 00       	push   $0x80284c
  801311:	e8 a8 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80131e:	eb 23                	jmp    801343 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801320:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801323:	8b 52 18             	mov    0x18(%edx),%edx
  801326:	85 d2                	test   %edx,%edx
  801328:	74 14                	je     80133e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	ff 75 0c             	pushl  0xc(%ebp)
  801330:	50                   	push   %eax
  801331:	ff d2                	call   *%edx
  801333:	89 c2                	mov    %eax,%edx
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	eb 09                	jmp    801343 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133a:	89 c2                	mov    %eax,%edx
  80133c:	eb 05                	jmp    801343 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80133e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801343:	89 d0                	mov    %edx,%eax
  801345:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	53                   	push   %ebx
  80134e:	83 ec 14             	sub    $0x14,%esp
  801351:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801354:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	ff 75 08             	pushl  0x8(%ebp)
  80135b:	e8 6c fb ff ff       	call   800ecc <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	89 c2                	mov    %eax,%edx
  801365:	85 c0                	test   %eax,%eax
  801367:	78 58                	js     8013c1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136f:	50                   	push   %eax
  801370:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801373:	ff 30                	pushl  (%eax)
  801375:	e8 a8 fb ff ff       	call   800f22 <dev_lookup>
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 37                	js     8013b8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801381:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801384:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801388:	74 32                	je     8013bc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80138a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80138d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801394:	00 00 00 
	stat->st_isdir = 0;
  801397:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80139e:	00 00 00 
	stat->st_dev = dev;
  8013a1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	53                   	push   %ebx
  8013ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ae:	ff 50 14             	call   *0x14(%eax)
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	eb 09                	jmp    8013c1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b8:	89 c2                	mov    %eax,%edx
  8013ba:	eb 05                	jmp    8013c1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013c1:	89 d0                	mov    %edx,%eax
  8013c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	6a 00                	push   $0x0
  8013d2:	ff 75 08             	pushl  0x8(%ebp)
  8013d5:	e8 d6 01 00 00       	call   8015b0 <open>
  8013da:	89 c3                	mov    %eax,%ebx
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 1b                	js     8013fe <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	ff 75 0c             	pushl  0xc(%ebp)
  8013e9:	50                   	push   %eax
  8013ea:	e8 5b ff ff ff       	call   80134a <fstat>
  8013ef:	89 c6                	mov    %eax,%esi
	close(fd);
  8013f1:	89 1c 24             	mov    %ebx,(%esp)
  8013f4:	e8 fd fb ff ff       	call   800ff6 <close>
	return r;
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	89 f0                	mov    %esi,%eax
}
  8013fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801401:	5b                   	pop    %ebx
  801402:	5e                   	pop    %esi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	56                   	push   %esi
  801409:	53                   	push   %ebx
  80140a:	89 c6                	mov    %eax,%esi
  80140c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80140e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801415:	75 12                	jne    801429 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801417:	83 ec 0c             	sub    $0xc,%esp
  80141a:	6a 01                	push   $0x1
  80141c:	e8 44 0d 00 00       	call   802165 <ipc_find_env>
  801421:	a3 04 40 80 00       	mov    %eax,0x804004
  801426:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801429:	6a 07                	push   $0x7
  80142b:	68 00 50 80 00       	push   $0x805000
  801430:	56                   	push   %esi
  801431:	ff 35 04 40 80 00    	pushl  0x804004
  801437:	e8 d5 0c 00 00       	call   802111 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80143c:	83 c4 0c             	add    $0xc,%esp
  80143f:	6a 00                	push   $0x0
  801441:	53                   	push   %ebx
  801442:	6a 00                	push   $0x0
  801444:	e8 61 0c 00 00       	call   8020aa <ipc_recv>
}
  801449:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801456:	8b 45 08             	mov    0x8(%ebp),%eax
  801459:	8b 40 0c             	mov    0xc(%eax),%eax
  80145c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801461:	8b 45 0c             	mov    0xc(%ebp),%eax
  801464:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801469:	ba 00 00 00 00       	mov    $0x0,%edx
  80146e:	b8 02 00 00 00       	mov    $0x2,%eax
  801473:	e8 8d ff ff ff       	call   801405 <fsipc>
}
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	8b 40 0c             	mov    0xc(%eax),%eax
  801486:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80148b:	ba 00 00 00 00       	mov    $0x0,%edx
  801490:	b8 06 00 00 00       	mov    $0x6,%eax
  801495:	e8 6b ff ff ff       	call   801405 <fsipc>
}
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	53                   	push   %ebx
  8014a0:	83 ec 04             	sub    $0x4,%esp
  8014a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ac:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8014bb:	e8 45 ff ff ff       	call   801405 <fsipc>
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 2c                	js     8014f0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	68 00 50 80 00       	push   $0x805000
  8014cc:	53                   	push   %ebx
  8014cd:	e8 71 f3 ff ff       	call   800843 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014dd:	a1 84 50 80 00       	mov    0x805084,%eax
  8014e2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f3:	c9                   	leave  
  8014f4:	c3                   	ret    

008014f5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	83 ec 0c             	sub    $0xc,%esp
  8014fb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801501:	8b 52 0c             	mov    0xc(%edx),%edx
  801504:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80150a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80150f:	50                   	push   %eax
  801510:	ff 75 0c             	pushl  0xc(%ebp)
  801513:	68 08 50 80 00       	push   $0x805008
  801518:	e8 b8 f4 ff ff       	call   8009d5 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80151d:	ba 00 00 00 00       	mov    $0x0,%edx
  801522:	b8 04 00 00 00       	mov    $0x4,%eax
  801527:	e8 d9 fe ff ff       	call   801405 <fsipc>

}
  80152c:	c9                   	leave  
  80152d:	c3                   	ret    

0080152e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	56                   	push   %esi
  801532:	53                   	push   %ebx
  801533:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	8b 40 0c             	mov    0xc(%eax),%eax
  80153c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801541:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801547:	ba 00 00 00 00       	mov    $0x0,%edx
  80154c:	b8 03 00 00 00       	mov    $0x3,%eax
  801551:	e8 af fe ff ff       	call   801405 <fsipc>
  801556:	89 c3                	mov    %eax,%ebx
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 4b                	js     8015a7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80155c:	39 c6                	cmp    %eax,%esi
  80155e:	73 16                	jae    801576 <devfile_read+0x48>
  801560:	68 c0 28 80 00       	push   $0x8028c0
  801565:	68 c7 28 80 00       	push   $0x8028c7
  80156a:	6a 7c                	push   $0x7c
  80156c:	68 dc 28 80 00       	push   $0x8028dc
  801571:	e8 6f ec ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  801576:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80157b:	7e 16                	jle    801593 <devfile_read+0x65>
  80157d:	68 e7 28 80 00       	push   $0x8028e7
  801582:	68 c7 28 80 00       	push   $0x8028c7
  801587:	6a 7d                	push   $0x7d
  801589:	68 dc 28 80 00       	push   $0x8028dc
  80158e:	e8 52 ec ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801593:	83 ec 04             	sub    $0x4,%esp
  801596:	50                   	push   %eax
  801597:	68 00 50 80 00       	push   $0x805000
  80159c:	ff 75 0c             	pushl  0xc(%ebp)
  80159f:	e8 31 f4 ff ff       	call   8009d5 <memmove>
	return r;
  8015a4:	83 c4 10             	add    $0x10,%esp
}
  8015a7:	89 d8                	mov    %ebx,%eax
  8015a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    

008015b0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 20             	sub    $0x20,%esp
  8015b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ba:	53                   	push   %ebx
  8015bb:	e8 4a f2 ff ff       	call   80080a <strlen>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015c8:	7f 67                	jg     801631 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	e8 a7 f8 ff ff       	call   800e7d <fd_alloc>
  8015d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8015d9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 57                	js     801636 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	53                   	push   %ebx
  8015e3:	68 00 50 80 00       	push   $0x805000
  8015e8:	e8 56 f2 ff ff       	call   800843 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015fd:	e8 03 fe ff ff       	call   801405 <fsipc>
  801602:	89 c3                	mov    %eax,%ebx
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	85 c0                	test   %eax,%eax
  801609:	79 14                	jns    80161f <open+0x6f>
		fd_close(fd, 0);
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	6a 00                	push   $0x0
  801610:	ff 75 f4             	pushl  -0xc(%ebp)
  801613:	e8 5d f9 ff ff       	call   800f75 <fd_close>
		return r;
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	89 da                	mov    %ebx,%edx
  80161d:	eb 17                	jmp    801636 <open+0x86>
	}

	return fd2num(fd);
  80161f:	83 ec 0c             	sub    $0xc,%esp
  801622:	ff 75 f4             	pushl  -0xc(%ebp)
  801625:	e8 2c f8 ff ff       	call   800e56 <fd2num>
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb 05                	jmp    801636 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801631:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801636:	89 d0                	mov    %edx,%eax
  801638:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801643:	ba 00 00 00 00       	mov    $0x0,%edx
  801648:	b8 08 00 00 00       	mov    $0x8,%eax
  80164d:	e8 b3 fd ff ff       	call   801405 <fsipc>
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801654:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801658:	7e 37                	jle    801691 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801663:	ff 70 04             	pushl  0x4(%eax)
  801666:	8d 40 10             	lea    0x10(%eax),%eax
  801669:	50                   	push   %eax
  80166a:	ff 33                	pushl  (%ebx)
  80166c:	e8 9b fb ff ff       	call   80120c <write>
		if (result > 0)
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	7e 03                	jle    80167b <writebuf+0x27>
			b->result += result;
  801678:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80167b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80167e:	74 0d                	je     80168d <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801680:	85 c0                	test   %eax,%eax
  801682:	ba 00 00 00 00       	mov    $0x0,%edx
  801687:	0f 4f c2             	cmovg  %edx,%eax
  80168a:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801690:	c9                   	leave  
  801691:	f3 c3                	repz ret 

00801693 <putch>:

static void
putch(int ch, void *thunk)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 04             	sub    $0x4,%esp
  80169a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80169d:	8b 53 04             	mov    0x4(%ebx),%edx
  8016a0:	8d 42 01             	lea    0x1(%edx),%eax
  8016a3:	89 43 04             	mov    %eax,0x4(%ebx)
  8016a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a9:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016ad:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016b2:	75 0e                	jne    8016c2 <putch+0x2f>
		writebuf(b);
  8016b4:	89 d8                	mov    %ebx,%eax
  8016b6:	e8 99 ff ff ff       	call   801654 <writebuf>
		b->idx = 0;
  8016bb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016c2:	83 c4 04             	add    $0x4,%esp
  8016c5:	5b                   	pop    %ebx
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d4:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016da:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016e1:	00 00 00 
	b.result = 0;
  8016e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016eb:	00 00 00 
	b.error = 1;
  8016ee:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016f5:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016f8:	ff 75 10             	pushl  0x10(%ebp)
  8016fb:	ff 75 0c             	pushl  0xc(%ebp)
  8016fe:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801704:	50                   	push   %eax
  801705:	68 93 16 80 00       	push   $0x801693
  80170a:	e8 e6 ec ff ff       	call   8003f5 <vprintfmt>
	if (b.idx > 0)
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801719:	7e 0b                	jle    801726 <vfprintf+0x5e>
		writebuf(&b);
  80171b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801721:	e8 2e ff ff ff       	call   801654 <writebuf>

	return (b.result ? b.result : b.error);
  801726:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80172c:	85 c0                	test   %eax,%eax
  80172e:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80173d:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801740:	50                   	push   %eax
  801741:	ff 75 0c             	pushl  0xc(%ebp)
  801744:	ff 75 08             	pushl  0x8(%ebp)
  801747:	e8 7c ff ff ff       	call   8016c8 <vfprintf>
	va_end(ap);

	return cnt;
}
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <printf>:

int
printf(const char *fmt, ...)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801754:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801757:	50                   	push   %eax
  801758:	ff 75 08             	pushl  0x8(%ebp)
  80175b:	6a 01                	push   $0x1
  80175d:	e8 66 ff ff ff       	call   8016c8 <vfprintf>
	va_end(ap);

	return cnt;
}
  801762:	c9                   	leave  
  801763:	c3                   	ret    

00801764 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80176c:	83 ec 0c             	sub    $0xc,%esp
  80176f:	ff 75 08             	pushl  0x8(%ebp)
  801772:	e8 ef f6 ff ff       	call   800e66 <fd2data>
  801777:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801779:	83 c4 08             	add    $0x8,%esp
  80177c:	68 f3 28 80 00       	push   $0x8028f3
  801781:	53                   	push   %ebx
  801782:	e8 bc f0 ff ff       	call   800843 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801787:	8b 46 04             	mov    0x4(%esi),%eax
  80178a:	2b 06                	sub    (%esi),%eax
  80178c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801792:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801799:	00 00 00 
	stat->st_dev = &devpipe;
  80179c:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8017a3:	30 80 00 
	return 0;
}
  8017a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5e                   	pop    %esi
  8017b0:	5d                   	pop    %ebp
  8017b1:	c3                   	ret    

008017b2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 0c             	sub    $0xc,%esp
  8017b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017bc:	53                   	push   %ebx
  8017bd:	6a 00                	push   $0x0
  8017bf:	e8 07 f5 ff ff       	call   800ccb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017c4:	89 1c 24             	mov    %ebx,(%esp)
  8017c7:	e8 9a f6 ff ff       	call   800e66 <fd2data>
  8017cc:	83 c4 08             	add    $0x8,%esp
  8017cf:	50                   	push   %eax
  8017d0:	6a 00                	push   $0x0
  8017d2:	e8 f4 f4 ff ff       	call   800ccb <sys_page_unmap>
}
  8017d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	57                   	push   %edi
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 1c             	sub    $0x1c,%esp
  8017e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017e8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017ea:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8017ef:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017f2:	83 ec 0c             	sub    $0xc,%esp
  8017f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8017f8:	e8 a1 09 00 00       	call   80219e <pageref>
  8017fd:	89 c3                	mov    %eax,%ebx
  8017ff:	89 3c 24             	mov    %edi,(%esp)
  801802:	e8 97 09 00 00       	call   80219e <pageref>
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	39 c3                	cmp    %eax,%ebx
  80180c:	0f 94 c1             	sete   %cl
  80180f:	0f b6 c9             	movzbl %cl,%ecx
  801812:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801815:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  80181b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80181e:	39 ce                	cmp    %ecx,%esi
  801820:	74 1b                	je     80183d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801822:	39 c3                	cmp    %eax,%ebx
  801824:	75 c4                	jne    8017ea <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801826:	8b 42 58             	mov    0x58(%edx),%eax
  801829:	ff 75 e4             	pushl  -0x1c(%ebp)
  80182c:	50                   	push   %eax
  80182d:	56                   	push   %esi
  80182e:	68 fa 28 80 00       	push   $0x8028fa
  801833:	e8 86 ea ff ff       	call   8002be <cprintf>
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	eb ad                	jmp    8017ea <_pipeisclosed+0xe>
	}
}
  80183d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801840:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801843:	5b                   	pop    %ebx
  801844:	5e                   	pop    %esi
  801845:	5f                   	pop    %edi
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	57                   	push   %edi
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	83 ec 28             	sub    $0x28,%esp
  801851:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801854:	56                   	push   %esi
  801855:	e8 0c f6 ff ff       	call   800e66 <fd2data>
  80185a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	bf 00 00 00 00       	mov    $0x0,%edi
  801864:	eb 4b                	jmp    8018b1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801866:	89 da                	mov    %ebx,%edx
  801868:	89 f0                	mov    %esi,%eax
  80186a:	e8 6d ff ff ff       	call   8017dc <_pipeisclosed>
  80186f:	85 c0                	test   %eax,%eax
  801871:	75 48                	jne    8018bb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801873:	e8 af f3 ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801878:	8b 43 04             	mov    0x4(%ebx),%eax
  80187b:	8b 0b                	mov    (%ebx),%ecx
  80187d:	8d 51 20             	lea    0x20(%ecx),%edx
  801880:	39 d0                	cmp    %edx,%eax
  801882:	73 e2                	jae    801866 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801884:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801887:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80188b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80188e:	89 c2                	mov    %eax,%edx
  801890:	c1 fa 1f             	sar    $0x1f,%edx
  801893:	89 d1                	mov    %edx,%ecx
  801895:	c1 e9 1b             	shr    $0x1b,%ecx
  801898:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80189b:	83 e2 1f             	and    $0x1f,%edx
  80189e:	29 ca                	sub    %ecx,%edx
  8018a0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018a8:	83 c0 01             	add    $0x1,%eax
  8018ab:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ae:	83 c7 01             	add    $0x1,%edi
  8018b1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018b4:	75 c2                	jne    801878 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b9:	eb 05                	jmp    8018c0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018bb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5f                   	pop    %edi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	57                   	push   %edi
  8018cc:	56                   	push   %esi
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 18             	sub    $0x18,%esp
  8018d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018d4:	57                   	push   %edi
  8018d5:	e8 8c f5 ff ff       	call   800e66 <fd2data>
  8018da:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e4:	eb 3d                	jmp    801923 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018e6:	85 db                	test   %ebx,%ebx
  8018e8:	74 04                	je     8018ee <devpipe_read+0x26>
				return i;
  8018ea:	89 d8                	mov    %ebx,%eax
  8018ec:	eb 44                	jmp    801932 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018ee:	89 f2                	mov    %esi,%edx
  8018f0:	89 f8                	mov    %edi,%eax
  8018f2:	e8 e5 fe ff ff       	call   8017dc <_pipeisclosed>
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	75 32                	jne    80192d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018fb:	e8 27 f3 ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801900:	8b 06                	mov    (%esi),%eax
  801902:	3b 46 04             	cmp    0x4(%esi),%eax
  801905:	74 df                	je     8018e6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801907:	99                   	cltd   
  801908:	c1 ea 1b             	shr    $0x1b,%edx
  80190b:	01 d0                	add    %edx,%eax
  80190d:	83 e0 1f             	and    $0x1f,%eax
  801910:	29 d0                	sub    %edx,%eax
  801912:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80191a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80191d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801920:	83 c3 01             	add    $0x1,%ebx
  801923:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801926:	75 d8                	jne    801900 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801928:	8b 45 10             	mov    0x10(%ebp),%eax
  80192b:	eb 05                	jmp    801932 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801932:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801935:	5b                   	pop    %ebx
  801936:	5e                   	pop    %esi
  801937:	5f                   	pop    %edi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	56                   	push   %esi
  80193e:	53                   	push   %ebx
  80193f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801942:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801945:	50                   	push   %eax
  801946:	e8 32 f5 ff ff       	call   800e7d <fd_alloc>
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	89 c2                	mov    %eax,%edx
  801950:	85 c0                	test   %eax,%eax
  801952:	0f 88 2c 01 00 00    	js     801a84 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801958:	83 ec 04             	sub    $0x4,%esp
  80195b:	68 07 04 00 00       	push   $0x407
  801960:	ff 75 f4             	pushl  -0xc(%ebp)
  801963:	6a 00                	push   $0x0
  801965:	e8 dc f2 ff ff       	call   800c46 <sys_page_alloc>
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	89 c2                	mov    %eax,%edx
  80196f:	85 c0                	test   %eax,%eax
  801971:	0f 88 0d 01 00 00    	js     801a84 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80197d:	50                   	push   %eax
  80197e:	e8 fa f4 ff ff       	call   800e7d <fd_alloc>
  801983:	89 c3                	mov    %eax,%ebx
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	85 c0                	test   %eax,%eax
  80198a:	0f 88 e2 00 00 00    	js     801a72 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801990:	83 ec 04             	sub    $0x4,%esp
  801993:	68 07 04 00 00       	push   $0x407
  801998:	ff 75 f0             	pushl  -0x10(%ebp)
  80199b:	6a 00                	push   $0x0
  80199d:	e8 a4 f2 ff ff       	call   800c46 <sys_page_alloc>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	0f 88 c3 00 00 00    	js     801a72 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b5:	e8 ac f4 ff ff       	call   800e66 <fd2data>
  8019ba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019bc:	83 c4 0c             	add    $0xc,%esp
  8019bf:	68 07 04 00 00       	push   $0x407
  8019c4:	50                   	push   %eax
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 7a f2 ff ff       	call   800c46 <sys_page_alloc>
  8019cc:	89 c3                	mov    %eax,%ebx
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	0f 88 89 00 00 00    	js     801a62 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d9:	83 ec 0c             	sub    $0xc,%esp
  8019dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8019df:	e8 82 f4 ff ff       	call   800e66 <fd2data>
  8019e4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019eb:	50                   	push   %eax
  8019ec:	6a 00                	push   $0x0
  8019ee:	56                   	push   %esi
  8019ef:	6a 00                	push   $0x0
  8019f1:	e8 93 f2 ff ff       	call   800c89 <sys_page_map>
  8019f6:	89 c3                	mov    %eax,%ebx
  8019f8:	83 c4 20             	add    $0x20,%esp
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	78 55                	js     801a54 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019ff:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a14:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2f:	e8 22 f4 ff ff       	call   800e56 <fd2num>
  801a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a37:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a39:	83 c4 04             	add    $0x4,%esp
  801a3c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a3f:	e8 12 f4 ff ff       	call   800e56 <fd2num>
  801a44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a47:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a52:	eb 30                	jmp    801a84 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a54:	83 ec 08             	sub    $0x8,%esp
  801a57:	56                   	push   %esi
  801a58:	6a 00                	push   $0x0
  801a5a:	e8 6c f2 ff ff       	call   800ccb <sys_page_unmap>
  801a5f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a62:	83 ec 08             	sub    $0x8,%esp
  801a65:	ff 75 f0             	pushl  -0x10(%ebp)
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 5c f2 ff ff       	call   800ccb <sys_page_unmap>
  801a6f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a72:	83 ec 08             	sub    $0x8,%esp
  801a75:	ff 75 f4             	pushl  -0xc(%ebp)
  801a78:	6a 00                	push   $0x0
  801a7a:	e8 4c f2 ff ff       	call   800ccb <sys_page_unmap>
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a84:	89 d0                	mov    %edx,%eax
  801a86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5e                   	pop    %esi
  801a8b:	5d                   	pop    %ebp
  801a8c:	c3                   	ret    

00801a8d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a96:	50                   	push   %eax
  801a97:	ff 75 08             	pushl  0x8(%ebp)
  801a9a:	e8 2d f4 ff ff       	call   800ecc <fd_lookup>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	78 18                	js     801abe <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	ff 75 f4             	pushl  -0xc(%ebp)
  801aac:	e8 b5 f3 ff ff       	call   800e66 <fd2data>
	return _pipeisclosed(fd, p);
  801ab1:	89 c2                	mov    %eax,%edx
  801ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab6:	e8 21 fd ff ff       	call   8017dc <_pipeisclosed>
  801abb:	83 c4 10             	add    $0x10,%esp
}
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ac6:	68 12 29 80 00       	push   $0x802912
  801acb:	ff 75 0c             	pushl  0xc(%ebp)
  801ace:	e8 70 ed ff ff       	call   800843 <strcpy>
	return 0;
}
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	53                   	push   %ebx
  801ade:	83 ec 10             	sub    $0x10,%esp
  801ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ae4:	53                   	push   %ebx
  801ae5:	e8 b4 06 00 00       	call   80219e <pageref>
  801aea:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801aed:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801af2:	83 f8 01             	cmp    $0x1,%eax
  801af5:	75 10                	jne    801b07 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	ff 73 0c             	pushl  0xc(%ebx)
  801afd:	e8 c0 02 00 00       	call   801dc2 <nsipc_close>
  801b02:	89 c2                	mov    %eax,%edx
  801b04:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b07:	89 d0                	mov    %edx,%eax
  801b09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b14:	6a 00                	push   $0x0
  801b16:	ff 75 10             	pushl  0x10(%ebp)
  801b19:	ff 75 0c             	pushl  0xc(%ebp)
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	ff 70 0c             	pushl  0xc(%eax)
  801b22:	e8 78 03 00 00       	call   801e9f <nsipc_send>
}
  801b27:	c9                   	leave  
  801b28:	c3                   	ret    

00801b29 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b2f:	6a 00                	push   $0x0
  801b31:	ff 75 10             	pushl  0x10(%ebp)
  801b34:	ff 75 0c             	pushl  0xc(%ebp)
  801b37:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3a:	ff 70 0c             	pushl  0xc(%eax)
  801b3d:	e8 f1 02 00 00       	call   801e33 <nsipc_recv>
}
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b4a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b4d:	52                   	push   %edx
  801b4e:	50                   	push   %eax
  801b4f:	e8 78 f3 ff ff       	call   800ecc <fd_lookup>
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 17                	js     801b72 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5e:	8b 0d 40 30 80 00    	mov    0x803040,%ecx
  801b64:	39 08                	cmp    %ecx,(%eax)
  801b66:	75 05                	jne    801b6d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b68:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6b:	eb 05                	jmp    801b72 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b6d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b72:	c9                   	leave  
  801b73:	c3                   	ret    

00801b74 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	56                   	push   %esi
  801b78:	53                   	push   %ebx
  801b79:	83 ec 1c             	sub    $0x1c,%esp
  801b7c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b81:	50                   	push   %eax
  801b82:	e8 f6 f2 ff ff       	call   800e7d <fd_alloc>
  801b87:	89 c3                	mov    %eax,%ebx
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 1b                	js     801bab <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b90:	83 ec 04             	sub    $0x4,%esp
  801b93:	68 07 04 00 00       	push   $0x407
  801b98:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9b:	6a 00                	push   $0x0
  801b9d:	e8 a4 f0 ff ff       	call   800c46 <sys_page_alloc>
  801ba2:	89 c3                	mov    %eax,%ebx
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	79 10                	jns    801bbb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	56                   	push   %esi
  801baf:	e8 0e 02 00 00       	call   801dc2 <nsipc_close>
		return r;
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	89 d8                	mov    %ebx,%eax
  801bb9:	eb 24                	jmp    801bdf <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bbb:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bd0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bd3:	83 ec 0c             	sub    $0xc,%esp
  801bd6:	50                   	push   %eax
  801bd7:	e8 7a f2 ff ff       	call   800e56 <fd2num>
  801bdc:	83 c4 10             	add    $0x10,%esp
}
  801bdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be2:	5b                   	pop    %ebx
  801be3:	5e                   	pop    %esi
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
  801bef:	e8 50 ff ff ff       	call   801b44 <fd2sockid>
		return r;
  801bf4:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 1f                	js     801c19 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bfa:	83 ec 04             	sub    $0x4,%esp
  801bfd:	ff 75 10             	pushl  0x10(%ebp)
  801c00:	ff 75 0c             	pushl  0xc(%ebp)
  801c03:	50                   	push   %eax
  801c04:	e8 12 01 00 00       	call   801d1b <nsipc_accept>
  801c09:	83 c4 10             	add    $0x10,%esp
		return r;
  801c0c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 07                	js     801c19 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c12:	e8 5d ff ff ff       	call   801b74 <alloc_sockfd>
  801c17:	89 c1                	mov    %eax,%ecx
}
  801c19:	89 c8                	mov    %ecx,%eax
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c23:	8b 45 08             	mov    0x8(%ebp),%eax
  801c26:	e8 19 ff ff ff       	call   801b44 <fd2sockid>
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	78 12                	js     801c41 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c2f:	83 ec 04             	sub    $0x4,%esp
  801c32:	ff 75 10             	pushl  0x10(%ebp)
  801c35:	ff 75 0c             	pushl  0xc(%ebp)
  801c38:	50                   	push   %eax
  801c39:	e8 2d 01 00 00       	call   801d6b <nsipc_bind>
  801c3e:	83 c4 10             	add    $0x10,%esp
}
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <shutdown>:

int
shutdown(int s, int how)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	e8 f3 fe ff ff       	call   801b44 <fd2sockid>
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 0f                	js     801c64 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	ff 75 0c             	pushl  0xc(%ebp)
  801c5b:	50                   	push   %eax
  801c5c:	e8 3f 01 00 00       	call   801da0 <nsipc_shutdown>
  801c61:	83 c4 10             	add    $0x10,%esp
}
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    

00801c66 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	e8 d0 fe ff ff       	call   801b44 <fd2sockid>
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 12                	js     801c8a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c78:	83 ec 04             	sub    $0x4,%esp
  801c7b:	ff 75 10             	pushl  0x10(%ebp)
  801c7e:	ff 75 0c             	pushl  0xc(%ebp)
  801c81:	50                   	push   %eax
  801c82:	e8 55 01 00 00       	call   801ddc <nsipc_connect>
  801c87:	83 c4 10             	add    $0x10,%esp
}
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <listen>:

int
listen(int s, int backlog)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	e8 aa fe ff ff       	call   801b44 <fd2sockid>
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	78 0f                	js     801cad <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c9e:	83 ec 08             	sub    $0x8,%esp
  801ca1:	ff 75 0c             	pushl  0xc(%ebp)
  801ca4:	50                   	push   %eax
  801ca5:	e8 67 01 00 00       	call   801e11 <nsipc_listen>
  801caa:	83 c4 10             	add    $0x10,%esp
}
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    

00801caf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cb5:	ff 75 10             	pushl  0x10(%ebp)
  801cb8:	ff 75 0c             	pushl  0xc(%ebp)
  801cbb:	ff 75 08             	pushl  0x8(%ebp)
  801cbe:	e8 3a 02 00 00       	call   801efd <nsipc_socket>
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 05                	js     801ccf <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801cca:	e8 a5 fe ff ff       	call   801b74 <alloc_sockfd>
}
  801ccf:	c9                   	leave  
  801cd0:	c3                   	ret    

00801cd1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	53                   	push   %ebx
  801cd5:	83 ec 04             	sub    $0x4,%esp
  801cd8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cda:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801ce1:	75 12                	jne    801cf5 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ce3:	83 ec 0c             	sub    $0xc,%esp
  801ce6:	6a 02                	push   $0x2
  801ce8:	e8 78 04 00 00       	call   802165 <ipc_find_env>
  801ced:	a3 08 40 80 00       	mov    %eax,0x804008
  801cf2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cf5:	6a 07                	push   $0x7
  801cf7:	68 00 60 80 00       	push   $0x806000
  801cfc:	53                   	push   %ebx
  801cfd:	ff 35 08 40 80 00    	pushl  0x804008
  801d03:	e8 09 04 00 00       	call   802111 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d08:	83 c4 0c             	add    $0xc,%esp
  801d0b:	6a 00                	push   $0x0
  801d0d:	6a 00                	push   $0x0
  801d0f:	6a 00                	push   $0x0
  801d11:	e8 94 03 00 00       	call   8020aa <ipc_recv>
}
  801d16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d2b:	8b 06                	mov    (%esi),%eax
  801d2d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d32:	b8 01 00 00 00       	mov    $0x1,%eax
  801d37:	e8 95 ff ff ff       	call   801cd1 <nsipc>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 20                	js     801d62 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d42:	83 ec 04             	sub    $0x4,%esp
  801d45:	ff 35 10 60 80 00    	pushl  0x806010
  801d4b:	68 00 60 80 00       	push   $0x806000
  801d50:	ff 75 0c             	pushl  0xc(%ebp)
  801d53:	e8 7d ec ff ff       	call   8009d5 <memmove>
		*addrlen = ret->ret_addrlen;
  801d58:	a1 10 60 80 00       	mov    0x806010,%eax
  801d5d:	89 06                	mov    %eax,(%esi)
  801d5f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d62:	89 d8                	mov    %ebx,%eax
  801d64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	53                   	push   %ebx
  801d6f:	83 ec 08             	sub    $0x8,%esp
  801d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d75:	8b 45 08             	mov    0x8(%ebp),%eax
  801d78:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d7d:	53                   	push   %ebx
  801d7e:	ff 75 0c             	pushl  0xc(%ebp)
  801d81:	68 04 60 80 00       	push   $0x806004
  801d86:	e8 4a ec ff ff       	call   8009d5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d8b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d91:	b8 02 00 00 00       	mov    $0x2,%eax
  801d96:	e8 36 ff ff ff       	call   801cd1 <nsipc>
}
  801d9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801da6:	8b 45 08             	mov    0x8(%ebp),%eax
  801da9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801db6:	b8 03 00 00 00       	mov    $0x3,%eax
  801dbb:	e8 11 ff ff ff       	call   801cd1 <nsipc>
}
  801dc0:	c9                   	leave  
  801dc1:	c3                   	ret    

00801dc2 <nsipc_close>:

int
nsipc_close(int s)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801dd0:	b8 04 00 00 00       	mov    $0x4,%eax
  801dd5:	e8 f7 fe ff ff       	call   801cd1 <nsipc>
}
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	53                   	push   %ebx
  801de0:	83 ec 08             	sub    $0x8,%esp
  801de3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dee:	53                   	push   %ebx
  801def:	ff 75 0c             	pushl  0xc(%ebp)
  801df2:	68 04 60 80 00       	push   $0x806004
  801df7:	e8 d9 eb ff ff       	call   8009d5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dfc:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e02:	b8 05 00 00 00       	mov    $0x5,%eax
  801e07:	e8 c5 fe ff ff       	call   801cd1 <nsipc>
}
  801e0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e0f:	c9                   	leave  
  801e10:	c3                   	ret    

00801e11 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e17:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e22:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e27:	b8 06 00 00 00       	mov    $0x6,%eax
  801e2c:	e8 a0 fe ff ff       	call   801cd1 <nsipc>
}
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	56                   	push   %esi
  801e37:	53                   	push   %ebx
  801e38:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e43:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e49:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e51:	b8 07 00 00 00       	mov    $0x7,%eax
  801e56:	e8 76 fe ff ff       	call   801cd1 <nsipc>
  801e5b:	89 c3                	mov    %eax,%ebx
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	78 35                	js     801e96 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e61:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e66:	7f 04                	jg     801e6c <nsipc_recv+0x39>
  801e68:	39 c6                	cmp    %eax,%esi
  801e6a:	7d 16                	jge    801e82 <nsipc_recv+0x4f>
  801e6c:	68 1e 29 80 00       	push   $0x80291e
  801e71:	68 c7 28 80 00       	push   $0x8028c7
  801e76:	6a 62                	push   $0x62
  801e78:	68 33 29 80 00       	push   $0x802933
  801e7d:	e8 63 e3 ff ff       	call   8001e5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e82:	83 ec 04             	sub    $0x4,%esp
  801e85:	50                   	push   %eax
  801e86:	68 00 60 80 00       	push   $0x806000
  801e8b:	ff 75 0c             	pushl  0xc(%ebp)
  801e8e:	e8 42 eb ff ff       	call   8009d5 <memmove>
  801e93:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e96:	89 d8                	mov    %ebx,%eax
  801e98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9b:	5b                   	pop    %ebx
  801e9c:	5e                   	pop    %esi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    

00801e9f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	53                   	push   %ebx
  801ea3:	83 ec 04             	sub    $0x4,%esp
  801ea6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  801eac:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801eb1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801eb7:	7e 16                	jle    801ecf <nsipc_send+0x30>
  801eb9:	68 3f 29 80 00       	push   $0x80293f
  801ebe:	68 c7 28 80 00       	push   $0x8028c7
  801ec3:	6a 6d                	push   $0x6d
  801ec5:	68 33 29 80 00       	push   $0x802933
  801eca:	e8 16 e3 ff ff       	call   8001e5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ecf:	83 ec 04             	sub    $0x4,%esp
  801ed2:	53                   	push   %ebx
  801ed3:	ff 75 0c             	pushl  0xc(%ebp)
  801ed6:	68 0c 60 80 00       	push   $0x80600c
  801edb:	e8 f5 ea ff ff       	call   8009d5 <memmove>
	nsipcbuf.send.req_size = size;
  801ee0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ee6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ee9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801eee:	b8 08 00 00 00       	mov    $0x8,%eax
  801ef3:	e8 d9 fd ff ff       	call   801cd1 <nsipc>
}
  801ef8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801efb:	c9                   	leave  
  801efc:	c3                   	ret    

00801efd <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f03:	8b 45 08             	mov    0x8(%ebp),%eax
  801f06:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f13:	8b 45 10             	mov    0x10(%ebp),%eax
  801f16:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f1b:	b8 09 00 00 00       	mov    $0x9,%eax
  801f20:	e8 ac fd ff ff       	call   801cd1 <nsipc>
}
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f37:	68 4b 29 80 00       	push   $0x80294b
  801f3c:	ff 75 0c             	pushl  0xc(%ebp)
  801f3f:	e8 ff e8 ff ff       	call   800843 <strcpy>
	return 0;
}
  801f44:	b8 00 00 00 00       	mov    $0x0,%eax
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    

00801f4b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	57                   	push   %edi
  801f4f:	56                   	push   %esi
  801f50:	53                   	push   %ebx
  801f51:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f57:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f5c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f62:	eb 2d                	jmp    801f91 <devcons_write+0x46>
		m = n - tot;
  801f64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f67:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f69:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f6c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f71:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f74:	83 ec 04             	sub    $0x4,%esp
  801f77:	53                   	push   %ebx
  801f78:	03 45 0c             	add    0xc(%ebp),%eax
  801f7b:	50                   	push   %eax
  801f7c:	57                   	push   %edi
  801f7d:	e8 53 ea ff ff       	call   8009d5 <memmove>
		sys_cputs(buf, m);
  801f82:	83 c4 08             	add    $0x8,%esp
  801f85:	53                   	push   %ebx
  801f86:	57                   	push   %edi
  801f87:	e8 fe eb ff ff       	call   800b8a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f8c:	01 de                	add    %ebx,%esi
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	89 f0                	mov    %esi,%eax
  801f93:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f96:	72 cc                	jb     801f64 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9b:	5b                   	pop    %ebx
  801f9c:	5e                   	pop    %esi
  801f9d:	5f                   	pop    %edi
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

00801fa0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	83 ec 08             	sub    $0x8,%esp
  801fa6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801faf:	74 2a                	je     801fdb <devcons_read+0x3b>
  801fb1:	eb 05                	jmp    801fb8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fb3:	e8 6f ec ff ff       	call   800c27 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fb8:	e8 eb eb ff ff       	call   800ba8 <sys_cgetc>
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	74 f2                	je     801fb3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	78 16                	js     801fdb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fc5:	83 f8 04             	cmp    $0x4,%eax
  801fc8:	74 0c                	je     801fd6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fcd:	88 02                	mov    %al,(%edx)
	return 1;
  801fcf:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd4:	eb 05                	jmp    801fdb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fd6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fdb:	c9                   	leave  
  801fdc:	c3                   	ret    

00801fdd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fe9:	6a 01                	push   $0x1
  801feb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fee:	50                   	push   %eax
  801fef:	e8 96 eb ff ff       	call   800b8a <sys_cputs>
}
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	c9                   	leave  
  801ff8:	c3                   	ret    

00801ff9 <getchar>:

int
getchar(void)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fff:	6a 01                	push   $0x1
  802001:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802004:	50                   	push   %eax
  802005:	6a 00                	push   $0x0
  802007:	e8 26 f1 ff ff       	call   801132 <read>
	if (r < 0)
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	85 c0                	test   %eax,%eax
  802011:	78 0f                	js     802022 <getchar+0x29>
		return r;
	if (r < 1)
  802013:	85 c0                	test   %eax,%eax
  802015:	7e 06                	jle    80201d <getchar+0x24>
		return -E_EOF;
	return c;
  802017:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80201b:	eb 05                	jmp    802022 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80201d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802022:	c9                   	leave  
  802023:	c3                   	ret    

00802024 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80202a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80202d:	50                   	push   %eax
  80202e:	ff 75 08             	pushl  0x8(%ebp)
  802031:	e8 96 ee ff ff       	call   800ecc <fd_lookup>
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	85 c0                	test   %eax,%eax
  80203b:	78 11                	js     80204e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80203d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802040:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802046:	39 10                	cmp    %edx,(%eax)
  802048:	0f 94 c0             	sete   %al
  80204b:	0f b6 c0             	movzbl %al,%eax
}
  80204e:	c9                   	leave  
  80204f:	c3                   	ret    

00802050 <opencons>:

int
opencons(void)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802056:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802059:	50                   	push   %eax
  80205a:	e8 1e ee ff ff       	call   800e7d <fd_alloc>
  80205f:	83 c4 10             	add    $0x10,%esp
		return r;
  802062:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802064:	85 c0                	test   %eax,%eax
  802066:	78 3e                	js     8020a6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802068:	83 ec 04             	sub    $0x4,%esp
  80206b:	68 07 04 00 00       	push   $0x407
  802070:	ff 75 f4             	pushl  -0xc(%ebp)
  802073:	6a 00                	push   $0x0
  802075:	e8 cc eb ff ff       	call   800c46 <sys_page_alloc>
  80207a:	83 c4 10             	add    $0x10,%esp
		return r;
  80207d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80207f:	85 c0                	test   %eax,%eax
  802081:	78 23                	js     8020a6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802083:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80208e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802091:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802098:	83 ec 0c             	sub    $0xc,%esp
  80209b:	50                   	push   %eax
  80209c:	e8 b5 ed ff ff       	call   800e56 <fd2num>
  8020a1:	89 c2                	mov    %eax,%edx
  8020a3:	83 c4 10             	add    $0x10,%esp
}
  8020a6:	89 d0                	mov    %edx,%eax
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	56                   	push   %esi
  8020ae:	53                   	push   %ebx
  8020af:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8020b8:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8020ba:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020bf:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8020c2:	83 ec 0c             	sub    $0xc,%esp
  8020c5:	50                   	push   %eax
  8020c6:	e8 2b ed ff ff       	call   800df6 <sys_ipc_recv>

	if (from_env_store != NULL)
  8020cb:	83 c4 10             	add    $0x10,%esp
  8020ce:	85 f6                	test   %esi,%esi
  8020d0:	74 14                	je     8020e6 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8020d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 09                	js     8020e4 <ipc_recv+0x3a>
  8020db:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8020e1:	8b 52 74             	mov    0x74(%edx),%edx
  8020e4:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8020e6:	85 db                	test   %ebx,%ebx
  8020e8:	74 14                	je     8020fe <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8020ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8020ef:	85 c0                	test   %eax,%eax
  8020f1:	78 09                	js     8020fc <ipc_recv+0x52>
  8020f3:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8020f9:	8b 52 78             	mov    0x78(%edx),%edx
  8020fc:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8020fe:	85 c0                	test   %eax,%eax
  802100:	78 08                	js     80210a <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802102:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802107:	8b 40 70             	mov    0x70(%eax),%eax
}
  80210a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5d                   	pop    %ebp
  802110:	c3                   	ret    

00802111 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802111:	55                   	push   %ebp
  802112:	89 e5                	mov    %esp,%ebp
  802114:	57                   	push   %edi
  802115:	56                   	push   %esi
  802116:	53                   	push   %ebx
  802117:	83 ec 0c             	sub    $0xc,%esp
  80211a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80211d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802120:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802123:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802125:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80212a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80212d:	ff 75 14             	pushl  0x14(%ebp)
  802130:	53                   	push   %ebx
  802131:	56                   	push   %esi
  802132:	57                   	push   %edi
  802133:	e8 9b ec ff ff       	call   800dd3 <sys_ipc_try_send>

		if (err < 0) {
  802138:	83 c4 10             	add    $0x10,%esp
  80213b:	85 c0                	test   %eax,%eax
  80213d:	79 1e                	jns    80215d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80213f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802142:	75 07                	jne    80214b <ipc_send+0x3a>
				sys_yield();
  802144:	e8 de ea ff ff       	call   800c27 <sys_yield>
  802149:	eb e2                	jmp    80212d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80214b:	50                   	push   %eax
  80214c:	68 57 29 80 00       	push   $0x802957
  802151:	6a 49                	push   $0x49
  802153:	68 64 29 80 00       	push   $0x802964
  802158:	e8 88 e0 ff ff       	call   8001e5 <_panic>
		}

	} while (err < 0);

}
  80215d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802160:	5b                   	pop    %ebx
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    

00802165 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80216b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802170:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802173:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802179:	8b 52 50             	mov    0x50(%edx),%edx
  80217c:	39 ca                	cmp    %ecx,%edx
  80217e:	75 0d                	jne    80218d <ipc_find_env+0x28>
			return envs[i].env_id;
  802180:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802183:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802188:	8b 40 48             	mov    0x48(%eax),%eax
  80218b:	eb 0f                	jmp    80219c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80218d:	83 c0 01             	add    $0x1,%eax
  802190:	3d 00 04 00 00       	cmp    $0x400,%eax
  802195:	75 d9                	jne    802170 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802197:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80219c:	5d                   	pop    %ebp
  80219d:	c3                   	ret    

0080219e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80219e:	55                   	push   %ebp
  80219f:	89 e5                	mov    %esp,%ebp
  8021a1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a4:	89 d0                	mov    %edx,%eax
  8021a6:	c1 e8 16             	shr    $0x16,%eax
  8021a9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021b0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b5:	f6 c1 01             	test   $0x1,%cl
  8021b8:	74 1d                	je     8021d7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ba:	c1 ea 0c             	shr    $0xc,%edx
  8021bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021c4:	f6 c2 01             	test   $0x1,%dl
  8021c7:	74 0e                	je     8021d7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c9:	c1 ea 0c             	shr    $0xc,%edx
  8021cc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021d3:	ef 
  8021d4:	0f b7 c0             	movzwl %ax,%eax
}
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	66 90                	xchg   %ax,%ax
  8021db:	66 90                	xchg   %ax,%ax
  8021dd:	66 90                	xchg   %ax,%ax
  8021df:	90                   	nop

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
