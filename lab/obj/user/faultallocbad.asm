
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
  800040:	68 80 1e 80 00       	push   $0x801e80
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
  80006a:	68 a0 1e 80 00       	push   $0x801ea0
  80006f:	6a 0f                	push   $0xf
  800071:	68 8a 1e 80 00       	push   $0x801e8a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 1e 80 00       	push   $0x801ecc
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
  80009c:	e8 c6 0c 00 00       	call   800d67 <set_pgfault_handler>
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
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800101:	e8 97 0e 00 00       	call   800f9d <close_all>
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
  800133:	68 f8 1e 80 00       	push   $0x801ef8
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
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
  800251:	e8 8a 19 00 00       	call   801be0 <__udivdi3>
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
  800294:	e8 77 1a 00 00       	call   801d10 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 1b 1f 80 00 	movsbl 0x801f1b(%eax),%eax
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
  800398:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
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
  80045c:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 18                	jne    80047f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800467:	50                   	push   %eax
  800468:	68 33 1f 80 00       	push   $0x801f33
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
  800480:	68 f5 22 80 00       	push   $0x8022f5
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
  8004a4:	b8 2c 1f 80 00       	mov    $0x801f2c,%eax
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
  800b1f:	68 1f 22 80 00       	push   $0x80221f
  800b24:	6a 23                	push   $0x23
  800b26:	68 3c 22 80 00       	push   $0x80223c
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
  800ba0:	68 1f 22 80 00       	push   $0x80221f
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 3c 22 80 00       	push   $0x80223c
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
  800be2:	68 1f 22 80 00       	push   $0x80221f
  800be7:	6a 23                	push   $0x23
  800be9:	68 3c 22 80 00       	push   $0x80223c
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
  800c24:	68 1f 22 80 00       	push   $0x80221f
  800c29:	6a 23                	push   $0x23
  800c2b:	68 3c 22 80 00       	push   $0x80223c
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
  800c66:	68 1f 22 80 00       	push   $0x80221f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 3c 22 80 00       	push   $0x80223c
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
  800ca8:	68 1f 22 80 00       	push   $0x80221f
  800cad:	6a 23                	push   $0x23
  800caf:	68 3c 22 80 00       	push   $0x80223c
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
  800cea:	68 1f 22 80 00       	push   $0x80221f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 3c 22 80 00       	push   $0x80223c
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
  800d4e:	68 1f 22 80 00       	push   $0x80221f
  800d53:	6a 23                	push   $0x23
  800d55:	68 3c 22 80 00       	push   $0x80223c
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

00800d67 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d6d:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d74:	75 2e                	jne    800da4 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800d76:	e8 bd fd ff ff       	call   800b38 <sys_getenvid>
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	68 07 0e 00 00       	push   $0xe07
  800d83:	68 00 f0 bf ee       	push   $0xeebff000
  800d88:	50                   	push   %eax
  800d89:	e8 e8 fd ff ff       	call   800b76 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800d8e:	e8 a5 fd ff ff       	call   800b38 <sys_getenvid>
  800d93:	83 c4 08             	add    $0x8,%esp
  800d96:	68 ae 0d 80 00       	push   $0x800dae
  800d9b:	50                   	push   %eax
  800d9c:	e8 20 ff ff ff       	call   800cc1 <sys_env_set_pgfault_upcall>
  800da1:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
  800da7:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dae:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800daf:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800db4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800db6:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800db9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800dbd:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800dc1:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800dc4:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800dc7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800dc8:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800dcb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800dcc:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800dcd:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800dd1:	c3                   	ret    

00800dd2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	05 00 00 00 30       	add    $0x30000000,%eax
  800ddd:	c1 e8 0c             	shr    $0xc,%eax
}
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	05 00 00 00 30       	add    $0x30000000,%eax
  800ded:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dff:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e04:	89 c2                	mov    %eax,%edx
  800e06:	c1 ea 16             	shr    $0x16,%edx
  800e09:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e10:	f6 c2 01             	test   $0x1,%dl
  800e13:	74 11                	je     800e26 <fd_alloc+0x2d>
  800e15:	89 c2                	mov    %eax,%edx
  800e17:	c1 ea 0c             	shr    $0xc,%edx
  800e1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e21:	f6 c2 01             	test   $0x1,%dl
  800e24:	75 09                	jne    800e2f <fd_alloc+0x36>
			*fd_store = fd;
  800e26:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e28:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2d:	eb 17                	jmp    800e46 <fd_alloc+0x4d>
  800e2f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e34:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e39:	75 c9                	jne    800e04 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e3b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e41:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e4e:	83 f8 1f             	cmp    $0x1f,%eax
  800e51:	77 36                	ja     800e89 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e53:	c1 e0 0c             	shl    $0xc,%eax
  800e56:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e5b:	89 c2                	mov    %eax,%edx
  800e5d:	c1 ea 16             	shr    $0x16,%edx
  800e60:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e67:	f6 c2 01             	test   $0x1,%dl
  800e6a:	74 24                	je     800e90 <fd_lookup+0x48>
  800e6c:	89 c2                	mov    %eax,%edx
  800e6e:	c1 ea 0c             	shr    $0xc,%edx
  800e71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e78:	f6 c2 01             	test   $0x1,%dl
  800e7b:	74 1a                	je     800e97 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e80:	89 02                	mov    %eax,(%edx)
	return 0;
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
  800e87:	eb 13                	jmp    800e9c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8e:	eb 0c                	jmp    800e9c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e95:	eb 05                	jmp    800e9c <fd_lookup+0x54>
  800e97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	83 ec 08             	sub    $0x8,%esp
  800ea4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea7:	ba cc 22 80 00       	mov    $0x8022cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eac:	eb 13                	jmp    800ec1 <dev_lookup+0x23>
  800eae:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eb1:	39 08                	cmp    %ecx,(%eax)
  800eb3:	75 0c                	jne    800ec1 <dev_lookup+0x23>
			*dev = devtab[i];
  800eb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	eb 2e                	jmp    800eef <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec1:	8b 02                	mov    (%edx),%eax
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	75 e7                	jne    800eae <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec7:	a1 04 40 80 00       	mov    0x804004,%eax
  800ecc:	8b 40 48             	mov    0x48(%eax),%eax
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	51                   	push   %ecx
  800ed3:	50                   	push   %eax
  800ed4:	68 4c 22 80 00       	push   $0x80224c
  800ed9:	e8 10 f3 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ee7:	83 c4 10             	add    $0x10,%esp
  800eea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eef:	c9                   	leave  
  800ef0:	c3                   	ret    

