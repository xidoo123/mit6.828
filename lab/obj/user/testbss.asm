
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
  800039:	68 40 23 80 00       	push   $0x802340
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
  800056:	68 bb 23 80 00       	push   $0x8023bb
  80005b:	6a 11                	push   $0x11
  80005d:	68 d8 23 80 00       	push   $0x8023d8
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
  800096:	68 60 23 80 00       	push   $0x802360
  80009b:	6a 16                	push   $0x16
  80009d:	68 d8 23 80 00       	push   $0x8023d8
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
  8000b4:	68 88 23 80 00       	push   $0x802388
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 e7 23 80 00       	push   $0x8023e7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 d8 23 80 00       	push   $0x8023d8
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
  800128:	e8 cf 0e 00 00       	call   800ffc <close_all>
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
  80015a:	68 08 24 80 00       	push   $0x802408
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 d6 23 80 00 	movl   $0x8023d6,(%esp)
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
  800278:	e8 33 1e 00 00       	call   8020b0 <__udivdi3>
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
  8002bb:	e8 20 1f 00 00       	call   8021e0 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 2b 24 80 00 	movsbl 0x80242b(%eax),%eax
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
  8003bf:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
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
  800483:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	75 18                	jne    8004a6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048e:	50                   	push   %eax
  80048f:	68 43 24 80 00       	push   $0x802443
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
  8004a7:	68 f9 27 80 00       	push   $0x8027f9
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
  8004cb:	b8 3c 24 80 00       	mov    $0x80243c,%eax
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
  800b46:	68 1f 27 80 00       	push   $0x80271f
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 3c 27 80 00       	push   $0x80273c
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
  800bc7:	68 1f 27 80 00       	push   $0x80271f
  800bcc:	6a 23                	push   $0x23
  800bce:	68 3c 27 80 00       	push   $0x80273c
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
  800c09:	68 1f 27 80 00       	push   $0x80271f
  800c0e:	6a 23                	push   $0x23
  800c10:	68 3c 27 80 00       	push   $0x80273c
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
  800c4b:	68 1f 27 80 00       	push   $0x80271f
  800c50:	6a 23                	push   $0x23
  800c52:	68 3c 27 80 00       	push   $0x80273c
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
  800c8d:	68 1f 27 80 00       	push   $0x80271f
  800c92:	6a 23                	push   $0x23
  800c94:	68 3c 27 80 00       	push   $0x80273c
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
  800ccf:	68 1f 27 80 00       	push   $0x80271f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 3c 27 80 00       	push   $0x80273c
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
  800d11:	68 1f 27 80 00       	push   $0x80271f
  800d16:	6a 23                	push   $0x23
  800d18:	68 3c 27 80 00       	push   $0x80273c
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
  800d75:	68 1f 27 80 00       	push   $0x80271f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 3c 27 80 00       	push   $0x80273c
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
  800dd6:	68 1f 27 80 00       	push   $0x80271f
  800ddb:	6a 23                	push   $0x23
  800ddd:	68 3c 27 80 00       	push   $0x80273c
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

00800def <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
  800df5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfd:	b8 10 00 00 00       	mov    $0x10,%eax
  800e02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	89 df                	mov    %ebx,%edi
  800e0a:	89 de                	mov    %ebx,%esi
  800e0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	7e 17                	jle    800e29 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e12:	83 ec 0c             	sub    $0xc,%esp
  800e15:	50                   	push   %eax
  800e16:	6a 10                	push   $0x10
  800e18:	68 1f 27 80 00       	push   $0x80271f
  800e1d:	6a 23                	push   $0x23
  800e1f:	68 3c 27 80 00       	push   $0x80273c
  800e24:	e8 13 f3 ff ff       	call   80013c <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e44:	8b 45 08             	mov    0x8(%ebp),%eax
  800e47:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e51:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e63:	89 c2                	mov    %eax,%edx
  800e65:	c1 ea 16             	shr    $0x16,%edx
  800e68:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6f:	f6 c2 01             	test   $0x1,%dl
  800e72:	74 11                	je     800e85 <fd_alloc+0x2d>
  800e74:	89 c2                	mov    %eax,%edx
  800e76:	c1 ea 0c             	shr    $0xc,%edx
  800e79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e80:	f6 c2 01             	test   $0x1,%dl
  800e83:	75 09                	jne    800e8e <fd_alloc+0x36>
			*fd_store = fd;
  800e85:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8c:	eb 17                	jmp    800ea5 <fd_alloc+0x4d>
  800e8e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e93:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e98:	75 c9                	jne    800e63 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e9a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ea0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ead:	83 f8 1f             	cmp    $0x1f,%eax
  800eb0:	77 36                	ja     800ee8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb2:	c1 e0 0c             	shl    $0xc,%eax
  800eb5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	c1 ea 16             	shr    $0x16,%edx
  800ebf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec6:	f6 c2 01             	test   $0x1,%dl
  800ec9:	74 24                	je     800eef <fd_lookup+0x48>
  800ecb:	89 c2                	mov    %eax,%edx
  800ecd:	c1 ea 0c             	shr    $0xc,%edx
  800ed0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed7:	f6 c2 01             	test   $0x1,%dl
  800eda:	74 1a                	je     800ef6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800edc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800edf:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	eb 13                	jmp    800efb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eed:	eb 0c                	jmp    800efb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef4:	eb 05                	jmp    800efb <fd_lookup+0x54>
  800ef6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	83 ec 08             	sub    $0x8,%esp
  800f03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f06:	ba cc 27 80 00       	mov    $0x8027cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0b:	eb 13                	jmp    800f20 <dev_lookup+0x23>
  800f0d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f10:	39 08                	cmp    %ecx,(%eax)
  800f12:	75 0c                	jne    800f20 <dev_lookup+0x23>
			*dev = devtab[i];
  800f14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f17:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f19:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1e:	eb 2e                	jmp    800f4e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f20:	8b 02                	mov    (%edx),%eax
  800f22:	85 c0                	test   %eax,%eax
  800f24:	75 e7                	jne    800f0d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f26:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f2b:	8b 40 48             	mov    0x48(%eax),%eax
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	51                   	push   %ecx
  800f32:	50                   	push   %eax
  800f33:	68 4c 27 80 00       	push   $0x80274c
  800f38:	e8 d8 f2 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4e:	c9                   	leave  
  800f4f:	c3                   	ret    

