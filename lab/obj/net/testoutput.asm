
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 9b 01 00 00       	call   8001cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 12 0c 00 00       	call   800c4f <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 30 80 00 a0 	movl   $0x8026a0,0x803000
  800046:	26 80 00 

	output_envid = fork();
  800049:	e8 28 0f 00 00       	call   800f76 <fork>
  80004e:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	79 14                	jns    80006b <umain+0x38>
		panic("error forking");
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	68 ab 26 80 00       	push   $0x8026ab
  80005f:	6a 16                	push   $0x16
  800061:	68 b9 26 80 00       	push   $0x8026b9
  800066:	e8 c1 01 00 00       	call   80022c <_panic>
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <umain+0x52>
		output(ns_envid);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	56                   	push   %esi
  800078:	e8 40 01 00 00       	call   8001bd <output>
		return;
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	e9 8f 00 00 00       	jmp    800114 <umain+0xe1>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 07                	push   $0x7
  80008a:	68 00 b0 fe 0f       	push   $0xffeb000
  80008f:	6a 00                	push   $0x0
  800091:	e8 f7 0b 00 00       	call   800c8d <sys_page_alloc>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x7c>
			panic("sys_page_alloc: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 ca 26 80 00       	push   $0x8026ca
  8000a3:	6a 1e                	push   $0x1e
  8000a5:	68 b9 26 80 00       	push   $0x8026b9
  8000aa:	e8 7d 01 00 00       	call   80022c <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000af:	53                   	push   %ebx
  8000b0:	68 dd 26 80 00       	push   $0x8026dd
  8000b5:	68 fc 0f 00 00       	push   $0xffc
  8000ba:	68 04 b0 fe 0f       	push   $0xffeb004
  8000bf:	e8 73 07 00 00       	call   800837 <snprintf>
  8000c4:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000c9:	83 c4 08             	add    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	68 e9 26 80 00       	push   $0x8026e9
  8000d2:	e8 2e 02 00 00       	call   800305 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000d7:	6a 07                	push   $0x7
  8000d9:	68 00 b0 fe 0f       	push   $0xffeb000
  8000de:	6a 0b                	push   $0xb
  8000e0:	ff 35 00 40 80 00    	pushl  0x804000
  8000e6:	e8 a9 10 00 00       	call   801194 <ipc_send>
		sys_page_unmap(0, pkt);
  8000eb:	83 c4 18             	add    $0x18,%esp
  8000ee:	68 00 b0 fe 0f       	push   $0xffeb000
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 18 0c 00 00       	call   800d12 <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000fa:	83 c3 01             	add    $0x1,%ebx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	83 fb 0a             	cmp    $0xa,%ebx
  800103:	75 80                	jne    800085 <umain+0x52>
  800105:	bb 14 00 00 00       	mov    $0x14,%ebx
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80010a:	e8 5f 0b 00 00       	call   800c6e <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80010f:	83 eb 01             	sub    $0x1,%ebx
  800112:	75 f6                	jne    80010a <umain+0xd7>
		sys_yield();
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 1c             	sub    $0x1c,%esp
  800124:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800127:	e8 52 0d 00 00       	call   800e7e <sys_time_msec>
  80012c:	03 45 0c             	add    0xc(%ebp),%eax
  80012f:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800131:	c7 05 00 30 80 00 01 	movl   $0x802701,0x803000
  800138:	27 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80013b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80013e:	eb 05                	jmp    800145 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800140:	e8 29 0b 00 00       	call   800c6e <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800145:	e8 34 0d 00 00       	call   800e7e <sys_time_msec>
  80014a:	89 c2                	mov    %eax,%edx
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 04                	js     800154 <timer+0x39>
  800150:	39 c3                	cmp    %eax,%ebx
  800152:	77 ec                	ja     800140 <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  800154:	85 c0                	test   %eax,%eax
  800156:	79 12                	jns    80016a <timer+0x4f>
			panic("sys_time_msec: %e", r);
  800158:	52                   	push   %edx
  800159:	68 0a 27 80 00       	push   $0x80270a
  80015e:	6a 0f                	push   $0xf
  800160:	68 1c 27 80 00       	push   $0x80271c
  800165:	e8 c2 00 00 00       	call   80022c <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 0c                	push   $0xc
  800170:	56                   	push   %esi
  800171:	e8 1e 10 00 00       	call   801194 <ipc_send>
  800176:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	57                   	push   %edi
  800181:	e8 a7 0f 00 00       	call   80112d <ipc_recv>
  800186:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	39 f0                	cmp    %esi,%eax
  800190:	74 13                	je     8001a5 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	50                   	push   %eax
  800196:	68 28 27 80 00       	push   $0x802728
  80019b:	e8 65 01 00 00       	call   800305 <cprintf>
				continue;
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	eb d4                	jmp    800179 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  8001a5:	e8 d4 0c 00 00       	call   800e7e <sys_time_msec>
  8001aa:	01 c3                	add    %eax,%ebx
  8001ac:	eb 97                	jmp    800145 <timer+0x2a>

008001ae <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  8001b1:	c7 05 00 30 80 00 63 	movl   $0x802763,0x803000
  8001b8:	27 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  8001c0:	c7 05 00 30 80 00 6c 	movl   $0x80276c,0x803000
  8001c7:	27 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001d7:	e8 73 0a 00 00       	call   800c4f <sys_getenvid>
  8001dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7e 07                	jle    8001f9 <libmain+0x2d>
		binaryname = argv[0];
  8001f2:	8b 06                	mov    (%esi),%eax
  8001f4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	e8 30 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800203:	e8 0a 00 00 00       	call   800212 <exit>
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800218:	e8 cf 11 00 00       	call   8013ec <close_all>
	sys_env_destroy(0);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	6a 00                	push   $0x0
  800222:	e8 e7 09 00 00       	call   800c0e <sys_env_destroy>
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800231:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800234:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023a:	e8 10 0a 00 00       	call   800c4f <sys_getenvid>
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	56                   	push   %esi
  800249:	50                   	push   %eax
  80024a:	68 80 27 80 00       	push   $0x802780
  80024f:	e8 b1 00 00 00       	call   800305 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800254:	83 c4 18             	add    $0x18,%esp
  800257:	53                   	push   %ebx
  800258:	ff 75 10             	pushl  0x10(%ebp)
  80025b:	e8 54 00 00 00       	call   8002b4 <vcprintf>
	cprintf("\n");
  800260:	c7 04 24 ff 26 80 00 	movl   $0x8026ff,(%esp)
  800267:	e8 99 00 00 00       	call   800305 <cprintf>
  80026c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026f:	cc                   	int3   
  800270:	eb fd                	jmp    80026f <_panic+0x43>

00800272 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	53                   	push   %ebx
  800276:	83 ec 04             	sub    $0x4,%esp
  800279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027c:	8b 13                	mov    (%ebx),%edx
  80027e:	8d 42 01             	lea    0x1(%edx),%eax
  800281:	89 03                	mov    %eax,(%ebx)
  800283:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800286:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028f:	75 1a                	jne    8002ab <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	68 ff 00 00 00       	push   $0xff
  800299:	8d 43 08             	lea    0x8(%ebx),%eax
  80029c:	50                   	push   %eax
  80029d:	e8 2f 09 00 00       	call   800bd1 <sys_cputs>
		b->idx = 0;
  8002a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c4:	00 00 00 
	b.cnt = 0;
  8002c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d1:	ff 75 0c             	pushl  0xc(%ebp)
  8002d4:	ff 75 08             	pushl  0x8(%ebp)
  8002d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002dd:	50                   	push   %eax
  8002de:	68 72 02 80 00       	push   $0x800272
  8002e3:	e8 54 01 00 00       	call   80043c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e8:	83 c4 08             	add    $0x8,%esp
  8002eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f7:	50                   	push   %eax
  8002f8:	e8 d4 08 00 00       	call   800bd1 <sys_cputs>

	return b.cnt;
}
  8002fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030e:	50                   	push   %eax
  80030f:	ff 75 08             	pushl  0x8(%ebp)
  800312:	e8 9d ff ff ff       	call   8002b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 1c             	sub    $0x1c,%esp
  800322:	89 c7                	mov    %eax,%edi
  800324:	89 d6                	mov    %edx,%esi
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800332:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800335:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80033d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800340:	39 d3                	cmp    %edx,%ebx
  800342:	72 05                	jb     800349 <printnum+0x30>
  800344:	39 45 10             	cmp    %eax,0x10(%ebp)
  800347:	77 45                	ja     80038e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 18             	pushl  0x18(%ebp)
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800355:	53                   	push   %ebx
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035f:	ff 75 e0             	pushl  -0x20(%ebp)
  800362:	ff 75 dc             	pushl  -0x24(%ebp)
  800365:	ff 75 d8             	pushl  -0x28(%ebp)
  800368:	e8 a3 20 00 00       	call   802410 <__udivdi3>
  80036d:	83 c4 18             	add    $0x18,%esp
  800370:	52                   	push   %edx
  800371:	50                   	push   %eax
  800372:	89 f2                	mov    %esi,%edx
  800374:	89 f8                	mov    %edi,%eax
  800376:	e8 9e ff ff ff       	call   800319 <printnum>
  80037b:	83 c4 20             	add    $0x20,%esp
  80037e:	eb 18                	jmp    800398 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	56                   	push   %esi
  800384:	ff 75 18             	pushl  0x18(%ebp)
  800387:	ff d7                	call   *%edi
  800389:	83 c4 10             	add    $0x10,%esp
  80038c:	eb 03                	jmp    800391 <printnum+0x78>
  80038e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800391:	83 eb 01             	sub    $0x1,%ebx
  800394:	85 db                	test   %ebx,%ebx
  800396:	7f e8                	jg     800380 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	83 ec 04             	sub    $0x4,%esp
  80039f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ab:	e8 90 21 00 00       	call   802540 <__umoddi3>
  8003b0:	83 c4 14             	add    $0x14,%esp
  8003b3:	0f be 80 a3 27 80 00 	movsbl 0x8027a3(%eax),%eax
  8003ba:	50                   	push   %eax
  8003bb:	ff d7                	call   *%edi
}
  8003bd:	83 c4 10             	add    $0x10,%esp
  8003c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c3:	5b                   	pop    %ebx
  8003c4:	5e                   	pop    %esi
  8003c5:	5f                   	pop    %edi
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cb:	83 fa 01             	cmp    $0x1,%edx
  8003ce:	7e 0e                	jle    8003de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	8b 52 04             	mov    0x4(%edx),%edx
  8003dc:	eb 22                	jmp    800400 <getuint+0x38>
	else if (lflag)
  8003de:	85 d2                	test   %edx,%edx
  8003e0:	74 10                	je     8003f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e7:	89 08                	mov    %ecx,(%eax)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	eb 0e                	jmp    800400 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f7:	89 08                	mov    %ecx,(%eax)
  8003f9:	8b 02                	mov    (%edx),%eax
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800408:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040c:	8b 10                	mov    (%eax),%edx
  80040e:	3b 50 04             	cmp    0x4(%eax),%edx
  800411:	73 0a                	jae    80041d <sprintputch+0x1b>
		*b->buf++ = ch;
  800413:	8d 4a 01             	lea    0x1(%edx),%ecx
  800416:	89 08                	mov    %ecx,(%eax)
  800418:	8b 45 08             	mov    0x8(%ebp),%eax
  80041b:	88 02                	mov    %al,(%edx)
}
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800425:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800428:	50                   	push   %eax
  800429:	ff 75 10             	pushl  0x10(%ebp)
  80042c:	ff 75 0c             	pushl  0xc(%ebp)
  80042f:	ff 75 08             	pushl  0x8(%ebp)
  800432:	e8 05 00 00 00       	call   80043c <vprintfmt>
	va_end(ap);
}
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	c9                   	leave  
  80043b:	c3                   	ret    

