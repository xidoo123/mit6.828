
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 20 27 80 00       	push   $0x802720
  800043:	e8 6d 18 00 00       	call   8018b5 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 25 27 80 00       	push   $0x802725
  800057:	6a 0c                	push   $0xc
  800059:	68 33 27 80 00       	push   $0x802733
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 2f 15 00 00       	call   80159d <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 47 14 00 00       	call   8014c8 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 48 27 80 00       	push   $0x802748
  800090:	6a 0f                	push   $0xf
  800092:	68 33 27 80 00       	push   $0x802733
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 03 0f 00 00       	call   800fa4 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 52 27 80 00       	push   $0x802752
  8000ad:	6a 12                	push   $0x12
  8000af:	68 33 27 80 00       	push   $0x802733
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 d1 14 00 00       	call   80159d <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 dd 13 00 00       	call   8014c8 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 d4 27 80 00       	push   $0x8027d4
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 33 27 80 00       	push   $0x802733
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 68 09 00 00       	call   800a83 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 00 28 80 00       	push   $0x802800
  80012a:	6a 19                	push   $0x19
  80012c:	68 33 27 80 00       	push   $0x802733
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 5b 27 80 00       	push   $0x80275b
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 4f 14 00 00       	call   80159d <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 a5 11 00 00       	call   8012fb <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 b5 1f 00 00       	call   80211c <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 4e 13 00 00       	call   8014c8 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 38 28 80 00       	push   $0x802838
  80018b:	6a 21                	push   $0x21
  80018d:	68 33 27 80 00       	push   $0x802733
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 74 27 80 00       	push   $0x802774
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 4f 11 00 00       	call   8012fb <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 73 0a 00 00       	call   800c3b <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 1d 11 00 00       	call   801326 <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 e7 09 00 00       	call   800bfa <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 10 0a 00 00       	call   800c3b <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 68 28 80 00       	push   $0x802868
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 72 27 80 00 	movl   $0x802772,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 2f 09 00 00       	call   800bbd <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 54 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 d4 08 00 00       	call   800bbd <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 37 21 00 00       	call   802490 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 24 22 00 00       	call   8025c0 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 8b 28 80 00 	movsbl 0x80288b(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	eb 12                	jmp    80044e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043c:	85 c0                	test   %eax,%eax
  80043e:	0f 84 89 03 00 00    	je     8007cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	50                   	push   %eax
  800449:	ff d6                	call   *%esi
  80044b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e2                	jne    80043c <vprintfmt+0x14>
  80045a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800465:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 07                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8d 47 01             	lea    0x1(%edi),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	0f b6 07             	movzbl (%edi),%eax
  80048a:	0f b6 c8             	movzbl %al,%ecx
  80048d:	83 e8 23             	sub    $0x23,%eax
  800490:	3c 55                	cmp    $0x55,%al
  800492:	0f 87 1a 03 00 00    	ja     8007b2 <vprintfmt+0x38a>
  800498:	0f b6 c0             	movzbl %al,%eax
  80049b:	ff 24 85 c0 29 80 00 	jmp    *0x8029c0(,%eax,4)
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a9:	eb d6                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004c3:	83 fa 09             	cmp    $0x9,%edx
  8004c6:	77 39                	ja     800501 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004cb:	eb e9                	jmp    8004b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004de:	eb 27                	jmp    800507 <vprintfmt+0xdf>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ea:	0f 49 c8             	cmovns %eax,%ecx
  8004ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	eb 8c                	jmp    800481 <vprintfmt+0x59>
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ff:	eb 80                	jmp    800481 <vprintfmt+0x59>
  800501:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	0f 89 70 ff ff ff    	jns    800481 <vprintfmt+0x59>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	e9 5e ff ff ff       	jmp    800481 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800523:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800529:	e9 53 ff ff ff       	jmp    800481 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	ff 30                	pushl  (%eax)
  80053d:	ff d6                	call   *%esi
			break;
  80053f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 04 ff ff ff       	jmp    80044e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 0f             	cmp    $0xf,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x142>
  80055f:	8b 14 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 a3 28 80 00       	push   $0x8028a3
  800570:	53                   	push   %ebx
  800571:	56                   	push   %esi
  800572:	e8 94 fe ff ff       	call   80040b <printfmt>
  800577:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057d:	e9 cc fe ff ff       	jmp    80044e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800582:	52                   	push   %edx
  800583:	68 11 2d 80 00       	push   $0x802d11
  800588:	53                   	push   %ebx
  800589:	56                   	push   %esi
  80058a:	e8 7c fe ff ff       	call   80040b <printfmt>
  80058f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800595:	e9 b4 fe ff ff       	jmp    80044e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	b8 9c 28 80 00       	mov    $0x80289c,%eax
  8005ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b3:	0f 8e 94 00 00 00    	jle    80064d <vprintfmt+0x225>
  8005b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bd:	0f 84 98 00 00 00    	je     80065b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c9:	57                   	push   %edi
  8005ca:	e8 86 02 00 00       	call   800855 <strnlen>
  8005cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d2:	29 c1                	sub    %eax,%ecx
  8005d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x1c0>
  8005fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800601:	85 c9                	test   %ecx,%ecx
  800603:	b8 00 00 00 00       	mov    $0x0,%eax
  800608:	0f 49 c1             	cmovns %ecx,%eax
  80060b:	29 c1                	sub    %eax,%ecx
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	89 cb                	mov    %ecx,%ebx
  800618:	eb 4d                	jmp    800667 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x213>
  800620:	0f be c0             	movsbl %al,%eax
  800623:	83 e8 20             	sub    $0x20,%eax
  800626:	83 f8 5e             	cmp    $0x5e,%eax
  800629:	76 10                	jbe    80063b <vprintfmt+0x213>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	6a 3f                	push   $0x3f
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	52                   	push   %edx
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	eb 1a                	jmp    800667 <vprintfmt+0x23f>
  80064d:	89 75 08             	mov    %esi,0x8(%ebp)
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800656:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800659:	eb 0c                	jmp    800667 <vprintfmt+0x23f>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800661:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800664:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800667:	83 c7 01             	add    $0x1,%edi
  80066a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066e:	0f be d0             	movsbl %al,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 23                	je     800698 <vprintfmt+0x270>
  800675:	85 f6                	test   %esi,%esi
  800677:	78 a1                	js     80061a <vprintfmt+0x1f2>
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	79 9c                	jns    80061a <vprintfmt+0x1f2>
  80067e:	89 df                	mov    %ebx,%edi
  800680:	8b 75 08             	mov    0x8(%ebp),%esi
  800683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800686:	eb 18                	jmp    8006a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 20                	push   $0x20
  80068e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	83 ef 01             	sub    $0x1,%edi
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 08                	jmp    8006a0 <vprintfmt+0x278>
  800698:	89 df                	mov    %ebx,%edi
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f e4                	jg     800688 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	e9 a2 fd ff ff       	jmp    80044e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 fa 01             	cmp    $0x1,%edx
  8006af:	7e 16                	jle    8006c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 08             	lea    0x8(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 50 04             	mov    0x4(%eax),%edx
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c5:	eb 32                	jmp    8006f9 <vprintfmt+0x2d1>
	else if (lflag)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 18                	je     8006e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	89 c1                	mov    %eax,%ecx
  8006db:	c1 f9 1f             	sar    $0x1f,%ecx
  8006de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e1:	eb 16                	jmp    8006f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 50 04             	lea    0x4(%eax),%edx
  8006e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	89 c1                	mov    %eax,%ecx
  8006f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800704:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800708:	79 74                	jns    80077e <vprintfmt+0x356>
				putch('-', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 2d                	push   $0x2d
  800710:	ff d6                	call   *%esi
				num = -(long long) num;
  800712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800715:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800718:	f7 d8                	neg    %eax
  80071a:	83 d2 00             	adc    $0x0,%edx
  80071d:	f7 da                	neg    %edx
  80071f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800727:	eb 55                	jmp    80077e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	e8 83 fc ff ff       	call   8003b4 <getuint>
			base = 10;
  800731:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800736:	eb 46                	jmp    80077e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	e8 74 fc ff ff       	call   8003b4 <getuint>
			base = 8;
  800740:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800745:	eb 37                	jmp    80077e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 30                	push   $0x30
  80074d:	ff d6                	call   *%esi
			putch('x', putdat);
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 78                	push   $0x78
  800755:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800760:	8b 00                	mov    (%eax),%eax
  800762:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800767:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80076f:	eb 0d                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 3b fc ff ff       	call   8003b4 <getuint>
			base = 16;
  800779:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077e:	83 ec 0c             	sub    $0xc,%esp
  800781:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800785:	57                   	push   %edi
  800786:	ff 75 e0             	pushl  -0x20(%ebp)
  800789:	51                   	push   %ecx
  80078a:	52                   	push   %edx
  80078b:	50                   	push   %eax
  80078c:	89 da                	mov    %ebx,%edx
  80078e:	89 f0                	mov    %esi,%eax
  800790:	e8 70 fb ff ff       	call   800305 <printnum>
			break;
  800795:	83 c4 20             	add    $0x20,%esp
  800798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079b:	e9 ae fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	51                   	push   %ecx
  8007a5:	ff d6                	call   *%esi
			break;
  8007a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ad:	e9 9c fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	6a 25                	push   $0x25
  8007b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb 03                	jmp    8007c2 <vprintfmt+0x39a>
  8007bf:	83 ef 01             	sub    $0x1,%edi
  8007c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c6:	75 f7                	jne    8007bf <vprintfmt+0x397>
  8007c8:	e9 81 fc ff ff       	jmp    80044e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5f                   	pop    %edi
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 18             	sub    $0x18,%esp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	74 26                	je     80081c <vsnprintf+0x47>
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	7e 22                	jle    80081c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fa:	ff 75 14             	pushl  0x14(%ebp)
  8007fd:	ff 75 10             	pushl  0x10(%ebp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	68 ee 03 80 00       	push   $0x8003ee
  800809:	e8 1a fc ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800811:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	eb 05                	jmp    800821 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082c:	50                   	push   %eax
  80082d:	ff 75 10             	pushl  0x10(%ebp)
  800830:	ff 75 0c             	pushl  0xc(%ebp)
  800833:	ff 75 08             	pushl  0x8(%ebp)
  800836:	e8 9a ff ff ff       	call   8007d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	eb 03                	jmp    80084d <strlen+0x10>
		n++;
  80084a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800851:	75 f7                	jne    80084a <strlen+0xd>
		n++;
	return n;
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
  800863:	eb 03                	jmp    800868 <strnlen+0x13>
		n++;
  800865:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 08                	je     800874 <strnlen+0x1f>
  80086c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800870:	75 f3                	jne    800865 <strnlen+0x10>
  800872:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800880:	89 c2                	mov    %eax,%edx
  800882:	83 c2 01             	add    $0x1,%edx
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089d:	53                   	push   %ebx
  80089e:	e8 9a ff ff ff       	call   80083d <strlen>
  8008a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	01 d8                	add    %ebx,%eax
  8008ab:	50                   	push   %eax
  8008ac:	e8 c5 ff ff ff       	call   800876 <strcpy>
	return dst;
}
  8008b1:	89 d8                	mov    %ebx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	89 f3                	mov    %esi,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	89 f2                	mov    %esi,%edx
  8008ca:	eb 0f                	jmp    8008db <strncpy+0x23>
		*dst++ = *src;
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	39 da                	cmp    %ebx,%edx
  8008dd:	75 ed                	jne    8008cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008df:	89 f0                	mov    %esi,%eax
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 21                	je     80091a <strlcpy+0x35>
  8008f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fd:	89 f2                	mov    %esi,%edx
  8008ff:	eb 09                	jmp    80090a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090a:	39 c2                	cmp    %eax,%edx
  80090c:	74 09                	je     800917 <strlcpy+0x32>
  80090e:	0f b6 19             	movzbl (%ecx),%ebx
  800911:	84 db                	test   %bl,%bl
  800913:	75 ec                	jne    800901 <strlcpy+0x1c>
  800915:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800917:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091a:	29 f0                	sub    %esi,%eax
}
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800929:	eb 06                	jmp    800931 <strcmp+0x11>
		p++, q++;
  80092b:	83 c1 01             	add    $0x1,%ecx
  80092e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800931:	0f b6 01             	movzbl (%ecx),%eax
  800934:	84 c0                	test   %al,%al
  800936:	74 04                	je     80093c <strcmp+0x1c>
  800938:	3a 02                	cmp    (%edx),%al
  80093a:	74 ef                	je     80092b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093c:	0f b6 c0             	movzbl %al,%eax
  80093f:	0f b6 12             	movzbl (%edx),%edx
  800942:	29 d0                	sub    %edx,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c3                	mov    %eax,%ebx
  800952:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800955:	eb 06                	jmp    80095d <strncmp+0x17>
		n--, p++, q++;
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095d:	39 d8                	cmp    %ebx,%eax
  80095f:	74 15                	je     800976 <strncmp+0x30>
  800961:	0f b6 08             	movzbl (%eax),%ecx
  800964:	84 c9                	test   %cl,%cl
  800966:	74 04                	je     80096c <strncmp+0x26>
  800968:	3a 0a                	cmp    (%edx),%cl
  80096a:	74 eb                	je     800957 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	0f b6 12             	movzbl (%edx),%edx
  800972:	29 d0                	sub    %edx,%eax
  800974:	eb 05                	jmp    80097b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800988:	eb 07                	jmp    800991 <strchr+0x13>
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 0f                	je     80099d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	84 d2                	test   %dl,%dl
  800996:	75 f2                	jne    80098a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a9:	eb 03                	jmp    8009ae <strfind+0xf>
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 04                	je     8009b9 <strfind+0x1a>
  8009b5:	84 d2                	test   %dl,%dl
  8009b7:	75 f2                	jne    8009ab <strfind+0xc>
			break;
	return (char *) s;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c7:	85 c9                	test   %ecx,%ecx
  8009c9:	74 36                	je     800a01 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d1:	75 28                	jne    8009fb <memset+0x40>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 23                	jne    8009fb <memset+0x40>
		c &= 0xFF;
  8009d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009dc:	89 d3                	mov    %edx,%ebx
  8009de:	c1 e3 08             	shl    $0x8,%ebx
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 18             	shl    $0x18,%esi
  8009e6:	89 d0                	mov    %edx,%eax
  8009e8:	c1 e0 10             	shl    $0x10,%eax
  8009eb:	09 f0                	or     %esi,%eax
  8009ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ef:	89 d8                	mov    %ebx,%eax
  8009f1:	09 d0                	or     %edx,%eax
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
  8009f6:	fc                   	cld    
  8009f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f9:	eb 06                	jmp    800a01 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	fc                   	cld    
  8009ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a16:	39 c6                	cmp    %eax,%esi
  800a18:	73 35                	jae    800a4f <memmove+0x47>
  800a1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 2e                	jae    800a4f <memmove+0x47>
		s += n;
		d += n;
  800a21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	09 fe                	or     %edi,%esi
  800a28:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2e:	75 13                	jne    800a43 <memmove+0x3b>
  800a30:	f6 c1 03             	test   $0x3,%cl
  800a33:	75 0e                	jne    800a43 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a35:	83 ef 04             	sub    $0x4,%edi
  800a38:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
  800a3e:	fd                   	std    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 09                	jmp    800a4c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a43:	83 ef 01             	sub    $0x1,%edi
  800a46:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a49:	fd                   	std    
  800a4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4c:	fc                   	cld    
  800a4d:	eb 1d                	jmp    800a6c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	89 f2                	mov    %esi,%edx
  800a51:	09 c2                	or     %eax,%edx
  800a53:	f6 c2 03             	test   $0x3,%dl
  800a56:	75 0f                	jne    800a67 <memmove+0x5f>
  800a58:	f6 c1 03             	test   $0x3,%cl
  800a5b:	75 0a                	jne    800a67 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
  800a60:	89 c7                	mov    %eax,%edi
  800a62:	fc                   	cld    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 05                	jmp    800a6c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	fc                   	cld    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 87 ff ff ff       	call   800a08 <memmove>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	eb 1a                	jmp    800aaf <memcmp+0x2c>
		if (*s1 != *s2)
  800a95:	0f b6 08             	movzbl (%eax),%ecx
  800a98:	0f b6 1a             	movzbl (%edx),%ebx
  800a9b:	38 d9                	cmp    %bl,%cl
  800a9d:	74 0a                	je     800aa9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a9f:	0f b6 c1             	movzbl %cl,%eax
  800aa2:	0f b6 db             	movzbl %bl,%ebx
  800aa5:	29 d8                	sub    %ebx,%eax
  800aa7:	eb 0f                	jmp    800ab8 <memcmp+0x35>
		s1++, s2++;
  800aa9:	83 c0 01             	add    $0x1,%eax
  800aac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaf:	39 f0                	cmp    %esi,%eax
  800ab1:	75 e2                	jne    800a95 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac3:	89 c1                	mov    %eax,%ecx
  800ac5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acc:	eb 0a                	jmp    800ad8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	0f b6 10             	movzbl (%eax),%edx
  800ad1:	39 da                	cmp    %ebx,%edx
  800ad3:	74 07                	je     800adc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	39 c8                	cmp    %ecx,%eax
  800ada:	72 f2                	jb     800ace <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aeb:	eb 03                	jmp    800af0 <strtol+0x11>
		s++;
  800aed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af0:	0f b6 01             	movzbl (%ecx),%eax
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 f6                	je     800aed <strtol+0xe>
  800af7:	3c 09                	cmp    $0x9,%al
  800af9:	74 f2                	je     800aed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afb:	3c 2b                	cmp    $0x2b,%al
  800afd:	75 0a                	jne    800b09 <strtol+0x2a>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
  800b07:	eb 11                	jmp    800b1a <strtol+0x3b>
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0e:	3c 2d                	cmp    $0x2d,%al
  800b10:	75 08                	jne    800b1a <strtol+0x3b>
		s++, neg = 1;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b20:	75 15                	jne    800b37 <strtol+0x58>
  800b22:	80 39 30             	cmpb   $0x30,(%ecx)
  800b25:	75 10                	jne    800b37 <strtol+0x58>
  800b27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2b:	75 7c                	jne    800ba9 <strtol+0xca>
		s += 2, base = 16;
  800b2d:	83 c1 02             	add    $0x2,%ecx
  800b30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b35:	eb 16                	jmp    800b4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b37:	85 db                	test   %ebx,%ebx
  800b39:	75 12                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 08                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 11             	movzbl (%ecx),%edx
  800b58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 09             	cmp    $0x9,%bl
  800b60:	77 08                	ja     800b6a <strtol+0x8b>
			dig = *s - '0';
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 30             	sub    $0x30,%edx
  800b68:	eb 22                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	80 fb 19             	cmp    $0x19,%bl
  800b72:	77 08                	ja     800b7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b74:	0f be d2             	movsbl %dl,%edx
  800b77:	83 ea 57             	sub    $0x57,%edx
  800b7a:	eb 10                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7f:	89 f3                	mov    %esi,%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 16                	ja     800b9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b86:	0f be d2             	movsbl %dl,%edx
  800b89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8f:	7d 0b                	jge    800b9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9a:	eb b9                	jmp    800b55 <strtol+0x76>

	if (endptr)
  800b9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba0:	74 0d                	je     800baf <strtol+0xd0>
		*endptr = (char *) s;
  800ba2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba5:	89 0e                	mov    %ecx,(%esi)
  800ba7:	eb 06                	jmp    800baf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba9:	85 db                	test   %ebx,%ebx
  800bab:	74 98                	je     800b45 <strtol+0x66>
  800bad:	eb 9e                	jmp    800b4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	f7 da                	neg    %edx
  800bb3:	85 ff                	test   %edi,%edi
  800bb5:	0f 45 c2             	cmovne %edx,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 c3                	mov    %eax,%ebx
  800bd0:	89 c7                	mov    %eax,%edi
  800bd2:	89 c6                	mov    %eax,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 01 00 00 00       	mov    $0x1,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c08:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 cb                	mov    %ecx,%ebx
  800c12:	89 cf                	mov    %ecx,%edi
  800c14:	89 ce                	mov    %ecx,%esi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 03                	push   $0x3
  800c22:	68 7f 2b 80 00       	push   $0x802b7f
  800c27:	6a 23                	push   $0x23
  800c29:	68 9c 2b 80 00       	push   $0x802b9c
  800c2e:	e8 e5 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4b:	89 d1                	mov    %edx,%ecx
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	89 d7                	mov    %edx,%edi
  800c51:	89 d6                	mov    %edx,%esi
  800c53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_yield>:

void
sys_yield(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c82:	be 00 00 00 00       	mov    $0x0,%esi
  800c87:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	89 f7                	mov    %esi,%edi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 04                	push   $0x4
  800ca3:	68 7f 2b 80 00       	push   $0x802b7f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 9c 2b 80 00       	push   $0x802b9c
  800caf:	e8 64 f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 05                	push   $0x5
  800ce5:	68 7f 2b 80 00       	push   $0x802b7f
  800cea:	6a 23                	push   $0x23
  800cec:	68 9c 2b 80 00       	push   $0x802b9c
  800cf1:	e8 22 f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 06                	push   $0x6
  800d27:	68 7f 2b 80 00       	push   $0x802b7f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 9c 2b 80 00       	push   $0x802b9c
  800d33:	e8 e0 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 08                	push   $0x8
  800d69:	68 7f 2b 80 00       	push   $0x802b7f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 9c 2b 80 00       	push   $0x802b9c
  800d75:	e8 9e f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d90:	b8 09 00 00 00       	mov    $0x9,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 df                	mov    %ebx,%edi
  800d9d:	89 de                	mov    %ebx,%esi
  800d9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 09                	push   $0x9
  800dab:	68 7f 2b 80 00       	push   $0x802b7f
  800db0:	6a 23                	push   $0x23
  800db2:	68 9c 2b 80 00       	push   $0x802b9c
  800db7:	e8 5c f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	89 de                	mov    %ebx,%esi
  800de1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 17                	jle    800dfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 0a                	push   $0xa
  800ded:	68 7f 2b 80 00       	push   $0x802b7f
  800df2:	6a 23                	push   $0x23
  800df4:	68 9c 2b 80 00       	push   $0x802b9c
  800df9:	e8 1a f4 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	be 00 00 00 00       	mov    $0x0,%esi
  800e11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 0d                	push   $0xd
  800e51:	68 7f 2b 80 00       	push   $0x802b7f
  800e56:	6a 23                	push   $0x23
  800e58:	68 9c 2b 80 00       	push   $0x802b9c
  800e5d:	e8 b6 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	ba 00 00 00 00       	mov    $0x0,%edx
  800e75:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e7a:	89 d1                	mov    %edx,%ecx
  800e7c:	89 d3                	mov    %edx,%ebx
  800e7e:	89 d7                	mov    %edx,%edi
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e97:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	89 df                	mov    %ebx,%edi
  800ea4:	89 de                	mov    %ebx,%esi
  800ea6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	7e 17                	jle    800ec3 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eac:	83 ec 0c             	sub    $0xc,%esp
  800eaf:	50                   	push   %eax
  800eb0:	6a 0f                	push   $0xf
  800eb2:	68 7f 2b 80 00       	push   $0x802b7f
  800eb7:	6a 23                	push   $0x23
  800eb9:	68 9c 2b 80 00       	push   $0x802b9c
  800ebe:	e8 55 f3 ff ff       	call   800218 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ed3:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800ed5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ed9:	75 25                	jne    800f00 <pgfault+0x35>
  800edb:	89 d8                	mov    %ebx,%eax
  800edd:	c1 e8 0c             	shr    $0xc,%eax
  800ee0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee7:	f6 c4 08             	test   $0x8,%ah
  800eea:	75 14                	jne    800f00 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	68 ac 2b 80 00       	push   $0x802bac
  800ef4:	6a 1e                	push   $0x1e
  800ef6:	68 40 2c 80 00       	push   $0x802c40
  800efb:	e8 18 f3 ff ff       	call   800218 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f00:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f06:	e8 30 fd ff ff       	call   800c3b <sys_getenvid>
  800f0b:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	6a 07                	push   $0x7
  800f12:	68 00 f0 7f 00       	push   $0x7ff000
  800f17:	50                   	push   %eax
  800f18:	e8 5c fd ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	79 12                	jns    800f36 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f24:	50                   	push   %eax
  800f25:	68 d8 2b 80 00       	push   $0x802bd8
  800f2a:	6a 33                	push   $0x33
  800f2c:	68 40 2c 80 00       	push   $0x802c40
  800f31:	e8 e2 f2 ff ff       	call   800218 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f36:	83 ec 04             	sub    $0x4,%esp
  800f39:	68 00 10 00 00       	push   $0x1000
  800f3e:	53                   	push   %ebx
  800f3f:	68 00 f0 7f 00       	push   $0x7ff000
  800f44:	e8 27 fb ff ff       	call   800a70 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f49:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f50:	53                   	push   %ebx
  800f51:	56                   	push   %esi
  800f52:	68 00 f0 7f 00       	push   $0x7ff000
  800f57:	56                   	push   %esi
  800f58:	e8 5f fd ff ff       	call   800cbc <sys_page_map>
	if (r < 0)
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	79 12                	jns    800f76 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f64:	50                   	push   %eax
  800f65:	68 fc 2b 80 00       	push   $0x802bfc
  800f6a:	6a 3b                	push   $0x3b
  800f6c:	68 40 2c 80 00       	push   $0x802c40
  800f71:	e8 a2 f2 ff ff       	call   800218 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f76:	83 ec 08             	sub    $0x8,%esp
  800f79:	68 00 f0 7f 00       	push   $0x7ff000
  800f7e:	56                   	push   %esi
  800f7f:	e8 7a fd ff ff       	call   800cfe <sys_page_unmap>
	if (r < 0)
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	79 12                	jns    800f9d <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f8b:	50                   	push   %eax
  800f8c:	68 20 2c 80 00       	push   $0x802c20
  800f91:	6a 40                	push   $0x40
  800f93:	68 40 2c 80 00       	push   $0x802c40
  800f98:	e8 7b f2 ff ff       	call   800218 <_panic>
}
  800f9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800fad:	68 cb 0e 80 00       	push   $0x800ecb
  800fb2:	e8 37 13 00 00       	call   8022ee <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbc:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	0f 88 64 01 00 00    	js     80112d <fork+0x189>
  800fc9:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800fce:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	75 21                	jne    800ff8 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd7:	e8 5f fc ff ff       	call   800c3b <sys_getenvid>
  800fdc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe9:	a3 20 44 80 00       	mov    %eax,0x804420
        return 0;
  800fee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff3:	e9 3f 01 00 00       	jmp    801137 <fork+0x193>
  800ff8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ffb:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800ffd:	89 d8                	mov    %ebx,%eax
  800fff:	c1 e8 16             	shr    $0x16,%eax
  801002:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801009:	a8 01                	test   $0x1,%al
  80100b:	0f 84 bd 00 00 00    	je     8010ce <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801011:	89 d8                	mov    %ebx,%eax
  801013:	c1 e8 0c             	shr    $0xc,%eax
  801016:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101d:	f6 c2 01             	test   $0x1,%dl
  801020:	0f 84 a8 00 00 00    	je     8010ce <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801026:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102d:	a8 04                	test   $0x4,%al
  80102f:	0f 84 99 00 00 00    	je     8010ce <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801035:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103c:	f6 c4 04             	test   $0x4,%ah
  80103f:	74 17                	je     801058 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	68 07 0e 00 00       	push   $0xe07
  801049:	53                   	push   %ebx
  80104a:	57                   	push   %edi
  80104b:	53                   	push   %ebx
  80104c:	6a 00                	push   $0x0
  80104e:	e8 69 fc ff ff       	call   800cbc <sys_page_map>
  801053:	83 c4 20             	add    $0x20,%esp
  801056:	eb 76                	jmp    8010ce <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801058:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80105f:	a8 02                	test   $0x2,%al
  801061:	75 0c                	jne    80106f <fork+0xcb>
  801063:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80106a:	f6 c4 08             	test   $0x8,%ah
  80106d:	74 3f                	je     8010ae <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	68 05 08 00 00       	push   $0x805
  801077:	53                   	push   %ebx
  801078:	57                   	push   %edi
  801079:	53                   	push   %ebx
  80107a:	6a 00                	push   $0x0
  80107c:	e8 3b fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0)
  801081:	83 c4 20             	add    $0x20,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	0f 88 a5 00 00 00    	js     801131 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	68 05 08 00 00       	push   $0x805
  801094:	53                   	push   %ebx
  801095:	6a 00                	push   $0x0
  801097:	53                   	push   %ebx
  801098:	6a 00                	push   $0x0
  80109a:	e8 1d fc ff ff       	call   800cbc <sys_page_map>
  80109f:	83 c4 20             	add    $0x20,%esp
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010a9:	0f 4f c1             	cmovg  %ecx,%eax
  8010ac:	eb 1c                	jmp    8010ca <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	6a 05                	push   $0x5
  8010b3:	53                   	push   %ebx
  8010b4:	57                   	push   %edi
  8010b5:	53                   	push   %ebx
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 ff fb ff ff       	call   800cbc <sys_page_map>
  8010bd:	83 c4 20             	add    $0x20,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c7:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	78 67                	js     801135 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8010ce:	83 c6 01             	add    $0x1,%esi
  8010d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d7:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010dd:	0f 85 1a ff ff ff    	jne    800ffd <fork+0x59>
  8010e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	6a 07                	push   $0x7
  8010eb:	68 00 f0 bf ee       	push   $0xeebff000
  8010f0:	57                   	push   %edi
  8010f1:	e8 83 fb ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  8010f6:	83 c4 10             	add    $0x10,%esp
		return r;
  8010f9:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 38                	js     801137 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010ff:	83 ec 08             	sub    $0x8,%esp
  801102:	68 35 23 80 00       	push   $0x802335
  801107:	57                   	push   %edi
  801108:	e8 b7 fc ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80110d:	83 c4 10             	add    $0x10,%esp
		return r;
  801110:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	78 21                	js     801137 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801116:	83 ec 08             	sub    $0x8,%esp
  801119:	6a 02                	push   $0x2
  80111b:	57                   	push   %edi
  80111c:	e8 1f fc ff ff       	call   800d40 <sys_env_set_status>
	if (r < 0)
  801121:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801124:	85 c0                	test   %eax,%eax
  801126:	0f 48 f8             	cmovs  %eax,%edi
  801129:	89 fa                	mov    %edi,%edx
  80112b:	eb 0a                	jmp    801137 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	eb 06                	jmp    801137 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801131:	89 c2                	mov    %eax,%edx
  801133:	eb 02                	jmp    801137 <fork+0x193>
  801135:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801137:	89 d0                	mov    %edx,%eax
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <sfork>:

// Challenge!
int
sfork(void)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801147:	68 4b 2c 80 00       	push   $0x802c4b
  80114c:	68 c9 00 00 00       	push   $0xc9
  801151:	68 40 2c 80 00       	push   $0x802c40
  801156:	e8 bd f0 ff ff       	call   800218 <_panic>

0080115b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115e:	8b 45 08             	mov    0x8(%ebp),%eax
  801161:	05 00 00 00 30       	add    $0x30000000,%eax
  801166:	c1 e8 0c             	shr    $0xc,%eax
}
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80116e:	8b 45 08             	mov    0x8(%ebp),%eax
  801171:	05 00 00 00 30       	add    $0x30000000,%eax
  801176:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80117b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    

