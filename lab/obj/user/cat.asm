
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
  800048:	e8 4e 11 00 00       	call   80119b <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 80 1f 80 00       	push   $0x801f80
  800060:	6a 0d                	push   $0xd
  800062:	68 9b 1f 80 00       	push   $0x801f9b
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
  80007a:	e8 42 10 00 00       	call   8010c1 <read>
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
  800093:	68 a6 1f 80 00       	push   $0x801fa6
  800098:	6a 0f                	push   $0xf
  80009a:	68 9b 1f 80 00       	push   $0x801f9b
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
  8000b7:	c7 05 00 30 80 00 bb 	movl   $0x801fbb,0x803000
  8000be:	1f 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 bf 1f 80 00       	push   $0x801fbf
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
  8000e8:	e8 33 14 00 00       	call   801520 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 c7 1f 80 00       	push   $0x801fc7
  800102:	e8 b7 15 00 00       	call   8016be <printf>
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
  80011b:	e8 65 0e 00 00       	call   800f85 <close>
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
  80017f:	e8 2c 0e 00 00       	call   800fb0 <close_all>
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
  8001b1:	68 e4 1f 80 00       	push   $0x801fe4
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 25 24 80 00 	movl   $0x802425,(%esp)
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
  8002cf:	e8 1c 1a 00 00       	call   801cf0 <__udivdi3>
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
  800312:	e8 09 1b 00 00       	call   801e20 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 07 20 80 00 	movsbl 0x802007(%eax),%eax
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
  800416:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
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
  8004da:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	75 18                	jne    8004fd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	50                   	push   %eax
  8004e6:	68 1f 20 80 00       	push   $0x80201f
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
  8004fe:	68 fe 23 80 00       	push   $0x8023fe
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
  800522:	b8 18 20 80 00       	mov    $0x802018,%eax
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
  800b9d:	68 ff 22 80 00       	push   $0x8022ff
  800ba2:	6a 23                	push   $0x23
  800ba4:	68 1c 23 80 00       	push   $0x80231c
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
  800c1e:	68 ff 22 80 00       	push   $0x8022ff
  800c23:	6a 23                	push   $0x23
  800c25:	68 1c 23 80 00       	push   $0x80231c
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
  800c60:	68 ff 22 80 00       	push   $0x8022ff
  800c65:	6a 23                	push   $0x23
  800c67:	68 1c 23 80 00       	push   $0x80231c
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
  800ca2:	68 ff 22 80 00       	push   $0x8022ff
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 1c 23 80 00       	push   $0x80231c
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
  800ce4:	68 ff 22 80 00       	push   $0x8022ff
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 1c 23 80 00       	push   $0x80231c
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
  800d26:	68 ff 22 80 00       	push   $0x8022ff
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 1c 23 80 00       	push   $0x80231c
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
  800d68:	68 ff 22 80 00       	push   $0x8022ff
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 1c 23 80 00       	push   $0x80231c
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
  800dcc:	68 ff 22 80 00       	push   $0x8022ff
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 1c 23 80 00       	push   $0x80231c
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

00800de5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	05 00 00 00 30       	add    $0x30000000,%eax
  800df0:	c1 e8 0c             	shr    $0xc,%eax
}
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	05 00 00 00 30       	add    $0x30000000,%eax
  800e00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e05:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e12:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e17:	89 c2                	mov    %eax,%edx
  800e19:	c1 ea 16             	shr    $0x16,%edx
  800e1c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e23:	f6 c2 01             	test   $0x1,%dl
  800e26:	74 11                	je     800e39 <fd_alloc+0x2d>
  800e28:	89 c2                	mov    %eax,%edx
  800e2a:	c1 ea 0c             	shr    $0xc,%edx
  800e2d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e34:	f6 c2 01             	test   $0x1,%dl
  800e37:	75 09                	jne    800e42 <fd_alloc+0x36>
			*fd_store = fd;
  800e39:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e40:	eb 17                	jmp    800e59 <fd_alloc+0x4d>
  800e42:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e47:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e4c:	75 c9                	jne    800e17 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e4e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e54:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e61:	83 f8 1f             	cmp    $0x1f,%eax
  800e64:	77 36                	ja     800e9c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e66:	c1 e0 0c             	shl    $0xc,%eax
  800e69:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e6e:	89 c2                	mov    %eax,%edx
  800e70:	c1 ea 16             	shr    $0x16,%edx
  800e73:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7a:	f6 c2 01             	test   $0x1,%dl
  800e7d:	74 24                	je     800ea3 <fd_lookup+0x48>
  800e7f:	89 c2                	mov    %eax,%edx
  800e81:	c1 ea 0c             	shr    $0xc,%edx
  800e84:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8b:	f6 c2 01             	test   $0x1,%dl
  800e8e:	74 1a                	je     800eaa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e93:	89 02                	mov    %eax,(%edx)
	return 0;
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	eb 13                	jmp    800eaf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea1:	eb 0c                	jmp    800eaf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea8:	eb 05                	jmp    800eaf <fd_lookup+0x54>
  800eaa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eba:	ba ac 23 80 00       	mov    $0x8023ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ebf:	eb 13                	jmp    800ed4 <dev_lookup+0x23>
  800ec1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ec4:	39 08                	cmp    %ecx,(%eax)
  800ec6:	75 0c                	jne    800ed4 <dev_lookup+0x23>
			*dev = devtab[i];
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed2:	eb 2e                	jmp    800f02 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed4:	8b 02                	mov    (%edx),%eax
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	75 e7                	jne    800ec1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eda:	a1 20 60 80 00       	mov    0x806020,%eax
  800edf:	8b 40 48             	mov    0x48(%eax),%eax
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	51                   	push   %ecx
  800ee6:	50                   	push   %eax
  800ee7:	68 2c 23 80 00       	push   $0x80232c
  800eec:	e8 7b f3 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 10             	sub    $0x10,%esp
  800f0c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f15:	50                   	push   %eax
  800f16:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f1c:	c1 e8 0c             	shr    $0xc,%eax
  800f1f:	50                   	push   %eax
  800f20:	e8 36 ff ff ff       	call   800e5b <fd_lookup>
  800f25:	83 c4 08             	add    $0x8,%esp
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	78 05                	js     800f31 <fd_close+0x2d>
	    || fd != fd2)
  800f2c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f2f:	74 0c                	je     800f3d <fd_close+0x39>
		return (must_exist ? r : 0);
  800f31:	84 db                	test   %bl,%bl
  800f33:	ba 00 00 00 00       	mov    $0x0,%edx
  800f38:	0f 44 c2             	cmove  %edx,%eax
  800f3b:	eb 41                	jmp    800f7e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f43:	50                   	push   %eax
  800f44:	ff 36                	pushl  (%esi)
  800f46:	e8 66 ff ff ff       	call   800eb1 <dev_lookup>
  800f4b:	89 c3                	mov    %eax,%ebx
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 1a                	js     800f6e <fd_close+0x6a>
		if (dev->dev_close)
  800f54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f57:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	74 0b                	je     800f6e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	56                   	push   %esi
  800f67:	ff d0                	call   *%eax
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	56                   	push   %esi
  800f72:	6a 00                	push   $0x0
  800f74:	e8 00 fd ff ff       	call   800c79 <sys_page_unmap>
	return r;
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	89 d8                	mov    %ebx,%eax
}
  800f7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	ff 75 08             	pushl  0x8(%ebp)
  800f92:	e8 c4 fe ff ff       	call   800e5b <fd_lookup>
  800f97:	83 c4 08             	add    $0x8,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	78 10                	js     800fae <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	6a 01                	push   $0x1
  800fa3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa6:	e8 59 ff ff ff       	call   800f04 <fd_close>
  800fab:	83 c4 10             	add    $0x10,%esp
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <close_all>:

void
close_all(void)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbc:	83 ec 0c             	sub    $0xc,%esp
  800fbf:	53                   	push   %ebx
  800fc0:	e8 c0 ff ff ff       	call   800f85 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc5:	83 c3 01             	add    $0x1,%ebx
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	83 fb 20             	cmp    $0x20,%ebx
  800fce:	75 ec                	jne    800fbc <close_all+0xc>
		close(i);
}
  800fd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	57                   	push   %edi
  800fd9:	56                   	push   %esi
  800fda:	53                   	push   %ebx
  800fdb:	83 ec 2c             	sub    $0x2c,%esp
  800fde:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe4:	50                   	push   %eax
  800fe5:	ff 75 08             	pushl  0x8(%ebp)
  800fe8:	e8 6e fe ff ff       	call   800e5b <fd_lookup>
  800fed:	83 c4 08             	add    $0x8,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	0f 88 c1 00 00 00    	js     8010b9 <dup+0xe4>
		return r;
	close(newfdnum);
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	56                   	push   %esi
  800ffc:	e8 84 ff ff ff       	call   800f85 <close>

	newfd = INDEX2FD(newfdnum);
  801001:	89 f3                	mov    %esi,%ebx
  801003:	c1 e3 0c             	shl    $0xc,%ebx
  801006:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80100c:	83 c4 04             	add    $0x4,%esp
  80100f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801012:	e8 de fd ff ff       	call   800df5 <fd2data>
  801017:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801019:	89 1c 24             	mov    %ebx,(%esp)
  80101c:	e8 d4 fd ff ff       	call   800df5 <fd2data>
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801027:	89 f8                	mov    %edi,%eax
  801029:	c1 e8 16             	shr    $0x16,%eax
  80102c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801033:	a8 01                	test   $0x1,%al
  801035:	74 37                	je     80106e <dup+0x99>
  801037:	89 f8                	mov    %edi,%eax
  801039:	c1 e8 0c             	shr    $0xc,%eax
  80103c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801043:	f6 c2 01             	test   $0x1,%dl
  801046:	74 26                	je     80106e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801048:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	25 07 0e 00 00       	and    $0xe07,%eax
  801057:	50                   	push   %eax
  801058:	ff 75 d4             	pushl  -0x2c(%ebp)
  80105b:	6a 00                	push   $0x0
  80105d:	57                   	push   %edi
  80105e:	6a 00                	push   $0x0
  801060:	e8 d2 fb ff ff       	call   800c37 <sys_page_map>
  801065:	89 c7                	mov    %eax,%edi
  801067:	83 c4 20             	add    $0x20,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 2e                	js     80109c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80106e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801071:	89 d0                	mov    %edx,%eax
  801073:	c1 e8 0c             	shr    $0xc,%eax
  801076:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107d:	83 ec 0c             	sub    $0xc,%esp
  801080:	25 07 0e 00 00       	and    $0xe07,%eax
  801085:	50                   	push   %eax
  801086:	53                   	push   %ebx
  801087:	6a 00                	push   $0x0
  801089:	52                   	push   %edx
  80108a:	6a 00                	push   $0x0
  80108c:	e8 a6 fb ff ff       	call   800c37 <sys_page_map>
  801091:	89 c7                	mov    %eax,%edi
  801093:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801096:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801098:	85 ff                	test   %edi,%edi
  80109a:	79 1d                	jns    8010b9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80109c:	83 ec 08             	sub    $0x8,%esp
  80109f:	53                   	push   %ebx
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 d2 fb ff ff       	call   800c79 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a7:	83 c4 08             	add    $0x8,%esp
  8010aa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 c5 fb ff ff       	call   800c79 <sys_page_unmap>
	return r;
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	89 f8                	mov    %edi,%eax
}
  8010b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 14             	sub    $0x14,%esp
  8010c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ce:	50                   	push   %eax
  8010cf:	53                   	push   %ebx
  8010d0:	e8 86 fd ff ff       	call   800e5b <fd_lookup>
  8010d5:	83 c4 08             	add    $0x8,%esp
  8010d8:	89 c2                	mov    %eax,%edx
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 6d                	js     80114b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010de:	83 ec 08             	sub    $0x8,%esp
  8010e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e4:	50                   	push   %eax
  8010e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e8:	ff 30                	pushl  (%eax)
  8010ea:	e8 c2 fd ff ff       	call   800eb1 <dev_lookup>
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	78 4c                	js     801142 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f9:	8b 42 08             	mov    0x8(%edx),%eax
  8010fc:	83 e0 03             	and    $0x3,%eax
  8010ff:	83 f8 01             	cmp    $0x1,%eax
  801102:	75 21                	jne    801125 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801104:	a1 20 60 80 00       	mov    0x806020,%eax
  801109:	8b 40 48             	mov    0x48(%eax),%eax
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	53                   	push   %ebx
  801110:	50                   	push   %eax
  801111:	68 70 23 80 00       	push   $0x802370
  801116:	e8 51 f1 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801123:	eb 26                	jmp    80114b <read+0x8a>
	}
	if (!dev->dev_read)
  801125:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801128:	8b 40 08             	mov    0x8(%eax),%eax
  80112b:	85 c0                	test   %eax,%eax
  80112d:	74 17                	je     801146 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80112f:	83 ec 04             	sub    $0x4,%esp
  801132:	ff 75 10             	pushl  0x10(%ebp)
  801135:	ff 75 0c             	pushl  0xc(%ebp)
  801138:	52                   	push   %edx
  801139:	ff d0                	call   *%eax
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	eb 09                	jmp    80114b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801142:	89 c2                	mov    %eax,%edx
  801144:	eb 05                	jmp    80114b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801146:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80114b:	89 d0                	mov    %edx,%eax
  80114d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	57                   	push   %edi
  801156:	56                   	push   %esi
  801157:	53                   	push   %ebx
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80115e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801161:	bb 00 00 00 00       	mov    $0x0,%ebx
  801166:	eb 21                	jmp    801189 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	89 f0                	mov    %esi,%eax
  80116d:	29 d8                	sub    %ebx,%eax
  80116f:	50                   	push   %eax
  801170:	89 d8                	mov    %ebx,%eax
  801172:	03 45 0c             	add    0xc(%ebp),%eax
  801175:	50                   	push   %eax
  801176:	57                   	push   %edi
  801177:	e8 45 ff ff ff       	call   8010c1 <read>
		if (m < 0)
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	78 10                	js     801193 <readn+0x41>
			return m;
		if (m == 0)
  801183:	85 c0                	test   %eax,%eax
  801185:	74 0a                	je     801191 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801187:	01 c3                	add    %eax,%ebx
  801189:	39 f3                	cmp    %esi,%ebx
  80118b:	72 db                	jb     801168 <readn+0x16>
  80118d:	89 d8                	mov    %ebx,%eax
  80118f:	eb 02                	jmp    801193 <readn+0x41>
  801191:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801196:	5b                   	pop    %ebx
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	53                   	push   %ebx
  80119f:	83 ec 14             	sub    $0x14,%esp
  8011a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a8:	50                   	push   %eax
  8011a9:	53                   	push   %ebx
  8011aa:	e8 ac fc ff ff       	call   800e5b <fd_lookup>
  8011af:	83 c4 08             	add    $0x8,%esp
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	78 68                	js     801220 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c2:	ff 30                	pushl  (%eax)
  8011c4:	e8 e8 fc ff ff       	call   800eb1 <dev_lookup>
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	78 47                	js     801217 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d7:	75 21                	jne    8011fa <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d9:	a1 20 60 80 00       	mov    0x806020,%eax
  8011de:	8b 40 48             	mov    0x48(%eax),%eax
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	53                   	push   %ebx
  8011e5:	50                   	push   %eax
  8011e6:	68 8c 23 80 00       	push   $0x80238c
  8011eb:	e8 7c f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f8:	eb 26                	jmp    801220 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801200:	85 d2                	test   %edx,%edx
  801202:	74 17                	je     80121b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801204:	83 ec 04             	sub    $0x4,%esp
  801207:	ff 75 10             	pushl  0x10(%ebp)
  80120a:	ff 75 0c             	pushl  0xc(%ebp)
  80120d:	50                   	push   %eax
  80120e:	ff d2                	call   *%edx
  801210:	89 c2                	mov    %eax,%edx
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	eb 09                	jmp    801220 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801217:	89 c2                	mov    %eax,%edx
  801219:	eb 05                	jmp    801220 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80121b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801220:	89 d0                	mov    %edx,%eax
  801222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <seek>:

int
seek(int fdnum, off_t offset)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	ff 75 08             	pushl  0x8(%ebp)
  801234:	e8 22 fc ff ff       	call   800e5b <fd_lookup>
  801239:	83 c4 08             	add    $0x8,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 0e                	js     80124e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801240:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801243:	8b 55 0c             	mov    0xc(%ebp),%edx
  801246:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124e:	c9                   	leave  
  80124f:	c3                   	ret    

00801250 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	53                   	push   %ebx
  801254:	83 ec 14             	sub    $0x14,%esp
  801257:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	53                   	push   %ebx
  80125f:	e8 f7 fb ff ff       	call   800e5b <fd_lookup>
  801264:	83 c4 08             	add    $0x8,%esp
  801267:	89 c2                	mov    %eax,%edx
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 65                	js     8012d2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801277:	ff 30                	pushl  (%eax)
  801279:	e8 33 fc ff ff       	call   800eb1 <dev_lookup>
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 44                	js     8012c9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801288:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128c:	75 21                	jne    8012af <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80128e:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801293:	8b 40 48             	mov    0x48(%eax),%eax
  801296:	83 ec 04             	sub    $0x4,%esp
  801299:	53                   	push   %ebx
  80129a:	50                   	push   %eax
  80129b:	68 4c 23 80 00       	push   $0x80234c
  8012a0:	e8 c7 ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ad:	eb 23                	jmp    8012d2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b2:	8b 52 18             	mov    0x18(%edx),%edx
  8012b5:	85 d2                	test   %edx,%edx
  8012b7:	74 14                	je     8012cd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	ff 75 0c             	pushl  0xc(%ebp)
  8012bf:	50                   	push   %eax
  8012c0:	ff d2                	call   *%edx
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	eb 09                	jmp    8012d2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	eb 05                	jmp    8012d2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012d2:	89 d0                	mov    %edx,%eax
  8012d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	53                   	push   %ebx
  8012dd:	83 ec 14             	sub    $0x14,%esp
  8012e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	ff 75 08             	pushl  0x8(%ebp)
  8012ea:	e8 6c fb ff ff       	call   800e5b <fd_lookup>
  8012ef:	83 c4 08             	add    $0x8,%esp
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 58                	js     801350 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fe:	50                   	push   %eax
  8012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801302:	ff 30                	pushl  (%eax)
  801304:	e8 a8 fb ff ff       	call   800eb1 <dev_lookup>
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 37                	js     801347 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801310:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801313:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801317:	74 32                	je     80134b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801319:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80131c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801323:	00 00 00 
	stat->st_isdir = 0;
  801326:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80132d:	00 00 00 
	stat->st_dev = dev;
  801330:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	53                   	push   %ebx
  80133a:	ff 75 f0             	pushl  -0x10(%ebp)
  80133d:	ff 50 14             	call   *0x14(%eax)
  801340:	89 c2                	mov    %eax,%edx
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	eb 09                	jmp    801350 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801347:	89 c2                	mov    %eax,%edx
  801349:	eb 05                	jmp    801350 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80134b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801350:	89 d0                	mov    %edx,%eax
  801352:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	56                   	push   %esi
  80135b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	6a 00                	push   $0x0
  801361:	ff 75 08             	pushl  0x8(%ebp)
  801364:	e8 b7 01 00 00       	call   801520 <open>
  801369:	89 c3                	mov    %eax,%ebx
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 1b                	js     80138d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	ff 75 0c             	pushl  0xc(%ebp)
  801378:	50                   	push   %eax
  801379:	e8 5b ff ff ff       	call   8012d9 <fstat>
  80137e:	89 c6                	mov    %eax,%esi
	close(fd);
  801380:	89 1c 24             	mov    %ebx,(%esp)
  801383:	e8 fd fb ff ff       	call   800f85 <close>
	return r;
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	89 f0                	mov    %esi,%eax
}
  80138d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	56                   	push   %esi
  801398:	53                   	push   %ebx
  801399:	89 c6                	mov    %eax,%esi
  80139b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80139d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013a4:	75 12                	jne    8013b8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013a6:	83 ec 0c             	sub    $0xc,%esp
  8013a9:	6a 01                	push   $0x1
  8013ab:	e8 be 08 00 00       	call   801c6e <ipc_find_env>
  8013b0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013b5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b8:	6a 07                	push   $0x7
  8013ba:	68 00 70 80 00       	push   $0x807000
  8013bf:	56                   	push   %esi
  8013c0:	ff 35 00 40 80 00    	pushl  0x804000
  8013c6:	e8 4f 08 00 00       	call   801c1a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013cb:	83 c4 0c             	add    $0xc,%esp
  8013ce:	6a 00                	push   $0x0
  8013d0:	53                   	push   %ebx
  8013d1:	6a 00                	push   $0x0
  8013d3:	e8 db 07 00 00       	call   801bb3 <ipc_recv>
}
  8013d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013eb:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8013f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f3:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fd:	b8 02 00 00 00       	mov    $0x2,%eax
  801402:	e8 8d ff ff ff       	call   801394 <fsipc>
}
  801407:	c9                   	leave  
  801408:	c3                   	ret    

00801409 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	8b 40 0c             	mov    0xc(%eax),%eax
  801415:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80141a:	ba 00 00 00 00       	mov    $0x0,%edx
  80141f:	b8 06 00 00 00       	mov    $0x6,%eax
  801424:	e8 6b ff ff ff       	call   801394 <fsipc>
}
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	53                   	push   %ebx
  80142f:	83 ec 04             	sub    $0x4,%esp
  801432:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801435:	8b 45 08             	mov    0x8(%ebp),%eax
  801438:	8b 40 0c             	mov    0xc(%eax),%eax
  80143b:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801440:	ba 00 00 00 00       	mov    $0x0,%edx
  801445:	b8 05 00 00 00       	mov    $0x5,%eax
  80144a:	e8 45 ff ff ff       	call   801394 <fsipc>
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 2c                	js     80147f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	68 00 70 80 00       	push   $0x807000
  80145b:	53                   	push   %ebx
  80145c:	e8 90 f3 ff ff       	call   8007f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801461:	a1 80 70 80 00       	mov    0x807080,%eax
  801466:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80146c:	a1 84 70 80 00       	mov    0x807084,%eax
  801471:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801482:	c9                   	leave  
  801483:	c3                   	ret    

00801484 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80148a:	68 bc 23 80 00       	push   $0x8023bc
  80148f:	68 90 00 00 00       	push   $0x90
  801494:	68 da 23 80 00       	push   $0x8023da
  801499:	e8 f5 ec ff ff       	call   800193 <_panic>

