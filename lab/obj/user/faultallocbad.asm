
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 40 23 80 00       	push   $0x802340
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 18 0b 00 00       	call   800b76 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 23 80 00       	push   $0x802360
  80006f:	6a 0f                	push   $0xf
  800071:	68 4a 23 80 00       	push   $0x80234a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 23 80 00       	push   $0x80238c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 97 06 00 00       	call   800720 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 27 0d 00 00       	call   800dc8 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 0a 0a 00 00       	call   800aba <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 73 0a 00 00       	call   800b38 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 f8 0e 00 00       	call   800ffe <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 e7 09 00 00       	call   800af7 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 10 0a 00 00       	call   800b38 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 b8 23 80 00       	push   $0x8023b8
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 24 28 80 00 	movl   $0x802824,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 2f 09 00 00       	call   800aba <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 54 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 d4 08 00 00       	call   800aba <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 5a 1e 00 00       	call   8020b0 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 47 1f 00 00       	call   8021e0 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 db 23 80 00 	movsbl 0x8023db(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7e 0e                	jle    8002c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	eb 22                	jmp    8002e9 <getuint+0x38>
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 10                	je     8002db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	eb 0e                	jmp    8002e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	88 02                	mov    %al,(%edx)
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	eb 12                	jmp    80034b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 84 89 03 00 00    	je     8006ca <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	50                   	push   %eax
  800346:	ff d6                	call   *%esi
  800348:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	83 c7 01             	add    $0x1,%edi
  80034e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e2                	jne    800339 <vprintfmt+0x14>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 07                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8d 47 01             	lea    0x1(%edi),%eax
  800381:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800384:	0f b6 07             	movzbl (%edi),%eax
  800387:	0f b6 c8             	movzbl %al,%ecx
  80038a:	83 e8 23             	sub    $0x23,%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 1a 03 00 00    	ja     8006af <vprintfmt+0x38a>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a6:	eb d6                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 39                	ja     8003fe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c8:	eb e9                	jmp    8003b3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003db:	eb 27                	jmp    800404 <vprintfmt+0xdf>
  8003dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	0f 49 c8             	cmovns %eax,%ecx
  8003ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	eb 8c                	jmp    80037e <vprintfmt+0x59>
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fc:	eb 80                	jmp    80037e <vprintfmt+0x59>
  8003fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800401:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800408:	0f 89 70 ff ff ff    	jns    80037e <vprintfmt+0x59>
				width = precision, precision = -1;
  80040e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800411:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800414:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041b:	e9 5e ff ff ff       	jmp    80037e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800420:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800426:	e9 53 ff ff ff       	jmp    80037e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 30                	pushl  (%eax)
  80043a:	ff d6                	call   *%esi
			break;
  80043c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800442:	e9 04 ff ff ff       	jmp    80034b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	99                   	cltd   
  800453:	31 d0                	xor    %edx,%eax
  800455:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800457:	83 f8 0f             	cmp    $0xf,%eax
  80045a:	7f 0b                	jg     800467 <vprintfmt+0x142>
  80045c:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 18                	jne    80047f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800467:	50                   	push   %eax
  800468:	68 f3 23 80 00       	push   $0x8023f3
  80046d:	53                   	push   %ebx
  80046e:	56                   	push   %esi
  80046f:	e8 94 fe ff ff       	call   800308 <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047a:	e9 cc fe ff ff       	jmp    80034b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047f:	52                   	push   %edx
  800480:	68 b9 27 80 00       	push   $0x8027b9
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 7c fe ff ff       	call   800308 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 b4 fe ff ff       	jmp    80034b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	b8 ec 23 80 00       	mov    $0x8023ec,%eax
  8004a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b0:	0f 8e 94 00 00 00    	jle    80054a <vprintfmt+0x225>
  8004b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ba:	0f 84 98 00 00 00    	je     800558 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c6:	57                   	push   %edi
  8004c7:	e8 86 02 00 00       	call   800752 <strnlen>
  8004cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	eb 0f                	jmp    8004f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ed                	jg     8004e5 <vprintfmt+0x1c0>
  8004f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fe:	85 c9                	test   %ecx,%ecx
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 49 c1             	cmovns %ecx,%eax
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	89 cb                	mov    %ecx,%ebx
  800515:	eb 4d                	jmp    800564 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051b:	74 1b                	je     800538 <vprintfmt+0x213>
  80051d:	0f be c0             	movsbl %al,%eax
  800520:	83 e8 20             	sub    $0x20,%eax
  800523:	83 f8 5e             	cmp    $0x5e,%eax
  800526:	76 10                	jbe    800538 <vprintfmt+0x213>
					putch('?', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	ff 75 0c             	pushl  0xc(%ebp)
  80052e:	6a 3f                	push   $0x3f
  800530:	ff 55 08             	call   *0x8(%ebp)
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	eb 0d                	jmp    800545 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	52                   	push   %edx
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	83 eb 01             	sub    $0x1,%ebx
  800548:	eb 1a                	jmp    800564 <vprintfmt+0x23f>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	eb 0c                	jmp    800564 <vprintfmt+0x23f>
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	74 23                	je     800595 <vprintfmt+0x270>
  800572:	85 f6                	test   %esi,%esi
  800574:	78 a1                	js     800517 <vprintfmt+0x1f2>
  800576:	83 ee 01             	sub    $0x1,%esi
  800579:	79 9c                	jns    800517 <vprintfmt+0x1f2>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	eb 18                	jmp    80059d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	6a 20                	push   $0x20
  80058b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058d:	83 ef 01             	sub    $0x1,%edi
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb 08                	jmp    80059d <vprintfmt+0x278>
  800595:	89 df                	mov    %ebx,%edi
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	85 ff                	test   %edi,%edi
  80059f:	7f e4                	jg     800585 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a4:	e9 a2 fd ff ff       	jmp    80034b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a9:	83 fa 01             	cmp    $0x1,%edx
  8005ac:	7e 16                	jle    8005c4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 08             	lea    0x8(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 50 04             	mov    0x4(%eax),%edx
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c2:	eb 32                	jmp    8005f6 <vprintfmt+0x2d1>
	else if (lflag)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	74 18                	je     8005e0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005de:	eb 16                	jmp    8005f6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800601:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800605:	79 74                	jns    80067b <vprintfmt+0x356>
				putch('-', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 2d                	push   $0x2d
  80060d:	ff d6                	call   *%esi
				num = -(long long) num;
  80060f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800615:	f7 d8                	neg    %eax
  800617:	83 d2 00             	adc    $0x0,%edx
  80061a:	f7 da                	neg    %edx
  80061c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800624:	eb 55                	jmp    80067b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 83 fc ff ff       	call   8002b1 <getuint>
			base = 10;
  80062e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800633:	eb 46                	jmp    80067b <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 74 fc ff ff       	call   8002b1 <getuint>
			base = 8;
  80063d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800642:	eb 37                	jmp    80067b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 30                	push   $0x30
  80064a:	ff d6                	call   *%esi
			putch('x', putdat);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 78                	push   $0x78
  800652:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800664:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800667:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066c:	eb 0d                	jmp    80067b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 3b fc ff ff       	call   8002b1 <getuint>
			base = 16;
  800676:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067b:	83 ec 0c             	sub    $0xc,%esp
  80067e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800682:	57                   	push   %edi
  800683:	ff 75 e0             	pushl  -0x20(%ebp)
  800686:	51                   	push   %ecx
  800687:	52                   	push   %edx
  800688:	50                   	push   %eax
  800689:	89 da                	mov    %ebx,%edx
  80068b:	89 f0                	mov    %esi,%eax
  80068d:	e8 70 fb ff ff       	call   800202 <printnum>
			break;
  800692:	83 c4 20             	add    $0x20,%esp
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	e9 ae fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	51                   	push   %ecx
  8006a2:	ff d6                	call   *%esi
			break;
  8006a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006aa:	e9 9c fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 25                	push   $0x25
  8006b5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 03                	jmp    8006bf <vprintfmt+0x39a>
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c3:	75 f7                	jne    8006bc <vprintfmt+0x397>
  8006c5:	e9 81 fc ff ff       	jmp    80034b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cd:	5b                   	pop    %ebx
  8006ce:	5e                   	pop    %esi
  8006cf:	5f                   	pop    %edi
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 18             	sub    $0x18,%esp
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	74 26                	je     800719 <vsnprintf+0x47>
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	7e 22                	jle    800719 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f7:	ff 75 14             	pushl  0x14(%ebp)
  8006fa:	ff 75 10             	pushl  0x10(%ebp)
  8006fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800700:	50                   	push   %eax
  800701:	68 eb 02 80 00       	push   $0x8002eb
  800706:	e8 1a fc ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 05                	jmp    80071e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800729:	50                   	push   %eax
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	e8 9a ff ff ff       	call   8006d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	eb 03                	jmp    80074a <strlen+0x10>
		n++;
  800747:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074e:	75 f7                	jne    800747 <strlen+0xd>
		n++;
	return n;
}
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	ba 00 00 00 00       	mov    $0x0,%edx
  800760:	eb 03                	jmp    800765 <strnlen+0x13>
		n++;
  800762:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	39 c2                	cmp    %eax,%edx
  800767:	74 08                	je     800771 <strnlen+0x1f>
  800769:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076d:	75 f3                	jne    800762 <strnlen+0x10>
  80076f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	83 c2 01             	add    $0x1,%edx
  800782:	83 c1 01             	add    $0x1,%ecx
  800785:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078c:	84 db                	test   %bl,%bl
  80078e:	75 ef                	jne    80077f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800790:	5b                   	pop    %ebx
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 9a ff ff ff       	call   80073a <strlen>
  8007a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	01 d8                	add    %ebx,%eax
  8007a8:	50                   	push   %eax
  8007a9:	e8 c5 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	eb 0f                	jmp    8007d8 <strncpy+0x23>
		*dst++ = *src;
  8007c9:	83 c2 01             	add    $0x1,%edx
  8007cc:	0f b6 01             	movzbl (%ecx),%eax
  8007cf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d8:	39 da                	cmp    %ebx,%edx
  8007da:	75 ed                	jne    8007c9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	74 21                	je     800817 <strlcpy+0x35>
  8007f6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fa:	89 f2                	mov    %esi,%edx
  8007fc:	eb 09                	jmp    800807 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800807:	39 c2                	cmp    %eax,%edx
  800809:	74 09                	je     800814 <strlcpy+0x32>
  80080b:	0f b6 19             	movzbl (%ecx),%ebx
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ec                	jne    8007fe <strlcpy+0x1c>
  800812:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800814:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800817:	29 f0                	sub    %esi,%eax
}
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800826:	eb 06                	jmp    80082e <strcmp+0x11>
		p++, q++;
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	84 c0                	test   %al,%al
  800833:	74 04                	je     800839 <strcmp+0x1c>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	74 ef                	je     800828 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800839:	0f b6 c0             	movzbl %al,%eax
  80083c:	0f b6 12             	movzbl (%edx),%edx
  80083f:	29 d0                	sub    %edx,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 c3                	mov    %eax,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800852:	eb 06                	jmp    80085a <strncmp+0x17>
		n--, p++, q++;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085a:	39 d8                	cmp    %ebx,%eax
  80085c:	74 15                	je     800873 <strncmp+0x30>
  80085e:	0f b6 08             	movzbl (%eax),%ecx
  800861:	84 c9                	test   %cl,%cl
  800863:	74 04                	je     800869 <strncmp+0x26>
  800865:	3a 0a                	cmp    (%edx),%cl
  800867:	74 eb                	je     800854 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 00             	movzbl (%eax),%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
  800871:	eb 05                	jmp    800878 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800885:	eb 07                	jmp    80088e <strchr+0x13>
		if (*s == c)
  800887:	38 ca                	cmp    %cl,%dl
  800889:	74 0f                	je     80089a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	0f b6 10             	movzbl (%eax),%edx
  800891:	84 d2                	test   %dl,%dl
  800893:	75 f2                	jne    800887 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	eb 03                	jmp    8008ab <strfind+0xf>
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 04                	je     8008b6 <strfind+0x1a>
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
  8008be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 36                	je     8008fe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ce:	75 28                	jne    8008f8 <memset+0x40>
  8008d0:	f6 c1 03             	test   $0x3,%cl
  8008d3:	75 23                	jne    8008f8 <memset+0x40>
		c &= 0xFF;
  8008d5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d9:	89 d3                	mov    %edx,%ebx
  8008db:	c1 e3 08             	shl    $0x8,%ebx
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	c1 e6 18             	shl    $0x18,%esi
  8008e3:	89 d0                	mov    %edx,%eax
  8008e5:	c1 e0 10             	shl    $0x10,%eax
  8008e8:	09 f0                	or     %esi,%eax
  8008ea:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ec:	89 d8                	mov    %ebx,%eax
  8008ee:	09 d0                	or     %edx,%eax
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
  8008f3:	fc                   	cld    
  8008f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f6:	eb 06                	jmp    8008fe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fb:	fc                   	cld    
  8008fc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fe:	89 f8                	mov    %edi,%eax
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800913:	39 c6                	cmp    %eax,%esi
  800915:	73 35                	jae    80094c <memmove+0x47>
  800917:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	73 2e                	jae    80094c <memmove+0x47>
		s += n;
		d += n;
  80091e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800921:	89 d6                	mov    %edx,%esi
  800923:	09 fe                	or     %edi,%esi
  800925:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092b:	75 13                	jne    800940 <memmove+0x3b>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0e                	jne    800940 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800932:	83 ef 04             	sub    $0x4,%edi
  800935:	8d 72 fc             	lea    -0x4(%edx),%esi
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	fd                   	std    
  80093c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 09                	jmp    800949 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800940:	83 ef 01             	sub    $0x1,%edi
  800943:	8d 72 ff             	lea    -0x1(%edx),%esi
  800946:	fd                   	std    
  800947:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800949:	fc                   	cld    
  80094a:	eb 1d                	jmp    800969 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	89 f2                	mov    %esi,%edx
  80094e:	09 c2                	or     %eax,%edx
  800950:	f6 c2 03             	test   $0x3,%dl
  800953:	75 0f                	jne    800964 <memmove+0x5f>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0a                	jne    800964 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095a:	c1 e9 02             	shr    $0x2,%ecx
  80095d:	89 c7                	mov    %eax,%edi
  80095f:	fc                   	cld    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 05                	jmp    800969 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800970:	ff 75 10             	pushl  0x10(%ebp)
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 87 ff ff ff       	call   800905 <memmove>
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098b:	89 c6                	mov    %eax,%esi
  80098d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	eb 1a                	jmp    8009ac <memcmp+0x2c>
		if (*s1 != *s2)
  800992:	0f b6 08             	movzbl (%eax),%ecx
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	38 d9                	cmp    %bl,%cl
  80099a:	74 0a                	je     8009a6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099c:	0f b6 c1             	movzbl %cl,%eax
  80099f:	0f b6 db             	movzbl %bl,%ebx
  8009a2:	29 d8                	sub    %ebx,%eax
  8009a4:	eb 0f                	jmp    8009b5 <memcmp+0x35>
		s1++, s2++;
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	39 f0                	cmp    %esi,%eax
  8009ae:	75 e2                	jne    800992 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c0:	89 c1                	mov    %eax,%ecx
  8009c2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c9:	eb 0a                	jmp    8009d5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	0f b6 10             	movzbl (%eax),%edx
  8009ce:	39 da                	cmp    %ebx,%edx
  8009d0:	74 07                	je     8009d9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	39 c8                	cmp    %ecx,%eax
  8009d7:	72 f2                	jb     8009cb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e8:	eb 03                	jmp    8009ed <strtol+0x11>
		s++;
  8009ea:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ed:	0f b6 01             	movzbl (%ecx),%eax
  8009f0:	3c 20                	cmp    $0x20,%al
  8009f2:	74 f6                	je     8009ea <strtol+0xe>
  8009f4:	3c 09                	cmp    $0x9,%al
  8009f6:	74 f2                	je     8009ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f8:	3c 2b                	cmp    $0x2b,%al
  8009fa:	75 0a                	jne    800a06 <strtol+0x2a>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ff:	bf 00 00 00 00       	mov    $0x0,%edi
  800a04:	eb 11                	jmp    800a17 <strtol+0x3b>
  800a06:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0b:	3c 2d                	cmp    $0x2d,%al
  800a0d:	75 08                	jne    800a17 <strtol+0x3b>
		s++, neg = 1;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1d:	75 15                	jne    800a34 <strtol+0x58>
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 10                	jne    800a34 <strtol+0x58>
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	75 7c                	jne    800aa6 <strtol+0xca>
		s += 2, base = 16;
  800a2a:	83 c1 02             	add    $0x2,%ecx
  800a2d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a32:	eb 16                	jmp    800a4a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a34:	85 db                	test   %ebx,%ebx
  800a36:	75 12                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a38:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	75 08                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
  800a42:	83 c1 01             	add    $0x1,%ecx
  800a45:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a52:	0f b6 11             	movzbl (%ecx),%edx
  800a55:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a58:	89 f3                	mov    %esi,%ebx
  800a5a:	80 fb 09             	cmp    $0x9,%bl
  800a5d:	77 08                	ja     800a67 <strtol+0x8b>
			dig = *s - '0';
  800a5f:	0f be d2             	movsbl %dl,%edx
  800a62:	83 ea 30             	sub    $0x30,%edx
  800a65:	eb 22                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a67:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 19             	cmp    $0x19,%bl
  800a6f:	77 08                	ja     800a79 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 57             	sub    $0x57,%edx
  800a77:	eb 10                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a79:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 19             	cmp    $0x19,%bl
  800a81:	77 16                	ja     800a99 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8c:	7d 0b                	jge    800a99 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a95:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a97:	eb b9                	jmp    800a52 <strtol+0x76>

	if (endptr)
  800a99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9d:	74 0d                	je     800aac <strtol+0xd0>
		*endptr = (char *) s;
  800a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa2:	89 0e                	mov    %ecx,(%esi)
  800aa4:	eb 06                	jmp    800aac <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	74 98                	je     800a42 <strtol+0x66>
  800aaa:	eb 9e                	jmp    800a4a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aac:	89 c2                	mov    %eax,%edx
  800aae:	f7 da                	neg    %edx
  800ab0:	85 ff                	test   %edi,%edi
  800ab2:	0f 45 c2             	cmovne %edx,%eax
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae8:	89 d1                	mov    %edx,%ecx
  800aea:	89 d3                	mov    %edx,%ebx
  800aec:	89 d7                	mov    %edx,%edi
  800aee:	89 d6                	mov    %edx,%esi
  800af0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b05:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 cb                	mov    %ecx,%ebx
  800b0f:	89 cf                	mov    %ecx,%edi
  800b11:	89 ce                	mov    %ecx,%esi
  800b13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	7e 17                	jle    800b30 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	50                   	push   %eax
  800b1d:	6a 03                	push   $0x3
  800b1f:	68 df 26 80 00       	push   $0x8026df
  800b24:	6a 23                	push   $0x23
  800b26:	68 fc 26 80 00       	push   $0x8026fc
  800b2b:	e8 e5 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 02 00 00 00       	mov    $0x2,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_yield>:

void
sys_yield(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	be 00 00 00 00       	mov    $0x0,%esi
  800b84:	b8 04 00 00 00       	mov    $0x4,%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b92:	89 f7                	mov    %esi,%edi
  800b94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7e 17                	jle    800bb1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 04                	push   $0x4
  800ba0:	68 df 26 80 00       	push   $0x8026df
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 fc 26 80 00       	push   $0x8026fc
  800bac:	e8 64 f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 05                	push   $0x5
  800be2:	68 df 26 80 00       	push   $0x8026df
  800be7:	6a 23                	push   $0x23
  800be9:	68 fc 26 80 00       	push   $0x8026fc
  800bee:	e8 22 f5 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c09:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	89 df                	mov    %ebx,%edi
  800c16:	89 de                	mov    %ebx,%esi
  800c18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 06                	push   $0x6
  800c24:	68 df 26 80 00       	push   $0x8026df
  800c29:	6a 23                	push   $0x23
  800c2b:	68 fc 26 80 00       	push   $0x8026fc
  800c30:	e8 e0 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 08                	push   $0x8
  800c66:	68 df 26 80 00       	push   $0x8026df
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 fc 26 80 00       	push   $0x8026fc
  800c72:	e8 9e f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 09                	push   $0x9
  800ca8:	68 df 26 80 00       	push   $0x8026df
  800cad:	6a 23                	push   $0x23
  800caf:	68 fc 26 80 00       	push   $0x8026fc
  800cb4:	e8 5c f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 0a                	push   $0xa
  800cea:	68 df 26 80 00       	push   $0x8026df
  800cef:	6a 23                	push   $0x23
  800cf1:	68 fc 26 80 00       	push   $0x8026fc
  800cf6:	e8 1a f4 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	be 00 00 00 00       	mov    $0x0,%esi
  800d0e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d34:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 cb                	mov    %ecx,%ebx
  800d3e:	89 cf                	mov    %ecx,%edi
  800d40:	89 ce                	mov    %ecx,%esi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 0d                	push   $0xd
  800d4e:	68 df 26 80 00       	push   $0x8026df
  800d53:	6a 23                	push   $0x23
  800d55:	68 fc 26 80 00       	push   $0x8026fc
  800d5a:	e8 b6 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d72:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d77:	89 d1                	mov    %edx,%ecx
  800d79:	89 d3                	mov    %edx,%ebx
  800d7b:	89 d7                	mov    %edx,%edi
  800d7d:	89 d6                	mov    %edx,%esi
  800d7f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d94:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 df                	mov    %ebx,%edi
  800da1:	89 de                	mov    %ebx,%esi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 0f                	push   $0xf
  800daf:	68 df 26 80 00       	push   $0x8026df
  800db4:	6a 23                	push   $0x23
  800db6:	68 fc 26 80 00       	push   $0x8026fc
  800dbb:	e8 55 f3 ff ff       	call   800115 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dce:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800dd5:	75 2e                	jne    800e05 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800dd7:	e8 5c fd ff ff       	call   800b38 <sys_getenvid>
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	68 07 0e 00 00       	push   $0xe07
  800de4:	68 00 f0 bf ee       	push   $0xeebff000
  800de9:	50                   	push   %eax
  800dea:	e8 87 fd ff ff       	call   800b76 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800def:	e8 44 fd ff ff       	call   800b38 <sys_getenvid>
  800df4:	83 c4 08             	add    $0x8,%esp
  800df7:	68 0f 0e 80 00       	push   $0x800e0f
  800dfc:	50                   	push   %eax
  800dfd:	e8 bf fe ff ff       	call   800cc1 <sys_env_set_pgfault_upcall>
  800e02:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800e0d:	c9                   	leave  
  800e0e:	c3                   	ret    

00800e0f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e0f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e10:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e15:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e17:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800e1a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800e1e:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800e22:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800e25:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800e28:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800e29:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800e2c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800e2d:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800e2e:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800e32:	c3                   	ret    

00800e33 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e53:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e60:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	c1 ea 16             	shr    $0x16,%edx
  800e6a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	74 11                	je     800e87 <fd_alloc+0x2d>
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	c1 ea 0c             	shr    $0xc,%edx
  800e7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e82:	f6 c2 01             	test   $0x1,%dl
  800e85:	75 09                	jne    800e90 <fd_alloc+0x36>
			*fd_store = fd;
  800e87:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8e:	eb 17                	jmp    800ea7 <fd_alloc+0x4d>
  800e90:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e95:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e9a:	75 c9                	jne    800e65 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e9c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ea2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eaf:	83 f8 1f             	cmp    $0x1f,%eax
  800eb2:	77 36                	ja     800eea <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb4:	c1 e0 0c             	shl    $0xc,%eax
  800eb7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ebc:	89 c2                	mov    %eax,%edx
  800ebe:	c1 ea 16             	shr    $0x16,%edx
  800ec1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec8:	f6 c2 01             	test   $0x1,%dl
  800ecb:	74 24                	je     800ef1 <fd_lookup+0x48>
  800ecd:	89 c2                	mov    %eax,%edx
  800ecf:	c1 ea 0c             	shr    $0xc,%edx
  800ed2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed9:	f6 c2 01             	test   $0x1,%dl
  800edc:	74 1a                	je     800ef8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ede:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee1:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	eb 13                	jmp    800efd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eef:	eb 0c                	jmp    800efd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef6:	eb 05                	jmp    800efd <fd_lookup+0x54>
  800ef8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f08:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0d:	eb 13                	jmp    800f22 <dev_lookup+0x23>
  800f0f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f12:	39 08                	cmp    %ecx,(%eax)
  800f14:	75 0c                	jne    800f22 <dev_lookup+0x23>
			*dev = devtab[i];
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f20:	eb 2e                	jmp    800f50 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f22:	8b 02                	mov    (%edx),%eax
  800f24:	85 c0                	test   %eax,%eax
  800f26:	75 e7                	jne    800f0f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f28:	a1 08 40 80 00       	mov    0x804008,%eax
  800f2d:	8b 40 48             	mov    0x48(%eax),%eax
  800f30:	83 ec 04             	sub    $0x4,%esp
  800f33:	51                   	push   %ecx
  800f34:	50                   	push   %eax
  800f35:	68 0c 27 80 00       	push   $0x80270c
  800f3a:	e8 af f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	56                   	push   %esi
  800f56:	53                   	push   %ebx
  800f57:	83 ec 10             	sub    $0x10,%esp
  800f5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f6a:	c1 e8 0c             	shr    $0xc,%eax
  800f6d:	50                   	push   %eax
  800f6e:	e8 36 ff ff ff       	call   800ea9 <fd_lookup>
  800f73:	83 c4 08             	add    $0x8,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	78 05                	js     800f7f <fd_close+0x2d>
	    || fd != fd2)
  800f7a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7d:	74 0c                	je     800f8b <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7f:	84 db                	test   %bl,%bl
  800f81:	ba 00 00 00 00       	mov    $0x0,%edx
  800f86:	0f 44 c2             	cmove  %edx,%eax
  800f89:	eb 41                	jmp    800fcc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f8b:	83 ec 08             	sub    $0x8,%esp
  800f8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f91:	50                   	push   %eax
  800f92:	ff 36                	pushl  (%esi)
  800f94:	e8 66 ff ff ff       	call   800eff <dev_lookup>
  800f99:	89 c3                	mov    %eax,%ebx
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	78 1a                	js     800fbc <fd_close+0x6a>
		if (dev->dev_close)
  800fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fad:	85 c0                	test   %eax,%eax
  800faf:	74 0b                	je     800fbc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	56                   	push   %esi
  800fb5:	ff d0                	call   *%eax
  800fb7:	89 c3                	mov    %eax,%ebx
  800fb9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	56                   	push   %esi
  800fc0:	6a 00                	push   $0x0
  800fc2:	e8 34 fc ff ff       	call   800bfb <sys_page_unmap>
	return r;
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	89 d8                	mov    %ebx,%eax
}
  800fcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	ff 75 08             	pushl  0x8(%ebp)
  800fe0:	e8 c4 fe ff ff       	call   800ea9 <fd_lookup>
  800fe5:	83 c4 08             	add    $0x8,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 10                	js     800ffc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	6a 01                	push   $0x1
  800ff1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff4:	e8 59 ff ff ff       	call   800f52 <fd_close>
  800ff9:	83 c4 10             	add    $0x10,%esp
}
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <close_all>:

