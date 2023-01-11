
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 f1 11 00 00       	call   80123e <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 a0 24 80 00       	push   $0x8024a0
  800060:	6a 0d                	push   $0xd
  800062:	68 bb 24 80 00       	push   $0x8024bb
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 e5 10 00 00       	call   801164 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 c6 24 80 00       	push   $0x8024c6
  800098:	6a 0f                	push   $0xf
  80009a:	68 bb 24 80 00       	push   $0x8024bb
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 db 	movl   $0x8024db,0x803000
  8000be:	24 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 df 24 80 00       	push   $0x8024df
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 f5 14 00 00       	call   8015e2 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 e7 24 80 00       	push   $0x8024e7
  800102:	e8 79 16 00 00       	call   801780 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 08 0f 00 00       	call   801028 <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013e:	e8 73 0a 00 00       	call   800bb6 <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 cf 0e 00 00       	call   801053 <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 e7 09 00 00       	call   800b75 <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 10 0a 00 00       	call   800bb6 <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 04 25 80 00       	push   $0x802504
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 64 29 80 00 	movl   $0x802964,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 2f 09 00 00       	call   800b38 <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 54 01 00 00       	call   8003a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 d4 08 00 00       	call   800b38 <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a7:	39 d3                	cmp    %edx,%ebx
  8002a9:	72 05                	jb     8002b0 <printnum+0x30>
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 45                	ja     8002f5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 3c 1f 00 00       	call   802210 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 18                	jmp    8002ff <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	eb 03                	jmp    8002f8 <printnum+0x78>
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f e8                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 29 20 00 00       	call   802340 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 27 25 80 00 	movsbl 0x802527(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800332:	83 fa 01             	cmp    $0x1,%edx
  800335:	7e 0e                	jle    800345 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	8b 52 04             	mov    0x4(%edx),%edx
  800343:	eb 22                	jmp    800367 <getuint+0x38>
	else if (lflag)
  800345:	85 d2                	test   %edx,%edx
  800347:	74 10                	je     800359 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034e:	89 08                	mov    %ecx,(%eax)
  800350:	8b 02                	mov    (%edx),%eax
  800352:	ba 00 00 00 00       	mov    $0x0,%edx
  800357:	eb 0e                	jmp    800367 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800373:	8b 10                	mov    (%eax),%edx
  800375:	3b 50 04             	cmp    0x4(%eax),%edx
  800378:	73 0a                	jae    800384 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
  800382:	88 02                	mov    %al,(%edx)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	50                   	push   %eax
  800390:	ff 75 10             	pushl  0x10(%ebp)
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	e8 05 00 00 00       	call   8003a3 <vprintfmt>
	va_end(ap);
}
  80039e:	83 c4 10             	add    $0x10,%esp
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
  8003ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 89 03 00 00    	je     800748 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	50                   	push   %eax
  8003c4:	ff d6                	call   *%esi
  8003c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	83 c7 01             	add    $0x1,%edi
  8003cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d0:	83 f8 25             	cmp    $0x25,%eax
  8003d3:	75 e2                	jne    8003b7 <vprintfmt+0x14>
  8003d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	eb 07                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8d 47 01             	lea    0x1(%edi),%eax
  8003ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800402:	0f b6 07             	movzbl (%edi),%eax
  800405:	0f b6 c8             	movzbl %al,%ecx
  800408:	83 e8 23             	sub    $0x23,%eax
  80040b:	3c 55                	cmp    $0x55,%al
  80040d:	0f 87 1a 03 00 00    	ja     80072d <vprintfmt+0x38a>
  800413:	0f b6 c0             	movzbl %al,%eax
  800416:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800424:	eb d6                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	b8 00 00 00 00       	mov    $0x0,%eax
  80042e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800431:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800434:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800438:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043e:	83 fa 09             	cmp    $0x9,%edx
  800441:	77 39                	ja     80047c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800443:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800446:	eb e9                	jmp    800431 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 48 04             	lea    0x4(%eax),%ecx
  80044e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800451:	8b 00                	mov    (%eax),%eax
  800453:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800459:	eb 27                	jmp    800482 <vprintfmt+0xdf>
  80045b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045e:	85 c0                	test   %eax,%eax
  800460:	b9 00 00 00 00       	mov    $0x0,%ecx
  800465:	0f 49 c8             	cmovns %eax,%ecx
  800468:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	eb 8c                	jmp    8003fc <vprintfmt+0x59>
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800473:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047a:	eb 80                	jmp    8003fc <vprintfmt+0x59>
  80047c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80047f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800482:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800486:	0f 89 70 ff ff ff    	jns    8003fc <vprintfmt+0x59>
				width = precision, precision = -1;
  80048c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800492:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800499:	e9 5e ff ff ff       	jmp    8003fc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a4:	e9 53 ff ff ff       	jmp    8003fc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	ff 30                	pushl  (%eax)
  8004b8:	ff d6                	call   *%esi
			break;
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c0:	e9 04 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	99                   	cltd   
  8004d1:	31 d0                	xor    %edx,%eax
  8004d3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d5:	83 f8 0f             	cmp    $0xf,%eax
  8004d8:	7f 0b                	jg     8004e5 <vprintfmt+0x142>
  8004da:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	75 18                	jne    8004fd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	50                   	push   %eax
  8004e6:	68 3f 25 80 00       	push   $0x80253f
  8004eb:	53                   	push   %ebx
  8004ec:	56                   	push   %esi
  8004ed:	e8 94 fe ff ff       	call   800386 <printfmt>
  8004f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f8:	e9 cc fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fd:	52                   	push   %edx
  8004fe:	68 f9 28 80 00       	push   $0x8028f9
  800503:	53                   	push   %ebx
  800504:	56                   	push   %esi
  800505:	e8 7c fe ff ff       	call   800386 <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800510:	e9 b4 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 04             	lea    0x4(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800520:	85 ff                	test   %edi,%edi
  800522:	b8 38 25 80 00       	mov    $0x802538,%eax
  800527:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 8e 94 00 00 00    	jle    8005c8 <vprintfmt+0x225>
  800534:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800538:	0f 84 98 00 00 00    	je     8005d6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 d0             	pushl  -0x30(%ebp)
  800544:	57                   	push   %edi
  800545:	e8 86 02 00 00       	call   8007d0 <strnlen>
  80054a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054d:	29 c1                	sub    %eax,%ecx
  80054f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800555:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800559:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	eb 0f                	jmp    800572 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 75 e0             	pushl  -0x20(%ebp)
  80056a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	83 ef 01             	sub    $0x1,%edi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 ff                	test   %edi,%edi
  800574:	7f ed                	jg     800563 <vprintfmt+0x1c0>
  800576:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800579:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	b8 00 00 00 00       	mov    $0x0,%eax
  800583:	0f 49 c1             	cmovns %ecx,%eax
  800586:	29 c1                	sub    %eax,%ecx
  800588:	89 75 08             	mov    %esi,0x8(%ebp)
  80058b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800591:	89 cb                	mov    %ecx,%ebx
  800593:	eb 4d                	jmp    8005e2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800599:	74 1b                	je     8005b6 <vprintfmt+0x213>
  80059b:	0f be c0             	movsbl %al,%eax
  80059e:	83 e8 20             	sub    $0x20,%eax
  8005a1:	83 f8 5e             	cmp    $0x5e,%eax
  8005a4:	76 10                	jbe    8005b6 <vprintfmt+0x213>
					putch('?', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ac:	6a 3f                	push   $0x3f
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	eb 0d                	jmp    8005c3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	ff 75 0c             	pushl  0xc(%ebp)
  8005bc:	52                   	push   %edx
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c3:	83 eb 01             	sub    $0x1,%ebx
  8005c6:	eb 1a                	jmp    8005e2 <vprintfmt+0x23f>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	eb 0c                	jmp    8005e2 <vprintfmt+0x23f>
  8005d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e2:	83 c7 01             	add    $0x1,%edi
  8005e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e9:	0f be d0             	movsbl %al,%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	74 23                	je     800613 <vprintfmt+0x270>
  8005f0:	85 f6                	test   %esi,%esi
  8005f2:	78 a1                	js     800595 <vprintfmt+0x1f2>
  8005f4:	83 ee 01             	sub    $0x1,%esi
  8005f7:	79 9c                	jns    800595 <vprintfmt+0x1f2>
  8005f9:	89 df                	mov    %ebx,%edi
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800601:	eb 18                	jmp    80061b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 20                	push   $0x20
  800609:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb 08                	jmp    80061b <vprintfmt+0x278>
  800613:	89 df                	mov    %ebx,%edi
  800615:	8b 75 08             	mov    0x8(%ebp),%esi
  800618:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061b:	85 ff                	test   %edi,%edi
  80061d:	7f e4                	jg     800603 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800622:	e9 a2 fd ff ff       	jmp    8003c9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 fa 01             	cmp    $0x1,%edx
  80062a:	7e 16                	jle    800642 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	eb 32                	jmp    800674 <vprintfmt+0x2d1>
	else if (lflag)
  800642:	85 d2                	test   %edx,%edx
  800644:	74 18                	je     80065e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 c1                	mov    %eax,%ecx
  800656:	c1 f9 1f             	sar    $0x1f,%ecx
  800659:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065c:	eb 16                	jmp    800674 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	89 c1                	mov    %eax,%ecx
  80066e:	c1 f9 1f             	sar    $0x1f,%ecx
  800671:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800674:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800677:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80067f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800683:	79 74                	jns    8006f9 <vprintfmt+0x356>
				putch('-', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 2d                	push   $0x2d
  80068b:	ff d6                	call   *%esi
				num = -(long long) num;
  80068d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800690:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800693:	f7 d8                	neg    %eax
  800695:	83 d2 00             	adc    $0x0,%edx
  800698:	f7 da                	neg    %edx
  80069a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a2:	eb 55                	jmp    8006f9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a7:	e8 83 fc ff ff       	call   80032f <getuint>
			base = 10;
  8006ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b1:	eb 46                	jmp    8006f9 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 74 fc ff ff       	call   80032f <getuint>
			base = 8;
  8006bb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c0:	eb 37                	jmp    8006f9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 30                	push   $0x30
  8006c8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ca:	83 c4 08             	add    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 78                	push   $0x78
  8006d0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ea:	eb 0d                	jmp    8006f9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	e8 3b fc ff ff       	call   80032f <getuint>
			base = 16;
  8006f4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f9:	83 ec 0c             	sub    $0xc,%esp
  8006fc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800700:	57                   	push   %edi
  800701:	ff 75 e0             	pushl  -0x20(%ebp)
  800704:	51                   	push   %ecx
  800705:	52                   	push   %edx
  800706:	50                   	push   %eax
  800707:	89 da                	mov    %ebx,%edx
  800709:	89 f0                	mov    %esi,%eax
  80070b:	e8 70 fb ff ff       	call   800280 <printnum>
			break;
  800710:	83 c4 20             	add    $0x20,%esp
  800713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800716:	e9 ae fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	51                   	push   %ecx
  800720:	ff d6                	call   *%esi
			break;
  800722:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800728:	e9 9c fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	6a 25                	push   $0x25
  800733:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 03                	jmp    80073d <vprintfmt+0x39a>
  80073a:	83 ef 01             	sub    $0x1,%edi
  80073d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800741:	75 f7                	jne    80073a <vprintfmt+0x397>
  800743:	e9 81 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800763:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 26                	je     800797 <vsnprintf+0x47>
  800771:	85 d2                	test   %edx,%edx
  800773:	7e 22                	jle    800797 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800775:	ff 75 14             	pushl  0x14(%ebp)
  800778:	ff 75 10             	pushl  0x10(%ebp)
  80077b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	68 69 03 80 00       	push   $0x800369
  800784:	e8 1a fc ff ff       	call   8003a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800789:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 05                	jmp    80079c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a7:	50                   	push   %eax
  8007a8:	ff 75 10             	pushl  0x10(%ebp)
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	ff 75 08             	pushl  0x8(%ebp)
  8007b1:	e8 9a ff ff ff       	call   800750 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 03                	jmp    8007c8 <strlen+0x10>
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cc:	75 f7                	jne    8007c5 <strlen+0xd>
		n++;
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	eb 03                	jmp    8007e3 <strnlen+0x13>
		n++;
  8007e0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 c2                	cmp    %eax,%edx
  8007e5:	74 08                	je     8007ef <strnlen+0x1f>
  8007e7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007eb:	75 f3                	jne    8007e0 <strnlen+0x10>
  8007ed:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	83 c1 01             	add    $0x1,%ecx
  800803:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800807:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080a:	84 db                	test   %bl,%bl
  80080c:	75 ef                	jne    8007fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800818:	53                   	push   %ebx
  800819:	e8 9a ff ff ff       	call   8007b8 <strlen>
  80081e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800821:	ff 75 0c             	pushl  0xc(%ebp)
  800824:	01 d8                	add    %ebx,%eax
  800826:	50                   	push   %eax
  800827:	e8 c5 ff ff ff       	call   8007f1 <strcpy>
	return dst;
}
  80082c:	89 d8                	mov    %ebx,%eax
  80082e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 75 08             	mov    0x8(%ebp),%esi
  80083b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083e:	89 f3                	mov    %esi,%ebx
  800840:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800843:	89 f2                	mov    %esi,%edx
  800845:	eb 0f                	jmp    800856 <strncpy+0x23>
		*dst++ = *src;
  800847:	83 c2 01             	add    $0x1,%edx
  80084a:	0f b6 01             	movzbl (%ecx),%eax
  80084d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800850:	80 39 01             	cmpb   $0x1,(%ecx)
  800853:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800856:	39 da                	cmp    %ebx,%edx
  800858:	75 ed                	jne    800847 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 55 10             	mov    0x10(%ebp),%edx
  80086e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800870:	85 d2                	test   %edx,%edx
  800872:	74 21                	je     800895 <strlcpy+0x35>
  800874:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800878:	89 f2                	mov    %esi,%edx
  80087a:	eb 09                	jmp    800885 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	83 c1 01             	add    $0x1,%ecx
  800882:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800885:	39 c2                	cmp    %eax,%edx
  800887:	74 09                	je     800892 <strlcpy+0x32>
  800889:	0f b6 19             	movzbl (%ecx),%ebx
  80088c:	84 db                	test   %bl,%bl
  80088e:	75 ec                	jne    80087c <strlcpy+0x1c>
  800890:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800892:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800895:	29 f0                	sub    %esi,%eax
}
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a4:	eb 06                	jmp    8008ac <strcmp+0x11>
		p++, q++;
  8008a6:	83 c1 01             	add    $0x1,%ecx
  8008a9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ac:	0f b6 01             	movzbl (%ecx),%eax
  8008af:	84 c0                	test   %al,%al
  8008b1:	74 04                	je     8008b7 <strcmp+0x1c>
  8008b3:	3a 02                	cmp    (%edx),%al
  8008b5:	74 ef                	je     8008a6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 c0             	movzbl %al,%eax
  8008ba:	0f b6 12             	movzbl (%edx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 06                	jmp    8008d8 <strncmp+0x17>
		n--, p++, q++;
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d8:	39 d8                	cmp    %ebx,%eax
  8008da:	74 15                	je     8008f1 <strncmp+0x30>
  8008dc:	0f b6 08             	movzbl (%eax),%ecx
  8008df:	84 c9                	test   %cl,%cl
  8008e1:	74 04                	je     8008e7 <strncmp+0x26>
  8008e3:	3a 0a                	cmp    (%edx),%cl
  8008e5:	74 eb                	je     8008d2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 00             	movzbl (%eax),%eax
  8008ea:	0f b6 12             	movzbl (%edx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
  8008ef:	eb 05                	jmp    8008f6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	eb 07                	jmp    80090c <strchr+0x13>
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 0f                	je     800918 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	0f b6 10             	movzbl (%eax),%edx
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f2                	jne    800905 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	eb 03                	jmp    800929 <strfind+0xf>
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 04                	je     800934 <strfind+0x1a>
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f2                	jne    800926 <strfind+0xc>
			break;
	return (char *) s;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800942:	85 c9                	test   %ecx,%ecx
  800944:	74 36                	je     80097c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800946:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094c:	75 28                	jne    800976 <memset+0x40>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 23                	jne    800976 <memset+0x40>
		c &= 0xFF;
  800953:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800957:	89 d3                	mov    %edx,%ebx
  800959:	c1 e3 08             	shl    $0x8,%ebx
  80095c:	89 d6                	mov    %edx,%esi
  80095e:	c1 e6 18             	shl    $0x18,%esi
  800961:	89 d0                	mov    %edx,%eax
  800963:	c1 e0 10             	shl    $0x10,%eax
  800966:	09 f0                	or     %esi,%eax
  800968:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096a:	89 d8                	mov    %ebx,%eax
  80096c:	09 d0                	or     %edx,%eax
  80096e:	c1 e9 02             	shr    $0x2,%ecx
  800971:	fc                   	cld    
  800972:	f3 ab                	rep stos %eax,%es:(%edi)
  800974:	eb 06                	jmp    80097c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800976:	8b 45 0c             	mov    0xc(%ebp),%eax
  800979:	fc                   	cld    
  80097a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800991:	39 c6                	cmp    %eax,%esi
  800993:	73 35                	jae    8009ca <memmove+0x47>
  800995:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	73 2e                	jae    8009ca <memmove+0x47>
		s += n;
		d += n;
  80099c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	89 d6                	mov    %edx,%esi
  8009a1:	09 fe                	or     %edi,%esi
  8009a3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a9:	75 13                	jne    8009be <memmove+0x3b>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	75 0e                	jne    8009be <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b0:	83 ef 04             	sub    $0x4,%edi
  8009b3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
  8009b9:	fd                   	std    
  8009ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bc:	eb 09                	jmp    8009c7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009be:	83 ef 01             	sub    $0x1,%edi
  8009c1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c4:	fd                   	std    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c7:	fc                   	cld    
  8009c8:	eb 1d                	jmp    8009e7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	89 f2                	mov    %esi,%edx
  8009cc:	09 c2                	or     %eax,%edx
  8009ce:	f6 c2 03             	test   $0x3,%dl
  8009d1:	75 0f                	jne    8009e2 <memmove+0x5f>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 0a                	jne    8009e2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
  8009db:	89 c7                	mov    %eax,%edi
  8009dd:	fc                   	cld    
  8009de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e0:	eb 05                	jmp    8009e7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ee:	ff 75 10             	pushl  0x10(%ebp)
  8009f1:	ff 75 0c             	pushl  0xc(%ebp)
  8009f4:	ff 75 08             	pushl  0x8(%ebp)
  8009f7:	e8 87 ff ff ff       	call   800983 <memmove>
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a09:	89 c6                	mov    %eax,%esi
  800a0b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	eb 1a                	jmp    800a2a <memcmp+0x2c>
		if (*s1 != *s2)
  800a10:	0f b6 08             	movzbl (%eax),%ecx
  800a13:	0f b6 1a             	movzbl (%edx),%ebx
  800a16:	38 d9                	cmp    %bl,%cl
  800a18:	74 0a                	je     800a24 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1a:	0f b6 c1             	movzbl %cl,%eax
  800a1d:	0f b6 db             	movzbl %bl,%ebx
  800a20:	29 d8                	sub    %ebx,%eax
  800a22:	eb 0f                	jmp    800a33 <memcmp+0x35>
		s1++, s2++;
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	39 f0                	cmp    %esi,%eax
  800a2c:	75 e2                	jne    800a10 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a33:	5b                   	pop    %ebx
  800a34:	5e                   	pop    %esi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3e:	89 c1                	mov    %eax,%ecx
  800a40:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a43:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a47:	eb 0a                	jmp    800a53 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	0f b6 10             	movzbl (%eax),%edx
  800a4c:	39 da                	cmp    %ebx,%edx
  800a4e:	74 07                	je     800a57 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a50:	83 c0 01             	add    $0x1,%eax
  800a53:	39 c8                	cmp    %ecx,%eax
  800a55:	72 f2                	jb     800a49 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a66:	eb 03                	jmp    800a6b <strtol+0x11>
		s++;
  800a68:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6b:	0f b6 01             	movzbl (%ecx),%eax
  800a6e:	3c 20                	cmp    $0x20,%al
  800a70:	74 f6                	je     800a68 <strtol+0xe>
  800a72:	3c 09                	cmp    $0x9,%al
  800a74:	74 f2                	je     800a68 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a76:	3c 2b                	cmp    $0x2b,%al
  800a78:	75 0a                	jne    800a84 <strtol+0x2a>
		s++;
  800a7a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a82:	eb 11                	jmp    800a95 <strtol+0x3b>
  800a84:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a89:	3c 2d                	cmp    $0x2d,%al
  800a8b:	75 08                	jne    800a95 <strtol+0x3b>
		s++, neg = 1;
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9b:	75 15                	jne    800ab2 <strtol+0x58>
  800a9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa0:	75 10                	jne    800ab2 <strtol+0x58>
  800aa2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa6:	75 7c                	jne    800b24 <strtol+0xca>
		s += 2, base = 16;
  800aa8:	83 c1 02             	add    $0x2,%ecx
  800aab:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab0:	eb 16                	jmp    800ac8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab2:	85 db                	test   %ebx,%ebx
  800ab4:	75 12                	jne    800ac8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abb:	80 39 30             	cmpb   $0x30,(%ecx)
  800abe:	75 08                	jne    800ac8 <strtol+0x6e>
		s++, base = 8;
  800ac0:	83 c1 01             	add    $0x1,%ecx
  800ac3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad0:	0f b6 11             	movzbl (%ecx),%edx
  800ad3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad6:	89 f3                	mov    %esi,%ebx
  800ad8:	80 fb 09             	cmp    $0x9,%bl
  800adb:	77 08                	ja     800ae5 <strtol+0x8b>
			dig = *s - '0';
  800add:	0f be d2             	movsbl %dl,%edx
  800ae0:	83 ea 30             	sub    $0x30,%edx
  800ae3:	eb 22                	jmp    800b07 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae8:	89 f3                	mov    %esi,%ebx
  800aea:	80 fb 19             	cmp    $0x19,%bl
  800aed:	77 08                	ja     800af7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aef:	0f be d2             	movsbl %dl,%edx
  800af2:	83 ea 57             	sub    $0x57,%edx
  800af5:	eb 10                	jmp    800b07 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 19             	cmp    $0x19,%bl
  800aff:	77 16                	ja     800b17 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b07:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0a:	7d 0b                	jge    800b17 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0c:	83 c1 01             	add    $0x1,%ecx
  800b0f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b13:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b15:	eb b9                	jmp    800ad0 <strtol+0x76>

	if (endptr)
  800b17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1b:	74 0d                	je     800b2a <strtol+0xd0>
		*endptr = (char *) s;
  800b1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b20:	89 0e                	mov    %ecx,(%esi)
  800b22:	eb 06                	jmp    800b2a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	74 98                	je     800ac0 <strtol+0x66>
  800b28:	eb 9e                	jmp    800ac8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2a:	89 c2                	mov    %eax,%edx
  800b2c:	f7 da                	neg    %edx
  800b2e:	85 ff                	test   %edi,%edi
  800b30:	0f 45 c2             	cmovne %edx,%eax
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	89 c6                	mov    %eax,%esi
  800b4f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	b8 03 00 00 00       	mov    $0x3,%eax
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	89 cb                	mov    %ecx,%ebx
  800b8d:	89 cf                	mov    %ecx,%edi
  800b8f:	89 ce                	mov    %ecx,%esi
  800b91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7e 17                	jle    800bae <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	6a 03                	push   $0x3
  800b9d:	68 1f 28 80 00       	push   $0x80281f
  800ba2:	6a 23                	push   $0x23
  800ba4:	68 3c 28 80 00       	push   $0x80283c
  800ba9:	e8 e5 f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_yield>:

void
sys_yield(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be5:	89 d1                	mov    %edx,%ecx
  800be7:	89 d3                	mov    %edx,%ebx
  800be9:	89 d7                	mov    %edx,%edi
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfd:	be 00 00 00 00       	mov    $0x0,%esi
  800c02:	b8 04 00 00 00       	mov    $0x4,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	89 f7                	mov    %esi,%edi
  800c12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7e 17                	jle    800c2f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	50                   	push   %eax
  800c1c:	6a 04                	push   $0x4
  800c1e:	68 1f 28 80 00       	push   $0x80281f
  800c23:	6a 23                	push   $0x23
  800c25:	68 3c 28 80 00       	push   $0x80283c
  800c2a:	e8 64 f5 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	b8 05 00 00 00       	mov    $0x5,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 75 18             	mov    0x18(%ebp),%esi
  800c54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7e 17                	jle    800c71 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	50                   	push   %eax
  800c5e:	6a 05                	push   $0x5
  800c60:	68 1f 28 80 00       	push   $0x80281f
  800c65:	6a 23                	push   $0x23
  800c67:	68 3c 28 80 00       	push   $0x80283c
  800c6c:	e8 22 f5 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c87:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	89 df                	mov    %ebx,%edi
  800c94:	89 de                	mov    %ebx,%esi
  800c96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 17                	jle    800cb3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 06                	push   $0x6
  800ca2:	68 1f 28 80 00       	push   $0x80281f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 3c 28 80 00       	push   $0x80283c
  800cae:	e8 e0 f4 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	89 df                	mov    %ebx,%edi
  800cd6:	89 de                	mov    %ebx,%esi
  800cd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 17                	jle    800cf5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 08                	push   $0x8
  800ce4:	68 1f 28 80 00       	push   $0x80281f
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 3c 28 80 00       	push   $0x80283c
  800cf0:	e8 9e f4 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 17                	jle    800d37 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 09                	push   $0x9
  800d26:	68 1f 28 80 00       	push   $0x80281f
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 3c 28 80 00       	push   $0x80283c
  800d32:	e8 5c f4 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 17                	jle    800d79 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	50                   	push   %eax
  800d66:	6a 0a                	push   $0xa
  800d68:	68 1f 28 80 00       	push   $0x80281f
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 3c 28 80 00       	push   $0x80283c
  800d74:	e8 1a f4 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	be 00 00 00 00       	mov    $0x0,%esi
  800d8c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 cb                	mov    %ecx,%ebx
  800dbc:	89 cf                	mov    %ecx,%edi
  800dbe:	89 ce                	mov    %ecx,%esi
  800dc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 17                	jle    800ddd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	6a 0d                	push   $0xd
  800dcc:	68 1f 28 80 00       	push   $0x80281f
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 3c 28 80 00       	push   $0x80283c
  800dd8:	e8 b6 f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	89 d3                	mov    %edx,%ebx
  800df9:	89 d7                	mov    %edx,%edi
  800dfb:	89 d6                	mov    %edx,%esi
  800dfd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e12:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	89 df                	mov    %ebx,%edi
  800e1f:	89 de                	mov    %ebx,%esi
  800e21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e23:	85 c0                	test   %eax,%eax
  800e25:	7e 17                	jle    800e3e <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	50                   	push   %eax
  800e2b:	6a 0f                	push   $0xf
  800e2d:	68 1f 28 80 00       	push   $0x80281f
  800e32:	6a 23                	push   $0x23
  800e34:	68 3c 28 80 00       	push   $0x80283c
  800e39:	e8 55 f3 ff ff       	call   800193 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e54:	b8 10 00 00 00       	mov    $0x10,%eax
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	89 df                	mov    %ebx,%edi
  800e61:	89 de                	mov    %ebx,%esi
  800e63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 10                	push   $0x10
  800e6f:	68 1f 28 80 00       	push   $0x80281f
  800e74:	6a 23                	push   $0x23
  800e76:	68 3c 28 80 00       	push   $0x80283c
  800e7b:	e8 13 f3 ff ff       	call   800193 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	05 00 00 00 30       	add    $0x30000000,%eax
  800e93:	c1 e8 0c             	shr    $0xc,%eax
}
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9e:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	c1 ea 16             	shr    $0x16,%edx
  800ebf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec6:	f6 c2 01             	test   $0x1,%dl
  800ec9:	74 11                	je     800edc <fd_alloc+0x2d>
  800ecb:	89 c2                	mov    %eax,%edx
  800ecd:	c1 ea 0c             	shr    $0xc,%edx
  800ed0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed7:	f6 c2 01             	test   $0x1,%dl
  800eda:	75 09                	jne    800ee5 <fd_alloc+0x36>
			*fd_store = fd;
  800edc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	eb 17                	jmp    800efc <fd_alloc+0x4d>
  800ee5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eef:	75 c9                	jne    800eba <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ef7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f04:	83 f8 1f             	cmp    $0x1f,%eax
  800f07:	77 36                	ja     800f3f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f09:	c1 e0 0c             	shl    $0xc,%eax
  800f0c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f11:	89 c2                	mov    %eax,%edx
  800f13:	c1 ea 16             	shr    $0x16,%edx
  800f16:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1d:	f6 c2 01             	test   $0x1,%dl
  800f20:	74 24                	je     800f46 <fd_lookup+0x48>
  800f22:	89 c2                	mov    %eax,%edx
  800f24:	c1 ea 0c             	shr    $0xc,%edx
  800f27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2e:	f6 c2 01             	test   $0x1,%dl
  800f31:	74 1a                	je     800f4d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f36:	89 02                	mov    %eax,(%edx)
	return 0;
  800f38:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3d:	eb 13                	jmp    800f52 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f44:	eb 0c                	jmp    800f52 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4b:	eb 05                	jmp    800f52 <fd_lookup+0x54>
  800f4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 08             	sub    $0x8,%esp
  800f5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5d:	ba cc 28 80 00       	mov    $0x8028cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f62:	eb 13                	jmp    800f77 <dev_lookup+0x23>
  800f64:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f67:	39 08                	cmp    %ecx,(%eax)
  800f69:	75 0c                	jne    800f77 <dev_lookup+0x23>
			*dev = devtab[i];
  800f6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f70:	b8 00 00 00 00       	mov    $0x0,%eax
  800f75:	eb 2e                	jmp    800fa5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f77:	8b 02                	mov    (%edx),%eax
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	75 e7                	jne    800f64 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f7d:	a1 20 60 80 00       	mov    0x806020,%eax
  800f82:	8b 40 48             	mov    0x48(%eax),%eax
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	51                   	push   %ecx
  800f89:	50                   	push   %eax
  800f8a:	68 4c 28 80 00       	push   $0x80284c
  800f8f:	e8 d8 f2 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f97:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	83 ec 10             	sub    $0x10,%esp
  800faf:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb8:	50                   	push   %eax
  800fb9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fbf:	c1 e8 0c             	shr    $0xc,%eax
  800fc2:	50                   	push   %eax
  800fc3:	e8 36 ff ff ff       	call   800efe <fd_lookup>
  800fc8:	83 c4 08             	add    $0x8,%esp
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	78 05                	js     800fd4 <fd_close+0x2d>
	    || fd != fd2)
  800fcf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd2:	74 0c                	je     800fe0 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fd4:	84 db                	test   %bl,%bl
  800fd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdb:	0f 44 c2             	cmove  %edx,%eax
  800fde:	eb 41                	jmp    801021 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	ff 36                	pushl  (%esi)
  800fe9:	e8 66 ff ff ff       	call   800f54 <dev_lookup>
  800fee:	89 c3                	mov    %eax,%ebx
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 1a                	js     801011 <fd_close+0x6a>
		if (dev->dev_close)
  800ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffa:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ffd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801002:	85 c0                	test   %eax,%eax
  801004:	74 0b                	je     801011 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	56                   	push   %esi
  80100a:	ff d0                	call   *%eax
  80100c:	89 c3                	mov    %eax,%ebx
  80100e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801011:	83 ec 08             	sub    $0x8,%esp
  801014:	56                   	push   %esi
  801015:	6a 00                	push   $0x0
  801017:	e8 5d fc ff ff       	call   800c79 <sys_page_unmap>
	return r;
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	89 d8                	mov    %ebx,%eax
}
  801021:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80102e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801031:	50                   	push   %eax
  801032:	ff 75 08             	pushl  0x8(%ebp)
  801035:	e8 c4 fe ff ff       	call   800efe <fd_lookup>
  80103a:	83 c4 08             	add    $0x8,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 10                	js     801051 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	6a 01                	push   $0x1
  801046:	ff 75 f4             	pushl  -0xc(%ebp)
  801049:	e8 59 ff ff ff       	call   800fa7 <fd_close>
  80104e:	83 c4 10             	add    $0x10,%esp
}
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <close_all>:

