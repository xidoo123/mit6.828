
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 00 23 80 00       	push   $0x802300
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 7b 23 80 00       	push   $0x80237b
  80005b:	6a 11                	push   $0x11
  80005d:	68 98 23 80 00       	push   $0x802398
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 20 23 80 00       	push   $0x802320
  80009b:	6a 16                	push   $0x16
  80009d:	68 98 23 80 00       	push   $0x802398
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 48 23 80 00       	push   $0x802348
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 a7 23 80 00       	push   $0x8023a7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 98 23 80 00       	push   $0x802398
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e7:	e8 73 0a 00 00       	call   800b5f <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 8d 0e 00 00       	call   800fba <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 e7 09 00 00       	call   800b1e <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 10 0a 00 00       	call   800b5f <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 c8 23 80 00       	push   $0x8023c8
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 2f 09 00 00       	call   800ae1 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 54 01 00 00       	call   80034c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 d4 08 00 00       	call   800ae1 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 f3 1d 00 00       	call   802070 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 e0 1e 00 00       	call   8021a0 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 eb 23 80 00 	movsbl 0x8023eb(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1b>
		*b->buf++ = ch;
  800323:	8d 4a 01             	lea    0x1(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	88 02                	mov    %al,(%edx)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800335:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800338:	50                   	push   %eax
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 05 00 00 00       	call   80034c <vprintfmt>
	va_end(ap);
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	eb 12                	jmp    800372 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 84 89 03 00 00    	je     8006f1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	53                   	push   %ebx
  80036c:	50                   	push   %eax
  80036d:	ff d6                	call   *%esi
  80036f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	83 c7 01             	add    $0x1,%edi
  800375:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e2                	jne    800360 <vprintfmt+0x14>
  80037e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800382:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800389:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 07                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8d 47 01             	lea    0x1(%edi),%eax
  8003a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ab:	0f b6 07             	movzbl (%edi),%eax
  8003ae:	0f b6 c8             	movzbl %al,%ecx
  8003b1:	83 e8 23             	sub    $0x23,%eax
  8003b4:	3c 55                	cmp    $0x55,%al
  8003b6:	0f 87 1a 03 00 00    	ja     8006d6 <vprintfmt+0x38a>
  8003bc:	0f b6 c0             	movzbl %al,%eax
  8003bf:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cd:	eb d6                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e7:	83 fa 09             	cmp    $0x9,%edx
  8003ea:	77 39                	ja     800425 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ef:	eb e9                	jmp    8003da <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800402:	eb 27                	jmp    80042b <vprintfmt+0xdf>
  800404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	0f 49 c8             	cmovns %eax,%ecx
  800411:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	eb 8c                	jmp    8003a5 <vprintfmt+0x59>
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800423:	eb 80                	jmp    8003a5 <vprintfmt+0x59>
  800425:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800428:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042f:	0f 89 70 ff ff ff    	jns    8003a5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800435:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800442:	e9 5e ff ff ff       	jmp    8003a5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044d:	e9 53 ff ff ff       	jmp    8003a5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	53                   	push   %ebx
  80045f:	ff 30                	pushl  (%eax)
  800461:	ff d6                	call   *%esi
			break;
  800463:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800469:	e9 04 ff ff ff       	jmp    800372 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	99                   	cltd   
  80047a:	31 d0                	xor    %edx,%eax
  80047c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047e:	83 f8 0f             	cmp    $0xf,%eax
  800481:	7f 0b                	jg     80048e <vprintfmt+0x142>
  800483:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	75 18                	jne    8004a6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048e:	50                   	push   %eax
  80048f:	68 03 24 80 00       	push   $0x802403
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 94 fe ff ff       	call   80032f <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a1:	e9 cc fe ff ff       	jmp    800372 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a6:	52                   	push   %edx
  8004a7:	68 b9 27 80 00       	push   $0x8027b9
  8004ac:	53                   	push   %ebx
  8004ad:	56                   	push   %esi
  8004ae:	e8 7c fe ff ff       	call   80032f <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b9:	e9 b4 fe ff ff       	jmp    800372 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	b8 fc 23 80 00       	mov    $0x8023fc,%eax
  8004d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 8e 94 00 00 00    	jle    800571 <vprintfmt+0x225>
  8004dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e1:	0f 84 98 00 00 00    	je     80057f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ed:	57                   	push   %edi
  8004ee:	e8 86 02 00 00       	call   800779 <strnlen>
  8004f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800508:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	eb 0f                	jmp    80051b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 e0             	pushl  -0x20(%ebp)
  800513:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <vprintfmt+0x1c0>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800525:	85 c9                	test   %ecx,%ecx
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 49 c1             	cmovns %ecx,%eax
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	89 cb                	mov    %ecx,%ebx
  80053c:	eb 4d                	jmp    80058b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800542:	74 1b                	je     80055f <vprintfmt+0x213>
  800544:	0f be c0             	movsbl %al,%eax
  800547:	83 e8 20             	sub    $0x20,%eax
  80054a:	83 f8 5e             	cmp    $0x5e,%eax
  80054d:	76 10                	jbe    80055f <vprintfmt+0x213>
					putch('?', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	6a 3f                	push   $0x3f
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 0d                	jmp    80056c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	52                   	push   %edx
  800566:	ff 55 08             	call   *0x8(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	83 eb 01             	sub    $0x1,%ebx
  80056f:	eb 1a                	jmp    80058b <vprintfmt+0x23f>
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	eb 0c                	jmp    80058b <vprintfmt+0x23f>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	83 c7 01             	add    $0x1,%edi
  80058e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800592:	0f be d0             	movsbl %al,%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	74 23                	je     8005bc <vprintfmt+0x270>
  800599:	85 f6                	test   %esi,%esi
  80059b:	78 a1                	js     80053e <vprintfmt+0x1f2>
  80059d:	83 ee 01             	sub    $0x1,%esi
  8005a0:	79 9c                	jns    80053e <vprintfmt+0x1f2>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	eb 18                	jmp    8005c4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 20                	push   $0x20
  8005b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	eb 08                	jmp    8005c4 <vprintfmt+0x278>
  8005bc:	89 df                	mov    %ebx,%edi
  8005be:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f e4                	jg     8005ac <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	e9 a2 fd ff ff       	jmp    800372 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 fa 01             	cmp    $0x1,%edx
  8005d3:	7e 16                	jle    8005eb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 08             	lea    0x8(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 50 04             	mov    0x4(%eax),%edx
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e9:	eb 32                	jmp    80061d <vprintfmt+0x2d1>
	else if (lflag)
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	74 18                	je     800607 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800605:	eb 16                	jmp    80061d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800615:	89 c1                	mov    %eax,%ecx
  800617:	c1 f9 1f             	sar    $0x1f,%ecx
  80061a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800620:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800623:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800628:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062c:	79 74                	jns    8006a2 <vprintfmt+0x356>
				putch('-', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 2d                	push   $0x2d
  800634:	ff d6                	call   *%esi
				num = -(long long) num;
  800636:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800639:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063c:	f7 d8                	neg    %eax
  80063e:	83 d2 00             	adc    $0x0,%edx
  800641:	f7 da                	neg    %edx
  800643:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800646:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064b:	eb 55                	jmp    8006a2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064d:	8d 45 14             	lea    0x14(%ebp),%eax
  800650:	e8 83 fc ff ff       	call   8002d8 <getuint>
			base = 10;
  800655:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065a:	eb 46                	jmp    8006a2 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	e8 74 fc ff ff       	call   8002d8 <getuint>
			base = 8;
  800664:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800669:	eb 37                	jmp    8006a2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 30                	push   $0x30
  800671:	ff d6                	call   *%esi
			putch('x', putdat);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 78                	push   $0x78
  800679:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800684:	8b 00                	mov    (%eax),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800693:	eb 0d                	jmp    8006a2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 3b fc ff ff       	call   8002d8 <getuint>
			base = 16;
  80069d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a2:	83 ec 0c             	sub    $0xc,%esp
  8006a5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a9:	57                   	push   %edi
  8006aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ad:	51                   	push   %ecx
  8006ae:	52                   	push   %edx
  8006af:	50                   	push   %eax
  8006b0:	89 da                	mov    %ebx,%edx
  8006b2:	89 f0                	mov    %esi,%eax
  8006b4:	e8 70 fb ff ff       	call   800229 <printnum>
			break;
  8006b9:	83 c4 20             	add    $0x20,%esp
  8006bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bf:	e9 ae fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	51                   	push   %ecx
  8006c9:	ff d6                	call   *%esi
			break;
  8006cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d1:	e9 9c fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	6a 25                	push   $0x25
  8006dc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 03                	jmp    8006e6 <vprintfmt+0x39a>
  8006e3:	83 ef 01             	sub    $0x1,%edi
  8006e6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ea:	75 f7                	jne    8006e3 <vprintfmt+0x397>
  8006ec:	e9 81 fc ff ff       	jmp    800372 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f4:	5b                   	pop    %ebx
  8006f5:	5e                   	pop    %esi
  8006f6:	5f                   	pop    %edi
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	83 ec 18             	sub    $0x18,%esp
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800705:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800708:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800716:	85 c0                	test   %eax,%eax
  800718:	74 26                	je     800740 <vsnprintf+0x47>
  80071a:	85 d2                	test   %edx,%edx
  80071c:	7e 22                	jle    800740 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071e:	ff 75 14             	pushl  0x14(%ebp)
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	68 12 03 80 00       	push   $0x800312
  80072d:	e8 1a fc ff ff       	call   80034c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800732:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800735:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	eb 05                	jmp    800745 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800740:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800750:	50                   	push   %eax
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	ff 75 0c             	pushl  0xc(%ebp)
  800757:	ff 75 08             	pushl  0x8(%ebp)
  80075a:	e8 9a ff ff ff       	call   8006f9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
  80076c:	eb 03                	jmp    800771 <strlen+0x10>
		n++;
  80076e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800771:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800775:	75 f7                	jne    80076e <strlen+0xd>
		n++;
	return n;
}
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800782:	ba 00 00 00 00       	mov    $0x0,%edx
  800787:	eb 03                	jmp    80078c <strnlen+0x13>
		n++;
  800789:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 08                	je     800798 <strnlen+0x1f>
  800790:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800794:	75 f3                	jne    800789 <strnlen+0x10>
  800796:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	53                   	push   %ebx
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	83 c2 01             	add    $0x1,%edx
  8007a9:	83 c1 01             	add    $0x1,%ecx
  8007ac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 ef                	jne    8007a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b7:	5b                   	pop    %ebx
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c1:	53                   	push   %ebx
  8007c2:	e8 9a ff ff ff       	call   800761 <strlen>
  8007c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ca:	ff 75 0c             	pushl  0xc(%ebp)
  8007cd:	01 d8                	add    %ebx,%eax
  8007cf:	50                   	push   %eax
  8007d0:	e8 c5 ff ff ff       	call   80079a <strcpy>
	return dst;
}
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	89 f3                	mov    %esi,%ebx
  8007e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	89 f2                	mov    %esi,%edx
  8007ee:	eb 0f                	jmp    8007ff <strncpy+0x23>
		*dst++ = *src;
  8007f0:	83 c2 01             	add    $0x1,%edx
  8007f3:	0f b6 01             	movzbl (%ecx),%eax
  8007f6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ff:	39 da                	cmp    %ebx,%edx
  800801:	75 ed                	jne    8007f0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800803:	89 f0                	mov    %esi,%eax
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800814:	8b 55 10             	mov    0x10(%ebp),%edx
  800817:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 21                	je     80083e <strlcpy+0x35>
  80081d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800821:	89 f2                	mov    %esi,%edx
  800823:	eb 09                	jmp    80082e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800825:	83 c2 01             	add    $0x1,%edx
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082e:	39 c2                	cmp    %eax,%edx
  800830:	74 09                	je     80083b <strlcpy+0x32>
  800832:	0f b6 19             	movzbl (%ecx),%ebx
  800835:	84 db                	test   %bl,%bl
  800837:	75 ec                	jne    800825 <strlcpy+0x1c>
  800839:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083e:	29 f0                	sub    %esi,%eax
}
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084d:	eb 06                	jmp    800855 <strcmp+0x11>
		p++, q++;
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800855:	0f b6 01             	movzbl (%ecx),%eax
  800858:	84 c0                	test   %al,%al
  80085a:	74 04                	je     800860 <strcmp+0x1c>
  80085c:	3a 02                	cmp    (%edx),%al
  80085e:	74 ef                	je     80084f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800860:	0f b6 c0             	movzbl %al,%eax
  800863:	0f b6 12             	movzbl (%edx),%edx
  800866:	29 d0                	sub    %edx,%eax
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
  800874:	89 c3                	mov    %eax,%ebx
  800876:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800879:	eb 06                	jmp    800881 <strncmp+0x17>
		n--, p++, q++;
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800881:	39 d8                	cmp    %ebx,%eax
  800883:	74 15                	je     80089a <strncmp+0x30>
  800885:	0f b6 08             	movzbl (%eax),%ecx
  800888:	84 c9                	test   %cl,%cl
  80088a:	74 04                	je     800890 <strncmp+0x26>
  80088c:	3a 0a                	cmp    (%edx),%cl
  80088e:	74 eb                	je     80087b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800890:	0f b6 00             	movzbl (%eax),%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
  800898:	eb 05                	jmp    80089f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089f:	5b                   	pop    %ebx
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ac:	eb 07                	jmp    8008b5 <strchr+0x13>
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 0f                	je     8008c1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 10             	movzbl (%eax),%edx
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	75 f2                	jne    8008ae <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cd:	eb 03                	jmp    8008d2 <strfind+0xf>
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 04                	je     8008dd <strfind+0x1a>
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	75 f2                	jne    8008cf <strfind+0xc>
			break;
	return (char *) s;
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	74 36                	je     800925 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f5:	75 28                	jne    80091f <memset+0x40>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 23                	jne    80091f <memset+0x40>
		c &= 0xFF;
  8008fc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800900:	89 d3                	mov    %edx,%ebx
  800902:	c1 e3 08             	shl    $0x8,%ebx
  800905:	89 d6                	mov    %edx,%esi
  800907:	c1 e6 18             	shl    $0x18,%esi
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	c1 e0 10             	shl    $0x10,%eax
  80090f:	09 f0                	or     %esi,%eax
  800911:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800913:	89 d8                	mov    %ebx,%eax
  800915:	09 d0                	or     %edx,%eax
  800917:	c1 e9 02             	shr    $0x2,%ecx
  80091a:	fc                   	cld    
  80091b:	f3 ab                	rep stos %eax,%es:(%edi)
  80091d:	eb 06                	jmp    800925 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	fc                   	cld    
  800923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800925:	89 f8                	mov    %edi,%eax
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	57                   	push   %edi
  800930:	56                   	push   %esi
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093a:	39 c6                	cmp    %eax,%esi
  80093c:	73 35                	jae    800973 <memmove+0x47>
  80093e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800941:	39 d0                	cmp    %edx,%eax
  800943:	73 2e                	jae    800973 <memmove+0x47>
		s += n;
		d += n;
  800945:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	89 d6                	mov    %edx,%esi
  80094a:	09 fe                	or     %edi,%esi
  80094c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800952:	75 13                	jne    800967 <memmove+0x3b>
  800954:	f6 c1 03             	test   $0x3,%cl
  800957:	75 0e                	jne    800967 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800959:	83 ef 04             	sub    $0x4,%edi
  80095c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095f:	c1 e9 02             	shr    $0x2,%ecx
  800962:	fd                   	std    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 09                	jmp    800970 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800967:	83 ef 01             	sub    $0x1,%edi
  80096a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096d:	fd                   	std    
  80096e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800970:	fc                   	cld    
  800971:	eb 1d                	jmp    800990 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	89 f2                	mov    %esi,%edx
  800975:	09 c2                	or     %eax,%edx
  800977:	f6 c2 03             	test   $0x3,%dl
  80097a:	75 0f                	jne    80098b <memmove+0x5f>
  80097c:	f6 c1 03             	test   $0x3,%cl
  80097f:	75 0a                	jne    80098b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800981:	c1 e9 02             	shr    $0x2,%ecx
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb 05                	jmp    800990 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098b:	89 c7                	mov    %eax,%edi
  80098d:	fc                   	cld    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800997:	ff 75 10             	pushl  0x10(%ebp)
  80099a:	ff 75 0c             	pushl  0xc(%ebp)
  80099d:	ff 75 08             	pushl  0x8(%ebp)
  8009a0:	e8 87 ff ff ff       	call   80092c <memmove>
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b2:	89 c6                	mov    %eax,%esi
  8009b4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	eb 1a                	jmp    8009d3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b9:	0f b6 08             	movzbl (%eax),%ecx
  8009bc:	0f b6 1a             	movzbl (%edx),%ebx
  8009bf:	38 d9                	cmp    %bl,%cl
  8009c1:	74 0a                	je     8009cd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c3:	0f b6 c1             	movzbl %cl,%eax
  8009c6:	0f b6 db             	movzbl %bl,%ebx
  8009c9:	29 d8                	sub    %ebx,%eax
  8009cb:	eb 0f                	jmp    8009dc <memcmp+0x35>
		s1++, s2++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	39 f0                	cmp    %esi,%eax
  8009d5:	75 e2                	jne    8009b9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	53                   	push   %ebx
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e7:	89 c1                	mov    %eax,%ecx
  8009e9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ec:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f0:	eb 0a                	jmp    8009fc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f2:	0f b6 10             	movzbl (%eax),%edx
  8009f5:	39 da                	cmp    %ebx,%edx
  8009f7:	74 07                	je     800a00 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	39 c8                	cmp    %ecx,%eax
  8009fe:	72 f2                	jb     8009f2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a00:	5b                   	pop    %ebx
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	eb 03                	jmp    800a14 <strtol+0x11>
		s++;
  800a11:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a14:	0f b6 01             	movzbl (%ecx),%eax
  800a17:	3c 20                	cmp    $0x20,%al
  800a19:	74 f6                	je     800a11 <strtol+0xe>
  800a1b:	3c 09                	cmp    $0x9,%al
  800a1d:	74 f2                	je     800a11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1f:	3c 2b                	cmp    $0x2b,%al
  800a21:	75 0a                	jne    800a2d <strtol+0x2a>
		s++;
  800a23:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2b:	eb 11                	jmp    800a3e <strtol+0x3b>
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a32:	3c 2d                	cmp    $0x2d,%al
  800a34:	75 08                	jne    800a3e <strtol+0x3b>
		s++, neg = 1;
  800a36:	83 c1 01             	add    $0x1,%ecx
  800a39:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a44:	75 15                	jne    800a5b <strtol+0x58>
  800a46:	80 39 30             	cmpb   $0x30,(%ecx)
  800a49:	75 10                	jne    800a5b <strtol+0x58>
  800a4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4f:	75 7c                	jne    800acd <strtol+0xca>
		s += 2, base = 16;
  800a51:	83 c1 02             	add    $0x2,%ecx
  800a54:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a59:	eb 16                	jmp    800a71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5b:	85 db                	test   %ebx,%ebx
  800a5d:	75 12                	jne    800a71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a64:	80 39 30             	cmpb   $0x30,(%ecx)
  800a67:	75 08                	jne    800a71 <strtol+0x6e>
		s++, base = 8;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a79:	0f b6 11             	movzbl (%ecx),%edx
  800a7c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 09             	cmp    $0x9,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x8b>
			dig = *s - '0';
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 30             	sub    $0x30,%edx
  800a8c:	eb 22                	jmp    800ab0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 19             	cmp    $0x19,%bl
  800a96:	77 08                	ja     800aa0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 57             	sub    $0x57,%edx
  800a9e:	eb 10                	jmp    800ab0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 16                	ja     800ac0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab3:	7d 0b                	jge    800ac0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab5:	83 c1 01             	add    $0x1,%ecx
  800ab8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abe:	eb b9                	jmp    800a79 <strtol+0x76>

	if (endptr)
  800ac0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac4:	74 0d                	je     800ad3 <strtol+0xd0>
		*endptr = (char *) s;
  800ac6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac9:	89 0e                	mov    %ecx,(%esi)
  800acb:	eb 06                	jmp    800ad3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	74 98                	je     800a69 <strtol+0x66>
  800ad1:	eb 9e                	jmp    800a71 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad3:	89 c2                	mov    %eax,%edx
  800ad5:	f7 da                	neg    %edx
  800ad7:	85 ff                	test   %edi,%edi
  800ad9:	0f 45 c2             	cmovne %edx,%eax
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_cgetc>:

int
sys_cgetc(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0f:	89 d1                	mov    %edx,%ecx
  800b11:	89 d3                	mov    %edx,%ebx
  800b13:	89 d7                	mov    %edx,%edi
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	89 cb                	mov    %ecx,%ebx
  800b36:	89 cf                	mov    %ecx,%edi
  800b38:	89 ce                	mov    %ecx,%esi
  800b3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 03                	push   $0x3
  800b46:	68 df 26 80 00       	push   $0x8026df
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 fc 26 80 00       	push   $0x8026fc
  800b52:	e8 e5 f5 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_yield>:

void
sys_yield(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	be 00 00 00 00       	mov    $0x0,%esi
  800bab:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb9:	89 f7                	mov    %esi,%edi
  800bbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 04                	push   $0x4
  800bc7:	68 df 26 80 00       	push   $0x8026df
  800bcc:	6a 23                	push   $0x23
  800bce:	68 fc 26 80 00       	push   $0x8026fc
  800bd3:	e8 64 f5 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfa:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 05                	push   $0x5
  800c09:	68 df 26 80 00       	push   $0x8026df
  800c0e:	6a 23                	push   $0x23
  800c10:	68 fc 26 80 00       	push   $0x8026fc
  800c15:	e8 22 f5 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c30:	b8 06 00 00 00       	mov    $0x6,%eax
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	89 df                	mov    %ebx,%edi
  800c3d:	89 de                	mov    %ebx,%esi
  800c3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 17                	jle    800c5c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 06                	push   $0x6
  800c4b:	68 df 26 80 00       	push   $0x8026df
  800c50:	6a 23                	push   $0x23
  800c52:	68 fc 26 80 00       	push   $0x8026fc
  800c57:	e8 e0 f4 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	b8 08 00 00 00       	mov    $0x8,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 17                	jle    800c9e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 08                	push   $0x8
  800c8d:	68 df 26 80 00       	push   $0x8026df
  800c92:	6a 23                	push   $0x23
  800c94:	68 fc 26 80 00       	push   $0x8026fc
  800c99:	e8 9e f4 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 09                	push   $0x9
  800ccf:	68 df 26 80 00       	push   $0x8026df
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 fc 26 80 00       	push   $0x8026fc
  800cdb:	e8 5c f4 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 df                	mov    %ebx,%edi
  800d03:	89 de                	mov    %ebx,%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0a                	push   $0xa
  800d11:	68 df 26 80 00       	push   $0x8026df
  800d16:	6a 23                	push   $0x23
  800d18:	68 fc 26 80 00       	push   $0x8026fc
  800d1d:	e8 1a f4 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	be 00 00 00 00       	mov    $0x0,%esi
  800d35:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d43:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d46:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 cb                	mov    %ecx,%ebx
  800d65:	89 cf                	mov    %ecx,%edi
  800d67:	89 ce                	mov    %ecx,%esi
  800d69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 0d                	push   $0xd
  800d75:	68 df 26 80 00       	push   $0x8026df
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 fc 26 80 00       	push   $0x8026fc
  800d81:	e8 b6 f3 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	ba 00 00 00 00       	mov    $0x0,%edx
  800d99:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9e:	89 d1                	mov    %edx,%ecx
  800da0:	89 d3                	mov    %edx,%ebx
  800da2:	89 d7                	mov    %edx,%edi
  800da4:	89 d6                	mov    %edx,%esi
  800da6:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 17                	jle    800de7 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	50                   	push   %eax
  800dd4:	6a 0f                	push   $0xf
  800dd6:	68 df 26 80 00       	push   $0x8026df
  800ddb:	6a 23                	push   $0x23
  800ddd:	68 fc 26 80 00       	push   $0x8026fc
  800de2:	e8 55 f3 ff ff       	call   80013c <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
  800df5:	05 00 00 00 30       	add    $0x30000000,%eax
  800dfa:	c1 e8 0c             	shr    $0xc,%eax
}
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e0f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e21:	89 c2                	mov    %eax,%edx
  800e23:	c1 ea 16             	shr    $0x16,%edx
  800e26:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2d:	f6 c2 01             	test   $0x1,%dl
  800e30:	74 11                	je     800e43 <fd_alloc+0x2d>
  800e32:	89 c2                	mov    %eax,%edx
  800e34:	c1 ea 0c             	shr    $0xc,%edx
  800e37:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3e:	f6 c2 01             	test   $0x1,%dl
  800e41:	75 09                	jne    800e4c <fd_alloc+0x36>
			*fd_store = fd;
  800e43:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e45:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4a:	eb 17                	jmp    800e63 <fd_alloc+0x4d>
  800e4c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e51:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e56:	75 c9                	jne    800e21 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e58:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e5e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e6b:	83 f8 1f             	cmp    $0x1f,%eax
  800e6e:	77 36                	ja     800ea6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e70:	c1 e0 0c             	shl    $0xc,%eax
  800e73:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e78:	89 c2                	mov    %eax,%edx
  800e7a:	c1 ea 16             	shr    $0x16,%edx
  800e7d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e84:	f6 c2 01             	test   $0x1,%dl
  800e87:	74 24                	je     800ead <fd_lookup+0x48>
  800e89:	89 c2                	mov    %eax,%edx
  800e8b:	c1 ea 0c             	shr    $0xc,%edx
  800e8e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e95:	f6 c2 01             	test   $0x1,%dl
  800e98:	74 1a                	je     800eb4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9d:	89 02                	mov    %eax,(%edx)
	return 0;
  800e9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea4:	eb 13                	jmp    800eb9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eab:	eb 0c                	jmp    800eb9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ead:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb2:	eb 05                	jmp    800eb9 <fd_lookup+0x54>
  800eb4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 08             	sub    $0x8,%esp
  800ec1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec4:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec9:	eb 13                	jmp    800ede <dev_lookup+0x23>
  800ecb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ece:	39 08                	cmp    %ecx,(%eax)
  800ed0:	75 0c                	jne    800ede <dev_lookup+0x23>
			*dev = devtab[i];
  800ed2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed7:	b8 00 00 00 00       	mov    $0x0,%eax
  800edc:	eb 2e                	jmp    800f0c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ede:	8b 02                	mov    (%edx),%eax
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	75 e7                	jne    800ecb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ee4:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800ee9:	8b 40 48             	mov    0x48(%eax),%eax
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	51                   	push   %ecx
  800ef0:	50                   	push   %eax
  800ef1:	68 0c 27 80 00       	push   $0x80270c
  800ef6:	e8 1a f3 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800efb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f04:	83 c4 10             	add    $0x10,%esp
  800f07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f0c:	c9                   	leave  
  800f0d:	c3                   	ret    

00800f0e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	83 ec 10             	sub    $0x10,%esp
  800f16:	8b 75 08             	mov    0x8(%ebp),%esi
  800f19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1f:	50                   	push   %eax
  800f20:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f26:	c1 e8 0c             	shr    $0xc,%eax
  800f29:	50                   	push   %eax
  800f2a:	e8 36 ff ff ff       	call   800e65 <fd_lookup>
  800f2f:	83 c4 08             	add    $0x8,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	78 05                	js     800f3b <fd_close+0x2d>
	    || fd != fd2)
  800f36:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f39:	74 0c                	je     800f47 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f3b:	84 db                	test   %bl,%bl
  800f3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f42:	0f 44 c2             	cmove  %edx,%eax
  800f45:	eb 41                	jmp    800f88 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f47:	83 ec 08             	sub    $0x8,%esp
  800f4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f4d:	50                   	push   %eax
  800f4e:	ff 36                	pushl  (%esi)
  800f50:	e8 66 ff ff ff       	call   800ebb <dev_lookup>
  800f55:	89 c3                	mov    %eax,%ebx
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	78 1a                	js     800f78 <fd_close+0x6a>
		if (dev->dev_close)
  800f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f61:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f64:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	74 0b                	je     800f78 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	56                   	push   %esi
  800f71:	ff d0                	call   *%eax
  800f73:	89 c3                	mov    %eax,%ebx
  800f75:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f78:	83 ec 08             	sub    $0x8,%esp
  800f7b:	56                   	push   %esi
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 9f fc ff ff       	call   800c22 <sys_page_unmap>
	return r;
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	89 d8                	mov    %ebx,%eax
}
  800f88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5e                   	pop    %esi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	ff 75 08             	pushl  0x8(%ebp)
  800f9c:	e8 c4 fe ff ff       	call   800e65 <fd_lookup>
  800fa1:	83 c4 08             	add    $0x8,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 10                	js     800fb8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	6a 01                	push   $0x1
  800fad:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb0:	e8 59 ff ff ff       	call   800f0e <fd_close>
  800fb5:	83 c4 10             	add    $0x10,%esp
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <close_all>:

void
close_all(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	53                   	push   %ebx
  800fbe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	53                   	push   %ebx
  800fca:	e8 c0 ff ff ff       	call   800f8f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fcf:	83 c3 01             	add    $0x1,%ebx
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	83 fb 20             	cmp    $0x20,%ebx
  800fd8:	75 ec                	jne    800fc6 <close_all+0xc>
		close(i);
}
  800fda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	57                   	push   %edi
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 2c             	sub    $0x2c,%esp
  800fe8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800feb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fee:	50                   	push   %eax
  800fef:	ff 75 08             	pushl  0x8(%ebp)
  800ff2:	e8 6e fe ff ff       	call   800e65 <fd_lookup>
  800ff7:	83 c4 08             	add    $0x8,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	0f 88 c1 00 00 00    	js     8010c3 <dup+0xe4>
		return r;
	close(newfdnum);
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	56                   	push   %esi
  801006:	e8 84 ff ff ff       	call   800f8f <close>

	newfd = INDEX2FD(newfdnum);
  80100b:	89 f3                	mov    %esi,%ebx
  80100d:	c1 e3 0c             	shl    $0xc,%ebx
  801010:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801016:	83 c4 04             	add    $0x4,%esp
  801019:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101c:	e8 de fd ff ff       	call   800dff <fd2data>
  801021:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801023:	89 1c 24             	mov    %ebx,(%esp)
  801026:	e8 d4 fd ff ff       	call   800dff <fd2data>
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801031:	89 f8                	mov    %edi,%eax
  801033:	c1 e8 16             	shr    $0x16,%eax
  801036:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103d:	a8 01                	test   $0x1,%al
  80103f:	74 37                	je     801078 <dup+0x99>
  801041:	89 f8                	mov    %edi,%eax
  801043:	c1 e8 0c             	shr    $0xc,%eax
  801046:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104d:	f6 c2 01             	test   $0x1,%dl
  801050:	74 26                	je     801078 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801052:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	25 07 0e 00 00       	and    $0xe07,%eax
  801061:	50                   	push   %eax
  801062:	ff 75 d4             	pushl  -0x2c(%ebp)
  801065:	6a 00                	push   $0x0
  801067:	57                   	push   %edi
  801068:	6a 00                	push   $0x0
  80106a:	e8 71 fb ff ff       	call   800be0 <sys_page_map>
  80106f:	89 c7                	mov    %eax,%edi
  801071:	83 c4 20             	add    $0x20,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	78 2e                	js     8010a6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801078:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80107b:	89 d0                	mov    %edx,%eax
  80107d:	c1 e8 0c             	shr    $0xc,%eax
  801080:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	25 07 0e 00 00       	and    $0xe07,%eax
  80108f:	50                   	push   %eax
  801090:	53                   	push   %ebx
  801091:	6a 00                	push   $0x0
  801093:	52                   	push   %edx
  801094:	6a 00                	push   $0x0
  801096:	e8 45 fb ff ff       	call   800be0 <sys_page_map>
  80109b:	89 c7                	mov    %eax,%edi
  80109d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010a0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a2:	85 ff                	test   %edi,%edi
  8010a4:	79 1d                	jns    8010c3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	53                   	push   %ebx
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 71 fb ff ff       	call   800c22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b1:	83 c4 08             	add    $0x8,%esp
  8010b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 64 fb ff ff       	call   800c22 <sys_page_unmap>
	return r;
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	89 f8                	mov    %edi,%eax
}
  8010c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	53                   	push   %ebx
  8010cf:	83 ec 14             	sub    $0x14,%esp
  8010d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d8:	50                   	push   %eax
  8010d9:	53                   	push   %ebx
  8010da:	e8 86 fd ff ff       	call   800e65 <fd_lookup>
  8010df:	83 c4 08             	add    $0x8,%esp
  8010e2:	89 c2                	mov    %eax,%edx
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	78 6d                	js     801155 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e8:	83 ec 08             	sub    $0x8,%esp
  8010eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ee:	50                   	push   %eax
  8010ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f2:	ff 30                	pushl  (%eax)
  8010f4:	e8 c2 fd ff ff       	call   800ebb <dev_lookup>
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	78 4c                	js     80114c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801100:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801103:	8b 42 08             	mov    0x8(%edx),%eax
  801106:	83 e0 03             	and    $0x3,%eax
  801109:	83 f8 01             	cmp    $0x1,%eax
  80110c:	75 21                	jne    80112f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80110e:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801113:	8b 40 48             	mov    0x48(%eax),%eax
  801116:	83 ec 04             	sub    $0x4,%esp
  801119:	53                   	push   %ebx
  80111a:	50                   	push   %eax
  80111b:	68 50 27 80 00       	push   $0x802750
  801120:	e8 f0 f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80112d:	eb 26                	jmp    801155 <read+0x8a>
	}
	if (!dev->dev_read)
  80112f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801132:	8b 40 08             	mov    0x8(%eax),%eax
  801135:	85 c0                	test   %eax,%eax
  801137:	74 17                	je     801150 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801139:	83 ec 04             	sub    $0x4,%esp
  80113c:	ff 75 10             	pushl  0x10(%ebp)
  80113f:	ff 75 0c             	pushl  0xc(%ebp)
  801142:	52                   	push   %edx
  801143:	ff d0                	call   *%eax
  801145:	89 c2                	mov    %eax,%edx
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	eb 09                	jmp    801155 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114c:	89 c2                	mov    %eax,%edx
  80114e:	eb 05                	jmp    801155 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801150:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801155:	89 d0                	mov    %edx,%eax
  801157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    

