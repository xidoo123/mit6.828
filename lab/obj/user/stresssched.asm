
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
  800044:	e8 4e 0e 00 00       	call   800e97 <fork>
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
  8000b8:	68 c0 25 80 00       	push   $0x8025c0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 e8 25 80 00       	push   $0x8025e8
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 fb 25 80 00       	push   $0x8025fb
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
  800139:	e8 db 10 00 00       	call   801219 <close_all>
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
  80016b:	68 24 26 80 00       	push   $0x802624
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 17 26 80 00 	movl   $0x802617,(%esp)
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
  800289:	e8 a2 20 00 00       	call   802330 <__udivdi3>
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
  8002cc:	e8 8f 21 00 00       	call   802460 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 47 26 80 00 	movsbl 0x802647(%eax),%eax
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
  8003d0:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
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
  800494:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 5f 26 80 00       	push   $0x80265f
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
  8004b8:	68 d1 2a 80 00       	push   $0x802ad1
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
  8004dc:	b8 58 26 80 00       	mov    $0x802658,%eax
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
  800b57:	68 3f 29 80 00       	push   $0x80293f
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 5c 29 80 00       	push   $0x80295c
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
  800bd8:	68 3f 29 80 00       	push   $0x80293f
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 5c 29 80 00       	push   $0x80295c
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
  800c1a:	68 3f 29 80 00       	push   $0x80293f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 5c 29 80 00       	push   $0x80295c
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
  800c5c:	68 3f 29 80 00       	push   $0x80293f
  800c61:	6a 23                	push   $0x23
  800c63:	68 5c 29 80 00       	push   $0x80295c
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
  800c9e:	68 3f 29 80 00       	push   $0x80293f
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 5c 29 80 00       	push   $0x80295c
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
  800ce0:	68 3f 29 80 00       	push   $0x80293f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 5c 29 80 00       	push   $0x80295c
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
  800d22:	68 3f 29 80 00       	push   $0x80293f
  800d27:	6a 23                	push   $0x23
  800d29:	68 5c 29 80 00       	push   $0x80295c
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
  800d86:	68 3f 29 80 00       	push   $0x80293f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 5c 29 80 00       	push   $0x80295c
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

00800dbe <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dc6:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800dc8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dcc:	75 25                	jne    800df3 <pgfault+0x35>
  800dce:	89 d8                	mov    %ebx,%eax
  800dd0:	c1 e8 0c             	shr    $0xc,%eax
  800dd3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dda:	f6 c4 08             	test   $0x8,%ah
  800ddd:	75 14                	jne    800df3 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	68 6c 29 80 00       	push   $0x80296c
  800de7:	6a 1e                	push   $0x1e
  800de9:	68 00 2a 80 00       	push   $0x802a00
  800dee:	e8 5a f3 ff ff       	call   80014d <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800df3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800df9:	e8 72 fd ff ff       	call   800b70 <sys_getenvid>
  800dfe:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e00:	83 ec 04             	sub    $0x4,%esp
  800e03:	6a 07                	push   $0x7
  800e05:	68 00 f0 7f 00       	push   $0x7ff000
  800e0a:	50                   	push   %eax
  800e0b:	e8 9e fd ff ff       	call   800bae <sys_page_alloc>
	if (r < 0)
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	79 12                	jns    800e29 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e17:	50                   	push   %eax
  800e18:	68 98 29 80 00       	push   $0x802998
  800e1d:	6a 33                	push   $0x33
  800e1f:	68 00 2a 80 00       	push   $0x802a00
  800e24:	e8 24 f3 ff ff       	call   80014d <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	68 00 10 00 00       	push   $0x1000
  800e31:	53                   	push   %ebx
  800e32:	68 00 f0 7f 00       	push   $0x7ff000
  800e37:	e8 69 fb ff ff       	call   8009a5 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e3c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e43:	53                   	push   %ebx
  800e44:	56                   	push   %esi
  800e45:	68 00 f0 7f 00       	push   $0x7ff000
  800e4a:	56                   	push   %esi
  800e4b:	e8 a1 fd ff ff       	call   800bf1 <sys_page_map>
	if (r < 0)
  800e50:	83 c4 20             	add    $0x20,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	79 12                	jns    800e69 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e57:	50                   	push   %eax
  800e58:	68 bc 29 80 00       	push   $0x8029bc
  800e5d:	6a 3b                	push   $0x3b
  800e5f:	68 00 2a 80 00       	push   $0x802a00
  800e64:	e8 e4 f2 ff ff       	call   80014d <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e69:	83 ec 08             	sub    $0x8,%esp
  800e6c:	68 00 f0 7f 00       	push   $0x7ff000
  800e71:	56                   	push   %esi
  800e72:	e8 bc fd ff ff       	call   800c33 <sys_page_unmap>
	if (r < 0)
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	79 12                	jns    800e90 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e7e:	50                   	push   %eax
  800e7f:	68 e0 29 80 00       	push   $0x8029e0
  800e84:	6a 40                	push   $0x40
  800e86:	68 00 2a 80 00       	push   $0x802a00
  800e8b:	e8 bd f2 ff ff       	call   80014d <_panic>
}
  800e90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800ea0:	68 be 0d 80 00       	push   $0x800dbe
  800ea5:	e8 e8 12 00 00       	call   802192 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eaa:	b8 07 00 00 00       	mov    $0x7,%eax
  800eaf:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	0f 88 64 01 00 00    	js     801020 <fork+0x189>
  800ebc:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800ec1:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	75 21                	jne    800eeb <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eca:	e8 a1 fc ff ff       	call   800b70 <sys_getenvid>
  800ecf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ed7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800edc:	a3 0c 40 80 00       	mov    %eax,0x80400c
        return 0;
  800ee1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee6:	e9 3f 01 00 00       	jmp    80102a <fork+0x193>
  800eeb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800eee:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	c1 e8 16             	shr    $0x16,%eax
  800ef5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800efc:	a8 01                	test   $0x1,%al
  800efe:	0f 84 bd 00 00 00    	je     800fc1 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f04:	89 d8                	mov    %ebx,%eax
  800f06:	c1 e8 0c             	shr    $0xc,%eax
  800f09:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f10:	f6 c2 01             	test   $0x1,%dl
  800f13:	0f 84 a8 00 00 00    	je     800fc1 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f19:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f20:	a8 04                	test   $0x4,%al
  800f22:	0f 84 99 00 00 00    	je     800fc1 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f28:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f2f:	f6 c4 04             	test   $0x4,%ah
  800f32:	74 17                	je     800f4b <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f34:	83 ec 0c             	sub    $0xc,%esp
  800f37:	68 07 0e 00 00       	push   $0xe07
  800f3c:	53                   	push   %ebx
  800f3d:	57                   	push   %edi
  800f3e:	53                   	push   %ebx
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 ab fc ff ff       	call   800bf1 <sys_page_map>
  800f46:	83 c4 20             	add    $0x20,%esp
  800f49:	eb 76                	jmp    800fc1 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f4b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f52:	a8 02                	test   $0x2,%al
  800f54:	75 0c                	jne    800f62 <fork+0xcb>
  800f56:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f5d:	f6 c4 08             	test   $0x8,%ah
  800f60:	74 3f                	je     800fa1 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	68 05 08 00 00       	push   $0x805
  800f6a:	53                   	push   %ebx
  800f6b:	57                   	push   %edi
  800f6c:	53                   	push   %ebx
  800f6d:	6a 00                	push   $0x0
  800f6f:	e8 7d fc ff ff       	call   800bf1 <sys_page_map>
		if (r < 0)
  800f74:	83 c4 20             	add    $0x20,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	0f 88 a5 00 00 00    	js     801024 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	68 05 08 00 00       	push   $0x805
  800f87:	53                   	push   %ebx
  800f88:	6a 00                	push   $0x0
  800f8a:	53                   	push   %ebx
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 5f fc ff ff       	call   800bf1 <sys_page_map>
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9c:	0f 4f c1             	cmovg  %ecx,%eax
  800f9f:	eb 1c                	jmp    800fbd <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	6a 05                	push   $0x5
  800fa6:	53                   	push   %ebx
  800fa7:	57                   	push   %edi
  800fa8:	53                   	push   %ebx
  800fa9:	6a 00                	push   $0x0
  800fab:	e8 41 fc ff ff       	call   800bf1 <sys_page_map>
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fba:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 67                	js     801028 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fc1:	83 c6 01             	add    $0x1,%esi
  800fc4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fca:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800fd0:	0f 85 1a ff ff ff    	jne    800ef0 <fork+0x59>
  800fd6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	6a 07                	push   $0x7
  800fde:	68 00 f0 bf ee       	push   $0xeebff000
  800fe3:	57                   	push   %edi
  800fe4:	e8 c5 fb ff ff       	call   800bae <sys_page_alloc>
	if (r < 0)
  800fe9:	83 c4 10             	add    $0x10,%esp
		return r;
  800fec:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 38                	js     80102a <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800ff2:	83 ec 08             	sub    $0x8,%esp
  800ff5:	68 d9 21 80 00       	push   $0x8021d9
  800ffa:	57                   	push   %edi
  800ffb:	e8 f9 fc ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801000:	83 c4 10             	add    $0x10,%esp
		return r;
  801003:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	78 21                	js     80102a <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801009:	83 ec 08             	sub    $0x8,%esp
  80100c:	6a 02                	push   $0x2
  80100e:	57                   	push   %edi
  80100f:	e8 61 fc ff ff       	call   800c75 <sys_env_set_status>
	if (r < 0)
  801014:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801017:	85 c0                	test   %eax,%eax
  801019:	0f 48 f8             	cmovs  %eax,%edi
  80101c:	89 fa                	mov    %edi,%edx
  80101e:	eb 0a                	jmp    80102a <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801020:	89 c2                	mov    %eax,%edx
  801022:	eb 06                	jmp    80102a <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801024:	89 c2                	mov    %eax,%edx
  801026:	eb 02                	jmp    80102a <fork+0x193>
  801028:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  80102a:	89 d0                	mov    %edx,%eax
  80102c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sfork>:

// Challenge!
int
sfork(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80103a:	68 0b 2a 80 00       	push   $0x802a0b
  80103f:	68 c9 00 00 00       	push   $0xc9
  801044:	68 00 2a 80 00       	push   $0x802a00
  801049:	e8 ff f0 ff ff       	call   80014d <_panic>

0080104e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801051:	8b 45 08             	mov    0x8(%ebp),%eax
  801054:	05 00 00 00 30       	add    $0x30000000,%eax
  801059:	c1 e8 0c             	shr    $0xc,%eax
}
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    

0080105e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	05 00 00 00 30       	add    $0x30000000,%eax
  801069:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80106e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801080:	89 c2                	mov    %eax,%edx
  801082:	c1 ea 16             	shr    $0x16,%edx
  801085:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108c:	f6 c2 01             	test   $0x1,%dl
  80108f:	74 11                	je     8010a2 <fd_alloc+0x2d>
  801091:	89 c2                	mov    %eax,%edx
  801093:	c1 ea 0c             	shr    $0xc,%edx
  801096:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109d:	f6 c2 01             	test   $0x1,%dl
  8010a0:	75 09                	jne    8010ab <fd_alloc+0x36>
			*fd_store = fd;
  8010a2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a9:	eb 17                	jmp    8010c2 <fd_alloc+0x4d>
  8010ab:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b5:	75 c9                	jne    801080 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010b7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010bd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ca:	83 f8 1f             	cmp    $0x1f,%eax
  8010cd:	77 36                	ja     801105 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010cf:	c1 e0 0c             	shl    $0xc,%eax
  8010d2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010d7:	89 c2                	mov    %eax,%edx
  8010d9:	c1 ea 16             	shr    $0x16,%edx
  8010dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e3:	f6 c2 01             	test   $0x1,%dl
  8010e6:	74 24                	je     80110c <fd_lookup+0x48>
  8010e8:	89 c2                	mov    %eax,%edx
  8010ea:	c1 ea 0c             	shr    $0xc,%edx
  8010ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f4:	f6 c2 01             	test   $0x1,%dl
  8010f7:	74 1a                	je     801113 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fc:	89 02                	mov    %eax,(%edx)
	return 0;
  8010fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801103:	eb 13                	jmp    801118 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801105:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110a:	eb 0c                	jmp    801118 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801111:	eb 05                	jmp    801118 <fd_lookup+0x54>
  801113:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801123:	ba a4 2a 80 00       	mov    $0x802aa4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801128:	eb 13                	jmp    80113d <dev_lookup+0x23>
  80112a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80112d:	39 08                	cmp    %ecx,(%eax)
  80112f:	75 0c                	jne    80113d <dev_lookup+0x23>
			*dev = devtab[i];
  801131:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801134:	89 01                	mov    %eax,(%ecx)
			return 0;
  801136:	b8 00 00 00 00       	mov    $0x0,%eax
  80113b:	eb 2e                	jmp    80116b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80113d:	8b 02                	mov    (%edx),%eax
  80113f:	85 c0                	test   %eax,%eax
  801141:	75 e7                	jne    80112a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801143:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801148:	8b 40 48             	mov    0x48(%eax),%eax
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	51                   	push   %ecx
  80114f:	50                   	push   %eax
  801150:	68 24 2a 80 00       	push   $0x802a24
  801155:	e8 cc f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  80115a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    

0080116d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	83 ec 10             	sub    $0x10,%esp
  801175:	8b 75 08             	mov    0x8(%ebp),%esi
  801178:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801185:	c1 e8 0c             	shr    $0xc,%eax
  801188:	50                   	push   %eax
  801189:	e8 36 ff ff ff       	call   8010c4 <fd_lookup>
  80118e:	83 c4 08             	add    $0x8,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 05                	js     80119a <fd_close+0x2d>
	    || fd != fd2)
  801195:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801198:	74 0c                	je     8011a6 <fd_close+0x39>
		return (must_exist ? r : 0);
  80119a:	84 db                	test   %bl,%bl
  80119c:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a1:	0f 44 c2             	cmove  %edx,%eax
  8011a4:	eb 41                	jmp    8011e7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ac:	50                   	push   %eax
  8011ad:	ff 36                	pushl  (%esi)
  8011af:	e8 66 ff ff ff       	call   80111a <dev_lookup>
  8011b4:	89 c3                	mov    %eax,%ebx
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 1a                	js     8011d7 <fd_close+0x6a>
		if (dev->dev_close)
  8011bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	74 0b                	je     8011d7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011cc:	83 ec 0c             	sub    $0xc,%esp
  8011cf:	56                   	push   %esi
  8011d0:	ff d0                	call   *%eax
  8011d2:	89 c3                	mov    %eax,%ebx
  8011d4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011d7:	83 ec 08             	sub    $0x8,%esp
  8011da:	56                   	push   %esi
  8011db:	6a 00                	push   $0x0
  8011dd:	e8 51 fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	89 d8                	mov    %ebx,%eax
}
  8011e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ea:	5b                   	pop    %ebx
  8011eb:	5e                   	pop    %esi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f7:	50                   	push   %eax
  8011f8:	ff 75 08             	pushl  0x8(%ebp)
  8011fb:	e8 c4 fe ff ff       	call   8010c4 <fd_lookup>
  801200:	83 c4 08             	add    $0x8,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 10                	js     801217 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	6a 01                	push   $0x1
  80120c:	ff 75 f4             	pushl  -0xc(%ebp)
  80120f:	e8 59 ff ff ff       	call   80116d <fd_close>
  801214:	83 c4 10             	add    $0x10,%esp
}
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <close_all>:

void
close_all(void)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	53                   	push   %ebx
  80121d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801220:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801225:	83 ec 0c             	sub    $0xc,%esp
  801228:	53                   	push   %ebx
  801229:	e8 c0 ff ff ff       	call   8011ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80122e:	83 c3 01             	add    $0x1,%ebx
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	83 fb 20             	cmp    $0x20,%ebx
  801237:	75 ec                	jne    801225 <close_all+0xc>
		close(i);
}
  801239:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
  801244:	83 ec 2c             	sub    $0x2c,%esp
  801247:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80124a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80124d:	50                   	push   %eax
  80124e:	ff 75 08             	pushl  0x8(%ebp)
  801251:	e8 6e fe ff ff       	call   8010c4 <fd_lookup>
  801256:	83 c4 08             	add    $0x8,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	0f 88 c1 00 00 00    	js     801322 <dup+0xe4>
		return r;
	close(newfdnum);
  801261:	83 ec 0c             	sub    $0xc,%esp
  801264:	56                   	push   %esi
  801265:	e8 84 ff ff ff       	call   8011ee <close>

	newfd = INDEX2FD(newfdnum);
  80126a:	89 f3                	mov    %esi,%ebx
  80126c:	c1 e3 0c             	shl    $0xc,%ebx
  80126f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801275:	83 c4 04             	add    $0x4,%esp
  801278:	ff 75 e4             	pushl  -0x1c(%ebp)
  80127b:	e8 de fd ff ff       	call   80105e <fd2data>
  801280:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801282:	89 1c 24             	mov    %ebx,(%esp)
  801285:	e8 d4 fd ff ff       	call   80105e <fd2data>
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801290:	89 f8                	mov    %edi,%eax
  801292:	c1 e8 16             	shr    $0x16,%eax
  801295:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80129c:	a8 01                	test   $0x1,%al
  80129e:	74 37                	je     8012d7 <dup+0x99>
  8012a0:	89 f8                	mov    %edi,%eax
  8012a2:	c1 e8 0c             	shr    $0xc,%eax
  8012a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	74 26                	je     8012d7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b8:	83 ec 0c             	sub    $0xc,%esp
  8012bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c0:	50                   	push   %eax
  8012c1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012c4:	6a 00                	push   $0x0
  8012c6:	57                   	push   %edi
  8012c7:	6a 00                	push   $0x0
  8012c9:	e8 23 f9 ff ff       	call   800bf1 <sys_page_map>
  8012ce:	89 c7                	mov    %eax,%edi
  8012d0:	83 c4 20             	add    $0x20,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 2e                	js     801305 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012da:	89 d0                	mov    %edx,%eax
  8012dc:	c1 e8 0c             	shr    $0xc,%eax
  8012df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e6:	83 ec 0c             	sub    $0xc,%esp
  8012e9:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ee:	50                   	push   %eax
  8012ef:	53                   	push   %ebx
  8012f0:	6a 00                	push   $0x0
  8012f2:	52                   	push   %edx
  8012f3:	6a 00                	push   $0x0
  8012f5:	e8 f7 f8 ff ff       	call   800bf1 <sys_page_map>
  8012fa:	89 c7                	mov    %eax,%edi
  8012fc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012ff:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801301:	85 ff                	test   %edi,%edi
  801303:	79 1d                	jns    801322 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	53                   	push   %ebx
  801309:	6a 00                	push   $0x0
  80130b:	e8 23 f9 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801310:	83 c4 08             	add    $0x8,%esp
  801313:	ff 75 d4             	pushl  -0x2c(%ebp)
  801316:	6a 00                	push   $0x0
  801318:	e8 16 f9 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	89 f8                	mov    %edi,%eax
}
  801322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5f                   	pop    %edi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	53                   	push   %ebx
  80132e:	83 ec 14             	sub    $0x14,%esp
  801331:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801334:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	53                   	push   %ebx
  801339:	e8 86 fd ff ff       	call   8010c4 <fd_lookup>
  80133e:	83 c4 08             	add    $0x8,%esp
  801341:	89 c2                	mov    %eax,%edx
  801343:	85 c0                	test   %eax,%eax
  801345:	78 6d                	js     8013b4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801351:	ff 30                	pushl  (%eax)
  801353:	e8 c2 fd ff ff       	call   80111a <dev_lookup>
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 4c                	js     8013ab <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80135f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801362:	8b 42 08             	mov    0x8(%edx),%eax
  801365:	83 e0 03             	and    $0x3,%eax
  801368:	83 f8 01             	cmp    $0x1,%eax
  80136b:	75 21                	jne    80138e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80136d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801372:	8b 40 48             	mov    0x48(%eax),%eax
  801375:	83 ec 04             	sub    $0x4,%esp
  801378:	53                   	push   %ebx
  801379:	50                   	push   %eax
  80137a:	68 68 2a 80 00       	push   $0x802a68
  80137f:	e8 a2 ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80138c:	eb 26                	jmp    8013b4 <read+0x8a>
	}
	if (!dev->dev_read)
  80138e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801391:	8b 40 08             	mov    0x8(%eax),%eax
  801394:	85 c0                	test   %eax,%eax
  801396:	74 17                	je     8013af <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801398:	83 ec 04             	sub    $0x4,%esp
  80139b:	ff 75 10             	pushl  0x10(%ebp)
  80139e:	ff 75 0c             	pushl  0xc(%ebp)
  8013a1:	52                   	push   %edx
  8013a2:	ff d0                	call   *%eax
  8013a4:	89 c2                	mov    %eax,%edx
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	eb 09                	jmp    8013b4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ab:	89 c2                	mov    %eax,%edx
  8013ad:	eb 05                	jmp    8013b4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013af:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013b4:	89 d0                	mov    %edx,%eax
  8013b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	57                   	push   %edi
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 0c             	sub    $0xc,%esp
  8013c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cf:	eb 21                	jmp    8013f2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d1:	83 ec 04             	sub    $0x4,%esp
  8013d4:	89 f0                	mov    %esi,%eax
  8013d6:	29 d8                	sub    %ebx,%eax
  8013d8:	50                   	push   %eax
  8013d9:	89 d8                	mov    %ebx,%eax
  8013db:	03 45 0c             	add    0xc(%ebp),%eax
  8013de:	50                   	push   %eax
  8013df:	57                   	push   %edi
  8013e0:	e8 45 ff ff ff       	call   80132a <read>
		if (m < 0)
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 10                	js     8013fc <readn+0x41>
			return m;
		if (m == 0)
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	74 0a                	je     8013fa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f0:	01 c3                	add    %eax,%ebx
  8013f2:	39 f3                	cmp    %esi,%ebx
  8013f4:	72 db                	jb     8013d1 <readn+0x16>
  8013f6:	89 d8                	mov    %ebx,%eax
  8013f8:	eb 02                	jmp    8013fc <readn+0x41>
  8013fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5f                   	pop    %edi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	53                   	push   %ebx
  801408:	83 ec 14             	sub    $0x14,%esp
  80140b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801411:	50                   	push   %eax
  801412:	53                   	push   %ebx
  801413:	e8 ac fc ff ff       	call   8010c4 <fd_lookup>
  801418:	83 c4 08             	add    $0x8,%esp
  80141b:	89 c2                	mov    %eax,%edx
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 68                	js     801489 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801427:	50                   	push   %eax
  801428:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142b:	ff 30                	pushl  (%eax)
  80142d:	e8 e8 fc ff ff       	call   80111a <dev_lookup>
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 47                	js     801480 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801439:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801440:	75 21                	jne    801463 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801442:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801447:	8b 40 48             	mov    0x48(%eax),%eax
  80144a:	83 ec 04             	sub    $0x4,%esp
  80144d:	53                   	push   %ebx
  80144e:	50                   	push   %eax
  80144f:	68 84 2a 80 00       	push   $0x802a84
  801454:	e8 cd ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801461:	eb 26                	jmp    801489 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801463:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801466:	8b 52 0c             	mov    0xc(%edx),%edx
  801469:	85 d2                	test   %edx,%edx
  80146b:	74 17                	je     801484 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80146d:	83 ec 04             	sub    $0x4,%esp
  801470:	ff 75 10             	pushl  0x10(%ebp)
  801473:	ff 75 0c             	pushl  0xc(%ebp)
  801476:	50                   	push   %eax
  801477:	ff d2                	call   *%edx
  801479:	89 c2                	mov    %eax,%edx
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	eb 09                	jmp    801489 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801480:	89 c2                	mov    %eax,%edx
  801482:	eb 05                	jmp    801489 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801484:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801489:	89 d0                	mov    %edx,%eax
  80148b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <seek>:

int
seek(int fdnum, off_t offset)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801496:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	ff 75 08             	pushl  0x8(%ebp)
  80149d:	e8 22 fc ff ff       	call   8010c4 <fd_lookup>
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 0e                	js     8014b7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014af:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	53                   	push   %ebx
  8014bd:	83 ec 14             	sub    $0x14,%esp
  8014c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	53                   	push   %ebx
  8014c8:	e8 f7 fb ff ff       	call   8010c4 <fd_lookup>
  8014cd:	83 c4 08             	add    $0x8,%esp
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 65                	js     80153b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e0:	ff 30                	pushl  (%eax)
  8014e2:	e8 33 fc ff ff       	call   80111a <dev_lookup>
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 44                	js     801532 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f5:	75 21                	jne    801518 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014f7:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014fc:	8b 40 48             	mov    0x48(%eax),%eax
  8014ff:	83 ec 04             	sub    $0x4,%esp
  801502:	53                   	push   %ebx
  801503:	50                   	push   %eax
  801504:	68 44 2a 80 00       	push   $0x802a44
  801509:	e8 18 ed ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801516:	eb 23                	jmp    80153b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801518:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151b:	8b 52 18             	mov    0x18(%edx),%edx
  80151e:	85 d2                	test   %edx,%edx
  801520:	74 14                	je     801536 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	ff 75 0c             	pushl  0xc(%ebp)
  801528:	50                   	push   %eax
  801529:	ff d2                	call   *%edx
  80152b:	89 c2                	mov    %eax,%edx
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	eb 09                	jmp    80153b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	89 c2                	mov    %eax,%edx
  801534:	eb 05                	jmp    80153b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801536:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80153b:	89 d0                	mov    %edx,%eax
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	53                   	push   %ebx
  801546:	83 ec 14             	sub    $0x14,%esp
  801549:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	ff 75 08             	pushl  0x8(%ebp)
  801553:	e8 6c fb ff ff       	call   8010c4 <fd_lookup>
  801558:	83 c4 08             	add    $0x8,%esp
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 58                	js     8015b9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801567:	50                   	push   %eax
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	ff 30                	pushl  (%eax)
  80156d:	e8 a8 fb ff ff       	call   80111a <dev_lookup>
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	78 37                	js     8015b0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801579:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801580:	74 32                	je     8015b4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801582:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801585:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80158c:	00 00 00 
	stat->st_isdir = 0;
  80158f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801596:	00 00 00 
	stat->st_dev = dev;
  801599:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	53                   	push   %ebx
  8015a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a6:	ff 50 14             	call   *0x14(%eax)
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	eb 09                	jmp    8015b9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	eb 05                	jmp    8015b9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015b9:	89 d0                	mov    %edx,%eax
  8015bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	56                   	push   %esi
  8015c4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	6a 00                	push   $0x0
  8015ca:	ff 75 08             	pushl  0x8(%ebp)
  8015cd:	e8 d6 01 00 00       	call   8017a8 <open>
  8015d2:	89 c3                	mov    %eax,%ebx
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 1b                	js     8015f6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	ff 75 0c             	pushl  0xc(%ebp)
  8015e1:	50                   	push   %eax
  8015e2:	e8 5b ff ff ff       	call   801542 <fstat>
  8015e7:	89 c6                	mov    %eax,%esi
	close(fd);
  8015e9:	89 1c 24             	mov    %ebx,(%esp)
  8015ec:	e8 fd fb ff ff       	call   8011ee <close>
	return r;
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	89 f0                	mov    %esi,%eax
}
  8015f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f9:	5b                   	pop    %ebx
  8015fa:	5e                   	pop    %esi
  8015fb:	5d                   	pop    %ebp
  8015fc:	c3                   	ret    

008015fd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	56                   	push   %esi
  801601:	53                   	push   %ebx
  801602:	89 c6                	mov    %eax,%esi
  801604:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801606:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80160d:	75 12                	jne    801621 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80160f:	83 ec 0c             	sub    $0xc,%esp
  801612:	6a 01                	push   $0x1
  801614:	e8 9f 0c 00 00       	call   8022b8 <ipc_find_env>
  801619:	a3 00 40 80 00       	mov    %eax,0x804000
  80161e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801621:	6a 07                	push   $0x7
  801623:	68 00 50 80 00       	push   $0x805000
  801628:	56                   	push   %esi
  801629:	ff 35 00 40 80 00    	pushl  0x804000
  80162f:	e8 30 0c 00 00       	call   802264 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801634:	83 c4 0c             	add    $0xc,%esp
  801637:	6a 00                	push   $0x0
  801639:	53                   	push   %ebx
  80163a:	6a 00                	push   $0x0
  80163c:	e8 bc 0b 00 00       	call   8021fd <ipc_recv>
}
  801641:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801644:	5b                   	pop    %ebx
  801645:	5e                   	pop    %esi
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    

00801648 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80164e:	8b 45 08             	mov    0x8(%ebp),%eax
  801651:	8b 40 0c             	mov    0xc(%eax),%eax
  801654:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801659:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801661:	ba 00 00 00 00       	mov    $0x0,%edx
  801666:	b8 02 00 00 00       	mov    $0x2,%eax
  80166b:	e8 8d ff ff ff       	call   8015fd <fsipc>
}
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	8b 40 0c             	mov    0xc(%eax),%eax
  80167e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801683:	ba 00 00 00 00       	mov    $0x0,%edx
  801688:	b8 06 00 00 00       	mov    $0x6,%eax
  80168d:	e8 6b ff ff ff       	call   8015fd <fsipc>
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	53                   	push   %ebx
  801698:	83 ec 04             	sub    $0x4,%esp
  80169b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b3:	e8 45 ff ff ff       	call   8015fd <fsipc>
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 2c                	js     8016e8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	68 00 50 80 00       	push   $0x805000
  8016c4:	53                   	push   %ebx
  8016c5:	e8 e1 f0 ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ca:	a1 80 50 80 00       	mov    0x805080,%eax
  8016cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d5:	a1 84 50 80 00       	mov    0x805084,%eax
  8016da:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    