void
close_all(void)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	53                   	push   %ebx
  801002:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801005:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	53                   	push   %ebx
  80100e:	e8 c0 ff ff ff       	call   800fd3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801013:	83 c3 01             	add    $0x1,%ebx
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	83 fb 20             	cmp    $0x20,%ebx
  80101c:	75 ec                	jne    80100a <close_all+0xc>
		close(i);
}
  80101e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	57                   	push   %edi
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
  801029:	83 ec 2c             	sub    $0x2c,%esp
  80102c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801032:	50                   	push   %eax
  801033:	ff 75 08             	pushl  0x8(%ebp)
  801036:	e8 6e fe ff ff       	call   800ea9 <fd_lookup>
  80103b:	83 c4 08             	add    $0x8,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	0f 88 c1 00 00 00    	js     801107 <dup+0xe4>
		return r;
	close(newfdnum);
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	56                   	push   %esi
  80104a:	e8 84 ff ff ff       	call   800fd3 <close>

	newfd = INDEX2FD(newfdnum);
  80104f:	89 f3                	mov    %esi,%ebx
  801051:	c1 e3 0c             	shl    $0xc,%ebx
  801054:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80105a:	83 c4 04             	add    $0x4,%esp
  80105d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801060:	e8 de fd ff ff       	call   800e43 <fd2data>
  801065:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801067:	89 1c 24             	mov    %ebx,(%esp)
  80106a:	e8 d4 fd ff ff       	call   800e43 <fd2data>
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801075:	89 f8                	mov    %edi,%eax
  801077:	c1 e8 16             	shr    $0x16,%eax
  80107a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801081:	a8 01                	test   $0x1,%al
  801083:	74 37                	je     8010bc <dup+0x99>
  801085:	89 f8                	mov    %edi,%eax
  801087:	c1 e8 0c             	shr    $0xc,%eax
  80108a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801091:	f6 c2 01             	test   $0x1,%dl
  801094:	74 26                	je     8010bc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801096:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a5:	50                   	push   %eax
  8010a6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a9:	6a 00                	push   $0x0
  8010ab:	57                   	push   %edi
  8010ac:	6a 00                	push   $0x0
  8010ae:	e8 06 fb ff ff       	call   800bb9 <sys_page_map>
  8010b3:	89 c7                	mov    %eax,%edi
  8010b5:	83 c4 20             	add    $0x20,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	78 2e                	js     8010ea <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010bf:	89 d0                	mov    %edx,%eax
  8010c1:	c1 e8 0c             	shr    $0xc,%eax
  8010c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d3:	50                   	push   %eax
  8010d4:	53                   	push   %ebx
  8010d5:	6a 00                	push   $0x0
  8010d7:	52                   	push   %edx
  8010d8:	6a 00                	push   $0x0
  8010da:	e8 da fa ff ff       	call   800bb9 <sys_page_map>
  8010df:	89 c7                	mov    %eax,%edi
  8010e1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e6:	85 ff                	test   %edi,%edi
  8010e8:	79 1d                	jns    801107 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010ea:	83 ec 08             	sub    $0x8,%esp
  8010ed:	53                   	push   %ebx
  8010ee:	6a 00                	push   $0x0
  8010f0:	e8 06 fb ff ff       	call   800bfb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f5:	83 c4 08             	add    $0x8,%esp
  8010f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010fb:	6a 00                	push   $0x0
  8010fd:	e8 f9 fa ff ff       	call   800bfb <sys_page_unmap>
	return r;
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	89 f8                	mov    %edi,%eax
}
  801107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110a:	5b                   	pop    %ebx
  80110b:	5e                   	pop    %esi
  80110c:	5f                   	pop    %edi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	53                   	push   %ebx
  801113:	83 ec 14             	sub    $0x14,%esp
  801116:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801119:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111c:	50                   	push   %eax
  80111d:	53                   	push   %ebx
  80111e:	e8 86 fd ff ff       	call   800ea9 <fd_lookup>
  801123:	83 c4 08             	add    $0x8,%esp
  801126:	89 c2                	mov    %eax,%edx
  801128:	85 c0                	test   %eax,%eax
  80112a:	78 6d                	js     801199 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801132:	50                   	push   %eax
  801133:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801136:	ff 30                	pushl  (%eax)
  801138:	e8 c2 fd ff ff       	call   800eff <dev_lookup>
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	78 4c                	js     801190 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801144:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801147:	8b 42 08             	mov    0x8(%edx),%eax
  80114a:	83 e0 03             	and    $0x3,%eax
  80114d:	83 f8 01             	cmp    $0x1,%eax
  801150:	75 21                	jne    801173 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801152:	a1 08 40 80 00       	mov    0x804008,%eax
  801157:	8b 40 48             	mov    0x48(%eax),%eax
  80115a:	83 ec 04             	sub    $0x4,%esp
  80115d:	53                   	push   %ebx
  80115e:	50                   	push   %eax
  80115f:	68 50 27 80 00       	push   $0x802750
  801164:	e8 85 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801171:	eb 26                	jmp    801199 <read+0x8a>
	}
	if (!dev->dev_read)
  801173:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801176:	8b 40 08             	mov    0x8(%eax),%eax
  801179:	85 c0                	test   %eax,%eax
  80117b:	74 17                	je     801194 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	ff 75 10             	pushl  0x10(%ebp)
  801183:	ff 75 0c             	pushl  0xc(%ebp)
  801186:	52                   	push   %edx
  801187:	ff d0                	call   *%eax
  801189:	89 c2                	mov    %eax,%edx
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	eb 09                	jmp    801199 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801190:	89 c2                	mov    %eax,%edx
  801192:	eb 05                	jmp    801199 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801194:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801199:	89 d0                	mov    %edx,%eax
  80119b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    