0080115c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
  801162:	83 ec 0c             	sub    $0xc,%esp
  801165:	8b 7d 08             	mov    0x8(%ebp),%edi
  801168:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801170:	eb 21                	jmp    801193 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	89 f0                	mov    %esi,%eax
  801177:	29 d8                	sub    %ebx,%eax
  801179:	50                   	push   %eax
  80117a:	89 d8                	mov    %ebx,%eax
  80117c:	03 45 0c             	add    0xc(%ebp),%eax
  80117f:	50                   	push   %eax
  801180:	57                   	push   %edi
  801181:	e8 45 ff ff ff       	call   8010cb <read>
		if (m < 0)
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	78 10                	js     80119d <readn+0x41>
			return m;
		if (m == 0)
  80118d:	85 c0                	test   %eax,%eax
  80118f:	74 0a                	je     80119b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801191:	01 c3                	add    %eax,%ebx
  801193:	39 f3                	cmp    %esi,%ebx
  801195:	72 db                	jb     801172 <readn+0x16>
  801197:	89 d8                	mov    %ebx,%eax
  801199:	eb 02                	jmp    80119d <readn+0x41>
  80119b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80119d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 14             	sub    $0x14,%esp
  8011ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	53                   	push   %ebx
  8011b4:	e8 ac fc ff ff       	call   800e65 <fd_lookup>
  8011b9:	83 c4 08             	add    $0x8,%esp
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 68                	js     80122a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c2:	83 ec 08             	sub    $0x8,%esp
  8011c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cc:	ff 30                	pushl  (%eax)
  8011ce:	e8 e8 fc ff ff       	call   800ebb <dev_lookup>
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 47                	js     801221 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e1:	75 21                	jne    801204 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e3:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011e8:	8b 40 48             	mov    0x48(%eax),%eax
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	53                   	push   %ebx
  8011ef:	50                   	push   %eax
  8011f0:	68 6c 27 80 00       	push   $0x80276c
  8011f5:	e8 1b f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801202:	eb 26                	jmp    80122a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801204:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801207:	8b 52 0c             	mov    0xc(%edx),%edx
  80120a:	85 d2                	test   %edx,%edx
  80120c:	74 17                	je     801225 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	ff 75 10             	pushl  0x10(%ebp)
  801214:	ff 75 0c             	pushl  0xc(%ebp)
  801217:	50                   	push   %eax
  801218:	ff d2                	call   *%edx
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	eb 09                	jmp    80122a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801221:	89 c2                	mov    %eax,%edx
  801223:	eb 05                	jmp    80122a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801225:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80122a:	89 d0                	mov    %edx,%eax
  80122c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122f:	c9                   	leave  
  801230:	c3                   	ret    

