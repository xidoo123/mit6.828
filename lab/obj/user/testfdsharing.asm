
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
  80003e:	68 60 27 80 00       	push   $0x802760
  800043:	e8 af 18 00 00       	call   8018f7 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 65 27 80 00       	push   $0x802765
  800057:	6a 0c                	push   $0xc
  800059:	68 73 27 80 00       	push   $0x802773
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 71 15 00 00       	call   8015df <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 89 14 00 00       	call   80150a <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 88 27 80 00       	push   $0x802788
  800090:	6a 0f                	push   $0xf
  800092:	68 73 27 80 00       	push   $0x802773
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 45 0f 00 00       	call   800fe6 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 92 27 80 00       	push   $0x802792
  8000ad:	6a 12                	push   $0x12
  8000af:	68 73 27 80 00       	push   $0x802773
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 13 15 00 00       	call   8015df <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 1f 14 00 00       	call   80150a <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 14 28 80 00       	push   $0x802814
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 73 27 80 00       	push   $0x802773
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
  800125:	68 40 28 80 00       	push   $0x802840
  80012a:	6a 19                	push   $0x19
  80012c:	68 73 27 80 00       	push   $0x802773
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 9b 27 80 00       	push   $0x80279b
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 91 14 00 00       	call   8015df <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 e7 11 00 00       	call   80133d <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 f7 1f 00 00       	call   80215e <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 90 13 00 00       	call   80150a <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 78 28 80 00       	push   $0x802878
  80018b:	6a 21                	push   $0x21
  80018d:	68 73 27 80 00       	push   $0x802773
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 b4 27 80 00       	push   $0x8027b4
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 91 11 00 00       	call   80133d <close>
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
  800204:	e8 5f 11 00 00       	call   801368 <close_all>
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
  800236:	68 a8 28 80 00       	push   $0x8028a8
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 b2 27 80 00 	movl   $0x8027b2,(%esp)
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
  800354:	e8 77 21 00 00       	call   8024d0 <__udivdi3>
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
  800397:	e8 64 22 00 00       	call   802600 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 cb 28 80 00 	movsbl 0x8028cb(%eax),%eax
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
  80049b:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
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
  80055f:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 e3 28 80 00       	push   $0x8028e3
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
  800583:	68 51 2d 80 00       	push   $0x802d51
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
  8005a7:	b8 dc 28 80 00       	mov    $0x8028dc,%eax
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
  800c22:	68 bf 2b 80 00       	push   $0x802bbf
  800c27:	6a 23                	push   $0x23
  800c29:	68 dc 2b 80 00       	push   $0x802bdc
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
  800ca3:	68 bf 2b 80 00       	push   $0x802bbf
  800ca8:	6a 23                	push   $0x23
  800caa:	68 dc 2b 80 00       	push   $0x802bdc
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
  800ce5:	68 bf 2b 80 00       	push   $0x802bbf
  800cea:	6a 23                	push   $0x23
  800cec:	68 dc 2b 80 00       	push   $0x802bdc
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
  800d27:	68 bf 2b 80 00       	push   $0x802bbf
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 dc 2b 80 00       	push   $0x802bdc
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
  800d69:	68 bf 2b 80 00       	push   $0x802bbf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 2b 80 00       	push   $0x802bdc
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
  800dab:	68 bf 2b 80 00       	push   $0x802bbf
  800db0:	6a 23                	push   $0x23
  800db2:	68 dc 2b 80 00       	push   $0x802bdc
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
  800ded:	68 bf 2b 80 00       	push   $0x802bbf
  800df2:	6a 23                	push   $0x23
  800df4:	68 dc 2b 80 00       	push   $0x802bdc
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
  800e51:	68 bf 2b 80 00       	push   $0x802bbf
  800e56:	6a 23                	push   $0x23
  800e58:	68 dc 2b 80 00       	push   $0x802bdc
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
  800eb2:	68 bf 2b 80 00       	push   $0x802bbf
  800eb7:	6a 23                	push   $0x23
  800eb9:	68 dc 2b 80 00       	push   $0x802bdc
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

00800ecb <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed9:	b8 10 00 00 00       	mov    $0x10,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 df                	mov    %ebx,%edi
  800ee6:	89 de                	mov    %ebx,%esi
  800ee8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eea:	85 c0                	test   %eax,%eax
  800eec:	7e 17                	jle    800f05 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	50                   	push   %eax
  800ef2:	6a 10                	push   $0x10
  800ef4:	68 bf 2b 80 00       	push   $0x802bbf
  800ef9:	6a 23                	push   $0x23
  800efb:	68 dc 2b 80 00       	push   $0x802bdc
  800f00:	e8 13 f3 ff ff       	call   800218 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f15:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f17:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f1b:	75 25                	jne    800f42 <pgfault+0x35>
  800f1d:	89 d8                	mov    %ebx,%eax
  800f1f:	c1 e8 0c             	shr    $0xc,%eax
  800f22:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f29:	f6 c4 08             	test   $0x8,%ah
  800f2c:	75 14                	jne    800f42 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	68 ec 2b 80 00       	push   $0x802bec
  800f36:	6a 1e                	push   $0x1e
  800f38:	68 80 2c 80 00       	push   $0x802c80
  800f3d:	e8 d6 f2 ff ff       	call   800218 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f42:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f48:	e8 ee fc ff ff       	call   800c3b <sys_getenvid>
  800f4d:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f4f:	83 ec 04             	sub    $0x4,%esp
  800f52:	6a 07                	push   $0x7
  800f54:	68 00 f0 7f 00       	push   $0x7ff000
  800f59:	50                   	push   %eax
  800f5a:	e8 1a fd ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	79 12                	jns    800f78 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f66:	50                   	push   %eax
  800f67:	68 18 2c 80 00       	push   $0x802c18
  800f6c:	6a 33                	push   $0x33
  800f6e:	68 80 2c 80 00       	push   $0x802c80
  800f73:	e8 a0 f2 ff ff       	call   800218 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f78:	83 ec 04             	sub    $0x4,%esp
  800f7b:	68 00 10 00 00       	push   $0x1000
  800f80:	53                   	push   %ebx
  800f81:	68 00 f0 7f 00       	push   $0x7ff000
  800f86:	e8 e5 fa ff ff       	call   800a70 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f8b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f92:	53                   	push   %ebx
  800f93:	56                   	push   %esi
  800f94:	68 00 f0 7f 00       	push   $0x7ff000
  800f99:	56                   	push   %esi
  800f9a:	e8 1d fd ff ff       	call   800cbc <sys_page_map>
	if (r < 0)
  800f9f:	83 c4 20             	add    $0x20,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	79 12                	jns    800fb8 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800fa6:	50                   	push   %eax
  800fa7:	68 3c 2c 80 00       	push   $0x802c3c
  800fac:	6a 3b                	push   $0x3b
  800fae:	68 80 2c 80 00       	push   $0x802c80
  800fb3:	e8 60 f2 ff ff       	call   800218 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800fb8:	83 ec 08             	sub    $0x8,%esp
  800fbb:	68 00 f0 7f 00       	push   $0x7ff000
  800fc0:	56                   	push   %esi
  800fc1:	e8 38 fd ff ff       	call   800cfe <sys_page_unmap>
	if (r < 0)
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	79 12                	jns    800fdf <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800fcd:	50                   	push   %eax
  800fce:	68 60 2c 80 00       	push   $0x802c60
  800fd3:	6a 40                	push   $0x40
  800fd5:	68 80 2c 80 00       	push   $0x802c80
  800fda:	e8 39 f2 ff ff       	call   800218 <_panic>
}
  800fdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
  800fec:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800fef:	68 0d 0f 80 00       	push   $0x800f0d
  800ff4:	e8 37 13 00 00       	call   802330 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ff9:	b8 07 00 00 00       	mov    $0x7,%eax
  800ffe:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	0f 88 64 01 00 00    	js     80116f <fork+0x189>
  80100b:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801010:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  801015:	85 c0                	test   %eax,%eax
  801017:	75 21                	jne    80103a <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801019:	e8 1d fc ff ff       	call   800c3b <sys_getenvid>
  80101e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801023:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801026:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80102b:	a3 20 44 80 00       	mov    %eax,0x804420
        return 0;
  801030:	ba 00 00 00 00       	mov    $0x0,%edx
  801035:	e9 3f 01 00 00       	jmp    801179 <fork+0x193>
  80103a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80103d:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80103f:	89 d8                	mov    %ebx,%eax
  801041:	c1 e8 16             	shr    $0x16,%eax
  801044:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104b:	a8 01                	test   $0x1,%al
  80104d:	0f 84 bd 00 00 00    	je     801110 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801053:	89 d8                	mov    %ebx,%eax
  801055:	c1 e8 0c             	shr    $0xc,%eax
  801058:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105f:	f6 c2 01             	test   $0x1,%dl
  801062:	0f 84 a8 00 00 00    	je     801110 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801068:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106f:	a8 04                	test   $0x4,%al
  801071:	0f 84 99 00 00 00    	je     801110 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801077:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80107e:	f6 c4 04             	test   $0x4,%ah
  801081:	74 17                	je     80109a <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	68 07 0e 00 00       	push   $0xe07
  80108b:	53                   	push   %ebx
  80108c:	57                   	push   %edi
  80108d:	53                   	push   %ebx
  80108e:	6a 00                	push   $0x0
  801090:	e8 27 fc ff ff       	call   800cbc <sys_page_map>
  801095:	83 c4 20             	add    $0x20,%esp
  801098:	eb 76                	jmp    801110 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80109a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a1:	a8 02                	test   $0x2,%al
  8010a3:	75 0c                	jne    8010b1 <fork+0xcb>
  8010a5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ac:	f6 c4 08             	test   $0x8,%ah
  8010af:	74 3f                	je     8010f0 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	68 05 08 00 00       	push   $0x805
  8010b9:	53                   	push   %ebx
  8010ba:	57                   	push   %edi
  8010bb:	53                   	push   %ebx
  8010bc:	6a 00                	push   $0x0
  8010be:	e8 f9 fb ff ff       	call   800cbc <sys_page_map>
		if (r < 0)
  8010c3:	83 c4 20             	add    $0x20,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	0f 88 a5 00 00 00    	js     801173 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	68 05 08 00 00       	push   $0x805
  8010d6:	53                   	push   %ebx
  8010d7:	6a 00                	push   $0x0
  8010d9:	53                   	push   %ebx
  8010da:	6a 00                	push   $0x0
  8010dc:	e8 db fb ff ff       	call   800cbc <sys_page_map>
  8010e1:	83 c4 20             	add    $0x20,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010eb:	0f 4f c1             	cmovg  %ecx,%eax
  8010ee:	eb 1c                	jmp    80110c <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	6a 05                	push   $0x5
  8010f5:	53                   	push   %ebx
  8010f6:	57                   	push   %edi
  8010f7:	53                   	push   %ebx
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 bd fb ff ff       	call   800cbc <sys_page_map>
  8010ff:	83 c4 20             	add    $0x20,%esp
  801102:	85 c0                	test   %eax,%eax
  801104:	b9 00 00 00 00       	mov    $0x0,%ecx
  801109:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80110c:	85 c0                	test   %eax,%eax
  80110e:	78 67                	js     801177 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801110:	83 c6 01             	add    $0x1,%esi
  801113:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801119:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80111f:	0f 85 1a ff ff ff    	jne    80103f <fork+0x59>
  801125:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801128:	83 ec 04             	sub    $0x4,%esp
  80112b:	6a 07                	push   $0x7
  80112d:	68 00 f0 bf ee       	push   $0xeebff000
  801132:	57                   	push   %edi
  801133:	e8 41 fb ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  801138:	83 c4 10             	add    $0x10,%esp
		return r;
  80113b:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80113d:	85 c0                	test   %eax,%eax
  80113f:	78 38                	js     801179 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	68 77 23 80 00       	push   $0x802377
  801149:	57                   	push   %edi
  80114a:	e8 75 fc ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80114f:	83 c4 10             	add    $0x10,%esp
		return r;
  801152:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801154:	85 c0                	test   %eax,%eax
  801156:	78 21                	js     801179 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	6a 02                	push   $0x2
  80115d:	57                   	push   %edi
  80115e:	e8 dd fb ff ff       	call   800d40 <sys_env_set_status>
	if (r < 0)
  801163:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801166:	85 c0                	test   %eax,%eax
  801168:	0f 48 f8             	cmovs  %eax,%edi
  80116b:	89 fa                	mov    %edi,%edx
  80116d:	eb 0a                	jmp    801179 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80116f:	89 c2                	mov    %eax,%edx
  801171:	eb 06                	jmp    801179 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801173:	89 c2                	mov    %eax,%edx
  801175:	eb 02                	jmp    801179 <fork+0x193>
  801177:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801179:	89 d0                	mov    %edx,%eax
  80117b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117e:	5b                   	pop    %ebx
  80117f:	5e                   	pop    %esi
  801180:	5f                   	pop    %edi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <sfork>:

// Challenge!
int
sfork(void)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801189:	68 8b 2c 80 00       	push   $0x802c8b
  80118e:	68 c9 00 00 00       	push   $0xc9
  801193:	68 80 2c 80 00       	push   $0x802c80
  801198:	e8 7b f0 ff ff       	call   800218 <_panic>

0080119d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a8:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011bd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ca:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011cf:	89 c2                	mov    %eax,%edx
  8011d1:	c1 ea 16             	shr    $0x16,%edx
  8011d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011db:	f6 c2 01             	test   $0x1,%dl
  8011de:	74 11                	je     8011f1 <fd_alloc+0x2d>
  8011e0:	89 c2                	mov    %eax,%edx
  8011e2:	c1 ea 0c             	shr    $0xc,%edx
  8011e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ec:	f6 c2 01             	test   $0x1,%dl
  8011ef:	75 09                	jne    8011fa <fd_alloc+0x36>
			*fd_store = fd;
  8011f1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f8:	eb 17                	jmp    801211 <fd_alloc+0x4d>
  8011fa:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ff:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801204:	75 c9                	jne    8011cf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801206:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80120c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801219:	83 f8 1f             	cmp    $0x1f,%eax
  80121c:	77 36                	ja     801254 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80121e:	c1 e0 0c             	shl    $0xc,%eax
  801221:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801226:	89 c2                	mov    %eax,%edx
  801228:	c1 ea 16             	shr    $0x16,%edx
  80122b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801232:	f6 c2 01             	test   $0x1,%dl
  801235:	74 24                	je     80125b <fd_lookup+0x48>
  801237:	89 c2                	mov    %eax,%edx
  801239:	c1 ea 0c             	shr    $0xc,%edx
  80123c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801243:	f6 c2 01             	test   $0x1,%dl
  801246:	74 1a                	je     801262 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801248:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124b:	89 02                	mov    %eax,(%edx)
	return 0;
  80124d:	b8 00 00 00 00       	mov    $0x0,%eax
  801252:	eb 13                	jmp    801267 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801254:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801259:	eb 0c                	jmp    801267 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80125b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801260:	eb 05                	jmp    801267 <fd_lookup+0x54>
  801262:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	83 ec 08             	sub    $0x8,%esp
  80126f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801272:	ba 24 2d 80 00       	mov    $0x802d24,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801277:	eb 13                	jmp    80128c <dev_lookup+0x23>
  801279:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80127c:	39 08                	cmp    %ecx,(%eax)
  80127e:	75 0c                	jne    80128c <dev_lookup+0x23>
			*dev = devtab[i];
  801280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801283:	89 01                	mov    %eax,(%ecx)
			return 0;
  801285:	b8 00 00 00 00       	mov    $0x0,%eax
  80128a:	eb 2e                	jmp    8012ba <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80128c:	8b 02                	mov    (%edx),%eax
  80128e:	85 c0                	test   %eax,%eax
  801290:	75 e7                	jne    801279 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801292:	a1 20 44 80 00       	mov    0x804420,%eax
  801297:	8b 40 48             	mov    0x48(%eax),%eax
  80129a:	83 ec 04             	sub    $0x4,%esp
  80129d:	51                   	push   %ecx
  80129e:	50                   	push   %eax
  80129f:	68 a4 2c 80 00       	push   $0x802ca4
  8012a4:	e8 48 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  8012a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	56                   	push   %esi
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 10             	sub    $0x10,%esp
  8012c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012d4:	c1 e8 0c             	shr    $0xc,%eax
  8012d7:	50                   	push   %eax
  8012d8:	e8 36 ff ff ff       	call   801213 <fd_lookup>
  8012dd:	83 c4 08             	add    $0x8,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 05                	js     8012e9 <fd_close+0x2d>
	    || fd != fd2)
  8012e4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012e7:	74 0c                	je     8012f5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012e9:	84 db                	test   %bl,%bl
  8012eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f0:	0f 44 c2             	cmove  %edx,%eax
  8012f3:	eb 41                	jmp    801336 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	ff 36                	pushl  (%esi)
  8012fe:	e8 66 ff ff ff       	call   801269 <dev_lookup>
  801303:	89 c3                	mov    %eax,%ebx
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	78 1a                	js     801326 <fd_close+0x6a>
		if (dev->dev_close)
  80130c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801312:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801317:	85 c0                	test   %eax,%eax
  801319:	74 0b                	je     801326 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	56                   	push   %esi
  80131f:	ff d0                	call   *%eax
  801321:	89 c3                	mov    %eax,%ebx
  801323:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	56                   	push   %esi
  80132a:	6a 00                	push   $0x0
  80132c:	e8 cd f9 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	89 d8                	mov    %ebx,%eax
}
  801336:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	ff 75 08             	pushl  0x8(%ebp)
  80134a:	e8 c4 fe ff ff       	call   801213 <fd_lookup>
  80134f:	83 c4 08             	add    $0x8,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 10                	js     801366 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	6a 01                	push   $0x1
  80135b:	ff 75 f4             	pushl  -0xc(%ebp)
  80135e:	e8 59 ff ff ff       	call   8012bc <fd_close>
  801363:	83 c4 10             	add    $0x10,%esp
}
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <close_all>:

void
close_all(void)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	53                   	push   %ebx
  80136c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801374:	83 ec 0c             	sub    $0xc,%esp
  801377:	53                   	push   %ebx
  801378:	e8 c0 ff ff ff       	call   80133d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80137d:	83 c3 01             	add    $0x1,%ebx
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	83 fb 20             	cmp    $0x20,%ebx
  801386:	75 ec                	jne    801374 <close_all+0xc>
		close(i);
}
  801388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	57                   	push   %edi
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
  801393:	83 ec 2c             	sub    $0x2c,%esp
  801396:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801399:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80139c:	50                   	push   %eax
  80139d:	ff 75 08             	pushl  0x8(%ebp)
  8013a0:	e8 6e fe ff ff       	call   801213 <fd_lookup>
  8013a5:	83 c4 08             	add    $0x8,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	0f 88 c1 00 00 00    	js     801471 <dup+0xe4>
		return r;
	close(newfdnum);
  8013b0:	83 ec 0c             	sub    $0xc,%esp
  8013b3:	56                   	push   %esi
  8013b4:	e8 84 ff ff ff       	call   80133d <close>

	newfd = INDEX2FD(newfdnum);
  8013b9:	89 f3                	mov    %esi,%ebx
  8013bb:	c1 e3 0c             	shl    $0xc,%ebx
  8013be:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013c4:	83 c4 04             	add    $0x4,%esp
  8013c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ca:	e8 de fd ff ff       	call   8011ad <fd2data>
  8013cf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013d1:	89 1c 24             	mov    %ebx,(%esp)
  8013d4:	e8 d4 fd ff ff       	call   8011ad <fd2data>
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013df:	89 f8                	mov    %edi,%eax
  8013e1:	c1 e8 16             	shr    $0x16,%eax
  8013e4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013eb:	a8 01                	test   $0x1,%al
  8013ed:	74 37                	je     801426 <dup+0x99>
  8013ef:	89 f8                	mov    %edi,%eax
  8013f1:	c1 e8 0c             	shr    $0xc,%eax
  8013f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013fb:	f6 c2 01             	test   $0x1,%dl
  8013fe:	74 26                	je     801426 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801400:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	25 07 0e 00 00       	and    $0xe07,%eax
  80140f:	50                   	push   %eax
  801410:	ff 75 d4             	pushl  -0x2c(%ebp)
  801413:	6a 00                	push   $0x0
  801415:	57                   	push   %edi
  801416:	6a 00                	push   $0x0
  801418:	e8 9f f8 ff ff       	call   800cbc <sys_page_map>
  80141d:	89 c7                	mov    %eax,%edi
  80141f:	83 c4 20             	add    $0x20,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	78 2e                	js     801454 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801426:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801429:	89 d0                	mov    %edx,%eax
  80142b:	c1 e8 0c             	shr    $0xc,%eax
  80142e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801435:	83 ec 0c             	sub    $0xc,%esp
  801438:	25 07 0e 00 00       	and    $0xe07,%eax
  80143d:	50                   	push   %eax
  80143e:	53                   	push   %ebx
  80143f:	6a 00                	push   $0x0
  801441:	52                   	push   %edx
  801442:	6a 00                	push   $0x0
  801444:	e8 73 f8 ff ff       	call   800cbc <sys_page_map>
  801449:	89 c7                	mov    %eax,%edi
  80144b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80144e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801450:	85 ff                	test   %edi,%edi
  801452:	79 1d                	jns    801471 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	53                   	push   %ebx
  801458:	6a 00                	push   $0x0
  80145a:	e8 9f f8 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80145f:	83 c4 08             	add    $0x8,%esp
  801462:	ff 75 d4             	pushl  -0x2c(%ebp)
  801465:	6a 00                	push   $0x0
  801467:	e8 92 f8 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	89 f8                	mov    %edi,%eax
}
  801471:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801474:	5b                   	pop    %ebx
  801475:	5e                   	pop    %esi
  801476:	5f                   	pop    %edi
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	53                   	push   %ebx
  80147d:	83 ec 14             	sub    $0x14,%esp
  801480:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801483:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801486:	50                   	push   %eax
  801487:	53                   	push   %ebx
  801488:	e8 86 fd ff ff       	call   801213 <fd_lookup>
  80148d:	83 c4 08             	add    $0x8,%esp
  801490:	89 c2                	mov    %eax,%edx
  801492:	85 c0                	test   %eax,%eax
  801494:	78 6d                	js     801503 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801496:	83 ec 08             	sub    $0x8,%esp
  801499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a0:	ff 30                	pushl  (%eax)
  8014a2:	e8 c2 fd ff ff       	call   801269 <dev_lookup>
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 4c                	js     8014fa <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014b1:	8b 42 08             	mov    0x8(%edx),%eax
  8014b4:	83 e0 03             	and    $0x3,%eax
  8014b7:	83 f8 01             	cmp    $0x1,%eax
  8014ba:	75 21                	jne    8014dd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014bc:	a1 20 44 80 00       	mov    0x804420,%eax
  8014c1:	8b 40 48             	mov    0x48(%eax),%eax
  8014c4:	83 ec 04             	sub    $0x4,%esp
  8014c7:	53                   	push   %ebx
  8014c8:	50                   	push   %eax
  8014c9:	68 e8 2c 80 00       	push   $0x802ce8
  8014ce:	e8 1e ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014db:	eb 26                	jmp    801503 <read+0x8a>
	}
	if (!dev->dev_read)
  8014dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e0:	8b 40 08             	mov    0x8(%eax),%eax
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	74 17                	je     8014fe <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e7:	83 ec 04             	sub    $0x4,%esp
  8014ea:	ff 75 10             	pushl  0x10(%ebp)
  8014ed:	ff 75 0c             	pushl  0xc(%ebp)
  8014f0:	52                   	push   %edx
  8014f1:	ff d0                	call   *%eax
  8014f3:	89 c2                	mov    %eax,%edx
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	eb 09                	jmp    801503 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fa:	89 c2                	mov    %eax,%edx
  8014fc:	eb 05                	jmp    801503 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801503:	89 d0                	mov    %edx,%eax
  801505:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	57                   	push   %edi
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	83 ec 0c             	sub    $0xc,%esp
  801513:	8b 7d 08             	mov    0x8(%ebp),%edi
  801516:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801519:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151e:	eb 21                	jmp    801541 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801520:	83 ec 04             	sub    $0x4,%esp
  801523:	89 f0                	mov    %esi,%eax
  801525:	29 d8                	sub    %ebx,%eax
  801527:	50                   	push   %eax
  801528:	89 d8                	mov    %ebx,%eax
  80152a:	03 45 0c             	add    0xc(%ebp),%eax
  80152d:	50                   	push   %eax
  80152e:	57                   	push   %edi
  80152f:	e8 45 ff ff ff       	call   801479 <read>
		if (m < 0)
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	78 10                	js     80154b <readn+0x41>
			return m;
		if (m == 0)
  80153b:	85 c0                	test   %eax,%eax
  80153d:	74 0a                	je     801549 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153f:	01 c3                	add    %eax,%ebx
  801541:	39 f3                	cmp    %esi,%ebx
  801543:	72 db                	jb     801520 <readn+0x16>
  801545:	89 d8                	mov    %ebx,%eax
  801547:	eb 02                	jmp    80154b <readn+0x41>
  801549:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80154b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154e:	5b                   	pop    %ebx
  80154f:	5e                   	pop    %esi
  801550:	5f                   	pop    %edi
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    

