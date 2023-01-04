
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 33 0b 00 00       	call   800b70 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 2f 0e 00 00       	call   800e78 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 2e 0b 00 00       	call   800b8f <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 05 0b 00 00       	call   800b8f <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 40 21 80 00       	push   $0x802140
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 68 21 80 00       	push   $0x802168
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 7b 21 80 00       	push   $0x80217b
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 73 0a 00 00       	call   800b70 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 bf 10 00 00       	call   8011fd <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 e7 09 00 00       	call   800b2f <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 10 0a 00 00       	call   800b70 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 a4 21 80 00       	push   $0x8021a4
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 97 21 80 00 	movl   $0x802197,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 2f 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 d4 08 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 22 1c 00 00       	call   801eb0 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 0f 1d 00 00       	call   801fe0 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 c7 21 80 00 	movsbl 0x8021c7(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 89 03 00 00    	je     800702 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 07             	movzbl (%edi),%eax
  8003bf:	0f b6 c8             	movzbl %al,%ecx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 1a 03 00 00    	ja     8006e7 <vprintfmt+0x38a>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003de:	eb d6                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f8:	83 fa 09             	cmp    $0x9,%edx
  8003fb:	77 39                	ja     800436 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 48 04             	lea    0x4(%eax),%ecx
  800408:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800413:	eb 27                	jmp    80043c <vprintfmt+0xdf>
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	85 c0                	test   %eax,%eax
  80041a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041f:	0f 49 c8             	cmovns %eax,%ecx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800428:	eb 8c                	jmp    8003b6 <vprintfmt+0x59>
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800434:	eb 80                	jmp    8003b6 <vprintfmt+0x59>
  800436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	0f 89 70 ff ff ff    	jns    8003b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800446:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800453:	e9 5e ff ff ff       	jmp    8003b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800458:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045e:	e9 53 ff ff ff       	jmp    8003b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 30                	pushl  (%eax)
  800472:	ff d6                	call   *%esi
			break;
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047a:	e9 04 ff ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	99                   	cltd   
  80048b:	31 d0                	xor    %edx,%eax
  80048d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 df 21 80 00       	push   $0x8021df
  8004a5:	53                   	push   %ebx
  8004a6:	56                   	push   %esi
  8004a7:	e8 94 fe ff ff       	call   800340 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b2:	e9 cc fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b7:	52                   	push   %edx
  8004b8:	68 4d 26 80 00       	push   $0x80264d
  8004bd:	53                   	push   %ebx
  8004be:	56                   	push   %esi
  8004bf:	e8 7c fe ff ff       	call   800340 <printfmt>
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 b4 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	b8 d8 21 80 00       	mov    $0x8021d8,%eax
  8004e1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e8:	0f 8e 94 00 00 00    	jle    800582 <vprintfmt+0x225>
  8004ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f2:	0f 84 98 00 00 00    	je     800590 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fe:	57                   	push   %edi
  8004ff:	e8 86 02 00 00       	call   80078a <strnlen>
  800504:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800519:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0f                	jmp    80052c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	ff 75 e0             	pushl  -0x20(%ebp)
  800524:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f ed                	jg     80051d <vprintfmt+0x1c0>
  800530:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800533:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800536:	85 c9                	test   %ecx,%ecx
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	0f 49 c1             	cmovns %ecx,%eax
  800540:	29 c1                	sub    %eax,%ecx
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	89 cb                	mov    %ecx,%ebx
  80054d:	eb 4d                	jmp    80059c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800553:	74 1b                	je     800570 <vprintfmt+0x213>
  800555:	0f be c0             	movsbl %al,%eax
  800558:	83 e8 20             	sub    $0x20,%eax
  80055b:	83 f8 5e             	cmp    $0x5e,%eax
  80055e:	76 10                	jbe    800570 <vprintfmt+0x213>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	6a 3f                	push   $0x3f
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 0d                	jmp    80057d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	52                   	push   %edx
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	83 eb 01             	sub    $0x1,%ebx
  800580:	eb 1a                	jmp    80059c <vprintfmt+0x23f>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	eb 0c                	jmp    80059c <vprintfmt+0x23f>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	0f be d0             	movsbl %al,%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 23                	je     8005cd <vprintfmt+0x270>
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	78 a1                	js     80054f <vprintfmt+0x1f2>
  8005ae:	83 ee 01             	sub    $0x1,%esi
  8005b1:	79 9c                	jns    80054f <vprintfmt+0x1f2>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	eb 18                	jmp    8005d5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 20                	push   $0x20
  8005c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	83 ef 01             	sub    $0x1,%edi
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 08                	jmp    8005d5 <vprintfmt+0x278>
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	7f e4                	jg     8005bd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	e9 a2 fd ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e1:	83 fa 01             	cmp    $0x1,%edx
  8005e4:	7e 16                	jle    8005fc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fa:	eb 32                	jmp    80062e <vprintfmt+0x2d1>
	else if (lflag)
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 18                	je     800618 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 c1                	mov    %eax,%ecx
  800610:	c1 f9 1f             	sar    $0x1f,%ecx
  800613:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800616:	eb 16                	jmp    80062e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 c1                	mov    %eax,%ecx
  800628:	c1 f9 1f             	sar    $0x1f,%ecx
  80062b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063d:	79 74                	jns    8006b3 <vprintfmt+0x356>
				putch('-', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 2d                	push   $0x2d
  800645:	ff d6                	call   *%esi
				num = -(long long) num;
  800647:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064d:	f7 d8                	neg    %eax
  80064f:	83 d2 00             	adc    $0x0,%edx
  800652:	f7 da                	neg    %edx
  800654:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800657:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065c:	eb 55                	jmp    8006b3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 83 fc ff ff       	call   8002e9 <getuint>
			base = 10;
  800666:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066b:	eb 46                	jmp    8006b3 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 74 fc ff ff       	call   8002e9 <getuint>
			base = 8;
  800675:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80067a:	eb 37                	jmp    8006b3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 30                	push   $0x30
  800682:	ff d6                	call   *%esi
			putch('x', putdat);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 78                	push   $0x78
  80068a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a4:	eb 0d                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 3b fc ff ff       	call   8002e9 <getuint>
			base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b3:	83 ec 0c             	sub    $0xc,%esp
  8006b6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ba:	57                   	push   %edi
  8006bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006be:	51                   	push   %ecx
  8006bf:	52                   	push   %edx
  8006c0:	50                   	push   %eax
  8006c1:	89 da                	mov    %ebx,%edx
  8006c3:	89 f0                	mov    %esi,%eax
  8006c5:	e8 70 fb ff ff       	call   80023a <printnum>
			break;
  8006ca:	83 c4 20             	add    $0x20,%esp
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d0:	e9 ae fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	51                   	push   %ecx
  8006da:	ff d6                	call   *%esi
			break;
  8006dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e2:	e9 9c fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 25                	push   $0x25
  8006ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	eb 03                	jmp    8006f7 <vprintfmt+0x39a>
  8006f4:	83 ef 01             	sub    $0x1,%edi
  8006f7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fb:	75 f7                	jne    8006f4 <vprintfmt+0x397>
  8006fd:	e9 81 fc ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800716:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800719:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800720:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800727:	85 c0                	test   %eax,%eax
  800729:	74 26                	je     800751 <vsnprintf+0x47>
  80072b:	85 d2                	test   %edx,%edx
  80072d:	7e 22                	jle    800751 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072f:	ff 75 14             	pushl  0x14(%ebp)
  800732:	ff 75 10             	pushl  0x10(%ebp)
  800735:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	68 23 03 80 00       	push   $0x800323
  80073e:	e8 1a fc ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800743:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800746:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 05                	jmp    800756 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 9a ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 03                	jmp    800782 <strlen+0x10>
		n++;
  80077f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f7                	jne    80077f <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	ba 00 00 00 00       	mov    $0x0,%edx
  800798:	eb 03                	jmp    80079d <strnlen+0x13>
		n++;
  80079a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	39 c2                	cmp    %eax,%edx
  80079f:	74 08                	je     8007a9 <strnlen+0x1f>
  8007a1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a5:	75 f3                	jne    80079a <strnlen+0x10>
  8007a7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	89 c2                	mov    %eax,%edx
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c4:	84 db                	test   %bl,%bl
  8007c6:	75 ef                	jne    8007b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	53                   	push   %ebx
  8007d3:	e8 9a ff ff ff       	call   800772 <strlen>
  8007d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	01 d8                	add    %ebx,%eax
  8007e0:	50                   	push   %eax
  8007e1:	e8 c5 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007e6:	89 d8                	mov    %ebx,%eax
  8007e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f8:	89 f3                	mov    %esi,%ebx
  8007fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 0f                	jmp    800810 <strncpy+0x23>
		*dst++ = *src;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	0f b6 01             	movzbl (%ecx),%eax
  800807:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 39 01             	cmpb   $0x1,(%ecx)
  80080d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	39 da                	cmp    %ebx,%edx
  800812:	75 ed                	jne    800801 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	89 f0                	mov    %esi,%eax
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	8b 55 10             	mov    0x10(%ebp),%edx
  800828:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082a:	85 d2                	test   %edx,%edx
  80082c:	74 21                	je     80084f <strlcpy+0x35>
  80082e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800832:	89 f2                	mov    %esi,%edx
  800834:	eb 09                	jmp    80083f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083f:	39 c2                	cmp    %eax,%edx
  800841:	74 09                	je     80084c <strlcpy+0x32>
  800843:	0f b6 19             	movzbl (%ecx),%ebx
  800846:	84 db                	test   %bl,%bl
  800848:	75 ec                	jne    800836 <strlcpy+0x1c>
  80084a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084f:	29 f0                	sub    %esi,%eax
}
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strcmp+0x11>
		p++, q++;
  800860:	83 c1 01             	add    $0x1,%ecx
  800863:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800866:	0f b6 01             	movzbl (%ecx),%eax
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x1c>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 ef                	je     800860 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 c3                	mov    %eax,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strncmp+0x17>
		n--, p++, q++;
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 15                	je     8008ab <strncmp+0x30>
  800896:	0f b6 08             	movzbl (%eax),%ecx
  800899:	84 c9                	test   %cl,%cl
  80089b:	74 04                	je     8008a1 <strncmp+0x26>
  80089d:	3a 0a                	cmp    (%edx),%cl
  80089f:	74 eb                	je     80088c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 00             	movzbl (%eax),%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
  8008a9:	eb 05                	jmp    8008b0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bd:	eb 07                	jmp    8008c6 <strchr+0x13>
		if (*s == c)
  8008bf:	38 ca                	cmp    %cl,%dl
  8008c1:	74 0f                	je     8008d2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c3:	83 c0 01             	add    $0x1,%eax
  8008c6:	0f b6 10             	movzbl (%eax),%edx
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	75 f2                	jne    8008bf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	eb 03                	jmp    8008e3 <strfind+0xf>
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 04                	je     8008ee <strfind+0x1a>
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	75 f2                	jne    8008e0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 36                	je     800936 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 28                	jne    800930 <memset+0x40>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 23                	jne    800930 <memset+0x40>
		c &= 0xFF;
  80090d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800911:	89 d3                	mov    %edx,%ebx
  800913:	c1 e3 08             	shl    $0x8,%ebx
  800916:	89 d6                	mov    %edx,%esi
  800918:	c1 e6 18             	shl    $0x18,%esi
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	c1 e0 10             	shl    $0x10,%eax
  800920:	09 f0                	or     %esi,%eax
  800922:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800924:	89 d8                	mov    %ebx,%eax
  800926:	09 d0                	or     %edx,%eax
  800928:	c1 e9 02             	shr    $0x2,%ecx
  80092b:	fc                   	cld    
  80092c:	f3 ab                	rep stos %eax,%es:(%edi)
  80092e:	eb 06                	jmp    800936 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	fc                   	cld    
  800934:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800936:	89 f8                	mov    %edi,%eax
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 75 0c             	mov    0xc(%ebp),%esi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094b:	39 c6                	cmp    %eax,%esi
  80094d:	73 35                	jae    800984 <memmove+0x47>
  80094f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800952:	39 d0                	cmp    %edx,%eax
  800954:	73 2e                	jae    800984 <memmove+0x47>
		s += n;
		d += n;
  800956:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 d6                	mov    %edx,%esi
  80095b:	09 fe                	or     %edi,%esi
  80095d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800963:	75 13                	jne    800978 <memmove+0x3b>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 0e                	jne    800978 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096a:	83 ef 04             	sub    $0x4,%edi
  80096d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800970:	c1 e9 02             	shr    $0x2,%ecx
  800973:	fd                   	std    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 09                	jmp    800981 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800978:	83 ef 01             	sub    $0x1,%edi
  80097b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097e:	fd                   	std    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800981:	fc                   	cld    
  800982:	eb 1d                	jmp    8009a1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 f2                	mov    %esi,%edx
  800986:	09 c2                	or     %eax,%edx
  800988:	f6 c2 03             	test   $0x3,%dl
  80098b:	75 0f                	jne    80099c <memmove+0x5f>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0a                	jne    80099c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800992:	c1 e9 02             	shr    $0x2,%ecx
  800995:	89 c7                	mov    %eax,%edi
  800997:	fc                   	cld    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 05                	jmp    8009a1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099c:	89 c7                	mov    %eax,%edi
  80099e:	fc                   	cld    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a8:	ff 75 10             	pushl  0x10(%ebp)
  8009ab:	ff 75 0c             	pushl  0xc(%ebp)
  8009ae:	ff 75 08             	pushl  0x8(%ebp)
  8009b1:	e8 87 ff ff ff       	call   80093d <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	89 c6                	mov    %eax,%esi
  8009c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	eb 1a                	jmp    8009e4 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	74 0a                	je     8009de <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d4:	0f b6 c1             	movzbl %cl,%eax
  8009d7:	0f b6 db             	movzbl %bl,%ebx
  8009da:	29 d8                	sub    %ebx,%eax
  8009dc:	eb 0f                	jmp    8009ed <memcmp+0x35>
		s1++, s2++;
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e4:	39 f0                	cmp    %esi,%eax
  8009e6:	75 e2                	jne    8009ca <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f8:	89 c1                	mov    %eax,%ecx
  8009fa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a01:	eb 0a                	jmp    800a0d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	0f b6 10             	movzbl (%eax),%edx
  800a06:	39 da                	cmp    %ebx,%edx
  800a08:	74 07                	je     800a11 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 c8                	cmp    %ecx,%eax
  800a0f:	72 f2                	jb     800a03 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	75 0a                	jne    800a3e <strtol+0x2a>
		s++;
  800a34:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3c:	eb 11                	jmp    800a4f <strtol+0x3b>
  800a3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a43:	3c 2d                	cmp    $0x2d,%al
  800a45:	75 08                	jne    800a4f <strtol+0x3b>
		s++, neg = 1;
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 15                	jne    800a6c <strtol+0x58>
  800a57:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5a:	75 10                	jne    800a6c <strtol+0x58>
  800a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a60:	75 7c                	jne    800ade <strtol+0xca>
		s += 2, base = 16;
  800a62:	83 c1 02             	add    $0x2,%ecx
  800a65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6a:	eb 16                	jmp    800a82 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	75 12                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a70:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a75:	80 39 30             	cmpb   $0x30,(%ecx)
  800a78:	75 08                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8a:	0f b6 11             	movzbl (%ecx),%edx
  800a8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 09             	cmp    $0x9,%bl
  800a95:	77 08                	ja     800a9f <strtol+0x8b>
			dig = *s - '0';
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 30             	sub    $0x30,%edx
  800a9d:	eb 22                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 08                	ja     800ab1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 57             	sub    $0x57,%edx
  800aaf:	eb 10                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 16                	ja     800ad1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac4:	7d 0b                	jge    800ad1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acf:	eb b9                	jmp    800a8a <strtol+0x76>

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 0d                	je     800ae4 <strtol+0xd0>
		*endptr = (char *) s;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	89 0e                	mov    %ecx,(%esi)
  800adc:	eb 06                	jmp    800ae4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	74 98                	je     800a7a <strtol+0x66>
  800ae2:	eb 9e                	jmp    800a82 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 17                	jle    800b68 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 bf 24 80 00       	push   $0x8024bf
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 dc 24 80 00       	push   $0x8024dc
  800b63:	e8 e5 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 bf 24 80 00       	push   $0x8024bf
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 dc 24 80 00       	push   $0x8024dc
  800be4:	e8 64 f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 bf 24 80 00       	push   $0x8024bf
  800c1f:	6a 23                	push   $0x23
  800c21:	68 dc 24 80 00       	push   $0x8024dc
  800c26:	e8 22 f5 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 06 00 00 00       	mov    $0x6,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 bf 24 80 00       	push   $0x8024bf
  800c61:	6a 23                	push   $0x23
  800c63:	68 dc 24 80 00       	push   $0x8024dc
  800c68:	e8 e0 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	b8 08 00 00 00       	mov    $0x8,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 bf 24 80 00       	push   $0x8024bf
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 dc 24 80 00       	push   $0x8024dc
  800caa:	e8 9e f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 bf 24 80 00       	push   $0x8024bf
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 dc 24 80 00       	push   $0x8024dc
  800cec:	e8 5c f4 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 0a                	push   $0xa
  800d22:	68 bf 24 80 00       	push   $0x8024bf
  800d27:	6a 23                	push   $0x23
  800d29:	68 dc 24 80 00       	push   $0x8024dc
  800d2e:	e8 1a f4 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0d                	push   $0xd
  800d86:	68 bf 24 80 00       	push   $0x8024bf
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 dc 24 80 00       	push   $0x8024dc
  800d92:	e8 b6 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800da7:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800da9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dad:	75 25                	jne    800dd4 <pgfault+0x35>
  800daf:	89 d8                	mov    %ebx,%eax
  800db1:	c1 e8 0c             	shr    $0xc,%eax
  800db4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dbb:	f6 c4 08             	test   $0x8,%ah
  800dbe:	75 14                	jne    800dd4 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800dc0:	83 ec 04             	sub    $0x4,%esp
  800dc3:	68 ec 24 80 00       	push   $0x8024ec
  800dc8:	6a 1e                	push   $0x1e
  800dca:	68 80 25 80 00       	push   $0x802580
  800dcf:	e8 79 f3 ff ff       	call   80014d <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800dd4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800dda:	e8 91 fd ff ff       	call   800b70 <sys_getenvid>
  800ddf:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800de1:	83 ec 04             	sub    $0x4,%esp
  800de4:	6a 07                	push   $0x7
  800de6:	68 00 f0 7f 00       	push   $0x7ff000
  800deb:	50                   	push   %eax
  800dec:	e8 bd fd ff ff       	call   800bae <sys_page_alloc>
	if (r < 0)
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	85 c0                	test   %eax,%eax
  800df6:	79 12                	jns    800e0a <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800df8:	50                   	push   %eax
  800df9:	68 18 25 80 00       	push   $0x802518
  800dfe:	6a 31                	push   $0x31
  800e00:	68 80 25 80 00       	push   $0x802580
  800e05:	e8 43 f3 ff ff       	call   80014d <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	68 00 10 00 00       	push   $0x1000
  800e12:	53                   	push   %ebx
  800e13:	68 00 f0 7f 00       	push   $0x7ff000
  800e18:	e8 88 fb ff ff       	call   8009a5 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e1d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e24:	53                   	push   %ebx
  800e25:	56                   	push   %esi
  800e26:	68 00 f0 7f 00       	push   $0x7ff000
  800e2b:	56                   	push   %esi
  800e2c:	e8 c0 fd ff ff       	call   800bf1 <sys_page_map>
	if (r < 0)
  800e31:	83 c4 20             	add    $0x20,%esp
  800e34:	85 c0                	test   %eax,%eax
  800e36:	79 12                	jns    800e4a <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e38:	50                   	push   %eax
  800e39:	68 3c 25 80 00       	push   $0x80253c
  800e3e:	6a 39                	push   $0x39
  800e40:	68 80 25 80 00       	push   $0x802580
  800e45:	e8 03 f3 ff ff       	call   80014d <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	56                   	push   %esi
  800e53:	e8 db fd ff ff       	call   800c33 <sys_page_unmap>
	if (r < 0)
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	79 12                	jns    800e71 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e5f:	50                   	push   %eax
  800e60:	68 60 25 80 00       	push   $0x802560
  800e65:	6a 3e                	push   $0x3e
  800e67:	68 80 25 80 00       	push   $0x802580
  800e6c:	e8 dc f2 ff ff       	call   80014d <_panic>
}
  800e71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	53                   	push   %ebx
  800e7e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e81:	68 9f 0d 80 00       	push   $0x800d9f
  800e86:	e8 84 0e 00 00       	call   801d0f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e8b:	b8 07 00 00 00       	mov    $0x7,%eax
  800e90:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	0f 88 67 01 00 00    	js     801004 <fork+0x18c>
  800e9d:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800ea2:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	75 21                	jne    800ecc <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eab:	e8 c0 fc ff ff       	call   800b70 <sys_getenvid>
  800eb0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eb8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebd:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800ec2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec7:	e9 42 01 00 00       	jmp    80100e <fork+0x196>
  800ecc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ecf:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800ed1:	89 d8                	mov    %ebx,%eax
  800ed3:	c1 e8 16             	shr    $0x16,%eax
  800ed6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800edd:	a8 01                	test   $0x1,%al
  800edf:	0f 84 c0 00 00 00    	je     800fa5 <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800ee5:	89 d8                	mov    %ebx,%eax
  800ee7:	c1 e8 0c             	shr    $0xc,%eax
  800eea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef1:	f6 c2 01             	test   $0x1,%dl
  800ef4:	0f 84 ab 00 00 00    	je     800fa5 <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800efa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f01:	a9 02 08 00 00       	test   $0x802,%eax
  800f06:	0f 84 99 00 00 00    	je     800fa5 <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f0c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f13:	f6 c4 04             	test   $0x4,%ah
  800f16:	74 17                	je     800f2f <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f18:	83 ec 0c             	sub    $0xc,%esp
  800f1b:	68 07 0e 00 00       	push   $0xe07
  800f20:	53                   	push   %ebx
  800f21:	57                   	push   %edi
  800f22:	53                   	push   %ebx
  800f23:	6a 00                	push   $0x0
  800f25:	e8 c7 fc ff ff       	call   800bf1 <sys_page_map>
  800f2a:	83 c4 20             	add    $0x20,%esp
  800f2d:	eb 76                	jmp    800fa5 <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f2f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f36:	a8 02                	test   $0x2,%al
  800f38:	75 0c                	jne    800f46 <fork+0xce>
  800f3a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f41:	f6 c4 08             	test   $0x8,%ah
  800f44:	74 3f                	je     800f85 <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	68 05 08 00 00       	push   $0x805
  800f4e:	53                   	push   %ebx
  800f4f:	57                   	push   %edi
  800f50:	53                   	push   %ebx
  800f51:	6a 00                	push   $0x0
  800f53:	e8 99 fc ff ff       	call   800bf1 <sys_page_map>
		if (r < 0)
  800f58:	83 c4 20             	add    $0x20,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	0f 88 a5 00 00 00    	js     801008 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	68 05 08 00 00       	push   $0x805
  800f6b:	53                   	push   %ebx
  800f6c:	6a 00                	push   $0x0
  800f6e:	53                   	push   %ebx
  800f6f:	6a 00                	push   $0x0
  800f71:	e8 7b fc ff ff       	call   800bf1 <sys_page_map>
  800f76:	83 c4 20             	add    $0x20,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f80:	0f 4f c1             	cmovg  %ecx,%eax
  800f83:	eb 1c                	jmp    800fa1 <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f85:	83 ec 0c             	sub    $0xc,%esp
  800f88:	6a 05                	push   $0x5
  800f8a:	53                   	push   %ebx
  800f8b:	57                   	push   %edi
  800f8c:	53                   	push   %ebx
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 5d fc ff ff       	call   800bf1 <sys_page_map>
  800f94:	83 c4 20             	add    $0x20,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9e:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 67                	js     80100c <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fa5:	83 c6 01             	add    $0x1,%esi
  800fa8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fae:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800fb4:	0f 85 17 ff ff ff    	jne    800ed1 <fork+0x59>
  800fba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fbd:	83 ec 04             	sub    $0x4,%esp
  800fc0:	6a 07                	push   $0x7
  800fc2:	68 00 f0 bf ee       	push   $0xeebff000
  800fc7:	57                   	push   %edi
  800fc8:	e8 e1 fb ff ff       	call   800bae <sys_page_alloc>
	if (r < 0)
  800fcd:	83 c4 10             	add    $0x10,%esp
		return r;
  800fd0:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 38                	js     80100e <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	68 56 1d 80 00       	push   $0x801d56
  800fde:	57                   	push   %edi
  800fdf:	e8 15 fd ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fe4:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe7:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 21                	js     80100e <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	6a 02                	push   $0x2
  800ff2:	57                   	push   %edi
  800ff3:	e8 7d fc ff ff       	call   800c75 <sys_env_set_status>
	if (r < 0)
  800ff8:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	0f 48 f8             	cmovs  %eax,%edi
  801000:	89 fa                	mov    %edi,%edx
  801002:	eb 0a                	jmp    80100e <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801004:	89 c2                	mov    %eax,%edx
  801006:	eb 06                	jmp    80100e <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801008:	89 c2                	mov    %eax,%edx
  80100a:	eb 02                	jmp    80100e <fork+0x196>
  80100c:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  80100e:	89 d0                	mov    %edx,%eax
  801010:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sfork>:

// Challenge!
int
sfork(void)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80101e:	68 8b 25 80 00       	push   $0x80258b
  801023:	68 c6 00 00 00       	push   $0xc6
  801028:	68 80 25 80 00       	push   $0x802580
  80102d:	e8 1b f1 ff ff       	call   80014d <_panic>

00801032 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801035:	8b 45 08             	mov    0x8(%ebp),%eax
  801038:	05 00 00 00 30       	add    $0x30000000,%eax
  80103d:	c1 e8 0c             	shr    $0xc,%eax
}
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801045:	8b 45 08             	mov    0x8(%ebp),%eax
  801048:	05 00 00 00 30       	add    $0x30000000,%eax
  80104d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801052:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801064:	89 c2                	mov    %eax,%edx
  801066:	c1 ea 16             	shr    $0x16,%edx
  801069:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801070:	f6 c2 01             	test   $0x1,%dl
  801073:	74 11                	je     801086 <fd_alloc+0x2d>
  801075:	89 c2                	mov    %eax,%edx
  801077:	c1 ea 0c             	shr    $0xc,%edx
  80107a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801081:	f6 c2 01             	test   $0x1,%dl
  801084:	75 09                	jne    80108f <fd_alloc+0x36>
			*fd_store = fd;
  801086:	89 01                	mov    %eax,(%ecx)
			return 0;
  801088:	b8 00 00 00 00       	mov    $0x0,%eax
  80108d:	eb 17                	jmp    8010a6 <fd_alloc+0x4d>
  80108f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801094:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801099:	75 c9                	jne    801064 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80109b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010a1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010a6:	5d                   	pop    %ebp
  8010a7:	c3                   	ret    