00801231 <seek>:

int
seek(int fdnum, off_t offset)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801237:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	ff 75 08             	pushl  0x8(%ebp)
  80123e:	e8 22 fc ff ff       	call   800e65 <fd_lookup>
  801243:	83 c4 08             	add    $0x8,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 0e                	js     801258 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80124a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80124d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801250:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	53                   	push   %ebx
  80125e:	83 ec 14             	sub    $0x14,%esp
  801261:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	53                   	push   %ebx
  801269:	e8 f7 fb ff ff       	call   800e65 <fd_lookup>
  80126e:	83 c4 08             	add    $0x8,%esp
  801271:	89 c2                	mov    %eax,%edx
  801273:	85 c0                	test   %eax,%eax
  801275:	78 65                	js     8012dc <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	ff 30                	pushl  (%eax)
  801283:	e8 33 fc ff ff       	call   800ebb <dev_lookup>
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 44                	js     8012d3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801292:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801296:	75 21                	jne    8012b9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801298:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	53                   	push   %ebx
  8012a4:	50                   	push   %eax
  8012a5:	68 2c 27 80 00       	push   $0x80272c
  8012aa:	e8 66 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b7:	eb 23                	jmp    8012dc <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bc:	8b 52 18             	mov    0x18(%edx),%edx
  8012bf:	85 d2                	test   %edx,%edx
  8012c1:	74 14                	je     8012d7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	ff 75 0c             	pushl  0xc(%ebp)
  8012c9:	50                   	push   %eax
  8012ca:	ff d2                	call   *%edx
  8012cc:	89 c2                	mov    %eax,%edx
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	eb 09                	jmp    8012dc <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	eb 05                	jmp    8012dc <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012dc:	89 d0                	mov    %edx,%eax
  8012de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e1:	c9                   	leave  
  8012e2:	c3                   	ret    

