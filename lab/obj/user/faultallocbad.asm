
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
  800040:	68 80 23 80 00       	push   $0x802380
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
  80006a:	68 a0 23 80 00       	push   $0x8023a0
  80006f:	6a 0f                	push   $0xf
  800071:	68 8a 23 80 00       	push   $0x80238a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 23 80 00       	push   $0x8023cc
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
  80009c:	e8 69 0d 00 00       	call   800e0a <set_pgfault_handler>
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
  800101:	e8 3a 0f 00 00       	call   801040 <close_all>
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
  800133:	68 f8 23 80 00       	push   $0x8023f8
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 64 28 80 00 	movl   $0x802864,(%esp)
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
  800251:	e8 9a 1e 00 00       	call   8020f0 <__udivdi3>
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
  800294:	e8 87 1f 00 00       	call   802220 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
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
  800398:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
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
  80045c:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 18                	jne    80047f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800467:	50                   	push   %eax
  800468:	68 33 24 80 00       	push   $0x802433
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
  800480:	68 f9 27 80 00       	push   $0x8027f9
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
  8004a4:	b8 2c 24 80 00       	mov    $0x80242c,%eax
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
  800b1f:	68 1f 27 80 00       	push   $0x80271f
  800b24:	6a 23                	push   $0x23
  800b26:	68 3c 27 80 00       	push   $0x80273c
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
  800ba0:	68 1f 27 80 00       	push   $0x80271f
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 3c 27 80 00       	push   $0x80273c
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
  800be2:	68 1f 27 80 00       	push   $0x80271f
  800be7:	6a 23                	push   $0x23
  800be9:	68 3c 27 80 00       	push   $0x80273c
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
  800c24:	68 1f 27 80 00       	push   $0x80271f
  800c29:	6a 23                	push   $0x23
  800c2b:	68 3c 27 80 00       	push   $0x80273c
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
  800c66:	68 1f 27 80 00       	push   $0x80271f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 3c 27 80 00       	push   $0x80273c
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
  800ca8:	68 1f 27 80 00       	push   $0x80271f
  800cad:	6a 23                	push   $0x23
  800caf:	68 3c 27 80 00       	push   $0x80273c
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
  800cea:	68 1f 27 80 00       	push   $0x80271f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 3c 27 80 00       	push   $0x80273c
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
  800d4e:	68 1f 27 80 00       	push   $0x80271f
  800d53:	6a 23                	push   $0x23
  800d55:	68 3c 27 80 00       	push   $0x80273c
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
  800daf:	68 1f 27 80 00       	push   $0x80271f
  800db4:	6a 23                	push   $0x23
  800db6:	68 3c 27 80 00       	push   $0x80273c
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

00800dc8 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	b8 10 00 00 00       	mov    $0x10,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 10                	push   $0x10
  800df1:	68 1f 27 80 00       	push   $0x80271f
  800df6:	6a 23                	push   $0x23
  800df8:	68 3c 27 80 00       	push   $0x80273c
  800dfd:	e8 13 f3 ff ff       	call   800115 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e10:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e17:	75 2e                	jne    800e47 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800e19:	e8 1a fd ff ff       	call   800b38 <sys_getenvid>
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	68 07 0e 00 00       	push   $0xe07
  800e26:	68 00 f0 bf ee       	push   $0xeebff000
  800e2b:	50                   	push   %eax
  800e2c:	e8 45 fd ff ff       	call   800b76 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800e31:	e8 02 fd ff ff       	call   800b38 <sys_getenvid>
  800e36:	83 c4 08             	add    $0x8,%esp
  800e39:	68 51 0e 80 00       	push   $0x800e51
  800e3e:	50                   	push   %eax
  800e3f:	e8 7d fe ff ff       	call   800cc1 <sys_env_set_pgfault_upcall>
  800e44:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    

00800e51 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e51:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e52:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e57:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e59:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800e5c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800e60:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800e64:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800e67:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800e6a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800e6b:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800e6e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800e6f:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800e70:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800e74:	c3                   	ret    

00800e75 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e80:	c1 e8 0c             	shr    $0xc,%eax
}
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e95:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ea7:	89 c2                	mov    %eax,%edx
  800ea9:	c1 ea 16             	shr    $0x16,%edx
  800eac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb3:	f6 c2 01             	test   $0x1,%dl
  800eb6:	74 11                	je     800ec9 <fd_alloc+0x2d>
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	c1 ea 0c             	shr    $0xc,%edx
  800ebd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec4:	f6 c2 01             	test   $0x1,%dl
  800ec7:	75 09                	jne    800ed2 <fd_alloc+0x36>
			*fd_store = fd;
  800ec9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed0:	eb 17                	jmp    800ee9 <fd_alloc+0x4d>
  800ed2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ed7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800edc:	75 c9                	jne    800ea7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ede:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ee4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ef1:	83 f8 1f             	cmp    $0x1f,%eax
  800ef4:	77 36                	ja     800f2c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ef6:	c1 e0 0c             	shl    $0xc,%eax
  800ef9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800efe:	89 c2                	mov    %eax,%edx
  800f00:	c1 ea 16             	shr    $0x16,%edx
  800f03:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0a:	f6 c2 01             	test   $0x1,%dl
  800f0d:	74 24                	je     800f33 <fd_lookup+0x48>
  800f0f:	89 c2                	mov    %eax,%edx
  800f11:	c1 ea 0c             	shr    $0xc,%edx
  800f14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1b:	f6 c2 01             	test   $0x1,%dl
  800f1e:	74 1a                	je     800f3a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f23:	89 02                	mov    %eax,(%edx)
	return 0;
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2a:	eb 13                	jmp    800f3f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f31:	eb 0c                	jmp    800f3f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f38:	eb 05                	jmp    800f3f <fd_lookup+0x54>
  800f3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4a:	ba cc 27 80 00       	mov    $0x8027cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f4f:	eb 13                	jmp    800f64 <dev_lookup+0x23>
  800f51:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f54:	39 08                	cmp    %ecx,(%eax)
  800f56:	75 0c                	jne    800f64 <dev_lookup+0x23>
			*dev = devtab[i];
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f62:	eb 2e                	jmp    800f92 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f64:	8b 02                	mov    (%edx),%eax
  800f66:	85 c0                	test   %eax,%eax
  800f68:	75 e7                	jne    800f51 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f6a:	a1 08 40 80 00       	mov    0x804008,%eax
  800f6f:	8b 40 48             	mov    0x48(%eax),%eax
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	51                   	push   %ecx
  800f76:	50                   	push   %eax
  800f77:	68 4c 27 80 00       	push   $0x80274c
  800f7c:	e8 6d f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 10             	sub    $0x10,%esp
  800f9c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa5:	50                   	push   %eax
  800fa6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fac:	c1 e8 0c             	shr    $0xc,%eax
  800faf:	50                   	push   %eax
  800fb0:	e8 36 ff ff ff       	call   800eeb <fd_lookup>
  800fb5:	83 c4 08             	add    $0x8,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 05                	js     800fc1 <fd_close+0x2d>
	    || fd != fd2)
  800fbc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fbf:	74 0c                	je     800fcd <fd_close+0x39>
		return (must_exist ? r : 0);
  800fc1:	84 db                	test   %bl,%bl
  800fc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc8:	0f 44 c2             	cmove  %edx,%eax
  800fcb:	eb 41                	jmp    80100e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fd3:	50                   	push   %eax
  800fd4:	ff 36                	pushl  (%esi)
  800fd6:	e8 66 ff ff ff       	call   800f41 <dev_lookup>
  800fdb:	89 c3                	mov    %eax,%ebx
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 1a                	js     800ffe <fd_close+0x6a>
		if (dev->dev_close)
  800fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fea:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	74 0b                	je     800ffe <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	56                   	push   %esi
  800ff7:	ff d0                	call   *%eax
  800ff9:	89 c3                	mov    %eax,%ebx
  800ffb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ffe:	83 ec 08             	sub    $0x8,%esp
  801001:	56                   	push   %esi
  801002:	6a 00                	push   $0x0
  801004:	e8 f2 fb ff ff       	call   800bfb <sys_page_unmap>
	return r;
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	89 d8                	mov    %ebx,%eax
}
  80100e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80101b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101e:	50                   	push   %eax
  80101f:	ff 75 08             	pushl  0x8(%ebp)
  801022:	e8 c4 fe ff ff       	call   800eeb <fd_lookup>
  801027:	83 c4 08             	add    $0x8,%esp
  80102a:	85 c0                	test   %eax,%eax
  80102c:	78 10                	js     80103e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	6a 01                	push   $0x1
  801033:	ff 75 f4             	pushl  -0xc(%ebp)
  801036:	e8 59 ff ff ff       	call   800f94 <fd_close>
  80103b:	83 c4 10             	add    $0x10,%esp
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <close_all>:

void
close_all(void)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	53                   	push   %ebx
  801044:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801047:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	53                   	push   %ebx
  801050:	e8 c0 ff ff ff       	call   801015 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801055:	83 c3 01             	add    $0x1,%ebx
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	83 fb 20             	cmp    $0x20,%ebx
  80105e:	75 ec                	jne    80104c <close_all+0xc>
		close(i);
}
  801060:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	57                   	push   %edi
  801069:	56                   	push   %esi
  80106a:	53                   	push   %ebx
  80106b:	83 ec 2c             	sub    $0x2c,%esp
  80106e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801071:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801074:	50                   	push   %eax
  801075:	ff 75 08             	pushl  0x8(%ebp)
  801078:	e8 6e fe ff ff       	call   800eeb <fd_lookup>
  80107d:	83 c4 08             	add    $0x8,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	0f 88 c1 00 00 00    	js     801149 <dup+0xe4>
		return r;
	close(newfdnum);
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	56                   	push   %esi
  80108c:	e8 84 ff ff ff       	call   801015 <close>

	newfd = INDEX2FD(newfdnum);
  801091:	89 f3                	mov    %esi,%ebx
  801093:	c1 e3 0c             	shl    $0xc,%ebx
  801096:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80109c:	83 c4 04             	add    $0x4,%esp
  80109f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a2:	e8 de fd ff ff       	call   800e85 <fd2data>
  8010a7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010a9:	89 1c 24             	mov    %ebx,(%esp)
  8010ac:	e8 d4 fd ff ff       	call   800e85 <fd2data>
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010b7:	89 f8                	mov    %edi,%eax
  8010b9:	c1 e8 16             	shr    $0x16,%eax
  8010bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c3:	a8 01                	test   $0x1,%al
  8010c5:	74 37                	je     8010fe <dup+0x99>
  8010c7:	89 f8                	mov    %edi,%eax
  8010c9:	c1 e8 0c             	shr    $0xc,%eax
  8010cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d3:	f6 c2 01             	test   $0x1,%dl
  8010d6:	74 26                	je     8010fe <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e7:	50                   	push   %eax
  8010e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010eb:	6a 00                	push   $0x0
  8010ed:	57                   	push   %edi
  8010ee:	6a 00                	push   $0x0
  8010f0:	e8 c4 fa ff ff       	call   800bb9 <sys_page_map>
  8010f5:	89 c7                	mov    %eax,%edi
  8010f7:	83 c4 20             	add    $0x20,%esp
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	78 2e                	js     80112c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801101:	89 d0                	mov    %edx,%eax
  801103:	c1 e8 0c             	shr    $0xc,%eax
  801106:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	25 07 0e 00 00       	and    $0xe07,%eax
  801115:	50                   	push   %eax
  801116:	53                   	push   %ebx
  801117:	6a 00                	push   $0x0
  801119:	52                   	push   %edx
  80111a:	6a 00                	push   $0x0
  80111c:	e8 98 fa ff ff       	call   800bb9 <sys_page_map>
  801121:	89 c7                	mov    %eax,%edi
  801123:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801126:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801128:	85 ff                	test   %edi,%edi
  80112a:	79 1d                	jns    801149 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	53                   	push   %ebx
  801130:	6a 00                	push   $0x0
  801132:	e8 c4 fa ff ff       	call   800bfb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801137:	83 c4 08             	add    $0x8,%esp
  80113a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80113d:	6a 00                	push   $0x0
  80113f:	e8 b7 fa ff ff       	call   800bfb <sys_page_unmap>
	return r;
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	89 f8                	mov    %edi,%eax
}
  801149:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	53                   	push   %ebx
  801155:	83 ec 14             	sub    $0x14,%esp
  801158:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80115b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80115e:	50                   	push   %eax
  80115f:	53                   	push   %ebx
  801160:	e8 86 fd ff ff       	call   800eeb <fd_lookup>
  801165:	83 c4 08             	add    $0x8,%esp
  801168:	89 c2                	mov    %eax,%edx
  80116a:	85 c0                	test   %eax,%eax
  80116c:	78 6d                	js     8011db <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116e:	83 ec 08             	sub    $0x8,%esp
  801171:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801174:	50                   	push   %eax
  801175:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801178:	ff 30                	pushl  (%eax)
  80117a:	e8 c2 fd ff ff       	call   800f41 <dev_lookup>
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	78 4c                	js     8011d2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801186:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801189:	8b 42 08             	mov    0x8(%edx),%eax
  80118c:	83 e0 03             	and    $0x3,%eax
  80118f:	83 f8 01             	cmp    $0x1,%eax
  801192:	75 21                	jne    8011b5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801194:	a1 08 40 80 00       	mov    0x804008,%eax
  801199:	8b 40 48             	mov    0x48(%eax),%eax
  80119c:	83 ec 04             	sub    $0x4,%esp
  80119f:	53                   	push   %ebx
  8011a0:	50                   	push   %eax
  8011a1:	68 90 27 80 00       	push   $0x802790
  8011a6:	e8 43 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011b3:	eb 26                	jmp    8011db <read+0x8a>
	}
	if (!dev->dev_read)
  8011b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b8:	8b 40 08             	mov    0x8(%eax),%eax
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	74 17                	je     8011d6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	ff 75 10             	pushl  0x10(%ebp)
  8011c5:	ff 75 0c             	pushl  0xc(%ebp)
  8011c8:	52                   	push   %edx
  8011c9:	ff d0                	call   *%eax
  8011cb:	89 c2                	mov    %eax,%edx
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	eb 09                	jmp    8011db <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	eb 05                	jmp    8011db <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011db:	89 d0                	mov    %edx,%eax
  8011dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 0c             	sub    $0xc,%esp
  8011eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f6:	eb 21                	jmp    801219 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	89 f0                	mov    %esi,%eax
  8011fd:	29 d8                	sub    %ebx,%eax
  8011ff:	50                   	push   %eax
  801200:	89 d8                	mov    %ebx,%eax
  801202:	03 45 0c             	add    0xc(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	57                   	push   %edi
  801207:	e8 45 ff ff ff       	call   801151 <read>
		if (m < 0)
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 10                	js     801223 <readn+0x41>
			return m;
		if (m == 0)
  801213:	85 c0                	test   %eax,%eax
  801215:	74 0a                	je     801221 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801217:	01 c3                	add    %eax,%ebx
  801219:	39 f3                	cmp    %esi,%ebx
  80121b:	72 db                	jb     8011f8 <readn+0x16>
  80121d:	89 d8                	mov    %ebx,%eax
  80121f:	eb 02                	jmp    801223 <readn+0x41>
  801221:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801226:	5b                   	pop    %ebx
  801227:	5e                   	pop    %esi
  801228:	5f                   	pop    %edi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	53                   	push   %ebx
  80122f:	83 ec 14             	sub    $0x14,%esp
  801232:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801235:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801238:	50                   	push   %eax
  801239:	53                   	push   %ebx
  80123a:	e8 ac fc ff ff       	call   800eeb <fd_lookup>
  80123f:	83 c4 08             	add    $0x8,%esp
  801242:	89 c2                	mov    %eax,%edx
  801244:	85 c0                	test   %eax,%eax
  801246:	78 68                	js     8012b0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801248:	83 ec 08             	sub    $0x8,%esp
  80124b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	ff 30                	pushl  (%eax)
  801254:	e8 e8 fc ff ff       	call   800f41 <dev_lookup>
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 47                	js     8012a7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801260:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801263:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801267:	75 21                	jne    80128a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801269:	a1 08 40 80 00       	mov    0x804008,%eax
  80126e:	8b 40 48             	mov    0x48(%eax),%eax
  801271:	83 ec 04             	sub    $0x4,%esp
  801274:	53                   	push   %ebx
  801275:	50                   	push   %eax
  801276:	68 ac 27 80 00       	push   $0x8027ac
  80127b:	e8 6e ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801288:	eb 26                	jmp    8012b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80128a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128d:	8b 52 0c             	mov    0xc(%edx),%edx
  801290:	85 d2                	test   %edx,%edx
  801292:	74 17                	je     8012ab <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801294:	83 ec 04             	sub    $0x4,%esp
  801297:	ff 75 10             	pushl  0x10(%ebp)
  80129a:	ff 75 0c             	pushl  0xc(%ebp)
  80129d:	50                   	push   %eax
  80129e:	ff d2                	call   *%edx
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	eb 09                	jmp    8012b0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	eb 05                	jmp    8012b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012b0:	89 d0                	mov    %edx,%eax
  8012b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	ff 75 08             	pushl  0x8(%ebp)
  8012c4:	e8 22 fc ff ff       	call   800eeb <fd_lookup>
  8012c9:	83 c4 08             	add    $0x8,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 0e                	js     8012de <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012de:	c9                   	leave  
  8012df:	c3                   	ret    

008012e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 14             	sub    $0x14,%esp
  8012e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	53                   	push   %ebx
  8012ef:	e8 f7 fb ff ff       	call   800eeb <fd_lookup>
  8012f4:	83 c4 08             	add    $0x8,%esp
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 65                	js     801362 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801303:	50                   	push   %eax
  801304:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801307:	ff 30                	pushl  (%eax)
  801309:	e8 33 fc ff ff       	call   800f41 <dev_lookup>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 44                	js     801359 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801318:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80131c:	75 21                	jne    80133f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80131e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801323:	8b 40 48             	mov    0x48(%eax),%eax
  801326:	83 ec 04             	sub    $0x4,%esp
  801329:	53                   	push   %ebx
  80132a:	50                   	push   %eax
  80132b:	68 6c 27 80 00       	push   $0x80276c
  801330:	e8 b9 ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80133d:	eb 23                	jmp    801362 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80133f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801342:	8b 52 18             	mov    0x18(%edx),%edx
  801345:	85 d2                	test   %edx,%edx
  801347:	74 14                	je     80135d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	ff 75 0c             	pushl  0xc(%ebp)
  80134f:	50                   	push   %eax
  801350:	ff d2                	call   *%edx
  801352:	89 c2                	mov    %eax,%edx
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	eb 09                	jmp    801362 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801359:	89 c2                	mov    %eax,%edx
  80135b:	eb 05                	jmp    801362 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80135d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801362:	89 d0                	mov    %edx,%eax
  801364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	53                   	push   %ebx
  80136d:	83 ec 14             	sub    $0x14,%esp
  801370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801373:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 6c fb ff ff       	call   800eeb <fd_lookup>
  80137f:	83 c4 08             	add    $0x8,%esp
  801382:	89 c2                	mov    %eax,%edx
  801384:	85 c0                	test   %eax,%eax
  801386:	78 58                	js     8013e0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801392:	ff 30                	pushl  (%eax)
  801394:	e8 a8 fb ff ff       	call   800f41 <dev_lookup>
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 37                	js     8013d7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013a7:	74 32                	je     8013db <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013b3:	00 00 00 
	stat->st_isdir = 0;
  8013b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013bd:	00 00 00 
	stat->st_dev = dev;
  8013c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8013cd:	ff 50 14             	call   *0x14(%eax)
  8013d0:	89 c2                	mov    %eax,%edx
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	eb 09                	jmp    8013e0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d7:	89 c2                	mov    %eax,%edx
  8013d9:	eb 05                	jmp    8013e0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013e0:	89 d0                	mov    %edx,%eax
  8013e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	56                   	push   %esi
  8013eb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	6a 00                	push   $0x0
  8013f1:	ff 75 08             	pushl  0x8(%ebp)
  8013f4:	e8 d6 01 00 00       	call   8015cf <open>
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 1b                	js     80141d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	ff 75 0c             	pushl  0xc(%ebp)
  801408:	50                   	push   %eax
  801409:	e8 5b ff ff ff       	call   801369 <fstat>
  80140e:	89 c6                	mov    %eax,%esi
	close(fd);
  801410:	89 1c 24             	mov    %ebx,(%esp)
  801413:	e8 fd fb ff ff       	call   801015 <close>
	return r;
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	89 f0                	mov    %esi,%eax
}
  80141d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	56                   	push   %esi
  801428:	53                   	push   %ebx
  801429:	89 c6                	mov    %eax,%esi
  80142b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80142d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801434:	75 12                	jne    801448 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	6a 01                	push   $0x1
  80143b:	e8 34 0c 00 00       	call   802074 <ipc_find_env>
  801440:	a3 00 40 80 00       	mov    %eax,0x804000
  801445:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801448:	6a 07                	push   $0x7
  80144a:	68 00 50 80 00       	push   $0x805000
  80144f:	56                   	push   %esi
  801450:	ff 35 00 40 80 00    	pushl  0x804000
  801456:	e8 c5 0b 00 00       	call   802020 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80145b:	83 c4 0c             	add    $0xc,%esp
  80145e:	6a 00                	push   $0x0
  801460:	53                   	push   %ebx
  801461:	6a 00                	push   $0x0
  801463:	e8 51 0b 00 00       	call   801fb9 <ipc_recv>
}
  801468:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    