00801182 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801188:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	c1 ea 16             	shr    $0x16,%edx
  801192:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801199:	f6 c2 01             	test   $0x1,%dl
  80119c:	74 11                	je     8011af <fd_alloc+0x2d>
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	c1 ea 0c             	shr    $0xc,%edx
  8011a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011aa:	f6 c2 01             	test   $0x1,%dl
  8011ad:	75 09                	jne    8011b8 <fd_alloc+0x36>
			*fd_store = fd;
  8011af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	eb 17                	jmp    8011cf <fd_alloc+0x4d>
  8011b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c2:	75 c9                	jne    80118d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d7:	83 f8 1f             	cmp    $0x1f,%eax
  8011da:	77 36                	ja     801212 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011dc:	c1 e0 0c             	shl    $0xc,%eax
  8011df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	c1 ea 16             	shr    $0x16,%edx
  8011e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f0:	f6 c2 01             	test   $0x1,%dl
  8011f3:	74 24                	je     801219 <fd_lookup+0x48>
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	c1 ea 0c             	shr    $0xc,%edx
  8011fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801201:	f6 c2 01             	test   $0x1,%dl
  801204:	74 1a                	je     801220 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801206:	8b 55 0c             	mov    0xc(%ebp),%edx
  801209:	89 02                	mov    %eax,(%edx)
	return 0;
  80120b:	b8 00 00 00 00       	mov    $0x0,%eax
  801210:	eb 13                	jmp    801225 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801212:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801217:	eb 0c                	jmp    801225 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801219:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121e:	eb 05                	jmp    801225 <fd_lookup+0x54>
  801220:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801230:	ba e4 2c 80 00       	mov    $0x802ce4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801235:	eb 13                	jmp    80124a <dev_lookup+0x23>
  801237:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80123a:	39 08                	cmp    %ecx,(%eax)
  80123c:	75 0c                	jne    80124a <dev_lookup+0x23>
			*dev = devtab[i];
  80123e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801241:	89 01                	mov    %eax,(%ecx)
			return 0;
  801243:	b8 00 00 00 00       	mov    $0x0,%eax
  801248:	eb 2e                	jmp    801278 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80124a:	8b 02                	mov    (%edx),%eax
  80124c:	85 c0                	test   %eax,%eax
  80124e:	75 e7                	jne    801237 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801250:	a1 20 44 80 00       	mov    0x804420,%eax
  801255:	8b 40 48             	mov    0x48(%eax),%eax
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	51                   	push   %ecx
  80125c:	50                   	push   %eax
  80125d:	68 64 2c 80 00       	push   $0x802c64
  801262:	e8 8a f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  801267:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 10             	sub    $0x10,%esp
  801282:	8b 75 08             	mov    0x8(%ebp),%esi
  801285:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801288:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801292:	c1 e8 0c             	shr    $0xc,%eax
  801295:	50                   	push   %eax
  801296:	e8 36 ff ff ff       	call   8011d1 <fd_lookup>
  80129b:	83 c4 08             	add    $0x8,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 05                	js     8012a7 <fd_close+0x2d>
	    || fd != fd2)
  8012a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012a5:	74 0c                	je     8012b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012a7:	84 db                	test   %bl,%bl
  8012a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ae:	0f 44 c2             	cmove  %edx,%eax
  8012b1:	eb 41                	jmp    8012f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b3:	83 ec 08             	sub    $0x8,%esp
  8012b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b9:	50                   	push   %eax
  8012ba:	ff 36                	pushl  (%esi)
  8012bc:	e8 66 ff ff ff       	call   801227 <dev_lookup>
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 1a                	js     8012e4 <fd_close+0x6a>
		if (dev->dev_close)
  8012ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	74 0b                	je     8012e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	56                   	push   %esi
  8012dd:	ff d0                	call   *%eax
  8012df:	89 c3                	mov    %eax,%ebx
  8012e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	56                   	push   %esi
  8012e8:	6a 00                	push   $0x0
  8012ea:	e8 0f fa ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	89 d8                	mov    %ebx,%eax
}
  8012f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5d                   	pop    %ebp
  8012fa:	c3                   	ret    