void
close_all(void)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	53                   	push   %ebx
  801063:	e8 c0 ff ff ff       	call   801028 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801068:	83 c3 01             	add    $0x1,%ebx
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	83 fb 20             	cmp    $0x20,%ebx
  801071:	75 ec                	jne    80105f <close_all+0xc>
		close(i);
}
  801073:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 2c             	sub    $0x2c,%esp
  801081:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801084:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801087:	50                   	push   %eax
  801088:	ff 75 08             	pushl  0x8(%ebp)
  80108b:	e8 6e fe ff ff       	call   800efe <fd_lookup>
  801090:	83 c4 08             	add    $0x8,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	0f 88 c1 00 00 00    	js     80115c <dup+0xe4>
		return r;
	close(newfdnum);
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	56                   	push   %esi
  80109f:	e8 84 ff ff ff       	call   801028 <close>

	newfd = INDEX2FD(newfdnum);
  8010a4:	89 f3                	mov    %esi,%ebx
  8010a6:	c1 e3 0c             	shl    $0xc,%ebx
  8010a9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010af:	83 c4 04             	add    $0x4,%esp
  8010b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b5:	e8 de fd ff ff       	call   800e98 <fd2data>
  8010ba:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010bc:	89 1c 24             	mov    %ebx,(%esp)
  8010bf:	e8 d4 fd ff ff       	call   800e98 <fd2data>
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ca:	89 f8                	mov    %edi,%eax
  8010cc:	c1 e8 16             	shr    $0x16,%eax
  8010cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d6:	a8 01                	test   $0x1,%al
  8010d8:	74 37                	je     801111 <dup+0x99>
  8010da:	89 f8                	mov    %edi,%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
  8010df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e6:	f6 c2 01             	test   $0x1,%dl
  8010e9:	74 26                	je     801111 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fa:	50                   	push   %eax
  8010fb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010fe:	6a 00                	push   $0x0
  801100:	57                   	push   %edi
  801101:	6a 00                	push   $0x0
  801103:	e8 2f fb ff ff       	call   800c37 <sys_page_map>
  801108:	89 c7                	mov    %eax,%edi
  80110a:	83 c4 20             	add    $0x20,%esp
  80110d:	85 c0                	test   %eax,%eax
  80110f:	78 2e                	js     80113f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801111:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801114:	89 d0                	mov    %edx,%eax
  801116:	c1 e8 0c             	shr    $0xc,%eax
  801119:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	25 07 0e 00 00       	and    $0xe07,%eax
  801128:	50                   	push   %eax
  801129:	53                   	push   %ebx
  80112a:	6a 00                	push   $0x0
  80112c:	52                   	push   %edx
  80112d:	6a 00                	push   $0x0
  80112f:	e8 03 fb ff ff       	call   800c37 <sys_page_map>
  801134:	89 c7                	mov    %eax,%edi
  801136:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801139:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113b:	85 ff                	test   %edi,%edi
  80113d:	79 1d                	jns    80115c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	53                   	push   %ebx
  801143:	6a 00                	push   $0x0
  801145:	e8 2f fb ff ff       	call   800c79 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114a:	83 c4 08             	add    $0x8,%esp
  80114d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801150:	6a 00                	push   $0x0
  801152:	e8 22 fb ff ff       	call   800c79 <sys_page_unmap>
	return r;
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	89 f8                	mov    %edi,%eax
}
  80115c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	53                   	push   %ebx
  801168:	83 ec 14             	sub    $0x14,%esp
  80116b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801171:	50                   	push   %eax
  801172:	53                   	push   %ebx
  801173:	e8 86 fd ff ff       	call   800efe <fd_lookup>
  801178:	83 c4 08             	add    $0x8,%esp
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 6d                	js     8011ee <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801187:	50                   	push   %eax
  801188:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118b:	ff 30                	pushl  (%eax)
  80118d:	e8 c2 fd ff ff       	call   800f54 <dev_lookup>
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 4c                	js     8011e5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801199:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119c:	8b 42 08             	mov    0x8(%edx),%eax
  80119f:	83 e0 03             	and    $0x3,%eax
  8011a2:	83 f8 01             	cmp    $0x1,%eax
  8011a5:	75 21                	jne    8011c8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a7:	a1 20 60 80 00       	mov    0x806020,%eax
  8011ac:	8b 40 48             	mov    0x48(%eax),%eax
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	53                   	push   %ebx
  8011b3:	50                   	push   %eax
  8011b4:	68 90 28 80 00       	push   $0x802890
  8011b9:	e8 ae f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c6:	eb 26                	jmp    8011ee <read+0x8a>
	}
	if (!dev->dev_read)
  8011c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cb:	8b 40 08             	mov    0x8(%eax),%eax
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	74 17                	je     8011e9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	ff 75 10             	pushl  0x10(%ebp)
  8011d8:	ff 75 0c             	pushl  0xc(%ebp)
  8011db:	52                   	push   %edx
  8011dc:	ff d0                	call   *%eax
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	eb 09                	jmp    8011ee <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	eb 05                	jmp    8011ee <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011ee:	89 d0                	mov    %edx,%eax
  8011f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f3:	c9                   	leave  
  8011f4:	c3                   	ret    