008011a0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	57                   	push   %edi
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	83 ec 0c             	sub    $0xc,%esp
  8011a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b4:	eb 21                	jmp    8011d7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b6:	83 ec 04             	sub    $0x4,%esp
  8011b9:	89 f0                	mov    %esi,%eax
  8011bb:	29 d8                	sub    %ebx,%eax
  8011bd:	50                   	push   %eax
  8011be:	89 d8                	mov    %ebx,%eax
  8011c0:	03 45 0c             	add    0xc(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	57                   	push   %edi
  8011c5:	e8 45 ff ff ff       	call   80110f <read>
		if (m < 0)
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 10                	js     8011e1 <readn+0x41>
			return m;
		if (m == 0)
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	74 0a                	je     8011df <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d5:	01 c3                	add    %eax,%ebx
  8011d7:	39 f3                	cmp    %esi,%ebx
  8011d9:	72 db                	jb     8011b6 <readn+0x16>
  8011db:	89 d8                	mov    %ebx,%eax
  8011dd:	eb 02                	jmp    8011e1 <readn+0x41>
  8011df:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 14             	sub    $0x14,%esp
  8011f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	53                   	push   %ebx
  8011f8:	e8 ac fc ff ff       	call   800ea9 <fd_lookup>
  8011fd:	83 c4 08             	add    $0x8,%esp
  801200:	89 c2                	mov    %eax,%edx
  801202:	85 c0                	test   %eax,%eax
  801204:	78 68                	js     80126e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801210:	ff 30                	pushl  (%eax)
  801212:	e8 e8 fc ff ff       	call   800eff <dev_lookup>
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 47                	js     801265 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801221:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801225:	75 21                	jne    801248 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801227:	a1 08 40 80 00       	mov    0x804008,%eax
  80122c:	8b 40 48             	mov    0x48(%eax),%eax
  80122f:	83 ec 04             	sub    $0x4,%esp
  801232:	53                   	push   %ebx
  801233:	50                   	push   %eax
  801234:	68 6c 27 80 00       	push   $0x80276c
  801239:	e8 b0 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801246:	eb 26                	jmp    80126e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801248:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124b:	8b 52 0c             	mov    0xc(%edx),%edx
  80124e:	85 d2                	test   %edx,%edx
  801250:	74 17                	je     801269 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	ff 75 10             	pushl  0x10(%ebp)
  801258:	ff 75 0c             	pushl  0xc(%ebp)
  80125b:	50                   	push   %eax
  80125c:	ff d2                	call   *%edx
  80125e:	89 c2                	mov    %eax,%edx
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	eb 09                	jmp    80126e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801265:	89 c2                	mov    %eax,%edx
  801267:	eb 05                	jmp    80126e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801269:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80126e:	89 d0                	mov    %edx,%eax
  801270:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801273:	c9                   	leave  
  801274:	c3                   	ret    

00801275 <seek>:

int
seek(int fdnum, off_t offset)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80127b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127e:	50                   	push   %eax
  80127f:	ff 75 08             	pushl  0x8(%ebp)
  801282:	e8 22 fc ff ff       	call   800ea9 <fd_lookup>
  801287:	83 c4 08             	add    $0x8,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 0e                	js     80129c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801291:	8b 55 0c             	mov    0xc(%ebp),%edx
  801294:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    

0080129e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 14             	sub    $0x14,%esp
  8012a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	53                   	push   %ebx
  8012ad:	e8 f7 fb ff ff       	call   800ea9 <fd_lookup>
  8012b2:	83 c4 08             	add    $0x8,%esp
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 65                	js     801320 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	ff 30                	pushl  (%eax)
  8012c7:	e8 33 fc ff ff       	call   800eff <dev_lookup>
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 44                	js     801317 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012da:	75 21                	jne    8012fd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012dc:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e1:	8b 40 48             	mov    0x48(%eax),%eax
  8012e4:	83 ec 04             	sub    $0x4,%esp
  8012e7:	53                   	push   %ebx
  8012e8:	50                   	push   %eax
  8012e9:	68 2c 27 80 00       	push   $0x80272c
  8012ee:	e8 fb ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012fb:	eb 23                	jmp    801320 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801300:	8b 52 18             	mov    0x18(%edx),%edx
  801303:	85 d2                	test   %edx,%edx
  801305:	74 14                	je     80131b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	ff 75 0c             	pushl  0xc(%ebp)
  80130d:	50                   	push   %eax
  80130e:	ff d2                	call   *%edx
  801310:	89 c2                	mov    %eax,%edx
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	eb 09                	jmp    801320 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801317:	89 c2                	mov    %eax,%edx
  801319:	eb 05                	jmp    801320 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80131b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801320:	89 d0                	mov    %edx,%eax
  801322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	53                   	push   %ebx
  80132b:	83 ec 14             	sub    $0x14,%esp
  80132e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801331:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801334:	50                   	push   %eax
  801335:	ff 75 08             	pushl  0x8(%ebp)
  801338:	e8 6c fb ff ff       	call   800ea9 <fd_lookup>
  80133d:	83 c4 08             	add    $0x8,%esp
  801340:	89 c2                	mov    %eax,%edx
  801342:	85 c0                	test   %eax,%eax
  801344:	78 58                	js     80139e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801350:	ff 30                	pushl  (%eax)
  801352:	e8 a8 fb ff ff       	call   800eff <dev_lookup>
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	85 c0                	test   %eax,%eax
  80135c:	78 37                	js     801395 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80135e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801361:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801365:	74 32                	je     801399 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801367:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80136a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801371:	00 00 00 
	stat->st_isdir = 0;
  801374:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80137b:	00 00 00 
	stat->st_dev = dev;
  80137e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	53                   	push   %ebx
  801388:	ff 75 f0             	pushl  -0x10(%ebp)
  80138b:	ff 50 14             	call   *0x14(%eax)
  80138e:	89 c2                	mov    %eax,%edx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	eb 09                	jmp    80139e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801395:	89 c2                	mov    %eax,%edx
  801397:	eb 05                	jmp    80139e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801399:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80139e:	89 d0                	mov    %edx,%eax
  8013a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	56                   	push   %esi
  8013a9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	6a 00                	push   $0x0
  8013af:	ff 75 08             	pushl  0x8(%ebp)
  8013b2:	e8 d6 01 00 00       	call   80158d <open>
  8013b7:	89 c3                	mov    %eax,%ebx
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 1b                	js     8013db <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	ff 75 0c             	pushl  0xc(%ebp)
  8013c6:	50                   	push   %eax
  8013c7:	e8 5b ff ff ff       	call   801327 <fstat>
  8013cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ce:	89 1c 24             	mov    %ebx,(%esp)
  8013d1:	e8 fd fb ff ff       	call   800fd3 <close>
	return r;
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	89 f0                	mov    %esi,%eax
}
  8013db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5e                   	pop    %esi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
  8013e7:	89 c6                	mov    %eax,%esi
  8013e9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013eb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013f2:	75 12                	jne    801406 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f4:	83 ec 0c             	sub    $0xc,%esp
  8013f7:	6a 01                	push   $0x1
  8013f9:	e8 34 0c 00 00       	call   802032 <ipc_find_env>
  8013fe:	a3 00 40 80 00       	mov    %eax,0x804000
  801403:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801406:	6a 07                	push   $0x7
  801408:	68 00 50 80 00       	push   $0x805000
  80140d:	56                   	push   %esi
  80140e:	ff 35 00 40 80 00    	pushl  0x804000
  801414:	e8 c5 0b 00 00       	call   801fde <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801419:	83 c4 0c             	add    $0xc,%esp
  80141c:	6a 00                	push   $0x0
  80141e:	53                   	push   %ebx
  80141f:	6a 00                	push   $0x0
  801421:	e8 51 0b 00 00       	call   801f77 <ipc_recv>
}
  801426:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801429:	5b                   	pop    %ebx
  80142a:	5e                   	pop    %esi
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    

