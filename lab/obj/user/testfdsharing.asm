
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
  80003e:	68 00 22 80 00       	push   $0x802200
  800043:	e8 b7 17 00 00       	call   8017ff <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 05 22 80 00       	push   $0x802205
  800057:	6a 0c                	push   $0xc
  800059:	68 13 22 80 00       	push   $0x802213
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 98 14 00 00       	call   801506 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 b0 13 00 00       	call   801431 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 28 22 80 00       	push   $0x802228
  800090:	6a 0f                	push   $0xf
  800092:	68 13 22 80 00       	push   $0x802213
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 a2 0e 00 00       	call   800f43 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 32 22 80 00       	push   $0x802232
  8000ad:	6a 12                	push   $0x12
  8000af:	68 13 22 80 00       	push   $0x802213
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 3a 14 00 00       	call   801506 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 70 22 80 00 	movl   $0x802270,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 46 13 00 00       	call   801431 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 b4 22 80 00       	push   $0x8022b4
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 13 22 80 00       	push   $0x802213
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
  800125:	68 e0 22 80 00       	push   $0x8022e0
  80012a:	6a 19                	push   $0x19
  80012c:	68 13 22 80 00       	push   $0x802213
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 3b 22 80 00       	push   $0x80223b
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 b8 13 00 00       	call   801506 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 0e 11 00 00       	call   801264 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 98 1a 00 00       	call   801bff <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 b7 12 00 00       	call   801431 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 18 23 80 00       	push   $0x802318
  80018b:	6a 21                	push   $0x21
  80018d:	68 13 22 80 00       	push   $0x802213
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 54 22 80 00       	push   $0x802254
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 b8 10 00 00       	call   801264 <close>
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
  800204:	e8 86 10 00 00       	call   80128f <close_all>
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
  800236:	68 48 23 80 00       	push   $0x802348
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 52 22 80 00 	movl   $0x802252,(%esp)
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
  800354:	e8 17 1c 00 00       	call   801f70 <__udivdi3>
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
  800397:	e8 04 1d 00 00       	call   8020a0 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 6b 23 80 00 	movsbl 0x80236b(%eax),%eax
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
  80049b:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
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
  80055f:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 83 23 80 00       	push   $0x802383
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
  800583:	68 16 28 80 00       	push   $0x802816
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
  8005a7:	b8 7c 23 80 00       	mov    $0x80237c,%eax
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
  800c22:	68 5f 26 80 00       	push   $0x80265f
  800c27:	6a 23                	push   $0x23
  800c29:	68 7c 26 80 00       	push   $0x80267c
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
  800ca3:	68 5f 26 80 00       	push   $0x80265f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 7c 26 80 00       	push   $0x80267c
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
  800ce5:	68 5f 26 80 00       	push   $0x80265f
  800cea:	6a 23                	push   $0x23
  800cec:	68 7c 26 80 00       	push   $0x80267c
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
  800d27:	68 5f 26 80 00       	push   $0x80265f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 7c 26 80 00       	push   $0x80267c
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
  800d69:	68 5f 26 80 00       	push   $0x80265f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 7c 26 80 00       	push   $0x80267c
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
  800dab:	68 5f 26 80 00       	push   $0x80265f
  800db0:	6a 23                	push   $0x23
  800db2:	68 7c 26 80 00       	push   $0x80267c
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
  800ded:	68 5f 26 80 00       	push   $0x80265f
  800df2:	6a 23                	push   $0x23
  800df4:	68 7c 26 80 00       	push   $0x80267c
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
  800e51:	68 5f 26 80 00       	push   $0x80265f
  800e56:	6a 23                	push   $0x23
  800e58:	68 7c 26 80 00       	push   $0x80267c
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