008011f5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	57                   	push   %edi
  8011f9:	56                   	push   %esi
  8011fa:	53                   	push   %ebx
  8011fb:	83 ec 0c             	sub    $0xc,%esp
  8011fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801201:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801204:	bb 00 00 00 00       	mov    $0x0,%ebx
  801209:	eb 21                	jmp    80122c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	89 f0                	mov    %esi,%eax
  801210:	29 d8                	sub    %ebx,%eax
  801212:	50                   	push   %eax
  801213:	89 d8                	mov    %ebx,%eax
  801215:	03 45 0c             	add    0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	57                   	push   %edi
  80121a:	e8 45 ff ff ff       	call   801164 <read>
		if (m < 0)
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 10                	js     801236 <readn+0x41>
			return m;
		if (m == 0)
  801226:	85 c0                	test   %eax,%eax
  801228:	74 0a                	je     801234 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122a:	01 c3                	add    %eax,%ebx
  80122c:	39 f3                	cmp    %esi,%ebx
  80122e:	72 db                	jb     80120b <readn+0x16>
  801230:	89 d8                	mov    %ebx,%eax
  801232:	eb 02                	jmp    801236 <readn+0x41>
  801234:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801236:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801239:	5b                   	pop    %ebx
  80123a:	5e                   	pop    %esi
  80123b:	5f                   	pop    %edi
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	53                   	push   %ebx
  801242:	83 ec 14             	sub    $0x14,%esp
  801245:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801248:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	53                   	push   %ebx
  80124d:	e8 ac fc ff ff       	call   800efe <fd_lookup>
  801252:	83 c4 08             	add    $0x8,%esp
  801255:	89 c2                	mov    %eax,%edx
  801257:	85 c0                	test   %eax,%eax
  801259:	78 68                	js     8012c3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125b:	83 ec 08             	sub    $0x8,%esp
  80125e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801261:	50                   	push   %eax
  801262:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801265:	ff 30                	pushl  (%eax)
  801267:	e8 e8 fc ff ff       	call   800f54 <dev_lookup>
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 47                	js     8012ba <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801273:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801276:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127a:	75 21                	jne    80129d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80127c:	a1 20 60 80 00       	mov    0x806020,%eax
  801281:	8b 40 48             	mov    0x48(%eax),%eax
  801284:	83 ec 04             	sub    $0x4,%esp
  801287:	53                   	push   %ebx
  801288:	50                   	push   %eax
  801289:	68 ac 28 80 00       	push   $0x8028ac
  80128e:	e8 d9 ef ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129b:	eb 26                	jmp    8012c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80129d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a0:	8b 52 0c             	mov    0xc(%edx),%edx
  8012a3:	85 d2                	test   %edx,%edx
  8012a5:	74 17                	je     8012be <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012a7:	83 ec 04             	sub    $0x4,%esp
  8012aa:	ff 75 10             	pushl  0x10(%ebp)
  8012ad:	ff 75 0c             	pushl  0xc(%ebp)
  8012b0:	50                   	push   %eax
  8012b1:	ff d2                	call   *%edx
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	eb 09                	jmp    8012c3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	eb 05                	jmp    8012c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012c3:	89 d0                	mov    %edx,%eax
  8012c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d3:	50                   	push   %eax
  8012d4:	ff 75 08             	pushl  0x8(%ebp)
  8012d7:	e8 22 fc ff ff       	call   800efe <fd_lookup>
  8012dc:	83 c4 08             	add    $0x8,%esp
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 0e                	js     8012f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 14             	sub    $0x14,%esp
  8012fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	53                   	push   %ebx
  801302:	e8 f7 fb ff ff       	call   800efe <fd_lookup>
  801307:	83 c4 08             	add    $0x8,%esp
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 65                	js     801375 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801316:	50                   	push   %eax
  801317:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131a:	ff 30                	pushl  (%eax)
  80131c:	e8 33 fc ff ff       	call   800f54 <dev_lookup>
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 44                	js     80136c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801328:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80132f:	75 21                	jne    801352 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801331:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801336:	8b 40 48             	mov    0x48(%eax),%eax
  801339:	83 ec 04             	sub    $0x4,%esp
  80133c:	53                   	push   %ebx
  80133d:	50                   	push   %eax
  80133e:	68 6c 28 80 00       	push   $0x80286c
  801343:	e8 24 ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801350:	eb 23                	jmp    801375 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801352:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801355:	8b 52 18             	mov    0x18(%edx),%edx
  801358:	85 d2                	test   %edx,%edx
  80135a:	74 14                	je     801370 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	ff 75 0c             	pushl  0xc(%ebp)
  801362:	50                   	push   %eax
  801363:	ff d2                	call   *%edx
  801365:	89 c2                	mov    %eax,%edx
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	eb 09                	jmp    801375 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	eb 05                	jmp    801375 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801370:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801375:	89 d0                	mov    %edx,%eax
  801377:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	53                   	push   %ebx
  801380:	83 ec 14             	sub    $0x14,%esp
  801383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801386:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	ff 75 08             	pushl  0x8(%ebp)
  80138d:	e8 6c fb ff ff       	call   800efe <fd_lookup>
  801392:	83 c4 08             	add    $0x8,%esp
  801395:	89 c2                	mov    %eax,%edx
  801397:	85 c0                	test   %eax,%eax
  801399:	78 58                	js     8013f3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a5:	ff 30                	pushl  (%eax)
  8013a7:	e8 a8 fb ff ff       	call   800f54 <dev_lookup>
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 37                	js     8013ea <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ba:	74 32                	je     8013ee <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013bc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013bf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c6:	00 00 00 
	stat->st_isdir = 0;
  8013c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d0:	00 00 00 
	stat->st_dev = dev;
  8013d3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e0:	ff 50 14             	call   *0x14(%eax)
  8013e3:	89 c2                	mov    %eax,%edx
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	eb 09                	jmp    8013f3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	eb 05                	jmp    8013f3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f3:	89 d0                	mov    %edx,%eax
  8013f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	6a 00                	push   $0x0
  801404:	ff 75 08             	pushl  0x8(%ebp)
  801407:	e8 d6 01 00 00       	call   8015e2 <open>
  80140c:	89 c3                	mov    %eax,%ebx
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	78 1b                	js     801430 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	ff 75 0c             	pushl  0xc(%ebp)
  80141b:	50                   	push   %eax
  80141c:	e8 5b ff ff ff       	call   80137c <fstat>
  801421:	89 c6                	mov    %eax,%esi
	close(fd);
  801423:	89 1c 24             	mov    %ebx,(%esp)
  801426:	e8 fd fb ff ff       	call   801028 <close>
	return r;
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	89 f0                	mov    %esi,%eax
}
  801430:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801433:	5b                   	pop    %ebx
  801434:	5e                   	pop    %esi
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    

