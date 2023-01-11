
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 5c 18 00 00       	call   8018ab <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 52 18 00 00       	call   8018ab <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 a0 2e 80 00 	movl   $0x802ea0,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 0b 2f 80 00 	movl   $0x802f0b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 06 0e 00 00       	call   800e89 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 b3 16 00 00       	call   801745 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 1a 2f 80 00       	push   $0x802f1a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 d1 0d 00 00       	call   800e89 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 7e 16 00 00       	call   801745 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 15 2f 80 00       	push   $0x802f15
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 0e 15 00 00       	call   801609 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 02 15 00 00       	call   801609 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 28 2f 80 00       	push   $0x802f28
  80011b:	e8 a3 1a 00 00       	call   801bc3 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 35 2f 80 00       	push   $0x802f35
  80012f:	6a 13                	push   $0x13
  800131:	68 4b 2f 80 00       	push   $0x802f4b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 4d 27 00 00       	call   802894 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 5c 2f 80 00       	push   $0x802f5c
  800154:	6a 15                	push   $0x15
  800156:	68 4b 2f 80 00       	push   $0x802f4b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 c4 2e 80 00       	push   $0x802ec4
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 3d 11 00 00       	call   8012b2 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 65 2f 80 00       	push   $0x802f65
  800182:	6a 1a                	push   $0x1a
  800184:	68 4b 2f 80 00       	push   $0x802f4b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 bc 14 00 00       	call   801659 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 b1 14 00 00       	call   801659 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 59 14 00 00       	call   801609 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 51 14 00 00       	call   801609 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 6e 2f 80 00       	push   $0x802f6e
  8001bf:	68 32 2f 80 00       	push   $0x802f32
  8001c4:	68 71 2f 80 00       	push   $0x802f71
  8001c9:	e8 16 20 00 00       	call   8021e4 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 75 2f 80 00       	push   $0x802f75
  8001dd:	6a 21                	push   $0x21
  8001df:	68 4b 2f 80 00       	push   $0x802f4b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 16 14 00 00       	call   801609 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 0a 14 00 00       	call   801609 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 13 28 00 00       	call   802a1a <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 f1 13 00 00       	call   801609 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 e9 13 00 00       	call   801609 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 7f 2f 80 00       	push   $0x802f7f
  800230:	e8 8e 19 00 00       	call   801bc3 <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 e8 2e 80 00       	push   $0x802ee8
  800245:	6a 2c                	push   $0x2c
  800247:	68 4b 2f 80 00       	push   $0x802f4b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 d9 14 00 00       	call   801745 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 c6 14 00 00       	call   801745 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 8d 2f 80 00       	push   $0x802f8d
  80028c:	6a 33                	push   $0x33
  80028e:	68 4b 2f 80 00       	push   $0x802f4b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 a7 2f 80 00       	push   $0x802fa7
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 4b 2f 80 00       	push   $0x802f4b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 c1 2f 80 00       	push   $0x802fc1
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 d6 2f 80 00       	push   $0x802fd6
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 24 08 00 00       	call   800b42 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 78 09 00 00       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 23 0b 00 00       	call   800e89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 94 0b 00 00       	call   800f26 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 10 0b 00 00       	call   800ea7 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 bb 0a 00 00       	call   800e89 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 5f 13 00 00       	call   801745 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 cf 10 00 00       	call   8014df <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 57 10 00 00       	call   801490 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 f1 0a 00 00       	call   800f45 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 ee 0f 00 00       	call   801469 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 73 0a 00 00       	call   800f07 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 5f 11 00 00       	call   801634 <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 e7 09 00 00       	call   800ec6 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 10 0a 00 00       	call   800f07 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 ec 2f 80 00       	push   $0x802fec
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 18 2f 80 00 	movl   $0x802f18,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 2f 09 00 00       	call   800e89 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 d4 08 00 00       	call   800e89 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 eb 25 00 00       	call   802c10 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 d8 26 00 00       	call   802d40 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 0f 30 80 00 	movsbl 0x80300f(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 89 03 00 00    	je     800a99 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 1a 03 00 00    	ja     800a7e <vprintfmt+0x38a>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 60 31 80 00 	jmp    *0x803160(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 39                	ja     8007cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800797:	eb e9                	jmp    800782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 48 04             	lea    0x4(%eax),%ecx
  80079f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 27                	jmp    8007d3 <vprintfmt+0xdf>
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	0f 49 c8             	cmovns %eax,%ecx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	eb 8c                	jmp    80074d <vprintfmt+0x59>
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cb:	eb 80                	jmp    80074d <vprintfmt+0x59>
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d7:	0f 89 70 ff ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ea:	e9 5e ff ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f5:	e9 53 ff ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	ff 30                	pushl  (%eax)
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800811:	e9 04 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	31 d0                	xor    %edx,%eax
  800824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800826:	83 f8 0f             	cmp    $0xf,%eax
  800829:	7f 0b                	jg     800836 <vprintfmt+0x142>
  80082b:	8b 14 85 c0 32 80 00 	mov    0x8032c0(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 27 30 80 00       	push   $0x803027
  80083c:	53                   	push   %ebx
  80083d:	56                   	push   %esi
  80083e:	e8 94 fe ff ff       	call   8006d7 <printfmt>
  800843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800849:	e9 cc fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80084e:	52                   	push   %edx
  80084f:	68 ad 34 80 00       	push   $0x8034ad
  800854:	53                   	push   %ebx
  800855:	56                   	push   %esi
  800856:	e8 7c fe ff ff       	call   8006d7 <printfmt>
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	e9 b4 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800871:	85 ff                	test   %edi,%edi
  800873:	b8 20 30 80 00       	mov    $0x803020,%eax
  800878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	0f 8e 94 00 00 00    	jle    800919 <vprintfmt+0x225>
  800885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800889:	0f 84 98 00 00 00    	je     800927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	ff 75 d0             	pushl  -0x30(%ebp)
  800895:	57                   	push   %edi
  800896:	e8 86 02 00 00       	call   800b21 <strnlen>
  80089b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80089e:	29 c1                	sub    %eax,%ecx
  8008a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b2:	eb 0f                	jmp    8008c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 ff                	test   %edi,%edi
  8008c5:	7f ed                	jg     8008b4 <vprintfmt+0x1c0>
  8008c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	0f 49 c1             	cmovns %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x213>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x213>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x23f>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x23f>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x270>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f2>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f2>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x278>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 a2 fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d1>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d4:	79 74                	jns    800a4a <vprintfmt+0x356>
				putch('-', putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	6a 2d                	push   $0x2d
  8009dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e4:	f7 d8                	neg    %eax
  8009e6:	83 d2 00             	adc    $0x0,%edx
  8009e9:	f7 da                	neg    %edx
  8009eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f3:	eb 55                	jmp    800a4a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f8:	e8 83 fc ff ff       	call   800680 <getuint>
			base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a02:	eb 46                	jmp    800a4a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800a04:	8d 45 14             	lea    0x14(%ebp),%eax
  800a07:	e8 74 fc ff ff       	call   800680 <getuint>
			base = 8;
  800a0c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a11:	eb 37                	jmp    800a4a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 30                	push   $0x30
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 78                	push   $0x78
  800a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 3b fc ff ff       	call   800680 <getuint>
			base = 16;
  800a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a51:	57                   	push   %edi
  800a52:	ff 75 e0             	pushl  -0x20(%ebp)
  800a55:	51                   	push   %ecx
  800a56:	52                   	push   %edx
  800a57:	50                   	push   %eax
  800a58:	89 da                	mov    %ebx,%edx
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	e8 70 fb ff ff       	call   8005d1 <printnum>
			break;
  800a61:	83 c4 20             	add    $0x20,%esp
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	e9 ae fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	51                   	push   %ecx
  800a71:	ff d6                	call   *%esi
			break;
  800a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a79:	e9 9c fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	53                   	push   %ebx
  800a82:	6a 25                	push   $0x25
  800a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	eb 03                	jmp    800a8e <vprintfmt+0x39a>
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a92:	75 f7                	jne    800a8b <vprintfmt+0x397>
  800a94:	e9 81 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 26                	je     800ae8 <vsnprintf+0x47>
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	7e 22                	jle    800ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	ff 75 14             	pushl  0x14(%ebp)
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	68 ba 06 80 00       	push   $0x8006ba
  800ad5:	e8 1a fc ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	eb 05                	jmp    800aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	50                   	push   %eax
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 9a ff ff ff       	call   800aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 03                	jmp    800b19 <strlen+0x10>
		n++;
  800b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1d:	75 f7                	jne    800b16 <strlen+0xd>
		n++;
	return n;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x13>
		n++;
  800b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	39 c2                	cmp    %eax,%edx
  800b36:	74 08                	je     800b40 <strnlen+0x1f>
  800b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3c:	75 f3                	jne    800b31 <strnlen+0x10>
  800b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b69:	53                   	push   %ebx
  800b6a:	e8 9a ff ff ff       	call   800b09 <strlen>
  800b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	01 d8                	add    %ebx,%eax
  800b77:	50                   	push   %eax
  800b78:	e8 c5 ff ff ff       	call   800b42 <strcpy>
	return dst;
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	eb 0f                	jmp    800ba7 <strncpy+0x23>
		*dst++ = *src;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba7:	39 da                	cmp    %ebx,%edx
  800ba9:	75 ed                	jne    800b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc1:	85 d2                	test   %edx,%edx
  800bc3:	74 21                	je     800be6 <strlcpy+0x35>
  800bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc9:	89 f2                	mov    %esi,%edx
  800bcb:	eb 09                	jmp    800bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	74 09                	je     800be3 <strlcpy+0x32>
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	84 db                	test   %bl,%bl
  800bdf:	75 ec                	jne    800bcd <strlcpy+0x1c>
  800be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 03                	jmp    800c7a <strfind+0xf>
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7d:	38 ca                	cmp    %cl,%dl
  800c7f:	74 04                	je     800c85 <strfind+0x1a>
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d29:	c1 e9 02             	shr    $0x2,%ecx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	ff 75 08             	pushl  0x8(%ebp)
  800d48:	e8 87 ff ff ff       	call   800cd4 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5a:	89 c6                	mov    %eax,%esi
  800d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	eb 1a                	jmp    800d7b <memcmp+0x2c>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	74 0a                	je     800d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 0f                	jmp    800d84 <memcmp+0x35>
		s1++, s2++;
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	39 f0                	cmp    %esi,%eax
  800d7d:	75 e2                	jne    800d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d98:	eb 0a                	jmp    800da4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9a:	0f b6 10             	movzbl (%eax),%edx
  800d9d:	39 da                	cmp    %ebx,%edx
  800d9f:	74 07                	je     800da8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da1:	83 c0 01             	add    $0x1,%eax
  800da4:	39 c8                	cmp    %ecx,%eax
  800da6:	72 f2                	jb     800d9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db7:	eb 03                	jmp    800dbc <strtol+0x11>
		s++;
  800db9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f6                	je     800db9 <strtol+0xe>
  800dc3:	3c 09                	cmp    $0x9,%al
  800dc5:	74 f2                	je     800db9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc7:	3c 2b                	cmp    $0x2b,%al
  800dc9:	75 0a                	jne    800dd5 <strtol+0x2a>
		s++;
  800dcb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd3:	eb 11                	jmp    800de6 <strtol+0x3b>
  800dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dda:	3c 2d                	cmp    $0x2d,%al
  800ddc:	75 08                	jne    800de6 <strtol+0x3b>
		s++, neg = 1;
  800dde:	83 c1 01             	add    $0x1,%ecx
  800de1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dec:	75 15                	jne    800e03 <strtol+0x58>
  800dee:	80 39 30             	cmpb   $0x30,(%ecx)
  800df1:	75 10                	jne    800e03 <strtol+0x58>
  800df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df7:	75 7c                	jne    800e75 <strtol+0xca>
		s += 2, base = 16;
  800df9:	83 c1 02             	add    $0x2,%ecx
  800dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e01:	eb 16                	jmp    800e19 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	75 12                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e07:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0f:	75 08                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
  800e11:	83 c1 01             	add    $0x1,%ecx
  800e14:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e21:	0f b6 11             	movzbl (%ecx),%edx
  800e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e27:	89 f3                	mov    %esi,%ebx
  800e29:	80 fb 09             	cmp    $0x9,%bl
  800e2c:	77 08                	ja     800e36 <strtol+0x8b>
			dig = *s - '0';
  800e2e:	0f be d2             	movsbl %dl,%edx
  800e31:	83 ea 30             	sub    $0x30,%edx
  800e34:	eb 22                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e36:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e39:	89 f3                	mov    %esi,%ebx
  800e3b:	80 fb 19             	cmp    $0x19,%bl
  800e3e:	77 08                	ja     800e48 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e40:	0f be d2             	movsbl %dl,%edx
  800e43:	83 ea 57             	sub    $0x57,%edx
  800e46:	eb 10                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e48:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4b:	89 f3                	mov    %esi,%ebx
  800e4d:	80 fb 19             	cmp    $0x19,%bl
  800e50:	77 16                	ja     800e68 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e52:	0f be d2             	movsbl %dl,%edx
  800e55:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5b:	7d 0b                	jge    800e68 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e64:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e66:	eb b9                	jmp    800e21 <strtol+0x76>

	if (endptr)
  800e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6c:	74 0d                	je     800e7b <strtol+0xd0>
		*endptr = (char *) s;
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	89 0e                	mov    %ecx,(%esi)
  800e73:	eb 06                	jmp    800e7b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e75:	85 db                	test   %ebx,%ebx
  800e77:	74 98                	je     800e11 <strtol+0x66>
  800e79:	eb 9e                	jmp    800e19 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	f7 da                	neg    %edx
  800e7f:	85 ff                	test   %edi,%edi
  800e81:	0f 45 c2             	cmovne %edx,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	89 d1                	mov    %edx,%ecx
  800eb9:	89 d3                	mov    %edx,%ebx
  800ebb:	89 d7                	mov    %edx,%edi
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 03                	push   $0x3
  800eee:	68 1f 33 80 00       	push   $0x80331f
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 3c 33 80 00       	push   $0x80333c
  800efa:	e8 e5 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 02 00 00 00       	mov    $0x2,%eax
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 d3                	mov    %edx,%ebx
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 04 00 00 00       	mov    $0x4,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	89 f7                	mov    %esi,%edi
  800f63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 04                	push   $0x4
  800f6f:	68 1f 33 80 00       	push   $0x80331f
  800f74:	6a 23                	push   $0x23
  800f76:	68 3c 33 80 00       	push   $0x80333c
  800f7b:	e8 64 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	b8 05 00 00 00       	mov    $0x5,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 05                	push   $0x5
  800fb1:	68 1f 33 80 00       	push   $0x80331f
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 3c 33 80 00       	push   $0x80333c
  800fbd:	e8 22 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 06                	push   $0x6
  800ff3:	68 1f 33 80 00       	push   $0x80331f
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 3c 33 80 00       	push   $0x80333c
  800fff:	e8 e0 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 df                	mov    %ebx,%edi
  801027:	89 de                	mov    %ebx,%esi
  801029:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 17                	jle    801046 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	6a 08                	push   $0x8
  801035:	68 1f 33 80 00       	push   $0x80331f
  80103a:	6a 23                	push   $0x23
  80103c:	68 3c 33 80 00       	push   $0x80333c
  801041:	e8 9e f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105c:	b8 09 00 00 00       	mov    $0x9,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 df                	mov    %ebx,%edi
  801069:	89 de                	mov    %ebx,%esi
  80106b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 09                	push   $0x9
  801077:	68 1f 33 80 00       	push   $0x80331f
  80107c:	6a 23                	push   $0x23
  80107e:	68 3c 33 80 00       	push   $0x80333c
  801083:	e8 5c f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 0a                	push   $0xa
  8010b9:	68 1f 33 80 00       	push   $0x80331f
  8010be:	6a 23                	push   $0x23
  8010c0:	68 3c 33 80 00       	push   $0x80333c
  8010c5:	e8 1a f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	be 00 00 00 00       	mov    $0x0,%esi
  8010dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ee:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0d 00 00 00       	mov    $0xd,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	89 ce                	mov    %ecx,%esi
  801111:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 1f 33 80 00       	push   $0x80331f
  801122:	6a 23                	push   $0x23
  801124:	68 3c 33 80 00       	push   $0x80333c
  801129:	e8 b6 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113c:	ba 00 00 00 00       	mov    $0x0,%edx
  801141:	b8 0e 00 00 00       	mov    $0xe,%eax
  801146:	89 d1                	mov    %edx,%ecx
  801148:	89 d3                	mov    %edx,%ebx
  80114a:	89 d7                	mov    %edx,%edi
  80114c:	89 d6                	mov    %edx,%esi
  80114e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801163:	b8 0f 00 00 00       	mov    $0xf,%eax
  801168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116b:	8b 55 08             	mov    0x8(%ebp),%edx
  80116e:	89 df                	mov    %ebx,%edi
  801170:	89 de                	mov    %ebx,%esi
  801172:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801174:	85 c0                	test   %eax,%eax
  801176:	7e 17                	jle    80118f <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801178:	83 ec 0c             	sub    $0xc,%esp
  80117b:	50                   	push   %eax
  80117c:	6a 0f                	push   $0xf
  80117e:	68 1f 33 80 00       	push   $0x80331f
  801183:	6a 23                	push   $0x23
  801185:	68 3c 33 80 00       	push   $0x80333c
  80118a:	e8 55 f3 ff ff       	call   8004e4 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  80118f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a5:	b8 10 00 00 00       	mov    $0x10,%eax
  8011aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b0:	89 df                	mov    %ebx,%edi
  8011b2:	89 de                	mov    %ebx,%esi
  8011b4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	7e 17                	jle    8011d1 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ba:	83 ec 0c             	sub    $0xc,%esp
  8011bd:	50                   	push   %eax
  8011be:	6a 10                	push   $0x10
  8011c0:	68 1f 33 80 00       	push   $0x80331f
  8011c5:	6a 23                	push   $0x23
  8011c7:	68 3c 33 80 00       	push   $0x80333c
  8011cc:	e8 13 f3 ff ff       	call   8004e4 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8011d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	56                   	push   %esi
  8011dd:	53                   	push   %ebx
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011e1:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  8011e3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011e7:	75 25                	jne    80120e <pgfault+0x35>
  8011e9:	89 d8                	mov    %ebx,%eax
  8011eb:	c1 e8 0c             	shr    $0xc,%eax
  8011ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011f5:	f6 c4 08             	test   $0x8,%ah
  8011f8:	75 14                	jne    80120e <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	68 4c 33 80 00       	push   $0x80334c
  801202:	6a 1e                	push   $0x1e
  801204:	68 e0 33 80 00       	push   $0x8033e0
  801209:	e8 d6 f2 ff ff       	call   8004e4 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  80120e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  801214:	e8 ee fc ff ff       	call   800f07 <sys_getenvid>
  801219:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	6a 07                	push   $0x7
  801220:	68 00 f0 7f 00       	push   $0x7ff000
  801225:	50                   	push   %eax
  801226:	e8 1a fd ff ff       	call   800f45 <sys_page_alloc>
	if (r < 0)
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	79 12                	jns    801244 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  801232:	50                   	push   %eax
  801233:	68 78 33 80 00       	push   $0x803378
  801238:	6a 33                	push   $0x33
  80123a:	68 e0 33 80 00       	push   $0x8033e0
  80123f:	e8 a0 f2 ff ff       	call   8004e4 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	68 00 10 00 00       	push   $0x1000
  80124c:	53                   	push   %ebx
  80124d:	68 00 f0 7f 00       	push   $0x7ff000
  801252:	e8 e5 fa ff ff       	call   800d3c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  801257:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80125e:	53                   	push   %ebx
  80125f:	56                   	push   %esi
  801260:	68 00 f0 7f 00       	push   $0x7ff000
  801265:	56                   	push   %esi
  801266:	e8 1d fd ff ff       	call   800f88 <sys_page_map>
	if (r < 0)
  80126b:	83 c4 20             	add    $0x20,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	79 12                	jns    801284 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  801272:	50                   	push   %eax
  801273:	68 9c 33 80 00       	push   $0x80339c
  801278:	6a 3b                	push   $0x3b
  80127a:	68 e0 33 80 00       	push   $0x8033e0
  80127f:	e8 60 f2 ff ff       	call   8004e4 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	68 00 f0 7f 00       	push   $0x7ff000
  80128c:	56                   	push   %esi
  80128d:	e8 38 fd ff ff       	call   800fca <sys_page_unmap>
	if (r < 0)
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	79 12                	jns    8012ab <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  801299:	50                   	push   %eax
  80129a:	68 c0 33 80 00       	push   $0x8033c0
  80129f:	6a 40                	push   $0x40
  8012a1:	68 e0 33 80 00       	push   $0x8033e0
  8012a6:	e8 39 f2 ff ff       	call   8004e4 <_panic>
}
  8012ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	57                   	push   %edi
  8012b6:	56                   	push   %esi
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  8012bb:	68 d9 11 80 00       	push   $0x8011d9
  8012c0:	e8 a4 17 00 00       	call   802a69 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012c5:	b8 07 00 00 00       	mov    $0x7,%eax
  8012ca:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	0f 88 64 01 00 00    	js     80143b <fork+0x189>
  8012d7:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8012dc:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	75 21                	jne    801306 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012e5:	e8 1d fc ff ff       	call   800f07 <sys_getenvid>
  8012ea:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012f7:	a3 08 50 80 00       	mov    %eax,0x805008
        return 0;
  8012fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801301:	e9 3f 01 00 00       	jmp    801445 <fork+0x193>
  801306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801309:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80130b:	89 d8                	mov    %ebx,%eax
  80130d:	c1 e8 16             	shr    $0x16,%eax
  801310:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801317:	a8 01                	test   $0x1,%al
  801319:	0f 84 bd 00 00 00    	je     8013dc <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80131f:	89 d8                	mov    %ebx,%eax
  801321:	c1 e8 0c             	shr    $0xc,%eax
  801324:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80132b:	f6 c2 01             	test   $0x1,%dl
  80132e:	0f 84 a8 00 00 00    	je     8013dc <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801334:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133b:	a8 04                	test   $0x4,%al
  80133d:	0f 84 99 00 00 00    	je     8013dc <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801343:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80134a:	f6 c4 04             	test   $0x4,%ah
  80134d:	74 17                	je     801366 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	68 07 0e 00 00       	push   $0xe07
  801357:	53                   	push   %ebx
  801358:	57                   	push   %edi
  801359:	53                   	push   %ebx
  80135a:	6a 00                	push   $0x0
  80135c:	e8 27 fc ff ff       	call   800f88 <sys_page_map>
  801361:	83 c4 20             	add    $0x20,%esp
  801364:	eb 76                	jmp    8013dc <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801366:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80136d:	a8 02                	test   $0x2,%al
  80136f:	75 0c                	jne    80137d <fork+0xcb>
  801371:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801378:	f6 c4 08             	test   $0x8,%ah
  80137b:	74 3f                	je     8013bc <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	68 05 08 00 00       	push   $0x805
  801385:	53                   	push   %ebx
  801386:	57                   	push   %edi
  801387:	53                   	push   %ebx
  801388:	6a 00                	push   $0x0
  80138a:	e8 f9 fb ff ff       	call   800f88 <sys_page_map>
		if (r < 0)
  80138f:	83 c4 20             	add    $0x20,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	0f 88 a5 00 00 00    	js     80143f <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	68 05 08 00 00       	push   $0x805
  8013a2:	53                   	push   %ebx
  8013a3:	6a 00                	push   $0x0
  8013a5:	53                   	push   %ebx
  8013a6:	6a 00                	push   $0x0
  8013a8:	e8 db fb ff ff       	call   800f88 <sys_page_map>
  8013ad:	83 c4 20             	add    $0x20,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013b7:	0f 4f c1             	cmovg  %ecx,%eax
  8013ba:	eb 1c                	jmp    8013d8 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	6a 05                	push   $0x5
  8013c1:	53                   	push   %ebx
  8013c2:	57                   	push   %edi
  8013c3:	53                   	push   %ebx
  8013c4:	6a 00                	push   $0x0
  8013c6:	e8 bd fb ff ff       	call   800f88 <sys_page_map>
  8013cb:	83 c4 20             	add    $0x20,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013d5:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 67                	js     801443 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8013dc:	83 c6 01             	add    $0x1,%esi
  8013df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013e5:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8013eb:	0f 85 1a ff ff ff    	jne    80130b <fork+0x59>
  8013f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8013f4:	83 ec 04             	sub    $0x4,%esp
  8013f7:	6a 07                	push   $0x7
  8013f9:	68 00 f0 bf ee       	push   $0xeebff000
  8013fe:	57                   	push   %edi
  8013ff:	e8 41 fb ff ff       	call   800f45 <sys_page_alloc>
	if (r < 0)
  801404:	83 c4 10             	add    $0x10,%esp
		return r;
  801407:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 38                	js     801445 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	68 b0 2a 80 00       	push   $0x802ab0
  801415:	57                   	push   %edi
  801416:	e8 75 fc ff ff       	call   801090 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80141b:	83 c4 10             	add    $0x10,%esp
		return r;
  80141e:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801420:	85 c0                	test   %eax,%eax
  801422:	78 21                	js     801445 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	6a 02                	push   $0x2
  801429:	57                   	push   %edi
  80142a:	e8 dd fb ff ff       	call   80100c <sys_env_set_status>
	if (r < 0)
  80142f:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801432:	85 c0                	test   %eax,%eax
  801434:	0f 48 f8             	cmovs  %eax,%edi
  801437:	89 fa                	mov    %edi,%edx
  801439:	eb 0a                	jmp    801445 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80143b:	89 c2                	mov    %eax,%edx
  80143d:	eb 06                	jmp    801445 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80143f:	89 c2                	mov    %eax,%edx
  801441:	eb 02                	jmp    801445 <fork+0x193>
  801443:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801445:	89 d0                	mov    %edx,%eax
  801447:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144a:	5b                   	pop    %ebx
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <sfork>:

// Challenge!
int
sfork(void)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801455:	68 eb 33 80 00       	push   $0x8033eb
  80145a:	68 c9 00 00 00       	push   $0xc9
  80145f:	68 e0 33 80 00       	push   $0x8033e0
  801464:	e8 7b f0 ff ff       	call   8004e4 <_panic>

00801469 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80146c:	8b 45 08             	mov    0x8(%ebp),%eax
  80146f:	05 00 00 00 30       	add    $0x30000000,%eax
  801474:	c1 e8 0c             	shr    $0xc,%eax
}
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80147c:	8b 45 08             	mov    0x8(%ebp),%eax
  80147f:	05 00 00 00 30       	add    $0x30000000,%eax
  801484:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801489:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801496:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	c1 ea 16             	shr    $0x16,%edx
  8014a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a7:	f6 c2 01             	test   $0x1,%dl
  8014aa:	74 11                	je     8014bd <fd_alloc+0x2d>
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	c1 ea 0c             	shr    $0xc,%edx
  8014b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b8:	f6 c2 01             	test   $0x1,%dl
  8014bb:	75 09                	jne    8014c6 <fd_alloc+0x36>
			*fd_store = fd;
  8014bd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c4:	eb 17                	jmp    8014dd <fd_alloc+0x4d>
  8014c6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014cb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014d0:	75 c9                	jne    80149b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014d2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014d8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e5:	83 f8 1f             	cmp    $0x1f,%eax
  8014e8:	77 36                	ja     801520 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014ea:	c1 e0 0c             	shl    $0xc,%eax
  8014ed:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	c1 ea 16             	shr    $0x16,%edx
  8014f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014fe:	f6 c2 01             	test   $0x1,%dl
  801501:	74 24                	je     801527 <fd_lookup+0x48>
  801503:	89 c2                	mov    %eax,%edx
  801505:	c1 ea 0c             	shr    $0xc,%edx
  801508:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150f:	f6 c2 01             	test   $0x1,%dl
  801512:	74 1a                	je     80152e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801514:	8b 55 0c             	mov    0xc(%ebp),%edx
  801517:	89 02                	mov    %eax,(%edx)
	return 0;
  801519:	b8 00 00 00 00       	mov    $0x0,%eax
  80151e:	eb 13                	jmp    801533 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801520:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801525:	eb 0c                	jmp    801533 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801527:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152c:	eb 05                	jmp    801533 <fd_lookup+0x54>
  80152e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    

00801535 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153e:	ba 80 34 80 00       	mov    $0x803480,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801543:	eb 13                	jmp    801558 <dev_lookup+0x23>
  801545:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801548:	39 08                	cmp    %ecx,(%eax)
  80154a:	75 0c                	jne    801558 <dev_lookup+0x23>
			*dev = devtab[i];
  80154c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
  801556:	eb 2e                	jmp    801586 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801558:	8b 02                	mov    (%edx),%eax
  80155a:	85 c0                	test   %eax,%eax
  80155c:	75 e7                	jne    801545 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80155e:	a1 08 50 80 00       	mov    0x805008,%eax
  801563:	8b 40 48             	mov    0x48(%eax),%eax
  801566:	83 ec 04             	sub    $0x4,%esp
  801569:	51                   	push   %ecx
  80156a:	50                   	push   %eax
  80156b:	68 04 34 80 00       	push   $0x803404
  801570:	e8 48 f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  801575:	8b 45 0c             	mov    0xc(%ebp),%eax
  801578:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801586:	c9                   	leave  
  801587:	c3                   	ret    

00801588 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	56                   	push   %esi
  80158c:	53                   	push   %ebx
  80158d:	83 ec 10             	sub    $0x10,%esp
  801590:	8b 75 08             	mov    0x8(%ebp),%esi
  801593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801596:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015a0:	c1 e8 0c             	shr    $0xc,%eax
  8015a3:	50                   	push   %eax
  8015a4:	e8 36 ff ff ff       	call   8014df <fd_lookup>
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 05                	js     8015b5 <fd_close+0x2d>
	    || fd != fd2)
  8015b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015b3:	74 0c                	je     8015c1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015b5:	84 db                	test   %bl,%bl
  8015b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bc:	0f 44 c2             	cmove  %edx,%eax
  8015bf:	eb 41                	jmp    801602 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	ff 36                	pushl  (%esi)
  8015ca:	e8 66 ff ff ff       	call   801535 <dev_lookup>
  8015cf:	89 c3                	mov    %eax,%ebx
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 1a                	js     8015f2 <fd_close+0x6a>
		if (dev->dev_close)
  8015d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015db:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015de:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	74 0b                	je     8015f2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	56                   	push   %esi
  8015eb:	ff d0                	call   *%eax
  8015ed:	89 c3                	mov    %eax,%ebx
  8015ef:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	56                   	push   %esi
  8015f6:	6a 00                	push   $0x0
  8015f8:	e8 cd f9 ff ff       	call   800fca <sys_page_unmap>
	return r;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	89 d8                	mov    %ebx,%eax
}
  801602:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801605:	5b                   	pop    %ebx
  801606:	5e                   	pop    %esi
  801607:	5d                   	pop    %ebp
  801608:	c3                   	ret    