00800e6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e72:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e78:	75 25                	jne    800e9f <pgfault+0x35>
  800e7a:	89 d8                	mov    %ebx,%eax
  800e7c:	c1 e8 0c             	shr    $0xc,%eax
  800e7f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e86:	f6 c4 08             	test   $0x8,%ah
  800e89:	75 14                	jne    800e9f <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	68 8c 26 80 00       	push   $0x80268c
  800e93:	6a 1e                	push   $0x1e
  800e95:	68 20 27 80 00       	push   $0x802720
  800e9a:	e8 79 f3 ff ff       	call   800218 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e9f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ea5:	e8 91 fd ff ff       	call   800c3b <sys_getenvid>
  800eaa:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	6a 07                	push   $0x7
  800eb1:	68 00 f0 7f 00       	push   $0x7ff000
  800eb6:	50                   	push   %eax
  800eb7:	e8 bd fd ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 12                	jns    800ed5 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ec3:	50                   	push   %eax
  800ec4:	68 b8 26 80 00       	push   $0x8026b8
  800ec9:	6a 31                	push   $0x31
  800ecb:	68 20 27 80 00       	push   $0x802720
  800ed0:	e8 43 f3 ff ff       	call   800218 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	68 00 10 00 00       	push   $0x1000
  800edd:	53                   	push   %ebx
  800ede:	68 00 f0 7f 00       	push   $0x7ff000
  800ee3:	e8 88 fb ff ff       	call   800a70 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ee8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eef:	53                   	push   %ebx
  800ef0:	56                   	push   %esi
  800ef1:	68 00 f0 7f 00       	push   $0x7ff000
  800ef6:	56                   	push   %esi
  800ef7:	e8 c0 fd ff ff       	call   800cbc <sys_page_map>
	if (r < 0)
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	79 12                	jns    800f15 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f03:	50                   	push   %eax
  800f04:	68 dc 26 80 00       	push   $0x8026dc
  800f09:	6a 39                	push   $0x39
  800f0b:	68 20 27 80 00       	push   $0x802720
  800f10:	e8 03 f3 ff ff       	call   800218 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f15:	83 ec 08             	sub    $0x8,%esp
  800f18:	68 00 f0 7f 00       	push   $0x7ff000
  800f1d:	56                   	push   %esi
  800f1e:	e8 db fd ff ff       	call   800cfe <sys_page_unmap>
	if (r < 0)
  800f23:	83 c4 10             	add    $0x10,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	79 12                	jns    800f3c <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f2a:	50                   	push   %eax
  800f2b:	68 00 27 80 00       	push   $0x802700
  800f30:	6a 3e                	push   $0x3e
  800f32:	68 20 27 80 00       	push   $0x802720
  800f37:	e8 dc f2 ff ff       	call   800218 <_panic>
}
  800f3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f4c:	68 6a 0e 80 00       	push   $0x800e6a
  800f51:	e8 7b 0e 00 00       	call   801dd1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f56:	b8 07 00 00 00       	mov    $0x7,%eax
  800f5b:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	0f 88 3a 01 00 00    	js     8010a2 <fork+0x15f>
  800f68:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f6d:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f72:	85 c0                	test   %eax,%eax
  800f74:	75 21                	jne    800f97 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f76:	e8 c0 fc ff ff       	call   800c3b <sys_getenvid>
  800f7b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f80:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f83:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f88:	a3 20 44 80 00       	mov    %eax,0x804420
        return 0;
  800f8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f92:	e9 0b 01 00 00       	jmp    8010a2 <fork+0x15f>
  800f97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f9a:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f9c:	89 d8                	mov    %ebx,%eax
  800f9e:	c1 e8 16             	shr    $0x16,%eax
  800fa1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa8:	a8 01                	test   $0x1,%al
  800faa:	0f 84 99 00 00 00    	je     801049 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fb0:	89 d8                	mov    %ebx,%eax
  800fb2:	c1 e8 0c             	shr    $0xc,%eax
  800fb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbc:	f6 c2 01             	test   $0x1,%dl
  800fbf:	0f 84 84 00 00 00    	je     801049 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800fc5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcc:	a9 02 08 00 00       	test   $0x802,%eax
  800fd1:	74 76                	je     801049 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fd3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fda:	a8 02                	test   $0x2,%al
  800fdc:	75 0c                	jne    800fea <fork+0xa7>
  800fde:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe5:	f6 c4 08             	test   $0x8,%ah
  800fe8:	74 3f                	je     801029 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fea:	83 ec 0c             	sub    $0xc,%esp
  800fed:	68 05 08 00 00       	push   $0x805
  800ff2:	53                   	push   %ebx
  800ff3:	57                   	push   %edi
  800ff4:	53                   	push   %ebx
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 c0 fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0)
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	0f 88 9b 00 00 00    	js     8010a2 <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	68 05 08 00 00       	push   $0x805
  80100f:	53                   	push   %ebx
  801010:	6a 00                	push   $0x0
  801012:	53                   	push   %ebx
  801013:	6a 00                	push   $0x0
  801015:	e8 a2 fc ff ff       	call   800cbc <sys_page_map>
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801024:	0f 4f c1             	cmovg  %ecx,%eax
  801027:	eb 1c                	jmp    801045 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	6a 05                	push   $0x5
  80102e:	53                   	push   %ebx
  80102f:	57                   	push   %edi
  801030:	53                   	push   %ebx
  801031:	6a 00                	push   $0x0
  801033:	e8 84 fc ff ff       	call   800cbc <sys_page_map>
  801038:	83 c4 20             	add    $0x20,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801042:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801045:	85 c0                	test   %eax,%eax
  801047:	78 59                	js     8010a2 <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801049:	83 c6 01             	add    $0x1,%esi
  80104c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801052:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801058:	0f 85 3e ff ff ff    	jne    800f9c <fork+0x59>
  80105e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801061:	83 ec 04             	sub    $0x4,%esp
  801064:	6a 07                	push   $0x7
  801066:	68 00 f0 bf ee       	push   $0xeebff000
  80106b:	57                   	push   %edi
  80106c:	e8 08 fc ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	78 2a                	js     8010a2 <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801078:	83 ec 08             	sub    $0x8,%esp
  80107b:	68 18 1e 80 00       	push   $0x801e18
  801080:	57                   	push   %edi
  801081:	e8 3e fd ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 15                	js     8010a2 <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	6a 02                	push   $0x2
  801092:	57                   	push   %edi
  801093:	e8 a8 fc ff ff       	call   800d40 <sys_env_set_status>
	if (r < 0)
  801098:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  80109b:	85 c0                	test   %eax,%eax
  80109d:	0f 49 c7             	cmovns %edi,%eax
  8010a0:	eb 00                	jmp    8010a2 <fork+0x15f>
	// panic("fork not implemented");
}
  8010a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <sfork>:

// Challenge!
int
sfork(void)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b0:	68 2b 27 80 00       	push   $0x80272b
  8010b5:	68 c3 00 00 00       	push   $0xc3
  8010ba:	68 20 27 80 00       	push   $0x802720
  8010bf:	e8 54 f1 ff ff       	call   800218 <_panic>

008010c4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cf:	c1 e8 0c             	shr    $0xc,%eax
}
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010da:	05 00 00 00 30       	add    $0x30000000,%eax
  8010df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010f6:	89 c2                	mov    %eax,%edx
  8010f8:	c1 ea 16             	shr    $0x16,%edx
  8010fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801102:	f6 c2 01             	test   $0x1,%dl
  801105:	74 11                	je     801118 <fd_alloc+0x2d>
  801107:	89 c2                	mov    %eax,%edx
  801109:	c1 ea 0c             	shr    $0xc,%edx
  80110c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801113:	f6 c2 01             	test   $0x1,%dl
  801116:	75 09                	jne    801121 <fd_alloc+0x36>
			*fd_store = fd;
  801118:	89 01                	mov    %eax,(%ecx)
			return 0;
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
  80111f:	eb 17                	jmp    801138 <fd_alloc+0x4d>
  801121:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801126:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80112b:	75 c9                	jne    8010f6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80112d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801133:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801140:	83 f8 1f             	cmp    $0x1f,%eax
  801143:	77 36                	ja     80117b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801145:	c1 e0 0c             	shl    $0xc,%eax
  801148:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	c1 ea 16             	shr    $0x16,%edx
  801152:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801159:	f6 c2 01             	test   $0x1,%dl
  80115c:	74 24                	je     801182 <fd_lookup+0x48>
  80115e:	89 c2                	mov    %eax,%edx
  801160:	c1 ea 0c             	shr    $0xc,%edx
  801163:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116a:	f6 c2 01             	test   $0x1,%dl
  80116d:	74 1a                	je     801189 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80116f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801172:	89 02                	mov    %eax,(%edx)
	return 0;
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
  801179:	eb 13                	jmp    80118e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80117b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801180:	eb 0c                	jmp    80118e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801182:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801187:	eb 05                	jmp    80118e <fd_lookup+0x54>
  801189:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801199:	ba c4 27 80 00       	mov    $0x8027c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80119e:	eb 13                	jmp    8011b3 <dev_lookup+0x23>
  8011a0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011a3:	39 08                	cmp    %ecx,(%eax)
  8011a5:	75 0c                	jne    8011b3 <dev_lookup+0x23>
			*dev = devtab[i];
  8011a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011aa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b1:	eb 2e                	jmp    8011e1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011b3:	8b 02                	mov    (%edx),%eax
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	75 e7                	jne    8011a0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011b9:	a1 20 44 80 00       	mov    0x804420,%eax
  8011be:	8b 40 48             	mov    0x48(%eax),%eax
  8011c1:	83 ec 04             	sub    $0x4,%esp
  8011c4:	51                   	push   %ecx
  8011c5:	50                   	push   %eax
  8011c6:	68 44 27 80 00       	push   $0x802744
  8011cb:	e8 21 f1 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  8011d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 10             	sub    $0x10,%esp
  8011eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011fb:	c1 e8 0c             	shr    $0xc,%eax
  8011fe:	50                   	push   %eax
  8011ff:	e8 36 ff ff ff       	call   80113a <fd_lookup>
  801204:	83 c4 08             	add    $0x8,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 05                	js     801210 <fd_close+0x2d>
	    || fd != fd2)
  80120b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80120e:	74 0c                	je     80121c <fd_close+0x39>
		return (must_exist ? r : 0);
  801210:	84 db                	test   %bl,%bl
  801212:	ba 00 00 00 00       	mov    $0x0,%edx
  801217:	0f 44 c2             	cmove  %edx,%eax
  80121a:	eb 41                	jmp    80125d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80121c:	83 ec 08             	sub    $0x8,%esp
  80121f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	ff 36                	pushl  (%esi)
  801225:	e8 66 ff ff ff       	call   801190 <dev_lookup>
  80122a:	89 c3                	mov    %eax,%ebx
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 1a                	js     80124d <fd_close+0x6a>
		if (dev->dev_close)
  801233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801236:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801239:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80123e:	85 c0                	test   %eax,%eax
  801240:	74 0b                	je     80124d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801242:	83 ec 0c             	sub    $0xc,%esp
  801245:	56                   	push   %esi
  801246:	ff d0                	call   *%eax
  801248:	89 c3                	mov    %eax,%ebx
  80124a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	56                   	push   %esi
  801251:	6a 00                	push   $0x0
  801253:	e8 a6 fa ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	89 d8                	mov    %ebx,%eax
}
  80125d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	ff 75 08             	pushl  0x8(%ebp)
  801271:	e8 c4 fe ff ff       	call   80113a <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 10                	js     80128d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	6a 01                	push   $0x1
  801282:	ff 75 f4             	pushl  -0xc(%ebp)
  801285:	e8 59 ff ff ff       	call   8011e3 <fd_close>
  80128a:	83 c4 10             	add    $0x10,%esp
}
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <close_all>:

void
close_all(void)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	53                   	push   %ebx
  801293:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801296:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80129b:	83 ec 0c             	sub    $0xc,%esp
  80129e:	53                   	push   %ebx
  80129f:	e8 c0 ff ff ff       	call   801264 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a4:	83 c3 01             	add    $0x1,%ebx
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	83 fb 20             	cmp    $0x20,%ebx
  8012ad:	75 ec                	jne    80129b <close_all+0xc>
		close(i);
}
  8012af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b2:	c9                   	leave  
  8012b3:	c3                   	ret    

008012b4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	57                   	push   %edi
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 2c             	sub    $0x2c,%esp
  8012bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c3:	50                   	push   %eax
  8012c4:	ff 75 08             	pushl  0x8(%ebp)
  8012c7:	e8 6e fe ff ff       	call   80113a <fd_lookup>
  8012cc:	83 c4 08             	add    $0x8,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	0f 88 c1 00 00 00    	js     801398 <dup+0xe4>
		return r;
	close(newfdnum);
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	56                   	push   %esi
  8012db:	e8 84 ff ff ff       	call   801264 <close>

	newfd = INDEX2FD(newfdnum);
  8012e0:	89 f3                	mov    %esi,%ebx
  8012e2:	c1 e3 0c             	shl    $0xc,%ebx
  8012e5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012eb:	83 c4 04             	add    $0x4,%esp
  8012ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012f1:	e8 de fd ff ff       	call   8010d4 <fd2data>
  8012f6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012f8:	89 1c 24             	mov    %ebx,(%esp)
  8012fb:	e8 d4 fd ff ff       	call   8010d4 <fd2data>
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801306:	89 f8                	mov    %edi,%eax
  801308:	c1 e8 16             	shr    $0x16,%eax
  80130b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801312:	a8 01                	test   $0x1,%al
  801314:	74 37                	je     80134d <dup+0x99>
  801316:	89 f8                	mov    %edi,%eax
  801318:	c1 e8 0c             	shr    $0xc,%eax
  80131b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801322:	f6 c2 01             	test   $0x1,%dl
  801325:	74 26                	je     80134d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801327:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	25 07 0e 00 00       	and    $0xe07,%eax
  801336:	50                   	push   %eax
  801337:	ff 75 d4             	pushl  -0x2c(%ebp)
  80133a:	6a 00                	push   $0x0
  80133c:	57                   	push   %edi
  80133d:	6a 00                	push   $0x0
  80133f:	e8 78 f9 ff ff       	call   800cbc <sys_page_map>
  801344:	89 c7                	mov    %eax,%edi
  801346:	83 c4 20             	add    $0x20,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 2e                	js     80137b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801350:	89 d0                	mov    %edx,%eax
  801352:	c1 e8 0c             	shr    $0xc,%eax
  801355:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	25 07 0e 00 00       	and    $0xe07,%eax
  801364:	50                   	push   %eax
  801365:	53                   	push   %ebx
  801366:	6a 00                	push   $0x0
  801368:	52                   	push   %edx
  801369:	6a 00                	push   $0x0
  80136b:	e8 4c f9 ff ff       	call   800cbc <sys_page_map>
  801370:	89 c7                	mov    %eax,%edi
  801372:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801375:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801377:	85 ff                	test   %edi,%edi
  801379:	79 1d                	jns    801398 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	53                   	push   %ebx
  80137f:	6a 00                	push   $0x0
  801381:	e8 78 f9 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801386:	83 c4 08             	add    $0x8,%esp
  801389:	ff 75 d4             	pushl  -0x2c(%ebp)
  80138c:	6a 00                	push   $0x0
  80138e:	e8 6b f9 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	89 f8                	mov    %edi,%eax
}
  801398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5e                   	pop    %esi
  80139d:	5f                   	pop    %edi
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 14             	sub    $0x14,%esp
  8013a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	53                   	push   %ebx
  8013af:	e8 86 fd ff ff       	call   80113a <fd_lookup>
  8013b4:	83 c4 08             	add    $0x8,%esp
  8013b7:	89 c2                	mov    %eax,%edx
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 6d                	js     80142a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c3:	50                   	push   %eax
  8013c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c7:	ff 30                	pushl  (%eax)
  8013c9:	e8 c2 fd ff ff       	call   801190 <dev_lookup>
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 4c                	js     801421 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d8:	8b 42 08             	mov    0x8(%edx),%eax
  8013db:	83 e0 03             	and    $0x3,%eax
  8013de:	83 f8 01             	cmp    $0x1,%eax
  8013e1:	75 21                	jne    801404 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e3:	a1 20 44 80 00       	mov    0x804420,%eax
  8013e8:	8b 40 48             	mov    0x48(%eax),%eax
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	53                   	push   %ebx
  8013ef:	50                   	push   %eax
  8013f0:	68 88 27 80 00       	push   $0x802788
  8013f5:	e8 f7 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801402:	eb 26                	jmp    80142a <read+0x8a>
	}
	if (!dev->dev_read)
  801404:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801407:	8b 40 08             	mov    0x8(%eax),%eax
  80140a:	85 c0                	test   %eax,%eax
  80140c:	74 17                	je     801425 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	ff 75 10             	pushl  0x10(%ebp)
  801414:	ff 75 0c             	pushl  0xc(%ebp)
  801417:	52                   	push   %edx
  801418:	ff d0                	call   *%eax
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	eb 09                	jmp    80142a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801421:	89 c2                	mov    %eax,%edx
  801423:	eb 05                	jmp    80142a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801425:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80142a:	89 d0                	mov    %edx,%eax
  80142c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	57                   	push   %edi
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80143d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801440:	bb 00 00 00 00       	mov    $0x0,%ebx
  801445:	eb 21                	jmp    801468 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801447:	83 ec 04             	sub    $0x4,%esp
  80144a:	89 f0                	mov    %esi,%eax
  80144c:	29 d8                	sub    %ebx,%eax
  80144e:	50                   	push   %eax
  80144f:	89 d8                	mov    %ebx,%eax
  801451:	03 45 0c             	add    0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	57                   	push   %edi
  801456:	e8 45 ff ff ff       	call   8013a0 <read>
		if (m < 0)
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 10                	js     801472 <readn+0x41>
			return m;
		if (m == 0)
  801462:	85 c0                	test   %eax,%eax
  801464:	74 0a                	je     801470 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801466:	01 c3                	add    %eax,%ebx
  801468:	39 f3                	cmp    %esi,%ebx
  80146a:	72 db                	jb     801447 <readn+0x16>
  80146c:	89 d8                	mov    %ebx,%eax
  80146e:	eb 02                	jmp    801472 <readn+0x41>
  801470:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801472:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5f                   	pop    %edi
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	53                   	push   %ebx
  80147e:	83 ec 14             	sub    $0x14,%esp
  801481:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801484:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	53                   	push   %ebx
  801489:	e8 ac fc ff ff       	call   80113a <fd_lookup>
  80148e:	83 c4 08             	add    $0x8,%esp
  801491:	89 c2                	mov    %eax,%edx
  801493:	85 c0                	test   %eax,%eax
  801495:	78 68                	js     8014ff <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a1:	ff 30                	pushl  (%eax)
  8014a3:	e8 e8 fc ff ff       	call   801190 <dev_lookup>
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 47                	js     8014f6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b6:	75 21                	jne    8014d9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b8:	a1 20 44 80 00       	mov    0x804420,%eax
  8014bd:	8b 40 48             	mov    0x48(%eax),%eax
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	53                   	push   %ebx
  8014c4:	50                   	push   %eax
  8014c5:	68 a4 27 80 00       	push   $0x8027a4
  8014ca:	e8 22 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d7:	eb 26                	jmp    8014ff <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014df:	85 d2                	test   %edx,%edx
  8014e1:	74 17                	je     8014fa <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	ff 75 10             	pushl  0x10(%ebp)
  8014e9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ec:	50                   	push   %eax
  8014ed:	ff d2                	call   *%edx
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	eb 09                	jmp    8014ff <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	eb 05                	jmp    8014ff <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ff:	89 d0                	mov    %edx,%eax
  801501:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <seek>:

int
seek(int fdnum, off_t offset)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	ff 75 08             	pushl  0x8(%ebp)
  801513:	e8 22 fc ff ff       	call   80113a <fd_lookup>
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 0e                	js     80152d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80151f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801522:	8b 55 0c             	mov    0xc(%ebp),%edx
  801525:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801528:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	53                   	push   %ebx
  801533:	83 ec 14             	sub    $0x14,%esp
  801536:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801539:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153c:	50                   	push   %eax
  80153d:	53                   	push   %ebx
  80153e:	e8 f7 fb ff ff       	call   80113a <fd_lookup>
  801543:	83 c4 08             	add    $0x8,%esp
  801546:	89 c2                	mov    %eax,%edx
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 65                	js     8015b1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801556:	ff 30                	pushl  (%eax)
  801558:	e8 33 fc ff ff       	call   801190 <dev_lookup>
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 44                	js     8015a8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801564:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801567:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156b:	75 21                	jne    80158e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80156d:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801572:	8b 40 48             	mov    0x48(%eax),%eax
  801575:	83 ec 04             	sub    $0x4,%esp
  801578:	53                   	push   %ebx
  801579:	50                   	push   %eax
  80157a:	68 64 27 80 00       	push   $0x802764
  80157f:	e8 6d ed ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158c:	eb 23                	jmp    8015b1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80158e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801591:	8b 52 18             	mov    0x18(%edx),%edx
  801594:	85 d2                	test   %edx,%edx
  801596:	74 14                	je     8015ac <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	50                   	push   %eax
  80159f:	ff d2                	call   *%edx
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	eb 09                	jmp    8015b1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	eb 05                	jmp    8015b1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b1:	89 d0                	mov    %edx,%eax
  8015b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 14             	sub    $0x14,%esp
  8015bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	ff 75 08             	pushl  0x8(%ebp)
  8015c9:	e8 6c fb ff ff       	call   80113a <fd_lookup>
  8015ce:	83 c4 08             	add    $0x8,%esp
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 58                	js     80162f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	ff 30                	pushl  (%eax)
  8015e3:	e8 a8 fb ff ff       	call   801190 <dev_lookup>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 37                	js     801626 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015f6:	74 32                	je     80162a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801602:	00 00 00 
	stat->st_isdir = 0;
  801605:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80160c:	00 00 00 
	stat->st_dev = dev;
  80160f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	53                   	push   %ebx
  801619:	ff 75 f0             	pushl  -0x10(%ebp)
  80161c:	ff 50 14             	call   *0x14(%eax)
  80161f:	89 c2                	mov    %eax,%edx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	eb 09                	jmp    80162f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801626:	89 c2                	mov    %eax,%edx
  801628:	eb 05                	jmp    80162f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80162a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80162f:	89 d0                	mov    %edx,%eax
  801631:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	6a 00                	push   $0x0
  801640:	ff 75 08             	pushl  0x8(%ebp)
  801643:	e8 b7 01 00 00       	call   8017ff <open>
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 1b                	js     80166c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	ff 75 0c             	pushl  0xc(%ebp)
  801657:	50                   	push   %eax
  801658:	e8 5b ff ff ff       	call   8015b8 <fstat>
  80165d:	89 c6                	mov    %eax,%esi
	close(fd);
  80165f:	89 1c 24             	mov    %ebx,(%esp)
  801662:	e8 fd fb ff ff       	call   801264 <close>
	return r;
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	89 f0                	mov    %esi,%eax
}
  80166c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	56                   	push   %esi
  801677:	53                   	push   %ebx
  801678:	89 c6                	mov    %eax,%esi
  80167a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801683:	75 12                	jne    801697 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801685:	83 ec 0c             	sub    $0xc,%esp
  801688:	6a 01                	push   $0x1
  80168a:	e8 68 08 00 00       	call   801ef7 <ipc_find_env>
  80168f:	a3 00 40 80 00       	mov    %eax,0x804000
  801694:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801697:	6a 07                	push   $0x7
  801699:	68 00 50 80 00       	push   $0x805000
  80169e:	56                   	push   %esi
  80169f:	ff 35 00 40 80 00    	pushl  0x804000
  8016a5:	e8 f9 07 00 00       	call   801ea3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016aa:	83 c4 0c             	add    $0xc,%esp
  8016ad:	6a 00                	push   $0x0
  8016af:	53                   	push   %ebx
  8016b0:	6a 00                	push   $0x0
  8016b2:	e8 85 07 00 00       	call   801e3c <ipc_recv>
}
  8016b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ba:	5b                   	pop    %ebx
  8016bb:	5e                   	pop    %esi
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dc:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e1:	e8 8d ff ff ff       	call   801673 <fsipc>
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	b8 06 00 00 00       	mov    $0x6,%eax
  801703:	e8 6b ff ff ff       	call   801673 <fsipc>
}
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	53                   	push   %ebx
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	8b 40 0c             	mov    0xc(%eax),%eax
  80171a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80171f:	ba 00 00 00 00       	mov    $0x0,%edx
  801724:	b8 05 00 00 00       	mov    $0x5,%eax
  801729:	e8 45 ff ff ff       	call   801673 <fsipc>
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 2c                	js     80175e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	68 00 50 80 00       	push   $0x805000
  80173a:	53                   	push   %ebx
  80173b:	e8 36 f1 ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801740:	a1 80 50 80 00       	mov    0x805080,%eax
  801745:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80174b:	a1 84 50 80 00       	mov    0x805084,%eax
  801750:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801769:	68 d4 27 80 00       	push   $0x8027d4
  80176e:	68 90 00 00 00       	push   $0x90
  801773:	68 f2 27 80 00       	push   $0x8027f2
  801778:	e8 9b ea ff ff       	call   800218 <_panic>

