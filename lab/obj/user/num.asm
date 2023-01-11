
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
  80005d:	68 00 25 80 00       	push   $0x802500
  800062:	e8 6b 17 00 00       	call   8017d2 <printf>
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
  80007c:	e8 0f 12 00 00       	call   801290 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 05 25 80 00       	push   $0x802505
  800095:	6a 13                	push   $0x13
  800097:	68 20 25 80 00       	push   $0x802520
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
  8000b8:	e8 f9 10 00 00       	call   8011b6 <read>
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
  8000d3:	68 2b 25 80 00       	push   $0x80252b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 20 25 80 00       	push   $0x802520
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
  8000f4:	c7 05 04 30 80 00 40 	movl   $0x802540,0x803004
  8000fb:	25 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 44 25 80 00       	push   $0x802544
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
  80012f:	e8 00 15 00 00       	call   801634 <open>
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
  800146:	68 4c 25 80 00       	push   $0x80254c
  80014b:	6a 27                	push   $0x27
  80014d:	68 20 25 80 00       	push   $0x802520
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 10 0f 00 00       	call   80107a <close>

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
  8001d1:	e8 cf 0e 00 00       	call   8010a5 <close_all>
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
  800203:	68 68 25 80 00       	push   $0x802568
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 c4 29 80 00 	movl   $0x8029c4,(%esp)
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
  800321:	e8 3a 1f 00 00       	call   802260 <__udivdi3>
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
  800364:	e8 27 20 00 00       	call   802390 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 8b 25 80 00 	movsbl 0x80258b(%eax),%eax
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
  800468:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
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
  80052c:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	75 18                	jne    80054f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800537:	50                   	push   %eax
  800538:	68 a3 25 80 00       	push   $0x8025a3
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
  800550:	68 59 29 80 00       	push   $0x802959
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
  800574:	b8 9c 25 80 00       	mov    $0x80259c,%eax
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
  800bef:	68 7f 28 80 00       	push   $0x80287f
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 9c 28 80 00       	push   $0x80289c
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
  800c70:	68 7f 28 80 00       	push   $0x80287f
  800c75:	6a 23                	push   $0x23
  800c77:	68 9c 28 80 00       	push   $0x80289c
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
  800cb2:	68 7f 28 80 00       	push   $0x80287f
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 9c 28 80 00       	push   $0x80289c
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
  800cf4:	68 7f 28 80 00       	push   $0x80287f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 9c 28 80 00       	push   $0x80289c
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
  800d36:	68 7f 28 80 00       	push   $0x80287f
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 9c 28 80 00       	push   $0x80289c
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
  800d78:	68 7f 28 80 00       	push   $0x80287f
  800d7d:	6a 23                	push   $0x23
  800d7f:	68 9c 28 80 00       	push   $0x80289c
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
  800dba:	68 7f 28 80 00       	push   $0x80287f
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 9c 28 80 00       	push   $0x80289c
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
  800e1e:	68 7f 28 80 00       	push   $0x80287f
  800e23:	6a 23                	push   $0x23
  800e25:	68 9c 28 80 00       	push   $0x80289c
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

00800e56 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e64:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 df                	mov    %ebx,%edi
  800e71:	89 de                	mov    %ebx,%esi
  800e73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 17                	jle    800e90 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	50                   	push   %eax
  800e7d:	6a 0f                	push   $0xf
  800e7f:	68 7f 28 80 00       	push   $0x80287f
  800e84:	6a 23                	push   $0x23
  800e86:	68 9c 28 80 00       	push   $0x80289c
  800e8b:	e8 55 f3 ff ff       	call   8001e5 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea6:	b8 10 00 00 00       	mov    $0x10,%eax
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	89 df                	mov    %ebx,%edi
  800eb3:	89 de                	mov    %ebx,%esi
  800eb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 17                	jle    800ed2 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	50                   	push   %eax
  800ebf:	6a 10                	push   $0x10
  800ec1:	68 7f 28 80 00       	push   $0x80287f
  800ec6:	6a 23                	push   $0x23
  800ec8:	68 9c 28 80 00       	push   $0x80289c
  800ecd:	e8 13 f3 ff ff       	call   8001e5 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee5:	c1 e8 0c             	shr    $0xc,%eax
}
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800efa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f07:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f0c:	89 c2                	mov    %eax,%edx
  800f0e:	c1 ea 16             	shr    $0x16,%edx
  800f11:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f18:	f6 c2 01             	test   $0x1,%dl
  800f1b:	74 11                	je     800f2e <fd_alloc+0x2d>
  800f1d:	89 c2                	mov    %eax,%edx
  800f1f:	c1 ea 0c             	shr    $0xc,%edx
  800f22:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f29:	f6 c2 01             	test   $0x1,%dl
  800f2c:	75 09                	jne    800f37 <fd_alloc+0x36>
			*fd_store = fd;
  800f2e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f30:	b8 00 00 00 00       	mov    $0x0,%eax
  800f35:	eb 17                	jmp    800f4e <fd_alloc+0x4d>
  800f37:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f3c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f41:	75 c9                	jne    800f0c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f43:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f49:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f56:	83 f8 1f             	cmp    $0x1f,%eax
  800f59:	77 36                	ja     800f91 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f5b:	c1 e0 0c             	shl    $0xc,%eax
  800f5e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f63:	89 c2                	mov    %eax,%edx
  800f65:	c1 ea 16             	shr    $0x16,%edx
  800f68:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6f:	f6 c2 01             	test   $0x1,%dl
  800f72:	74 24                	je     800f98 <fd_lookup+0x48>
  800f74:	89 c2                	mov    %eax,%edx
  800f76:	c1 ea 0c             	shr    $0xc,%edx
  800f79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f80:	f6 c2 01             	test   $0x1,%dl
  800f83:	74 1a                	je     800f9f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f88:	89 02                	mov    %eax,(%edx)
	return 0;
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	eb 13                	jmp    800fa4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f96:	eb 0c                	jmp    800fa4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9d:	eb 05                	jmp    800fa4 <fd_lookup+0x54>
  800f9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	83 ec 08             	sub    $0x8,%esp
  800fac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800faf:	ba 2c 29 80 00       	mov    $0x80292c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb4:	eb 13                	jmp    800fc9 <dev_lookup+0x23>
  800fb6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fb9:	39 08                	cmp    %ecx,(%eax)
  800fbb:	75 0c                	jne    800fc9 <dev_lookup+0x23>
			*dev = devtab[i];
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc7:	eb 2e                	jmp    800ff7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc9:	8b 02                	mov    (%edx),%eax
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	75 e7                	jne    800fb6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fcf:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800fd4:	8b 40 48             	mov    0x48(%eax),%eax
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	51                   	push   %ecx
  800fdb:	50                   	push   %eax
  800fdc:	68 ac 28 80 00       	push   $0x8028ac
  800fe1:	e8 d8 f2 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 10             	sub    $0x10,%esp
  801001:	8b 75 08             	mov    0x8(%ebp),%esi
  801004:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801007:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801011:	c1 e8 0c             	shr    $0xc,%eax
  801014:	50                   	push   %eax
  801015:	e8 36 ff ff ff       	call   800f50 <fd_lookup>
  80101a:	83 c4 08             	add    $0x8,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	78 05                	js     801026 <fd_close+0x2d>
	    || fd != fd2)
  801021:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801024:	74 0c                	je     801032 <fd_close+0x39>
		return (must_exist ? r : 0);
  801026:	84 db                	test   %bl,%bl
  801028:	ba 00 00 00 00       	mov    $0x0,%edx
  80102d:	0f 44 c2             	cmove  %edx,%eax
  801030:	eb 41                	jmp    801073 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801032:	83 ec 08             	sub    $0x8,%esp
  801035:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801038:	50                   	push   %eax
  801039:	ff 36                	pushl  (%esi)
  80103b:	e8 66 ff ff ff       	call   800fa6 <dev_lookup>
  801040:	89 c3                	mov    %eax,%ebx
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	85 c0                	test   %eax,%eax
  801047:	78 1a                	js     801063 <fd_close+0x6a>
		if (dev->dev_close)
  801049:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80104c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80104f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801054:	85 c0                	test   %eax,%eax
  801056:	74 0b                	je     801063 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	56                   	push   %esi
  80105c:	ff d0                	call   *%eax
  80105e:	89 c3                	mov    %eax,%ebx
  801060:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	56                   	push   %esi
  801067:	6a 00                	push   $0x0
  801069:	e8 5d fc ff ff       	call   800ccb <sys_page_unmap>
	return r;
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	89 d8                	mov    %ebx,%eax
}
  801073:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801083:	50                   	push   %eax
  801084:	ff 75 08             	pushl  0x8(%ebp)
  801087:	e8 c4 fe ff ff       	call   800f50 <fd_lookup>
  80108c:	83 c4 08             	add    $0x8,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	78 10                	js     8010a3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801093:	83 ec 08             	sub    $0x8,%esp
  801096:	6a 01                	push   $0x1
  801098:	ff 75 f4             	pushl  -0xc(%ebp)
  80109b:	e8 59 ff ff ff       	call   800ff9 <fd_close>
  8010a0:	83 c4 10             	add    $0x10,%esp
}
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    

008010a5 <close_all>:

void
close_all(void)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	53                   	push   %ebx
  8010b5:	e8 c0 ff ff ff       	call   80107a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ba:	83 c3 01             	add    $0x1,%ebx
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	83 fb 20             	cmp    $0x20,%ebx
  8010c3:	75 ec                	jne    8010b1 <close_all+0xc>
		close(i);
}
  8010c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 2c             	sub    $0x2c,%esp
  8010d3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	ff 75 08             	pushl  0x8(%ebp)
  8010dd:	e8 6e fe ff ff       	call   800f50 <fd_lookup>
  8010e2:	83 c4 08             	add    $0x8,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	0f 88 c1 00 00 00    	js     8011ae <dup+0xe4>
		return r;
	close(newfdnum);
  8010ed:	83 ec 0c             	sub    $0xc,%esp
  8010f0:	56                   	push   %esi
  8010f1:	e8 84 ff ff ff       	call   80107a <close>

	newfd = INDEX2FD(newfdnum);
  8010f6:	89 f3                	mov    %esi,%ebx
  8010f8:	c1 e3 0c             	shl    $0xc,%ebx
  8010fb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801101:	83 c4 04             	add    $0x4,%esp
  801104:	ff 75 e4             	pushl  -0x1c(%ebp)
  801107:	e8 de fd ff ff       	call   800eea <fd2data>
  80110c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80110e:	89 1c 24             	mov    %ebx,(%esp)
  801111:	e8 d4 fd ff ff       	call   800eea <fd2data>
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80111c:	89 f8                	mov    %edi,%eax
  80111e:	c1 e8 16             	shr    $0x16,%eax
  801121:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801128:	a8 01                	test   $0x1,%al
  80112a:	74 37                	je     801163 <dup+0x99>
  80112c:	89 f8                	mov    %edi,%eax
  80112e:	c1 e8 0c             	shr    $0xc,%eax
  801131:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801138:	f6 c2 01             	test   $0x1,%dl
  80113b:	74 26                	je     801163 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80113d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	25 07 0e 00 00       	and    $0xe07,%eax
  80114c:	50                   	push   %eax
  80114d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801150:	6a 00                	push   $0x0
  801152:	57                   	push   %edi
  801153:	6a 00                	push   $0x0
  801155:	e8 2f fb ff ff       	call   800c89 <sys_page_map>
  80115a:	89 c7                	mov    %eax,%edi
  80115c:	83 c4 20             	add    $0x20,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 2e                	js     801191 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801163:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801166:	89 d0                	mov    %edx,%eax
  801168:	c1 e8 0c             	shr    $0xc,%eax
  80116b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801172:	83 ec 0c             	sub    $0xc,%esp
  801175:	25 07 0e 00 00       	and    $0xe07,%eax
  80117a:	50                   	push   %eax
  80117b:	53                   	push   %ebx
  80117c:	6a 00                	push   $0x0
  80117e:	52                   	push   %edx
  80117f:	6a 00                	push   $0x0
  801181:	e8 03 fb ff ff       	call   800c89 <sys_page_map>
  801186:	89 c7                	mov    %eax,%edi
  801188:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80118b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80118d:	85 ff                	test   %edi,%edi
  80118f:	79 1d                	jns    8011ae <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801191:	83 ec 08             	sub    $0x8,%esp
  801194:	53                   	push   %ebx
  801195:	6a 00                	push   $0x0
  801197:	e8 2f fb ff ff       	call   800ccb <sys_page_unmap>
	sys_page_unmap(0, nva);
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011a2:	6a 00                	push   $0x0
  8011a4:	e8 22 fb ff ff       	call   800ccb <sys_page_unmap>
	return r;
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	89 f8                	mov    %edi,%eax
}
  8011ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5f                   	pop    %edi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	53                   	push   %ebx
  8011ba:	83 ec 14             	sub    $0x14,%esp
  8011bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	53                   	push   %ebx
  8011c5:	e8 86 fd ff ff       	call   800f50 <fd_lookup>
  8011ca:	83 c4 08             	add    $0x8,%esp
  8011cd:	89 c2                	mov    %eax,%edx
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 6d                	js     801240 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dd:	ff 30                	pushl  (%eax)
  8011df:	e8 c2 fd ff ff       	call   800fa6 <dev_lookup>
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 4c                	js     801237 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ee:	8b 42 08             	mov    0x8(%edx),%eax
  8011f1:	83 e0 03             	and    $0x3,%eax
  8011f4:	83 f8 01             	cmp    $0x1,%eax
  8011f7:	75 21                	jne    80121a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011fe:	8b 40 48             	mov    0x48(%eax),%eax
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	53                   	push   %ebx
  801205:	50                   	push   %eax
  801206:	68 f0 28 80 00       	push   $0x8028f0
  80120b:	e8 ae f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801218:	eb 26                	jmp    801240 <read+0x8a>
	}
	if (!dev->dev_read)
  80121a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121d:	8b 40 08             	mov    0x8(%eax),%eax
  801220:	85 c0                	test   %eax,%eax
  801222:	74 17                	je     80123b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801224:	83 ec 04             	sub    $0x4,%esp
  801227:	ff 75 10             	pushl  0x10(%ebp)
  80122a:	ff 75 0c             	pushl  0xc(%ebp)
  80122d:	52                   	push   %edx
  80122e:	ff d0                	call   *%eax
  801230:	89 c2                	mov    %eax,%edx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	eb 09                	jmp    801240 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801237:	89 c2                	mov    %eax,%edx
  801239:	eb 05                	jmp    801240 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80123b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801240:	89 d0                	mov    %edx,%eax
  801242:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	57                   	push   %edi
  80124b:	56                   	push   %esi
  80124c:	53                   	push   %ebx
  80124d:	83 ec 0c             	sub    $0xc,%esp
  801250:	8b 7d 08             	mov    0x8(%ebp),%edi
  801253:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125b:	eb 21                	jmp    80127e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80125d:	83 ec 04             	sub    $0x4,%esp
  801260:	89 f0                	mov    %esi,%eax
  801262:	29 d8                	sub    %ebx,%eax
  801264:	50                   	push   %eax
  801265:	89 d8                	mov    %ebx,%eax
  801267:	03 45 0c             	add    0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	57                   	push   %edi
  80126c:	e8 45 ff ff ff       	call   8011b6 <read>
		if (m < 0)
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 10                	js     801288 <readn+0x41>
			return m;
		if (m == 0)
  801278:	85 c0                	test   %eax,%eax
  80127a:	74 0a                	je     801286 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80127c:	01 c3                	add    %eax,%ebx
  80127e:	39 f3                	cmp    %esi,%ebx
  801280:	72 db                	jb     80125d <readn+0x16>
  801282:	89 d8                	mov    %ebx,%eax
  801284:	eb 02                	jmp    801288 <readn+0x41>
  801286:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5f                   	pop    %edi
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	53                   	push   %ebx
  801294:	83 ec 14             	sub    $0x14,%esp
  801297:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	53                   	push   %ebx
  80129f:	e8 ac fc ff ff       	call   800f50 <fd_lookup>
  8012a4:	83 c4 08             	add    $0x8,%esp
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 68                	js     801315 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b7:	ff 30                	pushl  (%eax)
  8012b9:	e8 e8 fc ff ff       	call   800fa6 <dev_lookup>
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 47                	js     80130c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012cc:	75 21                	jne    8012ef <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ce:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012d3:	8b 40 48             	mov    0x48(%eax),%eax
  8012d6:	83 ec 04             	sub    $0x4,%esp
  8012d9:	53                   	push   %ebx
  8012da:	50                   	push   %eax
  8012db:	68 0c 29 80 00       	push   $0x80290c
  8012e0:	e8 d9 ef ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ed:	eb 26                	jmp    801315 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8012f5:	85 d2                	test   %edx,%edx
  8012f7:	74 17                	je     801310 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012f9:	83 ec 04             	sub    $0x4,%esp
  8012fc:	ff 75 10             	pushl  0x10(%ebp)
  8012ff:	ff 75 0c             	pushl  0xc(%ebp)
  801302:	50                   	push   %eax
  801303:	ff d2                	call   *%edx
  801305:	89 c2                	mov    %eax,%edx
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	eb 09                	jmp    801315 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	eb 05                	jmp    801315 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801310:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801315:	89 d0                	mov    %edx,%eax
  801317:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131a:	c9                   	leave  
  80131b:	c3                   	ret    

0080131c <seek>:

int
seek(int fdnum, off_t offset)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801322:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	ff 75 08             	pushl  0x8(%ebp)
  801329:	e8 22 fc ff ff       	call   800f50 <fd_lookup>
  80132e:	83 c4 08             	add    $0x8,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 0e                	js     801343 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801335:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80133e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 14             	sub    $0x14,%esp
  80134c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	53                   	push   %ebx
  801354:	e8 f7 fb ff ff       	call   800f50 <fd_lookup>
  801359:	83 c4 08             	add    $0x8,%esp
  80135c:	89 c2                	mov    %eax,%edx
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 65                	js     8013c7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801368:	50                   	push   %eax
  801369:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136c:	ff 30                	pushl  (%eax)
  80136e:	e8 33 fc ff ff       	call   800fa6 <dev_lookup>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	78 44                	js     8013be <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80137a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801381:	75 21                	jne    8013a4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801383:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801388:	8b 40 48             	mov    0x48(%eax),%eax
  80138b:	83 ec 04             	sub    $0x4,%esp
  80138e:	53                   	push   %ebx
  80138f:	50                   	push   %eax
  801390:	68 cc 28 80 00       	push   $0x8028cc
  801395:	e8 24 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013a2:	eb 23                	jmp    8013c7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a7:	8b 52 18             	mov    0x18(%edx),%edx
  8013aa:	85 d2                	test   %edx,%edx
  8013ac:	74 14                	je     8013c2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013ae:	83 ec 08             	sub    $0x8,%esp
  8013b1:	ff 75 0c             	pushl  0xc(%ebp)
  8013b4:	50                   	push   %eax
  8013b5:	ff d2                	call   *%edx
  8013b7:	89 c2                	mov    %eax,%edx
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	eb 09                	jmp    8013c7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013be:	89 c2                	mov    %eax,%edx
  8013c0:	eb 05                	jmp    8013c7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013c7:	89 d0                	mov    %edx,%eax
  8013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 14             	sub    $0x14,%esp
  8013d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	ff 75 08             	pushl  0x8(%ebp)
  8013df:	e8 6c fb ff ff       	call   800f50 <fd_lookup>
  8013e4:	83 c4 08             	add    $0x8,%esp
  8013e7:	89 c2                	mov    %eax,%edx
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 58                	js     801445 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f3:	50                   	push   %eax
  8013f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f7:	ff 30                	pushl  (%eax)
  8013f9:	e8 a8 fb ff ff       	call   800fa6 <dev_lookup>
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 37                	js     80143c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801405:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801408:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80140c:	74 32                	je     801440 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80140e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801411:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801418:	00 00 00 
	stat->st_isdir = 0;
  80141b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801422:	00 00 00 
	stat->st_dev = dev;
  801425:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	53                   	push   %ebx
  80142f:	ff 75 f0             	pushl  -0x10(%ebp)
  801432:	ff 50 14             	call   *0x14(%eax)
  801435:	89 c2                	mov    %eax,%edx
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	eb 09                	jmp    801445 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	eb 05                	jmp    801445 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801440:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801445:	89 d0                	mov    %edx,%eax
  801447:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	56                   	push   %esi
  801450:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	6a 00                	push   $0x0
  801456:	ff 75 08             	pushl  0x8(%ebp)
  801459:	e8 d6 01 00 00       	call   801634 <open>
  80145e:	89 c3                	mov    %eax,%ebx
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	78 1b                	js     801482 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	ff 75 0c             	pushl  0xc(%ebp)
  80146d:	50                   	push   %eax
  80146e:	e8 5b ff ff ff       	call   8013ce <fstat>
  801473:	89 c6                	mov    %eax,%esi
	close(fd);
  801475:	89 1c 24             	mov    %ebx,(%esp)
  801478:	e8 fd fb ff ff       	call   80107a <close>
	return r;
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	89 f0                	mov    %esi,%eax
}
  801482:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801485:	5b                   	pop    %ebx
  801486:	5e                   	pop    %esi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
  80148e:	89 c6                	mov    %eax,%esi
  801490:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801492:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801499:	75 12                	jne    8014ad <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80149b:	83 ec 0c             	sub    $0xc,%esp
  80149e:	6a 01                	push   $0x1
  8014a0:	e8 44 0d 00 00       	call   8021e9 <ipc_find_env>
  8014a5:	a3 04 40 80 00       	mov    %eax,0x804004
  8014aa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014ad:	6a 07                	push   $0x7
  8014af:	68 00 50 80 00       	push   $0x805000
  8014b4:	56                   	push   %esi
  8014b5:	ff 35 04 40 80 00    	pushl  0x804004
  8014bb:	e8 d5 0c 00 00       	call   802195 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014c0:	83 c4 0c             	add    $0xc,%esp
  8014c3:	6a 00                	push   $0x0
  8014c5:	53                   	push   %ebx
  8014c6:	6a 00                	push   $0x0
  8014c8:	e8 61 0c 00 00       	call   80212e <ipc_recv>
}
  8014cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d0:	5b                   	pop    %ebx
  8014d1:	5e                   	pop    %esi
  8014d2:	5d                   	pop    %ebp
  8014d3:	c3                   	ret    

008014d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014da:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8014f7:	e8 8d ff ff ff       	call   801489 <fsipc>
}
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	8b 40 0c             	mov    0xc(%eax),%eax
  80150a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80150f:	ba 00 00 00 00       	mov    $0x0,%edx
  801514:	b8 06 00 00 00       	mov    $0x6,%eax
  801519:	e8 6b ff ff ff       	call   801489 <fsipc>
}
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	53                   	push   %ebx
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80152a:	8b 45 08             	mov    0x8(%ebp),%eax
  80152d:	8b 40 0c             	mov    0xc(%eax),%eax
  801530:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801535:	ba 00 00 00 00       	mov    $0x0,%edx
  80153a:	b8 05 00 00 00       	mov    $0x5,%eax
  80153f:	e8 45 ff ff ff       	call   801489 <fsipc>
  801544:	85 c0                	test   %eax,%eax
  801546:	78 2c                	js     801574 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	68 00 50 80 00       	push   $0x805000
  801550:	53                   	push   %ebx
  801551:	e8 ed f2 ff ff       	call   800843 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801556:	a1 80 50 80 00       	mov    0x805080,%eax
  80155b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801561:	a1 84 50 80 00       	mov    0x805084,%eax
  801566:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801574:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801582:	8b 55 08             	mov    0x8(%ebp),%edx
  801585:	8b 52 0c             	mov    0xc(%edx),%edx
  801588:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80158e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801593:	50                   	push   %eax
  801594:	ff 75 0c             	pushl  0xc(%ebp)
  801597:	68 08 50 80 00       	push   $0x805008
  80159c:	e8 34 f4 ff ff       	call   8009d5 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8015a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ab:	e8 d9 fe ff ff       	call   801489 <fsipc>

}
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
  8015b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015c5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8015d5:	e8 af fe ff ff       	call   801489 <fsipc>
  8015da:	89 c3                	mov    %eax,%ebx
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 4b                	js     80162b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015e0:	39 c6                	cmp    %eax,%esi
  8015e2:	73 16                	jae    8015fa <devfile_read+0x48>
  8015e4:	68 40 29 80 00       	push   $0x802940
  8015e9:	68 47 29 80 00       	push   $0x802947
  8015ee:	6a 7c                	push   $0x7c
  8015f0:	68 5c 29 80 00       	push   $0x80295c
  8015f5:	e8 eb eb ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  8015fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015ff:	7e 16                	jle    801617 <devfile_read+0x65>
  801601:	68 67 29 80 00       	push   $0x802967
  801606:	68 47 29 80 00       	push   $0x802947
  80160b:	6a 7d                	push   $0x7d
  80160d:	68 5c 29 80 00       	push   $0x80295c
  801612:	e8 ce eb ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801617:	83 ec 04             	sub    $0x4,%esp
  80161a:	50                   	push   %eax
  80161b:	68 00 50 80 00       	push   $0x805000
  801620:	ff 75 0c             	pushl  0xc(%ebp)
  801623:	e8 ad f3 ff ff       	call   8009d5 <memmove>
	return r;
  801628:	83 c4 10             	add    $0x10,%esp
}
  80162b:	89 d8                	mov    %ebx,%eax
  80162d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801630:	5b                   	pop    %ebx
  801631:	5e                   	pop    %esi
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    

00801634 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	53                   	push   %ebx
  801638:	83 ec 20             	sub    $0x20,%esp
  80163b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80163e:	53                   	push   %ebx
  80163f:	e8 c6 f1 ff ff       	call   80080a <strlen>
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80164c:	7f 67                	jg     8016b5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	e8 a7 f8 ff ff       	call   800f01 <fd_alloc>
  80165a:	83 c4 10             	add    $0x10,%esp
		return r;
  80165d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 57                	js     8016ba <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	53                   	push   %ebx
  801667:	68 00 50 80 00       	push   $0x805000
  80166c:	e8 d2 f1 ff ff       	call   800843 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801671:	8b 45 0c             	mov    0xc(%ebp),%eax
  801674:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801679:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167c:	b8 01 00 00 00       	mov    $0x1,%eax
  801681:	e8 03 fe ff ff       	call   801489 <fsipc>
  801686:	89 c3                	mov    %eax,%ebx
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	79 14                	jns    8016a3 <open+0x6f>
		fd_close(fd, 0);
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	6a 00                	push   $0x0
  801694:	ff 75 f4             	pushl  -0xc(%ebp)
  801697:	e8 5d f9 ff ff       	call   800ff9 <fd_close>
		return r;
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	89 da                	mov    %ebx,%edx
  8016a1:	eb 17                	jmp    8016ba <open+0x86>
	}

	return fd2num(fd);
  8016a3:	83 ec 0c             	sub    $0xc,%esp
  8016a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a9:	e8 2c f8 ff ff       	call   800eda <fd2num>
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	eb 05                	jmp    8016ba <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016b5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016ba:	89 d0                	mov    %edx,%eax
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8016d1:	e8 b3 fd ff ff       	call   801489 <fsipc>
}
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016d8:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016dc:	7e 37                	jle    801715 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016e7:	ff 70 04             	pushl  0x4(%eax)
  8016ea:	8d 40 10             	lea    0x10(%eax),%eax
  8016ed:	50                   	push   %eax
  8016ee:	ff 33                	pushl  (%ebx)
  8016f0:	e8 9b fb ff ff       	call   801290 <write>
		if (result > 0)
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	7e 03                	jle    8016ff <writebuf+0x27>
			b->result += result;
  8016fc:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016ff:	3b 43 04             	cmp    0x4(%ebx),%eax
  801702:	74 0d                	je     801711 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801704:	85 c0                	test   %eax,%eax
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
  80170b:	0f 4f c2             	cmovg  %edx,%eax
  80170e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801711:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801714:	c9                   	leave  
  801715:	f3 c3                	repz ret 