00801553 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 14             	sub    $0x14,%esp
  80155a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	53                   	push   %ebx
  801562:	e8 ac fc ff ff       	call   801213 <fd_lookup>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 68                	js     8015d8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157a:	ff 30                	pushl  (%eax)
  80157c:	e8 e8 fc ff ff       	call   801269 <dev_lookup>
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	85 c0                	test   %eax,%eax
  801586:	78 47                	js     8015cf <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158f:	75 21                	jne    8015b2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801591:	a1 20 44 80 00       	mov    0x804420,%eax
  801596:	8b 40 48             	mov    0x48(%eax),%eax
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	53                   	push   %ebx
  80159d:	50                   	push   %eax
  80159e:	68 04 2d 80 00       	push   $0x802d04
  8015a3:	e8 49 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b0:	eb 26                	jmp    8015d8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b8:	85 d2                	test   %edx,%edx
  8015ba:	74 17                	je     8015d3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015bc:	83 ec 04             	sub    $0x4,%esp
  8015bf:	ff 75 10             	pushl  0x10(%ebp)
  8015c2:	ff 75 0c             	pushl  0xc(%ebp)
  8015c5:	50                   	push   %eax
  8015c6:	ff d2                	call   *%edx
  8015c8:	89 c2                	mov    %eax,%edx
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	eb 09                	jmp    8015d8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cf:	89 c2                	mov    %eax,%edx
  8015d1:	eb 05                	jmp    8015d8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015d8:	89 d0                	mov    %edx,%eax
  8015da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <seek>:

int
seek(int fdnum, off_t offset)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	ff 75 08             	pushl  0x8(%ebp)
  8015ec:	e8 22 fc ff ff       	call   801213 <fd_lookup>
  8015f1:	83 c4 08             	add    $0x8,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 0e                	js     801606 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fe:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801601:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	53                   	push   %ebx
  80160c:	83 ec 14             	sub    $0x14,%esp
  80160f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801612:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	53                   	push   %ebx
  801617:	e8 f7 fb ff ff       	call   801213 <fd_lookup>
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	89 c2                	mov    %eax,%edx
  801621:	85 c0                	test   %eax,%eax
  801623:	78 65                	js     80168a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162f:	ff 30                	pushl  (%eax)
  801631:	e8 33 fc ff ff       	call   801269 <dev_lookup>
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 44                	js     801681 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801640:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801644:	75 21                	jne    801667 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801646:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80164b:	8b 40 48             	mov    0x48(%eax),%eax
  80164e:	83 ec 04             	sub    $0x4,%esp
  801651:	53                   	push   %ebx
  801652:	50                   	push   %eax
  801653:	68 c4 2c 80 00       	push   $0x802cc4
  801658:	e8 94 ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801665:	eb 23                	jmp    80168a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801667:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166a:	8b 52 18             	mov    0x18(%edx),%edx
  80166d:	85 d2                	test   %edx,%edx
  80166f:	74 14                	je     801685 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	ff 75 0c             	pushl  0xc(%ebp)
  801677:	50                   	push   %eax
  801678:	ff d2                	call   *%edx
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	eb 09                	jmp    80168a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801681:	89 c2                	mov    %eax,%edx
  801683:	eb 05                	jmp    80168a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801685:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80168a:	89 d0                	mov    %edx,%eax
  80168c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168f:	c9                   	leave  
  801690:	c3                   	ret    

00801691 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	53                   	push   %ebx
  801695:	83 ec 14             	sub    $0x14,%esp
  801698:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169e:	50                   	push   %eax
  80169f:	ff 75 08             	pushl  0x8(%ebp)
  8016a2:	e8 6c fb ff ff       	call   801213 <fd_lookup>
  8016a7:	83 c4 08             	add    $0x8,%esp
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 58                	js     801708 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ba:	ff 30                	pushl  (%eax)
  8016bc:	e8 a8 fb ff ff       	call   801269 <dev_lookup>
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 37                	js     8016ff <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016cf:	74 32                	je     801703 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016d1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016db:	00 00 00 
	stat->st_isdir = 0;
  8016de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e5:	00 00 00 
	stat->st_dev = dev;
  8016e8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	53                   	push   %ebx
  8016f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016f5:	ff 50 14             	call   *0x14(%eax)
  8016f8:	89 c2                	mov    %eax,%edx
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	eb 09                	jmp    801708 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ff:	89 c2                	mov    %eax,%edx
  801701:	eb 05                	jmp    801708 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801703:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801708:	89 d0                	mov    %edx,%eax
  80170a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	6a 00                	push   $0x0
  801719:	ff 75 08             	pushl  0x8(%ebp)
  80171c:	e8 d6 01 00 00       	call   8018f7 <open>
  801721:	89 c3                	mov    %eax,%ebx
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	78 1b                	js     801745 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	ff 75 0c             	pushl  0xc(%ebp)
  801730:	50                   	push   %eax
  801731:	e8 5b ff ff ff       	call   801691 <fstat>
  801736:	89 c6                	mov    %eax,%esi
	close(fd);
  801738:	89 1c 24             	mov    %ebx,(%esp)
  80173b:	e8 fd fb ff ff       	call   80133d <close>
	return r;
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	89 f0                	mov    %esi,%eax
}
  801745:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	56                   	push   %esi
  801750:	53                   	push   %ebx
  801751:	89 c6                	mov    %eax,%esi
  801753:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801755:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80175c:	75 12                	jne    801770 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80175e:	83 ec 0c             	sub    $0xc,%esp
  801761:	6a 01                	push   $0x1
  801763:	e8 ee 0c 00 00       	call   802456 <ipc_find_env>
  801768:	a3 00 40 80 00       	mov    %eax,0x804000
  80176d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801770:	6a 07                	push   $0x7
  801772:	68 00 50 80 00       	push   $0x805000
  801777:	56                   	push   %esi
  801778:	ff 35 00 40 80 00    	pushl  0x804000
  80177e:	e8 7f 0c 00 00       	call   802402 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801783:	83 c4 0c             	add    $0xc,%esp
  801786:	6a 00                	push   $0x0
  801788:	53                   	push   %ebx
  801789:	6a 00                	push   $0x0
  80178b:	e8 0b 0c 00 00       	call   80239b <ipc_recv>
}
  801790:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ab:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ba:	e8 8d ff ff ff       	call   80174c <fsipc>
}
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017dc:	e8 6b ff ff ff       	call   80174c <fsipc>
}
  8017e1:	c9                   	leave  
  8017e2:	c3                   	ret    

008017e3 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	53                   	push   %ebx
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fd:	b8 05 00 00 00       	mov    $0x5,%eax
  801802:	e8 45 ff ff ff       	call   80174c <fsipc>
  801807:	85 c0                	test   %eax,%eax
  801809:	78 2c                	js     801837 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	68 00 50 80 00       	push   $0x805000
  801813:	53                   	push   %ebx
  801814:	e8 5d f0 ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801819:	a1 80 50 80 00       	mov    0x805080,%eax
  80181e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801824:	a1 84 50 80 00       	mov    0x805084,%eax
  801829:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	83 ec 0c             	sub    $0xc,%esp
  801842:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801845:	8b 55 08             	mov    0x8(%ebp),%edx
  801848:	8b 52 0c             	mov    0xc(%edx),%edx
  80184b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801851:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801856:	50                   	push   %eax
  801857:	ff 75 0c             	pushl  0xc(%ebp)
  80185a:	68 08 50 80 00       	push   $0x805008
  80185f:	e8 a4 f1 ff ff       	call   800a08 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801864:	ba 00 00 00 00       	mov    $0x0,%edx
  801869:	b8 04 00 00 00       	mov    $0x4,%eax
  80186e:	e8 d9 fe ff ff       	call   80174c <fsipc>

}
  801873:	c9                   	leave  
  801874:	c3                   	ret    