0080177d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	56                   	push   %esi
  801781:	53                   	push   %ebx
  801782:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801790:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a0:	e8 ce fe ff ff       	call   801673 <fsipc>
  8017a5:	89 c3                	mov    %eax,%ebx
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 4b                	js     8017f6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017ab:	39 c6                	cmp    %eax,%esi
  8017ad:	73 16                	jae    8017c5 <devfile_read+0x48>
  8017af:	68 fd 27 80 00       	push   $0x8027fd
  8017b4:	68 04 28 80 00       	push   $0x802804
  8017b9:	6a 7c                	push   $0x7c
  8017bb:	68 f2 27 80 00       	push   $0x8027f2
  8017c0:	e8 53 ea ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  8017c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ca:	7e 16                	jle    8017e2 <devfile_read+0x65>
  8017cc:	68 19 28 80 00       	push   $0x802819
  8017d1:	68 04 28 80 00       	push   $0x802804
  8017d6:	6a 7d                	push   $0x7d
  8017d8:	68 f2 27 80 00       	push   $0x8027f2
  8017dd:	e8 36 ea ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e2:	83 ec 04             	sub    $0x4,%esp
  8017e5:	50                   	push   %eax
  8017e6:	68 00 50 80 00       	push   $0x805000
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	e8 15 f2 ff ff       	call   800a08 <memmove>
	return r;
  8017f3:	83 c4 10             	add    $0x10,%esp
}
  8017f6:	89 d8                	mov    %ebx,%eax
  8017f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	53                   	push   %ebx
  801803:	83 ec 20             	sub    $0x20,%esp
  801806:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801809:	53                   	push   %ebx
  80180a:	e8 2e f0 ff ff       	call   80083d <strlen>
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801817:	7f 67                	jg     801880 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181f:	50                   	push   %eax
  801820:	e8 c6 f8 ff ff       	call   8010eb <fd_alloc>
  801825:	83 c4 10             	add    $0x10,%esp
		return r;
  801828:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 57                	js     801885 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	53                   	push   %ebx
  801832:	68 00 50 80 00       	push   $0x805000
  801837:	e8 3a f0 ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801847:	b8 01 00 00 00       	mov    $0x1,%eax
  80184c:	e8 22 fe ff ff       	call   801673 <fsipc>
  801851:	89 c3                	mov    %eax,%ebx
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	85 c0                	test   %eax,%eax
  801858:	79 14                	jns    80186e <open+0x6f>
		fd_close(fd, 0);
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	6a 00                	push   $0x0
  80185f:	ff 75 f4             	pushl  -0xc(%ebp)
  801862:	e8 7c f9 ff ff       	call   8011e3 <fd_close>
		return r;
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	89 da                	mov    %ebx,%edx
  80186c:	eb 17                	jmp    801885 <open+0x86>
	}

	return fd2num(fd);
  80186e:	83 ec 0c             	sub    $0xc,%esp
  801871:	ff 75 f4             	pushl  -0xc(%ebp)
  801874:	e8 4b f8 ff ff       	call   8010c4 <fd2num>
  801879:	89 c2                	mov    %eax,%edx
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	eb 05                	jmp    801885 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801880:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801885:	89 d0                	mov    %edx,%eax
  801887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801892:	ba 00 00 00 00       	mov    $0x0,%edx
  801897:	b8 08 00 00 00       	mov    $0x8,%eax
  80189c:	e8 d2 fd ff ff       	call   801673 <fsipc>
}
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	56                   	push   %esi
  8018a7:	53                   	push   %ebx
  8018a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	ff 75 08             	pushl  0x8(%ebp)
  8018b1:	e8 1e f8 ff ff       	call   8010d4 <fd2data>
  8018b6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018b8:	83 c4 08             	add    $0x8,%esp
  8018bb:	68 25 28 80 00       	push   $0x802825
  8018c0:	53                   	push   %ebx
  8018c1:	e8 b0 ef ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018c6:	8b 46 04             	mov    0x4(%esi),%eax
  8018c9:	2b 06                	sub    (%esi),%eax
  8018cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d8:	00 00 00 
	stat->st_dev = &devpipe;
  8018db:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018e2:	30 80 00 
	return 0;
}
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5e                   	pop    %esi
  8018ef:	5d                   	pop    %ebp
  8018f0:	c3                   	ret    