00800ef1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 10             	sub    $0x10,%esp
  800ef9:	8b 75 08             	mov    0x8(%ebp),%esi
  800efc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f02:	50                   	push   %eax
  800f03:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f09:	c1 e8 0c             	shr    $0xc,%eax
  800f0c:	50                   	push   %eax
  800f0d:	e8 36 ff ff ff       	call   800e48 <fd_lookup>
  800f12:	83 c4 08             	add    $0x8,%esp
  800f15:	85 c0                	test   %eax,%eax
  800f17:	78 05                	js     800f1e <fd_close+0x2d>
	    || fd != fd2)
  800f19:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f1c:	74 0c                	je     800f2a <fd_close+0x39>
		return (must_exist ? r : 0);
  800f1e:	84 db                	test   %bl,%bl
  800f20:	ba 00 00 00 00       	mov    $0x0,%edx
  800f25:	0f 44 c2             	cmove  %edx,%eax
  800f28:	eb 41                	jmp    800f6b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f30:	50                   	push   %eax
  800f31:	ff 36                	pushl  (%esi)
  800f33:	e8 66 ff ff ff       	call   800e9e <dev_lookup>
  800f38:	89 c3                	mov    %eax,%ebx
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 1a                	js     800f5b <fd_close+0x6a>
		if (dev->dev_close)
  800f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f44:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f47:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	74 0b                	je     800f5b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f50:	83 ec 0c             	sub    $0xc,%esp
  800f53:	56                   	push   %esi
  800f54:	ff d0                	call   *%eax
  800f56:	89 c3                	mov    %eax,%ebx
  800f58:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	56                   	push   %esi
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 95 fc ff ff       	call   800bfb <sys_page_unmap>
	return r;
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	89 d8                	mov    %ebx,%eax
}
  800f6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7b:	50                   	push   %eax
  800f7c:	ff 75 08             	pushl  0x8(%ebp)
  800f7f:	e8 c4 fe ff ff       	call   800e48 <fd_lookup>
  800f84:	83 c4 08             	add    $0x8,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	78 10                	js     800f9b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f8b:	83 ec 08             	sub    $0x8,%esp
  800f8e:	6a 01                	push   $0x1
  800f90:	ff 75 f4             	pushl  -0xc(%ebp)
  800f93:	e8 59 ff ff ff       	call   800ef1 <fd_close>
  800f98:	83 c4 10             	add    $0x10,%esp
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <close_all>:

void
close_all(void)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	53                   	push   %ebx
  800fad:	e8 c0 ff ff ff       	call   800f72 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb2:	83 c3 01             	add    $0x1,%ebx
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	83 fb 20             	cmp    $0x20,%ebx
  800fbb:	75 ec                	jne    800fa9 <close_all+0xc>
		close(i);
}
  800fbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    

00800fc2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 2c             	sub    $0x2c,%esp
  800fcb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd1:	50                   	push   %eax
  800fd2:	ff 75 08             	pushl  0x8(%ebp)
  800fd5:	e8 6e fe ff ff       	call   800e48 <fd_lookup>
  800fda:	83 c4 08             	add    $0x8,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	0f 88 c1 00 00 00    	js     8010a6 <dup+0xe4>
		return r;
	close(newfdnum);
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	56                   	push   %esi
  800fe9:	e8 84 ff ff ff       	call   800f72 <close>

	newfd = INDEX2FD(newfdnum);
  800fee:	89 f3                	mov    %esi,%ebx
  800ff0:	c1 e3 0c             	shl    $0xc,%ebx
  800ff3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ff9:	83 c4 04             	add    $0x4,%esp
  800ffc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fff:	e8 de fd ff ff       	call   800de2 <fd2data>
  801004:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801006:	89 1c 24             	mov    %ebx,(%esp)
  801009:	e8 d4 fd ff ff       	call   800de2 <fd2data>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801014:	89 f8                	mov    %edi,%eax
  801016:	c1 e8 16             	shr    $0x16,%eax
  801019:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801020:	a8 01                	test   $0x1,%al
  801022:	74 37                	je     80105b <dup+0x99>
  801024:	89 f8                	mov    %edi,%eax
  801026:	c1 e8 0c             	shr    $0xc,%eax
  801029:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801030:	f6 c2 01             	test   $0x1,%dl
  801033:	74 26                	je     80105b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801035:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	25 07 0e 00 00       	and    $0xe07,%eax
  801044:	50                   	push   %eax
  801045:	ff 75 d4             	pushl  -0x2c(%ebp)
  801048:	6a 00                	push   $0x0
  80104a:	57                   	push   %edi
  80104b:	6a 00                	push   $0x0
  80104d:	e8 67 fb ff ff       	call   800bb9 <sys_page_map>
  801052:	89 c7                	mov    %eax,%edi
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	78 2e                	js     801089 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80105e:	89 d0                	mov    %edx,%eax
  801060:	c1 e8 0c             	shr    $0xc,%eax
  801063:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	25 07 0e 00 00       	and    $0xe07,%eax
  801072:	50                   	push   %eax
  801073:	53                   	push   %ebx
  801074:	6a 00                	push   $0x0
  801076:	52                   	push   %edx
  801077:	6a 00                	push   $0x0
  801079:	e8 3b fb ff ff       	call   800bb9 <sys_page_map>
  80107e:	89 c7                	mov    %eax,%edi
  801080:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801083:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801085:	85 ff                	test   %edi,%edi
  801087:	79 1d                	jns    8010a6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801089:	83 ec 08             	sub    $0x8,%esp
  80108c:	53                   	push   %ebx
  80108d:	6a 00                	push   $0x0
  80108f:	e8 67 fb ff ff       	call   800bfb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801094:	83 c4 08             	add    $0x8,%esp
  801097:	ff 75 d4             	pushl  -0x2c(%ebp)
  80109a:	6a 00                	push   $0x0
  80109c:	e8 5a fb ff ff       	call   800bfb <sys_page_unmap>
	return r;
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	89 f8                	mov    %edi,%eax
}
  8010a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a9:	5b                   	pop    %ebx
  8010aa:	5e                   	pop    %esi
  8010ab:	5f                   	pop    %edi
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	53                   	push   %ebx
  8010b2:	83 ec 14             	sub    $0x14,%esp
  8010b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010bb:	50                   	push   %eax
  8010bc:	53                   	push   %ebx
  8010bd:	e8 86 fd ff ff       	call   800e48 <fd_lookup>
  8010c2:	83 c4 08             	add    $0x8,%esp
  8010c5:	89 c2                	mov    %eax,%edx
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 6d                	js     801138 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010cb:	83 ec 08             	sub    $0x8,%esp
  8010ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d1:	50                   	push   %eax
  8010d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d5:	ff 30                	pushl  (%eax)
  8010d7:	e8 c2 fd ff ff       	call   800e9e <dev_lookup>
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 4c                	js     80112f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010e6:	8b 42 08             	mov    0x8(%edx),%eax
  8010e9:	83 e0 03             	and    $0x3,%eax
  8010ec:	83 f8 01             	cmp    $0x1,%eax
  8010ef:	75 21                	jne    801112 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f6:	8b 40 48             	mov    0x48(%eax),%eax
  8010f9:	83 ec 04             	sub    $0x4,%esp
  8010fc:	53                   	push   %ebx
  8010fd:	50                   	push   %eax
  8010fe:	68 90 22 80 00       	push   $0x802290
  801103:	e8 e6 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801110:	eb 26                	jmp    801138 <read+0x8a>
	}
	if (!dev->dev_read)
  801112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801115:	8b 40 08             	mov    0x8(%eax),%eax
  801118:	85 c0                	test   %eax,%eax
  80111a:	74 17                	je     801133 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80111c:	83 ec 04             	sub    $0x4,%esp
  80111f:	ff 75 10             	pushl  0x10(%ebp)
  801122:	ff 75 0c             	pushl  0xc(%ebp)
  801125:	52                   	push   %edx
  801126:	ff d0                	call   *%eax
  801128:	89 c2                	mov    %eax,%edx
  80112a:	83 c4 10             	add    $0x10,%esp
  80112d:	eb 09                	jmp    801138 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112f:	89 c2                	mov    %eax,%edx
  801131:	eb 05                	jmp    801138 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801133:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801138:	89 d0                	mov    %edx,%eax
  80113a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	57                   	push   %edi
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	8b 7d 08             	mov    0x8(%ebp),%edi
  80114b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801153:	eb 21                	jmp    801176 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801155:	83 ec 04             	sub    $0x4,%esp
  801158:	89 f0                	mov    %esi,%eax
  80115a:	29 d8                	sub    %ebx,%eax
  80115c:	50                   	push   %eax
  80115d:	89 d8                	mov    %ebx,%eax
  80115f:	03 45 0c             	add    0xc(%ebp),%eax
  801162:	50                   	push   %eax
  801163:	57                   	push   %edi
  801164:	e8 45 ff ff ff       	call   8010ae <read>
		if (m < 0)
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	78 10                	js     801180 <readn+0x41>
			return m;
		if (m == 0)
  801170:	85 c0                	test   %eax,%eax
  801172:	74 0a                	je     80117e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801174:	01 c3                	add    %eax,%ebx
  801176:	39 f3                	cmp    %esi,%ebx
  801178:	72 db                	jb     801155 <readn+0x16>
  80117a:	89 d8                	mov    %ebx,%eax
  80117c:	eb 02                	jmp    801180 <readn+0x41>
  80117e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	53                   	push   %ebx
  80118c:	83 ec 14             	sub    $0x14,%esp
  80118f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801192:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	53                   	push   %ebx
  801197:	e8 ac fc ff ff       	call   800e48 <fd_lookup>
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 68                	js     80120d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011af:	ff 30                	pushl  (%eax)
  8011b1:	e8 e8 fc ff ff       	call   800e9e <dev_lookup>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 47                	js     801204 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011c4:	75 21                	jne    8011e7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cb:	8b 40 48             	mov    0x48(%eax),%eax
  8011ce:	83 ec 04             	sub    $0x4,%esp
  8011d1:	53                   	push   %ebx
  8011d2:	50                   	push   %eax
  8011d3:	68 ac 22 80 00       	push   $0x8022ac
  8011d8:	e8 11 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e5:	eb 26                	jmp    80120d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8011ed:	85 d2                	test   %edx,%edx
  8011ef:	74 17                	je     801208 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	ff 75 10             	pushl  0x10(%ebp)
  8011f7:	ff 75 0c             	pushl  0xc(%ebp)
  8011fa:	50                   	push   %eax
  8011fb:	ff d2                	call   *%edx
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	eb 09                	jmp    80120d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801204:	89 c2                	mov    %eax,%edx
  801206:	eb 05                	jmp    80120d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801208:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80120d:	89 d0                	mov    %edx,%eax
  80120f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801212:	c9                   	leave  
  801213:	c3                   	ret    