00801875 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	56                   	push   %esi
  801879:	53                   	push   %ebx
  80187a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187d:	8b 45 08             	mov    0x8(%ebp),%eax
  801880:	8b 40 0c             	mov    0xc(%eax),%eax
  801883:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801888:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188e:	ba 00 00 00 00       	mov    $0x0,%edx
  801893:	b8 03 00 00 00       	mov    $0x3,%eax
  801898:	e8 af fe ff ff       	call   80174c <fsipc>
  80189d:	89 c3                	mov    %eax,%ebx
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	78 4b                	js     8018ee <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018a3:	39 c6                	cmp    %eax,%esi
  8018a5:	73 16                	jae    8018bd <devfile_read+0x48>
  8018a7:	68 38 2d 80 00       	push   $0x802d38
  8018ac:	68 3f 2d 80 00       	push   $0x802d3f
  8018b1:	6a 7c                	push   $0x7c
  8018b3:	68 54 2d 80 00       	push   $0x802d54
  8018b8:	e8 5b e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  8018bd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c2:	7e 16                	jle    8018da <devfile_read+0x65>
  8018c4:	68 5f 2d 80 00       	push   $0x802d5f
  8018c9:	68 3f 2d 80 00       	push   $0x802d3f
  8018ce:	6a 7d                	push   $0x7d
  8018d0:	68 54 2d 80 00       	push   $0x802d54
  8018d5:	e8 3e e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018da:	83 ec 04             	sub    $0x4,%esp
  8018dd:	50                   	push   %eax
  8018de:	68 00 50 80 00       	push   $0x805000
  8018e3:	ff 75 0c             	pushl  0xc(%ebp)
  8018e6:	e8 1d f1 ff ff       	call   800a08 <memmove>
	return r;
  8018eb:	83 c4 10             	add    $0x10,%esp
}
  8018ee:	89 d8                	mov    %ebx,%eax
  8018f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f3:	5b                   	pop    %ebx
  8018f4:	5e                   	pop    %esi
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	53                   	push   %ebx
  8018fb:	83 ec 20             	sub    $0x20,%esp
  8018fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801901:	53                   	push   %ebx
  801902:	e8 36 ef ff ff       	call   80083d <strlen>
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190f:	7f 67                	jg     801978 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801911:	83 ec 0c             	sub    $0xc,%esp
  801914:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801917:	50                   	push   %eax
  801918:	e8 a7 f8 ff ff       	call   8011c4 <fd_alloc>
  80191d:	83 c4 10             	add    $0x10,%esp
		return r;
  801920:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801922:	85 c0                	test   %eax,%eax
  801924:	78 57                	js     80197d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	53                   	push   %ebx
  80192a:	68 00 50 80 00       	push   $0x805000
  80192f:	e8 42 ef ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801934:	8b 45 0c             	mov    0xc(%ebp),%eax
  801937:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193f:	b8 01 00 00 00       	mov    $0x1,%eax
  801944:	e8 03 fe ff ff       	call   80174c <fsipc>
  801949:	89 c3                	mov    %eax,%ebx
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	85 c0                	test   %eax,%eax
  801950:	79 14                	jns    801966 <open+0x6f>
		fd_close(fd, 0);
  801952:	83 ec 08             	sub    $0x8,%esp
  801955:	6a 00                	push   $0x0
  801957:	ff 75 f4             	pushl  -0xc(%ebp)
  80195a:	e8 5d f9 ff ff       	call   8012bc <fd_close>
		return r;
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	89 da                	mov    %ebx,%edx
  801964:	eb 17                	jmp    80197d <open+0x86>
	}

	return fd2num(fd);
  801966:	83 ec 0c             	sub    $0xc,%esp
  801969:	ff 75 f4             	pushl  -0xc(%ebp)
  80196c:	e8 2c f8 ff ff       	call   80119d <fd2num>
  801971:	89 c2                	mov    %eax,%edx
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	eb 05                	jmp    80197d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801978:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80197d:	89 d0                	mov    %edx,%eax
  80197f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	b8 08 00 00 00       	mov    $0x8,%eax
  801994:	e8 b3 fd ff ff       	call   80174c <fsipc>
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019a1:	68 6b 2d 80 00       	push   $0x802d6b
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	e8 c8 ee ff ff       	call   800876 <strcpy>
	return 0;
}
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	53                   	push   %ebx
  8019b9:	83 ec 10             	sub    $0x10,%esp
  8019bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019bf:	53                   	push   %ebx
  8019c0:	e8 ca 0a 00 00       	call   80248f <pageref>
  8019c5:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019c8:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019cd:	83 f8 01             	cmp    $0x1,%eax
  8019d0:	75 10                	jne    8019e2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	ff 73 0c             	pushl  0xc(%ebx)
  8019d8:	e8 c0 02 00 00       	call   801c9d <nsipc_close>
  8019dd:	89 c2                	mov    %eax,%edx
  8019df:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019e2:	89 d0                	mov    %edx,%eax
  8019e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019ef:	6a 00                	push   $0x0
  8019f1:	ff 75 10             	pushl  0x10(%ebp)
  8019f4:	ff 75 0c             	pushl  0xc(%ebp)
  8019f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fa:	ff 70 0c             	pushl  0xc(%eax)
  8019fd:	e8 78 03 00 00       	call   801d7a <nsipc_send>
}
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    

00801a04 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a0a:	6a 00                	push   $0x0
  801a0c:	ff 75 10             	pushl  0x10(%ebp)
  801a0f:	ff 75 0c             	pushl  0xc(%ebp)
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	ff 70 0c             	pushl  0xc(%eax)
  801a18:	e8 f1 02 00 00       	call   801d0e <nsipc_recv>
}
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a25:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a28:	52                   	push   %edx
  801a29:	50                   	push   %eax
  801a2a:	e8 e4 f7 ff ff       	call   801213 <fd_lookup>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 17                	js     801a4d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a39:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a3f:	39 08                	cmp    %ecx,(%eax)
  801a41:	75 05                	jne    801a48 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a43:	8b 40 0c             	mov    0xc(%eax),%eax
  801a46:	eb 05                	jmp    801a4d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a48:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	56                   	push   %esi
  801a53:	53                   	push   %ebx
  801a54:	83 ec 1c             	sub    $0x1c,%esp
  801a57:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5c:	50                   	push   %eax
  801a5d:	e8 62 f7 ff ff       	call   8011c4 <fd_alloc>
  801a62:	89 c3                	mov    %eax,%ebx
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 1b                	js     801a86 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a6b:	83 ec 04             	sub    $0x4,%esp
  801a6e:	68 07 04 00 00       	push   $0x407
  801a73:	ff 75 f4             	pushl  -0xc(%ebp)
  801a76:	6a 00                	push   $0x0
  801a78:	e8 fc f1 ff ff       	call   800c79 <sys_page_alloc>
  801a7d:	89 c3                	mov    %eax,%ebx
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	79 10                	jns    801a96 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	56                   	push   %esi
  801a8a:	e8 0e 02 00 00       	call   801c9d <nsipc_close>
		return r;
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	89 d8                	mov    %ebx,%eax
  801a94:	eb 24                	jmp    801aba <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a96:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801aab:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	50                   	push   %eax
  801ab2:	e8 e6 f6 ff ff       	call   80119d <fd2num>
  801ab7:	83 c4 10             	add    $0x10,%esp
}
  801aba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5e                   	pop    %esi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	e8 50 ff ff ff       	call   801a1f <fd2sockid>
		return r;
  801acf:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 1f                	js     801af4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ad5:	83 ec 04             	sub    $0x4,%esp
  801ad8:	ff 75 10             	pushl  0x10(%ebp)
  801adb:	ff 75 0c             	pushl  0xc(%ebp)
  801ade:	50                   	push   %eax
  801adf:	e8 12 01 00 00       	call   801bf6 <nsipc_accept>
  801ae4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 07                	js     801af4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801aed:	e8 5d ff ff ff       	call   801a4f <alloc_sockfd>
  801af2:	89 c1                	mov    %eax,%ecx
}
  801af4:	89 c8                	mov    %ecx,%eax
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	e8 19 ff ff ff       	call   801a1f <fd2sockid>
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 12                	js     801b1c <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b0a:	83 ec 04             	sub    $0x4,%esp
  801b0d:	ff 75 10             	pushl  0x10(%ebp)
  801b10:	ff 75 0c             	pushl  0xc(%ebp)
  801b13:	50                   	push   %eax
  801b14:	e8 2d 01 00 00       	call   801c46 <nsipc_bind>
  801b19:	83 c4 10             	add    $0x10,%esp
}
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <shutdown>:

int
shutdown(int s, int how)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b24:	8b 45 08             	mov    0x8(%ebp),%eax
  801b27:	e8 f3 fe ff ff       	call   801a1f <fd2sockid>
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 0f                	js     801b3f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b30:	83 ec 08             	sub    $0x8,%esp
  801b33:	ff 75 0c             	pushl  0xc(%ebp)
  801b36:	50                   	push   %eax
  801b37:	e8 3f 01 00 00       	call   801c7b <nsipc_shutdown>
  801b3c:	83 c4 10             	add    $0x10,%esp
}
  801b3f:	c9                   	leave  
  801b40:	c3                   	ret    

00801b41 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b47:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4a:	e8 d0 fe ff ff       	call   801a1f <fd2sockid>
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	78 12                	js     801b65 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b53:	83 ec 04             	sub    $0x4,%esp
  801b56:	ff 75 10             	pushl  0x10(%ebp)
  801b59:	ff 75 0c             	pushl  0xc(%ebp)
  801b5c:	50                   	push   %eax
  801b5d:	e8 55 01 00 00       	call   801cb7 <nsipc_connect>
  801b62:	83 c4 10             	add    $0x10,%esp
}
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <listen>:

int
listen(int s, int backlog)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b70:	e8 aa fe ff ff       	call   801a1f <fd2sockid>
  801b75:	85 c0                	test   %eax,%eax
  801b77:	78 0f                	js     801b88 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b79:	83 ec 08             	sub    $0x8,%esp
  801b7c:	ff 75 0c             	pushl  0xc(%ebp)
  801b7f:	50                   	push   %eax
  801b80:	e8 67 01 00 00       	call   801cec <nsipc_listen>
  801b85:	83 c4 10             	add    $0x10,%esp
}
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b90:	ff 75 10             	pushl  0x10(%ebp)
  801b93:	ff 75 0c             	pushl  0xc(%ebp)
  801b96:	ff 75 08             	pushl  0x8(%ebp)
  801b99:	e8 3a 02 00 00       	call   801dd8 <nsipc_socket>
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 05                	js     801baa <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ba5:	e8 a5 fe ff ff       	call   801a4f <alloc_sockfd>
}
  801baa:	c9                   	leave  
  801bab:	c3                   	ret    