008012e3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 14             	sub    $0x14,%esp
  8012ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	ff 75 08             	pushl  0x8(%ebp)
  8012f4:	e8 6c fb ff ff       	call   800e65 <fd_lookup>
  8012f9:	83 c4 08             	add    $0x8,%esp
  8012fc:	89 c2                	mov    %eax,%edx
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 58                	js     80135a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801308:	50                   	push   %eax
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	ff 30                	pushl  (%eax)
  80130e:	e8 a8 fb ff ff       	call   800ebb <dev_lookup>
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 37                	js     801351 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80131a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801321:	74 32                	je     801355 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801323:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801326:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80132d:	00 00 00 
	stat->st_isdir = 0;
  801330:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801337:	00 00 00 
	stat->st_dev = dev;
  80133a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	53                   	push   %ebx
  801344:	ff 75 f0             	pushl  -0x10(%ebp)
  801347:	ff 50 14             	call   *0x14(%eax)
  80134a:	89 c2                	mov    %eax,%edx
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	eb 09                	jmp    80135a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801351:	89 c2                	mov    %eax,%edx
  801353:	eb 05                	jmp    80135a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801355:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80135a:	89 d0                	mov    %edx,%eax
  80135c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	56                   	push   %esi
  801365:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	6a 00                	push   $0x0
  80136b:	ff 75 08             	pushl  0x8(%ebp)
  80136e:	e8 d6 01 00 00       	call   801549 <open>
  801373:	89 c3                	mov    %eax,%ebx
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 1b                	js     801397 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	ff 75 0c             	pushl  0xc(%ebp)
  801382:	50                   	push   %eax
  801383:	e8 5b ff ff ff       	call   8012e3 <fstat>
  801388:	89 c6                	mov    %eax,%esi
	close(fd);
  80138a:	89 1c 24             	mov    %ebx,(%esp)
  80138d:	e8 fd fb ff ff       	call   800f8f <close>
	return r;
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	89 f0                	mov    %esi,%eax
}
  801397:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139a:	5b                   	pop    %ebx
  80139b:	5e                   	pop    %esi
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	89 c6                	mov    %eax,%esi
  8013a5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013a7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ae:	75 12                	jne    8013c2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013b0:	83 ec 0c             	sub    $0xc,%esp
  8013b3:	6a 01                	push   $0x1
  8013b5:	e8 34 0c 00 00       	call   801fee <ipc_find_env>
  8013ba:	a3 00 40 80 00       	mov    %eax,0x804000
  8013bf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c2:	6a 07                	push   $0x7
  8013c4:	68 00 50 c0 00       	push   $0xc05000
  8013c9:	56                   	push   %esi
  8013ca:	ff 35 00 40 80 00    	pushl  0x804000
  8013d0:	e8 c5 0b 00 00       	call   801f9a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d5:	83 c4 0c             	add    $0xc,%esp
  8013d8:	6a 00                	push   $0x0
  8013da:	53                   	push   %ebx
  8013db:	6a 00                	push   $0x0
  8013dd:	e8 51 0b 00 00       	call   801f33 <ipc_recv>
}
  8013e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5e                   	pop    %esi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f5:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8013fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fd:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801402:	ba 00 00 00 00       	mov    $0x0,%edx
  801407:	b8 02 00 00 00       	mov    $0x2,%eax
  80140c:	e8 8d ff ff ff       	call   80139e <fsipc>
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801419:	8b 45 08             	mov    0x8(%ebp),%eax
  80141c:	8b 40 0c             	mov    0xc(%eax),%eax
  80141f:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	b8 06 00 00 00       	mov    $0x6,%eax
  80142e:	e8 6b ff ff ff       	call   80139e <fsipc>
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	53                   	push   %ebx
  801439:	83 ec 04             	sub    $0x4,%esp
  80143c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80143f:	8b 45 08             	mov    0x8(%ebp),%eax
  801442:	8b 40 0c             	mov    0xc(%eax),%eax
  801445:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80144a:	ba 00 00 00 00       	mov    $0x0,%edx
  80144f:	b8 05 00 00 00       	mov    $0x5,%eax
  801454:	e8 45 ff ff ff       	call   80139e <fsipc>
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 2c                	js     801489 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	68 00 50 c0 00       	push   $0xc05000
  801465:	53                   	push   %ebx
  801466:	e8 2f f3 ff ff       	call   80079a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80146b:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801470:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801476:	a1 84 50 c0 00       	mov    0xc05084,%eax
  80147b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801489:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 0c             	sub    $0xc,%esp
  801494:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801497:	8b 55 08             	mov    0x8(%ebp),%edx
  80149a:	8b 52 0c             	mov    0xc(%edx),%edx
  80149d:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  8014a3:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014a8:	50                   	push   %eax
  8014a9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ac:	68 08 50 c0 00       	push   $0xc05008
  8014b1:	e8 76 f4 ff ff       	call   80092c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8014c0:	e8 d9 fe ff ff       	call   80139e <fsipc>

}
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	56                   	push   %esi
  8014cb:	53                   	push   %ebx
  8014cc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d5:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014da:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8014ea:	e8 af fe ff ff       	call   80139e <fsipc>
  8014ef:	89 c3                	mov    %eax,%ebx
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 4b                	js     801540 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014f5:	39 c6                	cmp    %eax,%esi
  8014f7:	73 16                	jae    80150f <devfile_read+0x48>
  8014f9:	68 a0 27 80 00       	push   $0x8027a0
  8014fe:	68 a7 27 80 00       	push   $0x8027a7
  801503:	6a 7c                	push   $0x7c
  801505:	68 bc 27 80 00       	push   $0x8027bc
  80150a:	e8 2d ec ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  80150f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801514:	7e 16                	jle    80152c <devfile_read+0x65>
  801516:	68 c7 27 80 00       	push   $0x8027c7
  80151b:	68 a7 27 80 00       	push   $0x8027a7
  801520:	6a 7d                	push   $0x7d
  801522:	68 bc 27 80 00       	push   $0x8027bc
  801527:	e8 10 ec ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	50                   	push   %eax
  801530:	68 00 50 c0 00       	push   $0xc05000
  801535:	ff 75 0c             	pushl  0xc(%ebp)
  801538:	e8 ef f3 ff ff       	call   80092c <memmove>
	return r;
  80153d:	83 c4 10             	add    $0x10,%esp
}
  801540:	89 d8                	mov    %ebx,%eax
  801542:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    