008012fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	ff 75 08             	pushl  0x8(%ebp)
  801308:	e8 c4 fe ff ff       	call   8011d1 <fd_lookup>
  80130d:	83 c4 08             	add    $0x8,%esp
  801310:	85 c0                	test   %eax,%eax
  801312:	78 10                	js     801324 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	6a 01                	push   $0x1
  801319:	ff 75 f4             	pushl  -0xc(%ebp)
  80131c:	e8 59 ff ff ff       	call   80127a <fd_close>
  801321:	83 c4 10             	add    $0x10,%esp
}
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <close_all>:

void
close_all(void)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	53                   	push   %ebx
  80132a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80132d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801332:	83 ec 0c             	sub    $0xc,%esp
  801335:	53                   	push   %ebx
  801336:	e8 c0 ff ff ff       	call   8012fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80133b:	83 c3 01             	add    $0x1,%ebx
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	83 fb 20             	cmp    $0x20,%ebx
  801344:	75 ec                	jne    801332 <close_all+0xc>
		close(i);
}
  801346:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	57                   	push   %edi
  80134f:	56                   	push   %esi
  801350:	53                   	push   %ebx
  801351:	83 ec 2c             	sub    $0x2c,%esp
  801354:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801357:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	ff 75 08             	pushl  0x8(%ebp)
  80135e:	e8 6e fe ff ff       	call   8011d1 <fd_lookup>
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	0f 88 c1 00 00 00    	js     80142f <dup+0xe4>
		return r;
	close(newfdnum);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	56                   	push   %esi
  801372:	e8 84 ff ff ff       	call   8012fb <close>

	newfd = INDEX2FD(newfdnum);
  801377:	89 f3                	mov    %esi,%ebx
  801379:	c1 e3 0c             	shl    $0xc,%ebx
  80137c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801382:	83 c4 04             	add    $0x4,%esp
  801385:	ff 75 e4             	pushl  -0x1c(%ebp)
  801388:	e8 de fd ff ff       	call   80116b <fd2data>
  80138d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80138f:	89 1c 24             	mov    %ebx,(%esp)
  801392:	e8 d4 fd ff ff       	call   80116b <fd2data>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80139d:	89 f8                	mov    %edi,%eax
  80139f:	c1 e8 16             	shr    $0x16,%eax
  8013a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a9:	a8 01                	test   $0x1,%al
  8013ab:	74 37                	je     8013e4 <dup+0x99>
  8013ad:	89 f8                	mov    %edi,%eax
  8013af:	c1 e8 0c             	shr    $0xc,%eax
  8013b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b9:	f6 c2 01             	test   $0x1,%dl
  8013bc:	74 26                	je     8013e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013cd:	50                   	push   %eax
  8013ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d1:	6a 00                	push   $0x0
  8013d3:	57                   	push   %edi
  8013d4:	6a 00                	push   $0x0
  8013d6:	e8 e1 f8 ff ff       	call   800cbc <sys_page_map>
  8013db:	89 c7                	mov    %eax,%edi
  8013dd:	83 c4 20             	add    $0x20,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 2e                	js     801412 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013e7:	89 d0                	mov    %edx,%eax
  8013e9:	c1 e8 0c             	shr    $0xc,%eax
  8013ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013fb:	50                   	push   %eax
  8013fc:	53                   	push   %ebx
  8013fd:	6a 00                	push   $0x0
  8013ff:	52                   	push   %edx
  801400:	6a 00                	push   $0x0
  801402:	e8 b5 f8 ff ff       	call   800cbc <sys_page_map>
  801407:	89 c7                	mov    %eax,%edi
  801409:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80140c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80140e:	85 ff                	test   %edi,%edi
  801410:	79 1d                	jns    80142f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	53                   	push   %ebx
  801416:	6a 00                	push   $0x0
  801418:	e8 e1 f8 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80141d:	83 c4 08             	add    $0x8,%esp
  801420:	ff 75 d4             	pushl  -0x2c(%ebp)
  801423:	6a 00                	push   $0x0
  801425:	e8 d4 f8 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	89 f8                	mov    %edi,%eax
}
  80142f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801432:	5b                   	pop    %ebx
  801433:	5e                   	pop    %esi
  801434:	5f                   	pop    %edi
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    