00801437 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	56                   	push   %esi
  80143b:	53                   	push   %ebx
  80143c:	89 c6                	mov    %eax,%esi
  80143e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801440:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801447:	75 12                	jne    80145b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801449:	83 ec 0c             	sub    $0xc,%esp
  80144c:	6a 01                	push   $0x1
  80144e:	e8 44 0d 00 00       	call   802197 <ipc_find_env>
  801453:	a3 00 40 80 00       	mov    %eax,0x804000
  801458:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80145b:	6a 07                	push   $0x7
  80145d:	68 00 70 80 00       	push   $0x807000
  801462:	56                   	push   %esi
  801463:	ff 35 00 40 80 00    	pushl  0x804000
  801469:	e8 d5 0c 00 00       	call   802143 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80146e:	83 c4 0c             	add    $0xc,%esp
  801471:	6a 00                	push   $0x0
  801473:	53                   	push   %ebx
  801474:	6a 00                	push   $0x0
  801476:	e8 61 0c 00 00       	call   8020dc <ipc_recv>
}
  80147b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801488:	8b 45 08             	mov    0x8(%ebp),%eax
  80148b:	8b 40 0c             	mov    0xc(%eax),%eax
  80148e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801493:	8b 45 0c             	mov    0xc(%ebp),%eax
  801496:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80149b:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a5:	e8 8d ff ff ff       	call   801437 <fsipc>
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b8:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8014bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c7:	e8 6b ff ff ff       	call   801437 <fsipc>
}
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	8b 40 0c             	mov    0xc(%eax),%eax
  8014de:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ed:	e8 45 ff ff ff       	call   801437 <fsipc>
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 2c                	js     801522 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	68 00 70 80 00       	push   $0x807000
  8014fe:	53                   	push   %ebx
  8014ff:	e8 ed f2 ff ff       	call   8007f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801504:	a1 80 70 80 00       	mov    0x807080,%eax
  801509:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80150f:	a1 84 70 80 00       	mov    0x807084,%eax
  801514:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801530:	8b 55 08             	mov    0x8(%ebp),%edx
  801533:	8b 52 0c             	mov    0xc(%edx),%edx
  801536:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  80153c:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801541:	50                   	push   %eax
  801542:	ff 75 0c             	pushl  0xc(%ebp)
  801545:	68 08 70 80 00       	push   $0x807008
  80154a:	e8 34 f4 ff ff       	call   800983 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 04 00 00 00       	mov    $0x4,%eax
  801559:	e8 d9 fe ff ff       	call   801437 <fsipc>

}
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	56                   	push   %esi
  801564:	53                   	push   %ebx
  801565:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801568:	8b 45 08             	mov    0x8(%ebp),%eax
  80156b:	8b 40 0c             	mov    0xc(%eax),%eax
  80156e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801573:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801579:	ba 00 00 00 00       	mov    $0x0,%edx
  80157e:	b8 03 00 00 00       	mov    $0x3,%eax
  801583:	e8 af fe ff ff       	call   801437 <fsipc>
  801588:	89 c3                	mov    %eax,%ebx
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 4b                	js     8015d9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80158e:	39 c6                	cmp    %eax,%esi
  801590:	73 16                	jae    8015a8 <devfile_read+0x48>
  801592:	68 e0 28 80 00       	push   $0x8028e0
  801597:	68 e7 28 80 00       	push   $0x8028e7
  80159c:	6a 7c                	push   $0x7c
  80159e:	68 fc 28 80 00       	push   $0x8028fc
  8015a3:	e8 eb eb ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  8015a8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015ad:	7e 16                	jle    8015c5 <devfile_read+0x65>
  8015af:	68 07 29 80 00       	push   $0x802907
  8015b4:	68 e7 28 80 00       	push   $0x8028e7
  8015b9:	6a 7d                	push   $0x7d
  8015bb:	68 fc 28 80 00       	push   $0x8028fc
  8015c0:	e8 ce eb ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	50                   	push   %eax
  8015c9:	68 00 70 80 00       	push   $0x807000
  8015ce:	ff 75 0c             	pushl  0xc(%ebp)
  8015d1:	e8 ad f3 ff ff       	call   800983 <memmove>
	return r;
  8015d6:	83 c4 10             	add    $0x10,%esp
}
  8015d9:	89 d8                	mov    %ebx,%eax
  8015db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015de:	5b                   	pop    %ebx
  8015df:	5e                   	pop    %esi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 20             	sub    $0x20,%esp
  8015e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ec:	53                   	push   %ebx
  8015ed:	e8 c6 f1 ff ff       	call   8007b8 <strlen>
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015fa:	7f 67                	jg     801663 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015fc:	83 ec 0c             	sub    $0xc,%esp
  8015ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	e8 a7 f8 ff ff       	call   800eaf <fd_alloc>
  801608:	83 c4 10             	add    $0x10,%esp
		return r;
  80160b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 57                	js     801668 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	53                   	push   %ebx
  801615:	68 00 70 80 00       	push   $0x807000
  80161a:	e8 d2 f1 ff ff       	call   8007f1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80161f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801622:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801627:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162a:	b8 01 00 00 00       	mov    $0x1,%eax
  80162f:	e8 03 fe ff ff       	call   801437 <fsipc>
  801634:	89 c3                	mov    %eax,%ebx
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	79 14                	jns    801651 <open+0x6f>
		fd_close(fd, 0);
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	6a 00                	push   $0x0
  801642:	ff 75 f4             	pushl  -0xc(%ebp)
  801645:	e8 5d f9 ff ff       	call   800fa7 <fd_close>
		return r;
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	89 da                	mov    %ebx,%edx
  80164f:	eb 17                	jmp    801668 <open+0x86>
	}

	return fd2num(fd);
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	ff 75 f4             	pushl  -0xc(%ebp)
  801657:	e8 2c f8 ff ff       	call   800e88 <fd2num>
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	eb 05                	jmp    801668 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801663:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801668:	89 d0                	mov    %edx,%eax
  80166a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801675:	ba 00 00 00 00       	mov    $0x0,%edx
  80167a:	b8 08 00 00 00       	mov    $0x8,%eax
  80167f:	e8 b3 fd ff ff       	call   801437 <fsipc>
}
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801686:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80168a:	7e 37                	jle    8016c3 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	53                   	push   %ebx
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801695:	ff 70 04             	pushl  0x4(%eax)
  801698:	8d 40 10             	lea    0x10(%eax),%eax
  80169b:	50                   	push   %eax
  80169c:	ff 33                	pushl  (%ebx)
  80169e:	e8 9b fb ff ff       	call   80123e <write>
		if (result > 0)
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	7e 03                	jle    8016ad <writebuf+0x27>
			b->result += result;
  8016aa:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016ad:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016b0:	74 0d                	je     8016bf <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	0f 4f c2             	cmovg  %edx,%eax
  8016bc:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c2:	c9                   	leave  
  8016c3:	f3 c3                	repz ret 