00801549 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	53                   	push   %ebx
  80154d:	83 ec 20             	sub    $0x20,%esp
  801550:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801553:	53                   	push   %ebx
  801554:	e8 08 f2 ff ff       	call   800761 <strlen>
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801561:	7f 67                	jg     8015ca <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801563:	83 ec 0c             	sub    $0xc,%esp
  801566:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	e8 a7 f8 ff ff       	call   800e16 <fd_alloc>
  80156f:	83 c4 10             	add    $0x10,%esp
		return r;
  801572:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801574:	85 c0                	test   %eax,%eax
  801576:	78 57                	js     8015cf <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	53                   	push   %ebx
  80157c:	68 00 50 c0 00       	push   $0xc05000
  801581:	e8 14 f2 ff ff       	call   80079a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801586:	8b 45 0c             	mov    0xc(%ebp),%eax
  801589:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80158e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801591:	b8 01 00 00 00       	mov    $0x1,%eax
  801596:	e8 03 fe ff ff       	call   80139e <fsipc>
  80159b:	89 c3                	mov    %eax,%ebx
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	79 14                	jns    8015b8 <open+0x6f>
		fd_close(fd, 0);
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	6a 00                	push   $0x0
  8015a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ac:	e8 5d f9 ff ff       	call   800f0e <fd_close>
		return r;
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	89 da                	mov    %ebx,%edx
  8015b6:	eb 17                	jmp    8015cf <open+0x86>
	}

	return fd2num(fd);
  8015b8:	83 ec 0c             	sub    $0xc,%esp
  8015bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015be:	e8 2c f8 ff ff       	call   800def <fd2num>
  8015c3:	89 c2                	mov    %eax,%edx
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	eb 05                	jmp    8015cf <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015ca:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015cf:	89 d0                	mov    %edx,%eax
  8015d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8015e6:	e8 b3 fd ff ff       	call   80139e <fsipc>
}
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015f3:	68 d3 27 80 00       	push   $0x8027d3
  8015f8:	ff 75 0c             	pushl  0xc(%ebp)
  8015fb:	e8 9a f1 ff ff       	call   80079a <strcpy>
	return 0;
}
  801600:	b8 00 00 00 00       	mov    $0x0,%eax
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	53                   	push   %ebx
  80160b:	83 ec 10             	sub    $0x10,%esp
  80160e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801611:	53                   	push   %ebx
  801612:	e8 10 0a 00 00       	call   802027 <pageref>
  801617:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80161a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80161f:	83 f8 01             	cmp    $0x1,%eax
  801622:	75 10                	jne    801634 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801624:	83 ec 0c             	sub    $0xc,%esp
  801627:	ff 73 0c             	pushl  0xc(%ebx)
  80162a:	e8 c0 02 00 00       	call   8018ef <nsipc_close>
  80162f:	89 c2                	mov    %eax,%edx
  801631:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801634:	89 d0                	mov    %edx,%eax
  801636:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801641:	6a 00                	push   $0x0
  801643:	ff 75 10             	pushl  0x10(%ebp)
  801646:	ff 75 0c             	pushl  0xc(%ebp)
  801649:	8b 45 08             	mov    0x8(%ebp),%eax
  80164c:	ff 70 0c             	pushl  0xc(%eax)
  80164f:	e8 78 03 00 00       	call   8019cc <nsipc_send>
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80165c:	6a 00                	push   $0x0
  80165e:	ff 75 10             	pushl  0x10(%ebp)
  801661:	ff 75 0c             	pushl  0xc(%ebp)
  801664:	8b 45 08             	mov    0x8(%ebp),%eax
  801667:	ff 70 0c             	pushl  0xc(%eax)
  80166a:	e8 f1 02 00 00       	call   801960 <nsipc_recv>
}
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801677:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80167a:	52                   	push   %edx
  80167b:	50                   	push   %eax
  80167c:	e8 e4 f7 ff ff       	call   800e65 <fd_lookup>
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	78 17                	js     80169f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801691:	39 08                	cmp    %ecx,(%eax)
  801693:	75 05                	jne    80169a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801695:	8b 40 0c             	mov    0xc(%eax),%eax
  801698:	eb 05                	jmp    80169f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80169a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 1c             	sub    $0x1c,%esp
  8016a9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ae:	50                   	push   %eax
  8016af:	e8 62 f7 ff ff       	call   800e16 <fd_alloc>
  8016b4:	89 c3                	mov    %eax,%ebx
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 1b                	js     8016d8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016bd:	83 ec 04             	sub    $0x4,%esp
  8016c0:	68 07 04 00 00       	push   $0x407
  8016c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c8:	6a 00                	push   $0x0
  8016ca:	e8 ce f4 ff ff       	call   800b9d <sys_page_alloc>
  8016cf:	89 c3                	mov    %eax,%ebx
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	79 10                	jns    8016e8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016d8:	83 ec 0c             	sub    $0xc,%esp
  8016db:	56                   	push   %esi
  8016dc:	e8 0e 02 00 00       	call   8018ef <nsipc_close>
		return r;
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	89 d8                	mov    %ebx,%eax
  8016e6:	eb 24                	jmp    80170c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016e8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016fd:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801700:	83 ec 0c             	sub    $0xc,%esp
  801703:	50                   	push   %eax
  801704:	e8 e6 f6 ff ff       	call   800def <fd2num>
  801709:	83 c4 10             	add    $0x10,%esp
}
  80170c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	e8 50 ff ff ff       	call   801671 <fd2sockid>
		return r;
  801721:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801723:	85 c0                	test   %eax,%eax
  801725:	78 1f                	js     801746 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801727:	83 ec 04             	sub    $0x4,%esp
  80172a:	ff 75 10             	pushl  0x10(%ebp)
  80172d:	ff 75 0c             	pushl  0xc(%ebp)
  801730:	50                   	push   %eax
  801731:	e8 12 01 00 00       	call   801848 <nsipc_accept>
  801736:	83 c4 10             	add    $0x10,%esp
		return r;
  801739:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 07                	js     801746 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80173f:	e8 5d ff ff ff       	call   8016a1 <alloc_sockfd>
  801744:	89 c1                	mov    %eax,%ecx
}
  801746:	89 c8                	mov    %ecx,%eax
  801748:	c9                   	leave  
  801749:	c3                   	ret    

