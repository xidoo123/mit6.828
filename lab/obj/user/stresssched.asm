
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
  800044:	e8 d2 0e 00 00       	call   800f1b <fork>
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
  80008f:	a1 08 40 80 00       	mov    0x804008,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 08 40 80 00       	mov    %eax,0x804008
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
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 40 26 80 00       	push   $0x802640
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 68 26 80 00       	push   $0x802668
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 7b 26 80 00       	push   $0x80267b
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
  80010a:	a3 0c 40 80 00       	mov    %eax,0x80400c

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
  800139:	e8 5f 11 00 00       	call   80129d <close_all>
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
  80016b:	68 a4 26 80 00       	push   $0x8026a4
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 97 26 80 00 	movl   $0x802697,(%esp)
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
  800289:	e8 22 21 00 00       	call   8023b0 <__udivdi3>
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
  8002cc:	e8 0f 22 00 00       	call   8024e0 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 c7 26 80 00 	movsbl 0x8026c7(%eax),%eax
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
  8003d0:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
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
  800494:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 df 26 80 00       	push   $0x8026df
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
  8004b8:	68 51 2b 80 00       	push   $0x802b51
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
  8004dc:	b8 d8 26 80 00       	mov    $0x8026d8,%eax
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
  800b57:	68 bf 29 80 00       	push   $0x8029bf
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 dc 29 80 00       	push   $0x8029dc
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
  800bd8:	68 bf 29 80 00       	push   $0x8029bf
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 dc 29 80 00       	push   $0x8029dc
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
  800c1a:	68 bf 29 80 00       	push   $0x8029bf
  800c1f:	6a 23                	push   $0x23
  800c21:	68 dc 29 80 00       	push   $0x8029dc
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
  800c5c:	68 bf 29 80 00       	push   $0x8029bf
  800c61:	6a 23                	push   $0x23
  800c63:	68 dc 29 80 00       	push   $0x8029dc
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
  800c9e:	68 bf 29 80 00       	push   $0x8029bf
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 dc 29 80 00       	push   $0x8029dc
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
  800ce0:	68 bf 29 80 00       	push   $0x8029bf
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 dc 29 80 00       	push   $0x8029dc
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
  800d22:	68 bf 29 80 00       	push   $0x8029bf
  800d27:	6a 23                	push   $0x23
  800d29:	68 dc 29 80 00       	push   $0x8029dc
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
  800d86:	68 bf 29 80 00       	push   $0x8029bf
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 dc 29 80 00       	push   $0x8029dc
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

00800d9f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	ba 00 00 00 00       	mov    $0x0,%edx
  800daa:	b8 0e 00 00 00       	mov    $0xe,%eax
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 d3                	mov    %edx,%ebx
  800db3:	89 d7                	mov    %edx,%edi
  800db5:	89 d6                	mov    %edx,%esi
  800db7:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcc:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	89 de                	mov    %ebx,%esi
  800ddb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 17                	jle    800df8 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 0f                	push   $0xf
  800de7:	68 bf 29 80 00       	push   $0x8029bf
  800dec:	6a 23                	push   $0x23
  800dee:	68 dc 29 80 00       	push   $0x8029dc
  800df3:	e8 55 f3 ff ff       	call   80014d <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 17                	jle    800e3a <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	6a 10                	push   $0x10
  800e29:	68 bf 29 80 00       	push   $0x8029bf
  800e2e:	6a 23                	push   $0x23
  800e30:	68 dc 29 80 00       	push   $0x8029dc
  800e35:	e8 13 f3 ff ff       	call   80014d <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e4a:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e4c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e50:	75 25                	jne    800e77 <pgfault+0x35>
  800e52:	89 d8                	mov    %ebx,%eax
  800e54:	c1 e8 0c             	shr    $0xc,%eax
  800e57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e5e:	f6 c4 08             	test   $0x8,%ah
  800e61:	75 14                	jne    800e77 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	68 ec 29 80 00       	push   $0x8029ec
  800e6b:	6a 1e                	push   $0x1e
  800e6d:	68 80 2a 80 00       	push   $0x802a80
  800e72:	e8 d6 f2 ff ff       	call   80014d <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e77:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e7d:	e8 ee fc ff ff       	call   800b70 <sys_getenvid>
  800e82:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e84:	83 ec 04             	sub    $0x4,%esp
  800e87:	6a 07                	push   $0x7
  800e89:	68 00 f0 7f 00       	push   $0x7ff000
  800e8e:	50                   	push   %eax
  800e8f:	e8 1a fd ff ff       	call   800bae <sys_page_alloc>
	if (r < 0)
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	79 12                	jns    800ead <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e9b:	50                   	push   %eax
  800e9c:	68 18 2a 80 00       	push   $0x802a18
  800ea1:	6a 33                	push   $0x33
  800ea3:	68 80 2a 80 00       	push   $0x802a80
  800ea8:	e8 a0 f2 ff ff       	call   80014d <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ead:	83 ec 04             	sub    $0x4,%esp
  800eb0:	68 00 10 00 00       	push   $0x1000
  800eb5:	53                   	push   %ebx
  800eb6:	68 00 f0 7f 00       	push   $0x7ff000
  800ebb:	e8 e5 fa ff ff       	call   8009a5 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ec0:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec7:	53                   	push   %ebx
  800ec8:	56                   	push   %esi
  800ec9:	68 00 f0 7f 00       	push   $0x7ff000
  800ece:	56                   	push   %esi
  800ecf:	e8 1d fd ff ff       	call   800bf1 <sys_page_map>
	if (r < 0)
  800ed4:	83 c4 20             	add    $0x20,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	79 12                	jns    800eed <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800edb:	50                   	push   %eax
  800edc:	68 3c 2a 80 00       	push   $0x802a3c
  800ee1:	6a 3b                	push   $0x3b
  800ee3:	68 80 2a 80 00       	push   $0x802a80
  800ee8:	e8 60 f2 ff ff       	call   80014d <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800eed:	83 ec 08             	sub    $0x8,%esp
  800ef0:	68 00 f0 7f 00       	push   $0x7ff000
  800ef5:	56                   	push   %esi
  800ef6:	e8 38 fd ff ff       	call   800c33 <sys_page_unmap>
	if (r < 0)
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	79 12                	jns    800f14 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f02:	50                   	push   %eax
  800f03:	68 60 2a 80 00       	push   $0x802a60
  800f08:	6a 40                	push   $0x40
  800f0a:	68 80 2a 80 00       	push   $0x802a80
  800f0f:	e8 39 f2 ff ff       	call   80014d <_panic>
}
  800f14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f24:	68 42 0e 80 00       	push   $0x800e42
  800f29:	e8 e8 12 00 00       	call   802216 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f2e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f33:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	0f 88 64 01 00 00    	js     8010a4 <fork+0x189>
  800f40:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f45:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	75 21                	jne    800f6f <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f4e:	e8 1d fc ff ff       	call   800b70 <sys_getenvid>
  800f53:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f58:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f5b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f60:	a3 0c 40 80 00       	mov    %eax,0x80400c
        return 0;
  800f65:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6a:	e9 3f 01 00 00       	jmp    8010ae <fork+0x193>
  800f6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f72:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	c1 e8 16             	shr    $0x16,%eax
  800f79:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f80:	a8 01                	test   $0x1,%al
  800f82:	0f 84 bd 00 00 00    	je     801045 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	c1 e8 0c             	shr    $0xc,%eax
  800f8d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f94:	f6 c2 01             	test   $0x1,%dl
  800f97:	0f 84 a8 00 00 00    	je     801045 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f9d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa4:	a8 04                	test   $0x4,%al
  800fa6:	0f 84 99 00 00 00    	je     801045 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800fac:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb3:	f6 c4 04             	test   $0x4,%ah
  800fb6:	74 17                	je     800fcf <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	68 07 0e 00 00       	push   $0xe07
  800fc0:	53                   	push   %ebx
  800fc1:	57                   	push   %edi
  800fc2:	53                   	push   %ebx
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 27 fc ff ff       	call   800bf1 <sys_page_map>
  800fca:	83 c4 20             	add    $0x20,%esp
  800fcd:	eb 76                	jmp    801045 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fcf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fd6:	a8 02                	test   $0x2,%al
  800fd8:	75 0c                	jne    800fe6 <fork+0xcb>
  800fda:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe1:	f6 c4 08             	test   $0x8,%ah
  800fe4:	74 3f                	je     801025 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	68 05 08 00 00       	push   $0x805
  800fee:	53                   	push   %ebx
  800fef:	57                   	push   %edi
  800ff0:	53                   	push   %ebx
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 f9 fb ff ff       	call   800bf1 <sys_page_map>
		if (r < 0)
  800ff8:	83 c4 20             	add    $0x20,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	0f 88 a5 00 00 00    	js     8010a8 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	68 05 08 00 00       	push   $0x805
  80100b:	53                   	push   %ebx
  80100c:	6a 00                	push   $0x0
  80100e:	53                   	push   %ebx
  80100f:	6a 00                	push   $0x0
  801011:	e8 db fb ff ff       	call   800bf1 <sys_page_map>
  801016:	83 c4 20             	add    $0x20,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801020:	0f 4f c1             	cmovg  %ecx,%eax
  801023:	eb 1c                	jmp    801041 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	6a 05                	push   $0x5
  80102a:	53                   	push   %ebx
  80102b:	57                   	push   %edi
  80102c:	53                   	push   %ebx
  80102d:	6a 00                	push   $0x0
  80102f:	e8 bd fb ff ff       	call   800bf1 <sys_page_map>
  801034:	83 c4 20             	add    $0x20,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103e:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801041:	85 c0                	test   %eax,%eax
  801043:	78 67                	js     8010ac <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801045:	83 c6 01             	add    $0x1,%esi
  801048:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80104e:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801054:	0f 85 1a ff ff ff    	jne    800f74 <fork+0x59>
  80105a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80105d:	83 ec 04             	sub    $0x4,%esp
  801060:	6a 07                	push   $0x7
  801062:	68 00 f0 bf ee       	push   $0xeebff000
  801067:	57                   	push   %edi
  801068:	e8 41 fb ff ff       	call   800bae <sys_page_alloc>
	if (r < 0)
  80106d:	83 c4 10             	add    $0x10,%esp
		return r;
  801070:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	78 38                	js     8010ae <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801076:	83 ec 08             	sub    $0x8,%esp
  801079:	68 5d 22 80 00       	push   $0x80225d
  80107e:	57                   	push   %edi
  80107f:	e8 75 fc ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801084:	83 c4 10             	add    $0x10,%esp
		return r;
  801087:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 21                	js     8010ae <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	6a 02                	push   $0x2
  801092:	57                   	push   %edi
  801093:	e8 dd fb ff ff       	call   800c75 <sys_env_set_status>
	if (r < 0)
  801098:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  80109b:	85 c0                	test   %eax,%eax
  80109d:	0f 48 f8             	cmovs  %eax,%edi
  8010a0:	89 fa                	mov    %edi,%edx
  8010a2:	eb 0a                	jmp    8010ae <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010a4:	89 c2                	mov    %eax,%edx
  8010a6:	eb 06                	jmp    8010ae <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010a8:	89 c2                	mov    %eax,%edx
  8010aa:	eb 02                	jmp    8010ae <fork+0x193>
  8010ac:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8010ae:	89 d0                	mov    %edx,%eax
  8010b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010be:	68 8b 2a 80 00       	push   $0x802a8b
  8010c3:	68 c9 00 00 00       	push   $0xc9
  8010c8:	68 80 2a 80 00       	push   $0x802a80
  8010cd:	e8 7b f0 ff ff       	call   80014d <_panic>