008016c5 <putch>:

static void
putch(int ch, void *thunk)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 04             	sub    $0x4,%esp
  8016cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016cf:	8b 53 04             	mov    0x4(%ebx),%edx
  8016d2:	8d 42 01             	lea    0x1(%edx),%eax
  8016d5:	89 43 04             	mov    %eax,0x4(%ebx)
  8016d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016db:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016df:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016e4:	75 0e                	jne    8016f4 <putch+0x2f>
		writebuf(b);
  8016e6:	89 d8                	mov    %ebx,%eax
  8016e8:	e8 99 ff ff ff       	call   801686 <writebuf>
		b->idx = 0;
  8016ed:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016f4:	83 c4 04             	add    $0x4,%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80170c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801713:	00 00 00 
	b.result = 0;
  801716:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80171d:	00 00 00 
	b.error = 1;
  801720:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801727:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80172a:	ff 75 10             	pushl  0x10(%ebp)
  80172d:	ff 75 0c             	pushl  0xc(%ebp)
  801730:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	68 c5 16 80 00       	push   $0x8016c5
  80173c:	e8 62 ec ff ff       	call   8003a3 <vprintfmt>
	if (b.idx > 0)
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80174b:	7e 0b                	jle    801758 <vfprintf+0x5e>
		writebuf(&b);
  80174d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801753:	e8 2e ff ff ff       	call   801686 <writebuf>

	return (b.result ? b.result : b.error);
  801758:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80175e:	85 c0                	test   %eax,%eax
  801760:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80176f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801772:	50                   	push   %eax
  801773:	ff 75 0c             	pushl  0xc(%ebp)
  801776:	ff 75 08             	pushl  0x8(%ebp)
  801779:	e8 7c ff ff ff       	call   8016fa <vfprintf>
	va_end(ap);

	return cnt;
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <printf>:

int
printf(const char *fmt, ...)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801786:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801789:	50                   	push   %eax
  80178a:	ff 75 08             	pushl  0x8(%ebp)
  80178d:	6a 01                	push   $0x1
  80178f:	e8 66 ff ff ff       	call   8016fa <vfprintf>
	va_end(ap);

	return cnt;
}
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80179c:	68 13 29 80 00       	push   $0x802913
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	e8 48 f0 ff ff       	call   8007f1 <strcpy>
	return 0;
}
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	53                   	push   %ebx
  8017b4:	83 ec 10             	sub    $0x10,%esp
  8017b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8017ba:	53                   	push   %ebx
  8017bb:	e8 10 0a 00 00       	call   8021d0 <pageref>
  8017c0:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8017c8:	83 f8 01             	cmp    $0x1,%eax
  8017cb:	75 10                	jne    8017dd <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8017cd:	83 ec 0c             	sub    $0xc,%esp
  8017d0:	ff 73 0c             	pushl  0xc(%ebx)
  8017d3:	e8 c0 02 00 00       	call   801a98 <nsipc_close>
  8017d8:	89 c2                	mov    %eax,%edx
  8017da:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8017dd:	89 d0                	mov    %edx,%eax
  8017df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017ea:	6a 00                	push   $0x0
  8017ec:	ff 75 10             	pushl  0x10(%ebp)
  8017ef:	ff 75 0c             	pushl  0xc(%ebp)
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	ff 70 0c             	pushl  0xc(%eax)
  8017f8:	e8 78 03 00 00       	call   801b75 <nsipc_send>
}
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801805:	6a 00                	push   $0x0
  801807:	ff 75 10             	pushl  0x10(%ebp)
  80180a:	ff 75 0c             	pushl  0xc(%ebp)
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	ff 70 0c             	pushl  0xc(%eax)
  801813:	e8 f1 02 00 00       	call   801b09 <nsipc_recv>
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801820:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801823:	52                   	push   %edx
  801824:	50                   	push   %eax
  801825:	e8 d4 f6 ff ff       	call   800efe <fd_lookup>
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 17                	js     801848 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801831:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801834:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80183a:	39 08                	cmp    %ecx,(%eax)
  80183c:	75 05                	jne    801843 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80183e:	8b 40 0c             	mov    0xc(%eax),%eax
  801841:	eb 05                	jmp    801848 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801843:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
  80184f:	83 ec 1c             	sub    $0x1c,%esp
  801852:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801854:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801857:	50                   	push   %eax
  801858:	e8 52 f6 ff ff       	call   800eaf <fd_alloc>
  80185d:	89 c3                	mov    %eax,%ebx
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	78 1b                	js     801881 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801866:	83 ec 04             	sub    $0x4,%esp
  801869:	68 07 04 00 00       	push   $0x407
  80186e:	ff 75 f4             	pushl  -0xc(%ebp)
  801871:	6a 00                	push   $0x0
  801873:	e8 7c f3 ff ff       	call   800bf4 <sys_page_alloc>
  801878:	89 c3                	mov    %eax,%ebx
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	85 c0                	test   %eax,%eax
  80187f:	79 10                	jns    801891 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801881:	83 ec 0c             	sub    $0xc,%esp
  801884:	56                   	push   %esi
  801885:	e8 0e 02 00 00       	call   801a98 <nsipc_close>
		return r;
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	89 d8                	mov    %ebx,%eax
  80188f:	eb 24                	jmp    8018b5 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801891:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801897:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80189c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8018a6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	50                   	push   %eax
  8018ad:	e8 d6 f5 ff ff       	call   800e88 <fd2num>
  8018b2:	83 c4 10             	add    $0x10,%esp
}
  8018b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5e                   	pop    %esi
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	e8 50 ff ff ff       	call   80181a <fd2sockid>
		return r;
  8018ca:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 1f                	js     8018ef <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018d0:	83 ec 04             	sub    $0x4,%esp
  8018d3:	ff 75 10             	pushl  0x10(%ebp)
  8018d6:	ff 75 0c             	pushl  0xc(%ebp)
  8018d9:	50                   	push   %eax
  8018da:	e8 12 01 00 00       	call   8019f1 <nsipc_accept>
  8018df:	83 c4 10             	add    $0x10,%esp
		return r;
  8018e2:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 07                	js     8018ef <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8018e8:	e8 5d ff ff ff       	call   80184a <alloc_sockfd>
  8018ed:	89 c1                	mov    %eax,%ecx
}
  8018ef:	89 c8                	mov    %ecx,%eax
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fc:	e8 19 ff ff ff       	call   80181a <fd2sockid>
  801901:	85 c0                	test   %eax,%eax
  801903:	78 12                	js     801917 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801905:	83 ec 04             	sub    $0x4,%esp
  801908:	ff 75 10             	pushl  0x10(%ebp)
  80190b:	ff 75 0c             	pushl  0xc(%ebp)
  80190e:	50                   	push   %eax
  80190f:	e8 2d 01 00 00       	call   801a41 <nsipc_bind>
  801914:	83 c4 10             	add    $0x10,%esp
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <shutdown>:

int
shutdown(int s, int how)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80191f:	8b 45 08             	mov    0x8(%ebp),%eax
  801922:	e8 f3 fe ff ff       	call   80181a <fd2sockid>
  801927:	85 c0                	test   %eax,%eax
  801929:	78 0f                	js     80193a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	ff 75 0c             	pushl  0xc(%ebp)
  801931:	50                   	push   %eax
  801932:	e8 3f 01 00 00       	call   801a76 <nsipc_shutdown>
  801937:	83 c4 10             	add    $0x10,%esp
}
  80193a:	c9                   	leave  
  80193b:	c3                   	ret    

0080193c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	e8 d0 fe ff ff       	call   80181a <fd2sockid>
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 12                	js     801960 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	ff 75 10             	pushl  0x10(%ebp)
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	50                   	push   %eax
  801958:	e8 55 01 00 00       	call   801ab2 <nsipc_connect>
  80195d:	83 c4 10             	add    $0x10,%esp
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <listen>:

int
listen(int s, int backlog)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	e8 aa fe ff ff       	call   80181a <fd2sockid>
  801970:	85 c0                	test   %eax,%eax
  801972:	78 0f                	js     801983 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	ff 75 0c             	pushl  0xc(%ebp)
  80197a:	50                   	push   %eax
  80197b:	e8 67 01 00 00       	call   801ae7 <nsipc_listen>
  801980:	83 c4 10             	add    $0x10,%esp
}
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80198b:	ff 75 10             	pushl  0x10(%ebp)
  80198e:	ff 75 0c             	pushl  0xc(%ebp)
  801991:	ff 75 08             	pushl  0x8(%ebp)
  801994:	e8 3a 02 00 00       	call   801bd3 <nsipc_socket>
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 05                	js     8019a5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8019a0:	e8 a5 fe ff ff       	call   80184a <alloc_sockfd>
}
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 04             	sub    $0x4,%esp
  8019ae:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019b0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019b7:	75 12                	jne    8019cb <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	6a 02                	push   $0x2
  8019be:	e8 d4 07 00 00       	call   802197 <ipc_find_env>
  8019c3:	a3 04 40 80 00       	mov    %eax,0x804004
  8019c8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019cb:	6a 07                	push   $0x7
  8019cd:	68 00 80 80 00       	push   $0x808000
  8019d2:	53                   	push   %ebx
  8019d3:	ff 35 04 40 80 00    	pushl  0x804004
  8019d9:	e8 65 07 00 00       	call   802143 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019de:	83 c4 0c             	add    $0xc,%esp
  8019e1:	6a 00                	push   $0x0
  8019e3:	6a 00                	push   $0x0
  8019e5:	6a 00                	push   $0x0
  8019e7:	e8 f0 06 00 00       	call   8020dc <ipc_recv>
}
  8019ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ef:	c9                   	leave  
  8019f0:	c3                   	ret    