008010a8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ae:	83 f8 1f             	cmp    $0x1f,%eax
  8010b1:	77 36                	ja     8010e9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010b3:	c1 e0 0c             	shl    $0xc,%eax
  8010b6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010bb:	89 c2                	mov    %eax,%edx
  8010bd:	c1 ea 16             	shr    $0x16,%edx
  8010c0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c7:	f6 c2 01             	test   $0x1,%dl
  8010ca:	74 24                	je     8010f0 <fd_lookup+0x48>
  8010cc:	89 c2                	mov    %eax,%edx
  8010ce:	c1 ea 0c             	shr    $0xc,%edx
  8010d1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d8:	f6 c2 01             	test   $0x1,%dl
  8010db:	74 1a                	je     8010f7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e0:	89 02                	mov    %eax,(%edx)
	return 0;
  8010e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e7:	eb 13                	jmp    8010fc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ee:	eb 0c                	jmp    8010fc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f5:	eb 05                	jmp    8010fc <fd_lookup+0x54>
  8010f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801107:	ba 24 26 80 00       	mov    $0x802624,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80110c:	eb 13                	jmp    801121 <dev_lookup+0x23>
  80110e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801111:	39 08                	cmp    %ecx,(%eax)
  801113:	75 0c                	jne    801121 <dev_lookup+0x23>
			*dev = devtab[i];
  801115:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801118:	89 01                	mov    %eax,(%ecx)
			return 0;
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
  80111f:	eb 2e                	jmp    80114f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801121:	8b 02                	mov    (%edx),%eax
  801123:	85 c0                	test   %eax,%eax
  801125:	75 e7                	jne    80110e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801127:	a1 08 40 80 00       	mov    0x804008,%eax
  80112c:	8b 40 48             	mov    0x48(%eax),%eax
  80112f:	83 ec 04             	sub    $0x4,%esp
  801132:	51                   	push   %ecx
  801133:	50                   	push   %eax
  801134:	68 a4 25 80 00       	push   $0x8025a4
  801139:	e8 e8 f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  80113e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801141:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80114f:	c9                   	leave  
  801150:	c3                   	ret    