0080146f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801475:	8b 45 08             	mov    0x8(%ebp),%eax
  801478:	8b 40 0c             	mov    0xc(%eax),%eax
  80147b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801480:	8b 45 0c             	mov    0xc(%ebp),%eax
  801483:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801488:	ba 00 00 00 00       	mov    $0x0,%edx
  80148d:	b8 02 00 00 00       	mov    $0x2,%eax
  801492:	e8 8d ff ff ff       	call   801424 <fsipc>
}
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80149f:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014af:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b4:	e8 6b ff ff ff       	call   801424 <fsipc>
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8014da:	e8 45 ff ff ff       	call   801424 <fsipc>
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 2c                	js     80150f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	68 00 50 80 00       	push   $0x805000
  8014eb:	53                   	push   %ebx
  8014ec:	e8 82 f2 ff ff       	call   800773 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014f1:	a1 80 50 80 00       	mov    0x805080,%eax
  8014f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014fc:	a1 84 50 80 00       	mov    0x805084,%eax
  801501:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151d:	8b 55 08             	mov    0x8(%ebp),%edx
  801520:	8b 52 0c             	mov    0xc(%edx),%edx
  801523:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801529:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80152e:	50                   	push   %eax
  80152f:	ff 75 0c             	pushl  0xc(%ebp)
  801532:	68 08 50 80 00       	push   $0x805008
  801537:	e8 c9 f3 ff ff       	call   800905 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80153c:	ba 00 00 00 00       	mov    $0x0,%edx
  801541:	b8 04 00 00 00       	mov    $0x4,%eax
  801546:	e8 d9 fe ff ff       	call   801424 <fsipc>

}
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	56                   	push   %esi
  801551:	53                   	push   %ebx
  801552:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801555:	8b 45 08             	mov    0x8(%ebp),%eax
  801558:	8b 40 0c             	mov    0xc(%eax),%eax
  80155b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801560:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801566:	ba 00 00 00 00       	mov    $0x0,%edx
  80156b:	b8 03 00 00 00       	mov    $0x3,%eax
  801570:	e8 af fe ff ff       	call   801424 <fsipc>
  801575:	89 c3                	mov    %eax,%ebx
  801577:	85 c0                	test   %eax,%eax
  801579:	78 4b                	js     8015c6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80157b:	39 c6                	cmp    %eax,%esi
  80157d:	73 16                	jae    801595 <devfile_read+0x48>
  80157f:	68 e0 27 80 00       	push   $0x8027e0
  801584:	68 e7 27 80 00       	push   $0x8027e7
  801589:	6a 7c                	push   $0x7c
  80158b:	68 fc 27 80 00       	push   $0x8027fc
  801590:	e8 80 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  801595:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80159a:	7e 16                	jle    8015b2 <devfile_read+0x65>
  80159c:	68 07 28 80 00       	push   $0x802807
  8015a1:	68 e7 27 80 00       	push   $0x8027e7
  8015a6:	6a 7d                	push   $0x7d
  8015a8:	68 fc 27 80 00       	push   $0x8027fc
  8015ad:	e8 63 eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b2:	83 ec 04             	sub    $0x4,%esp
  8015b5:	50                   	push   %eax
  8015b6:	68 00 50 80 00       	push   $0x805000
  8015bb:	ff 75 0c             	pushl  0xc(%ebp)
  8015be:	e8 42 f3 ff ff       	call   800905 <memmove>
	return r;
  8015c3:	83 c4 10             	add    $0x10,%esp
}
  8015c6:	89 d8                	mov    %ebx,%eax
  8015c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 20             	sub    $0x20,%esp
  8015d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d9:	53                   	push   %ebx
  8015da:	e8 5b f1 ff ff       	call   80073a <strlen>
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e7:	7f 67                	jg     801650 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	e8 a7 f8 ff ff       	call   800e9c <fd_alloc>
  8015f5:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 57                	js     801655 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015fe:	83 ec 08             	sub    $0x8,%esp
  801601:	53                   	push   %ebx
  801602:	68 00 50 80 00       	push   $0x805000
  801607:	e8 67 f1 ff ff       	call   800773 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801614:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801617:	b8 01 00 00 00       	mov    $0x1,%eax
  80161c:	e8 03 fe ff ff       	call   801424 <fsipc>
  801621:	89 c3                	mov    %eax,%ebx
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	79 14                	jns    80163e <open+0x6f>
		fd_close(fd, 0);
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	6a 00                	push   $0x0
  80162f:	ff 75 f4             	pushl  -0xc(%ebp)
  801632:	e8 5d f9 ff ff       	call   800f94 <fd_close>
		return r;
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	89 da                	mov    %ebx,%edx
  80163c:	eb 17                	jmp    801655 <open+0x86>
	}

	return fd2num(fd);
  80163e:	83 ec 0c             	sub    $0xc,%esp
  801641:	ff 75 f4             	pushl  -0xc(%ebp)
  801644:	e8 2c f8 ff ff       	call   800e75 <fd2num>
  801649:	89 c2                	mov    %eax,%edx
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	eb 05                	jmp    801655 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801650:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801655:	89 d0                	mov    %edx,%eax
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801662:	ba 00 00 00 00       	mov    $0x0,%edx
  801667:	b8 08 00 00 00       	mov    $0x8,%eax
  80166c:	e8 b3 fd ff ff       	call   801424 <fsipc>
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801679:	68 13 28 80 00       	push   $0x802813
  80167e:	ff 75 0c             	pushl  0xc(%ebp)
  801681:	e8 ed f0 ff ff       	call   800773 <strcpy>
	return 0;
}
  801686:	b8 00 00 00 00       	mov    $0x0,%eax
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	53                   	push   %ebx
  801691:	83 ec 10             	sub    $0x10,%esp
  801694:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801697:	53                   	push   %ebx
  801698:	e8 10 0a 00 00       	call   8020ad <pageref>
  80169d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8016a5:	83 f8 01             	cmp    $0x1,%eax
  8016a8:	75 10                	jne    8016ba <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8016aa:	83 ec 0c             	sub    $0xc,%esp
  8016ad:	ff 73 0c             	pushl  0xc(%ebx)
  8016b0:	e8 c0 02 00 00       	call   801975 <nsipc_close>
  8016b5:	89 c2                	mov    %eax,%edx
  8016b7:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016ba:	89 d0                	mov    %edx,%eax
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016c7:	6a 00                	push   $0x0
  8016c9:	ff 75 10             	pushl  0x10(%ebp)
  8016cc:	ff 75 0c             	pushl  0xc(%ebp)
  8016cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d2:	ff 70 0c             	pushl  0xc(%eax)
  8016d5:	e8 78 03 00 00       	call   801a52 <nsipc_send>
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016e2:	6a 00                	push   $0x0
  8016e4:	ff 75 10             	pushl  0x10(%ebp)
  8016e7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ed:	ff 70 0c             	pushl  0xc(%eax)
  8016f0:	e8 f1 02 00 00       	call   8019e6 <nsipc_recv>
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016fd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801700:	52                   	push   %edx
  801701:	50                   	push   %eax
  801702:	e8 e4 f7 ff ff       	call   800eeb <fd_lookup>
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 17                	js     801725 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80170e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801711:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801717:	39 08                	cmp    %ecx,(%eax)
  801719:	75 05                	jne    801720 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80171b:	8b 40 0c             	mov    0xc(%eax),%eax
  80171e:	eb 05                	jmp    801725 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801720:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	83 ec 1c             	sub    $0x1c,%esp
  80172f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	e8 62 f7 ff ff       	call   800e9c <fd_alloc>
  80173a:	89 c3                	mov    %eax,%ebx
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 1b                	js     80175e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801743:	83 ec 04             	sub    $0x4,%esp
  801746:	68 07 04 00 00       	push   $0x407
  80174b:	ff 75 f4             	pushl  -0xc(%ebp)
  80174e:	6a 00                	push   $0x0
  801750:	e8 21 f4 ff ff       	call   800b76 <sys_page_alloc>
  801755:	89 c3                	mov    %eax,%ebx
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	79 10                	jns    80176e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80175e:	83 ec 0c             	sub    $0xc,%esp
  801761:	56                   	push   %esi
  801762:	e8 0e 02 00 00       	call   801975 <nsipc_close>
		return r;
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	89 d8                	mov    %ebx,%eax
  80176c:	eb 24                	jmp    801792 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80176e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801777:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801783:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801786:	83 ec 0c             	sub    $0xc,%esp
  801789:	50                   	push   %eax
  80178a:	e8 e6 f6 ff ff       	call   800e75 <fd2num>
  80178f:	83 c4 10             	add    $0x10,%esp
}
  801792:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	e8 50 ff ff ff       	call   8016f7 <fd2sockid>
		return r;
  8017a7:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 1f                	js     8017cc <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017ad:	83 ec 04             	sub    $0x4,%esp
  8017b0:	ff 75 10             	pushl  0x10(%ebp)
  8017b3:	ff 75 0c             	pushl  0xc(%ebp)
  8017b6:	50                   	push   %eax
  8017b7:	e8 12 01 00 00       	call   8018ce <nsipc_accept>
  8017bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8017bf:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 07                	js     8017cc <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017c5:	e8 5d ff ff ff       	call   801727 <alloc_sockfd>
  8017ca:	89 c1                	mov    %eax,%ecx
}
  8017cc:	89 c8                	mov    %ecx,%eax
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d9:	e8 19 ff ff ff       	call   8016f7 <fd2sockid>
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 12                	js     8017f4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017e2:	83 ec 04             	sub    $0x4,%esp
  8017e5:	ff 75 10             	pushl  0x10(%ebp)
  8017e8:	ff 75 0c             	pushl  0xc(%ebp)
  8017eb:	50                   	push   %eax
  8017ec:	e8 2d 01 00 00       	call   80191e <nsipc_bind>
  8017f1:	83 c4 10             	add    $0x10,%esp
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <shutdown>:

int
shutdown(int s, int how)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	e8 f3 fe ff ff       	call   8016f7 <fd2sockid>
  801804:	85 c0                	test   %eax,%eax
  801806:	78 0f                	js     801817 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	ff 75 0c             	pushl  0xc(%ebp)
  80180e:	50                   	push   %eax
  80180f:	e8 3f 01 00 00       	call   801953 <nsipc_shutdown>
  801814:	83 c4 10             	add    $0x10,%esp
}
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	e8 d0 fe ff ff       	call   8016f7 <fd2sockid>
  801827:	85 c0                	test   %eax,%eax
  801829:	78 12                	js     80183d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	ff 75 10             	pushl  0x10(%ebp)
  801831:	ff 75 0c             	pushl  0xc(%ebp)
  801834:	50                   	push   %eax
  801835:	e8 55 01 00 00       	call   80198f <nsipc_connect>
  80183a:	83 c4 10             	add    $0x10,%esp
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <listen>:

int
listen(int s, int backlog)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	e8 aa fe ff ff       	call   8016f7 <fd2sockid>
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 0f                	js     801860 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801851:	83 ec 08             	sub    $0x8,%esp
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	50                   	push   %eax
  801858:	e8 67 01 00 00       	call   8019c4 <nsipc_listen>
  80185d:	83 c4 10             	add    $0x10,%esp
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801868:	ff 75 10             	pushl  0x10(%ebp)
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	ff 75 08             	pushl  0x8(%ebp)
  801871:	e8 3a 02 00 00       	call   801ab0 <nsipc_socket>
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 05                	js     801882 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80187d:	e8 a5 fe ff ff       	call   801727 <alloc_sockfd>
}
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	53                   	push   %ebx
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80188d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801894:	75 12                	jne    8018a8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	6a 02                	push   $0x2
  80189b:	e8 d4 07 00 00       	call   802074 <ipc_find_env>
  8018a0:	a3 04 40 80 00       	mov    %eax,0x804004
  8018a5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018a8:	6a 07                	push   $0x7
  8018aa:	68 00 60 80 00       	push   $0x806000
  8018af:	53                   	push   %ebx
  8018b0:	ff 35 04 40 80 00    	pushl  0x804004
  8018b6:	e8 65 07 00 00       	call   802020 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018bb:	83 c4 0c             	add    $0xc,%esp
  8018be:	6a 00                	push   $0x0
  8018c0:	6a 00                	push   $0x0
  8018c2:	6a 00                	push   $0x0
  8018c4:	e8 f0 06 00 00       	call   801fb9 <ipc_recv>
}
  8018c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	56                   	push   %esi
  8018d2:	53                   	push   %ebx
  8018d3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018de:	8b 06                	mov    (%esi),%eax
  8018e0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ea:	e8 95 ff ff ff       	call   801884 <nsipc>
  8018ef:	89 c3                	mov    %eax,%ebx
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 20                	js     801915 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018f5:	83 ec 04             	sub    $0x4,%esp
  8018f8:	ff 35 10 60 80 00    	pushl  0x806010
  8018fe:	68 00 60 80 00       	push   $0x806000
  801903:	ff 75 0c             	pushl  0xc(%ebp)
  801906:	e8 fa ef ff ff       	call   800905 <memmove>
		*addrlen = ret->ret_addrlen;
  80190b:	a1 10 60 80 00       	mov    0x806010,%eax
  801910:	89 06                	mov    %eax,(%esi)
  801912:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801915:	89 d8                	mov    %ebx,%eax
  801917:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801930:	53                   	push   %ebx
  801931:	ff 75 0c             	pushl  0xc(%ebp)
  801934:	68 04 60 80 00       	push   $0x806004
  801939:	e8 c7 ef ff ff       	call   800905 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80193e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801944:	b8 02 00 00 00       	mov    $0x2,%eax
  801949:	e8 36 ff ff ff       	call   801884 <nsipc>
}
  80194e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801961:	8b 45 0c             	mov    0xc(%ebp),%eax
  801964:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801969:	b8 03 00 00 00       	mov    $0x3,%eax
  80196e:	e8 11 ff ff ff       	call   801884 <nsipc>
}
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <nsipc_close>:

int
nsipc_close(int s)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80197b:	8b 45 08             	mov    0x8(%ebp),%eax
  80197e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801983:	b8 04 00 00 00       	mov    $0x4,%eax
  801988:	e8 f7 fe ff ff       	call   801884 <nsipc>
}
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	53                   	push   %ebx
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019a1:	53                   	push   %ebx
  8019a2:	ff 75 0c             	pushl  0xc(%ebp)
  8019a5:	68 04 60 80 00       	push   $0x806004
  8019aa:	e8 56 ef ff ff       	call   800905 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019af:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8019ba:	e8 c5 fe ff ff       	call   801884 <nsipc>
}
  8019bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019da:	b8 06 00 00 00       	mov    $0x6,%eax
  8019df:	e8 a0 fe ff ff       	call   801884 <nsipc>
}
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	56                   	push   %esi
  8019ea:	53                   	push   %ebx
  8019eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019f6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ff:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a04:	b8 07 00 00 00       	mov    $0x7,%eax
  801a09:	e8 76 fe ff ff       	call   801884 <nsipc>
  801a0e:	89 c3                	mov    %eax,%ebx
  801a10:	85 c0                	test   %eax,%eax
  801a12:	78 35                	js     801a49 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a14:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a19:	7f 04                	jg     801a1f <nsipc_recv+0x39>
  801a1b:	39 c6                	cmp    %eax,%esi
  801a1d:	7d 16                	jge    801a35 <nsipc_recv+0x4f>
  801a1f:	68 1f 28 80 00       	push   $0x80281f
  801a24:	68 e7 27 80 00       	push   $0x8027e7
  801a29:	6a 62                	push   $0x62
  801a2b:	68 34 28 80 00       	push   $0x802834
  801a30:	e8 e0 e6 ff ff       	call   800115 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a35:	83 ec 04             	sub    $0x4,%esp
  801a38:	50                   	push   %eax
  801a39:	68 00 60 80 00       	push   $0x806000
  801a3e:	ff 75 0c             	pushl  0xc(%ebp)
  801a41:	e8 bf ee ff ff       	call   800905 <memmove>
  801a46:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a49:	89 d8                	mov    %ebx,%eax
  801a4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5e                   	pop    %esi
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    

00801a52 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	53                   	push   %ebx
  801a56:	83 ec 04             	sub    $0x4,%esp
  801a59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a64:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a6a:	7e 16                	jle    801a82 <nsipc_send+0x30>
  801a6c:	68 40 28 80 00       	push   $0x802840
  801a71:	68 e7 27 80 00       	push   $0x8027e7
  801a76:	6a 6d                	push   $0x6d
  801a78:	68 34 28 80 00       	push   $0x802834
  801a7d:	e8 93 e6 ff ff       	call   800115 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a82:	83 ec 04             	sub    $0x4,%esp
  801a85:	53                   	push   %ebx
  801a86:	ff 75 0c             	pushl  0xc(%ebp)
  801a89:	68 0c 60 80 00       	push   $0x80600c
  801a8e:	e8 72 ee ff ff       	call   800905 <memmove>
	nsipcbuf.send.req_size = size;
  801a93:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a99:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801aa1:	b8 08 00 00 00       	mov    $0x8,%eax
  801aa6:	e8 d9 fd ff ff       	call   801884 <nsipc>
}
  801aab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    