008010d2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010dd:	c1 e8 0c             	shr    $0xc,%eax
}
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ff:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801104:	89 c2                	mov    %eax,%edx
  801106:	c1 ea 16             	shr    $0x16,%edx
  801109:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801110:	f6 c2 01             	test   $0x1,%dl
  801113:	74 11                	je     801126 <fd_alloc+0x2d>
  801115:	89 c2                	mov    %eax,%edx
  801117:	c1 ea 0c             	shr    $0xc,%edx
  80111a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801121:	f6 c2 01             	test   $0x1,%dl
  801124:	75 09                	jne    80112f <fd_alloc+0x36>
			*fd_store = fd;
  801126:	89 01                	mov    %eax,(%ecx)
			return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
  80112d:	eb 17                	jmp    801146 <fd_alloc+0x4d>
  80112f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801134:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801139:	75 c9                	jne    801104 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80113b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801141:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114e:	83 f8 1f             	cmp    $0x1f,%eax
  801151:	77 36                	ja     801189 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801153:	c1 e0 0c             	shl    $0xc,%eax
  801156:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	c1 ea 16             	shr    $0x16,%edx
  801160:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801167:	f6 c2 01             	test   $0x1,%dl
  80116a:	74 24                	je     801190 <fd_lookup+0x48>
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	c1 ea 0c             	shr    $0xc,%edx
  801171:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801178:	f6 c2 01             	test   $0x1,%dl
  80117b:	74 1a                	je     801197 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80117d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801180:	89 02                	mov    %eax,(%edx)
	return 0;
  801182:	b8 00 00 00 00       	mov    $0x0,%eax
  801187:	eb 13                	jmp    80119c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801189:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118e:	eb 0c                	jmp    80119c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801190:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801195:	eb 05                	jmp    80119c <fd_lookup+0x54>
  801197:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a7:	ba 24 2b 80 00       	mov    $0x802b24,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ac:	eb 13                	jmp    8011c1 <dev_lookup+0x23>
  8011ae:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011b1:	39 08                	cmp    %ecx,(%eax)
  8011b3:	75 0c                	jne    8011c1 <dev_lookup+0x23>
			*dev = devtab[i];
  8011b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bf:	eb 2e                	jmp    8011ef <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011c1:	8b 02                	mov    (%edx),%eax
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	75 e7                	jne    8011ae <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011cc:	8b 40 48             	mov    0x48(%eax),%eax
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	51                   	push   %ecx
  8011d3:	50                   	push   %eax
  8011d4:	68 a4 2a 80 00       	push   $0x802aa4
  8011d9:	e8 48 f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  8011de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ef:	c9                   	leave  
  8011f0:	c3                   	ret    

008011f1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	56                   	push   %esi
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 10             	sub    $0x10,%esp
  8011f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801209:	c1 e8 0c             	shr    $0xc,%eax
  80120c:	50                   	push   %eax
  80120d:	e8 36 ff ff ff       	call   801148 <fd_lookup>
  801212:	83 c4 08             	add    $0x8,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 05                	js     80121e <fd_close+0x2d>
	    || fd != fd2)
  801219:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80121c:	74 0c                	je     80122a <fd_close+0x39>
		return (must_exist ? r : 0);
  80121e:	84 db                	test   %bl,%bl
  801220:	ba 00 00 00 00       	mov    $0x0,%edx
  801225:	0f 44 c2             	cmove  %edx,%eax
  801228:	eb 41                	jmp    80126b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	ff 36                	pushl  (%esi)
  801233:	e8 66 ff ff ff       	call   80119e <dev_lookup>
  801238:	89 c3                	mov    %eax,%ebx
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 1a                	js     80125b <fd_close+0x6a>
		if (dev->dev_close)
  801241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801244:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801247:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	74 0b                	je     80125b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801250:	83 ec 0c             	sub    $0xc,%esp
  801253:	56                   	push   %esi
  801254:	ff d0                	call   *%eax
  801256:	89 c3                	mov    %eax,%ebx
  801258:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80125b:	83 ec 08             	sub    $0x8,%esp
  80125e:	56                   	push   %esi
  80125f:	6a 00                	push   $0x0
  801261:	e8 cd f9 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	89 d8                	mov    %ebx,%eax
}
  80126b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126e:	5b                   	pop    %ebx
  80126f:	5e                   	pop    %esi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 c4 fe ff ff       	call   801148 <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 10                	js     80129b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	6a 01                	push   $0x1
  801290:	ff 75 f4             	pushl  -0xc(%ebp)
  801293:	e8 59 ff ff ff       	call   8011f1 <fd_close>
  801298:	83 c4 10             	add    $0x10,%esp
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <close_all>:

void
close_all(void)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	53                   	push   %ebx
  8012ad:	e8 c0 ff ff ff       	call   801272 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b2:	83 c3 01             	add    $0x1,%ebx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	83 fb 20             	cmp    $0x20,%ebx
  8012bb:	75 ec                	jne    8012a9 <close_all+0xc>
		close(i);
}
  8012bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	57                   	push   %edi
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 2c             	sub    $0x2c,%esp
  8012cb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	ff 75 08             	pushl  0x8(%ebp)
  8012d5:	e8 6e fe ff ff       	call   801148 <fd_lookup>
  8012da:	83 c4 08             	add    $0x8,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	0f 88 c1 00 00 00    	js     8013a6 <dup+0xe4>
		return r;
	close(newfdnum);
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	56                   	push   %esi
  8012e9:	e8 84 ff ff ff       	call   801272 <close>

	newfd = INDEX2FD(newfdnum);
  8012ee:	89 f3                	mov    %esi,%ebx
  8012f0:	c1 e3 0c             	shl    $0xc,%ebx
  8012f3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f9:	83 c4 04             	add    $0x4,%esp
  8012fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ff:	e8 de fd ff ff       	call   8010e2 <fd2data>
  801304:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801306:	89 1c 24             	mov    %ebx,(%esp)
  801309:	e8 d4 fd ff ff       	call   8010e2 <fd2data>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801314:	89 f8                	mov    %edi,%eax
  801316:	c1 e8 16             	shr    $0x16,%eax
  801319:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801320:	a8 01                	test   $0x1,%al
  801322:	74 37                	je     80135b <dup+0x99>
  801324:	89 f8                	mov    %edi,%eax
  801326:	c1 e8 0c             	shr    $0xc,%eax
  801329:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801330:	f6 c2 01             	test   $0x1,%dl
  801333:	74 26                	je     80135b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801335:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	25 07 0e 00 00       	and    $0xe07,%eax
  801344:	50                   	push   %eax
  801345:	ff 75 d4             	pushl  -0x2c(%ebp)
  801348:	6a 00                	push   $0x0
  80134a:	57                   	push   %edi
  80134b:	6a 00                	push   $0x0
  80134d:	e8 9f f8 ff ff       	call   800bf1 <sys_page_map>
  801352:	89 c7                	mov    %eax,%edi
  801354:	83 c4 20             	add    $0x20,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 2e                	js     801389 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80135b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80135e:	89 d0                	mov    %edx,%eax
  801360:	c1 e8 0c             	shr    $0xc,%eax
  801363:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	25 07 0e 00 00       	and    $0xe07,%eax
  801372:	50                   	push   %eax
  801373:	53                   	push   %ebx
  801374:	6a 00                	push   $0x0
  801376:	52                   	push   %edx
  801377:	6a 00                	push   $0x0
  801379:	e8 73 f8 ff ff       	call   800bf1 <sys_page_map>
  80137e:	89 c7                	mov    %eax,%edi
  801380:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801383:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801385:	85 ff                	test   %edi,%edi
  801387:	79 1d                	jns    8013a6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	53                   	push   %ebx
  80138d:	6a 00                	push   $0x0
  80138f:	e8 9f f8 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	ff 75 d4             	pushl  -0x2c(%ebp)
  80139a:	6a 00                	push   $0x0
  80139c:	e8 92 f8 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	89 f8                	mov    %edi,%eax
}
  8013a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a9:	5b                   	pop    %ebx
  8013aa:	5e                   	pop    %esi
  8013ab:	5f                   	pop    %edi
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 14             	sub    $0x14,%esp
  8013b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	53                   	push   %ebx
  8013bd:	e8 86 fd ff ff       	call   801148 <fd_lookup>
  8013c2:	83 c4 08             	add    $0x8,%esp
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 6d                	js     801438 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d5:	ff 30                	pushl  (%eax)
  8013d7:	e8 c2 fd ff ff       	call   80119e <dev_lookup>
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 4c                	js     80142f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e6:	8b 42 08             	mov    0x8(%edx),%eax
  8013e9:	83 e0 03             	and    $0x3,%eax
  8013ec:	83 f8 01             	cmp    $0x1,%eax
  8013ef:	75 21                	jne    801412 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013f6:	8b 40 48             	mov    0x48(%eax),%eax
  8013f9:	83 ec 04             	sub    $0x4,%esp
  8013fc:	53                   	push   %ebx
  8013fd:	50                   	push   %eax
  8013fe:	68 e8 2a 80 00       	push   $0x802ae8
  801403:	e8 1e ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801410:	eb 26                	jmp    801438 <read+0x8a>
	}
	if (!dev->dev_read)
  801412:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801415:	8b 40 08             	mov    0x8(%eax),%eax
  801418:	85 c0                	test   %eax,%eax
  80141a:	74 17                	je     801433 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80141c:	83 ec 04             	sub    $0x4,%esp
  80141f:	ff 75 10             	pushl  0x10(%ebp)
  801422:	ff 75 0c             	pushl  0xc(%ebp)
  801425:	52                   	push   %edx
  801426:	ff d0                	call   *%eax
  801428:	89 c2                	mov    %eax,%edx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	eb 09                	jmp    801438 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	89 c2                	mov    %eax,%edx
  801431:	eb 05                	jmp    801438 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801433:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801438:	89 d0                	mov    %edx,%eax
  80143a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	57                   	push   %edi
  801443:	56                   	push   %esi
  801444:	53                   	push   %ebx
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801453:	eb 21                	jmp    801476 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	89 f0                	mov    %esi,%eax
  80145a:	29 d8                	sub    %ebx,%eax
  80145c:	50                   	push   %eax
  80145d:	89 d8                	mov    %ebx,%eax
  80145f:	03 45 0c             	add    0xc(%ebp),%eax
  801462:	50                   	push   %eax
  801463:	57                   	push   %edi
  801464:	e8 45 ff ff ff       	call   8013ae <read>
		if (m < 0)
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 10                	js     801480 <readn+0x41>
			return m;
		if (m == 0)
  801470:	85 c0                	test   %eax,%eax
  801472:	74 0a                	je     80147e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801474:	01 c3                	add    %eax,%ebx
  801476:	39 f3                	cmp    %esi,%ebx
  801478:	72 db                	jb     801455 <readn+0x16>
  80147a:	89 d8                	mov    %ebx,%eax
  80147c:	eb 02                	jmp    801480 <readn+0x41>
  80147e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801480:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 14             	sub    $0x14,%esp
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801492:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	53                   	push   %ebx
  801497:	e8 ac fc ff ff       	call   801148 <fd_lookup>
  80149c:	83 c4 08             	add    $0x8,%esp
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 68                	js     80150d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	ff 30                	pushl  (%eax)
  8014b1:	e8 e8 fc ff ff       	call   80119e <dev_lookup>
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 47                	js     801504 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c4:	75 21                	jne    8014e7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c6:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014cb:	8b 40 48             	mov    0x48(%eax),%eax
  8014ce:	83 ec 04             	sub    $0x4,%esp
  8014d1:	53                   	push   %ebx
  8014d2:	50                   	push   %eax
  8014d3:	68 04 2b 80 00       	push   $0x802b04
  8014d8:	e8 49 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e5:	eb 26                	jmp    80150d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ed:	85 d2                	test   %edx,%edx
  8014ef:	74 17                	je     801508 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f1:	83 ec 04             	sub    $0x4,%esp
  8014f4:	ff 75 10             	pushl  0x10(%ebp)
  8014f7:	ff 75 0c             	pushl  0xc(%ebp)
  8014fa:	50                   	push   %eax
  8014fb:	ff d2                	call   *%edx
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	eb 09                	jmp    80150d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801504:	89 c2                	mov    %eax,%edx
  801506:	eb 05                	jmp    80150d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801508:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80150d:	89 d0                	mov    %edx,%eax
  80150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <seek>:

int
seek(int fdnum, off_t offset)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	ff 75 08             	pushl  0x8(%ebp)
  801521:	e8 22 fc ff ff       	call   801148 <fd_lookup>
  801526:	83 c4 08             	add    $0x8,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 0e                	js     80153b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801530:	8b 55 0c             	mov    0xc(%ebp),%edx
  801533:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801536:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 14             	sub    $0x14,%esp
  801544:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801547:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	53                   	push   %ebx
  80154c:	e8 f7 fb ff ff       	call   801148 <fd_lookup>
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	89 c2                	mov    %eax,%edx
  801556:	85 c0                	test   %eax,%eax
  801558:	78 65                	js     8015bf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801564:	ff 30                	pushl  (%eax)
  801566:	e8 33 fc ff ff       	call   80119e <dev_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 44                	js     8015b6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801572:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801575:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801579:	75 21                	jne    80159c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80157b:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801580:	8b 40 48             	mov    0x48(%eax),%eax
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	53                   	push   %ebx
  801587:	50                   	push   %eax
  801588:	68 c4 2a 80 00       	push   $0x802ac4
  80158d:	e8 94 ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159a:	eb 23                	jmp    8015bf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80159c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159f:	8b 52 18             	mov    0x18(%edx),%edx
  8015a2:	85 d2                	test   %edx,%edx
  8015a4:	74 14                	je     8015ba <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ac:	50                   	push   %eax
  8015ad:	ff d2                	call   *%edx
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	eb 09                	jmp    8015bf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	eb 05                	jmp    8015bf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015bf:	89 d0                	mov    %edx,%eax
  8015c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 14             	sub    $0x14,%esp
  8015cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	ff 75 08             	pushl  0x8(%ebp)
  8015d7:	e8 6c fb ff ff       	call   801148 <fd_lookup>
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 58                	js     80163d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e5:	83 ec 08             	sub    $0x8,%esp
  8015e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015eb:	50                   	push   %eax
  8015ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ef:	ff 30                	pushl  (%eax)
  8015f1:	e8 a8 fb ff ff       	call   80119e <dev_lookup>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 37                	js     801634 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801604:	74 32                	je     801638 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801606:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801609:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801610:	00 00 00 
	stat->st_isdir = 0;
  801613:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80161a:	00 00 00 
	stat->st_dev = dev;
  80161d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	53                   	push   %ebx
  801627:	ff 75 f0             	pushl  -0x10(%ebp)
  80162a:	ff 50 14             	call   *0x14(%eax)
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 09                	jmp    80163d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801634:	89 c2                	mov    %eax,%edx
  801636:	eb 05                	jmp    80163d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801638:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80163d:	89 d0                	mov    %edx,%eax
  80163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	56                   	push   %esi
  801648:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	6a 00                	push   $0x0
  80164e:	ff 75 08             	pushl  0x8(%ebp)
  801651:	e8 d6 01 00 00       	call   80182c <open>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 1b                	js     80167a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	ff 75 0c             	pushl  0xc(%ebp)
  801665:	50                   	push   %eax
  801666:	e8 5b ff ff ff       	call   8015c6 <fstat>
  80166b:	89 c6                	mov    %eax,%esi
	close(fd);
  80166d:	89 1c 24             	mov    %ebx,(%esp)
  801670:	e8 fd fb ff ff       	call   801272 <close>
	return r;
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	89 f0                	mov    %esi,%eax
}
  80167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	89 c6                	mov    %eax,%esi
  801688:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80168a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801691:	75 12                	jne    8016a5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	6a 01                	push   $0x1
  801698:	e8 9f 0c 00 00       	call   80233c <ipc_find_env>
  80169d:	a3 00 40 80 00       	mov    %eax,0x804000
  8016a2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a5:	6a 07                	push   $0x7
  8016a7:	68 00 50 80 00       	push   $0x805000
  8016ac:	56                   	push   %esi
  8016ad:	ff 35 00 40 80 00    	pushl  0x804000
  8016b3:	e8 30 0c 00 00       	call   8022e8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b8:	83 c4 0c             	add    $0xc,%esp
  8016bb:	6a 00                	push   $0x0
  8016bd:	53                   	push   %ebx
  8016be:	6a 00                	push   $0x0
  8016c0:	e8 bc 0b 00 00       	call   802281 <ipc_recv>
}
  8016c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c8:	5b                   	pop    %ebx
  8016c9:	5e                   	pop    %esi
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ef:	e8 8d ff ff ff       	call   801681 <fsipc>
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801702:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801707:	ba 00 00 00 00       	mov    $0x0,%edx
  80170c:	b8 06 00 00 00       	mov    $0x6,%eax
  801711:	e8 6b ff ff ff       	call   801681 <fsipc>
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	83 ec 04             	sub    $0x4,%esp
  80171f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 40 0c             	mov    0xc(%eax),%eax
  801728:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 05 00 00 00       	mov    $0x5,%eax
  801737:	e8 45 ff ff ff       	call   801681 <fsipc>
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 2c                	js     80176c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	68 00 50 80 00       	push   $0x805000
  801748:	53                   	push   %ebx
  801749:	e8 5d f0 ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174e:	a1 80 50 80 00       	mov    0x805080,%eax
  801753:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801759:	a1 84 50 80 00       	mov    0x805084,%eax
  80175e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 0c             	sub    $0xc,%esp
  801777:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80177a:	8b 55 08             	mov    0x8(%ebp),%edx
  80177d:	8b 52 0c             	mov    0xc(%edx),%edx
  801780:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801786:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80178b:	50                   	push   %eax
  80178c:	ff 75 0c             	pushl  0xc(%ebp)
  80178f:	68 08 50 80 00       	push   $0x805008
  801794:	e8 a4 f1 ff ff       	call   80093d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	b8 04 00 00 00       	mov    $0x4,%eax
  8017a3:	e8 d9 fe ff ff       	call   801681 <fsipc>

}
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
  8017af:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017bd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8017cd:	e8 af fe ff ff       	call   801681 <fsipc>
  8017d2:	89 c3                	mov    %eax,%ebx
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 4b                	js     801823 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017d8:	39 c6                	cmp    %eax,%esi
  8017da:	73 16                	jae    8017f2 <devfile_read+0x48>
  8017dc:	68 38 2b 80 00       	push   $0x802b38
  8017e1:	68 3f 2b 80 00       	push   $0x802b3f
  8017e6:	6a 7c                	push   $0x7c
  8017e8:	68 54 2b 80 00       	push   $0x802b54
  8017ed:	e8 5b e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  8017f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017f7:	7e 16                	jle    80180f <devfile_read+0x65>
  8017f9:	68 5f 2b 80 00       	push   $0x802b5f
  8017fe:	68 3f 2b 80 00       	push   $0x802b3f
  801803:	6a 7d                	push   $0x7d
  801805:	68 54 2b 80 00       	push   $0x802b54
  80180a:	e8 3e e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	50                   	push   %eax
  801813:	68 00 50 80 00       	push   $0x805000
  801818:	ff 75 0c             	pushl  0xc(%ebp)
  80181b:	e8 1d f1 ff ff       	call   80093d <memmove>
	return r;
  801820:	83 c4 10             	add    $0x10,%esp
}
  801823:	89 d8                	mov    %ebx,%eax
  801825:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801828:	5b                   	pop    %ebx
  801829:	5e                   	pop    %esi
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	53                   	push   %ebx
  801830:	83 ec 20             	sub    $0x20,%esp
  801833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801836:	53                   	push   %ebx
  801837:	e8 36 ef ff ff       	call   800772 <strlen>
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801844:	7f 67                	jg     8018ad <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801846:	83 ec 0c             	sub    $0xc,%esp
  801849:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184c:	50                   	push   %eax
  80184d:	e8 a7 f8 ff ff       	call   8010f9 <fd_alloc>
  801852:	83 c4 10             	add    $0x10,%esp
		return r;
  801855:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801857:	85 c0                	test   %eax,%eax
  801859:	78 57                	js     8018b2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	53                   	push   %ebx
  80185f:	68 00 50 80 00       	push   $0x805000
  801864:	e8 42 ef ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801871:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801874:	b8 01 00 00 00       	mov    $0x1,%eax
  801879:	e8 03 fe ff ff       	call   801681 <fsipc>
  80187e:	89 c3                	mov    %eax,%ebx
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	85 c0                	test   %eax,%eax
  801885:	79 14                	jns    80189b <open+0x6f>
		fd_close(fd, 0);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	6a 00                	push   $0x0
  80188c:	ff 75 f4             	pushl  -0xc(%ebp)
  80188f:	e8 5d f9 ff ff       	call   8011f1 <fd_close>
		return r;
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	89 da                	mov    %ebx,%edx
  801899:	eb 17                	jmp    8018b2 <open+0x86>
	}

	return fd2num(fd);
  80189b:	83 ec 0c             	sub    $0xc,%esp
  80189e:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a1:	e8 2c f8 ff ff       	call   8010d2 <fd2num>
  8018a6:	89 c2                	mov    %eax,%edx
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	eb 05                	jmp    8018b2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ad:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018b2:	89 d0                	mov    %edx,%eax
  8018b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8018c9:	e8 b3 fd ff ff       	call   801681 <fsipc>
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018d6:	68 6b 2b 80 00       	push   $0x802b6b
  8018db:	ff 75 0c             	pushl  0xc(%ebp)
  8018de:	e8 c8 ee ff ff       	call   8007ab <strcpy>
	return 0;
}
  8018e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 10             	sub    $0x10,%esp
  8018f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018f4:	53                   	push   %ebx
  8018f5:	e8 7b 0a 00 00       	call   802375 <pageref>
  8018fa:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801902:	83 f8 01             	cmp    $0x1,%eax
  801905:	75 10                	jne    801917 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801907:	83 ec 0c             	sub    $0xc,%esp
  80190a:	ff 73 0c             	pushl  0xc(%ebx)
  80190d:	e8 c0 02 00 00       	call   801bd2 <nsipc_close>
  801912:	89 c2                	mov    %eax,%edx
  801914:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801917:	89 d0                	mov    %edx,%eax
  801919:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801924:	6a 00                	push   $0x0
  801926:	ff 75 10             	pushl  0x10(%ebp)
  801929:	ff 75 0c             	pushl  0xc(%ebp)
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	ff 70 0c             	pushl  0xc(%eax)
  801932:	e8 78 03 00 00       	call   801caf <nsipc_send>
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80193f:	6a 00                	push   $0x0
  801941:	ff 75 10             	pushl  0x10(%ebp)
  801944:	ff 75 0c             	pushl  0xc(%ebp)
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
  80194a:	ff 70 0c             	pushl  0xc(%eax)
  80194d:	e8 f1 02 00 00       	call   801c43 <nsipc_recv>
}
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80195a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80195d:	52                   	push   %edx
  80195e:	50                   	push   %eax
  80195f:	e8 e4 f7 ff ff       	call   801148 <fd_lookup>
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	78 17                	js     801982 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80196b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801974:	39 08                	cmp    %ecx,(%eax)
  801976:	75 05                	jne    80197d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801978:	8b 40 0c             	mov    0xc(%eax),%eax
  80197b:	eb 05                	jmp    801982 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80197d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	83 ec 1c             	sub    $0x1c,%esp
  80198c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80198e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801991:	50                   	push   %eax
  801992:	e8 62 f7 ff ff       	call   8010f9 <fd_alloc>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 1b                	js     8019bb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019a0:	83 ec 04             	sub    $0x4,%esp
  8019a3:	68 07 04 00 00       	push   $0x407
  8019a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ab:	6a 00                	push   $0x0
  8019ad:	e8 fc f1 ff ff       	call   800bae <sys_page_alloc>
  8019b2:	89 c3                	mov    %eax,%ebx
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	79 10                	jns    8019cb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	56                   	push   %esi
  8019bf:	e8 0e 02 00 00       	call   801bd2 <nsipc_close>
		return r;
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	89 d8                	mov    %ebx,%eax
  8019c9:	eb 24                	jmp    8019ef <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019cb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019e0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019e3:	83 ec 0c             	sub    $0xc,%esp
  8019e6:	50                   	push   %eax
  8019e7:	e8 e6 f6 ff ff       	call   8010d2 <fd2num>
  8019ec:	83 c4 10             	add    $0x10,%esp
}
  8019ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f2:	5b                   	pop    %ebx
  8019f3:	5e                   	pop    %esi
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ff:	e8 50 ff ff ff       	call   801954 <fd2sockid>
		return r;
  801a04:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 1f                	js     801a29 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a0a:	83 ec 04             	sub    $0x4,%esp
  801a0d:	ff 75 10             	pushl  0x10(%ebp)
  801a10:	ff 75 0c             	pushl  0xc(%ebp)
  801a13:	50                   	push   %eax
  801a14:	e8 12 01 00 00       	call   801b2b <nsipc_accept>
  801a19:	83 c4 10             	add    $0x10,%esp
		return r;
  801a1c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 07                	js     801a29 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a22:	e8 5d ff ff ff       	call   801984 <alloc_sockfd>
  801a27:	89 c1                	mov    %eax,%ecx
}
  801a29:	89 c8                	mov    %ecx,%eax
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a33:	8b 45 08             	mov    0x8(%ebp),%eax
  801a36:	e8 19 ff ff ff       	call   801954 <fd2sockid>
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	78 12                	js     801a51 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	ff 75 10             	pushl  0x10(%ebp)
  801a45:	ff 75 0c             	pushl  0xc(%ebp)
  801a48:	50                   	push   %eax
  801a49:	e8 2d 01 00 00       	call   801b7b <nsipc_bind>
  801a4e:	83 c4 10             	add    $0x10,%esp
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <shutdown>:

int
shutdown(int s, int how)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	e8 f3 fe ff ff       	call   801954 <fd2sockid>
  801a61:	85 c0                	test   %eax,%eax
  801a63:	78 0f                	js     801a74 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a65:	83 ec 08             	sub    $0x8,%esp
  801a68:	ff 75 0c             	pushl  0xc(%ebp)
  801a6b:	50                   	push   %eax
  801a6c:	e8 3f 01 00 00       	call   801bb0 <nsipc_shutdown>
  801a71:	83 c4 10             	add    $0x10,%esp
}
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7f:	e8 d0 fe ff ff       	call   801954 <fd2sockid>
  801a84:	85 c0                	test   %eax,%eax
  801a86:	78 12                	js     801a9a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a88:	83 ec 04             	sub    $0x4,%esp
  801a8b:	ff 75 10             	pushl  0x10(%ebp)
  801a8e:	ff 75 0c             	pushl  0xc(%ebp)
  801a91:	50                   	push   %eax
  801a92:	e8 55 01 00 00       	call   801bec <nsipc_connect>
  801a97:	83 c4 10             	add    $0x10,%esp
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <listen>:

int
listen(int s, int backlog)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa5:	e8 aa fe ff ff       	call   801954 <fd2sockid>
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	78 0f                	js     801abd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	ff 75 0c             	pushl  0xc(%ebp)
  801ab4:	50                   	push   %eax
  801ab5:	e8 67 01 00 00       	call   801c21 <nsipc_listen>
  801aba:	83 c4 10             	add    $0x10,%esp
}
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ac5:	ff 75 10             	pushl  0x10(%ebp)
  801ac8:	ff 75 0c             	pushl  0xc(%ebp)
  801acb:	ff 75 08             	pushl  0x8(%ebp)
  801ace:	e8 3a 02 00 00       	call   801d0d <nsipc_socket>
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 05                	js     801adf <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ada:	e8 a5 fe ff ff       	call   801984 <alloc_sockfd>
}
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 04             	sub    $0x4,%esp
  801ae8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801aea:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801af1:	75 12                	jne    801b05 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	6a 02                	push   $0x2
  801af8:	e8 3f 08 00 00       	call   80233c <ipc_find_env>
  801afd:	a3 04 40 80 00       	mov    %eax,0x804004
  801b02:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b05:	6a 07                	push   $0x7
  801b07:	68 00 60 80 00       	push   $0x806000
  801b0c:	53                   	push   %ebx
  801b0d:	ff 35 04 40 80 00    	pushl  0x804004
  801b13:	e8 d0 07 00 00       	call   8022e8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b18:	83 c4 0c             	add    $0xc,%esp
  801b1b:	6a 00                	push   $0x0
  801b1d:	6a 00                	push   $0x0
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 5b 07 00 00       	call   802281 <ipc_recv>
}
  801b26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
  801b36:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b3b:	8b 06                	mov    (%esi),%eax
  801b3d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b42:	b8 01 00 00 00       	mov    $0x1,%eax
  801b47:	e8 95 ff ff ff       	call   801ae1 <nsipc>
  801b4c:	89 c3                	mov    %eax,%ebx
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 20                	js     801b72 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b52:	83 ec 04             	sub    $0x4,%esp
  801b55:	ff 35 10 60 80 00    	pushl  0x806010
  801b5b:	68 00 60 80 00       	push   $0x806000
  801b60:	ff 75 0c             	pushl  0xc(%ebp)
  801b63:	e8 d5 ed ff ff       	call   80093d <memmove>
		*addrlen = ret->ret_addrlen;
  801b68:	a1 10 60 80 00       	mov    0x806010,%eax
  801b6d:	89 06                	mov    %eax,(%esi)
  801b6f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b72:	89 d8                	mov    %ebx,%eax
  801b74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5e                   	pop    %esi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	53                   	push   %ebx
  801b7f:	83 ec 08             	sub    $0x8,%esp
  801b82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b8d:	53                   	push   %ebx
  801b8e:	ff 75 0c             	pushl  0xc(%ebp)
  801b91:	68 04 60 80 00       	push   $0x806004
  801b96:	e8 a2 ed ff ff       	call   80093d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b9b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ba1:	b8 02 00 00 00       	mov    $0x2,%eax
  801ba6:	e8 36 ff ff ff       	call   801ae1 <nsipc>
}
  801bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bc6:	b8 03 00 00 00       	mov    $0x3,%eax
  801bcb:	e8 11 ff ff ff       	call   801ae1 <nsipc>
}
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <nsipc_close>:

int
nsipc_close(int s)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801be0:	b8 04 00 00 00       	mov    $0x4,%eax
  801be5:	e8 f7 fe ff ff       	call   801ae1 <nsipc>
}
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 08             	sub    $0x8,%esp
  801bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bfe:	53                   	push   %ebx
  801bff:	ff 75 0c             	pushl  0xc(%ebp)
  801c02:	68 04 60 80 00       	push   $0x806004
  801c07:	e8 31 ed ff ff       	call   80093d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c0c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c12:	b8 05 00 00 00       	mov    $0x5,%eax
  801c17:	e8 c5 fe ff ff       	call   801ae1 <nsipc>
}
  801c1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c27:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c32:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c37:	b8 06 00 00 00       	mov    $0x6,%eax
  801c3c:	e8 a0 fe ff ff       	call   801ae1 <nsipc>
}
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c53:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c59:	8b 45 14             	mov    0x14(%ebp),%eax
  801c5c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c61:	b8 07 00 00 00       	mov    $0x7,%eax
  801c66:	e8 76 fe ff ff       	call   801ae1 <nsipc>
  801c6b:	89 c3                	mov    %eax,%ebx
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 35                	js     801ca6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c71:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c76:	7f 04                	jg     801c7c <nsipc_recv+0x39>
  801c78:	39 c6                	cmp    %eax,%esi
  801c7a:	7d 16                	jge    801c92 <nsipc_recv+0x4f>
  801c7c:	68 77 2b 80 00       	push   $0x802b77
  801c81:	68 3f 2b 80 00       	push   $0x802b3f
  801c86:	6a 62                	push   $0x62
  801c88:	68 8c 2b 80 00       	push   $0x802b8c
  801c8d:	e8 bb e4 ff ff       	call   80014d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c92:	83 ec 04             	sub    $0x4,%esp
  801c95:	50                   	push   %eax
  801c96:	68 00 60 80 00       	push   $0x806000
  801c9b:	ff 75 0c             	pushl  0xc(%ebp)
  801c9e:	e8 9a ec ff ff       	call   80093d <memmove>
  801ca3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5e                   	pop    %esi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	53                   	push   %ebx
  801cb3:	83 ec 04             	sub    $0x4,%esp
  801cb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbc:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801cc1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cc7:	7e 16                	jle    801cdf <nsipc_send+0x30>
  801cc9:	68 98 2b 80 00       	push   $0x802b98
  801cce:	68 3f 2b 80 00       	push   $0x802b3f
  801cd3:	6a 6d                	push   $0x6d
  801cd5:	68 8c 2b 80 00       	push   $0x802b8c
  801cda:	e8 6e e4 ff ff       	call   80014d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cdf:	83 ec 04             	sub    $0x4,%esp
  801ce2:	53                   	push   %ebx
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	68 0c 60 80 00       	push   $0x80600c
  801ceb:	e8 4d ec ff ff       	call   80093d <memmove>
	nsipcbuf.send.req_size = size;
  801cf0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cf6:	8b 45 14             	mov    0x14(%ebp),%eax
  801cf9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cfe:	b8 08 00 00 00       	mov    $0x8,%eax
  801d03:	e8 d9 fd ff ff       	call   801ae1 <nsipc>
}
  801d08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0b:	c9                   	leave  
  801d0c:	c3                   	ret    

00801d0d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d13:	8b 45 08             	mov    0x8(%ebp),%eax
  801d16:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d23:	8b 45 10             	mov    0x10(%ebp),%eax
  801d26:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d2b:	b8 09 00 00 00       	mov    $0x9,%eax
  801d30:	e8 ac fd ff ff       	call   801ae1 <nsipc>
}
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	56                   	push   %esi
  801d3b:	53                   	push   %ebx
  801d3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d3f:	83 ec 0c             	sub    $0xc,%esp
  801d42:	ff 75 08             	pushl  0x8(%ebp)
  801d45:	e8 98 f3 ff ff       	call   8010e2 <fd2data>
  801d4a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d4c:	83 c4 08             	add    $0x8,%esp
  801d4f:	68 a4 2b 80 00       	push   $0x802ba4
  801d54:	53                   	push   %ebx
  801d55:	e8 51 ea ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d5a:	8b 46 04             	mov    0x4(%esi),%eax
  801d5d:	2b 06                	sub    (%esi),%eax
  801d5f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d65:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d6c:	00 00 00 
	stat->st_dev = &devpipe;
  801d6f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d76:	30 80 00 
	return 0;
}
  801d79:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d81:	5b                   	pop    %ebx
  801d82:	5e                   	pop    %esi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	53                   	push   %ebx
  801d89:	83 ec 0c             	sub    $0xc,%esp
  801d8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d8f:	53                   	push   %ebx
  801d90:	6a 00                	push   $0x0
  801d92:	e8 9c ee ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d97:	89 1c 24             	mov    %ebx,(%esp)
  801d9a:	e8 43 f3 ff ff       	call   8010e2 <fd2data>
  801d9f:	83 c4 08             	add    $0x8,%esp
  801da2:	50                   	push   %eax
  801da3:	6a 00                	push   $0x0
  801da5:	e8 89 ee ff ff       	call   800c33 <sys_page_unmap>
}
  801daa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	57                   	push   %edi
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	83 ec 1c             	sub    $0x1c,%esp
  801db8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dbb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801dbd:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801dc2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dc5:	83 ec 0c             	sub    $0xc,%esp
  801dc8:	ff 75 e0             	pushl  -0x20(%ebp)
  801dcb:	e8 a5 05 00 00       	call   802375 <pageref>
  801dd0:	89 c3                	mov    %eax,%ebx
  801dd2:	89 3c 24             	mov    %edi,(%esp)
  801dd5:	e8 9b 05 00 00       	call   802375 <pageref>
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	39 c3                	cmp    %eax,%ebx
  801ddf:	0f 94 c1             	sete   %cl
  801de2:	0f b6 c9             	movzbl %cl,%ecx
  801de5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801de8:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801dee:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801df1:	39 ce                	cmp    %ecx,%esi
  801df3:	74 1b                	je     801e10 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801df5:	39 c3                	cmp    %eax,%ebx
  801df7:	75 c4                	jne    801dbd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801df9:	8b 42 58             	mov    0x58(%edx),%eax
  801dfc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dff:	50                   	push   %eax
  801e00:	56                   	push   %esi
  801e01:	68 ab 2b 80 00       	push   $0x802bab
  801e06:	e8 1b e4 ff ff       	call   800226 <cprintf>
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	eb ad                	jmp    801dbd <_pipeisclosed+0xe>
	}
}
  801e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e16:	5b                   	pop    %ebx
  801e17:	5e                   	pop    %esi
  801e18:	5f                   	pop    %edi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    

00801e1b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	57                   	push   %edi
  801e1f:	56                   	push   %esi
  801e20:	53                   	push   %ebx
  801e21:	83 ec 28             	sub    $0x28,%esp
  801e24:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e27:	56                   	push   %esi
  801e28:	e8 b5 f2 ff ff       	call   8010e2 <fd2data>
  801e2d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e2f:	83 c4 10             	add    $0x10,%esp
  801e32:	bf 00 00 00 00       	mov    $0x0,%edi
  801e37:	eb 4b                	jmp    801e84 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e39:	89 da                	mov    %ebx,%edx
  801e3b:	89 f0                	mov    %esi,%eax
  801e3d:	e8 6d ff ff ff       	call   801daf <_pipeisclosed>
  801e42:	85 c0                	test   %eax,%eax
  801e44:	75 48                	jne    801e8e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e46:	e8 44 ed ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e4b:	8b 43 04             	mov    0x4(%ebx),%eax
  801e4e:	8b 0b                	mov    (%ebx),%ecx
  801e50:	8d 51 20             	lea    0x20(%ecx),%edx
  801e53:	39 d0                	cmp    %edx,%eax
  801e55:	73 e2                	jae    801e39 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e5a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e5e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e61:	89 c2                	mov    %eax,%edx
  801e63:	c1 fa 1f             	sar    $0x1f,%edx
  801e66:	89 d1                	mov    %edx,%ecx
  801e68:	c1 e9 1b             	shr    $0x1b,%ecx
  801e6b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e6e:	83 e2 1f             	and    $0x1f,%edx
  801e71:	29 ca                	sub    %ecx,%edx
  801e73:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e77:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e7b:	83 c0 01             	add    $0x1,%eax
  801e7e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e81:	83 c7 01             	add    $0x1,%edi
  801e84:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e87:	75 c2                	jne    801e4b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e89:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8c:	eb 05                	jmp    801e93 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e96:	5b                   	pop    %ebx
  801e97:	5e                   	pop    %esi
  801e98:	5f                   	pop    %edi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	57                   	push   %edi
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	83 ec 18             	sub    $0x18,%esp
  801ea4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ea7:	57                   	push   %edi
  801ea8:	e8 35 f2 ff ff       	call   8010e2 <fd2data>
  801ead:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eb7:	eb 3d                	jmp    801ef6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801eb9:	85 db                	test   %ebx,%ebx
  801ebb:	74 04                	je     801ec1 <devpipe_read+0x26>
				return i;
  801ebd:	89 d8                	mov    %ebx,%eax
  801ebf:	eb 44                	jmp    801f05 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ec1:	89 f2                	mov    %esi,%edx
  801ec3:	89 f8                	mov    %edi,%eax
  801ec5:	e8 e5 fe ff ff       	call   801daf <_pipeisclosed>
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	75 32                	jne    801f00 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ece:	e8 bc ec ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ed3:	8b 06                	mov    (%esi),%eax
  801ed5:	3b 46 04             	cmp    0x4(%esi),%eax
  801ed8:	74 df                	je     801eb9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eda:	99                   	cltd   
  801edb:	c1 ea 1b             	shr    $0x1b,%edx
  801ede:	01 d0                	add    %edx,%eax
  801ee0:	83 e0 1f             	and    $0x1f,%eax
  801ee3:	29 d0                	sub    %edx,%eax
  801ee5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801eea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eed:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ef0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ef3:	83 c3 01             	add    $0x1,%ebx
  801ef6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ef9:	75 d8                	jne    801ed3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801efb:	8b 45 10             	mov    0x10(%ebp),%eax
  801efe:	eb 05                	jmp    801f05 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f00:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5f                   	pop    %edi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    