008016ed <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8016fc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801702:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801707:	50                   	push   %eax
  801708:	ff 75 0c             	pushl  0xc(%ebp)
  80170b:	68 08 50 80 00       	push   $0x805008
  801710:	e8 28 f2 ff ff       	call   80093d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801715:	ba 00 00 00 00       	mov    $0x0,%edx
  80171a:	b8 04 00 00 00       	mov    $0x4,%eax
  80171f:	e8 d9 fe ff ff       	call   8015fd <fsipc>

}
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	8b 40 0c             	mov    0xc(%eax),%eax
  801734:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801739:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80173f:	ba 00 00 00 00       	mov    $0x0,%edx
  801744:	b8 03 00 00 00       	mov    $0x3,%eax
  801749:	e8 af fe ff ff       	call   8015fd <fsipc>
  80174e:	89 c3                	mov    %eax,%ebx
  801750:	85 c0                	test   %eax,%eax
  801752:	78 4b                	js     80179f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801754:	39 c6                	cmp    %eax,%esi
  801756:	73 16                	jae    80176e <devfile_read+0x48>
  801758:	68 b8 2a 80 00       	push   $0x802ab8
  80175d:	68 bf 2a 80 00       	push   $0x802abf
  801762:	6a 7c                	push   $0x7c
  801764:	68 d4 2a 80 00       	push   $0x802ad4
  801769:	e8 df e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  80176e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801773:	7e 16                	jle    80178b <devfile_read+0x65>
  801775:	68 df 2a 80 00       	push   $0x802adf
  80177a:	68 bf 2a 80 00       	push   $0x802abf
  80177f:	6a 7d                	push   $0x7d
  801781:	68 d4 2a 80 00       	push   $0x802ad4
  801786:	e8 c2 e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80178b:	83 ec 04             	sub    $0x4,%esp
  80178e:	50                   	push   %eax
  80178f:	68 00 50 80 00       	push   $0x805000
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	e8 a1 f1 ff ff       	call   80093d <memmove>
	return r;
  80179c:	83 c4 10             	add    $0x10,%esp
}
  80179f:	89 d8                	mov    %ebx,%eax
  8017a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a4:	5b                   	pop    %ebx
  8017a5:	5e                   	pop    %esi
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	53                   	push   %ebx
  8017ac:	83 ec 20             	sub    $0x20,%esp
  8017af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017b2:	53                   	push   %ebx
  8017b3:	e8 ba ef ff ff       	call   800772 <strlen>
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017c0:	7f 67                	jg     801829 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017c2:	83 ec 0c             	sub    $0xc,%esp
  8017c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c8:	50                   	push   %eax
  8017c9:	e8 a7 f8 ff ff       	call   801075 <fd_alloc>
  8017ce:	83 c4 10             	add    $0x10,%esp
		return r;
  8017d1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 57                	js     80182e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017d7:	83 ec 08             	sub    $0x8,%esp
  8017da:	53                   	push   %ebx
  8017db:	68 00 50 80 00       	push   $0x805000
  8017e0:	e8 c6 ef ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f5:	e8 03 fe ff ff       	call   8015fd <fsipc>
  8017fa:	89 c3                	mov    %eax,%ebx
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	79 14                	jns    801817 <open+0x6f>
		fd_close(fd, 0);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	6a 00                	push   $0x0
  801808:	ff 75 f4             	pushl  -0xc(%ebp)
  80180b:	e8 5d f9 ff ff       	call   80116d <fd_close>
		return r;
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	89 da                	mov    %ebx,%edx
  801815:	eb 17                	jmp    80182e <open+0x86>
	}

	return fd2num(fd);
  801817:	83 ec 0c             	sub    $0xc,%esp
  80181a:	ff 75 f4             	pushl  -0xc(%ebp)
  80181d:	e8 2c f8 ff ff       	call   80104e <fd2num>
  801822:	89 c2                	mov    %eax,%edx
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	eb 05                	jmp    80182e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801829:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80182e:	89 d0                	mov    %edx,%eax
  801830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80183b:	ba 00 00 00 00       	mov    $0x0,%edx
  801840:	b8 08 00 00 00       	mov    $0x8,%eax
  801845:	e8 b3 fd ff ff       	call   8015fd <fsipc>
}
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	56                   	push   %esi
  801850:	53                   	push   %ebx
  801851:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801854:	83 ec 0c             	sub    $0xc,%esp
  801857:	ff 75 08             	pushl  0x8(%ebp)
  80185a:	e8 ff f7 ff ff       	call   80105e <fd2data>
  80185f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801861:	83 c4 08             	add    $0x8,%esp
  801864:	68 eb 2a 80 00       	push   $0x802aeb
  801869:	53                   	push   %ebx
  80186a:	e8 3c ef ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80186f:	8b 46 04             	mov    0x4(%esi),%eax
  801872:	2b 06                	sub    (%esi),%eax
  801874:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80187a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801881:	00 00 00 
	stat->st_dev = &devpipe;
  801884:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80188b:	30 80 00 
	return 0;
}
  80188e:	b8 00 00 00 00       	mov    $0x0,%eax
  801893:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801896:	5b                   	pop    %ebx
  801897:	5e                   	pop    %esi
  801898:	5d                   	pop    %ebp
  801899:	c3                   	ret    

0080189a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	53                   	push   %ebx
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018a4:	53                   	push   %ebx
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 87 f3 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018ac:	89 1c 24             	mov    %ebx,(%esp)
  8018af:	e8 aa f7 ff ff       	call   80105e <fd2data>
  8018b4:	83 c4 08             	add    $0x8,%esp
  8018b7:	50                   	push   %eax
  8018b8:	6a 00                	push   $0x0
  8018ba:	e8 74 f3 ff ff       	call   800c33 <sys_page_unmap>
}
  8018bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	57                   	push   %edi
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	83 ec 1c             	sub    $0x1c,%esp
  8018cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018d0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018d2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8018d7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8018e0:	e8 0c 0a 00 00       	call   8022f1 <pageref>
  8018e5:	89 c3                	mov    %eax,%ebx
  8018e7:	89 3c 24             	mov    %edi,(%esp)
  8018ea:	e8 02 0a 00 00       	call   8022f1 <pageref>
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	39 c3                	cmp    %eax,%ebx
  8018f4:	0f 94 c1             	sete   %cl
  8018f7:	0f b6 c9             	movzbl %cl,%ecx
  8018fa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018fd:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801903:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801906:	39 ce                	cmp    %ecx,%esi
  801908:	74 1b                	je     801925 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80190a:	39 c3                	cmp    %eax,%ebx
  80190c:	75 c4                	jne    8018d2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80190e:	8b 42 58             	mov    0x58(%edx),%eax
  801911:	ff 75 e4             	pushl  -0x1c(%ebp)
  801914:	50                   	push   %eax
  801915:	56                   	push   %esi
  801916:	68 f2 2a 80 00       	push   $0x802af2
  80191b:	e8 06 e9 ff ff       	call   800226 <cprintf>
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	eb ad                	jmp    8018d2 <_pipeisclosed+0xe>
	}
}
  801925:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801928:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192b:	5b                   	pop    %ebx
  80192c:	5e                   	pop    %esi
  80192d:	5f                   	pop    %edi
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	57                   	push   %edi
  801934:	56                   	push   %esi
  801935:	53                   	push   %ebx
  801936:	83 ec 28             	sub    $0x28,%esp
  801939:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80193c:	56                   	push   %esi
  80193d:	e8 1c f7 ff ff       	call   80105e <fd2data>
  801942:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	bf 00 00 00 00       	mov    $0x0,%edi
  80194c:	eb 4b                	jmp    801999 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80194e:	89 da                	mov    %ebx,%edx
  801950:	89 f0                	mov    %esi,%eax
  801952:	e8 6d ff ff ff       	call   8018c4 <_pipeisclosed>
  801957:	85 c0                	test   %eax,%eax
  801959:	75 48                	jne    8019a3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80195b:	e8 2f f2 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801960:	8b 43 04             	mov    0x4(%ebx),%eax
  801963:	8b 0b                	mov    (%ebx),%ecx
  801965:	8d 51 20             	lea    0x20(%ecx),%edx
  801968:	39 d0                	cmp    %edx,%eax
  80196a:	73 e2                	jae    80194e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80196c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80196f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801973:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801976:	89 c2                	mov    %eax,%edx
  801978:	c1 fa 1f             	sar    $0x1f,%edx
  80197b:	89 d1                	mov    %edx,%ecx
  80197d:	c1 e9 1b             	shr    $0x1b,%ecx
  801980:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801983:	83 e2 1f             	and    $0x1f,%edx
  801986:	29 ca                	sub    %ecx,%edx
  801988:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80198c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801990:	83 c0 01             	add    $0x1,%eax
  801993:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801996:	83 c7 01             	add    $0x1,%edi
  801999:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80199c:	75 c2                	jne    801960 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80199e:	8b 45 10             	mov    0x10(%ebp),%eax
  8019a1:	eb 05                	jmp    8019a8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019a3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	57                   	push   %edi
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	83 ec 18             	sub    $0x18,%esp
  8019b9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019bc:	57                   	push   %edi
  8019bd:	e8 9c f6 ff ff       	call   80105e <fd2data>
  8019c2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019cc:	eb 3d                	jmp    801a0b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019ce:	85 db                	test   %ebx,%ebx
  8019d0:	74 04                	je     8019d6 <devpipe_read+0x26>
				return i;
  8019d2:	89 d8                	mov    %ebx,%eax
  8019d4:	eb 44                	jmp    801a1a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019d6:	89 f2                	mov    %esi,%edx
  8019d8:	89 f8                	mov    %edi,%eax
  8019da:	e8 e5 fe ff ff       	call   8018c4 <_pipeisclosed>
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	75 32                	jne    801a15 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019e3:	e8 a7 f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019e8:	8b 06                	mov    (%esi),%eax
  8019ea:	3b 46 04             	cmp    0x4(%esi),%eax
  8019ed:	74 df                	je     8019ce <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019ef:	99                   	cltd   
  8019f0:	c1 ea 1b             	shr    $0x1b,%edx
  8019f3:	01 d0                	add    %edx,%eax
  8019f5:	83 e0 1f             	and    $0x1f,%eax
  8019f8:	29 d0                	sub    %edx,%eax
  8019fa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a02:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a05:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a08:	83 c3 01             	add    $0x1,%ebx
  801a0b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a0e:	75 d8                	jne    8019e8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a10:	8b 45 10             	mov    0x10(%ebp),%eax
  801a13:	eb 05                	jmp    801a1a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a15:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5f                   	pop    %edi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2d:	50                   	push   %eax
  801a2e:	e8 42 f6 ff ff       	call   801075 <fd_alloc>
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	89 c2                	mov    %eax,%edx
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	0f 88 2c 01 00 00    	js     801b6c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a40:	83 ec 04             	sub    $0x4,%esp
  801a43:	68 07 04 00 00       	push   $0x407
  801a48:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4b:	6a 00                	push   $0x0
  801a4d:	e8 5c f1 ff ff       	call   800bae <sys_page_alloc>
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	89 c2                	mov    %eax,%edx
  801a57:	85 c0                	test   %eax,%eax
  801a59:	0f 88 0d 01 00 00    	js     801b6c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a65:	50                   	push   %eax
  801a66:	e8 0a f6 ff ff       	call   801075 <fd_alloc>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	85 c0                	test   %eax,%eax
  801a72:	0f 88 e2 00 00 00    	js     801b5a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a78:	83 ec 04             	sub    $0x4,%esp
  801a7b:	68 07 04 00 00       	push   $0x407
  801a80:	ff 75 f0             	pushl  -0x10(%ebp)
  801a83:	6a 00                	push   $0x0
  801a85:	e8 24 f1 ff ff       	call   800bae <sys_page_alloc>
  801a8a:	89 c3                	mov    %eax,%ebx
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	0f 88 c3 00 00 00    	js     801b5a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9d:	e8 bc f5 ff ff       	call   80105e <fd2data>
  801aa2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa4:	83 c4 0c             	add    $0xc,%esp
  801aa7:	68 07 04 00 00       	push   $0x407
  801aac:	50                   	push   %eax
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 fa f0 ff ff       	call   800bae <sys_page_alloc>
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	0f 88 89 00 00 00    	js     801b4a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ac7:	e8 92 f5 ff ff       	call   80105e <fd2data>
  801acc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ad3:	50                   	push   %eax
  801ad4:	6a 00                	push   $0x0
  801ad6:	56                   	push   %esi
  801ad7:	6a 00                	push   $0x0
  801ad9:	e8 13 f1 ff ff       	call   800bf1 <sys_page_map>
  801ade:	89 c3                	mov    %eax,%ebx
  801ae0:	83 c4 20             	add    $0x20,%esp
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	78 55                	js     801b3c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ae7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801afc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b05:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b11:	83 ec 0c             	sub    $0xc,%esp
  801b14:	ff 75 f4             	pushl  -0xc(%ebp)
  801b17:	e8 32 f5 ff ff       	call   80104e <fd2num>
  801b1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b1f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b21:	83 c4 04             	add    $0x4,%esp
  801b24:	ff 75 f0             	pushl  -0x10(%ebp)
  801b27:	e8 22 f5 ff ff       	call   80104e <fd2num>
  801b2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3a:	eb 30                	jmp    801b6c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b3c:	83 ec 08             	sub    $0x8,%esp
  801b3f:	56                   	push   %esi
  801b40:	6a 00                	push   $0x0
  801b42:	e8 ec f0 ff ff       	call   800c33 <sys_page_unmap>
  801b47:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b4a:	83 ec 08             	sub    $0x8,%esp
  801b4d:	ff 75 f0             	pushl  -0x10(%ebp)
  801b50:	6a 00                	push   $0x0
  801b52:	e8 dc f0 ff ff       	call   800c33 <sys_page_unmap>
  801b57:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b5a:	83 ec 08             	sub    $0x8,%esp
  801b5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b60:	6a 00                	push   $0x0
  801b62:	e8 cc f0 ff ff       	call   800c33 <sys_page_unmap>
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b6c:	89 d0                	mov    %edx,%eax
  801b6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7e:	50                   	push   %eax
  801b7f:	ff 75 08             	pushl  0x8(%ebp)
  801b82:	e8 3d f5 ff ff       	call   8010c4 <fd_lookup>
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	78 18                	js     801ba6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	ff 75 f4             	pushl  -0xc(%ebp)
  801b94:	e8 c5 f4 ff ff       	call   80105e <fd2data>
	return _pipeisclosed(fd, p);
  801b99:	89 c2                	mov    %eax,%edx
  801b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9e:	e8 21 fd ff ff       	call   8018c4 <_pipeisclosed>
  801ba3:	83 c4 10             	add    $0x10,%esp
}
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bae:	68 0a 2b 80 00       	push   $0x802b0a
  801bb3:	ff 75 0c             	pushl  0xc(%ebp)
  801bb6:	e8 f0 eb ff ff       	call   8007ab <strcpy>
	return 0;
}
  801bbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    