00801437 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	53                   	push   %ebx
  80143b:	83 ec 14             	sub    $0x14,%esp
  80143e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801441:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	53                   	push   %ebx
  801446:	e8 86 fd ff ff       	call   8011d1 <fd_lookup>
  80144b:	83 c4 08             	add    $0x8,%esp
  80144e:	89 c2                	mov    %eax,%edx
  801450:	85 c0                	test   %eax,%eax
  801452:	78 6d                	js     8014c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145a:	50                   	push   %eax
  80145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145e:	ff 30                	pushl  (%eax)
  801460:	e8 c2 fd ff ff       	call   801227 <dev_lookup>
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 4c                	js     8014b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80146c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80146f:	8b 42 08             	mov    0x8(%edx),%eax
  801472:	83 e0 03             	and    $0x3,%eax
  801475:	83 f8 01             	cmp    $0x1,%eax
  801478:	75 21                	jne    80149b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80147a:	a1 20 44 80 00       	mov    0x804420,%eax
  80147f:	8b 40 48             	mov    0x48(%eax),%eax
  801482:	83 ec 04             	sub    $0x4,%esp
  801485:	53                   	push   %ebx
  801486:	50                   	push   %eax
  801487:	68 a8 2c 80 00       	push   $0x802ca8
  80148c:	e8 60 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801499:	eb 26                	jmp    8014c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80149b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149e:	8b 40 08             	mov    0x8(%eax),%eax
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	74 17                	je     8014bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	ff 75 10             	pushl  0x10(%ebp)
  8014ab:	ff 75 0c             	pushl  0xc(%ebp)
  8014ae:	52                   	push   %edx
  8014af:	ff d0                	call   *%eax
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	eb 09                	jmp    8014c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b8:	89 c2                	mov    %eax,%edx
  8014ba:	eb 05                	jmp    8014c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014c1:	89 d0                	mov    %edx,%eax
  8014c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	57                   	push   %edi
  8014cc:	56                   	push   %esi
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 0c             	sub    $0xc,%esp
  8014d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014dc:	eb 21                	jmp    8014ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014de:	83 ec 04             	sub    $0x4,%esp
  8014e1:	89 f0                	mov    %esi,%eax
  8014e3:	29 d8                	sub    %ebx,%eax
  8014e5:	50                   	push   %eax
  8014e6:	89 d8                	mov    %ebx,%eax
  8014e8:	03 45 0c             	add    0xc(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	57                   	push   %edi
  8014ed:	e8 45 ff ff ff       	call   801437 <read>
		if (m < 0)
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 10                	js     801509 <readn+0x41>
			return m;
		if (m == 0)
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	74 0a                	je     801507 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014fd:	01 c3                	add    %eax,%ebx
  8014ff:	39 f3                	cmp    %esi,%ebx
  801501:	72 db                	jb     8014de <readn+0x16>
  801503:	89 d8                	mov    %ebx,%eax
  801505:	eb 02                	jmp    801509 <readn+0x41>
  801507:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801509:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150c:	5b                   	pop    %ebx
  80150d:	5e                   	pop    %esi
  80150e:	5f                   	pop    %edi
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	53                   	push   %ebx
  801515:	83 ec 14             	sub    $0x14,%esp
  801518:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	53                   	push   %ebx
  801520:	e8 ac fc ff ff       	call   8011d1 <fd_lookup>
  801525:	83 c4 08             	add    $0x8,%esp
  801528:	89 c2                	mov    %eax,%edx
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 68                	js     801596 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152e:	83 ec 08             	sub    $0x8,%esp
  801531:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801538:	ff 30                	pushl  (%eax)
  80153a:	e8 e8 fc ff ff       	call   801227 <dev_lookup>
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 47                	js     80158d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801546:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801549:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154d:	75 21                	jne    801570 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80154f:	a1 20 44 80 00       	mov    0x804420,%eax
  801554:	8b 40 48             	mov    0x48(%eax),%eax
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	53                   	push   %ebx
  80155b:	50                   	push   %eax
  80155c:	68 c4 2c 80 00       	push   $0x802cc4
  801561:	e8 8b ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156e:	eb 26                	jmp    801596 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801570:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801573:	8b 52 0c             	mov    0xc(%edx),%edx
  801576:	85 d2                	test   %edx,%edx
  801578:	74 17                	je     801591 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80157a:	83 ec 04             	sub    $0x4,%esp
  80157d:	ff 75 10             	pushl  0x10(%ebp)
  801580:	ff 75 0c             	pushl  0xc(%ebp)
  801583:	50                   	push   %eax
  801584:	ff d2                	call   *%edx
  801586:	89 c2                	mov    %eax,%edx
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	eb 09                	jmp    801596 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	eb 05                	jmp    801596 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801591:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801596:	89 d0                	mov    %edx,%eax
  801598:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159b:	c9                   	leave  
  80159c:	c3                   	ret    

0080159d <seek>:

int
seek(int fdnum, off_t offset)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	ff 75 08             	pushl  0x8(%ebp)
  8015aa:	e8 22 fc ff ff       	call   8011d1 <fd_lookup>
  8015af:	83 c4 08             	add    $0x8,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 0e                	js     8015c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 14             	sub    $0x14,%esp
  8015cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	53                   	push   %ebx
  8015d5:	e8 f7 fb ff ff       	call   8011d1 <fd_lookup>
  8015da:	83 c4 08             	add    $0x8,%esp
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 65                	js     801648 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ed:	ff 30                	pushl  (%eax)
  8015ef:	e8 33 fc ff ff       	call   801227 <dev_lookup>
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 44                	js     80163f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801602:	75 21                	jne    801625 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801604:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801609:	8b 40 48             	mov    0x48(%eax),%eax
  80160c:	83 ec 04             	sub    $0x4,%esp
  80160f:	53                   	push   %ebx
  801610:	50                   	push   %eax
  801611:	68 84 2c 80 00       	push   $0x802c84
  801616:	e8 d6 ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801623:	eb 23                	jmp    801648 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801625:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801628:	8b 52 18             	mov    0x18(%edx),%edx
  80162b:	85 d2                	test   %edx,%edx
  80162d:	74 14                	je     801643 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	ff 75 0c             	pushl  0xc(%ebp)
  801635:	50                   	push   %eax
  801636:	ff d2                	call   *%edx
  801638:	89 c2                	mov    %eax,%edx
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	eb 09                	jmp    801648 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163f:	89 c2                	mov    %eax,%edx
  801641:	eb 05                	jmp    801648 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801643:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801648:	89 d0                	mov    %edx,%eax
  80164a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	53                   	push   %ebx
  801653:	83 ec 14             	sub    $0x14,%esp
  801656:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801659:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	ff 75 08             	pushl  0x8(%ebp)
  801660:	e8 6c fb ff ff       	call   8011d1 <fd_lookup>
  801665:	83 c4 08             	add    $0x8,%esp
  801668:	89 c2                	mov    %eax,%edx
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 58                	js     8016c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801678:	ff 30                	pushl  (%eax)
  80167a:	e8 a8 fb ff ff       	call   801227 <dev_lookup>
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	85 c0                	test   %eax,%eax
  801684:	78 37                	js     8016bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801689:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80168d:	74 32                	je     8016c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80168f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801692:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801699:	00 00 00 
	stat->st_isdir = 0;
  80169c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a3:	00 00 00 
	stat->st_dev = dev;
  8016a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	53                   	push   %ebx
  8016b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8016b3:	ff 50 14             	call   *0x14(%eax)
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb 09                	jmp    8016c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	eb 05                	jmp    8016c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016c6:	89 d0                	mov    %edx,%eax
  8016c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    

008016cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	56                   	push   %esi
  8016d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	6a 00                	push   $0x0
  8016d7:	ff 75 08             	pushl  0x8(%ebp)
  8016da:	e8 d6 01 00 00       	call   8018b5 <open>
  8016df:	89 c3                	mov    %eax,%ebx
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 1b                	js     801703 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ee:	50                   	push   %eax
  8016ef:	e8 5b ff ff ff       	call   80164f <fstat>
  8016f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f6:	89 1c 24             	mov    %ebx,(%esp)
  8016f9:	e8 fd fb ff ff       	call   8012fb <close>
	return r;
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	89 f0                	mov    %esi,%eax
}
  801703:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801706:	5b                   	pop    %ebx
  801707:	5e                   	pop    %esi
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
  80170f:	89 c6                	mov    %eax,%esi
  801711:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801713:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80171a:	75 12                	jne    80172e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80171c:	83 ec 0c             	sub    $0xc,%esp
  80171f:	6a 01                	push   $0x1
  801721:	e8 ee 0c 00 00       	call   802414 <ipc_find_env>
  801726:	a3 00 40 80 00       	mov    %eax,0x804000
  80172b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80172e:	6a 07                	push   $0x7
  801730:	68 00 50 80 00       	push   $0x805000
  801735:	56                   	push   %esi
  801736:	ff 35 00 40 80 00    	pushl  0x804000
  80173c:	e8 7f 0c 00 00       	call   8023c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801741:	83 c4 0c             	add    $0xc,%esp
  801744:	6a 00                	push   $0x0
  801746:	53                   	push   %ebx
  801747:	6a 00                	push   $0x0
  801749:	e8 0b 0c 00 00       	call   802359 <ipc_recv>
}
  80174e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801751:	5b                   	pop    %ebx
  801752:	5e                   	pop    %esi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	8b 40 0c             	mov    0xc(%eax),%eax
  801761:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801766:	8b 45 0c             	mov    0xc(%ebp),%eax
  801769:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80176e:	ba 00 00 00 00       	mov    $0x0,%edx
  801773:	b8 02 00 00 00       	mov    $0x2,%eax
  801778:	e8 8d ff ff ff       	call   80170a <fsipc>
}
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801790:	ba 00 00 00 00       	mov    $0x0,%edx
  801795:	b8 06 00 00 00       	mov    $0x6,%eax
  80179a:	e8 6b ff ff ff       	call   80170a <fsipc>
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	53                   	push   %ebx
  8017a5:	83 ec 04             	sub    $0x4,%esp
  8017a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c0:	e8 45 ff ff ff       	call   80170a <fsipc>
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 2c                	js     8017f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	68 00 50 80 00       	push   $0x805000
  8017d1:	53                   	push   %ebx
  8017d2:	e8 9f f0 ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8017dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8017e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801803:	8b 55 08             	mov    0x8(%ebp),%edx
  801806:	8b 52 0c             	mov    0xc(%edx),%edx
  801809:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80180f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801814:	50                   	push   %eax
  801815:	ff 75 0c             	pushl  0xc(%ebp)
  801818:	68 08 50 80 00       	push   $0x805008
  80181d:	e8 e6 f1 ff ff       	call   800a08 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801822:	ba 00 00 00 00       	mov    $0x0,%edx
  801827:	b8 04 00 00 00       	mov    $0x4,%eax
  80182c:	e8 d9 fe ff ff       	call   80170a <fsipc>

}
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
  801838:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	8b 40 0c             	mov    0xc(%eax),%eax
  801841:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801846:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80184c:	ba 00 00 00 00       	mov    $0x0,%edx
  801851:	b8 03 00 00 00       	mov    $0x3,%eax
  801856:	e8 af fe ff ff       	call   80170a <fsipc>
  80185b:	89 c3                	mov    %eax,%ebx
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 4b                	js     8018ac <devfile_read+0x79>
		return r;
	assert(r <= n);
  801861:	39 c6                	cmp    %eax,%esi
  801863:	73 16                	jae    80187b <devfile_read+0x48>
  801865:	68 f8 2c 80 00       	push   $0x802cf8
  80186a:	68 ff 2c 80 00       	push   $0x802cff
  80186f:	6a 7c                	push   $0x7c
  801871:	68 14 2d 80 00       	push   $0x802d14
  801876:	e8 9d e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  80187b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801880:	7e 16                	jle    801898 <devfile_read+0x65>
  801882:	68 1f 2d 80 00       	push   $0x802d1f
  801887:	68 ff 2c 80 00       	push   $0x802cff
  80188c:	6a 7d                	push   $0x7d
  80188e:	68 14 2d 80 00       	push   $0x802d14
  801893:	e8 80 e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801898:	83 ec 04             	sub    $0x4,%esp
  80189b:	50                   	push   %eax
  80189c:	68 00 50 80 00       	push   $0x805000
  8018a1:	ff 75 0c             	pushl  0xc(%ebp)
  8018a4:	e8 5f f1 ff ff       	call   800a08 <memmove>
	return r;
  8018a9:	83 c4 10             	add    $0x10,%esp
}
  8018ac:	89 d8                	mov    %ebx,%eax
  8018ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 20             	sub    $0x20,%esp
  8018bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018bf:	53                   	push   %ebx
  8018c0:	e8 78 ef ff ff       	call   80083d <strlen>
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018cd:	7f 67                	jg     801936 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018cf:	83 ec 0c             	sub    $0xc,%esp
  8018d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d5:	50                   	push   %eax
  8018d6:	e8 a7 f8 ff ff       	call   801182 <fd_alloc>
  8018db:	83 c4 10             	add    $0x10,%esp
		return r;
  8018de:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 57                	js     80193b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	53                   	push   %ebx
  8018e8:	68 00 50 80 00       	push   $0x805000
  8018ed:	e8 84 ef ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801902:	e8 03 fe ff ff       	call   80170a <fsipc>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	79 14                	jns    801924 <open+0x6f>
		fd_close(fd, 0);
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	6a 00                	push   $0x0
  801915:	ff 75 f4             	pushl  -0xc(%ebp)
  801918:	e8 5d f9 ff ff       	call   80127a <fd_close>
		return r;
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	89 da                	mov    %ebx,%edx
  801922:	eb 17                	jmp    80193b <open+0x86>
	}

	return fd2num(fd);
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	ff 75 f4             	pushl  -0xc(%ebp)
  80192a:	e8 2c f8 ff ff       	call   80115b <fd2num>
  80192f:	89 c2                	mov    %eax,%edx
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	eb 05                	jmp    80193b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801936:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80193b:	89 d0                	mov    %edx,%eax
  80193d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801948:	ba 00 00 00 00       	mov    $0x0,%edx
  80194d:	b8 08 00 00 00       	mov    $0x8,%eax
  801952:	e8 b3 fd ff ff       	call   80170a <fsipc>
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80195f:	68 2b 2d 80 00       	push   $0x802d2b
  801964:	ff 75 0c             	pushl  0xc(%ebp)
  801967:	e8 0a ef ff ff       	call   800876 <strcpy>
	return 0;
}
  80196c:	b8 00 00 00 00       	mov    $0x0,%eax
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	53                   	push   %ebx
  801977:	83 ec 10             	sub    $0x10,%esp
  80197a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80197d:	53                   	push   %ebx
  80197e:	e8 ca 0a 00 00       	call   80244d <pageref>
  801983:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801986:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80198b:	83 f8 01             	cmp    $0x1,%eax
  80198e:	75 10                	jne    8019a0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801990:	83 ec 0c             	sub    $0xc,%esp
  801993:	ff 73 0c             	pushl  0xc(%ebx)
  801996:	e8 c0 02 00 00       	call   801c5b <nsipc_close>
  80199b:	89 c2                	mov    %eax,%edx
  80199d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019a0:	89 d0                	mov    %edx,%eax
  8019a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019ad:	6a 00                	push   $0x0
  8019af:	ff 75 10             	pushl  0x10(%ebp)
  8019b2:	ff 75 0c             	pushl  0xc(%ebp)
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	ff 70 0c             	pushl  0xc(%eax)
  8019bb:	e8 78 03 00 00       	call   801d38 <nsipc_send>
}
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019c8:	6a 00                	push   $0x0
  8019ca:	ff 75 10             	pushl  0x10(%ebp)
  8019cd:	ff 75 0c             	pushl  0xc(%ebp)
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d3:	ff 70 0c             	pushl  0xc(%eax)
  8019d6:	e8 f1 02 00 00       	call   801ccc <nsipc_recv>
}
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019e3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019e6:	52                   	push   %edx
  8019e7:	50                   	push   %eax
  8019e8:	e8 e4 f7 ff ff       	call   8011d1 <fd_lookup>
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 17                	js     801a0b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f7:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019fd:	39 08                	cmp    %ecx,(%eax)
  8019ff:	75 05                	jne    801a06 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a01:	8b 40 0c             	mov    0xc(%eax),%eax
  801a04:	eb 05                	jmp    801a0b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a06:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	83 ec 1c             	sub    $0x1c,%esp
  801a15:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1a:	50                   	push   %eax
  801a1b:	e8 62 f7 ff ff       	call   801182 <fd_alloc>
  801a20:	89 c3                	mov    %eax,%ebx
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 1b                	js     801a44 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a29:	83 ec 04             	sub    $0x4,%esp
  801a2c:	68 07 04 00 00       	push   $0x407
  801a31:	ff 75 f4             	pushl  -0xc(%ebp)
  801a34:	6a 00                	push   $0x0
  801a36:	e8 3e f2 ff ff       	call   800c79 <sys_page_alloc>
  801a3b:	89 c3                	mov    %eax,%ebx
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	85 c0                	test   %eax,%eax
  801a42:	79 10                	jns    801a54 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	56                   	push   %esi
  801a48:	e8 0e 02 00 00       	call   801c5b <nsipc_close>
		return r;
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	89 d8                	mov    %ebx,%eax
  801a52:	eb 24                	jmp    801a78 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a54:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a62:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a69:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	50                   	push   %eax
  801a70:	e8 e6 f6 ff ff       	call   80115b <fd2num>
  801a75:	83 c4 10             	add    $0x10,%esp
}
  801a78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    