00801609 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	ff 75 08             	pushl  0x8(%ebp)
  801616:	e8 c4 fe ff ff       	call   8014df <fd_lookup>
  80161b:	83 c4 08             	add    $0x8,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 10                	js     801632 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	6a 01                	push   $0x1
  801627:	ff 75 f4             	pushl  -0xc(%ebp)
  80162a:	e8 59 ff ff ff       	call   801588 <fd_close>
  80162f:	83 c4 10             	add    $0x10,%esp
}
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <close_all>:

void
close_all(void)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	53                   	push   %ebx
  801638:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801640:	83 ec 0c             	sub    $0xc,%esp
  801643:	53                   	push   %ebx
  801644:	e8 c0 ff ff ff       	call   801609 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801649:	83 c3 01             	add    $0x1,%ebx
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	83 fb 20             	cmp    $0x20,%ebx
  801652:	75 ec                	jne    801640 <close_all+0xc>
		close(i);
}
  801654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	57                   	push   %edi
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	83 ec 2c             	sub    $0x2c,%esp
  801662:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801665:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	e8 6e fe ff ff       	call   8014df <fd_lookup>
  801671:	83 c4 08             	add    $0x8,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	0f 88 c1 00 00 00    	js     80173d <dup+0xe4>
		return r;
	close(newfdnum);
  80167c:	83 ec 0c             	sub    $0xc,%esp
  80167f:	56                   	push   %esi
  801680:	e8 84 ff ff ff       	call   801609 <close>

	newfd = INDEX2FD(newfdnum);
  801685:	89 f3                	mov    %esi,%ebx
  801687:	c1 e3 0c             	shl    $0xc,%ebx
  80168a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801690:	83 c4 04             	add    $0x4,%esp
  801693:	ff 75 e4             	pushl  -0x1c(%ebp)
  801696:	e8 de fd ff ff       	call   801479 <fd2data>
  80169b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80169d:	89 1c 24             	mov    %ebx,(%esp)
  8016a0:	e8 d4 fd ff ff       	call   801479 <fd2data>
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ab:	89 f8                	mov    %edi,%eax
  8016ad:	c1 e8 16             	shr    $0x16,%eax
  8016b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b7:	a8 01                	test   $0x1,%al
  8016b9:	74 37                	je     8016f2 <dup+0x99>
  8016bb:	89 f8                	mov    %edi,%eax
  8016bd:	c1 e8 0c             	shr    $0xc,%eax
  8016c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c7:	f6 c2 01             	test   $0x1,%dl
  8016ca:	74 26                	je     8016f2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8016db:	50                   	push   %eax
  8016dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016df:	6a 00                	push   $0x0
  8016e1:	57                   	push   %edi
  8016e2:	6a 00                	push   $0x0
  8016e4:	e8 9f f8 ff ff       	call   800f88 <sys_page_map>
  8016e9:	89 c7                	mov    %eax,%edi
  8016eb:	83 c4 20             	add    $0x20,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 2e                	js     801720 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f5:	89 d0                	mov    %edx,%eax
  8016f7:	c1 e8 0c             	shr    $0xc,%eax
  8016fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801701:	83 ec 0c             	sub    $0xc,%esp
  801704:	25 07 0e 00 00       	and    $0xe07,%eax
  801709:	50                   	push   %eax
  80170a:	53                   	push   %ebx
  80170b:	6a 00                	push   $0x0
  80170d:	52                   	push   %edx
  80170e:	6a 00                	push   $0x0
  801710:	e8 73 f8 ff ff       	call   800f88 <sys_page_map>
  801715:	89 c7                	mov    %eax,%edi
  801717:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80171a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80171c:	85 ff                	test   %edi,%edi
  80171e:	79 1d                	jns    80173d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	53                   	push   %ebx
  801724:	6a 00                	push   $0x0
  801726:	e8 9f f8 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  80172b:	83 c4 08             	add    $0x8,%esp
  80172e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801731:	6a 00                	push   $0x0
  801733:	e8 92 f8 ff ff       	call   800fca <sys_page_unmap>
	return r;
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	89 f8                	mov    %edi,%eax
}
  80173d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 14             	sub    $0x14,%esp
  80174c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801752:	50                   	push   %eax
  801753:	53                   	push   %ebx
  801754:	e8 86 fd ff ff       	call   8014df <fd_lookup>
  801759:	83 c4 08             	add    $0x8,%esp
  80175c:	89 c2                	mov    %eax,%edx
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 6d                	js     8017cf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801762:	83 ec 08             	sub    $0x8,%esp
  801765:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801768:	50                   	push   %eax
  801769:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176c:	ff 30                	pushl  (%eax)
  80176e:	e8 c2 fd ff ff       	call   801535 <dev_lookup>
  801773:	83 c4 10             	add    $0x10,%esp
  801776:	85 c0                	test   %eax,%eax
  801778:	78 4c                	js     8017c6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80177a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80177d:	8b 42 08             	mov    0x8(%edx),%eax
  801780:	83 e0 03             	and    $0x3,%eax
  801783:	83 f8 01             	cmp    $0x1,%eax
  801786:	75 21                	jne    8017a9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801788:	a1 08 50 80 00       	mov    0x805008,%eax
  80178d:	8b 40 48             	mov    0x48(%eax),%eax
  801790:	83 ec 04             	sub    $0x4,%esp
  801793:	53                   	push   %ebx
  801794:	50                   	push   %eax
  801795:	68 45 34 80 00       	push   $0x803445
  80179a:	e8 1e ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a7:	eb 26                	jmp    8017cf <read+0x8a>
	}
	if (!dev->dev_read)
  8017a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ac:	8b 40 08             	mov    0x8(%eax),%eax
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	74 17                	je     8017ca <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017b3:	83 ec 04             	sub    $0x4,%esp
  8017b6:	ff 75 10             	pushl  0x10(%ebp)
  8017b9:	ff 75 0c             	pushl  0xc(%ebp)
  8017bc:	52                   	push   %edx
  8017bd:	ff d0                	call   *%eax
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	eb 09                	jmp    8017cf <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c6:	89 c2                	mov    %eax,%edx
  8017c8:	eb 05                	jmp    8017cf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017cf:	89 d0                	mov    %edx,%eax
  8017d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	57                   	push   %edi
  8017da:	56                   	push   %esi
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 0c             	sub    $0xc,%esp
  8017df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ea:	eb 21                	jmp    80180d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017ec:	83 ec 04             	sub    $0x4,%esp
  8017ef:	89 f0                	mov    %esi,%eax
  8017f1:	29 d8                	sub    %ebx,%eax
  8017f3:	50                   	push   %eax
  8017f4:	89 d8                	mov    %ebx,%eax
  8017f6:	03 45 0c             	add    0xc(%ebp),%eax
  8017f9:	50                   	push   %eax
  8017fa:	57                   	push   %edi
  8017fb:	e8 45 ff ff ff       	call   801745 <read>
		if (m < 0)
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	78 10                	js     801817 <readn+0x41>
			return m;
		if (m == 0)
  801807:	85 c0                	test   %eax,%eax
  801809:	74 0a                	je     801815 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80180b:	01 c3                	add    %eax,%ebx
  80180d:	39 f3                	cmp    %esi,%ebx
  80180f:	72 db                	jb     8017ec <readn+0x16>
  801811:	89 d8                	mov    %ebx,%eax
  801813:	eb 02                	jmp    801817 <readn+0x41>
  801815:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5f                   	pop    %edi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 14             	sub    $0x14,%esp
  801826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801829:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182c:	50                   	push   %eax
  80182d:	53                   	push   %ebx
  80182e:	e8 ac fc ff ff       	call   8014df <fd_lookup>
  801833:	83 c4 08             	add    $0x8,%esp
  801836:	89 c2                	mov    %eax,%edx
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 68                	js     8018a4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801842:	50                   	push   %eax
  801843:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801846:	ff 30                	pushl  (%eax)
  801848:	e8 e8 fc ff ff       	call   801535 <dev_lookup>
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	85 c0                	test   %eax,%eax
  801852:	78 47                	js     80189b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801854:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801857:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185b:	75 21                	jne    80187e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80185d:	a1 08 50 80 00       	mov    0x805008,%eax
  801862:	8b 40 48             	mov    0x48(%eax),%eax
  801865:	83 ec 04             	sub    $0x4,%esp
  801868:	53                   	push   %ebx
  801869:	50                   	push   %eax
  80186a:	68 61 34 80 00       	push   $0x803461
  80186f:	e8 49 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80187c:	eb 26                	jmp    8018a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80187e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801881:	8b 52 0c             	mov    0xc(%edx),%edx
  801884:	85 d2                	test   %edx,%edx
  801886:	74 17                	je     80189f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	ff 75 10             	pushl  0x10(%ebp)
  80188e:	ff 75 0c             	pushl  0xc(%ebp)
  801891:	50                   	push   %eax
  801892:	ff d2                	call   *%edx
  801894:	89 c2                	mov    %eax,%edx
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	eb 09                	jmp    8018a4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189b:	89 c2                	mov    %eax,%edx
  80189d:	eb 05                	jmp    8018a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80189f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018a4:	89 d0                	mov    %edx,%eax
  8018a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <seek>:

int
seek(int fdnum, off_t offset)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018b4:	50                   	push   %eax
  8018b5:	ff 75 08             	pushl  0x8(%ebp)
  8018b8:	e8 22 fc ff ff       	call   8014df <fd_lookup>
  8018bd:	83 c4 08             	add    $0x8,%esp
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 0e                	js     8018d2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	53                   	push   %ebx
  8018d8:	83 ec 14             	sub    $0x14,%esp
  8018db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e1:	50                   	push   %eax
  8018e2:	53                   	push   %ebx
  8018e3:	e8 f7 fb ff ff       	call   8014df <fd_lookup>
  8018e8:	83 c4 08             	add    $0x8,%esp
  8018eb:	89 c2                	mov    %eax,%edx
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 65                	js     801956 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f7:	50                   	push   %eax
  8018f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fb:	ff 30                	pushl  (%eax)
  8018fd:	e8 33 fc ff ff       	call   801535 <dev_lookup>
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	85 c0                	test   %eax,%eax
  801907:	78 44                	js     80194d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801909:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801910:	75 21                	jne    801933 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801912:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801917:	8b 40 48             	mov    0x48(%eax),%eax
  80191a:	83 ec 04             	sub    $0x4,%esp
  80191d:	53                   	push   %ebx
  80191e:	50                   	push   %eax
  80191f:	68 24 34 80 00       	push   $0x803424
  801924:	e8 94 ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801931:	eb 23                	jmp    801956 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801933:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801936:	8b 52 18             	mov    0x18(%edx),%edx
  801939:	85 d2                	test   %edx,%edx
  80193b:	74 14                	je     801951 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80193d:	83 ec 08             	sub    $0x8,%esp
  801940:	ff 75 0c             	pushl  0xc(%ebp)
  801943:	50                   	push   %eax
  801944:	ff d2                	call   *%edx
  801946:	89 c2                	mov    %eax,%edx
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	eb 09                	jmp    801956 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194d:	89 c2                	mov    %eax,%edx
  80194f:	eb 05                	jmp    801956 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801951:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801956:	89 d0                	mov    %edx,%eax
  801958:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195b:	c9                   	leave  
  80195c:	c3                   	ret    

0080195d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	53                   	push   %ebx
  801961:	83 ec 14             	sub    $0x14,%esp
  801964:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801967:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196a:	50                   	push   %eax
  80196b:	ff 75 08             	pushl  0x8(%ebp)
  80196e:	e8 6c fb ff ff       	call   8014df <fd_lookup>
  801973:	83 c4 08             	add    $0x8,%esp
  801976:	89 c2                	mov    %eax,%edx
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 58                	js     8019d4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197c:	83 ec 08             	sub    $0x8,%esp
  80197f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801982:	50                   	push   %eax
  801983:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801986:	ff 30                	pushl  (%eax)
  801988:	e8 a8 fb ff ff       	call   801535 <dev_lookup>
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	85 c0                	test   %eax,%eax
  801992:	78 37                	js     8019cb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801997:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80199b:	74 32                	je     8019cf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80199d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019a0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019a7:	00 00 00 
	stat->st_isdir = 0;
  8019aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b1:	00 00 00 
	stat->st_dev = dev;
  8019b4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	53                   	push   %ebx
  8019be:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c1:	ff 50 14             	call   *0x14(%eax)
  8019c4:	89 c2                	mov    %eax,%edx
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	eb 09                	jmp    8019d4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019cb:	89 c2                	mov    %eax,%edx
  8019cd:	eb 05                	jmp    8019d4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019d4:	89 d0                	mov    %edx,%eax
  8019d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019e0:	83 ec 08             	sub    $0x8,%esp
  8019e3:	6a 00                	push   $0x0
  8019e5:	ff 75 08             	pushl  0x8(%ebp)
  8019e8:	e8 d6 01 00 00       	call   801bc3 <open>
  8019ed:	89 c3                	mov    %eax,%ebx
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 1b                	js     801a11 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019f6:	83 ec 08             	sub    $0x8,%esp
  8019f9:	ff 75 0c             	pushl  0xc(%ebp)
  8019fc:	50                   	push   %eax
  8019fd:	e8 5b ff ff ff       	call   80195d <fstat>
  801a02:	89 c6                	mov    %eax,%esi
	close(fd);
  801a04:	89 1c 24             	mov    %ebx,(%esp)
  801a07:	e8 fd fb ff ff       	call   801609 <close>
	return r;
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	89 f0                	mov    %esi,%eax
}
  801a11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a14:	5b                   	pop    %ebx
  801a15:	5e                   	pop    %esi
  801a16:	5d                   	pop    %ebp
  801a17:	c3                   	ret    

00801a18 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
  801a1d:	89 c6                	mov    %eax,%esi
  801a1f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a21:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a28:	75 12                	jne    801a3c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a2a:	83 ec 0c             	sub    $0xc,%esp
  801a2d:	6a 01                	push   $0x1
  801a2f:	e8 5b 11 00 00       	call   802b8f <ipc_find_env>
  801a34:	a3 00 50 80 00       	mov    %eax,0x805000
  801a39:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a3c:	6a 07                	push   $0x7
  801a3e:	68 00 60 80 00       	push   $0x806000
  801a43:	56                   	push   %esi
  801a44:	ff 35 00 50 80 00    	pushl  0x805000
  801a4a:	e8 ec 10 00 00       	call   802b3b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a4f:	83 c4 0c             	add    $0xc,%esp
  801a52:	6a 00                	push   $0x0
  801a54:	53                   	push   %ebx
  801a55:	6a 00                	push   $0x0
  801a57:	e8 78 10 00 00       	call   802ad4 <ipc_recv>
}
  801a5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5e                   	pop    %esi
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    