00801214 <seek>:

int
seek(int fdnum, off_t offset)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80121d:	50                   	push   %eax
  80121e:	ff 75 08             	pushl  0x8(%ebp)
  801221:	e8 22 fc ff ff       	call   800e48 <fd_lookup>
  801226:	83 c4 08             	add    $0x8,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 0e                	js     80123b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80122d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801230:	8b 55 0c             	mov    0xc(%ebp),%edx
  801233:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801236:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	53                   	push   %ebx
  801241:	83 ec 14             	sub    $0x14,%esp
  801244:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801247:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	53                   	push   %ebx
  80124c:	e8 f7 fb ff ff       	call   800e48 <fd_lookup>
  801251:	83 c4 08             	add    $0x8,%esp
  801254:	89 c2                	mov    %eax,%edx
  801256:	85 c0                	test   %eax,%eax
  801258:	78 65                	js     8012bf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801264:	ff 30                	pushl  (%eax)
  801266:	e8 33 fc ff ff       	call   800e9e <dev_lookup>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 44                	js     8012b6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801272:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801275:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801279:	75 21                	jne    80129c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80127b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801280:	8b 40 48             	mov    0x48(%eax),%eax
  801283:	83 ec 04             	sub    $0x4,%esp
  801286:	53                   	push   %ebx
  801287:	50                   	push   %eax
  801288:	68 6c 22 80 00       	push   $0x80226c
  80128d:	e8 5c ef ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129a:	eb 23                	jmp    8012bf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80129c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129f:	8b 52 18             	mov    0x18(%edx),%edx
  8012a2:	85 d2                	test   %edx,%edx
  8012a4:	74 14                	je     8012ba <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	ff 75 0c             	pushl  0xc(%ebp)
  8012ac:	50                   	push   %eax
  8012ad:	ff d2                	call   *%edx
  8012af:	89 c2                	mov    %eax,%edx
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	eb 09                	jmp    8012bf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b6:	89 c2                	mov    %eax,%edx
  8012b8:	eb 05                	jmp    8012bf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012bf:	89 d0                	mov    %edx,%eax
  8012c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c4:	c9                   	leave  
  8012c5:	c3                   	ret    

008012c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 14             	sub    $0x14,%esp
  8012cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d3:	50                   	push   %eax
  8012d4:	ff 75 08             	pushl  0x8(%ebp)
  8012d7:	e8 6c fb ff ff       	call   800e48 <fd_lookup>
  8012dc:	83 c4 08             	add    $0x8,%esp
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 58                	js     80133d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	ff 30                	pushl  (%eax)
  8012f1:	e8 a8 fb ff ff       	call   800e9e <dev_lookup>
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 37                	js     801334 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801300:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801304:	74 32                	je     801338 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801306:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801309:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801310:	00 00 00 
	stat->st_isdir = 0;
  801313:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80131a:	00 00 00 
	stat->st_dev = dev;
  80131d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	53                   	push   %ebx
  801327:	ff 75 f0             	pushl  -0x10(%ebp)
  80132a:	ff 50 14             	call   *0x14(%eax)
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	eb 09                	jmp    80133d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801334:	89 c2                	mov    %eax,%edx
  801336:	eb 05                	jmp    80133d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801338:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80133d:	89 d0                	mov    %edx,%eax
  80133f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	6a 00                	push   $0x0
  80134e:	ff 75 08             	pushl  0x8(%ebp)
  801351:	e8 d6 01 00 00       	call   80152c <open>
  801356:	89 c3                	mov    %eax,%ebx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 1b                	js     80137a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	ff 75 0c             	pushl  0xc(%ebp)
  801365:	50                   	push   %eax
  801366:	e8 5b ff ff ff       	call   8012c6 <fstat>
  80136b:	89 c6                	mov    %eax,%esi
	close(fd);
  80136d:	89 1c 24             	mov    %ebx,(%esp)
  801370:	e8 fd fb ff ff       	call   800f72 <close>
	return r;
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	89 f0                	mov    %esi,%eax
}
  80137a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    