00801f0d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	56                   	push   %esi
  801f11:	53                   	push   %ebx
  801f12:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f18:	50                   	push   %eax
  801f19:	e8 db f1 ff ff       	call   8010f9 <fd_alloc>
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	89 c2                	mov    %eax,%edx
  801f23:	85 c0                	test   %eax,%eax
  801f25:	0f 88 2c 01 00 00    	js     802057 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f2b:	83 ec 04             	sub    $0x4,%esp
  801f2e:	68 07 04 00 00       	push   $0x407
  801f33:	ff 75 f4             	pushl  -0xc(%ebp)
  801f36:	6a 00                	push   $0x0
  801f38:	e8 71 ec ff ff       	call   800bae <sys_page_alloc>
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	89 c2                	mov    %eax,%edx
  801f42:	85 c0                	test   %eax,%eax
  801f44:	0f 88 0d 01 00 00    	js     802057 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f4a:	83 ec 0c             	sub    $0xc,%esp
  801f4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f50:	50                   	push   %eax
  801f51:	e8 a3 f1 ff ff       	call   8010f9 <fd_alloc>
  801f56:	89 c3                	mov    %eax,%ebx
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	0f 88 e2 00 00 00    	js     802045 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f63:	83 ec 04             	sub    $0x4,%esp
  801f66:	68 07 04 00 00       	push   $0x407
  801f6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6e:	6a 00                	push   $0x0
  801f70:	e8 39 ec ff ff       	call   800bae <sys_page_alloc>
  801f75:	89 c3                	mov    %eax,%ebx
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	0f 88 c3 00 00 00    	js     802045 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f82:	83 ec 0c             	sub    $0xc,%esp
  801f85:	ff 75 f4             	pushl  -0xc(%ebp)
  801f88:	e8 55 f1 ff ff       	call   8010e2 <fd2data>
  801f8d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f8f:	83 c4 0c             	add    $0xc,%esp
  801f92:	68 07 04 00 00       	push   $0x407
  801f97:	50                   	push   %eax
  801f98:	6a 00                	push   $0x0
  801f9a:	e8 0f ec ff ff       	call   800bae <sys_page_alloc>
  801f9f:	89 c3                	mov    %eax,%ebx
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	0f 88 89 00 00 00    	js     802035 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fac:	83 ec 0c             	sub    $0xc,%esp
  801faf:	ff 75 f0             	pushl  -0x10(%ebp)
  801fb2:	e8 2b f1 ff ff       	call   8010e2 <fd2data>
  801fb7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fbe:	50                   	push   %eax
  801fbf:	6a 00                	push   $0x0
  801fc1:	56                   	push   %esi
  801fc2:	6a 00                	push   $0x0
  801fc4:	e8 28 ec ff ff       	call   800bf1 <sys_page_map>
  801fc9:	89 c3                	mov    %eax,%ebx
  801fcb:	83 c4 20             	add    $0x20,%esp
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	78 55                	js     802027 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fd2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fe7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ffc:	83 ec 0c             	sub    $0xc,%esp
  801fff:	ff 75 f4             	pushl  -0xc(%ebp)
  802002:	e8 cb f0 ff ff       	call   8010d2 <fd2num>
  802007:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80200a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80200c:	83 c4 04             	add    $0x4,%esp
  80200f:	ff 75 f0             	pushl  -0x10(%ebp)
  802012:	e8 bb f0 ff ff       	call   8010d2 <fd2num>
  802017:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80201a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	ba 00 00 00 00       	mov    $0x0,%edx
  802025:	eb 30                	jmp    802057 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802027:	83 ec 08             	sub    $0x8,%esp
  80202a:	56                   	push   %esi
  80202b:	6a 00                	push   $0x0
  80202d:	e8 01 ec ff ff       	call   800c33 <sys_page_unmap>
  802032:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802035:	83 ec 08             	sub    $0x8,%esp
  802038:	ff 75 f0             	pushl  -0x10(%ebp)
  80203b:	6a 00                	push   $0x0
  80203d:	e8 f1 eb ff ff       	call   800c33 <sys_page_unmap>
  802042:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802045:	83 ec 08             	sub    $0x8,%esp
  802048:	ff 75 f4             	pushl  -0xc(%ebp)
  80204b:	6a 00                	push   $0x0
  80204d:	e8 e1 eb ff ff       	call   800c33 <sys_page_unmap>
  802052:	83 c4 10             	add    $0x10,%esp
  802055:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802057:	89 d0                	mov    %edx,%eax
  802059:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80205c:	5b                   	pop    %ebx
  80205d:	5e                   	pop    %esi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    

00802060 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802066:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802069:	50                   	push   %eax
  80206a:	ff 75 08             	pushl  0x8(%ebp)
  80206d:	e8 d6 f0 ff ff       	call   801148 <fd_lookup>
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	85 c0                	test   %eax,%eax
  802077:	78 18                	js     802091 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802079:	83 ec 0c             	sub    $0xc,%esp
  80207c:	ff 75 f4             	pushl  -0xc(%ebp)
  80207f:	e8 5e f0 ff ff       	call   8010e2 <fd2data>
	return _pipeisclosed(fd, p);
  802084:	89 c2                	mov    %eax,%edx
  802086:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802089:	e8 21 fd ff ff       	call   801daf <_pipeisclosed>
  80208e:	83 c4 10             	add    $0x10,%esp
}
  802091:	c9                   	leave  
  802092:	c3                   	ret    

00802093 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802096:	b8 00 00 00 00       	mov    $0x0,%eax
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    

0080209d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020a3:	68 c3 2b 80 00       	push   $0x802bc3
  8020a8:	ff 75 0c             	pushl  0xc(%ebp)
  8020ab:	e8 fb e6 ff ff       	call   8007ab <strcpy>
	return 0;
}
  8020b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    

008020b7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	57                   	push   %edi
  8020bb:	56                   	push   %esi
  8020bc:	53                   	push   %ebx
  8020bd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020c3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020c8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020ce:	eb 2d                	jmp    8020fd <devcons_write+0x46>
		m = n - tot;
  8020d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020d3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020d5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020d8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020dd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020e0:	83 ec 04             	sub    $0x4,%esp
  8020e3:	53                   	push   %ebx
  8020e4:	03 45 0c             	add    0xc(%ebp),%eax
  8020e7:	50                   	push   %eax
  8020e8:	57                   	push   %edi
  8020e9:	e8 4f e8 ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  8020ee:	83 c4 08             	add    $0x8,%esp
  8020f1:	53                   	push   %ebx
  8020f2:	57                   	push   %edi
  8020f3:	e8 fa e9 ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020f8:	01 de                	add    %ebx,%esi
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	89 f0                	mov    %esi,%eax
  8020ff:	3b 75 10             	cmp    0x10(%ebp),%esi
  802102:	72 cc                	jb     8020d0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    

0080210c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 08             	sub    $0x8,%esp
  802112:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802117:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80211b:	74 2a                	je     802147 <devcons_read+0x3b>
  80211d:	eb 05                	jmp    802124 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80211f:	e8 6b ea ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802124:	e8 e7 e9 ff ff       	call   800b10 <sys_cgetc>
  802129:	85 c0                	test   %eax,%eax
  80212b:	74 f2                	je     80211f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 16                	js     802147 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802131:	83 f8 04             	cmp    $0x4,%eax
  802134:	74 0c                	je     802142 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802136:	8b 55 0c             	mov    0xc(%ebp),%edx
  802139:	88 02                	mov    %al,(%edx)
	return 1;
  80213b:	b8 01 00 00 00       	mov    $0x1,%eax
  802140:	eb 05                	jmp    802147 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802142:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802147:	c9                   	leave  
  802148:	c3                   	ret    

00802149 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80214f:	8b 45 08             	mov    0x8(%ebp),%eax
  802152:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802155:	6a 01                	push   $0x1
  802157:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80215a:	50                   	push   %eax
  80215b:	e8 92 e9 ff ff       	call   800af2 <sys_cputs>
}
  802160:	83 c4 10             	add    $0x10,%esp
  802163:	c9                   	leave  
  802164:	c3                   	ret    

00802165 <getchar>:

int
getchar(void)
{
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80216b:	6a 01                	push   $0x1
  80216d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802170:	50                   	push   %eax
  802171:	6a 00                	push   $0x0
  802173:	e8 36 f2 ff ff       	call   8013ae <read>
	if (r < 0)
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	85 c0                	test   %eax,%eax
  80217d:	78 0f                	js     80218e <getchar+0x29>
		return r;
	if (r < 1)
  80217f:	85 c0                	test   %eax,%eax
  802181:	7e 06                	jle    802189 <getchar+0x24>
		return -E_EOF;
	return c;
  802183:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802187:	eb 05                	jmp    80218e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802189:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80218e:	c9                   	leave  
  80218f:	c3                   	ret    

00802190 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802196:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802199:	50                   	push   %eax
  80219a:	ff 75 08             	pushl  0x8(%ebp)
  80219d:	e8 a6 ef ff ff       	call   801148 <fd_lookup>
  8021a2:	83 c4 10             	add    $0x10,%esp
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	78 11                	js     8021ba <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ac:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021b2:	39 10                	cmp    %edx,(%eax)
  8021b4:	0f 94 c0             	sete   %al
  8021b7:	0f b6 c0             	movzbl %al,%eax
}
  8021ba:	c9                   	leave  
  8021bb:	c3                   	ret    