00800f50 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	83 ec 10             	sub    $0x10,%esp
  800f58:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f61:	50                   	push   %eax
  800f62:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f68:	c1 e8 0c             	shr    $0xc,%eax
  800f6b:	50                   	push   %eax
  800f6c:	e8 36 ff ff ff       	call   800ea7 <fd_lookup>
  800f71:	83 c4 08             	add    $0x8,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	78 05                	js     800f7d <fd_close+0x2d>
	    || fd != fd2)
  800f78:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7b:	74 0c                	je     800f89 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7d:	84 db                	test   %bl,%bl
  800f7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f84:	0f 44 c2             	cmove  %edx,%eax
  800f87:	eb 41                	jmp    800fca <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f89:	83 ec 08             	sub    $0x8,%esp
  800f8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	ff 36                	pushl  (%esi)
  800f92:	e8 66 ff ff ff       	call   800efd <dev_lookup>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 1a                	js     800fba <fd_close+0x6a>
		if (dev->dev_close)
  800fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	74 0b                	je     800fba <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	56                   	push   %esi
  800fb3:	ff d0                	call   *%eax
  800fb5:	89 c3                	mov    %eax,%ebx
  800fb7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fba:	83 ec 08             	sub    $0x8,%esp
  800fbd:	56                   	push   %esi
  800fbe:	6a 00                	push   $0x0
  800fc0:	e8 5d fc ff ff       	call   800c22 <sys_page_unmap>
	return r;
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	89 d8                	mov    %ebx,%eax
}
  800fca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fda:	50                   	push   %eax
  800fdb:	ff 75 08             	pushl  0x8(%ebp)
  800fde:	e8 c4 fe ff ff       	call   800ea7 <fd_lookup>
  800fe3:	83 c4 08             	add    $0x8,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 10                	js     800ffa <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fea:	83 ec 08             	sub    $0x8,%esp
  800fed:	6a 01                	push   $0x1
  800fef:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff2:	e8 59 ff ff ff       	call   800f50 <fd_close>
  800ff7:	83 c4 10             	add    $0x10,%esp
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <close_all>:

void
close_all(void)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	53                   	push   %ebx
  801000:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801003:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	53                   	push   %ebx
  80100c:	e8 c0 ff ff ff       	call   800fd1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801011:	83 c3 01             	add    $0x1,%ebx
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	83 fb 20             	cmp    $0x20,%ebx
  80101a:	75 ec                	jne    801008 <close_all+0xc>
		close(i);
}
  80101c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	57                   	push   %edi
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	83 ec 2c             	sub    $0x2c,%esp
  80102a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801030:	50                   	push   %eax
  801031:	ff 75 08             	pushl  0x8(%ebp)
  801034:	e8 6e fe ff ff       	call   800ea7 <fd_lookup>
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	85 c0                	test   %eax,%eax
  80103e:	0f 88 c1 00 00 00    	js     801105 <dup+0xe4>
		return r;
	close(newfdnum);
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	56                   	push   %esi
  801048:	e8 84 ff ff ff       	call   800fd1 <close>

	newfd = INDEX2FD(newfdnum);
  80104d:	89 f3                	mov    %esi,%ebx
  80104f:	c1 e3 0c             	shl    $0xc,%ebx
  801052:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801058:	83 c4 04             	add    $0x4,%esp
  80105b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105e:	e8 de fd ff ff       	call   800e41 <fd2data>
  801063:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801065:	89 1c 24             	mov    %ebx,(%esp)
  801068:	e8 d4 fd ff ff       	call   800e41 <fd2data>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801073:	89 f8                	mov    %edi,%eax
  801075:	c1 e8 16             	shr    $0x16,%eax
  801078:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107f:	a8 01                	test   $0x1,%al
  801081:	74 37                	je     8010ba <dup+0x99>
  801083:	89 f8                	mov    %edi,%eax
  801085:	c1 e8 0c             	shr    $0xc,%eax
  801088:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	74 26                	je     8010ba <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a7:	6a 00                	push   $0x0
  8010a9:	57                   	push   %edi
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 2f fb ff ff       	call   800be0 <sys_page_map>
  8010b1:	89 c7                	mov    %eax,%edi
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 2e                	js     8010e8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010bd:	89 d0                	mov    %edx,%eax
  8010bf:	c1 e8 0c             	shr    $0xc,%eax
  8010c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d1:	50                   	push   %eax
  8010d2:	53                   	push   %ebx
  8010d3:	6a 00                	push   $0x0
  8010d5:	52                   	push   %edx
  8010d6:	6a 00                	push   $0x0
  8010d8:	e8 03 fb ff ff       	call   800be0 <sys_page_map>
  8010dd:	89 c7                	mov    %eax,%edi
  8010df:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e4:	85 ff                	test   %edi,%edi
  8010e6:	79 1d                	jns    801105 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e8:	83 ec 08             	sub    $0x8,%esp
  8010eb:	53                   	push   %ebx
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 2f fb ff ff       	call   800c22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 22 fb ff ff       	call   800c22 <sys_page_unmap>
	return r;
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	89 f8                	mov    %edi,%eax
}
  801105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	53                   	push   %ebx
  801111:	83 ec 14             	sub    $0x14,%esp
  801114:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801117:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111a:	50                   	push   %eax
  80111b:	53                   	push   %ebx
  80111c:	e8 86 fd ff ff       	call   800ea7 <fd_lookup>
  801121:	83 c4 08             	add    $0x8,%esp
  801124:	89 c2                	mov    %eax,%edx
  801126:	85 c0                	test   %eax,%eax
  801128:	78 6d                	js     801197 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801134:	ff 30                	pushl  (%eax)
  801136:	e8 c2 fd ff ff       	call   800efd <dev_lookup>
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 4c                	js     80118e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801142:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801145:	8b 42 08             	mov    0x8(%edx),%eax
  801148:	83 e0 03             	and    $0x3,%eax
  80114b:	83 f8 01             	cmp    $0x1,%eax
  80114e:	75 21                	jne    801171 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801150:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801155:	8b 40 48             	mov    0x48(%eax),%eax
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	53                   	push   %ebx
  80115c:	50                   	push   %eax
  80115d:	68 90 27 80 00       	push   $0x802790
  801162:	e8 ae f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116f:	eb 26                	jmp    801197 <read+0x8a>
	}
	if (!dev->dev_read)
  801171:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801174:	8b 40 08             	mov    0x8(%eax),%eax
  801177:	85 c0                	test   %eax,%eax
  801179:	74 17                	je     801192 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	ff 75 10             	pushl  0x10(%ebp)
  801181:	ff 75 0c             	pushl  0xc(%ebp)
  801184:	52                   	push   %edx
  801185:	ff d0                	call   *%eax
  801187:	89 c2                	mov    %eax,%edx
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	eb 09                	jmp    801197 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118e:	89 c2                	mov    %eax,%edx
  801190:	eb 05                	jmp    801197 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801192:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801197:	89 d0                	mov    %edx,%eax
  801199:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    