00801ab0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ac6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ace:	b8 09 00 00 00       	mov    $0x9,%eax
  801ad3:	e8 ac fd ff ff       	call   801884 <nsipc>
}
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
  801adf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	ff 75 08             	pushl  0x8(%ebp)
  801ae8:	e8 98 f3 ff ff       	call   800e85 <fd2data>
  801aed:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aef:	83 c4 08             	add    $0x8,%esp
  801af2:	68 4c 28 80 00       	push   $0x80284c
  801af7:	53                   	push   %ebx
  801af8:	e8 76 ec ff ff       	call   800773 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801afd:	8b 46 04             	mov    0x4(%esi),%eax
  801b00:	2b 06                	sub    (%esi),%eax
  801b02:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b08:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b0f:	00 00 00 
	stat->st_dev = &devpipe;
  801b12:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b19:	30 80 00 
	return 0;
}
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5e                   	pop    %esi
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b32:	53                   	push   %ebx
  801b33:	6a 00                	push   $0x0
  801b35:	e8 c1 f0 ff ff       	call   800bfb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b3a:	89 1c 24             	mov    %ebx,(%esp)
  801b3d:	e8 43 f3 ff ff       	call   800e85 <fd2data>
  801b42:	83 c4 08             	add    $0x8,%esp
  801b45:	50                   	push   %eax
  801b46:	6a 00                	push   $0x0
  801b48:	e8 ae f0 ff ff       	call   800bfb <sys_page_unmap>
}
  801b4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	57                   	push   %edi
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	83 ec 1c             	sub    $0x1c,%esp
  801b5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b5e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b60:	a1 08 40 80 00       	mov    0x804008,%eax
  801b65:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	ff 75 e0             	pushl  -0x20(%ebp)
  801b6e:	e8 3a 05 00 00       	call   8020ad <pageref>
  801b73:	89 c3                	mov    %eax,%ebx
  801b75:	89 3c 24             	mov    %edi,(%esp)
  801b78:	e8 30 05 00 00       	call   8020ad <pageref>
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	39 c3                	cmp    %eax,%ebx
  801b82:	0f 94 c1             	sete   %cl
  801b85:	0f b6 c9             	movzbl %cl,%ecx
  801b88:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b8b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b91:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b94:	39 ce                	cmp    %ecx,%esi
  801b96:	74 1b                	je     801bb3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b98:	39 c3                	cmp    %eax,%ebx
  801b9a:	75 c4                	jne    801b60 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b9c:	8b 42 58             	mov    0x58(%edx),%eax
  801b9f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ba2:	50                   	push   %eax
  801ba3:	56                   	push   %esi
  801ba4:	68 53 28 80 00       	push   $0x802853
  801ba9:	e8 40 e6 ff ff       	call   8001ee <cprintf>
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	eb ad                	jmp    801b60 <_pipeisclosed+0xe>
	}
}
  801bb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 28             	sub    $0x28,%esp
  801bc7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bca:	56                   	push   %esi
  801bcb:	e8 b5 f2 ff ff       	call   800e85 <fd2data>
  801bd0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	bf 00 00 00 00       	mov    $0x0,%edi
  801bda:	eb 4b                	jmp    801c27 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bdc:	89 da                	mov    %ebx,%edx
  801bde:	89 f0                	mov    %esi,%eax
  801be0:	e8 6d ff ff ff       	call   801b52 <_pipeisclosed>
  801be5:	85 c0                	test   %eax,%eax
  801be7:	75 48                	jne    801c31 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801be9:	e8 69 ef ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bee:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf1:	8b 0b                	mov    (%ebx),%ecx
  801bf3:	8d 51 20             	lea    0x20(%ecx),%edx
  801bf6:	39 d0                	cmp    %edx,%eax
  801bf8:	73 e2                	jae    801bdc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c01:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c04:	89 c2                	mov    %eax,%edx
  801c06:	c1 fa 1f             	sar    $0x1f,%edx
  801c09:	89 d1                	mov    %edx,%ecx
  801c0b:	c1 e9 1b             	shr    $0x1b,%ecx
  801c0e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c11:	83 e2 1f             	and    $0x1f,%edx
  801c14:	29 ca                	sub    %ecx,%edx
  801c16:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c1a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c1e:	83 c0 01             	add    $0x1,%eax
  801c21:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c24:	83 c7 01             	add    $0x1,%edi
  801c27:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c2a:	75 c2                	jne    801bee <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2f:	eb 05                	jmp    801c36 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c31:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c39:	5b                   	pop    %ebx
  801c3a:	5e                   	pop    %esi
  801c3b:	5f                   	pop    %edi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 18             	sub    $0x18,%esp
  801c47:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c4a:	57                   	push   %edi
  801c4b:	e8 35 f2 ff ff       	call   800e85 <fd2data>
  801c50:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c5a:	eb 3d                	jmp    801c99 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c5c:	85 db                	test   %ebx,%ebx
  801c5e:	74 04                	je     801c64 <devpipe_read+0x26>
				return i;
  801c60:	89 d8                	mov    %ebx,%eax
  801c62:	eb 44                	jmp    801ca8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c64:	89 f2                	mov    %esi,%edx
  801c66:	89 f8                	mov    %edi,%eax
  801c68:	e8 e5 fe ff ff       	call   801b52 <_pipeisclosed>
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	75 32                	jne    801ca3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c71:	e8 e1 ee ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c76:	8b 06                	mov    (%esi),%eax
  801c78:	3b 46 04             	cmp    0x4(%esi),%eax
  801c7b:	74 df                	je     801c5c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c7d:	99                   	cltd   
  801c7e:	c1 ea 1b             	shr    $0x1b,%edx
  801c81:	01 d0                	add    %edx,%eax
  801c83:	83 e0 1f             	and    $0x1f,%eax
  801c86:	29 d0                	sub    %edx,%eax
  801c88:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c90:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c93:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c96:	83 c3 01             	add    $0x1,%ebx
  801c99:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c9c:	75 d8                	jne    801c76 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca1:	eb 05                	jmp    801ca8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5e                   	pop    %esi
  801cad:	5f                   	pop    %edi
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	56                   	push   %esi
  801cb4:	53                   	push   %ebx
  801cb5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	e8 db f1 ff ff       	call   800e9c <fd_alloc>
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	89 c2                	mov    %eax,%edx
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	0f 88 2c 01 00 00    	js     801dfa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cce:	83 ec 04             	sub    $0x4,%esp
  801cd1:	68 07 04 00 00       	push   $0x407
  801cd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 96 ee ff ff       	call   800b76 <sys_page_alloc>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	89 c2                	mov    %eax,%edx
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	0f 88 0d 01 00 00    	js     801dfa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ced:	83 ec 0c             	sub    $0xc,%esp
  801cf0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cf3:	50                   	push   %eax
  801cf4:	e8 a3 f1 ff ff       	call   800e9c <fd_alloc>
  801cf9:	89 c3                	mov    %eax,%ebx
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	0f 88 e2 00 00 00    	js     801de8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d06:	83 ec 04             	sub    $0x4,%esp
  801d09:	68 07 04 00 00       	push   $0x407
  801d0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d11:	6a 00                	push   $0x0
  801d13:	e8 5e ee ff ff       	call   800b76 <sys_page_alloc>
  801d18:	89 c3                	mov    %eax,%ebx
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	0f 88 c3 00 00 00    	js     801de8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d25:	83 ec 0c             	sub    $0xc,%esp
  801d28:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2b:	e8 55 f1 ff ff       	call   800e85 <fd2data>
  801d30:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d32:	83 c4 0c             	add    $0xc,%esp
  801d35:	68 07 04 00 00       	push   $0x407
  801d3a:	50                   	push   %eax
  801d3b:	6a 00                	push   $0x0
  801d3d:	e8 34 ee ff ff       	call   800b76 <sys_page_alloc>
  801d42:	89 c3                	mov    %eax,%ebx
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	85 c0                	test   %eax,%eax
  801d49:	0f 88 89 00 00 00    	js     801dd8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	ff 75 f0             	pushl  -0x10(%ebp)
  801d55:	e8 2b f1 ff ff       	call   800e85 <fd2data>
  801d5a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d61:	50                   	push   %eax
  801d62:	6a 00                	push   $0x0
  801d64:	56                   	push   %esi
  801d65:	6a 00                	push   $0x0
  801d67:	e8 4d ee ff ff       	call   800bb9 <sys_page_map>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	83 c4 20             	add    $0x20,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	78 55                	js     801dca <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d75:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d83:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d8a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d93:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d98:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d9f:	83 ec 0c             	sub    $0xc,%esp
  801da2:	ff 75 f4             	pushl  -0xc(%ebp)
  801da5:	e8 cb f0 ff ff       	call   800e75 <fd2num>
  801daa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dad:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801daf:	83 c4 04             	add    $0x4,%esp
  801db2:	ff 75 f0             	pushl  -0x10(%ebp)
  801db5:	e8 bb f0 ff ff       	call   800e75 <fd2num>
  801dba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dc0:	83 c4 10             	add    $0x10,%esp
  801dc3:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc8:	eb 30                	jmp    801dfa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dca:	83 ec 08             	sub    $0x8,%esp
  801dcd:	56                   	push   %esi
  801dce:	6a 00                	push   $0x0
  801dd0:	e8 26 ee ff ff       	call   800bfb <sys_page_unmap>
  801dd5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dd8:	83 ec 08             	sub    $0x8,%esp
  801ddb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dde:	6a 00                	push   $0x0
  801de0:	e8 16 ee ff ff       	call   800bfb <sys_page_unmap>
  801de5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dee:	6a 00                	push   $0x0
  801df0:	e8 06 ee ff ff       	call   800bfb <sys_page_unmap>
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    

00801e03 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0c:	50                   	push   %eax
  801e0d:	ff 75 08             	pushl  0x8(%ebp)
  801e10:	e8 d6 f0 ff ff       	call   800eeb <fd_lookup>
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	78 18                	js     801e34 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e1c:	83 ec 0c             	sub    $0xc,%esp
  801e1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e22:	e8 5e f0 ff ff       	call   800e85 <fd2data>
	return _pipeisclosed(fd, p);
  801e27:	89 c2                	mov    %eax,%edx
  801e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2c:	e8 21 fd ff ff       	call   801b52 <_pipeisclosed>
  801e31:	83 c4 10             	add    $0x10,%esp
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e39:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3e:	5d                   	pop    %ebp
  801e3f:	c3                   	ret    