00801bac <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	53                   	push   %ebx
  801bb0:	83 ec 04             	sub    $0x4,%esp
  801bb3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bb5:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bbc:	75 12                	jne    801bd0 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bbe:	83 ec 0c             	sub    $0xc,%esp
  801bc1:	6a 02                	push   $0x2
  801bc3:	e8 8e 08 00 00       	call   802456 <ipc_find_env>
  801bc8:	a3 04 40 80 00       	mov    %eax,0x804004
  801bcd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bd0:	6a 07                	push   $0x7
  801bd2:	68 00 60 80 00       	push   $0x806000
  801bd7:	53                   	push   %ebx
  801bd8:	ff 35 04 40 80 00    	pushl  0x804004
  801bde:	e8 1f 08 00 00       	call   802402 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801be3:	83 c4 0c             	add    $0xc,%esp
  801be6:	6a 00                	push   $0x0
  801be8:	6a 00                	push   $0x0
  801bea:	6a 00                	push   $0x0
  801bec:	e8 aa 07 00 00       	call   80239b <ipc_recv>
}
  801bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	56                   	push   %esi
  801bfa:	53                   	push   %ebx
  801bfb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801c01:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c06:	8b 06                	mov    (%esi),%eax
  801c08:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c12:	e8 95 ff ff ff       	call   801bac <nsipc>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 20                	js     801c3d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c1d:	83 ec 04             	sub    $0x4,%esp
  801c20:	ff 35 10 60 80 00    	pushl  0x806010
  801c26:	68 00 60 80 00       	push   $0x806000
  801c2b:	ff 75 0c             	pushl  0xc(%ebp)
  801c2e:	e8 d5 ed ff ff       	call   800a08 <memmove>
		*addrlen = ret->ret_addrlen;
  801c33:	a1 10 60 80 00       	mov    0x806010,%eax
  801c38:	89 06                	mov    %eax,(%esi)
  801c3a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c3d:	89 d8                	mov    %ebx,%eax
  801c3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5e                   	pop    %esi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	53                   	push   %ebx
  801c4a:	83 ec 08             	sub    $0x8,%esp
  801c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c58:	53                   	push   %ebx
  801c59:	ff 75 0c             	pushl  0xc(%ebp)
  801c5c:	68 04 60 80 00       	push   $0x806004
  801c61:	e8 a2 ed ff ff       	call   800a08 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c66:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c6c:	b8 02 00 00 00       	mov    $0x2,%eax
  801c71:	e8 36 ff ff ff       	call   801bac <nsipc>
}
  801c76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c91:	b8 03 00 00 00       	mov    $0x3,%eax
  801c96:	e8 11 ff ff ff       	call   801bac <nsipc>
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <nsipc_close>:

int
nsipc_close(int s)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cab:	b8 04 00 00 00       	mov    $0x4,%eax
  801cb0:	e8 f7 fe ff ff       	call   801bac <nsipc>
}
  801cb5:	c9                   	leave  
  801cb6:	c3                   	ret    

00801cb7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	53                   	push   %ebx
  801cbb:	83 ec 08             	sub    $0x8,%esp
  801cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cc9:	53                   	push   %ebx
  801cca:	ff 75 0c             	pushl  0xc(%ebp)
  801ccd:	68 04 60 80 00       	push   $0x806004
  801cd2:	e8 31 ed ff ff       	call   800a08 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cd7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cdd:	b8 05 00 00 00       	mov    $0x5,%eax
  801ce2:	e8 c5 fe ff ff       	call   801bac <nsipc>
}
  801ce7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d02:	b8 06 00 00 00       	mov    $0x6,%eax
  801d07:	e8 a0 fe ff ff       	call   801bac <nsipc>
}
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	56                   	push   %esi
  801d12:	53                   	push   %ebx
  801d13:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d16:	8b 45 08             	mov    0x8(%ebp),%eax
  801d19:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d1e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d24:	8b 45 14             	mov    0x14(%ebp),%eax
  801d27:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d2c:	b8 07 00 00 00       	mov    $0x7,%eax
  801d31:	e8 76 fe ff ff       	call   801bac <nsipc>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 35                	js     801d71 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d3c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d41:	7f 04                	jg     801d47 <nsipc_recv+0x39>
  801d43:	39 c6                	cmp    %eax,%esi
  801d45:	7d 16                	jge    801d5d <nsipc_recv+0x4f>
  801d47:	68 77 2d 80 00       	push   $0x802d77
  801d4c:	68 3f 2d 80 00       	push   $0x802d3f
  801d51:	6a 62                	push   $0x62
  801d53:	68 8c 2d 80 00       	push   $0x802d8c
  801d58:	e8 bb e4 ff ff       	call   800218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d5d:	83 ec 04             	sub    $0x4,%esp
  801d60:	50                   	push   %eax
  801d61:	68 00 60 80 00       	push   $0x806000
  801d66:	ff 75 0c             	pushl  0xc(%ebp)
  801d69:	e8 9a ec ff ff       	call   800a08 <memmove>
  801d6e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d71:	89 d8                	mov    %ebx,%eax
  801d73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5e                   	pop    %esi
  801d78:	5d                   	pop    %ebp
  801d79:	c3                   	ret    

00801d7a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	53                   	push   %ebx
  801d7e:	83 ec 04             	sub    $0x4,%esp
  801d81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d84:	8b 45 08             	mov    0x8(%ebp),%eax
  801d87:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d8c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d92:	7e 16                	jle    801daa <nsipc_send+0x30>
  801d94:	68 98 2d 80 00       	push   $0x802d98
  801d99:	68 3f 2d 80 00       	push   $0x802d3f
  801d9e:	6a 6d                	push   $0x6d
  801da0:	68 8c 2d 80 00       	push   $0x802d8c
  801da5:	e8 6e e4 ff ff       	call   800218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801daa:	83 ec 04             	sub    $0x4,%esp
  801dad:	53                   	push   %ebx
  801dae:	ff 75 0c             	pushl  0xc(%ebp)
  801db1:	68 0c 60 80 00       	push   $0x80600c
  801db6:	e8 4d ec ff ff       	call   800a08 <memmove>
	nsipcbuf.send.req_size = size;
  801dbb:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801dc1:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dc9:	b8 08 00 00 00       	mov    $0x8,%eax
  801dce:	e8 d9 fd ff ff       	call   801bac <nsipc>
}
  801dd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd6:	c9                   	leave  
  801dd7:	c3                   	ret    

00801dd8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dde:	8b 45 08             	mov    0x8(%ebp),%eax
  801de1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801de6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de9:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dee:	8b 45 10             	mov    0x10(%ebp),%eax
  801df1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801df6:	b8 09 00 00 00       	mov    $0x9,%eax
  801dfb:	e8 ac fd ff ff       	call   801bac <nsipc>
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	56                   	push   %esi
  801e06:	53                   	push   %ebx
  801e07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e0a:	83 ec 0c             	sub    $0xc,%esp
  801e0d:	ff 75 08             	pushl  0x8(%ebp)
  801e10:	e8 98 f3 ff ff       	call   8011ad <fd2data>
  801e15:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e17:	83 c4 08             	add    $0x8,%esp
  801e1a:	68 a4 2d 80 00       	push   $0x802da4
  801e1f:	53                   	push   %ebx
  801e20:	e8 51 ea ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e25:	8b 46 04             	mov    0x4(%esi),%eax
  801e28:	2b 06                	sub    (%esi),%eax
  801e2a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e30:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e37:	00 00 00 
	stat->st_dev = &devpipe;
  801e3a:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e41:	30 80 00 
	return 0;
}
  801e44:	b8 00 00 00 00       	mov    $0x0,%eax
  801e49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4c:	5b                   	pop    %ebx
  801e4d:	5e                   	pop    %esi
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	53                   	push   %ebx
  801e54:	83 ec 0c             	sub    $0xc,%esp
  801e57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e5a:	53                   	push   %ebx
  801e5b:	6a 00                	push   $0x0
  801e5d:	e8 9c ee ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e62:	89 1c 24             	mov    %ebx,(%esp)
  801e65:	e8 43 f3 ff ff       	call   8011ad <fd2data>
  801e6a:	83 c4 08             	add    $0x8,%esp
  801e6d:	50                   	push   %eax
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 89 ee ff ff       	call   800cfe <sys_page_unmap>
}
  801e75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    

00801e7a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	57                   	push   %edi
  801e7e:	56                   	push   %esi
  801e7f:	53                   	push   %ebx
  801e80:	83 ec 1c             	sub    $0x1c,%esp
  801e83:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e86:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e88:	a1 20 44 80 00       	mov    0x804420,%eax
  801e8d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e90:	83 ec 0c             	sub    $0xc,%esp
  801e93:	ff 75 e0             	pushl  -0x20(%ebp)
  801e96:	e8 f4 05 00 00       	call   80248f <pageref>
  801e9b:	89 c3                	mov    %eax,%ebx
  801e9d:	89 3c 24             	mov    %edi,(%esp)
  801ea0:	e8 ea 05 00 00       	call   80248f <pageref>
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	39 c3                	cmp    %eax,%ebx
  801eaa:	0f 94 c1             	sete   %cl
  801ead:	0f b6 c9             	movzbl %cl,%ecx
  801eb0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801eb3:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801eb9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ebc:	39 ce                	cmp    %ecx,%esi
  801ebe:	74 1b                	je     801edb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ec0:	39 c3                	cmp    %eax,%ebx
  801ec2:	75 c4                	jne    801e88 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ec4:	8b 42 58             	mov    0x58(%edx),%eax
  801ec7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801eca:	50                   	push   %eax
  801ecb:	56                   	push   %esi
  801ecc:	68 ab 2d 80 00       	push   $0x802dab
  801ed1:	e8 1b e4 ff ff       	call   8002f1 <cprintf>
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	eb ad                	jmp    801e88 <_pipeisclosed+0xe>
	}
}
  801edb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee1:	5b                   	pop    %ebx
  801ee2:	5e                   	pop    %esi
  801ee3:	5f                   	pop    %edi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    

00801ee6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	57                   	push   %edi
  801eea:	56                   	push   %esi
  801eeb:	53                   	push   %ebx
  801eec:	83 ec 28             	sub    $0x28,%esp
  801eef:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ef2:	56                   	push   %esi
  801ef3:	e8 b5 f2 ff ff       	call   8011ad <fd2data>
  801ef8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801efa:	83 c4 10             	add    $0x10,%esp
  801efd:	bf 00 00 00 00       	mov    $0x0,%edi
  801f02:	eb 4b                	jmp    801f4f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f04:	89 da                	mov    %ebx,%edx
  801f06:	89 f0                	mov    %esi,%eax
  801f08:	e8 6d ff ff ff       	call   801e7a <_pipeisclosed>
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	75 48                	jne    801f59 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f11:	e8 44 ed ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f16:	8b 43 04             	mov    0x4(%ebx),%eax
  801f19:	8b 0b                	mov    (%ebx),%ecx
  801f1b:	8d 51 20             	lea    0x20(%ecx),%edx
  801f1e:	39 d0                	cmp    %edx,%eax
  801f20:	73 e2                	jae    801f04 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f25:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f29:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f2c:	89 c2                	mov    %eax,%edx
  801f2e:	c1 fa 1f             	sar    $0x1f,%edx
  801f31:	89 d1                	mov    %edx,%ecx
  801f33:	c1 e9 1b             	shr    $0x1b,%ecx
  801f36:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f39:	83 e2 1f             	and    $0x1f,%edx
  801f3c:	29 ca                	sub    %ecx,%edx
  801f3e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f42:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f46:	83 c0 01             	add    $0x1,%eax
  801f49:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4c:	83 c7 01             	add    $0x1,%edi
  801f4f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f52:	75 c2                	jne    801f16 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f54:	8b 45 10             	mov    0x10(%ebp),%eax
  801f57:	eb 05                	jmp    801f5e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f61:	5b                   	pop    %ebx
  801f62:	5e                   	pop    %esi
  801f63:	5f                   	pop    %edi
  801f64:	5d                   	pop    %ebp
  801f65:	c3                   	ret    