008019f1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a01:	8b 06                	mov    (%esi),%eax
  801a03:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a08:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0d:	e8 95 ff ff ff       	call   8019a7 <nsipc>
  801a12:	89 c3                	mov    %eax,%ebx
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 20                	js     801a38 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a18:	83 ec 04             	sub    $0x4,%esp
  801a1b:	ff 35 10 80 80 00    	pushl  0x808010
  801a21:	68 00 80 80 00       	push   $0x808000
  801a26:	ff 75 0c             	pushl  0xc(%ebp)
  801a29:	e8 55 ef ff ff       	call   800983 <memmove>
		*addrlen = ret->ret_addrlen;
  801a2e:	a1 10 80 80 00       	mov    0x808010,%eax
  801a33:	89 06                	mov    %eax,(%esi)
  801a35:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801a38:	89 d8                	mov    %ebx,%eax
  801a3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5e                   	pop    %esi
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	53                   	push   %ebx
  801a45:	83 ec 08             	sub    $0x8,%esp
  801a48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a53:	53                   	push   %ebx
  801a54:	ff 75 0c             	pushl  0xc(%ebp)
  801a57:	68 04 80 80 00       	push   $0x808004
  801a5c:	e8 22 ef ff ff       	call   800983 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a61:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801a67:	b8 02 00 00 00       	mov    $0x2,%eax
  801a6c:	e8 36 ff ff ff       	call   8019a7 <nsipc>
}
  801a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7f:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a87:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801a8c:	b8 03 00 00 00       	mov    $0x3,%eax
  801a91:	e8 11 ff ff ff       	call   8019a7 <nsipc>
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <nsipc_close>:

int
nsipc_close(int s)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801aa6:	b8 04 00 00 00       	mov    $0x4,%eax
  801aab:	e8 f7 fe ff ff       	call   8019a7 <nsipc>
}
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    

00801ab2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 08             	sub    $0x8,%esp
  801ab9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ac4:	53                   	push   %ebx
  801ac5:	ff 75 0c             	pushl  0xc(%ebp)
  801ac8:	68 04 80 80 00       	push   $0x808004
  801acd:	e8 b1 ee ff ff       	call   800983 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ad2:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801ad8:	b8 05 00 00 00       	mov    $0x5,%eax
  801add:	e8 c5 fe ff ff       	call   8019a7 <nsipc>
}
  801ae2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    

00801ae7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801aed:	8b 45 08             	mov    0x8(%ebp),%eax
  801af0:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af8:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801afd:	b8 06 00 00 00       	mov    $0x6,%eax
  801b02:	e8 a0 fe ff ff       	call   8019a7 <nsipc>
}
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b11:	8b 45 08             	mov    0x8(%ebp),%eax
  801b14:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801b19:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801b1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801b22:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b27:	b8 07 00 00 00       	mov    $0x7,%eax
  801b2c:	e8 76 fe ff ff       	call   8019a7 <nsipc>
  801b31:	89 c3                	mov    %eax,%ebx
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 35                	js     801b6c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801b37:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b3c:	7f 04                	jg     801b42 <nsipc_recv+0x39>
  801b3e:	39 c6                	cmp    %eax,%esi
  801b40:	7d 16                	jge    801b58 <nsipc_recv+0x4f>
  801b42:	68 1f 29 80 00       	push   $0x80291f
  801b47:	68 e7 28 80 00       	push   $0x8028e7
  801b4c:	6a 62                	push   $0x62
  801b4e:	68 34 29 80 00       	push   $0x802934
  801b53:	e8 3b e6 ff ff       	call   800193 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b58:	83 ec 04             	sub    $0x4,%esp
  801b5b:	50                   	push   %eax
  801b5c:	68 00 80 80 00       	push   $0x808000
  801b61:	ff 75 0c             	pushl  0xc(%ebp)
  801b64:	e8 1a ee ff ff       	call   800983 <memmove>
  801b69:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b6c:	89 d8                	mov    %ebx,%eax
  801b6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	53                   	push   %ebx
  801b79:	83 ec 04             	sub    $0x4,%esp
  801b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b82:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801b87:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b8d:	7e 16                	jle    801ba5 <nsipc_send+0x30>
  801b8f:	68 40 29 80 00       	push   $0x802940
  801b94:	68 e7 28 80 00       	push   $0x8028e7
  801b99:	6a 6d                	push   $0x6d
  801b9b:	68 34 29 80 00       	push   $0x802934
  801ba0:	e8 ee e5 ff ff       	call   800193 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ba5:	83 ec 04             	sub    $0x4,%esp
  801ba8:	53                   	push   %ebx
  801ba9:	ff 75 0c             	pushl  0xc(%ebp)
  801bac:	68 0c 80 80 00       	push   $0x80800c
  801bb1:	e8 cd ed ff ff       	call   800983 <memmove>
	nsipcbuf.send.req_size = size;
  801bb6:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801bbc:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbf:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801bc4:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc9:	e8 d9 fd ff ff       	call   8019a7 <nsipc>
}
  801bce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd1:	c9                   	leave  
  801bd2:	c3                   	ret    

00801bd3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdc:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be4:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801be9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bec:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801bf1:	b8 09 00 00 00       	mov    $0x9,%eax
  801bf6:	e8 ac fd ff ff       	call   8019a7 <nsipc>
}
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    

00801bfd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	ff 75 08             	pushl  0x8(%ebp)
  801c0b:	e8 88 f2 ff ff       	call   800e98 <fd2data>
  801c10:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c12:	83 c4 08             	add    $0x8,%esp
  801c15:	68 4c 29 80 00       	push   $0x80294c
  801c1a:	53                   	push   %ebx
  801c1b:	e8 d1 eb ff ff       	call   8007f1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c20:	8b 46 04             	mov    0x4(%esi),%eax
  801c23:	2b 06                	sub    (%esi),%eax
  801c25:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c2b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c32:	00 00 00 
	stat->st_dev = &devpipe;
  801c35:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801c3c:	30 80 00 
	return 0;
}
  801c3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5e                   	pop    %esi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	53                   	push   %ebx
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c55:	53                   	push   %ebx
  801c56:	6a 00                	push   $0x0
  801c58:	e8 1c f0 ff ff       	call   800c79 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c5d:	89 1c 24             	mov    %ebx,(%esp)
  801c60:	e8 33 f2 ff ff       	call   800e98 <fd2data>
  801c65:	83 c4 08             	add    $0x8,%esp
  801c68:	50                   	push   %eax
  801c69:	6a 00                	push   $0x0
  801c6b:	e8 09 f0 ff ff       	call   800c79 <sys_page_unmap>
}
  801c70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	57                   	push   %edi
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 1c             	sub    $0x1c,%esp
  801c7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c81:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c83:	a1 20 60 80 00       	mov    0x806020,%eax
  801c88:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c8b:	83 ec 0c             	sub    $0xc,%esp
  801c8e:	ff 75 e0             	pushl  -0x20(%ebp)
  801c91:	e8 3a 05 00 00       	call   8021d0 <pageref>
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	89 3c 24             	mov    %edi,(%esp)
  801c9b:	e8 30 05 00 00       	call   8021d0 <pageref>
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	39 c3                	cmp    %eax,%ebx
  801ca5:	0f 94 c1             	sete   %cl
  801ca8:	0f b6 c9             	movzbl %cl,%ecx
  801cab:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cae:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801cb4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cb7:	39 ce                	cmp    %ecx,%esi
  801cb9:	74 1b                	je     801cd6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cbb:	39 c3                	cmp    %eax,%ebx
  801cbd:	75 c4                	jne    801c83 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cbf:	8b 42 58             	mov    0x58(%edx),%eax
  801cc2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cc5:	50                   	push   %eax
  801cc6:	56                   	push   %esi
  801cc7:	68 53 29 80 00       	push   $0x802953
  801ccc:	e8 9b e5 ff ff       	call   80026c <cprintf>
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	eb ad                	jmp    801c83 <_pipeisclosed+0xe>
	}
}
  801cd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdc:	5b                   	pop    %ebx
  801cdd:	5e                   	pop    %esi
  801cde:	5f                   	pop    %edi
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    

00801ce1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	57                   	push   %edi
  801ce5:	56                   	push   %esi
  801ce6:	53                   	push   %ebx
  801ce7:	83 ec 28             	sub    $0x28,%esp
  801cea:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ced:	56                   	push   %esi
  801cee:	e8 a5 f1 ff ff       	call   800e98 <fd2data>
  801cf3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	bf 00 00 00 00       	mov    $0x0,%edi
  801cfd:	eb 4b                	jmp    801d4a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cff:	89 da                	mov    %ebx,%edx
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	e8 6d ff ff ff       	call   801c75 <_pipeisclosed>
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	75 48                	jne    801d54 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d0c:	e8 c4 ee ff ff       	call   800bd5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d11:	8b 43 04             	mov    0x4(%ebx),%eax
  801d14:	8b 0b                	mov    (%ebx),%ecx
  801d16:	8d 51 20             	lea    0x20(%ecx),%edx
  801d19:	39 d0                	cmp    %edx,%eax
  801d1b:	73 e2                	jae    801cff <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d20:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d24:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d27:	89 c2                	mov    %eax,%edx
  801d29:	c1 fa 1f             	sar    $0x1f,%edx
  801d2c:	89 d1                	mov    %edx,%ecx
  801d2e:	c1 e9 1b             	shr    $0x1b,%ecx
  801d31:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d34:	83 e2 1f             	and    $0x1f,%edx
  801d37:	29 ca                	sub    %ecx,%edx
  801d39:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d3d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d41:	83 c0 01             	add    $0x1,%eax
  801d44:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d47:	83 c7 01             	add    $0x1,%edi
  801d4a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d4d:	75 c2                	jne    801d11 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d4f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d52:	eb 05                	jmp    801d59 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d54:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	57                   	push   %edi
  801d65:	56                   	push   %esi
  801d66:	53                   	push   %ebx
  801d67:	83 ec 18             	sub    $0x18,%esp
  801d6a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d6d:	57                   	push   %edi
  801d6e:	e8 25 f1 ff ff       	call   800e98 <fd2data>
  801d73:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d7d:	eb 3d                	jmp    801dbc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d7f:	85 db                	test   %ebx,%ebx
  801d81:	74 04                	je     801d87 <devpipe_read+0x26>
				return i;
  801d83:	89 d8                	mov    %ebx,%eax
  801d85:	eb 44                	jmp    801dcb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d87:	89 f2                	mov    %esi,%edx
  801d89:	89 f8                	mov    %edi,%eax
  801d8b:	e8 e5 fe ff ff       	call   801c75 <_pipeisclosed>
  801d90:	85 c0                	test   %eax,%eax
  801d92:	75 32                	jne    801dc6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d94:	e8 3c ee ff ff       	call   800bd5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d99:	8b 06                	mov    (%esi),%eax
  801d9b:	3b 46 04             	cmp    0x4(%esi),%eax
  801d9e:	74 df                	je     801d7f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801da0:	99                   	cltd   
  801da1:	c1 ea 1b             	shr    $0x1b,%edx
  801da4:	01 d0                	add    %edx,%eax
  801da6:	83 e0 1f             	and    $0x1f,%eax
  801da9:	29 d0                	sub    %edx,%eax
  801dab:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801db6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db9:	83 c3 01             	add    $0x1,%ebx
  801dbc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dbf:	75 d8                	jne    801d99 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dc1:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc4:	eb 05                	jmp    801dcb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dc6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dce:	5b                   	pop    %ebx
  801dcf:	5e                   	pop    %esi
  801dd0:	5f                   	pop    %edi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    