0080174a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	e8 19 ff ff ff       	call   801671 <fd2sockid>
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 12                	js     80176e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	ff 75 10             	pushl  0x10(%ebp)
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	50                   	push   %eax
  801766:	e8 2d 01 00 00       	call   801898 <nsipc_bind>
  80176b:	83 c4 10             	add    $0x10,%esp
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <shutdown>:

int
shutdown(int s, int how)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	e8 f3 fe ff ff       	call   801671 <fd2sockid>
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 0f                	js     801791 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801782:	83 ec 08             	sub    $0x8,%esp
  801785:	ff 75 0c             	pushl  0xc(%ebp)
  801788:	50                   	push   %eax
  801789:	e8 3f 01 00 00       	call   8018cd <nsipc_shutdown>
  80178e:	83 c4 10             	add    $0x10,%esp
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	e8 d0 fe ff ff       	call   801671 <fd2sockid>
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 12                	js     8017b7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8017a5:	83 ec 04             	sub    $0x4,%esp
  8017a8:	ff 75 10             	pushl  0x10(%ebp)
  8017ab:	ff 75 0c             	pushl  0xc(%ebp)
  8017ae:	50                   	push   %eax
  8017af:	e8 55 01 00 00       	call   801909 <nsipc_connect>
  8017b4:	83 c4 10             	add    $0x10,%esp
}
  8017b7:	c9                   	leave  
  8017b8:	c3                   	ret    

008017b9 <listen>:

int
listen(int s, int backlog)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	e8 aa fe ff ff       	call   801671 <fd2sockid>
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 0f                	js     8017da <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	ff 75 0c             	pushl  0xc(%ebp)
  8017d1:	50                   	push   %eax
  8017d2:	e8 67 01 00 00       	call   80193e <nsipc_listen>
  8017d7:	83 c4 10             	add    $0x10,%esp
}
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017e2:	ff 75 10             	pushl  0x10(%ebp)
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	ff 75 08             	pushl  0x8(%ebp)
  8017eb:	e8 3a 02 00 00       	call   801a2a <nsipc_socket>
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 05                	js     8017fc <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017f7:	e8 a5 fe ff ff       	call   8016a1 <alloc_sockfd>
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	53                   	push   %ebx
  801802:	83 ec 04             	sub    $0x4,%esp
  801805:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801807:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80180e:	75 12                	jne    801822 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801810:	83 ec 0c             	sub    $0xc,%esp
  801813:	6a 02                	push   $0x2
  801815:	e8 d4 07 00 00       	call   801fee <ipc_find_env>
  80181a:	a3 04 40 80 00       	mov    %eax,0x804004
  80181f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801822:	6a 07                	push   $0x7
  801824:	68 00 60 c0 00       	push   $0xc06000
  801829:	53                   	push   %ebx
  80182a:	ff 35 04 40 80 00    	pushl  0x804004
  801830:	e8 65 07 00 00       	call   801f9a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801835:	83 c4 0c             	add    $0xc,%esp
  801838:	6a 00                	push   $0x0
  80183a:	6a 00                	push   $0x0
  80183c:	6a 00                	push   $0x0
  80183e:	e8 f0 06 00 00       	call   801f33 <ipc_recv>
}
  801843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
  80184d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801850:	8b 45 08             	mov    0x8(%ebp),%eax
  801853:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801858:	8b 06                	mov    (%esi),%eax
  80185a:	a3 04 60 c0 00       	mov    %eax,0xc06004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80185f:	b8 01 00 00 00       	mov    $0x1,%eax
  801864:	e8 95 ff ff ff       	call   8017fe <nsipc>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 20                	js     80188f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	ff 35 10 60 c0 00    	pushl  0xc06010
  801878:	68 00 60 c0 00       	push   $0xc06000
  80187d:	ff 75 0c             	pushl  0xc(%ebp)
  801880:	e8 a7 f0 ff ff       	call   80092c <memmove>
		*addrlen = ret->ret_addrlen;
  801885:	a1 10 60 c0 00       	mov    0xc06010,%eax
  80188a:	89 06                	mov    %eax,(%esi)
  80188c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80188f:	89 d8                	mov    %ebx,%eax
  801891:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801894:	5b                   	pop    %ebx
  801895:	5e                   	pop    %esi
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	53                   	push   %ebx
  80189c:	83 ec 08             	sub    $0x8,%esp
  80189f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a5:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018aa:	53                   	push   %ebx
  8018ab:	ff 75 0c             	pushl  0xc(%ebp)
  8018ae:	68 04 60 c0 00       	push   $0xc06004
  8018b3:	e8 74 f0 ff ff       	call   80092c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018b8:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  8018be:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c3:	e8 36 ff ff ff       	call   8017fe <nsipc>
}
  8018c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  8018db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018de:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  8018e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e8:	e8 11 ff ff ff       	call   8017fe <nsipc>
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <nsipc_close>:

int
nsipc_close(int s)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  8018fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801902:	e8 f7 fe ff ff       	call   8017fe <nsipc>
}
  801907:	c9                   	leave  
  801908:	c3                   	ret    