008021bc <opencons>:

int
opencons(void)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c5:	50                   	push   %eax
  8021c6:	e8 2e ef ff ff       	call   8010f9 <fd_alloc>
  8021cb:	83 c4 10             	add    $0x10,%esp
		return r;
  8021ce:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	78 3e                	js     802212 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d4:	83 ec 04             	sub    $0x4,%esp
  8021d7:	68 07 04 00 00       	push   $0x407
  8021dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8021df:	6a 00                	push   $0x0
  8021e1:	e8 c8 e9 ff ff       	call   800bae <sys_page_alloc>
  8021e6:	83 c4 10             	add    $0x10,%esp
		return r;
  8021e9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021eb:	85 c0                	test   %eax,%eax
  8021ed:	78 23                	js     802212 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021ef:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802204:	83 ec 0c             	sub    $0xc,%esp
  802207:	50                   	push   %eax
  802208:	e8 c5 ee ff ff       	call   8010d2 <fd2num>
  80220d:	89 c2                	mov    %eax,%edx
  80220f:	83 c4 10             	add    $0x10,%esp
}
  802212:	89 d0                	mov    %edx,%eax
  802214:	c9                   	leave  
  802215:	c3                   	ret    

00802216 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80221c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802223:	75 2e                	jne    802253 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802225:	e8 46 e9 ff ff       	call   800b70 <sys_getenvid>
  80222a:	83 ec 04             	sub    $0x4,%esp
  80222d:	68 07 0e 00 00       	push   $0xe07
  802232:	68 00 f0 bf ee       	push   $0xeebff000
  802237:	50                   	push   %eax
  802238:	e8 71 e9 ff ff       	call   800bae <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80223d:	e8 2e e9 ff ff       	call   800b70 <sys_getenvid>
  802242:	83 c4 08             	add    $0x8,%esp
  802245:	68 5d 22 80 00       	push   $0x80225d
  80224a:	50                   	push   %eax
  80224b:	e8 a9 ea ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
  802250:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802253:	8b 45 08             	mov    0x8(%ebp),%eax
  802256:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80225b:	c9                   	leave  
  80225c:	c3                   	ret    

0080225d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80225d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80225e:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802263:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802265:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802268:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80226c:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802270:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802273:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802276:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802277:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80227a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80227b:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80227c:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802280:	c3                   	ret    

00802281 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	56                   	push   %esi
  802285:	53                   	push   %ebx
  802286:	8b 75 08             	mov    0x8(%ebp),%esi
  802289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80228f:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802291:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802296:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802299:	83 ec 0c             	sub    $0xc,%esp
  80229c:	50                   	push   %eax
  80229d:	e8 bc ea ff ff       	call   800d5e <sys_ipc_recv>

	if (from_env_store != NULL)
  8022a2:	83 c4 10             	add    $0x10,%esp
  8022a5:	85 f6                	test   %esi,%esi
  8022a7:	74 14                	je     8022bd <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8022a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	78 09                	js     8022bb <ipc_recv+0x3a>
  8022b2:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8022b8:	8b 52 74             	mov    0x74(%edx),%edx
  8022bb:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8022bd:	85 db                	test   %ebx,%ebx
  8022bf:	74 14                	je     8022d5 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8022c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c6:	85 c0                	test   %eax,%eax
  8022c8:	78 09                	js     8022d3 <ipc_recv+0x52>
  8022ca:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8022d0:	8b 52 78             	mov    0x78(%edx),%edx
  8022d3:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8022d5:	85 c0                	test   %eax,%eax
  8022d7:	78 08                	js     8022e1 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8022d9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8022de:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e4:	5b                   	pop    %ebx
  8022e5:	5e                   	pop    %esi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    

008022e8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
  8022eb:	57                   	push   %edi
  8022ec:	56                   	push   %esi
  8022ed:	53                   	push   %ebx
  8022ee:	83 ec 0c             	sub    $0xc,%esp
  8022f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8022fa:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8022fc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802301:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802304:	ff 75 14             	pushl  0x14(%ebp)
  802307:	53                   	push   %ebx
  802308:	56                   	push   %esi
  802309:	57                   	push   %edi
  80230a:	e8 2c ea ff ff       	call   800d3b <sys_ipc_try_send>

		if (err < 0) {
  80230f:	83 c4 10             	add    $0x10,%esp
  802312:	85 c0                	test   %eax,%eax
  802314:	79 1e                	jns    802334 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802316:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802319:	75 07                	jne    802322 <ipc_send+0x3a>
				sys_yield();
  80231b:	e8 6f e8 ff ff       	call   800b8f <sys_yield>
  802320:	eb e2                	jmp    802304 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802322:	50                   	push   %eax
  802323:	68 cf 2b 80 00       	push   $0x802bcf
  802328:	6a 49                	push   $0x49
  80232a:	68 dc 2b 80 00       	push   $0x802bdc
  80232f:	e8 19 de ff ff       	call   80014d <_panic>
		}

	} while (err < 0);

}
  802334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    

0080233c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80233c:	55                   	push   %ebp
  80233d:	89 e5                	mov    %esp,%ebp
  80233f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802342:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802347:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80234a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802350:	8b 52 50             	mov    0x50(%edx),%edx
  802353:	39 ca                	cmp    %ecx,%edx
  802355:	75 0d                	jne    802364 <ipc_find_env+0x28>
			return envs[i].env_id;
  802357:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80235a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80235f:	8b 40 48             	mov    0x48(%eax),%eax
  802362:	eb 0f                	jmp    802373 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802364:	83 c0 01             	add    $0x1,%eax
  802367:	3d 00 04 00 00       	cmp    $0x400,%eax
  80236c:	75 d9                	jne    802347 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80236e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802373:	5d                   	pop    %ebp
  802374:	c3                   	ret    

00802375 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802375:	55                   	push   %ebp
  802376:	89 e5                	mov    %esp,%ebp
  802378:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80237b:	89 d0                	mov    %edx,%eax
  80237d:	c1 e8 16             	shr    $0x16,%eax
  802380:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802387:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80238c:	f6 c1 01             	test   $0x1,%cl
  80238f:	74 1d                	je     8023ae <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802391:	c1 ea 0c             	shr    $0xc,%edx
  802394:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80239b:	f6 c2 01             	test   $0x1,%dl
  80239e:	74 0e                	je     8023ae <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023a0:	c1 ea 0c             	shr    $0xc,%edx
  8023a3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023aa:	ef 
  8023ab:	0f b7 c0             	movzwl %ax,%eax
}
  8023ae:	5d                   	pop    %ebp
  8023af:	c3                   	ret    