00801151 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 10             	sub    $0x10,%esp
  801159:	8b 75 08             	mov    0x8(%ebp),%esi
  80115c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80115f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801162:	50                   	push   %eax
  801163:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801169:	c1 e8 0c             	shr    $0xc,%eax
  80116c:	50                   	push   %eax
  80116d:	e8 36 ff ff ff       	call   8010a8 <fd_lookup>
  801172:	83 c4 08             	add    $0x8,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	78 05                	js     80117e <fd_close+0x2d>
	    || fd != fd2)
  801179:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80117c:	74 0c                	je     80118a <fd_close+0x39>
		return (must_exist ? r : 0);
  80117e:	84 db                	test   %bl,%bl
  801180:	ba 00 00 00 00       	mov    $0x0,%edx
  801185:	0f 44 c2             	cmove  %edx,%eax
  801188:	eb 41                	jmp    8011cb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80118a:	83 ec 08             	sub    $0x8,%esp
  80118d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	ff 36                	pushl  (%esi)
  801193:	e8 66 ff ff ff       	call   8010fe <dev_lookup>
  801198:	89 c3                	mov    %eax,%ebx
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	85 c0                	test   %eax,%eax
  80119f:	78 1a                	js     8011bb <fd_close+0x6a>
		if (dev->dev_close)
  8011a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 0b                	je     8011bb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011b0:	83 ec 0c             	sub    $0xc,%esp
  8011b3:	56                   	push   %esi
  8011b4:	ff d0                	call   *%eax
  8011b6:	89 c3                	mov    %eax,%ebx
  8011b8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	56                   	push   %esi
  8011bf:	6a 00                	push   $0x0
  8011c1:	e8 6d fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	89 d8                	mov    %ebx,%eax
}
  8011cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011db:	50                   	push   %eax
  8011dc:	ff 75 08             	pushl  0x8(%ebp)
  8011df:	e8 c4 fe ff ff       	call   8010a8 <fd_lookup>
  8011e4:	83 c4 08             	add    $0x8,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 10                	js     8011fb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011eb:	83 ec 08             	sub    $0x8,%esp
  8011ee:	6a 01                	push   $0x1
  8011f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f3:	e8 59 ff ff ff       	call   801151 <fd_close>
  8011f8:	83 c4 10             	add    $0x10,%esp
}
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <close_all>:

void
close_all(void)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	53                   	push   %ebx
  801201:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801204:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	53                   	push   %ebx
  80120d:	e8 c0 ff ff ff       	call   8011d2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801212:	83 c3 01             	add    $0x1,%ebx
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	83 fb 20             	cmp    $0x20,%ebx
  80121b:	75 ec                	jne    801209 <close_all+0xc>
		close(i);
}
  80121d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	57                   	push   %edi
  801226:	56                   	push   %esi
  801227:	53                   	push   %ebx
  801228:	83 ec 2c             	sub    $0x2c,%esp
  80122b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80122e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	ff 75 08             	pushl  0x8(%ebp)
  801235:	e8 6e fe ff ff       	call   8010a8 <fd_lookup>
  80123a:	83 c4 08             	add    $0x8,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	0f 88 c1 00 00 00    	js     801306 <dup+0xe4>
		return r;
	close(newfdnum);
  801245:	83 ec 0c             	sub    $0xc,%esp
  801248:	56                   	push   %esi
  801249:	e8 84 ff ff ff       	call   8011d2 <close>

	newfd = INDEX2FD(newfdnum);
  80124e:	89 f3                	mov    %esi,%ebx
  801250:	c1 e3 0c             	shl    $0xc,%ebx
  801253:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801259:	83 c4 04             	add    $0x4,%esp
  80125c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125f:	e8 de fd ff ff       	call   801042 <fd2data>
  801264:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801266:	89 1c 24             	mov    %ebx,(%esp)
  801269:	e8 d4 fd ff ff       	call   801042 <fd2data>
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801274:	89 f8                	mov    %edi,%eax
  801276:	c1 e8 16             	shr    $0x16,%eax
  801279:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801280:	a8 01                	test   $0x1,%al
  801282:	74 37                	je     8012bb <dup+0x99>
  801284:	89 f8                	mov    %edi,%eax
  801286:	c1 e8 0c             	shr    $0xc,%eax
  801289:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801290:	f6 c2 01             	test   $0x1,%dl
  801293:	74 26                	je     8012bb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801295:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80129c:	83 ec 0c             	sub    $0xc,%esp
  80129f:	25 07 0e 00 00       	and    $0xe07,%eax
  8012a4:	50                   	push   %eax
  8012a5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012a8:	6a 00                	push   $0x0
  8012aa:	57                   	push   %edi
  8012ab:	6a 00                	push   $0x0
  8012ad:	e8 3f f9 ff ff       	call   800bf1 <sys_page_map>
  8012b2:	89 c7                	mov    %eax,%edi
  8012b4:	83 c4 20             	add    $0x20,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 2e                	js     8012e9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012be:	89 d0                	mov    %edx,%eax
  8012c0:	c1 e8 0c             	shr    $0xc,%eax
  8012c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d2:	50                   	push   %eax
  8012d3:	53                   	push   %ebx
  8012d4:	6a 00                	push   $0x0
  8012d6:	52                   	push   %edx
  8012d7:	6a 00                	push   $0x0
  8012d9:	e8 13 f9 ff ff       	call   800bf1 <sys_page_map>
  8012de:	89 c7                	mov    %eax,%edi
  8012e0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012e3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e5:	85 ff                	test   %edi,%edi
  8012e7:	79 1d                	jns    801306 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	53                   	push   %ebx
  8012ed:	6a 00                	push   $0x0
  8012ef:	e8 3f f9 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012f4:	83 c4 08             	add    $0x8,%esp
  8012f7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012fa:	6a 00                	push   $0x0
  8012fc:	e8 32 f9 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	89 f8                	mov    %edi,%eax
}
  801306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5f                   	pop    %edi
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	53                   	push   %ebx
  801312:	83 ec 14             	sub    $0x14,%esp
  801315:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801318:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	53                   	push   %ebx
  80131d:	e8 86 fd ff ff       	call   8010a8 <fd_lookup>
  801322:	83 c4 08             	add    $0x8,%esp
  801325:	89 c2                	mov    %eax,%edx
  801327:	85 c0                	test   %eax,%eax
  801329:	78 6d                	js     801398 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132b:	83 ec 08             	sub    $0x8,%esp
  80132e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801335:	ff 30                	pushl  (%eax)
  801337:	e8 c2 fd ff ff       	call   8010fe <dev_lookup>
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 4c                	js     80138f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801343:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801346:	8b 42 08             	mov    0x8(%edx),%eax
  801349:	83 e0 03             	and    $0x3,%eax
  80134c:	83 f8 01             	cmp    $0x1,%eax
  80134f:	75 21                	jne    801372 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801351:	a1 08 40 80 00       	mov    0x804008,%eax
  801356:	8b 40 48             	mov    0x48(%eax),%eax
  801359:	83 ec 04             	sub    $0x4,%esp
  80135c:	53                   	push   %ebx
  80135d:	50                   	push   %eax
  80135e:	68 e8 25 80 00       	push   $0x8025e8
  801363:	e8 be ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801370:	eb 26                	jmp    801398 <read+0x8a>
	}
	if (!dev->dev_read)
  801372:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801375:	8b 40 08             	mov    0x8(%eax),%eax
  801378:	85 c0                	test   %eax,%eax
  80137a:	74 17                	je     801393 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80137c:	83 ec 04             	sub    $0x4,%esp
  80137f:	ff 75 10             	pushl  0x10(%ebp)
  801382:	ff 75 0c             	pushl  0xc(%ebp)
  801385:	52                   	push   %edx
  801386:	ff d0                	call   *%eax
  801388:	89 c2                	mov    %eax,%edx
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	eb 09                	jmp    801398 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138f:	89 c2                	mov    %eax,%edx
  801391:	eb 05                	jmp    801398 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801393:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801398:	89 d0                	mov    %edx,%eax
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	57                   	push   %edi
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 0c             	sub    $0xc,%esp
  8013a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b3:	eb 21                	jmp    8013d6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	89 f0                	mov    %esi,%eax
  8013ba:	29 d8                	sub    %ebx,%eax
  8013bc:	50                   	push   %eax
  8013bd:	89 d8                	mov    %ebx,%eax
  8013bf:	03 45 0c             	add    0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	57                   	push   %edi
  8013c4:	e8 45 ff ff ff       	call   80130e <read>
		if (m < 0)
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 10                	js     8013e0 <readn+0x41>
			return m;
		if (m == 0)
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	74 0a                	je     8013de <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d4:	01 c3                	add    %eax,%ebx
  8013d6:	39 f3                	cmp    %esi,%ebx
  8013d8:	72 db                	jb     8013b5 <readn+0x16>
  8013da:	89 d8                	mov    %ebx,%eax
  8013dc:	eb 02                	jmp    8013e0 <readn+0x41>
  8013de:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5f                   	pop    %edi
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 14             	sub    $0x14,%esp
  8013ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	53                   	push   %ebx
  8013f7:	e8 ac fc ff ff       	call   8010a8 <fd_lookup>
  8013fc:	83 c4 08             	add    $0x8,%esp
  8013ff:	89 c2                	mov    %eax,%edx
  801401:	85 c0                	test   %eax,%eax
  801403:	78 68                	js     80146d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140f:	ff 30                	pushl  (%eax)
  801411:	e8 e8 fc ff ff       	call   8010fe <dev_lookup>
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 47                	js     801464 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801420:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801424:	75 21                	jne    801447 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801426:	a1 08 40 80 00       	mov    0x804008,%eax
  80142b:	8b 40 48             	mov    0x48(%eax),%eax
  80142e:	83 ec 04             	sub    $0x4,%esp
  801431:	53                   	push   %ebx
  801432:	50                   	push   %eax
  801433:	68 04 26 80 00       	push   $0x802604
  801438:	e8 e9 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801445:	eb 26                	jmp    80146d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801447:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80144a:	8b 52 0c             	mov    0xc(%edx),%edx
  80144d:	85 d2                	test   %edx,%edx
  80144f:	74 17                	je     801468 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801451:	83 ec 04             	sub    $0x4,%esp
  801454:	ff 75 10             	pushl  0x10(%ebp)
  801457:	ff 75 0c             	pushl  0xc(%ebp)
  80145a:	50                   	push   %eax
  80145b:	ff d2                	call   *%edx
  80145d:	89 c2                	mov    %eax,%edx
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	eb 09                	jmp    80146d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801464:	89 c2                	mov    %eax,%edx
  801466:	eb 05                	jmp    80146d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801468:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80146d:	89 d0                	mov    %edx,%eax
  80146f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <seek>:

int
seek(int fdnum, off_t offset)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80147d:	50                   	push   %eax
  80147e:	ff 75 08             	pushl  0x8(%ebp)
  801481:	e8 22 fc ff ff       	call   8010a8 <fd_lookup>
  801486:	83 c4 08             	add    $0x8,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 0e                	js     80149b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80148d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801490:	8b 55 0c             	mov    0xc(%ebp),%edx
  801493:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 14             	sub    $0x14,%esp
  8014a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014aa:	50                   	push   %eax
  8014ab:	53                   	push   %ebx
  8014ac:	e8 f7 fb ff ff       	call   8010a8 <fd_lookup>
  8014b1:	83 c4 08             	add    $0x8,%esp
  8014b4:	89 c2                	mov    %eax,%edx
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	78 65                	js     80151f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c4:	ff 30                	pushl  (%eax)
  8014c6:	e8 33 fc ff ff       	call   8010fe <dev_lookup>
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 44                	js     801516 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d9:	75 21                	jne    8014fc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014db:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014e0:	8b 40 48             	mov    0x48(%eax),%eax
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	53                   	push   %ebx
  8014e7:	50                   	push   %eax
  8014e8:	68 c4 25 80 00       	push   $0x8025c4
  8014ed:	e8 34 ed ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fa:	eb 23                	jmp    80151f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ff:	8b 52 18             	mov    0x18(%edx),%edx
  801502:	85 d2                	test   %edx,%edx
  801504:	74 14                	je     80151a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	ff 75 0c             	pushl  0xc(%ebp)
  80150c:	50                   	push   %eax
  80150d:	ff d2                	call   *%edx
  80150f:	89 c2                	mov    %eax,%edx
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	eb 09                	jmp    80151f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801516:	89 c2                	mov    %eax,%edx
  801518:	eb 05                	jmp    80151f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80151a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80151f:	89 d0                	mov    %edx,%eax
  801521:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	53                   	push   %ebx
  80152a:	83 ec 14             	sub    $0x14,%esp
  80152d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801530:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	ff 75 08             	pushl  0x8(%ebp)
  801537:	e8 6c fb ff ff       	call   8010a8 <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	89 c2                	mov    %eax,%edx
  801541:	85 c0                	test   %eax,%eax
  801543:	78 58                	js     80159d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154f:	ff 30                	pushl  (%eax)
  801551:	e8 a8 fb ff ff       	call   8010fe <dev_lookup>
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 37                	js     801594 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80155d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801560:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801564:	74 32                	je     801598 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801566:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801569:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801570:	00 00 00 
	stat->st_isdir = 0;
  801573:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80157a:	00 00 00 
	stat->st_dev = dev;
  80157d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	53                   	push   %ebx
  801587:	ff 75 f0             	pushl  -0x10(%ebp)
  80158a:	ff 50 14             	call   *0x14(%eax)
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	eb 09                	jmp    80159d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801594:	89 c2                	mov    %eax,%edx
  801596:	eb 05                	jmp    80159d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801598:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80159d:	89 d0                	mov    %edx,%eax
  80159f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	6a 00                	push   $0x0
  8015ae:	ff 75 08             	pushl  0x8(%ebp)
  8015b1:	e8 d6 01 00 00       	call   80178c <open>
  8015b6:	89 c3                	mov    %eax,%ebx
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 1b                	js     8015da <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	ff 75 0c             	pushl  0xc(%ebp)
  8015c5:	50                   	push   %eax
  8015c6:	e8 5b ff ff ff       	call   801526 <fstat>
  8015cb:	89 c6                	mov    %eax,%esi
	close(fd);
  8015cd:	89 1c 24             	mov    %ebx,(%esp)
  8015d0:	e8 fd fb ff ff       	call   8011d2 <close>
	return r;
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	89 f0                	mov    %esi,%eax
}
  8015da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5d                   	pop    %ebp
  8015e0:	c3                   	ret    

008015e1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
  8015e6:	89 c6                	mov    %eax,%esi
  8015e8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015ea:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015f1:	75 12                	jne    801605 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015f3:	83 ec 0c             	sub    $0xc,%esp
  8015f6:	6a 01                	push   $0x1
  8015f8:	e8 38 08 00 00       	call   801e35 <ipc_find_env>
  8015fd:	a3 00 40 80 00       	mov    %eax,0x804000
  801602:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801605:	6a 07                	push   $0x7
  801607:	68 00 50 80 00       	push   $0x805000
  80160c:	56                   	push   %esi
  80160d:	ff 35 00 40 80 00    	pushl  0x804000
  801613:	e8 c9 07 00 00       	call   801de1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801618:	83 c4 0c             	add    $0xc,%esp
  80161b:	6a 00                	push   $0x0
  80161d:	53                   	push   %ebx
  80161e:	6a 00                	push   $0x0
  801620:	e8 55 07 00 00       	call   801d7a <ipc_recv>
}
  801625:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801628:	5b                   	pop    %ebx
  801629:	5e                   	pop    %esi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    