00801e40 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e46:	68 6b 28 80 00       	push   $0x80286b
  801e4b:	ff 75 0c             	pushl  0xc(%ebp)
  801e4e:	e8 20 e9 ff ff       	call   800773 <strcpy>
	return 0;
}
  801e53:	b8 00 00 00 00       	mov    $0x0,%eax
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	57                   	push   %edi
  801e5e:	56                   	push   %esi
  801e5f:	53                   	push   %ebx
  801e60:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e66:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e6b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e71:	eb 2d                	jmp    801ea0 <devcons_write+0x46>
		m = n - tot;
  801e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e76:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e78:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e7b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e80:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e83:	83 ec 04             	sub    $0x4,%esp
  801e86:	53                   	push   %ebx
  801e87:	03 45 0c             	add    0xc(%ebp),%eax
  801e8a:	50                   	push   %eax
  801e8b:	57                   	push   %edi
  801e8c:	e8 74 ea ff ff       	call   800905 <memmove>
		sys_cputs(buf, m);
  801e91:	83 c4 08             	add    $0x8,%esp
  801e94:	53                   	push   %ebx
  801e95:	57                   	push   %edi
  801e96:	e8 1f ec ff ff       	call   800aba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9b:	01 de                	add    %ebx,%esi
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	89 f0                	mov    %esi,%eax
  801ea2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea5:	72 cc                	jb     801e73 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ea7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eaa:	5b                   	pop    %ebx
  801eab:	5e                   	pop    %esi
  801eac:	5f                   	pop    %edi
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	83 ec 08             	sub    $0x8,%esp
  801eb5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801eba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ebe:	74 2a                	je     801eea <devcons_read+0x3b>
  801ec0:	eb 05                	jmp    801ec7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ec2:	e8 90 ec ff ff       	call   800b57 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ec7:	e8 0c ec ff ff       	call   800ad8 <sys_cgetc>
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	74 f2                	je     801ec2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 16                	js     801eea <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ed4:	83 f8 04             	cmp    $0x4,%eax
  801ed7:	74 0c                	je     801ee5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ed9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801edc:	88 02                	mov    %al,(%edx)
	return 1;
  801ede:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee3:	eb 05                	jmp    801eea <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ef8:	6a 01                	push   $0x1
  801efa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801efd:	50                   	push   %eax
  801efe:	e8 b7 eb ff ff       	call   800aba <sys_cputs>
}
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <getchar>:

int
getchar(void)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f0e:	6a 01                	push   $0x1
  801f10:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f13:	50                   	push   %eax
  801f14:	6a 00                	push   $0x0
  801f16:	e8 36 f2 ff ff       	call   801151 <read>
	if (r < 0)
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 0f                	js     801f31 <getchar+0x29>
		return r;
	if (r < 1)
  801f22:	85 c0                	test   %eax,%eax
  801f24:	7e 06                	jle    801f2c <getchar+0x24>
		return -E_EOF;
	return c;
  801f26:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f2a:	eb 05                	jmp    801f31 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f2c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3c:	50                   	push   %eax
  801f3d:	ff 75 08             	pushl  0x8(%ebp)
  801f40:	e8 a6 ef ff ff       	call   800eeb <fd_lookup>
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	78 11                	js     801f5d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f55:	39 10                	cmp    %edx,(%eax)
  801f57:	0f 94 c0             	sete   %al
  801f5a:	0f b6 c0             	movzbl %al,%eax
}
  801f5d:	c9                   	leave  
  801f5e:	c3                   	ret    

00801f5f <opencons>:

int
opencons(void)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f68:	50                   	push   %eax
  801f69:	e8 2e ef ff ff       	call   800e9c <fd_alloc>
  801f6e:	83 c4 10             	add    $0x10,%esp
		return r;
  801f71:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 3e                	js     801fb5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f77:	83 ec 04             	sub    $0x4,%esp
  801f7a:	68 07 04 00 00       	push   $0x407
  801f7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f82:	6a 00                	push   $0x0
  801f84:	e8 ed eb ff ff       	call   800b76 <sys_page_alloc>
  801f89:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 23                	js     801fb5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f92:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa7:	83 ec 0c             	sub    $0xc,%esp
  801faa:	50                   	push   %eax
  801fab:	e8 c5 ee ff ff       	call   800e75 <fd2num>
  801fb0:	89 c2                	mov    %eax,%edx
  801fb2:	83 c4 10             	add    $0x10,%esp
}
  801fb5:	89 d0                	mov    %edx,%eax
  801fb7:	c9                   	leave  
  801fb8:	c3                   	ret    

00801fb9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	56                   	push   %esi
  801fbd:	53                   	push   %ebx
  801fbe:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801fc7:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801fc9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fce:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801fd1:	83 ec 0c             	sub    $0xc,%esp
  801fd4:	50                   	push   %eax
  801fd5:	e8 4c ed ff ff       	call   800d26 <sys_ipc_recv>

	if (from_env_store != NULL)
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	85 f6                	test   %esi,%esi
  801fdf:	74 14                	je     801ff5 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801fe1:	ba 00 00 00 00       	mov    $0x0,%edx
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	78 09                	js     801ff3 <ipc_recv+0x3a>
  801fea:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ff0:	8b 52 74             	mov    0x74(%edx),%edx
  801ff3:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ff5:	85 db                	test   %ebx,%ebx
  801ff7:	74 14                	je     80200d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ff9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffe:	85 c0                	test   %eax,%eax
  802000:	78 09                	js     80200b <ipc_recv+0x52>
  802002:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802008:	8b 52 78             	mov    0x78(%edx),%edx
  80200b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80200d:	85 c0                	test   %eax,%eax
  80200f:	78 08                	js     802019 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802011:	a1 08 40 80 00       	mov    0x804008,%eax
  802016:	8b 40 70             	mov    0x70(%eax),%eax
}
  802019:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80201c:	5b                   	pop    %ebx
  80201d:	5e                   	pop    %esi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    

00802020 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	53                   	push   %ebx
  802026:	83 ec 0c             	sub    $0xc,%esp
  802029:	8b 7d 08             	mov    0x8(%ebp),%edi
  80202c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80202f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802032:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802034:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802039:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80203c:	ff 75 14             	pushl  0x14(%ebp)
  80203f:	53                   	push   %ebx
  802040:	56                   	push   %esi
  802041:	57                   	push   %edi
  802042:	e8 bc ec ff ff       	call   800d03 <sys_ipc_try_send>

		if (err < 0) {
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	85 c0                	test   %eax,%eax
  80204c:	79 1e                	jns    80206c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80204e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802051:	75 07                	jne    80205a <ipc_send+0x3a>
				sys_yield();
  802053:	e8 ff ea ff ff       	call   800b57 <sys_yield>
  802058:	eb e2                	jmp    80203c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80205a:	50                   	push   %eax
  80205b:	68 77 28 80 00       	push   $0x802877
  802060:	6a 49                	push   $0x49
  802062:	68 84 28 80 00       	push   $0x802884
  802067:	e8 a9 e0 ff ff       	call   800115 <_panic>
		}

	} while (err < 0);

}
  80206c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80207a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80207f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802082:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802088:	8b 52 50             	mov    0x50(%edx),%edx
  80208b:	39 ca                	cmp    %ecx,%edx
  80208d:	75 0d                	jne    80209c <ipc_find_env+0x28>
			return envs[i].env_id;
  80208f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802092:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802097:	8b 40 48             	mov    0x48(%eax),%eax
  80209a:	eb 0f                	jmp    8020ab <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80209c:	83 c0 01             	add    $0x1,%eax
  80209f:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020a4:	75 d9                	jne    80207f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020ab:	5d                   	pop    %ebp
  8020ac:	c3                   	ret    

