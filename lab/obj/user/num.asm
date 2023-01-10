
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
  80005d:	68 c0 24 80 00       	push   $0x8024c0
  800062:	e8 29 17 00 00       	call   801790 <printf>
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
  80007c:	e8 cd 11 00 00       	call   80124e <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 c5 24 80 00       	push   $0x8024c5
  800095:	6a 13                	push   $0x13
  800097:	68 e0 24 80 00       	push   $0x8024e0
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
  8000b8:	e8 b7 10 00 00       	call   801174 <read>
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
  8000d3:	68 eb 24 80 00       	push   $0x8024eb
  8000d8:	6a 18                	push   $0x18
  8000da:	68 e0 24 80 00       	push   $0x8024e0
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
  8000f4:	c7 05 04 30 80 00 00 	movl   $0x802500,0x803004
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
  800114:	68 04 25 80 00       	push   $0x802504
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
  80012f:	e8 be 14 00 00       	call   8015f2 <open>
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
  800146:	68 0c 25 80 00       	push   $0x80250c
  80014b:	6a 27                	push   $0x27
  80014d:	68 e0 24 80 00       	push   $0x8024e0
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 ce 0e 00 00       	call   801038 <close>

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
  8001d1:	e8 8d 0e 00 00       	call   801063 <close_all>
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
  800203:	68 28 25 80 00       	push   $0x802528
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 84 29 80 00 	movl   $0x802984,(%esp)
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
  800321:	e8 fa 1e 00 00       	call   802220 <__udivdi3>
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
  800364:	e8 e7 1f 00 00       	call   802350 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 4b 25 80 00 	movsbl 0x80254b(%eax),%eax
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
  800468:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
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
  80052c:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	75 18                	jne    80054f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800537:	50                   	push   %eax
  800538:	68 63 25 80 00       	push   $0x802563
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
  800550:	68 19 29 80 00       	push   $0x802919
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
  800574:	b8 5c 25 80 00       	mov    $0x80255c,%eax
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
  800bef:	68 3f 28 80 00       	push   $0x80283f
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 5c 28 80 00       	push   $0x80285c
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
  800c70:	68 3f 28 80 00       	push   $0x80283f
  800c75:	6a 23                	push   $0x23
  800c77:	68 5c 28 80 00       	push   $0x80285c
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
  800cb2:	68 3f 28 80 00       	push   $0x80283f
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 5c 28 80 00       	push   $0x80285c
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
  800cf4:	68 3f 28 80 00       	push   $0x80283f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 5c 28 80 00       	push   $0x80285c
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
  800d36:	68 3f 28 80 00       	push   $0x80283f
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 5c 28 80 00       	push   $0x80285c
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
  800d78:	68 3f 28 80 00       	push   $0x80283f
  800d7d:	6a 23                	push   $0x23
  800d7f:	68 5c 28 80 00       	push   $0x80285c
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
  800dba:	68 3f 28 80 00       	push   $0x80283f
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 5c 28 80 00       	push   $0x80285c
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
  800e1e:	68 3f 28 80 00       	push   $0x80283f
  800e23:	6a 23                	push   $0x23
  800e25:	68 5c 28 80 00       	push   $0x80285c
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
  800e7f:	68 3f 28 80 00       	push   $0x80283f
  800e84:	6a 23                	push   $0x23
  800e86:	68 5c 28 80 00       	push   $0x80285c
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

00800e98 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9e:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea3:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
  800eae:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eb8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	c1 ea 16             	shr    $0x16,%edx
  800ecf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed6:	f6 c2 01             	test   $0x1,%dl
  800ed9:	74 11                	je     800eec <fd_alloc+0x2d>
  800edb:	89 c2                	mov    %eax,%edx
  800edd:	c1 ea 0c             	shr    $0xc,%edx
  800ee0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee7:	f6 c2 01             	test   $0x1,%dl
  800eea:	75 09                	jne    800ef5 <fd_alloc+0x36>
			*fd_store = fd;
  800eec:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	eb 17                	jmp    800f0c <fd_alloc+0x4d>
  800ef5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800efa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eff:	75 c9                	jne    800eca <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f01:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f07:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f14:	83 f8 1f             	cmp    $0x1f,%eax
  800f17:	77 36                	ja     800f4f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f19:	c1 e0 0c             	shl    $0xc,%eax
  800f1c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f21:	89 c2                	mov    %eax,%edx
  800f23:	c1 ea 16             	shr    $0x16,%edx
  800f26:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2d:	f6 c2 01             	test   $0x1,%dl
  800f30:	74 24                	je     800f56 <fd_lookup+0x48>
  800f32:	89 c2                	mov    %eax,%edx
  800f34:	c1 ea 0c             	shr    $0xc,%edx
  800f37:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3e:	f6 c2 01             	test   $0x1,%dl
  800f41:	74 1a                	je     800f5d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f46:	89 02                	mov    %eax,(%edx)
	return 0;
  800f48:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4d:	eb 13                	jmp    800f62 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f54:	eb 0c                	jmp    800f62 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5b:	eb 05                	jmp    800f62 <fd_lookup+0x54>
  800f5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6d:	ba ec 28 80 00       	mov    $0x8028ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f72:	eb 13                	jmp    800f87 <dev_lookup+0x23>
  800f74:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f77:	39 08                	cmp    %ecx,(%eax)
  800f79:	75 0c                	jne    800f87 <dev_lookup+0x23>
			*dev = devtab[i];
  800f7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f80:	b8 00 00 00 00       	mov    $0x0,%eax
  800f85:	eb 2e                	jmp    800fb5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f87:	8b 02                	mov    (%edx),%eax
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	75 e7                	jne    800f74 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f8d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800f92:	8b 40 48             	mov    0x48(%eax),%eax
  800f95:	83 ec 04             	sub    $0x4,%esp
  800f98:	51                   	push   %ecx
  800f99:	50                   	push   %eax
  800f9a:	68 6c 28 80 00       	push   $0x80286c
  800f9f:	e8 1a f3 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    

00800fb7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	56                   	push   %esi
  800fbb:	53                   	push   %ebx
  800fbc:	83 ec 10             	sub    $0x10,%esp
  800fbf:	8b 75 08             	mov    0x8(%ebp),%esi
  800fc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fcf:	c1 e8 0c             	shr    $0xc,%eax
  800fd2:	50                   	push   %eax
  800fd3:	e8 36 ff ff ff       	call   800f0e <fd_lookup>
  800fd8:	83 c4 08             	add    $0x8,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 05                	js     800fe4 <fd_close+0x2d>
	    || fd != fd2)
  800fdf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fe2:	74 0c                	je     800ff0 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fe4:	84 db                	test   %bl,%bl
  800fe6:	ba 00 00 00 00       	mov    $0x0,%edx
  800feb:	0f 44 c2             	cmove  %edx,%eax
  800fee:	eb 41                	jmp    801031 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ff0:	83 ec 08             	sub    $0x8,%esp
  800ff3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff6:	50                   	push   %eax
  800ff7:	ff 36                	pushl  (%esi)
  800ff9:	e8 66 ff ff ff       	call   800f64 <dev_lookup>
  800ffe:	89 c3                	mov    %eax,%ebx
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	78 1a                	js     801021 <fd_close+0x6a>
		if (dev->dev_close)
  801007:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80100a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80100d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801012:	85 c0                	test   %eax,%eax
  801014:	74 0b                	je     801021 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	56                   	push   %esi
  80101a:	ff d0                	call   *%eax
  80101c:	89 c3                	mov    %eax,%ebx
  80101e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801021:	83 ec 08             	sub    $0x8,%esp
  801024:	56                   	push   %esi
  801025:	6a 00                	push   $0x0
  801027:	e8 9f fc ff ff       	call   800ccb <sys_page_unmap>
	return r;
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	89 d8                	mov    %ebx,%eax
}
  801031:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801041:	50                   	push   %eax
  801042:	ff 75 08             	pushl  0x8(%ebp)
  801045:	e8 c4 fe ff ff       	call   800f0e <fd_lookup>
  80104a:	83 c4 08             	add    $0x8,%esp
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 10                	js     801061 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	6a 01                	push   $0x1
  801056:	ff 75 f4             	pushl  -0xc(%ebp)
  801059:	e8 59 ff ff ff       	call   800fb7 <fd_close>
  80105e:	83 c4 10             	add    $0x10,%esp
}
  801061:	c9                   	leave  
  801062:	c3                   	ret    

00801063 <close_all>:

void
close_all(void)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	53                   	push   %ebx
  801067:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80106a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	53                   	push   %ebx
  801073:	e8 c0 ff ff ff       	call   801038 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801078:	83 c3 01             	add    $0x1,%ebx
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	83 fb 20             	cmp    $0x20,%ebx
  801081:	75 ec                	jne    80106f <close_all+0xc>
		close(i);
}
  801083:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801086:	c9                   	leave  
  801087:	c3                   	ret    