0080119e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	eb 21                	jmp    8011d5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	89 f0                	mov    %esi,%eax
  8011b9:	29 d8                	sub    %ebx,%eax
  8011bb:	50                   	push   %eax
  8011bc:	89 d8                	mov    %ebx,%eax
  8011be:	03 45 0c             	add    0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	57                   	push   %edi
  8011c3:	e8 45 ff ff ff       	call   80110d <read>
		if (m < 0)
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 10                	js     8011df <readn+0x41>
			return m;
		if (m == 0)
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	74 0a                	je     8011dd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d3:	01 c3                	add    %eax,%ebx
  8011d5:	39 f3                	cmp    %esi,%ebx
  8011d7:	72 db                	jb     8011b4 <readn+0x16>
  8011d9:	89 d8                	mov    %ebx,%eax
  8011db:	eb 02                	jmp    8011df <readn+0x41>
  8011dd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 14             	sub    $0x14,%esp
  8011ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	53                   	push   %ebx
  8011f6:	e8 ac fc ff ff       	call   800ea7 <fd_lookup>
  8011fb:	83 c4 08             	add    $0x8,%esp
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	85 c0                	test   %eax,%eax
  801202:	78 68                	js     80126c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120a:	50                   	push   %eax
  80120b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120e:	ff 30                	pushl  (%eax)
  801210:	e8 e8 fc ff ff       	call   800efd <dev_lookup>
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 47                	js     801263 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801223:	75 21                	jne    801246 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801225:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80122a:	8b 40 48             	mov    0x48(%eax),%eax
  80122d:	83 ec 04             	sub    $0x4,%esp
  801230:	53                   	push   %ebx
  801231:	50                   	push   %eax
  801232:	68 ac 27 80 00       	push   $0x8027ac
  801237:	e8 d9 ef ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801244:	eb 26                	jmp    80126c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801246:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801249:	8b 52 0c             	mov    0xc(%edx),%edx
  80124c:	85 d2                	test   %edx,%edx
  80124e:	74 17                	je     801267 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	ff 75 10             	pushl  0x10(%ebp)
  801256:	ff 75 0c             	pushl  0xc(%ebp)
  801259:	50                   	push   %eax
  80125a:	ff d2                	call   *%edx
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	eb 09                	jmp    80126c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801263:	89 c2                	mov    %eax,%edx
  801265:	eb 05                	jmp    80126c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801267:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80126c:	89 d0                	mov    %edx,%eax
  80126e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <seek>:

int
seek(int fdnum, off_t offset)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801279:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	ff 75 08             	pushl  0x8(%ebp)
  801280:	e8 22 fc ff ff       	call   800ea7 <fd_lookup>
  801285:	83 c4 08             	add    $0x8,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 0e                	js     80129a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801292:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801295:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 14             	sub    $0x14,%esp
  8012a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a9:	50                   	push   %eax
  8012aa:	53                   	push   %ebx
  8012ab:	e8 f7 fb ff ff       	call   800ea7 <fd_lookup>
  8012b0:	83 c4 08             	add    $0x8,%esp
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 65                	js     80131e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	ff 30                	pushl  (%eax)
  8012c5:	e8 33 fc ff ff       	call   800efd <dev_lookup>
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 44                	js     801315 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d8:	75 21                	jne    8012fb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012da:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012df:	8b 40 48             	mov    0x48(%eax),%eax
  8012e2:	83 ec 04             	sub    $0x4,%esp
  8012e5:	53                   	push   %ebx
  8012e6:	50                   	push   %eax
  8012e7:	68 6c 27 80 00       	push   $0x80276c
  8012ec:	e8 24 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f9:	eb 23                	jmp    80131e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fe:	8b 52 18             	mov    0x18(%edx),%edx
  801301:	85 d2                	test   %edx,%edx
  801303:	74 14                	je     801319 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	ff 75 0c             	pushl  0xc(%ebp)
  80130b:	50                   	push   %eax
  80130c:	ff d2                	call   *%edx
  80130e:	89 c2                	mov    %eax,%edx
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	eb 09                	jmp    80131e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	89 c2                	mov    %eax,%edx
  801317:	eb 05                	jmp    80131e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801319:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131e:	89 d0                	mov    %edx,%eax
  801320:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801323:	c9                   	leave  
  801324:	c3                   	ret    

00801325 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	53                   	push   %ebx
  801329:	83 ec 14             	sub    $0x14,%esp
  80132c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 75 08             	pushl  0x8(%ebp)
  801336:	e8 6c fb ff ff       	call   800ea7 <fd_lookup>
  80133b:	83 c4 08             	add    $0x8,%esp
  80133e:	89 c2                	mov    %eax,%edx
  801340:	85 c0                	test   %eax,%eax
  801342:	78 58                	js     80139c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134e:	ff 30                	pushl  (%eax)
  801350:	e8 a8 fb ff ff       	call   800efd <dev_lookup>
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 37                	js     801393 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80135c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801363:	74 32                	je     801397 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801365:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801368:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136f:	00 00 00 
	stat->st_isdir = 0;
  801372:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801379:	00 00 00 
	stat->st_dev = dev;
  80137c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	53                   	push   %ebx
  801386:	ff 75 f0             	pushl  -0x10(%ebp)
  801389:	ff 50 14             	call   *0x14(%eax)
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	eb 09                	jmp    80139c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801393:	89 c2                	mov    %eax,%edx
  801395:	eb 05                	jmp    80139c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801397:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80139c:	89 d0                	mov    %edx,%eax
  80139e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	6a 00                	push   $0x0
  8013ad:	ff 75 08             	pushl  0x8(%ebp)
  8013b0:	e8 d6 01 00 00       	call   80158b <open>
  8013b5:	89 c3                	mov    %eax,%ebx
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 1b                	js     8013d9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	ff 75 0c             	pushl  0xc(%ebp)
  8013c4:	50                   	push   %eax
  8013c5:	e8 5b ff ff ff       	call   801325 <fstat>
  8013ca:	89 c6                	mov    %eax,%esi
	close(fd);
  8013cc:	89 1c 24             	mov    %ebx,(%esp)
  8013cf:	e8 fd fb ff ff       	call   800fd1 <close>
	return r;
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	89 f0                	mov    %esi,%eax
}
  8013d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	56                   	push   %esi
  8013e4:	53                   	push   %ebx
  8013e5:	89 c6                	mov    %eax,%esi
  8013e7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013f0:	75 12                	jne    801404 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f2:	83 ec 0c             	sub    $0xc,%esp
  8013f5:	6a 01                	push   $0x1
  8013f7:	e8 34 0c 00 00       	call   802030 <ipc_find_env>
  8013fc:	a3 00 40 80 00       	mov    %eax,0x804000
  801401:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801404:	6a 07                	push   $0x7
  801406:	68 00 50 c0 00       	push   $0xc05000
  80140b:	56                   	push   %esi
  80140c:	ff 35 00 40 80 00    	pushl  0x804000
  801412:	e8 c5 0b 00 00       	call   801fdc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801417:	83 c4 0c             	add    $0xc,%esp
  80141a:	6a 00                	push   $0x0
  80141c:	53                   	push   %ebx
  80141d:	6a 00                	push   $0x0
  80141f:	e8 51 0b 00 00       	call   801f75 <ipc_recv>
}
  801424:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    

0080142b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801431:	8b 45 08             	mov    0x8(%ebp),%eax
  801434:	8b 40 0c             	mov    0xc(%eax),%eax
  801437:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  80143c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143f:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801444:	ba 00 00 00 00       	mov    $0x0,%edx
  801449:	b8 02 00 00 00       	mov    $0x2,%eax
  80144e:	e8 8d ff ff ff       	call   8013e0 <fsipc>
}
  801453:	c9                   	leave  
  801454:	c3                   	ret    