00801f66 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	57                   	push   %edi
  801f6a:	56                   	push   %esi
  801f6b:	53                   	push   %ebx
  801f6c:	83 ec 18             	sub    $0x18,%esp
  801f6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f72:	57                   	push   %edi
  801f73:	e8 35 f2 ff ff       	call   8011ad <fd2data>
  801f78:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f82:	eb 3d                	jmp    801fc1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f84:	85 db                	test   %ebx,%ebx
  801f86:	74 04                	je     801f8c <devpipe_read+0x26>
				return i;
  801f88:	89 d8                	mov    %ebx,%eax
  801f8a:	eb 44                	jmp    801fd0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f8c:	89 f2                	mov    %esi,%edx
  801f8e:	89 f8                	mov    %edi,%eax
  801f90:	e8 e5 fe ff ff       	call   801e7a <_pipeisclosed>
  801f95:	85 c0                	test   %eax,%eax
  801f97:	75 32                	jne    801fcb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f99:	e8 bc ec ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f9e:	8b 06                	mov    (%esi),%eax
  801fa0:	3b 46 04             	cmp    0x4(%esi),%eax
  801fa3:	74 df                	je     801f84 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fa5:	99                   	cltd   
  801fa6:	c1 ea 1b             	shr    $0x1b,%edx
  801fa9:	01 d0                	add    %edx,%eax
  801fab:	83 e0 1f             	and    $0x1f,%eax
  801fae:	29 d0                	sub    %edx,%eax
  801fb0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fbb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fbe:	83 c3 01             	add    $0x1,%ebx
  801fc1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fc4:	75 d8                	jne    801f9e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fc6:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc9:	eb 05                	jmp    801fd0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fcb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    

00801fd8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	56                   	push   %esi
  801fdc:	53                   	push   %ebx
  801fdd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fe0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe3:	50                   	push   %eax
  801fe4:	e8 db f1 ff ff       	call   8011c4 <fd_alloc>
  801fe9:	83 c4 10             	add    $0x10,%esp
  801fec:	89 c2                	mov    %eax,%edx
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	0f 88 2c 01 00 00    	js     802122 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff6:	83 ec 04             	sub    $0x4,%esp
  801ff9:	68 07 04 00 00       	push   $0x407
  801ffe:	ff 75 f4             	pushl  -0xc(%ebp)
  802001:	6a 00                	push   $0x0
  802003:	e8 71 ec ff ff       	call   800c79 <sys_page_alloc>
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	89 c2                	mov    %eax,%edx
  80200d:	85 c0                	test   %eax,%eax
  80200f:	0f 88 0d 01 00 00    	js     802122 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802015:	83 ec 0c             	sub    $0xc,%esp
  802018:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80201b:	50                   	push   %eax
  80201c:	e8 a3 f1 ff ff       	call   8011c4 <fd_alloc>
  802021:	89 c3                	mov    %eax,%ebx
  802023:	83 c4 10             	add    $0x10,%esp
  802026:	85 c0                	test   %eax,%eax
  802028:	0f 88 e2 00 00 00    	js     802110 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202e:	83 ec 04             	sub    $0x4,%esp
  802031:	68 07 04 00 00       	push   $0x407
  802036:	ff 75 f0             	pushl  -0x10(%ebp)
  802039:	6a 00                	push   $0x0
  80203b:	e8 39 ec ff ff       	call   800c79 <sys_page_alloc>
  802040:	89 c3                	mov    %eax,%ebx
  802042:	83 c4 10             	add    $0x10,%esp
  802045:	85 c0                	test   %eax,%eax
  802047:	0f 88 c3 00 00 00    	js     802110 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80204d:	83 ec 0c             	sub    $0xc,%esp
  802050:	ff 75 f4             	pushl  -0xc(%ebp)
  802053:	e8 55 f1 ff ff       	call   8011ad <fd2data>
  802058:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205a:	83 c4 0c             	add    $0xc,%esp
  80205d:	68 07 04 00 00       	push   $0x407
  802062:	50                   	push   %eax
  802063:	6a 00                	push   $0x0
  802065:	e8 0f ec ff ff       	call   800c79 <sys_page_alloc>
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	85 c0                	test   %eax,%eax
  802071:	0f 88 89 00 00 00    	js     802100 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802077:	83 ec 0c             	sub    $0xc,%esp
  80207a:	ff 75 f0             	pushl  -0x10(%ebp)
  80207d:	e8 2b f1 ff ff       	call   8011ad <fd2data>
  802082:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802089:	50                   	push   %eax
  80208a:	6a 00                	push   $0x0
  80208c:	56                   	push   %esi
  80208d:	6a 00                	push   $0x0
  80208f:	e8 28 ec ff ff       	call   800cbc <sys_page_map>
  802094:	89 c3                	mov    %eax,%ebx
  802096:	83 c4 20             	add    $0x20,%esp
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 55                	js     8020f2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80209d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020b2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020bb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020c0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020c7:	83 ec 0c             	sub    $0xc,%esp
  8020ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8020cd:	e8 cb f0 ff ff       	call   80119d <fd2num>
  8020d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020d7:	83 c4 04             	add    $0x4,%esp
  8020da:	ff 75 f0             	pushl  -0x10(%ebp)
  8020dd:	e8 bb f0 ff ff       	call   80119d <fd2num>
  8020e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020e5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f0:	eb 30                	jmp    802122 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020f2:	83 ec 08             	sub    $0x8,%esp
  8020f5:	56                   	push   %esi
  8020f6:	6a 00                	push   $0x0
  8020f8:	e8 01 ec ff ff       	call   800cfe <sys_page_unmap>
  8020fd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802100:	83 ec 08             	sub    $0x8,%esp
  802103:	ff 75 f0             	pushl  -0x10(%ebp)
  802106:	6a 00                	push   $0x0
  802108:	e8 f1 eb ff ff       	call   800cfe <sys_page_unmap>
  80210d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802110:	83 ec 08             	sub    $0x8,%esp
  802113:	ff 75 f4             	pushl  -0xc(%ebp)
  802116:	6a 00                	push   $0x0
  802118:	e8 e1 eb ff ff       	call   800cfe <sys_page_unmap>
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802122:	89 d0                	mov    %edx,%eax
  802124:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802127:	5b                   	pop    %ebx
  802128:	5e                   	pop    %esi
  802129:	5d                   	pop    %ebp
  80212a:	c3                   	ret    

0080212b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80212b:	55                   	push   %ebp
  80212c:	89 e5                	mov    %esp,%ebp
  80212e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802131:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802134:	50                   	push   %eax
  802135:	ff 75 08             	pushl  0x8(%ebp)
  802138:	e8 d6 f0 ff ff       	call   801213 <fd_lookup>
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	85 c0                	test   %eax,%eax
  802142:	78 18                	js     80215c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802144:	83 ec 0c             	sub    $0xc,%esp
  802147:	ff 75 f4             	pushl  -0xc(%ebp)
  80214a:	e8 5e f0 ff ff       	call   8011ad <fd2data>
	return _pipeisclosed(fd, p);
  80214f:	89 c2                	mov    %eax,%edx
  802151:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802154:	e8 21 fd ff ff       	call   801e7a <_pipeisclosed>
  802159:	83 c4 10             	add    $0x10,%esp
}
  80215c:	c9                   	leave  
  80215d:	c3                   	ret    

0080215e <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80215e:	55                   	push   %ebp
  80215f:	89 e5                	mov    %esp,%ebp
  802161:	56                   	push   %esi
  802162:	53                   	push   %ebx
  802163:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802166:	85 f6                	test   %esi,%esi
  802168:	75 16                	jne    802180 <wait+0x22>
  80216a:	68 c3 2d 80 00       	push   $0x802dc3
  80216f:	68 3f 2d 80 00       	push   $0x802d3f
  802174:	6a 09                	push   $0x9
  802176:	68 ce 2d 80 00       	push   $0x802dce
  80217b:	e8 98 e0 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  802180:	89 f3                	mov    %esi,%ebx
  802182:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802188:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80218b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802191:	eb 05                	jmp    802198 <wait+0x3a>
		sys_yield();
  802193:	e8 c2 ea ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802198:	8b 43 48             	mov    0x48(%ebx),%eax
  80219b:	39 c6                	cmp    %eax,%esi
  80219d:	75 07                	jne    8021a6 <wait+0x48>
  80219f:	8b 43 54             	mov    0x54(%ebx),%eax
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	75 ed                	jne    802193 <wait+0x35>
		sys_yield();
}
  8021a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a9:	5b                   	pop    %ebx
  8021aa:	5e                   	pop    %esi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    

008021ad <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021ad:	55                   	push   %ebp
  8021ae:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b5:	5d                   	pop    %ebp
  8021b6:	c3                   	ret    

008021b7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021b7:	55                   	push   %ebp
  8021b8:	89 e5                	mov    %esp,%ebp
  8021ba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021bd:	68 d9 2d 80 00       	push   $0x802dd9
  8021c2:	ff 75 0c             	pushl  0xc(%ebp)
  8021c5:	e8 ac e6 ff ff       	call   800876 <strcpy>
	return 0;
}
  8021ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8021cf:	c9                   	leave  
  8021d0:	c3                   	ret    

008021d1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021d1:	55                   	push   %ebp
  8021d2:	89 e5                	mov    %esp,%ebp
  8021d4:	57                   	push   %edi
  8021d5:	56                   	push   %esi
  8021d6:	53                   	push   %ebx
  8021d7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021dd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021e2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021e8:	eb 2d                	jmp    802217 <devcons_write+0x46>
		m = n - tot;
  8021ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021ed:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021ef:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021f2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021f7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021fa:	83 ec 04             	sub    $0x4,%esp
  8021fd:	53                   	push   %ebx
  8021fe:	03 45 0c             	add    0xc(%ebp),%eax
  802201:	50                   	push   %eax
  802202:	57                   	push   %edi
  802203:	e8 00 e8 ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  802208:	83 c4 08             	add    $0x8,%esp
  80220b:	53                   	push   %ebx
  80220c:	57                   	push   %edi
  80220d:	e8 ab e9 ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802212:	01 de                	add    %ebx,%esi
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	89 f0                	mov    %esi,%eax
  802219:	3b 75 10             	cmp    0x10(%ebp),%esi
  80221c:	72 cc                	jb     8021ea <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80221e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5f                   	pop    %edi
  802224:	5d                   	pop    %ebp
  802225:	c3                   	ret    

00802226 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	83 ec 08             	sub    $0x8,%esp
  80222c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802231:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802235:	74 2a                	je     802261 <devcons_read+0x3b>
  802237:	eb 05                	jmp    80223e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802239:	e8 1c ea ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80223e:	e8 98 e9 ff ff       	call   800bdb <sys_cgetc>
  802243:	85 c0                	test   %eax,%eax
  802245:	74 f2                	je     802239 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802247:	85 c0                	test   %eax,%eax
  802249:	78 16                	js     802261 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80224b:	83 f8 04             	cmp    $0x4,%eax
  80224e:	74 0c                	je     80225c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802250:	8b 55 0c             	mov    0xc(%ebp),%edx
  802253:	88 02                	mov    %al,(%edx)
	return 1;
  802255:	b8 01 00 00 00       	mov    $0x1,%eax
  80225a:	eb 05                	jmp    802261 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80225c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802261:	c9                   	leave  
  802262:	c3                   	ret    

00802263 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802269:	8b 45 08             	mov    0x8(%ebp),%eax
  80226c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80226f:	6a 01                	push   $0x1
  802271:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802274:	50                   	push   %eax
  802275:	e8 43 e9 ff ff       	call   800bbd <sys_cputs>
}
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	c9                   	leave  
  80227e:	c3                   	ret    

0080227f <getchar>:

int
getchar(void)
{
  80227f:	55                   	push   %ebp
  802280:	89 e5                	mov    %esp,%ebp
  802282:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802285:	6a 01                	push   $0x1
  802287:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80228a:	50                   	push   %eax
  80228b:	6a 00                	push   $0x0
  80228d:	e8 e7 f1 ff ff       	call   801479 <read>
	if (r < 0)
  802292:	83 c4 10             	add    $0x10,%esp
  802295:	85 c0                	test   %eax,%eax
  802297:	78 0f                	js     8022a8 <getchar+0x29>
		return r;
	if (r < 1)
  802299:	85 c0                	test   %eax,%eax
  80229b:	7e 06                	jle    8022a3 <getchar+0x24>
		return -E_EOF;
	return c;
  80229d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022a1:	eb 05                	jmp    8022a8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022a3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022a8:	c9                   	leave  
  8022a9:	c3                   	ret    

008022aa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022aa:	55                   	push   %ebp
  8022ab:	89 e5                	mov    %esp,%ebp
  8022ad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b3:	50                   	push   %eax
  8022b4:	ff 75 08             	pushl  0x8(%ebp)
  8022b7:	e8 57 ef ff ff       	call   801213 <fd_lookup>
  8022bc:	83 c4 10             	add    $0x10,%esp
  8022bf:	85 c0                	test   %eax,%eax
  8022c1:	78 11                	js     8022d4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022cc:	39 10                	cmp    %edx,(%eax)
  8022ce:	0f 94 c0             	sete   %al
  8022d1:	0f b6 c0             	movzbl %al,%eax
}
  8022d4:	c9                   	leave  
  8022d5:	c3                   	ret    

008022d6 <opencons>:

int
opencons(void)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022df:	50                   	push   %eax
  8022e0:	e8 df ee ff ff       	call   8011c4 <fd_alloc>
  8022e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8022e8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	78 3e                	js     80232c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ee:	83 ec 04             	sub    $0x4,%esp
  8022f1:	68 07 04 00 00       	push   $0x407
  8022f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f9:	6a 00                	push   $0x0
  8022fb:	e8 79 e9 ff ff       	call   800c79 <sys_page_alloc>
  802300:	83 c4 10             	add    $0x10,%esp
		return r;
  802303:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802305:	85 c0                	test   %eax,%eax
  802307:	78 23                	js     80232c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802309:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80230f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802312:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802314:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802317:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80231e:	83 ec 0c             	sub    $0xc,%esp
  802321:	50                   	push   %eax
  802322:	e8 76 ee ff ff       	call   80119d <fd2num>
  802327:	89 c2                	mov    %eax,%edx
  802329:	83 c4 10             	add    $0x10,%esp
}
  80232c:	89 d0                	mov    %edx,%eax
  80232e:	c9                   	leave  
  80232f:	c3                   	ret    

00802330 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802336:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80233d:	75 2e                	jne    80236d <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80233f:	e8 f7 e8 ff ff       	call   800c3b <sys_getenvid>
  802344:	83 ec 04             	sub    $0x4,%esp
  802347:	68 07 0e 00 00       	push   $0xe07
  80234c:	68 00 f0 bf ee       	push   $0xeebff000
  802351:	50                   	push   %eax
  802352:	e8 22 e9 ff ff       	call   800c79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802357:	e8 df e8 ff ff       	call   800c3b <sys_getenvid>
  80235c:	83 c4 08             	add    $0x8,%esp
  80235f:	68 77 23 80 00       	push   $0x802377
  802364:	50                   	push   %eax
  802365:	e8 5a ea ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  80236a:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80236d:	8b 45 08             	mov    0x8(%ebp),%eax
  802370:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802375:	c9                   	leave  
  802376:	c3                   	ret    

00802377 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802377:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802378:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80237d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80237f:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802382:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802386:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80238a:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80238d:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802390:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802391:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802394:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802395:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802396:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80239a:	c3                   	ret    

0080239b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80239b:	55                   	push   %ebp
  80239c:	89 e5                	mov    %esp,%ebp
  80239e:	56                   	push   %esi
  80239f:	53                   	push   %ebx
  8023a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8023a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8023a9:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8023ab:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023b0:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8023b3:	83 ec 0c             	sub    $0xc,%esp
  8023b6:	50                   	push   %eax
  8023b7:	e8 6d ea ff ff       	call   800e29 <sys_ipc_recv>

	if (from_env_store != NULL)
  8023bc:	83 c4 10             	add    $0x10,%esp
  8023bf:	85 f6                	test   %esi,%esi
  8023c1:	74 14                	je     8023d7 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8023c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c8:	85 c0                	test   %eax,%eax
  8023ca:	78 09                	js     8023d5 <ipc_recv+0x3a>
  8023cc:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8023d2:	8b 52 74             	mov    0x74(%edx),%edx
  8023d5:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8023d7:	85 db                	test   %ebx,%ebx
  8023d9:	74 14                	je     8023ef <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8023db:	ba 00 00 00 00       	mov    $0x0,%edx
  8023e0:	85 c0                	test   %eax,%eax
  8023e2:	78 09                	js     8023ed <ipc_recv+0x52>
  8023e4:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8023ea:	8b 52 78             	mov    0x78(%edx),%edx
  8023ed:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	78 08                	js     8023fb <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8023f3:	a1 20 44 80 00       	mov    0x804420,%eax
  8023f8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023fe:	5b                   	pop    %ebx
  8023ff:	5e                   	pop    %esi
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    

00802402 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802402:	55                   	push   %ebp
  802403:	89 e5                	mov    %esp,%ebp
  802405:	57                   	push   %edi
  802406:	56                   	push   %esi
  802407:	53                   	push   %ebx
  802408:	83 ec 0c             	sub    $0xc,%esp
  80240b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80240e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802411:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802414:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802416:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80241b:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80241e:	ff 75 14             	pushl  0x14(%ebp)
  802421:	53                   	push   %ebx
  802422:	56                   	push   %esi
  802423:	57                   	push   %edi
  802424:	e8 dd e9 ff ff       	call   800e06 <sys_ipc_try_send>

		if (err < 0) {
  802429:	83 c4 10             	add    $0x10,%esp
  80242c:	85 c0                	test   %eax,%eax
  80242e:	79 1e                	jns    80244e <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802430:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802433:	75 07                	jne    80243c <ipc_send+0x3a>
				sys_yield();
  802435:	e8 20 e8 ff ff       	call   800c5a <sys_yield>
  80243a:	eb e2                	jmp    80241e <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80243c:	50                   	push   %eax
  80243d:	68 e5 2d 80 00       	push   $0x802de5
  802442:	6a 49                	push   $0x49
  802444:	68 f2 2d 80 00       	push   $0x802df2
  802449:	e8 ca dd ff ff       	call   800218 <_panic>
		}

	} while (err < 0);

}
  80244e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802451:	5b                   	pop    %ebx
  802452:	5e                   	pop    %esi
  802453:	5f                   	pop    %edi
  802454:	5d                   	pop    %ebp
  802455:	c3                   	ret    

00802456 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802456:	55                   	push   %ebp
  802457:	89 e5                	mov    %esp,%ebp
  802459:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80245c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802461:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802464:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80246a:	8b 52 50             	mov    0x50(%edx),%edx
  80246d:	39 ca                	cmp    %ecx,%edx
  80246f:	75 0d                	jne    80247e <ipc_find_env+0x28>
			return envs[i].env_id;
  802471:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802474:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802479:	8b 40 48             	mov    0x48(%eax),%eax
  80247c:	eb 0f                	jmp    80248d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80247e:	83 c0 01             	add    $0x1,%eax
  802481:	3d 00 04 00 00       	cmp    $0x400,%eax
  802486:	75 d9                	jne    802461 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802488:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80248d:	5d                   	pop    %ebp
  80248e:	c3                   	ret    

0080248f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80248f:	55                   	push   %ebp
  802490:	89 e5                	mov    %esp,%ebp
  802492:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802495:	89 d0                	mov    %edx,%eax
  802497:	c1 e8 16             	shr    $0x16,%eax
  80249a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024a1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024a6:	f6 c1 01             	test   $0x1,%cl
  8024a9:	74 1d                	je     8024c8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024ab:	c1 ea 0c             	shr    $0xc,%edx
  8024ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024b5:	f6 c2 01             	test   $0x1,%dl
  8024b8:	74 0e                	je     8024c8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024ba:	c1 ea 0c             	shr    $0xc,%edx
  8024bd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024c4:	ef 
  8024c5:	0f b7 c0             	movzwl %ax,%eax
}
  8024c8:	5d                   	pop    %ebp
  8024c9:	c3                   	ret    
  8024ca:	66 90                	xchg   %ax,%ax
  8024cc:	66 90                	xchg   %ax,%ax
  8024ce:	66 90                	xchg   %ax,%ax