00801a63 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a77:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a81:	b8 02 00 00 00       	mov    $0x2,%eax
  801a86:	e8 8d ff ff ff       	call   801a18 <fsipc>
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a93:	8b 45 08             	mov    0x8(%ebp),%eax
  801a96:	8b 40 0c             	mov    0xc(%eax),%eax
  801a99:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a9e:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa3:	b8 06 00 00 00       	mov    $0x6,%eax
  801aa8:	e8 6b ff ff ff       	call   801a18 <fsipc>
}
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 04             	sub    $0x4,%esp
  801ab6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	8b 40 0c             	mov    0xc(%eax),%eax
  801abf:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac9:	b8 05 00 00 00       	mov    $0x5,%eax
  801ace:	e8 45 ff ff ff       	call   801a18 <fsipc>
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 2c                	js     801b03 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ad7:	83 ec 08             	sub    $0x8,%esp
  801ada:	68 00 60 80 00       	push   $0x806000
  801adf:	53                   	push   %ebx
  801ae0:	e8 5d f0 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ae5:	a1 80 60 80 00       	mov    0x806080,%eax
  801aea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801af0:	a1 84 60 80 00       	mov    0x806084,%eax
  801af5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b11:	8b 55 08             	mov    0x8(%ebp),%edx
  801b14:	8b 52 0c             	mov    0xc(%edx),%edx
  801b17:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b1d:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b22:	50                   	push   %eax
  801b23:	ff 75 0c             	pushl  0xc(%ebp)
  801b26:	68 08 60 80 00       	push   $0x806008
  801b2b:	e8 a4 f1 ff ff       	call   800cd4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801b30:	ba 00 00 00 00       	mov    $0x0,%edx
  801b35:	b8 04 00 00 00       	mov    $0x4,%eax
  801b3a:	e8 d9 fe ff ff       	call   801a18 <fsipc>

}
  801b3f:	c9                   	leave  
  801b40:	c3                   	ret    

00801b41 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	56                   	push   %esi
  801b45:	53                   	push   %ebx
  801b46:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b54:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  801b64:	e8 af fe ff ff       	call   801a18 <fsipc>
  801b69:	89 c3                	mov    %eax,%ebx
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 4b                	js     801bba <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b6f:	39 c6                	cmp    %eax,%esi
  801b71:	73 16                	jae    801b89 <devfile_read+0x48>
  801b73:	68 94 34 80 00       	push   $0x803494
  801b78:	68 9b 34 80 00       	push   $0x80349b
  801b7d:	6a 7c                	push   $0x7c
  801b7f:	68 b0 34 80 00       	push   $0x8034b0
  801b84:	e8 5b e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801b89:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b8e:	7e 16                	jle    801ba6 <devfile_read+0x65>
  801b90:	68 bb 34 80 00       	push   $0x8034bb
  801b95:	68 9b 34 80 00       	push   $0x80349b
  801b9a:	6a 7d                	push   $0x7d
  801b9c:	68 b0 34 80 00       	push   $0x8034b0
  801ba1:	e8 3e e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ba6:	83 ec 04             	sub    $0x4,%esp
  801ba9:	50                   	push   %eax
  801baa:	68 00 60 80 00       	push   $0x806000
  801baf:	ff 75 0c             	pushl  0xc(%ebp)
  801bb2:	e8 1d f1 ff ff       	call   800cd4 <memmove>
	return r;
  801bb7:	83 c4 10             	add    $0x10,%esp
}
  801bba:	89 d8                	mov    %ebx,%eax
  801bbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	53                   	push   %ebx
  801bc7:	83 ec 20             	sub    $0x20,%esp
  801bca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bcd:	53                   	push   %ebx
  801bce:	e8 36 ef ff ff       	call   800b09 <strlen>
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bdb:	7f 67                	jg     801c44 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be3:	50                   	push   %eax
  801be4:	e8 a7 f8 ff ff       	call   801490 <fd_alloc>
  801be9:	83 c4 10             	add    $0x10,%esp
		return r;
  801bec:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 57                	js     801c49 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bf2:	83 ec 08             	sub    $0x8,%esp
  801bf5:	53                   	push   %ebx
  801bf6:	68 00 60 80 00       	push   $0x806000
  801bfb:	e8 42 ef ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c03:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c10:	e8 03 fe ff ff       	call   801a18 <fsipc>
  801c15:	89 c3                	mov    %eax,%ebx
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	79 14                	jns    801c32 <open+0x6f>
		fd_close(fd, 0);
  801c1e:	83 ec 08             	sub    $0x8,%esp
  801c21:	6a 00                	push   $0x0
  801c23:	ff 75 f4             	pushl  -0xc(%ebp)
  801c26:	e8 5d f9 ff ff       	call   801588 <fd_close>
		return r;
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	89 da                	mov    %ebx,%edx
  801c30:	eb 17                	jmp    801c49 <open+0x86>
	}

	return fd2num(fd);
  801c32:	83 ec 0c             	sub    $0xc,%esp
  801c35:	ff 75 f4             	pushl  -0xc(%ebp)
  801c38:	e8 2c f8 ff ff       	call   801469 <fd2num>
  801c3d:	89 c2                	mov    %eax,%edx
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	eb 05                	jmp    801c49 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c44:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c49:	89 d0                	mov    %edx,%eax
  801c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4e:	c9                   	leave  
  801c4f:	c3                   	ret    

00801c50 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c56:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5b:	b8 08 00 00 00       	mov    $0x8,%eax
  801c60:	e8 b3 fd ff ff       	call   801a18 <fsipc>
}
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	57                   	push   %edi
  801c6b:	56                   	push   %esi
  801c6c:	53                   	push   %ebx
  801c6d:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c73:	6a 00                	push   $0x0
  801c75:	ff 75 08             	pushl  0x8(%ebp)
  801c78:	e8 46 ff ff ff       	call   801bc3 <open>
  801c7d:	89 c7                	mov    %eax,%edi
  801c7f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	0f 88 97 04 00 00    	js     802127 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	68 00 02 00 00       	push   $0x200
  801c98:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c9e:	50                   	push   %eax
  801c9f:	57                   	push   %edi
  801ca0:	e8 31 fb ff ff       	call   8017d6 <readn>
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	3d 00 02 00 00       	cmp    $0x200,%eax
  801cad:	75 0c                	jne    801cbb <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801caf:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801cb6:	45 4c 46 
  801cb9:	74 33                	je     801cee <spawn+0x87>
		close(fd);
  801cbb:	83 ec 0c             	sub    $0xc,%esp
  801cbe:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cc4:	e8 40 f9 ff ff       	call   801609 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801cc9:	83 c4 0c             	add    $0xc,%esp
  801ccc:	68 7f 45 4c 46       	push   $0x464c457f
  801cd1:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801cd7:	68 c7 34 80 00       	push   $0x8034c7
  801cdc:	e8 dc e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801ce9:	e9 ec 04 00 00       	jmp    8021da <spawn+0x573>
  801cee:	b8 07 00 00 00       	mov    $0x7,%eax
  801cf3:	cd 30                	int    $0x30
  801cf5:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801cfb:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d01:	85 c0                	test   %eax,%eax
  801d03:	0f 88 29 04 00 00    	js     802132 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d09:	89 c6                	mov    %eax,%esi
  801d0b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d11:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d14:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d1a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d20:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d27:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d2d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d33:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d38:	be 00 00 00 00       	mov    $0x0,%esi
  801d3d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d40:	eb 13                	jmp    801d55 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d42:	83 ec 0c             	sub    $0xc,%esp
  801d45:	50                   	push   %eax
  801d46:	e8 be ed ff ff       	call   800b09 <strlen>
  801d4b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d4f:	83 c3 01             	add    $0x1,%ebx
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d5c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	75 df                	jne    801d42 <spawn+0xdb>
  801d63:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d69:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d6f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d74:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d76:	89 fa                	mov    %edi,%edx
  801d78:	83 e2 fc             	and    $0xfffffffc,%edx
  801d7b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d82:	29 c2                	sub    %eax,%edx
  801d84:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d8a:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d8d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d92:	0f 86 b0 03 00 00    	jbe    802148 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d98:	83 ec 04             	sub    $0x4,%esp
  801d9b:	6a 07                	push   $0x7
  801d9d:	68 00 00 40 00       	push   $0x400000
  801da2:	6a 00                	push   $0x0
  801da4:	e8 9c f1 ff ff       	call   800f45 <sys_page_alloc>
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 9e 03 00 00    	js     802152 <spawn+0x4eb>
  801db4:	be 00 00 00 00       	mov    $0x0,%esi
  801db9:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801dbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dc2:	eb 30                	jmp    801df4 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801dc4:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801dca:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801dd0:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801dd3:	83 ec 08             	sub    $0x8,%esp
  801dd6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801dd9:	57                   	push   %edi
  801dda:	e8 63 ed ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801ddf:	83 c4 04             	add    $0x4,%esp
  801de2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801de5:	e8 1f ed ff ff       	call   800b09 <strlen>
  801dea:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801dee:	83 c6 01             	add    $0x1,%esi
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801dfa:	7f c8                	jg     801dc4 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801dfc:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e02:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801e08:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e0f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e15:	74 19                	je     801e30 <spawn+0x1c9>
  801e17:	68 54 35 80 00       	push   $0x803554
  801e1c:	68 9b 34 80 00       	push   $0x80349b
  801e21:	68 f2 00 00 00       	push   $0xf2
  801e26:	68 e1 34 80 00       	push   $0x8034e1
  801e2b:	e8 b4 e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e30:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e36:	89 f8                	mov    %edi,%eax
  801e38:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e3d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e40:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e46:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e49:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e4f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e55:	83 ec 0c             	sub    $0xc,%esp
  801e58:	6a 07                	push   $0x7
  801e5a:	68 00 d0 bf ee       	push   $0xeebfd000
  801e5f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e65:	68 00 00 40 00       	push   $0x400000
  801e6a:	6a 00                	push   $0x0
  801e6c:	e8 17 f1 ff ff       	call   800f88 <sys_page_map>
  801e71:	89 c3                	mov    %eax,%ebx
  801e73:	83 c4 20             	add    $0x20,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	0f 88 4a 03 00 00    	js     8021c8 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e7e:	83 ec 08             	sub    $0x8,%esp
  801e81:	68 00 00 40 00       	push   $0x400000
  801e86:	6a 00                	push   $0x0
  801e88:	e8 3d f1 ff ff       	call   800fca <sys_page_unmap>
  801e8d:	89 c3                	mov    %eax,%ebx
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	0f 88 2e 03 00 00    	js     8021c8 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e9a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ea0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ea7:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ead:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801eb4:	00 00 00 
  801eb7:	e9 8a 01 00 00       	jmp    802046 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801ebc:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ec2:	83 38 01             	cmpl   $0x1,(%eax)
  801ec5:	0f 85 6d 01 00 00    	jne    802038 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ecb:	89 c7                	mov    %eax,%edi
  801ecd:	8b 40 18             	mov    0x18(%eax),%eax
  801ed0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ed6:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ed9:	83 f8 01             	cmp    $0x1,%eax
  801edc:	19 c0                	sbb    %eax,%eax
  801ede:	83 e0 fe             	and    $0xfffffffe,%eax
  801ee1:	83 c0 07             	add    $0x7,%eax
  801ee4:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801eea:	89 f8                	mov    %edi,%eax
  801eec:	8b 7f 04             	mov    0x4(%edi),%edi
  801eef:	89 f9                	mov    %edi,%ecx
  801ef1:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801ef7:	8b 78 10             	mov    0x10(%eax),%edi
  801efa:	8b 70 14             	mov    0x14(%eax),%esi
  801efd:	89 f3                	mov    %esi,%ebx
  801eff:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801f05:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f08:	89 f0                	mov    %esi,%eax
  801f0a:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f0f:	74 14                	je     801f25 <spawn+0x2be>
		va -= i;
  801f11:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f13:	01 c3                	add    %eax,%ebx
  801f15:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801f1b:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f1d:	29 c1                	sub    %eax,%ecx
  801f1f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f25:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f2a:	e9 f7 00 00 00       	jmp    802026 <spawn+0x3bf>
		if (i >= filesz) {
  801f2f:	39 df                	cmp    %ebx,%edi
  801f31:	77 27                	ja     801f5a <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f33:	83 ec 04             	sub    $0x4,%esp
  801f36:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f3c:	56                   	push   %esi
  801f3d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f43:	e8 fd ef ff ff       	call   800f45 <sys_page_alloc>
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	0f 89 c7 00 00 00    	jns    80201a <spawn+0x3b3>
  801f53:	89 c3                	mov    %eax,%ebx
  801f55:	e9 09 02 00 00       	jmp    802163 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f5a:	83 ec 04             	sub    $0x4,%esp
  801f5d:	6a 07                	push   $0x7
  801f5f:	68 00 00 40 00       	push   $0x400000
  801f64:	6a 00                	push   $0x0
  801f66:	e8 da ef ff ff       	call   800f45 <sys_page_alloc>
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	0f 88 e3 01 00 00    	js     802159 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f76:	83 ec 08             	sub    $0x8,%esp
  801f79:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f7f:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f85:	50                   	push   %eax
  801f86:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f8c:	e8 1a f9 ff ff       	call   8018ab <seek>
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	85 c0                	test   %eax,%eax
  801f96:	0f 88 c1 01 00 00    	js     80215d <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f9c:	83 ec 04             	sub    $0x4,%esp
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801fa7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801fac:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801fb1:	0f 47 c1             	cmova  %ecx,%eax
  801fb4:	50                   	push   %eax
  801fb5:	68 00 00 40 00       	push   $0x400000
  801fba:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fc0:	e8 11 f8 ff ff       	call   8017d6 <readn>
  801fc5:	83 c4 10             	add    $0x10,%esp
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	0f 88 91 01 00 00    	js     802161 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fd0:	83 ec 0c             	sub    $0xc,%esp
  801fd3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fd9:	56                   	push   %esi
  801fda:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fe0:	68 00 00 40 00       	push   $0x400000
  801fe5:	6a 00                	push   $0x0
  801fe7:	e8 9c ef ff ff       	call   800f88 <sys_page_map>
  801fec:	83 c4 20             	add    $0x20,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	79 15                	jns    802008 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801ff3:	50                   	push   %eax
  801ff4:	68 ed 34 80 00       	push   $0x8034ed
  801ff9:	68 25 01 00 00       	push   $0x125
  801ffe:	68 e1 34 80 00       	push   $0x8034e1
  802003:	e8 dc e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  802008:	83 ec 08             	sub    $0x8,%esp
  80200b:	68 00 00 40 00       	push   $0x400000
  802010:	6a 00                	push   $0x0
  802012:	e8 b3 ef ff ff       	call   800fca <sys_page_unmap>
  802017:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80201a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802020:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802026:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80202c:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802032:	0f 87 f7 fe ff ff    	ja     801f2f <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802038:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80203f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802046:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80204d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802053:	0f 8c 63 fe ff ff    	jl     801ebc <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802059:	83 ec 0c             	sub    $0xc,%esp
  80205c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802062:	e8 a2 f5 ff ff       	call   801609 <close>
  802067:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80206a:	bb 00 08 00 00       	mov    $0x800,%ebx
  80206f:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  802075:	89 d8                	mov    %ebx,%eax
  802077:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80207a:	89 c2                	mov    %eax,%edx
  80207c:	c1 ea 16             	shr    $0x16,%edx
  80207f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802086:	f6 c2 01             	test   $0x1,%dl
  802089:	74 4b                	je     8020d6 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80208b:	89 c2                	mov    %eax,%edx
  80208d:	c1 ea 0c             	shr    $0xc,%edx
  802090:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  802097:	f6 c1 01             	test   $0x1,%cl
  80209a:	74 3a                	je     8020d6 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  80209c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8020a3:	f6 c6 04             	test   $0x4,%dh
  8020a6:	74 2e                	je     8020d6 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  8020a8:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  8020af:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8020b5:	8b 49 48             	mov    0x48(%ecx),%ecx
  8020b8:	83 ec 0c             	sub    $0xc,%esp
  8020bb:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8020c1:	52                   	push   %edx
  8020c2:	50                   	push   %eax
  8020c3:	56                   	push   %esi
  8020c4:	50                   	push   %eax
  8020c5:	51                   	push   %ecx
  8020c6:	e8 bd ee ff ff       	call   800f88 <sys_page_map>
					if (r < 0)
  8020cb:	83 c4 20             	add    $0x20,%esp
  8020ce:	85 c0                	test   %eax,%eax
  8020d0:	0f 88 ae 00 00 00    	js     802184 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8020d6:	83 c3 01             	add    $0x1,%ebx
  8020d9:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8020df:	75 94                	jne    802075 <spawn+0x40e>
  8020e1:	e9 b3 00 00 00       	jmp    802199 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8020e6:	50                   	push   %eax
  8020e7:	68 0a 35 80 00       	push   $0x80350a
  8020ec:	68 86 00 00 00       	push   $0x86
  8020f1:	68 e1 34 80 00       	push   $0x8034e1
  8020f6:	e8 e9 e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8020fb:	83 ec 08             	sub    $0x8,%esp
  8020fe:	6a 02                	push   $0x2
  802100:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802106:	e8 01 ef ff ff       	call   80100c <sys_env_set_status>
  80210b:	83 c4 10             	add    $0x10,%esp
  80210e:	85 c0                	test   %eax,%eax
  802110:	79 2b                	jns    80213d <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  802112:	50                   	push   %eax
  802113:	68 24 35 80 00       	push   $0x803524
  802118:	68 89 00 00 00       	push   $0x89
  80211d:	68 e1 34 80 00       	push   $0x8034e1
  802122:	e8 bd e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802127:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80212d:	e9 a8 00 00 00       	jmp    8021da <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802132:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802138:	e9 9d 00 00 00       	jmp    8021da <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80213d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802143:	e9 92 00 00 00       	jmp    8021da <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802148:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80214d:	e9 88 00 00 00       	jmp    8021da <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802152:	89 c3                	mov    %eax,%ebx
  802154:	e9 81 00 00 00       	jmp    8021da <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802159:	89 c3                	mov    %eax,%ebx
  80215b:	eb 06                	jmp    802163 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80215d:	89 c3                	mov    %eax,%ebx
  80215f:	eb 02                	jmp    802163 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802161:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802163:	83 ec 0c             	sub    $0xc,%esp
  802166:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80216c:	e8 55 ed ff ff       	call   800ec6 <sys_env_destroy>
	close(fd);
  802171:	83 c4 04             	add    $0x4,%esp
  802174:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80217a:	e8 8a f4 ff ff       	call   801609 <close>
	return r;
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	eb 56                	jmp    8021da <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802184:	50                   	push   %eax
  802185:	68 3b 35 80 00       	push   $0x80353b
  80218a:	68 82 00 00 00       	push   $0x82
  80218f:	68 e1 34 80 00       	push   $0x8034e1
  802194:	e8 4b e3 ff ff       	call   8004e4 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802199:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8021a0:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8021a3:	83 ec 08             	sub    $0x8,%esp
  8021a6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8021ac:	50                   	push   %eax
  8021ad:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021b3:	e8 96 ee ff ff       	call   80104e <sys_env_set_trapframe>
  8021b8:	83 c4 10             	add    $0x10,%esp
  8021bb:	85 c0                	test   %eax,%eax
  8021bd:	0f 89 38 ff ff ff    	jns    8020fb <spawn+0x494>
  8021c3:	e9 1e ff ff ff       	jmp    8020e6 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8021c8:	83 ec 08             	sub    $0x8,%esp
  8021cb:	68 00 00 40 00       	push   $0x400000
  8021d0:	6a 00                	push   $0x0
  8021d2:	e8 f3 ed ff ff       	call   800fca <sys_page_unmap>
  8021d7:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021da:	89 d8                	mov    %ebx,%eax
  8021dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    

008021e4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	56                   	push   %esi
  8021e8:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021e9:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021ec:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021f1:	eb 03                	jmp    8021f6 <spawnl+0x12>
		argc++;
  8021f3:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021f6:	83 c2 04             	add    $0x4,%edx
  8021f9:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021fd:	75 f4                	jne    8021f3 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021ff:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802206:	83 e2 f0             	and    $0xfffffff0,%edx
  802209:	29 d4                	sub    %edx,%esp
  80220b:	8d 54 24 03          	lea    0x3(%esp),%edx
  80220f:	c1 ea 02             	shr    $0x2,%edx
  802212:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802219:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80221b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80221e:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802225:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80222c:	00 
  80222d:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80222f:	b8 00 00 00 00       	mov    $0x0,%eax
  802234:	eb 0a                	jmp    802240 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802236:	83 c0 01             	add    $0x1,%eax
  802239:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80223d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802240:	39 d0                	cmp    %edx,%eax
  802242:	75 f2                	jne    802236 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802244:	83 ec 08             	sub    $0x8,%esp
  802247:	56                   	push   %esi
  802248:	ff 75 08             	pushl  0x8(%ebp)
  80224b:	e8 17 fa ff ff       	call   801c67 <spawn>
}
  802250:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    