0080162c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801632:	8b 45 08             	mov    0x8(%ebp),%eax
  801635:	8b 40 0c             	mov    0xc(%eax),%eax
  801638:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80163d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801640:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801645:	ba 00 00 00 00       	mov    $0x0,%edx
  80164a:	b8 02 00 00 00       	mov    $0x2,%eax
  80164f:	e8 8d ff ff ff       	call   8015e1 <fsipc>
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80165c:	8b 45 08             	mov    0x8(%ebp),%eax
  80165f:	8b 40 0c             	mov    0xc(%eax),%eax
  801662:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801667:	ba 00 00 00 00       	mov    $0x0,%edx
  80166c:	b8 06 00 00 00       	mov    $0x6,%eax
  801671:	e8 6b ff ff ff       	call   8015e1 <fsipc>
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	53                   	push   %ebx
  80167c:	83 ec 04             	sub    $0x4,%esp
  80167f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801682:	8b 45 08             	mov    0x8(%ebp),%eax
  801685:	8b 40 0c             	mov    0xc(%eax),%eax
  801688:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80168d:	ba 00 00 00 00       	mov    $0x0,%edx
  801692:	b8 05 00 00 00       	mov    $0x5,%eax
  801697:	e8 45 ff ff ff       	call   8015e1 <fsipc>
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 2c                	js     8016cc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	68 00 50 80 00       	push   $0x805000
  8016a8:	53                   	push   %ebx
  8016a9:	e8 fd f0 ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ae:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016b9:	a1 84 50 80 00       	mov    0x805084,%eax
  8016be:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016da:	8b 55 08             	mov    0x8(%ebp),%edx
  8016dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8016e0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016e6:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016eb:	50                   	push   %eax
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	68 08 50 80 00       	push   $0x805008
  8016f4:	e8 44 f2 ff ff       	call   80093d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	b8 04 00 00 00       	mov    $0x4,%eax
  801703:	e8 d9 fe ff ff       	call   8015e1 <fsipc>

}
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
  80170f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80171d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 03 00 00 00       	mov    $0x3,%eax
  80172d:	e8 af fe ff ff       	call   8015e1 <fsipc>
  801732:	89 c3                	mov    %eax,%ebx
  801734:	85 c0                	test   %eax,%eax
  801736:	78 4b                	js     801783 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801738:	39 c6                	cmp    %eax,%esi
  80173a:	73 16                	jae    801752 <devfile_read+0x48>
  80173c:	68 34 26 80 00       	push   $0x802634
  801741:	68 3b 26 80 00       	push   $0x80263b
  801746:	6a 7c                	push   $0x7c
  801748:	68 50 26 80 00       	push   $0x802650
  80174d:	e8 fb e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  801752:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801757:	7e 16                	jle    80176f <devfile_read+0x65>
  801759:	68 5b 26 80 00       	push   $0x80265b
  80175e:	68 3b 26 80 00       	push   $0x80263b
  801763:	6a 7d                	push   $0x7d
  801765:	68 50 26 80 00       	push   $0x802650
  80176a:	e8 de e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176f:	83 ec 04             	sub    $0x4,%esp
  801772:	50                   	push   %eax
  801773:	68 00 50 80 00       	push   $0x805000
  801778:	ff 75 0c             	pushl  0xc(%ebp)
  80177b:	e8 bd f1 ff ff       	call   80093d <memmove>
	return r;
  801780:	83 c4 10             	add    $0x10,%esp
}
  801783:	89 d8                	mov    %ebx,%eax
  801785:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	83 ec 20             	sub    $0x20,%esp
  801793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801796:	53                   	push   %ebx
  801797:	e8 d6 ef ff ff       	call   800772 <strlen>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a4:	7f 67                	jg     80180d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ac:	50                   	push   %eax
  8017ad:	e8 a7 f8 ff ff       	call   801059 <fd_alloc>
  8017b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 57                	js     801812 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	53                   	push   %ebx
  8017bf:	68 00 50 80 00       	push   $0x805000
  8017c4:	e8 e2 ef ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d9:	e8 03 fe ff ff       	call   8015e1 <fsipc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	79 14                	jns    8017fb <open+0x6f>
		fd_close(fd, 0);
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	6a 00                	push   $0x0
  8017ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ef:	e8 5d f9 ff ff       	call   801151 <fd_close>
		return r;
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	89 da                	mov    %ebx,%edx
  8017f9:	eb 17                	jmp    801812 <open+0x86>
	}

	return fd2num(fd);
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801801:	e8 2c f8 ff ff       	call   801032 <fd2num>
  801806:	89 c2                	mov    %eax,%edx
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	eb 05                	jmp    801812 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80180d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801812:	89 d0                	mov    %edx,%eax
  801814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
  801824:	b8 08 00 00 00       	mov    $0x8,%eax
  801829:	e8 b3 fd ff ff       	call   8015e1 <fsipc>
}
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801838:	83 ec 0c             	sub    $0xc,%esp
  80183b:	ff 75 08             	pushl  0x8(%ebp)
  80183e:	e8 ff f7 ff ff       	call   801042 <fd2data>
  801843:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801845:	83 c4 08             	add    $0x8,%esp
  801848:	68 67 26 80 00       	push   $0x802667
  80184d:	53                   	push   %ebx
  80184e:	e8 58 ef ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801853:	8b 46 04             	mov    0x4(%esi),%eax
  801856:	2b 06                	sub    (%esi),%eax
  801858:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80185e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801865:	00 00 00 
	stat->st_dev = &devpipe;
  801868:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80186f:	30 80 00 
	return 0;
}
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801888:	53                   	push   %ebx
  801889:	6a 00                	push   $0x0
  80188b:	e8 a3 f3 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801890:	89 1c 24             	mov    %ebx,(%esp)
  801893:	e8 aa f7 ff ff       	call   801042 <fd2data>
  801898:	83 c4 08             	add    $0x8,%esp
  80189b:	50                   	push   %eax
  80189c:	6a 00                	push   $0x0
  80189e:	e8 90 f3 ff ff       	call   800c33 <sys_page_unmap>
}
  8018a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	57                   	push   %edi
  8018ac:	56                   	push   %esi
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 1c             	sub    $0x1c,%esp
  8018b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b6:	a1 08 40 80 00       	mov    0x804008,%eax
  8018bb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018be:	83 ec 0c             	sub    $0xc,%esp
  8018c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c4:	e8 a5 05 00 00       	call   801e6e <pageref>
  8018c9:	89 c3                	mov    %eax,%ebx
  8018cb:	89 3c 24             	mov    %edi,(%esp)
  8018ce:	e8 9b 05 00 00       	call   801e6e <pageref>
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	39 c3                	cmp    %eax,%ebx
  8018d8:	0f 94 c1             	sete   %cl
  8018db:	0f b6 c9             	movzbl %cl,%ecx
  8018de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018e1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8018e7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018ea:	39 ce                	cmp    %ecx,%esi
  8018ec:	74 1b                	je     801909 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018ee:	39 c3                	cmp    %eax,%ebx
  8018f0:	75 c4                	jne    8018b6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018f2:	8b 42 58             	mov    0x58(%edx),%eax
  8018f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f8:	50                   	push   %eax
  8018f9:	56                   	push   %esi
  8018fa:	68 6e 26 80 00       	push   $0x80266e
  8018ff:	e8 22 e9 ff ff       	call   800226 <cprintf>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	eb ad                	jmp    8018b6 <_pipeisclosed+0xe>
	}
}
  801909:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5f                   	pop    %edi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	57                   	push   %edi
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	83 ec 28             	sub    $0x28,%esp
  80191d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801920:	56                   	push   %esi
  801921:	e8 1c f7 ff ff       	call   801042 <fd2data>
  801926:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	bf 00 00 00 00       	mov    $0x0,%edi
  801930:	eb 4b                	jmp    80197d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801932:	89 da                	mov    %ebx,%edx
  801934:	89 f0                	mov    %esi,%eax
  801936:	e8 6d ff ff ff       	call   8018a8 <_pipeisclosed>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	75 48                	jne    801987 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80193f:	e8 4b f2 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801944:	8b 43 04             	mov    0x4(%ebx),%eax
  801947:	8b 0b                	mov    (%ebx),%ecx
  801949:	8d 51 20             	lea    0x20(%ecx),%edx
  80194c:	39 d0                	cmp    %edx,%eax
  80194e:	73 e2                	jae    801932 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801953:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801957:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80195a:	89 c2                	mov    %eax,%edx
  80195c:	c1 fa 1f             	sar    $0x1f,%edx
  80195f:	89 d1                	mov    %edx,%ecx
  801961:	c1 e9 1b             	shr    $0x1b,%ecx
  801964:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801967:	83 e2 1f             	and    $0x1f,%edx
  80196a:	29 ca                	sub    %ecx,%edx
  80196c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801970:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801974:	83 c0 01             	add    $0x1,%eax
  801977:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197a:	83 c7 01             	add    $0x1,%edi
  80197d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801980:	75 c2                	jne    801944 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801982:	8b 45 10             	mov    0x10(%ebp),%eax
  801985:	eb 05                	jmp    80198c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80198c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	83 ec 18             	sub    $0x18,%esp
  80199d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019a0:	57                   	push   %edi
  8019a1:	e8 9c f6 ff ff       	call   801042 <fd2data>
  8019a6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b0:	eb 3d                	jmp    8019ef <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019b2:	85 db                	test   %ebx,%ebx
  8019b4:	74 04                	je     8019ba <devpipe_read+0x26>
				return i;
  8019b6:	89 d8                	mov    %ebx,%eax
  8019b8:	eb 44                	jmp    8019fe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019ba:	89 f2                	mov    %esi,%edx
  8019bc:	89 f8                	mov    %edi,%eax
  8019be:	e8 e5 fe ff ff       	call   8018a8 <_pipeisclosed>
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	75 32                	jne    8019f9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c7:	e8 c3 f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019cc:	8b 06                	mov    (%esi),%eax
  8019ce:	3b 46 04             	cmp    0x4(%esi),%eax
  8019d1:	74 df                	je     8019b2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019d3:	99                   	cltd   
  8019d4:	c1 ea 1b             	shr    $0x1b,%edx
  8019d7:	01 d0                	add    %edx,%eax
  8019d9:	83 e0 1f             	and    $0x1f,%eax
  8019dc:	29 d0                	sub    %edx,%eax
  8019de:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019e9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ec:	83 c3 01             	add    $0x1,%ebx
  8019ef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019f2:	75 d8                	jne    8019cc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f7:	eb 05                	jmp    8019fe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a01:	5b                   	pop    %ebx
  801a02:	5e                   	pop    %esi
  801a03:	5f                   	pop    %edi
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a11:	50                   	push   %eax
  801a12:	e8 42 f6 ff ff       	call   801059 <fd_alloc>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	89 c2                	mov    %eax,%edx
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	0f 88 2c 01 00 00    	js     801b50 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	68 07 04 00 00       	push   $0x407
  801a2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2f:	6a 00                	push   $0x0
  801a31:	e8 78 f1 ff ff       	call   800bae <sys_page_alloc>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	0f 88 0d 01 00 00    	js     801b50 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	e8 0a f6 ff ff       	call   801059 <fd_alloc>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	0f 88 e2 00 00 00    	js     801b3e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5c:	83 ec 04             	sub    $0x4,%esp
  801a5f:	68 07 04 00 00       	push   $0x407
  801a64:	ff 75 f0             	pushl  -0x10(%ebp)
  801a67:	6a 00                	push   $0x0
  801a69:	e8 40 f1 ff ff       	call   800bae <sys_page_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	0f 88 c3 00 00 00    	js     801b3e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a81:	e8 bc f5 ff ff       	call   801042 <fd2data>
  801a86:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a88:	83 c4 0c             	add    $0xc,%esp
  801a8b:	68 07 04 00 00       	push   $0x407
  801a90:	50                   	push   %eax
  801a91:	6a 00                	push   $0x0
  801a93:	e8 16 f1 ff ff       	call   800bae <sys_page_alloc>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	0f 88 89 00 00 00    	js     801b2e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	ff 75 f0             	pushl  -0x10(%ebp)
  801aab:	e8 92 f5 ff ff       	call   801042 <fd2data>
  801ab0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ab7:	50                   	push   %eax
  801ab8:	6a 00                	push   $0x0
  801aba:	56                   	push   %esi
  801abb:	6a 00                	push   $0x0
  801abd:	e8 2f f1 ff ff       	call   800bf1 <sys_page_map>
  801ac2:	89 c3                	mov    %eax,%ebx
  801ac4:	83 c4 20             	add    $0x20,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 55                	js     801b20 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801acb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ae0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	ff 75 f4             	pushl  -0xc(%ebp)
  801afb:	e8 32 f5 ff ff       	call   801032 <fd2num>
  801b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b03:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b05:	83 c4 04             	add    $0x4,%esp
  801b08:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0b:	e8 22 f5 ff ff       	call   801032 <fd2num>
  801b10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b13:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1e:	eb 30                	jmp    801b50 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b20:	83 ec 08             	sub    $0x8,%esp
  801b23:	56                   	push   %esi
  801b24:	6a 00                	push   $0x0
  801b26:	e8 08 f1 ff ff       	call   800c33 <sys_page_unmap>
  801b2b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b2e:	83 ec 08             	sub    $0x8,%esp
  801b31:	ff 75 f0             	pushl  -0x10(%ebp)
  801b34:	6a 00                	push   $0x0
  801b36:	e8 f8 f0 ff ff       	call   800c33 <sys_page_unmap>
  801b3b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b3e:	83 ec 08             	sub    $0x8,%esp
  801b41:	ff 75 f4             	pushl  -0xc(%ebp)
  801b44:	6a 00                	push   $0x0
  801b46:	e8 e8 f0 ff ff       	call   800c33 <sys_page_unmap>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b50:	89 d0                	mov    %edx,%eax
  801b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b62:	50                   	push   %eax
  801b63:	ff 75 08             	pushl  0x8(%ebp)
  801b66:	e8 3d f5 ff ff       	call   8010a8 <fd_lookup>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 18                	js     801b8a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	e8 c5 f4 ff ff       	call   801042 <fd2data>
	return _pipeisclosed(fd, p);
  801b7d:	89 c2                	mov    %eax,%edx
  801b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b82:	e8 21 fd ff ff       	call   8018a8 <_pipeisclosed>
  801b87:	83 c4 10             	add    $0x10,%esp
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b9c:	68 86 26 80 00       	push   $0x802686
  801ba1:	ff 75 0c             	pushl  0xc(%ebp)
  801ba4:	e8 02 ec ff ff       	call   8007ab <strcpy>
	return 0;
}
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	53                   	push   %ebx
  801bb6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bbc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bc1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc7:	eb 2d                	jmp    801bf6 <devcons_write+0x46>
		m = n - tot;
  801bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bcc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bce:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bd1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bd6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	53                   	push   %ebx
  801bdd:	03 45 0c             	add    0xc(%ebp),%eax
  801be0:	50                   	push   %eax
  801be1:	57                   	push   %edi
  801be2:	e8 56 ed ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  801be7:	83 c4 08             	add    $0x8,%esp
  801bea:	53                   	push   %ebx
  801beb:	57                   	push   %edi
  801bec:	e8 01 ef ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf1:	01 de                	add    %ebx,%esi
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	89 f0                	mov    %esi,%eax
  801bf8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bfb:	72 cc                	jb     801bc9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c14:	74 2a                	je     801c40 <devcons_read+0x3b>
  801c16:	eb 05                	jmp    801c1d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c18:	e8 72 ef ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c1d:	e8 ee ee ff ff       	call   800b10 <sys_cgetc>
  801c22:	85 c0                	test   %eax,%eax
  801c24:	74 f2                	je     801c18 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 16                	js     801c40 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c2a:	83 f8 04             	cmp    $0x4,%eax
  801c2d:	74 0c                	je     801c3b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c32:	88 02                	mov    %al,(%edx)
	return 1;
  801c34:	b8 01 00 00 00       	mov    $0x1,%eax
  801c39:	eb 05                	jmp    801c40 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c3b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c4e:	6a 01                	push   $0x1
  801c50:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c53:	50                   	push   %eax
  801c54:	e8 99 ee ff ff       	call   800af2 <sys_cputs>
}
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    