00801455 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145b:	8b 45 08             	mov    0x8(%ebp),%eax
  80145e:	8b 40 0c             	mov    0xc(%eax),%eax
  801461:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801466:	ba 00 00 00 00       	mov    $0x0,%edx
  80146b:	b8 06 00 00 00       	mov    $0x6,%eax
  801470:	e8 6b ff ff ff       	call   8013e0 <fsipc>
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	53                   	push   %ebx
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801481:	8b 45 08             	mov    0x8(%ebp),%eax
  801484:	8b 40 0c             	mov    0xc(%eax),%eax
  801487:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148c:	ba 00 00 00 00       	mov    $0x0,%edx
  801491:	b8 05 00 00 00       	mov    $0x5,%eax
  801496:	e8 45 ff ff ff       	call   8013e0 <fsipc>
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 2c                	js     8014cb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	68 00 50 c0 00       	push   $0xc05000
  8014a7:	53                   	push   %ebx
  8014a8:	e8 ed f2 ff ff       	call   80079a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ad:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8014b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b8:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8014bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014df:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  8014e5:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014ea:	50                   	push   %eax
  8014eb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ee:	68 08 50 c0 00       	push   $0xc05008
  8014f3:	e8 34 f4 ff ff       	call   80092c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801502:	e8 d9 fe ff ff       	call   8013e0 <fsipc>

}
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801511:	8b 45 08             	mov    0x8(%ebp),%eax
  801514:	8b 40 0c             	mov    0xc(%eax),%eax
  801517:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  80151c:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801522:	ba 00 00 00 00       	mov    $0x0,%edx
  801527:	b8 03 00 00 00       	mov    $0x3,%eax
  80152c:	e8 af fe ff ff       	call   8013e0 <fsipc>
  801531:	89 c3                	mov    %eax,%ebx
  801533:	85 c0                	test   %eax,%eax
  801535:	78 4b                	js     801582 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801537:	39 c6                	cmp    %eax,%esi
  801539:	73 16                	jae    801551 <devfile_read+0x48>
  80153b:	68 e0 27 80 00       	push   $0x8027e0
  801540:	68 e7 27 80 00       	push   $0x8027e7
  801545:	6a 7c                	push   $0x7c
  801547:	68 fc 27 80 00       	push   $0x8027fc
  80154c:	e8 eb eb ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  801551:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801556:	7e 16                	jle    80156e <devfile_read+0x65>
  801558:	68 07 28 80 00       	push   $0x802807
  80155d:	68 e7 27 80 00       	push   $0x8027e7
  801562:	6a 7d                	push   $0x7d
  801564:	68 fc 27 80 00       	push   $0x8027fc
  801569:	e8 ce eb ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	50                   	push   %eax
  801572:	68 00 50 c0 00       	push   $0xc05000
  801577:	ff 75 0c             	pushl  0xc(%ebp)
  80157a:	e8 ad f3 ff ff       	call   80092c <memmove>
	return r;
  80157f:	83 c4 10             	add    $0x10,%esp
}
  801582:	89 d8                	mov    %ebx,%eax
  801584:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	53                   	push   %ebx
  80158f:	83 ec 20             	sub    $0x20,%esp
  801592:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801595:	53                   	push   %ebx
  801596:	e8 c6 f1 ff ff       	call   800761 <strlen>
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a3:	7f 67                	jg     80160c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a5:	83 ec 0c             	sub    $0xc,%esp
  8015a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	e8 a7 f8 ff ff       	call   800e58 <fd_alloc>
  8015b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 57                	js     801611 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	53                   	push   %ebx
  8015be:	68 00 50 c0 00       	push   $0xc05000
  8015c3:	e8 d2 f1 ff ff       	call   80079a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cb:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d8:	e8 03 fe ff ff       	call   8013e0 <fsipc>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	79 14                	jns    8015fa <open+0x6f>
		fd_close(fd, 0);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	6a 00                	push   $0x0
  8015eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ee:	e8 5d f9 ff ff       	call   800f50 <fd_close>
		return r;
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	89 da                	mov    %ebx,%edx
  8015f8:	eb 17                	jmp    801611 <open+0x86>
	}

	return fd2num(fd);
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801600:	e8 2c f8 ff ff       	call   800e31 <fd2num>
  801605:	89 c2                	mov    %eax,%edx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 05                	jmp    801611 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80160c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801611:	89 d0                	mov    %edx,%eax
  801613:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80161e:	ba 00 00 00 00       	mov    $0x0,%edx
  801623:	b8 08 00 00 00       	mov    $0x8,%eax
  801628:	e8 b3 fd ff ff       	call   8013e0 <fsipc>
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801635:	68 13 28 80 00       	push   $0x802813
  80163a:	ff 75 0c             	pushl  0xc(%ebp)
  80163d:	e8 58 f1 ff ff       	call   80079a <strcpy>
	return 0;
}
  801642:	b8 00 00 00 00       	mov    $0x0,%eax
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	53                   	push   %ebx
  80164d:	83 ec 10             	sub    $0x10,%esp
  801650:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801653:	53                   	push   %ebx
  801654:	e8 10 0a 00 00       	call   802069 <pageref>
  801659:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80165c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801661:	83 f8 01             	cmp    $0x1,%eax
  801664:	75 10                	jne    801676 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	ff 73 0c             	pushl  0xc(%ebx)
  80166c:	e8 c0 02 00 00       	call   801931 <nsipc_close>
  801671:	89 c2                	mov    %eax,%edx
  801673:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801676:	89 d0                	mov    %edx,%eax
  801678:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801683:	6a 00                	push   $0x0
  801685:	ff 75 10             	pushl  0x10(%ebp)
  801688:	ff 75 0c             	pushl  0xc(%ebp)
  80168b:	8b 45 08             	mov    0x8(%ebp),%eax
  80168e:	ff 70 0c             	pushl  0xc(%eax)
  801691:	e8 78 03 00 00       	call   801a0e <nsipc_send>
}
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80169e:	6a 00                	push   $0x0
  8016a0:	ff 75 10             	pushl  0x10(%ebp)
  8016a3:	ff 75 0c             	pushl  0xc(%ebp)
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	ff 70 0c             	pushl  0xc(%eax)
  8016ac:	e8 f1 02 00 00       	call   8019a2 <nsipc_recv>
}
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016b9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016bc:	52                   	push   %edx
  8016bd:	50                   	push   %eax
  8016be:	e8 e4 f7 ff ff       	call   800ea7 <fd_lookup>
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 17                	js     8016e1 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cd:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016d3:	39 08                	cmp    %ecx,(%eax)
  8016d5:	75 05                	jne    8016dc <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016da:	eb 05                	jmp    8016e1 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8016dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 1c             	sub    $0x1c,%esp
  8016eb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	e8 62 f7 ff ff       	call   800e58 <fd_alloc>
  8016f6:	89 c3                	mov    %eax,%ebx
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 1b                	js     80171a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016ff:	83 ec 04             	sub    $0x4,%esp
  801702:	68 07 04 00 00       	push   $0x407
  801707:	ff 75 f4             	pushl  -0xc(%ebp)
  80170a:	6a 00                	push   $0x0
  80170c:	e8 8c f4 ff ff       	call   800b9d <sys_page_alloc>
  801711:	89 c3                	mov    %eax,%ebx
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	79 10                	jns    80172a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	56                   	push   %esi
  80171e:	e8 0e 02 00 00       	call   801931 <nsipc_close>
		return r;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	89 d8                	mov    %ebx,%eax
  801728:	eb 24                	jmp    80174e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80172a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801733:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801738:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80173f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	50                   	push   %eax
  801746:	e8 e6 f6 ff ff       	call   800e31 <fd2num>
  80174b:	83 c4 10             	add    $0x10,%esp
}
  80174e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801751:	5b                   	pop    %ebx
  801752:	5e                   	pop    %esi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	e8 50 ff ff ff       	call   8016b3 <fd2sockid>
		return r;
  801763:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801765:	85 c0                	test   %eax,%eax
  801767:	78 1f                	js     801788 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801769:	83 ec 04             	sub    $0x4,%esp
  80176c:	ff 75 10             	pushl  0x10(%ebp)
  80176f:	ff 75 0c             	pushl  0xc(%ebp)
  801772:	50                   	push   %eax
  801773:	e8 12 01 00 00       	call   80188a <nsipc_accept>
  801778:	83 c4 10             	add    $0x10,%esp
		return r;
  80177b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 07                	js     801788 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801781:	e8 5d ff ff ff       	call   8016e3 <alloc_sockfd>
  801786:	89 c1                	mov    %eax,%ecx
}
  801788:	89 c8                	mov    %ecx,%eax
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	e8 19 ff ff ff       	call   8016b3 <fd2sockid>
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 12                	js     8017b0 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80179e:	83 ec 04             	sub    $0x4,%esp
  8017a1:	ff 75 10             	pushl  0x10(%ebp)
  8017a4:	ff 75 0c             	pushl  0xc(%ebp)
  8017a7:	50                   	push   %eax
  8017a8:	e8 2d 01 00 00       	call   8018da <nsipc_bind>
  8017ad:	83 c4 10             	add    $0x10,%esp
}
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <shutdown>:

int
shutdown(int s, int how)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	e8 f3 fe ff ff       	call   8016b3 <fd2sockid>
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 0f                	js     8017d3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	50                   	push   %eax
  8017cb:	e8 3f 01 00 00       	call   80190f <nsipc_shutdown>
  8017d0:	83 c4 10             	add    $0x10,%esp
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	e8 d0 fe ff ff       	call   8016b3 <fd2sockid>
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 12                	js     8017f9 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	ff 75 10             	pushl  0x10(%ebp)
  8017ed:	ff 75 0c             	pushl  0xc(%ebp)
  8017f0:	50                   	push   %eax
  8017f1:	e8 55 01 00 00       	call   80194b <nsipc_connect>
  8017f6:	83 c4 10             	add    $0x10,%esp
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <listen>:

int
listen(int s, int backlog)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	e8 aa fe ff ff       	call   8016b3 <fd2sockid>
  801809:	85 c0                	test   %eax,%eax
  80180b:	78 0f                	js     80181c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80180d:	83 ec 08             	sub    $0x8,%esp
  801810:	ff 75 0c             	pushl  0xc(%ebp)
  801813:	50                   	push   %eax
  801814:	e8 67 01 00 00       	call   801980 <nsipc_listen>
  801819:	83 c4 10             	add    $0x10,%esp
}
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    

0080181e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801824:	ff 75 10             	pushl  0x10(%ebp)
  801827:	ff 75 0c             	pushl  0xc(%ebp)
  80182a:	ff 75 08             	pushl  0x8(%ebp)
  80182d:	e8 3a 02 00 00       	call   801a6c <nsipc_socket>
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	85 c0                	test   %eax,%eax
  801837:	78 05                	js     80183e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801839:	e8 a5 fe ff ff       	call   8016e3 <alloc_sockfd>
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 04             	sub    $0x4,%esp
  801847:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801849:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801850:	75 12                	jne    801864 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	6a 02                	push   $0x2
  801857:	e8 d4 07 00 00       	call   802030 <ipc_find_env>
  80185c:	a3 04 40 80 00       	mov    %eax,0x804004
  801861:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801864:	6a 07                	push   $0x7
  801866:	68 00 60 c0 00       	push   $0xc06000
  80186b:	53                   	push   %ebx
  80186c:	ff 35 04 40 80 00    	pushl  0x804004
  801872:	e8 65 07 00 00       	call   801fdc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801877:	83 c4 0c             	add    $0xc,%esp
  80187a:	6a 00                	push   $0x0
  80187c:	6a 00                	push   $0x0
  80187e:	6a 00                	push   $0x0
  801880:	e8 f0 06 00 00       	call   801f75 <ipc_recv>
}
  801885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	56                   	push   %esi
  80188e:	53                   	push   %ebx
  80188f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
  801895:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80189a:	8b 06                	mov    (%esi),%eax
  80189c:	a3 04 60 c0 00       	mov    %eax,0xc06004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a6:	e8 95 ff ff ff       	call   801840 <nsipc>
  8018ab:	89 c3                	mov    %eax,%ebx
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 20                	js     8018d1 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018b1:	83 ec 04             	sub    $0x4,%esp
  8018b4:	ff 35 10 60 c0 00    	pushl  0xc06010
  8018ba:	68 00 60 c0 00       	push   $0xc06000
  8018bf:	ff 75 0c             	pushl  0xc(%ebp)
  8018c2:	e8 65 f0 ff ff       	call   80092c <memmove>
		*addrlen = ret->ret_addrlen;
  8018c7:	a1 10 60 c0 00       	mov    0xc06010,%eax
  8018cc:	89 06                	mov    %eax,(%esi)
  8018ce:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018d1:	89 d8                	mov    %ebx,%eax
  8018d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d6:	5b                   	pop    %ebx
  8018d7:	5e                   	pop    %esi
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	53                   	push   %ebx
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e7:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018ec:	53                   	push   %ebx
  8018ed:	ff 75 0c             	pushl  0xc(%ebp)
  8018f0:	68 04 60 c0 00       	push   $0xc06004
  8018f5:	e8 32 f0 ff ff       	call   80092c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018fa:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  801900:	b8 02 00 00 00       	mov    $0x2,%eax
  801905:	e8 36 ff ff ff       	call   801840 <nsipc>
}
  80190a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  80191d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801920:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  801925:	b8 03 00 00 00       	mov    $0x3,%eax
  80192a:	e8 11 ff ff ff       	call   801840 <nsipc>
}
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <nsipc_close>:

int
nsipc_close(int s)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801937:	8b 45 08             	mov    0x8(%ebp),%eax
  80193a:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  80193f:	b8 04 00 00 00       	mov    $0x4,%eax
  801944:	e8 f7 fe ff ff       	call   801840 <nsipc>
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	53                   	push   %ebx
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801955:	8b 45 08             	mov    0x8(%ebp),%eax
  801958:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80195d:	53                   	push   %ebx
  80195e:	ff 75 0c             	pushl  0xc(%ebp)
  801961:	68 04 60 c0 00       	push   $0xc06004
  801966:	e8 c1 ef ff ff       	call   80092c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80196b:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  801971:	b8 05 00 00 00       	mov    $0x5,%eax
  801976:	e8 c5 fe ff ff       	call   801840 <nsipc>
}
  80197b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  80198e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801991:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  801996:	b8 06 00 00 00       	mov    $0x6,%eax
  80199b:	e8 a0 fe ff ff       	call   801840 <nsipc>
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	56                   	push   %esi
  8019a6:	53                   	push   %ebx
  8019a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  8019b2:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  8019b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bb:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019c0:	b8 07 00 00 00       	mov    $0x7,%eax
  8019c5:	e8 76 fe ff ff       	call   801840 <nsipc>
  8019ca:	89 c3                	mov    %eax,%ebx
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 35                	js     801a05 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019d0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019d5:	7f 04                	jg     8019db <nsipc_recv+0x39>
  8019d7:	39 c6                	cmp    %eax,%esi
  8019d9:	7d 16                	jge    8019f1 <nsipc_recv+0x4f>
  8019db:	68 1f 28 80 00       	push   $0x80281f
  8019e0:	68 e7 27 80 00       	push   $0x8027e7
  8019e5:	6a 62                	push   $0x62
  8019e7:	68 34 28 80 00       	push   $0x802834
  8019ec:	e8 4b e7 ff ff       	call   80013c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019f1:	83 ec 04             	sub    $0x4,%esp
  8019f4:	50                   	push   %eax
  8019f5:	68 00 60 c0 00       	push   $0xc06000
  8019fa:	ff 75 0c             	pushl  0xc(%ebp)
  8019fd:	e8 2a ef ff ff       	call   80092c <memmove>
  801a02:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a05:	89 d8                	mov    %ebx,%eax
  801a07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0a:	5b                   	pop    %ebx
  801a0b:	5e                   	pop    %esi
  801a0c:	5d                   	pop    %ebp
  801a0d:	c3                   	ret    

00801a0e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	53                   	push   %ebx
  801a12:	83 ec 04             	sub    $0x4,%esp
  801a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  801a20:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a26:	7e 16                	jle    801a3e <nsipc_send+0x30>
  801a28:	68 40 28 80 00       	push   $0x802840
  801a2d:	68 e7 27 80 00       	push   $0x8027e7
  801a32:	6a 6d                	push   $0x6d
  801a34:	68 34 28 80 00       	push   $0x802834
  801a39:	e8 fe e6 ff ff       	call   80013c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a3e:	83 ec 04             	sub    $0x4,%esp
  801a41:	53                   	push   %ebx
  801a42:	ff 75 0c             	pushl  0xc(%ebp)
  801a45:	68 0c 60 c0 00       	push   $0xc0600c
  801a4a:	e8 dd ee ff ff       	call   80092c <memmove>
	nsipcbuf.send.req_size = size;
  801a4f:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801a55:	8b 45 14             	mov    0x14(%ebp),%eax
  801a58:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801a5d:	b8 08 00 00 00       	mov    $0x8,%eax
  801a62:	e8 d9 fd ff ff       	call   801840 <nsipc>
}
  801a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a72:	8b 45 08             	mov    0x8(%ebp),%eax
  801a75:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7d:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801a82:	8b 45 10             	mov    0x10(%ebp),%eax
  801a85:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801a8a:	b8 09 00 00 00       	mov    $0x9,%eax
  801a8f:	e8 ac fd ff ff       	call   801840 <nsipc>
}
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	ff 75 08             	pushl  0x8(%ebp)
  801aa4:	e8 98 f3 ff ff       	call   800e41 <fd2data>
  801aa9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aab:	83 c4 08             	add    $0x8,%esp
  801aae:	68 4c 28 80 00       	push   $0x80284c
  801ab3:	53                   	push   %ebx
  801ab4:	e8 e1 ec ff ff       	call   80079a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ab9:	8b 46 04             	mov    0x4(%esi),%eax
  801abc:	2b 06                	sub    (%esi),%eax
  801abe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ac4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801acb:	00 00 00 
	stat->st_dev = &devpipe;
  801ace:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ad5:	30 80 00 
	return 0;
}
  801ad8:	b8 00 00 00 00       	mov    $0x0,%eax
  801add:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	53                   	push   %ebx
  801ae8:	83 ec 0c             	sub    $0xc,%esp
  801aeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aee:	53                   	push   %ebx
  801aef:	6a 00                	push   $0x0
  801af1:	e8 2c f1 ff ff       	call   800c22 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801af6:	89 1c 24             	mov    %ebx,(%esp)
  801af9:	e8 43 f3 ff ff       	call   800e41 <fd2data>
  801afe:	83 c4 08             	add    $0x8,%esp
  801b01:	50                   	push   %eax
  801b02:	6a 00                	push   $0x0
  801b04:	e8 19 f1 ff ff       	call   800c22 <sys_page_unmap>
}
  801b09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 1c             	sub    $0x1c,%esp
  801b17:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b1a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b1c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b21:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	ff 75 e0             	pushl  -0x20(%ebp)
  801b2a:	e8 3a 05 00 00       	call   802069 <pageref>
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	89 3c 24             	mov    %edi,(%esp)
  801b34:	e8 30 05 00 00       	call   802069 <pageref>
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	39 c3                	cmp    %eax,%ebx
  801b3e:	0f 94 c1             	sete   %cl
  801b41:	0f b6 c9             	movzbl %cl,%ecx
  801b44:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b47:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801b4d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b50:	39 ce                	cmp    %ecx,%esi
  801b52:	74 1b                	je     801b6f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b54:	39 c3                	cmp    %eax,%ebx
  801b56:	75 c4                	jne    801b1c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b58:	8b 42 58             	mov    0x58(%edx),%eax
  801b5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b5e:	50                   	push   %eax
  801b5f:	56                   	push   %esi
  801b60:	68 53 28 80 00       	push   $0x802853
  801b65:	e8 ab e6 ff ff       	call   800215 <cprintf>
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	eb ad                	jmp    801b1c <_pipeisclosed+0xe>
	}
}
  801b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5f                   	pop    %edi
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	57                   	push   %edi
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 28             	sub    $0x28,%esp
  801b83:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b86:	56                   	push   %esi
  801b87:	e8 b5 f2 ff ff       	call   800e41 <fd2data>
  801b8c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	bf 00 00 00 00       	mov    $0x0,%edi
  801b96:	eb 4b                	jmp    801be3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b98:	89 da                	mov    %ebx,%edx
  801b9a:	89 f0                	mov    %esi,%eax
  801b9c:	e8 6d ff ff ff       	call   801b0e <_pipeisclosed>
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	75 48                	jne    801bed <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ba5:	e8 d4 ef ff ff       	call   800b7e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801baa:	8b 43 04             	mov    0x4(%ebx),%eax
  801bad:	8b 0b                	mov    (%ebx),%ecx
  801baf:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb2:	39 d0                	cmp    %edx,%eax
  801bb4:	73 e2                	jae    801b98 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bbd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc0:	89 c2                	mov    %eax,%edx
  801bc2:	c1 fa 1f             	sar    $0x1f,%edx
  801bc5:	89 d1                	mov    %edx,%ecx
  801bc7:	c1 e9 1b             	shr    $0x1b,%ecx
  801bca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bcd:	83 e2 1f             	and    $0x1f,%edx
  801bd0:	29 ca                	sub    %ecx,%edx
  801bd2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bd6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bda:	83 c0 01             	add    $0x1,%eax
  801bdd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be0:	83 c7 01             	add    $0x1,%edi
  801be3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801be6:	75 c2                	jne    801baa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801be8:	8b 45 10             	mov    0x10(%ebp),%eax
  801beb:	eb 05                	jmp    801bf2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf5:	5b                   	pop    %ebx
  801bf6:	5e                   	pop    %esi
  801bf7:	5f                   	pop    %edi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    