00801381 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
  801386:	89 c6                	mov    %eax,%esi
  801388:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80138a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801391:	75 12                	jne    8013a5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	6a 01                	push   $0x1
  801398:	e8 cd 07 00 00       	call   801b6a <ipc_find_env>
  80139d:	a3 00 40 80 00       	mov    %eax,0x804000
  8013a2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013a5:	6a 07                	push   $0x7
  8013a7:	68 00 50 80 00       	push   $0x805000
  8013ac:	56                   	push   %esi
  8013ad:	ff 35 00 40 80 00    	pushl  0x804000
  8013b3:	e8 5e 07 00 00       	call   801b16 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013b8:	83 c4 0c             	add    $0xc,%esp
  8013bb:	6a 00                	push   $0x0
  8013bd:	53                   	push   %ebx
  8013be:	6a 00                	push   $0x0
  8013c0:	e8 ea 06 00 00       	call   801aaf <ipc_recv>
}
  8013c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ea:	b8 02 00 00 00       	mov    $0x2,%eax
  8013ef:	e8 8d ff ff ff       	call   801381 <fsipc>
}
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801402:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801407:	ba 00 00 00 00       	mov    $0x0,%edx
  80140c:	b8 06 00 00 00       	mov    $0x6,%eax
  801411:	e8 6b ff ff ff       	call   801381 <fsipc>
}
  801416:	c9                   	leave  
  801417:	c3                   	ret    