008018f1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 0c             	sub    $0xc,%esp
  8018f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018fb:	53                   	push   %ebx
  8018fc:	6a 00                	push   $0x0
  8018fe:	e8 fb f3 ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801903:	89 1c 24             	mov    %ebx,(%esp)
  801906:	e8 c9 f7 ff ff       	call   8010d4 <fd2data>
  80190b:	83 c4 08             	add    $0x8,%esp
  80190e:	50                   	push   %eax
  80190f:	6a 00                	push   $0x0
  801911:	e8 e8 f3 ff ff       	call   800cfe <sys_page_unmap>
}
  801916:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	57                   	push   %edi
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	83 ec 1c             	sub    $0x1c,%esp
  801924:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801927:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801929:	a1 20 44 80 00       	mov    0x804420,%eax
  80192e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801931:	83 ec 0c             	sub    $0xc,%esp
  801934:	ff 75 e0             	pushl  -0x20(%ebp)
  801937:	e8 f4 05 00 00       	call   801f30 <pageref>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	89 3c 24             	mov    %edi,(%esp)
  801941:	e8 ea 05 00 00       	call   801f30 <pageref>
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	39 c3                	cmp    %eax,%ebx
  80194b:	0f 94 c1             	sete   %cl
  80194e:	0f b6 c9             	movzbl %cl,%ecx
  801951:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801954:	8b 15 20 44 80 00    	mov    0x804420,%edx
  80195a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80195d:	39 ce                	cmp    %ecx,%esi
  80195f:	74 1b                	je     80197c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801961:	39 c3                	cmp    %eax,%ebx
  801963:	75 c4                	jne    801929 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801965:	8b 42 58             	mov    0x58(%edx),%eax
  801968:	ff 75 e4             	pushl  -0x1c(%ebp)
  80196b:	50                   	push   %eax
  80196c:	56                   	push   %esi
  80196d:	68 2c 28 80 00       	push   $0x80282c
  801972:	e8 7a e9 ff ff       	call   8002f1 <cprintf>
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	eb ad                	jmp    801929 <_pipeisclosed+0xe>
	}
}
  80197c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80197f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801982:	5b                   	pop    %ebx
  801983:	5e                   	pop    %esi
  801984:	5f                   	pop    %edi
  801985:	5d                   	pop    %ebp
  801986:	c3                   	ret    

00801987 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	57                   	push   %edi
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	83 ec 28             	sub    $0x28,%esp
  801990:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801993:	56                   	push   %esi
  801994:	e8 3b f7 ff ff       	call   8010d4 <fd2data>
  801999:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a3:	eb 4b                	jmp    8019f0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019a5:	89 da                	mov    %ebx,%edx
  8019a7:	89 f0                	mov    %esi,%eax
  8019a9:	e8 6d ff ff ff       	call   80191b <_pipeisclosed>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	75 48                	jne    8019fa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019b2:	e8 a3 f2 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019b7:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ba:	8b 0b                	mov    (%ebx),%ecx
  8019bc:	8d 51 20             	lea    0x20(%ecx),%edx
  8019bf:	39 d0                	cmp    %edx,%eax
  8019c1:	73 e2                	jae    8019a5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019c6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019ca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019cd:	89 c2                	mov    %eax,%edx
  8019cf:	c1 fa 1f             	sar    $0x1f,%edx
  8019d2:	89 d1                	mov    %edx,%ecx
  8019d4:	c1 e9 1b             	shr    $0x1b,%ecx
  8019d7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019da:	83 e2 1f             	and    $0x1f,%edx
  8019dd:	29 ca                	sub    %ecx,%edx
  8019df:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019e7:	83 c0 01             	add    $0x1,%eax
  8019ea:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ed:	83 c7 01             	add    $0x1,%edi
  8019f0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019f3:	75 c2                	jne    8019b7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f8:	eb 05                	jmp    8019ff <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019fa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a02:	5b                   	pop    %ebx
  801a03:	5e                   	pop    %esi
  801a04:	5f                   	pop    %edi
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    