00801088 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	57                   	push   %edi
  80108c:	56                   	push   %esi
  80108d:	53                   	push   %ebx
  80108e:	83 ec 2c             	sub    $0x2c,%esp
  801091:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801094:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801097:	50                   	push   %eax
  801098:	ff 75 08             	pushl  0x8(%ebp)
  80109b:	e8 6e fe ff ff       	call   800f0e <fd_lookup>
  8010a0:	83 c4 08             	add    $0x8,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	0f 88 c1 00 00 00    	js     80116c <dup+0xe4>
		return r;
	close(newfdnum);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	56                   	push   %esi
  8010af:	e8 84 ff ff ff       	call   801038 <close>

	newfd = INDEX2FD(newfdnum);
  8010b4:	89 f3                	mov    %esi,%ebx
  8010b6:	c1 e3 0c             	shl    $0xc,%ebx
  8010b9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010bf:	83 c4 04             	add    $0x4,%esp
  8010c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c5:	e8 de fd ff ff       	call   800ea8 <fd2data>
  8010ca:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010cc:	89 1c 24             	mov    %ebx,(%esp)
  8010cf:	e8 d4 fd ff ff       	call   800ea8 <fd2data>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010da:	89 f8                	mov    %edi,%eax
  8010dc:	c1 e8 16             	shr    $0x16,%eax
  8010df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e6:	a8 01                	test   $0x1,%al
  8010e8:	74 37                	je     801121 <dup+0x99>
  8010ea:	89 f8                	mov    %edi,%eax
  8010ec:	c1 e8 0c             	shr    $0xc,%eax
  8010ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f6:	f6 c2 01             	test   $0x1,%dl
  8010f9:	74 26                	je     801121 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801102:	83 ec 0c             	sub    $0xc,%esp
  801105:	25 07 0e 00 00       	and    $0xe07,%eax
  80110a:	50                   	push   %eax
  80110b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110e:	6a 00                	push   $0x0
  801110:	57                   	push   %edi
  801111:	6a 00                	push   $0x0
  801113:	e8 71 fb ff ff       	call   800c89 <sys_page_map>
  801118:	89 c7                	mov    %eax,%edi
  80111a:	83 c4 20             	add    $0x20,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 2e                	js     80114f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801121:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801124:	89 d0                	mov    %edx,%eax
  801126:	c1 e8 0c             	shr    $0xc,%eax
  801129:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	25 07 0e 00 00       	and    $0xe07,%eax
  801138:	50                   	push   %eax
  801139:	53                   	push   %ebx
  80113a:	6a 00                	push   $0x0
  80113c:	52                   	push   %edx
  80113d:	6a 00                	push   $0x0
  80113f:	e8 45 fb ff ff       	call   800c89 <sys_page_map>
  801144:	89 c7                	mov    %eax,%edi
  801146:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801149:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114b:	85 ff                	test   %edi,%edi
  80114d:	79 1d                	jns    80116c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80114f:	83 ec 08             	sub    $0x8,%esp
  801152:	53                   	push   %ebx
  801153:	6a 00                	push   $0x0
  801155:	e8 71 fb ff ff       	call   800ccb <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115a:	83 c4 08             	add    $0x8,%esp
  80115d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801160:	6a 00                	push   $0x0
  801162:	e8 64 fb ff ff       	call   800ccb <sys_page_unmap>
	return r;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	89 f8                	mov    %edi,%eax
}
  80116c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	53                   	push   %ebx
  801178:	83 ec 14             	sub    $0x14,%esp
  80117b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	53                   	push   %ebx
  801183:	e8 86 fd ff ff       	call   800f0e <fd_lookup>
  801188:	83 c4 08             	add    $0x8,%esp
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 6d                	js     8011fe <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801191:	83 ec 08             	sub    $0x8,%esp
  801194:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119b:	ff 30                	pushl  (%eax)
  80119d:	e8 c2 fd ff ff       	call   800f64 <dev_lookup>
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 4c                	js     8011f5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ac:	8b 42 08             	mov    0x8(%edx),%eax
  8011af:	83 e0 03             	and    $0x3,%eax
  8011b2:	83 f8 01             	cmp    $0x1,%eax
  8011b5:	75 21                	jne    8011d8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011bc:	8b 40 48             	mov    0x48(%eax),%eax
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	53                   	push   %ebx
  8011c3:	50                   	push   %eax
  8011c4:	68 b0 28 80 00       	push   $0x8028b0
  8011c9:	e8 f0 f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d6:	eb 26                	jmp    8011fe <read+0x8a>
	}
	if (!dev->dev_read)
  8011d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011db:	8b 40 08             	mov    0x8(%eax),%eax
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	74 17                	je     8011f9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	ff 75 10             	pushl  0x10(%ebp)
  8011e8:	ff 75 0c             	pushl  0xc(%ebp)
  8011eb:	52                   	push   %edx
  8011ec:	ff d0                	call   *%eax
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	eb 09                	jmp    8011fe <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	eb 05                	jmp    8011fe <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011fe:	89 d0                	mov    %edx,%eax
  801200:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801203:	c9                   	leave  
  801204:	c3                   	ret    

00801205 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	57                   	push   %edi
  801209:	56                   	push   %esi
  80120a:	53                   	push   %ebx
  80120b:	83 ec 0c             	sub    $0xc,%esp
  80120e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801211:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801214:	bb 00 00 00 00       	mov    $0x0,%ebx
  801219:	eb 21                	jmp    80123c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	89 f0                	mov    %esi,%eax
  801220:	29 d8                	sub    %ebx,%eax
  801222:	50                   	push   %eax
  801223:	89 d8                	mov    %ebx,%eax
  801225:	03 45 0c             	add    0xc(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	57                   	push   %edi
  80122a:	e8 45 ff ff ff       	call   801174 <read>
		if (m < 0)
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	78 10                	js     801246 <readn+0x41>
			return m;
		if (m == 0)
  801236:	85 c0                	test   %eax,%eax
  801238:	74 0a                	je     801244 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123a:	01 c3                	add    %eax,%ebx
  80123c:	39 f3                	cmp    %esi,%ebx
  80123e:	72 db                	jb     80121b <readn+0x16>
  801240:	89 d8                	mov    %ebx,%eax
  801242:	eb 02                	jmp    801246 <readn+0x41>
  801244:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801249:	5b                   	pop    %ebx
  80124a:	5e                   	pop    %esi
  80124b:	5f                   	pop    %edi
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	53                   	push   %ebx
  801252:	83 ec 14             	sub    $0x14,%esp
  801255:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801258:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	53                   	push   %ebx
  80125d:	e8 ac fc ff ff       	call   800f0e <fd_lookup>
  801262:	83 c4 08             	add    $0x8,%esp
  801265:	89 c2                	mov    %eax,%edx
  801267:	85 c0                	test   %eax,%eax
  801269:	78 68                	js     8012d3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801275:	ff 30                	pushl  (%eax)
  801277:	e8 e8 fc ff ff       	call   800f64 <dev_lookup>
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 47                	js     8012ca <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801283:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801286:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128a:	75 21                	jne    8012ad <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80128c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801291:	8b 40 48             	mov    0x48(%eax),%eax
  801294:	83 ec 04             	sub    $0x4,%esp
  801297:	53                   	push   %ebx
  801298:	50                   	push   %eax
  801299:	68 cc 28 80 00       	push   $0x8028cc
  80129e:	e8 1b f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ab:	eb 26                	jmp    8012d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8012b3:	85 d2                	test   %edx,%edx
  8012b5:	74 17                	je     8012ce <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012b7:	83 ec 04             	sub    $0x4,%esp
  8012ba:	ff 75 10             	pushl  0x10(%ebp)
  8012bd:	ff 75 0c             	pushl  0xc(%ebp)
  8012c0:	50                   	push   %eax
  8012c1:	ff d2                	call   *%edx
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	eb 09                	jmp    8012d3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	eb 05                	jmp    8012d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012d3:	89 d0                	mov    %edx,%eax
  8012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d8:	c9                   	leave  
  8012d9:	c3                   	ret    

008012da <seek>:

int
seek(int fdnum, off_t offset)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 22 fc ff ff       	call   800f0e <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 0e                	js     801301 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 14             	sub    $0x14,%esp
  80130a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	53                   	push   %ebx
  801312:	e8 f7 fb ff ff       	call   800f0e <fd_lookup>
  801317:	83 c4 08             	add    $0x8,%esp
  80131a:	89 c2                	mov    %eax,%edx
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 65                	js     801385 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132a:	ff 30                	pushl  (%eax)
  80132c:	e8 33 fc ff ff       	call   800f64 <dev_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 44                	js     80137c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801338:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133f:	75 21                	jne    801362 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801341:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801346:	8b 40 48             	mov    0x48(%eax),%eax
  801349:	83 ec 04             	sub    $0x4,%esp
  80134c:	53                   	push   %ebx
  80134d:	50                   	push   %eax
  80134e:	68 8c 28 80 00       	push   $0x80288c
  801353:	e8 66 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801360:	eb 23                	jmp    801385 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801362:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801365:	8b 52 18             	mov    0x18(%edx),%edx
  801368:	85 d2                	test   %edx,%edx
  80136a:	74 14                	je     801380 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80136c:	83 ec 08             	sub    $0x8,%esp
  80136f:	ff 75 0c             	pushl  0xc(%ebp)
  801372:	50                   	push   %eax
  801373:	ff d2                	call   *%edx
  801375:	89 c2                	mov    %eax,%edx
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	eb 09                	jmp    801385 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137c:	89 c2                	mov    %eax,%edx
  80137e:	eb 05                	jmp    801385 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801380:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801385:	89 d0                	mov    %edx,%eax
  801387:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	53                   	push   %ebx
  801390:	83 ec 14             	sub    $0x14,%esp
  801393:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801396:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	ff 75 08             	pushl  0x8(%ebp)
  80139d:	e8 6c fb ff ff       	call   800f0e <fd_lookup>
  8013a2:	83 c4 08             	add    $0x8,%esp
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 58                	js     801403 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	ff 30                	pushl  (%eax)
  8013b7:	e8 a8 fb ff ff       	call   800f64 <dev_lookup>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 37                	js     8013fa <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ca:	74 32                	je     8013fe <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d6:	00 00 00 
	stat->st_isdir = 0;
  8013d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e0:	00 00 00 
	stat->st_dev = dev;
  8013e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	53                   	push   %ebx
  8013ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f0:	ff 50 14             	call   *0x14(%eax)
  8013f3:	89 c2                	mov    %eax,%edx
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	eb 09                	jmp    801403 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	eb 05                	jmp    801403 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801403:	89 d0                	mov    %edx,%eax
  801405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	56                   	push   %esi
  80140e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	6a 00                	push   $0x0
  801414:	ff 75 08             	pushl  0x8(%ebp)
  801417:	e8 d6 01 00 00       	call   8015f2 <open>
  80141c:	89 c3                	mov    %eax,%ebx
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 1b                	js     801440 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	ff 75 0c             	pushl  0xc(%ebp)
  80142b:	50                   	push   %eax
  80142c:	e8 5b ff ff ff       	call   80138c <fstat>
  801431:	89 c6                	mov    %eax,%esi
	close(fd);
  801433:	89 1c 24             	mov    %ebx,(%esp)
  801436:	e8 fd fb ff ff       	call   801038 <close>
	return r;
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	89 f0                	mov    %esi,%eax
}
  801440:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801443:	5b                   	pop    %ebx
  801444:	5e                   	pop    %esi
  801445:	5d                   	pop    %ebp
  801446:	c3                   	ret    