00801bfa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	57                   	push   %edi
  801bfe:	56                   	push   %esi
  801bff:	53                   	push   %ebx
  801c00:	83 ec 18             	sub    $0x18,%esp
  801c03:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c06:	57                   	push   %edi
  801c07:	e8 35 f2 ff ff       	call   800e41 <fd2data>
  801c0c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c16:	eb 3d                	jmp    801c55 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c18:	85 db                	test   %ebx,%ebx
  801c1a:	74 04                	je     801c20 <devpipe_read+0x26>
				return i;
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	eb 44                	jmp    801c64 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c20:	89 f2                	mov    %esi,%edx
  801c22:	89 f8                	mov    %edi,%eax
  801c24:	e8 e5 fe ff ff       	call   801b0e <_pipeisclosed>
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	75 32                	jne    801c5f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c2d:	e8 4c ef ff ff       	call   800b7e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c32:	8b 06                	mov    (%esi),%eax
  801c34:	3b 46 04             	cmp    0x4(%esi),%eax
  801c37:	74 df                	je     801c18 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c39:	99                   	cltd   
  801c3a:	c1 ea 1b             	shr    $0x1b,%edx
  801c3d:	01 d0                	add    %edx,%eax
  801c3f:	83 e0 1f             	and    $0x1f,%eax
  801c42:	29 d0                	sub    %edx,%eax
  801c44:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c4f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c52:	83 c3 01             	add    $0x1,%ebx
  801c55:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c58:	75 d8                	jne    801c32 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5d:	eb 05                	jmp    801c64 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c5f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c67:	5b                   	pop    %ebx
  801c68:	5e                   	pop    %esi
  801c69:	5f                   	pop    %edi
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c77:	50                   	push   %eax
  801c78:	e8 db f1 ff ff       	call   800e58 <fd_alloc>
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	89 c2                	mov    %eax,%edx
  801c82:	85 c0                	test   %eax,%eax
  801c84:	0f 88 2c 01 00 00    	js     801db6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8a:	83 ec 04             	sub    $0x4,%esp
  801c8d:	68 07 04 00 00       	push   $0x407
  801c92:	ff 75 f4             	pushl  -0xc(%ebp)
  801c95:	6a 00                	push   $0x0
  801c97:	e8 01 ef ff ff       	call   800b9d <sys_page_alloc>
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	89 c2                	mov    %eax,%edx
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	0f 88 0d 01 00 00    	js     801db6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801caf:	50                   	push   %eax
  801cb0:	e8 a3 f1 ff ff       	call   800e58 <fd_alloc>
  801cb5:	89 c3                	mov    %eax,%ebx
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	0f 88 e2 00 00 00    	js     801da4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc2:	83 ec 04             	sub    $0x4,%esp
  801cc5:	68 07 04 00 00       	push   $0x407
  801cca:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccd:	6a 00                	push   $0x0
  801ccf:	e8 c9 ee ff ff       	call   800b9d <sys_page_alloc>
  801cd4:	89 c3                	mov    %eax,%ebx
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	0f 88 c3 00 00 00    	js     801da4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ce1:	83 ec 0c             	sub    $0xc,%esp
  801ce4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce7:	e8 55 f1 ff ff       	call   800e41 <fd2data>
  801cec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cee:	83 c4 0c             	add    $0xc,%esp
  801cf1:	68 07 04 00 00       	push   $0x407
  801cf6:	50                   	push   %eax
  801cf7:	6a 00                	push   $0x0
  801cf9:	e8 9f ee ff ff       	call   800b9d <sys_page_alloc>
  801cfe:	89 c3                	mov    %eax,%ebx
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	85 c0                	test   %eax,%eax
  801d05:	0f 88 89 00 00 00    	js     801d94 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d11:	e8 2b f1 ff ff       	call   800e41 <fd2data>
  801d16:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d1d:	50                   	push   %eax
  801d1e:	6a 00                	push   $0x0
  801d20:	56                   	push   %esi
  801d21:	6a 00                	push   $0x0
  801d23:	e8 b8 ee ff ff       	call   800be0 <sys_page_map>
  801d28:	89 c3                	mov    %eax,%ebx
  801d2a:	83 c4 20             	add    $0x20,%esp
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	78 55                	js     801d86 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d31:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d46:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d54:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d61:	e8 cb f0 ff ff       	call   800e31 <fd2num>
  801d66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d69:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d6b:	83 c4 04             	add    $0x4,%esp
  801d6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d71:	e8 bb f0 ff ff       	call   800e31 <fd2num>
  801d76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d79:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d84:	eb 30                	jmp    801db6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d86:	83 ec 08             	sub    $0x8,%esp
  801d89:	56                   	push   %esi
  801d8a:	6a 00                	push   $0x0
  801d8c:	e8 91 ee ff ff       	call   800c22 <sys_page_unmap>
  801d91:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d94:	83 ec 08             	sub    $0x8,%esp
  801d97:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9a:	6a 00                	push   $0x0
  801d9c:	e8 81 ee ff ff       	call   800c22 <sys_page_unmap>
  801da1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801da4:	83 ec 08             	sub    $0x8,%esp
  801da7:	ff 75 f4             	pushl  -0xc(%ebp)
  801daa:	6a 00                	push   $0x0
  801dac:	e8 71 ee ff ff       	call   800c22 <sys_page_unmap>
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801db6:	89 d0                	mov    %edx,%eax
  801db8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc8:	50                   	push   %eax
  801dc9:	ff 75 08             	pushl  0x8(%ebp)
  801dcc:	e8 d6 f0 ff ff       	call   800ea7 <fd_lookup>
  801dd1:	83 c4 10             	add    $0x10,%esp
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	78 18                	js     801df0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dd8:	83 ec 0c             	sub    $0xc,%esp
  801ddb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dde:	e8 5e f0 ff ff       	call   800e41 <fd2data>
	return _pipeisclosed(fd, p);
  801de3:	89 c2                	mov    %eax,%edx
  801de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de8:	e8 21 fd ff ff       	call   801b0e <_pipeisclosed>
  801ded:	83 c4 10             	add    $0x10,%esp
}
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    