00801717 <putch>:

static void
putch(int ch, void *thunk)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	83 ec 04             	sub    $0x4,%esp
  80171e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801721:	8b 53 04             	mov    0x4(%ebx),%edx
  801724:	8d 42 01             	lea    0x1(%edx),%eax
  801727:	89 43 04             	mov    %eax,0x4(%ebx)
  80172a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80172d:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801731:	3d 00 01 00 00       	cmp    $0x100,%eax
  801736:	75 0e                	jne    801746 <putch+0x2f>
		writebuf(b);
  801738:	89 d8                	mov    %ebx,%eax
  80173a:	e8 99 ff ff ff       	call   8016d8 <writebuf>
		b->idx = 0;
  80173f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801746:	83 c4 04             	add    $0x4,%esp
  801749:	5b                   	pop    %ebx
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801755:	8b 45 08             	mov    0x8(%ebp),%eax
  801758:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80175e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801765:	00 00 00 
	b.result = 0;
  801768:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80176f:	00 00 00 
	b.error = 1;
  801772:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801779:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80177c:	ff 75 10             	pushl  0x10(%ebp)
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801788:	50                   	push   %eax
  801789:	68 17 17 80 00       	push   $0x801717
  80178e:	e8 62 ec ff ff       	call   8003f5 <vprintfmt>
	if (b.idx > 0)
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80179d:	7e 0b                	jle    8017aa <vfprintf+0x5e>
		writebuf(&b);
  80179f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017a5:	e8 2e ff ff ff       	call   8016d8 <writebuf>

	return (b.result ? b.result : b.error);
  8017aa:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017b9:	c9                   	leave  
  8017ba:	c3                   	ret    

008017bb <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017c1:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017c4:	50                   	push   %eax
  8017c5:	ff 75 0c             	pushl  0xc(%ebp)
  8017c8:	ff 75 08             	pushl  0x8(%ebp)
  8017cb:	e8 7c ff ff ff       	call   80174c <vfprintf>
	va_end(ap);

	return cnt;
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <printf>:

int
printf(const char *fmt, ...)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017d8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017db:	50                   	push   %eax
  8017dc:	ff 75 08             	pushl  0x8(%ebp)
  8017df:	6a 01                	push   $0x1
  8017e1:	e8 66 ff ff ff       	call   80174c <vfprintf>
	va_end(ap);

	return cnt;
}
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8017ee:	68 73 29 80 00       	push   $0x802973
  8017f3:	ff 75 0c             	pushl  0xc(%ebp)
  8017f6:	e8 48 f0 ff ff       	call   800843 <strcpy>
	return 0;
}
  8017fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	53                   	push   %ebx
  801806:	83 ec 10             	sub    $0x10,%esp
  801809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80180c:	53                   	push   %ebx
  80180d:	e8 10 0a 00 00       	call   802222 <pageref>
  801812:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801815:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80181a:	83 f8 01             	cmp    $0x1,%eax
  80181d:	75 10                	jne    80182f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	ff 73 0c             	pushl  0xc(%ebx)
  801825:	e8 c0 02 00 00       	call   801aea <nsipc_close>
  80182a:	89 c2                	mov    %eax,%edx
  80182c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80182f:	89 d0                	mov    %edx,%eax
  801831:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80183c:	6a 00                	push   $0x0
  80183e:	ff 75 10             	pushl  0x10(%ebp)
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	ff 70 0c             	pushl  0xc(%eax)
  80184a:	e8 78 03 00 00       	call   801bc7 <nsipc_send>
}
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801857:	6a 00                	push   $0x0
  801859:	ff 75 10             	pushl  0x10(%ebp)
  80185c:	ff 75 0c             	pushl  0xc(%ebp)
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	ff 70 0c             	pushl  0xc(%eax)
  801865:	e8 f1 02 00 00       	call   801b5b <nsipc_recv>
}
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801872:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801875:	52                   	push   %edx
  801876:	50                   	push   %eax
  801877:	e8 d4 f6 ff ff       	call   800f50 <fd_lookup>
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 17                	js     80189a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801883:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801886:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  80188c:	39 08                	cmp    %ecx,(%eax)
  80188e:	75 05                	jne    801895 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801890:	8b 40 0c             	mov    0xc(%eax),%eax
  801893:	eb 05                	jmp    80189a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801895:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	56                   	push   %esi
  8018a0:	53                   	push   %ebx
  8018a1:	83 ec 1c             	sub    $0x1c,%esp
  8018a4:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a9:	50                   	push   %eax
  8018aa:	e8 52 f6 ff ff       	call   800f01 <fd_alloc>
  8018af:	89 c3                	mov    %eax,%ebx
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 1b                	js     8018d3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018b8:	83 ec 04             	sub    $0x4,%esp
  8018bb:	68 07 04 00 00       	push   $0x407
  8018c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 7c f3 ff ff       	call   800c46 <sys_page_alloc>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	79 10                	jns    8018e3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8018d3:	83 ec 0c             	sub    $0xc,%esp
  8018d6:	56                   	push   %esi
  8018d7:	e8 0e 02 00 00       	call   801aea <nsipc_close>
		return r;
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	89 d8                	mov    %ebx,%eax
  8018e1:	eb 24                	jmp    801907 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8018e3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8018f8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	50                   	push   %eax
  8018ff:	e8 d6 f5 ff ff       	call   800eda <fd2num>
  801904:	83 c4 10             	add    $0x10,%esp
}
  801907:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801914:	8b 45 08             	mov    0x8(%ebp),%eax
  801917:	e8 50 ff ff ff       	call   80186c <fd2sockid>
		return r;
  80191c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 1f                	js     801941 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801922:	83 ec 04             	sub    $0x4,%esp
  801925:	ff 75 10             	pushl  0x10(%ebp)
  801928:	ff 75 0c             	pushl  0xc(%ebp)
  80192b:	50                   	push   %eax
  80192c:	e8 12 01 00 00       	call   801a43 <nsipc_accept>
  801931:	83 c4 10             	add    $0x10,%esp
		return r;
  801934:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801936:	85 c0                	test   %eax,%eax
  801938:	78 07                	js     801941 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80193a:	e8 5d ff ff ff       	call   80189c <alloc_sockfd>
  80193f:	89 c1                	mov    %eax,%ecx
}
  801941:	89 c8                	mov    %ecx,%eax
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80194b:	8b 45 08             	mov    0x8(%ebp),%eax
  80194e:	e8 19 ff ff ff       	call   80186c <fd2sockid>
  801953:	85 c0                	test   %eax,%eax
  801955:	78 12                	js     801969 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	ff 75 10             	pushl  0x10(%ebp)
  80195d:	ff 75 0c             	pushl  0xc(%ebp)
  801960:	50                   	push   %eax
  801961:	e8 2d 01 00 00       	call   801a93 <nsipc_bind>
  801966:	83 c4 10             	add    $0x10,%esp
}
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <shutdown>:

int
shutdown(int s, int how)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801971:	8b 45 08             	mov    0x8(%ebp),%eax
  801974:	e8 f3 fe ff ff       	call   80186c <fd2sockid>
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 0f                	js     80198c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	ff 75 0c             	pushl  0xc(%ebp)
  801983:	50                   	push   %eax
  801984:	e8 3f 01 00 00       	call   801ac8 <nsipc_shutdown>
  801989:	83 c4 10             	add    $0x10,%esp
}
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	e8 d0 fe ff ff       	call   80186c <fd2sockid>
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 12                	js     8019b2 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8019a0:	83 ec 04             	sub    $0x4,%esp
  8019a3:	ff 75 10             	pushl  0x10(%ebp)
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	50                   	push   %eax
  8019aa:	e8 55 01 00 00       	call   801b04 <nsipc_connect>
  8019af:	83 c4 10             	add    $0x10,%esp
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <listen>:

int
listen(int s, int backlog)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	e8 aa fe ff ff       	call   80186c <fd2sockid>
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 0f                	js     8019d5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8019c6:	83 ec 08             	sub    $0x8,%esp
  8019c9:	ff 75 0c             	pushl  0xc(%ebp)
  8019cc:	50                   	push   %eax
  8019cd:	e8 67 01 00 00       	call   801b39 <nsipc_listen>
  8019d2:	83 c4 10             	add    $0x10,%esp
}
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    

008019d7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019dd:	ff 75 10             	pushl  0x10(%ebp)
  8019e0:	ff 75 0c             	pushl  0xc(%ebp)
  8019e3:	ff 75 08             	pushl  0x8(%ebp)
  8019e6:	e8 3a 02 00 00       	call   801c25 <nsipc_socket>
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 05                	js     8019f7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8019f2:	e8 a5 fe ff ff       	call   80189c <alloc_sockfd>
}
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    