00801418 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	53                   	push   %ebx
  80141c:	83 ec 04             	sub    $0x4,%esp
  80141f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	8b 40 0c             	mov    0xc(%eax),%eax
  801428:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80142d:	ba 00 00 00 00       	mov    $0x0,%edx
  801432:	b8 05 00 00 00       	mov    $0x5,%eax
  801437:	e8 45 ff ff ff       	call   801381 <fsipc>
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 2c                	js     80146c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801440:	83 ec 08             	sub    $0x8,%esp
  801443:	68 00 50 80 00       	push   $0x805000
  801448:	53                   	push   %ebx
  801449:	e8 25 f3 ff ff       	call   800773 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80144e:	a1 80 50 80 00       	mov    0x805080,%eax
  801453:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801459:	a1 84 50 80 00       	mov    0x805084,%eax
  80145e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	83 ec 0c             	sub    $0xc,%esp
  801477:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80147a:	8b 55 08             	mov    0x8(%ebp),%edx
  80147d:	8b 52 0c             	mov    0xc(%edx),%edx
  801480:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801486:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80148b:	50                   	push   %eax
  80148c:	ff 75 0c             	pushl  0xc(%ebp)
  80148f:	68 08 50 80 00       	push   $0x805008
  801494:	e8 6c f4 ff ff       	call   800905 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801499:	ba 00 00 00 00       	mov    $0x0,%edx
  80149e:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a3:	e8 d9 fe ff ff       	call   801381 <fsipc>

}
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
  8014af:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014bd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014cd:	e8 af fe ff ff       	call   801381 <fsipc>
  8014d2:	89 c3                	mov    %eax,%ebx
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 4b                	js     801523 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014d8:	39 c6                	cmp    %eax,%esi
  8014da:	73 16                	jae    8014f2 <devfile_read+0x48>
  8014dc:	68 dc 22 80 00       	push   $0x8022dc
  8014e1:	68 e3 22 80 00       	push   $0x8022e3
  8014e6:	6a 7c                	push   $0x7c
  8014e8:	68 f8 22 80 00       	push   $0x8022f8
  8014ed:	e8 23 ec ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  8014f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f7:	7e 16                	jle    80150f <devfile_read+0x65>
  8014f9:	68 03 23 80 00       	push   $0x802303
  8014fe:	68 e3 22 80 00       	push   $0x8022e3
  801503:	6a 7d                	push   $0x7d
  801505:	68 f8 22 80 00       	push   $0x8022f8
  80150a:	e8 06 ec ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80150f:	83 ec 04             	sub    $0x4,%esp
  801512:	50                   	push   %eax
  801513:	68 00 50 80 00       	push   $0x805000
  801518:	ff 75 0c             	pushl  0xc(%ebp)
  80151b:	e8 e5 f3 ff ff       	call   800905 <memmove>
	return r;
  801520:	83 c4 10             	add    $0x10,%esp
}
  801523:	89 d8                	mov    %ebx,%eax
  801525:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	53                   	push   %ebx
  801530:	83 ec 20             	sub    $0x20,%esp
  801533:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801536:	53                   	push   %ebx
  801537:	e8 fe f1 ff ff       	call   80073a <strlen>
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801544:	7f 67                	jg     8015ad <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154c:	50                   	push   %eax
  80154d:	e8 a7 f8 ff ff       	call   800df9 <fd_alloc>
  801552:	83 c4 10             	add    $0x10,%esp
		return r;
  801555:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801557:	85 c0                	test   %eax,%eax
  801559:	78 57                	js     8015b2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	53                   	push   %ebx
  80155f:	68 00 50 80 00       	push   $0x805000
  801564:	e8 0a f2 ff ff       	call   800773 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801569:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801571:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801574:	b8 01 00 00 00       	mov    $0x1,%eax
  801579:	e8 03 fe ff ff       	call   801381 <fsipc>
  80157e:	89 c3                	mov    %eax,%ebx
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	79 14                	jns    80159b <open+0x6f>
		fd_close(fd, 0);
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	6a 00                	push   $0x0
  80158c:	ff 75 f4             	pushl  -0xc(%ebp)
  80158f:	e8 5d f9 ff ff       	call   800ef1 <fd_close>
		return r;
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	89 da                	mov    %ebx,%edx
  801599:	eb 17                	jmp    8015b2 <open+0x86>
	}

	return fd2num(fd);
  80159b:	83 ec 0c             	sub    $0xc,%esp
  80159e:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a1:	e8 2c f8 ff ff       	call   800dd2 <fd2num>
  8015a6:	89 c2                	mov    %eax,%edx
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	eb 05                	jmp    8015b2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015ad:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015b2:	89 d0                	mov    %edx,%eax
  8015b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c9:	e8 b3 fd ff ff       	call   801381 <fsipc>
}
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015d8:	83 ec 0c             	sub    $0xc,%esp
  8015db:	ff 75 08             	pushl  0x8(%ebp)
  8015de:	e8 ff f7 ff ff       	call   800de2 <fd2data>
  8015e3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015e5:	83 c4 08             	add    $0x8,%esp
  8015e8:	68 0f 23 80 00       	push   $0x80230f
  8015ed:	53                   	push   %ebx
  8015ee:	e8 80 f1 ff ff       	call   800773 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015f3:	8b 46 04             	mov    0x4(%esi),%eax
  8015f6:	2b 06                	sub    (%esi),%eax
  8015f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801605:	00 00 00 
	stat->st_dev = &devpipe;
  801608:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80160f:	30 80 00 
	return 0;
}
  801612:	b8 00 00 00 00       	mov    $0x0,%eax
  801617:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	53                   	push   %ebx
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801628:	53                   	push   %ebx
  801629:	6a 00                	push   $0x0
  80162b:	e8 cb f5 ff ff       	call   800bfb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801630:	89 1c 24             	mov    %ebx,(%esp)
  801633:	e8 aa f7 ff ff       	call   800de2 <fd2data>
  801638:	83 c4 08             	add    $0x8,%esp
  80163b:	50                   	push   %eax
  80163c:	6a 00                	push   $0x0
  80163e:	e8 b8 f5 ff ff       	call   800bfb <sys_page_unmap>
}
  801643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	57                   	push   %edi
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	83 ec 1c             	sub    $0x1c,%esp
  801651:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801654:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801656:	a1 04 40 80 00       	mov    0x804004,%eax
  80165b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	ff 75 e0             	pushl  -0x20(%ebp)
  801664:	e8 3a 05 00 00       	call   801ba3 <pageref>
  801669:	89 c3                	mov    %eax,%ebx
  80166b:	89 3c 24             	mov    %edi,(%esp)
  80166e:	e8 30 05 00 00       	call   801ba3 <pageref>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	39 c3                	cmp    %eax,%ebx
  801678:	0f 94 c1             	sete   %cl
  80167b:	0f b6 c9             	movzbl %cl,%ecx
  80167e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801681:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801687:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80168a:	39 ce                	cmp    %ecx,%esi
  80168c:	74 1b                	je     8016a9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80168e:	39 c3                	cmp    %eax,%ebx
  801690:	75 c4                	jne    801656 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801692:	8b 42 58             	mov    0x58(%edx),%eax
  801695:	ff 75 e4             	pushl  -0x1c(%ebp)
  801698:	50                   	push   %eax
  801699:	56                   	push   %esi
  80169a:	68 16 23 80 00       	push   $0x802316
  80169f:	e8 4a eb ff ff       	call   8001ee <cprintf>
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	eb ad                	jmp    801656 <_pipeisclosed+0xe>
	}
}
  8016a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	57                   	push   %edi
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 28             	sub    $0x28,%esp
  8016bd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016c0:	56                   	push   %esi
  8016c1:	e8 1c f7 ff ff       	call   800de2 <fd2data>
  8016c6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8016d0:	eb 4b                	jmp    80171d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016d2:	89 da                	mov    %ebx,%edx
  8016d4:	89 f0                	mov    %esi,%eax
  8016d6:	e8 6d ff ff ff       	call   801648 <_pipeisclosed>
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	75 48                	jne    801727 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016df:	e8 73 f4 ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016e4:	8b 43 04             	mov    0x4(%ebx),%eax
  8016e7:	8b 0b                	mov    (%ebx),%ecx
  8016e9:	8d 51 20             	lea    0x20(%ecx),%edx
  8016ec:	39 d0                	cmp    %edx,%eax
  8016ee:	73 e2                	jae    8016d2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016f7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	c1 fa 1f             	sar    $0x1f,%edx
  8016ff:	89 d1                	mov    %edx,%ecx
  801701:	c1 e9 1b             	shr    $0x1b,%ecx
  801704:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801707:	83 e2 1f             	and    $0x1f,%edx
  80170a:	29 ca                	sub    %ecx,%edx
  80170c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801710:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801714:	83 c0 01             	add    $0x1,%eax
  801717:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80171a:	83 c7 01             	add    $0x1,%edi
  80171d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801720:	75 c2                	jne    8016e4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801722:	8b 45 10             	mov    0x10(%ebp),%eax
  801725:	eb 05                	jmp    80172c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801727:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80172c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172f:	5b                   	pop    %ebx
  801730:	5e                   	pop    %esi
  801731:	5f                   	pop    %edi
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	57                   	push   %edi
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	83 ec 18             	sub    $0x18,%esp
  80173d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801740:	57                   	push   %edi
  801741:	e8 9c f6 ff ff       	call   800de2 <fd2data>
  801746:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801750:	eb 3d                	jmp    80178f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801752:	85 db                	test   %ebx,%ebx
  801754:	74 04                	je     80175a <devpipe_read+0x26>
				return i;
  801756:	89 d8                	mov    %ebx,%eax
  801758:	eb 44                	jmp    80179e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80175a:	89 f2                	mov    %esi,%edx
  80175c:	89 f8                	mov    %edi,%eax
  80175e:	e8 e5 fe ff ff       	call   801648 <_pipeisclosed>
  801763:	85 c0                	test   %eax,%eax
  801765:	75 32                	jne    801799 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801767:	e8 eb f3 ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80176c:	8b 06                	mov    (%esi),%eax
  80176e:	3b 46 04             	cmp    0x4(%esi),%eax
  801771:	74 df                	je     801752 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801773:	99                   	cltd   
  801774:	c1 ea 1b             	shr    $0x1b,%edx
  801777:	01 d0                	add    %edx,%eax
  801779:	83 e0 1f             	and    $0x1f,%eax
  80177c:	29 d0                	sub    %edx,%eax
  80177e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801786:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801789:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178c:	83 c3 01             	add    $0x1,%ebx
  80178f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801792:	75 d8                	jne    80176c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801794:	8b 45 10             	mov    0x10(%ebp),%eax
  801797:	eb 05                	jmp    80179e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801799:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80179e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a1:	5b                   	pop    %ebx
  8017a2:	5e                   	pop    %esi
  8017a3:	5f                   	pop    %edi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	56                   	push   %esi
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b1:	50                   	push   %eax
  8017b2:	e8 42 f6 ff ff       	call   800df9 <fd_alloc>
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	89 c2                	mov    %eax,%edx
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	0f 88 2c 01 00 00    	js     8018f0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c4:	83 ec 04             	sub    $0x4,%esp
  8017c7:	68 07 04 00 00       	push   $0x407
  8017cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8017cf:	6a 00                	push   $0x0
  8017d1:	e8 a0 f3 ff ff       	call   800b76 <sys_page_alloc>
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	89 c2                	mov    %eax,%edx
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	0f 88 0d 01 00 00    	js     8018f0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017e3:	83 ec 0c             	sub    $0xc,%esp
  8017e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e9:	50                   	push   %eax
  8017ea:	e8 0a f6 ff ff       	call   800df9 <fd_alloc>
  8017ef:	89 c3                	mov    %eax,%ebx
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	0f 88 e2 00 00 00    	js     8018de <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017fc:	83 ec 04             	sub    $0x4,%esp
  8017ff:	68 07 04 00 00       	push   $0x407
  801804:	ff 75 f0             	pushl  -0x10(%ebp)
  801807:	6a 00                	push   $0x0
  801809:	e8 68 f3 ff ff       	call   800b76 <sys_page_alloc>
  80180e:	89 c3                	mov    %eax,%ebx
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	0f 88 c3 00 00 00    	js     8018de <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80181b:	83 ec 0c             	sub    $0xc,%esp
  80181e:	ff 75 f4             	pushl  -0xc(%ebp)
  801821:	e8 bc f5 ff ff       	call   800de2 <fd2data>
  801826:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801828:	83 c4 0c             	add    $0xc,%esp
  80182b:	68 07 04 00 00       	push   $0x407
  801830:	50                   	push   %eax
  801831:	6a 00                	push   $0x0
  801833:	e8 3e f3 ff ff       	call   800b76 <sys_page_alloc>
  801838:	89 c3                	mov    %eax,%ebx
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	0f 88 89 00 00 00    	js     8018ce <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801845:	83 ec 0c             	sub    $0xc,%esp
  801848:	ff 75 f0             	pushl  -0x10(%ebp)
  80184b:	e8 92 f5 ff ff       	call   800de2 <fd2data>
  801850:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801857:	50                   	push   %eax
  801858:	6a 00                	push   $0x0
  80185a:	56                   	push   %esi
  80185b:	6a 00                	push   $0x0
  80185d:	e8 57 f3 ff ff       	call   800bb9 <sys_page_map>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	83 c4 20             	add    $0x20,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	78 55                	js     8018c0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80186b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801874:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801879:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801880:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801889:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80188b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801895:	83 ec 0c             	sub    $0xc,%esp
  801898:	ff 75 f4             	pushl  -0xc(%ebp)
  80189b:	e8 32 f5 ff ff       	call   800dd2 <fd2num>
  8018a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018a3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018a5:	83 c4 04             	add    $0x4,%esp
  8018a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ab:	e8 22 f5 ff ff       	call   800dd2 <fd2num>
  8018b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018be:	eb 30                	jmp    8018f0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	56                   	push   %esi
  8018c4:	6a 00                	push   $0x0
  8018c6:	e8 30 f3 ff ff       	call   800bfb <sys_page_unmap>
  8018cb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018ce:	83 ec 08             	sub    $0x8,%esp
  8018d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d4:	6a 00                	push   $0x0
  8018d6:	e8 20 f3 ff ff       	call   800bfb <sys_page_unmap>
  8018db:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e4:	6a 00                	push   $0x0
  8018e6:	e8 10 f3 ff ff       	call   800bfb <sys_page_unmap>
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018f0:	89 d0                	mov    %edx,%eax
  8018f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f5:	5b                   	pop    %ebx
  8018f6:	5e                   	pop    %esi
  8018f7:	5d                   	pop    %ebp
  8018f8:	c3                   	ret    