00802257 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80225d:	68 7c 35 80 00       	push   $0x80357c
  802262:	ff 75 0c             	pushl  0xc(%ebp)
  802265:	e8 d8 e8 ff ff       	call   800b42 <strcpy>
	return 0;
}
  80226a:	b8 00 00 00 00       	mov    $0x0,%eax
  80226f:	c9                   	leave  
  802270:	c3                   	ret    

00802271 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	53                   	push   %ebx
  802275:	83 ec 10             	sub    $0x10,%esp
  802278:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80227b:	53                   	push   %ebx
  80227c:	e8 47 09 00 00       	call   802bc8 <pageref>
  802281:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802284:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802289:	83 f8 01             	cmp    $0x1,%eax
  80228c:	75 10                	jne    80229e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80228e:	83 ec 0c             	sub    $0xc,%esp
  802291:	ff 73 0c             	pushl  0xc(%ebx)
  802294:	e8 c0 02 00 00       	call   802559 <nsipc_close>
  802299:	89 c2                	mov    %eax,%edx
  80229b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80229e:	89 d0                	mov    %edx,%eax
  8022a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022a3:	c9                   	leave  
  8022a4:	c3                   	ret    

008022a5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8022a5:	55                   	push   %ebp
  8022a6:	89 e5                	mov    %esp,%ebp
  8022a8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8022ab:	6a 00                	push   $0x0
  8022ad:	ff 75 10             	pushl  0x10(%ebp)
  8022b0:	ff 75 0c             	pushl  0xc(%ebp)
  8022b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b6:	ff 70 0c             	pushl  0xc(%eax)
  8022b9:	e8 78 03 00 00       	call   802636 <nsipc_send>
}
  8022be:	c9                   	leave  
  8022bf:	c3                   	ret    

008022c0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8022c6:	6a 00                	push   $0x0
  8022c8:	ff 75 10             	pushl  0x10(%ebp)
  8022cb:	ff 75 0c             	pushl  0xc(%ebp)
  8022ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d1:	ff 70 0c             	pushl  0xc(%eax)
  8022d4:	e8 f1 02 00 00       	call   8025ca <nsipc_recv>
}
  8022d9:	c9                   	leave  
  8022da:	c3                   	ret    

008022db <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8022e1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8022e4:	52                   	push   %edx
  8022e5:	50                   	push   %eax
  8022e6:	e8 f4 f1 ff ff       	call   8014df <fd_lookup>
  8022eb:	83 c4 10             	add    $0x10,%esp
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	78 17                	js     802309 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8022f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f5:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  8022fb:	39 08                	cmp    %ecx,(%eax)
  8022fd:	75 05                	jne    802304 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8022ff:	8b 40 0c             	mov    0xc(%eax),%eax
  802302:	eb 05                	jmp    802309 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802304:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802309:	c9                   	leave  
  80230a:	c3                   	ret    

0080230b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80230b:	55                   	push   %ebp
  80230c:	89 e5                	mov    %esp,%ebp
  80230e:	56                   	push   %esi
  80230f:	53                   	push   %ebx
  802310:	83 ec 1c             	sub    $0x1c,%esp
  802313:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802318:	50                   	push   %eax
  802319:	e8 72 f1 ff ff       	call   801490 <fd_alloc>
  80231e:	89 c3                	mov    %eax,%ebx
  802320:	83 c4 10             	add    $0x10,%esp
  802323:	85 c0                	test   %eax,%eax
  802325:	78 1b                	js     802342 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802327:	83 ec 04             	sub    $0x4,%esp
  80232a:	68 07 04 00 00       	push   $0x407
  80232f:	ff 75 f4             	pushl  -0xc(%ebp)
  802332:	6a 00                	push   $0x0
  802334:	e8 0c ec ff ff       	call   800f45 <sys_page_alloc>
  802339:	89 c3                	mov    %eax,%ebx
  80233b:	83 c4 10             	add    $0x10,%esp
  80233e:	85 c0                	test   %eax,%eax
  802340:	79 10                	jns    802352 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802342:	83 ec 0c             	sub    $0xc,%esp
  802345:	56                   	push   %esi
  802346:	e8 0e 02 00 00       	call   802559 <nsipc_close>
		return r;
  80234b:	83 c4 10             	add    $0x10,%esp
  80234e:	89 d8                	mov    %ebx,%eax
  802350:	eb 24                	jmp    802376 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802352:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80235d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802360:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802367:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80236a:	83 ec 0c             	sub    $0xc,%esp
  80236d:	50                   	push   %eax
  80236e:	e8 f6 f0 ff ff       	call   801469 <fd2num>
  802373:	83 c4 10             	add    $0x10,%esp
}
  802376:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802379:	5b                   	pop    %ebx
  80237a:	5e                   	pop    %esi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    

0080237d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80237d:	55                   	push   %ebp
  80237e:	89 e5                	mov    %esp,%ebp
  802380:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802383:	8b 45 08             	mov    0x8(%ebp),%eax
  802386:	e8 50 ff ff ff       	call   8022db <fd2sockid>
		return r;
  80238b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 1f                	js     8023b0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802391:	83 ec 04             	sub    $0x4,%esp
  802394:	ff 75 10             	pushl  0x10(%ebp)
  802397:	ff 75 0c             	pushl  0xc(%ebp)
  80239a:	50                   	push   %eax
  80239b:	e8 12 01 00 00       	call   8024b2 <nsipc_accept>
  8023a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8023a3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	78 07                	js     8023b0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8023a9:	e8 5d ff ff ff       	call   80230b <alloc_sockfd>
  8023ae:	89 c1                	mov    %eax,%ecx
}
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	c9                   	leave  
  8023b3:	c3                   	ret    

008023b4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023b4:	55                   	push   %ebp
  8023b5:	89 e5                	mov    %esp,%ebp
  8023b7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bd:	e8 19 ff ff ff       	call   8022db <fd2sockid>
  8023c2:	85 c0                	test   %eax,%eax
  8023c4:	78 12                	js     8023d8 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8023c6:	83 ec 04             	sub    $0x4,%esp
  8023c9:	ff 75 10             	pushl  0x10(%ebp)
  8023cc:	ff 75 0c             	pushl  0xc(%ebp)
  8023cf:	50                   	push   %eax
  8023d0:	e8 2d 01 00 00       	call   802502 <nsipc_bind>
  8023d5:	83 c4 10             	add    $0x10,%esp
}
  8023d8:	c9                   	leave  
  8023d9:	c3                   	ret    

008023da <shutdown>:

int
shutdown(int s, int how)
{
  8023da:	55                   	push   %ebp
  8023db:	89 e5                	mov    %esp,%ebp
  8023dd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e3:	e8 f3 fe ff ff       	call   8022db <fd2sockid>
  8023e8:	85 c0                	test   %eax,%eax
  8023ea:	78 0f                	js     8023fb <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8023ec:	83 ec 08             	sub    $0x8,%esp
  8023ef:	ff 75 0c             	pushl  0xc(%ebp)
  8023f2:	50                   	push   %eax
  8023f3:	e8 3f 01 00 00       	call   802537 <nsipc_shutdown>
  8023f8:	83 c4 10             	add    $0x10,%esp
}
  8023fb:	c9                   	leave  
  8023fc:	c3                   	ret    

008023fd <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023fd:	55                   	push   %ebp
  8023fe:	89 e5                	mov    %esp,%ebp
  802400:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802403:	8b 45 08             	mov    0x8(%ebp),%eax
  802406:	e8 d0 fe ff ff       	call   8022db <fd2sockid>
  80240b:	85 c0                	test   %eax,%eax
  80240d:	78 12                	js     802421 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80240f:	83 ec 04             	sub    $0x4,%esp
  802412:	ff 75 10             	pushl  0x10(%ebp)
  802415:	ff 75 0c             	pushl  0xc(%ebp)
  802418:	50                   	push   %eax
  802419:	e8 55 01 00 00       	call   802573 <nsipc_connect>
  80241e:	83 c4 10             	add    $0x10,%esp
}
  802421:	c9                   	leave  
  802422:	c3                   	ret    

00802423 <listen>:

int
listen(int s, int backlog)
{
  802423:	55                   	push   %ebp
  802424:	89 e5                	mov    %esp,%ebp
  802426:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802429:	8b 45 08             	mov    0x8(%ebp),%eax
  80242c:	e8 aa fe ff ff       	call   8022db <fd2sockid>
  802431:	85 c0                	test   %eax,%eax
  802433:	78 0f                	js     802444 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802435:	83 ec 08             	sub    $0x8,%esp
  802438:	ff 75 0c             	pushl  0xc(%ebp)
  80243b:	50                   	push   %eax
  80243c:	e8 67 01 00 00       	call   8025a8 <nsipc_listen>
  802441:	83 c4 10             	add    $0x10,%esp
}
  802444:	c9                   	leave  
  802445:	c3                   	ret    

00802446 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802446:	55                   	push   %ebp
  802447:	89 e5                	mov    %esp,%ebp
  802449:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80244c:	ff 75 10             	pushl  0x10(%ebp)
  80244f:	ff 75 0c             	pushl  0xc(%ebp)
  802452:	ff 75 08             	pushl  0x8(%ebp)
  802455:	e8 3a 02 00 00       	call   802694 <nsipc_socket>
  80245a:	83 c4 10             	add    $0x10,%esp
  80245d:	85 c0                	test   %eax,%eax
  80245f:	78 05                	js     802466 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802461:	e8 a5 fe ff ff       	call   80230b <alloc_sockfd>
}
  802466:	c9                   	leave  
  802467:	c3                   	ret    