008019f9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 04             	sub    $0x4,%esp
  801a00:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a02:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801a09:	75 12                	jne    801a1d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a0b:	83 ec 0c             	sub    $0xc,%esp
  801a0e:	6a 02                	push   $0x2
  801a10:	e8 d4 07 00 00       	call   8021e9 <ipc_find_env>
  801a15:	a3 08 40 80 00       	mov    %eax,0x804008
  801a1a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a1d:	6a 07                	push   $0x7
  801a1f:	68 00 60 80 00       	push   $0x806000
  801a24:	53                   	push   %ebx
  801a25:	ff 35 08 40 80 00    	pushl  0x804008
  801a2b:	e8 65 07 00 00       	call   802195 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a30:	83 c4 0c             	add    $0xc,%esp
  801a33:	6a 00                	push   $0x0
  801a35:	6a 00                	push   $0x0
  801a37:	6a 00                	push   $0x0
  801a39:	e8 f0 06 00 00       	call   80212e <ipc_recv>
}
  801a3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
  801a48:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a53:	8b 06                	mov    (%esi),%eax
  801a55:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5f:	e8 95 ff ff ff       	call   8019f9 <nsipc>
  801a64:	89 c3                	mov    %eax,%ebx
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 20                	js     801a8a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a6a:	83 ec 04             	sub    $0x4,%esp
  801a6d:	ff 35 10 60 80 00    	pushl  0x806010
  801a73:	68 00 60 80 00       	push   $0x806000
  801a78:	ff 75 0c             	pushl  0xc(%ebp)
  801a7b:	e8 55 ef ff ff       	call   8009d5 <memmove>
		*addrlen = ret->ret_addrlen;
  801a80:	a1 10 60 80 00       	mov    0x806010,%eax
  801a85:	89 06                	mov    %eax,(%esi)
  801a87:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801a8a:	89 d8                	mov    %ebx,%eax
  801a8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	53                   	push   %ebx
  801a97:	83 ec 08             	sub    $0x8,%esp
  801a9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801aa5:	53                   	push   %ebx
  801aa6:	ff 75 0c             	pushl  0xc(%ebp)
  801aa9:	68 04 60 80 00       	push   $0x806004
  801aae:	e8 22 ef ff ff       	call   8009d5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ab3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ab9:	b8 02 00 00 00       	mov    $0x2,%eax
  801abe:	e8 36 ff ff ff       	call   8019f9 <nsipc>
}
  801ac3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ade:	b8 03 00 00 00       	mov    $0x3,%eax
  801ae3:	e8 11 ff ff ff       	call   8019f9 <nsipc>
}
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <nsipc_close>:

int
nsipc_close(int s)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801af8:	b8 04 00 00 00       	mov    $0x4,%eax
  801afd:	e8 f7 fe ff ff       	call   8019f9 <nsipc>
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	53                   	push   %ebx
  801b08:	83 ec 08             	sub    $0x8,%esp
  801b0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b16:	53                   	push   %ebx
  801b17:	ff 75 0c             	pushl  0xc(%ebp)
  801b1a:	68 04 60 80 00       	push   $0x806004
  801b1f:	e8 b1 ee ff ff       	call   8009d5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b24:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b2a:	b8 05 00 00 00       	mov    $0x5,%eax
  801b2f:	e8 c5 fe ff ff       	call   8019f9 <nsipc>
}
  801b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b42:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b4f:	b8 06 00 00 00       	mov    $0x6,%eax
  801b54:	e8 a0 fe ff ff       	call   8019f9 <nsipc>
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	56                   	push   %esi
  801b5f:	53                   	push   %ebx
  801b60:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b63:	8b 45 08             	mov    0x8(%ebp),%eax
  801b66:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b6b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b71:	8b 45 14             	mov    0x14(%ebp),%eax
  801b74:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b79:	b8 07 00 00 00       	mov    $0x7,%eax
  801b7e:	e8 76 fe ff ff       	call   8019f9 <nsipc>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 35                	js     801bbe <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801b89:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b8e:	7f 04                	jg     801b94 <nsipc_recv+0x39>
  801b90:	39 c6                	cmp    %eax,%esi
  801b92:	7d 16                	jge    801baa <nsipc_recv+0x4f>
  801b94:	68 7f 29 80 00       	push   $0x80297f
  801b99:	68 47 29 80 00       	push   $0x802947
  801b9e:	6a 62                	push   $0x62
  801ba0:	68 94 29 80 00       	push   $0x802994
  801ba5:	e8 3b e6 ff ff       	call   8001e5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801baa:	83 ec 04             	sub    $0x4,%esp
  801bad:	50                   	push   %eax
  801bae:	68 00 60 80 00       	push   $0x806000
  801bb3:	ff 75 0c             	pushl  0xc(%ebp)
  801bb6:	e8 1a ee ff ff       	call   8009d5 <memmove>
  801bbb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801bbe:	89 d8                	mov    %ebx,%eax
  801bc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5d                   	pop    %ebp
  801bc6:	c3                   	ret    

00801bc7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	53                   	push   %ebx
  801bcb:	83 ec 04             	sub    $0x4,%esp
  801bce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801bd9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801bdf:	7e 16                	jle    801bf7 <nsipc_send+0x30>
  801be1:	68 a0 29 80 00       	push   $0x8029a0
  801be6:	68 47 29 80 00       	push   $0x802947
  801beb:	6a 6d                	push   $0x6d
  801bed:	68 94 29 80 00       	push   $0x802994
  801bf2:	e8 ee e5 ff ff       	call   8001e5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801bf7:	83 ec 04             	sub    $0x4,%esp
  801bfa:	53                   	push   %ebx
  801bfb:	ff 75 0c             	pushl  0xc(%ebp)
  801bfe:	68 0c 60 80 00       	push   $0x80600c
  801c03:	e8 cd ed ff ff       	call   8009d5 <memmove>
	nsipcbuf.send.req_size = size;
  801c08:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c0e:	8b 45 14             	mov    0x14(%ebp),%eax
  801c11:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c16:	b8 08 00 00 00       	mov    $0x8,%eax
  801c1b:	e8 d9 fd ff ff       	call   8019f9 <nsipc>
}
  801c20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c36:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c43:	b8 09 00 00 00       	mov    $0x9,%eax
  801c48:	e8 ac fd ff ff       	call   8019f9 <nsipc>
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c57:	83 ec 0c             	sub    $0xc,%esp
  801c5a:	ff 75 08             	pushl  0x8(%ebp)
  801c5d:	e8 88 f2 ff ff       	call   800eea <fd2data>
  801c62:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c64:	83 c4 08             	add    $0x8,%esp
  801c67:	68 ac 29 80 00       	push   $0x8029ac
  801c6c:	53                   	push   %ebx
  801c6d:	e8 d1 eb ff ff       	call   800843 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c72:	8b 46 04             	mov    0x4(%esi),%eax
  801c75:	2b 06                	sub    (%esi),%eax
  801c77:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c7d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c84:	00 00 00 
	stat->st_dev = &devpipe;
  801c87:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801c8e:	30 80 00 
	return 0;
}
  801c91:	b8 00 00 00 00       	mov    $0x0,%eax
  801c96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c99:	5b                   	pop    %ebx
  801c9a:	5e                   	pop    %esi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	53                   	push   %ebx
  801ca1:	83 ec 0c             	sub    $0xc,%esp
  801ca4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ca7:	53                   	push   %ebx
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 1c f0 ff ff       	call   800ccb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801caf:	89 1c 24             	mov    %ebx,(%esp)
  801cb2:	e8 33 f2 ff ff       	call   800eea <fd2data>
  801cb7:	83 c4 08             	add    $0x8,%esp
  801cba:	50                   	push   %eax
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 09 f0 ff ff       	call   800ccb <sys_page_unmap>
}
  801cc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	57                   	push   %edi
  801ccb:	56                   	push   %esi
  801ccc:	53                   	push   %ebx
  801ccd:	83 ec 1c             	sub    $0x1c,%esp
  801cd0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cd3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cd5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801cda:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cdd:	83 ec 0c             	sub    $0xc,%esp
  801ce0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ce3:	e8 3a 05 00 00       	call   802222 <pageref>
  801ce8:	89 c3                	mov    %eax,%ebx
  801cea:	89 3c 24             	mov    %edi,(%esp)
  801ced:	e8 30 05 00 00       	call   802222 <pageref>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	39 c3                	cmp    %eax,%ebx
  801cf7:	0f 94 c1             	sete   %cl
  801cfa:	0f b6 c9             	movzbl %cl,%ecx
  801cfd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d00:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801d06:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d09:	39 ce                	cmp    %ecx,%esi
  801d0b:	74 1b                	je     801d28 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d0d:	39 c3                	cmp    %eax,%ebx
  801d0f:	75 c4                	jne    801cd5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d11:	8b 42 58             	mov    0x58(%edx),%eax
  801d14:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d17:	50                   	push   %eax
  801d18:	56                   	push   %esi
  801d19:	68 b3 29 80 00       	push   $0x8029b3
  801d1e:	e8 9b e5 ff ff       	call   8002be <cprintf>
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	eb ad                	jmp    801cd5 <_pipeisclosed+0xe>
	}
}
  801d28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2e:	5b                   	pop    %ebx
  801d2f:	5e                   	pop    %esi
  801d30:	5f                   	pop    %edi
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	57                   	push   %edi
  801d37:	56                   	push   %esi
  801d38:	53                   	push   %ebx
  801d39:	83 ec 28             	sub    $0x28,%esp
  801d3c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d3f:	56                   	push   %esi
  801d40:	e8 a5 f1 ff ff       	call   800eea <fd2data>
  801d45:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d47:	83 c4 10             	add    $0x10,%esp
  801d4a:	bf 00 00 00 00       	mov    $0x0,%edi
  801d4f:	eb 4b                	jmp    801d9c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d51:	89 da                	mov    %ebx,%edx
  801d53:	89 f0                	mov    %esi,%eax
  801d55:	e8 6d ff ff ff       	call   801cc7 <_pipeisclosed>
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	75 48                	jne    801da6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d5e:	e8 c4 ee ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d63:	8b 43 04             	mov    0x4(%ebx),%eax
  801d66:	8b 0b                	mov    (%ebx),%ecx
  801d68:	8d 51 20             	lea    0x20(%ecx),%edx
  801d6b:	39 d0                	cmp    %edx,%eax
  801d6d:	73 e2                	jae    801d51 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d72:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d76:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d79:	89 c2                	mov    %eax,%edx
  801d7b:	c1 fa 1f             	sar    $0x1f,%edx
  801d7e:	89 d1                	mov    %edx,%ecx
  801d80:	c1 e9 1b             	shr    $0x1b,%ecx
  801d83:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d86:	83 e2 1f             	and    $0x1f,%edx
  801d89:	29 ca                	sub    %ecx,%edx
  801d8b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d8f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d93:	83 c0 01             	add    $0x1,%eax
  801d96:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d99:	83 c7 01             	add    $0x1,%edi
  801d9c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d9f:	75 c2                	jne    801d63 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801da1:	8b 45 10             	mov    0x10(%ebp),%eax
  801da4:	eb 05                	jmp    801dab <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dae:	5b                   	pop    %ebx
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    