0080043c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
  800442:	83 ec 2c             	sub    $0x2c,%esp
  800445:	8b 75 08             	mov    0x8(%ebp),%esi
  800448:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80044e:	eb 12                	jmp    800462 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800450:	85 c0                	test   %eax,%eax
  800452:	0f 84 89 03 00 00    	je     8007e1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	53                   	push   %ebx
  80045c:	50                   	push   %eax
  80045d:	ff d6                	call   *%esi
  80045f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800462:	83 c7 01             	add    $0x1,%edi
  800465:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800469:	83 f8 25             	cmp    $0x25,%eax
  80046c:	75 e2                	jne    800450 <vprintfmt+0x14>
  80046e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800472:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800479:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800480:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800487:	ba 00 00 00 00       	mov    $0x0,%edx
  80048c:	eb 07                	jmp    800495 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800491:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8d 47 01             	lea    0x1(%edi),%eax
  800498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049b:	0f b6 07             	movzbl (%edi),%eax
  80049e:	0f b6 c8             	movzbl %al,%ecx
  8004a1:	83 e8 23             	sub    $0x23,%eax
  8004a4:	3c 55                	cmp    $0x55,%al
  8004a6:	0f 87 1a 03 00 00    	ja     8007c6 <vprintfmt+0x38a>
  8004ac:	0f b6 c0             	movzbl %al,%eax
  8004af:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004bd:	eb d6                	jmp    800495 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004d7:	83 fa 09             	cmp    $0x9,%edx
  8004da:	77 39                	ja     800515 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004df:	eb e9                	jmp    8004ca <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8004e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f2:	eb 27                	jmp    80051b <vprintfmt+0xdf>
  8004f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004fe:	0f 49 c8             	cmovns %eax,%ecx
  800501:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800507:	eb 8c                	jmp    800495 <vprintfmt+0x59>
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800513:	eb 80                	jmp    800495 <vprintfmt+0x59>
  800515:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800518:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80051b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051f:	0f 89 70 ff ff ff    	jns    800495 <vprintfmt+0x59>
				width = precision, precision = -1;
  800525:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800528:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800532:	e9 5e ff ff ff       	jmp    800495 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800537:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053d:	e9 53 ff ff ff       	jmp    800495 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	ff 30                	pushl  (%eax)
  800551:	ff d6                	call   *%esi
			break;
  800553:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800559:	e9 04 ff ff ff       	jmp    800462 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 00                	mov    (%eax),%eax
  800569:	99                   	cltd   
  80056a:	31 d0                	xor    %edx,%eax
  80056c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056e:	83 f8 0f             	cmp    $0xf,%eax
  800571:	7f 0b                	jg     80057e <vprintfmt+0x142>
  800573:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  80057a:	85 d2                	test   %edx,%edx
  80057c:	75 18                	jne    800596 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80057e:	50                   	push   %eax
  80057f:	68 bb 27 80 00       	push   $0x8027bb
  800584:	53                   	push   %ebx
  800585:	56                   	push   %esi
  800586:	e8 94 fe ff ff       	call   80041f <printfmt>
  80058b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800591:	e9 cc fe ff ff       	jmp    800462 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800596:	52                   	push   %edx
  800597:	68 45 2c 80 00       	push   $0x802c45
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 7c fe ff ff       	call   80041f <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	e9 b4 fe ff ff       	jmp    800462 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005b9:	85 ff                	test   %edi,%edi
  8005bb:	b8 b4 27 80 00       	mov    $0x8027b4,%eax
  8005c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c7:	0f 8e 94 00 00 00    	jle    800661 <vprintfmt+0x225>
  8005cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d1:	0f 84 98 00 00 00    	je     80066f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	ff 75 d0             	pushl  -0x30(%ebp)
  8005dd:	57                   	push   %edi
  8005de:	e8 86 02 00 00       	call   800869 <strnlen>
  8005e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e6:	29 c1                	sub    %eax,%ecx
  8005e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fa:	eb 0f                	jmp    80060b <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	ff 75 e0             	pushl  -0x20(%ebp)
  800603:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800605:	83 ef 01             	sub    $0x1,%edi
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	85 ff                	test   %edi,%edi
  80060d:	7f ed                	jg     8005fc <vprintfmt+0x1c0>
  80060f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800612:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800615:	85 c9                	test   %ecx,%ecx
  800617:	b8 00 00 00 00       	mov    $0x0,%eax
  80061c:	0f 49 c1             	cmovns %ecx,%eax
  80061f:	29 c1                	sub    %eax,%ecx
  800621:	89 75 08             	mov    %esi,0x8(%ebp)
  800624:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800627:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062a:	89 cb                	mov    %ecx,%ebx
  80062c:	eb 4d                	jmp    80067b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800632:	74 1b                	je     80064f <vprintfmt+0x213>
  800634:	0f be c0             	movsbl %al,%eax
  800637:	83 e8 20             	sub    $0x20,%eax
  80063a:	83 f8 5e             	cmp    $0x5e,%eax
  80063d:	76 10                	jbe    80064f <vprintfmt+0x213>
					putch('?', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	ff 75 0c             	pushl  0xc(%ebp)
  800645:	6a 3f                	push   $0x3f
  800647:	ff 55 08             	call   *0x8(%ebp)
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	eb 0d                	jmp    80065c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	ff 75 0c             	pushl  0xc(%ebp)
  800655:	52                   	push   %edx
  800656:	ff 55 08             	call   *0x8(%ebp)
  800659:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065c:	83 eb 01             	sub    $0x1,%ebx
  80065f:	eb 1a                	jmp    80067b <vprintfmt+0x23f>
  800661:	89 75 08             	mov    %esi,0x8(%ebp)
  800664:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800667:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066d:	eb 0c                	jmp    80067b <vprintfmt+0x23f>
  80066f:	89 75 08             	mov    %esi,0x8(%ebp)
  800672:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800675:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800678:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067b:	83 c7 01             	add    $0x1,%edi
  80067e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800682:	0f be d0             	movsbl %al,%edx
  800685:	85 d2                	test   %edx,%edx
  800687:	74 23                	je     8006ac <vprintfmt+0x270>
  800689:	85 f6                	test   %esi,%esi
  80068b:	78 a1                	js     80062e <vprintfmt+0x1f2>
  80068d:	83 ee 01             	sub    $0x1,%esi
  800690:	79 9c                	jns    80062e <vprintfmt+0x1f2>
  800692:	89 df                	mov    %ebx,%edi
  800694:	8b 75 08             	mov    0x8(%ebp),%esi
  800697:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069a:	eb 18                	jmp    8006b4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 20                	push   $0x20
  8006a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a4:	83 ef 01             	sub    $0x1,%edi
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 08                	jmp    8006b4 <vprintfmt+0x278>
  8006ac:	89 df                	mov    %ebx,%edi
  8006ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b4:	85 ff                	test   %edi,%edi
  8006b6:	7f e4                	jg     80069c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bb:	e9 a2 fd ff ff       	jmp    800462 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c0:	83 fa 01             	cmp    $0x1,%edx
  8006c3:	7e 16                	jle    8006db <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 08             	lea    0x8(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	8b 50 04             	mov    0x4(%eax),%edx
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d9:	eb 32                	jmp    80070d <vprintfmt+0x2d1>
	else if (lflag)
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	74 18                	je     8006f7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 00                	mov    (%eax),%eax
  8006ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ed:	89 c1                	mov    %eax,%ecx
  8006ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f5:	eb 16                	jmp    80070d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800710:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800713:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800718:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80071c:	79 74                	jns    800792 <vprintfmt+0x356>
				putch('-', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	6a 2d                	push   $0x2d
  800724:	ff d6                	call   *%esi
				num = -(long long) num;
  800726:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800729:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80072c:	f7 d8                	neg    %eax
  80072e:	83 d2 00             	adc    $0x0,%edx
  800731:	f7 da                	neg    %edx
  800733:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800736:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80073b:	eb 55                	jmp    800792 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073d:	8d 45 14             	lea    0x14(%ebp),%eax
  800740:	e8 83 fc ff ff       	call   8003c8 <getuint>
			base = 10;
  800745:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80074a:	eb 46                	jmp    800792 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
  80074f:	e8 74 fc ff ff       	call   8003c8 <getuint>
			base = 8;
  800754:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800759:	eb 37                	jmp    800792 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	53                   	push   %ebx
  80075f:	6a 30                	push   $0x30
  800761:	ff d6                	call   *%esi
			putch('x', putdat);
  800763:	83 c4 08             	add    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 78                	push   $0x78
  800769:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 50 04             	lea    0x4(%eax),%edx
  800771:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800774:	8b 00                	mov    (%eax),%eax
  800776:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80077b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80077e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800783:	eb 0d                	jmp    800792 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800785:	8d 45 14             	lea    0x14(%ebp),%eax
  800788:	e8 3b fc ff ff       	call   8003c8 <getuint>
			base = 16;
  80078d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800792:	83 ec 0c             	sub    $0xc,%esp
  800795:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800799:	57                   	push   %edi
  80079a:	ff 75 e0             	pushl  -0x20(%ebp)
  80079d:	51                   	push   %ecx
  80079e:	52                   	push   %edx
  80079f:	50                   	push   %eax
  8007a0:	89 da                	mov    %ebx,%edx
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	e8 70 fb ff ff       	call   800319 <printnum>
			break;
  8007a9:	83 c4 20             	add    $0x20,%esp
  8007ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007af:	e9 ae fc ff ff       	jmp    800462 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	51                   	push   %ecx
  8007b9:	ff d6                	call   *%esi
			break;
  8007bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c1:	e9 9c fc ff ff       	jmp    800462 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c6:	83 ec 08             	sub    $0x8,%esp
  8007c9:	53                   	push   %ebx
  8007ca:	6a 25                	push   $0x25
  8007cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	eb 03                	jmp    8007d6 <vprintfmt+0x39a>
  8007d3:	83 ef 01             	sub    $0x1,%edi
  8007d6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007da:	75 f7                	jne    8007d3 <vprintfmt+0x397>
  8007dc:	e9 81 fc ff ff       	jmp    800462 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5f                   	pop    %edi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 18             	sub    $0x18,%esp
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800806:	85 c0                	test   %eax,%eax
  800808:	74 26                	je     800830 <vsnprintf+0x47>
  80080a:	85 d2                	test   %edx,%edx
  80080c:	7e 22                	jle    800830 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080e:	ff 75 14             	pushl  0x14(%ebp)
  800811:	ff 75 10             	pushl  0x10(%ebp)
  800814:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800817:	50                   	push   %eax
  800818:	68 02 04 80 00       	push   $0x800402
  80081d:	e8 1a fc ff ff       	call   80043c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800822:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800825:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	eb 05                	jmp    800835 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800830:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800840:	50                   	push   %eax
  800841:	ff 75 10             	pushl  0x10(%ebp)
  800844:	ff 75 0c             	pushl  0xc(%ebp)
  800847:	ff 75 08             	pushl  0x8(%ebp)
  80084a:	e8 9a ff ff ff       	call   8007e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
  80085c:	eb 03                	jmp    800861 <strlen+0x10>
		n++;
  80085e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800865:	75 f7                	jne    80085e <strlen+0xd>
		n++;
	return n;
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800872:	ba 00 00 00 00       	mov    $0x0,%edx
  800877:	eb 03                	jmp    80087c <strnlen+0x13>
		n++;
  800879:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	39 c2                	cmp    %eax,%edx
  80087e:	74 08                	je     800888 <strnlen+0x1f>
  800880:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800884:	75 f3                	jne    800879 <strnlen+0x10>
  800886:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800894:	89 c2                	mov    %eax,%edx
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b1:	53                   	push   %ebx
  8008b2:	e8 9a ff ff ff       	call   800851 <strlen>
  8008b7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ba:	ff 75 0c             	pushl  0xc(%ebp)
  8008bd:	01 d8                	add    %ebx,%eax
  8008bf:	50                   	push   %eax
  8008c0:	e8 c5 ff ff ff       	call   80088a <strcpy>
	return dst;
}
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	56                   	push   %esi
  8008d0:	53                   	push   %ebx
  8008d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d7:	89 f3                	mov    %esi,%ebx
  8008d9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dc:	89 f2                	mov    %esi,%edx
  8008de:	eb 0f                	jmp    8008ef <strncpy+0x23>
		*dst++ = *src;
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	0f b6 01             	movzbl (%ecx),%eax
  8008e6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e9:	80 39 01             	cmpb   $0x1,(%ecx)
  8008ec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ef:	39 da                	cmp    %ebx,%edx
  8008f1:	75 ed                	jne    8008e0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f3:	89 f0                	mov    %esi,%eax
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800901:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800904:	8b 55 10             	mov    0x10(%ebp),%edx
  800907:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800909:	85 d2                	test   %edx,%edx
  80090b:	74 21                	je     80092e <strlcpy+0x35>
  80090d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800911:	89 f2                	mov    %esi,%edx
  800913:	eb 09                	jmp    80091e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800915:	83 c2 01             	add    $0x1,%edx
  800918:	83 c1 01             	add    $0x1,%ecx
  80091b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091e:	39 c2                	cmp    %eax,%edx
  800920:	74 09                	je     80092b <strlcpy+0x32>
  800922:	0f b6 19             	movzbl (%ecx),%ebx
  800925:	84 db                	test   %bl,%bl
  800927:	75 ec                	jne    800915 <strlcpy+0x1c>
  800929:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092e:	29 f0                	sub    %esi,%eax
}
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093d:	eb 06                	jmp    800945 <strcmp+0x11>
		p++, q++;
  80093f:	83 c1 01             	add    $0x1,%ecx
  800942:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800945:	0f b6 01             	movzbl (%ecx),%eax
  800948:	84 c0                	test   %al,%al
  80094a:	74 04                	je     800950 <strcmp+0x1c>
  80094c:	3a 02                	cmp    (%edx),%al
  80094e:	74 ef                	je     80093f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800950:	0f b6 c0             	movzbl %al,%eax
  800953:	0f b6 12             	movzbl (%edx),%edx
  800956:	29 d0                	sub    %edx,%eax
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
  800964:	89 c3                	mov    %eax,%ebx
  800966:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800969:	eb 06                	jmp    800971 <strncmp+0x17>
		n--, p++, q++;
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800971:	39 d8                	cmp    %ebx,%eax
  800973:	74 15                	je     80098a <strncmp+0x30>
  800975:	0f b6 08             	movzbl (%eax),%ecx
  800978:	84 c9                	test   %cl,%cl
  80097a:	74 04                	je     800980 <strncmp+0x26>
  80097c:	3a 0a                	cmp    (%edx),%cl
  80097e:	74 eb                	je     80096b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800980:	0f b6 00             	movzbl (%eax),%eax
  800983:	0f b6 12             	movzbl (%edx),%edx
  800986:	29 d0                	sub    %edx,%eax
  800988:	eb 05                	jmp    80098f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098f:	5b                   	pop    %ebx
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099c:	eb 07                	jmp    8009a5 <strchr+0x13>
		if (*s == c)
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	74 0f                	je     8009b1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	75 f2                	jne    80099e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bd:	eb 03                	jmp    8009c2 <strfind+0xf>
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009c5:	38 ca                	cmp    %cl,%dl
  8009c7:	74 04                	je     8009cd <strfind+0x1a>
  8009c9:	84 d2                	test   %dl,%dl
  8009cb:	75 f2                	jne    8009bf <strfind+0xc>
			break;
	return (char *) s;
}
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009db:	85 c9                	test   %ecx,%ecx
  8009dd:	74 36                	je     800a15 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e5:	75 28                	jne    800a0f <memset+0x40>
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 23                	jne    800a0f <memset+0x40>
		c &= 0xFF;
  8009ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f0:	89 d3                	mov    %edx,%ebx
  8009f2:	c1 e3 08             	shl    $0x8,%ebx
  8009f5:	89 d6                	mov    %edx,%esi
  8009f7:	c1 e6 18             	shl    $0x18,%esi
  8009fa:	89 d0                	mov    %edx,%eax
  8009fc:	c1 e0 10             	shl    $0x10,%eax
  8009ff:	09 f0                	or     %esi,%eax
  800a01:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a03:	89 d8                	mov    %ebx,%eax
  800a05:	09 d0                	or     %edx,%eax
  800a07:	c1 e9 02             	shr    $0x2,%ecx
  800a0a:	fc                   	cld    
  800a0b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a0d:	eb 06                	jmp    800a15 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a12:	fc                   	cld    
  800a13:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a15:	89 f8                	mov    %edi,%eax
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a2a:	39 c6                	cmp    %eax,%esi
  800a2c:	73 35                	jae    800a63 <memmove+0x47>
  800a2e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a31:	39 d0                	cmp    %edx,%eax
  800a33:	73 2e                	jae    800a63 <memmove+0x47>
		s += n;
		d += n;
  800a35:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a38:	89 d6                	mov    %edx,%esi
  800a3a:	09 fe                	or     %edi,%esi
  800a3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a42:	75 13                	jne    800a57 <memmove+0x3b>
  800a44:	f6 c1 03             	test   $0x3,%cl
  800a47:	75 0e                	jne    800a57 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a49:	83 ef 04             	sub    $0x4,%edi
  800a4c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4f:	c1 e9 02             	shr    $0x2,%ecx
  800a52:	fd                   	std    
  800a53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a55:	eb 09                	jmp    800a60 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a57:	83 ef 01             	sub    $0x1,%edi
  800a5a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a5d:	fd                   	std    
  800a5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a60:	fc                   	cld    
  800a61:	eb 1d                	jmp    800a80 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a63:	89 f2                	mov    %esi,%edx
  800a65:	09 c2                	or     %eax,%edx
  800a67:	f6 c2 03             	test   $0x3,%dl
  800a6a:	75 0f                	jne    800a7b <memmove+0x5f>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 0a                	jne    800a7b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a71:	c1 e9 02             	shr    $0x2,%ecx
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	fc                   	cld    
  800a77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a79:	eb 05                	jmp    800a80 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	fc                   	cld    
  800a7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a87:	ff 75 10             	pushl  0x10(%ebp)
  800a8a:	ff 75 0c             	pushl  0xc(%ebp)
  800a8d:	ff 75 08             	pushl  0x8(%ebp)
  800a90:	e8 87 ff ff ff       	call   800a1c <memmove>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa2:	89 c6                	mov    %eax,%esi
  800aa4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	eb 1a                	jmp    800ac3 <memcmp+0x2c>
		if (*s1 != *s2)
  800aa9:	0f b6 08             	movzbl (%eax),%ecx
  800aac:	0f b6 1a             	movzbl (%edx),%ebx
  800aaf:	38 d9                	cmp    %bl,%cl
  800ab1:	74 0a                	je     800abd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab3:	0f b6 c1             	movzbl %cl,%eax
  800ab6:	0f b6 db             	movzbl %bl,%ebx
  800ab9:	29 d8                	sub    %ebx,%eax
  800abb:	eb 0f                	jmp    800acc <memcmp+0x35>
		s1++, s2++;
  800abd:	83 c0 01             	add    $0x1,%eax
  800ac0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac3:	39 f0                	cmp    %esi,%eax
  800ac5:	75 e2                	jne    800aa9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad7:	89 c1                	mov    %eax,%ecx
  800ad9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800adc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae0:	eb 0a                	jmp    800aec <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae2:	0f b6 10             	movzbl (%eax),%edx
  800ae5:	39 da                	cmp    %ebx,%edx
  800ae7:	74 07                	je     800af0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae9:	83 c0 01             	add    $0x1,%eax
  800aec:	39 c8                	cmp    %ecx,%eax
  800aee:	72 f2                	jb     800ae2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af0:	5b                   	pop    %ebx
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	eb 03                	jmp    800b04 <strtol+0x11>
		s++;
  800b01:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b04:	0f b6 01             	movzbl (%ecx),%eax
  800b07:	3c 20                	cmp    $0x20,%al
  800b09:	74 f6                	je     800b01 <strtol+0xe>
  800b0b:	3c 09                	cmp    $0x9,%al
  800b0d:	74 f2                	je     800b01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0f:	3c 2b                	cmp    $0x2b,%al
  800b11:	75 0a                	jne    800b1d <strtol+0x2a>
		s++;
  800b13:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1b:	eb 11                	jmp    800b2e <strtol+0x3b>
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b22:	3c 2d                	cmp    $0x2d,%al
  800b24:	75 08                	jne    800b2e <strtol+0x3b>
		s++, neg = 1;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b34:	75 15                	jne    800b4b <strtol+0x58>
  800b36:	80 39 30             	cmpb   $0x30,(%ecx)
  800b39:	75 10                	jne    800b4b <strtol+0x58>
  800b3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3f:	75 7c                	jne    800bbd <strtol+0xca>
		s += 2, base = 16;
  800b41:	83 c1 02             	add    $0x2,%ecx
  800b44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b49:	eb 16                	jmp    800b61 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b4b:	85 db                	test   %ebx,%ebx
  800b4d:	75 12                	jne    800b61 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b54:	80 39 30             	cmpb   $0x30,(%ecx)
  800b57:	75 08                	jne    800b61 <strtol+0x6e>
		s++, base = 8;
  800b59:	83 c1 01             	add    $0x1,%ecx
  800b5c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b69:	0f b6 11             	movzbl (%ecx),%edx
  800b6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	80 fb 09             	cmp    $0x9,%bl
  800b74:	77 08                	ja     800b7e <strtol+0x8b>
			dig = *s - '0';
  800b76:	0f be d2             	movsbl %dl,%edx
  800b79:	83 ea 30             	sub    $0x30,%edx
  800b7c:	eb 22                	jmp    800ba0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b7e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b81:	89 f3                	mov    %esi,%ebx
  800b83:	80 fb 19             	cmp    $0x19,%bl
  800b86:	77 08                	ja     800b90 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b88:	0f be d2             	movsbl %dl,%edx
  800b8b:	83 ea 57             	sub    $0x57,%edx
  800b8e:	eb 10                	jmp    800ba0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b90:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b93:	89 f3                	mov    %esi,%ebx
  800b95:	80 fb 19             	cmp    $0x19,%bl
  800b98:	77 16                	ja     800bb0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b9a:	0f be d2             	movsbl %dl,%edx
  800b9d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba3:	7d 0b                	jge    800bb0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ba5:	83 c1 01             	add    $0x1,%ecx
  800ba8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bae:	eb b9                	jmp    800b69 <strtol+0x76>

	if (endptr)
  800bb0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb4:	74 0d                	je     800bc3 <strtol+0xd0>
		*endptr = (char *) s;
  800bb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb9:	89 0e                	mov    %ecx,(%esi)
  800bbb:	eb 06                	jmp    800bc3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbd:	85 db                	test   %ebx,%ebx
  800bbf:	74 98                	je     800b59 <strtol+0x66>
  800bc1:	eb 9e                	jmp    800b61 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bc3:	89 c2                	mov    %eax,%edx
  800bc5:	f7 da                	neg    %edx
  800bc7:	85 ff                	test   %edi,%edi
  800bc9:	0f 45 c2             	cmovne %edx,%eax
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	89 c3                	mov    %eax,%ebx
  800be4:	89 c7                	mov    %eax,%edi
  800be6:	89 c6                	mov    %eax,%esi
  800be8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_cgetc>:

int
sys_cgetc(void)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	b8 01 00 00 00       	mov    $0x1,%eax
  800bff:	89 d1                	mov    %edx,%ecx
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	89 d7                	mov    %edx,%edi
  800c05:	89 d6                	mov    %edx,%esi
  800c07:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	89 cb                	mov    %ecx,%ebx
  800c26:	89 cf                	mov    %ecx,%edi
  800c28:	89 ce                	mov    %ecx,%esi
  800c2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 03                	push   $0x3
  800c36:	68 9f 2a 80 00       	push   $0x802a9f
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 bc 2a 80 00       	push   $0x802abc
  800c42:	e8 e5 f5 ff ff       	call   80022c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c5f:	89 d1                	mov    %edx,%ecx
  800c61:	89 d3                	mov    %edx,%ebx
  800c63:	89 d7                	mov    %edx,%edi
  800c65:	89 d6                	mov    %edx,%esi
  800c67:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_yield>:

void
sys_yield(void)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	ba 00 00 00 00       	mov    $0x0,%edx
  800c79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	89 d3                	mov    %edx,%ebx
  800c82:	89 d7                	mov    %edx,%edi
  800c84:	89 d6                	mov    %edx,%esi
  800c86:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	be 00 00 00 00       	mov    $0x0,%esi
  800c9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca9:	89 f7                	mov    %esi,%edi
  800cab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 17                	jle    800cc8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	6a 04                	push   $0x4
  800cb7:	68 9f 2a 80 00       	push   $0x802a9f
  800cbc:	6a 23                	push   $0x23
  800cbe:	68 bc 2a 80 00       	push   $0x802abc
  800cc3:	e8 64 f5 ff ff       	call   80022c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cea:	8b 75 18             	mov    0x18(%ebp),%esi
  800ced:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7e 17                	jle    800d0a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 05                	push   $0x5
  800cf9:	68 9f 2a 80 00       	push   $0x802a9f
  800cfe:	6a 23                	push   $0x23
  800d00:	68 bc 2a 80 00       	push   $0x802abc
  800d05:	e8 22 f5 ff ff       	call   80022c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	b8 06 00 00 00       	mov    $0x6,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7e 17                	jle    800d4c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	6a 06                	push   $0x6
  800d3b:	68 9f 2a 80 00       	push   $0x802a9f
  800d40:	6a 23                	push   $0x23
  800d42:	68 bc 2a 80 00       	push   $0x802abc
  800d47:	e8 e0 f4 ff ff       	call   80022c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	b8 08 00 00 00       	mov    $0x8,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 17                	jle    800d8e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	50                   	push   %eax
  800d7b:	6a 08                	push   $0x8
  800d7d:	68 9f 2a 80 00       	push   $0x802a9f
  800d82:	6a 23                	push   $0x23
  800d84:	68 bc 2a 80 00       	push   $0x802abc
  800d89:	e8 9e f4 ff ff       	call   80022c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da4:	b8 09 00 00 00       	mov    $0x9,%eax
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	89 df                	mov    %ebx,%edi
  800db1:	89 de                	mov    %ebx,%esi
  800db3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	7e 17                	jle    800dd0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	50                   	push   %eax
  800dbd:	6a 09                	push   $0x9
  800dbf:	68 9f 2a 80 00       	push   $0x802a9f
  800dc4:	6a 23                	push   $0x23
  800dc6:	68 bc 2a 80 00       	push   $0x802abc
  800dcb:	e8 5c f4 ff ff       	call   80022c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800deb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	89 df                	mov    %ebx,%edi
  800df3:	89 de                	mov    %ebx,%esi
  800df5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df7:	85 c0                	test   %eax,%eax
  800df9:	7e 17                	jle    800e12 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	50                   	push   %eax
  800dff:	6a 0a                	push   $0xa
  800e01:	68 9f 2a 80 00       	push   $0x802a9f
  800e06:	6a 23                	push   $0x23
  800e08:	68 bc 2a 80 00       	push   $0x802abc
  800e0d:	e8 1a f4 ff ff       	call   80022c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	be 00 00 00 00       	mov    $0x0,%esi
  800e25:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e36:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	57                   	push   %edi
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
  800e43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 cb                	mov    %ecx,%ebx
  800e55:	89 cf                	mov    %ecx,%edi
  800e57:	89 ce                	mov    %ecx,%esi
  800e59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	7e 17                	jle    800e76 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	50                   	push   %eax
  800e63:	6a 0d                	push   $0xd
  800e65:	68 9f 2a 80 00       	push   $0x802a9f
  800e6a:	6a 23                	push   $0x23
  800e6c:	68 bc 2a 80 00       	push   $0x802abc
  800e71:	e8 b6 f3 ff ff       	call   80022c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e79:	5b                   	pop    %ebx
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e8e:	89 d1                	mov    %edx,%ecx
  800e90:	89 d3                	mov    %edx,%ebx
  800e92:	89 d7                	mov    %edx,%edi
  800e94:	89 d6                	mov    %edx,%esi
  800e96:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea5:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800ea7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eab:	75 25                	jne    800ed2 <pgfault+0x35>
  800ead:	89 d8                	mov    %ebx,%eax
  800eaf:	c1 e8 0c             	shr    $0xc,%eax
  800eb2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb9:	f6 c4 08             	test   $0x8,%ah
  800ebc:	75 14                	jne    800ed2 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	68 cc 2a 80 00       	push   $0x802acc
  800ec6:	6a 1e                	push   $0x1e
  800ec8:	68 60 2b 80 00       	push   $0x802b60
  800ecd:	e8 5a f3 ff ff       	call   80022c <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800ed2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ed8:	e8 72 fd ff ff       	call   800c4f <sys_getenvid>
  800edd:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	6a 07                	push   $0x7
  800ee4:	68 00 f0 7f 00       	push   $0x7ff000
  800ee9:	50                   	push   %eax
  800eea:	e8 9e fd ff ff       	call   800c8d <sys_page_alloc>
	if (r < 0)
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	79 12                	jns    800f08 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ef6:	50                   	push   %eax
  800ef7:	68 f8 2a 80 00       	push   $0x802af8
  800efc:	6a 33                	push   $0x33
  800efe:	68 60 2b 80 00       	push   $0x802b60
  800f03:	e8 24 f3 ff ff       	call   80022c <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	68 00 10 00 00       	push   $0x1000
  800f10:	53                   	push   %ebx
  800f11:	68 00 f0 7f 00       	push   $0x7ff000
  800f16:	e8 69 fb ff ff       	call   800a84 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f1b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f22:	53                   	push   %ebx
  800f23:	56                   	push   %esi
  800f24:	68 00 f0 7f 00       	push   $0x7ff000
  800f29:	56                   	push   %esi
  800f2a:	e8 a1 fd ff ff       	call   800cd0 <sys_page_map>
	if (r < 0)
  800f2f:	83 c4 20             	add    $0x20,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	79 12                	jns    800f48 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f36:	50                   	push   %eax
  800f37:	68 1c 2b 80 00       	push   $0x802b1c
  800f3c:	6a 3b                	push   $0x3b
  800f3e:	68 60 2b 80 00       	push   $0x802b60
  800f43:	e8 e4 f2 ff ff       	call   80022c <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f48:	83 ec 08             	sub    $0x8,%esp
  800f4b:	68 00 f0 7f 00       	push   $0x7ff000
  800f50:	56                   	push   %esi
  800f51:	e8 bc fd ff ff       	call   800d12 <sys_page_unmap>
	if (r < 0)
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	79 12                	jns    800f6f <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f5d:	50                   	push   %eax
  800f5e:	68 40 2b 80 00       	push   $0x802b40
  800f63:	6a 40                	push   $0x40
  800f65:	68 60 2b 80 00       	push   $0x802b60
  800f6a:	e8 bd f2 ff ff       	call   80022c <_panic>
}
  800f6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f7f:	68 9d 0e 80 00       	push   $0x800e9d
  800f84:	e8 dc 13 00 00       	call   802365 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f89:	b8 07 00 00 00       	mov    $0x7,%eax
  800f8e:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	0f 88 64 01 00 00    	js     8010ff <fork+0x189>
  800f9b:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800fa0:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	75 21                	jne    800fca <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fa9:	e8 a1 fc ff ff       	call   800c4f <sys_getenvid>
  800fae:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fb6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fbb:	a3 0c 40 80 00       	mov    %eax,0x80400c
        return 0;
  800fc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc5:	e9 3f 01 00 00       	jmp    801109 <fork+0x193>
  800fca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fcd:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fcf:	89 d8                	mov    %ebx,%eax
  800fd1:	c1 e8 16             	shr    $0x16,%eax
  800fd4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fdb:	a8 01                	test   $0x1,%al
  800fdd:	0f 84 bd 00 00 00    	je     8010a0 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fe3:	89 d8                	mov    %ebx,%eax
  800fe5:	c1 e8 0c             	shr    $0xc,%eax
  800fe8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fef:	f6 c2 01             	test   $0x1,%dl
  800ff2:	0f 84 a8 00 00 00    	je     8010a0 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800ff8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fff:	a8 04                	test   $0x4,%al
  801001:	0f 84 99 00 00 00    	je     8010a0 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801007:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100e:	f6 c4 04             	test   $0x4,%ah
  801011:	74 17                	je     80102a <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	68 07 0e 00 00       	push   $0xe07
  80101b:	53                   	push   %ebx
  80101c:	57                   	push   %edi
  80101d:	53                   	push   %ebx
  80101e:	6a 00                	push   $0x0
  801020:	e8 ab fc ff ff       	call   800cd0 <sys_page_map>
  801025:	83 c4 20             	add    $0x20,%esp
  801028:	eb 76                	jmp    8010a0 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80102a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801031:	a8 02                	test   $0x2,%al
  801033:	75 0c                	jne    801041 <fork+0xcb>
  801035:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103c:	f6 c4 08             	test   $0x8,%ah
  80103f:	74 3f                	je     801080 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	68 05 08 00 00       	push   $0x805
  801049:	53                   	push   %ebx
  80104a:	57                   	push   %edi
  80104b:	53                   	push   %ebx
  80104c:	6a 00                	push   $0x0
  80104e:	e8 7d fc ff ff       	call   800cd0 <sys_page_map>
		if (r < 0)
  801053:	83 c4 20             	add    $0x20,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	0f 88 a5 00 00 00    	js     801103 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	68 05 08 00 00       	push   $0x805
  801066:	53                   	push   %ebx
  801067:	6a 00                	push   $0x0
  801069:	53                   	push   %ebx
  80106a:	6a 00                	push   $0x0
  80106c:	e8 5f fc ff ff       	call   800cd0 <sys_page_map>
  801071:	83 c4 20             	add    $0x20,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107b:	0f 4f c1             	cmovg  %ecx,%eax
  80107e:	eb 1c                	jmp    80109c <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	6a 05                	push   $0x5
  801085:	53                   	push   %ebx
  801086:	57                   	push   %edi
  801087:	53                   	push   %ebx
  801088:	6a 00                	push   $0x0
  80108a:	e8 41 fc ff ff       	call   800cd0 <sys_page_map>
  80108f:	83 c4 20             	add    $0x20,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	b9 00 00 00 00       	mov    $0x0,%ecx
  801099:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 67                	js     801107 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8010a0:	83 c6 01             	add    $0x1,%esi
  8010a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010a9:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010af:	0f 85 1a ff ff ff    	jne    800fcf <fork+0x59>
  8010b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8010b8:	83 ec 04             	sub    $0x4,%esp
  8010bb:	6a 07                	push   $0x7
  8010bd:	68 00 f0 bf ee       	push   $0xeebff000
  8010c2:	57                   	push   %edi
  8010c3:	e8 c5 fb ff ff       	call   800c8d <sys_page_alloc>
	if (r < 0)
  8010c8:	83 c4 10             	add    $0x10,%esp
		return r;
  8010cb:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 38                	js     801109 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010d1:	83 ec 08             	sub    $0x8,%esp
  8010d4:	68 ac 23 80 00       	push   $0x8023ac
  8010d9:	57                   	push   %edi
  8010da:	e8 f9 fc ff ff       	call   800dd8 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010df:	83 c4 10             	add    $0x10,%esp
		return r;
  8010e2:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	78 21                	js     801109 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010e8:	83 ec 08             	sub    $0x8,%esp
  8010eb:	6a 02                	push   $0x2
  8010ed:	57                   	push   %edi
  8010ee:	e8 61 fc ff ff       	call   800d54 <sys_env_set_status>
	if (r < 0)
  8010f3:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	0f 48 f8             	cmovs  %eax,%edi
  8010fb:	89 fa                	mov    %edi,%edx
  8010fd:	eb 0a                	jmp    801109 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010ff:	89 c2                	mov    %eax,%edx
  801101:	eb 06                	jmp    801109 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801103:	89 c2                	mov    %eax,%edx
  801105:	eb 02                	jmp    801109 <fork+0x193>
  801107:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801109:	89 d0                	mov    %edx,%eax
  80110b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    