00801447 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	56                   	push   %esi
  80144b:	53                   	push   %ebx
  80144c:	89 c6                	mov    %eax,%esi
  80144e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801450:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801457:	75 12                	jne    80146b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	6a 01                	push   $0x1
  80145e:	e8 44 0d 00 00       	call   8021a7 <ipc_find_env>
  801463:	a3 04 40 80 00       	mov    %eax,0x804004
  801468:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80146b:	6a 07                	push   $0x7
  80146d:	68 00 50 80 00       	push   $0x805000
  801472:	56                   	push   %esi
  801473:	ff 35 04 40 80 00    	pushl  0x804004
  801479:	e8 d5 0c 00 00       	call   802153 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80147e:	83 c4 0c             	add    $0xc,%esp
  801481:	6a 00                	push   $0x0
  801483:	53                   	push   %ebx
  801484:	6a 00                	push   $0x0
  801486:	e8 61 0c 00 00       	call   8020ec <ipc_recv>
}
  80148b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801498:	8b 45 08             	mov    0x8(%ebp),%eax
  80149b:	8b 40 0c             	mov    0xc(%eax),%eax
  80149e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b5:	e8 8d ff ff ff       	call   801447 <fsipc>
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8014d7:	e8 6b ff ff ff       	call   801447 <fsipc>
}
  8014dc:	c9                   	leave  
  8014dd:	c3                   	ret    

008014de <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 04             	sub    $0x4,%esp
  8014e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ee:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8014fd:	e8 45 ff ff ff       	call   801447 <fsipc>
  801502:	85 c0                	test   %eax,%eax
  801504:	78 2c                	js     801532 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	68 00 50 80 00       	push   $0x805000
  80150e:	53                   	push   %ebx
  80150f:	e8 2f f3 ff ff       	call   800843 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801514:	a1 80 50 80 00       	mov    0x805080,%eax
  801519:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80151f:	a1 84 50 80 00       	mov    0x805084,%eax
  801524:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801535:	c9                   	leave  
  801536:	c3                   	ret    

00801537 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801540:	8b 55 08             	mov    0x8(%ebp),%edx
  801543:	8b 52 0c             	mov    0xc(%edx),%edx
  801546:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80154c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801551:	50                   	push   %eax
  801552:	ff 75 0c             	pushl  0xc(%ebp)
  801555:	68 08 50 80 00       	push   $0x805008
  80155a:	e8 76 f4 ff ff       	call   8009d5 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80155f:	ba 00 00 00 00       	mov    $0x0,%edx
  801564:	b8 04 00 00 00       	mov    $0x4,%eax
  801569:	e8 d9 fe ff ff       	call   801447 <fsipc>

}
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801578:	8b 45 08             	mov    0x8(%ebp),%eax
  80157b:	8b 40 0c             	mov    0xc(%eax),%eax
  80157e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801583:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801589:	ba 00 00 00 00       	mov    $0x0,%edx
  80158e:	b8 03 00 00 00       	mov    $0x3,%eax
  801593:	e8 af fe ff ff       	call   801447 <fsipc>
  801598:	89 c3                	mov    %eax,%ebx
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 4b                	js     8015e9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80159e:	39 c6                	cmp    %eax,%esi
  8015a0:	73 16                	jae    8015b8 <devfile_read+0x48>
  8015a2:	68 00 29 80 00       	push   $0x802900
  8015a7:	68 07 29 80 00       	push   $0x802907
  8015ac:	6a 7c                	push   $0x7c
  8015ae:	68 1c 29 80 00       	push   $0x80291c
  8015b3:	e8 2d ec ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  8015b8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015bd:	7e 16                	jle    8015d5 <devfile_read+0x65>
  8015bf:	68 27 29 80 00       	push   $0x802927
  8015c4:	68 07 29 80 00       	push   $0x802907
  8015c9:	6a 7d                	push   $0x7d
  8015cb:	68 1c 29 80 00       	push   $0x80291c
  8015d0:	e8 10 ec ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	50                   	push   %eax
  8015d9:	68 00 50 80 00       	push   $0x805000
  8015de:	ff 75 0c             	pushl  0xc(%ebp)
  8015e1:	e8 ef f3 ff ff       	call   8009d5 <memmove>
	return r;
  8015e6:	83 c4 10             	add    $0x10,%esp
}
  8015e9:	89 d8                	mov    %ebx,%eax
  8015eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 20             	sub    $0x20,%esp
  8015f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015fc:	53                   	push   %ebx
  8015fd:	e8 08 f2 ff ff       	call   80080a <strlen>
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80160a:	7f 67                	jg     801673 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	e8 a7 f8 ff ff       	call   800ebf <fd_alloc>
  801618:	83 c4 10             	add    $0x10,%esp
		return r;
  80161b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 57                	js     801678 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	53                   	push   %ebx
  801625:	68 00 50 80 00       	push   $0x805000
  80162a:	e8 14 f2 ff ff       	call   800843 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80162f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801632:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801637:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163a:	b8 01 00 00 00       	mov    $0x1,%eax
  80163f:	e8 03 fe ff ff       	call   801447 <fsipc>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	85 c0                	test   %eax,%eax
  80164b:	79 14                	jns    801661 <open+0x6f>
		fd_close(fd, 0);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	6a 00                	push   $0x0
  801652:	ff 75 f4             	pushl  -0xc(%ebp)
  801655:	e8 5d f9 ff ff       	call   800fb7 <fd_close>
		return r;
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	89 da                	mov    %ebx,%edx
  80165f:	eb 17                	jmp    801678 <open+0x86>
	}

	return fd2num(fd);
  801661:	83 ec 0c             	sub    $0xc,%esp
  801664:	ff 75 f4             	pushl  -0xc(%ebp)
  801667:	e8 2c f8 ff ff       	call   800e98 <fd2num>
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	eb 05                	jmp    801678 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801673:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801678:	89 d0                	mov    %edx,%eax
  80167a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801685:	ba 00 00 00 00       	mov    $0x0,%edx
  80168a:	b8 08 00 00 00       	mov    $0x8,%eax
  80168f:	e8 b3 fd ff ff       	call   801447 <fsipc>
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801696:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80169a:	7e 37                	jle    8016d3 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016a5:	ff 70 04             	pushl  0x4(%eax)
  8016a8:	8d 40 10             	lea    0x10(%eax),%eax
  8016ab:	50                   	push   %eax
  8016ac:	ff 33                	pushl  (%ebx)
  8016ae:	e8 9b fb ff ff       	call   80124e <write>
		if (result > 0)
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	7e 03                	jle    8016bd <writebuf+0x27>
			b->result += result;
  8016ba:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016bd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016c0:	74 0d                	je     8016cf <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	0f 4f c2             	cmovg  %edx,%eax
  8016cc:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	f3 c3                	repz ret 

008016d5 <putch>:

static void
putch(int ch, void *thunk)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 04             	sub    $0x4,%esp
  8016dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016df:	8b 53 04             	mov    0x4(%ebx),%edx
  8016e2:	8d 42 01             	lea    0x1(%edx),%eax
  8016e5:	89 43 04             	mov    %eax,0x4(%ebx)
  8016e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016eb:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016ef:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016f4:	75 0e                	jne    801704 <putch+0x2f>
		writebuf(b);
  8016f6:	89 d8                	mov    %ebx,%eax
  8016f8:	e8 99 ff ff ff       	call   801696 <writebuf>
		b->idx = 0;
  8016fd:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801704:	83 c4 04             	add    $0x4,%esp
  801707:	5b                   	pop    %ebx
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80171c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801723:	00 00 00 
	b.result = 0;
  801726:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80172d:	00 00 00 
	b.error = 1;
  801730:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801737:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80173a:	ff 75 10             	pushl  0x10(%ebp)
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801746:	50                   	push   %eax
  801747:	68 d5 16 80 00       	push   $0x8016d5
  80174c:	e8 a4 ec ff ff       	call   8003f5 <vprintfmt>
	if (b.idx > 0)
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80175b:	7e 0b                	jle    801768 <vfprintf+0x5e>
		writebuf(&b);
  80175d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801763:	e8 2e ff ff ff       	call   801696 <writebuf>

	return (b.result ? b.result : b.error);
  801768:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80176e:	85 c0                	test   %eax,%eax
  801770:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801777:	c9                   	leave  
  801778:	c3                   	ret    

00801779 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80177f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801782:	50                   	push   %eax
  801783:	ff 75 0c             	pushl  0xc(%ebp)
  801786:	ff 75 08             	pushl  0x8(%ebp)
  801789:	e8 7c ff ff ff       	call   80170a <vfprintf>
	va_end(ap);

	return cnt;
}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <printf>:

int
printf(const char *fmt, ...)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801796:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801799:	50                   	push   %eax
  80179a:	ff 75 08             	pushl  0x8(%ebp)
  80179d:	6a 01                	push   $0x1
  80179f:	e8 66 ff ff ff       	call   80170a <vfprintf>
	va_end(ap);

	return cnt;
}
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8017ac:	68 33 29 80 00       	push   $0x802933
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	e8 8a f0 ff ff       	call   800843 <strcpy>
	return 0;
}
  8017b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017be:	c9                   	leave  
  8017bf:	c3                   	ret    

008017c0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 10             	sub    $0x10,%esp
  8017c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8017ca:	53                   	push   %ebx
  8017cb:	e8 10 0a 00 00       	call   8021e0 <pageref>
  8017d0:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8017d3:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8017d8:	83 f8 01             	cmp    $0x1,%eax
  8017db:	75 10                	jne    8017ed <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8017dd:	83 ec 0c             	sub    $0xc,%esp
  8017e0:	ff 73 0c             	pushl  0xc(%ebx)
  8017e3:	e8 c0 02 00 00       	call   801aa8 <nsipc_close>
  8017e8:	89 c2                	mov    %eax,%edx
  8017ea:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8017ed:	89 d0                	mov    %edx,%eax
  8017ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017fa:	6a 00                	push   $0x0
  8017fc:	ff 75 10             	pushl  0x10(%ebp)
  8017ff:	ff 75 0c             	pushl  0xc(%ebp)
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	ff 70 0c             	pushl  0xc(%eax)
  801808:	e8 78 03 00 00       	call   801b85 <nsipc_send>
}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801815:	6a 00                	push   $0x0
  801817:	ff 75 10             	pushl  0x10(%ebp)
  80181a:	ff 75 0c             	pushl  0xc(%ebp)
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	ff 70 0c             	pushl  0xc(%eax)
  801823:	e8 f1 02 00 00       	call   801b19 <nsipc_recv>
}
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801830:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801833:	52                   	push   %edx
  801834:	50                   	push   %eax
  801835:	e8 d4 f6 ff ff       	call   800f0e <fd_lookup>
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 17                	js     801858 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801841:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801844:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  80184a:	39 08                	cmp    %ecx,(%eax)
  80184c:	75 05                	jne    801853 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80184e:	8b 40 0c             	mov    0xc(%eax),%eax
  801851:	eb 05                	jmp    801858 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801853:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	83 ec 1c             	sub    $0x1c,%esp
  801862:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801864:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	e8 52 f6 ff ff       	call   800ebf <fd_alloc>
  80186d:	89 c3                	mov    %eax,%ebx
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	78 1b                	js     801891 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	68 07 04 00 00       	push   $0x407
  80187e:	ff 75 f4             	pushl  -0xc(%ebp)
  801881:	6a 00                	push   $0x0
  801883:	e8 be f3 ff ff       	call   800c46 <sys_page_alloc>
  801888:	89 c3                	mov    %eax,%ebx
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	79 10                	jns    8018a1 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	56                   	push   %esi
  801895:	e8 0e 02 00 00       	call   801aa8 <nsipc_close>
		return r;
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	89 d8                	mov    %ebx,%eax
  80189f:	eb 24                	jmp    8018c5 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8018a1:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8018a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018aa:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8018b6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8018b9:	83 ec 0c             	sub    $0xc,%esp
  8018bc:	50                   	push   %eax
  8018bd:	e8 d6 f5 ff ff       	call   800e98 <fd2num>
  8018c2:	83 c4 10             	add    $0x10,%esp
}
  8018c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c8:	5b                   	pop    %ebx
  8018c9:	5e                   	pop    %esi
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	e8 50 ff ff ff       	call   80182a <fd2sockid>
		return r;
  8018da:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 1f                	js     8018ff <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018e0:	83 ec 04             	sub    $0x4,%esp
  8018e3:	ff 75 10             	pushl  0x10(%ebp)
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	50                   	push   %eax
  8018ea:	e8 12 01 00 00       	call   801a01 <nsipc_accept>
  8018ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f2:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 07                	js     8018ff <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8018f8:	e8 5d ff ff ff       	call   80185a <alloc_sockfd>
  8018fd:	89 c1                	mov    %eax,%ecx
}
  8018ff:	89 c8                	mov    %ecx,%eax
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801909:	8b 45 08             	mov    0x8(%ebp),%eax
  80190c:	e8 19 ff ff ff       	call   80182a <fd2sockid>
  801911:	85 c0                	test   %eax,%eax
  801913:	78 12                	js     801927 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801915:	83 ec 04             	sub    $0x4,%esp
  801918:	ff 75 10             	pushl  0x10(%ebp)
  80191b:	ff 75 0c             	pushl  0xc(%ebp)
  80191e:	50                   	push   %eax
  80191f:	e8 2d 01 00 00       	call   801a51 <nsipc_bind>
  801924:	83 c4 10             	add    $0x10,%esp
}
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <shutdown>:

int
shutdown(int s, int how)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	e8 f3 fe ff ff       	call   80182a <fd2sockid>
  801937:	85 c0                	test   %eax,%eax
  801939:	78 0f                	js     80194a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	ff 75 0c             	pushl  0xc(%ebp)
  801941:	50                   	push   %eax
  801942:	e8 3f 01 00 00       	call   801a86 <nsipc_shutdown>
  801947:	83 c4 10             	add    $0x10,%esp
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801952:	8b 45 08             	mov    0x8(%ebp),%eax
  801955:	e8 d0 fe ff ff       	call   80182a <fd2sockid>
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 12                	js     801970 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80195e:	83 ec 04             	sub    $0x4,%esp
  801961:	ff 75 10             	pushl  0x10(%ebp)
  801964:	ff 75 0c             	pushl  0xc(%ebp)
  801967:	50                   	push   %eax
  801968:	e8 55 01 00 00       	call   801ac2 <nsipc_connect>
  80196d:	83 c4 10             	add    $0x10,%esp
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <listen>:

int
listen(int s, int backlog)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801978:	8b 45 08             	mov    0x8(%ebp),%eax
  80197b:	e8 aa fe ff ff       	call   80182a <fd2sockid>
  801980:	85 c0                	test   %eax,%eax
  801982:	78 0f                	js     801993 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801984:	83 ec 08             	sub    $0x8,%esp
  801987:	ff 75 0c             	pushl  0xc(%ebp)
  80198a:	50                   	push   %eax
  80198b:	e8 67 01 00 00       	call   801af7 <nsipc_listen>
  801990:	83 c4 10             	add    $0x10,%esp
}
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80199b:	ff 75 10             	pushl  0x10(%ebp)
  80199e:	ff 75 0c             	pushl  0xc(%ebp)
  8019a1:	ff 75 08             	pushl  0x8(%ebp)
  8019a4:	e8 3a 02 00 00       	call   801be3 <nsipc_socket>
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 05                	js     8019b5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8019b0:	e8 a5 fe ff ff       	call   80185a <alloc_sockfd>
}
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	53                   	push   %ebx
  8019bb:	83 ec 04             	sub    $0x4,%esp
  8019be:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019c0:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  8019c7:	75 12                	jne    8019db <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	6a 02                	push   $0x2
  8019ce:	e8 d4 07 00 00       	call   8021a7 <ipc_find_env>
  8019d3:	a3 08 40 80 00       	mov    %eax,0x804008
  8019d8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019db:	6a 07                	push   $0x7
  8019dd:	68 00 60 80 00       	push   $0x806000
  8019e2:	53                   	push   %ebx
  8019e3:	ff 35 08 40 80 00    	pushl  0x804008
  8019e9:	e8 65 07 00 00       	call   802153 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019ee:	83 c4 0c             	add    $0xc,%esp
  8019f1:	6a 00                	push   $0x0
  8019f3:	6a 00                	push   $0x0
  8019f5:	6a 00                	push   $0x0
  8019f7:	e8 f0 06 00 00       	call   8020ec <ipc_recv>
}
  8019fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a11:	8b 06                	mov    (%esi),%eax
  801a13:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a18:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1d:	e8 95 ff ff ff       	call   8019b7 <nsipc>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 20                	js     801a48 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a28:	83 ec 04             	sub    $0x4,%esp
  801a2b:	ff 35 10 60 80 00    	pushl  0x806010
  801a31:	68 00 60 80 00       	push   $0x806000
  801a36:	ff 75 0c             	pushl  0xc(%ebp)
  801a39:	e8 97 ef ff ff       	call   8009d5 <memmove>
		*addrlen = ret->ret_addrlen;
  801a3e:	a1 10 60 80 00       	mov    0x806010,%eax
  801a43:	89 06                	mov    %eax,(%esi)
  801a45:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801a48:	89 d8                	mov    %ebx,%eax
  801a4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    