00801bc2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	53                   	push   %ebx
  801bc6:	83 ec 10             	sub    $0x10,%esp
  801bc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bcc:	53                   	push   %ebx
  801bcd:	e8 1f 07 00 00       	call   8022f1 <pageref>
  801bd2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801bd5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801bda:	83 f8 01             	cmp    $0x1,%eax
  801bdd:	75 10                	jne    801bef <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801bdf:	83 ec 0c             	sub    $0xc,%esp
  801be2:	ff 73 0c             	pushl  0xc(%ebx)
  801be5:	e8 c0 02 00 00       	call   801eaa <nsipc_close>
  801bea:	89 c2                	mov    %eax,%edx
  801bec:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801bef:	89 d0                	mov    %edx,%eax
  801bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801bfc:	6a 00                	push   $0x0
  801bfe:	ff 75 10             	pushl  0x10(%ebp)
  801c01:	ff 75 0c             	pushl  0xc(%ebp)
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	ff 70 0c             	pushl  0xc(%eax)
  801c0a:	e8 78 03 00 00       	call   801f87 <nsipc_send>
}
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    

00801c11 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c17:	6a 00                	push   $0x0
  801c19:	ff 75 10             	pushl  0x10(%ebp)
  801c1c:	ff 75 0c             	pushl  0xc(%ebp)
  801c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c22:	ff 70 0c             	pushl  0xc(%eax)
  801c25:	e8 f1 02 00 00       	call   801f1b <nsipc_recv>
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c32:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c35:	52                   	push   %edx
  801c36:	50                   	push   %eax
  801c37:	e8 88 f4 ff ff       	call   8010c4 <fd_lookup>
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 17                	js     801c5a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c46:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801c4c:	39 08                	cmp    %ecx,(%eax)
  801c4e:	75 05                	jne    801c55 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c50:	8b 40 0c             	mov    0xc(%eax),%eax
  801c53:	eb 05                	jmp    801c5a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c55:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	56                   	push   %esi
  801c60:	53                   	push   %ebx
  801c61:	83 ec 1c             	sub    $0x1c,%esp
  801c64:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c69:	50                   	push   %eax
  801c6a:	e8 06 f4 ff ff       	call   801075 <fd_alloc>
  801c6f:	89 c3                	mov    %eax,%ebx
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 1b                	js     801c93 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c78:	83 ec 04             	sub    $0x4,%esp
  801c7b:	68 07 04 00 00       	push   $0x407
  801c80:	ff 75 f4             	pushl  -0xc(%ebp)
  801c83:	6a 00                	push   $0x0
  801c85:	e8 24 ef ff ff       	call   800bae <sys_page_alloc>
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	79 10                	jns    801ca3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c93:	83 ec 0c             	sub    $0xc,%esp
  801c96:	56                   	push   %esi
  801c97:	e8 0e 02 00 00       	call   801eaa <nsipc_close>
		return r;
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	89 d8                	mov    %ebx,%eax
  801ca1:	eb 24                	jmp    801cc7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ca3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cac:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cb8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801cbb:	83 ec 0c             	sub    $0xc,%esp
  801cbe:	50                   	push   %eax
  801cbf:	e8 8a f3 ff ff       	call   80104e <fd2num>
  801cc4:	83 c4 10             	add    $0x10,%esp
}
  801cc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd7:	e8 50 ff ff ff       	call   801c2c <fd2sockid>
		return r;
  801cdc:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 1f                	js     801d01 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ce2:	83 ec 04             	sub    $0x4,%esp
  801ce5:	ff 75 10             	pushl  0x10(%ebp)
  801ce8:	ff 75 0c             	pushl  0xc(%ebp)
  801ceb:	50                   	push   %eax
  801cec:	e8 12 01 00 00       	call   801e03 <nsipc_accept>
  801cf1:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 07                	js     801d01 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801cfa:	e8 5d ff ff ff       	call   801c5c <alloc_sockfd>
  801cff:	89 c1                	mov    %eax,%ecx
}
  801d01:	89 c8                	mov    %ecx,%eax
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    

00801d05 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0e:	e8 19 ff ff ff       	call   801c2c <fd2sockid>
  801d13:	85 c0                	test   %eax,%eax
  801d15:	78 12                	js     801d29 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	ff 75 10             	pushl  0x10(%ebp)
  801d1d:	ff 75 0c             	pushl  0xc(%ebp)
  801d20:	50                   	push   %eax
  801d21:	e8 2d 01 00 00       	call   801e53 <nsipc_bind>
  801d26:	83 c4 10             	add    $0x10,%esp
}
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <shutdown>:

int
shutdown(int s, int how)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d31:	8b 45 08             	mov    0x8(%ebp),%eax
  801d34:	e8 f3 fe ff ff       	call   801c2c <fd2sockid>
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 0f                	js     801d4c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d3d:	83 ec 08             	sub    $0x8,%esp
  801d40:	ff 75 0c             	pushl  0xc(%ebp)
  801d43:	50                   	push   %eax
  801d44:	e8 3f 01 00 00       	call   801e88 <nsipc_shutdown>
  801d49:	83 c4 10             	add    $0x10,%esp
}
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d54:	8b 45 08             	mov    0x8(%ebp),%eax
  801d57:	e8 d0 fe ff ff       	call   801c2c <fd2sockid>
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	78 12                	js     801d72 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801d60:	83 ec 04             	sub    $0x4,%esp
  801d63:	ff 75 10             	pushl  0x10(%ebp)
  801d66:	ff 75 0c             	pushl  0xc(%ebp)
  801d69:	50                   	push   %eax
  801d6a:	e8 55 01 00 00       	call   801ec4 <nsipc_connect>
  801d6f:	83 c4 10             	add    $0x10,%esp
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <listen>:

int
listen(int s, int backlog)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7d:	e8 aa fe ff ff       	call   801c2c <fd2sockid>
  801d82:	85 c0                	test   %eax,%eax
  801d84:	78 0f                	js     801d95 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d86:	83 ec 08             	sub    $0x8,%esp
  801d89:	ff 75 0c             	pushl  0xc(%ebp)
  801d8c:	50                   	push   %eax
  801d8d:	e8 67 01 00 00       	call   801ef9 <nsipc_listen>
  801d92:	83 c4 10             	add    $0x10,%esp
}
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d9d:	ff 75 10             	pushl  0x10(%ebp)
  801da0:	ff 75 0c             	pushl  0xc(%ebp)
  801da3:	ff 75 08             	pushl  0x8(%ebp)
  801da6:	e8 3a 02 00 00       	call   801fe5 <nsipc_socket>
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	85 c0                	test   %eax,%eax
  801db0:	78 05                	js     801db7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801db2:	e8 a5 fe ff ff       	call   801c5c <alloc_sockfd>
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	53                   	push   %ebx
  801dbd:	83 ec 04             	sub    $0x4,%esp
  801dc0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801dc2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801dc9:	75 12                	jne    801ddd <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801dcb:	83 ec 0c             	sub    $0xc,%esp
  801dce:	6a 02                	push   $0x2
  801dd0:	e8 e3 04 00 00       	call   8022b8 <ipc_find_env>
  801dd5:	a3 04 40 80 00       	mov    %eax,0x804004
  801dda:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ddd:	6a 07                	push   $0x7
  801ddf:	68 00 60 80 00       	push   $0x806000
  801de4:	53                   	push   %ebx
  801de5:	ff 35 04 40 80 00    	pushl  0x804004
  801deb:	e8 74 04 00 00       	call   802264 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801df0:	83 c4 0c             	add    $0xc,%esp
  801df3:	6a 00                	push   $0x0
  801df5:	6a 00                	push   $0x0
  801df7:	6a 00                	push   $0x0
  801df9:	e8 ff 03 00 00       	call   8021fd <ipc_recv>
}
  801dfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e13:	8b 06                	mov    (%esi),%eax
  801e15:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1f:	e8 95 ff ff ff       	call   801db9 <nsipc>
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	85 c0                	test   %eax,%eax
  801e28:	78 20                	js     801e4a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e2a:	83 ec 04             	sub    $0x4,%esp
  801e2d:	ff 35 10 60 80 00    	pushl  0x806010
  801e33:	68 00 60 80 00       	push   $0x806000
  801e38:	ff 75 0c             	pushl  0xc(%ebp)
  801e3b:	e8 fd ea ff ff       	call   80093d <memmove>
		*addrlen = ret->ret_addrlen;
  801e40:	a1 10 60 80 00       	mov    0x806010,%eax
  801e45:	89 06                	mov    %eax,(%esi)
  801e47:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e4a:	89 d8                	mov    %ebx,%eax
  801e4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    

00801e53 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	53                   	push   %ebx
  801e57:	83 ec 08             	sub    $0x8,%esp
  801e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e60:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e65:	53                   	push   %ebx
  801e66:	ff 75 0c             	pushl  0xc(%ebp)
  801e69:	68 04 60 80 00       	push   $0x806004
  801e6e:	e8 ca ea ff ff       	call   80093d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e73:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e79:	b8 02 00 00 00       	mov    $0x2,%eax
  801e7e:	e8 36 ff ff ff       	call   801db9 <nsipc>
}
  801e83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e91:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e99:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e9e:	b8 03 00 00 00       	mov    $0x3,%eax
  801ea3:	e8 11 ff ff ff       	call   801db9 <nsipc>
}
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <nsipc_close>:

int
nsipc_close(int s)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801eb8:	b8 04 00 00 00       	mov    $0x4,%eax
  801ebd:	e8 f7 fe ff ff       	call   801db9 <nsipc>
}
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	53                   	push   %ebx
  801ec8:	83 ec 08             	sub    $0x8,%esp
  801ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ece:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ed6:	53                   	push   %ebx
  801ed7:	ff 75 0c             	pushl  0xc(%ebp)
  801eda:	68 04 60 80 00       	push   $0x806004
  801edf:	e8 59 ea ff ff       	call   80093d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ee4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801eea:	b8 05 00 00 00       	mov    $0x5,%eax
  801eef:	e8 c5 fe ff ff       	call   801db9 <nsipc>
}
  801ef4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef7:	c9                   	leave  
  801ef8:	c3                   	ret    

00801ef9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801eff:	8b 45 08             	mov    0x8(%ebp),%eax
  801f02:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f0f:	b8 06 00 00 00       	mov    $0x6,%eax
  801f14:	e8 a0 fe ff ff       	call   801db9 <nsipc>
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f23:	8b 45 08             	mov    0x8(%ebp),%eax
  801f26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f2b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f31:	8b 45 14             	mov    0x14(%ebp),%eax
  801f34:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f39:	b8 07 00 00 00       	mov    $0x7,%eax
  801f3e:	e8 76 fe ff ff       	call   801db9 <nsipc>
  801f43:	89 c3                	mov    %eax,%ebx
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 35                	js     801f7e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f49:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f4e:	7f 04                	jg     801f54 <nsipc_recv+0x39>
  801f50:	39 c6                	cmp    %eax,%esi
  801f52:	7d 16                	jge    801f6a <nsipc_recv+0x4f>
  801f54:	68 16 2b 80 00       	push   $0x802b16
  801f59:	68 bf 2a 80 00       	push   $0x802abf
  801f5e:	6a 62                	push   $0x62
  801f60:	68 2b 2b 80 00       	push   $0x802b2b
  801f65:	e8 e3 e1 ff ff       	call   80014d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f6a:	83 ec 04             	sub    $0x4,%esp
  801f6d:	50                   	push   %eax
  801f6e:	68 00 60 80 00       	push   $0x806000
  801f73:	ff 75 0c             	pushl  0xc(%ebp)
  801f76:	e8 c2 e9 ff ff       	call   80093d <memmove>
  801f7b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f7e:	89 d8                	mov    %ebx,%eax
  801f80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5d                   	pop    %ebp
  801f86:	c3                   	ret    

00801f87 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	53                   	push   %ebx
  801f8b:	83 ec 04             	sub    $0x4,%esp
  801f8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f91:	8b 45 08             	mov    0x8(%ebp),%eax
  801f94:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f99:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f9f:	7e 16                	jle    801fb7 <nsipc_send+0x30>
  801fa1:	68 37 2b 80 00       	push   $0x802b37
  801fa6:	68 bf 2a 80 00       	push   $0x802abf
  801fab:	6a 6d                	push   $0x6d
  801fad:	68 2b 2b 80 00       	push   $0x802b2b
  801fb2:	e8 96 e1 ff ff       	call   80014d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fb7:	83 ec 04             	sub    $0x4,%esp
  801fba:	53                   	push   %ebx
  801fbb:	ff 75 0c             	pushl  0xc(%ebp)
  801fbe:	68 0c 60 80 00       	push   $0x80600c
  801fc3:	e8 75 e9 ff ff       	call   80093d <memmove>
	nsipcbuf.send.req_size = size;
  801fc8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fce:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fd6:	b8 08 00 00 00       	mov    $0x8,%eax
  801fdb:	e8 d9 fd ff ff       	call   801db9 <nsipc>
}
  801fe0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    

00801fe5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801feb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ffb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ffe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802003:	b8 09 00 00 00       	mov    $0x9,%eax
  802008:	e8 ac fd ff ff       	call   801db9 <nsipc>
}
  80200d:	c9                   	leave  
  80200e:	c3                   	ret    

0080200f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802012:	b8 00 00 00 00       	mov    $0x0,%eax
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80201f:	68 43 2b 80 00       	push   $0x802b43
  802024:	ff 75 0c             	pushl  0xc(%ebp)
  802027:	e8 7f e7 ff ff       	call   8007ab <strcpy>
	return 0;
}
  80202c:	b8 00 00 00 00       	mov    $0x0,%eax
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	57                   	push   %edi
  802037:	56                   	push   %esi
  802038:	53                   	push   %ebx
  802039:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80203f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802044:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80204a:	eb 2d                	jmp    802079 <devcons_write+0x46>
		m = n - tot;
  80204c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80204f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802051:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802054:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802059:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80205c:	83 ec 04             	sub    $0x4,%esp
  80205f:	53                   	push   %ebx
  802060:	03 45 0c             	add    0xc(%ebp),%eax
  802063:	50                   	push   %eax
  802064:	57                   	push   %edi
  802065:	e8 d3 e8 ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  80206a:	83 c4 08             	add    $0x8,%esp
  80206d:	53                   	push   %ebx
  80206e:	57                   	push   %edi
  80206f:	e8 7e ea ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802074:	01 de                	add    %ebx,%esi
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	89 f0                	mov    %esi,%eax
  80207b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80207e:	72 cc                	jb     80204c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    

00802088 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	83 ec 08             	sub    $0x8,%esp
  80208e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802093:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802097:	74 2a                	je     8020c3 <devcons_read+0x3b>
  802099:	eb 05                	jmp    8020a0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80209b:	e8 ef ea ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020a0:	e8 6b ea ff ff       	call   800b10 <sys_cgetc>
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	74 f2                	je     80209b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	78 16                	js     8020c3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020ad:	83 f8 04             	cmp    $0x4,%eax
  8020b0:	74 0c                	je     8020be <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b5:	88 02                	mov    %al,(%edx)
	return 1;
  8020b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bc:	eb 05                	jmp    8020c3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020be:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020c3:	c9                   	leave  
  8020c4:	c3                   	ret    

008020c5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ce:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020d1:	6a 01                	push   $0x1
  8020d3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d6:	50                   	push   %eax
  8020d7:	e8 16 ea ff ff       	call   800af2 <sys_cputs>
}
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	c9                   	leave  
  8020e0:	c3                   	ret    

008020e1 <getchar>:

int
getchar(void)
{
  8020e1:	55                   	push   %ebp
  8020e2:	89 e5                	mov    %esp,%ebp
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020e7:	6a 01                	push   $0x1
  8020e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ec:	50                   	push   %eax
  8020ed:	6a 00                	push   $0x0
  8020ef:	e8 36 f2 ff ff       	call   80132a <read>
	if (r < 0)
  8020f4:	83 c4 10             	add    $0x10,%esp
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	78 0f                	js     80210a <getchar+0x29>
		return r;
	if (r < 1)
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	7e 06                	jle    802105 <getchar+0x24>
		return -E_EOF;
	return c;
  8020ff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802103:	eb 05                	jmp    80210a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802105:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802115:	50                   	push   %eax
  802116:	ff 75 08             	pushl  0x8(%ebp)
  802119:	e8 a6 ef ff ff       	call   8010c4 <fd_lookup>
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	85 c0                	test   %eax,%eax
  802123:	78 11                	js     802136 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802125:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802128:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80212e:	39 10                	cmp    %edx,(%eax)
  802130:	0f 94 c0             	sete   %al
  802133:	0f b6 c0             	movzbl %al,%eax
}
  802136:	c9                   	leave  
  802137:	c3                   	ret    

00802138 <opencons>:

int
opencons(void)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80213e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802141:	50                   	push   %eax
  802142:	e8 2e ef ff ff       	call   801075 <fd_alloc>
  802147:	83 c4 10             	add    $0x10,%esp
		return r;
  80214a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80214c:	85 c0                	test   %eax,%eax
  80214e:	78 3e                	js     80218e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802150:	83 ec 04             	sub    $0x4,%esp
  802153:	68 07 04 00 00       	push   $0x407
  802158:	ff 75 f4             	pushl  -0xc(%ebp)
  80215b:	6a 00                	push   $0x0
  80215d:	e8 4c ea ff ff       	call   800bae <sys_page_alloc>
  802162:	83 c4 10             	add    $0x10,%esp
		return r;
  802165:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802167:	85 c0                	test   %eax,%eax
  802169:	78 23                	js     80218e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80216b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802171:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802174:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802176:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802179:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802180:	83 ec 0c             	sub    $0xc,%esp
  802183:	50                   	push   %eax
  802184:	e8 c5 ee ff ff       	call   80104e <fd2num>
  802189:	89 c2                	mov    %eax,%edx
  80218b:	83 c4 10             	add    $0x10,%esp
}
  80218e:	89 d0                	mov    %edx,%eax
  802190:	c9                   	leave  
  802191:	c3                   	ret    

00802192 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802198:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80219f:	75 2e                	jne    8021cf <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8021a1:	e8 ca e9 ff ff       	call   800b70 <sys_getenvid>
  8021a6:	83 ec 04             	sub    $0x4,%esp
  8021a9:	68 07 0e 00 00       	push   $0xe07
  8021ae:	68 00 f0 bf ee       	push   $0xeebff000
  8021b3:	50                   	push   %eax
  8021b4:	e8 f5 e9 ff ff       	call   800bae <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8021b9:	e8 b2 e9 ff ff       	call   800b70 <sys_getenvid>
  8021be:	83 c4 08             	add    $0x8,%esp
  8021c1:	68 d9 21 80 00       	push   $0x8021d9
  8021c6:	50                   	push   %eax
  8021c7:	e8 2d eb ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
  8021cc:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d2:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8021d7:	c9                   	leave  
  8021d8:	c3                   	ret    

008021d9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021d9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021da:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8021df:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021e1:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8021e4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8021e8:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8021ec:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8021ef:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8021f2:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8021f3:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8021f6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8021f7:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8021f8:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8021fc:	c3                   	ret    

008021fd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	56                   	push   %esi
  802201:	53                   	push   %ebx
  802202:	8b 75 08             	mov    0x8(%ebp),%esi
  802205:	8b 45 0c             	mov    0xc(%ebp),%eax
  802208:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80220b:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80220d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802212:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802215:	83 ec 0c             	sub    $0xc,%esp
  802218:	50                   	push   %eax
  802219:	e8 40 eb ff ff       	call   800d5e <sys_ipc_recv>

	if (from_env_store != NULL)
  80221e:	83 c4 10             	add    $0x10,%esp
  802221:	85 f6                	test   %esi,%esi
  802223:	74 14                	je     802239 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802225:	ba 00 00 00 00       	mov    $0x0,%edx
  80222a:	85 c0                	test   %eax,%eax
  80222c:	78 09                	js     802237 <ipc_recv+0x3a>
  80222e:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  802234:	8b 52 74             	mov    0x74(%edx),%edx
  802237:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802239:	85 db                	test   %ebx,%ebx
  80223b:	74 14                	je     802251 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80223d:	ba 00 00 00 00       	mov    $0x0,%edx
  802242:	85 c0                	test   %eax,%eax
  802244:	78 09                	js     80224f <ipc_recv+0x52>
  802246:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  80224c:	8b 52 78             	mov    0x78(%edx),%edx
  80224f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802251:	85 c0                	test   %eax,%eax
  802253:	78 08                	js     80225d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802255:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80225a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80225d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802260:	5b                   	pop    %ebx
  802261:	5e                   	pop    %esi
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    

00802264 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802264:	55                   	push   %ebp
  802265:	89 e5                	mov    %esp,%ebp
  802267:	57                   	push   %edi
  802268:	56                   	push   %esi
  802269:	53                   	push   %ebx
  80226a:	83 ec 0c             	sub    $0xc,%esp
  80226d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802270:	8b 75 0c             	mov    0xc(%ebp),%esi
  802273:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802276:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802278:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80227d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802280:	ff 75 14             	pushl  0x14(%ebp)
  802283:	53                   	push   %ebx
  802284:	56                   	push   %esi
  802285:	57                   	push   %edi
  802286:	e8 b0 ea ff ff       	call   800d3b <sys_ipc_try_send>

		if (err < 0) {
  80228b:	83 c4 10             	add    $0x10,%esp
  80228e:	85 c0                	test   %eax,%eax
  802290:	79 1e                	jns    8022b0 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802292:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802295:	75 07                	jne    80229e <ipc_send+0x3a>
				sys_yield();
  802297:	e8 f3 e8 ff ff       	call   800b8f <sys_yield>
  80229c:	eb e2                	jmp    802280 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80229e:	50                   	push   %eax
  80229f:	68 4f 2b 80 00       	push   $0x802b4f
  8022a4:	6a 49                	push   $0x49
  8022a6:	68 5c 2b 80 00       	push   $0x802b5c
  8022ab:	e8 9d de ff ff       	call   80014d <_panic>
		}

	} while (err < 0);

}
  8022b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    

008022b8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022be:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022c3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022c6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022cc:	8b 52 50             	mov    0x50(%edx),%edx
  8022cf:	39 ca                	cmp    %ecx,%edx
  8022d1:	75 0d                	jne    8022e0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8022d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022db:	8b 40 48             	mov    0x48(%eax),%eax
  8022de:	eb 0f                	jmp    8022ef <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022e0:	83 c0 01             	add    $0x1,%eax
  8022e3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022e8:	75 d9                	jne    8022c3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022ef:	5d                   	pop    %ebp
  8022f0:	c3                   	ret    