00801a07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	57                   	push   %edi
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 18             	sub    $0x18,%esp
  801a10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a13:	57                   	push   %edi
  801a14:	e8 bb f6 ff ff       	call   8010d4 <fd2data>
  801a19:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a23:	eb 3d                	jmp    801a62 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a25:	85 db                	test   %ebx,%ebx
  801a27:	74 04                	je     801a2d <devpipe_read+0x26>
				return i;
  801a29:	89 d8                	mov    %ebx,%eax
  801a2b:	eb 44                	jmp    801a71 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a2d:	89 f2                	mov    %esi,%edx
  801a2f:	89 f8                	mov    %edi,%eax
  801a31:	e8 e5 fe ff ff       	call   80191b <_pipeisclosed>
  801a36:	85 c0                	test   %eax,%eax
  801a38:	75 32                	jne    801a6c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a3a:	e8 1b f2 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a3f:	8b 06                	mov    (%esi),%eax
  801a41:	3b 46 04             	cmp    0x4(%esi),%eax
  801a44:	74 df                	je     801a25 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a46:	99                   	cltd   
  801a47:	c1 ea 1b             	shr    $0x1b,%edx
  801a4a:	01 d0                	add    %edx,%eax
  801a4c:	83 e0 1f             	and    $0x1f,%eax
  801a4f:	29 d0                	sub    %edx,%eax
  801a51:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a59:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a5c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5f:	83 c3 01             	add    $0x1,%ebx
  801a62:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a65:	75 d8                	jne    801a3f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a67:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6a:	eb 05                	jmp    801a71 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5f                   	pop    %edi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
  801a7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a84:	50                   	push   %eax
  801a85:	e8 61 f6 ff ff       	call   8010eb <fd_alloc>
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	89 c2                	mov    %eax,%edx
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	0f 88 2c 01 00 00    	js     801bc3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a97:	83 ec 04             	sub    $0x4,%esp
  801a9a:	68 07 04 00 00       	push   $0x407
  801a9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa2:	6a 00                	push   $0x0
  801aa4:	e8 d0 f1 ff ff       	call   800c79 <sys_page_alloc>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	89 c2                	mov    %eax,%edx
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	0f 88 0d 01 00 00    	js     801bc3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ab6:	83 ec 0c             	sub    $0xc,%esp
  801ab9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801abc:	50                   	push   %eax
  801abd:	e8 29 f6 ff ff       	call   8010eb <fd_alloc>
  801ac2:	89 c3                	mov    %eax,%ebx
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	0f 88 e2 00 00 00    	js     801bb1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acf:	83 ec 04             	sub    $0x4,%esp
  801ad2:	68 07 04 00 00       	push   $0x407
  801ad7:	ff 75 f0             	pushl  -0x10(%ebp)
  801ada:	6a 00                	push   $0x0
  801adc:	e8 98 f1 ff ff       	call   800c79 <sys_page_alloc>
  801ae1:	89 c3                	mov    %eax,%ebx
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	0f 88 c3 00 00 00    	js     801bb1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	ff 75 f4             	pushl  -0xc(%ebp)
  801af4:	e8 db f5 ff ff       	call   8010d4 <fd2data>
  801af9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801afb:	83 c4 0c             	add    $0xc,%esp
  801afe:	68 07 04 00 00       	push   $0x407
  801b03:	50                   	push   %eax
  801b04:	6a 00                	push   $0x0
  801b06:	e8 6e f1 ff ff       	call   800c79 <sys_page_alloc>
  801b0b:	89 c3                	mov    %eax,%ebx
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	0f 88 89 00 00 00    	js     801ba1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	83 ec 0c             	sub    $0xc,%esp
  801b1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b1e:	e8 b1 f5 ff ff       	call   8010d4 <fd2data>
  801b23:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b2a:	50                   	push   %eax
  801b2b:	6a 00                	push   $0x0
  801b2d:	56                   	push   %esi
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 87 f1 ff ff       	call   800cbc <sys_page_map>
  801b35:	89 c3                	mov    %eax,%ebx
  801b37:	83 c4 20             	add    $0x20,%esp
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 55                	js     801b93 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b3e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b47:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b53:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b61:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6e:	e8 51 f5 ff ff       	call   8010c4 <fd2num>
  801b73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b76:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b78:	83 c4 04             	add    $0x4,%esp
  801b7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7e:	e8 41 f5 ff ff       	call   8010c4 <fd2num>
  801b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b86:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b91:	eb 30                	jmp    801bc3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b93:	83 ec 08             	sub    $0x8,%esp
  801b96:	56                   	push   %esi
  801b97:	6a 00                	push   $0x0
  801b99:	e8 60 f1 ff ff       	call   800cfe <sys_page_unmap>
  801b9e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ba1:	83 ec 08             	sub    $0x8,%esp
  801ba4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba7:	6a 00                	push   $0x0
  801ba9:	e8 50 f1 ff ff       	call   800cfe <sys_page_unmap>
  801bae:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bb1:	83 ec 08             	sub    $0x8,%esp
  801bb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb7:	6a 00                	push   $0x0
  801bb9:	e8 40 f1 ff ff       	call   800cfe <sys_page_unmap>
  801bbe:	83 c4 10             	add    $0x10,%esp
  801bc1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bc3:	89 d0                	mov    %edx,%eax
  801bc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd5:	50                   	push   %eax
  801bd6:	ff 75 08             	pushl  0x8(%ebp)
  801bd9:	e8 5c f5 ff ff       	call   80113a <fd_lookup>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	78 18                	js     801bfd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	ff 75 f4             	pushl  -0xc(%ebp)
  801beb:	e8 e4 f4 ff ff       	call   8010d4 <fd2data>
	return _pipeisclosed(fd, p);
  801bf0:	89 c2                	mov    %eax,%edx
  801bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf5:	e8 21 fd ff ff       	call   80191b <_pipeisclosed>
  801bfa:	83 c4 10             	add    $0x10,%esp
}
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    

00801bff <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	56                   	push   %esi
  801c03:	53                   	push   %ebx
  801c04:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801c07:	85 f6                	test   %esi,%esi
  801c09:	75 16                	jne    801c21 <wait+0x22>
  801c0b:	68 44 28 80 00       	push   $0x802844
  801c10:	68 04 28 80 00       	push   $0x802804
  801c15:	6a 09                	push   $0x9
  801c17:	68 4f 28 80 00       	push   $0x80284f
  801c1c:	e8 f7 e5 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801c21:	89 f3                	mov    %esi,%ebx
  801c23:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c29:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801c2c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801c32:	eb 05                	jmp    801c39 <wait+0x3a>
		sys_yield();
  801c34:	e8 21 f0 ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c39:	8b 43 48             	mov    0x48(%ebx),%eax
  801c3c:	39 c6                	cmp    %eax,%esi
  801c3e:	75 07                	jne    801c47 <wait+0x48>
  801c40:	8b 43 54             	mov    0x54(%ebx),%eax
  801c43:	85 c0                	test   %eax,%eax
  801c45:	75 ed                	jne    801c34 <wait+0x35>
		sys_yield();
}
  801c47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4a:	5b                   	pop    %ebx
  801c4b:	5e                   	pop    %esi
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c51:	b8 00 00 00 00       	mov    $0x0,%eax
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c5e:	68 5a 28 80 00       	push   $0x80285a
  801c63:	ff 75 0c             	pushl  0xc(%ebp)
  801c66:	e8 0b ec ff ff       	call   800876 <strcpy>
	return 0;
}
  801c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	57                   	push   %edi
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c7e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c83:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c89:	eb 2d                	jmp    801cb8 <devcons_write+0x46>
		m = n - tot;
  801c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c8e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c90:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c93:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c98:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c9b:	83 ec 04             	sub    $0x4,%esp
  801c9e:	53                   	push   %ebx
  801c9f:	03 45 0c             	add    0xc(%ebp),%eax
  801ca2:	50                   	push   %eax
  801ca3:	57                   	push   %edi
  801ca4:	e8 5f ed ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  801ca9:	83 c4 08             	add    $0x8,%esp
  801cac:	53                   	push   %ebx
  801cad:	57                   	push   %edi
  801cae:	e8 0a ef ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb3:	01 de                	add    %ebx,%esi
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	89 f0                	mov    %esi,%eax
  801cba:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cbd:	72 cc                	jb     801c8b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	83 ec 08             	sub    $0x8,%esp
  801ccd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cd6:	74 2a                	je     801d02 <devcons_read+0x3b>
  801cd8:	eb 05                	jmp    801cdf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cda:	e8 7b ef ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cdf:	e8 f7 ee ff ff       	call   800bdb <sys_cgetc>
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	74 f2                	je     801cda <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	78 16                	js     801d02 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cec:	83 f8 04             	cmp    $0x4,%eax
  801cef:	74 0c                	je     801cfd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cf1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf4:	88 02                	mov    %al,(%edx)
	return 1;
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	eb 05                	jmp    801d02 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cfd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d02:	c9                   	leave  
  801d03:	c3                   	ret    

00801d04 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d10:	6a 01                	push   $0x1
  801d12:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d15:	50                   	push   %eax
  801d16:	e8 a2 ee ff ff       	call   800bbd <sys_cputs>
}
  801d1b:	83 c4 10             	add    $0x10,%esp
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <getchar>:

int
getchar(void)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d26:	6a 01                	push   $0x1
  801d28:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d2b:	50                   	push   %eax
  801d2c:	6a 00                	push   $0x0
  801d2e:	e8 6d f6 ff ff       	call   8013a0 <read>
	if (r < 0)
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 0f                	js     801d49 <getchar+0x29>
		return r;
	if (r < 1)
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	7e 06                	jle    801d44 <getchar+0x24>
		return -E_EOF;
	return c;
  801d3e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d42:	eb 05                	jmp    801d49 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d44:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    