00801a51 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	53                   	push   %ebx
  801a55:	83 ec 08             	sub    $0x8,%esp
  801a58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a63:	53                   	push   %ebx
  801a64:	ff 75 0c             	pushl  0xc(%ebp)
  801a67:	68 04 60 80 00       	push   $0x806004
  801a6c:	e8 64 ef ff ff       	call   8009d5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a71:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a77:	b8 02 00 00 00       	mov    $0x2,%eax
  801a7c:	e8 36 ff ff ff       	call   8019b7 <nsipc>
}
  801a81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a97:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801a9c:	b8 03 00 00 00       	mov    $0x3,%eax
  801aa1:	e8 11 ff ff ff       	call   8019b7 <nsipc>
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <nsipc_close>:

int
nsipc_close(int s)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ab6:	b8 04 00 00 00       	mov    $0x4,%eax
  801abb:	e8 f7 fe ff ff       	call   8019b7 <nsipc>
}
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	53                   	push   %ebx
  801ac6:	83 ec 08             	sub    $0x8,%esp
  801ac9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ad4:	53                   	push   %ebx
  801ad5:	ff 75 0c             	pushl  0xc(%ebp)
  801ad8:	68 04 60 80 00       	push   $0x806004
  801add:	e8 f3 ee ff ff       	call   8009d5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ae2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ae8:	b8 05 00 00 00       	mov    $0x5,%eax
  801aed:	e8 c5 fe ff ff       	call   8019b7 <nsipc>
}
  801af2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801afd:	8b 45 08             	mov    0x8(%ebp),%eax
  801b00:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b08:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b0d:	b8 06 00 00 00       	mov    $0x6,%eax
  801b12:	e8 a0 fe ff ff       	call   8019b7 <nsipc>
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b21:	8b 45 08             	mov    0x8(%ebp),%eax
  801b24:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b29:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801b32:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b37:	b8 07 00 00 00       	mov    $0x7,%eax
  801b3c:	e8 76 fe ff ff       	call   8019b7 <nsipc>
  801b41:	89 c3                	mov    %eax,%ebx
  801b43:	85 c0                	test   %eax,%eax
  801b45:	78 35                	js     801b7c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801b47:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b4c:	7f 04                	jg     801b52 <nsipc_recv+0x39>
  801b4e:	39 c6                	cmp    %eax,%esi
  801b50:	7d 16                	jge    801b68 <nsipc_recv+0x4f>
  801b52:	68 3f 29 80 00       	push   $0x80293f
  801b57:	68 07 29 80 00       	push   $0x802907
  801b5c:	6a 62                	push   $0x62
  801b5e:	68 54 29 80 00       	push   $0x802954
  801b63:	e8 7d e6 ff ff       	call   8001e5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b68:	83 ec 04             	sub    $0x4,%esp
  801b6b:	50                   	push   %eax
  801b6c:	68 00 60 80 00       	push   $0x806000
  801b71:	ff 75 0c             	pushl  0xc(%ebp)
  801b74:	e8 5c ee ff ff       	call   8009d5 <memmove>
  801b79:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b81:	5b                   	pop    %ebx
  801b82:	5e                   	pop    %esi
  801b83:	5d                   	pop    %ebp
  801b84:	c3                   	ret    

00801b85 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	53                   	push   %ebx
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801b97:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b9d:	7e 16                	jle    801bb5 <nsipc_send+0x30>
  801b9f:	68 60 29 80 00       	push   $0x802960
  801ba4:	68 07 29 80 00       	push   $0x802907
  801ba9:	6a 6d                	push   $0x6d
  801bab:	68 54 29 80 00       	push   $0x802954
  801bb0:	e8 30 e6 ff ff       	call   8001e5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	53                   	push   %ebx
  801bb9:	ff 75 0c             	pushl  0xc(%ebp)
  801bbc:	68 0c 60 80 00       	push   $0x80600c
  801bc1:	e8 0f ee ff ff       	call   8009d5 <memmove>
	nsipcbuf.send.req_size = size;
  801bc6:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801bcc:	8b 45 14             	mov    0x14(%ebp),%eax
  801bcf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801bd4:	b8 08 00 00 00       	mov    $0x8,%eax
  801bd9:	e8 d9 fd ff ff       	call   8019b7 <nsipc>
}
  801bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801bf9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bfc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c01:	b8 09 00 00 00       	mov    $0x9,%eax
  801c06:	e8 ac fd ff ff       	call   8019b7 <nsipc>
}
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    

00801c0d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
  801c12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	ff 75 08             	pushl  0x8(%ebp)
  801c1b:	e8 88 f2 ff ff       	call   800ea8 <fd2data>
  801c20:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c22:	83 c4 08             	add    $0x8,%esp
  801c25:	68 6c 29 80 00       	push   $0x80296c
  801c2a:	53                   	push   %ebx
  801c2b:	e8 13 ec ff ff       	call   800843 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c30:	8b 46 04             	mov    0x4(%esi),%eax
  801c33:	2b 06                	sub    (%esi),%eax
  801c35:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c3b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c42:	00 00 00 
	stat->st_dev = &devpipe;
  801c45:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801c4c:	30 80 00 
	return 0;
}
  801c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	53                   	push   %ebx
  801c5f:	83 ec 0c             	sub    $0xc,%esp
  801c62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c65:	53                   	push   %ebx
  801c66:	6a 00                	push   $0x0
  801c68:	e8 5e f0 ff ff       	call   800ccb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c6d:	89 1c 24             	mov    %ebx,(%esp)
  801c70:	e8 33 f2 ff ff       	call   800ea8 <fd2data>
  801c75:	83 c4 08             	add    $0x8,%esp
  801c78:	50                   	push   %eax
  801c79:	6a 00                	push   $0x0
  801c7b:	e8 4b f0 ff ff       	call   800ccb <sys_page_unmap>
}
  801c80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c83:	c9                   	leave  
  801c84:	c3                   	ret    