00802468 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
  80246b:	53                   	push   %ebx
  80246c:	83 ec 04             	sub    $0x4,%esp
  80246f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802471:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802478:	75 12                	jne    80248c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80247a:	83 ec 0c             	sub    $0xc,%esp
  80247d:	6a 02                	push   $0x2
  80247f:	e8 0b 07 00 00       	call   802b8f <ipc_find_env>
  802484:	a3 04 50 80 00       	mov    %eax,0x805004
  802489:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80248c:	6a 07                	push   $0x7
  80248e:	68 00 70 80 00       	push   $0x807000
  802493:	53                   	push   %ebx
  802494:	ff 35 04 50 80 00    	pushl  0x805004
  80249a:	e8 9c 06 00 00       	call   802b3b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80249f:	83 c4 0c             	add    $0xc,%esp
  8024a2:	6a 00                	push   $0x0
  8024a4:	6a 00                	push   $0x0
  8024a6:	6a 00                	push   $0x0
  8024a8:	e8 27 06 00 00       	call   802ad4 <ipc_recv>
}
  8024ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024b0:	c9                   	leave  
  8024b1:	c3                   	ret    

008024b2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024b2:	55                   	push   %ebp
  8024b3:	89 e5                	mov    %esp,%ebp
  8024b5:	56                   	push   %esi
  8024b6:	53                   	push   %ebx
  8024b7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8024ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8024c2:	8b 06                	mov    (%esi),%eax
  8024c4:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8024c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ce:	e8 95 ff ff ff       	call   802468 <nsipc>
  8024d3:	89 c3                	mov    %eax,%ebx
  8024d5:	85 c0                	test   %eax,%eax
  8024d7:	78 20                	js     8024f9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8024d9:	83 ec 04             	sub    $0x4,%esp
  8024dc:	ff 35 10 70 80 00    	pushl  0x807010
  8024e2:	68 00 70 80 00       	push   $0x807000
  8024e7:	ff 75 0c             	pushl  0xc(%ebp)
  8024ea:	e8 e5 e7 ff ff       	call   800cd4 <memmove>
		*addrlen = ret->ret_addrlen;
  8024ef:	a1 10 70 80 00       	mov    0x807010,%eax
  8024f4:	89 06                	mov    %eax,(%esi)
  8024f6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8024f9:	89 d8                	mov    %ebx,%eax
  8024fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024fe:	5b                   	pop    %ebx
  8024ff:	5e                   	pop    %esi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    

00802502 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802502:	55                   	push   %ebp
  802503:	89 e5                	mov    %esp,%ebp
  802505:	53                   	push   %ebx
  802506:	83 ec 08             	sub    $0x8,%esp
  802509:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80250c:	8b 45 08             	mov    0x8(%ebp),%eax
  80250f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802514:	53                   	push   %ebx
  802515:	ff 75 0c             	pushl  0xc(%ebp)
  802518:	68 04 70 80 00       	push   $0x807004
  80251d:	e8 b2 e7 ff ff       	call   800cd4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802522:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802528:	b8 02 00 00 00       	mov    $0x2,%eax
  80252d:	e8 36 ff ff ff       	call   802468 <nsipc>
}
  802532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802535:	c9                   	leave  
  802536:	c3                   	ret    

00802537 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80253d:	8b 45 08             	mov    0x8(%ebp),%eax
  802540:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802545:	8b 45 0c             	mov    0xc(%ebp),%eax
  802548:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80254d:	b8 03 00 00 00       	mov    $0x3,%eax
  802552:	e8 11 ff ff ff       	call   802468 <nsipc>
}
  802557:	c9                   	leave  
  802558:	c3                   	ret    

00802559 <nsipc_close>:

int
nsipc_close(int s)
{
  802559:	55                   	push   %ebp
  80255a:	89 e5                	mov    %esp,%ebp
  80255c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80255f:	8b 45 08             	mov    0x8(%ebp),%eax
  802562:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802567:	b8 04 00 00 00       	mov    $0x4,%eax
  80256c:	e8 f7 fe ff ff       	call   802468 <nsipc>
}
  802571:	c9                   	leave  
  802572:	c3                   	ret    

00802573 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802573:	55                   	push   %ebp
  802574:	89 e5                	mov    %esp,%ebp
  802576:	53                   	push   %ebx
  802577:	83 ec 08             	sub    $0x8,%esp
  80257a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80257d:	8b 45 08             	mov    0x8(%ebp),%eax
  802580:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802585:	53                   	push   %ebx
  802586:	ff 75 0c             	pushl  0xc(%ebp)
  802589:	68 04 70 80 00       	push   $0x807004
  80258e:	e8 41 e7 ff ff       	call   800cd4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802593:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802599:	b8 05 00 00 00       	mov    $0x5,%eax
  80259e:	e8 c5 fe ff ff       	call   802468 <nsipc>
}
  8025a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025a6:	c9                   	leave  
  8025a7:	c3                   	ret    

008025a8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8025a8:	55                   	push   %ebp
  8025a9:	89 e5                	mov    %esp,%ebp
  8025ab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8025ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8025b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025b9:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8025be:	b8 06 00 00 00       	mov    $0x6,%eax
  8025c3:	e8 a0 fe ff ff       	call   802468 <nsipc>
}
  8025c8:	c9                   	leave  
  8025c9:	c3                   	ret    

008025ca <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8025ca:	55                   	push   %ebp
  8025cb:	89 e5                	mov    %esp,%ebp
  8025cd:	56                   	push   %esi
  8025ce:	53                   	push   %ebx
  8025cf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8025d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8025da:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8025e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8025e3:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025e8:	b8 07 00 00 00       	mov    $0x7,%eax
  8025ed:	e8 76 fe ff ff       	call   802468 <nsipc>
  8025f2:	89 c3                	mov    %eax,%ebx
  8025f4:	85 c0                	test   %eax,%eax
  8025f6:	78 35                	js     80262d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8025f8:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8025fd:	7f 04                	jg     802603 <nsipc_recv+0x39>
  8025ff:	39 c6                	cmp    %eax,%esi
  802601:	7d 16                	jge    802619 <nsipc_recv+0x4f>
  802603:	68 88 35 80 00       	push   $0x803588
  802608:	68 9b 34 80 00       	push   $0x80349b
  80260d:	6a 62                	push   $0x62
  80260f:	68 9d 35 80 00       	push   $0x80359d
  802614:	e8 cb de ff ff       	call   8004e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802619:	83 ec 04             	sub    $0x4,%esp
  80261c:	50                   	push   %eax
  80261d:	68 00 70 80 00       	push   $0x807000
  802622:	ff 75 0c             	pushl  0xc(%ebp)
  802625:	e8 aa e6 ff ff       	call   800cd4 <memmove>
  80262a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80262d:	89 d8                	mov    %ebx,%eax
  80262f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802632:	5b                   	pop    %ebx
  802633:	5e                   	pop    %esi
  802634:	5d                   	pop    %ebp
  802635:	c3                   	ret    

00802636 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	53                   	push   %ebx
  80263a:	83 ec 04             	sub    $0x4,%esp
  80263d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802640:	8b 45 08             	mov    0x8(%ebp),%eax
  802643:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802648:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80264e:	7e 16                	jle    802666 <nsipc_send+0x30>
  802650:	68 a9 35 80 00       	push   $0x8035a9
  802655:	68 9b 34 80 00       	push   $0x80349b
  80265a:	6a 6d                	push   $0x6d
  80265c:	68 9d 35 80 00       	push   $0x80359d
  802661:	e8 7e de ff ff       	call   8004e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802666:	83 ec 04             	sub    $0x4,%esp
  802669:	53                   	push   %ebx
  80266a:	ff 75 0c             	pushl  0xc(%ebp)
  80266d:	68 0c 70 80 00       	push   $0x80700c
  802672:	e8 5d e6 ff ff       	call   800cd4 <memmove>
	nsipcbuf.send.req_size = size;
  802677:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80267d:	8b 45 14             	mov    0x14(%ebp),%eax
  802680:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802685:	b8 08 00 00 00       	mov    $0x8,%eax
  80268a:	e8 d9 fd ff ff       	call   802468 <nsipc>
}
  80268f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802692:	c9                   	leave  
  802693:	c3                   	ret    

00802694 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802694:	55                   	push   %ebp
  802695:	89 e5                	mov    %esp,%ebp
  802697:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80269a:	8b 45 08             	mov    0x8(%ebp),%eax
  80269d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8026a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026a5:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8026aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8026ad:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8026b2:	b8 09 00 00 00       	mov    $0x9,%eax
  8026b7:	e8 ac fd ff ff       	call   802468 <nsipc>
}
  8026bc:	c9                   	leave  
  8026bd:	c3                   	ret    

008026be <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8026be:	55                   	push   %ebp
  8026bf:	89 e5                	mov    %esp,%ebp
  8026c1:	56                   	push   %esi
  8026c2:	53                   	push   %ebx
  8026c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8026c6:	83 ec 0c             	sub    $0xc,%esp
  8026c9:	ff 75 08             	pushl  0x8(%ebp)
  8026cc:	e8 a8 ed ff ff       	call   801479 <fd2data>
  8026d1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8026d3:	83 c4 08             	add    $0x8,%esp
  8026d6:	68 b5 35 80 00       	push   $0x8035b5
  8026db:	53                   	push   %ebx
  8026dc:	e8 61 e4 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8026e1:	8b 46 04             	mov    0x4(%esi),%eax
  8026e4:	2b 06                	sub    (%esi),%eax
  8026e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8026ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8026f3:	00 00 00 
	stat->st_dev = &devpipe;
  8026f6:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  8026fd:	40 80 00 
	return 0;
}
  802700:	b8 00 00 00 00       	mov    $0x0,%eax
  802705:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802708:	5b                   	pop    %ebx
  802709:	5e                   	pop    %esi
  80270a:	5d                   	pop    %ebp
  80270b:	c3                   	ret    

0080270c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80270c:	55                   	push   %ebp
  80270d:	89 e5                	mov    %esp,%ebp
  80270f:	53                   	push   %ebx
  802710:	83 ec 0c             	sub    $0xc,%esp
  802713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802716:	53                   	push   %ebx
  802717:	6a 00                	push   $0x0
  802719:	e8 ac e8 ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80271e:	89 1c 24             	mov    %ebx,(%esp)
  802721:	e8 53 ed ff ff       	call   801479 <fd2data>
  802726:	83 c4 08             	add    $0x8,%esp
  802729:	50                   	push   %eax
  80272a:	6a 00                	push   $0x0
  80272c:	e8 99 e8 ff ff       	call   800fca <sys_page_unmap>
}
  802731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802734:	c9                   	leave  
  802735:	c3                   	ret    

00802736 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802736:	55                   	push   %ebp
  802737:	89 e5                	mov    %esp,%ebp
  802739:	57                   	push   %edi
  80273a:	56                   	push   %esi
  80273b:	53                   	push   %ebx
  80273c:	83 ec 1c             	sub    $0x1c,%esp
  80273f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802742:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802744:	a1 08 50 80 00       	mov    0x805008,%eax
  802749:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80274c:	83 ec 0c             	sub    $0xc,%esp
  80274f:	ff 75 e0             	pushl  -0x20(%ebp)
  802752:	e8 71 04 00 00       	call   802bc8 <pageref>
  802757:	89 c3                	mov    %eax,%ebx
  802759:	89 3c 24             	mov    %edi,(%esp)
  80275c:	e8 67 04 00 00       	call   802bc8 <pageref>
  802761:	83 c4 10             	add    $0x10,%esp
  802764:	39 c3                	cmp    %eax,%ebx
  802766:	0f 94 c1             	sete   %cl
  802769:	0f b6 c9             	movzbl %cl,%ecx
  80276c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80276f:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802775:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802778:	39 ce                	cmp    %ecx,%esi
  80277a:	74 1b                	je     802797 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80277c:	39 c3                	cmp    %eax,%ebx
  80277e:	75 c4                	jne    802744 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802780:	8b 42 58             	mov    0x58(%edx),%eax
  802783:	ff 75 e4             	pushl  -0x1c(%ebp)
  802786:	50                   	push   %eax
  802787:	56                   	push   %esi
  802788:	68 bc 35 80 00       	push   $0x8035bc
  80278d:	e8 2b de ff ff       	call   8005bd <cprintf>
  802792:	83 c4 10             	add    $0x10,%esp
  802795:	eb ad                	jmp    802744 <_pipeisclosed+0xe>
	}
}
  802797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80279a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80279d:	5b                   	pop    %ebx
  80279e:	5e                   	pop    %esi
  80279f:	5f                   	pop    %edi
  8027a0:	5d                   	pop    %ebp
  8027a1:	c3                   	ret    

008027a2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027a2:	55                   	push   %ebp
  8027a3:	89 e5                	mov    %esp,%ebp
  8027a5:	57                   	push   %edi
  8027a6:	56                   	push   %esi
  8027a7:	53                   	push   %ebx
  8027a8:	83 ec 28             	sub    $0x28,%esp
  8027ab:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8027ae:	56                   	push   %esi
  8027af:	e8 c5 ec ff ff       	call   801479 <fd2data>
  8027b4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027b6:	83 c4 10             	add    $0x10,%esp
  8027b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8027be:	eb 4b                	jmp    80280b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8027c0:	89 da                	mov    %ebx,%edx
  8027c2:	89 f0                	mov    %esi,%eax
  8027c4:	e8 6d ff ff ff       	call   802736 <_pipeisclosed>
  8027c9:	85 c0                	test   %eax,%eax
  8027cb:	75 48                	jne    802815 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8027cd:	e8 54 e7 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8027d2:	8b 43 04             	mov    0x4(%ebx),%eax
  8027d5:	8b 0b                	mov    (%ebx),%ecx
  8027d7:	8d 51 20             	lea    0x20(%ecx),%edx
  8027da:	39 d0                	cmp    %edx,%eax
  8027dc:	73 e2                	jae    8027c0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8027de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027e1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8027e5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8027e8:	89 c2                	mov    %eax,%edx
  8027ea:	c1 fa 1f             	sar    $0x1f,%edx
  8027ed:	89 d1                	mov    %edx,%ecx
  8027ef:	c1 e9 1b             	shr    $0x1b,%ecx
  8027f2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8027f5:	83 e2 1f             	and    $0x1f,%edx
  8027f8:	29 ca                	sub    %ecx,%edx
  8027fa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8027fe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802802:	83 c0 01             	add    $0x1,%eax
  802805:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802808:	83 c7 01             	add    $0x1,%edi
  80280b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80280e:	75 c2                	jne    8027d2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802810:	8b 45 10             	mov    0x10(%ebp),%eax
  802813:	eb 05                	jmp    80281a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802815:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80281a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80281d:	5b                   	pop    %ebx
  80281e:	5e                   	pop    %esi
  80281f:	5f                   	pop    %edi
  802820:	5d                   	pop    %ebp
  802821:	c3                   	ret    