00801909 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	53                   	push   %ebx
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80191b:	53                   	push   %ebx
  80191c:	ff 75 0c             	pushl  0xc(%ebp)
  80191f:	68 04 60 c0 00       	push   $0xc06004
  801924:	e8 03 f0 ff ff       	call   80092c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801929:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  80192f:	b8 05 00 00 00       	mov    $0x5,%eax
  801934:	e8 c5 fe ff ff       	call   8017fe <nsipc>
}
  801939:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801944:	8b 45 08             	mov    0x8(%ebp),%eax
  801947:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  80194c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194f:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  801954:	b8 06 00 00 00       	mov    $0x6,%eax
  801959:	e8 a0 fe ff ff       	call   8017fe <nsipc>
}
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  801970:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  801976:	8b 45 14             	mov    0x14(%ebp),%eax
  801979:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80197e:	b8 07 00 00 00       	mov    $0x7,%eax
  801983:	e8 76 fe ff ff       	call   8017fe <nsipc>
  801988:	89 c3                	mov    %eax,%ebx
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 35                	js     8019c3 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80198e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801993:	7f 04                	jg     801999 <nsipc_recv+0x39>
  801995:	39 c6                	cmp    %eax,%esi
  801997:	7d 16                	jge    8019af <nsipc_recv+0x4f>
  801999:	68 df 27 80 00       	push   $0x8027df
  80199e:	68 a7 27 80 00       	push   $0x8027a7
  8019a3:	6a 62                	push   $0x62
  8019a5:	68 f4 27 80 00       	push   $0x8027f4
  8019aa:	e8 8d e7 ff ff       	call   80013c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019af:	83 ec 04             	sub    $0x4,%esp
  8019b2:	50                   	push   %eax
  8019b3:	68 00 60 c0 00       	push   $0xc06000
  8019b8:	ff 75 0c             	pushl  0xc(%ebp)
  8019bb:	e8 6c ef ff ff       	call   80092c <memmove>
  8019c0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019c3:	89 d8                	mov    %ebx,%eax
  8019c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c8:	5b                   	pop    %ebx
  8019c9:	5e                   	pop    %esi
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 04             	sub    $0x4,%esp
  8019d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  8019de:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019e4:	7e 16                	jle    8019fc <nsipc_send+0x30>
  8019e6:	68 00 28 80 00       	push   $0x802800
  8019eb:	68 a7 27 80 00       	push   $0x8027a7
  8019f0:	6a 6d                	push   $0x6d
  8019f2:	68 f4 27 80 00       	push   $0x8027f4
  8019f7:	e8 40 e7 ff ff       	call   80013c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019fc:	83 ec 04             	sub    $0x4,%esp
  8019ff:	53                   	push   %ebx
  801a00:	ff 75 0c             	pushl  0xc(%ebp)
  801a03:	68 0c 60 c0 00       	push   $0xc0600c
  801a08:	e8 1f ef ff ff       	call   80092c <memmove>
	nsipcbuf.send.req_size = size;
  801a0d:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801a13:	8b 45 14             	mov    0x14(%ebp),%eax
  801a16:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801a1b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a20:	e8 d9 fd ff ff       	call   8017fe <nsipc>
}
  801a25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3b:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801a40:	8b 45 10             	mov    0x10(%ebp),%eax
  801a43:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801a48:	b8 09 00 00 00       	mov    $0x9,%eax
  801a4d:	e8 ac fd ff ff       	call   8017fe <nsipc>
}
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	ff 75 08             	pushl  0x8(%ebp)
  801a62:	e8 98 f3 ff ff       	call   800dff <fd2data>
  801a67:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a69:	83 c4 08             	add    $0x8,%esp
  801a6c:	68 0c 28 80 00       	push   $0x80280c
  801a71:	53                   	push   %ebx
  801a72:	e8 23 ed ff ff       	call   80079a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a77:	8b 46 04             	mov    0x4(%esi),%eax
  801a7a:	2b 06                	sub    (%esi),%eax
  801a7c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a82:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a89:	00 00 00 
	stat->st_dev = &devpipe;
  801a8c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a93:	30 80 00 
	return 0;
}
  801a96:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	53                   	push   %ebx
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aac:	53                   	push   %ebx
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 6e f1 ff ff       	call   800c22 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ab4:	89 1c 24             	mov    %ebx,(%esp)
  801ab7:	e8 43 f3 ff ff       	call   800dff <fd2data>
  801abc:	83 c4 08             	add    $0x8,%esp
  801abf:	50                   	push   %eax
  801ac0:	6a 00                	push   $0x0
  801ac2:	e8 5b f1 ff ff       	call   800c22 <sys_page_unmap>
}
  801ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	57                   	push   %edi
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 1c             	sub    $0x1c,%esp
  801ad5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ad8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ada:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801adf:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae8:	e8 3a 05 00 00       	call   802027 <pageref>
  801aed:	89 c3                	mov    %eax,%ebx
  801aef:	89 3c 24             	mov    %edi,(%esp)
  801af2:	e8 30 05 00 00       	call   802027 <pageref>
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	39 c3                	cmp    %eax,%ebx
  801afc:	0f 94 c1             	sete   %cl
  801aff:	0f b6 c9             	movzbl %cl,%ecx
  801b02:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b05:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801b0b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b0e:	39 ce                	cmp    %ecx,%esi
  801b10:	74 1b                	je     801b2d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b12:	39 c3                	cmp    %eax,%ebx
  801b14:	75 c4                	jne    801ada <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b16:	8b 42 58             	mov    0x58(%edx),%eax
  801b19:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b1c:	50                   	push   %eax
  801b1d:	56                   	push   %esi
  801b1e:	68 13 28 80 00       	push   $0x802813
  801b23:	e8 ed e6 ff ff       	call   800215 <cprintf>
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	eb ad                	jmp    801ada <_pipeisclosed+0xe>
	}
}
  801b2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b33:	5b                   	pop    %ebx
  801b34:	5e                   	pop    %esi
  801b35:	5f                   	pop    %edi
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	57                   	push   %edi
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
  801b3e:	83 ec 28             	sub    $0x28,%esp
  801b41:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b44:	56                   	push   %esi
  801b45:	e8 b5 f2 ff ff       	call   800dff <fd2data>
  801b4a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b54:	eb 4b                	jmp    801ba1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b56:	89 da                	mov    %ebx,%edx
  801b58:	89 f0                	mov    %esi,%eax
  801b5a:	e8 6d ff ff ff       	call   801acc <_pipeisclosed>
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	75 48                	jne    801bab <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b63:	e8 16 f0 ff ff       	call   800b7e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b68:	8b 43 04             	mov    0x4(%ebx),%eax
  801b6b:	8b 0b                	mov    (%ebx),%ecx
  801b6d:	8d 51 20             	lea    0x20(%ecx),%edx
  801b70:	39 d0                	cmp    %edx,%eax
  801b72:	73 e2                	jae    801b56 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b77:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b7b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b7e:	89 c2                	mov    %eax,%edx
  801b80:	c1 fa 1f             	sar    $0x1f,%edx
  801b83:	89 d1                	mov    %edx,%ecx
  801b85:	c1 e9 1b             	shr    $0x1b,%ecx
  801b88:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b8b:	83 e2 1f             	and    $0x1f,%edx
  801b8e:	29 ca                	sub    %ecx,%edx
  801b90:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b94:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b98:	83 c0 01             	add    $0x1,%eax
  801b9b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9e:	83 c7 01             	add    $0x1,%edi
  801ba1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ba4:	75 c2                	jne    801b68 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ba6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba9:	eb 05                	jmp    801bb0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	57                   	push   %edi
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 18             	sub    $0x18,%esp
  801bc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bc4:	57                   	push   %edi
  801bc5:	e8 35 f2 ff ff       	call   800dff <fd2data>
  801bca:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bd4:	eb 3d                	jmp    801c13 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bd6:	85 db                	test   %ebx,%ebx
  801bd8:	74 04                	je     801bde <devpipe_read+0x26>
				return i;
  801bda:	89 d8                	mov    %ebx,%eax
  801bdc:	eb 44                	jmp    801c22 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bde:	89 f2                	mov    %esi,%edx
  801be0:	89 f8                	mov    %edi,%eax
  801be2:	e8 e5 fe ff ff       	call   801acc <_pipeisclosed>
  801be7:	85 c0                	test   %eax,%eax
  801be9:	75 32                	jne    801c1d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801beb:	e8 8e ef ff ff       	call   800b7e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bf0:	8b 06                	mov    (%esi),%eax
  801bf2:	3b 46 04             	cmp    0x4(%esi),%eax
  801bf5:	74 df                	je     801bd6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bf7:	99                   	cltd   
  801bf8:	c1 ea 1b             	shr    $0x1b,%edx
  801bfb:	01 d0                	add    %edx,%eax
  801bfd:	83 e0 1f             	and    $0x1f,%eax
  801c00:	29 d0                	sub    %edx,%eax
  801c02:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c0d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c10:	83 c3 01             	add    $0x1,%ebx
  801c13:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c16:	75 d8                	jne    801bf0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c18:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1b:	eb 05                	jmp    801c22 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c25:	5b                   	pop    %ebx
  801c26:	5e                   	pop    %esi
  801c27:	5f                   	pop    %edi
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	56                   	push   %esi
  801c2e:	53                   	push   %ebx
  801c2f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c35:	50                   	push   %eax
  801c36:	e8 db f1 ff ff       	call   800e16 <fd_alloc>
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	89 c2                	mov    %eax,%edx
  801c40:	85 c0                	test   %eax,%eax
  801c42:	0f 88 2c 01 00 00    	js     801d74 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c48:	83 ec 04             	sub    $0x4,%esp
  801c4b:	68 07 04 00 00       	push   $0x407
  801c50:	ff 75 f4             	pushl  -0xc(%ebp)
  801c53:	6a 00                	push   $0x0
  801c55:	e8 43 ef ff ff       	call   800b9d <sys_page_alloc>
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	89 c2                	mov    %eax,%edx
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	0f 88 0d 01 00 00    	js     801d74 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c6d:	50                   	push   %eax
  801c6e:	e8 a3 f1 ff ff       	call   800e16 <fd_alloc>
  801c73:	89 c3                	mov    %eax,%ebx
  801c75:	83 c4 10             	add    $0x10,%esp
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	0f 88 e2 00 00 00    	js     801d62 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c80:	83 ec 04             	sub    $0x4,%esp
  801c83:	68 07 04 00 00       	push   $0x407
  801c88:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 0b ef ff ff       	call   800b9d <sys_page_alloc>
  801c92:	89 c3                	mov    %eax,%ebx
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	85 c0                	test   %eax,%eax
  801c99:	0f 88 c3 00 00 00    	js     801d62 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c9f:	83 ec 0c             	sub    $0xc,%esp
  801ca2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca5:	e8 55 f1 ff ff       	call   800dff <fd2data>
  801caa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cac:	83 c4 0c             	add    $0xc,%esp
  801caf:	68 07 04 00 00       	push   $0x407
  801cb4:	50                   	push   %eax
  801cb5:	6a 00                	push   $0x0
  801cb7:	e8 e1 ee ff ff       	call   800b9d <sys_page_alloc>
  801cbc:	89 c3                	mov    %eax,%ebx
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	0f 88 89 00 00 00    	js     801d52 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc9:	83 ec 0c             	sub    $0xc,%esp
  801ccc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccf:	e8 2b f1 ff ff       	call   800dff <fd2data>
  801cd4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cdb:	50                   	push   %eax
  801cdc:	6a 00                	push   $0x0
  801cde:	56                   	push   %esi
  801cdf:	6a 00                	push   $0x0
  801ce1:	e8 fa ee ff ff       	call   800be0 <sys_page_map>
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	83 c4 20             	add    $0x20,%esp
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	78 55                	js     801d44 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d04:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d12:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d19:	83 ec 0c             	sub    $0xc,%esp
  801d1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1f:	e8 cb f0 ff ff       	call   800def <fd2num>
  801d24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d27:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d29:	83 c4 04             	add    $0x4,%esp
  801d2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2f:	e8 bb f0 ff ff       	call   800def <fd2num>
  801d34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d37:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d42:	eb 30                	jmp    801d74 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	56                   	push   %esi
  801d48:	6a 00                	push   $0x0
  801d4a:	e8 d3 ee ff ff       	call   800c22 <sys_page_unmap>
  801d4f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d52:	83 ec 08             	sub    $0x8,%esp
  801d55:	ff 75 f0             	pushl  -0x10(%ebp)
  801d58:	6a 00                	push   $0x0
  801d5a:	e8 c3 ee ff ff       	call   800c22 <sys_page_unmap>
  801d5f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d62:	83 ec 08             	sub    $0x8,%esp
  801d65:	ff 75 f4             	pushl  -0xc(%ebp)
  801d68:	6a 00                	push   $0x0
  801d6a:	e8 b3 ee ff ff       	call   800c22 <sys_page_unmap>
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d74:	89 d0                	mov    %edx,%eax
  801d76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d86:	50                   	push   %eax
  801d87:	ff 75 08             	pushl  0x8(%ebp)
  801d8a:	e8 d6 f0 ff ff       	call   800e65 <fd_lookup>
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	85 c0                	test   %eax,%eax
  801d94:	78 18                	js     801dae <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d96:	83 ec 0c             	sub    $0xc,%esp
  801d99:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9c:	e8 5e f0 ff ff       	call   800dff <fd2data>
	return _pipeisclosed(fd, p);
  801da1:	89 c2                	mov    %eax,%edx
  801da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da6:	e8 21 fd ff ff       	call   801acc <_pipeisclosed>
  801dab:	83 c4 10             	add    $0x10,%esp
}
  801dae:	c9                   	leave  
  801daf:	c3                   	ret    