00801c85 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	57                   	push   %edi
  801c89:	56                   	push   %esi
  801c8a:	53                   	push   %ebx
  801c8b:	83 ec 1c             	sub    $0x1c,%esp
  801c8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c91:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c93:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801c98:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c9b:	83 ec 0c             	sub    $0xc,%esp
  801c9e:	ff 75 e0             	pushl  -0x20(%ebp)
  801ca1:	e8 3a 05 00 00       	call   8021e0 <pageref>
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	89 3c 24             	mov    %edi,(%esp)
  801cab:	e8 30 05 00 00       	call   8021e0 <pageref>
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	39 c3                	cmp    %eax,%ebx
  801cb5:	0f 94 c1             	sete   %cl
  801cb8:	0f b6 c9             	movzbl %cl,%ecx
  801cbb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cbe:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801cc4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cc7:	39 ce                	cmp    %ecx,%esi
  801cc9:	74 1b                	je     801ce6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ccb:	39 c3                	cmp    %eax,%ebx
  801ccd:	75 c4                	jne    801c93 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ccf:	8b 42 58             	mov    0x58(%edx),%eax
  801cd2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cd5:	50                   	push   %eax
  801cd6:	56                   	push   %esi
  801cd7:	68 73 29 80 00       	push   $0x802973
  801cdc:	e8 dd e5 ff ff       	call   8002be <cprintf>
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	eb ad                	jmp    801c93 <_pipeisclosed+0xe>
	}
}
  801ce6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cec:	5b                   	pop    %ebx
  801ced:	5e                   	pop    %esi
  801cee:	5f                   	pop    %edi
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	57                   	push   %edi
  801cf5:	56                   	push   %esi
  801cf6:	53                   	push   %ebx
  801cf7:	83 ec 28             	sub    $0x28,%esp
  801cfa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cfd:	56                   	push   %esi
  801cfe:	e8 a5 f1 ff ff       	call   800ea8 <fd2data>
  801d03:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	bf 00 00 00 00       	mov    $0x0,%edi
  801d0d:	eb 4b                	jmp    801d5a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d0f:	89 da                	mov    %ebx,%edx
  801d11:	89 f0                	mov    %esi,%eax
  801d13:	e8 6d ff ff ff       	call   801c85 <_pipeisclosed>
  801d18:	85 c0                	test   %eax,%eax
  801d1a:	75 48                	jne    801d64 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d1c:	e8 06 ef ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d21:	8b 43 04             	mov    0x4(%ebx),%eax
  801d24:	8b 0b                	mov    (%ebx),%ecx
  801d26:	8d 51 20             	lea    0x20(%ecx),%edx
  801d29:	39 d0                	cmp    %edx,%eax
  801d2b:	73 e2                	jae    801d0f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d30:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d34:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	c1 fa 1f             	sar    $0x1f,%edx
  801d3c:	89 d1                	mov    %edx,%ecx
  801d3e:	c1 e9 1b             	shr    $0x1b,%ecx
  801d41:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d44:	83 e2 1f             	and    $0x1f,%edx
  801d47:	29 ca                	sub    %ecx,%edx
  801d49:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d4d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d51:	83 c0 01             	add    $0x1,%eax
  801d54:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d57:	83 c7 01             	add    $0x1,%edi
  801d5a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d5d:	75 c2                	jne    801d21 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d62:	eb 05                	jmp    801d69 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d64:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	57                   	push   %edi
  801d75:	56                   	push   %esi
  801d76:	53                   	push   %ebx
  801d77:	83 ec 18             	sub    $0x18,%esp
  801d7a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d7d:	57                   	push   %edi
  801d7e:	e8 25 f1 ff ff       	call   800ea8 <fd2data>
  801d83:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d8d:	eb 3d                	jmp    801dcc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d8f:	85 db                	test   %ebx,%ebx
  801d91:	74 04                	je     801d97 <devpipe_read+0x26>
				return i;
  801d93:	89 d8                	mov    %ebx,%eax
  801d95:	eb 44                	jmp    801ddb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d97:	89 f2                	mov    %esi,%edx
  801d99:	89 f8                	mov    %edi,%eax
  801d9b:	e8 e5 fe ff ff       	call   801c85 <_pipeisclosed>
  801da0:	85 c0                	test   %eax,%eax
  801da2:	75 32                	jne    801dd6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801da4:	e8 7e ee ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801da9:	8b 06                	mov    (%esi),%eax
  801dab:	3b 46 04             	cmp    0x4(%esi),%eax
  801dae:	74 df                	je     801d8f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801db0:	99                   	cltd   
  801db1:	c1 ea 1b             	shr    $0x1b,%edx
  801db4:	01 d0                	add    %edx,%eax
  801db6:	83 e0 1f             	and    $0x1f,%eax
  801db9:	29 d0                	sub    %edx,%eax
  801dbb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dc3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dc6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc9:	83 c3 01             	add    $0x1,%ebx
  801dcc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dcf:	75 d8                	jne    801da9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dd1:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd4:	eb 05                	jmp    801ddb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dde:	5b                   	pop    %ebx
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    

00801de3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	56                   	push   %esi
  801de7:	53                   	push   %ebx
  801de8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801deb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dee:	50                   	push   %eax
  801def:	e8 cb f0 ff ff       	call   800ebf <fd_alloc>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	89 c2                	mov    %eax,%edx
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	0f 88 2c 01 00 00    	js     801f2d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e01:	83 ec 04             	sub    $0x4,%esp
  801e04:	68 07 04 00 00       	push   $0x407
  801e09:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0c:	6a 00                	push   $0x0
  801e0e:	e8 33 ee ff ff       	call   800c46 <sys_page_alloc>
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	89 c2                	mov    %eax,%edx
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	0f 88 0d 01 00 00    	js     801f2d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e20:	83 ec 0c             	sub    $0xc,%esp
  801e23:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e26:	50                   	push   %eax
  801e27:	e8 93 f0 ff ff       	call   800ebf <fd_alloc>
  801e2c:	89 c3                	mov    %eax,%ebx
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	0f 88 e2 00 00 00    	js     801f1b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e39:	83 ec 04             	sub    $0x4,%esp
  801e3c:	68 07 04 00 00       	push   $0x407
  801e41:	ff 75 f0             	pushl  -0x10(%ebp)
  801e44:	6a 00                	push   $0x0
  801e46:	e8 fb ed ff ff       	call   800c46 <sys_page_alloc>
  801e4b:	89 c3                	mov    %eax,%ebx
  801e4d:	83 c4 10             	add    $0x10,%esp
  801e50:	85 c0                	test   %eax,%eax
  801e52:	0f 88 c3 00 00 00    	js     801f1b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e58:	83 ec 0c             	sub    $0xc,%esp
  801e5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5e:	e8 45 f0 ff ff       	call   800ea8 <fd2data>
  801e63:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e65:	83 c4 0c             	add    $0xc,%esp
  801e68:	68 07 04 00 00       	push   $0x407
  801e6d:	50                   	push   %eax
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 d1 ed ff ff       	call   800c46 <sys_page_alloc>
  801e75:	89 c3                	mov    %eax,%ebx
  801e77:	83 c4 10             	add    $0x10,%esp
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	0f 88 89 00 00 00    	js     801f0b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	ff 75 f0             	pushl  -0x10(%ebp)
  801e88:	e8 1b f0 ff ff       	call   800ea8 <fd2data>
  801e8d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e94:	50                   	push   %eax
  801e95:	6a 00                	push   $0x0
  801e97:	56                   	push   %esi
  801e98:	6a 00                	push   $0x0
  801e9a:	e8 ea ed ff ff       	call   800c89 <sys_page_map>
  801e9f:	89 c3                	mov    %eax,%ebx
  801ea1:	83 c4 20             	add    $0x20,%esp
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	78 55                	js     801efd <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ea8:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ebd:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ecb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ed2:	83 ec 0c             	sub    $0xc,%esp
  801ed5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed8:	e8 bb ef ff ff       	call   800e98 <fd2num>
  801edd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ee2:	83 c4 04             	add    $0x4,%esp
  801ee5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee8:	e8 ab ef ff ff       	call   800e98 <fd2num>
  801eed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ef0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	ba 00 00 00 00       	mov    $0x0,%edx
  801efb:	eb 30                	jmp    801f2d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801efd:	83 ec 08             	sub    $0x8,%esp
  801f00:	56                   	push   %esi
  801f01:	6a 00                	push   $0x0
  801f03:	e8 c3 ed ff ff       	call   800ccb <sys_page_unmap>
  801f08:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f0b:	83 ec 08             	sub    $0x8,%esp
  801f0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801f11:	6a 00                	push   $0x0
  801f13:	e8 b3 ed ff ff       	call   800ccb <sys_page_unmap>
  801f18:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f1b:	83 ec 08             	sub    $0x8,%esp
  801f1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f21:	6a 00                	push   $0x0
  801f23:	e8 a3 ed ff ff       	call   800ccb <sys_page_unmap>
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f2d:	89 d0                	mov    %edx,%eax
  801f2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f32:	5b                   	pop    %ebx
  801f33:	5e                   	pop    %esi
  801f34:	5d                   	pop    %ebp
  801f35:	c3                   	ret    

00801f36 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3f:	50                   	push   %eax
  801f40:	ff 75 08             	pushl  0x8(%ebp)
  801f43:	e8 c6 ef ff ff       	call   800f0e <fd_lookup>
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	78 18                	js     801f67 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	ff 75 f4             	pushl  -0xc(%ebp)
  801f55:	e8 4e ef ff ff       	call   800ea8 <fd2data>
	return _pipeisclosed(fd, p);
  801f5a:	89 c2                	mov    %eax,%edx
  801f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5f:	e8 21 fd ff ff       	call   801c85 <_pipeisclosed>
  801f64:	83 c4 10             	add    $0x10,%esp
}
  801f67:	c9                   	leave  
  801f68:	c3                   	ret    

00801f69 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    

00801f73 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f79:	68 8b 29 80 00       	push   $0x80298b
  801f7e:	ff 75 0c             	pushl  0xc(%ebp)
  801f81:	e8 bd e8 ff ff       	call   800843 <strcpy>
	return 0;
}
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8b:	c9                   	leave  
  801f8c:	c3                   	ret    

00801f8d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	57                   	push   %edi
  801f91:	56                   	push   %esi
  801f92:	53                   	push   %ebx
  801f93:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f99:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f9e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fa4:	eb 2d                	jmp    801fd3 <devcons_write+0x46>
		m = n - tot;
  801fa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fab:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fae:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fb3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fb6:	83 ec 04             	sub    $0x4,%esp
  801fb9:	53                   	push   %ebx
  801fba:	03 45 0c             	add    0xc(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	57                   	push   %edi
  801fbf:	e8 11 ea ff ff       	call   8009d5 <memmove>
		sys_cputs(buf, m);
  801fc4:	83 c4 08             	add    $0x8,%esp
  801fc7:	53                   	push   %ebx
  801fc8:	57                   	push   %edi
  801fc9:	e8 bc eb ff ff       	call   800b8a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fce:	01 de                	add    %ebx,%esi
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	89 f0                	mov    %esi,%eax
  801fd5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fd8:	72 cc                	jb     801fa6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    

00801fe2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 08             	sub    $0x8,%esp
  801fe8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ff1:	74 2a                	je     80201d <devcons_read+0x3b>
  801ff3:	eb 05                	jmp    801ffa <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ff5:	e8 2d ec ff ff       	call   800c27 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ffa:	e8 a9 eb ff ff       	call   800ba8 <sys_cgetc>
  801fff:	85 c0                	test   %eax,%eax
  802001:	74 f2                	je     801ff5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802003:	85 c0                	test   %eax,%eax
  802005:	78 16                	js     80201d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802007:	83 f8 04             	cmp    $0x4,%eax
  80200a:	74 0c                	je     802018 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80200c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200f:	88 02                	mov    %al,(%edx)
	return 1;
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	eb 05                	jmp    80201d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802018:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    

0080201f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802025:	8b 45 08             	mov    0x8(%ebp),%eax
  802028:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80202b:	6a 01                	push   $0x1
  80202d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802030:	50                   	push   %eax
  802031:	e8 54 eb ff ff       	call   800b8a <sys_cputs>
}
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	c9                   	leave  
  80203a:	c3                   	ret    