00801db3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	57                   	push   %edi
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
  801db9:	83 ec 18             	sub    $0x18,%esp
  801dbc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dbf:	57                   	push   %edi
  801dc0:	e8 25 f1 ff ff       	call   800eea <fd2data>
  801dc5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dcf:	eb 3d                	jmp    801e0e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dd1:	85 db                	test   %ebx,%ebx
  801dd3:	74 04                	je     801dd9 <devpipe_read+0x26>
				return i;
  801dd5:	89 d8                	mov    %ebx,%eax
  801dd7:	eb 44                	jmp    801e1d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dd9:	89 f2                	mov    %esi,%edx
  801ddb:	89 f8                	mov    %edi,%eax
  801ddd:	e8 e5 fe ff ff       	call   801cc7 <_pipeisclosed>
  801de2:	85 c0                	test   %eax,%eax
  801de4:	75 32                	jne    801e18 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801de6:	e8 3c ee ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801deb:	8b 06                	mov    (%esi),%eax
  801ded:	3b 46 04             	cmp    0x4(%esi),%eax
  801df0:	74 df                	je     801dd1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df2:	99                   	cltd   
  801df3:	c1 ea 1b             	shr    $0x1b,%edx
  801df6:	01 d0                	add    %edx,%eax
  801df8:	83 e0 1f             	and    $0x1f,%eax
  801dfb:	29 d0                	sub    %edx,%eax
  801dfd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e05:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e08:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0b:	83 c3 01             	add    $0x1,%ebx
  801e0e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e11:	75 d8                	jne    801deb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e13:	8b 45 10             	mov    0x10(%ebp),%eax
  801e16:	eb 05                	jmp    801e1d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e20:	5b                   	pop    %ebx
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    

00801e25 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	56                   	push   %esi
  801e29:	53                   	push   %ebx
  801e2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e30:	50                   	push   %eax
  801e31:	e8 cb f0 ff ff       	call   800f01 <fd_alloc>
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	89 c2                	mov    %eax,%edx
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	0f 88 2c 01 00 00    	js     801f6f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e43:	83 ec 04             	sub    $0x4,%esp
  801e46:	68 07 04 00 00       	push   $0x407
  801e4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4e:	6a 00                	push   $0x0
  801e50:	e8 f1 ed ff ff       	call   800c46 <sys_page_alloc>
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	89 c2                	mov    %eax,%edx
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	0f 88 0d 01 00 00    	js     801f6f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e62:	83 ec 0c             	sub    $0xc,%esp
  801e65:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e68:	50                   	push   %eax
  801e69:	e8 93 f0 ff ff       	call   800f01 <fd_alloc>
  801e6e:	89 c3                	mov    %eax,%ebx
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	0f 88 e2 00 00 00    	js     801f5d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7b:	83 ec 04             	sub    $0x4,%esp
  801e7e:	68 07 04 00 00       	push   $0x407
  801e83:	ff 75 f0             	pushl  -0x10(%ebp)
  801e86:	6a 00                	push   $0x0
  801e88:	e8 b9 ed ff ff       	call   800c46 <sys_page_alloc>
  801e8d:	89 c3                	mov    %eax,%ebx
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	0f 88 c3 00 00 00    	js     801f5d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e9a:	83 ec 0c             	sub    $0xc,%esp
  801e9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea0:	e8 45 f0 ff ff       	call   800eea <fd2data>
  801ea5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea7:	83 c4 0c             	add    $0xc,%esp
  801eaa:	68 07 04 00 00       	push   $0x407
  801eaf:	50                   	push   %eax
  801eb0:	6a 00                	push   $0x0
  801eb2:	e8 8f ed ff ff       	call   800c46 <sys_page_alloc>
  801eb7:	89 c3                	mov    %eax,%ebx
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	0f 88 89 00 00 00    	js     801f4d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec4:	83 ec 0c             	sub    $0xc,%esp
  801ec7:	ff 75 f0             	pushl  -0x10(%ebp)
  801eca:	e8 1b f0 ff ff       	call   800eea <fd2data>
  801ecf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ed6:	50                   	push   %eax
  801ed7:	6a 00                	push   $0x0
  801ed9:	56                   	push   %esi
  801eda:	6a 00                	push   $0x0
  801edc:	e8 a8 ed ff ff       	call   800c89 <sys_page_map>
  801ee1:	89 c3                	mov    %eax,%ebx
  801ee3:	83 c4 20             	add    $0x20,%esp
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	78 55                	js     801f3f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801eea:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eff:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f08:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f14:	83 ec 0c             	sub    $0xc,%esp
  801f17:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1a:	e8 bb ef ff ff       	call   800eda <fd2num>
  801f1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f22:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f24:	83 c4 04             	add    $0x4,%esp
  801f27:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2a:	e8 ab ef ff ff       	call   800eda <fd2num>
  801f2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f32:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	ba 00 00 00 00       	mov    $0x0,%edx
  801f3d:	eb 30                	jmp    801f6f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f3f:	83 ec 08             	sub    $0x8,%esp
  801f42:	56                   	push   %esi
  801f43:	6a 00                	push   $0x0
  801f45:	e8 81 ed ff ff       	call   800ccb <sys_page_unmap>
  801f4a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f4d:	83 ec 08             	sub    $0x8,%esp
  801f50:	ff 75 f0             	pushl  -0x10(%ebp)
  801f53:	6a 00                	push   $0x0
  801f55:	e8 71 ed ff ff       	call   800ccb <sys_page_unmap>
  801f5a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f5d:	83 ec 08             	sub    $0x8,%esp
  801f60:	ff 75 f4             	pushl  -0xc(%ebp)
  801f63:	6a 00                	push   $0x0
  801f65:	e8 61 ed ff ff       	call   800ccb <sys_page_unmap>
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f6f:	89 d0                	mov    %edx,%eax
  801f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f81:	50                   	push   %eax
  801f82:	ff 75 08             	pushl  0x8(%ebp)
  801f85:	e8 c6 ef ff ff       	call   800f50 <fd_lookup>
  801f8a:	83 c4 10             	add    $0x10,%esp
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	78 18                	js     801fa9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f91:	83 ec 0c             	sub    $0xc,%esp
  801f94:	ff 75 f4             	pushl  -0xc(%ebp)
  801f97:	e8 4e ef ff ff       	call   800eea <fd2data>
	return _pipeisclosed(fd, p);
  801f9c:	89 c2                	mov    %eax,%edx
  801f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa1:	e8 21 fd ff ff       	call   801cc7 <_pipeisclosed>
  801fa6:	83 c4 10             	add    $0x10,%esp
}
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fae:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    

00801fb5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fbb:	68 cb 29 80 00       	push   $0x8029cb
  801fc0:	ff 75 0c             	pushl  0xc(%ebp)
  801fc3:	e8 7b e8 ff ff       	call   800843 <strcpy>
	return 0;
}
  801fc8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    

00801fcf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	57                   	push   %edi
  801fd3:	56                   	push   %esi
  801fd4:	53                   	push   %ebx
  801fd5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fdb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fe0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe6:	eb 2d                	jmp    802015 <devcons_write+0x46>
		m = n - tot;
  801fe8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801feb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fed:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ff0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ff5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ff8:	83 ec 04             	sub    $0x4,%esp
  801ffb:	53                   	push   %ebx
  801ffc:	03 45 0c             	add    0xc(%ebp),%eax
  801fff:	50                   	push   %eax
  802000:	57                   	push   %edi
  802001:	e8 cf e9 ff ff       	call   8009d5 <memmove>
		sys_cputs(buf, m);
  802006:	83 c4 08             	add    $0x8,%esp
  802009:	53                   	push   %ebx
  80200a:	57                   	push   %edi
  80200b:	e8 7a eb ff ff       	call   800b8a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802010:	01 de                	add    %ebx,%esi
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	89 f0                	mov    %esi,%eax
  802017:	3b 75 10             	cmp    0x10(%ebp),%esi
  80201a:	72 cc                	jb     801fe8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80201c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    