00801db0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801db3:	b8 00 00 00 00       	mov    $0x0,%eax
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    

00801dba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dc0:	68 2b 28 80 00       	push   $0x80282b
  801dc5:	ff 75 0c             	pushl  0xc(%ebp)
  801dc8:	e8 cd e9 ff ff       	call   80079a <strcpy>
	return 0;
}
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	57                   	push   %edi
  801dd8:	56                   	push   %esi
  801dd9:	53                   	push   %ebx
  801dda:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801deb:	eb 2d                	jmp    801e1a <devcons_write+0x46>
		m = n - tot;
  801ded:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801df2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801df5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dfa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dfd:	83 ec 04             	sub    $0x4,%esp
  801e00:	53                   	push   %ebx
  801e01:	03 45 0c             	add    0xc(%ebp),%eax
  801e04:	50                   	push   %eax
  801e05:	57                   	push   %edi
  801e06:	e8 21 eb ff ff       	call   80092c <memmove>
		sys_cputs(buf, m);
  801e0b:	83 c4 08             	add    $0x8,%esp
  801e0e:	53                   	push   %ebx
  801e0f:	57                   	push   %edi
  801e10:	e8 cc ec ff ff       	call   800ae1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e15:	01 de                	add    %ebx,%esi
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	89 f0                	mov    %esi,%eax
  801e1c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e1f:	72 cc                	jb     801ded <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e38:	74 2a                	je     801e64 <devcons_read+0x3b>
  801e3a:	eb 05                	jmp    801e41 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e3c:	e8 3d ed ff ff       	call   800b7e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e41:	e8 b9 ec ff ff       	call   800aff <sys_cgetc>
  801e46:	85 c0                	test   %eax,%eax
  801e48:	74 f2                	je     801e3c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	78 16                	js     801e64 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e4e:	83 f8 04             	cmp    $0x4,%eax
  801e51:	74 0c                	je     801e5f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e53:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e56:	88 02                	mov    %al,(%edx)
	return 1;
  801e58:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5d:	eb 05                	jmp    801e64 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e5f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e72:	6a 01                	push   $0x1
  801e74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	e8 64 ec ff ff       	call   800ae1 <sys_cputs>
}
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    

00801e82 <getchar>:

int
getchar(void)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e88:	6a 01                	push   $0x1
  801e8a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e8d:	50                   	push   %eax
  801e8e:	6a 00                	push   $0x0
  801e90:	e8 36 f2 ff ff       	call   8010cb <read>
	if (r < 0)
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	78 0f                	js     801eab <getchar+0x29>
		return r;
	if (r < 1)
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	7e 06                	jle    801ea6 <getchar+0x24>
		return -E_EOF;
	return c;
  801ea0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ea4:	eb 05                	jmp    801eab <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ea6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb6:	50                   	push   %eax
  801eb7:	ff 75 08             	pushl  0x8(%ebp)
  801eba:	e8 a6 ef ff ff       	call   800e65 <fd_lookup>
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	78 11                	js     801ed7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ecf:	39 10                	cmp    %edx,(%eax)
  801ed1:	0f 94 c0             	sete   %al
  801ed4:	0f b6 c0             	movzbl %al,%eax
}
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <opencons>:

int
opencons(void)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801edf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee2:	50                   	push   %eax
  801ee3:	e8 2e ef ff ff       	call   800e16 <fd_alloc>
  801ee8:	83 c4 10             	add    $0x10,%esp
		return r;
  801eeb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 3e                	js     801f2f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef1:	83 ec 04             	sub    $0x4,%esp
  801ef4:	68 07 04 00 00       	push   $0x407
  801ef9:	ff 75 f4             	pushl  -0xc(%ebp)
  801efc:	6a 00                	push   $0x0
  801efe:	e8 9a ec ff ff       	call   800b9d <sys_page_alloc>
  801f03:	83 c4 10             	add    $0x10,%esp
		return r;
  801f06:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 23                	js     801f2f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f0c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f15:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f21:	83 ec 0c             	sub    $0xc,%esp
  801f24:	50                   	push   %eax
  801f25:	e8 c5 ee ff ff       	call   800def <fd2num>
  801f2a:	89 c2                	mov    %eax,%edx
  801f2c:	83 c4 10             	add    $0x10,%esp
}
  801f2f:	89 d0                	mov    %edx,%eax
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	8b 75 08             	mov    0x8(%ebp),%esi
  801f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f41:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f43:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f48:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f4b:	83 ec 0c             	sub    $0xc,%esp
  801f4e:	50                   	push   %eax
  801f4f:	e8 f9 ed ff ff       	call   800d4d <sys_ipc_recv>

	if (from_env_store != NULL)
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 f6                	test   %esi,%esi
  801f59:	74 14                	je     801f6f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 09                	js     801f6d <ipc_recv+0x3a>
  801f64:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801f6a:	8b 52 74             	mov    0x74(%edx),%edx
  801f6d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f6f:	85 db                	test   %ebx,%ebx
  801f71:	74 14                	je     801f87 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f73:	ba 00 00 00 00       	mov    $0x0,%edx
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	78 09                	js     801f85 <ipc_recv+0x52>
  801f7c:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801f82:	8b 52 78             	mov    0x78(%edx),%edx
  801f85:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 08                	js     801f93 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f8b:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f90:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f96:	5b                   	pop    %ebx
  801f97:	5e                   	pop    %esi
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	57                   	push   %edi
  801f9e:	56                   	push   %esi
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 0c             	sub    $0xc,%esp
  801fa3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801fac:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fae:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fb3:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801fb6:	ff 75 14             	pushl  0x14(%ebp)
  801fb9:	53                   	push   %ebx
  801fba:	56                   	push   %esi
  801fbb:	57                   	push   %edi
  801fbc:	e8 69 ed ff ff       	call   800d2a <sys_ipc_try_send>

		if (err < 0) {
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	79 1e                	jns    801fe6 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fc8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fcb:	75 07                	jne    801fd4 <ipc_send+0x3a>
				sys_yield();
  801fcd:	e8 ac eb ff ff       	call   800b7e <sys_yield>
  801fd2:	eb e2                	jmp    801fb6 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801fd4:	50                   	push   %eax
  801fd5:	68 37 28 80 00       	push   $0x802837
  801fda:	6a 49                	push   $0x49
  801fdc:	68 44 28 80 00       	push   $0x802844
  801fe1:	e8 56 e1 ff ff       	call   80013c <_panic>
		}

	} while (err < 0);

}
  801fe6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe9:	5b                   	pop    %ebx
  801fea:	5e                   	pop    %esi
  801feb:	5f                   	pop    %edi
  801fec:	5d                   	pop    %ebp
  801fed:	c3                   	ret    

00801fee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ff4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ff9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ffc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802002:	8b 52 50             	mov    0x50(%edx),%edx
  802005:	39 ca                	cmp    %ecx,%edx
  802007:	75 0d                	jne    802016 <ipc_find_env+0x28>
			return envs[i].env_id;
  802009:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80200c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802011:	8b 40 48             	mov    0x48(%eax),%eax
  802014:	eb 0f                	jmp    802025 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802016:	83 c0 01             	add    $0x1,%eax
  802019:	3d 00 04 00 00       	cmp    $0x400,%eax
  80201e:	75 d9                	jne    801ff9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    

00802027 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802027:	55                   	push   %ebp
  802028:	89 e5                	mov    %esp,%ebp
  80202a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202d:	89 d0                	mov    %edx,%eax
  80202f:	c1 e8 16             	shr    $0x16,%eax
  802032:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802039:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203e:	f6 c1 01             	test   $0x1,%cl
  802041:	74 1d                	je     802060 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802043:	c1 ea 0c             	shr    $0xc,%edx
  802046:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80204d:	f6 c2 01             	test   $0x1,%dl
  802050:	74 0e                	je     802060 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802052:	c1 ea 0c             	shr    $0xc,%edx
  802055:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80205c:	ef 
  80205d:	0f b7 c0             	movzwl %ax,%eax
}
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