0080203b <getchar>:

int
getchar(void)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802041:	6a 01                	push   $0x1
  802043:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802046:	50                   	push   %eax
  802047:	6a 00                	push   $0x0
  802049:	e8 26 f1 ff ff       	call   801174 <read>
	if (r < 0)
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	85 c0                	test   %eax,%eax
  802053:	78 0f                	js     802064 <getchar+0x29>
		return r;
	if (r < 1)
  802055:	85 c0                	test   %eax,%eax
  802057:	7e 06                	jle    80205f <getchar+0x24>
		return -E_EOF;
	return c;
  802059:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80205d:	eb 05                	jmp    802064 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80205f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802064:	c9                   	leave  
  802065:	c3                   	ret    

00802066 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802066:	55                   	push   %ebp
  802067:	89 e5                	mov    %esp,%ebp
  802069:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80206c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206f:	50                   	push   %eax
  802070:	ff 75 08             	pushl  0x8(%ebp)
  802073:	e8 96 ee ff ff       	call   800f0e <fd_lookup>
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	85 c0                	test   %eax,%eax
  80207d:	78 11                	js     802090 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80207f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802082:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802088:	39 10                	cmp    %edx,(%eax)
  80208a:	0f 94 c0             	sete   %al
  80208d:	0f b6 c0             	movzbl %al,%eax
}
  802090:	c9                   	leave  
  802091:	c3                   	ret    

00802092 <opencons>:

int
opencons(void)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802098:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209b:	50                   	push   %eax
  80209c:	e8 1e ee ff ff       	call   800ebf <fd_alloc>
  8020a1:	83 c4 10             	add    $0x10,%esp
		return r;
  8020a4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 3e                	js     8020e8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020aa:	83 ec 04             	sub    $0x4,%esp
  8020ad:	68 07 04 00 00       	push   $0x407
  8020b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b5:	6a 00                	push   $0x0
  8020b7:	e8 8a eb ff ff       	call   800c46 <sys_page_alloc>
  8020bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8020bf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	78 23                	js     8020e8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020c5:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8020cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020da:	83 ec 0c             	sub    $0xc,%esp
  8020dd:	50                   	push   %eax
  8020de:	e8 b5 ed ff ff       	call   800e98 <fd2num>
  8020e3:	89 c2                	mov    %eax,%edx
  8020e5:	83 c4 10             	add    $0x10,%esp
}
  8020e8:	89 d0                	mov    %edx,%eax
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    

008020ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	56                   	push   %esi
  8020f0:	53                   	push   %ebx
  8020f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8020f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8020fa:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8020fc:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802101:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802104:	83 ec 0c             	sub    $0xc,%esp
  802107:	50                   	push   %eax
  802108:	e8 e9 ec ff ff       	call   800df6 <sys_ipc_recv>

	if (from_env_store != NULL)
  80210d:	83 c4 10             	add    $0x10,%esp
  802110:	85 f6                	test   %esi,%esi
  802112:	74 14                	je     802128 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802114:	ba 00 00 00 00       	mov    $0x0,%edx
  802119:	85 c0                	test   %eax,%eax
  80211b:	78 09                	js     802126 <ipc_recv+0x3a>
  80211d:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  802123:	8b 52 74             	mov    0x74(%edx),%edx
  802126:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802128:	85 db                	test   %ebx,%ebx
  80212a:	74 14                	je     802140 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80212c:	ba 00 00 00 00       	mov    $0x0,%edx
  802131:	85 c0                	test   %eax,%eax
  802133:	78 09                	js     80213e <ipc_recv+0x52>
  802135:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  80213b:	8b 52 78             	mov    0x78(%edx),%edx
  80213e:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802140:	85 c0                	test   %eax,%eax
  802142:	78 08                	js     80214c <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802144:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802149:	8b 40 70             	mov    0x70(%eax),%eax
}
  80214c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    

00802153 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	57                   	push   %edi
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
  802159:	83 ec 0c             	sub    $0xc,%esp
  80215c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80215f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802162:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802165:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802167:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80216c:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80216f:	ff 75 14             	pushl  0x14(%ebp)
  802172:	53                   	push   %ebx
  802173:	56                   	push   %esi
  802174:	57                   	push   %edi
  802175:	e8 59 ec ff ff       	call   800dd3 <sys_ipc_try_send>

		if (err < 0) {
  80217a:	83 c4 10             	add    $0x10,%esp
  80217d:	85 c0                	test   %eax,%eax
  80217f:	79 1e                	jns    80219f <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802181:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802184:	75 07                	jne    80218d <ipc_send+0x3a>
				sys_yield();
  802186:	e8 9c ea ff ff       	call   800c27 <sys_yield>
  80218b:	eb e2                	jmp    80216f <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80218d:	50                   	push   %eax
  80218e:	68 97 29 80 00       	push   $0x802997
  802193:	6a 49                	push   $0x49
  802195:	68 a4 29 80 00       	push   $0x8029a4
  80219a:	e8 46 e0 ff ff       	call   8001e5 <_panic>
		}

	} while (err < 0);

}
  80219f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a2:	5b                   	pop    %ebx
  8021a3:	5e                   	pop    %esi
  8021a4:	5f                   	pop    %edi
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021ad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021b2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021b5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021bb:	8b 52 50             	mov    0x50(%edx),%edx
  8021be:	39 ca                	cmp    %ecx,%edx
  8021c0:	75 0d                	jne    8021cf <ipc_find_env+0x28>
			return envs[i].env_id;
  8021c2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021c5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021ca:	8b 40 48             	mov    0x48(%eax),%eax
  8021cd:	eb 0f                	jmp    8021de <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021cf:	83 c0 01             	add    $0x1,%eax
  8021d2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021d7:	75 d9                	jne    8021b2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    

008021e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	c1 e8 16             	shr    $0x16,%eax
  8021eb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021f2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f7:	f6 c1 01             	test   $0x1,%cl
  8021fa:	74 1d                	je     802219 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021fc:	c1 ea 0c             	shr    $0xc,%edx
  8021ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802206:	f6 c2 01             	test   $0x1,%dl
  802209:	74 0e                	je     802219 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80220b:	c1 ea 0c             	shr    $0xc,%edx
  80220e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802215:	ef 
  802216:	0f b7 c0             	movzwl %ax,%eax
}
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    
  80221b:	66 90                	xchg   %ax,%ax
  80221d:	66 90                	xchg   %ax,%ax
  80221f:	90                   	nop