0080149e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	56                   	push   %esi
  8014a2:	53                   	push   %ebx
  8014a3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ac:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8014b1:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c1:	e8 ce fe ff ff       	call   801394 <fsipc>
  8014c6:	89 c3                	mov    %eax,%ebx
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 4b                	js     801517 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014cc:	39 c6                	cmp    %eax,%esi
  8014ce:	73 16                	jae    8014e6 <devfile_read+0x48>
  8014d0:	68 e5 23 80 00       	push   $0x8023e5
  8014d5:	68 ec 23 80 00       	push   $0x8023ec
  8014da:	6a 7c                	push   $0x7c
  8014dc:	68 da 23 80 00       	push   $0x8023da
  8014e1:	e8 ad ec ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  8014e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014eb:	7e 16                	jle    801503 <devfile_read+0x65>
  8014ed:	68 01 24 80 00       	push   $0x802401
  8014f2:	68 ec 23 80 00       	push   $0x8023ec
  8014f7:	6a 7d                	push   $0x7d
  8014f9:	68 da 23 80 00       	push   $0x8023da
  8014fe:	e8 90 ec ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801503:	83 ec 04             	sub    $0x4,%esp
  801506:	50                   	push   %eax
  801507:	68 00 70 80 00       	push   $0x807000
  80150c:	ff 75 0c             	pushl  0xc(%ebp)
  80150f:	e8 6f f4 ff ff       	call   800983 <memmove>
	return r;
  801514:	83 c4 10             	add    $0x10,%esp
}
  801517:	89 d8                	mov    %ebx,%eax
  801519:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151c:	5b                   	pop    %ebx
  80151d:	5e                   	pop    %esi
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	53                   	push   %ebx
  801524:	83 ec 20             	sub    $0x20,%esp
  801527:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80152a:	53                   	push   %ebx
  80152b:	e8 88 f2 ff ff       	call   8007b8 <strlen>
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801538:	7f 67                	jg     8015a1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	e8 c6 f8 ff ff       	call   800e0c <fd_alloc>
  801546:	83 c4 10             	add    $0x10,%esp
		return r;
  801549:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 57                	js     8015a6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	53                   	push   %ebx
  801553:	68 00 70 80 00       	push   $0x807000
  801558:	e8 94 f2 ff ff       	call   8007f1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80155d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801560:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801565:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801568:	b8 01 00 00 00       	mov    $0x1,%eax
  80156d:	e8 22 fe ff ff       	call   801394 <fsipc>
  801572:	89 c3                	mov    %eax,%ebx
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	79 14                	jns    80158f <open+0x6f>
		fd_close(fd, 0);
  80157b:	83 ec 08             	sub    $0x8,%esp
  80157e:	6a 00                	push   $0x0
  801580:	ff 75 f4             	pushl  -0xc(%ebp)
  801583:	e8 7c f9 ff ff       	call   800f04 <fd_close>
		return r;
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	89 da                	mov    %ebx,%edx
  80158d:	eb 17                	jmp    8015a6 <open+0x86>
	}

	return fd2num(fd);
  80158f:	83 ec 0c             	sub    $0xc,%esp
  801592:	ff 75 f4             	pushl  -0xc(%ebp)
  801595:	e8 4b f8 ff ff       	call   800de5 <fd2num>
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	eb 05                	jmp    8015a6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015a1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015a6:	89 d0                	mov    %edx,%eax
  8015a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8015bd:	e8 d2 fd ff ff       	call   801394 <fsipc>
}
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8015c4:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8015c8:	7e 37                	jle    801601 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 08             	sub    $0x8,%esp
  8015d1:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8015d3:	ff 70 04             	pushl  0x4(%eax)
  8015d6:	8d 40 10             	lea    0x10(%eax),%eax
  8015d9:	50                   	push   %eax
  8015da:	ff 33                	pushl  (%ebx)
  8015dc:	e8 ba fb ff ff       	call   80119b <write>
		if (result > 0)
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	7e 03                	jle    8015eb <writebuf+0x27>
			b->result += result;
  8015e8:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8015eb:	3b 43 04             	cmp    0x4(%ebx),%eax
  8015ee:	74 0d                	je     8015fd <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f7:	0f 4f c2             	cmovg  %edx,%eax
  8015fa:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8015fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801600:	c9                   	leave  
  801601:	f3 c3                	repz ret 

00801603 <putch>:

static void
putch(int ch, void *thunk)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	53                   	push   %ebx
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80160d:	8b 53 04             	mov    0x4(%ebx),%edx
  801610:	8d 42 01             	lea    0x1(%edx),%eax
  801613:	89 43 04             	mov    %eax,0x4(%ebx)
  801616:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801619:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80161d:	3d 00 01 00 00       	cmp    $0x100,%eax
  801622:	75 0e                	jne    801632 <putch+0x2f>
		writebuf(b);
  801624:	89 d8                	mov    %ebx,%eax
  801626:	e8 99 ff ff ff       	call   8015c4 <writebuf>
		b->idx = 0;
  80162b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801632:	83 c4 04             	add    $0x4,%esp
  801635:	5b                   	pop    %ebx
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    

00801638 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801641:	8b 45 08             	mov    0x8(%ebp),%eax
  801644:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80164a:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801651:	00 00 00 
	b.result = 0;
  801654:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80165b:	00 00 00 
	b.error = 1;
  80165e:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801665:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801668:	ff 75 10             	pushl  0x10(%ebp)
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	68 03 16 80 00       	push   $0x801603
  80167a:	e8 24 ed ff ff       	call   8003a3 <vprintfmt>
	if (b.idx > 0)
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801689:	7e 0b                	jle    801696 <vfprintf+0x5e>
		writebuf(&b);
  80168b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801691:	e8 2e ff ff ff       	call   8015c4 <writebuf>

	return (b.result ? b.result : b.error);
  801696:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80169c:	85 c0                	test   %eax,%eax
  80169e:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    

008016a7 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016ad:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8016b0:	50                   	push   %eax
  8016b1:	ff 75 0c             	pushl  0xc(%ebp)
  8016b4:	ff 75 08             	pushl  0x8(%ebp)
  8016b7:	e8 7c ff ff ff       	call   801638 <vfprintf>
	va_end(ap);

	return cnt;
}
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    

008016be <printf>:

int
printf(const char *fmt, ...)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8016c7:	50                   	push   %eax
  8016c8:	ff 75 08             	pushl  0x8(%ebp)
  8016cb:	6a 01                	push   $0x1
  8016cd:	e8 66 ff ff ff       	call   801638 <vfprintf>
	va_end(ap);

	return cnt;
}
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016dc:	83 ec 0c             	sub    $0xc,%esp
  8016df:	ff 75 08             	pushl  0x8(%ebp)
  8016e2:	e8 0e f7 ff ff       	call   800df5 <fd2data>
  8016e7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016e9:	83 c4 08             	add    $0x8,%esp
  8016ec:	68 0d 24 80 00       	push   $0x80240d
  8016f1:	53                   	push   %ebx
  8016f2:	e8 fa f0 ff ff       	call   8007f1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016f7:	8b 46 04             	mov    0x4(%esi),%eax
  8016fa:	2b 06                	sub    (%esi),%eax
  8016fc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801702:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801709:	00 00 00 
	stat->st_dev = &devpipe;
  80170c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801713:	30 80 00 
	return 0;
}
  801716:	b8 00 00 00 00       	mov    $0x0,%eax
  80171b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	83 ec 0c             	sub    $0xc,%esp
  801729:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80172c:	53                   	push   %ebx
  80172d:	6a 00                	push   $0x0
  80172f:	e8 45 f5 ff ff       	call   800c79 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801734:	89 1c 24             	mov    %ebx,(%esp)
  801737:	e8 b9 f6 ff ff       	call   800df5 <fd2data>
  80173c:	83 c4 08             	add    $0x8,%esp
  80173f:	50                   	push   %eax
  801740:	6a 00                	push   $0x0
  801742:	e8 32 f5 ff ff       	call   800c79 <sys_page_unmap>
}
  801747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	57                   	push   %edi
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	83 ec 1c             	sub    $0x1c,%esp
  801755:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801758:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80175a:	a1 20 60 80 00       	mov    0x806020,%eax
  80175f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801762:	83 ec 0c             	sub    $0xc,%esp
  801765:	ff 75 e0             	pushl  -0x20(%ebp)
  801768:	e8 3a 05 00 00       	call   801ca7 <pageref>
  80176d:	89 c3                	mov    %eax,%ebx
  80176f:	89 3c 24             	mov    %edi,(%esp)
  801772:	e8 30 05 00 00       	call   801ca7 <pageref>
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	39 c3                	cmp    %eax,%ebx
  80177c:	0f 94 c1             	sete   %cl
  80177f:	0f b6 c9             	movzbl %cl,%ecx
  801782:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801785:	8b 15 20 60 80 00    	mov    0x806020,%edx
  80178b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80178e:	39 ce                	cmp    %ecx,%esi
  801790:	74 1b                	je     8017ad <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801792:	39 c3                	cmp    %eax,%ebx
  801794:	75 c4                	jne    80175a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801796:	8b 42 58             	mov    0x58(%edx),%eax
  801799:	ff 75 e4             	pushl  -0x1c(%ebp)
  80179c:	50                   	push   %eax
  80179d:	56                   	push   %esi
  80179e:	68 14 24 80 00       	push   $0x802414
  8017a3:	e8 c4 ea ff ff       	call   80026c <cprintf>
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	eb ad                	jmp    80175a <_pipeisclosed+0xe>
	}
}
  8017ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5f                   	pop    %edi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	57                   	push   %edi
  8017bc:	56                   	push   %esi
  8017bd:	53                   	push   %ebx
  8017be:	83 ec 28             	sub    $0x28,%esp
  8017c1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017c4:	56                   	push   %esi
  8017c5:	e8 2b f6 ff ff       	call   800df5 <fd2data>
  8017ca:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8017d4:	eb 4b                	jmp    801821 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017d6:	89 da                	mov    %ebx,%edx
  8017d8:	89 f0                	mov    %esi,%eax
  8017da:	e8 6d ff ff ff       	call   80174c <_pipeisclosed>
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	75 48                	jne    80182b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017e3:	e8 ed f3 ff ff       	call   800bd5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017e8:	8b 43 04             	mov    0x4(%ebx),%eax
  8017eb:	8b 0b                	mov    (%ebx),%ecx
  8017ed:	8d 51 20             	lea    0x20(%ecx),%edx
  8017f0:	39 d0                	cmp    %edx,%eax
  8017f2:	73 e2                	jae    8017d6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017fb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017fe:	89 c2                	mov    %eax,%edx
  801800:	c1 fa 1f             	sar    $0x1f,%edx
  801803:	89 d1                	mov    %edx,%ecx
  801805:	c1 e9 1b             	shr    $0x1b,%ecx
  801808:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80180b:	83 e2 1f             	and    $0x1f,%edx
  80180e:	29 ca                	sub    %ecx,%edx
  801810:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801814:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801818:	83 c0 01             	add    $0x1,%eax
  80181b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80181e:	83 c7 01             	add    $0x1,%edi
  801821:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801824:	75 c2                	jne    8017e8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801826:	8b 45 10             	mov    0x10(%ebp),%eax
  801829:	eb 05                	jmp    801830 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80182b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801830:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801833:	5b                   	pop    %ebx
  801834:	5e                   	pop    %esi
  801835:	5f                   	pop    %edi
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	57                   	push   %edi
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	83 ec 18             	sub    $0x18,%esp
  801841:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801844:	57                   	push   %edi
  801845:	e8 ab f5 ff ff       	call   800df5 <fd2data>
  80184a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801854:	eb 3d                	jmp    801893 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801856:	85 db                	test   %ebx,%ebx
  801858:	74 04                	je     80185e <devpipe_read+0x26>
				return i;
  80185a:	89 d8                	mov    %ebx,%eax
  80185c:	eb 44                	jmp    8018a2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80185e:	89 f2                	mov    %esi,%edx
  801860:	89 f8                	mov    %edi,%eax
  801862:	e8 e5 fe ff ff       	call   80174c <_pipeisclosed>
  801867:	85 c0                	test   %eax,%eax
  801869:	75 32                	jne    80189d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80186b:	e8 65 f3 ff ff       	call   800bd5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801870:	8b 06                	mov    (%esi),%eax
  801872:	3b 46 04             	cmp    0x4(%esi),%eax
  801875:	74 df                	je     801856 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801877:	99                   	cltd   
  801878:	c1 ea 1b             	shr    $0x1b,%edx
  80187b:	01 d0                	add    %edx,%eax
  80187d:	83 e0 1f             	and    $0x1f,%eax
  801880:	29 d0                	sub    %edx,%eax
  801882:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80188a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80188d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801890:	83 c3 01             	add    $0x1,%ebx
  801893:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801896:	75 d8                	jne    801870 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801898:	8b 45 10             	mov    0x10(%ebp),%eax
  80189b:	eb 05                	jmp    8018a2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5f                   	pop    %edi
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	56                   	push   %esi
  8018ae:	53                   	push   %ebx
  8018af:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b5:	50                   	push   %eax
  8018b6:	e8 51 f5 ff ff       	call   800e0c <fd_alloc>
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	89 c2                	mov    %eax,%edx
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	0f 88 2c 01 00 00    	js     8019f4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c8:	83 ec 04             	sub    $0x4,%esp
  8018cb:	68 07 04 00 00       	push   $0x407
  8018d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d3:	6a 00                	push   $0x0
  8018d5:	e8 1a f3 ff ff       	call   800bf4 <sys_page_alloc>
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	89 c2                	mov    %eax,%edx
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	0f 88 0d 01 00 00    	js     8019f4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ed:	50                   	push   %eax
  8018ee:	e8 19 f5 ff ff       	call   800e0c <fd_alloc>
  8018f3:	89 c3                	mov    %eax,%ebx
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	0f 88 e2 00 00 00    	js     8019e2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	68 07 04 00 00       	push   $0x407
  801908:	ff 75 f0             	pushl  -0x10(%ebp)
  80190b:	6a 00                	push   $0x0
  80190d:	e8 e2 f2 ff ff       	call   800bf4 <sys_page_alloc>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	85 c0                	test   %eax,%eax
  801919:	0f 88 c3 00 00 00    	js     8019e2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80191f:	83 ec 0c             	sub    $0xc,%esp
  801922:	ff 75 f4             	pushl  -0xc(%ebp)
  801925:	e8 cb f4 ff ff       	call   800df5 <fd2data>
  80192a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80192c:	83 c4 0c             	add    $0xc,%esp
  80192f:	68 07 04 00 00       	push   $0x407
  801934:	50                   	push   %eax
  801935:	6a 00                	push   $0x0
  801937:	e8 b8 f2 ff ff       	call   800bf4 <sys_page_alloc>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	85 c0                	test   %eax,%eax
  801943:	0f 88 89 00 00 00    	js     8019d2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801949:	83 ec 0c             	sub    $0xc,%esp
  80194c:	ff 75 f0             	pushl  -0x10(%ebp)
  80194f:	e8 a1 f4 ff ff       	call   800df5 <fd2data>
  801954:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80195b:	50                   	push   %eax
  80195c:	6a 00                	push   $0x0
  80195e:	56                   	push   %esi
  80195f:	6a 00                	push   $0x0
  801961:	e8 d1 f2 ff ff       	call   800c37 <sys_page_map>
  801966:	89 c3                	mov    %eax,%ebx
  801968:	83 c4 20             	add    $0x20,%esp
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 55                	js     8019c4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80196f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801975:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801978:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80197a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801984:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80198a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801992:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801999:	83 ec 0c             	sub    $0xc,%esp
  80199c:	ff 75 f4             	pushl  -0xc(%ebp)
  80199f:	e8 41 f4 ff ff       	call   800de5 <fd2num>
  8019a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019a9:	83 c4 04             	add    $0x4,%esp
  8019ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8019af:	e8 31 f4 ff ff       	call   800de5 <fd2num>
  8019b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019b7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c2:	eb 30                	jmp    8019f4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8019c4:	83 ec 08             	sub    $0x8,%esp
  8019c7:	56                   	push   %esi
  8019c8:	6a 00                	push   $0x0
  8019ca:	e8 aa f2 ff ff       	call   800c79 <sys_page_unmap>
  8019cf:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019d2:	83 ec 08             	sub    $0x8,%esp
  8019d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 9a f2 ff ff       	call   800c79 <sys_page_unmap>
  8019df:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019e2:	83 ec 08             	sub    $0x8,%esp
  8019e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e8:	6a 00                	push   $0x0
  8019ea:	e8 8a f2 ff ff       	call   800c79 <sys_page_unmap>
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019f4:	89 d0                	mov    %edx,%eax
  8019f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f9:	5b                   	pop    %ebx
  8019fa:	5e                   	pop    %esi
  8019fb:	5d                   	pop    %ebp
  8019fc:	c3                   	ret    