00801c5e <getchar>:

int
getchar(void)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c64:	6a 01                	push   $0x1
  801c66:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c69:	50                   	push   %eax
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 9d f6 ff ff       	call   80130e <read>
	if (r < 0)
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 0f                	js     801c87 <getchar+0x29>
		return r;
	if (r < 1)
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	7e 06                	jle    801c82 <getchar+0x24>
		return -E_EOF;
	return c;
  801c7c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c80:	eb 05                	jmp    801c87 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c82:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c92:	50                   	push   %eax
  801c93:	ff 75 08             	pushl  0x8(%ebp)
  801c96:	e8 0d f4 ff ff       	call   8010a8 <fd_lookup>
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 11                	js     801cb3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cab:	39 10                	cmp    %edx,(%eax)
  801cad:	0f 94 c0             	sete   %al
  801cb0:	0f b6 c0             	movzbl %al,%eax
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <opencons>:

int
opencons(void)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbe:	50                   	push   %eax
  801cbf:	e8 95 f3 ff ff       	call   801059 <fd_alloc>
  801cc4:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 3e                	js     801d0b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	68 07 04 00 00       	push   $0x407
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 cf ee ff ff       	call   800bae <sys_page_alloc>
  801cdf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 23                	js     801d0b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	50                   	push   %eax
  801d01:	e8 2c f3 ff ff       	call   801032 <fd2num>
  801d06:	89 c2                	mov    %eax,%edx
  801d08:	83 c4 10             	add    $0x10,%esp
}
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d15:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d1c:	75 2e                	jne    801d4c <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801d1e:	e8 4d ee ff ff       	call   800b70 <sys_getenvid>
  801d23:	83 ec 04             	sub    $0x4,%esp
  801d26:	68 07 0e 00 00       	push   $0xe07
  801d2b:	68 00 f0 bf ee       	push   $0xeebff000
  801d30:	50                   	push   %eax
  801d31:	e8 78 ee ff ff       	call   800bae <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801d36:	e8 35 ee ff ff       	call   800b70 <sys_getenvid>
  801d3b:	83 c4 08             	add    $0x8,%esp
  801d3e:	68 56 1d 80 00       	push   $0x801d56
  801d43:	50                   	push   %eax
  801d44:	e8 b0 ef ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
  801d49:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4f:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d56:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d57:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d5c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d5e:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801d61:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801d65:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801d69:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801d6c:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801d6f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801d70:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801d73:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801d74:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801d75:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801d79:	c3                   	ret    

00801d7a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	56                   	push   %esi
  801d7e:	53                   	push   %ebx
  801d7f:	8b 75 08             	mov    0x8(%ebp),%esi
  801d82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801d88:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801d8a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d8f:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801d92:	83 ec 0c             	sub    $0xc,%esp
  801d95:	50                   	push   %eax
  801d96:	e8 c3 ef ff ff       	call   800d5e <sys_ipc_recv>

	if (from_env_store != NULL)
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	85 f6                	test   %esi,%esi
  801da0:	74 14                	je     801db6 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801da2:	ba 00 00 00 00       	mov    $0x0,%edx
  801da7:	85 c0                	test   %eax,%eax
  801da9:	78 09                	js     801db4 <ipc_recv+0x3a>
  801dab:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801db1:	8b 52 74             	mov    0x74(%edx),%edx
  801db4:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801db6:	85 db                	test   %ebx,%ebx
  801db8:	74 14                	je     801dce <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801dba:	ba 00 00 00 00       	mov    $0x0,%edx
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	78 09                	js     801dcc <ipc_recv+0x52>
  801dc3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801dc9:	8b 52 78             	mov    0x78(%edx),%edx
  801dcc:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 08                	js     801dda <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801dd2:	a1 08 40 80 00       	mov    0x804008,%eax
  801dd7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801dda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ddd:	5b                   	pop    %ebx
  801dde:	5e                   	pop    %esi
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    

00801de1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	57                   	push   %edi
  801de5:	56                   	push   %esi
  801de6:	53                   	push   %ebx
  801de7:	83 ec 0c             	sub    $0xc,%esp
  801dea:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ded:	8b 75 0c             	mov    0xc(%ebp),%esi
  801df0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801df3:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801df5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801dfa:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801dfd:	ff 75 14             	pushl  0x14(%ebp)
  801e00:	53                   	push   %ebx
  801e01:	56                   	push   %esi
  801e02:	57                   	push   %edi
  801e03:	e8 33 ef ff ff       	call   800d3b <sys_ipc_try_send>

		if (err < 0) {
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	79 1e                	jns    801e2d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801e0f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e12:	75 07                	jne    801e1b <ipc_send+0x3a>
				sys_yield();
  801e14:	e8 76 ed ff ff       	call   800b8f <sys_yield>
  801e19:	eb e2                	jmp    801dfd <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801e1b:	50                   	push   %eax
  801e1c:	68 92 26 80 00       	push   $0x802692
  801e21:	6a 49                	push   $0x49
  801e23:	68 9f 26 80 00       	push   $0x80269f
  801e28:	e8 20 e3 ff ff       	call   80014d <_panic>
		}

	} while (err < 0);

}
  801e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e30:	5b                   	pop    %ebx
  801e31:	5e                   	pop    %esi
  801e32:	5f                   	pop    %edi
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    

00801e35 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e3b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e40:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e43:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e49:	8b 52 50             	mov    0x50(%edx),%edx
  801e4c:	39 ca                	cmp    %ecx,%edx
  801e4e:	75 0d                	jne    801e5d <ipc_find_env+0x28>
			return envs[i].env_id;
  801e50:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e53:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e58:	8b 40 48             	mov    0x48(%eax),%eax
  801e5b:	eb 0f                	jmp    801e6c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e5d:	83 c0 01             	add    $0x1,%eax
  801e60:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e65:	75 d9                	jne    801e40 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e6c:	5d                   	pop    %ebp
  801e6d:	c3                   	ret    

00801e6e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e74:	89 d0                	mov    %edx,%eax
  801e76:	c1 e8 16             	shr    $0x16,%eax
  801e79:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e80:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e85:	f6 c1 01             	test   $0x1,%cl
  801e88:	74 1d                	je     801ea7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e8a:	c1 ea 0c             	shr    $0xc,%edx
  801e8d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e94:	f6 c2 01             	test   $0x1,%dl
  801e97:	74 0e                	je     801ea7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e99:	c1 ea 0c             	shr    $0xc,%edx
  801e9c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ea3:	ef 
  801ea4:	0f b7 c0             	movzwl %ax,%eax
}
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    
  801ea9:	66 90                	xchg   %ax,%ax
  801eab:	66 90                	xchg   %ax,%ax
  801ead:	66 90                	xchg   %ax,%ax
  801eaf:	90                   	nop