008020ad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b3:	89 d0                	mov    %edx,%eax
  8020b5:	c1 e8 16             	shr    $0x16,%eax
  8020b8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020bf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c4:	f6 c1 01             	test   $0x1,%cl
  8020c7:	74 1d                	je     8020e6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020c9:	c1 ea 0c             	shr    $0xc,%edx
  8020cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020d3:	f6 c2 01             	test   $0x1,%dl
  8020d6:	74 0e                	je     8020e6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d8:	c1 ea 0c             	shr    $0xc,%edx
  8020db:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020e2:	ef 
  8020e3:	0f b7 c0             	movzwl %ax,%eax
}
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 f6                	test   %esi,%esi
  802109:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80210d:	89 ca                	mov    %ecx,%edx
  80210f:	89 f8                	mov    %edi,%eax
  802111:	75 3d                	jne    802150 <__udivdi3+0x60>
  802113:	39 cf                	cmp    %ecx,%edi
  802115:	0f 87 c5 00 00 00    	ja     8021e0 <__udivdi3+0xf0>
  80211b:	85 ff                	test   %edi,%edi
  80211d:	89 fd                	mov    %edi,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f7                	div    %edi
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 c8                	mov    %ecx,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c1                	mov    %eax,%ecx
  802134:	89 d8                	mov    %ebx,%eax
  802136:	89 cf                	mov    %ecx,%edi
  802138:	f7 f5                	div    %ebp
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	39 ce                	cmp    %ecx,%esi
  802152:	77 74                	ja     8021c8 <__udivdi3+0xd8>
  802154:	0f bd fe             	bsr    %esi,%edi
  802157:	83 f7 1f             	xor    $0x1f,%edi
  80215a:	0f 84 98 00 00 00    	je     8021f8 <__udivdi3+0x108>
  802160:	bb 20 00 00 00       	mov    $0x20,%ebx
  802165:	89 f9                	mov    %edi,%ecx
  802167:	89 c5                	mov    %eax,%ebp
  802169:	29 fb                	sub    %edi,%ebx
  80216b:	d3 e6                	shl    %cl,%esi
  80216d:	89 d9                	mov    %ebx,%ecx
  80216f:	d3 ed                	shr    %cl,%ebp
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e0                	shl    %cl,%eax
  802175:	09 ee                	or     %ebp,%esi
  802177:	89 d9                	mov    %ebx,%ecx
  802179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217d:	89 d5                	mov    %edx,%ebp
  80217f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802183:	d3 ed                	shr    %cl,%ebp
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e2                	shl    %cl,%edx
  802189:	89 d9                	mov    %ebx,%ecx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	09 c2                	or     %eax,%edx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	89 ea                	mov    %ebp,%edx
  802193:	f7 f6                	div    %esi
  802195:	89 d5                	mov    %edx,%ebp
  802197:	89 c3                	mov    %eax,%ebx
  802199:	f7 64 24 0c          	mull   0xc(%esp)
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	72 10                	jb     8021b1 <__udivdi3+0xc1>
  8021a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e6                	shl    %cl,%esi
  8021a9:	39 c6                	cmp    %eax,%esi
  8021ab:	73 07                	jae    8021b4 <__udivdi3+0xc4>
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	75 03                	jne    8021b4 <__udivdi3+0xc4>
  8021b1:	83 eb 01             	sub    $0x1,%ebx
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 d8                	mov    %ebx,%eax
  8021b8:	89 fa                	mov    %edi,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	31 ff                	xor    %edi,%edi
  8021ca:	31 db                	xor    %ebx,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	f7 f7                	div    %edi
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 c3                	mov    %eax,%ebx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 fa                	mov    %edi,%edx
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	39 ce                	cmp    %ecx,%esi
  8021fa:	72 0c                	jb     802208 <__udivdi3+0x118>
  8021fc:	31 db                	xor    %ebx,%ebx
  8021fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802202:	0f 87 34 ff ff ff    	ja     80213c <__udivdi3+0x4c>
  802208:	bb 01 00 00 00       	mov    $0x1,%ebx
  80220d:	e9 2a ff ff ff       	jmp    80213c <__udivdi3+0x4c>
  802212:	66 90                	xchg   %ax,%ax
  802214:	66 90                	xchg   %ax,%ax
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80222b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 d2                	test   %edx,%edx
  802239:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80223d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802241:	89 f3                	mov    %esi,%ebx
  802243:	89 3c 24             	mov    %edi,(%esp)
  802246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224a:	75 1c                	jne    802268 <__umoddi3+0x48>
  80224c:	39 f7                	cmp    %esi,%edi
  80224e:	76 50                	jbe    8022a0 <__umoddi3+0x80>
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	f7 f7                	div    %edi
  802256:	89 d0                	mov    %edx,%eax
  802258:	31 d2                	xor    %edx,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	39 f2                	cmp    %esi,%edx
  80226a:	89 d0                	mov    %edx,%eax
  80226c:	77 52                	ja     8022c0 <__umoddi3+0xa0>
  80226e:	0f bd ea             	bsr    %edx,%ebp
  802271:	83 f5 1f             	xor    $0x1f,%ebp
  802274:	75 5a                	jne    8022d0 <__umoddi3+0xb0>
  802276:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80227a:	0f 82 e0 00 00 00    	jb     802360 <__umoddi3+0x140>
  802280:	39 0c 24             	cmp    %ecx,(%esp)
  802283:	0f 86 d7 00 00 00    	jbe    802360 <__umoddi3+0x140>
  802289:	8b 44 24 08          	mov    0x8(%esp),%eax
  80228d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802291:	83 c4 1c             	add    $0x1c,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	85 ff                	test   %edi,%edi
  8022a2:	89 fd                	mov    %edi,%ebp
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x91>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f7                	div    %edi
  8022af:	89 c5                	mov    %eax,%ebp
  8022b1:	89 f0                	mov    %esi,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f5                	div    %ebp
  8022b7:	89 c8                	mov    %ecx,%eax
  8022b9:	f7 f5                	div    %ebp
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	eb 99                	jmp    802258 <__umoddi3+0x38>
  8022bf:	90                   	nop
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	83 c4 1c             	add    $0x1c,%esp
  8022c7:	5b                   	pop    %ebx
  8022c8:	5e                   	pop    %esi
  8022c9:	5f                   	pop    %edi
  8022ca:	5d                   	pop    %ebp
  8022cb:	c3                   	ret    
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	8b 34 24             	mov    (%esp),%esi
  8022d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022d8:	89 e9                	mov    %ebp,%ecx
  8022da:	29 ef                	sub    %ebp,%edi
  8022dc:	d3 e0                	shl    %cl,%eax
  8022de:	89 f9                	mov    %edi,%ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	d3 ea                	shr    %cl,%edx
  8022e4:	89 e9                	mov    %ebp,%ecx
  8022e6:	09 c2                	or     %eax,%edx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 14 24             	mov    %edx,(%esp)
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	d3 e2                	shl    %cl,%edx
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	89 c6                	mov    %eax,%esi
  802301:	d3 e3                	shl    %cl,%ebx
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 d0                	mov    %edx,%eax
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	09 d8                	or     %ebx,%eax
  80230d:	89 d3                	mov    %edx,%ebx
  80230f:	89 f2                	mov    %esi,%edx
  802311:	f7 34 24             	divl   (%esp)
  802314:	89 d6                	mov    %edx,%esi
  802316:	d3 e3                	shl    %cl,%ebx
  802318:	f7 64 24 04          	mull   0x4(%esp)
  80231c:	39 d6                	cmp    %edx,%esi
  80231e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802322:	89 d1                	mov    %edx,%ecx
  802324:	89 c3                	mov    %eax,%ebx
  802326:	72 08                	jb     802330 <__umoddi3+0x110>
  802328:	75 11                	jne    80233b <__umoddi3+0x11b>
  80232a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80232e:	73 0b                	jae    80233b <__umoddi3+0x11b>
  802330:	2b 44 24 04          	sub    0x4(%esp),%eax
  802334:	1b 14 24             	sbb    (%esp),%edx
  802337:	89 d1                	mov    %edx,%ecx
  802339:	89 c3                	mov    %eax,%ebx
  80233b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80233f:	29 da                	sub    %ebx,%edx
  802341:	19 ce                	sbb    %ecx,%esi
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 f0                	mov    %esi,%eax
  802347:	d3 e0                	shl    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	d3 ea                	shr    %cl,%edx
  80234d:	89 e9                	mov    %ebp,%ecx
  80234f:	d3 ee                	shr    %cl,%esi
  802351:	09 d0                	or     %edx,%eax
  802353:	89 f2                	mov    %esi,%edx
  802355:	83 c4 1c             	add    $0x1c,%esp
  802358:	5b                   	pop    %ebx
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	29 f9                	sub    %edi,%ecx
  802362:	19 d6                	sbb    %edx,%esi
  802364:	89 74 24 04          	mov    %esi,0x4(%esp)
  802368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80236c:	e9 18 ff ff ff       	jmp    802289 <__umoddi3+0x69>