00801a7f <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a85:	8b 45 08             	mov    0x8(%ebp),%eax
  801a88:	e8 50 ff ff ff       	call   8019dd <fd2sockid>
		return r;
  801a8d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 1f                	js     801ab2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a93:	83 ec 04             	sub    $0x4,%esp
  801a96:	ff 75 10             	pushl  0x10(%ebp)
  801a99:	ff 75 0c             	pushl  0xc(%ebp)
  801a9c:	50                   	push   %eax
  801a9d:	e8 12 01 00 00       	call   801bb4 <nsipc_accept>
  801aa2:	83 c4 10             	add    $0x10,%esp
		return r;
  801aa5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 07                	js     801ab2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801aab:	e8 5d ff ff ff       	call   801a0d <alloc_sockfd>
  801ab0:	89 c1                	mov    %eax,%ecx
}
  801ab2:	89 c8                	mov    %ecx,%eax
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	e8 19 ff ff ff       	call   8019dd <fd2sockid>
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	78 12                	js     801ada <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ac8:	83 ec 04             	sub    $0x4,%esp
  801acb:	ff 75 10             	pushl  0x10(%ebp)
  801ace:	ff 75 0c             	pushl  0xc(%ebp)
  801ad1:	50                   	push   %eax
  801ad2:	e8 2d 01 00 00       	call   801c04 <nsipc_bind>
  801ad7:	83 c4 10             	add    $0x10,%esp
}
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <shutdown>:

int
shutdown(int s, int how)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae5:	e8 f3 fe ff ff       	call   8019dd <fd2sockid>
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 0f                	js     801afd <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	ff 75 0c             	pushl  0xc(%ebp)
  801af4:	50                   	push   %eax
  801af5:	e8 3f 01 00 00       	call   801c39 <nsipc_shutdown>
  801afa:	83 c4 10             	add    $0x10,%esp
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b05:	8b 45 08             	mov    0x8(%ebp),%eax
  801b08:	e8 d0 fe ff ff       	call   8019dd <fd2sockid>
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 12                	js     801b23 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b11:	83 ec 04             	sub    $0x4,%esp
  801b14:	ff 75 10             	pushl  0x10(%ebp)
  801b17:	ff 75 0c             	pushl  0xc(%ebp)
  801b1a:	50                   	push   %eax
  801b1b:	e8 55 01 00 00       	call   801c75 <nsipc_connect>
  801b20:	83 c4 10             	add    $0x10,%esp
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <listen>:

int
listen(int s, int backlog)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	e8 aa fe ff ff       	call   8019dd <fd2sockid>
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 0f                	js     801b46 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b37:	83 ec 08             	sub    $0x8,%esp
  801b3a:	ff 75 0c             	pushl  0xc(%ebp)
  801b3d:	50                   	push   %eax
  801b3e:	e8 67 01 00 00       	call   801caa <nsipc_listen>
  801b43:	83 c4 10             	add    $0x10,%esp
}
  801b46:	c9                   	leave  
  801b47:	c3                   	ret    

00801b48 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b4e:	ff 75 10             	pushl  0x10(%ebp)
  801b51:	ff 75 0c             	pushl  0xc(%ebp)
  801b54:	ff 75 08             	pushl  0x8(%ebp)
  801b57:	e8 3a 02 00 00       	call   801d96 <nsipc_socket>
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 05                	js     801b68 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b63:	e8 a5 fe ff ff       	call   801a0d <alloc_sockfd>
}
  801b68:	c9                   	leave  
  801b69:	c3                   	ret    

00801b6a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	53                   	push   %ebx
  801b6e:	83 ec 04             	sub    $0x4,%esp
  801b71:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b73:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b7a:	75 12                	jne    801b8e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b7c:	83 ec 0c             	sub    $0xc,%esp
  801b7f:	6a 02                	push   $0x2
  801b81:	e8 8e 08 00 00       	call   802414 <ipc_find_env>
  801b86:	a3 04 40 80 00       	mov    %eax,0x804004
  801b8b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b8e:	6a 07                	push   $0x7
  801b90:	68 00 60 80 00       	push   $0x806000
  801b95:	53                   	push   %ebx
  801b96:	ff 35 04 40 80 00    	pushl  0x804004
  801b9c:	e8 1f 08 00 00       	call   8023c0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ba1:	83 c4 0c             	add    $0xc,%esp
  801ba4:	6a 00                	push   $0x0
  801ba6:	6a 00                	push   $0x0
  801ba8:	6a 00                	push   $0x0
  801baa:	e8 aa 07 00 00       	call   802359 <ipc_recv>
}
  801baf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bc4:	8b 06                	mov    (%esi),%eax
  801bc6:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bcb:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd0:	e8 95 ff ff ff       	call   801b6a <nsipc>
  801bd5:	89 c3                	mov    %eax,%ebx
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	78 20                	js     801bfb <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bdb:	83 ec 04             	sub    $0x4,%esp
  801bde:	ff 35 10 60 80 00    	pushl  0x806010
  801be4:	68 00 60 80 00       	push   $0x806000
  801be9:	ff 75 0c             	pushl  0xc(%ebp)
  801bec:	e8 17 ee ff ff       	call   800a08 <memmove>
		*addrlen = ret->ret_addrlen;
  801bf1:	a1 10 60 80 00       	mov    0x806010,%eax
  801bf6:	89 06                	mov    %eax,(%esi)
  801bf8:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bfb:	89 d8                	mov    %ebx,%eax
  801bfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	53                   	push   %ebx
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c11:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c16:	53                   	push   %ebx
  801c17:	ff 75 0c             	pushl  0xc(%ebp)
  801c1a:	68 04 60 80 00       	push   $0x806004
  801c1f:	e8 e4 ed ff ff       	call   800a08 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c24:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c2a:	b8 02 00 00 00       	mov    $0x2,%eax
  801c2f:	e8 36 ff ff ff       	call   801b6a <nsipc>
}
  801c34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c37:	c9                   	leave  
  801c38:	c3                   	ret    

00801c39 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c42:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c4f:	b8 03 00 00 00       	mov    $0x3,%eax
  801c54:	e8 11 ff ff ff       	call   801b6a <nsipc>
}
  801c59:	c9                   	leave  
  801c5a:	c3                   	ret    

00801c5b <nsipc_close>:

int
nsipc_close(int s)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c61:	8b 45 08             	mov    0x8(%ebp),%eax
  801c64:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c69:	b8 04 00 00 00       	mov    $0x4,%eax
  801c6e:	e8 f7 fe ff ff       	call   801b6a <nsipc>
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	53                   	push   %ebx
  801c79:	83 ec 08             	sub    $0x8,%esp
  801c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c82:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c87:	53                   	push   %ebx
  801c88:	ff 75 0c             	pushl  0xc(%ebp)
  801c8b:	68 04 60 80 00       	push   $0x806004
  801c90:	e8 73 ed ff ff       	call   800a08 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c95:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c9b:	b8 05 00 00 00       	mov    $0x5,%eax
  801ca0:	e8 c5 fe ff ff       	call   801b6a <nsipc>
}
  801ca5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cc0:	b8 06 00 00 00       	mov    $0x6,%eax
  801cc5:	e8 a0 fe ff ff       	call   801b6a <nsipc>
}
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	56                   	push   %esi
  801cd0:	53                   	push   %ebx
  801cd1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cdc:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ce2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ce5:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cea:	b8 07 00 00 00       	mov    $0x7,%eax
  801cef:	e8 76 fe ff ff       	call   801b6a <nsipc>
  801cf4:	89 c3                	mov    %eax,%ebx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 35                	js     801d2f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801cfa:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cff:	7f 04                	jg     801d05 <nsipc_recv+0x39>
  801d01:	39 c6                	cmp    %eax,%esi
  801d03:	7d 16                	jge    801d1b <nsipc_recv+0x4f>
  801d05:	68 37 2d 80 00       	push   $0x802d37
  801d0a:	68 ff 2c 80 00       	push   $0x802cff
  801d0f:	6a 62                	push   $0x62
  801d11:	68 4c 2d 80 00       	push   $0x802d4c
  801d16:	e8 fd e4 ff ff       	call   800218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d1b:	83 ec 04             	sub    $0x4,%esp
  801d1e:	50                   	push   %eax
  801d1f:	68 00 60 80 00       	push   $0x806000
  801d24:	ff 75 0c             	pushl  0xc(%ebp)
  801d27:	e8 dc ec ff ff       	call   800a08 <memmove>
  801d2c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d2f:	89 d8                	mov    %ebx,%eax
  801d31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	53                   	push   %ebx
  801d3c:	83 ec 04             	sub    $0x4,%esp
  801d3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d42:	8b 45 08             	mov    0x8(%ebp),%eax
  801d45:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d4a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d50:	7e 16                	jle    801d68 <nsipc_send+0x30>
  801d52:	68 58 2d 80 00       	push   $0x802d58
  801d57:	68 ff 2c 80 00       	push   $0x802cff
  801d5c:	6a 6d                	push   $0x6d
  801d5e:	68 4c 2d 80 00       	push   $0x802d4c
  801d63:	e8 b0 e4 ff ff       	call   800218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d68:	83 ec 04             	sub    $0x4,%esp
  801d6b:	53                   	push   %ebx
  801d6c:	ff 75 0c             	pushl  0xc(%ebp)
  801d6f:	68 0c 60 80 00       	push   $0x80600c
  801d74:	e8 8f ec ff ff       	call   800a08 <memmove>
	nsipcbuf.send.req_size = size;
  801d79:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d7f:	8b 45 14             	mov    0x14(%ebp),%eax
  801d82:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d87:	b8 08 00 00 00       	mov    $0x8,%eax
  801d8c:	e8 d9 fd ff ff       	call   801b6a <nsipc>
}
  801d91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801da4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dac:	8b 45 10             	mov    0x10(%ebp),%eax
  801daf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801db4:	b8 09 00 00 00       	mov    $0x9,%eax
  801db9:	e8 ac fd ff ff       	call   801b6a <nsipc>
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	56                   	push   %esi
  801dc4:	53                   	push   %ebx
  801dc5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dc8:	83 ec 0c             	sub    $0xc,%esp
  801dcb:	ff 75 08             	pushl  0x8(%ebp)
  801dce:	e8 98 f3 ff ff       	call   80116b <fd2data>
  801dd3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801dd5:	83 c4 08             	add    $0x8,%esp
  801dd8:	68 64 2d 80 00       	push   $0x802d64
  801ddd:	53                   	push   %ebx
  801dde:	e8 93 ea ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801de3:	8b 46 04             	mov    0x4(%esi),%eax
  801de6:	2b 06                	sub    (%esi),%eax
  801de8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801df5:	00 00 00 
	stat->st_dev = &devpipe;
  801df8:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801dff:	30 80 00 
	return 0;
}
  801e02:	b8 00 00 00 00       	mov    $0x0,%eax
  801e07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0a:	5b                   	pop    %ebx
  801e0b:	5e                   	pop    %esi
  801e0c:	5d                   	pop    %ebp
  801e0d:	c3                   	ret    

00801e0e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	53                   	push   %ebx
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e18:	53                   	push   %ebx
  801e19:	6a 00                	push   $0x0
  801e1b:	e8 de ee ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e20:	89 1c 24             	mov    %ebx,(%esp)
  801e23:	e8 43 f3 ff ff       	call   80116b <fd2data>
  801e28:	83 c4 08             	add    $0x8,%esp
  801e2b:	50                   	push   %eax
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 cb ee ff ff       	call   800cfe <sys_page_unmap>
}
  801e33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	57                   	push   %edi
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	83 ec 1c             	sub    $0x1c,%esp
  801e41:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e44:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e46:	a1 20 44 80 00       	mov    0x804420,%eax
  801e4b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e4e:	83 ec 0c             	sub    $0xc,%esp
  801e51:	ff 75 e0             	pushl  -0x20(%ebp)
  801e54:	e8 f4 05 00 00       	call   80244d <pageref>
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	89 3c 24             	mov    %edi,(%esp)
  801e5e:	e8 ea 05 00 00       	call   80244d <pageref>
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	39 c3                	cmp    %eax,%ebx
  801e68:	0f 94 c1             	sete   %cl
  801e6b:	0f b6 c9             	movzbl %cl,%ecx
  801e6e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e71:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801e77:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e7a:	39 ce                	cmp    %ecx,%esi
  801e7c:	74 1b                	je     801e99 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e7e:	39 c3                	cmp    %eax,%ebx
  801e80:	75 c4                	jne    801e46 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e82:	8b 42 58             	mov    0x58(%edx),%eax
  801e85:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e88:	50                   	push   %eax
  801e89:	56                   	push   %esi
  801e8a:	68 6b 2d 80 00       	push   $0x802d6b
  801e8f:	e8 5d e4 ff ff       	call   8002f1 <cprintf>
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	eb ad                	jmp    801e46 <_pipeisclosed+0xe>
	}
}
  801e99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5e                   	pop    %esi
  801ea1:	5f                   	pop    %edi
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	57                   	push   %edi
  801ea8:	56                   	push   %esi
  801ea9:	53                   	push   %ebx
  801eaa:	83 ec 28             	sub    $0x28,%esp
  801ead:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801eb0:	56                   	push   %esi
  801eb1:	e8 b5 f2 ff ff       	call   80116b <fd2data>
  801eb6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	bf 00 00 00 00       	mov    $0x0,%edi
  801ec0:	eb 4b                	jmp    801f0d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ec2:	89 da                	mov    %ebx,%edx
  801ec4:	89 f0                	mov    %esi,%eax
  801ec6:	e8 6d ff ff ff       	call   801e38 <_pipeisclosed>
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	75 48                	jne    801f17 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ecf:	e8 86 ed ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ed4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ed7:	8b 0b                	mov    (%ebx),%ecx
  801ed9:	8d 51 20             	lea    0x20(%ecx),%edx
  801edc:	39 d0                	cmp    %edx,%eax
  801ede:	73 e2                	jae    801ec2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ee7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801eea:	89 c2                	mov    %eax,%edx
  801eec:	c1 fa 1f             	sar    $0x1f,%edx
  801eef:	89 d1                	mov    %edx,%ecx
  801ef1:	c1 e9 1b             	shr    $0x1b,%ecx
  801ef4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ef7:	83 e2 1f             	and    $0x1f,%edx
  801efa:	29 ca                	sub    %ecx,%edx
  801efc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f00:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f04:	83 c0 01             	add    $0x1,%eax
  801f07:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f0a:	83 c7 01             	add    $0x1,%edi
  801f0d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f10:	75 c2                	jne    801ed4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f12:	8b 45 10             	mov    0x10(%ebp),%eax
  801f15:	eb 05                	jmp    801f1c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f17:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	57                   	push   %edi
  801f28:	56                   	push   %esi
  801f29:	53                   	push   %ebx
  801f2a:	83 ec 18             	sub    $0x18,%esp
  801f2d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f30:	57                   	push   %edi
  801f31:	e8 35 f2 ff ff       	call   80116b <fd2data>
  801f36:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f40:	eb 3d                	jmp    801f7f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f42:	85 db                	test   %ebx,%ebx
  801f44:	74 04                	je     801f4a <devpipe_read+0x26>
				return i;
  801f46:	89 d8                	mov    %ebx,%eax
  801f48:	eb 44                	jmp    801f8e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f4a:	89 f2                	mov    %esi,%edx
  801f4c:	89 f8                	mov    %edi,%eax
  801f4e:	e8 e5 fe ff ff       	call   801e38 <_pipeisclosed>
  801f53:	85 c0                	test   %eax,%eax
  801f55:	75 32                	jne    801f89 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f57:	e8 fe ec ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f5c:	8b 06                	mov    (%esi),%eax
  801f5e:	3b 46 04             	cmp    0x4(%esi),%eax
  801f61:	74 df                	je     801f42 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f63:	99                   	cltd   
  801f64:	c1 ea 1b             	shr    $0x1b,%edx
  801f67:	01 d0                	add    %edx,%eax
  801f69:	83 e0 1f             	and    $0x1f,%eax
  801f6c:	29 d0                	sub    %edx,%eax
  801f6e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f76:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f79:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f7c:	83 c3 01             	add    $0x1,%ebx
  801f7f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f82:	75 d8                	jne    801f5c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f84:	8b 45 10             	mov    0x10(%ebp),%eax
  801f87:	eb 05                	jmp    801f8e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	5f                   	pop    %edi
  801f94:	5d                   	pop    %ebp
  801f95:	c3                   	ret    

00801f96 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa1:	50                   	push   %eax
  801fa2:	e8 db f1 ff ff       	call   801182 <fd_alloc>
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	89 c2                	mov    %eax,%edx
  801fac:	85 c0                	test   %eax,%eax
  801fae:	0f 88 2c 01 00 00    	js     8020e0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fb4:	83 ec 04             	sub    $0x4,%esp
  801fb7:	68 07 04 00 00       	push   $0x407
  801fbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbf:	6a 00                	push   $0x0
  801fc1:	e8 b3 ec ff ff       	call   800c79 <sys_page_alloc>
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	89 c2                	mov    %eax,%edx
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	0f 88 0d 01 00 00    	js     8020e0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fd3:	83 ec 0c             	sub    $0xc,%esp
  801fd6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fd9:	50                   	push   %eax
  801fda:	e8 a3 f1 ff ff       	call   801182 <fd_alloc>
  801fdf:	89 c3                	mov    %eax,%ebx
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	0f 88 e2 00 00 00    	js     8020ce <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fec:	83 ec 04             	sub    $0x4,%esp
  801fef:	68 07 04 00 00       	push   $0x407
  801ff4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff7:	6a 00                	push   $0x0
  801ff9:	e8 7b ec ff ff       	call   800c79 <sys_page_alloc>
  801ffe:	89 c3                	mov    %eax,%ebx
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	85 c0                	test   %eax,%eax
  802005:	0f 88 c3 00 00 00    	js     8020ce <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80200b:	83 ec 0c             	sub    $0xc,%esp
  80200e:	ff 75 f4             	pushl  -0xc(%ebp)
  802011:	e8 55 f1 ff ff       	call   80116b <fd2data>
  802016:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802018:	83 c4 0c             	add    $0xc,%esp
  80201b:	68 07 04 00 00       	push   $0x407
  802020:	50                   	push   %eax
  802021:	6a 00                	push   $0x0
  802023:	e8 51 ec ff ff       	call   800c79 <sys_page_alloc>
  802028:	89 c3                	mov    %eax,%ebx
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	85 c0                	test   %eax,%eax
  80202f:	0f 88 89 00 00 00    	js     8020be <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802035:	83 ec 0c             	sub    $0xc,%esp
  802038:	ff 75 f0             	pushl  -0x10(%ebp)
  80203b:	e8 2b f1 ff ff       	call   80116b <fd2data>
  802040:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802047:	50                   	push   %eax
  802048:	6a 00                	push   $0x0
  80204a:	56                   	push   %esi
  80204b:	6a 00                	push   $0x0
  80204d:	e8 6a ec ff ff       	call   800cbc <sys_page_map>
  802052:	89 c3                	mov    %eax,%ebx
  802054:	83 c4 20             	add    $0x20,%esp
  802057:	85 c0                	test   %eax,%eax
  802059:	78 55                	js     8020b0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80205b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802064:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802066:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802069:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802070:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802076:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802079:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80207b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80207e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802085:	83 ec 0c             	sub    $0xc,%esp
  802088:	ff 75 f4             	pushl  -0xc(%ebp)
  80208b:	e8 cb f0 ff ff       	call   80115b <fd2num>
  802090:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802093:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802095:	83 c4 04             	add    $0x4,%esp
  802098:	ff 75 f0             	pushl  -0x10(%ebp)
  80209b:	e8 bb f0 ff ff       	call   80115b <fd2num>
  8020a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020a3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020a6:	83 c4 10             	add    $0x10,%esp
  8020a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8020ae:	eb 30                	jmp    8020e0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020b0:	83 ec 08             	sub    $0x8,%esp
  8020b3:	56                   	push   %esi
  8020b4:	6a 00                	push   $0x0
  8020b6:	e8 43 ec ff ff       	call   800cfe <sys_page_unmap>
  8020bb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020be:	83 ec 08             	sub    $0x8,%esp
  8020c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c4:	6a 00                	push   $0x0
  8020c6:	e8 33 ec ff ff       	call   800cfe <sys_page_unmap>
  8020cb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020ce:	83 ec 08             	sub    $0x8,%esp
  8020d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d4:	6a 00                	push   $0x0
  8020d6:	e8 23 ec ff ff       	call   800cfe <sys_page_unmap>
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020e0:	89 d0                	mov    %edx,%eax
  8020e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e5:	5b                   	pop    %ebx
  8020e6:	5e                   	pop    %esi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f2:	50                   	push   %eax
  8020f3:	ff 75 08             	pushl  0x8(%ebp)
  8020f6:	e8 d6 f0 ff ff       	call   8011d1 <fd_lookup>
  8020fb:	83 c4 10             	add    $0x10,%esp
  8020fe:	85 c0                	test   %eax,%eax
  802100:	78 18                	js     80211a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802102:	83 ec 0c             	sub    $0xc,%esp
  802105:	ff 75 f4             	pushl  -0xc(%ebp)
  802108:	e8 5e f0 ff ff       	call   80116b <fd2data>
	return _pipeisclosed(fd, p);
  80210d:	89 c2                	mov    %eax,%edx
  80210f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802112:	e8 21 fd ff ff       	call   801e38 <_pipeisclosed>
  802117:	83 c4 10             	add    $0x10,%esp
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	56                   	push   %esi
  802120:	53                   	push   %ebx
  802121:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802124:	85 f6                	test   %esi,%esi
  802126:	75 16                	jne    80213e <wait+0x22>
  802128:	68 83 2d 80 00       	push   $0x802d83
  80212d:	68 ff 2c 80 00       	push   $0x802cff
  802132:	6a 09                	push   $0x9
  802134:	68 8e 2d 80 00       	push   $0x802d8e
  802139:	e8 da e0 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  80213e:	89 f3                	mov    %esi,%ebx
  802140:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802146:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802149:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80214f:	eb 05                	jmp    802156 <wait+0x3a>
		sys_yield();
  802151:	e8 04 eb ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802156:	8b 43 48             	mov    0x48(%ebx),%eax
  802159:	39 c6                	cmp    %eax,%esi
  80215b:	75 07                	jne    802164 <wait+0x48>
  80215d:	8b 43 54             	mov    0x54(%ebx),%eax
  802160:	85 c0                	test   %eax,%eax
  802162:	75 ed                	jne    802151 <wait+0x35>
		sys_yield();
}
  802164:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    