00801dd3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	56                   	push   %esi
  801dd7:	53                   	push   %ebx
  801dd8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ddb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dde:	50                   	push   %eax
  801ddf:	e8 cb f0 ff ff       	call   800eaf <fd_alloc>
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	89 c2                	mov    %eax,%edx
  801de9:	85 c0                	test   %eax,%eax
  801deb:	0f 88 2c 01 00 00    	js     801f1d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df1:	83 ec 04             	sub    $0x4,%esp
  801df4:	68 07 04 00 00       	push   $0x407
  801df9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 f1 ed ff ff       	call   800bf4 <sys_page_alloc>
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	89 c2                	mov    %eax,%edx
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	0f 88 0d 01 00 00    	js     801f1d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e10:	83 ec 0c             	sub    $0xc,%esp
  801e13:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e16:	50                   	push   %eax
  801e17:	e8 93 f0 ff ff       	call   800eaf <fd_alloc>
  801e1c:	89 c3                	mov    %eax,%ebx
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	85 c0                	test   %eax,%eax
  801e23:	0f 88 e2 00 00 00    	js     801f0b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e29:	83 ec 04             	sub    $0x4,%esp
  801e2c:	68 07 04 00 00       	push   $0x407
  801e31:	ff 75 f0             	pushl  -0x10(%ebp)
  801e34:	6a 00                	push   $0x0
  801e36:	e8 b9 ed ff ff       	call   800bf4 <sys_page_alloc>
  801e3b:	89 c3                	mov    %eax,%ebx
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	85 c0                	test   %eax,%eax
  801e42:	0f 88 c3 00 00 00    	js     801f0b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e48:	83 ec 0c             	sub    $0xc,%esp
  801e4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4e:	e8 45 f0 ff ff       	call   800e98 <fd2data>
  801e53:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e55:	83 c4 0c             	add    $0xc,%esp
  801e58:	68 07 04 00 00       	push   $0x407
  801e5d:	50                   	push   %eax
  801e5e:	6a 00                	push   $0x0
  801e60:	e8 8f ed ff ff       	call   800bf4 <sys_page_alloc>
  801e65:	89 c3                	mov    %eax,%ebx
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	0f 88 89 00 00 00    	js     801efb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e72:	83 ec 0c             	sub    $0xc,%esp
  801e75:	ff 75 f0             	pushl  -0x10(%ebp)
  801e78:	e8 1b f0 ff ff       	call   800e98 <fd2data>
  801e7d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e84:	50                   	push   %eax
  801e85:	6a 00                	push   $0x0
  801e87:	56                   	push   %esi
  801e88:	6a 00                	push   $0x0
  801e8a:	e8 a8 ed ff ff       	call   800c37 <sys_page_map>
  801e8f:	89 c3                	mov    %eax,%ebx
  801e91:	83 c4 20             	add    $0x20,%esp
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 55                	js     801eed <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e98:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ead:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ebb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec8:	e8 bb ef ff ff       	call   800e88 <fd2num>
  801ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ed2:	83 c4 04             	add    $0x4,%esp
  801ed5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed8:	e8 ab ef ff ff       	call   800e88 <fd2num>
  801edd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	ba 00 00 00 00       	mov    $0x0,%edx
  801eeb:	eb 30                	jmp    801f1d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801eed:	83 ec 08             	sub    $0x8,%esp
  801ef0:	56                   	push   %esi
  801ef1:	6a 00                	push   $0x0
  801ef3:	e8 81 ed ff ff       	call   800c79 <sys_page_unmap>
  801ef8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801efb:	83 ec 08             	sub    $0x8,%esp
  801efe:	ff 75 f0             	pushl  -0x10(%ebp)
  801f01:	6a 00                	push   $0x0
  801f03:	e8 71 ed ff ff       	call   800c79 <sys_page_unmap>
  801f08:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f0b:	83 ec 08             	sub    $0x8,%esp
  801f0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f11:	6a 00                	push   $0x0
  801f13:	e8 61 ed ff ff       	call   800c79 <sys_page_unmap>
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f1d:	89 d0                	mov    %edx,%eax
  801f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    

00801f26 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2f:	50                   	push   %eax
  801f30:	ff 75 08             	pushl  0x8(%ebp)
  801f33:	e8 c6 ef ff ff       	call   800efe <fd_lookup>
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	78 18                	js     801f57 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f3f:	83 ec 0c             	sub    $0xc,%esp
  801f42:	ff 75 f4             	pushl  -0xc(%ebp)
  801f45:	e8 4e ef ff ff       	call   800e98 <fd2data>
	return _pipeisclosed(fd, p);
  801f4a:	89 c2                	mov    %eax,%edx
  801f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4f:	e8 21 fd ff ff       	call   801c75 <_pipeisclosed>
  801f54:	83 c4 10             	add    $0x10,%esp
}
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    

00801f63 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f69:	68 6b 29 80 00       	push   $0x80296b
  801f6e:	ff 75 0c             	pushl  0xc(%ebp)
  801f71:	e8 7b e8 ff ff       	call   8007f1 <strcpy>
	return 0;
}
  801f76:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	57                   	push   %edi
  801f81:	56                   	push   %esi
  801f82:	53                   	push   %ebx
  801f83:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f89:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f8e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f94:	eb 2d                	jmp    801fc3 <devcons_write+0x46>
		m = n - tot;
  801f96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f99:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f9b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f9e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fa3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fa6:	83 ec 04             	sub    $0x4,%esp
  801fa9:	53                   	push   %ebx
  801faa:	03 45 0c             	add    0xc(%ebp),%eax
  801fad:	50                   	push   %eax
  801fae:	57                   	push   %edi
  801faf:	e8 cf e9 ff ff       	call   800983 <memmove>
		sys_cputs(buf, m);
  801fb4:	83 c4 08             	add    $0x8,%esp
  801fb7:	53                   	push   %ebx
  801fb8:	57                   	push   %edi
  801fb9:	e8 7a eb ff ff       	call   800b38 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fbe:	01 de                	add    %ebx,%esi
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	89 f0                	mov    %esi,%eax
  801fc5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fc8:	72 cc                	jb     801f96 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	83 ec 08             	sub    $0x8,%esp
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fe1:	74 2a                	je     80200d <devcons_read+0x3b>
  801fe3:	eb 05                	jmp    801fea <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fe5:	e8 eb eb ff ff       	call   800bd5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fea:	e8 67 eb ff ff       	call   800b56 <sys_cgetc>
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	74 f2                	je     801fe5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	78 16                	js     80200d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ff7:	83 f8 04             	cmp    $0x4,%eax
  801ffa:	74 0c                	je     802008 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ffc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fff:	88 02                	mov    %al,(%edx)
	return 1;
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	eb 05                	jmp    80200d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802008:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80200d:	c9                   	leave  
  80200e:	c3                   	ret    

0080200f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802015:	8b 45 08             	mov    0x8(%ebp),%eax
  802018:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80201b:	6a 01                	push   $0x1
  80201d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802020:	50                   	push   %eax
  802021:	e8 12 eb ff ff       	call   800b38 <sys_cputs>
}
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <getchar>:

int
getchar(void)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802031:	6a 01                	push   $0x1
  802033:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802036:	50                   	push   %eax
  802037:	6a 00                	push   $0x0
  802039:	e8 26 f1 ff ff       	call   801164 <read>
	if (r < 0)
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	85 c0                	test   %eax,%eax
  802043:	78 0f                	js     802054 <getchar+0x29>
		return r;
	if (r < 1)
  802045:	85 c0                	test   %eax,%eax
  802047:	7e 06                	jle    80204f <getchar+0x24>
		return -E_EOF;
	return c;
  802049:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80204d:	eb 05                	jmp    802054 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80204f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802054:	c9                   	leave  
  802055:	c3                   	ret    

00802056 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80205c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205f:	50                   	push   %eax
  802060:	ff 75 08             	pushl  0x8(%ebp)
  802063:	e8 96 ee ff ff       	call   800efe <fd_lookup>
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 11                	js     802080 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80206f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802072:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802078:	39 10                	cmp    %edx,(%eax)
  80207a:	0f 94 c0             	sete   %al
  80207d:	0f b6 c0             	movzbl %al,%eax
}
  802080:	c9                   	leave  
  802081:	c3                   	ret    

00802082 <opencons>:

int
opencons(void)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802088:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208b:	50                   	push   %eax
  80208c:	e8 1e ee ff ff       	call   800eaf <fd_alloc>
  802091:	83 c4 10             	add    $0x10,%esp
		return r;
  802094:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802096:	85 c0                	test   %eax,%eax
  802098:	78 3e                	js     8020d8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80209a:	83 ec 04             	sub    $0x4,%esp
  80209d:	68 07 04 00 00       	push   $0x407
  8020a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a5:	6a 00                	push   $0x0
  8020a7:	e8 48 eb ff ff       	call   800bf4 <sys_page_alloc>
  8020ac:	83 c4 10             	add    $0x10,%esp
		return r;
  8020af:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	78 23                	js     8020d8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020b5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020be:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020ca:	83 ec 0c             	sub    $0xc,%esp
  8020cd:	50                   	push   %eax
  8020ce:	e8 b5 ed ff ff       	call   800e88 <fd2num>
  8020d3:	89 c2                	mov    %eax,%edx
  8020d5:	83 c4 10             	add    $0x10,%esp
}
  8020d8:	89 d0                	mov    %edx,%eax
  8020da:	c9                   	leave  
  8020db:	c3                   	ret    

008020dc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	56                   	push   %esi
  8020e0:	53                   	push   %ebx
  8020e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8020e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8020ea:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8020ec:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020f1:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8020f4:	83 ec 0c             	sub    $0xc,%esp
  8020f7:	50                   	push   %eax
  8020f8:	e8 a7 ec ff ff       	call   800da4 <sys_ipc_recv>

	if (from_env_store != NULL)
  8020fd:	83 c4 10             	add    $0x10,%esp
  802100:	85 f6                	test   %esi,%esi
  802102:	74 14                	je     802118 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802104:	ba 00 00 00 00       	mov    $0x0,%edx
  802109:	85 c0                	test   %eax,%eax
  80210b:	78 09                	js     802116 <ipc_recv+0x3a>
  80210d:	8b 15 20 60 80 00    	mov    0x806020,%edx
  802113:	8b 52 74             	mov    0x74(%edx),%edx
  802116:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802118:	85 db                	test   %ebx,%ebx
  80211a:	74 14                	je     802130 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80211c:	ba 00 00 00 00       	mov    $0x0,%edx
  802121:	85 c0                	test   %eax,%eax
  802123:	78 09                	js     80212e <ipc_recv+0x52>
  802125:	8b 15 20 60 80 00    	mov    0x806020,%edx
  80212b:	8b 52 78             	mov    0x78(%edx),%edx
  80212e:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802130:	85 c0                	test   %eax,%eax
  802132:	78 08                	js     80213c <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802134:	a1 20 60 80 00       	mov    0x806020,%eax
  802139:	8b 40 70             	mov    0x70(%eax),%eax
}
  80213c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    

00802143 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	57                   	push   %edi
  802147:	56                   	push   %esi
  802148:	53                   	push   %ebx
  802149:	83 ec 0c             	sub    $0xc,%esp
  80214c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80214f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802152:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802155:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802157:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80215c:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80215f:	ff 75 14             	pushl  0x14(%ebp)
  802162:	53                   	push   %ebx
  802163:	56                   	push   %esi
  802164:	57                   	push   %edi
  802165:	e8 17 ec ff ff       	call   800d81 <sys_ipc_try_send>

		if (err < 0) {
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	79 1e                	jns    80218f <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802171:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802174:	75 07                	jne    80217d <ipc_send+0x3a>
				sys_yield();
  802176:	e8 5a ea ff ff       	call   800bd5 <sys_yield>
  80217b:	eb e2                	jmp    80215f <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80217d:	50                   	push   %eax
  80217e:	68 77 29 80 00       	push   $0x802977
  802183:	6a 49                	push   $0x49
  802185:	68 84 29 80 00       	push   $0x802984
  80218a:	e8 04 e0 ff ff       	call   800193 <_panic>
		}

	} while (err < 0);

}
  80218f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802192:	5b                   	pop    %ebx
  802193:	5e                   	pop    %esi
  802194:	5f                   	pop    %edi
  802195:	5d                   	pop    %ebp
  802196:	c3                   	ret    