00802024 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	83 ec 08             	sub    $0x8,%esp
  80202a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80202f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802033:	74 2a                	je     80205f <devcons_read+0x3b>
  802035:	eb 05                	jmp    80203c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802037:	e8 eb eb ff ff       	call   800c27 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80203c:	e8 67 eb ff ff       	call   800ba8 <sys_cgetc>
  802041:	85 c0                	test   %eax,%eax
  802043:	74 f2                	je     802037 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802045:	85 c0                	test   %eax,%eax
  802047:	78 16                	js     80205f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802049:	83 f8 04             	cmp    $0x4,%eax
  80204c:	74 0c                	je     80205a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80204e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802051:	88 02                	mov    %al,(%edx)
	return 1;
  802053:	b8 01 00 00 00       	mov    $0x1,%eax
  802058:	eb 05                	jmp    80205f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80205a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80205f:	c9                   	leave  
  802060:	c3                   	ret    

00802061 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802067:	8b 45 08             	mov    0x8(%ebp),%eax
  80206a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80206d:	6a 01                	push   $0x1
  80206f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802072:	50                   	push   %eax
  802073:	e8 12 eb ff ff       	call   800b8a <sys_cputs>
}
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	c9                   	leave  
  80207c:	c3                   	ret    

0080207d <getchar>:

int
getchar(void)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802083:	6a 01                	push   $0x1
  802085:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802088:	50                   	push   %eax
  802089:	6a 00                	push   $0x0
  80208b:	e8 26 f1 ff ff       	call   8011b6 <read>
	if (r < 0)
  802090:	83 c4 10             	add    $0x10,%esp
  802093:	85 c0                	test   %eax,%eax
  802095:	78 0f                	js     8020a6 <getchar+0x29>
		return r;
	if (r < 1)
  802097:	85 c0                	test   %eax,%eax
  802099:	7e 06                	jle    8020a1 <getchar+0x24>
		return -E_EOF;
	return c;
  80209b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80209f:	eb 05                	jmp    8020a6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020a1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020a6:	c9                   	leave  
  8020a7:	c3                   	ret    

008020a8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b1:	50                   	push   %eax
  8020b2:	ff 75 08             	pushl  0x8(%ebp)
  8020b5:	e8 96 ee ff ff       	call   800f50 <fd_lookup>
  8020ba:	83 c4 10             	add    $0x10,%esp
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	78 11                	js     8020d2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c4:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8020ca:	39 10                	cmp    %edx,(%eax)
  8020cc:	0f 94 c0             	sete   %al
  8020cf:	0f b6 c0             	movzbl %al,%eax
}
  8020d2:	c9                   	leave  
  8020d3:	c3                   	ret    

008020d4 <opencons>:

int
opencons(void)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020dd:	50                   	push   %eax
  8020de:	e8 1e ee ff ff       	call   800f01 <fd_alloc>
  8020e3:	83 c4 10             	add    $0x10,%esp
		return r;
  8020e6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	78 3e                	js     80212a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ec:	83 ec 04             	sub    $0x4,%esp
  8020ef:	68 07 04 00 00       	push   $0x407
  8020f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f7:	6a 00                	push   $0x0
  8020f9:	e8 48 eb ff ff       	call   800c46 <sys_page_alloc>
  8020fe:	83 c4 10             	add    $0x10,%esp
		return r;
  802101:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802103:	85 c0                	test   %eax,%eax
  802105:	78 23                	js     80212a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802107:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80210d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802110:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802115:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80211c:	83 ec 0c             	sub    $0xc,%esp
  80211f:	50                   	push   %eax
  802120:	e8 b5 ed ff ff       	call   800eda <fd2num>
  802125:	89 c2                	mov    %eax,%edx
  802127:	83 c4 10             	add    $0x10,%esp
}
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	c9                   	leave  
  80212d:	c3                   	ret    

0080212e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80212e:	55                   	push   %ebp
  80212f:	89 e5                	mov    %esp,%ebp
  802131:	56                   	push   %esi
  802132:	53                   	push   %ebx
  802133:	8b 75 08             	mov    0x8(%ebp),%esi
  802136:	8b 45 0c             	mov    0xc(%ebp),%eax
  802139:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80213c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80213e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802143:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802146:	83 ec 0c             	sub    $0xc,%esp
  802149:	50                   	push   %eax
  80214a:	e8 a7 ec ff ff       	call   800df6 <sys_ipc_recv>

	if (from_env_store != NULL)
  80214f:	83 c4 10             	add    $0x10,%esp
  802152:	85 f6                	test   %esi,%esi
  802154:	74 14                	je     80216a <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802156:	ba 00 00 00 00       	mov    $0x0,%edx
  80215b:	85 c0                	test   %eax,%eax
  80215d:	78 09                	js     802168 <ipc_recv+0x3a>
  80215f:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  802165:	8b 52 74             	mov    0x74(%edx),%edx
  802168:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80216a:	85 db                	test   %ebx,%ebx
  80216c:	74 14                	je     802182 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80216e:	ba 00 00 00 00       	mov    $0x0,%edx
  802173:	85 c0                	test   %eax,%eax
  802175:	78 09                	js     802180 <ipc_recv+0x52>
  802177:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  80217d:	8b 52 78             	mov    0x78(%edx),%edx
  802180:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802182:	85 c0                	test   %eax,%eax
  802184:	78 08                	js     80218e <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802186:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80218b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80218e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802191:	5b                   	pop    %ebx
  802192:	5e                   	pop    %esi
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    

00802195 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
  802198:	57                   	push   %edi
  802199:	56                   	push   %esi
  80219a:	53                   	push   %ebx
  80219b:	83 ec 0c             	sub    $0xc,%esp
  80219e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8021a7:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8021a9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021ae:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8021b1:	ff 75 14             	pushl  0x14(%ebp)
  8021b4:	53                   	push   %ebx
  8021b5:	56                   	push   %esi
  8021b6:	57                   	push   %edi
  8021b7:	e8 17 ec ff ff       	call   800dd3 <sys_ipc_try_send>

		if (err < 0) {
  8021bc:	83 c4 10             	add    $0x10,%esp
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	79 1e                	jns    8021e1 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8021c3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021c6:	75 07                	jne    8021cf <ipc_send+0x3a>
				sys_yield();
  8021c8:	e8 5a ea ff ff       	call   800c27 <sys_yield>
  8021cd:	eb e2                	jmp    8021b1 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8021cf:	50                   	push   %eax
  8021d0:	68 d7 29 80 00       	push   $0x8029d7
  8021d5:	6a 49                	push   $0x49
  8021d7:	68 e4 29 80 00       	push   $0x8029e4
  8021dc:	e8 04 e0 ff ff       	call   8001e5 <_panic>
		}

	} while (err < 0);

}
  8021e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    

008021e9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021e9:	55                   	push   %ebp
  8021ea:	89 e5                	mov    %esp,%ebp
  8021ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021ef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021f4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021f7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021fd:	8b 52 50             	mov    0x50(%edx),%edx
  802200:	39 ca                	cmp    %ecx,%edx
  802202:	75 0d                	jne    802211 <ipc_find_env+0x28>
			return envs[i].env_id;
  802204:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802207:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80220c:	8b 40 48             	mov    0x48(%eax),%eax
  80220f:	eb 0f                	jmp    802220 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802211:	83 c0 01             	add    $0x1,%eax
  802214:	3d 00 04 00 00       	cmp    $0x400,%eax
  802219:	75 d9                	jne    8021f4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    

00802222 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802228:	89 d0                	mov    %edx,%eax
  80222a:	c1 e8 16             	shr    $0x16,%eax
  80222d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802234:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802239:	f6 c1 01             	test   $0x1,%cl
  80223c:	74 1d                	je     80225b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80223e:	c1 ea 0c             	shr    $0xc,%edx
  802241:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802248:	f6 c2 01             	test   $0x1,%dl
  80224b:	74 0e                	je     80225b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80224d:	c1 ea 0c             	shr    $0xc,%edx
  802250:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802257:	ef 
  802258:	0f b7 c0             	movzwl %ax,%eax
}
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	66 90                	xchg   %ax,%ax
  80225f:	90                   	nop