0080142d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	8b 40 0c             	mov    0xc(%eax),%eax
  801439:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80143e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801441:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801446:	ba 00 00 00 00       	mov    $0x0,%edx
  80144b:	b8 02 00 00 00       	mov    $0x2,%eax
  801450:	e8 8d ff ff ff       	call   8013e2 <fsipc>
}
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	8b 40 0c             	mov    0xc(%eax),%eax
  801463:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801468:	ba 00 00 00 00       	mov    $0x0,%edx
  80146d:	b8 06 00 00 00       	mov    $0x6,%eax
  801472:	e8 6b ff ff ff       	call   8013e2 <fsipc>
}
  801477:	c9                   	leave  
  801478:	c3                   	ret    

00801479 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	53                   	push   %ebx
  80147d:	83 ec 04             	sub    $0x4,%esp
  801480:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	8b 40 0c             	mov    0xc(%eax),%eax
  801489:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148e:	ba 00 00 00 00       	mov    $0x0,%edx
  801493:	b8 05 00 00 00       	mov    $0x5,%eax
  801498:	e8 45 ff ff ff       	call   8013e2 <fsipc>
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 2c                	js     8014cd <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	68 00 50 80 00       	push   $0x805000
  8014a9:	53                   	push   %ebx
  8014aa:	e8 c4 f2 ff ff       	call   800773 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014af:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ba:	a1 84 50 80 00       	mov    0x805084,%eax
  8014bf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	83 ec 0c             	sub    $0xc,%esp
  8014d8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014db:	8b 55 08             	mov    0x8(%ebp),%edx
  8014de:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014e7:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014ec:	50                   	push   %eax
  8014ed:	ff 75 0c             	pushl  0xc(%ebp)
  8014f0:	68 08 50 80 00       	push   $0x805008
  8014f5:	e8 0b f4 ff ff       	call   800905 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ff:	b8 04 00 00 00       	mov    $0x4,%eax
  801504:	e8 d9 fe ff ff       	call   8013e2 <fsipc>

}
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	8b 40 0c             	mov    0xc(%eax),%eax
  801519:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801524:	ba 00 00 00 00       	mov    $0x0,%edx
  801529:	b8 03 00 00 00       	mov    $0x3,%eax
  80152e:	e8 af fe ff ff       	call   8013e2 <fsipc>
  801533:	89 c3                	mov    %eax,%ebx
  801535:	85 c0                	test   %eax,%eax
  801537:	78 4b                	js     801584 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801539:	39 c6                	cmp    %eax,%esi
  80153b:	73 16                	jae    801553 <devfile_read+0x48>
  80153d:	68 a0 27 80 00       	push   $0x8027a0
  801542:	68 a7 27 80 00       	push   $0x8027a7
  801547:	6a 7c                	push   $0x7c
  801549:	68 bc 27 80 00       	push   $0x8027bc
  80154e:	e8 c2 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  801553:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801558:	7e 16                	jle    801570 <devfile_read+0x65>
  80155a:	68 c7 27 80 00       	push   $0x8027c7
  80155f:	68 a7 27 80 00       	push   $0x8027a7
  801564:	6a 7d                	push   $0x7d
  801566:	68 bc 27 80 00       	push   $0x8027bc
  80156b:	e8 a5 eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801570:	83 ec 04             	sub    $0x4,%esp
  801573:	50                   	push   %eax
  801574:	68 00 50 80 00       	push   $0x805000
  801579:	ff 75 0c             	pushl  0xc(%ebp)
  80157c:	e8 84 f3 ff ff       	call   800905 <memmove>
	return r;
  801581:	83 c4 10             	add    $0x10,%esp
}
  801584:	89 d8                	mov    %ebx,%eax
  801586:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	5d                   	pop    %ebp
  80158c:	c3                   	ret    