008023b0 <__udivdi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 1c             	sub    $0x1c,%esp
  8023b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023c7:	85 f6                	test   %esi,%esi
  8023c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023cd:	89 ca                	mov    %ecx,%edx
  8023cf:	89 f8                	mov    %edi,%eax
  8023d1:	75 3d                	jne    802410 <__udivdi3+0x60>
  8023d3:	39 cf                	cmp    %ecx,%edi
  8023d5:	0f 87 c5 00 00 00    	ja     8024a0 <__udivdi3+0xf0>
  8023db:	85 ff                	test   %edi,%edi
  8023dd:	89 fd                	mov    %edi,%ebp
  8023df:	75 0b                	jne    8023ec <__udivdi3+0x3c>
  8023e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e6:	31 d2                	xor    %edx,%edx
  8023e8:	f7 f7                	div    %edi
  8023ea:	89 c5                	mov    %eax,%ebp
  8023ec:	89 c8                	mov    %ecx,%eax
  8023ee:	31 d2                	xor    %edx,%edx
  8023f0:	f7 f5                	div    %ebp
  8023f2:	89 c1                	mov    %eax,%ecx
  8023f4:	89 d8                	mov    %ebx,%eax
  8023f6:	89 cf                	mov    %ecx,%edi
  8023f8:	f7 f5                	div    %ebp
  8023fa:	89 c3                	mov    %eax,%ebx
  8023fc:	89 d8                	mov    %ebx,%eax
  8023fe:	89 fa                	mov    %edi,%edx
  802400:	83 c4 1c             	add    $0x1c,%esp
  802403:	5b                   	pop    %ebx
  802404:	5e                   	pop    %esi
  802405:	5f                   	pop    %edi
  802406:	5d                   	pop    %ebp
  802407:	c3                   	ret    
  802408:	90                   	nop
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	39 ce                	cmp    %ecx,%esi
  802412:	77 74                	ja     802488 <__udivdi3+0xd8>
  802414:	0f bd fe             	bsr    %esi,%edi
  802417:	83 f7 1f             	xor    $0x1f,%edi
  80241a:	0f 84 98 00 00 00    	je     8024b8 <__udivdi3+0x108>
  802420:	bb 20 00 00 00       	mov    $0x20,%ebx
  802425:	89 f9                	mov    %edi,%ecx
  802427:	89 c5                	mov    %eax,%ebp
  802429:	29 fb                	sub    %edi,%ebx
  80242b:	d3 e6                	shl    %cl,%esi
  80242d:	89 d9                	mov    %ebx,%ecx
  80242f:	d3 ed                	shr    %cl,%ebp
  802431:	89 f9                	mov    %edi,%ecx
  802433:	d3 e0                	shl    %cl,%eax
  802435:	09 ee                	or     %ebp,%esi
  802437:	89 d9                	mov    %ebx,%ecx
  802439:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80243d:	89 d5                	mov    %edx,%ebp
  80243f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802443:	d3 ed                	shr    %cl,%ebp
  802445:	89 f9                	mov    %edi,%ecx
  802447:	d3 e2                	shl    %cl,%edx
  802449:	89 d9                	mov    %ebx,%ecx
  80244b:	d3 e8                	shr    %cl,%eax
  80244d:	09 c2                	or     %eax,%edx
  80244f:	89 d0                	mov    %edx,%eax
  802451:	89 ea                	mov    %ebp,%edx
  802453:	f7 f6                	div    %esi
  802455:	89 d5                	mov    %edx,%ebp
  802457:	89 c3                	mov    %eax,%ebx
  802459:	f7 64 24 0c          	mull   0xc(%esp)
  80245d:	39 d5                	cmp    %edx,%ebp
  80245f:	72 10                	jb     802471 <__udivdi3+0xc1>
  802461:	8b 74 24 08          	mov    0x8(%esp),%esi
  802465:	89 f9                	mov    %edi,%ecx
  802467:	d3 e6                	shl    %cl,%esi
  802469:	39 c6                	cmp    %eax,%esi
  80246b:	73 07                	jae    802474 <__udivdi3+0xc4>
  80246d:	39 d5                	cmp    %edx,%ebp
  80246f:	75 03                	jne    802474 <__udivdi3+0xc4>
  802471:	83 eb 01             	sub    $0x1,%ebx
  802474:	31 ff                	xor    %edi,%edi
  802476:	89 d8                	mov    %ebx,%eax
  802478:	89 fa                	mov    %edi,%edx
  80247a:	83 c4 1c             	add    $0x1c,%esp
  80247d:	5b                   	pop    %ebx
  80247e:	5e                   	pop    %esi
  80247f:	5f                   	pop    %edi
  802480:	5d                   	pop    %ebp
  802481:	c3                   	ret    
  802482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802488:	31 ff                	xor    %edi,%edi
  80248a:	31 db                	xor    %ebx,%ebx
  80248c:	89 d8                	mov    %ebx,%eax
  80248e:	89 fa                	mov    %edi,%edx
  802490:	83 c4 1c             	add    $0x1c,%esp
  802493:	5b                   	pop    %ebx
  802494:	5e                   	pop    %esi
  802495:	5f                   	pop    %edi
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    
  802498:	90                   	nop
  802499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	89 d8                	mov    %ebx,%eax
  8024a2:	f7 f7                	div    %edi
  8024a4:	31 ff                	xor    %edi,%edi
  8024a6:	89 c3                	mov    %eax,%ebx
  8024a8:	89 d8                	mov    %ebx,%eax
  8024aa:	89 fa                	mov    %edi,%edx
  8024ac:	83 c4 1c             	add    $0x1c,%esp
  8024af:	5b                   	pop    %ebx
  8024b0:	5e                   	pop    %esi
  8024b1:	5f                   	pop    %edi
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    
  8024b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024b8:	39 ce                	cmp    %ecx,%esi
  8024ba:	72 0c                	jb     8024c8 <__udivdi3+0x118>
  8024bc:	31 db                	xor    %ebx,%ebx
  8024be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024c2:	0f 87 34 ff ff ff    	ja     8023fc <__udivdi3+0x4c>
  8024c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024cd:	e9 2a ff ff ff       	jmp    8023fc <__udivdi3+0x4c>
  8024d2:	66 90                	xchg   %ax,%ax
  8024d4:	66 90                	xchg   %ax,%ax
  8024d6:	66 90                	xchg   %ax,%ax
  8024d8:	66 90                	xchg   %ax,%ax
  8024da:	66 90                	xchg   %ax,%ax
  8024dc:	66 90                	xchg   %ax,%ax
  8024de:	66 90                	xchg   %ax,%ax

008024e0 <__umoddi3>:
  8024e0:	55                   	push   %ebp
  8024e1:	57                   	push   %edi
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	83 ec 1c             	sub    $0x1c,%esp
  8024e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024f7:	85 d2                	test   %edx,%edx
  8024f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802501:	89 f3                	mov    %esi,%ebx
  802503:	89 3c 24             	mov    %edi,(%esp)
  802506:	89 74 24 04          	mov    %esi,0x4(%esp)
  80250a:	75 1c                	jne    802528 <__umoddi3+0x48>
  80250c:	39 f7                	cmp    %esi,%edi
  80250e:	76 50                	jbe    802560 <__umoddi3+0x80>
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 f2                	mov    %esi,%edx
  802514:	f7 f7                	div    %edi
  802516:	89 d0                	mov    %edx,%eax
  802518:	31 d2                	xor    %edx,%edx
  80251a:	83 c4 1c             	add    $0x1c,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	39 f2                	cmp    %esi,%edx
  80252a:	89 d0                	mov    %edx,%eax
  80252c:	77 52                	ja     802580 <__umoddi3+0xa0>
  80252e:	0f bd ea             	bsr    %edx,%ebp
  802531:	83 f5 1f             	xor    $0x1f,%ebp
  802534:	75 5a                	jne    802590 <__umoddi3+0xb0>
  802536:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80253a:	0f 82 e0 00 00 00    	jb     802620 <__umoddi3+0x140>
  802540:	39 0c 24             	cmp    %ecx,(%esp)
  802543:	0f 86 d7 00 00 00    	jbe    802620 <__umoddi3+0x140>
  802549:	8b 44 24 08          	mov    0x8(%esp),%eax
  80254d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802551:	83 c4 1c             	add    $0x1c,%esp
  802554:	5b                   	pop    %ebx
  802555:	5e                   	pop    %esi
  802556:	5f                   	pop    %edi
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	85 ff                	test   %edi,%edi
  802562:	89 fd                	mov    %edi,%ebp
  802564:	75 0b                	jne    802571 <__umoddi3+0x91>
  802566:	b8 01 00 00 00       	mov    $0x1,%eax
  80256b:	31 d2                	xor    %edx,%edx
  80256d:	f7 f7                	div    %edi
  80256f:	89 c5                	mov    %eax,%ebp
  802571:	89 f0                	mov    %esi,%eax
  802573:	31 d2                	xor    %edx,%edx
  802575:	f7 f5                	div    %ebp
  802577:	89 c8                	mov    %ecx,%eax
  802579:	f7 f5                	div    %ebp
  80257b:	89 d0                	mov    %edx,%eax
  80257d:	eb 99                	jmp    802518 <__umoddi3+0x38>
  80257f:	90                   	nop
  802580:	89 c8                	mov    %ecx,%eax
  802582:	89 f2                	mov    %esi,%edx
  802584:	83 c4 1c             	add    $0x1c,%esp
  802587:	5b                   	pop    %ebx
  802588:	5e                   	pop    %esi
  802589:	5f                   	pop    %edi
  80258a:	5d                   	pop    %ebp
  80258b:	c3                   	ret    
  80258c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802590:	8b 34 24             	mov    (%esp),%esi
  802593:	bf 20 00 00 00       	mov    $0x20,%edi
  802598:	89 e9                	mov    %ebp,%ecx
  80259a:	29 ef                	sub    %ebp,%edi
  80259c:	d3 e0                	shl    %cl,%eax
  80259e:	89 f9                	mov    %edi,%ecx
  8025a0:	89 f2                	mov    %esi,%edx
  8025a2:	d3 ea                	shr    %cl,%edx
  8025a4:	89 e9                	mov    %ebp,%ecx
  8025a6:	09 c2                	or     %eax,%edx
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	89 14 24             	mov    %edx,(%esp)
  8025ad:	89 f2                	mov    %esi,%edx
  8025af:	d3 e2                	shl    %cl,%edx
  8025b1:	89 f9                	mov    %edi,%ecx
  8025b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025bb:	d3 e8                	shr    %cl,%eax
  8025bd:	89 e9                	mov    %ebp,%ecx
  8025bf:	89 c6                	mov    %eax,%esi
  8025c1:	d3 e3                	shl    %cl,%ebx
  8025c3:	89 f9                	mov    %edi,%ecx
  8025c5:	89 d0                	mov    %edx,%eax
  8025c7:	d3 e8                	shr    %cl,%eax
  8025c9:	89 e9                	mov    %ebp,%ecx
  8025cb:	09 d8                	or     %ebx,%eax
  8025cd:	89 d3                	mov    %edx,%ebx
  8025cf:	89 f2                	mov    %esi,%edx
  8025d1:	f7 34 24             	divl   (%esp)
  8025d4:	89 d6                	mov    %edx,%esi
  8025d6:	d3 e3                	shl    %cl,%ebx
  8025d8:	f7 64 24 04          	mull   0x4(%esp)
  8025dc:	39 d6                	cmp    %edx,%esi
  8025de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025e2:	89 d1                	mov    %edx,%ecx
  8025e4:	89 c3                	mov    %eax,%ebx
  8025e6:	72 08                	jb     8025f0 <__umoddi3+0x110>
  8025e8:	75 11                	jne    8025fb <__umoddi3+0x11b>
  8025ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025ee:	73 0b                	jae    8025fb <__umoddi3+0x11b>
  8025f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025f4:	1b 14 24             	sbb    (%esp),%edx
  8025f7:	89 d1                	mov    %edx,%ecx
  8025f9:	89 c3                	mov    %eax,%ebx
  8025fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025ff:	29 da                	sub    %ebx,%edx
  802601:	19 ce                	sbb    %ecx,%esi
  802603:	89 f9                	mov    %edi,%ecx
  802605:	89 f0                	mov    %esi,%eax
  802607:	d3 e0                	shl    %cl,%eax
  802609:	89 e9                	mov    %ebp,%ecx
  80260b:	d3 ea                	shr    %cl,%edx
  80260d:	89 e9                	mov    %ebp,%ecx
  80260f:	d3 ee                	shr    %cl,%esi
  802611:	09 d0                	or     %edx,%eax
  802613:	89 f2                	mov    %esi,%edx
  802615:	83 c4 1c             	add    $0x1c,%esp
  802618:	5b                   	pop    %ebx
  802619:	5e                   	pop    %esi
  80261a:	5f                   	pop    %edi
  80261b:	5d                   	pop    %ebp
  80261c:	c3                   	ret    
  80261d:	8d 76 00             	lea    0x0(%esi),%esi
  802620:	29 f9                	sub    %edi,%ecx
  802622:	19 d6                	sbb    %edx,%esi
  802624:	89 74 24 04          	mov    %esi,0x4(%esp)
  802628:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80262c:	e9 18 ff ff ff       	jmp    802549 <__umoddi3+0x69>