00802260 <__udivdi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80226b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80226f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 f6                	test   %esi,%esi
  802279:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80227d:	89 ca                	mov    %ecx,%edx
  80227f:	89 f8                	mov    %edi,%eax
  802281:	75 3d                	jne    8022c0 <__udivdi3+0x60>
  802283:	39 cf                	cmp    %ecx,%edi
  802285:	0f 87 c5 00 00 00    	ja     802350 <__udivdi3+0xf0>
  80228b:	85 ff                	test   %edi,%edi
  80228d:	89 fd                	mov    %edi,%ebp
  80228f:	75 0b                	jne    80229c <__udivdi3+0x3c>
  802291:	b8 01 00 00 00       	mov    $0x1,%eax
  802296:	31 d2                	xor    %edx,%edx
  802298:	f7 f7                	div    %edi
  80229a:	89 c5                	mov    %eax,%ebp
  80229c:	89 c8                	mov    %ecx,%eax
  80229e:	31 d2                	xor    %edx,%edx
  8022a0:	f7 f5                	div    %ebp
  8022a2:	89 c1                	mov    %eax,%ecx
  8022a4:	89 d8                	mov    %ebx,%eax
  8022a6:	89 cf                	mov    %ecx,%edi
  8022a8:	f7 f5                	div    %ebp
  8022aa:	89 c3                	mov    %eax,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	39 ce                	cmp    %ecx,%esi
  8022c2:	77 74                	ja     802338 <__udivdi3+0xd8>
  8022c4:	0f bd fe             	bsr    %esi,%edi
  8022c7:	83 f7 1f             	xor    $0x1f,%edi
  8022ca:	0f 84 98 00 00 00    	je     802368 <__udivdi3+0x108>
  8022d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	89 c5                	mov    %eax,%ebp
  8022d9:	29 fb                	sub    %edi,%ebx
  8022db:	d3 e6                	shl    %cl,%esi
  8022dd:	89 d9                	mov    %ebx,%ecx
  8022df:	d3 ed                	shr    %cl,%ebp
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	d3 e0                	shl    %cl,%eax
  8022e5:	09 ee                	or     %ebp,%esi
  8022e7:	89 d9                	mov    %ebx,%ecx
  8022e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ed:	89 d5                	mov    %edx,%ebp
  8022ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022f3:	d3 ed                	shr    %cl,%ebp
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e2                	shl    %cl,%edx
  8022f9:	89 d9                	mov    %ebx,%ecx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	09 c2                	or     %eax,%edx
  8022ff:	89 d0                	mov    %edx,%eax
  802301:	89 ea                	mov    %ebp,%edx
  802303:	f7 f6                	div    %esi
  802305:	89 d5                	mov    %edx,%ebp
  802307:	89 c3                	mov    %eax,%ebx
  802309:	f7 64 24 0c          	mull   0xc(%esp)
  80230d:	39 d5                	cmp    %edx,%ebp
  80230f:	72 10                	jb     802321 <__udivdi3+0xc1>
  802311:	8b 74 24 08          	mov    0x8(%esp),%esi
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e6                	shl    %cl,%esi
  802319:	39 c6                	cmp    %eax,%esi
  80231b:	73 07                	jae    802324 <__udivdi3+0xc4>
  80231d:	39 d5                	cmp    %edx,%ebp
  80231f:	75 03                	jne    802324 <__udivdi3+0xc4>
  802321:	83 eb 01             	sub    $0x1,%ebx
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 d8                	mov    %ebx,%eax
  802328:	89 fa                	mov    %edi,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	31 ff                	xor    %edi,%edi
  80233a:	31 db                	xor    %ebx,%ebx
  80233c:	89 d8                	mov    %ebx,%eax
  80233e:	89 fa                	mov    %edi,%edx
  802340:	83 c4 1c             	add    $0x1c,%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	90                   	nop
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	89 d8                	mov    %ebx,%eax
  802352:	f7 f7                	div    %edi
  802354:	31 ff                	xor    %edi,%edi
  802356:	89 c3                	mov    %eax,%ebx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 fa                	mov    %edi,%edx
  80235c:	83 c4 1c             	add    $0x1c,%esp
  80235f:	5b                   	pop    %ebx
  802360:	5e                   	pop    %esi
  802361:	5f                   	pop    %edi
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    
  802364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802368:	39 ce                	cmp    %ecx,%esi
  80236a:	72 0c                	jb     802378 <__udivdi3+0x118>
  80236c:	31 db                	xor    %ebx,%ebx
  80236e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802372:	0f 87 34 ff ff ff    	ja     8022ac <__udivdi3+0x4c>
  802378:	bb 01 00 00 00       	mov    $0x1,%ebx
  80237d:	e9 2a ff ff ff       	jmp    8022ac <__udivdi3+0x4c>
  802382:	66 90                	xchg   %ax,%ax
  802384:	66 90                	xchg   %ax,%ax
  802386:	66 90                	xchg   %ax,%ax
  802388:	66 90                	xchg   %ax,%ax
  80238a:	66 90                	xchg   %ax,%ax
  80238c:	66 90                	xchg   %ax,%ax
  80238e:	66 90                	xchg   %ax,%ax

00802390 <__umoddi3>:
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
  802394:	83 ec 1c             	sub    $0x1c,%esp
  802397:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80239b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80239f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023a7:	85 d2                	test   %edx,%edx
  8023a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023b1:	89 f3                	mov    %esi,%ebx
  8023b3:	89 3c 24             	mov    %edi,(%esp)
  8023b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ba:	75 1c                	jne    8023d8 <__umoddi3+0x48>
  8023bc:	39 f7                	cmp    %esi,%edi
  8023be:	76 50                	jbe    802410 <__umoddi3+0x80>
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	f7 f7                	div    %edi
  8023c6:	89 d0                	mov    %edx,%eax
  8023c8:	31 d2                	xor    %edx,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	39 f2                	cmp    %esi,%edx
  8023da:	89 d0                	mov    %edx,%eax
  8023dc:	77 52                	ja     802430 <__umoddi3+0xa0>
  8023de:	0f bd ea             	bsr    %edx,%ebp
  8023e1:	83 f5 1f             	xor    $0x1f,%ebp
  8023e4:	75 5a                	jne    802440 <__umoddi3+0xb0>
  8023e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ea:	0f 82 e0 00 00 00    	jb     8024d0 <__umoddi3+0x140>
  8023f0:	39 0c 24             	cmp    %ecx,(%esp)
  8023f3:	0f 86 d7 00 00 00    	jbe    8024d0 <__umoddi3+0x140>
  8023f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802401:	83 c4 1c             	add    $0x1c,%esp
  802404:	5b                   	pop    %ebx
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	85 ff                	test   %edi,%edi
  802412:	89 fd                	mov    %edi,%ebp
  802414:	75 0b                	jne    802421 <__umoddi3+0x91>
  802416:	b8 01 00 00 00       	mov    $0x1,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	f7 f7                	div    %edi
  80241f:	89 c5                	mov    %eax,%ebp
  802421:	89 f0                	mov    %esi,%eax
  802423:	31 d2                	xor    %edx,%edx
  802425:	f7 f5                	div    %ebp
  802427:	89 c8                	mov    %ecx,%eax
  802429:	f7 f5                	div    %ebp
  80242b:	89 d0                	mov    %edx,%eax
  80242d:	eb 99                	jmp    8023c8 <__umoddi3+0x38>
  80242f:	90                   	nop
  802430:	89 c8                	mov    %ecx,%eax
  802432:	89 f2                	mov    %esi,%edx
  802434:	83 c4 1c             	add    $0x1c,%esp
  802437:	5b                   	pop    %ebx
  802438:	5e                   	pop    %esi
  802439:	5f                   	pop    %edi
  80243a:	5d                   	pop    %ebp
  80243b:	c3                   	ret    
  80243c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802440:	8b 34 24             	mov    (%esp),%esi
  802443:	bf 20 00 00 00       	mov    $0x20,%edi
  802448:	89 e9                	mov    %ebp,%ecx
  80244a:	29 ef                	sub    %ebp,%edi
  80244c:	d3 e0                	shl    %cl,%eax
  80244e:	89 f9                	mov    %edi,%ecx
  802450:	89 f2                	mov    %esi,%edx
  802452:	d3 ea                	shr    %cl,%edx
  802454:	89 e9                	mov    %ebp,%ecx
  802456:	09 c2                	or     %eax,%edx
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	89 14 24             	mov    %edx,(%esp)
  80245d:	89 f2                	mov    %esi,%edx
  80245f:	d3 e2                	shl    %cl,%edx
  802461:	89 f9                	mov    %edi,%ecx
  802463:	89 54 24 04          	mov    %edx,0x4(%esp)
  802467:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	89 e9                	mov    %ebp,%ecx
  80246f:	89 c6                	mov    %eax,%esi
  802471:	d3 e3                	shl    %cl,%ebx
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 d0                	mov    %edx,%eax
  802477:	d3 e8                	shr    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	09 d8                	or     %ebx,%eax
  80247d:	89 d3                	mov    %edx,%ebx
  80247f:	89 f2                	mov    %esi,%edx
  802481:	f7 34 24             	divl   (%esp)
  802484:	89 d6                	mov    %edx,%esi
  802486:	d3 e3                	shl    %cl,%ebx
  802488:	f7 64 24 04          	mull   0x4(%esp)
  80248c:	39 d6                	cmp    %edx,%esi
  80248e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802492:	89 d1                	mov    %edx,%ecx
  802494:	89 c3                	mov    %eax,%ebx
  802496:	72 08                	jb     8024a0 <__umoddi3+0x110>
  802498:	75 11                	jne    8024ab <__umoddi3+0x11b>
  80249a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80249e:	73 0b                	jae    8024ab <__umoddi3+0x11b>
  8024a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024a4:	1b 14 24             	sbb    (%esp),%edx
  8024a7:	89 d1                	mov    %edx,%ecx
  8024a9:	89 c3                	mov    %eax,%ebx
  8024ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024af:	29 da                	sub    %ebx,%edx
  8024b1:	19 ce                	sbb    %ecx,%esi
  8024b3:	89 f9                	mov    %edi,%ecx
  8024b5:	89 f0                	mov    %esi,%eax
  8024b7:	d3 e0                	shl    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	d3 ea                	shr    %cl,%edx
  8024bd:	89 e9                	mov    %ebp,%ecx
  8024bf:	d3 ee                	shr    %cl,%esi
  8024c1:	09 d0                	or     %edx,%eax
  8024c3:	89 f2                	mov    %esi,%edx
  8024c5:	83 c4 1c             	add    $0x1c,%esp
  8024c8:	5b                   	pop    %ebx
  8024c9:	5e                   	pop    %esi
  8024ca:	5f                   	pop    %edi
  8024cb:	5d                   	pop    %ebp
  8024cc:	c3                   	ret    
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi
  8024d0:	29 f9                	sub    %edi,%ecx
  8024d2:	19 d6                	sbb    %edx,%esi
  8024d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024dc:	e9 18 ff ff ff       	jmp    8023f9 <__umoddi3+0x69>