0080158d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	53                   	push   %ebx
  801591:	83 ec 20             	sub    $0x20,%esp
  801594:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801597:	53                   	push   %ebx
  801598:	e8 9d f1 ff ff       	call   80073a <strlen>
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a5:	7f 67                	jg     80160e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	e8 a7 f8 ff ff       	call   800e5a <fd_alloc>
  8015b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 57                	js     801613 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	68 00 50 80 00       	push   $0x805000
  8015c5:	e8 a9 f1 ff ff       	call   800773 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015da:	e8 03 fe ff ff       	call   8013e2 <fsipc>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	79 14                	jns    8015fc <open+0x6f>
		fd_close(fd, 0);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	6a 00                	push   $0x0
  8015ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f0:	e8 5d f9 ff ff       	call   800f52 <fd_close>
		return r;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	89 da                	mov    %ebx,%edx
  8015fa:	eb 17                	jmp    801613 <open+0x86>
	}

	return fd2num(fd);
  8015fc:	83 ec 0c             	sub    $0xc,%esp
  8015ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801602:	e8 2c f8 ff ff       	call   800e33 <fd2num>
  801607:	89 c2                	mov    %eax,%edx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb 05                	jmp    801613 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80160e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801613:	89 d0                	mov    %edx,%eax
  801615:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801620:	ba 00 00 00 00       	mov    $0x0,%edx
  801625:	b8 08 00 00 00       	mov    $0x8,%eax
  80162a:	e8 b3 fd ff ff       	call   8013e2 <fsipc>
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801637:	68 d3 27 80 00       	push   $0x8027d3
  80163c:	ff 75 0c             	pushl  0xc(%ebp)
  80163f:	e8 2f f1 ff ff       	call   800773 <strcpy>
	return 0;
}
  801644:	b8 00 00 00 00       	mov    $0x0,%eax
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	53                   	push   %ebx
  80164f:	83 ec 10             	sub    $0x10,%esp
  801652:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801655:	53                   	push   %ebx
  801656:	e8 10 0a 00 00       	call   80206b <pageref>
  80165b:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80165e:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801663:	83 f8 01             	cmp    $0x1,%eax
  801666:	75 10                	jne    801678 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	ff 73 0c             	pushl  0xc(%ebx)
  80166e:	e8 c0 02 00 00       	call   801933 <nsipc_close>
  801673:	89 c2                	mov    %eax,%edx
  801675:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801678:	89 d0                	mov    %edx,%eax
  80167a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801685:	6a 00                	push   $0x0
  801687:	ff 75 10             	pushl  0x10(%ebp)
  80168a:	ff 75 0c             	pushl  0xc(%ebp)
  80168d:	8b 45 08             	mov    0x8(%ebp),%eax
  801690:	ff 70 0c             	pushl  0xc(%eax)
  801693:	e8 78 03 00 00       	call   801a10 <nsipc_send>
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016a0:	6a 00                	push   $0x0
  8016a2:	ff 75 10             	pushl  0x10(%ebp)
  8016a5:	ff 75 0c             	pushl  0xc(%ebp)
  8016a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ab:	ff 70 0c             	pushl  0xc(%eax)
  8016ae:	e8 f1 02 00 00       	call   8019a4 <nsipc_recv>
}
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016bb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016be:	52                   	push   %edx
  8016bf:	50                   	push   %eax
  8016c0:	e8 e4 f7 ff ff       	call   800ea9 <fd_lookup>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 17                	js     8016e3 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cf:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016d5:	39 08                	cmp    %ecx,(%eax)
  8016d7:	75 05                	jne    8016de <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016dc:	eb 05                	jmp    8016e3 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8016de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	56                   	push   %esi
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 1c             	sub    $0x1c,%esp
  8016ed:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f2:	50                   	push   %eax
  8016f3:	e8 62 f7 ff ff       	call   800e5a <fd_alloc>
  8016f8:	89 c3                	mov    %eax,%ebx
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 1b                	js     80171c <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801701:	83 ec 04             	sub    $0x4,%esp
  801704:	68 07 04 00 00       	push   $0x407
  801709:	ff 75 f4             	pushl  -0xc(%ebp)
  80170c:	6a 00                	push   $0x0
  80170e:	e8 63 f4 ff ff       	call   800b76 <sys_page_alloc>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	79 10                	jns    80172c <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80171c:	83 ec 0c             	sub    $0xc,%esp
  80171f:	56                   	push   %esi
  801720:	e8 0e 02 00 00       	call   801933 <nsipc_close>
		return r;
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	89 d8                	mov    %ebx,%eax
  80172a:	eb 24                	jmp    801750 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80172c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801735:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801741:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	50                   	push   %eax
  801748:	e8 e6 f6 ff ff       	call   800e33 <fd2num>
  80174d:	83 c4 10             	add    $0x10,%esp
}
  801750:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80175d:	8b 45 08             	mov    0x8(%ebp),%eax
  801760:	e8 50 ff ff ff       	call   8016b5 <fd2sockid>
		return r;
  801765:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801767:	85 c0                	test   %eax,%eax
  801769:	78 1f                	js     80178a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80176b:	83 ec 04             	sub    $0x4,%esp
  80176e:	ff 75 10             	pushl  0x10(%ebp)
  801771:	ff 75 0c             	pushl  0xc(%ebp)
  801774:	50                   	push   %eax
  801775:	e8 12 01 00 00       	call   80188c <nsipc_accept>
  80177a:	83 c4 10             	add    $0x10,%esp
		return r;
  80177d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 07                	js     80178a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801783:	e8 5d ff ff ff       	call   8016e5 <alloc_sockfd>
  801788:	89 c1                	mov    %eax,%ecx
}
  80178a:	89 c8                	mov    %ecx,%eax
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801794:	8b 45 08             	mov    0x8(%ebp),%eax
  801797:	e8 19 ff ff ff       	call   8016b5 <fd2sockid>
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 12                	js     8017b2 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017a0:	83 ec 04             	sub    $0x4,%esp
  8017a3:	ff 75 10             	pushl  0x10(%ebp)
  8017a6:	ff 75 0c             	pushl  0xc(%ebp)
  8017a9:	50                   	push   %eax
  8017aa:	e8 2d 01 00 00       	call   8018dc <nsipc_bind>
  8017af:	83 c4 10             	add    $0x10,%esp
}
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <shutdown>:

int
shutdown(int s, int how)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	e8 f3 fe ff ff       	call   8016b5 <fd2sockid>
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 0f                	js     8017d5 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	ff 75 0c             	pushl  0xc(%ebp)
  8017cc:	50                   	push   %eax
  8017cd:	e8 3f 01 00 00       	call   801911 <nsipc_shutdown>
  8017d2:	83 c4 10             	add    $0x10,%esp
}
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	e8 d0 fe ff ff       	call   8016b5 <fd2sockid>
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 12                	js     8017fb <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8017e9:	83 ec 04             	sub    $0x4,%esp
  8017ec:	ff 75 10             	pushl  0x10(%ebp)
  8017ef:	ff 75 0c             	pushl  0xc(%ebp)
  8017f2:	50                   	push   %eax
  8017f3:	e8 55 01 00 00       	call   80194d <nsipc_connect>
  8017f8:	83 c4 10             	add    $0x10,%esp
}
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <listen>:

int
listen(int s, int backlog)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	e8 aa fe ff ff       	call   8016b5 <fd2sockid>
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 0f                	js     80181e <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80180f:	83 ec 08             	sub    $0x8,%esp
  801812:	ff 75 0c             	pushl  0xc(%ebp)
  801815:	50                   	push   %eax
  801816:	e8 67 01 00 00       	call   801982 <nsipc_listen>
  80181b:	83 c4 10             	add    $0x10,%esp
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801826:	ff 75 10             	pushl  0x10(%ebp)
  801829:	ff 75 0c             	pushl  0xc(%ebp)
  80182c:	ff 75 08             	pushl  0x8(%ebp)
  80182f:	e8 3a 02 00 00       	call   801a6e <nsipc_socket>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	78 05                	js     801840 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80183b:	e8 a5 fe ff ff       	call   8016e5 <alloc_sockfd>
}
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	53                   	push   %ebx
  801846:	83 ec 04             	sub    $0x4,%esp
  801849:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80184b:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801852:	75 12                	jne    801866 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801854:	83 ec 0c             	sub    $0xc,%esp
  801857:	6a 02                	push   $0x2
  801859:	e8 d4 07 00 00       	call   802032 <ipc_find_env>
  80185e:	a3 04 40 80 00       	mov    %eax,0x804004
  801863:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801866:	6a 07                	push   $0x7
  801868:	68 00 60 80 00       	push   $0x806000
  80186d:	53                   	push   %ebx
  80186e:	ff 35 04 40 80 00    	pushl  0x804004
  801874:	e8 65 07 00 00       	call   801fde <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801879:	83 c4 0c             	add    $0xc,%esp
  80187c:	6a 00                	push   $0x0
  80187e:	6a 00                	push   $0x0
  801880:	6a 00                	push   $0x0
  801882:	e8 f0 06 00 00       	call   801f77 <ipc_recv>
}
  801887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	56                   	push   %esi
  801890:	53                   	push   %ebx
  801891:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80189c:	8b 06                	mov    (%esi),%eax
  80189e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a8:	e8 95 ff ff ff       	call   801842 <nsipc>
  8018ad:	89 c3                	mov    %eax,%ebx
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 20                	js     8018d3 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018b3:	83 ec 04             	sub    $0x4,%esp
  8018b6:	ff 35 10 60 80 00    	pushl  0x806010
  8018bc:	68 00 60 80 00       	push   $0x806000
  8018c1:	ff 75 0c             	pushl  0xc(%ebp)
  8018c4:	e8 3c f0 ff ff       	call   800905 <memmove>
		*addrlen = ret->ret_addrlen;
  8018c9:	a1 10 60 80 00       	mov    0x806010,%eax
  8018ce:	89 06                	mov    %eax,(%esi)
  8018d0:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018d3:	89 d8                	mov    %ebx,%eax
  8018d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	53                   	push   %ebx
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018ee:	53                   	push   %ebx
  8018ef:	ff 75 0c             	pushl  0xc(%ebp)
  8018f2:	68 04 60 80 00       	push   $0x806004
  8018f7:	e8 09 f0 ff ff       	call   800905 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018fc:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801902:	b8 02 00 00 00       	mov    $0x2,%eax
  801907:	e8 36 ff ff ff       	call   801842 <nsipc>
}
  80190c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80191f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801922:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801927:	b8 03 00 00 00       	mov    $0x3,%eax
  80192c:	e8 11 ff ff ff       	call   801842 <nsipc>
}
  801931:	c9                   	leave  
  801932:	c3                   	ret    

00801933 <nsipc_close>:

int
nsipc_close(int s)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801941:	b8 04 00 00 00       	mov    $0x4,%eax
  801946:	e8 f7 fe ff ff       	call   801842 <nsipc>
}
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	53                   	push   %ebx
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
  80195a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80195f:	53                   	push   %ebx
  801960:	ff 75 0c             	pushl  0xc(%ebp)
  801963:	68 04 60 80 00       	push   $0x806004
  801968:	e8 98 ef ff ff       	call   800905 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80196d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801973:	b8 05 00 00 00       	mov    $0x5,%eax
  801978:	e8 c5 fe ff ff       	call   801842 <nsipc>
}
  80197d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801988:	8b 45 08             	mov    0x8(%ebp),%eax
  80198b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801990:	8b 45 0c             	mov    0xc(%ebp),%eax
  801993:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801998:	b8 06 00 00 00       	mov    $0x6,%eax
  80199d:	e8 a0 fe ff ff       	call   801842 <nsipc>
}
  8019a2:	c9                   	leave  
  8019a3:	c3                   	ret    