00802822 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802822:	55                   	push   %ebp
  802823:	89 e5                	mov    %esp,%ebp
  802825:	57                   	push   %edi
  802826:	56                   	push   %esi
  802827:	53                   	push   %ebx
  802828:	83 ec 18             	sub    $0x18,%esp
  80282b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80282e:	57                   	push   %edi
  80282f:	e8 45 ec ff ff       	call   801479 <fd2data>
  802834:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802836:	83 c4 10             	add    $0x10,%esp
  802839:	bb 00 00 00 00       	mov    $0x0,%ebx
  80283e:	eb 3d                	jmp    80287d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802840:	85 db                	test   %ebx,%ebx
  802842:	74 04                	je     802848 <devpipe_read+0x26>
				return i;
  802844:	89 d8                	mov    %ebx,%eax
  802846:	eb 44                	jmp    80288c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802848:	89 f2                	mov    %esi,%edx
  80284a:	89 f8                	mov    %edi,%eax
  80284c:	e8 e5 fe ff ff       	call   802736 <_pipeisclosed>
  802851:	85 c0                	test   %eax,%eax
  802853:	75 32                	jne    802887 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802855:	e8 cc e6 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80285a:	8b 06                	mov    (%esi),%eax
  80285c:	3b 46 04             	cmp    0x4(%esi),%eax
  80285f:	74 df                	je     802840 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802861:	99                   	cltd   
  802862:	c1 ea 1b             	shr    $0x1b,%edx
  802865:	01 d0                	add    %edx,%eax
  802867:	83 e0 1f             	and    $0x1f,%eax
  80286a:	29 d0                	sub    %edx,%eax
  80286c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802871:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802874:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802877:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80287a:	83 c3 01             	add    $0x1,%ebx
  80287d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802880:	75 d8                	jne    80285a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802882:	8b 45 10             	mov    0x10(%ebp),%eax
  802885:	eb 05                	jmp    80288c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802887:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80288c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80288f:	5b                   	pop    %ebx
  802890:	5e                   	pop    %esi
  802891:	5f                   	pop    %edi
  802892:	5d                   	pop    %ebp
  802893:	c3                   	ret    

00802894 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802894:	55                   	push   %ebp
  802895:	89 e5                	mov    %esp,%ebp
  802897:	56                   	push   %esi
  802898:	53                   	push   %ebx
  802899:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80289c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80289f:	50                   	push   %eax
  8028a0:	e8 eb eb ff ff       	call   801490 <fd_alloc>
  8028a5:	83 c4 10             	add    $0x10,%esp
  8028a8:	89 c2                	mov    %eax,%edx
  8028aa:	85 c0                	test   %eax,%eax
  8028ac:	0f 88 2c 01 00 00    	js     8029de <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028b2:	83 ec 04             	sub    $0x4,%esp
  8028b5:	68 07 04 00 00       	push   $0x407
  8028ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8028bd:	6a 00                	push   $0x0
  8028bf:	e8 81 e6 ff ff       	call   800f45 <sys_page_alloc>
  8028c4:	83 c4 10             	add    $0x10,%esp
  8028c7:	89 c2                	mov    %eax,%edx
  8028c9:	85 c0                	test   %eax,%eax
  8028cb:	0f 88 0d 01 00 00    	js     8029de <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8028d1:	83 ec 0c             	sub    $0xc,%esp
  8028d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028d7:	50                   	push   %eax
  8028d8:	e8 b3 eb ff ff       	call   801490 <fd_alloc>
  8028dd:	89 c3                	mov    %eax,%ebx
  8028df:	83 c4 10             	add    $0x10,%esp
  8028e2:	85 c0                	test   %eax,%eax
  8028e4:	0f 88 e2 00 00 00    	js     8029cc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028ea:	83 ec 04             	sub    $0x4,%esp
  8028ed:	68 07 04 00 00       	push   $0x407
  8028f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8028f5:	6a 00                	push   $0x0
  8028f7:	e8 49 e6 ff ff       	call   800f45 <sys_page_alloc>
  8028fc:	89 c3                	mov    %eax,%ebx
  8028fe:	83 c4 10             	add    $0x10,%esp
  802901:	85 c0                	test   %eax,%eax
  802903:	0f 88 c3 00 00 00    	js     8029cc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802909:	83 ec 0c             	sub    $0xc,%esp
  80290c:	ff 75 f4             	pushl  -0xc(%ebp)
  80290f:	e8 65 eb ff ff       	call   801479 <fd2data>
  802914:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802916:	83 c4 0c             	add    $0xc,%esp
  802919:	68 07 04 00 00       	push   $0x407
  80291e:	50                   	push   %eax
  80291f:	6a 00                	push   $0x0
  802921:	e8 1f e6 ff ff       	call   800f45 <sys_page_alloc>
  802926:	89 c3                	mov    %eax,%ebx
  802928:	83 c4 10             	add    $0x10,%esp
  80292b:	85 c0                	test   %eax,%eax
  80292d:	0f 88 89 00 00 00    	js     8029bc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802933:	83 ec 0c             	sub    $0xc,%esp
  802936:	ff 75 f0             	pushl  -0x10(%ebp)
  802939:	e8 3b eb ff ff       	call   801479 <fd2data>
  80293e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802945:	50                   	push   %eax
  802946:	6a 00                	push   $0x0
  802948:	56                   	push   %esi
  802949:	6a 00                	push   $0x0
  80294b:	e8 38 e6 ff ff       	call   800f88 <sys_page_map>
  802950:	89 c3                	mov    %eax,%ebx
  802952:	83 c4 20             	add    $0x20,%esp
  802955:	85 c0                	test   %eax,%eax
  802957:	78 55                	js     8029ae <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802959:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80295f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802962:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802964:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802967:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80296e:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802974:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802977:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802979:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80297c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802983:	83 ec 0c             	sub    $0xc,%esp
  802986:	ff 75 f4             	pushl  -0xc(%ebp)
  802989:	e8 db ea ff ff       	call   801469 <fd2num>
  80298e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802991:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802993:	83 c4 04             	add    $0x4,%esp
  802996:	ff 75 f0             	pushl  -0x10(%ebp)
  802999:	e8 cb ea ff ff       	call   801469 <fd2num>
  80299e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029a1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8029a4:	83 c4 10             	add    $0x10,%esp
  8029a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8029ac:	eb 30                	jmp    8029de <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8029ae:	83 ec 08             	sub    $0x8,%esp
  8029b1:	56                   	push   %esi
  8029b2:	6a 00                	push   $0x0
  8029b4:	e8 11 e6 ff ff       	call   800fca <sys_page_unmap>
  8029b9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8029bc:	83 ec 08             	sub    $0x8,%esp
  8029bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8029c2:	6a 00                	push   $0x0
  8029c4:	e8 01 e6 ff ff       	call   800fca <sys_page_unmap>
  8029c9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8029cc:	83 ec 08             	sub    $0x8,%esp
  8029cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8029d2:	6a 00                	push   $0x0
  8029d4:	e8 f1 e5 ff ff       	call   800fca <sys_page_unmap>
  8029d9:	83 c4 10             	add    $0x10,%esp
  8029dc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8029de:	89 d0                	mov    %edx,%eax
  8029e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029e3:	5b                   	pop    %ebx
  8029e4:	5e                   	pop    %esi
  8029e5:	5d                   	pop    %ebp
  8029e6:	c3                   	ret    

008029e7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8029e7:	55                   	push   %ebp
  8029e8:	89 e5                	mov    %esp,%ebp
  8029ea:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029f0:	50                   	push   %eax
  8029f1:	ff 75 08             	pushl  0x8(%ebp)
  8029f4:	e8 e6 ea ff ff       	call   8014df <fd_lookup>
  8029f9:	83 c4 10             	add    $0x10,%esp
  8029fc:	85 c0                	test   %eax,%eax
  8029fe:	78 18                	js     802a18 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802a00:	83 ec 0c             	sub    $0xc,%esp
  802a03:	ff 75 f4             	pushl  -0xc(%ebp)
  802a06:	e8 6e ea ff ff       	call   801479 <fd2data>
	return _pipeisclosed(fd, p);
  802a0b:	89 c2                	mov    %eax,%edx
  802a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a10:	e8 21 fd ff ff       	call   802736 <_pipeisclosed>
  802a15:	83 c4 10             	add    $0x10,%esp
}
  802a18:	c9                   	leave  
  802a19:	c3                   	ret    

00802a1a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802a1a:	55                   	push   %ebp
  802a1b:	89 e5                	mov    %esp,%ebp
  802a1d:	56                   	push   %esi
  802a1e:	53                   	push   %ebx
  802a1f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802a22:	85 f6                	test   %esi,%esi
  802a24:	75 16                	jne    802a3c <wait+0x22>
  802a26:	68 d4 35 80 00       	push   $0x8035d4
  802a2b:	68 9b 34 80 00       	push   $0x80349b
  802a30:	6a 09                	push   $0x9
  802a32:	68 df 35 80 00       	push   $0x8035df
  802a37:	e8 a8 da ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  802a3c:	89 f3                	mov    %esi,%ebx
  802a3e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a44:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802a47:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802a4d:	eb 05                	jmp    802a54 <wait+0x3a>
		sys_yield();
  802a4f:	e8 d2 e4 ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a54:	8b 43 48             	mov    0x48(%ebx),%eax
  802a57:	39 c6                	cmp    %eax,%esi
  802a59:	75 07                	jne    802a62 <wait+0x48>
  802a5b:	8b 43 54             	mov    0x54(%ebx),%eax
  802a5e:	85 c0                	test   %eax,%eax
  802a60:	75 ed                	jne    802a4f <wait+0x35>
		sys_yield();
}
  802a62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a65:	5b                   	pop    %ebx
  802a66:	5e                   	pop    %esi
  802a67:	5d                   	pop    %ebp
  802a68:	c3                   	ret    

00802a69 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a69:	55                   	push   %ebp
  802a6a:	89 e5                	mov    %esp,%ebp
  802a6c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802a6f:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802a76:	75 2e                	jne    802aa6 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802a78:	e8 8a e4 ff ff       	call   800f07 <sys_getenvid>
  802a7d:	83 ec 04             	sub    $0x4,%esp
  802a80:	68 07 0e 00 00       	push   $0xe07
  802a85:	68 00 f0 bf ee       	push   $0xeebff000
  802a8a:	50                   	push   %eax
  802a8b:	e8 b5 e4 ff ff       	call   800f45 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802a90:	e8 72 e4 ff ff       	call   800f07 <sys_getenvid>
  802a95:	83 c4 08             	add    $0x8,%esp
  802a98:	68 b0 2a 80 00       	push   $0x802ab0
  802a9d:	50                   	push   %eax
  802a9e:	e8 ed e5 ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  802aa3:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  802aa9:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802aae:	c9                   	leave  
  802aaf:	c3                   	ret    

00802ab0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ab0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ab1:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802ab6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ab8:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802abb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802abf:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802ac3:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802ac6:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802ac9:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802aca:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802acd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802ace:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802acf:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802ad3:	c3                   	ret    

00802ad4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802ad4:	55                   	push   %ebp
  802ad5:	89 e5                	mov    %esp,%ebp
  802ad7:	56                   	push   %esi
  802ad8:	53                   	push   %ebx
  802ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  802adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  802adf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802ae2:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802ae4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802ae9:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802aec:	83 ec 0c             	sub    $0xc,%esp
  802aef:	50                   	push   %eax
  802af0:	e8 00 e6 ff ff       	call   8010f5 <sys_ipc_recv>

	if (from_env_store != NULL)
  802af5:	83 c4 10             	add    $0x10,%esp
  802af8:	85 f6                	test   %esi,%esi
  802afa:	74 14                	je     802b10 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802afc:	ba 00 00 00 00       	mov    $0x0,%edx
  802b01:	85 c0                	test   %eax,%eax
  802b03:	78 09                	js     802b0e <ipc_recv+0x3a>
  802b05:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802b0b:	8b 52 74             	mov    0x74(%edx),%edx
  802b0e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802b10:	85 db                	test   %ebx,%ebx
  802b12:	74 14                	je     802b28 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802b14:	ba 00 00 00 00       	mov    $0x0,%edx
  802b19:	85 c0                	test   %eax,%eax
  802b1b:	78 09                	js     802b26 <ipc_recv+0x52>
  802b1d:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802b23:	8b 52 78             	mov    0x78(%edx),%edx
  802b26:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802b28:	85 c0                	test   %eax,%eax
  802b2a:	78 08                	js     802b34 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802b2c:	a1 08 50 80 00       	mov    0x805008,%eax
  802b31:	8b 40 70             	mov    0x70(%eax),%eax
}
  802b34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b37:	5b                   	pop    %ebx
  802b38:	5e                   	pop    %esi
  802b39:	5d                   	pop    %ebp
  802b3a:	c3                   	ret    

00802b3b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802b3b:	55                   	push   %ebp
  802b3c:	89 e5                	mov    %esp,%ebp
  802b3e:	57                   	push   %edi
  802b3f:	56                   	push   %esi
  802b40:	53                   	push   %ebx
  802b41:	83 ec 0c             	sub    $0xc,%esp
  802b44:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b47:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802b4d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802b4f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802b54:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802b57:	ff 75 14             	pushl  0x14(%ebp)
  802b5a:	53                   	push   %ebx
  802b5b:	56                   	push   %esi
  802b5c:	57                   	push   %edi
  802b5d:	e8 70 e5 ff ff       	call   8010d2 <sys_ipc_try_send>

		if (err < 0) {
  802b62:	83 c4 10             	add    $0x10,%esp
  802b65:	85 c0                	test   %eax,%eax
  802b67:	79 1e                	jns    802b87 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802b69:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b6c:	75 07                	jne    802b75 <ipc_send+0x3a>
				sys_yield();
  802b6e:	e8 b3 e3 ff ff       	call   800f26 <sys_yield>
  802b73:	eb e2                	jmp    802b57 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802b75:	50                   	push   %eax
  802b76:	68 ea 35 80 00       	push   $0x8035ea
  802b7b:	6a 49                	push   $0x49
  802b7d:	68 f7 35 80 00       	push   $0x8035f7
  802b82:	e8 5d d9 ff ff       	call   8004e4 <_panic>
		}

	} while (err < 0);

}
  802b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b8a:	5b                   	pop    %ebx
  802b8b:	5e                   	pop    %esi
  802b8c:	5f                   	pop    %edi
  802b8d:	5d                   	pop    %ebp
  802b8e:	c3                   	ret    

00802b8f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b8f:	55                   	push   %ebp
  802b90:	89 e5                	mov    %esp,%ebp
  802b92:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802b95:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b9a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802b9d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802ba3:	8b 52 50             	mov    0x50(%edx),%edx
  802ba6:	39 ca                	cmp    %ecx,%edx
  802ba8:	75 0d                	jne    802bb7 <ipc_find_env+0x28>
			return envs[i].env_id;
  802baa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802bad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802bb2:	8b 40 48             	mov    0x48(%eax),%eax
  802bb5:	eb 0f                	jmp    802bc6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802bb7:	83 c0 01             	add    $0x1,%eax
  802bba:	3d 00 04 00 00       	cmp    $0x400,%eax
  802bbf:	75 d9                	jne    802b9a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802bc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bc6:	5d                   	pop    %ebp
  802bc7:	c3                   	ret    