00801113 <sfork>:

// Challenge!
int
sfork(void)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801119:	68 6b 2b 80 00       	push   $0x802b6b
  80111e:	68 c9 00 00 00       	push   $0xc9
  801123:	68 60 2b 80 00       	push   $0x802b60
  801128:	e8 ff f0 ff ff       	call   80022c <_panic>

0080112d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	8b 75 08             	mov    0x8(%ebp),%esi
  801135:	8b 45 0c             	mov    0xc(%ebp),%eax
  801138:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80113b:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80113d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801142:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	50                   	push   %eax
  801149:	e8 ef fc ff ff       	call   800e3d <sys_ipc_recv>

	if (from_env_store != NULL)
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 f6                	test   %esi,%esi
  801153:	74 14                	je     801169 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801155:	ba 00 00 00 00       	mov    $0x0,%edx
  80115a:	85 c0                	test   %eax,%eax
  80115c:	78 09                	js     801167 <ipc_recv+0x3a>
  80115e:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801164:	8b 52 74             	mov    0x74(%edx),%edx
  801167:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801169:	85 db                	test   %ebx,%ebx
  80116b:	74 14                	je     801181 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80116d:	ba 00 00 00 00       	mov    $0x0,%edx
  801172:	85 c0                	test   %eax,%eax
  801174:	78 09                	js     80117f <ipc_recv+0x52>
  801176:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  80117c:	8b 52 78             	mov    0x78(%edx),%edx
  80117f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801181:	85 c0                	test   %eax,%eax
  801183:	78 08                	js     80118d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801185:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80118a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80118d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801190:	5b                   	pop    %ebx
  801191:	5e                   	pop    %esi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	57                   	push   %edi
  801198:	56                   	push   %esi
  801199:	53                   	push   %ebx
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8011a6:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8011a8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011ad:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8011b0:	ff 75 14             	pushl  0x14(%ebp)
  8011b3:	53                   	push   %ebx
  8011b4:	56                   	push   %esi
  8011b5:	57                   	push   %edi
  8011b6:	e8 5f fc ff ff       	call   800e1a <sys_ipc_try_send>

		if (err < 0) {
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	79 1e                	jns    8011e0 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8011c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011c5:	75 07                	jne    8011ce <ipc_send+0x3a>
				sys_yield();
  8011c7:	e8 a2 fa ff ff       	call   800c6e <sys_yield>
  8011cc:	eb e2                	jmp    8011b0 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8011ce:	50                   	push   %eax
  8011cf:	68 81 2b 80 00       	push   $0x802b81
  8011d4:	6a 49                	push   $0x49
  8011d6:	68 8e 2b 80 00       	push   $0x802b8e
  8011db:	e8 4c f0 ff ff       	call   80022c <_panic>
		}

	} while (err < 0);

}
  8011e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011ee:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011f3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011f6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011fc:	8b 52 50             	mov    0x50(%edx),%edx
  8011ff:	39 ca                	cmp    %ecx,%edx
  801201:	75 0d                	jne    801210 <ipc_find_env+0x28>
			return envs[i].env_id;
  801203:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801206:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80120b:	8b 40 48             	mov    0x48(%eax),%eax
  80120e:	eb 0f                	jmp    80121f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801210:	83 c0 01             	add    $0x1,%eax
  801213:	3d 00 04 00 00       	cmp    $0x400,%eax
  801218:	75 d9                	jne    8011f3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80121a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801224:	8b 45 08             	mov    0x8(%ebp),%eax
  801227:	05 00 00 00 30       	add    $0x30000000,%eax
  80122c:	c1 e8 0c             	shr    $0xc,%eax
}
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
  801237:	05 00 00 00 30       	add    $0x30000000,%eax
  80123c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801241:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801253:	89 c2                	mov    %eax,%edx
  801255:	c1 ea 16             	shr    $0x16,%edx
  801258:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125f:	f6 c2 01             	test   $0x1,%dl
  801262:	74 11                	je     801275 <fd_alloc+0x2d>
  801264:	89 c2                	mov    %eax,%edx
  801266:	c1 ea 0c             	shr    $0xc,%edx
  801269:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801270:	f6 c2 01             	test   $0x1,%dl
  801273:	75 09                	jne    80127e <fd_alloc+0x36>
			*fd_store = fd;
  801275:	89 01                	mov    %eax,(%ecx)
			return 0;
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
  80127c:	eb 17                	jmp    801295 <fd_alloc+0x4d>
  80127e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801283:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801288:	75 c9                	jne    801253 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80128a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801290:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80129d:	83 f8 1f             	cmp    $0x1f,%eax
  8012a0:	77 36                	ja     8012d8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a2:	c1 e0 0c             	shl    $0xc,%eax
  8012a5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012aa:	89 c2                	mov    %eax,%edx
  8012ac:	c1 ea 16             	shr    $0x16,%edx
  8012af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b6:	f6 c2 01             	test   $0x1,%dl
  8012b9:	74 24                	je     8012df <fd_lookup+0x48>
  8012bb:	89 c2                	mov    %eax,%edx
  8012bd:	c1 ea 0c             	shr    $0xc,%edx
  8012c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c7:	f6 c2 01             	test   $0x1,%dl
  8012ca:	74 1a                	je     8012e6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012cf:	89 02                	mov    %eax,(%edx)
	return 0;
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d6:	eb 13                	jmp    8012eb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012dd:	eb 0c                	jmp    8012eb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e4:	eb 05                	jmp    8012eb <fd_lookup+0x54>
  8012e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f6:	ba 18 2c 80 00       	mov    $0x802c18,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012fb:	eb 13                	jmp    801310 <dev_lookup+0x23>
  8012fd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801300:	39 08                	cmp    %ecx,(%eax)
  801302:	75 0c                	jne    801310 <dev_lookup+0x23>
			*dev = devtab[i];
  801304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801307:	89 01                	mov    %eax,(%ecx)
			return 0;
  801309:	b8 00 00 00 00       	mov    $0x0,%eax
  80130e:	eb 2e                	jmp    80133e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801310:	8b 02                	mov    (%edx),%eax
  801312:	85 c0                	test   %eax,%eax
  801314:	75 e7                	jne    8012fd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801316:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80131b:	8b 40 48             	mov    0x48(%eax),%eax
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	51                   	push   %ecx
  801322:	50                   	push   %eax
  801323:	68 98 2b 80 00       	push   $0x802b98
  801328:	e8 d8 ef ff ff       	call   800305 <cprintf>
	*dev = 0;
  80132d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801330:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
  801345:	83 ec 10             	sub    $0x10,%esp
  801348:	8b 75 08             	mov    0x8(%ebp),%esi
  80134b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801351:	50                   	push   %eax
  801352:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801358:	c1 e8 0c             	shr    $0xc,%eax
  80135b:	50                   	push   %eax
  80135c:	e8 36 ff ff ff       	call   801297 <fd_lookup>
  801361:	83 c4 08             	add    $0x8,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 05                	js     80136d <fd_close+0x2d>
	    || fd != fd2)
  801368:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80136b:	74 0c                	je     801379 <fd_close+0x39>
		return (must_exist ? r : 0);
  80136d:	84 db                	test   %bl,%bl
  80136f:	ba 00 00 00 00       	mov    $0x0,%edx
  801374:	0f 44 c2             	cmove  %edx,%eax
  801377:	eb 41                	jmp    8013ba <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	ff 36                	pushl  (%esi)
  801382:	e8 66 ff ff ff       	call   8012ed <dev_lookup>
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 1a                	js     8013aa <fd_close+0x6a>
		if (dev->dev_close)
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801396:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80139b:	85 c0                	test   %eax,%eax
  80139d:	74 0b                	je     8013aa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	56                   	push   %esi
  8013a3:	ff d0                	call   *%eax
  8013a5:	89 c3                	mov    %eax,%ebx
  8013a7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	56                   	push   %esi
  8013ae:	6a 00                	push   $0x0
  8013b0:	e8 5d f9 ff ff       	call   800d12 <sys_page_unmap>
	return r;
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	89 d8                	mov    %ebx,%eax
}
  8013ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bd:	5b                   	pop    %ebx
  8013be:	5e                   	pop    %esi
  8013bf:	5d                   	pop    %ebp
  8013c0:	c3                   	ret    

008013c1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ca:	50                   	push   %eax
  8013cb:	ff 75 08             	pushl  0x8(%ebp)
  8013ce:	e8 c4 fe ff ff       	call   801297 <fd_lookup>
  8013d3:	83 c4 08             	add    $0x8,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 10                	js     8013ea <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	6a 01                	push   $0x1
  8013df:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e2:	e8 59 ff ff ff       	call   801340 <fd_close>
  8013e7:	83 c4 10             	add    $0x10,%esp
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <close_all>:

void
close_all(void)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	e8 c0 ff ff ff       	call   8013c1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801401:	83 c3 01             	add    $0x1,%ebx
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	83 fb 20             	cmp    $0x20,%ebx
  80140a:	75 ec                	jne    8013f8 <close_all+0xc>
		close(i);
}
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	57                   	push   %edi
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 2c             	sub    $0x2c,%esp
  80141a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	ff 75 08             	pushl  0x8(%ebp)
  801424:	e8 6e fe ff ff       	call   801297 <fd_lookup>
  801429:	83 c4 08             	add    $0x8,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	0f 88 c1 00 00 00    	js     8014f5 <dup+0xe4>
		return r;
	close(newfdnum);
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	56                   	push   %esi
  801438:	e8 84 ff ff ff       	call   8013c1 <close>

	newfd = INDEX2FD(newfdnum);
  80143d:	89 f3                	mov    %esi,%ebx
  80143f:	c1 e3 0c             	shl    $0xc,%ebx
  801442:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801448:	83 c4 04             	add    $0x4,%esp
  80144b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144e:	e8 de fd ff ff       	call   801231 <fd2data>
  801453:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801455:	89 1c 24             	mov    %ebx,(%esp)
  801458:	e8 d4 fd ff ff       	call   801231 <fd2data>
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801463:	89 f8                	mov    %edi,%eax
  801465:	c1 e8 16             	shr    $0x16,%eax
  801468:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146f:	a8 01                	test   $0x1,%al
  801471:	74 37                	je     8014aa <dup+0x99>
  801473:	89 f8                	mov    %edi,%eax
  801475:	c1 e8 0c             	shr    $0xc,%eax
  801478:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147f:	f6 c2 01             	test   $0x1,%dl
  801482:	74 26                	je     8014aa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801484:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	25 07 0e 00 00       	and    $0xe07,%eax
  801493:	50                   	push   %eax
  801494:	ff 75 d4             	pushl  -0x2c(%ebp)
  801497:	6a 00                	push   $0x0
  801499:	57                   	push   %edi
  80149a:	6a 00                	push   $0x0
  80149c:	e8 2f f8 ff ff       	call   800cd0 <sys_page_map>
  8014a1:	89 c7                	mov    %eax,%edi
  8014a3:	83 c4 20             	add    $0x20,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 2e                	js     8014d8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014ad:	89 d0                	mov    %edx,%eax
  8014af:	c1 e8 0c             	shr    $0xc,%eax
  8014b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c1:	50                   	push   %eax
  8014c2:	53                   	push   %ebx
  8014c3:	6a 00                	push   $0x0
  8014c5:	52                   	push   %edx
  8014c6:	6a 00                	push   $0x0
  8014c8:	e8 03 f8 ff ff       	call   800cd0 <sys_page_map>
  8014cd:	89 c7                	mov    %eax,%edi
  8014cf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014d2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d4:	85 ff                	test   %edi,%edi
  8014d6:	79 1d                	jns    8014f5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	53                   	push   %ebx
  8014dc:	6a 00                	push   $0x0
  8014de:	e8 2f f8 ff ff       	call   800d12 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e9:	6a 00                	push   $0x0
  8014eb:	e8 22 f8 ff ff       	call   800d12 <sys_page_unmap>
	return r;
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	89 f8                	mov    %edi,%eax
}
  8014f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5f                   	pop    %edi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	53                   	push   %ebx
  801501:	83 ec 14             	sub    $0x14,%esp
  801504:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801507:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	53                   	push   %ebx
  80150c:	e8 86 fd ff ff       	call   801297 <fd_lookup>
  801511:	83 c4 08             	add    $0x8,%esp
  801514:	89 c2                	mov    %eax,%edx
  801516:	85 c0                	test   %eax,%eax
  801518:	78 6d                	js     801587 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801524:	ff 30                	pushl  (%eax)
  801526:	e8 c2 fd ff ff       	call   8012ed <dev_lookup>
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 4c                	js     80157e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801532:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801535:	8b 42 08             	mov    0x8(%edx),%eax
  801538:	83 e0 03             	and    $0x3,%eax
  80153b:	83 f8 01             	cmp    $0x1,%eax
  80153e:	75 21                	jne    801561 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801540:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801545:	8b 40 48             	mov    0x48(%eax),%eax
  801548:	83 ec 04             	sub    $0x4,%esp
  80154b:	53                   	push   %ebx
  80154c:	50                   	push   %eax
  80154d:	68 dc 2b 80 00       	push   $0x802bdc
  801552:	e8 ae ed ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155f:	eb 26                	jmp    801587 <read+0x8a>
	}
	if (!dev->dev_read)
  801561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801564:	8b 40 08             	mov    0x8(%eax),%eax
  801567:	85 c0                	test   %eax,%eax
  801569:	74 17                	je     801582 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	ff 75 10             	pushl  0x10(%ebp)
  801571:	ff 75 0c             	pushl  0xc(%ebp)
  801574:	52                   	push   %edx
  801575:	ff d0                	call   *%eax
  801577:	89 c2                	mov    %eax,%edx
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	eb 09                	jmp    801587 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157e:	89 c2                	mov    %eax,%edx
  801580:	eb 05                	jmp    801587 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801582:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801587:	89 d0                	mov    %edx,%eax
  801589:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	57                   	push   %edi
  801592:	56                   	push   %esi
  801593:	53                   	push   %ebx
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a2:	eb 21                	jmp    8015c5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a4:	83 ec 04             	sub    $0x4,%esp
  8015a7:	89 f0                	mov    %esi,%eax
  8015a9:	29 d8                	sub    %ebx,%eax
  8015ab:	50                   	push   %eax
  8015ac:	89 d8                	mov    %ebx,%eax
  8015ae:	03 45 0c             	add    0xc(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	57                   	push   %edi
  8015b3:	e8 45 ff ff ff       	call   8014fd <read>
		if (m < 0)
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 10                	js     8015cf <readn+0x41>
			return m;
		if (m == 0)
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	74 0a                	je     8015cd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c3:	01 c3                	add    %eax,%ebx
  8015c5:	39 f3                	cmp    %esi,%ebx
  8015c7:	72 db                	jb     8015a4 <readn+0x16>
  8015c9:	89 d8                	mov    %ebx,%eax
  8015cb:	eb 02                	jmp    8015cf <readn+0x41>
  8015cd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	53                   	push   %ebx
  8015db:	83 ec 14             	sub    $0x14,%esp
  8015de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	53                   	push   %ebx
  8015e6:	e8 ac fc ff ff       	call   801297 <fd_lookup>
  8015eb:	83 c4 08             	add    $0x8,%esp
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 68                	js     80165c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fa:	50                   	push   %eax
  8015fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fe:	ff 30                	pushl  (%eax)
  801600:	e8 e8 fc ff ff       	call   8012ed <dev_lookup>
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 47                	js     801653 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801613:	75 21                	jne    801636 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801615:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80161a:	8b 40 48             	mov    0x48(%eax),%eax
  80161d:	83 ec 04             	sub    $0x4,%esp
  801620:	53                   	push   %ebx
  801621:	50                   	push   %eax
  801622:	68 f8 2b 80 00       	push   $0x802bf8
  801627:	e8 d9 ec ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801634:	eb 26                	jmp    80165c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801636:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801639:	8b 52 0c             	mov    0xc(%edx),%edx
  80163c:	85 d2                	test   %edx,%edx
  80163e:	74 17                	je     801657 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	ff 75 10             	pushl  0x10(%ebp)
  801646:	ff 75 0c             	pushl  0xc(%ebp)
  801649:	50                   	push   %eax
  80164a:	ff d2                	call   *%edx
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	eb 09                	jmp    80165c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801653:	89 c2                	mov    %eax,%edx
  801655:	eb 05                	jmp    80165c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801657:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80165c:	89 d0                	mov    %edx,%eax
  80165e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <seek>:

int
seek(int fdnum, off_t offset)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801669:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	ff 75 08             	pushl  0x8(%ebp)
  801670:	e8 22 fc ff ff       	call   801297 <fd_lookup>
  801675:	83 c4 08             	add    $0x8,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 0e                	js     80168a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80167c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80167f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801682:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	53                   	push   %ebx
  801690:	83 ec 14             	sub    $0x14,%esp
  801693:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801696:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	53                   	push   %ebx
  80169b:	e8 f7 fb ff ff       	call   801297 <fd_lookup>
  8016a0:	83 c4 08             	add    $0x8,%esp
  8016a3:	89 c2                	mov    %eax,%edx
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 65                	js     80170e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b3:	ff 30                	pushl  (%eax)
  8016b5:	e8 33 fc ff ff       	call   8012ed <dev_lookup>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 44                	js     801705 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c8:	75 21                	jne    8016eb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016ca:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016cf:	8b 40 48             	mov    0x48(%eax),%eax
  8016d2:	83 ec 04             	sub    $0x4,%esp
  8016d5:	53                   	push   %ebx
  8016d6:	50                   	push   %eax
  8016d7:	68 b8 2b 80 00       	push   $0x802bb8
  8016dc:	e8 24 ec ff ff       	call   800305 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e9:	eb 23                	jmp    80170e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ee:	8b 52 18             	mov    0x18(%edx),%edx
  8016f1:	85 d2                	test   %edx,%edx
  8016f3:	74 14                	je     801709 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	50                   	push   %eax
  8016fc:	ff d2                	call   *%edx
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	eb 09                	jmp    80170e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	89 c2                	mov    %eax,%edx
  801707:	eb 05                	jmp    80170e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801709:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80170e:	89 d0                	mov    %edx,%eax
  801710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	53                   	push   %ebx
  801719:	83 ec 14             	sub    $0x14,%esp
  80171c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801722:	50                   	push   %eax
  801723:	ff 75 08             	pushl  0x8(%ebp)
  801726:	e8 6c fb ff ff       	call   801297 <fd_lookup>
  80172b:	83 c4 08             	add    $0x8,%esp
  80172e:	89 c2                	mov    %eax,%edx
  801730:	85 c0                	test   %eax,%eax
  801732:	78 58                	js     80178c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801734:	83 ec 08             	sub    $0x8,%esp
  801737:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173e:	ff 30                	pushl  (%eax)
  801740:	e8 a8 fb ff ff       	call   8012ed <dev_lookup>
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 37                	js     801783 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801753:	74 32                	je     801787 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801755:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801758:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80175f:	00 00 00 
	stat->st_isdir = 0;
  801762:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801769:	00 00 00 
	stat->st_dev = dev;
  80176c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801772:	83 ec 08             	sub    $0x8,%esp
  801775:	53                   	push   %ebx
  801776:	ff 75 f0             	pushl  -0x10(%ebp)
  801779:	ff 50 14             	call   *0x14(%eax)
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	eb 09                	jmp    80178c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801783:	89 c2                	mov    %eax,%edx
  801785:	eb 05                	jmp    80178c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801787:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80178c:	89 d0                	mov    %edx,%eax
  80178e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	56                   	push   %esi
  801797:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	6a 00                	push   $0x0
  80179d:	ff 75 08             	pushl  0x8(%ebp)
  8017a0:	e8 d6 01 00 00       	call   80197b <open>
  8017a5:	89 c3                	mov    %eax,%ebx
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 1b                	js     8017c9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	50                   	push   %eax
  8017b5:	e8 5b ff ff ff       	call   801715 <fstat>
  8017ba:	89 c6                	mov    %eax,%esi
	close(fd);
  8017bc:	89 1c 24             	mov    %ebx,(%esp)
  8017bf:	e8 fd fb ff ff       	call   8013c1 <close>
	return r;
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	89 f0                	mov    %esi,%eax
}
  8017c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cc:	5b                   	pop    %ebx
  8017cd:	5e                   	pop    %esi
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	56                   	push   %esi
  8017d4:	53                   	push   %ebx
  8017d5:	89 c6                	mov    %eax,%esi
  8017d7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017e0:	75 12                	jne    8017f4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e2:	83 ec 0c             	sub    $0xc,%esp
  8017e5:	6a 01                	push   $0x1
  8017e7:	e8 fc f9 ff ff       	call   8011e8 <ipc_find_env>
  8017ec:	a3 04 40 80 00       	mov    %eax,0x804004
  8017f1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f4:	6a 07                	push   $0x7
  8017f6:	68 00 50 80 00       	push   $0x805000
  8017fb:	56                   	push   %esi
  8017fc:	ff 35 04 40 80 00    	pushl  0x804004
  801802:	e8 8d f9 ff ff       	call   801194 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801807:	83 c4 0c             	add    $0xc,%esp
  80180a:	6a 00                	push   $0x0
  80180c:	53                   	push   %ebx
  80180d:	6a 00                	push   $0x0
  80180f:	e8 19 f9 ff ff       	call   80112d <ipc_recv>
}
  801814:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801821:	8b 45 08             	mov    0x8(%ebp),%eax
  801824:	8b 40 0c             	mov    0xc(%eax),%eax
  801827:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80182c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801834:	ba 00 00 00 00       	mov    $0x0,%edx
  801839:	b8 02 00 00 00       	mov    $0x2,%eax
  80183e:	e8 8d ff ff ff       	call   8017d0 <fsipc>
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	8b 40 0c             	mov    0xc(%eax),%eax
  801851:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 06 00 00 00       	mov    $0x6,%eax
  801860:	e8 6b ff ff ff       	call   8017d0 <fsipc>
}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	8b 40 0c             	mov    0xc(%eax),%eax
  801877:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187c:	ba 00 00 00 00       	mov    $0x0,%edx
  801881:	b8 05 00 00 00       	mov    $0x5,%eax
  801886:	e8 45 ff ff ff       	call   8017d0 <fsipc>
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 2c                	js     8018bb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	68 00 50 80 00       	push   $0x805000
  801897:	53                   	push   %ebx
  801898:	e8 ed ef ff ff       	call   80088a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189d:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 0c             	sub    $0xc,%esp
  8018c6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8018cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8018cf:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018d5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018da:	50                   	push   %eax
  8018db:	ff 75 0c             	pushl  0xc(%ebp)
  8018de:	68 08 50 80 00       	push   $0x805008
  8018e3:	e8 34 f1 ff ff       	call   800a1c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ed:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f2:	e8 d9 fe ff ff       	call   8017d0 <fsipc>

}
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	56                   	push   %esi
  8018fd:	53                   	push   %ebx
  8018fe:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 40 0c             	mov    0xc(%eax),%eax
  801907:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80190c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801912:	ba 00 00 00 00       	mov    $0x0,%edx
  801917:	b8 03 00 00 00       	mov    $0x3,%eax
  80191c:	e8 af fe ff ff       	call   8017d0 <fsipc>
  801921:	89 c3                	mov    %eax,%ebx
  801923:	85 c0                	test   %eax,%eax
  801925:	78 4b                	js     801972 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801927:	39 c6                	cmp    %eax,%esi
  801929:	73 16                	jae    801941 <devfile_read+0x48>
  80192b:	68 2c 2c 80 00       	push   $0x802c2c
  801930:	68 33 2c 80 00       	push   $0x802c33
  801935:	6a 7c                	push   $0x7c
  801937:	68 48 2c 80 00       	push   $0x802c48
  80193c:	e8 eb e8 ff ff       	call   80022c <_panic>
	assert(r <= PGSIZE);
  801941:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801946:	7e 16                	jle    80195e <devfile_read+0x65>
  801948:	68 53 2c 80 00       	push   $0x802c53
  80194d:	68 33 2c 80 00       	push   $0x802c33
  801952:	6a 7d                	push   $0x7d
  801954:	68 48 2c 80 00       	push   $0x802c48
  801959:	e8 ce e8 ff ff       	call   80022c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80195e:	83 ec 04             	sub    $0x4,%esp
  801961:	50                   	push   %eax
  801962:	68 00 50 80 00       	push   $0x805000
  801967:	ff 75 0c             	pushl  0xc(%ebp)
  80196a:	e8 ad f0 ff ff       	call   800a1c <memmove>
	return r;
  80196f:	83 c4 10             	add    $0x10,%esp
}
  801972:	89 d8                	mov    %ebx,%eax
  801974:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	53                   	push   %ebx
  80197f:	83 ec 20             	sub    $0x20,%esp
  801982:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801985:	53                   	push   %ebx
  801986:	e8 c6 ee ff ff       	call   800851 <strlen>
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801993:	7f 67                	jg     8019fc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801995:	83 ec 0c             	sub    $0xc,%esp
  801998:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199b:	50                   	push   %eax
  80199c:	e8 a7 f8 ff ff       	call   801248 <fd_alloc>
  8019a1:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 57                	js     801a01 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019aa:	83 ec 08             	sub    $0x8,%esp
  8019ad:	53                   	push   %ebx
  8019ae:	68 00 50 80 00       	push   $0x805000
  8019b3:	e8 d2 ee ff ff       	call   80088a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c8:	e8 03 fe ff ff       	call   8017d0 <fsipc>
  8019cd:	89 c3                	mov    %eax,%ebx
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	79 14                	jns    8019ea <open+0x6f>
		fd_close(fd, 0);
  8019d6:	83 ec 08             	sub    $0x8,%esp
  8019d9:	6a 00                	push   $0x0
  8019db:	ff 75 f4             	pushl  -0xc(%ebp)
  8019de:	e8 5d f9 ff ff       	call   801340 <fd_close>
		return r;
  8019e3:	83 c4 10             	add    $0x10,%esp
  8019e6:	89 da                	mov    %ebx,%edx
  8019e8:	eb 17                	jmp    801a01 <open+0x86>
	}

	return fd2num(fd);
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f0:	e8 2c f8 ff ff       	call   801221 <fd2num>
  8019f5:	89 c2                	mov    %eax,%edx
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	eb 05                	jmp    801a01 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019fc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a01:	89 d0                	mov    %edx,%eax
  801a03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a0e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a13:	b8 08 00 00 00       	mov    $0x8,%eax
  801a18:	e8 b3 fd ff ff       	call   8017d0 <fsipc>
}
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
  801a24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	ff 75 08             	pushl  0x8(%ebp)
  801a2d:	e8 ff f7 ff ff       	call   801231 <fd2data>
  801a32:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a34:	83 c4 08             	add    $0x8,%esp
  801a37:	68 5f 2c 80 00       	push   $0x802c5f
  801a3c:	53                   	push   %ebx
  801a3d:	e8 48 ee ff ff       	call   80088a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a42:	8b 46 04             	mov    0x4(%esi),%eax
  801a45:	2b 06                	sub    (%esi),%eax
  801a47:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a4d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a54:	00 00 00 
	stat->st_dev = &devpipe;
  801a57:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a5e:	30 80 00 
	return 0;
}
  801a61:	b8 00 00 00 00       	mov    $0x0,%eax
  801a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	53                   	push   %ebx
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a77:	53                   	push   %ebx
  801a78:	6a 00                	push   $0x0
  801a7a:	e8 93 f2 ff ff       	call   800d12 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a7f:	89 1c 24             	mov    %ebx,(%esp)
  801a82:	e8 aa f7 ff ff       	call   801231 <fd2data>
  801a87:	83 c4 08             	add    $0x8,%esp
  801a8a:	50                   	push   %eax
  801a8b:	6a 00                	push   $0x0
  801a8d:	e8 80 f2 ff ff       	call   800d12 <sys_page_unmap>
}
  801a92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	57                   	push   %edi
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 1c             	sub    $0x1c,%esp
  801aa0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801aaa:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab3:	e8 18 09 00 00       	call   8023d0 <pageref>
  801ab8:	89 c3                	mov    %eax,%ebx
  801aba:	89 3c 24             	mov    %edi,(%esp)
  801abd:	e8 0e 09 00 00       	call   8023d0 <pageref>
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	39 c3                	cmp    %eax,%ebx
  801ac7:	0f 94 c1             	sete   %cl
  801aca:	0f b6 c9             	movzbl %cl,%ecx
  801acd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ad0:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801ad6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ad9:	39 ce                	cmp    %ecx,%esi
  801adb:	74 1b                	je     801af8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801add:	39 c3                	cmp    %eax,%ebx
  801adf:	75 c4                	jne    801aa5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae1:	8b 42 58             	mov    0x58(%edx),%eax
  801ae4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae7:	50                   	push   %eax
  801ae8:	56                   	push   %esi
  801ae9:	68 66 2c 80 00       	push   $0x802c66
  801aee:	e8 12 e8 ff ff       	call   800305 <cprintf>
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	eb ad                	jmp    801aa5 <_pipeisclosed+0xe>
	}
}
  801af8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801afb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afe:	5b                   	pop    %ebx
  801aff:	5e                   	pop    %esi
  801b00:	5f                   	pop    %edi
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	57                   	push   %edi
  801b07:	56                   	push   %esi
  801b08:	53                   	push   %ebx
  801b09:	83 ec 28             	sub    $0x28,%esp
  801b0c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b0f:	56                   	push   %esi
  801b10:	e8 1c f7 ff ff       	call   801231 <fd2data>
  801b15:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b1f:	eb 4b                	jmp    801b6c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b21:	89 da                	mov    %ebx,%edx
  801b23:	89 f0                	mov    %esi,%eax
  801b25:	e8 6d ff ff ff       	call   801a97 <_pipeisclosed>
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	75 48                	jne    801b76 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b2e:	e8 3b f1 ff ff       	call   800c6e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b33:	8b 43 04             	mov    0x4(%ebx),%eax
  801b36:	8b 0b                	mov    (%ebx),%ecx
  801b38:	8d 51 20             	lea    0x20(%ecx),%edx
  801b3b:	39 d0                	cmp    %edx,%eax
  801b3d:	73 e2                	jae    801b21 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b42:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b46:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b49:	89 c2                	mov    %eax,%edx
  801b4b:	c1 fa 1f             	sar    $0x1f,%edx
  801b4e:	89 d1                	mov    %edx,%ecx
  801b50:	c1 e9 1b             	shr    $0x1b,%ecx
  801b53:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b56:	83 e2 1f             	and    $0x1f,%edx
  801b59:	29 ca                	sub    %ecx,%edx
  801b5b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b5f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b63:	83 c0 01             	add    $0x1,%eax
  801b66:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b69:	83 c7 01             	add    $0x1,%edi
  801b6c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b6f:	75 c2                	jne    801b33 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b71:	8b 45 10             	mov    0x10(%ebp),%eax
  801b74:	eb 05                	jmp    801b7b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b76:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7e:	5b                   	pop    %ebx
  801b7f:	5e                   	pop    %esi
  801b80:	5f                   	pop    %edi
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	57                   	push   %edi
  801b87:	56                   	push   %esi
  801b88:	53                   	push   %ebx
  801b89:	83 ec 18             	sub    $0x18,%esp
  801b8c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b8f:	57                   	push   %edi
  801b90:	e8 9c f6 ff ff       	call   801231 <fd2data>
  801b95:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b9f:	eb 3d                	jmp    801bde <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ba1:	85 db                	test   %ebx,%ebx
  801ba3:	74 04                	je     801ba9 <devpipe_read+0x26>
				return i;
  801ba5:	89 d8                	mov    %ebx,%eax
  801ba7:	eb 44                	jmp    801bed <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ba9:	89 f2                	mov    %esi,%edx
  801bab:	89 f8                	mov    %edi,%eax
  801bad:	e8 e5 fe ff ff       	call   801a97 <_pipeisclosed>
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	75 32                	jne    801be8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bb6:	e8 b3 f0 ff ff       	call   800c6e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bbb:	8b 06                	mov    (%esi),%eax
  801bbd:	3b 46 04             	cmp    0x4(%esi),%eax
  801bc0:	74 df                	je     801ba1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc2:	99                   	cltd   
  801bc3:	c1 ea 1b             	shr    $0x1b,%edx
  801bc6:	01 d0                	add    %edx,%eax
  801bc8:	83 e0 1f             	and    $0x1f,%eax
  801bcb:	29 d0                	sub    %edx,%eax
  801bcd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bd8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdb:	83 c3 01             	add    $0x1,%ebx
  801bde:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be1:	75 d8                	jne    801bbb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be3:	8b 45 10             	mov    0x10(%ebp),%eax
  801be6:	eb 05                	jmp    801bed <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf0:	5b                   	pop    %ebx
  801bf1:	5e                   	pop    %esi
  801bf2:	5f                   	pop    %edi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	56                   	push   %esi
  801bf9:	53                   	push   %ebx
  801bfa:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bfd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c00:	50                   	push   %eax
  801c01:	e8 42 f6 ff ff       	call   801248 <fd_alloc>
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	89 c2                	mov    %eax,%edx
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	0f 88 2c 01 00 00    	js     801d3f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	68 07 04 00 00       	push   $0x407
  801c1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1e:	6a 00                	push   $0x0
  801c20:	e8 68 f0 ff ff       	call   800c8d <sys_page_alloc>
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	89 c2                	mov    %eax,%edx
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	0f 88 0d 01 00 00    	js     801d3f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c32:	83 ec 0c             	sub    $0xc,%esp
  801c35:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c38:	50                   	push   %eax
  801c39:	e8 0a f6 ff ff       	call   801248 <fd_alloc>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	0f 88 e2 00 00 00    	js     801d2d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4b:	83 ec 04             	sub    $0x4,%esp
  801c4e:	68 07 04 00 00       	push   $0x407
  801c53:	ff 75 f0             	pushl  -0x10(%ebp)
  801c56:	6a 00                	push   $0x0
  801c58:	e8 30 f0 ff ff       	call   800c8d <sys_page_alloc>
  801c5d:	89 c3                	mov    %eax,%ebx
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	85 c0                	test   %eax,%eax
  801c64:	0f 88 c3 00 00 00    	js     801d2d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c70:	e8 bc f5 ff ff       	call   801231 <fd2data>
  801c75:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c77:	83 c4 0c             	add    $0xc,%esp
  801c7a:	68 07 04 00 00       	push   $0x407
  801c7f:	50                   	push   %eax
  801c80:	6a 00                	push   $0x0
  801c82:	e8 06 f0 ff ff       	call   800c8d <sys_page_alloc>
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	0f 88 89 00 00 00    	js     801d1d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9a:	e8 92 f5 ff ff       	call   801231 <fd2data>
  801c9f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ca6:	50                   	push   %eax
  801ca7:	6a 00                	push   $0x0
  801ca9:	56                   	push   %esi
  801caa:	6a 00                	push   $0x0
  801cac:	e8 1f f0 ff ff       	call   800cd0 <sys_page_map>
  801cb1:	89 c3                	mov    %eax,%ebx
  801cb3:	83 c4 20             	add    $0x20,%esp
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	78 55                	js     801d0f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cba:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ccf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cdd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cea:	e8 32 f5 ff ff       	call   801221 <fd2num>
  801cef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cf4:	83 c4 04             	add    $0x4,%esp
  801cf7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfa:	e8 22 f5 ff ff       	call   801221 <fd2num>
  801cff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d02:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0d:	eb 30                	jmp    801d3f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d0f:	83 ec 08             	sub    $0x8,%esp
  801d12:	56                   	push   %esi
  801d13:	6a 00                	push   $0x0
  801d15:	e8 f8 ef ff ff       	call   800d12 <sys_page_unmap>
  801d1a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d1d:	83 ec 08             	sub    $0x8,%esp
  801d20:	ff 75 f0             	pushl  -0x10(%ebp)
  801d23:	6a 00                	push   $0x0
  801d25:	e8 e8 ef ff ff       	call   800d12 <sys_page_unmap>
  801d2a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d2d:	83 ec 08             	sub    $0x8,%esp
  801d30:	ff 75 f4             	pushl  -0xc(%ebp)
  801d33:	6a 00                	push   $0x0
  801d35:	e8 d8 ef ff ff       	call   800d12 <sys_page_unmap>
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d3f:	89 d0                	mov    %edx,%eax
  801d41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    