008019a4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8019af:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019b4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019c2:	b8 07 00 00 00       	mov    $0x7,%eax
  8019c7:	e8 76 fe ff ff       	call   801842 <nsipc>
  8019cc:	89 c3                	mov    %eax,%ebx
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 35                	js     801a07 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019d2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019d7:	7f 04                	jg     8019dd <nsipc_recv+0x39>
  8019d9:	39 c6                	cmp    %eax,%esi
  8019db:	7d 16                	jge    8019f3 <nsipc_recv+0x4f>
  8019dd:	68 df 27 80 00       	push   $0x8027df
  8019e2:	68 a7 27 80 00       	push   $0x8027a7
  8019e7:	6a 62                	push   $0x62
  8019e9:	68 f4 27 80 00       	push   $0x8027f4
  8019ee:	e8 22 e7 ff ff       	call   800115 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019f3:	83 ec 04             	sub    $0x4,%esp
  8019f6:	50                   	push   %eax
  8019f7:	68 00 60 80 00       	push   $0x806000
  8019fc:	ff 75 0c             	pushl  0xc(%ebp)
  8019ff:	e8 01 ef ff ff       	call   800905 <memmove>
  801a04:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a07:	89 d8                	mov    %ebx,%eax
  801a09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	53                   	push   %ebx
  801a14:	83 ec 04             	sub    $0x4,%esp
  801a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a22:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a28:	7e 16                	jle    801a40 <nsipc_send+0x30>
  801a2a:	68 00 28 80 00       	push   $0x802800
  801a2f:	68 a7 27 80 00       	push   $0x8027a7
  801a34:	6a 6d                	push   $0x6d
  801a36:	68 f4 27 80 00       	push   $0x8027f4
  801a3b:	e8 d5 e6 ff ff       	call   800115 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a40:	83 ec 04             	sub    $0x4,%esp
  801a43:	53                   	push   %ebx
  801a44:	ff 75 0c             	pushl  0xc(%ebp)
  801a47:	68 0c 60 80 00       	push   $0x80600c
  801a4c:	e8 b4 ee ff ff       	call   800905 <memmove>
	nsipcbuf.send.req_size = size;
  801a51:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a57:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a5f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a64:	e8 d9 fd ff ff       	call   801842 <nsipc>
}
  801a69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a84:	8b 45 10             	mov    0x10(%ebp),%eax
  801a87:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a8c:	b8 09 00 00 00       	mov    $0x9,%eax
  801a91:	e8 ac fd ff ff       	call   801842 <nsipc>
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	ff 75 08             	pushl  0x8(%ebp)
  801aa6:	e8 98 f3 ff ff       	call   800e43 <fd2data>
  801aab:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aad:	83 c4 08             	add    $0x8,%esp
  801ab0:	68 0c 28 80 00       	push   $0x80280c
  801ab5:	53                   	push   %ebx
  801ab6:	e8 b8 ec ff ff       	call   800773 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801abb:	8b 46 04             	mov    0x4(%esi),%eax
  801abe:	2b 06                	sub    (%esi),%eax
  801ac0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ac6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801acd:	00 00 00 
	stat->st_dev = &devpipe;
  801ad0:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ad7:	30 80 00 
	return 0;
}
  801ada:	b8 00 00 00 00       	mov    $0x0,%eax
  801adf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	53                   	push   %ebx
  801aea:	83 ec 0c             	sub    $0xc,%esp
  801aed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801af0:	53                   	push   %ebx
  801af1:	6a 00                	push   $0x0
  801af3:	e8 03 f1 ff ff       	call   800bfb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801af8:	89 1c 24             	mov    %ebx,(%esp)
  801afb:	e8 43 f3 ff ff       	call   800e43 <fd2data>
  801b00:	83 c4 08             	add    $0x8,%esp
  801b03:	50                   	push   %eax
  801b04:	6a 00                	push   $0x0
  801b06:	e8 f0 f0 ff ff       	call   800bfb <sys_page_unmap>
}
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	57                   	push   %edi
  801b14:	56                   	push   %esi
  801b15:	53                   	push   %ebx
  801b16:	83 ec 1c             	sub    $0x1c,%esp
  801b19:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b1c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b1e:	a1 08 40 80 00       	mov    0x804008,%eax
  801b23:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b26:	83 ec 0c             	sub    $0xc,%esp
  801b29:	ff 75 e0             	pushl  -0x20(%ebp)
  801b2c:	e8 3a 05 00 00       	call   80206b <pageref>
  801b31:	89 c3                	mov    %eax,%ebx
  801b33:	89 3c 24             	mov    %edi,(%esp)
  801b36:	e8 30 05 00 00       	call   80206b <pageref>
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	39 c3                	cmp    %eax,%ebx
  801b40:	0f 94 c1             	sete   %cl
  801b43:	0f b6 c9             	movzbl %cl,%ecx
  801b46:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b49:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b4f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b52:	39 ce                	cmp    %ecx,%esi
  801b54:	74 1b                	je     801b71 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b56:	39 c3                	cmp    %eax,%ebx
  801b58:	75 c4                	jne    801b1e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b5a:	8b 42 58             	mov    0x58(%edx),%eax
  801b5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b60:	50                   	push   %eax
  801b61:	56                   	push   %esi
  801b62:	68 13 28 80 00       	push   $0x802813
  801b67:	e8 82 e6 ff ff       	call   8001ee <cprintf>
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	eb ad                	jmp    801b1e <_pipeisclosed+0xe>
	}
}
  801b71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5e                   	pop    %esi
  801b79:	5f                   	pop    %edi
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	57                   	push   %edi
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 28             	sub    $0x28,%esp
  801b85:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b88:	56                   	push   %esi
  801b89:	e8 b5 f2 ff ff       	call   800e43 <fd2data>
  801b8e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	bf 00 00 00 00       	mov    $0x0,%edi
  801b98:	eb 4b                	jmp    801be5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b9a:	89 da                	mov    %ebx,%edx
  801b9c:	89 f0                	mov    %esi,%eax
  801b9e:	e8 6d ff ff ff       	call   801b10 <_pipeisclosed>
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	75 48                	jne    801bef <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ba7:	e8 ab ef ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bac:	8b 43 04             	mov    0x4(%ebx),%eax
  801baf:	8b 0b                	mov    (%ebx),%ecx
  801bb1:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb4:	39 d0                	cmp    %edx,%eax
  801bb6:	73 e2                	jae    801b9a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bbf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc2:	89 c2                	mov    %eax,%edx
  801bc4:	c1 fa 1f             	sar    $0x1f,%edx
  801bc7:	89 d1                	mov    %edx,%ecx
  801bc9:	c1 e9 1b             	shr    $0x1b,%ecx
  801bcc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bcf:	83 e2 1f             	and    $0x1f,%edx
  801bd2:	29 ca                	sub    %ecx,%edx
  801bd4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bd8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bdc:	83 c0 01             	add    $0x1,%eax
  801bdf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be2:	83 c7 01             	add    $0x1,%edi
  801be5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801be8:	75 c2                	jne    801bac <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bea:	8b 45 10             	mov    0x10(%ebp),%eax
  801bed:	eb 05                	jmp    801bf4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5f                   	pop    %edi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	83 ec 18             	sub    $0x18,%esp
  801c05:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c08:	57                   	push   %edi
  801c09:	e8 35 f2 ff ff       	call   800e43 <fd2data>
  801c0e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c18:	eb 3d                	jmp    801c57 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c1a:	85 db                	test   %ebx,%ebx
  801c1c:	74 04                	je     801c22 <devpipe_read+0x26>
				return i;
  801c1e:	89 d8                	mov    %ebx,%eax
  801c20:	eb 44                	jmp    801c66 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c22:	89 f2                	mov    %esi,%edx
  801c24:	89 f8                	mov    %edi,%eax
  801c26:	e8 e5 fe ff ff       	call   801b10 <_pipeisclosed>
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	75 32                	jne    801c61 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c2f:	e8 23 ef ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c34:	8b 06                	mov    (%esi),%eax
  801c36:	3b 46 04             	cmp    0x4(%esi),%eax
  801c39:	74 df                	je     801c1a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3b:	99                   	cltd   
  801c3c:	c1 ea 1b             	shr    $0x1b,%edx
  801c3f:	01 d0                	add    %edx,%eax
  801c41:	83 e0 1f             	and    $0x1f,%eax
  801c44:	29 d0                	sub    %edx,%eax
  801c46:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c51:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c54:	83 c3 01             	add    $0x1,%ebx
  801c57:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c5a:	75 d8                	jne    801c34 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5f:	eb 05                	jmp    801c66 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	56                   	push   %esi
  801c72:	53                   	push   %ebx
  801c73:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c79:	50                   	push   %eax
  801c7a:	e8 db f1 ff ff       	call   800e5a <fd_alloc>
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	89 c2                	mov    %eax,%edx
  801c84:	85 c0                	test   %eax,%eax
  801c86:	0f 88 2c 01 00 00    	js     801db8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8c:	83 ec 04             	sub    $0x4,%esp
  801c8f:	68 07 04 00 00       	push   $0x407
  801c94:	ff 75 f4             	pushl  -0xc(%ebp)
  801c97:	6a 00                	push   $0x0
  801c99:	e8 d8 ee ff ff       	call   800b76 <sys_page_alloc>
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	89 c2                	mov    %eax,%edx
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	0f 88 0d 01 00 00    	js     801db8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cab:	83 ec 0c             	sub    $0xc,%esp
  801cae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb1:	50                   	push   %eax
  801cb2:	e8 a3 f1 ff ff       	call   800e5a <fd_alloc>
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	0f 88 e2 00 00 00    	js     801da6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc4:	83 ec 04             	sub    $0x4,%esp
  801cc7:	68 07 04 00 00       	push   $0x407
  801ccc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 a0 ee ff ff       	call   800b76 <sys_page_alloc>
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	0f 88 c3 00 00 00    	js     801da6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ce3:	83 ec 0c             	sub    $0xc,%esp
  801ce6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce9:	e8 55 f1 ff ff       	call   800e43 <fd2data>
  801cee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf0:	83 c4 0c             	add    $0xc,%esp
  801cf3:	68 07 04 00 00       	push   $0x407
  801cf8:	50                   	push   %eax
  801cf9:	6a 00                	push   $0x0
  801cfb:	e8 76 ee ff ff       	call   800b76 <sys_page_alloc>
  801d00:	89 c3                	mov    %eax,%ebx
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	85 c0                	test   %eax,%eax
  801d07:	0f 88 89 00 00 00    	js     801d96 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0d:	83 ec 0c             	sub    $0xc,%esp
  801d10:	ff 75 f0             	pushl  -0x10(%ebp)
  801d13:	e8 2b f1 ff ff       	call   800e43 <fd2data>
  801d18:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d1f:	50                   	push   %eax
  801d20:	6a 00                	push   $0x0
  801d22:	56                   	push   %esi
  801d23:	6a 00                	push   $0x0
  801d25:	e8 8f ee ff ff       	call   800bb9 <sys_page_map>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	83 c4 20             	add    $0x20,%esp
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	78 55                	js     801d88 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d33:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d41:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d48:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d51:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d56:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d5d:	83 ec 0c             	sub    $0xc,%esp
  801d60:	ff 75 f4             	pushl  -0xc(%ebp)
  801d63:	e8 cb f0 ff ff       	call   800e33 <fd2num>
  801d68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d6d:	83 c4 04             	add    $0x4,%esp
  801d70:	ff 75 f0             	pushl  -0x10(%ebp)
  801d73:	e8 bb f0 ff ff       	call   800e33 <fd2num>
  801d78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	ba 00 00 00 00       	mov    $0x0,%edx
  801d86:	eb 30                	jmp    801db8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d88:	83 ec 08             	sub    $0x8,%esp
  801d8b:	56                   	push   %esi
  801d8c:	6a 00                	push   $0x0
  801d8e:	e8 68 ee ff ff       	call   800bfb <sys_page_unmap>
  801d93:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d96:	83 ec 08             	sub    $0x8,%esp
  801d99:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9c:	6a 00                	push   $0x0
  801d9e:	e8 58 ee ff ff       	call   800bfb <sys_page_unmap>
  801da3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801da6:	83 ec 08             	sub    $0x8,%esp
  801da9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dac:	6a 00                	push   $0x0
  801dae:	e8 48 ee ff ff       	call   800bfb <sys_page_unmap>
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801db8:	89 d0                	mov    %edx,%eax
  801dba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5d                   	pop    %ebp
  801dc0:	c3                   	ret    