00802197 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802197:	55                   	push   %ebp
  802198:	89 e5                	mov    %esp,%ebp
  80219a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80219d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021a2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021a5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021ab:	8b 52 50             	mov    0x50(%edx),%edx
  8021ae:	39 ca                	cmp    %ecx,%edx
  8021b0:	75 0d                	jne    8021bf <ipc_find_env+0x28>
			return envs[i].env_id;
  8021b2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021b5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021ba:	8b 40 48             	mov    0x48(%eax),%eax
  8021bd:	eb 0f                	jmp    8021ce <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021bf:	83 c0 01             	add    $0x1,%eax
  8021c2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021c7:	75 d9                	jne    8021a2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021ce:	5d                   	pop    %ebp
  8021cf:	c3                   	ret    

008021d0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	c1 e8 16             	shr    $0x16,%eax
  8021db:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021e2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e7:	f6 c1 01             	test   $0x1,%cl
  8021ea:	74 1d                	je     802209 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ec:	c1 ea 0c             	shr    $0xc,%edx
  8021ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021f6:	f6 c2 01             	test   $0x1,%dl
  8021f9:	74 0e                	je     802209 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021fb:	c1 ea 0c             	shr    $0xc,%edx
  8021fe:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802205:	ef 
  802206:	0f b7 c0             	movzwl %ax,%eax
}
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    
  80220b:	66 90                	xchg   %ax,%ax
  80220d:	66 90                	xchg   %ax,%ax
  80220f:	90                   	nop

00802210 <__udivdi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80221b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80221f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 f6                	test   %esi,%esi
  802229:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80222d:	89 ca                	mov    %ecx,%edx
  80222f:	89 f8                	mov    %edi,%eax
  802231:	75 3d                	jne    802270 <__udivdi3+0x60>
  802233:	39 cf                	cmp    %ecx,%edi
  802235:	0f 87 c5 00 00 00    	ja     802300 <__udivdi3+0xf0>
  80223b:	85 ff                	test   %edi,%edi
  80223d:	89 fd                	mov    %edi,%ebp
  80223f:	75 0b                	jne    80224c <__udivdi3+0x3c>
  802241:	b8 01 00 00 00       	mov    $0x1,%eax
  802246:	31 d2                	xor    %edx,%edx
  802248:	f7 f7                	div    %edi
  80224a:	89 c5                	mov    %eax,%ebp
  80224c:	89 c8                	mov    %ecx,%eax
  80224e:	31 d2                	xor    %edx,%edx
  802250:	f7 f5                	div    %ebp
  802252:	89 c1                	mov    %eax,%ecx
  802254:	89 d8                	mov    %ebx,%eax
  802256:	89 cf                	mov    %ecx,%edi
  802258:	f7 f5                	div    %ebp
  80225a:	89 c3                	mov    %eax,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	39 ce                	cmp    %ecx,%esi
  802272:	77 74                	ja     8022e8 <__udivdi3+0xd8>
  802274:	0f bd fe             	bsr    %esi,%edi
  802277:	83 f7 1f             	xor    $0x1f,%edi
  80227a:	0f 84 98 00 00 00    	je     802318 <__udivdi3+0x108>
  802280:	bb 20 00 00 00       	mov    $0x20,%ebx
  802285:	89 f9                	mov    %edi,%ecx
  802287:	89 c5                	mov    %eax,%ebp
  802289:	29 fb                	sub    %edi,%ebx
  80228b:	d3 e6                	shl    %cl,%esi
  80228d:	89 d9                	mov    %ebx,%ecx
  80228f:	d3 ed                	shr    %cl,%ebp
  802291:	89 f9                	mov    %edi,%ecx
  802293:	d3 e0                	shl    %cl,%eax
  802295:	09 ee                	or     %ebp,%esi
  802297:	89 d9                	mov    %ebx,%ecx
  802299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80229d:	89 d5                	mov    %edx,%ebp
  80229f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022a3:	d3 ed                	shr    %cl,%ebp
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e2                	shl    %cl,%edx
  8022a9:	89 d9                	mov    %ebx,%ecx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	09 c2                	or     %eax,%edx
  8022af:	89 d0                	mov    %edx,%eax
  8022b1:	89 ea                	mov    %ebp,%edx
  8022b3:	f7 f6                	div    %esi
  8022b5:	89 d5                	mov    %edx,%ebp
  8022b7:	89 c3                	mov    %eax,%ebx
  8022b9:	f7 64 24 0c          	mull   0xc(%esp)
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	72 10                	jb     8022d1 <__udivdi3+0xc1>
  8022c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	d3 e6                	shl    %cl,%esi
  8022c9:	39 c6                	cmp    %eax,%esi
  8022cb:	73 07                	jae    8022d4 <__udivdi3+0xc4>
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	75 03                	jne    8022d4 <__udivdi3+0xc4>
  8022d1:	83 eb 01             	sub    $0x1,%ebx
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 d8                	mov    %ebx,%eax
  8022d8:	89 fa                	mov    %edi,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	31 ff                	xor    %edi,%edi
  8022ea:	31 db                	xor    %ebx,%ebx
  8022ec:	89 d8                	mov    %ebx,%eax
  8022ee:	89 fa                	mov    %edi,%edx
  8022f0:	83 c4 1c             	add    $0x1c,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
  8022f8:	90                   	nop
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 d8                	mov    %ebx,%eax
  802302:	f7 f7                	div    %edi
  802304:	31 ff                	xor    %edi,%edi
  802306:	89 c3                	mov    %eax,%ebx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 fa                	mov    %edi,%edx
  80230c:	83 c4 1c             	add    $0x1c,%esp
  80230f:	5b                   	pop    %ebx
  802310:	5e                   	pop    %esi
  802311:	5f                   	pop    %edi
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    
  802314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802318:	39 ce                	cmp    %ecx,%esi
  80231a:	72 0c                	jb     802328 <__udivdi3+0x118>
  80231c:	31 db                	xor    %ebx,%ebx
  80231e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802322:	0f 87 34 ff ff ff    	ja     80225c <__udivdi3+0x4c>
  802328:	bb 01 00 00 00       	mov    $0x1,%ebx
  80232d:	e9 2a ff ff ff       	jmp    80225c <__udivdi3+0x4c>
  802332:	66 90                	xchg   %ax,%ax
  802334:	66 90                	xchg   %ax,%ax
  802336:	66 90                	xchg   %ax,%ax
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__umoddi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 1c             	sub    $0x1c,%esp
  802347:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80234b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80234f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802357:	85 d2                	test   %edx,%edx
  802359:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80235d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802361:	89 f3                	mov    %esi,%ebx
  802363:	89 3c 24             	mov    %edi,(%esp)
  802366:	89 74 24 04          	mov    %esi,0x4(%esp)
  80236a:	75 1c                	jne    802388 <__umoddi3+0x48>
  80236c:	39 f7                	cmp    %esi,%edi
  80236e:	76 50                	jbe    8023c0 <__umoddi3+0x80>
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	f7 f7                	div    %edi
  802376:	89 d0                	mov    %edx,%eax
  802378:	31 d2                	xor    %edx,%edx
  80237a:	83 c4 1c             	add    $0x1c,%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5f                   	pop    %edi
  802380:	5d                   	pop    %ebp
  802381:	c3                   	ret    
  802382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802388:	39 f2                	cmp    %esi,%edx
  80238a:	89 d0                	mov    %edx,%eax
  80238c:	77 52                	ja     8023e0 <__umoddi3+0xa0>
  80238e:	0f bd ea             	bsr    %edx,%ebp
  802391:	83 f5 1f             	xor    $0x1f,%ebp
  802394:	75 5a                	jne    8023f0 <__umoddi3+0xb0>
  802396:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80239a:	0f 82 e0 00 00 00    	jb     802480 <__umoddi3+0x140>
  8023a0:	39 0c 24             	cmp    %ecx,(%esp)
  8023a3:	0f 86 d7 00 00 00    	jbe    802480 <__umoddi3+0x140>
  8023a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023b1:	83 c4 1c             	add    $0x1c,%esp
  8023b4:	5b                   	pop    %ebx
  8023b5:	5e                   	pop    %esi
  8023b6:	5f                   	pop    %edi
  8023b7:	5d                   	pop    %ebp
  8023b8:	c3                   	ret    
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	85 ff                	test   %edi,%edi
  8023c2:	89 fd                	mov    %edi,%ebp
  8023c4:	75 0b                	jne    8023d1 <__umoddi3+0x91>
  8023c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	f7 f7                	div    %edi
  8023cf:	89 c5                	mov    %eax,%ebp
  8023d1:	89 f0                	mov    %esi,%eax
  8023d3:	31 d2                	xor    %edx,%edx
  8023d5:	f7 f5                	div    %ebp
  8023d7:	89 c8                	mov    %ecx,%eax
  8023d9:	f7 f5                	div    %ebp
  8023db:	89 d0                	mov    %edx,%eax
  8023dd:	eb 99                	jmp    802378 <__umoddi3+0x38>
  8023df:	90                   	nop
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	83 c4 1c             	add    $0x1c,%esp
  8023e7:	5b                   	pop    %ebx
  8023e8:	5e                   	pop    %esi
  8023e9:	5f                   	pop    %edi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    
  8023ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	8b 34 24             	mov    (%esp),%esi
  8023f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	29 ef                	sub    %ebp,%edi
  8023fc:	d3 e0                	shl    %cl,%eax
  8023fe:	89 f9                	mov    %edi,%ecx
  802400:	89 f2                	mov    %esi,%edx
  802402:	d3 ea                	shr    %cl,%edx
  802404:	89 e9                	mov    %ebp,%ecx
  802406:	09 c2                	or     %eax,%edx
  802408:	89 d8                	mov    %ebx,%eax
  80240a:	89 14 24             	mov    %edx,(%esp)
  80240d:	89 f2                	mov    %esi,%edx
  80240f:	d3 e2                	shl    %cl,%edx
  802411:	89 f9                	mov    %edi,%ecx
  802413:	89 54 24 04          	mov    %edx,0x4(%esp)
  802417:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	89 e9                	mov    %ebp,%ecx
  80241f:	89 c6                	mov    %eax,%esi
  802421:	d3 e3                	shl    %cl,%ebx
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 d0                	mov    %edx,%eax
  802427:	d3 e8                	shr    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	09 d8                	or     %ebx,%eax
  80242d:	89 d3                	mov    %edx,%ebx
  80242f:	89 f2                	mov    %esi,%edx
  802431:	f7 34 24             	divl   (%esp)
  802434:	89 d6                	mov    %edx,%esi
  802436:	d3 e3                	shl    %cl,%ebx
  802438:	f7 64 24 04          	mull   0x4(%esp)
  80243c:	39 d6                	cmp    %edx,%esi
  80243e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802442:	89 d1                	mov    %edx,%ecx
  802444:	89 c3                	mov    %eax,%ebx
  802446:	72 08                	jb     802450 <__umoddi3+0x110>
  802448:	75 11                	jne    80245b <__umoddi3+0x11b>
  80244a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80244e:	73 0b                	jae    80245b <__umoddi3+0x11b>
  802450:	2b 44 24 04          	sub    0x4(%esp),%eax
  802454:	1b 14 24             	sbb    (%esp),%edx
  802457:	89 d1                	mov    %edx,%ecx
  802459:	89 c3                	mov    %eax,%ebx
  80245b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80245f:	29 da                	sub    %ebx,%edx
  802461:	19 ce                	sbb    %ecx,%esi
  802463:	89 f9                	mov    %edi,%ecx
  802465:	89 f0                	mov    %esi,%eax
  802467:	d3 e0                	shl    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	d3 ea                	shr    %cl,%edx
  80246d:	89 e9                	mov    %ebp,%ecx
  80246f:	d3 ee                	shr    %cl,%esi
  802471:	09 d0                	or     %edx,%eax
  802473:	89 f2                	mov    %esi,%edx
  802475:	83 c4 1c             	add    $0x1c,%esp
  802478:	5b                   	pop    %ebx
  802479:	5e                   	pop    %esi
  80247a:	5f                   	pop    %edi
  80247b:	5d                   	pop    %ebp
  80247c:	c3                   	ret    
  80247d:	8d 76 00             	lea    0x0(%esi),%esi
  802480:	29 f9                	sub    %edi,%ecx
  802482:	19 d6                	sbb    %edx,%esi
  802484:	89 74 24 04          	mov    %esi,0x4(%esp)
  802488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80248c:	e9 18 ff ff ff       	jmp    8023a9 <__umoddi3+0x69>