00801d4b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d54:	50                   	push   %eax
  801d55:	ff 75 08             	pushl  0x8(%ebp)
  801d58:	e8 dd f3 ff ff       	call   80113a <fd_lookup>
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 11                	js     801d75 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d67:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6d:	39 10                	cmp    %edx,(%eax)
  801d6f:	0f 94 c0             	sete   %al
  801d72:	0f b6 c0             	movzbl %al,%eax
}
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <opencons>:

int
opencons(void)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d80:	50                   	push   %eax
  801d81:	e8 65 f3 ff ff       	call   8010eb <fd_alloc>
  801d86:	83 c4 10             	add    $0x10,%esp
		return r;
  801d89:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	78 3e                	js     801dcd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8f:	83 ec 04             	sub    $0x4,%esp
  801d92:	68 07 04 00 00       	push   $0x407
  801d97:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9a:	6a 00                	push   $0x0
  801d9c:	e8 d8 ee ff ff       	call   800c79 <sys_page_alloc>
  801da1:	83 c4 10             	add    $0x10,%esp
		return r;
  801da4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801da6:	85 c0                	test   %eax,%eax
  801da8:	78 23                	js     801dcd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801daa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dbf:	83 ec 0c             	sub    $0xc,%esp
  801dc2:	50                   	push   %eax
  801dc3:	e8 fc f2 ff ff       	call   8010c4 <fd2num>
  801dc8:	89 c2                	mov    %eax,%edx
  801dca:	83 c4 10             	add    $0x10,%esp
}
  801dcd:	89 d0                	mov    %edx,%eax
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    

00801dd1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dd7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dde:	75 2e                	jne    801e0e <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801de0:	e8 56 ee ff ff       	call   800c3b <sys_getenvid>
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	68 07 0e 00 00       	push   $0xe07
  801ded:	68 00 f0 bf ee       	push   $0xeebff000
  801df2:	50                   	push   %eax
  801df3:	e8 81 ee ff ff       	call   800c79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801df8:	e8 3e ee ff ff       	call   800c3b <sys_getenvid>
  801dfd:	83 c4 08             	add    $0x8,%esp
  801e00:	68 18 1e 80 00       	push   $0x801e18
  801e05:	50                   	push   %eax
  801e06:	e8 b9 ef ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  801e0b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e11:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    

00801e18 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e18:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e19:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e1e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e20:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e23:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e27:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e2b:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e2e:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e31:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e32:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e35:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e36:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e37:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e3b:	c3                   	ret    

00801e3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	8b 75 08             	mov    0x8(%ebp),%esi
  801e44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e4a:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e4c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e51:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e54:	83 ec 0c             	sub    $0xc,%esp
  801e57:	50                   	push   %eax
  801e58:	e8 cc ef ff ff       	call   800e29 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e5d:	83 c4 10             	add    $0x10,%esp
  801e60:	85 f6                	test   %esi,%esi
  801e62:	74 14                	je     801e78 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e64:	ba 00 00 00 00       	mov    $0x0,%edx
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 09                	js     801e76 <ipc_recv+0x3a>
  801e6d:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801e73:	8b 52 74             	mov    0x74(%edx),%edx
  801e76:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e78:	85 db                	test   %ebx,%ebx
  801e7a:	74 14                	je     801e90 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801e7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e81:	85 c0                	test   %eax,%eax
  801e83:	78 09                	js     801e8e <ipc_recv+0x52>
  801e85:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801e8b:	8b 52 78             	mov    0x78(%edx),%edx
  801e8e:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 08                	js     801e9c <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801e94:	a1 20 44 80 00       	mov    0x804420,%eax
  801e99:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5e                   	pop    %esi
  801ea1:	5d                   	pop    %ebp
  801ea2:	c3                   	ret    

00801ea3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	57                   	push   %edi
  801ea7:	56                   	push   %esi
  801ea8:	53                   	push   %ebx
  801ea9:	83 ec 0c             	sub    $0xc,%esp
  801eac:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eaf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801eb5:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801eb7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ebc:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ebf:	ff 75 14             	pushl  0x14(%ebp)
  801ec2:	53                   	push   %ebx
  801ec3:	56                   	push   %esi
  801ec4:	57                   	push   %edi
  801ec5:	e8 3c ef ff ff       	call   800e06 <sys_ipc_try_send>

		if (err < 0) {
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	79 1e                	jns    801eef <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ed1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed4:	75 07                	jne    801edd <ipc_send+0x3a>
				sys_yield();
  801ed6:	e8 7f ed ff ff       	call   800c5a <sys_yield>
  801edb:	eb e2                	jmp    801ebf <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801edd:	50                   	push   %eax
  801ede:	68 66 28 80 00       	push   $0x802866
  801ee3:	6a 49                	push   $0x49
  801ee5:	68 73 28 80 00       	push   $0x802873
  801eea:	e8 29 e3 ff ff       	call   800218 <_panic>
		}

	} while (err < 0);

}
  801eef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef2:	5b                   	pop    %ebx
  801ef3:	5e                   	pop    %esi
  801ef4:	5f                   	pop    %edi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    

00801ef7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801efd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f02:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f05:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f0b:	8b 52 50             	mov    0x50(%edx),%edx
  801f0e:	39 ca                	cmp    %ecx,%edx
  801f10:	75 0d                	jne    801f1f <ipc_find_env+0x28>
			return envs[i].env_id;
  801f12:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f15:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f1a:	8b 40 48             	mov    0x48(%eax),%eax
  801f1d:	eb 0f                	jmp    801f2e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f1f:	83 c0 01             	add    $0x1,%eax
  801f22:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f27:	75 d9                	jne    801f02 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f2e:	5d                   	pop    %ebp
  801f2f:	c3                   	ret    

00801f30 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f36:	89 d0                	mov    %edx,%eax
  801f38:	c1 e8 16             	shr    $0x16,%eax
  801f3b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f47:	f6 c1 01             	test   $0x1,%cl
  801f4a:	74 1d                	je     801f69 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f4c:	c1 ea 0c             	shr    $0xc,%edx
  801f4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f56:	f6 c2 01             	test   $0x1,%dl
  801f59:	74 0e                	je     801f69 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f5b:	c1 ea 0c             	shr    $0xc,%edx
  801f5e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f65:	ef 
  801f66:	0f b7 c0             	movzwl %ax,%eax
}
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    
  801f6b:	66 90                	xchg   %ax,%ax
  801f6d:	66 90                	xchg   %ax,%ax
  801f6f:	90                   	nop

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