00801eb0 <__udivdi3>:
  801eb0:	55                   	push   %ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 1c             	sub    $0x1c,%esp
  801eb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ebb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ebf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ec7:	85 f6                	test   %esi,%esi
  801ec9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ecd:	89 ca                	mov    %ecx,%edx
  801ecf:	89 f8                	mov    %edi,%eax
  801ed1:	75 3d                	jne    801f10 <__udivdi3+0x60>
  801ed3:	39 cf                	cmp    %ecx,%edi
  801ed5:	0f 87 c5 00 00 00    	ja     801fa0 <__udivdi3+0xf0>
  801edb:	85 ff                	test   %edi,%edi
  801edd:	89 fd                	mov    %edi,%ebp
  801edf:	75 0b                	jne    801eec <__udivdi3+0x3c>
  801ee1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee6:	31 d2                	xor    %edx,%edx
  801ee8:	f7 f7                	div    %edi
  801eea:	89 c5                	mov    %eax,%ebp
  801eec:	89 c8                	mov    %ecx,%eax
  801eee:	31 d2                	xor    %edx,%edx
  801ef0:	f7 f5                	div    %ebp
  801ef2:	89 c1                	mov    %eax,%ecx
  801ef4:	89 d8                	mov    %ebx,%eax
  801ef6:	89 cf                	mov    %ecx,%edi
  801ef8:	f7 f5                	div    %ebp
  801efa:	89 c3                	mov    %eax,%ebx
  801efc:	89 d8                	mov    %ebx,%eax
  801efe:	89 fa                	mov    %edi,%edx
  801f00:	83 c4 1c             	add    $0x1c,%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    
  801f08:	90                   	nop
  801f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f10:	39 ce                	cmp    %ecx,%esi
  801f12:	77 74                	ja     801f88 <__udivdi3+0xd8>
  801f14:	0f bd fe             	bsr    %esi,%edi
  801f17:	83 f7 1f             	xor    $0x1f,%edi
  801f1a:	0f 84 98 00 00 00    	je     801fb8 <__udivdi3+0x108>
  801f20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f25:	89 f9                	mov    %edi,%ecx
  801f27:	89 c5                	mov    %eax,%ebp
  801f29:	29 fb                	sub    %edi,%ebx
  801f2b:	d3 e6                	shl    %cl,%esi
  801f2d:	89 d9                	mov    %ebx,%ecx
  801f2f:	d3 ed                	shr    %cl,%ebp
  801f31:	89 f9                	mov    %edi,%ecx
  801f33:	d3 e0                	shl    %cl,%eax
  801f35:	09 ee                	or     %ebp,%esi
  801f37:	89 d9                	mov    %ebx,%ecx
  801f39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3d:	89 d5                	mov    %edx,%ebp
  801f3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f43:	d3 ed                	shr    %cl,%ebp
  801f45:	89 f9                	mov    %edi,%ecx
  801f47:	d3 e2                	shl    %cl,%edx
  801f49:	89 d9                	mov    %ebx,%ecx
  801f4b:	d3 e8                	shr    %cl,%eax
  801f4d:	09 c2                	or     %eax,%edx
  801f4f:	89 d0                	mov    %edx,%eax
  801f51:	89 ea                	mov    %ebp,%edx
  801f53:	f7 f6                	div    %esi
  801f55:	89 d5                	mov    %edx,%ebp
  801f57:	89 c3                	mov    %eax,%ebx
  801f59:	f7 64 24 0c          	mull   0xc(%esp)
  801f5d:	39 d5                	cmp    %edx,%ebp
  801f5f:	72 10                	jb     801f71 <__udivdi3+0xc1>
  801f61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f65:	89 f9                	mov    %edi,%ecx
  801f67:	d3 e6                	shl    %cl,%esi
  801f69:	39 c6                	cmp    %eax,%esi
  801f6b:	73 07                	jae    801f74 <__udivdi3+0xc4>
  801f6d:	39 d5                	cmp    %edx,%ebp
  801f6f:	75 03                	jne    801f74 <__udivdi3+0xc4>
  801f71:	83 eb 01             	sub    $0x1,%ebx
  801f74:	31 ff                	xor    %edi,%edi
  801f76:	89 d8                	mov    %ebx,%eax
  801f78:	89 fa                	mov    %edi,%edx
  801f7a:	83 c4 1c             	add    $0x1c,%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    
  801f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f88:	31 ff                	xor    %edi,%edi
  801f8a:	31 db                	xor    %ebx,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	89 d8                	mov    %ebx,%eax
  801fa2:	f7 f7                	div    %edi
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	89 d8                	mov    %ebx,%eax
  801faa:	89 fa                	mov    %edi,%edx
  801fac:	83 c4 1c             	add    $0x1c,%esp
  801faf:	5b                   	pop    %ebx
  801fb0:	5e                   	pop    %esi
  801fb1:	5f                   	pop    %edi
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	39 ce                	cmp    %ecx,%esi
  801fba:	72 0c                	jb     801fc8 <__udivdi3+0x118>
  801fbc:	31 db                	xor    %ebx,%ebx
  801fbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fc2:	0f 87 34 ff ff ff    	ja     801efc <__udivdi3+0x4c>
  801fc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fcd:	e9 2a ff ff ff       	jmp    801efc <__udivdi3+0x4c>
  801fd2:	66 90                	xchg   %ax,%ax
  801fd4:	66 90                	xchg   %ax,%ax
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__umoddi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801feb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 d2                	test   %edx,%edx
  801ff9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802001:	89 f3                	mov    %esi,%ebx
  802003:	89 3c 24             	mov    %edi,(%esp)
  802006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80200a:	75 1c                	jne    802028 <__umoddi3+0x48>
  80200c:	39 f7                	cmp    %esi,%edi
  80200e:	76 50                	jbe    802060 <__umoddi3+0x80>
  802010:	89 c8                	mov    %ecx,%eax
  802012:	89 f2                	mov    %esi,%edx
  802014:	f7 f7                	div    %edi
  802016:	89 d0                	mov    %edx,%eax
  802018:	31 d2                	xor    %edx,%edx
  80201a:	83 c4 1c             	add    $0x1c,%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802028:	39 f2                	cmp    %esi,%edx
  80202a:	89 d0                	mov    %edx,%eax
  80202c:	77 52                	ja     802080 <__umoddi3+0xa0>
  80202e:	0f bd ea             	bsr    %edx,%ebp
  802031:	83 f5 1f             	xor    $0x1f,%ebp
  802034:	75 5a                	jne    802090 <__umoddi3+0xb0>
  802036:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80203a:	0f 82 e0 00 00 00    	jb     802120 <__umoddi3+0x140>
  802040:	39 0c 24             	cmp    %ecx,(%esp)
  802043:	0f 86 d7 00 00 00    	jbe    802120 <__umoddi3+0x140>
  802049:	8b 44 24 08          	mov    0x8(%esp),%eax
  80204d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802051:	83 c4 1c             	add    $0x1c,%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	85 ff                	test   %edi,%edi
  802062:	89 fd                	mov    %edi,%ebp
  802064:	75 0b                	jne    802071 <__umoddi3+0x91>
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f7                	div    %edi
  80206f:	89 c5                	mov    %eax,%ebp
  802071:	89 f0                	mov    %esi,%eax
  802073:	31 d2                	xor    %edx,%edx
  802075:	f7 f5                	div    %ebp
  802077:	89 c8                	mov    %ecx,%eax
  802079:	f7 f5                	div    %ebp
  80207b:	89 d0                	mov    %edx,%eax
  80207d:	eb 99                	jmp    802018 <__umoddi3+0x38>
  80207f:	90                   	nop
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	83 c4 1c             	add    $0x1c,%esp
  802087:	5b                   	pop    %ebx
  802088:	5e                   	pop    %esi
  802089:	5f                   	pop    %edi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    
  80208c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802090:	8b 34 24             	mov    (%esp),%esi
  802093:	bf 20 00 00 00       	mov    $0x20,%edi
  802098:	89 e9                	mov    %ebp,%ecx
  80209a:	29 ef                	sub    %ebp,%edi
  80209c:	d3 e0                	shl    %cl,%eax
  80209e:	89 f9                	mov    %edi,%ecx
  8020a0:	89 f2                	mov    %esi,%edx
  8020a2:	d3 ea                	shr    %cl,%edx
  8020a4:	89 e9                	mov    %ebp,%ecx
  8020a6:	09 c2                	or     %eax,%edx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 14 24             	mov    %edx,(%esp)
  8020ad:	89 f2                	mov    %esi,%edx
  8020af:	d3 e2                	shl    %cl,%edx
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	89 e9                	mov    %ebp,%ecx
  8020bf:	89 c6                	mov    %eax,%esi
  8020c1:	d3 e3                	shl    %cl,%ebx
  8020c3:	89 f9                	mov    %edi,%ecx
  8020c5:	89 d0                	mov    %edx,%eax
  8020c7:	d3 e8                	shr    %cl,%eax
  8020c9:	89 e9                	mov    %ebp,%ecx
  8020cb:	09 d8                	or     %ebx,%eax
  8020cd:	89 d3                	mov    %edx,%ebx
  8020cf:	89 f2                	mov    %esi,%edx
  8020d1:	f7 34 24             	divl   (%esp)
  8020d4:	89 d6                	mov    %edx,%esi
  8020d6:	d3 e3                	shl    %cl,%ebx
  8020d8:	f7 64 24 04          	mull   0x4(%esp)
  8020dc:	39 d6                	cmp    %edx,%esi
  8020de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e2:	89 d1                	mov    %edx,%ecx
  8020e4:	89 c3                	mov    %eax,%ebx
  8020e6:	72 08                	jb     8020f0 <__umoddi3+0x110>
  8020e8:	75 11                	jne    8020fb <__umoddi3+0x11b>
  8020ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020ee:	73 0b                	jae    8020fb <__umoddi3+0x11b>
  8020f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020f4:	1b 14 24             	sbb    (%esp),%edx
  8020f7:	89 d1                	mov    %edx,%ecx
  8020f9:	89 c3                	mov    %eax,%ebx
  8020fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020ff:	29 da                	sub    %ebx,%edx
  802101:	19 ce                	sbb    %ecx,%esi
  802103:	89 f9                	mov    %edi,%ecx
  802105:	89 f0                	mov    %esi,%eax
  802107:	d3 e0                	shl    %cl,%eax
  802109:	89 e9                	mov    %ebp,%ecx
  80210b:	d3 ea                	shr    %cl,%edx
  80210d:	89 e9                	mov    %ebp,%ecx
  80210f:	d3 ee                	shr    %cl,%esi
  802111:	09 d0                	or     %edx,%eax
  802113:	89 f2                	mov    %esi,%edx
  802115:	83 c4 1c             	add    $0x1c,%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5f                   	pop    %edi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    
  80211d:	8d 76 00             	lea    0x0(%esi),%esi
  802120:	29 f9                	sub    %edi,%ecx
  802122:	19 d6                	sbb    %edx,%esi
  802124:	89 74 24 04          	mov    %esi,0x4(%esp)
  802128:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80212c:	e9 18 ff ff ff       	jmp    802049 <__umoddi3+0x69>