00802bc8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802bc8:	55                   	push   %ebp
  802bc9:	89 e5                	mov    %esp,%ebp
  802bcb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802bce:	89 d0                	mov    %edx,%eax
  802bd0:	c1 e8 16             	shr    $0x16,%eax
  802bd3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802bda:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802bdf:	f6 c1 01             	test   $0x1,%cl
  802be2:	74 1d                	je     802c01 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802be4:	c1 ea 0c             	shr    $0xc,%edx
  802be7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802bee:	f6 c2 01             	test   $0x1,%dl
  802bf1:	74 0e                	je     802c01 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802bf3:	c1 ea 0c             	shr    $0xc,%edx
  802bf6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802bfd:	ef 
  802bfe:	0f b7 c0             	movzwl %ax,%eax
}
  802c01:	5d                   	pop    %ebp
  802c02:	c3                   	ret    
  802c03:	66 90                	xchg   %ax,%ax
  802c05:	66 90                	xchg   %ax,%ax
  802c07:	66 90                	xchg   %ax,%ax
  802c09:	66 90                	xchg   %ax,%ax
  802c0b:	66 90                	xchg   %ax,%ax
  802c0d:	66 90                	xchg   %ax,%ax
  802c0f:	90                   	nop

00802c10 <__udivdi3>:
  802c10:	55                   	push   %ebp
  802c11:	57                   	push   %edi
  802c12:	56                   	push   %esi
  802c13:	53                   	push   %ebx
  802c14:	83 ec 1c             	sub    $0x1c,%esp
  802c17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802c1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802c1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802c27:	85 f6                	test   %esi,%esi
  802c29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c2d:	89 ca                	mov    %ecx,%edx
  802c2f:	89 f8                	mov    %edi,%eax
  802c31:	75 3d                	jne    802c70 <__udivdi3+0x60>
  802c33:	39 cf                	cmp    %ecx,%edi
  802c35:	0f 87 c5 00 00 00    	ja     802d00 <__udivdi3+0xf0>
  802c3b:	85 ff                	test   %edi,%edi
  802c3d:	89 fd                	mov    %edi,%ebp
  802c3f:	75 0b                	jne    802c4c <__udivdi3+0x3c>
  802c41:	b8 01 00 00 00       	mov    $0x1,%eax
  802c46:	31 d2                	xor    %edx,%edx
  802c48:	f7 f7                	div    %edi
  802c4a:	89 c5                	mov    %eax,%ebp
  802c4c:	89 c8                	mov    %ecx,%eax
  802c4e:	31 d2                	xor    %edx,%edx
  802c50:	f7 f5                	div    %ebp
  802c52:	89 c1                	mov    %eax,%ecx
  802c54:	89 d8                	mov    %ebx,%eax
  802c56:	89 cf                	mov    %ecx,%edi
  802c58:	f7 f5                	div    %ebp
  802c5a:	89 c3                	mov    %eax,%ebx
  802c5c:	89 d8                	mov    %ebx,%eax
  802c5e:	89 fa                	mov    %edi,%edx
  802c60:	83 c4 1c             	add    $0x1c,%esp
  802c63:	5b                   	pop    %ebx
  802c64:	5e                   	pop    %esi
  802c65:	5f                   	pop    %edi
  802c66:	5d                   	pop    %ebp
  802c67:	c3                   	ret    
  802c68:	90                   	nop
  802c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c70:	39 ce                	cmp    %ecx,%esi
  802c72:	77 74                	ja     802ce8 <__udivdi3+0xd8>
  802c74:	0f bd fe             	bsr    %esi,%edi
  802c77:	83 f7 1f             	xor    $0x1f,%edi
  802c7a:	0f 84 98 00 00 00    	je     802d18 <__udivdi3+0x108>
  802c80:	bb 20 00 00 00       	mov    $0x20,%ebx
  802c85:	89 f9                	mov    %edi,%ecx
  802c87:	89 c5                	mov    %eax,%ebp
  802c89:	29 fb                	sub    %edi,%ebx
  802c8b:	d3 e6                	shl    %cl,%esi
  802c8d:	89 d9                	mov    %ebx,%ecx
  802c8f:	d3 ed                	shr    %cl,%ebp
  802c91:	89 f9                	mov    %edi,%ecx
  802c93:	d3 e0                	shl    %cl,%eax
  802c95:	09 ee                	or     %ebp,%esi
  802c97:	89 d9                	mov    %ebx,%ecx
  802c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c9d:	89 d5                	mov    %edx,%ebp
  802c9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802ca3:	d3 ed                	shr    %cl,%ebp
  802ca5:	89 f9                	mov    %edi,%ecx
  802ca7:	d3 e2                	shl    %cl,%edx
  802ca9:	89 d9                	mov    %ebx,%ecx
  802cab:	d3 e8                	shr    %cl,%eax
  802cad:	09 c2                	or     %eax,%edx
  802caf:	89 d0                	mov    %edx,%eax
  802cb1:	89 ea                	mov    %ebp,%edx
  802cb3:	f7 f6                	div    %esi
  802cb5:	89 d5                	mov    %edx,%ebp
  802cb7:	89 c3                	mov    %eax,%ebx
  802cb9:	f7 64 24 0c          	mull   0xc(%esp)
  802cbd:	39 d5                	cmp    %edx,%ebp
  802cbf:	72 10                	jb     802cd1 <__udivdi3+0xc1>
  802cc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802cc5:	89 f9                	mov    %edi,%ecx
  802cc7:	d3 e6                	shl    %cl,%esi
  802cc9:	39 c6                	cmp    %eax,%esi
  802ccb:	73 07                	jae    802cd4 <__udivdi3+0xc4>
  802ccd:	39 d5                	cmp    %edx,%ebp
  802ccf:	75 03                	jne    802cd4 <__udivdi3+0xc4>
  802cd1:	83 eb 01             	sub    $0x1,%ebx
  802cd4:	31 ff                	xor    %edi,%edi
  802cd6:	89 d8                	mov    %ebx,%eax
  802cd8:	89 fa                	mov    %edi,%edx
  802cda:	83 c4 1c             	add    $0x1c,%esp
  802cdd:	5b                   	pop    %ebx
  802cde:	5e                   	pop    %esi
  802cdf:	5f                   	pop    %edi
  802ce0:	5d                   	pop    %ebp
  802ce1:	c3                   	ret    
  802ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ce8:	31 ff                	xor    %edi,%edi
  802cea:	31 db                	xor    %ebx,%ebx
  802cec:	89 d8                	mov    %ebx,%eax
  802cee:	89 fa                	mov    %edi,%edx
  802cf0:	83 c4 1c             	add    $0x1c,%esp
  802cf3:	5b                   	pop    %ebx
  802cf4:	5e                   	pop    %esi
  802cf5:	5f                   	pop    %edi
  802cf6:	5d                   	pop    %ebp
  802cf7:	c3                   	ret    
  802cf8:	90                   	nop
  802cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d00:	89 d8                	mov    %ebx,%eax
  802d02:	f7 f7                	div    %edi
  802d04:	31 ff                	xor    %edi,%edi
  802d06:	89 c3                	mov    %eax,%ebx
  802d08:	89 d8                	mov    %ebx,%eax
  802d0a:	89 fa                	mov    %edi,%edx
  802d0c:	83 c4 1c             	add    $0x1c,%esp
  802d0f:	5b                   	pop    %ebx
  802d10:	5e                   	pop    %esi
  802d11:	5f                   	pop    %edi
  802d12:	5d                   	pop    %ebp
  802d13:	c3                   	ret    
  802d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d18:	39 ce                	cmp    %ecx,%esi
  802d1a:	72 0c                	jb     802d28 <__udivdi3+0x118>
  802d1c:	31 db                	xor    %ebx,%ebx
  802d1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802d22:	0f 87 34 ff ff ff    	ja     802c5c <__udivdi3+0x4c>
  802d28:	bb 01 00 00 00       	mov    $0x1,%ebx
  802d2d:	e9 2a ff ff ff       	jmp    802c5c <__udivdi3+0x4c>
  802d32:	66 90                	xchg   %ax,%ax
  802d34:	66 90                	xchg   %ax,%ax
  802d36:	66 90                	xchg   %ax,%ax
  802d38:	66 90                	xchg   %ax,%ax
  802d3a:	66 90                	xchg   %ax,%ax
  802d3c:	66 90                	xchg   %ax,%ax
  802d3e:	66 90                	xchg   %ax,%ax

00802d40 <__umoddi3>:
  802d40:	55                   	push   %ebp
  802d41:	57                   	push   %edi
  802d42:	56                   	push   %esi
  802d43:	53                   	push   %ebx
  802d44:	83 ec 1c             	sub    $0x1c,%esp
  802d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802d57:	85 d2                	test   %edx,%edx
  802d59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d61:	89 f3                	mov    %esi,%ebx
  802d63:	89 3c 24             	mov    %edi,(%esp)
  802d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d6a:	75 1c                	jne    802d88 <__umoddi3+0x48>
  802d6c:	39 f7                	cmp    %esi,%edi
  802d6e:	76 50                	jbe    802dc0 <__umoddi3+0x80>
  802d70:	89 c8                	mov    %ecx,%eax
  802d72:	89 f2                	mov    %esi,%edx
  802d74:	f7 f7                	div    %edi
  802d76:	89 d0                	mov    %edx,%eax
  802d78:	31 d2                	xor    %edx,%edx
  802d7a:	83 c4 1c             	add    $0x1c,%esp
  802d7d:	5b                   	pop    %ebx
  802d7e:	5e                   	pop    %esi
  802d7f:	5f                   	pop    %edi
  802d80:	5d                   	pop    %ebp
  802d81:	c3                   	ret    
  802d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d88:	39 f2                	cmp    %esi,%edx
  802d8a:	89 d0                	mov    %edx,%eax
  802d8c:	77 52                	ja     802de0 <__umoddi3+0xa0>
  802d8e:	0f bd ea             	bsr    %edx,%ebp
  802d91:	83 f5 1f             	xor    $0x1f,%ebp
  802d94:	75 5a                	jne    802df0 <__umoddi3+0xb0>
  802d96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802d9a:	0f 82 e0 00 00 00    	jb     802e80 <__umoddi3+0x140>
  802da0:	39 0c 24             	cmp    %ecx,(%esp)
  802da3:	0f 86 d7 00 00 00    	jbe    802e80 <__umoddi3+0x140>
  802da9:	8b 44 24 08          	mov    0x8(%esp),%eax
  802dad:	8b 54 24 04          	mov    0x4(%esp),%edx
  802db1:	83 c4 1c             	add    $0x1c,%esp
  802db4:	5b                   	pop    %ebx
  802db5:	5e                   	pop    %esi
  802db6:	5f                   	pop    %edi
  802db7:	5d                   	pop    %ebp
  802db8:	c3                   	ret    
  802db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802dc0:	85 ff                	test   %edi,%edi
  802dc2:	89 fd                	mov    %edi,%ebp
  802dc4:	75 0b                	jne    802dd1 <__umoddi3+0x91>
  802dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  802dcb:	31 d2                	xor    %edx,%edx
  802dcd:	f7 f7                	div    %edi
  802dcf:	89 c5                	mov    %eax,%ebp
  802dd1:	89 f0                	mov    %esi,%eax
  802dd3:	31 d2                	xor    %edx,%edx
  802dd5:	f7 f5                	div    %ebp
  802dd7:	89 c8                	mov    %ecx,%eax
  802dd9:	f7 f5                	div    %ebp
  802ddb:	89 d0                	mov    %edx,%eax
  802ddd:	eb 99                	jmp    802d78 <__umoddi3+0x38>
  802ddf:	90                   	nop
  802de0:	89 c8                	mov    %ecx,%eax
  802de2:	89 f2                	mov    %esi,%edx
  802de4:	83 c4 1c             	add    $0x1c,%esp
  802de7:	5b                   	pop    %ebx
  802de8:	5e                   	pop    %esi
  802de9:	5f                   	pop    %edi
  802dea:	5d                   	pop    %ebp
  802deb:	c3                   	ret    
  802dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802df0:	8b 34 24             	mov    (%esp),%esi
  802df3:	bf 20 00 00 00       	mov    $0x20,%edi
  802df8:	89 e9                	mov    %ebp,%ecx
  802dfa:	29 ef                	sub    %ebp,%edi
  802dfc:	d3 e0                	shl    %cl,%eax
  802dfe:	89 f9                	mov    %edi,%ecx
  802e00:	89 f2                	mov    %esi,%edx
  802e02:	d3 ea                	shr    %cl,%edx
  802e04:	89 e9                	mov    %ebp,%ecx
  802e06:	09 c2                	or     %eax,%edx
  802e08:	89 d8                	mov    %ebx,%eax
  802e0a:	89 14 24             	mov    %edx,(%esp)
  802e0d:	89 f2                	mov    %esi,%edx
  802e0f:	d3 e2                	shl    %cl,%edx
  802e11:	89 f9                	mov    %edi,%ecx
  802e13:	89 54 24 04          	mov    %edx,0x4(%esp)
  802e17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802e1b:	d3 e8                	shr    %cl,%eax
  802e1d:	89 e9                	mov    %ebp,%ecx
  802e1f:	89 c6                	mov    %eax,%esi
  802e21:	d3 e3                	shl    %cl,%ebx
  802e23:	89 f9                	mov    %edi,%ecx
  802e25:	89 d0                	mov    %edx,%eax
  802e27:	d3 e8                	shr    %cl,%eax
  802e29:	89 e9                	mov    %ebp,%ecx
  802e2b:	09 d8                	or     %ebx,%eax
  802e2d:	89 d3                	mov    %edx,%ebx
  802e2f:	89 f2                	mov    %esi,%edx
  802e31:	f7 34 24             	divl   (%esp)
  802e34:	89 d6                	mov    %edx,%esi
  802e36:	d3 e3                	shl    %cl,%ebx
  802e38:	f7 64 24 04          	mull   0x4(%esp)
  802e3c:	39 d6                	cmp    %edx,%esi
  802e3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802e42:	89 d1                	mov    %edx,%ecx
  802e44:	89 c3                	mov    %eax,%ebx
  802e46:	72 08                	jb     802e50 <__umoddi3+0x110>
  802e48:	75 11                	jne    802e5b <__umoddi3+0x11b>
  802e4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802e4e:	73 0b                	jae    802e5b <__umoddi3+0x11b>
  802e50:	2b 44 24 04          	sub    0x4(%esp),%eax
  802e54:	1b 14 24             	sbb    (%esp),%edx
  802e57:	89 d1                	mov    %edx,%ecx
  802e59:	89 c3                	mov    %eax,%ebx
  802e5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802e5f:	29 da                	sub    %ebx,%edx
  802e61:	19 ce                	sbb    %ecx,%esi
  802e63:	89 f9                	mov    %edi,%ecx
  802e65:	89 f0                	mov    %esi,%eax
  802e67:	d3 e0                	shl    %cl,%eax
  802e69:	89 e9                	mov    %ebp,%ecx
  802e6b:	d3 ea                	shr    %cl,%edx
  802e6d:	89 e9                	mov    %ebp,%ecx
  802e6f:	d3 ee                	shr    %cl,%esi
  802e71:	09 d0                	or     %edx,%eax
  802e73:	89 f2                	mov    %esi,%edx
  802e75:	83 c4 1c             	add    $0x1c,%esp
  802e78:	5b                   	pop    %ebx
  802e79:	5e                   	pop    %esi
  802e7a:	5f                   	pop    %edi
  802e7b:	5d                   	pop    %ebp
  802e7c:	c3                   	ret    
  802e7d:	8d 76 00             	lea    0x0(%esi),%esi
  802e80:	29 f9                	sub    %edi,%ecx
  802e82:	19 d6                	sbb    %edx,%esi
  802e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802e8c:	e9 18 ff ff ff       	jmp    802da9 <__umoddi3+0x69>