008019fd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a06:	50                   	push   %eax
  801a07:	ff 75 08             	pushl  0x8(%ebp)
  801a0a:	e8 4c f4 ff ff       	call   800e5b <fd_lookup>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 18                	js     801a2e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1c:	e8 d4 f3 ff ff       	call   800df5 <fd2data>
	return _pipeisclosed(fd, p);
  801a21:	89 c2                	mov    %eax,%edx
  801a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a26:	e8 21 fd ff ff       	call   80174c <_pipeisclosed>
  801a2b:	83 c4 10             	add    $0x10,%esp
}
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a33:	b8 00 00 00 00       	mov    $0x0,%eax
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    

00801a3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a40:	68 2c 24 80 00       	push   $0x80242c
  801a45:	ff 75 0c             	pushl  0xc(%ebp)
  801a48:	e8 a4 ed ff ff       	call   8007f1 <strcpy>
	return 0;
}
  801a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	57                   	push   %edi
  801a58:	56                   	push   %esi
  801a59:	53                   	push   %ebx
  801a5a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a60:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a65:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a6b:	eb 2d                	jmp    801a9a <devcons_write+0x46>
		m = n - tot;
  801a6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a70:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a72:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a75:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a7a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a7d:	83 ec 04             	sub    $0x4,%esp
  801a80:	53                   	push   %ebx
  801a81:	03 45 0c             	add    0xc(%ebp),%eax
  801a84:	50                   	push   %eax
  801a85:	57                   	push   %edi
  801a86:	e8 f8 ee ff ff       	call   800983 <memmove>
		sys_cputs(buf, m);
  801a8b:	83 c4 08             	add    $0x8,%esp
  801a8e:	53                   	push   %ebx
  801a8f:	57                   	push   %edi
  801a90:	e8 a3 f0 ff ff       	call   800b38 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a95:	01 de                	add    %ebx,%esi
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	89 f0                	mov    %esi,%eax
  801a9c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a9f:	72 cc                	jb     801a6d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801aa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5f                   	pop    %edi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	83 ec 08             	sub    $0x8,%esp
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ab4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ab8:	74 2a                	je     801ae4 <devcons_read+0x3b>
  801aba:	eb 05                	jmp    801ac1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801abc:	e8 14 f1 ff ff       	call   800bd5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ac1:	e8 90 f0 ff ff       	call   800b56 <sys_cgetc>
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	74 f2                	je     801abc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 16                	js     801ae4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ace:	83 f8 04             	cmp    $0x4,%eax
  801ad1:	74 0c                	je     801adf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ad6:	88 02                	mov    %al,(%edx)
	return 1;
  801ad8:	b8 01 00 00 00       	mov    $0x1,%eax
  801add:	eb 05                	jmp    801ae4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801af2:	6a 01                	push   $0x1
  801af4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801af7:	50                   	push   %eax
  801af8:	e8 3b f0 ff ff       	call   800b38 <sys_cputs>
}
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <getchar>:

int
getchar(void)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b08:	6a 01                	push   $0x1
  801b0a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b0d:	50                   	push   %eax
  801b0e:	6a 00                	push   $0x0
  801b10:	e8 ac f5 ff ff       	call   8010c1 <read>
	if (r < 0)
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	78 0f                	js     801b2b <getchar+0x29>
		return r;
	if (r < 1)
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	7e 06                	jle    801b26 <getchar+0x24>
		return -E_EOF;
	return c;
  801b20:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b24:	eb 05                	jmp    801b2b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b26:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b2b:	c9                   	leave  
  801b2c:	c3                   	ret    

00801b2d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b36:	50                   	push   %eax
  801b37:	ff 75 08             	pushl  0x8(%ebp)
  801b3a:	e8 1c f3 ff ff       	call   800e5b <fd_lookup>
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	85 c0                	test   %eax,%eax
  801b44:	78 11                	js     801b57 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b49:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b4f:	39 10                	cmp    %edx,(%eax)
  801b51:	0f 94 c0             	sete   %al
  801b54:	0f b6 c0             	movzbl %al,%eax
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <opencons>:

int
opencons(void)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b62:	50                   	push   %eax
  801b63:	e8 a4 f2 ff ff       	call   800e0c <fd_alloc>
  801b68:	83 c4 10             	add    $0x10,%esp
		return r;
  801b6b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	78 3e                	js     801baf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	68 07 04 00 00       	push   $0x407
  801b79:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7c:	6a 00                	push   $0x0
  801b7e:	e8 71 f0 ff ff       	call   800bf4 <sys_page_alloc>
  801b83:	83 c4 10             	add    $0x10,%esp
		return r;
  801b86:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 23                	js     801baf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b8c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b95:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ba1:	83 ec 0c             	sub    $0xc,%esp
  801ba4:	50                   	push   %eax
  801ba5:	e8 3b f2 ff ff       	call   800de5 <fd2num>
  801baa:	89 c2                	mov    %eax,%edx
  801bac:	83 c4 10             	add    $0x10,%esp
}
  801baf:	89 d0                	mov    %edx,%eax
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801bc1:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801bc3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bc8:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801bcb:	83 ec 0c             	sub    $0xc,%esp
  801bce:	50                   	push   %eax
  801bcf:	e8 d0 f1 ff ff       	call   800da4 <sys_ipc_recv>

	if (from_env_store != NULL)
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	74 14                	je     801bef <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  801be0:	85 c0                	test   %eax,%eax
  801be2:	78 09                	js     801bed <ipc_recv+0x3a>
  801be4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801bea:	8b 52 74             	mov    0x74(%edx),%edx
  801bed:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801bef:	85 db                	test   %ebx,%ebx
  801bf1:	74 14                	je     801c07 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	78 09                	js     801c05 <ipc_recv+0x52>
  801bfc:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801c02:	8b 52 78             	mov    0x78(%edx),%edx
  801c05:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 08                	js     801c13 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801c0b:	a1 20 60 80 00       	mov    0x806020,%eax
  801c10:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	57                   	push   %edi
  801c1e:	56                   	push   %esi
  801c1f:	53                   	push   %ebx
  801c20:	83 ec 0c             	sub    $0xc,%esp
  801c23:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c26:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801c2c:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801c2e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c33:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801c36:	ff 75 14             	pushl  0x14(%ebp)
  801c39:	53                   	push   %ebx
  801c3a:	56                   	push   %esi
  801c3b:	57                   	push   %edi
  801c3c:	e8 40 f1 ff ff       	call   800d81 <sys_ipc_try_send>

		if (err < 0) {
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	85 c0                	test   %eax,%eax
  801c46:	79 1e                	jns    801c66 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801c48:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c4b:	75 07                	jne    801c54 <ipc_send+0x3a>
				sys_yield();
  801c4d:	e8 83 ef ff ff       	call   800bd5 <sys_yield>
  801c52:	eb e2                	jmp    801c36 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801c54:	50                   	push   %eax
  801c55:	68 38 24 80 00       	push   $0x802438
  801c5a:	6a 49                	push   $0x49
  801c5c:	68 45 24 80 00       	push   $0x802445
  801c61:	e8 2d e5 ff ff       	call   800193 <_panic>
		}

	} while (err < 0);

}
  801c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c74:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c79:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c7c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c82:	8b 52 50             	mov    0x50(%edx),%edx
  801c85:	39 ca                	cmp    %ecx,%edx
  801c87:	75 0d                	jne    801c96 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c89:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c8c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c91:	8b 40 48             	mov    0x48(%eax),%eax
  801c94:	eb 0f                	jmp    801ca5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c96:	83 c0 01             	add    $0x1,%eax
  801c99:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c9e:	75 d9                	jne    801c79 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cad:	89 d0                	mov    %edx,%eax
  801caf:	c1 e8 16             	shr    $0x16,%eax
  801cb2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cbe:	f6 c1 01             	test   $0x1,%cl
  801cc1:	74 1d                	je     801ce0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cc3:	c1 ea 0c             	shr    $0xc,%edx
  801cc6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ccd:	f6 c2 01             	test   $0x1,%dl
  801cd0:	74 0e                	je     801ce0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cd2:	c1 ea 0c             	shr    $0xc,%edx
  801cd5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cdc:	ef 
  801cdd:	0f b7 c0             	movzwl %ax,%eax
}
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__udivdi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801cfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801cff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 f6                	test   %esi,%esi
  801d09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d0d:	89 ca                	mov    %ecx,%edx
  801d0f:	89 f8                	mov    %edi,%eax
  801d11:	75 3d                	jne    801d50 <__udivdi3+0x60>
  801d13:	39 cf                	cmp    %ecx,%edi
  801d15:	0f 87 c5 00 00 00    	ja     801de0 <__udivdi3+0xf0>
  801d1b:	85 ff                	test   %edi,%edi
  801d1d:	89 fd                	mov    %edi,%ebp
  801d1f:	75 0b                	jne    801d2c <__udivdi3+0x3c>
  801d21:	b8 01 00 00 00       	mov    $0x1,%eax
  801d26:	31 d2                	xor    %edx,%edx
  801d28:	f7 f7                	div    %edi
  801d2a:	89 c5                	mov    %eax,%ebp
  801d2c:	89 c8                	mov    %ecx,%eax
  801d2e:	31 d2                	xor    %edx,%edx
  801d30:	f7 f5                	div    %ebp
  801d32:	89 c1                	mov    %eax,%ecx
  801d34:	89 d8                	mov    %ebx,%eax
  801d36:	89 cf                	mov    %ecx,%edi
  801d38:	f7 f5                	div    %ebp
  801d3a:	89 c3                	mov    %eax,%ebx
  801d3c:	89 d8                	mov    %ebx,%eax
  801d3e:	89 fa                	mov    %edi,%edx
  801d40:	83 c4 1c             	add    $0x1c,%esp
  801d43:	5b                   	pop    %ebx
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    
  801d48:	90                   	nop
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	39 ce                	cmp    %ecx,%esi
  801d52:	77 74                	ja     801dc8 <__udivdi3+0xd8>
  801d54:	0f bd fe             	bsr    %esi,%edi
  801d57:	83 f7 1f             	xor    $0x1f,%edi
  801d5a:	0f 84 98 00 00 00    	je     801df8 <__udivdi3+0x108>
  801d60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d65:	89 f9                	mov    %edi,%ecx
  801d67:	89 c5                	mov    %eax,%ebp
  801d69:	29 fb                	sub    %edi,%ebx
  801d6b:	d3 e6                	shl    %cl,%esi
  801d6d:	89 d9                	mov    %ebx,%ecx
  801d6f:	d3 ed                	shr    %cl,%ebp
  801d71:	89 f9                	mov    %edi,%ecx
  801d73:	d3 e0                	shl    %cl,%eax
  801d75:	09 ee                	or     %ebp,%esi
  801d77:	89 d9                	mov    %ebx,%ecx
  801d79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d7d:	89 d5                	mov    %edx,%ebp
  801d7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d83:	d3 ed                	shr    %cl,%ebp
  801d85:	89 f9                	mov    %edi,%ecx
  801d87:	d3 e2                	shl    %cl,%edx
  801d89:	89 d9                	mov    %ebx,%ecx
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	09 c2                	or     %eax,%edx
  801d8f:	89 d0                	mov    %edx,%eax
  801d91:	89 ea                	mov    %ebp,%edx
  801d93:	f7 f6                	div    %esi
  801d95:	89 d5                	mov    %edx,%ebp
  801d97:	89 c3                	mov    %eax,%ebx
  801d99:	f7 64 24 0c          	mull   0xc(%esp)
  801d9d:	39 d5                	cmp    %edx,%ebp
  801d9f:	72 10                	jb     801db1 <__udivdi3+0xc1>
  801da1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801da5:	89 f9                	mov    %edi,%ecx
  801da7:	d3 e6                	shl    %cl,%esi
  801da9:	39 c6                	cmp    %eax,%esi
  801dab:	73 07                	jae    801db4 <__udivdi3+0xc4>
  801dad:	39 d5                	cmp    %edx,%ebp
  801daf:	75 03                	jne    801db4 <__udivdi3+0xc4>
  801db1:	83 eb 01             	sub    $0x1,%ebx
  801db4:	31 ff                	xor    %edi,%edi
  801db6:	89 d8                	mov    %ebx,%eax
  801db8:	89 fa                	mov    %edi,%edx
  801dba:	83 c4 1c             	add    $0x1c,%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5f                   	pop    %edi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    
  801dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc8:	31 ff                	xor    %edi,%edi
  801dca:	31 db                	xor    %ebx,%ebx
  801dcc:	89 d8                	mov    %ebx,%eax
  801dce:	89 fa                	mov    %edi,%edx
  801dd0:	83 c4 1c             	add    $0x1c,%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	5f                   	pop    %edi
  801dd6:	5d                   	pop    %ebp
  801dd7:	c3                   	ret    
  801dd8:	90                   	nop
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	89 d8                	mov    %ebx,%eax
  801de2:	f7 f7                	div    %edi
  801de4:	31 ff                	xor    %edi,%edi
  801de6:	89 c3                	mov    %eax,%ebx
  801de8:	89 d8                	mov    %ebx,%eax
  801dea:	89 fa                	mov    %edi,%edx
  801dec:	83 c4 1c             	add    $0x1c,%esp
  801def:	5b                   	pop    %ebx
  801df0:	5e                   	pop    %esi
  801df1:	5f                   	pop    %edi
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    
  801df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df8:	39 ce                	cmp    %ecx,%esi
  801dfa:	72 0c                	jb     801e08 <__udivdi3+0x118>
  801dfc:	31 db                	xor    %ebx,%ebx
  801dfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e02:	0f 87 34 ff ff ff    	ja     801d3c <__udivdi3+0x4c>
  801e08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e0d:	e9 2a ff ff ff       	jmp    801d3c <__udivdi3+0x4c>
  801e12:	66 90                	xchg   %ax,%ax
  801e14:	66 90                	xchg   %ax,%ax
  801e16:	66 90                	xchg   %ax,%ax
  801e18:	66 90                	xchg   %ax,%ax
  801e1a:	66 90                	xchg   %ax,%ax
  801e1c:	66 90                	xchg   %ax,%ax
  801e1e:	66 90                	xchg   %ax,%ax