008018f9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801902:	50                   	push   %eax
  801903:	ff 75 08             	pushl  0x8(%ebp)
  801906:	e8 3d f5 ff ff       	call   800e48 <fd_lookup>
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 18                	js     80192a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	ff 75 f4             	pushl  -0xc(%ebp)
  801918:	e8 c5 f4 ff ff       	call   800de2 <fd2data>
	return _pipeisclosed(fd, p);
  80191d:	89 c2                	mov    %eax,%edx
  80191f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801922:	e8 21 fd ff ff       	call   801648 <_pipeisclosed>
  801927:	83 c4 10             	add    $0x10,%esp
}
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80192f:	b8 00 00 00 00       	mov    $0x0,%eax
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80193c:	68 2e 23 80 00       	push   $0x80232e
  801941:	ff 75 0c             	pushl  0xc(%ebp)
  801944:	e8 2a ee ff ff       	call   800773 <strcpy>
	return 0;
}
  801949:	b8 00 00 00 00       	mov    $0x0,%eax
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	57                   	push   %edi
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
  801956:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80195c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801961:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801967:	eb 2d                	jmp    801996 <devcons_write+0x46>
		m = n - tot;
  801969:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80196c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80196e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801971:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801976:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801979:	83 ec 04             	sub    $0x4,%esp
  80197c:	53                   	push   %ebx
  80197d:	03 45 0c             	add    0xc(%ebp),%eax
  801980:	50                   	push   %eax
  801981:	57                   	push   %edi
  801982:	e8 7e ef ff ff       	call   800905 <memmove>
		sys_cputs(buf, m);
  801987:	83 c4 08             	add    $0x8,%esp
  80198a:	53                   	push   %ebx
  80198b:	57                   	push   %edi
  80198c:	e8 29 f1 ff ff       	call   800aba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801991:	01 de                	add    %ebx,%esi
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	89 f0                	mov    %esi,%eax
  801998:	3b 75 10             	cmp    0x10(%ebp),%esi
  80199b:	72 cc                	jb     801969 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80199d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5f                   	pop    %edi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    

008019a5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 08             	sub    $0x8,%esp
  8019ab:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019b4:	74 2a                	je     8019e0 <devcons_read+0x3b>
  8019b6:	eb 05                	jmp    8019bd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019b8:	e8 9a f1 ff ff       	call   800b57 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019bd:	e8 16 f1 ff ff       	call   800ad8 <sys_cgetc>
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	74 f2                	je     8019b8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 16                	js     8019e0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019ca:	83 f8 04             	cmp    $0x4,%eax
  8019cd:	74 0c                	je     8019db <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d2:	88 02                	mov    %al,(%edx)
	return 1;
  8019d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d9:	eb 05                	jmp    8019e0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019db:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019e0:	c9                   	leave  
  8019e1:	c3                   	ret    

008019e2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019ee:	6a 01                	push   $0x1
  8019f0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019f3:	50                   	push   %eax
  8019f4:	e8 c1 f0 ff ff       	call   800aba <sys_cputs>
}
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <getchar>:

int
getchar(void)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a04:	6a 01                	push   $0x1
  801a06:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a09:	50                   	push   %eax
  801a0a:	6a 00                	push   $0x0
  801a0c:	e8 9d f6 ff ff       	call   8010ae <read>
	if (r < 0)
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 0f                	js     801a27 <getchar+0x29>
		return r;
	if (r < 1)
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	7e 06                	jle    801a22 <getchar+0x24>
		return -E_EOF;
	return c;
  801a1c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a20:	eb 05                	jmp    801a27 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a22:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    