00802220 <__udivdi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80222b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80222f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 f6                	test   %esi,%esi
  802239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80223d:	89 ca                	mov    %ecx,%edx
  80223f:	89 f8                	mov    %edi,%eax
  802241:	75 3d                	jne    802280 <__udivdi3+0x60>
  802243:	39 cf                	cmp    %ecx,%edi
  802245:	0f 87 c5 00 00 00    	ja     802310 <__udivdi3+0xf0>
  80224b:	85 ff                	test   %edi,%edi
  80224d:	89 fd                	mov    %edi,%ebp
  80224f:	75 0b                	jne    80225c <__udivdi3+0x3c>
  802251:	b8 01 00 00 00       	mov    $0x1,%eax
  802256:	31 d2                	xor    %edx,%edx
  802258:	f7 f7                	div    %edi
  80225a:	89 c5                	mov    %eax,%ebp
  80225c:	89 c8                	mov    %ecx,%eax
  80225e:	31 d2                	xor    %edx,%edx
  802260:	f7 f5                	div    %ebp
  802262:	89 c1                	mov    %eax,%ecx
  802264:	89 d8                	mov    %ebx,%eax
  802266:	89 cf                	mov    %ecx,%edi
  802268:	f7 f5                	div    %ebp
  80226a:	89 c3                	mov    %eax,%ebx
  80226c:	89 d8                	mov    %ebx,%eax
  80226e:	89 fa                	mov    %edi,%edx
  802270:	83 c4 1c             	add    $0x1c,%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	90                   	nop
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	39 ce                	cmp    %ecx,%esi
  802282:	77 74                	ja     8022f8 <__udivdi3+0xd8>
  802284:	0f bd fe             	bsr    %esi,%edi
  802287:	83 f7 1f             	xor    $0x1f,%edi
  80228a:	0f 84 98 00 00 00    	je     802328 <__udivdi3+0x108>
  802290:	bb 20 00 00 00       	mov    $0x20,%ebx
  802295:	89 f9                	mov    %edi,%ecx
  802297:	89 c5                	mov    %eax,%ebp
  802299:	29 fb                	sub    %edi,%ebx
  80229b:	d3 e6                	shl    %cl,%esi
  80229d:	89 d9                	mov    %ebx,%ecx
  80229f:	d3 ed                	shr    %cl,%ebp
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	d3 e0                	shl    %cl,%eax
  8022a5:	09 ee                	or     %ebp,%esi
  8022a7:	89 d9                	mov    %ebx,%ecx
  8022a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ad:	89 d5                	mov    %edx,%ebp
  8022af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022b3:	d3 ed                	shr    %cl,%ebp
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e2                	shl    %cl,%edx
  8022b9:	89 d9                	mov    %ebx,%ecx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	09 c2                	or     %eax,%edx
  8022bf:	89 d0                	mov    %edx,%eax
  8022c1:	89 ea                	mov    %ebp,%edx
  8022c3:	f7 f6                	div    %esi
  8022c5:	89 d5                	mov    %edx,%ebp
  8022c7:	89 c3                	mov    %eax,%ebx
  8022c9:	f7 64 24 0c          	mull   0xc(%esp)
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	72 10                	jb     8022e1 <__udivdi3+0xc1>
  8022d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e6                	shl    %cl,%esi
  8022d9:	39 c6                	cmp    %eax,%esi
  8022db:	73 07                	jae    8022e4 <__udivdi3+0xc4>
  8022dd:	39 d5                	cmp    %edx,%ebp
  8022df:	75 03                	jne    8022e4 <__udivdi3+0xc4>
  8022e1:	83 eb 01             	sub    $0x1,%ebx
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 d8                	mov    %ebx,%eax
  8022e8:	89 fa                	mov    %edi,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	31 ff                	xor    %edi,%edi
  8022fa:	31 db                	xor    %ebx,%ebx
  8022fc:	89 d8                	mov    %ebx,%eax
  8022fe:	89 fa                	mov    %edi,%edx
  802300:	83 c4 1c             	add    $0x1c,%esp
  802303:	5b                   	pop    %ebx
  802304:	5e                   	pop    %esi
  802305:	5f                   	pop    %edi
  802306:	5d                   	pop    %ebp
  802307:	c3                   	ret    
  802308:	90                   	nop
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 d8                	mov    %ebx,%eax
  802312:	f7 f7                	div    %edi
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 c3                	mov    %eax,%ebx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 fa                	mov    %edi,%edx
  80231c:	83 c4 1c             	add    $0x1c,%esp
  80231f:	5b                   	pop    %ebx
  802320:	5e                   	pop    %esi
  802321:	5f                   	pop    %edi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	39 ce                	cmp    %ecx,%esi
  80232a:	72 0c                	jb     802338 <__udivdi3+0x118>
  80232c:	31 db                	xor    %ebx,%ebx
  80232e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802332:	0f 87 34 ff ff ff    	ja     80226c <__udivdi3+0x4c>
  802338:	bb 01 00 00 00       	mov    $0x1,%ebx
  80233d:	e9 2a ff ff ff       	jmp    80226c <__udivdi3+0x4c>
  802342:	66 90                	xchg   %ax,%ax
  802344:	66 90                	xchg   %ax,%ax
  802346:	66 90                	xchg   %ax,%ax
  802348:	66 90                	xchg   %ax,%ax
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	66 90                	xchg   %ax,%ax
  80234e:	66 90                	xchg   %ax,%ax

00802350 <__umoddi3>:
  802350:	55                   	push   %ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	83 ec 1c             	sub    $0x1c,%esp
  802357:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80235b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80235f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802363:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802367:	85 d2                	test   %edx,%edx
  802369:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80236d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802371:	89 f3                	mov    %esi,%ebx
  802373:	89 3c 24             	mov    %edi,(%esp)
  802376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80237a:	75 1c                	jne    802398 <__umoddi3+0x48>
  80237c:	39 f7                	cmp    %esi,%edi
  80237e:	76 50                	jbe    8023d0 <__umoddi3+0x80>
  802380:	89 c8                	mov    %ecx,%eax
  802382:	89 f2                	mov    %esi,%edx
  802384:	f7 f7                	div    %edi
  802386:	89 d0                	mov    %edx,%eax
  802388:	31 d2                	xor    %edx,%edx
  80238a:	83 c4 1c             	add    $0x1c,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	39 f2                	cmp    %esi,%edx
  80239a:	89 d0                	mov    %edx,%eax
  80239c:	77 52                	ja     8023f0 <__umoddi3+0xa0>
  80239e:	0f bd ea             	bsr    %edx,%ebp
  8023a1:	83 f5 1f             	xor    $0x1f,%ebp
  8023a4:	75 5a                	jne    802400 <__umoddi3+0xb0>
  8023a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023aa:	0f 82 e0 00 00 00    	jb     802490 <__umoddi3+0x140>
  8023b0:	39 0c 24             	cmp    %ecx,(%esp)
  8023b3:	0f 86 d7 00 00 00    	jbe    802490 <__umoddi3+0x140>
  8023b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023c1:	83 c4 1c             	add    $0x1c,%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	85 ff                	test   %edi,%edi
  8023d2:	89 fd                	mov    %edi,%ebp
  8023d4:	75 0b                	jne    8023e1 <__umoddi3+0x91>
  8023d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	f7 f7                	div    %edi
  8023df:	89 c5                	mov    %eax,%ebp
  8023e1:	89 f0                	mov    %esi,%eax
  8023e3:	31 d2                	xor    %edx,%edx
  8023e5:	f7 f5                	div    %ebp
  8023e7:	89 c8                	mov    %ecx,%eax
  8023e9:	f7 f5                	div    %ebp
  8023eb:	89 d0                	mov    %edx,%eax
  8023ed:	eb 99                	jmp    802388 <__umoddi3+0x38>
  8023ef:	90                   	nop
  8023f0:	89 c8                	mov    %ecx,%eax
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	83 c4 1c             	add    $0x1c,%esp
  8023f7:	5b                   	pop    %ebx
  8023f8:	5e                   	pop    %esi
  8023f9:	5f                   	pop    %edi
  8023fa:	5d                   	pop    %ebp
  8023fb:	c3                   	ret    
  8023fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802400:	8b 34 24             	mov    (%esp),%esi
  802403:	bf 20 00 00 00       	mov    $0x20,%edi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	29 ef                	sub    %ebp,%edi
  80240c:	d3 e0                	shl    %cl,%eax
  80240e:	89 f9                	mov    %edi,%ecx
  802410:	89 f2                	mov    %esi,%edx
  802412:	d3 ea                	shr    %cl,%edx
  802414:	89 e9                	mov    %ebp,%ecx
  802416:	09 c2                	or     %eax,%edx
  802418:	89 d8                	mov    %ebx,%eax
  80241a:	89 14 24             	mov    %edx,(%esp)
  80241d:	89 f2                	mov    %esi,%edx
  80241f:	d3 e2                	shl    %cl,%edx
  802421:	89 f9                	mov    %edi,%ecx
  802423:	89 54 24 04          	mov    %edx,0x4(%esp)
  802427:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	89 c6                	mov    %eax,%esi
  802431:	d3 e3                	shl    %cl,%ebx
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 d0                	mov    %edx,%eax
  802437:	d3 e8                	shr    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	09 d8                	or     %ebx,%eax
  80243d:	89 d3                	mov    %edx,%ebx
  80243f:	89 f2                	mov    %esi,%edx
  802441:	f7 34 24             	divl   (%esp)
  802444:	89 d6                	mov    %edx,%esi
  802446:	d3 e3                	shl    %cl,%ebx
  802448:	f7 64 24 04          	mull   0x4(%esp)
  80244c:	39 d6                	cmp    %edx,%esi
  80244e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802452:	89 d1                	mov    %edx,%ecx
  802454:	89 c3                	mov    %eax,%ebx
  802456:	72 08                	jb     802460 <__umoddi3+0x110>
  802458:	75 11                	jne    80246b <__umoddi3+0x11b>
  80245a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80245e:	73 0b                	jae    80246b <__umoddi3+0x11b>
  802460:	2b 44 24 04          	sub    0x4(%esp),%eax
  802464:	1b 14 24             	sbb    (%esp),%edx
  802467:	89 d1                	mov    %edx,%ecx
  802469:	89 c3                	mov    %eax,%ebx
  80246b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80246f:	29 da                	sub    %ebx,%edx
  802471:	19 ce                	sbb    %ecx,%esi
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 f0                	mov    %esi,%eax
  802477:	d3 e0                	shl    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	d3 ea                	shr    %cl,%edx
  80247d:	89 e9                	mov    %ebp,%ecx
  80247f:	d3 ee                	shr    %cl,%esi
  802481:	09 d0                	or     %edx,%eax
  802483:	89 f2                	mov    %esi,%edx
  802485:	83 c4 1c             	add    $0x1c,%esp
  802488:	5b                   	pop    %ebx
  802489:	5e                   	pop    %esi
  80248a:	5f                   	pop    %edi
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    
  80248d:	8d 76 00             	lea    0x0(%esi),%esi
  802490:	29 f9                	sub    %edi,%ecx
  802492:	19 d6                	sbb    %edx,%esi
  802494:	89 74 24 04          	mov    %esi,0x4(%esp)
  802498:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80249c:	e9 18 ff ff ff       	jmp    8023b9 <__umoddi3+0x69>