00801dc1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dca:	50                   	push   %eax
  801dcb:	ff 75 08             	pushl  0x8(%ebp)
  801dce:	e8 d6 f0 ff ff       	call   800ea9 <fd_lookup>
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 18                	js     801df2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dda:	83 ec 0c             	sub    $0xc,%esp
  801ddd:	ff 75 f4             	pushl  -0xc(%ebp)
  801de0:	e8 5e f0 ff ff       	call   800e43 <fd2data>
	return _pipeisclosed(fd, p);
  801de5:	89 c2                	mov    %eax,%edx
  801de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dea:	e8 21 fd ff ff       	call   801b10 <_pipeisclosed>
  801def:	83 c4 10             	add    $0x10,%esp
}
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801df7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    

00801dfe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e04:	68 2b 28 80 00       	push   $0x80282b
  801e09:	ff 75 0c             	pushl  0xc(%ebp)
  801e0c:	e8 62 e9 ff ff       	call   800773 <strcpy>
	return 0;
}
  801e11:	b8 00 00 00 00       	mov    $0x0,%eax
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    

00801e18 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	57                   	push   %edi
  801e1c:	56                   	push   %esi
  801e1d:	53                   	push   %ebx
  801e1e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e24:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e29:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2f:	eb 2d                	jmp    801e5e <devcons_write+0x46>
		m = n - tot;
  801e31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e34:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e36:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e39:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e3e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e41:	83 ec 04             	sub    $0x4,%esp
  801e44:	53                   	push   %ebx
  801e45:	03 45 0c             	add    0xc(%ebp),%eax
  801e48:	50                   	push   %eax
  801e49:	57                   	push   %edi
  801e4a:	e8 b6 ea ff ff       	call   800905 <memmove>
		sys_cputs(buf, m);
  801e4f:	83 c4 08             	add    $0x8,%esp
  801e52:	53                   	push   %ebx
  801e53:	57                   	push   %edi
  801e54:	e8 61 ec ff ff       	call   800aba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e59:	01 de                	add    %ebx,%esi
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	89 f0                	mov    %esi,%eax
  801e60:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e63:	72 cc                	jb     801e31 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5e                   	pop    %esi
  801e6a:	5f                   	pop    %edi
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    

00801e6d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	83 ec 08             	sub    $0x8,%esp
  801e73:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e7c:	74 2a                	je     801ea8 <devcons_read+0x3b>
  801e7e:	eb 05                	jmp    801e85 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e80:	e8 d2 ec ff ff       	call   800b57 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e85:	e8 4e ec ff ff       	call   800ad8 <sys_cgetc>
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	74 f2                	je     801e80 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 16                	js     801ea8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e92:	83 f8 04             	cmp    $0x4,%eax
  801e95:	74 0c                	je     801ea3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e9a:	88 02                	mov    %al,(%edx)
	return 1;
  801e9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea1:	eb 05                	jmp    801ea8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eb6:	6a 01                	push   $0x1
  801eb8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ebb:	50                   	push   %eax
  801ebc:	e8 f9 eb ff ff       	call   800aba <sys_cputs>
}
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	c9                   	leave  
  801ec5:	c3                   	ret    

00801ec6 <getchar>:

int
getchar(void)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ecc:	6a 01                	push   $0x1
  801ece:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed1:	50                   	push   %eax
  801ed2:	6a 00                	push   $0x0
  801ed4:	e8 36 f2 ff ff       	call   80110f <read>
	if (r < 0)
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	85 c0                	test   %eax,%eax
  801ede:	78 0f                	js     801eef <getchar+0x29>
		return r;
	if (r < 1)
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	7e 06                	jle    801eea <getchar+0x24>
		return -E_EOF;
	return c;
  801ee4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ee8:	eb 05                	jmp    801eef <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eea:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eef:	c9                   	leave  
  801ef0:	c3                   	ret    

00801ef1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efa:	50                   	push   %eax
  801efb:	ff 75 08             	pushl  0x8(%ebp)
  801efe:	e8 a6 ef ff ff       	call   800ea9 <fd_lookup>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	85 c0                	test   %eax,%eax
  801f08:	78 11                	js     801f1b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f13:	39 10                	cmp    %edx,(%eax)
  801f15:	0f 94 c0             	sete   %al
  801f18:	0f b6 c0             	movzbl %al,%eax
}
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    

00801f1d <opencons>:

int
opencons(void)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f26:	50                   	push   %eax
  801f27:	e8 2e ef ff ff       	call   800e5a <fd_alloc>
  801f2c:	83 c4 10             	add    $0x10,%esp
		return r;
  801f2f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f31:	85 c0                	test   %eax,%eax
  801f33:	78 3e                	js     801f73 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f35:	83 ec 04             	sub    $0x4,%esp
  801f38:	68 07 04 00 00       	push   $0x407
  801f3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f40:	6a 00                	push   $0x0
  801f42:	e8 2f ec ff ff       	call   800b76 <sys_page_alloc>
  801f47:	83 c4 10             	add    $0x10,%esp
		return r;
  801f4a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	78 23                	js     801f73 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f50:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f59:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f65:	83 ec 0c             	sub    $0xc,%esp
  801f68:	50                   	push   %eax
  801f69:	e8 c5 ee ff ff       	call   800e33 <fd2num>
  801f6e:	89 c2                	mov    %eax,%edx
  801f70:	83 c4 10             	add    $0x10,%esp
}
  801f73:	89 d0                	mov    %edx,%eax
  801f75:	c9                   	leave  
  801f76:	c3                   	ret    

00801f77 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	56                   	push   %esi
  801f7b:	53                   	push   %ebx
  801f7c:	8b 75 08             	mov    0x8(%ebp),%esi
  801f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f85:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f87:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f8c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f8f:	83 ec 0c             	sub    $0xc,%esp
  801f92:	50                   	push   %eax
  801f93:	e8 8e ed ff ff       	call   800d26 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 f6                	test   %esi,%esi
  801f9d:	74 14                	je     801fb3 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 09                	js     801fb1 <ipc_recv+0x3a>
  801fa8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fae:	8b 52 74             	mov    0x74(%edx),%edx
  801fb1:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801fb3:	85 db                	test   %ebx,%ebx
  801fb5:	74 14                	je     801fcb <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801fb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	78 09                	js     801fc9 <ipc_recv+0x52>
  801fc0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fc6:	8b 52 78             	mov    0x78(%edx),%edx
  801fc9:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	78 08                	js     801fd7 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801fcf:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fda:	5b                   	pop    %ebx
  801fdb:	5e                   	pop    %esi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 0c             	sub    $0xc,%esp
  801fe7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fea:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ff0:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ff2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ff7:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ffa:	ff 75 14             	pushl  0x14(%ebp)
  801ffd:	53                   	push   %ebx
  801ffe:	56                   	push   %esi
  801fff:	57                   	push   %edi
  802000:	e8 fe ec ff ff       	call   800d03 <sys_ipc_try_send>

		if (err < 0) {
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	79 1e                	jns    80202a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80200c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80200f:	75 07                	jne    802018 <ipc_send+0x3a>
				sys_yield();
  802011:	e8 41 eb ff ff       	call   800b57 <sys_yield>
  802016:	eb e2                	jmp    801ffa <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802018:	50                   	push   %eax
  802019:	68 37 28 80 00       	push   $0x802837
  80201e:	6a 49                	push   $0x49
  802020:	68 44 28 80 00       	push   $0x802844
  802025:	e8 eb e0 ff ff       	call   800115 <_panic>
		}

	} while (err < 0);

}
  80202a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802038:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80203d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802040:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802046:	8b 52 50             	mov    0x50(%edx),%edx
  802049:	39 ca                	cmp    %ecx,%edx
  80204b:	75 0d                	jne    80205a <ipc_find_env+0x28>
			return envs[i].env_id;
  80204d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802050:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802055:	8b 40 48             	mov    0x48(%eax),%eax
  802058:	eb 0f                	jmp    802069 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205a:	83 c0 01             	add    $0x1,%eax
  80205d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802062:	75 d9                	jne    80203d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802064:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    

0080206b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802071:	89 d0                	mov    %edx,%eax
  802073:	c1 e8 16             	shr    $0x16,%eax
  802076:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80207d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802082:	f6 c1 01             	test   $0x1,%cl
  802085:	74 1d                	je     8020a4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802087:	c1 ea 0c             	shr    $0xc,%edx
  80208a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802091:	f6 c2 01             	test   $0x1,%dl
  802094:	74 0e                	je     8020a4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802096:	c1 ea 0c             	shr    $0xc,%edx
  802099:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a0:	ef 
  8020a1:	0f b7 c0             	movzwl %ax,%eax
}
  8020a4:	5d                   	pop    %ebp
  8020a5:	c3                   	ret    
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