008024d0 <__udivdi3>:
  8024d0:	55                   	push   %ebp
  8024d1:	57                   	push   %edi
  8024d2:	56                   	push   %esi
  8024d3:	53                   	push   %ebx
  8024d4:	83 ec 1c             	sub    $0x1c,%esp
  8024d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024e7:	85 f6                	test   %esi,%esi
  8024e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ed:	89 ca                	mov    %ecx,%edx
  8024ef:	89 f8                	mov    %edi,%eax
  8024f1:	75 3d                	jne    802530 <__udivdi3+0x60>
  8024f3:	39 cf                	cmp    %ecx,%edi
  8024f5:	0f 87 c5 00 00 00    	ja     8025c0 <__udivdi3+0xf0>
  8024fb:	85 ff                	test   %edi,%edi
  8024fd:	89 fd                	mov    %edi,%ebp
  8024ff:	75 0b                	jne    80250c <__udivdi3+0x3c>
  802501:	b8 01 00 00 00       	mov    $0x1,%eax
  802506:	31 d2                	xor    %edx,%edx
  802508:	f7 f7                	div    %edi
  80250a:	89 c5                	mov    %eax,%ebp
  80250c:	89 c8                	mov    %ecx,%eax
  80250e:	31 d2                	xor    %edx,%edx
  802510:	f7 f5                	div    %ebp
  802512:	89 c1                	mov    %eax,%ecx
  802514:	89 d8                	mov    %ebx,%eax
  802516:	89 cf                	mov    %ecx,%edi
  802518:	f7 f5                	div    %ebp
  80251a:	89 c3                	mov    %eax,%ebx
  80251c:	89 d8                	mov    %ebx,%eax
  80251e:	89 fa                	mov    %edi,%edx
  802520:	83 c4 1c             	add    $0x1c,%esp
  802523:	5b                   	pop    %ebx
  802524:	5e                   	pop    %esi
  802525:	5f                   	pop    %edi
  802526:	5d                   	pop    %ebp
  802527:	c3                   	ret    
  802528:	90                   	nop
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	39 ce                	cmp    %ecx,%esi
  802532:	77 74                	ja     8025a8 <__udivdi3+0xd8>
  802534:	0f bd fe             	bsr    %esi,%edi
  802537:	83 f7 1f             	xor    $0x1f,%edi
  80253a:	0f 84 98 00 00 00    	je     8025d8 <__udivdi3+0x108>
  802540:	bb 20 00 00 00       	mov    $0x20,%ebx
  802545:	89 f9                	mov    %edi,%ecx
  802547:	89 c5                	mov    %eax,%ebp
  802549:	29 fb                	sub    %edi,%ebx
  80254b:	d3 e6                	shl    %cl,%esi
  80254d:	89 d9                	mov    %ebx,%ecx
  80254f:	d3 ed                	shr    %cl,%ebp
  802551:	89 f9                	mov    %edi,%ecx
  802553:	d3 e0                	shl    %cl,%eax
  802555:	09 ee                	or     %ebp,%esi
  802557:	89 d9                	mov    %ebx,%ecx
  802559:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80255d:	89 d5                	mov    %edx,%ebp
  80255f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802563:	d3 ed                	shr    %cl,%ebp
  802565:	89 f9                	mov    %edi,%ecx
  802567:	d3 e2                	shl    %cl,%edx
  802569:	89 d9                	mov    %ebx,%ecx
  80256b:	d3 e8                	shr    %cl,%eax
  80256d:	09 c2                	or     %eax,%edx
  80256f:	89 d0                	mov    %edx,%eax
  802571:	89 ea                	mov    %ebp,%edx
  802573:	f7 f6                	div    %esi
  802575:	89 d5                	mov    %edx,%ebp
  802577:	89 c3                	mov    %eax,%ebx
  802579:	f7 64 24 0c          	mull   0xc(%esp)
  80257d:	39 d5                	cmp    %edx,%ebp
  80257f:	72 10                	jb     802591 <__udivdi3+0xc1>
  802581:	8b 74 24 08          	mov    0x8(%esp),%esi
  802585:	89 f9                	mov    %edi,%ecx
  802587:	d3 e6                	shl    %cl,%esi
  802589:	39 c6                	cmp    %eax,%esi
  80258b:	73 07                	jae    802594 <__udivdi3+0xc4>
  80258d:	39 d5                	cmp    %edx,%ebp
  80258f:	75 03                	jne    802594 <__udivdi3+0xc4>
  802591:	83 eb 01             	sub    $0x1,%ebx
  802594:	31 ff                	xor    %edi,%edi
  802596:	89 d8                	mov    %ebx,%eax
  802598:	89 fa                	mov    %edi,%edx
  80259a:	83 c4 1c             	add    $0x1c,%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	31 ff                	xor    %edi,%edi
  8025aa:	31 db                	xor    %ebx,%ebx
  8025ac:	89 d8                	mov    %ebx,%eax
  8025ae:	89 fa                	mov    %edi,%edx
  8025b0:	83 c4 1c             	add    $0x1c,%esp
  8025b3:	5b                   	pop    %ebx
  8025b4:	5e                   	pop    %esi
  8025b5:	5f                   	pop    %edi
  8025b6:	5d                   	pop    %ebp
  8025b7:	c3                   	ret    
  8025b8:	90                   	nop
  8025b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	89 d8                	mov    %ebx,%eax
  8025c2:	f7 f7                	div    %edi
  8025c4:	31 ff                	xor    %edi,%edi
  8025c6:	89 c3                	mov    %eax,%ebx
  8025c8:	89 d8                	mov    %ebx,%eax
  8025ca:	89 fa                	mov    %edi,%edx
  8025cc:	83 c4 1c             	add    $0x1c,%esp
  8025cf:	5b                   	pop    %ebx
  8025d0:	5e                   	pop    %esi
  8025d1:	5f                   	pop    %edi
  8025d2:	5d                   	pop    %ebp
  8025d3:	c3                   	ret    
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	39 ce                	cmp    %ecx,%esi
  8025da:	72 0c                	jb     8025e8 <__udivdi3+0x118>
  8025dc:	31 db                	xor    %ebx,%ebx
  8025de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025e2:	0f 87 34 ff ff ff    	ja     80251c <__udivdi3+0x4c>
  8025e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025ed:	e9 2a ff ff ff       	jmp    80251c <__udivdi3+0x4c>
  8025f2:	66 90                	xchg   %ax,%ax
  8025f4:	66 90                	xchg   %ax,%ax
  8025f6:	66 90                	xchg   %ax,%ax
  8025f8:	66 90                	xchg   %ax,%ax
  8025fa:	66 90                	xchg   %ax,%ax
  8025fc:	66 90                	xchg   %ax,%ax
  8025fe:	66 90                	xchg   %ax,%ax

00802600 <__umoddi3>:
  802600:	55                   	push   %ebp
  802601:	57                   	push   %edi
  802602:	56                   	push   %esi
  802603:	53                   	push   %ebx
  802604:	83 ec 1c             	sub    $0x1c,%esp
  802607:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80260b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80260f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802613:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802617:	85 d2                	test   %edx,%edx
  802619:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80261d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802621:	89 f3                	mov    %esi,%ebx
  802623:	89 3c 24             	mov    %edi,(%esp)
  802626:	89 74 24 04          	mov    %esi,0x4(%esp)
  80262a:	75 1c                	jne    802648 <__umoddi3+0x48>
  80262c:	39 f7                	cmp    %esi,%edi
  80262e:	76 50                	jbe    802680 <__umoddi3+0x80>
  802630:	89 c8                	mov    %ecx,%eax
  802632:	89 f2                	mov    %esi,%edx
  802634:	f7 f7                	div    %edi
  802636:	89 d0                	mov    %edx,%eax
  802638:	31 d2                	xor    %edx,%edx
  80263a:	83 c4 1c             	add    $0x1c,%esp
  80263d:	5b                   	pop    %ebx
  80263e:	5e                   	pop    %esi
  80263f:	5f                   	pop    %edi
  802640:	5d                   	pop    %ebp
  802641:	c3                   	ret    
  802642:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802648:	39 f2                	cmp    %esi,%edx
  80264a:	89 d0                	mov    %edx,%eax
  80264c:	77 52                	ja     8026a0 <__umoddi3+0xa0>
  80264e:	0f bd ea             	bsr    %edx,%ebp
  802651:	83 f5 1f             	xor    $0x1f,%ebp
  802654:	75 5a                	jne    8026b0 <__umoddi3+0xb0>
  802656:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80265a:	0f 82 e0 00 00 00    	jb     802740 <__umoddi3+0x140>
  802660:	39 0c 24             	cmp    %ecx,(%esp)
  802663:	0f 86 d7 00 00 00    	jbe    802740 <__umoddi3+0x140>
  802669:	8b 44 24 08          	mov    0x8(%esp),%eax
  80266d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802671:	83 c4 1c             	add    $0x1c,%esp
  802674:	5b                   	pop    %ebx
  802675:	5e                   	pop    %esi
  802676:	5f                   	pop    %edi
  802677:	5d                   	pop    %ebp
  802678:	c3                   	ret    
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	85 ff                	test   %edi,%edi
  802682:	89 fd                	mov    %edi,%ebp
  802684:	75 0b                	jne    802691 <__umoddi3+0x91>
  802686:	b8 01 00 00 00       	mov    $0x1,%eax
  80268b:	31 d2                	xor    %edx,%edx
  80268d:	f7 f7                	div    %edi
  80268f:	89 c5                	mov    %eax,%ebp
  802691:	89 f0                	mov    %esi,%eax
  802693:	31 d2                	xor    %edx,%edx
  802695:	f7 f5                	div    %ebp
  802697:	89 c8                	mov    %ecx,%eax
  802699:	f7 f5                	div    %ebp
  80269b:	89 d0                	mov    %edx,%eax
  80269d:	eb 99                	jmp    802638 <__umoddi3+0x38>
  80269f:	90                   	nop
  8026a0:	89 c8                	mov    %ecx,%eax
  8026a2:	89 f2                	mov    %esi,%edx
  8026a4:	83 c4 1c             	add    $0x1c,%esp
  8026a7:	5b                   	pop    %ebx
  8026a8:	5e                   	pop    %esi
  8026a9:	5f                   	pop    %edi
  8026aa:	5d                   	pop    %ebp
  8026ab:	c3                   	ret    
  8026ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	8b 34 24             	mov    (%esp),%esi
  8026b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026b8:	89 e9                	mov    %ebp,%ecx
  8026ba:	29 ef                	sub    %ebp,%edi
  8026bc:	d3 e0                	shl    %cl,%eax
  8026be:	89 f9                	mov    %edi,%ecx
  8026c0:	89 f2                	mov    %esi,%edx
  8026c2:	d3 ea                	shr    %cl,%edx
  8026c4:	89 e9                	mov    %ebp,%ecx
  8026c6:	09 c2                	or     %eax,%edx
  8026c8:	89 d8                	mov    %ebx,%eax
  8026ca:	89 14 24             	mov    %edx,(%esp)
  8026cd:	89 f2                	mov    %esi,%edx
  8026cf:	d3 e2                	shl    %cl,%edx
  8026d1:	89 f9                	mov    %edi,%ecx
  8026d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026db:	d3 e8                	shr    %cl,%eax
  8026dd:	89 e9                	mov    %ebp,%ecx
  8026df:	89 c6                	mov    %eax,%esi
  8026e1:	d3 e3                	shl    %cl,%ebx
  8026e3:	89 f9                	mov    %edi,%ecx
  8026e5:	89 d0                	mov    %edx,%eax
  8026e7:	d3 e8                	shr    %cl,%eax
  8026e9:	89 e9                	mov    %ebp,%ecx
  8026eb:	09 d8                	or     %ebx,%eax
  8026ed:	89 d3                	mov    %edx,%ebx
  8026ef:	89 f2                	mov    %esi,%edx
  8026f1:	f7 34 24             	divl   (%esp)
  8026f4:	89 d6                	mov    %edx,%esi
  8026f6:	d3 e3                	shl    %cl,%ebx
  8026f8:	f7 64 24 04          	mull   0x4(%esp)
  8026fc:	39 d6                	cmp    %edx,%esi
  8026fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802702:	89 d1                	mov    %edx,%ecx
  802704:	89 c3                	mov    %eax,%ebx
  802706:	72 08                	jb     802710 <__umoddi3+0x110>
  802708:	75 11                	jne    80271b <__umoddi3+0x11b>
  80270a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80270e:	73 0b                	jae    80271b <__umoddi3+0x11b>
  802710:	2b 44 24 04          	sub    0x4(%esp),%eax
  802714:	1b 14 24             	sbb    (%esp),%edx
  802717:	89 d1                	mov    %edx,%ecx
  802719:	89 c3                	mov    %eax,%ebx
  80271b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80271f:	29 da                	sub    %ebx,%edx
  802721:	19 ce                	sbb    %ecx,%esi
  802723:	89 f9                	mov    %edi,%ecx
  802725:	89 f0                	mov    %esi,%eax
  802727:	d3 e0                	shl    %cl,%eax
  802729:	89 e9                	mov    %ebp,%ecx
  80272b:	d3 ea                	shr    %cl,%edx
  80272d:	89 e9                	mov    %ebp,%ecx
  80272f:	d3 ee                	shr    %cl,%esi
  802731:	09 d0                	or     %edx,%eax
  802733:	89 f2                	mov    %esi,%edx
  802735:	83 c4 1c             	add    $0x1c,%esp
  802738:	5b                   	pop    %ebx
  802739:	5e                   	pop    %esi
  80273a:	5f                   	pop    %edi
  80273b:	5d                   	pop    %ebp
  80273c:	c3                   	ret    
  80273d:	8d 76 00             	lea    0x0(%esi),%esi
  802740:	29 f9                	sub    %edi,%ecx
  802742:	19 d6                	sbb    %edx,%esi
  802744:	89 74 24 04          	mov    %esi,0x4(%esp)
  802748:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80274c:	e9 18 ff ff ff       	jmp    802669 <__umoddi3+0x69>