0080216b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80216e:	b8 00 00 00 00       	mov    $0x0,%eax
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    

00802175 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80217b:	68 99 2d 80 00       	push   $0x802d99
  802180:	ff 75 0c             	pushl  0xc(%ebp)
  802183:	e8 ee e6 ff ff       	call   800876 <strcpy>
	return 0;
}
  802188:	b8 00 00 00 00       	mov    $0x0,%eax
  80218d:	c9                   	leave  
  80218e:	c3                   	ret    

0080218f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	57                   	push   %edi
  802193:	56                   	push   %esi
  802194:	53                   	push   %ebx
  802195:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80219b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021a0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a6:	eb 2d                	jmp    8021d5 <devcons_write+0x46>
		m = n - tot;
  8021a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021ab:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021ad:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021b0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021b5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021b8:	83 ec 04             	sub    $0x4,%esp
  8021bb:	53                   	push   %ebx
  8021bc:	03 45 0c             	add    0xc(%ebp),%eax
  8021bf:	50                   	push   %eax
  8021c0:	57                   	push   %edi
  8021c1:	e8 42 e8 ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  8021c6:	83 c4 08             	add    $0x8,%esp
  8021c9:	53                   	push   %ebx
  8021ca:	57                   	push   %edi
  8021cb:	e8 ed e9 ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d0:	01 de                	add    %ebx,%esi
  8021d2:	83 c4 10             	add    $0x10,%esp
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021da:	72 cc                	jb     8021a8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    

008021e4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	83 ec 08             	sub    $0x8,%esp
  8021ea:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021f3:	74 2a                	je     80221f <devcons_read+0x3b>
  8021f5:	eb 05                	jmp    8021fc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021f7:	e8 5e ea ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021fc:	e8 da e9 ff ff       	call   800bdb <sys_cgetc>
  802201:	85 c0                	test   %eax,%eax
  802203:	74 f2                	je     8021f7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802205:	85 c0                	test   %eax,%eax
  802207:	78 16                	js     80221f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802209:	83 f8 04             	cmp    $0x4,%eax
  80220c:	74 0c                	je     80221a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80220e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802211:	88 02                	mov    %al,(%edx)
	return 1;
  802213:	b8 01 00 00 00       	mov    $0x1,%eax
  802218:	eb 05                	jmp    80221f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80221a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80221f:	c9                   	leave  
  802220:	c3                   	ret    

00802221 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802221:	55                   	push   %ebp
  802222:	89 e5                	mov    %esp,%ebp
  802224:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802227:	8b 45 08             	mov    0x8(%ebp),%eax
  80222a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80222d:	6a 01                	push   $0x1
  80222f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802232:	50                   	push   %eax
  802233:	e8 85 e9 ff ff       	call   800bbd <sys_cputs>
}
  802238:	83 c4 10             	add    $0x10,%esp
  80223b:	c9                   	leave  
  80223c:	c3                   	ret    

0080223d <getchar>:

int
getchar(void)
{
  80223d:	55                   	push   %ebp
  80223e:	89 e5                	mov    %esp,%ebp
  802240:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802243:	6a 01                	push   $0x1
  802245:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802248:	50                   	push   %eax
  802249:	6a 00                	push   $0x0
  80224b:	e8 e7 f1 ff ff       	call   801437 <read>
	if (r < 0)
  802250:	83 c4 10             	add    $0x10,%esp
  802253:	85 c0                	test   %eax,%eax
  802255:	78 0f                	js     802266 <getchar+0x29>
		return r;
	if (r < 1)
  802257:	85 c0                	test   %eax,%eax
  802259:	7e 06                	jle    802261 <getchar+0x24>
		return -E_EOF;
	return c;
  80225b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80225f:	eb 05                	jmp    802266 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802261:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802266:	c9                   	leave  
  802267:	c3                   	ret    

00802268 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80226e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802271:	50                   	push   %eax
  802272:	ff 75 08             	pushl  0x8(%ebp)
  802275:	e8 57 ef ff ff       	call   8011d1 <fd_lookup>
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	85 c0                	test   %eax,%eax
  80227f:	78 11                	js     802292 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802281:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802284:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80228a:	39 10                	cmp    %edx,(%eax)
  80228c:	0f 94 c0             	sete   %al
  80228f:	0f b6 c0             	movzbl %al,%eax
}
  802292:	c9                   	leave  
  802293:	c3                   	ret    

00802294 <opencons>:

int
opencons(void)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80229a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229d:	50                   	push   %eax
  80229e:	e8 df ee ff ff       	call   801182 <fd_alloc>
  8022a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022a8:	85 c0                	test   %eax,%eax
  8022aa:	78 3e                	js     8022ea <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ac:	83 ec 04             	sub    $0x4,%esp
  8022af:	68 07 04 00 00       	push   $0x407
  8022b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8022b7:	6a 00                	push   $0x0
  8022b9:	e8 bb e9 ff ff       	call   800c79 <sys_page_alloc>
  8022be:	83 c4 10             	add    $0x10,%esp
		return r;
  8022c1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022c3:	85 c0                	test   %eax,%eax
  8022c5:	78 23                	js     8022ea <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022c7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022dc:	83 ec 0c             	sub    $0xc,%esp
  8022df:	50                   	push   %eax
  8022e0:	e8 76 ee ff ff       	call   80115b <fd2num>
  8022e5:	89 c2                	mov    %eax,%edx
  8022e7:	83 c4 10             	add    $0x10,%esp
}
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	c9                   	leave  
  8022ed:	c3                   	ret    

008022ee <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022ee:	55                   	push   %ebp
  8022ef:	89 e5                	mov    %esp,%ebp
  8022f1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022f4:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022fb:	75 2e                	jne    80232b <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8022fd:	e8 39 e9 ff ff       	call   800c3b <sys_getenvid>
  802302:	83 ec 04             	sub    $0x4,%esp
  802305:	68 07 0e 00 00       	push   $0xe07
  80230a:	68 00 f0 bf ee       	push   $0xeebff000
  80230f:	50                   	push   %eax
  802310:	e8 64 e9 ff ff       	call   800c79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802315:	e8 21 e9 ff ff       	call   800c3b <sys_getenvid>
  80231a:	83 c4 08             	add    $0x8,%esp
  80231d:	68 35 23 80 00       	push   $0x802335
  802322:	50                   	push   %eax
  802323:	e8 9c ea ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  802328:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80232b:	8b 45 08             	mov    0x8(%ebp),%eax
  80232e:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802333:	c9                   	leave  
  802334:	c3                   	ret    

00802335 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802335:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802336:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80233b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80233d:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802340:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802344:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802348:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80234b:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80234e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80234f:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802352:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802353:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802354:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802358:	c3                   	ret    

00802359 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	56                   	push   %esi
  80235d:	53                   	push   %ebx
  80235e:	8b 75 08             	mov    0x8(%ebp),%esi
  802361:	8b 45 0c             	mov    0xc(%ebp),%eax
  802364:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802367:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802369:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80236e:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802371:	83 ec 0c             	sub    $0xc,%esp
  802374:	50                   	push   %eax
  802375:	e8 af ea ff ff       	call   800e29 <sys_ipc_recv>

	if (from_env_store != NULL)
  80237a:	83 c4 10             	add    $0x10,%esp
  80237d:	85 f6                	test   %esi,%esi
  80237f:	74 14                	je     802395 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802381:	ba 00 00 00 00       	mov    $0x0,%edx
  802386:	85 c0                	test   %eax,%eax
  802388:	78 09                	js     802393 <ipc_recv+0x3a>
  80238a:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802390:	8b 52 74             	mov    0x74(%edx),%edx
  802393:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802395:	85 db                	test   %ebx,%ebx
  802397:	74 14                	je     8023ad <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802399:	ba 00 00 00 00       	mov    $0x0,%edx
  80239e:	85 c0                	test   %eax,%eax
  8023a0:	78 09                	js     8023ab <ipc_recv+0x52>
  8023a2:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8023a8:	8b 52 78             	mov    0x78(%edx),%edx
  8023ab:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	78 08                	js     8023b9 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8023b1:	a1 20 44 80 00       	mov    0x804420,%eax
  8023b6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023bc:	5b                   	pop    %ebx
  8023bd:	5e                   	pop    %esi
  8023be:	5d                   	pop    %ebp
  8023bf:	c3                   	ret    

008023c0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	57                   	push   %edi
  8023c4:	56                   	push   %esi
  8023c5:	53                   	push   %ebx
  8023c6:	83 ec 0c             	sub    $0xc,%esp
  8023c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8023d2:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8023d4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023d9:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8023dc:	ff 75 14             	pushl  0x14(%ebp)
  8023df:	53                   	push   %ebx
  8023e0:	56                   	push   %esi
  8023e1:	57                   	push   %edi
  8023e2:	e8 1f ea ff ff       	call   800e06 <sys_ipc_try_send>

		if (err < 0) {
  8023e7:	83 c4 10             	add    $0x10,%esp
  8023ea:	85 c0                	test   %eax,%eax
  8023ec:	79 1e                	jns    80240c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8023ee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023f1:	75 07                	jne    8023fa <ipc_send+0x3a>
				sys_yield();
  8023f3:	e8 62 e8 ff ff       	call   800c5a <sys_yield>
  8023f8:	eb e2                	jmp    8023dc <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8023fa:	50                   	push   %eax
  8023fb:	68 a5 2d 80 00       	push   $0x802da5
  802400:	6a 49                	push   $0x49
  802402:	68 b2 2d 80 00       	push   $0x802db2
  802407:	e8 0c de ff ff       	call   800218 <_panic>
		}

	} while (err < 0);

}
  80240c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80240f:	5b                   	pop    %ebx
  802410:	5e                   	pop    %esi
  802411:	5f                   	pop    %edi
  802412:	5d                   	pop    %ebp
  802413:	c3                   	ret    

00802414 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802414:	55                   	push   %ebp
  802415:	89 e5                	mov    %esp,%ebp
  802417:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80241a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80241f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802422:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802428:	8b 52 50             	mov    0x50(%edx),%edx
  80242b:	39 ca                	cmp    %ecx,%edx
  80242d:	75 0d                	jne    80243c <ipc_find_env+0x28>
			return envs[i].env_id;
  80242f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802432:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802437:	8b 40 48             	mov    0x48(%eax),%eax
  80243a:	eb 0f                	jmp    80244b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80243c:	83 c0 01             	add    $0x1,%eax
  80243f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802444:	75 d9                	jne    80241f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802446:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    