00801e20 <__umoddi3>:
  801e20:	55                   	push   %ebp
  801e21:	57                   	push   %edi
  801e22:	56                   	push   %esi
  801e23:	53                   	push   %ebx
  801e24:	83 ec 1c             	sub    $0x1c,%esp
  801e27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e37:	85 d2                	test   %edx,%edx
  801e39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e41:	89 f3                	mov    %esi,%ebx
  801e43:	89 3c 24             	mov    %edi,(%esp)
  801e46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e4a:	75 1c                	jne    801e68 <__umoddi3+0x48>
  801e4c:	39 f7                	cmp    %esi,%edi
  801e4e:	76 50                	jbe    801ea0 <__umoddi3+0x80>
  801e50:	89 c8                	mov    %ecx,%eax
  801e52:	89 f2                	mov    %esi,%edx
  801e54:	f7 f7                	div    %edi
  801e56:	89 d0                	mov    %edx,%eax
  801e58:	31 d2                	xor    %edx,%edx
  801e5a:	83 c4 1c             	add    $0x1c,%esp
  801e5d:	5b                   	pop    %ebx
  801e5e:	5e                   	pop    %esi
  801e5f:	5f                   	pop    %edi
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    
  801e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e68:	39 f2                	cmp    %esi,%edx
  801e6a:	89 d0                	mov    %edx,%eax
  801e6c:	77 52                	ja     801ec0 <__umoddi3+0xa0>
  801e6e:	0f bd ea             	bsr    %edx,%ebp
  801e71:	83 f5 1f             	xor    $0x1f,%ebp
  801e74:	75 5a                	jne    801ed0 <__umoddi3+0xb0>
  801e76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e7a:	0f 82 e0 00 00 00    	jb     801f60 <__umoddi3+0x140>
  801e80:	39 0c 24             	cmp    %ecx,(%esp)
  801e83:	0f 86 d7 00 00 00    	jbe    801f60 <__umoddi3+0x140>
  801e89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e91:	83 c4 1c             	add    $0x1c,%esp
  801e94:	5b                   	pop    %ebx
  801e95:	5e                   	pop    %esi
  801e96:	5f                   	pop    %edi
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    
  801e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	85 ff                	test   %edi,%edi
  801ea2:	89 fd                	mov    %edi,%ebp
  801ea4:	75 0b                	jne    801eb1 <__umoddi3+0x91>
  801ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  801eab:	31 d2                	xor    %edx,%edx
  801ead:	f7 f7                	div    %edi
  801eaf:	89 c5                	mov    %eax,%ebp
  801eb1:	89 f0                	mov    %esi,%eax
  801eb3:	31 d2                	xor    %edx,%edx
  801eb5:	f7 f5                	div    %ebp
  801eb7:	89 c8                	mov    %ecx,%eax
  801eb9:	f7 f5                	div    %ebp
  801ebb:	89 d0                	mov    %edx,%eax
  801ebd:	eb 99                	jmp    801e58 <__umoddi3+0x38>
  801ebf:	90                   	nop
  801ec0:	89 c8                	mov    %ecx,%eax
  801ec2:	89 f2                	mov    %esi,%edx
  801ec4:	83 c4 1c             	add    $0x1c,%esp
  801ec7:	5b                   	pop    %ebx
  801ec8:	5e                   	pop    %esi
  801ec9:	5f                   	pop    %edi
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    
  801ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ed0:	8b 34 24             	mov    (%esp),%esi
  801ed3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ed8:	89 e9                	mov    %ebp,%ecx
  801eda:	29 ef                	sub    %ebp,%edi
  801edc:	d3 e0                	shl    %cl,%eax
  801ede:	89 f9                	mov    %edi,%ecx
  801ee0:	89 f2                	mov    %esi,%edx
  801ee2:	d3 ea                	shr    %cl,%edx
  801ee4:	89 e9                	mov    %ebp,%ecx
  801ee6:	09 c2                	or     %eax,%edx
  801ee8:	89 d8                	mov    %ebx,%eax
  801eea:	89 14 24             	mov    %edx,(%esp)
  801eed:	89 f2                	mov    %esi,%edx
  801eef:	d3 e2                	shl    %cl,%edx
  801ef1:	89 f9                	mov    %edi,%ecx
  801ef3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ef7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801efb:	d3 e8                	shr    %cl,%eax
  801efd:	89 e9                	mov    %ebp,%ecx
  801eff:	89 c6                	mov    %eax,%esi
  801f01:	d3 e3                	shl    %cl,%ebx
  801f03:	89 f9                	mov    %edi,%ecx
  801f05:	89 d0                	mov    %edx,%eax
  801f07:	d3 e8                	shr    %cl,%eax
  801f09:	89 e9                	mov    %ebp,%ecx
  801f0b:	09 d8                	or     %ebx,%eax
  801f0d:	89 d3                	mov    %edx,%ebx
  801f0f:	89 f2                	mov    %esi,%edx
  801f11:	f7 34 24             	divl   (%esp)
  801f14:	89 d6                	mov    %edx,%esi
  801f16:	d3 e3                	shl    %cl,%ebx
  801f18:	f7 64 24 04          	mull   0x4(%esp)
  801f1c:	39 d6                	cmp    %edx,%esi
  801f1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f22:	89 d1                	mov    %edx,%ecx
  801f24:	89 c3                	mov    %eax,%ebx
  801f26:	72 08                	jb     801f30 <__umoddi3+0x110>
  801f28:	75 11                	jne    801f3b <__umoddi3+0x11b>
  801f2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f2e:	73 0b                	jae    801f3b <__umoddi3+0x11b>
  801f30:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f34:	1b 14 24             	sbb    (%esp),%edx
  801f37:	89 d1                	mov    %edx,%ecx
  801f39:	89 c3                	mov    %eax,%ebx
  801f3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f3f:	29 da                	sub    %ebx,%edx
  801f41:	19 ce                	sbb    %ecx,%esi
  801f43:	89 f9                	mov    %edi,%ecx
  801f45:	89 f0                	mov    %esi,%eax
  801f47:	d3 e0                	shl    %cl,%eax
  801f49:	89 e9                	mov    %ebp,%ecx
  801f4b:	d3 ea                	shr    %cl,%edx
  801f4d:	89 e9                	mov    %ebp,%ecx
  801f4f:	d3 ee                	shr    %cl,%esi
  801f51:	09 d0                	or     %edx,%eax
  801f53:	89 f2                	mov    %esi,%edx
  801f55:	83 c4 1c             	add    $0x1c,%esp
  801f58:	5b                   	pop    %ebx
  801f59:	5e                   	pop    %esi
  801f5a:	5f                   	pop    %edi
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    
  801f5d:	8d 76 00             	lea    0x0(%esi),%esi
  801f60:	29 f9                	sub    %edi,%ecx
  801f62:	19 d6                	sbb    %edx,%esi
  801f64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f6c:	e9 18 ff ff ff       	jmp    801e89 <__umoddi3+0x69>