00801dfc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e02:	68 6b 28 80 00       	push   $0x80286b
  801e07:	ff 75 0c             	pushl  0xc(%ebp)
  801e0a:	e8 8b e9 ff ff       	call   80079a <strcpy>
	return 0;
}
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	57                   	push   %edi
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e22:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2d:	eb 2d                	jmp    801e5c <devcons_write+0x46>
		m = n - tot;
  801e2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e32:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e34:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e37:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e3c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e3f:	83 ec 04             	sub    $0x4,%esp
  801e42:	53                   	push   %ebx
  801e43:	03 45 0c             	add    0xc(%ebp),%eax
  801e46:	50                   	push   %eax
  801e47:	57                   	push   %edi
  801e48:	e8 df ea ff ff       	call   80092c <memmove>
		sys_cputs(buf, m);
  801e4d:	83 c4 08             	add    $0x8,%esp
  801e50:	53                   	push   %ebx
  801e51:	57                   	push   %edi
  801e52:	e8 8a ec ff ff       	call   800ae1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e57:	01 de                	add    %ebx,%esi
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	89 f0                	mov    %esi,%eax
  801e5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e61:	72 cc                	jb     801e2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5f                   	pop    %edi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    

00801e6b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 08             	sub    $0x8,%esp
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e7a:	74 2a                	je     801ea6 <devcons_read+0x3b>
  801e7c:	eb 05                	jmp    801e83 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e7e:	e8 fb ec ff ff       	call   800b7e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e83:	e8 77 ec ff ff       	call   800aff <sys_cgetc>
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	74 f2                	je     801e7e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 16                	js     801ea6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e90:	83 f8 04             	cmp    $0x4,%eax
  801e93:	74 0c                	je     801ea1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e98:	88 02                	mov    %al,(%edx)
	return 1;
  801e9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9f:	eb 05                	jmp    801ea6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ea1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eae:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eb4:	6a 01                	push   $0x1
  801eb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb9:	50                   	push   %eax
  801eba:	e8 22 ec ff ff       	call   800ae1 <sys_cputs>
}
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <getchar>:

int
getchar(void)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eca:	6a 01                	push   $0x1
  801ecc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ecf:	50                   	push   %eax
  801ed0:	6a 00                	push   $0x0
  801ed2:	e8 36 f2 ff ff       	call   80110d <read>
	if (r < 0)
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	85 c0                	test   %eax,%eax
  801edc:	78 0f                	js     801eed <getchar+0x29>
		return r;
	if (r < 1)
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	7e 06                	jle    801ee8 <getchar+0x24>
		return -E_EOF;
	return c;
  801ee2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ee6:	eb 05                	jmp    801eed <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ee8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef8:	50                   	push   %eax
  801ef9:	ff 75 08             	pushl  0x8(%ebp)
  801efc:	e8 a6 ef ff ff       	call   800ea7 <fd_lookup>
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	85 c0                	test   %eax,%eax
  801f06:	78 11                	js     801f19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f11:	39 10                	cmp    %edx,(%eax)
  801f13:	0f 94 c0             	sete   %al
  801f16:	0f b6 c0             	movzbl %al,%eax
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <opencons>:

int
opencons(void)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f24:	50                   	push   %eax
  801f25:	e8 2e ef ff ff       	call   800e58 <fd_alloc>
  801f2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801f2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 3e                	js     801f71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f33:	83 ec 04             	sub    $0x4,%esp
  801f36:	68 07 04 00 00       	push   $0x407
  801f3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3e:	6a 00                	push   $0x0
  801f40:	e8 58 ec ff ff       	call   800b9d <sys_page_alloc>
  801f45:	83 c4 10             	add    $0x10,%esp
		return r;
  801f48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	78 23                	js     801f71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f4e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f63:	83 ec 0c             	sub    $0xc,%esp
  801f66:	50                   	push   %eax
  801f67:	e8 c5 ee ff ff       	call   800e31 <fd2num>
  801f6c:	89 c2                	mov    %eax,%edx
  801f6e:	83 c4 10             	add    $0x10,%esp
}
  801f71:	89 d0                	mov    %edx,%eax
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	56                   	push   %esi
  801f79:	53                   	push   %ebx
  801f7a:	8b 75 08             	mov    0x8(%ebp),%esi
  801f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f83:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f85:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f8a:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f8d:	83 ec 0c             	sub    $0xc,%esp
  801f90:	50                   	push   %eax
  801f91:	e8 b7 ed ff ff       	call   800d4d <sys_ipc_recv>

	if (from_env_store != NULL)
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	85 f6                	test   %esi,%esi
  801f9b:	74 14                	je     801fb1 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 09                	js     801faf <ipc_recv+0x3a>
  801fa6:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801fac:	8b 52 74             	mov    0x74(%edx),%edx
  801faf:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801fb1:	85 db                	test   %ebx,%ebx
  801fb3:	74 14                	je     801fc9 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801fb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	78 09                	js     801fc7 <ipc_recv+0x52>
  801fbe:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801fc4:	8b 52 78             	mov    0x78(%edx),%edx
  801fc7:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 08                	js     801fd5 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801fcd:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801fd2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    

00801fdc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	57                   	push   %edi
  801fe0:	56                   	push   %esi
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 0c             	sub    $0xc,%esp
  801fe5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801feb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801fee:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ff0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ff5:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ff8:	ff 75 14             	pushl  0x14(%ebp)
  801ffb:	53                   	push   %ebx
  801ffc:	56                   	push   %esi
  801ffd:	57                   	push   %edi
  801ffe:	e8 27 ed ff ff       	call   800d2a <sys_ipc_try_send>

		if (err < 0) {
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	85 c0                	test   %eax,%eax
  802008:	79 1e                	jns    802028 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80200a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80200d:	75 07                	jne    802016 <ipc_send+0x3a>
				sys_yield();
  80200f:	e8 6a eb ff ff       	call   800b7e <sys_yield>
  802014:	eb e2                	jmp    801ff8 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802016:	50                   	push   %eax
  802017:	68 77 28 80 00       	push   $0x802877
  80201c:	6a 49                	push   $0x49
  80201e:	68 84 28 80 00       	push   $0x802884
  802023:	e8 14 e1 ff ff       	call   80013c <_panic>
		}

	} while (err < 0);

}
  802028:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5e                   	pop    %esi
  80202d:	5f                   	pop    %edi
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    

00802030 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802036:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80203b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80203e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802044:	8b 52 50             	mov    0x50(%edx),%edx
  802047:	39 ca                	cmp    %ecx,%edx
  802049:	75 0d                	jne    802058 <ipc_find_env+0x28>
			return envs[i].env_id;
  80204b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80204e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802053:	8b 40 48             	mov    0x48(%eax),%eax
  802056:	eb 0f                	jmp    802067 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802058:	83 c0 01             	add    $0x1,%eax
  80205b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802060:	75 d9                	jne    80203b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802062:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    

00802069 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206f:	89 d0                	mov    %edx,%eax
  802071:	c1 e8 16             	shr    $0x16,%eax
  802074:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802080:	f6 c1 01             	test   $0x1,%cl
  802083:	74 1d                	je     8020a2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802085:	c1 ea 0c             	shr    $0xc,%edx
  802088:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80208f:	f6 c2 01             	test   $0x1,%dl
  802092:	74 0e                	je     8020a2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802094:	c1 ea 0c             	shr    $0xc,%edx
  802097:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80209e:	ef 
  80209f:	0f b7 c0             	movzwl %ax,%eax
}
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