00801d48 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d51:	50                   	push   %eax
  801d52:	ff 75 08             	pushl  0x8(%ebp)
  801d55:	e8 3d f5 ff ff       	call   801297 <fd_lookup>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 18                	js     801d79 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d61:	83 ec 0c             	sub    $0xc,%esp
  801d64:	ff 75 f4             	pushl  -0xc(%ebp)
  801d67:	e8 c5 f4 ff ff       	call   801231 <fd2data>
	return _pipeisclosed(fd, p);
  801d6c:	89 c2                	mov    %eax,%edx
  801d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d71:	e8 21 fd ff ff       	call   801a97 <_pipeisclosed>
  801d76:	83 c4 10             	add    $0x10,%esp
}
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d81:	68 7e 2c 80 00       	push   $0x802c7e
  801d86:	ff 75 0c             	pushl  0xc(%ebp)
  801d89:	e8 fc ea ff ff       	call   80088a <strcpy>
	return 0;
}
  801d8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	53                   	push   %ebx
  801d99:	83 ec 10             	sub    $0x10,%esp
  801d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d9f:	53                   	push   %ebx
  801da0:	e8 2b 06 00 00       	call   8023d0 <pageref>
  801da5:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801da8:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801dad:	83 f8 01             	cmp    $0x1,%eax
  801db0:	75 10                	jne    801dc2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801db2:	83 ec 0c             	sub    $0xc,%esp
  801db5:	ff 73 0c             	pushl  0xc(%ebx)
  801db8:	e8 c0 02 00 00       	call   80207d <nsipc_close>
  801dbd:	89 c2                	mov    %eax,%edx
  801dbf:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801dc2:	89 d0                	mov    %edx,%eax
  801dc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    

00801dc9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801dcf:	6a 00                	push   $0x0
  801dd1:	ff 75 10             	pushl  0x10(%ebp)
  801dd4:	ff 75 0c             	pushl  0xc(%ebp)
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dda:	ff 70 0c             	pushl  0xc(%eax)
  801ddd:	e8 78 03 00 00       	call   80215a <nsipc_send>
}
  801de2:	c9                   	leave  
  801de3:	c3                   	ret    

00801de4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801dea:	6a 00                	push   $0x0
  801dec:	ff 75 10             	pushl  0x10(%ebp)
  801def:	ff 75 0c             	pushl  0xc(%ebp)
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	ff 70 0c             	pushl  0xc(%eax)
  801df8:	e8 f1 02 00 00       	call   8020ee <nsipc_recv>
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e05:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e08:	52                   	push   %edx
  801e09:	50                   	push   %eax
  801e0a:	e8 88 f4 ff ff       	call   801297 <fd_lookup>
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 17                	js     801e2d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e19:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801e1f:	39 08                	cmp    %ecx,(%eax)
  801e21:	75 05                	jne    801e28 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e23:	8b 40 0c             	mov    0xc(%eax),%eax
  801e26:	eb 05                	jmp    801e2d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e28:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	83 ec 1c             	sub    $0x1c,%esp
  801e37:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	e8 06 f4 ff ff       	call   801248 <fd_alloc>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 1b                	js     801e66 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e4b:	83 ec 04             	sub    $0x4,%esp
  801e4e:	68 07 04 00 00       	push   $0x407
  801e53:	ff 75 f4             	pushl  -0xc(%ebp)
  801e56:	6a 00                	push   $0x0
  801e58:	e8 30 ee ff ff       	call   800c8d <sys_page_alloc>
  801e5d:	89 c3                	mov    %eax,%ebx
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	85 c0                	test   %eax,%eax
  801e64:	79 10                	jns    801e76 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	56                   	push   %esi
  801e6a:	e8 0e 02 00 00       	call   80207d <nsipc_close>
		return r;
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	89 d8                	mov    %ebx,%eax
  801e74:	eb 24                	jmp    801e9a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e76:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e84:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e8b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	50                   	push   %eax
  801e92:	e8 8a f3 ff ff       	call   801221 <fd2num>
  801e97:	83 c4 10             	add    $0x10,%esp
}
  801e9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaa:	e8 50 ff ff ff       	call   801dff <fd2sockid>
		return r;
  801eaf:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 1f                	js     801ed4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801eb5:	83 ec 04             	sub    $0x4,%esp
  801eb8:	ff 75 10             	pushl  0x10(%ebp)
  801ebb:	ff 75 0c             	pushl  0xc(%ebp)
  801ebe:	50                   	push   %eax
  801ebf:	e8 12 01 00 00       	call   801fd6 <nsipc_accept>
  801ec4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	78 07                	js     801ed4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ecd:	e8 5d ff ff ff       	call   801e2f <alloc_sockfd>
  801ed2:	89 c1                	mov    %eax,%ecx
}
  801ed4:	89 c8                	mov    %ecx,%eax
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ede:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee1:	e8 19 ff ff ff       	call   801dff <fd2sockid>
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	78 12                	js     801efc <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801eea:	83 ec 04             	sub    $0x4,%esp
  801eed:	ff 75 10             	pushl  0x10(%ebp)
  801ef0:	ff 75 0c             	pushl  0xc(%ebp)
  801ef3:	50                   	push   %eax
  801ef4:	e8 2d 01 00 00       	call   802026 <nsipc_bind>
  801ef9:	83 c4 10             	add    $0x10,%esp
}
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <shutdown>:

int
shutdown(int s, int how)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	e8 f3 fe ff ff       	call   801dff <fd2sockid>
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 0f                	js     801f1f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f10:	83 ec 08             	sub    $0x8,%esp
  801f13:	ff 75 0c             	pushl  0xc(%ebp)
  801f16:	50                   	push   %eax
  801f17:	e8 3f 01 00 00       	call   80205b <nsipc_shutdown>
  801f1c:	83 c4 10             	add    $0x10,%esp
}
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    

00801f21 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f27:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2a:	e8 d0 fe ff ff       	call   801dff <fd2sockid>
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 12                	js     801f45 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801f33:	83 ec 04             	sub    $0x4,%esp
  801f36:	ff 75 10             	pushl  0x10(%ebp)
  801f39:	ff 75 0c             	pushl  0xc(%ebp)
  801f3c:	50                   	push   %eax
  801f3d:	e8 55 01 00 00       	call   802097 <nsipc_connect>
  801f42:	83 c4 10             	add    $0x10,%esp
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <listen>:

int
listen(int s, int backlog)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f50:	e8 aa fe ff ff       	call   801dff <fd2sockid>
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 0f                	js     801f68 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f59:	83 ec 08             	sub    $0x8,%esp
  801f5c:	ff 75 0c             	pushl  0xc(%ebp)
  801f5f:	50                   	push   %eax
  801f60:	e8 67 01 00 00       	call   8020cc <nsipc_listen>
  801f65:	83 c4 10             	add    $0x10,%esp
}
  801f68:	c9                   	leave  
  801f69:	c3                   	ret    

00801f6a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f70:	ff 75 10             	pushl  0x10(%ebp)
  801f73:	ff 75 0c             	pushl  0xc(%ebp)
  801f76:	ff 75 08             	pushl  0x8(%ebp)
  801f79:	e8 3a 02 00 00       	call   8021b8 <nsipc_socket>
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	85 c0                	test   %eax,%eax
  801f83:	78 05                	js     801f8a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f85:	e8 a5 fe ff ff       	call   801e2f <alloc_sockfd>
}
  801f8a:	c9                   	leave  
  801f8b:	c3                   	ret    

00801f8c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	53                   	push   %ebx
  801f90:	83 ec 04             	sub    $0x4,%esp
  801f93:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f95:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801f9c:	75 12                	jne    801fb0 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f9e:	83 ec 0c             	sub    $0xc,%esp
  801fa1:	6a 02                	push   $0x2
  801fa3:	e8 40 f2 ff ff       	call   8011e8 <ipc_find_env>
  801fa8:	a3 08 40 80 00       	mov    %eax,0x804008
  801fad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fb0:	6a 07                	push   $0x7
  801fb2:	68 00 60 80 00       	push   $0x806000
  801fb7:	53                   	push   %ebx
  801fb8:	ff 35 08 40 80 00    	pushl  0x804008
  801fbe:	e8 d1 f1 ff ff       	call   801194 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fc3:	83 c4 0c             	add    $0xc,%esp
  801fc6:	6a 00                	push   $0x0
  801fc8:	6a 00                	push   $0x0
  801fca:	6a 00                	push   $0x0
  801fcc:	e8 5c f1 ff ff       	call   80112d <ipc_recv>
}
  801fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd4:	c9                   	leave  
  801fd5:	c3                   	ret    

00801fd6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	56                   	push   %esi
  801fda:	53                   	push   %ebx
  801fdb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fde:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801fe6:	8b 06                	mov    (%esi),%eax
  801fe8:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fed:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff2:	e8 95 ff ff ff       	call   801f8c <nsipc>
  801ff7:	89 c3                	mov    %eax,%ebx
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	78 20                	js     80201d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ffd:	83 ec 04             	sub    $0x4,%esp
  802000:	ff 35 10 60 80 00    	pushl  0x806010
  802006:	68 00 60 80 00       	push   $0x806000
  80200b:	ff 75 0c             	pushl  0xc(%ebp)
  80200e:	e8 09 ea ff ff       	call   800a1c <memmove>
		*addrlen = ret->ret_addrlen;
  802013:	a1 10 60 80 00       	mov    0x806010,%eax
  802018:	89 06                	mov    %eax,(%esi)
  80201a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80201d:	89 d8                	mov    %ebx,%eax
  80201f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802022:	5b                   	pop    %ebx
  802023:	5e                   	pop    %esi
  802024:	5d                   	pop    %ebp
  802025:	c3                   	ret    

00802026 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	53                   	push   %ebx
  80202a:	83 ec 08             	sub    $0x8,%esp
  80202d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802030:	8b 45 08             	mov    0x8(%ebp),%eax
  802033:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802038:	53                   	push   %ebx
  802039:	ff 75 0c             	pushl  0xc(%ebp)
  80203c:	68 04 60 80 00       	push   $0x806004
  802041:	e8 d6 e9 ff ff       	call   800a1c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802046:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80204c:	b8 02 00 00 00       	mov    $0x2,%eax
  802051:	e8 36 ff ff ff       	call   801f8c <nsipc>
}
  802056:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802059:	c9                   	leave  
  80205a:	c3                   	ret    

0080205b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802061:	8b 45 08             	mov    0x8(%ebp),%eax
  802064:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  802069:	8b 45 0c             	mov    0xc(%ebp),%eax
  80206c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802071:	b8 03 00 00 00       	mov    $0x3,%eax
  802076:	e8 11 ff ff ff       	call   801f8c <nsipc>
}
  80207b:	c9                   	leave  
  80207c:	c3                   	ret    

0080207d <nsipc_close>:

int
nsipc_close(int s)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802083:	8b 45 08             	mov    0x8(%ebp),%eax
  802086:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80208b:	b8 04 00 00 00       	mov    $0x4,%eax
  802090:	e8 f7 fe ff ff       	call   801f8c <nsipc>
}
  802095:	c9                   	leave  
  802096:	c3                   	ret    

00802097 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	53                   	push   %ebx
  80209b:	83 ec 08             	sub    $0x8,%esp
  80209e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020a9:	53                   	push   %ebx
  8020aa:	ff 75 0c             	pushl  0xc(%ebp)
  8020ad:	68 04 60 80 00       	push   $0x806004
  8020b2:	e8 65 e9 ff ff       	call   800a1c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020b7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8020bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8020c2:	e8 c5 fe ff ff       	call   801f8c <nsipc>
}
  8020c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ca:	c9                   	leave  
  8020cb:	c3                   	ret    

008020cc <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8020da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020dd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8020e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8020e7:	e8 a0 fe ff ff       	call   801f8c <nsipc>
}
  8020ec:	c9                   	leave  
  8020ed:	c3                   	ret    

008020ee <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	56                   	push   %esi
  8020f2:	53                   	push   %ebx
  8020f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8020fe:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802104:	8b 45 14             	mov    0x14(%ebp),%eax
  802107:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80210c:	b8 07 00 00 00       	mov    $0x7,%eax
  802111:	e8 76 fe ff ff       	call   801f8c <nsipc>
  802116:	89 c3                	mov    %eax,%ebx
  802118:	85 c0                	test   %eax,%eax
  80211a:	78 35                	js     802151 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80211c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802121:	7f 04                	jg     802127 <nsipc_recv+0x39>
  802123:	39 c6                	cmp    %eax,%esi
  802125:	7d 16                	jge    80213d <nsipc_recv+0x4f>
  802127:	68 8a 2c 80 00       	push   $0x802c8a
  80212c:	68 33 2c 80 00       	push   $0x802c33
  802131:	6a 62                	push   $0x62
  802133:	68 9f 2c 80 00       	push   $0x802c9f
  802138:	e8 ef e0 ff ff       	call   80022c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80213d:	83 ec 04             	sub    $0x4,%esp
  802140:	50                   	push   %eax
  802141:	68 00 60 80 00       	push   $0x806000
  802146:	ff 75 0c             	pushl  0xc(%ebp)
  802149:	e8 ce e8 ff ff       	call   800a1c <memmove>
  80214e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802151:	89 d8                	mov    %ebx,%eax
  802153:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802156:	5b                   	pop    %ebx
  802157:	5e                   	pop    %esi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    

0080215a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	53                   	push   %ebx
  80215e:	83 ec 04             	sub    $0x4,%esp
  802161:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802164:	8b 45 08             	mov    0x8(%ebp),%eax
  802167:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80216c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802172:	7e 16                	jle    80218a <nsipc_send+0x30>
  802174:	68 ab 2c 80 00       	push   $0x802cab
  802179:	68 33 2c 80 00       	push   $0x802c33
  80217e:	6a 6d                	push   $0x6d
  802180:	68 9f 2c 80 00       	push   $0x802c9f
  802185:	e8 a2 e0 ff ff       	call   80022c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80218a:	83 ec 04             	sub    $0x4,%esp
  80218d:	53                   	push   %ebx
  80218e:	ff 75 0c             	pushl  0xc(%ebp)
  802191:	68 0c 60 80 00       	push   $0x80600c
  802196:	e8 81 e8 ff ff       	call   800a1c <memmove>
	nsipcbuf.send.req_size = size;
  80219b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8021a4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8021a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8021ae:	e8 d9 fd ff ff       	call   801f8c <nsipc>
}
  8021b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021b6:	c9                   	leave  
  8021b7:	c3                   	ret    

008021b8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021be:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8021c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c9:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8021ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8021d1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8021d6:	b8 09 00 00 00       	mov    $0x9,%eax
  8021db:	e8 ac fd ff ff       	call   801f8c <nsipc>
}
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    

008021e2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    

008021ec <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021f2:	68 b7 2c 80 00       	push   $0x802cb7
  8021f7:	ff 75 0c             	pushl  0xc(%ebp)
  8021fa:	e8 8b e6 ff ff       	call   80088a <strcpy>
	return 0;
}
  8021ff:	b8 00 00 00 00       	mov    $0x0,%eax
  802204:	c9                   	leave  
  802205:	c3                   	ret    

00802206 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802206:	55                   	push   %ebp
  802207:	89 e5                	mov    %esp,%ebp
  802209:	57                   	push   %edi
  80220a:	56                   	push   %esi
  80220b:	53                   	push   %ebx
  80220c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802212:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802217:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80221d:	eb 2d                	jmp    80224c <devcons_write+0x46>
		m = n - tot;
  80221f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802222:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802224:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802227:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80222c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80222f:	83 ec 04             	sub    $0x4,%esp
  802232:	53                   	push   %ebx
  802233:	03 45 0c             	add    0xc(%ebp),%eax
  802236:	50                   	push   %eax
  802237:	57                   	push   %edi
  802238:	e8 df e7 ff ff       	call   800a1c <memmove>
		sys_cputs(buf, m);
  80223d:	83 c4 08             	add    $0x8,%esp
  802240:	53                   	push   %ebx
  802241:	57                   	push   %edi
  802242:	e8 8a e9 ff ff       	call   800bd1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802247:	01 de                	add    %ebx,%esi
  802249:	83 c4 10             	add    $0x10,%esp
  80224c:	89 f0                	mov    %esi,%eax
  80224e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802251:	72 cc                	jb     80221f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802256:	5b                   	pop    %ebx
  802257:	5e                   	pop    %esi
  802258:	5f                   	pop    %edi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    

0080225b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	83 ec 08             	sub    $0x8,%esp
  802261:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802266:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80226a:	74 2a                	je     802296 <devcons_read+0x3b>
  80226c:	eb 05                	jmp    802273 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80226e:	e8 fb e9 ff ff       	call   800c6e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802273:	e8 77 e9 ff ff       	call   800bef <sys_cgetc>
  802278:	85 c0                	test   %eax,%eax
  80227a:	74 f2                	je     80226e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80227c:	85 c0                	test   %eax,%eax
  80227e:	78 16                	js     802296 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802280:	83 f8 04             	cmp    $0x4,%eax
  802283:	74 0c                	je     802291 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802285:	8b 55 0c             	mov    0xc(%ebp),%edx
  802288:	88 02                	mov    %al,(%edx)
	return 1;
  80228a:	b8 01 00 00 00       	mov    $0x1,%eax
  80228f:	eb 05                	jmp    802296 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802291:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802296:	c9                   	leave  
  802297:	c3                   	ret    

00802298 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802298:	55                   	push   %ebp
  802299:	89 e5                	mov    %esp,%ebp
  80229b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80229e:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022a4:	6a 01                	push   $0x1
  8022a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a9:	50                   	push   %eax
  8022aa:	e8 22 e9 ff ff       	call   800bd1 <sys_cputs>
}
  8022af:	83 c4 10             	add    $0x10,%esp
  8022b2:	c9                   	leave  
  8022b3:	c3                   	ret    

008022b4 <getchar>:

int
getchar(void)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022ba:	6a 01                	push   $0x1
  8022bc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022bf:	50                   	push   %eax
  8022c0:	6a 00                	push   $0x0
  8022c2:	e8 36 f2 ff ff       	call   8014fd <read>
	if (r < 0)
  8022c7:	83 c4 10             	add    $0x10,%esp
  8022ca:	85 c0                	test   %eax,%eax
  8022cc:	78 0f                	js     8022dd <getchar+0x29>
		return r;
	if (r < 1)
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	7e 06                	jle    8022d8 <getchar+0x24>
		return -E_EOF;
	return c;
  8022d2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022d6:	eb 05                	jmp    8022dd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022d8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022dd:	c9                   	leave  
  8022de:	c3                   	ret    

008022df <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022df:	55                   	push   %ebp
  8022e0:	89 e5                	mov    %esp,%ebp
  8022e2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e8:	50                   	push   %eax
  8022e9:	ff 75 08             	pushl  0x8(%ebp)
  8022ec:	e8 a6 ef ff ff       	call   801297 <fd_lookup>
  8022f1:	83 c4 10             	add    $0x10,%esp
  8022f4:	85 c0                	test   %eax,%eax
  8022f6:	78 11                	js     802309 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802301:	39 10                	cmp    %edx,(%eax)
  802303:	0f 94 c0             	sete   %al
  802306:	0f b6 c0             	movzbl %al,%eax
}
  802309:	c9                   	leave  
  80230a:	c3                   	ret    