0080244d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80244d:	55                   	push   %ebp
  80244e:	89 e5                	mov    %esp,%ebp
  802450:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802453:	89 d0                	mov    %edx,%eax
  802455:	c1 e8 16             	shr    $0x16,%eax
  802458:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80245f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802464:	f6 c1 01             	test   $0x1,%cl
  802467:	74 1d                	je     802486 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802469:	c1 ea 0c             	shr    $0xc,%edx
  80246c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802473:	f6 c2 01             	test   $0x1,%dl
  802476:	74 0e                	je     802486 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802478:	c1 ea 0c             	shr    $0xc,%edx
  80247b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802482:	ef 
  802483:	0f b7 c0             	movzwl %ax,%eax
}
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__udivdi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	53                   	push   %ebx
  802494:	83 ec 1c             	sub    $0x1c,%esp
  802497:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80249b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80249f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024a7:	85 f6                	test   %esi,%esi
  8024a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ad:	89 ca                	mov    %ecx,%edx
  8024af:	89 f8                	mov    %edi,%eax
  8024b1:	75 3d                	jne    8024f0 <__udivdi3+0x60>
  8024b3:	39 cf                	cmp    %ecx,%edi
  8024b5:	0f 87 c5 00 00 00    	ja     802580 <__udivdi3+0xf0>
  8024bb:	85 ff                	test   %edi,%edi
  8024bd:	89 fd                	mov    %edi,%ebp
  8024bf:	75 0b                	jne    8024cc <__udivdi3+0x3c>
  8024c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c6:	31 d2                	xor    %edx,%edx
  8024c8:	f7 f7                	div    %edi
  8024ca:	89 c5                	mov    %eax,%ebp
  8024cc:	89 c8                	mov    %ecx,%eax
  8024ce:	31 d2                	xor    %edx,%edx
  8024d0:	f7 f5                	div    %ebp
  8024d2:	89 c1                	mov    %eax,%ecx
  8024d4:	89 d8                	mov    %ebx,%eax
  8024d6:	89 cf                	mov    %ecx,%edi
  8024d8:	f7 f5                	div    %ebp
  8024da:	89 c3                	mov    %eax,%ebx
  8024dc:	89 d8                	mov    %ebx,%eax
  8024de:	89 fa                	mov    %edi,%edx
  8024e0:	83 c4 1c             	add    $0x1c,%esp
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5f                   	pop    %edi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    
  8024e8:	90                   	nop
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	39 ce                	cmp    %ecx,%esi
  8024f2:	77 74                	ja     802568 <__udivdi3+0xd8>
  8024f4:	0f bd fe             	bsr    %esi,%edi
  8024f7:	83 f7 1f             	xor    $0x1f,%edi
  8024fa:	0f 84 98 00 00 00    	je     802598 <__udivdi3+0x108>
  802500:	bb 20 00 00 00       	mov    $0x20,%ebx
  802505:	89 f9                	mov    %edi,%ecx
  802507:	89 c5                	mov    %eax,%ebp
  802509:	29 fb                	sub    %edi,%ebx
  80250b:	d3 e6                	shl    %cl,%esi
  80250d:	89 d9                	mov    %ebx,%ecx
  80250f:	d3 ed                	shr    %cl,%ebp
  802511:	89 f9                	mov    %edi,%ecx
  802513:	d3 e0                	shl    %cl,%eax
  802515:	09 ee                	or     %ebp,%esi
  802517:	89 d9                	mov    %ebx,%ecx
  802519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80251d:	89 d5                	mov    %edx,%ebp
  80251f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802523:	d3 ed                	shr    %cl,%ebp
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e2                	shl    %cl,%edx
  802529:	89 d9                	mov    %ebx,%ecx
  80252b:	d3 e8                	shr    %cl,%eax
  80252d:	09 c2                	or     %eax,%edx
  80252f:	89 d0                	mov    %edx,%eax
  802531:	89 ea                	mov    %ebp,%edx
  802533:	f7 f6                	div    %esi
  802535:	89 d5                	mov    %edx,%ebp
  802537:	89 c3                	mov    %eax,%ebx
  802539:	f7 64 24 0c          	mull   0xc(%esp)
  80253d:	39 d5                	cmp    %edx,%ebp
  80253f:	72 10                	jb     802551 <__udivdi3+0xc1>
  802541:	8b 74 24 08          	mov    0x8(%esp),%esi
  802545:	89 f9                	mov    %edi,%ecx
  802547:	d3 e6                	shl    %cl,%esi
  802549:	39 c6                	cmp    %eax,%esi
  80254b:	73 07                	jae    802554 <__udivdi3+0xc4>
  80254d:	39 d5                	cmp    %edx,%ebp
  80254f:	75 03                	jne    802554 <__udivdi3+0xc4>
  802551:	83 eb 01             	sub    $0x1,%ebx
  802554:	31 ff                	xor    %edi,%edi
  802556:	89 d8                	mov    %ebx,%eax
  802558:	89 fa                	mov    %edi,%edx
  80255a:	83 c4 1c             	add    $0x1c,%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5f                   	pop    %edi
  802560:	5d                   	pop    %ebp
  802561:	c3                   	ret    
  802562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802568:	31 ff                	xor    %edi,%edi
  80256a:	31 db                	xor    %ebx,%ebx
  80256c:	89 d8                	mov    %ebx,%eax
  80256e:	89 fa                	mov    %edi,%edx
  802570:	83 c4 1c             	add    $0x1c,%esp
  802573:	5b                   	pop    %ebx
  802574:	5e                   	pop    %esi
  802575:	5f                   	pop    %edi
  802576:	5d                   	pop    %ebp
  802577:	c3                   	ret    
  802578:	90                   	nop
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	89 d8                	mov    %ebx,%eax
  802582:	f7 f7                	div    %edi
  802584:	31 ff                	xor    %edi,%edi
  802586:	89 c3                	mov    %eax,%ebx
  802588:	89 d8                	mov    %ebx,%eax
  80258a:	89 fa                	mov    %edi,%edx
  80258c:	83 c4 1c             	add    $0x1c,%esp
  80258f:	5b                   	pop    %ebx
  802590:	5e                   	pop    %esi
  802591:	5f                   	pop    %edi
  802592:	5d                   	pop    %ebp
  802593:	c3                   	ret    
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	39 ce                	cmp    %ecx,%esi
  80259a:	72 0c                	jb     8025a8 <__udivdi3+0x118>
  80259c:	31 db                	xor    %ebx,%ebx
  80259e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025a2:	0f 87 34 ff ff ff    	ja     8024dc <__udivdi3+0x4c>
  8025a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025ad:	e9 2a ff ff ff       	jmp    8024dc <__udivdi3+0x4c>
  8025b2:	66 90                	xchg   %ax,%ax
  8025b4:	66 90                	xchg   %ax,%ax
  8025b6:	66 90                	xchg   %ax,%ax
  8025b8:	66 90                	xchg   %ax,%ax
  8025ba:	66 90                	xchg   %ax,%ax
  8025bc:	66 90                	xchg   %ax,%ax
  8025be:	66 90                	xchg   %ax,%ax

008025c0 <__umoddi3>:
  8025c0:	55                   	push   %ebp
  8025c1:	57                   	push   %edi
  8025c2:	56                   	push   %esi
  8025c3:	53                   	push   %ebx
  8025c4:	83 ec 1c             	sub    $0x1c,%esp
  8025c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025d7:	85 d2                	test   %edx,%edx
  8025d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025e1:	89 f3                	mov    %esi,%ebx
  8025e3:	89 3c 24             	mov    %edi,(%esp)
  8025e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ea:	75 1c                	jne    802608 <__umoddi3+0x48>
  8025ec:	39 f7                	cmp    %esi,%edi
  8025ee:	76 50                	jbe    802640 <__umoddi3+0x80>
  8025f0:	89 c8                	mov    %ecx,%eax
  8025f2:	89 f2                	mov    %esi,%edx
  8025f4:	f7 f7                	div    %edi
  8025f6:	89 d0                	mov    %edx,%eax
  8025f8:	31 d2                	xor    %edx,%edx
  8025fa:	83 c4 1c             	add    $0x1c,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
  802602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802608:	39 f2                	cmp    %esi,%edx
  80260a:	89 d0                	mov    %edx,%eax
  80260c:	77 52                	ja     802660 <__umoddi3+0xa0>
  80260e:	0f bd ea             	bsr    %edx,%ebp
  802611:	83 f5 1f             	xor    $0x1f,%ebp
  802614:	75 5a                	jne    802670 <__umoddi3+0xb0>
  802616:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80261a:	0f 82 e0 00 00 00    	jb     802700 <__umoddi3+0x140>
  802620:	39 0c 24             	cmp    %ecx,(%esp)
  802623:	0f 86 d7 00 00 00    	jbe    802700 <__umoddi3+0x140>
  802629:	8b 44 24 08          	mov    0x8(%esp),%eax
  80262d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802631:	83 c4 1c             	add    $0x1c,%esp
  802634:	5b                   	pop    %ebx
  802635:	5e                   	pop    %esi
  802636:	5f                   	pop    %edi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	85 ff                	test   %edi,%edi
  802642:	89 fd                	mov    %edi,%ebp
  802644:	75 0b                	jne    802651 <__umoddi3+0x91>
  802646:	b8 01 00 00 00       	mov    $0x1,%eax
  80264b:	31 d2                	xor    %edx,%edx
  80264d:	f7 f7                	div    %edi
  80264f:	89 c5                	mov    %eax,%ebp
  802651:	89 f0                	mov    %esi,%eax
  802653:	31 d2                	xor    %edx,%edx
  802655:	f7 f5                	div    %ebp
  802657:	89 c8                	mov    %ecx,%eax
  802659:	f7 f5                	div    %ebp
  80265b:	89 d0                	mov    %edx,%eax
  80265d:	eb 99                	jmp    8025f8 <__umoddi3+0x38>
  80265f:	90                   	nop
  802660:	89 c8                	mov    %ecx,%eax
  802662:	89 f2                	mov    %esi,%edx
  802664:	83 c4 1c             	add    $0x1c,%esp
  802667:	5b                   	pop    %ebx
  802668:	5e                   	pop    %esi
  802669:	5f                   	pop    %edi
  80266a:	5d                   	pop    %ebp
  80266b:	c3                   	ret    
  80266c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802670:	8b 34 24             	mov    (%esp),%esi
  802673:	bf 20 00 00 00       	mov    $0x20,%edi
  802678:	89 e9                	mov    %ebp,%ecx
  80267a:	29 ef                	sub    %ebp,%edi
  80267c:	d3 e0                	shl    %cl,%eax
  80267e:	89 f9                	mov    %edi,%ecx
  802680:	89 f2                	mov    %esi,%edx
  802682:	d3 ea                	shr    %cl,%edx
  802684:	89 e9                	mov    %ebp,%ecx
  802686:	09 c2                	or     %eax,%edx
  802688:	89 d8                	mov    %ebx,%eax
  80268a:	89 14 24             	mov    %edx,(%esp)
  80268d:	89 f2                	mov    %esi,%edx
  80268f:	d3 e2                	shl    %cl,%edx
  802691:	89 f9                	mov    %edi,%ecx
  802693:	89 54 24 04          	mov    %edx,0x4(%esp)
  802697:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	89 e9                	mov    %ebp,%ecx
  80269f:	89 c6                	mov    %eax,%esi
  8026a1:	d3 e3                	shl    %cl,%ebx
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 d0                	mov    %edx,%eax
  8026a7:	d3 e8                	shr    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	09 d8                	or     %ebx,%eax
  8026ad:	89 d3                	mov    %edx,%ebx
  8026af:	89 f2                	mov    %esi,%edx
  8026b1:	f7 34 24             	divl   (%esp)
  8026b4:	89 d6                	mov    %edx,%esi
  8026b6:	d3 e3                	shl    %cl,%ebx
  8026b8:	f7 64 24 04          	mull   0x4(%esp)
  8026bc:	39 d6                	cmp    %edx,%esi
  8026be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026c2:	89 d1                	mov    %edx,%ecx
  8026c4:	89 c3                	mov    %eax,%ebx
  8026c6:	72 08                	jb     8026d0 <__umoddi3+0x110>
  8026c8:	75 11                	jne    8026db <__umoddi3+0x11b>
  8026ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ce:	73 0b                	jae    8026db <__umoddi3+0x11b>
  8026d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026d4:	1b 14 24             	sbb    (%esp),%edx
  8026d7:	89 d1                	mov    %edx,%ecx
  8026d9:	89 c3                	mov    %eax,%ebx
  8026db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026df:	29 da                	sub    %ebx,%edx
  8026e1:	19 ce                	sbb    %ecx,%esi
  8026e3:	89 f9                	mov    %edi,%ecx
  8026e5:	89 f0                	mov    %esi,%eax
  8026e7:	d3 e0                	shl    %cl,%eax
  8026e9:	89 e9                	mov    %ebp,%ecx
  8026eb:	d3 ea                	shr    %cl,%edx
  8026ed:	89 e9                	mov    %ebp,%ecx
  8026ef:	d3 ee                	shr    %cl,%esi
  8026f1:	09 d0                	or     %edx,%eax
  8026f3:	89 f2                	mov    %esi,%edx
  8026f5:	83 c4 1c             	add    $0x1c,%esp
  8026f8:	5b                   	pop    %ebx
  8026f9:	5e                   	pop    %esi
  8026fa:	5f                   	pop    %edi
  8026fb:	5d                   	pop    %ebp
  8026fc:	c3                   	ret    
  8026fd:	8d 76 00             	lea    0x0(%esi),%esi
  802700:	29 f9                	sub    %edi,%ecx
  802702:	19 d6                	sbb    %edx,%esi
  802704:	89 74 24 04          	mov    %esi,0x4(%esp)
  802708:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80270c:	e9 18 ff ff ff       	jmp    802629 <__umoddi3+0x69>