00801a29 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a32:	50                   	push   %eax
  801a33:	ff 75 08             	pushl  0x8(%ebp)
  801a36:	e8 0d f4 ff ff       	call   800e48 <fd_lookup>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 11                	js     801a53 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a45:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a4b:	39 10                	cmp    %edx,(%eax)
  801a4d:	0f 94 c0             	sete   %al
  801a50:	0f b6 c0             	movzbl %al,%eax
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <opencons>:

int
opencons(void)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5e:	50                   	push   %eax
  801a5f:	e8 95 f3 ff ff       	call   800df9 <fd_alloc>
  801a64:	83 c4 10             	add    $0x10,%esp
		return r;
  801a67:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 3e                	js     801aab <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a6d:	83 ec 04             	sub    $0x4,%esp
  801a70:	68 07 04 00 00       	push   $0x407
  801a75:	ff 75 f4             	pushl  -0xc(%ebp)
  801a78:	6a 00                	push   $0x0
  801a7a:	e8 f7 f0 ff ff       	call   800b76 <sys_page_alloc>
  801a7f:	83 c4 10             	add    $0x10,%esp
		return r;
  801a82:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a84:	85 c0                	test   %eax,%eax
  801a86:	78 23                	js     801aab <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a88:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a91:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a96:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	50                   	push   %eax
  801aa1:	e8 2c f3 ff ff       	call   800dd2 <fd2num>
  801aa6:	89 c2                	mov    %eax,%edx
  801aa8:	83 c4 10             	add    $0x10,%esp
}
  801aab:	89 d0                	mov    %edx,%eax
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801abd:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801abf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ac4:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ac7:	83 ec 0c             	sub    $0xc,%esp
  801aca:	50                   	push   %eax
  801acb:	e8 56 f2 ff ff       	call   800d26 <sys_ipc_recv>

	if (from_env_store != NULL)
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	85 f6                	test   %esi,%esi
  801ad5:	74 14                	je     801aeb <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 09                	js     801ae9 <ipc_recv+0x3a>
  801ae0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ae6:	8b 52 74             	mov    0x74(%edx),%edx
  801ae9:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801aeb:	85 db                	test   %ebx,%ebx
  801aed:	74 14                	je     801b03 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 09                	js     801b01 <ipc_recv+0x52>
  801af8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801afe:	8b 52 78             	mov    0x78(%edx),%edx
  801b01:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801b03:	85 c0                	test   %eax,%eax
  801b05:	78 08                	js     801b0f <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801b07:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b12:	5b                   	pop    %ebx
  801b13:	5e                   	pop    %esi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	57                   	push   %edi
  801b1a:	56                   	push   %esi
  801b1b:	53                   	push   %ebx
  801b1c:	83 ec 0c             	sub    $0xc,%esp
  801b1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b22:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801b28:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801b2a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b2f:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801b32:	ff 75 14             	pushl  0x14(%ebp)
  801b35:	53                   	push   %ebx
  801b36:	56                   	push   %esi
  801b37:	57                   	push   %edi
  801b38:	e8 c6 f1 ff ff       	call   800d03 <sys_ipc_try_send>

		if (err < 0) {
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	79 1e                	jns    801b62 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801b44:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b47:	75 07                	jne    801b50 <ipc_send+0x3a>
				sys_yield();
  801b49:	e8 09 f0 ff ff       	call   800b57 <sys_yield>
  801b4e:	eb e2                	jmp    801b32 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801b50:	50                   	push   %eax
  801b51:	68 3a 23 80 00       	push   $0x80233a
  801b56:	6a 49                	push   $0x49
  801b58:	68 47 23 80 00       	push   $0x802347
  801b5d:	e8 b3 e5 ff ff       	call   800115 <_panic>
		}

	} while (err < 0);

}
  801b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b75:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b78:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b7e:	8b 52 50             	mov    0x50(%edx),%edx
  801b81:	39 ca                	cmp    %ecx,%edx
  801b83:	75 0d                	jne    801b92 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b85:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b88:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b8d:	8b 40 48             	mov    0x48(%eax),%eax
  801b90:	eb 0f                	jmp    801ba1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b92:	83 c0 01             	add    $0x1,%eax
  801b95:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b9a:	75 d9                	jne    801b75 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba9:	89 d0                	mov    %edx,%eax
  801bab:	c1 e8 16             	shr    $0x16,%eax
  801bae:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bba:	f6 c1 01             	test   $0x1,%cl
  801bbd:	74 1d                	je     801bdc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bbf:	c1 ea 0c             	shr    $0xc,%edx
  801bc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bc9:	f6 c2 01             	test   $0x1,%dl
  801bcc:	74 0e                	je     801bdc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bce:	c1 ea 0c             	shr    $0xc,%edx
  801bd1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bd8:	ef 
  801bd9:	0f b7 c0             	movzwl %ax,%eax
}
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    
  801bde:	66 90                	xchg   %ax,%ax

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
  801be7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801beb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bf7:	85 f6                	test   %esi,%esi
  801bf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bfd:	89 ca                	mov    %ecx,%edx
  801bff:	89 f8                	mov    %edi,%eax
  801c01:	75 3d                	jne    801c40 <__udivdi3+0x60>
  801c03:	39 cf                	cmp    %ecx,%edi
  801c05:	0f 87 c5 00 00 00    	ja     801cd0 <__udivdi3+0xf0>
  801c0b:	85 ff                	test   %edi,%edi
  801c0d:	89 fd                	mov    %edi,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f7                	div    %edi
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 c8                	mov    %ecx,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c1                	mov    %eax,%ecx
  801c24:	89 d8                	mov    %ebx,%eax
  801c26:	89 cf                	mov    %ecx,%edi
  801c28:	f7 f5                	div    %ebp
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	89 fa                	mov    %edi,%edx
  801c30:	83 c4 1c             	add    $0x1c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
  801c38:	90                   	nop
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	39 ce                	cmp    %ecx,%esi
  801c42:	77 74                	ja     801cb8 <__udivdi3+0xd8>
  801c44:	0f bd fe             	bsr    %esi,%edi
  801c47:	83 f7 1f             	xor    $0x1f,%edi
  801c4a:	0f 84 98 00 00 00    	je     801ce8 <__udivdi3+0x108>
  801c50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	89 c5                	mov    %eax,%ebp
  801c59:	29 fb                	sub    %edi,%ebx
  801c5b:	d3 e6                	shl    %cl,%esi
  801c5d:	89 d9                	mov    %ebx,%ecx
  801c5f:	d3 ed                	shr    %cl,%ebp
  801c61:	89 f9                	mov    %edi,%ecx
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	09 ee                	or     %ebp,%esi
  801c67:	89 d9                	mov    %ebx,%ecx
  801c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6d:	89 d5                	mov    %edx,%ebp
  801c6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c73:	d3 ed                	shr    %cl,%ebp
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e2                	shl    %cl,%edx
  801c79:	89 d9                	mov    %ebx,%ecx
  801c7b:	d3 e8                	shr    %cl,%eax
  801c7d:	09 c2                	or     %eax,%edx
  801c7f:	89 d0                	mov    %edx,%eax
  801c81:	89 ea                	mov    %ebp,%edx
  801c83:	f7 f6                	div    %esi
  801c85:	89 d5                	mov    %edx,%ebp
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	f7 64 24 0c          	mull   0xc(%esp)
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	72 10                	jb     801ca1 <__udivdi3+0xc1>
  801c91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 e6                	shl    %cl,%esi
  801c99:	39 c6                	cmp    %eax,%esi
  801c9b:	73 07                	jae    801ca4 <__udivdi3+0xc4>
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	75 03                	jne    801ca4 <__udivdi3+0xc4>
  801ca1:	83 eb 01             	sub    $0x1,%ebx
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	89 fa                	mov    %edi,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	31 ff                	xor    %edi,%edi
  801cba:	31 db                	xor    %ebx,%ebx
  801cbc:	89 d8                	mov    %ebx,%eax
  801cbe:	89 fa                	mov    %edi,%edx
  801cc0:	83 c4 1c             	add    $0x1c,%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    
  801cc8:	90                   	nop
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 d8                	mov    %ebx,%eax
  801cd2:	f7 f7                	div    %edi
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	89 fa                	mov    %edi,%edx
  801cdc:	83 c4 1c             	add    $0x1c,%esp
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	39 ce                	cmp    %ecx,%esi
  801cea:	72 0c                	jb     801cf8 <__udivdi3+0x118>
  801cec:	31 db                	xor    %ebx,%ebx
  801cee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cf2:	0f 87 34 ff ff ff    	ja     801c2c <__udivdi3+0x4c>
  801cf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cfd:	e9 2a ff ff ff       	jmp    801c2c <__udivdi3+0x4c>
  801d02:	66 90                	xchg   %ax,%ax
  801d04:	66 90                	xchg   %ax,%ax
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 1c             	sub    $0x1c,%esp
  801d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d27:	85 d2                	test   %edx,%edx
  801d29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d31:	89 f3                	mov    %esi,%ebx
  801d33:	89 3c 24             	mov    %edi,(%esp)
  801d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3a:	75 1c                	jne    801d58 <__umoddi3+0x48>
  801d3c:	39 f7                	cmp    %esi,%edi
  801d3e:	76 50                	jbe    801d90 <__umoddi3+0x80>
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	f7 f7                	div    %edi
  801d46:	89 d0                	mov    %edx,%eax
  801d48:	31 d2                	xor    %edx,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	39 f2                	cmp    %esi,%edx
  801d5a:	89 d0                	mov    %edx,%eax
  801d5c:	77 52                	ja     801db0 <__umoddi3+0xa0>
  801d5e:	0f bd ea             	bsr    %edx,%ebp
  801d61:	83 f5 1f             	xor    $0x1f,%ebp
  801d64:	75 5a                	jne    801dc0 <__umoddi3+0xb0>
  801d66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d6a:	0f 82 e0 00 00 00    	jb     801e50 <__umoddi3+0x140>
  801d70:	39 0c 24             	cmp    %ecx,(%esp)
  801d73:	0f 86 d7 00 00 00    	jbe    801e50 <__umoddi3+0x140>
  801d79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d81:	83 c4 1c             	add    $0x1c,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	85 ff                	test   %edi,%edi
  801d92:	89 fd                	mov    %edi,%ebp
  801d94:	75 0b                	jne    801da1 <__umoddi3+0x91>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f7                	div    %edi
  801d9f:	89 c5                	mov    %eax,%ebp
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f5                	div    %ebp
  801da7:	89 c8                	mov    %ecx,%eax
  801da9:	f7 f5                	div    %ebp
  801dab:	89 d0                	mov    %edx,%eax
  801dad:	eb 99                	jmp    801d48 <__umoddi3+0x38>
  801daf:	90                   	nop
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	83 c4 1c             	add    $0x1c,%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5f                   	pop    %edi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    
  801dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	8b 34 24             	mov    (%esp),%esi
  801dc3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dc8:	89 e9                	mov    %ebp,%ecx
  801dca:	29 ef                	sub    %ebp,%edi
  801dcc:	d3 e0                	shl    %cl,%eax
  801dce:	89 f9                	mov    %edi,%ecx
  801dd0:	89 f2                	mov    %esi,%edx
  801dd2:	d3 ea                	shr    %cl,%edx
  801dd4:	89 e9                	mov    %ebp,%ecx
  801dd6:	09 c2                	or     %eax,%edx
  801dd8:	89 d8                	mov    %ebx,%eax
  801dda:	89 14 24             	mov    %edx,(%esp)
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	d3 e2                	shl    %cl,%edx
  801de1:	89 f9                	mov    %edi,%ecx
  801de3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	89 c6                	mov    %eax,%esi
  801df1:	d3 e3                	shl    %cl,%ebx
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 d0                	mov    %edx,%eax
  801df7:	d3 e8                	shr    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	09 d8                	or     %ebx,%eax
  801dfd:	89 d3                	mov    %edx,%ebx
  801dff:	89 f2                	mov    %esi,%edx
  801e01:	f7 34 24             	divl   (%esp)
  801e04:	89 d6                	mov    %edx,%esi
  801e06:	d3 e3                	shl    %cl,%ebx
  801e08:	f7 64 24 04          	mull   0x4(%esp)
  801e0c:	39 d6                	cmp    %edx,%esi
  801e0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e12:	89 d1                	mov    %edx,%ecx
  801e14:	89 c3                	mov    %eax,%ebx
  801e16:	72 08                	jb     801e20 <__umoddi3+0x110>
  801e18:	75 11                	jne    801e2b <__umoddi3+0x11b>
  801e1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e1e:	73 0b                	jae    801e2b <__umoddi3+0x11b>
  801e20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e24:	1b 14 24             	sbb    (%esp),%edx
  801e27:	89 d1                	mov    %edx,%ecx
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e2f:	29 da                	sub    %ebx,%edx
  801e31:	19 ce                	sbb    %ecx,%esi
  801e33:	89 f9                	mov    %edi,%ecx
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	d3 e0                	shl    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	d3 ea                	shr    %cl,%edx
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	d3 ee                	shr    %cl,%esi
  801e41:	09 d0                	or     %edx,%eax
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	83 c4 1c             	add    $0x1c,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi
  801e50:	29 f9                	sub    %edi,%ecx
  801e52:	19 d6                	sbb    %edx,%esi
  801e54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e5c:	e9 18 ff ff ff       	jmp    801d79 <__umoddi3+0x69>