0080230b <opencons>:

int
opencons(void)
{
  80230b:	55                   	push   %ebp
  80230c:	89 e5                	mov    %esp,%ebp
  80230e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802314:	50                   	push   %eax
  802315:	e8 2e ef ff ff       	call   801248 <fd_alloc>
  80231a:	83 c4 10             	add    $0x10,%esp
		return r;
  80231d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80231f:	85 c0                	test   %eax,%eax
  802321:	78 3e                	js     802361 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802323:	83 ec 04             	sub    $0x4,%esp
  802326:	68 07 04 00 00       	push   $0x407
  80232b:	ff 75 f4             	pushl  -0xc(%ebp)
  80232e:	6a 00                	push   $0x0
  802330:	e8 58 e9 ff ff       	call   800c8d <sys_page_alloc>
  802335:	83 c4 10             	add    $0x10,%esp
		return r;
  802338:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80233a:	85 c0                	test   %eax,%eax
  80233c:	78 23                	js     802361 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80233e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802344:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802347:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802353:	83 ec 0c             	sub    $0xc,%esp
  802356:	50                   	push   %eax
  802357:	e8 c5 ee ff ff       	call   801221 <fd2num>
  80235c:	89 c2                	mov    %eax,%edx
  80235e:	83 c4 10             	add    $0x10,%esp
}
  802361:	89 d0                	mov    %edx,%eax
  802363:	c9                   	leave  
  802364:	c3                   	ret    

00802365 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802365:	55                   	push   %ebp
  802366:	89 e5                	mov    %esp,%ebp
  802368:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80236b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802372:	75 2e                	jne    8023a2 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802374:	e8 d6 e8 ff ff       	call   800c4f <sys_getenvid>
  802379:	83 ec 04             	sub    $0x4,%esp
  80237c:	68 07 0e 00 00       	push   $0xe07
  802381:	68 00 f0 bf ee       	push   $0xeebff000
  802386:	50                   	push   %eax
  802387:	e8 01 e9 ff ff       	call   800c8d <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80238c:	e8 be e8 ff ff       	call   800c4f <sys_getenvid>
  802391:	83 c4 08             	add    $0x8,%esp
  802394:	68 ac 23 80 00       	push   $0x8023ac
  802399:	50                   	push   %eax
  80239a:	e8 39 ea ff ff       	call   800dd8 <sys_env_set_pgfault_upcall>
  80239f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a5:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023aa:	c9                   	leave  
  8023ab:	c3                   	ret    

008023ac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023ac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023ad:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023b2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023b4:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8023b7:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8023bb:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8023bf:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8023c2:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8023c5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8023c6:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8023c9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8023ca:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8023cb:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8023cf:	c3                   	ret    

008023d0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d6:	89 d0                	mov    %edx,%eax
  8023d8:	c1 e8 16             	shr    $0x16,%eax
  8023db:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023e2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e7:	f6 c1 01             	test   $0x1,%cl
  8023ea:	74 1d                	je     802409 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023ec:	c1 ea 0c             	shr    $0xc,%edx
  8023ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023f6:	f6 c2 01             	test   $0x1,%dl
  8023f9:	74 0e                	je     802409 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023fb:	c1 ea 0c             	shr    $0xc,%edx
  8023fe:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802405:	ef 
  802406:	0f b7 c0             	movzwl %ax,%eax
}
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    
  80240b:	66 90                	xchg   %ax,%ax
  80240d:	66 90                	xchg   %ax,%ax
  80240f:	90                   	nop

00802410 <__udivdi3>:
  802410:	55                   	push   %ebp
  802411:	57                   	push   %edi
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 1c             	sub    $0x1c,%esp
  802417:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80241b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80241f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802427:	85 f6                	test   %esi,%esi
  802429:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80242d:	89 ca                	mov    %ecx,%edx
  80242f:	89 f8                	mov    %edi,%eax
  802431:	75 3d                	jne    802470 <__udivdi3+0x60>
  802433:	39 cf                	cmp    %ecx,%edi
  802435:	0f 87 c5 00 00 00    	ja     802500 <__udivdi3+0xf0>
  80243b:	85 ff                	test   %edi,%edi
  80243d:	89 fd                	mov    %edi,%ebp
  80243f:	75 0b                	jne    80244c <__udivdi3+0x3c>
  802441:	b8 01 00 00 00       	mov    $0x1,%eax
  802446:	31 d2                	xor    %edx,%edx
  802448:	f7 f7                	div    %edi
  80244a:	89 c5                	mov    %eax,%ebp
  80244c:	89 c8                	mov    %ecx,%eax
  80244e:	31 d2                	xor    %edx,%edx
  802450:	f7 f5                	div    %ebp
  802452:	89 c1                	mov    %eax,%ecx
  802454:	89 d8                	mov    %ebx,%eax
  802456:	89 cf                	mov    %ecx,%edi
  802458:	f7 f5                	div    %ebp
  80245a:	89 c3                	mov    %eax,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	39 ce                	cmp    %ecx,%esi
  802472:	77 74                	ja     8024e8 <__udivdi3+0xd8>
  802474:	0f bd fe             	bsr    %esi,%edi
  802477:	83 f7 1f             	xor    $0x1f,%edi
  80247a:	0f 84 98 00 00 00    	je     802518 <__udivdi3+0x108>
  802480:	bb 20 00 00 00       	mov    $0x20,%ebx
  802485:	89 f9                	mov    %edi,%ecx
  802487:	89 c5                	mov    %eax,%ebp
  802489:	29 fb                	sub    %edi,%ebx
  80248b:	d3 e6                	shl    %cl,%esi
  80248d:	89 d9                	mov    %ebx,%ecx
  80248f:	d3 ed                	shr    %cl,%ebp
  802491:	89 f9                	mov    %edi,%ecx
  802493:	d3 e0                	shl    %cl,%eax
  802495:	09 ee                	or     %ebp,%esi
  802497:	89 d9                	mov    %ebx,%ecx
  802499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249d:	89 d5                	mov    %edx,%ebp
  80249f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024a3:	d3 ed                	shr    %cl,%ebp
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	d3 e2                	shl    %cl,%edx
  8024a9:	89 d9                	mov    %ebx,%ecx
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	09 c2                	or     %eax,%edx
  8024af:	89 d0                	mov    %edx,%eax
  8024b1:	89 ea                	mov    %ebp,%edx
  8024b3:	f7 f6                	div    %esi
  8024b5:	89 d5                	mov    %edx,%ebp
  8024b7:	89 c3                	mov    %eax,%ebx
  8024b9:	f7 64 24 0c          	mull   0xc(%esp)
  8024bd:	39 d5                	cmp    %edx,%ebp
  8024bf:	72 10                	jb     8024d1 <__udivdi3+0xc1>
  8024c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e6                	shl    %cl,%esi
  8024c9:	39 c6                	cmp    %eax,%esi
  8024cb:	73 07                	jae    8024d4 <__udivdi3+0xc4>
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	75 03                	jne    8024d4 <__udivdi3+0xc4>
  8024d1:	83 eb 01             	sub    $0x1,%ebx
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 d8                	mov    %ebx,%eax
  8024d8:	89 fa                	mov    %edi,%edx
  8024da:	83 c4 1c             	add    $0x1c,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	31 ff                	xor    %edi,%edi
  8024ea:	31 db                	xor    %ebx,%ebx
  8024ec:	89 d8                	mov    %ebx,%eax
  8024ee:	89 fa                	mov    %edi,%edx
  8024f0:	83 c4 1c             	add    $0x1c,%esp
  8024f3:	5b                   	pop    %ebx
  8024f4:	5e                   	pop    %esi
  8024f5:	5f                   	pop    %edi
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    
  8024f8:	90                   	nop
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 d8                	mov    %ebx,%eax
  802502:	f7 f7                	div    %edi
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 c3                	mov    %eax,%ebx
  802508:	89 d8                	mov    %ebx,%eax
  80250a:	89 fa                	mov    %edi,%edx
  80250c:	83 c4 1c             	add    $0x1c,%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    
  802514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802518:	39 ce                	cmp    %ecx,%esi
  80251a:	72 0c                	jb     802528 <__udivdi3+0x118>
  80251c:	31 db                	xor    %ebx,%ebx
  80251e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802522:	0f 87 34 ff ff ff    	ja     80245c <__udivdi3+0x4c>
  802528:	bb 01 00 00 00       	mov    $0x1,%ebx
  80252d:	e9 2a ff ff ff       	jmp    80245c <__udivdi3+0x4c>
  802532:	66 90                	xchg   %ax,%ax
  802534:	66 90                	xchg   %ax,%ax
  802536:	66 90                	xchg   %ax,%ax
  802538:	66 90                	xchg   %ax,%ax
  80253a:	66 90                	xchg   %ax,%ax
  80253c:	66 90                	xchg   %ax,%ax
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__umoddi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 1c             	sub    $0x1c,%esp
  802547:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80254b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80254f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802557:	85 d2                	test   %edx,%edx
  802559:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80255d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802561:	89 f3                	mov    %esi,%ebx
  802563:	89 3c 24             	mov    %edi,(%esp)
  802566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80256a:	75 1c                	jne    802588 <__umoddi3+0x48>
  80256c:	39 f7                	cmp    %esi,%edi
  80256e:	76 50                	jbe    8025c0 <__umoddi3+0x80>
  802570:	89 c8                	mov    %ecx,%eax
  802572:	89 f2                	mov    %esi,%edx
  802574:	f7 f7                	div    %edi
  802576:	89 d0                	mov    %edx,%eax
  802578:	31 d2                	xor    %edx,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	39 f2                	cmp    %esi,%edx
  80258a:	89 d0                	mov    %edx,%eax
  80258c:	77 52                	ja     8025e0 <__umoddi3+0xa0>
  80258e:	0f bd ea             	bsr    %edx,%ebp
  802591:	83 f5 1f             	xor    $0x1f,%ebp
  802594:	75 5a                	jne    8025f0 <__umoddi3+0xb0>
  802596:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80259a:	0f 82 e0 00 00 00    	jb     802680 <__umoddi3+0x140>
  8025a0:	39 0c 24             	cmp    %ecx,(%esp)
  8025a3:	0f 86 d7 00 00 00    	jbe    802680 <__umoddi3+0x140>
  8025a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025b1:	83 c4 1c             	add    $0x1c,%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    
  8025b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	85 ff                	test   %edi,%edi
  8025c2:	89 fd                	mov    %edi,%ebp
  8025c4:	75 0b                	jne    8025d1 <__umoddi3+0x91>
  8025c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	f7 f7                	div    %edi
  8025cf:	89 c5                	mov    %eax,%ebp
  8025d1:	89 f0                	mov    %esi,%eax
  8025d3:	31 d2                	xor    %edx,%edx
  8025d5:	f7 f5                	div    %ebp
  8025d7:	89 c8                	mov    %ecx,%eax
  8025d9:	f7 f5                	div    %ebp
  8025db:	89 d0                	mov    %edx,%eax
  8025dd:	eb 99                	jmp    802578 <__umoddi3+0x38>
  8025df:	90                   	nop
  8025e0:	89 c8                	mov    %ecx,%eax
  8025e2:	89 f2                	mov    %esi,%edx
  8025e4:	83 c4 1c             	add    $0x1c,%esp
  8025e7:	5b                   	pop    %ebx
  8025e8:	5e                   	pop    %esi
  8025e9:	5f                   	pop    %edi
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    
  8025ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	8b 34 24             	mov    (%esp),%esi
  8025f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025f8:	89 e9                	mov    %ebp,%ecx
  8025fa:	29 ef                	sub    %ebp,%edi
  8025fc:	d3 e0                	shl    %cl,%eax
  8025fe:	89 f9                	mov    %edi,%ecx
  802600:	89 f2                	mov    %esi,%edx
  802602:	d3 ea                	shr    %cl,%edx
  802604:	89 e9                	mov    %ebp,%ecx
  802606:	09 c2                	or     %eax,%edx
  802608:	89 d8                	mov    %ebx,%eax
  80260a:	89 14 24             	mov    %edx,(%esp)
  80260d:	89 f2                	mov    %esi,%edx
  80260f:	d3 e2                	shl    %cl,%edx
  802611:	89 f9                	mov    %edi,%ecx
  802613:	89 54 24 04          	mov    %edx,0x4(%esp)
  802617:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80261b:	d3 e8                	shr    %cl,%eax
  80261d:	89 e9                	mov    %ebp,%ecx
  80261f:	89 c6                	mov    %eax,%esi
  802621:	d3 e3                	shl    %cl,%ebx
  802623:	89 f9                	mov    %edi,%ecx
  802625:	89 d0                	mov    %edx,%eax
  802627:	d3 e8                	shr    %cl,%eax
  802629:	89 e9                	mov    %ebp,%ecx
  80262b:	09 d8                	or     %ebx,%eax
  80262d:	89 d3                	mov    %edx,%ebx
  80262f:	89 f2                	mov    %esi,%edx
  802631:	f7 34 24             	divl   (%esp)
  802634:	89 d6                	mov    %edx,%esi
  802636:	d3 e3                	shl    %cl,%ebx
  802638:	f7 64 24 04          	mull   0x4(%esp)
  80263c:	39 d6                	cmp    %edx,%esi
  80263e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802642:	89 d1                	mov    %edx,%ecx
  802644:	89 c3                	mov    %eax,%ebx
  802646:	72 08                	jb     802650 <__umoddi3+0x110>
  802648:	75 11                	jne    80265b <__umoddi3+0x11b>
  80264a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80264e:	73 0b                	jae    80265b <__umoddi3+0x11b>
  802650:	2b 44 24 04          	sub    0x4(%esp),%eax
  802654:	1b 14 24             	sbb    (%esp),%edx
  802657:	89 d1                	mov    %edx,%ecx
  802659:	89 c3                	mov    %eax,%ebx
  80265b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80265f:	29 da                	sub    %ebx,%edx
  802661:	19 ce                	sbb    %ecx,%esi
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 f0                	mov    %esi,%eax
  802667:	d3 e0                	shl    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	d3 ea                	shr    %cl,%edx
  80266d:	89 e9                	mov    %ebp,%ecx
  80266f:	d3 ee                	shr    %cl,%esi
  802671:	09 d0                	or     %edx,%eax
  802673:	89 f2                	mov    %esi,%edx
  802675:	83 c4 1c             	add    $0x1c,%esp
  802678:	5b                   	pop    %ebx
  802679:	5e                   	pop    %esi
  80267a:	5f                   	pop    %edi
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    
  80267d:	8d 76 00             	lea    0x0(%esi),%esi
  802680:	29 f9                	sub    %edi,%ecx
  802682:	19 d6                	sbb    %edx,%esi
  802684:	89 74 24 04          	mov    %esi,0x4(%esp)
  802688:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80268c:	e9 18 ff ff ff       	jmp    8025a9 <__umoddi3+0x69>