008022f1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022f1:	55                   	push   %ebp
  8022f2:	89 e5                	mov    %esp,%ebp
  8022f4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022f7:	89 d0                	mov    %edx,%eax
  8022f9:	c1 e8 16             	shr    $0x16,%eax
  8022fc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802303:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802308:	f6 c1 01             	test   $0x1,%cl
  80230b:	74 1d                	je     80232a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80230d:	c1 ea 0c             	shr    $0xc,%edx
  802310:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802317:	f6 c2 01             	test   $0x1,%dl
  80231a:	74 0e                	je     80232a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80231c:	c1 ea 0c             	shr    $0xc,%edx
  80231f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802326:	ef 
  802327:	0f b7 c0             	movzwl %ax,%eax
}
  80232a:	5d                   	pop    %ebp
  80232b:	c3                   	ret    
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__udivdi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80233b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80233f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 f6                	test   %esi,%esi
  802349:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80234d:	89 ca                	mov    %ecx,%edx
  80234f:	89 f8                	mov    %edi,%eax
  802351:	75 3d                	jne    802390 <__udivdi3+0x60>
  802353:	39 cf                	cmp    %ecx,%edi
  802355:	0f 87 c5 00 00 00    	ja     802420 <__udivdi3+0xf0>
  80235b:	85 ff                	test   %edi,%edi
  80235d:	89 fd                	mov    %edi,%ebp
  80235f:	75 0b                	jne    80236c <__udivdi3+0x3c>
  802361:	b8 01 00 00 00       	mov    $0x1,%eax
  802366:	31 d2                	xor    %edx,%edx
  802368:	f7 f7                	div    %edi
  80236a:	89 c5                	mov    %eax,%ebp
  80236c:	89 c8                	mov    %ecx,%eax
  80236e:	31 d2                	xor    %edx,%edx
  802370:	f7 f5                	div    %ebp
  802372:	89 c1                	mov    %eax,%ecx
  802374:	89 d8                	mov    %ebx,%eax
  802376:	89 cf                	mov    %ecx,%edi
  802378:	f7 f5                	div    %ebp
  80237a:	89 c3                	mov    %eax,%ebx
  80237c:	89 d8                	mov    %ebx,%eax
  80237e:	89 fa                	mov    %edi,%edx
  802380:	83 c4 1c             	add    $0x1c,%esp
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5f                   	pop    %edi
  802386:	5d                   	pop    %ebp
  802387:	c3                   	ret    
  802388:	90                   	nop
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	39 ce                	cmp    %ecx,%esi
  802392:	77 74                	ja     802408 <__udivdi3+0xd8>
  802394:	0f bd fe             	bsr    %esi,%edi
  802397:	83 f7 1f             	xor    $0x1f,%edi
  80239a:	0f 84 98 00 00 00    	je     802438 <__udivdi3+0x108>
  8023a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023a5:	89 f9                	mov    %edi,%ecx
  8023a7:	89 c5                	mov    %eax,%ebp
  8023a9:	29 fb                	sub    %edi,%ebx
  8023ab:	d3 e6                	shl    %cl,%esi
  8023ad:	89 d9                	mov    %ebx,%ecx
  8023af:	d3 ed                	shr    %cl,%ebp
  8023b1:	89 f9                	mov    %edi,%ecx
  8023b3:	d3 e0                	shl    %cl,%eax
  8023b5:	09 ee                	or     %ebp,%esi
  8023b7:	89 d9                	mov    %ebx,%ecx
  8023b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bd:	89 d5                	mov    %edx,%ebp
  8023bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023c3:	d3 ed                	shr    %cl,%ebp
  8023c5:	89 f9                	mov    %edi,%ecx
  8023c7:	d3 e2                	shl    %cl,%edx
  8023c9:	89 d9                	mov    %ebx,%ecx
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	09 c2                	or     %eax,%edx
  8023cf:	89 d0                	mov    %edx,%eax
  8023d1:	89 ea                	mov    %ebp,%edx
  8023d3:	f7 f6                	div    %esi
  8023d5:	89 d5                	mov    %edx,%ebp
  8023d7:	89 c3                	mov    %eax,%ebx
  8023d9:	f7 64 24 0c          	mull   0xc(%esp)
  8023dd:	39 d5                	cmp    %edx,%ebp
  8023df:	72 10                	jb     8023f1 <__udivdi3+0xc1>
  8023e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023e5:	89 f9                	mov    %edi,%ecx
  8023e7:	d3 e6                	shl    %cl,%esi
  8023e9:	39 c6                	cmp    %eax,%esi
  8023eb:	73 07                	jae    8023f4 <__udivdi3+0xc4>
  8023ed:	39 d5                	cmp    %edx,%ebp
  8023ef:	75 03                	jne    8023f4 <__udivdi3+0xc4>
  8023f1:	83 eb 01             	sub    $0x1,%ebx
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 d8                	mov    %ebx,%eax
  8023f8:	89 fa                	mov    %edi,%edx
  8023fa:	83 c4 1c             	add    $0x1c,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5f                   	pop    %edi
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    
  802402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802408:	31 ff                	xor    %edi,%edi
  80240a:	31 db                	xor    %ebx,%ebx
  80240c:	89 d8                	mov    %ebx,%eax
  80240e:	89 fa                	mov    %edi,%edx
  802410:	83 c4 1c             	add    $0x1c,%esp
  802413:	5b                   	pop    %ebx
  802414:	5e                   	pop    %esi
  802415:	5f                   	pop    %edi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    
  802418:	90                   	nop
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	89 d8                	mov    %ebx,%eax
  802422:	f7 f7                	div    %edi
  802424:	31 ff                	xor    %edi,%edi
  802426:	89 c3                	mov    %eax,%ebx
  802428:	89 d8                	mov    %ebx,%eax
  80242a:	89 fa                	mov    %edi,%edx
  80242c:	83 c4 1c             	add    $0x1c,%esp
  80242f:	5b                   	pop    %ebx
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
  802434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802438:	39 ce                	cmp    %ecx,%esi
  80243a:	72 0c                	jb     802448 <__udivdi3+0x118>
  80243c:	31 db                	xor    %ebx,%ebx
  80243e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802442:	0f 87 34 ff ff ff    	ja     80237c <__udivdi3+0x4c>
  802448:	bb 01 00 00 00       	mov    $0x1,%ebx
  80244d:	e9 2a ff ff ff       	jmp    80237c <__udivdi3+0x4c>
  802452:	66 90                	xchg   %ax,%ax
  802454:	66 90                	xchg   %ax,%ax
  802456:	66 90                	xchg   %ax,%ax
  802458:	66 90                	xchg   %ax,%ax
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__umoddi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	83 ec 1c             	sub    $0x1c,%esp
  802467:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80246b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80246f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802473:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802477:	85 d2                	test   %edx,%edx
  802479:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80247d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802481:	89 f3                	mov    %esi,%ebx
  802483:	89 3c 24             	mov    %edi,(%esp)
  802486:	89 74 24 04          	mov    %esi,0x4(%esp)
  80248a:	75 1c                	jne    8024a8 <__umoddi3+0x48>
  80248c:	39 f7                	cmp    %esi,%edi
  80248e:	76 50                	jbe    8024e0 <__umoddi3+0x80>
  802490:	89 c8                	mov    %ecx,%eax
  802492:	89 f2                	mov    %esi,%edx
  802494:	f7 f7                	div    %edi
  802496:	89 d0                	mov    %edx,%eax
  802498:	31 d2                	xor    %edx,%edx
  80249a:	83 c4 1c             	add    $0x1c,%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5e                   	pop    %esi
  80249f:	5f                   	pop    %edi
  8024a0:	5d                   	pop    %ebp
  8024a1:	c3                   	ret    
  8024a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024a8:	39 f2                	cmp    %esi,%edx
  8024aa:	89 d0                	mov    %edx,%eax
  8024ac:	77 52                	ja     802500 <__umoddi3+0xa0>
  8024ae:	0f bd ea             	bsr    %edx,%ebp
  8024b1:	83 f5 1f             	xor    $0x1f,%ebp
  8024b4:	75 5a                	jne    802510 <__umoddi3+0xb0>
  8024b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ba:	0f 82 e0 00 00 00    	jb     8025a0 <__umoddi3+0x140>
  8024c0:	39 0c 24             	cmp    %ecx,(%esp)
  8024c3:	0f 86 d7 00 00 00    	jbe    8025a0 <__umoddi3+0x140>
  8024c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024d1:	83 c4 1c             	add    $0x1c,%esp
  8024d4:	5b                   	pop    %ebx
  8024d5:	5e                   	pop    %esi
  8024d6:	5f                   	pop    %edi
  8024d7:	5d                   	pop    %ebp
  8024d8:	c3                   	ret    
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	85 ff                	test   %edi,%edi
  8024e2:	89 fd                	mov    %edi,%ebp
  8024e4:	75 0b                	jne    8024f1 <__umoddi3+0x91>
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	f7 f7                	div    %edi
  8024ef:	89 c5                	mov    %eax,%ebp
  8024f1:	89 f0                	mov    %esi,%eax
  8024f3:	31 d2                	xor    %edx,%edx
  8024f5:	f7 f5                	div    %ebp
  8024f7:	89 c8                	mov    %ecx,%eax
  8024f9:	f7 f5                	div    %ebp
  8024fb:	89 d0                	mov    %edx,%eax
  8024fd:	eb 99                	jmp    802498 <__umoddi3+0x38>
  8024ff:	90                   	nop
  802500:	89 c8                	mov    %ecx,%eax
  802502:	89 f2                	mov    %esi,%edx
  802504:	83 c4 1c             	add    $0x1c,%esp
  802507:	5b                   	pop    %ebx
  802508:	5e                   	pop    %esi
  802509:	5f                   	pop    %edi
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    
  80250c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802510:	8b 34 24             	mov    (%esp),%esi
  802513:	bf 20 00 00 00       	mov    $0x20,%edi
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	29 ef                	sub    %ebp,%edi
  80251c:	d3 e0                	shl    %cl,%eax
  80251e:	89 f9                	mov    %edi,%ecx
  802520:	89 f2                	mov    %esi,%edx
  802522:	d3 ea                	shr    %cl,%edx
  802524:	89 e9                	mov    %ebp,%ecx
  802526:	09 c2                	or     %eax,%edx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 14 24             	mov    %edx,(%esp)
  80252d:	89 f2                	mov    %esi,%edx
  80252f:	d3 e2                	shl    %cl,%edx
  802531:	89 f9                	mov    %edi,%ecx
  802533:	89 54 24 04          	mov    %edx,0x4(%esp)
  802537:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80253b:	d3 e8                	shr    %cl,%eax
  80253d:	89 e9                	mov    %ebp,%ecx
  80253f:	89 c6                	mov    %eax,%esi
  802541:	d3 e3                	shl    %cl,%ebx
  802543:	89 f9                	mov    %edi,%ecx
  802545:	89 d0                	mov    %edx,%eax
  802547:	d3 e8                	shr    %cl,%eax
  802549:	89 e9                	mov    %ebp,%ecx
  80254b:	09 d8                	or     %ebx,%eax
  80254d:	89 d3                	mov    %edx,%ebx
  80254f:	89 f2                	mov    %esi,%edx
  802551:	f7 34 24             	divl   (%esp)
  802554:	89 d6                	mov    %edx,%esi
  802556:	d3 e3                	shl    %cl,%ebx
  802558:	f7 64 24 04          	mull   0x4(%esp)
  80255c:	39 d6                	cmp    %edx,%esi
  80255e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802562:	89 d1                	mov    %edx,%ecx
  802564:	89 c3                	mov    %eax,%ebx
  802566:	72 08                	jb     802570 <__umoddi3+0x110>
  802568:	75 11                	jne    80257b <__umoddi3+0x11b>
  80256a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80256e:	73 0b                	jae    80257b <__umoddi3+0x11b>
  802570:	2b 44 24 04          	sub    0x4(%esp),%eax
  802574:	1b 14 24             	sbb    (%esp),%edx
  802577:	89 d1                	mov    %edx,%ecx
  802579:	89 c3                	mov    %eax,%ebx
  80257b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80257f:	29 da                	sub    %ebx,%edx
  802581:	19 ce                	sbb    %ecx,%esi
  802583:	89 f9                	mov    %edi,%ecx
  802585:	89 f0                	mov    %esi,%eax
  802587:	d3 e0                	shl    %cl,%eax
  802589:	89 e9                	mov    %ebp,%ecx
  80258b:	d3 ea                	shr    %cl,%edx
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	d3 ee                	shr    %cl,%esi
  802591:	09 d0                	or     %edx,%eax
  802593:	89 f2                	mov    %esi,%edx
  802595:	83 c4 1c             	add    $0x1c,%esp
  802598:	5b                   	pop    %ebx
  802599:	5e                   	pop    %esi
  80259a:	5f                   	pop    %edi
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    
  80259d:	8d 76 00             	lea    0x0(%esi),%esi
  8025a0:	29 f9                	sub    %edi,%ecx
  8025a2:	19 d6                	sbb    %edx,%esi
  8025a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025ac:	e9 18 ff ff ff       	jmp    8024c9 <__umoddi3+0x69>
