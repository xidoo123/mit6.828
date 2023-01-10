
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
  80004a:	e8 1a 18 00 00       	call   801869 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 10 18 00 00       	call   801869 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 60 2e 80 00 	movl   $0x802e60,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 cb 2e 80 00 	movl   $0x802ecb,(%esp)
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
  80008d:	e8 71 16 00 00       	call   801703 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 da 2e 80 00       	push   $0x802eda
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
  8000c2:	e8 3c 16 00 00       	call   801703 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 d5 2e 80 00       	push   $0x802ed5
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
  8000f6:	e8 cc 14 00 00       	call   8015c7 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 c0 14 00 00       	call   8015c7 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 e8 2e 80 00       	push   $0x802ee8
  80011b:	e8 61 1a 00 00       	call   801b81 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 f5 2e 80 00       	push   $0x802ef5
  80012f:	6a 13                	push   $0x13
  800131:	68 0b 2f 80 00       	push   $0x802f0b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 0b 27 00 00       	call   802852 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 1c 2f 80 00       	push   $0x802f1c
  800154:	6a 15                	push   $0x15
  800156:	68 0b 2f 80 00       	push   $0x802f0b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 84 2e 80 00       	push   $0x802e84
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 fb 10 00 00       	call   801270 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 25 2f 80 00       	push   $0x802f25
  800182:	6a 1a                	push   $0x1a
  800184:	68 0b 2f 80 00       	push   $0x802f0b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 7a 14 00 00       	call   801617 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 6f 14 00 00       	call   801617 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 17 14 00 00       	call   8015c7 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 0f 14 00 00       	call   8015c7 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 2e 2f 80 00       	push   $0x802f2e
  8001bf:	68 f2 2e 80 00       	push   $0x802ef2
  8001c4:	68 31 2f 80 00       	push   $0x802f31
  8001c9:	e8 d4 1f 00 00       	call   8021a2 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 35 2f 80 00       	push   $0x802f35
  8001dd:	6a 21                	push   $0x21
  8001df:	68 0b 2f 80 00       	push   $0x802f0b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 d4 13 00 00       	call   8015c7 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 c8 13 00 00       	call   8015c7 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 d1 27 00 00       	call   8029d8 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 af 13 00 00       	call   8015c7 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 a7 13 00 00       	call   8015c7 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 3f 2f 80 00       	push   $0x802f3f
  800230:	e8 4c 19 00 00       	call   801b81 <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 a8 2e 80 00       	push   $0x802ea8
  800245:	6a 2c                	push   $0x2c
  800247:	68 0b 2f 80 00       	push   $0x802f0b
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
  800267:	e8 97 14 00 00       	call   801703 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 84 14 00 00       	call   801703 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 4d 2f 80 00       	push   $0x802f4d
  80028c:	6a 33                	push   $0x33
  80028e:	68 0b 2f 80 00       	push   $0x802f0b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 67 2f 80 00       	push   $0x802f67
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 0b 2f 80 00       	push   $0x802f0b
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
  8002eb:	68 81 2f 80 00       	push   $0x802f81
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
  800311:	68 96 2f 80 00       	push   $0x802f96
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
  8003e1:	e8 1d 13 00 00       	call   801703 <read>
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
  80040b:	e8 8d 10 00 00       	call   80149d <fd_lookup>
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
  800434:	e8 15 10 00 00       	call   80144e <fd_alloc>
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
  800476:	e8 ac 0f 00 00       	call   801427 <fd2num>
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
  8004d0:	e8 1d 11 00 00       	call   8015f2 <close_all>
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
  800502:	68 ac 2f 80 00       	push   $0x802fac
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 d8 2e 80 00 	movl   $0x802ed8,(%esp)
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
  800620:	e8 ab 25 00 00       	call   802bd0 <__udivdi3>
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
  800663:	e8 98 26 00 00       	call   802d00 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 cf 2f 80 00 	movsbl 0x802fcf(%eax),%eax
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
  800767:	ff 24 85 20 31 80 00 	jmp    *0x803120(,%eax,4)
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
  80082b:	8b 14 85 80 32 80 00 	mov    0x803280(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 e7 2f 80 00       	push   $0x802fe7
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
  80084f:	68 6d 34 80 00       	push   $0x80346d
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
  800873:	b8 e0 2f 80 00       	mov    $0x802fe0,%eax
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
  800eee:	68 df 32 80 00       	push   $0x8032df
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 fc 32 80 00       	push   $0x8032fc
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
  800f6f:	68 df 32 80 00       	push   $0x8032df
  800f74:	6a 23                	push   $0x23
  800f76:	68 fc 32 80 00       	push   $0x8032fc
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
  800fb1:	68 df 32 80 00       	push   $0x8032df
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 fc 32 80 00       	push   $0x8032fc
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
  800ff3:	68 df 32 80 00       	push   $0x8032df
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 fc 32 80 00       	push   $0x8032fc
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
  801035:	68 df 32 80 00       	push   $0x8032df
  80103a:	6a 23                	push   $0x23
  80103c:	68 fc 32 80 00       	push   $0x8032fc
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
  801077:	68 df 32 80 00       	push   $0x8032df
  80107c:	6a 23                	push   $0x23
  80107e:	68 fc 32 80 00       	push   $0x8032fc
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
  8010b9:	68 df 32 80 00       	push   $0x8032df
  8010be:	6a 23                	push   $0x23
  8010c0:	68 fc 32 80 00       	push   $0x8032fc
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
  80111d:	68 df 32 80 00       	push   $0x8032df
  801122:	6a 23                	push   $0x23
  801124:	68 fc 32 80 00       	push   $0x8032fc
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
  80117e:	68 df 32 80 00       	push   $0x8032df
  801183:	6a 23                	push   $0x23
  801185:	68 fc 32 80 00       	push   $0x8032fc
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

00801197 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
  80119c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80119f:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  8011a1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011a5:	75 25                	jne    8011cc <pgfault+0x35>
  8011a7:	89 d8                	mov    %ebx,%eax
  8011a9:	c1 e8 0c             	shr    $0xc,%eax
  8011ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b3:	f6 c4 08             	test   $0x8,%ah
  8011b6:	75 14                	jne    8011cc <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  8011b8:	83 ec 04             	sub    $0x4,%esp
  8011bb:	68 0c 33 80 00       	push   $0x80330c
  8011c0:	6a 1e                	push   $0x1e
  8011c2:	68 a0 33 80 00       	push   $0x8033a0
  8011c7:	e8 18 f3 ff ff       	call   8004e4 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  8011cc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  8011d2:	e8 30 fd ff ff       	call   800f07 <sys_getenvid>
  8011d7:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  8011d9:	83 ec 04             	sub    $0x4,%esp
  8011dc:	6a 07                	push   $0x7
  8011de:	68 00 f0 7f 00       	push   $0x7ff000
  8011e3:	50                   	push   %eax
  8011e4:	e8 5c fd ff ff       	call   800f45 <sys_page_alloc>
	if (r < 0)
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	79 12                	jns    801202 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  8011f0:	50                   	push   %eax
  8011f1:	68 38 33 80 00       	push   $0x803338
  8011f6:	6a 33                	push   $0x33
  8011f8:	68 a0 33 80 00       	push   $0x8033a0
  8011fd:	e8 e2 f2 ff ff       	call   8004e4 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	68 00 10 00 00       	push   $0x1000
  80120a:	53                   	push   %ebx
  80120b:	68 00 f0 7f 00       	push   $0x7ff000
  801210:	e8 27 fb ff ff       	call   800d3c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  801215:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80121c:	53                   	push   %ebx
  80121d:	56                   	push   %esi
  80121e:	68 00 f0 7f 00       	push   $0x7ff000
  801223:	56                   	push   %esi
  801224:	e8 5f fd ff ff       	call   800f88 <sys_page_map>
	if (r < 0)
  801229:	83 c4 20             	add    $0x20,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	79 12                	jns    801242 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  801230:	50                   	push   %eax
  801231:	68 5c 33 80 00       	push   $0x80335c
  801236:	6a 3b                	push   $0x3b
  801238:	68 a0 33 80 00       	push   $0x8033a0
  80123d:	e8 a2 f2 ff ff       	call   8004e4 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  801242:	83 ec 08             	sub    $0x8,%esp
  801245:	68 00 f0 7f 00       	push   $0x7ff000
  80124a:	56                   	push   %esi
  80124b:	e8 7a fd ff ff       	call   800fca <sys_page_unmap>
	if (r < 0)
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	79 12                	jns    801269 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  801257:	50                   	push   %eax
  801258:	68 80 33 80 00       	push   $0x803380
  80125d:	6a 40                	push   $0x40
  80125f:	68 a0 33 80 00       	push   $0x8033a0
  801264:	e8 7b f2 ff ff       	call   8004e4 <_panic>
}
  801269:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	57                   	push   %edi
  801274:	56                   	push   %esi
  801275:	53                   	push   %ebx
  801276:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801279:	68 97 11 80 00       	push   $0x801197
  80127e:	e8 a4 17 00 00       	call   802a27 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801283:	b8 07 00 00 00       	mov    $0x7,%eax
  801288:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	85 c0                	test   %eax,%eax
  80128f:	0f 88 64 01 00 00    	js     8013f9 <fork+0x189>
  801295:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80129a:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	75 21                	jne    8012c4 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012a3:	e8 5f fc ff ff       	call   800f07 <sys_getenvid>
  8012a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012ad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012b5:	a3 08 50 80 00       	mov    %eax,0x805008
        return 0;
  8012ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8012bf:	e9 3f 01 00 00       	jmp    801403 <fork+0x193>
  8012c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c7:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8012c9:	89 d8                	mov    %ebx,%eax
  8012cb:	c1 e8 16             	shr    $0x16,%eax
  8012ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d5:	a8 01                	test   $0x1,%al
  8012d7:	0f 84 bd 00 00 00    	je     80139a <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  8012dd:	89 d8                	mov    %ebx,%eax
  8012df:	c1 e8 0c             	shr    $0xc,%eax
  8012e2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e9:	f6 c2 01             	test   $0x1,%dl
  8012ec:	0f 84 a8 00 00 00    	je     80139a <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  8012f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f9:	a8 04                	test   $0x4,%al
  8012fb:	0f 84 99 00 00 00    	je     80139a <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801301:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801308:	f6 c4 04             	test   $0x4,%ah
  80130b:	74 17                	je     801324 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	68 07 0e 00 00       	push   $0xe07
  801315:	53                   	push   %ebx
  801316:	57                   	push   %edi
  801317:	53                   	push   %ebx
  801318:	6a 00                	push   $0x0
  80131a:	e8 69 fc ff ff       	call   800f88 <sys_page_map>
  80131f:	83 c4 20             	add    $0x20,%esp
  801322:	eb 76                	jmp    80139a <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801324:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80132b:	a8 02                	test   $0x2,%al
  80132d:	75 0c                	jne    80133b <fork+0xcb>
  80132f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801336:	f6 c4 08             	test   $0x8,%ah
  801339:	74 3f                	je     80137a <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	68 05 08 00 00       	push   $0x805
  801343:	53                   	push   %ebx
  801344:	57                   	push   %edi
  801345:	53                   	push   %ebx
  801346:	6a 00                	push   $0x0
  801348:	e8 3b fc ff ff       	call   800f88 <sys_page_map>
		if (r < 0)
  80134d:	83 c4 20             	add    $0x20,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	0f 88 a5 00 00 00    	js     8013fd <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	68 05 08 00 00       	push   $0x805
  801360:	53                   	push   %ebx
  801361:	6a 00                	push   $0x0
  801363:	53                   	push   %ebx
  801364:	6a 00                	push   $0x0
  801366:	e8 1d fc ff ff       	call   800f88 <sys_page_map>
  80136b:	83 c4 20             	add    $0x20,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	b9 00 00 00 00       	mov    $0x0,%ecx
  801375:	0f 4f c1             	cmovg  %ecx,%eax
  801378:	eb 1c                	jmp    801396 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80137a:	83 ec 0c             	sub    $0xc,%esp
  80137d:	6a 05                	push   $0x5
  80137f:	53                   	push   %ebx
  801380:	57                   	push   %edi
  801381:	53                   	push   %ebx
  801382:	6a 00                	push   $0x0
  801384:	e8 ff fb ff ff       	call   800f88 <sys_page_map>
  801389:	83 c4 20             	add    $0x20,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801393:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801396:	85 c0                	test   %eax,%eax
  801398:	78 67                	js     801401 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80139a:	83 c6 01             	add    $0x1,%esi
  80139d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013a3:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8013a9:	0f 85 1a ff ff ff    	jne    8012c9 <fork+0x59>
  8013af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	6a 07                	push   $0x7
  8013b7:	68 00 f0 bf ee       	push   $0xeebff000
  8013bc:	57                   	push   %edi
  8013bd:	e8 83 fb ff ff       	call   800f45 <sys_page_alloc>
	if (r < 0)
  8013c2:	83 c4 10             	add    $0x10,%esp
		return r;
  8013c5:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 38                	js     801403 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	68 6e 2a 80 00       	push   $0x802a6e
  8013d3:	57                   	push   %edi
  8013d4:	e8 b7 fc ff ff       	call   801090 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8013d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8013dc:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 21                	js     801403 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	6a 02                	push   $0x2
  8013e7:	57                   	push   %edi
  8013e8:	e8 1f fc ff ff       	call   80100c <sys_env_set_status>
	if (r < 0)
  8013ed:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	0f 48 f8             	cmovs  %eax,%edi
  8013f5:	89 fa                	mov    %edi,%edx
  8013f7:	eb 0a                	jmp    801403 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8013f9:	89 c2                	mov    %eax,%edx
  8013fb:	eb 06                	jmp    801403 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8013fd:	89 c2                	mov    %eax,%edx
  8013ff:	eb 02                	jmp    801403 <fork+0x193>
  801401:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801403:	89 d0                	mov    %edx,%eax
  801405:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5f                   	pop    %edi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <sfork>:

// Challenge!
int
sfork(void)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801413:	68 ab 33 80 00       	push   $0x8033ab
  801418:	68 c9 00 00 00       	push   $0xc9
  80141d:	68 a0 33 80 00       	push   $0x8033a0
  801422:	e8 bd f0 ff ff       	call   8004e4 <_panic>

00801427 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80142a:	8b 45 08             	mov    0x8(%ebp),%eax
  80142d:	05 00 00 00 30       	add    $0x30000000,%eax
  801432:	c1 e8 0c             	shr    $0xc,%eax
}
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    

00801437 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80143a:	8b 45 08             	mov    0x8(%ebp),%eax
  80143d:	05 00 00 00 30       	add    $0x30000000,%eax
  801442:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801447:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    

0080144e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801454:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801459:	89 c2                	mov    %eax,%edx
  80145b:	c1 ea 16             	shr    $0x16,%edx
  80145e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801465:	f6 c2 01             	test   $0x1,%dl
  801468:	74 11                	je     80147b <fd_alloc+0x2d>
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	c1 ea 0c             	shr    $0xc,%edx
  80146f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801476:	f6 c2 01             	test   $0x1,%dl
  801479:	75 09                	jne    801484 <fd_alloc+0x36>
			*fd_store = fd;
  80147b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80147d:	b8 00 00 00 00       	mov    $0x0,%eax
  801482:	eb 17                	jmp    80149b <fd_alloc+0x4d>
  801484:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801489:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80148e:	75 c9                	jne    801459 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801490:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801496:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    

0080149d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014a3:	83 f8 1f             	cmp    $0x1f,%eax
  8014a6:	77 36                	ja     8014de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014a8:	c1 e0 0c             	shl    $0xc,%eax
  8014ab:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014b0:	89 c2                	mov    %eax,%edx
  8014b2:	c1 ea 16             	shr    $0x16,%edx
  8014b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014bc:	f6 c2 01             	test   $0x1,%dl
  8014bf:	74 24                	je     8014e5 <fd_lookup+0x48>
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	c1 ea 0c             	shr    $0xc,%edx
  8014c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014cd:	f6 c2 01             	test   $0x1,%dl
  8014d0:	74 1a                	je     8014ec <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d5:	89 02                	mov    %eax,(%edx)
	return 0;
  8014d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014dc:	eb 13                	jmp    8014f1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e3:	eb 0c                	jmp    8014f1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ea:	eb 05                	jmp    8014f1 <fd_lookup+0x54>
  8014ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014fc:	ba 40 34 80 00       	mov    $0x803440,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801501:	eb 13                	jmp    801516 <dev_lookup+0x23>
  801503:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801506:	39 08                	cmp    %ecx,(%eax)
  801508:	75 0c                	jne    801516 <dev_lookup+0x23>
			*dev = devtab[i];
  80150a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80150d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80150f:	b8 00 00 00 00       	mov    $0x0,%eax
  801514:	eb 2e                	jmp    801544 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801516:	8b 02                	mov    (%edx),%eax
  801518:	85 c0                	test   %eax,%eax
  80151a:	75 e7                	jne    801503 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80151c:	a1 08 50 80 00       	mov    0x805008,%eax
  801521:	8b 40 48             	mov    0x48(%eax),%eax
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	51                   	push   %ecx
  801528:	50                   	push   %eax
  801529:	68 c4 33 80 00       	push   $0x8033c4
  80152e:	e8 8a f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  801533:	8b 45 0c             	mov    0xc(%ebp),%eax
  801536:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801544:	c9                   	leave  
  801545:	c3                   	ret    

00801546 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	56                   	push   %esi
  80154a:	53                   	push   %ebx
  80154b:	83 ec 10             	sub    $0x10,%esp
  80154e:	8b 75 08             	mov    0x8(%ebp),%esi
  801551:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80155e:	c1 e8 0c             	shr    $0xc,%eax
  801561:	50                   	push   %eax
  801562:	e8 36 ff ff ff       	call   80149d <fd_lookup>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 05                	js     801573 <fd_close+0x2d>
	    || fd != fd2)
  80156e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801571:	74 0c                	je     80157f <fd_close+0x39>
		return (must_exist ? r : 0);
  801573:	84 db                	test   %bl,%bl
  801575:	ba 00 00 00 00       	mov    $0x0,%edx
  80157a:	0f 44 c2             	cmove  %edx,%eax
  80157d:	eb 41                	jmp    8015c0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	ff 36                	pushl  (%esi)
  801588:	e8 66 ff ff ff       	call   8014f3 <dev_lookup>
  80158d:	89 c3                	mov    %eax,%ebx
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	78 1a                	js     8015b0 <fd_close+0x6a>
		if (dev->dev_close)
  801596:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801599:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80159c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	74 0b                	je     8015b0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015a5:	83 ec 0c             	sub    $0xc,%esp
  8015a8:	56                   	push   %esi
  8015a9:	ff d0                	call   *%eax
  8015ab:	89 c3                	mov    %eax,%ebx
  8015ad:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	56                   	push   %esi
  8015b4:	6a 00                	push   $0x0
  8015b6:	e8 0f fa ff ff       	call   800fca <sys_page_unmap>
	return r;
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	89 d8                	mov    %ebx,%eax
}
  8015c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c3:	5b                   	pop    %ebx
  8015c4:	5e                   	pop    %esi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	ff 75 08             	pushl  0x8(%ebp)
  8015d4:	e8 c4 fe ff ff       	call   80149d <fd_lookup>
  8015d9:	83 c4 08             	add    $0x8,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 10                	js     8015f0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	6a 01                	push   $0x1
  8015e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e8:	e8 59 ff ff ff       	call   801546 <fd_close>
  8015ed:	83 c4 10             	add    $0x10,%esp
}
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <close_all>:

void
close_all(void)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	53                   	push   %ebx
  801602:	e8 c0 ff ff ff       	call   8015c7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801607:	83 c3 01             	add    $0x1,%ebx
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	83 fb 20             	cmp    $0x20,%ebx
  801610:	75 ec                	jne    8015fe <close_all+0xc>
		close(i);
}
  801612:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	57                   	push   %edi
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
  80161d:	83 ec 2c             	sub    $0x2c,%esp
  801620:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801623:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801626:	50                   	push   %eax
  801627:	ff 75 08             	pushl  0x8(%ebp)
  80162a:	e8 6e fe ff ff       	call   80149d <fd_lookup>
  80162f:	83 c4 08             	add    $0x8,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	0f 88 c1 00 00 00    	js     8016fb <dup+0xe4>
		return r;
	close(newfdnum);
  80163a:	83 ec 0c             	sub    $0xc,%esp
  80163d:	56                   	push   %esi
  80163e:	e8 84 ff ff ff       	call   8015c7 <close>

	newfd = INDEX2FD(newfdnum);
  801643:	89 f3                	mov    %esi,%ebx
  801645:	c1 e3 0c             	shl    $0xc,%ebx
  801648:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80164e:	83 c4 04             	add    $0x4,%esp
  801651:	ff 75 e4             	pushl  -0x1c(%ebp)
  801654:	e8 de fd ff ff       	call   801437 <fd2data>
  801659:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80165b:	89 1c 24             	mov    %ebx,(%esp)
  80165e:	e8 d4 fd ff ff       	call   801437 <fd2data>
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801669:	89 f8                	mov    %edi,%eax
  80166b:	c1 e8 16             	shr    $0x16,%eax
  80166e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801675:	a8 01                	test   $0x1,%al
  801677:	74 37                	je     8016b0 <dup+0x99>
  801679:	89 f8                	mov    %edi,%eax
  80167b:	c1 e8 0c             	shr    $0xc,%eax
  80167e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801685:	f6 c2 01             	test   $0x1,%dl
  801688:	74 26                	je     8016b0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80168a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801691:	83 ec 0c             	sub    $0xc,%esp
  801694:	25 07 0e 00 00       	and    $0xe07,%eax
  801699:	50                   	push   %eax
  80169a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80169d:	6a 00                	push   $0x0
  80169f:	57                   	push   %edi
  8016a0:	6a 00                	push   $0x0
  8016a2:	e8 e1 f8 ff ff       	call   800f88 <sys_page_map>
  8016a7:	89 c7                	mov    %eax,%edi
  8016a9:	83 c4 20             	add    $0x20,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 2e                	js     8016de <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016b3:	89 d0                	mov    %edx,%eax
  8016b5:	c1 e8 0c             	shr    $0xc,%eax
  8016b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016c7:	50                   	push   %eax
  8016c8:	53                   	push   %ebx
  8016c9:	6a 00                	push   $0x0
  8016cb:	52                   	push   %edx
  8016cc:	6a 00                	push   $0x0
  8016ce:	e8 b5 f8 ff ff       	call   800f88 <sys_page_map>
  8016d3:	89 c7                	mov    %eax,%edi
  8016d5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016d8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016da:	85 ff                	test   %edi,%edi
  8016dc:	79 1d                	jns    8016fb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	53                   	push   %ebx
  8016e2:	6a 00                	push   $0x0
  8016e4:	e8 e1 f8 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016e9:	83 c4 08             	add    $0x8,%esp
  8016ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016ef:	6a 00                	push   $0x0
  8016f1:	e8 d4 f8 ff ff       	call   800fca <sys_page_unmap>
	return r;
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	89 f8                	mov    %edi,%eax
}
  8016fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fe:	5b                   	pop    %ebx
  8016ff:	5e                   	pop    %esi
  801700:	5f                   	pop    %edi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	83 ec 14             	sub    $0x14,%esp
  80170a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	53                   	push   %ebx
  801712:	e8 86 fd ff ff       	call   80149d <fd_lookup>
  801717:	83 c4 08             	add    $0x8,%esp
  80171a:	89 c2                	mov    %eax,%edx
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 6d                	js     80178d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172a:	ff 30                	pushl  (%eax)
  80172c:	e8 c2 fd ff ff       	call   8014f3 <dev_lookup>
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	85 c0                	test   %eax,%eax
  801736:	78 4c                	js     801784 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801738:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80173b:	8b 42 08             	mov    0x8(%edx),%eax
  80173e:	83 e0 03             	and    $0x3,%eax
  801741:	83 f8 01             	cmp    $0x1,%eax
  801744:	75 21                	jne    801767 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801746:	a1 08 50 80 00       	mov    0x805008,%eax
  80174b:	8b 40 48             	mov    0x48(%eax),%eax
  80174e:	83 ec 04             	sub    $0x4,%esp
  801751:	53                   	push   %ebx
  801752:	50                   	push   %eax
  801753:	68 05 34 80 00       	push   $0x803405
  801758:	e8 60 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801765:	eb 26                	jmp    80178d <read+0x8a>
	}
	if (!dev->dev_read)
  801767:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176a:	8b 40 08             	mov    0x8(%eax),%eax
  80176d:	85 c0                	test   %eax,%eax
  80176f:	74 17                	je     801788 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801771:	83 ec 04             	sub    $0x4,%esp
  801774:	ff 75 10             	pushl  0x10(%ebp)
  801777:	ff 75 0c             	pushl  0xc(%ebp)
  80177a:	52                   	push   %edx
  80177b:	ff d0                	call   *%eax
  80177d:	89 c2                	mov    %eax,%edx
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	eb 09                	jmp    80178d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801784:	89 c2                	mov    %eax,%edx
  801786:	eb 05                	jmp    80178d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801788:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80178d:	89 d0                	mov    %edx,%eax
  80178f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801792:	c9                   	leave  
  801793:	c3                   	ret    

00801794 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	57                   	push   %edi
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
  80179a:	83 ec 0c             	sub    $0xc,%esp
  80179d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017a0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a8:	eb 21                	jmp    8017cb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017aa:	83 ec 04             	sub    $0x4,%esp
  8017ad:	89 f0                	mov    %esi,%eax
  8017af:	29 d8                	sub    %ebx,%eax
  8017b1:	50                   	push   %eax
  8017b2:	89 d8                	mov    %ebx,%eax
  8017b4:	03 45 0c             	add    0xc(%ebp),%eax
  8017b7:	50                   	push   %eax
  8017b8:	57                   	push   %edi
  8017b9:	e8 45 ff ff ff       	call   801703 <read>
		if (m < 0)
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 10                	js     8017d5 <readn+0x41>
			return m;
		if (m == 0)
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	74 0a                	je     8017d3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c9:	01 c3                	add    %eax,%ebx
  8017cb:	39 f3                	cmp    %esi,%ebx
  8017cd:	72 db                	jb     8017aa <readn+0x16>
  8017cf:	89 d8                	mov    %ebx,%eax
  8017d1:	eb 02                	jmp    8017d5 <readn+0x41>
  8017d3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5e                   	pop    %esi
  8017da:	5f                   	pop    %edi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 14             	sub    $0x14,%esp
  8017e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ea:	50                   	push   %eax
  8017eb:	53                   	push   %ebx
  8017ec:	e8 ac fc ff ff       	call   80149d <fd_lookup>
  8017f1:	83 c4 08             	add    $0x8,%esp
  8017f4:	89 c2                	mov    %eax,%edx
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 68                	js     801862 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801800:	50                   	push   %eax
  801801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801804:	ff 30                	pushl  (%eax)
  801806:	e8 e8 fc ff ff       	call   8014f3 <dev_lookup>
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 47                	js     801859 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801819:	75 21                	jne    80183c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80181b:	a1 08 50 80 00       	mov    0x805008,%eax
  801820:	8b 40 48             	mov    0x48(%eax),%eax
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	53                   	push   %ebx
  801827:	50                   	push   %eax
  801828:	68 21 34 80 00       	push   $0x803421
  80182d:	e8 8b ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80183a:	eb 26                	jmp    801862 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80183c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183f:	8b 52 0c             	mov    0xc(%edx),%edx
  801842:	85 d2                	test   %edx,%edx
  801844:	74 17                	je     80185d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801846:	83 ec 04             	sub    $0x4,%esp
  801849:	ff 75 10             	pushl  0x10(%ebp)
  80184c:	ff 75 0c             	pushl  0xc(%ebp)
  80184f:	50                   	push   %eax
  801850:	ff d2                	call   *%edx
  801852:	89 c2                	mov    %eax,%edx
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	eb 09                	jmp    801862 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801859:	89 c2                	mov    %eax,%edx
  80185b:	eb 05                	jmp    801862 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80185d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801862:	89 d0                	mov    %edx,%eax
  801864:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <seek>:

int
seek(int fdnum, off_t offset)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801872:	50                   	push   %eax
  801873:	ff 75 08             	pushl  0x8(%ebp)
  801876:	e8 22 fc ff ff       	call   80149d <fd_lookup>
  80187b:	83 c4 08             	add    $0x8,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	78 0e                	js     801890 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801882:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801885:	8b 55 0c             	mov    0xc(%ebp),%edx
  801888:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80188b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	83 ec 14             	sub    $0x14,%esp
  801899:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80189c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	53                   	push   %ebx
  8018a1:	e8 f7 fb ff ff       	call   80149d <fd_lookup>
  8018a6:	83 c4 08             	add    $0x8,%esp
  8018a9:	89 c2                	mov    %eax,%edx
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 65                	js     801914 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b5:	50                   	push   %eax
  8018b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b9:	ff 30                	pushl  (%eax)
  8018bb:	e8 33 fc ff ff       	call   8014f3 <dev_lookup>
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 44                	js     80190b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ce:	75 21                	jne    8018f1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018d0:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018d5:	8b 40 48             	mov    0x48(%eax),%eax
  8018d8:	83 ec 04             	sub    $0x4,%esp
  8018db:	53                   	push   %ebx
  8018dc:	50                   	push   %eax
  8018dd:	68 e4 33 80 00       	push   $0x8033e4
  8018e2:	e8 d6 ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018ef:	eb 23                	jmp    801914 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f4:	8b 52 18             	mov    0x18(%edx),%edx
  8018f7:	85 d2                	test   %edx,%edx
  8018f9:	74 14                	je     80190f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	ff 75 0c             	pushl  0xc(%ebp)
  801901:	50                   	push   %eax
  801902:	ff d2                	call   *%edx
  801904:	89 c2                	mov    %eax,%edx
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	eb 09                	jmp    801914 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190b:	89 c2                	mov    %eax,%edx
  80190d:	eb 05                	jmp    801914 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80190f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801914:	89 d0                	mov    %edx,%eax
  801916:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	53                   	push   %ebx
  80191f:	83 ec 14             	sub    $0x14,%esp
  801922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801925:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801928:	50                   	push   %eax
  801929:	ff 75 08             	pushl  0x8(%ebp)
  80192c:	e8 6c fb ff ff       	call   80149d <fd_lookup>
  801931:	83 c4 08             	add    $0x8,%esp
  801934:	89 c2                	mov    %eax,%edx
  801936:	85 c0                	test   %eax,%eax
  801938:	78 58                	js     801992 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193a:	83 ec 08             	sub    $0x8,%esp
  80193d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801940:	50                   	push   %eax
  801941:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801944:	ff 30                	pushl  (%eax)
  801946:	e8 a8 fb ff ff       	call   8014f3 <dev_lookup>
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	85 c0                	test   %eax,%eax
  801950:	78 37                	js     801989 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801955:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801959:	74 32                	je     80198d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80195b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80195e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801965:	00 00 00 
	stat->st_isdir = 0;
  801968:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80196f:	00 00 00 
	stat->st_dev = dev;
  801972:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	53                   	push   %ebx
  80197c:	ff 75 f0             	pushl  -0x10(%ebp)
  80197f:	ff 50 14             	call   *0x14(%eax)
  801982:	89 c2                	mov    %eax,%edx
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	eb 09                	jmp    801992 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801989:	89 c2                	mov    %eax,%edx
  80198b:	eb 05                	jmp    801992 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80198d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801992:	89 d0                	mov    %edx,%eax
  801994:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	56                   	push   %esi
  80199d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	6a 00                	push   $0x0
  8019a3:	ff 75 08             	pushl  0x8(%ebp)
  8019a6:	e8 d6 01 00 00       	call   801b81 <open>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 1b                	js     8019cf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ba:	50                   	push   %eax
  8019bb:	e8 5b ff ff ff       	call   80191b <fstat>
  8019c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8019c2:	89 1c 24             	mov    %ebx,(%esp)
  8019c5:	e8 fd fb ff ff       	call   8015c7 <close>
	return r;
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	89 f0                	mov    %esi,%eax
}
  8019cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d2:	5b                   	pop    %ebx
  8019d3:	5e                   	pop    %esi
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	56                   	push   %esi
  8019da:	53                   	push   %ebx
  8019db:	89 c6                	mov    %eax,%esi
  8019dd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019df:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019e6:	75 12                	jne    8019fa <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	6a 01                	push   $0x1
  8019ed:	e8 5b 11 00 00       	call   802b4d <ipc_find_env>
  8019f2:	a3 00 50 80 00       	mov    %eax,0x805000
  8019f7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019fa:	6a 07                	push   $0x7
  8019fc:	68 00 60 80 00       	push   $0x806000
  801a01:	56                   	push   %esi
  801a02:	ff 35 00 50 80 00    	pushl  0x805000
  801a08:	e8 ec 10 00 00       	call   802af9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a0d:	83 c4 0c             	add    $0xc,%esp
  801a10:	6a 00                	push   $0x0
  801a12:	53                   	push   %ebx
  801a13:	6a 00                	push   $0x0
  801a15:	e8 78 10 00 00       	call   802a92 <ipc_recv>
}
  801a1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a27:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a35:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3f:	b8 02 00 00 00       	mov    $0x2,%eax
  801a44:	e8 8d ff ff ff       	call   8019d6 <fsipc>
}
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a51:	8b 45 08             	mov    0x8(%ebp),%eax
  801a54:	8b 40 0c             	mov    0xc(%eax),%eax
  801a57:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a61:	b8 06 00 00 00       	mov    $0x6,%eax
  801a66:	e8 6b ff ff ff       	call   8019d6 <fsipc>
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	53                   	push   %ebx
  801a71:	83 ec 04             	sub    $0x4,%esp
  801a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a77:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a82:	ba 00 00 00 00       	mov    $0x0,%edx
  801a87:	b8 05 00 00 00       	mov    $0x5,%eax
  801a8c:	e8 45 ff ff ff       	call   8019d6 <fsipc>
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 2c                	js     801ac1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a95:	83 ec 08             	sub    $0x8,%esp
  801a98:	68 00 60 80 00       	push   $0x806000
  801a9d:	53                   	push   %ebx
  801a9e:	e8 9f f0 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aa3:	a1 80 60 80 00       	mov    0x806080,%eax
  801aa8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aae:	a1 84 60 80 00       	mov    0x806084,%eax
  801ab3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801acf:	8b 55 08             	mov    0x8(%ebp),%edx
  801ad2:	8b 52 0c             	mov    0xc(%edx),%edx
  801ad5:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801adb:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ae0:	50                   	push   %eax
  801ae1:	ff 75 0c             	pushl  0xc(%ebp)
  801ae4:	68 08 60 80 00       	push   $0x806008
  801ae9:	e8 e6 f1 ff ff       	call   800cd4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801aee:	ba 00 00 00 00       	mov    $0x0,%edx
  801af3:	b8 04 00 00 00       	mov    $0x4,%eax
  801af8:	e8 d9 fe ff ff       	call   8019d6 <fsipc>

}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b12:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b18:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1d:	b8 03 00 00 00       	mov    $0x3,%eax
  801b22:	e8 af fe ff ff       	call   8019d6 <fsipc>
  801b27:	89 c3                	mov    %eax,%ebx
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 4b                	js     801b78 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b2d:	39 c6                	cmp    %eax,%esi
  801b2f:	73 16                	jae    801b47 <devfile_read+0x48>
  801b31:	68 54 34 80 00       	push   $0x803454
  801b36:	68 5b 34 80 00       	push   $0x80345b
  801b3b:	6a 7c                	push   $0x7c
  801b3d:	68 70 34 80 00       	push   $0x803470
  801b42:	e8 9d e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801b47:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b4c:	7e 16                	jle    801b64 <devfile_read+0x65>
  801b4e:	68 7b 34 80 00       	push   $0x80347b
  801b53:	68 5b 34 80 00       	push   $0x80345b
  801b58:	6a 7d                	push   $0x7d
  801b5a:	68 70 34 80 00       	push   $0x803470
  801b5f:	e8 80 e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b64:	83 ec 04             	sub    $0x4,%esp
  801b67:	50                   	push   %eax
  801b68:	68 00 60 80 00       	push   $0x806000
  801b6d:	ff 75 0c             	pushl  0xc(%ebp)
  801b70:	e8 5f f1 ff ff       	call   800cd4 <memmove>
	return r;
  801b75:	83 c4 10             	add    $0x10,%esp
}
  801b78:	89 d8                	mov    %ebx,%eax
  801b7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7d:	5b                   	pop    %ebx
  801b7e:	5e                   	pop    %esi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	53                   	push   %ebx
  801b85:	83 ec 20             	sub    $0x20,%esp
  801b88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b8b:	53                   	push   %ebx
  801b8c:	e8 78 ef ff ff       	call   800b09 <strlen>
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b99:	7f 67                	jg     801c02 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b9b:	83 ec 0c             	sub    $0xc,%esp
  801b9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 a7 f8 ff ff       	call   80144e <fd_alloc>
  801ba7:	83 c4 10             	add    $0x10,%esp
		return r;
  801baa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 57                	js     801c07 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bb0:	83 ec 08             	sub    $0x8,%esp
  801bb3:	53                   	push   %ebx
  801bb4:	68 00 60 80 00       	push   $0x806000
  801bb9:	e8 84 ef ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc1:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bce:	e8 03 fe ff ff       	call   8019d6 <fsipc>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	79 14                	jns    801bf0 <open+0x6f>
		fd_close(fd, 0);
  801bdc:	83 ec 08             	sub    $0x8,%esp
  801bdf:	6a 00                	push   $0x0
  801be1:	ff 75 f4             	pushl  -0xc(%ebp)
  801be4:	e8 5d f9 ff ff       	call   801546 <fd_close>
		return r;
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	89 da                	mov    %ebx,%edx
  801bee:	eb 17                	jmp    801c07 <open+0x86>
	}

	return fd2num(fd);
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf6:	e8 2c f8 ff ff       	call   801427 <fd2num>
  801bfb:	89 c2                	mov    %eax,%edx
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	eb 05                	jmp    801c07 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c02:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c07:	89 d0                	mov    %edx,%eax
  801c09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    

00801c0e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c14:	ba 00 00 00 00       	mov    $0x0,%edx
  801c19:	b8 08 00 00 00       	mov    $0x8,%eax
  801c1e:	e8 b3 fd ff ff       	call   8019d6 <fsipc>
}
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	57                   	push   %edi
  801c29:	56                   	push   %esi
  801c2a:	53                   	push   %ebx
  801c2b:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c31:	6a 00                	push   $0x0
  801c33:	ff 75 08             	pushl  0x8(%ebp)
  801c36:	e8 46 ff ff ff       	call   801b81 <open>
  801c3b:	89 c7                	mov    %eax,%edi
  801c3d:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	85 c0                	test   %eax,%eax
  801c48:	0f 88 97 04 00 00    	js     8020e5 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c4e:	83 ec 04             	sub    $0x4,%esp
  801c51:	68 00 02 00 00       	push   $0x200
  801c56:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c5c:	50                   	push   %eax
  801c5d:	57                   	push   %edi
  801c5e:	e8 31 fb ff ff       	call   801794 <readn>
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c6b:	75 0c                	jne    801c79 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c6d:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c74:	45 4c 46 
  801c77:	74 33                	je     801cac <spawn+0x87>
		close(fd);
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c82:	e8 40 f9 ff ff       	call   8015c7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c87:	83 c4 0c             	add    $0xc,%esp
  801c8a:	68 7f 45 4c 46       	push   $0x464c457f
  801c8f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c95:	68 87 34 80 00       	push   $0x803487
  801c9a:	e8 1e e9 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801ca7:	e9 ec 04 00 00       	jmp    802198 <spawn+0x573>
  801cac:	b8 07 00 00 00       	mov    $0x7,%eax
  801cb1:	cd 30                	int    $0x30
  801cb3:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801cb9:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	0f 88 29 04 00 00    	js     8020f0 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801cc7:	89 c6                	mov    %eax,%esi
  801cc9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801ccf:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801cd2:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801cd8:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cde:	b9 11 00 00 00       	mov    $0x11,%ecx
  801ce3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801ce5:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801ceb:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801cf6:	be 00 00 00 00       	mov    $0x0,%esi
  801cfb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cfe:	eb 13                	jmp    801d13 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d00:	83 ec 0c             	sub    $0xc,%esp
  801d03:	50                   	push   %eax
  801d04:	e8 00 ee ff ff       	call   800b09 <strlen>
  801d09:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d0d:	83 c3 01             	add    $0x1,%ebx
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d1a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	75 df                	jne    801d00 <spawn+0xdb>
  801d21:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d27:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d2d:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d32:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d34:	89 fa                	mov    %edi,%edx
  801d36:	83 e2 fc             	and    $0xfffffffc,%edx
  801d39:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d40:	29 c2                	sub    %eax,%edx
  801d42:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d48:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d4b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d50:	0f 86 b0 03 00 00    	jbe    802106 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d56:	83 ec 04             	sub    $0x4,%esp
  801d59:	6a 07                	push   $0x7
  801d5b:	68 00 00 40 00       	push   $0x400000
  801d60:	6a 00                	push   $0x0
  801d62:	e8 de f1 ff ff       	call   800f45 <sys_page_alloc>
  801d67:	83 c4 10             	add    $0x10,%esp
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	0f 88 9e 03 00 00    	js     802110 <spawn+0x4eb>
  801d72:	be 00 00 00 00       	mov    $0x0,%esi
  801d77:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d80:	eb 30                	jmp    801db2 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d82:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d88:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801d8e:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801d91:	83 ec 08             	sub    $0x8,%esp
  801d94:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d97:	57                   	push   %edi
  801d98:	e8 a5 ed ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d9d:	83 c4 04             	add    $0x4,%esp
  801da0:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801da3:	e8 61 ed ff ff       	call   800b09 <strlen>
  801da8:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801dac:	83 c6 01             	add    $0x1,%esi
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801db8:	7f c8                	jg     801d82 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801dba:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dc0:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801dc6:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801dcd:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801dd3:	74 19                	je     801dee <spawn+0x1c9>
  801dd5:	68 14 35 80 00       	push   $0x803514
  801dda:	68 5b 34 80 00       	push   $0x80345b
  801ddf:	68 f2 00 00 00       	push   $0xf2
  801de4:	68 a1 34 80 00       	push   $0x8034a1
  801de9:	e8 f6 e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801dee:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801df4:	89 f8                	mov    %edi,%eax
  801df6:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801dfb:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801dfe:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e04:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e07:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e0d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e13:	83 ec 0c             	sub    $0xc,%esp
  801e16:	6a 07                	push   $0x7
  801e18:	68 00 d0 bf ee       	push   $0xeebfd000
  801e1d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e23:	68 00 00 40 00       	push   $0x400000
  801e28:	6a 00                	push   $0x0
  801e2a:	e8 59 f1 ff ff       	call   800f88 <sys_page_map>
  801e2f:	89 c3                	mov    %eax,%ebx
  801e31:	83 c4 20             	add    $0x20,%esp
  801e34:	85 c0                	test   %eax,%eax
  801e36:	0f 88 4a 03 00 00    	js     802186 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e3c:	83 ec 08             	sub    $0x8,%esp
  801e3f:	68 00 00 40 00       	push   $0x400000
  801e44:	6a 00                	push   $0x0
  801e46:	e8 7f f1 ff ff       	call   800fca <sys_page_unmap>
  801e4b:	89 c3                	mov    %eax,%ebx
  801e4d:	83 c4 10             	add    $0x10,%esp
  801e50:	85 c0                	test   %eax,%eax
  801e52:	0f 88 2e 03 00 00    	js     802186 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e58:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e5e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e65:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e6b:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e72:	00 00 00 
  801e75:	e9 8a 01 00 00       	jmp    802004 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801e7a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e80:	83 38 01             	cmpl   $0x1,(%eax)
  801e83:	0f 85 6d 01 00 00    	jne    801ff6 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e89:	89 c7                	mov    %eax,%edi
  801e8b:	8b 40 18             	mov    0x18(%eax),%eax
  801e8e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e94:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e97:	83 f8 01             	cmp    $0x1,%eax
  801e9a:	19 c0                	sbb    %eax,%eax
  801e9c:	83 e0 fe             	and    $0xfffffffe,%eax
  801e9f:	83 c0 07             	add    $0x7,%eax
  801ea2:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ea8:	89 f8                	mov    %edi,%eax
  801eaa:	8b 7f 04             	mov    0x4(%edi),%edi
  801ead:	89 f9                	mov    %edi,%ecx
  801eaf:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801eb5:	8b 78 10             	mov    0x10(%eax),%edi
  801eb8:	8b 70 14             	mov    0x14(%eax),%esi
  801ebb:	89 f3                	mov    %esi,%ebx
  801ebd:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801ec3:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ec6:	89 f0                	mov    %esi,%eax
  801ec8:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ecd:	74 14                	je     801ee3 <spawn+0x2be>
		va -= i;
  801ecf:	29 c6                	sub    %eax,%esi
		memsz += i;
  801ed1:	01 c3                	add    %eax,%ebx
  801ed3:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801ed9:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801edb:	29 c1                	sub    %eax,%ecx
  801edd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ee3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ee8:	e9 f7 00 00 00       	jmp    801fe4 <spawn+0x3bf>
		if (i >= filesz) {
  801eed:	39 df                	cmp    %ebx,%edi
  801eef:	77 27                	ja     801f18 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ef1:	83 ec 04             	sub    $0x4,%esp
  801ef4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801efa:	56                   	push   %esi
  801efb:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f01:	e8 3f f0 ff ff       	call   800f45 <sys_page_alloc>
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	0f 89 c7 00 00 00    	jns    801fd8 <spawn+0x3b3>
  801f11:	89 c3                	mov    %eax,%ebx
  801f13:	e9 09 02 00 00       	jmp    802121 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f18:	83 ec 04             	sub    $0x4,%esp
  801f1b:	6a 07                	push   $0x7
  801f1d:	68 00 00 40 00       	push   $0x400000
  801f22:	6a 00                	push   $0x0
  801f24:	e8 1c f0 ff ff       	call   800f45 <sys_page_alloc>
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	0f 88 e3 01 00 00    	js     802117 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f34:	83 ec 08             	sub    $0x8,%esp
  801f37:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f3d:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f43:	50                   	push   %eax
  801f44:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f4a:	e8 1a f9 ff ff       	call   801869 <seek>
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	85 c0                	test   %eax,%eax
  801f54:	0f 88 c1 01 00 00    	js     80211b <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f5a:	83 ec 04             	sub    $0x4,%esp
  801f5d:	89 f8                	mov    %edi,%eax
  801f5f:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f65:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f6a:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801f6f:	0f 47 c1             	cmova  %ecx,%eax
  801f72:	50                   	push   %eax
  801f73:	68 00 00 40 00       	push   $0x400000
  801f78:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f7e:	e8 11 f8 ff ff       	call   801794 <readn>
  801f83:	83 c4 10             	add    $0x10,%esp
  801f86:	85 c0                	test   %eax,%eax
  801f88:	0f 88 91 01 00 00    	js     80211f <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f8e:	83 ec 0c             	sub    $0xc,%esp
  801f91:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f97:	56                   	push   %esi
  801f98:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f9e:	68 00 00 40 00       	push   $0x400000
  801fa3:	6a 00                	push   $0x0
  801fa5:	e8 de ef ff ff       	call   800f88 <sys_page_map>
  801faa:	83 c4 20             	add    $0x20,%esp
  801fad:	85 c0                	test   %eax,%eax
  801faf:	79 15                	jns    801fc6 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801fb1:	50                   	push   %eax
  801fb2:	68 ad 34 80 00       	push   $0x8034ad
  801fb7:	68 25 01 00 00       	push   $0x125
  801fbc:	68 a1 34 80 00       	push   $0x8034a1
  801fc1:	e8 1e e5 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801fc6:	83 ec 08             	sub    $0x8,%esp
  801fc9:	68 00 00 40 00       	push   $0x400000
  801fce:	6a 00                	push   $0x0
  801fd0:	e8 f5 ef ff ff       	call   800fca <sys_page_unmap>
  801fd5:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fd8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fde:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801fe4:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801fea:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801ff0:	0f 87 f7 fe ff ff    	ja     801eed <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ff6:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801ffd:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802004:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80200b:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802011:	0f 8c 63 fe ff ff    	jl     801e7a <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802017:	83 ec 0c             	sub    $0xc,%esp
  80201a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802020:	e8 a2 f5 ff ff       	call   8015c7 <close>
  802025:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  802028:	bb 00 08 00 00       	mov    $0x800,%ebx
  80202d:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  802033:	89 d8                	mov    %ebx,%eax
  802035:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  802038:	89 c2                	mov    %eax,%edx
  80203a:	c1 ea 16             	shr    $0x16,%edx
  80203d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802044:	f6 c2 01             	test   $0x1,%dl
  802047:	74 4b                	je     802094 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  802049:	89 c2                	mov    %eax,%edx
  80204b:	c1 ea 0c             	shr    $0xc,%edx
  80204e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  802055:	f6 c1 01             	test   $0x1,%cl
  802058:	74 3a                	je     802094 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  80205a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802061:	f6 c6 04             	test   $0x4,%dh
  802064:	74 2e                	je     802094 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  802066:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  80206d:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  802073:	8b 49 48             	mov    0x48(%ecx),%ecx
  802076:	83 ec 0c             	sub    $0xc,%esp
  802079:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80207f:	52                   	push   %edx
  802080:	50                   	push   %eax
  802081:	56                   	push   %esi
  802082:	50                   	push   %eax
  802083:	51                   	push   %ecx
  802084:	e8 ff ee ff ff       	call   800f88 <sys_page_map>
					if (r < 0)
  802089:	83 c4 20             	add    $0x20,%esp
  80208c:	85 c0                	test   %eax,%eax
  80208e:	0f 88 ae 00 00 00    	js     802142 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  802094:	83 c3 01             	add    $0x1,%ebx
  802097:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80209d:	75 94                	jne    802033 <spawn+0x40e>
  80209f:	e9 b3 00 00 00       	jmp    802157 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8020a4:	50                   	push   %eax
  8020a5:	68 ca 34 80 00       	push   $0x8034ca
  8020aa:	68 86 00 00 00       	push   $0x86
  8020af:	68 a1 34 80 00       	push   $0x8034a1
  8020b4:	e8 2b e4 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8020b9:	83 ec 08             	sub    $0x8,%esp
  8020bc:	6a 02                	push   $0x2
  8020be:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020c4:	e8 43 ef ff ff       	call   80100c <sys_env_set_status>
  8020c9:	83 c4 10             	add    $0x10,%esp
  8020cc:	85 c0                	test   %eax,%eax
  8020ce:	79 2b                	jns    8020fb <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  8020d0:	50                   	push   %eax
  8020d1:	68 e4 34 80 00       	push   $0x8034e4
  8020d6:	68 89 00 00 00       	push   $0x89
  8020db:	68 a1 34 80 00       	push   $0x8034a1
  8020e0:	e8 ff e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8020e5:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8020eb:	e9 a8 00 00 00       	jmp    802198 <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8020f0:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8020f6:	e9 9d 00 00 00       	jmp    802198 <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8020fb:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802101:	e9 92 00 00 00       	jmp    802198 <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802106:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80210b:	e9 88 00 00 00       	jmp    802198 <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802110:	89 c3                	mov    %eax,%ebx
  802112:	e9 81 00 00 00       	jmp    802198 <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802117:	89 c3                	mov    %eax,%ebx
  802119:	eb 06                	jmp    802121 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80211b:	89 c3                	mov    %eax,%ebx
  80211d:	eb 02                	jmp    802121 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80211f:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802121:	83 ec 0c             	sub    $0xc,%esp
  802124:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80212a:	e8 97 ed ff ff       	call   800ec6 <sys_env_destroy>
	close(fd);
  80212f:	83 c4 04             	add    $0x4,%esp
  802132:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802138:	e8 8a f4 ff ff       	call   8015c7 <close>
	return r;
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	eb 56                	jmp    802198 <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802142:	50                   	push   %eax
  802143:	68 fb 34 80 00       	push   $0x8034fb
  802148:	68 82 00 00 00       	push   $0x82
  80214d:	68 a1 34 80 00       	push   $0x8034a1
  802152:	e8 8d e3 ff ff       	call   8004e4 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802157:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80215e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802161:	83 ec 08             	sub    $0x8,%esp
  802164:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80216a:	50                   	push   %eax
  80216b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802171:	e8 d8 ee ff ff       	call   80104e <sys_env_set_trapframe>
  802176:	83 c4 10             	add    $0x10,%esp
  802179:	85 c0                	test   %eax,%eax
  80217b:	0f 89 38 ff ff ff    	jns    8020b9 <spawn+0x494>
  802181:	e9 1e ff ff ff       	jmp    8020a4 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802186:	83 ec 08             	sub    $0x8,%esp
  802189:	68 00 00 40 00       	push   $0x400000
  80218e:	6a 00                	push   $0x0
  802190:	e8 35 ee ff ff       	call   800fca <sys_page_unmap>
  802195:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    

008021a2 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	56                   	push   %esi
  8021a6:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021a7:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021aa:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021af:	eb 03                	jmp    8021b4 <spawnl+0x12>
		argc++;
  8021b1:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021b4:	83 c2 04             	add    $0x4,%edx
  8021b7:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021bb:	75 f4                	jne    8021b1 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021bd:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021c4:	83 e2 f0             	and    $0xfffffff0,%edx
  8021c7:	29 d4                	sub    %edx,%esp
  8021c9:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021cd:	c1 ea 02             	shr    $0x2,%edx
  8021d0:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021d7:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021dc:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021e3:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021ea:	00 
  8021eb:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f2:	eb 0a                	jmp    8021fe <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8021f4:	83 c0 01             	add    $0x1,%eax
  8021f7:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8021fb:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021fe:	39 d0                	cmp    %edx,%eax
  802200:	75 f2                	jne    8021f4 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802202:	83 ec 08             	sub    $0x8,%esp
  802205:	56                   	push   %esi
  802206:	ff 75 08             	pushl  0x8(%ebp)
  802209:	e8 17 fa ff ff       	call   801c25 <spawn>
}
  80220e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802211:	5b                   	pop    %ebx
  802212:	5e                   	pop    %esi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80221b:	68 3c 35 80 00       	push   $0x80353c
  802220:	ff 75 0c             	pushl  0xc(%ebp)
  802223:	e8 1a e9 ff ff       	call   800b42 <strcpy>
	return 0;
}
  802228:	b8 00 00 00 00       	mov    $0x0,%eax
  80222d:	c9                   	leave  
  80222e:	c3                   	ret    

0080222f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	53                   	push   %ebx
  802233:	83 ec 10             	sub    $0x10,%esp
  802236:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802239:	53                   	push   %ebx
  80223a:	e8 47 09 00 00       	call   802b86 <pageref>
  80223f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802242:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802247:	83 f8 01             	cmp    $0x1,%eax
  80224a:	75 10                	jne    80225c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80224c:	83 ec 0c             	sub    $0xc,%esp
  80224f:	ff 73 0c             	pushl  0xc(%ebx)
  802252:	e8 c0 02 00 00       	call   802517 <nsipc_close>
  802257:	89 c2                	mov    %eax,%edx
  802259:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80225c:	89 d0                	mov    %edx,%eax
  80225e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802261:	c9                   	leave  
  802262:	c3                   	ret    

00802263 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802269:	6a 00                	push   $0x0
  80226b:	ff 75 10             	pushl  0x10(%ebp)
  80226e:	ff 75 0c             	pushl  0xc(%ebp)
  802271:	8b 45 08             	mov    0x8(%ebp),%eax
  802274:	ff 70 0c             	pushl  0xc(%eax)
  802277:	e8 78 03 00 00       	call   8025f4 <nsipc_send>
}
  80227c:	c9                   	leave  
  80227d:	c3                   	ret    

0080227e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802284:	6a 00                	push   $0x0
  802286:	ff 75 10             	pushl  0x10(%ebp)
  802289:	ff 75 0c             	pushl  0xc(%ebp)
  80228c:	8b 45 08             	mov    0x8(%ebp),%eax
  80228f:	ff 70 0c             	pushl  0xc(%eax)
  802292:	e8 f1 02 00 00       	call   802588 <nsipc_recv>
}
  802297:	c9                   	leave  
  802298:	c3                   	ret    

00802299 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802299:	55                   	push   %ebp
  80229a:	89 e5                	mov    %esp,%ebp
  80229c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80229f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8022a2:	52                   	push   %edx
  8022a3:	50                   	push   %eax
  8022a4:	e8 f4 f1 ff ff       	call   80149d <fd_lookup>
  8022a9:	83 c4 10             	add    $0x10,%esp
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	78 17                	js     8022c7 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8022b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b3:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  8022b9:	39 08                	cmp    %ecx,(%eax)
  8022bb:	75 05                	jne    8022c2 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8022bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8022c0:	eb 05                	jmp    8022c7 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8022c2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8022c7:	c9                   	leave  
  8022c8:	c3                   	ret    

008022c9 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	56                   	push   %esi
  8022cd:	53                   	push   %ebx
  8022ce:	83 ec 1c             	sub    $0x1c,%esp
  8022d1:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8022d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d6:	50                   	push   %eax
  8022d7:	e8 72 f1 ff ff       	call   80144e <fd_alloc>
  8022dc:	89 c3                	mov    %eax,%ebx
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	85 c0                	test   %eax,%eax
  8022e3:	78 1b                	js     802300 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8022e5:	83 ec 04             	sub    $0x4,%esp
  8022e8:	68 07 04 00 00       	push   $0x407
  8022ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f0:	6a 00                	push   $0x0
  8022f2:	e8 4e ec ff ff       	call   800f45 <sys_page_alloc>
  8022f7:	89 c3                	mov    %eax,%ebx
  8022f9:	83 c4 10             	add    $0x10,%esp
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	79 10                	jns    802310 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802300:	83 ec 0c             	sub    $0xc,%esp
  802303:	56                   	push   %esi
  802304:	e8 0e 02 00 00       	call   802517 <nsipc_close>
		return r;
  802309:	83 c4 10             	add    $0x10,%esp
  80230c:	89 d8                	mov    %ebx,%eax
  80230e:	eb 24                	jmp    802334 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802310:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802316:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802319:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802325:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802328:	83 ec 0c             	sub    $0xc,%esp
  80232b:	50                   	push   %eax
  80232c:	e8 f6 f0 ff ff       	call   801427 <fd2num>
  802331:	83 c4 10             	add    $0x10,%esp
}
  802334:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    

0080233b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802341:	8b 45 08             	mov    0x8(%ebp),%eax
  802344:	e8 50 ff ff ff       	call   802299 <fd2sockid>
		return r;
  802349:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80234b:	85 c0                	test   %eax,%eax
  80234d:	78 1f                	js     80236e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80234f:	83 ec 04             	sub    $0x4,%esp
  802352:	ff 75 10             	pushl  0x10(%ebp)
  802355:	ff 75 0c             	pushl  0xc(%ebp)
  802358:	50                   	push   %eax
  802359:	e8 12 01 00 00       	call   802470 <nsipc_accept>
  80235e:	83 c4 10             	add    $0x10,%esp
		return r;
  802361:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802363:	85 c0                	test   %eax,%eax
  802365:	78 07                	js     80236e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802367:	e8 5d ff ff ff       	call   8022c9 <alloc_sockfd>
  80236c:	89 c1                	mov    %eax,%ecx
}
  80236e:	89 c8                	mov    %ecx,%eax
  802370:	c9                   	leave  
  802371:	c3                   	ret    

00802372 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802372:	55                   	push   %ebp
  802373:	89 e5                	mov    %esp,%ebp
  802375:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802378:	8b 45 08             	mov    0x8(%ebp),%eax
  80237b:	e8 19 ff ff ff       	call   802299 <fd2sockid>
  802380:	85 c0                	test   %eax,%eax
  802382:	78 12                	js     802396 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802384:	83 ec 04             	sub    $0x4,%esp
  802387:	ff 75 10             	pushl  0x10(%ebp)
  80238a:	ff 75 0c             	pushl  0xc(%ebp)
  80238d:	50                   	push   %eax
  80238e:	e8 2d 01 00 00       	call   8024c0 <nsipc_bind>
  802393:	83 c4 10             	add    $0x10,%esp
}
  802396:	c9                   	leave  
  802397:	c3                   	ret    

00802398 <shutdown>:

int
shutdown(int s, int how)
{
  802398:	55                   	push   %ebp
  802399:	89 e5                	mov    %esp,%ebp
  80239b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80239e:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a1:	e8 f3 fe ff ff       	call   802299 <fd2sockid>
  8023a6:	85 c0                	test   %eax,%eax
  8023a8:	78 0f                	js     8023b9 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8023aa:	83 ec 08             	sub    $0x8,%esp
  8023ad:	ff 75 0c             	pushl  0xc(%ebp)
  8023b0:	50                   	push   %eax
  8023b1:	e8 3f 01 00 00       	call   8024f5 <nsipc_shutdown>
  8023b6:	83 c4 10             	add    $0x10,%esp
}
  8023b9:	c9                   	leave  
  8023ba:	c3                   	ret    

008023bb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023bb:	55                   	push   %ebp
  8023bc:	89 e5                	mov    %esp,%ebp
  8023be:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c4:	e8 d0 fe ff ff       	call   802299 <fd2sockid>
  8023c9:	85 c0                	test   %eax,%eax
  8023cb:	78 12                	js     8023df <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8023cd:	83 ec 04             	sub    $0x4,%esp
  8023d0:	ff 75 10             	pushl  0x10(%ebp)
  8023d3:	ff 75 0c             	pushl  0xc(%ebp)
  8023d6:	50                   	push   %eax
  8023d7:	e8 55 01 00 00       	call   802531 <nsipc_connect>
  8023dc:	83 c4 10             	add    $0x10,%esp
}
  8023df:	c9                   	leave  
  8023e0:	c3                   	ret    

008023e1 <listen>:

int
listen(int s, int backlog)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ea:	e8 aa fe ff ff       	call   802299 <fd2sockid>
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	78 0f                	js     802402 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8023f3:	83 ec 08             	sub    $0x8,%esp
  8023f6:	ff 75 0c             	pushl  0xc(%ebp)
  8023f9:	50                   	push   %eax
  8023fa:	e8 67 01 00 00       	call   802566 <nsipc_listen>
  8023ff:	83 c4 10             	add    $0x10,%esp
}
  802402:	c9                   	leave  
  802403:	c3                   	ret    

00802404 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80240a:	ff 75 10             	pushl  0x10(%ebp)
  80240d:	ff 75 0c             	pushl  0xc(%ebp)
  802410:	ff 75 08             	pushl  0x8(%ebp)
  802413:	e8 3a 02 00 00       	call   802652 <nsipc_socket>
  802418:	83 c4 10             	add    $0x10,%esp
  80241b:	85 c0                	test   %eax,%eax
  80241d:	78 05                	js     802424 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80241f:	e8 a5 fe ff ff       	call   8022c9 <alloc_sockfd>
}
  802424:	c9                   	leave  
  802425:	c3                   	ret    

00802426 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802426:	55                   	push   %ebp
  802427:	89 e5                	mov    %esp,%ebp
  802429:	53                   	push   %ebx
  80242a:	83 ec 04             	sub    $0x4,%esp
  80242d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80242f:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802436:	75 12                	jne    80244a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802438:	83 ec 0c             	sub    $0xc,%esp
  80243b:	6a 02                	push   $0x2
  80243d:	e8 0b 07 00 00       	call   802b4d <ipc_find_env>
  802442:	a3 04 50 80 00       	mov    %eax,0x805004
  802447:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80244a:	6a 07                	push   $0x7
  80244c:	68 00 70 80 00       	push   $0x807000
  802451:	53                   	push   %ebx
  802452:	ff 35 04 50 80 00    	pushl  0x805004
  802458:	e8 9c 06 00 00       	call   802af9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80245d:	83 c4 0c             	add    $0xc,%esp
  802460:	6a 00                	push   $0x0
  802462:	6a 00                	push   $0x0
  802464:	6a 00                	push   $0x0
  802466:	e8 27 06 00 00       	call   802a92 <ipc_recv>
}
  80246b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80246e:	c9                   	leave  
  80246f:	c3                   	ret    

00802470 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	56                   	push   %esi
  802474:	53                   	push   %ebx
  802475:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802478:	8b 45 08             	mov    0x8(%ebp),%eax
  80247b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802480:	8b 06                	mov    (%esi),%eax
  802482:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802487:	b8 01 00 00 00       	mov    $0x1,%eax
  80248c:	e8 95 ff ff ff       	call   802426 <nsipc>
  802491:	89 c3                	mov    %eax,%ebx
  802493:	85 c0                	test   %eax,%eax
  802495:	78 20                	js     8024b7 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802497:	83 ec 04             	sub    $0x4,%esp
  80249a:	ff 35 10 70 80 00    	pushl  0x807010
  8024a0:	68 00 70 80 00       	push   $0x807000
  8024a5:	ff 75 0c             	pushl  0xc(%ebp)
  8024a8:	e8 27 e8 ff ff       	call   800cd4 <memmove>
		*addrlen = ret->ret_addrlen;
  8024ad:	a1 10 70 80 00       	mov    0x807010,%eax
  8024b2:	89 06                	mov    %eax,(%esi)
  8024b4:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8024b7:	89 d8                	mov    %ebx,%eax
  8024b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024bc:	5b                   	pop    %ebx
  8024bd:	5e                   	pop    %esi
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    

008024c0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 08             	sub    $0x8,%esp
  8024c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8024ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8024d2:	53                   	push   %ebx
  8024d3:	ff 75 0c             	pushl  0xc(%ebp)
  8024d6:	68 04 70 80 00       	push   $0x807004
  8024db:	e8 f4 e7 ff ff       	call   800cd4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024e0:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8024e6:	b8 02 00 00 00       	mov    $0x2,%eax
  8024eb:	e8 36 ff ff ff       	call   802426 <nsipc>
}
  8024f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024f3:	c9                   	leave  
  8024f4:	c3                   	ret    

008024f5 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8024f5:	55                   	push   %ebp
  8024f6:	89 e5                	mov    %esp,%ebp
  8024f8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8024fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fe:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802503:	8b 45 0c             	mov    0xc(%ebp),%eax
  802506:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80250b:	b8 03 00 00 00       	mov    $0x3,%eax
  802510:	e8 11 ff ff ff       	call   802426 <nsipc>
}
  802515:	c9                   	leave  
  802516:	c3                   	ret    

00802517 <nsipc_close>:

int
nsipc_close(int s)
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80251d:	8b 45 08             	mov    0x8(%ebp),%eax
  802520:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802525:	b8 04 00 00 00       	mov    $0x4,%eax
  80252a:	e8 f7 fe ff ff       	call   802426 <nsipc>
}
  80252f:	c9                   	leave  
  802530:	c3                   	ret    

00802531 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802531:	55                   	push   %ebp
  802532:	89 e5                	mov    %esp,%ebp
  802534:	53                   	push   %ebx
  802535:	83 ec 08             	sub    $0x8,%esp
  802538:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80253b:	8b 45 08             	mov    0x8(%ebp),%eax
  80253e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802543:	53                   	push   %ebx
  802544:	ff 75 0c             	pushl  0xc(%ebp)
  802547:	68 04 70 80 00       	push   $0x807004
  80254c:	e8 83 e7 ff ff       	call   800cd4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802551:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802557:	b8 05 00 00 00       	mov    $0x5,%eax
  80255c:	e8 c5 fe ff ff       	call   802426 <nsipc>
}
  802561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802564:	c9                   	leave  
  802565:	c3                   	ret    

00802566 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802566:	55                   	push   %ebp
  802567:	89 e5                	mov    %esp,%ebp
  802569:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80256c:	8b 45 08             	mov    0x8(%ebp),%eax
  80256f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802574:	8b 45 0c             	mov    0xc(%ebp),%eax
  802577:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80257c:	b8 06 00 00 00       	mov    $0x6,%eax
  802581:	e8 a0 fe ff ff       	call   802426 <nsipc>
}
  802586:	c9                   	leave  
  802587:	c3                   	ret    

00802588 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802588:	55                   	push   %ebp
  802589:	89 e5                	mov    %esp,%ebp
  80258b:	56                   	push   %esi
  80258c:	53                   	push   %ebx
  80258d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802590:	8b 45 08             	mov    0x8(%ebp),%eax
  802593:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802598:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80259e:	8b 45 14             	mov    0x14(%ebp),%eax
  8025a1:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025a6:	b8 07 00 00 00       	mov    $0x7,%eax
  8025ab:	e8 76 fe ff ff       	call   802426 <nsipc>
  8025b0:	89 c3                	mov    %eax,%ebx
  8025b2:	85 c0                	test   %eax,%eax
  8025b4:	78 35                	js     8025eb <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8025b6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8025bb:	7f 04                	jg     8025c1 <nsipc_recv+0x39>
  8025bd:	39 c6                	cmp    %eax,%esi
  8025bf:	7d 16                	jge    8025d7 <nsipc_recv+0x4f>
  8025c1:	68 48 35 80 00       	push   $0x803548
  8025c6:	68 5b 34 80 00       	push   $0x80345b
  8025cb:	6a 62                	push   $0x62
  8025cd:	68 5d 35 80 00       	push   $0x80355d
  8025d2:	e8 0d df ff ff       	call   8004e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8025d7:	83 ec 04             	sub    $0x4,%esp
  8025da:	50                   	push   %eax
  8025db:	68 00 70 80 00       	push   $0x807000
  8025e0:	ff 75 0c             	pushl  0xc(%ebp)
  8025e3:	e8 ec e6 ff ff       	call   800cd4 <memmove>
  8025e8:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8025eb:	89 d8                	mov    %ebx,%eax
  8025ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025f0:	5b                   	pop    %ebx
  8025f1:	5e                   	pop    %esi
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    

008025f4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8025f4:	55                   	push   %ebp
  8025f5:	89 e5                	mov    %esp,%ebp
  8025f7:	53                   	push   %ebx
  8025f8:	83 ec 04             	sub    $0x4,%esp
  8025fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8025fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802601:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802606:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80260c:	7e 16                	jle    802624 <nsipc_send+0x30>
  80260e:	68 69 35 80 00       	push   $0x803569
  802613:	68 5b 34 80 00       	push   $0x80345b
  802618:	6a 6d                	push   $0x6d
  80261a:	68 5d 35 80 00       	push   $0x80355d
  80261f:	e8 c0 de ff ff       	call   8004e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802624:	83 ec 04             	sub    $0x4,%esp
  802627:	53                   	push   %ebx
  802628:	ff 75 0c             	pushl  0xc(%ebp)
  80262b:	68 0c 70 80 00       	push   $0x80700c
  802630:	e8 9f e6 ff ff       	call   800cd4 <memmove>
	nsipcbuf.send.req_size = size;
  802635:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80263b:	8b 45 14             	mov    0x14(%ebp),%eax
  80263e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802643:	b8 08 00 00 00       	mov    $0x8,%eax
  802648:	e8 d9 fd ff ff       	call   802426 <nsipc>
}
  80264d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802650:	c9                   	leave  
  802651:	c3                   	ret    

00802652 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802652:	55                   	push   %ebp
  802653:	89 e5                	mov    %esp,%ebp
  802655:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802658:	8b 45 08             	mov    0x8(%ebp),%eax
  80265b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802660:	8b 45 0c             	mov    0xc(%ebp),%eax
  802663:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802668:	8b 45 10             	mov    0x10(%ebp),%eax
  80266b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802670:	b8 09 00 00 00       	mov    $0x9,%eax
  802675:	e8 ac fd ff ff       	call   802426 <nsipc>
}
  80267a:	c9                   	leave  
  80267b:	c3                   	ret    

0080267c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80267c:	55                   	push   %ebp
  80267d:	89 e5                	mov    %esp,%ebp
  80267f:	56                   	push   %esi
  802680:	53                   	push   %ebx
  802681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802684:	83 ec 0c             	sub    $0xc,%esp
  802687:	ff 75 08             	pushl  0x8(%ebp)
  80268a:	e8 a8 ed ff ff       	call   801437 <fd2data>
  80268f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802691:	83 c4 08             	add    $0x8,%esp
  802694:	68 75 35 80 00       	push   $0x803575
  802699:	53                   	push   %ebx
  80269a:	e8 a3 e4 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80269f:	8b 46 04             	mov    0x4(%esi),%eax
  8026a2:	2b 06                	sub    (%esi),%eax
  8026a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8026aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8026b1:	00 00 00 
	stat->st_dev = &devpipe;
  8026b4:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  8026bb:	40 80 00 
	return 0;
}
  8026be:	b8 00 00 00 00       	mov    $0x0,%eax
  8026c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026c6:	5b                   	pop    %ebx
  8026c7:	5e                   	pop    %esi
  8026c8:	5d                   	pop    %ebp
  8026c9:	c3                   	ret    

008026ca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8026ca:	55                   	push   %ebp
  8026cb:	89 e5                	mov    %esp,%ebp
  8026cd:	53                   	push   %ebx
  8026ce:	83 ec 0c             	sub    $0xc,%esp
  8026d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8026d4:	53                   	push   %ebx
  8026d5:	6a 00                	push   $0x0
  8026d7:	e8 ee e8 ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8026dc:	89 1c 24             	mov    %ebx,(%esp)
  8026df:	e8 53 ed ff ff       	call   801437 <fd2data>
  8026e4:	83 c4 08             	add    $0x8,%esp
  8026e7:	50                   	push   %eax
  8026e8:	6a 00                	push   $0x0
  8026ea:	e8 db e8 ff ff       	call   800fca <sys_page_unmap>
}
  8026ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026f2:	c9                   	leave  
  8026f3:	c3                   	ret    

008026f4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8026f4:	55                   	push   %ebp
  8026f5:	89 e5                	mov    %esp,%ebp
  8026f7:	57                   	push   %edi
  8026f8:	56                   	push   %esi
  8026f9:	53                   	push   %ebx
  8026fa:	83 ec 1c             	sub    $0x1c,%esp
  8026fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802700:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802702:	a1 08 50 80 00       	mov    0x805008,%eax
  802707:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80270a:	83 ec 0c             	sub    $0xc,%esp
  80270d:	ff 75 e0             	pushl  -0x20(%ebp)
  802710:	e8 71 04 00 00       	call   802b86 <pageref>
  802715:	89 c3                	mov    %eax,%ebx
  802717:	89 3c 24             	mov    %edi,(%esp)
  80271a:	e8 67 04 00 00       	call   802b86 <pageref>
  80271f:	83 c4 10             	add    $0x10,%esp
  802722:	39 c3                	cmp    %eax,%ebx
  802724:	0f 94 c1             	sete   %cl
  802727:	0f b6 c9             	movzbl %cl,%ecx
  80272a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80272d:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802733:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802736:	39 ce                	cmp    %ecx,%esi
  802738:	74 1b                	je     802755 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80273a:	39 c3                	cmp    %eax,%ebx
  80273c:	75 c4                	jne    802702 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80273e:	8b 42 58             	mov    0x58(%edx),%eax
  802741:	ff 75 e4             	pushl  -0x1c(%ebp)
  802744:	50                   	push   %eax
  802745:	56                   	push   %esi
  802746:	68 7c 35 80 00       	push   $0x80357c
  80274b:	e8 6d de ff ff       	call   8005bd <cprintf>
  802750:	83 c4 10             	add    $0x10,%esp
  802753:	eb ad                	jmp    802702 <_pipeisclosed+0xe>
	}
}
  802755:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802758:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80275b:	5b                   	pop    %ebx
  80275c:	5e                   	pop    %esi
  80275d:	5f                   	pop    %edi
  80275e:	5d                   	pop    %ebp
  80275f:	c3                   	ret    

00802760 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	57                   	push   %edi
  802764:	56                   	push   %esi
  802765:	53                   	push   %ebx
  802766:	83 ec 28             	sub    $0x28,%esp
  802769:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80276c:	56                   	push   %esi
  80276d:	e8 c5 ec ff ff       	call   801437 <fd2data>
  802772:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802774:	83 c4 10             	add    $0x10,%esp
  802777:	bf 00 00 00 00       	mov    $0x0,%edi
  80277c:	eb 4b                	jmp    8027c9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80277e:	89 da                	mov    %ebx,%edx
  802780:	89 f0                	mov    %esi,%eax
  802782:	e8 6d ff ff ff       	call   8026f4 <_pipeisclosed>
  802787:	85 c0                	test   %eax,%eax
  802789:	75 48                	jne    8027d3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80278b:	e8 96 e7 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802790:	8b 43 04             	mov    0x4(%ebx),%eax
  802793:	8b 0b                	mov    (%ebx),%ecx
  802795:	8d 51 20             	lea    0x20(%ecx),%edx
  802798:	39 d0                	cmp    %edx,%eax
  80279a:	73 e2                	jae    80277e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80279c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80279f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8027a3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8027a6:	89 c2                	mov    %eax,%edx
  8027a8:	c1 fa 1f             	sar    $0x1f,%edx
  8027ab:	89 d1                	mov    %edx,%ecx
  8027ad:	c1 e9 1b             	shr    $0x1b,%ecx
  8027b0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8027b3:	83 e2 1f             	and    $0x1f,%edx
  8027b6:	29 ca                	sub    %ecx,%edx
  8027b8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8027bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8027c0:	83 c0 01             	add    $0x1,%eax
  8027c3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027c6:	83 c7 01             	add    $0x1,%edi
  8027c9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8027cc:	75 c2                	jne    802790 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8027ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8027d1:	eb 05                	jmp    8027d8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8027d3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8027d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027db:	5b                   	pop    %ebx
  8027dc:	5e                   	pop    %esi
  8027dd:	5f                   	pop    %edi
  8027de:	5d                   	pop    %ebp
  8027df:	c3                   	ret    

008027e0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027e0:	55                   	push   %ebp
  8027e1:	89 e5                	mov    %esp,%ebp
  8027e3:	57                   	push   %edi
  8027e4:	56                   	push   %esi
  8027e5:	53                   	push   %ebx
  8027e6:	83 ec 18             	sub    $0x18,%esp
  8027e9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8027ec:	57                   	push   %edi
  8027ed:	e8 45 ec ff ff       	call   801437 <fd2data>
  8027f2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027f4:	83 c4 10             	add    $0x10,%esp
  8027f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027fc:	eb 3d                	jmp    80283b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8027fe:	85 db                	test   %ebx,%ebx
  802800:	74 04                	je     802806 <devpipe_read+0x26>
				return i;
  802802:	89 d8                	mov    %ebx,%eax
  802804:	eb 44                	jmp    80284a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802806:	89 f2                	mov    %esi,%edx
  802808:	89 f8                	mov    %edi,%eax
  80280a:	e8 e5 fe ff ff       	call   8026f4 <_pipeisclosed>
  80280f:	85 c0                	test   %eax,%eax
  802811:	75 32                	jne    802845 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802813:	e8 0e e7 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802818:	8b 06                	mov    (%esi),%eax
  80281a:	3b 46 04             	cmp    0x4(%esi),%eax
  80281d:	74 df                	je     8027fe <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80281f:	99                   	cltd   
  802820:	c1 ea 1b             	shr    $0x1b,%edx
  802823:	01 d0                	add    %edx,%eax
  802825:	83 e0 1f             	and    $0x1f,%eax
  802828:	29 d0                	sub    %edx,%eax
  80282a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80282f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802832:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802835:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802838:	83 c3 01             	add    $0x1,%ebx
  80283b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80283e:	75 d8                	jne    802818 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802840:	8b 45 10             	mov    0x10(%ebp),%eax
  802843:	eb 05                	jmp    80284a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802845:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80284a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80284d:	5b                   	pop    %ebx
  80284e:	5e                   	pop    %esi
  80284f:	5f                   	pop    %edi
  802850:	5d                   	pop    %ebp
  802851:	c3                   	ret    

00802852 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802852:	55                   	push   %ebp
  802853:	89 e5                	mov    %esp,%ebp
  802855:	56                   	push   %esi
  802856:	53                   	push   %ebx
  802857:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80285a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80285d:	50                   	push   %eax
  80285e:	e8 eb eb ff ff       	call   80144e <fd_alloc>
  802863:	83 c4 10             	add    $0x10,%esp
  802866:	89 c2                	mov    %eax,%edx
  802868:	85 c0                	test   %eax,%eax
  80286a:	0f 88 2c 01 00 00    	js     80299c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802870:	83 ec 04             	sub    $0x4,%esp
  802873:	68 07 04 00 00       	push   $0x407
  802878:	ff 75 f4             	pushl  -0xc(%ebp)
  80287b:	6a 00                	push   $0x0
  80287d:	e8 c3 e6 ff ff       	call   800f45 <sys_page_alloc>
  802882:	83 c4 10             	add    $0x10,%esp
  802885:	89 c2                	mov    %eax,%edx
  802887:	85 c0                	test   %eax,%eax
  802889:	0f 88 0d 01 00 00    	js     80299c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80288f:	83 ec 0c             	sub    $0xc,%esp
  802892:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802895:	50                   	push   %eax
  802896:	e8 b3 eb ff ff       	call   80144e <fd_alloc>
  80289b:	89 c3                	mov    %eax,%ebx
  80289d:	83 c4 10             	add    $0x10,%esp
  8028a0:	85 c0                	test   %eax,%eax
  8028a2:	0f 88 e2 00 00 00    	js     80298a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028a8:	83 ec 04             	sub    $0x4,%esp
  8028ab:	68 07 04 00 00       	push   $0x407
  8028b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8028b3:	6a 00                	push   $0x0
  8028b5:	e8 8b e6 ff ff       	call   800f45 <sys_page_alloc>
  8028ba:	89 c3                	mov    %eax,%ebx
  8028bc:	83 c4 10             	add    $0x10,%esp
  8028bf:	85 c0                	test   %eax,%eax
  8028c1:	0f 88 c3 00 00 00    	js     80298a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8028c7:	83 ec 0c             	sub    $0xc,%esp
  8028ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8028cd:	e8 65 eb ff ff       	call   801437 <fd2data>
  8028d2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028d4:	83 c4 0c             	add    $0xc,%esp
  8028d7:	68 07 04 00 00       	push   $0x407
  8028dc:	50                   	push   %eax
  8028dd:	6a 00                	push   $0x0
  8028df:	e8 61 e6 ff ff       	call   800f45 <sys_page_alloc>
  8028e4:	89 c3                	mov    %eax,%ebx
  8028e6:	83 c4 10             	add    $0x10,%esp
  8028e9:	85 c0                	test   %eax,%eax
  8028eb:	0f 88 89 00 00 00    	js     80297a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028f1:	83 ec 0c             	sub    $0xc,%esp
  8028f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8028f7:	e8 3b eb ff ff       	call   801437 <fd2data>
  8028fc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802903:	50                   	push   %eax
  802904:	6a 00                	push   $0x0
  802906:	56                   	push   %esi
  802907:	6a 00                	push   $0x0
  802909:	e8 7a e6 ff ff       	call   800f88 <sys_page_map>
  80290e:	89 c3                	mov    %eax,%ebx
  802910:	83 c4 20             	add    $0x20,%esp
  802913:	85 c0                	test   %eax,%eax
  802915:	78 55                	js     80296c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802917:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80291d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802920:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802922:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802925:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80292c:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802932:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802935:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802937:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80293a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802941:	83 ec 0c             	sub    $0xc,%esp
  802944:	ff 75 f4             	pushl  -0xc(%ebp)
  802947:	e8 db ea ff ff       	call   801427 <fd2num>
  80294c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80294f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802951:	83 c4 04             	add    $0x4,%esp
  802954:	ff 75 f0             	pushl  -0x10(%ebp)
  802957:	e8 cb ea ff ff       	call   801427 <fd2num>
  80295c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80295f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802962:	83 c4 10             	add    $0x10,%esp
  802965:	ba 00 00 00 00       	mov    $0x0,%edx
  80296a:	eb 30                	jmp    80299c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80296c:	83 ec 08             	sub    $0x8,%esp
  80296f:	56                   	push   %esi
  802970:	6a 00                	push   $0x0
  802972:	e8 53 e6 ff ff       	call   800fca <sys_page_unmap>
  802977:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80297a:	83 ec 08             	sub    $0x8,%esp
  80297d:	ff 75 f0             	pushl  -0x10(%ebp)
  802980:	6a 00                	push   $0x0
  802982:	e8 43 e6 ff ff       	call   800fca <sys_page_unmap>
  802987:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80298a:	83 ec 08             	sub    $0x8,%esp
  80298d:	ff 75 f4             	pushl  -0xc(%ebp)
  802990:	6a 00                	push   $0x0
  802992:	e8 33 e6 ff ff       	call   800fca <sys_page_unmap>
  802997:	83 c4 10             	add    $0x10,%esp
  80299a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80299c:	89 d0                	mov    %edx,%eax
  80299e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029a1:	5b                   	pop    %ebx
  8029a2:	5e                   	pop    %esi
  8029a3:	5d                   	pop    %ebp
  8029a4:	c3                   	ret    

008029a5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8029a5:	55                   	push   %ebp
  8029a6:	89 e5                	mov    %esp,%ebp
  8029a8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029ae:	50                   	push   %eax
  8029af:	ff 75 08             	pushl  0x8(%ebp)
  8029b2:	e8 e6 ea ff ff       	call   80149d <fd_lookup>
  8029b7:	83 c4 10             	add    $0x10,%esp
  8029ba:	85 c0                	test   %eax,%eax
  8029bc:	78 18                	js     8029d6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8029be:	83 ec 0c             	sub    $0xc,%esp
  8029c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8029c4:	e8 6e ea ff ff       	call   801437 <fd2data>
	return _pipeisclosed(fd, p);
  8029c9:	89 c2                	mov    %eax,%edx
  8029cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029ce:	e8 21 fd ff ff       	call   8026f4 <_pipeisclosed>
  8029d3:	83 c4 10             	add    $0x10,%esp
}
  8029d6:	c9                   	leave  
  8029d7:	c3                   	ret    

008029d8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8029d8:	55                   	push   %ebp
  8029d9:	89 e5                	mov    %esp,%ebp
  8029db:	56                   	push   %esi
  8029dc:	53                   	push   %ebx
  8029dd:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8029e0:	85 f6                	test   %esi,%esi
  8029e2:	75 16                	jne    8029fa <wait+0x22>
  8029e4:	68 94 35 80 00       	push   $0x803594
  8029e9:	68 5b 34 80 00       	push   $0x80345b
  8029ee:	6a 09                	push   $0x9
  8029f0:	68 9f 35 80 00       	push   $0x80359f
  8029f5:	e8 ea da ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  8029fa:	89 f3                	mov    %esi,%ebx
  8029fc:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a02:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802a05:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802a0b:	eb 05                	jmp    802a12 <wait+0x3a>
		sys_yield();
  802a0d:	e8 14 e5 ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a12:	8b 43 48             	mov    0x48(%ebx),%eax
  802a15:	39 c6                	cmp    %eax,%esi
  802a17:	75 07                	jne    802a20 <wait+0x48>
  802a19:	8b 43 54             	mov    0x54(%ebx),%eax
  802a1c:	85 c0                	test   %eax,%eax
  802a1e:	75 ed                	jne    802a0d <wait+0x35>
		sys_yield();
}
  802a20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a23:	5b                   	pop    %ebx
  802a24:	5e                   	pop    %esi
  802a25:	5d                   	pop    %ebp
  802a26:	c3                   	ret    

00802a27 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a27:	55                   	push   %ebp
  802a28:	89 e5                	mov    %esp,%ebp
  802a2a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802a2d:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802a34:	75 2e                	jne    802a64 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802a36:	e8 cc e4 ff ff       	call   800f07 <sys_getenvid>
  802a3b:	83 ec 04             	sub    $0x4,%esp
  802a3e:	68 07 0e 00 00       	push   $0xe07
  802a43:	68 00 f0 bf ee       	push   $0xeebff000
  802a48:	50                   	push   %eax
  802a49:	e8 f7 e4 ff ff       	call   800f45 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802a4e:	e8 b4 e4 ff ff       	call   800f07 <sys_getenvid>
  802a53:	83 c4 08             	add    $0x8,%esp
  802a56:	68 6e 2a 80 00       	push   $0x802a6e
  802a5b:	50                   	push   %eax
  802a5c:	e8 2f e6 ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  802a61:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a64:	8b 45 08             	mov    0x8(%ebp),%eax
  802a67:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802a6c:	c9                   	leave  
  802a6d:	c3                   	ret    

00802a6e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a6e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a6f:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802a74:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a76:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802a79:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802a7d:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802a81:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802a84:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802a87:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802a88:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802a8b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802a8c:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802a8d:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802a91:	c3                   	ret    

00802a92 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802a92:	55                   	push   %ebp
  802a93:	89 e5                	mov    %esp,%ebp
  802a95:	56                   	push   %esi
  802a96:	53                   	push   %ebx
  802a97:	8b 75 08             	mov    0x8(%ebp),%esi
  802a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802aa0:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802aa2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802aa7:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802aaa:	83 ec 0c             	sub    $0xc,%esp
  802aad:	50                   	push   %eax
  802aae:	e8 42 e6 ff ff       	call   8010f5 <sys_ipc_recv>

	if (from_env_store != NULL)
  802ab3:	83 c4 10             	add    $0x10,%esp
  802ab6:	85 f6                	test   %esi,%esi
  802ab8:	74 14                	je     802ace <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802aba:	ba 00 00 00 00       	mov    $0x0,%edx
  802abf:	85 c0                	test   %eax,%eax
  802ac1:	78 09                	js     802acc <ipc_recv+0x3a>
  802ac3:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802ac9:	8b 52 74             	mov    0x74(%edx),%edx
  802acc:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802ace:	85 db                	test   %ebx,%ebx
  802ad0:	74 14                	je     802ae6 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  802ad7:	85 c0                	test   %eax,%eax
  802ad9:	78 09                	js     802ae4 <ipc_recv+0x52>
  802adb:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802ae1:	8b 52 78             	mov    0x78(%edx),%edx
  802ae4:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802ae6:	85 c0                	test   %eax,%eax
  802ae8:	78 08                	js     802af2 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802aea:	a1 08 50 80 00       	mov    0x805008,%eax
  802aef:	8b 40 70             	mov    0x70(%eax),%eax
}
  802af2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802af5:	5b                   	pop    %ebx
  802af6:	5e                   	pop    %esi
  802af7:	5d                   	pop    %ebp
  802af8:	c3                   	ret    

00802af9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802af9:	55                   	push   %ebp
  802afa:	89 e5                	mov    %esp,%ebp
  802afc:	57                   	push   %edi
  802afd:	56                   	push   %esi
  802afe:	53                   	push   %ebx
  802aff:	83 ec 0c             	sub    $0xc,%esp
  802b02:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802b0b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802b0d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802b12:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802b15:	ff 75 14             	pushl  0x14(%ebp)
  802b18:	53                   	push   %ebx
  802b19:	56                   	push   %esi
  802b1a:	57                   	push   %edi
  802b1b:	e8 b2 e5 ff ff       	call   8010d2 <sys_ipc_try_send>

		if (err < 0) {
  802b20:	83 c4 10             	add    $0x10,%esp
  802b23:	85 c0                	test   %eax,%eax
  802b25:	79 1e                	jns    802b45 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802b27:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b2a:	75 07                	jne    802b33 <ipc_send+0x3a>
				sys_yield();
  802b2c:	e8 f5 e3 ff ff       	call   800f26 <sys_yield>
  802b31:	eb e2                	jmp    802b15 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802b33:	50                   	push   %eax
  802b34:	68 aa 35 80 00       	push   $0x8035aa
  802b39:	6a 49                	push   $0x49
  802b3b:	68 b7 35 80 00       	push   $0x8035b7
  802b40:	e8 9f d9 ff ff       	call   8004e4 <_panic>
		}

	} while (err < 0);

}
  802b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b48:	5b                   	pop    %ebx
  802b49:	5e                   	pop    %esi
  802b4a:	5f                   	pop    %edi
  802b4b:	5d                   	pop    %ebp
  802b4c:	c3                   	ret    

00802b4d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b4d:	55                   	push   %ebp
  802b4e:	89 e5                	mov    %esp,%ebp
  802b50:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802b53:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b58:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802b5b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802b61:	8b 52 50             	mov    0x50(%edx),%edx
  802b64:	39 ca                	cmp    %ecx,%edx
  802b66:	75 0d                	jne    802b75 <ipc_find_env+0x28>
			return envs[i].env_id;
  802b68:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802b6b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802b70:	8b 40 48             	mov    0x48(%eax),%eax
  802b73:	eb 0f                	jmp    802b84 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802b75:	83 c0 01             	add    $0x1,%eax
  802b78:	3d 00 04 00 00       	cmp    $0x400,%eax
  802b7d:	75 d9                	jne    802b58 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802b84:	5d                   	pop    %ebp
  802b85:	c3                   	ret    

00802b86 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802b86:	55                   	push   %ebp
  802b87:	89 e5                	mov    %esp,%ebp
  802b89:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b8c:	89 d0                	mov    %edx,%eax
  802b8e:	c1 e8 16             	shr    $0x16,%eax
  802b91:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802b98:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b9d:	f6 c1 01             	test   $0x1,%cl
  802ba0:	74 1d                	je     802bbf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ba2:	c1 ea 0c             	shr    $0xc,%edx
  802ba5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802bac:	f6 c2 01             	test   $0x1,%dl
  802baf:	74 0e                	je     802bbf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802bb1:	c1 ea 0c             	shr    $0xc,%edx
  802bb4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802bbb:	ef 
  802bbc:	0f b7 c0             	movzwl %ax,%eax
}
  802bbf:	5d                   	pop    %ebp
  802bc0:	c3                   	ret    
  802bc1:	66 90                	xchg   %ax,%ax
  802bc3:	66 90                	xchg   %ax,%ax
  802bc5:	66 90                	xchg   %ax,%ax
  802bc7:	66 90                	xchg   %ax,%ax
  802bc9:	66 90                	xchg   %ax,%ax
  802bcb:	66 90                	xchg   %ax,%ax
  802bcd:	66 90                	xchg   %ax,%ax
  802bcf:	90                   	nop

00802bd0 <__udivdi3>:
  802bd0:	55                   	push   %ebp
  802bd1:	57                   	push   %edi
  802bd2:	56                   	push   %esi
  802bd3:	53                   	push   %ebx
  802bd4:	83 ec 1c             	sub    $0x1c,%esp
  802bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802be7:	85 f6                	test   %esi,%esi
  802be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802bed:	89 ca                	mov    %ecx,%edx
  802bef:	89 f8                	mov    %edi,%eax
  802bf1:	75 3d                	jne    802c30 <__udivdi3+0x60>
  802bf3:	39 cf                	cmp    %ecx,%edi
  802bf5:	0f 87 c5 00 00 00    	ja     802cc0 <__udivdi3+0xf0>
  802bfb:	85 ff                	test   %edi,%edi
  802bfd:	89 fd                	mov    %edi,%ebp
  802bff:	75 0b                	jne    802c0c <__udivdi3+0x3c>
  802c01:	b8 01 00 00 00       	mov    $0x1,%eax
  802c06:	31 d2                	xor    %edx,%edx
  802c08:	f7 f7                	div    %edi
  802c0a:	89 c5                	mov    %eax,%ebp
  802c0c:	89 c8                	mov    %ecx,%eax
  802c0e:	31 d2                	xor    %edx,%edx
  802c10:	f7 f5                	div    %ebp
  802c12:	89 c1                	mov    %eax,%ecx
  802c14:	89 d8                	mov    %ebx,%eax
  802c16:	89 cf                	mov    %ecx,%edi
  802c18:	f7 f5                	div    %ebp
  802c1a:	89 c3                	mov    %eax,%ebx
  802c1c:	89 d8                	mov    %ebx,%eax
  802c1e:	89 fa                	mov    %edi,%edx
  802c20:	83 c4 1c             	add    $0x1c,%esp
  802c23:	5b                   	pop    %ebx
  802c24:	5e                   	pop    %esi
  802c25:	5f                   	pop    %edi
  802c26:	5d                   	pop    %ebp
  802c27:	c3                   	ret    
  802c28:	90                   	nop
  802c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c30:	39 ce                	cmp    %ecx,%esi
  802c32:	77 74                	ja     802ca8 <__udivdi3+0xd8>
  802c34:	0f bd fe             	bsr    %esi,%edi
  802c37:	83 f7 1f             	xor    $0x1f,%edi
  802c3a:	0f 84 98 00 00 00    	je     802cd8 <__udivdi3+0x108>
  802c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  802c45:	89 f9                	mov    %edi,%ecx
  802c47:	89 c5                	mov    %eax,%ebp
  802c49:	29 fb                	sub    %edi,%ebx
  802c4b:	d3 e6                	shl    %cl,%esi
  802c4d:	89 d9                	mov    %ebx,%ecx
  802c4f:	d3 ed                	shr    %cl,%ebp
  802c51:	89 f9                	mov    %edi,%ecx
  802c53:	d3 e0                	shl    %cl,%eax
  802c55:	09 ee                	or     %ebp,%esi
  802c57:	89 d9                	mov    %ebx,%ecx
  802c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c5d:	89 d5                	mov    %edx,%ebp
  802c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c63:	d3 ed                	shr    %cl,%ebp
  802c65:	89 f9                	mov    %edi,%ecx
  802c67:	d3 e2                	shl    %cl,%edx
  802c69:	89 d9                	mov    %ebx,%ecx
  802c6b:	d3 e8                	shr    %cl,%eax
  802c6d:	09 c2                	or     %eax,%edx
  802c6f:	89 d0                	mov    %edx,%eax
  802c71:	89 ea                	mov    %ebp,%edx
  802c73:	f7 f6                	div    %esi
  802c75:	89 d5                	mov    %edx,%ebp
  802c77:	89 c3                	mov    %eax,%ebx
  802c79:	f7 64 24 0c          	mull   0xc(%esp)
  802c7d:	39 d5                	cmp    %edx,%ebp
  802c7f:	72 10                	jb     802c91 <__udivdi3+0xc1>
  802c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  802c85:	89 f9                	mov    %edi,%ecx
  802c87:	d3 e6                	shl    %cl,%esi
  802c89:	39 c6                	cmp    %eax,%esi
  802c8b:	73 07                	jae    802c94 <__udivdi3+0xc4>
  802c8d:	39 d5                	cmp    %edx,%ebp
  802c8f:	75 03                	jne    802c94 <__udivdi3+0xc4>
  802c91:	83 eb 01             	sub    $0x1,%ebx
  802c94:	31 ff                	xor    %edi,%edi
  802c96:	89 d8                	mov    %ebx,%eax
  802c98:	89 fa                	mov    %edi,%edx
  802c9a:	83 c4 1c             	add    $0x1c,%esp
  802c9d:	5b                   	pop    %ebx
  802c9e:	5e                   	pop    %esi
  802c9f:	5f                   	pop    %edi
  802ca0:	5d                   	pop    %ebp
  802ca1:	c3                   	ret    
  802ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ca8:	31 ff                	xor    %edi,%edi
  802caa:	31 db                	xor    %ebx,%ebx
  802cac:	89 d8                	mov    %ebx,%eax
  802cae:	89 fa                	mov    %edi,%edx
  802cb0:	83 c4 1c             	add    $0x1c,%esp
  802cb3:	5b                   	pop    %ebx
  802cb4:	5e                   	pop    %esi
  802cb5:	5f                   	pop    %edi
  802cb6:	5d                   	pop    %ebp
  802cb7:	c3                   	ret    
  802cb8:	90                   	nop
  802cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cc0:	89 d8                	mov    %ebx,%eax
  802cc2:	f7 f7                	div    %edi
  802cc4:	31 ff                	xor    %edi,%edi
  802cc6:	89 c3                	mov    %eax,%ebx
  802cc8:	89 d8                	mov    %ebx,%eax
  802cca:	89 fa                	mov    %edi,%edx
  802ccc:	83 c4 1c             	add    $0x1c,%esp
  802ccf:	5b                   	pop    %ebx
  802cd0:	5e                   	pop    %esi
  802cd1:	5f                   	pop    %edi
  802cd2:	5d                   	pop    %ebp
  802cd3:	c3                   	ret    
  802cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802cd8:	39 ce                	cmp    %ecx,%esi
  802cda:	72 0c                	jb     802ce8 <__udivdi3+0x118>
  802cdc:	31 db                	xor    %ebx,%ebx
  802cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802ce2:	0f 87 34 ff ff ff    	ja     802c1c <__udivdi3+0x4c>
  802ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  802ced:	e9 2a ff ff ff       	jmp    802c1c <__udivdi3+0x4c>
  802cf2:	66 90                	xchg   %ax,%ax
  802cf4:	66 90                	xchg   %ax,%ax
  802cf6:	66 90                	xchg   %ax,%ax
  802cf8:	66 90                	xchg   %ax,%ax
  802cfa:	66 90                	xchg   %ax,%ax
  802cfc:	66 90                	xchg   %ax,%ax
  802cfe:	66 90                	xchg   %ax,%ax

00802d00 <__umoddi3>:
  802d00:	55                   	push   %ebp
  802d01:	57                   	push   %edi
  802d02:	56                   	push   %esi
  802d03:	53                   	push   %ebx
  802d04:	83 ec 1c             	sub    $0x1c,%esp
  802d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802d17:	85 d2                	test   %edx,%edx
  802d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d21:	89 f3                	mov    %esi,%ebx
  802d23:	89 3c 24             	mov    %edi,(%esp)
  802d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d2a:	75 1c                	jne    802d48 <__umoddi3+0x48>
  802d2c:	39 f7                	cmp    %esi,%edi
  802d2e:	76 50                	jbe    802d80 <__umoddi3+0x80>
  802d30:	89 c8                	mov    %ecx,%eax
  802d32:	89 f2                	mov    %esi,%edx
  802d34:	f7 f7                	div    %edi
  802d36:	89 d0                	mov    %edx,%eax
  802d38:	31 d2                	xor    %edx,%edx
  802d3a:	83 c4 1c             	add    $0x1c,%esp
  802d3d:	5b                   	pop    %ebx
  802d3e:	5e                   	pop    %esi
  802d3f:	5f                   	pop    %edi
  802d40:	5d                   	pop    %ebp
  802d41:	c3                   	ret    
  802d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d48:	39 f2                	cmp    %esi,%edx
  802d4a:	89 d0                	mov    %edx,%eax
  802d4c:	77 52                	ja     802da0 <__umoddi3+0xa0>
  802d4e:	0f bd ea             	bsr    %edx,%ebp
  802d51:	83 f5 1f             	xor    $0x1f,%ebp
  802d54:	75 5a                	jne    802db0 <__umoddi3+0xb0>
  802d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802d5a:	0f 82 e0 00 00 00    	jb     802e40 <__umoddi3+0x140>
  802d60:	39 0c 24             	cmp    %ecx,(%esp)
  802d63:	0f 86 d7 00 00 00    	jbe    802e40 <__umoddi3+0x140>
  802d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  802d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802d71:	83 c4 1c             	add    $0x1c,%esp
  802d74:	5b                   	pop    %ebx
  802d75:	5e                   	pop    %esi
  802d76:	5f                   	pop    %edi
  802d77:	5d                   	pop    %ebp
  802d78:	c3                   	ret    
  802d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d80:	85 ff                	test   %edi,%edi
  802d82:	89 fd                	mov    %edi,%ebp
  802d84:	75 0b                	jne    802d91 <__umoddi3+0x91>
  802d86:	b8 01 00 00 00       	mov    $0x1,%eax
  802d8b:	31 d2                	xor    %edx,%edx
  802d8d:	f7 f7                	div    %edi
  802d8f:	89 c5                	mov    %eax,%ebp
  802d91:	89 f0                	mov    %esi,%eax
  802d93:	31 d2                	xor    %edx,%edx
  802d95:	f7 f5                	div    %ebp
  802d97:	89 c8                	mov    %ecx,%eax
  802d99:	f7 f5                	div    %ebp
  802d9b:	89 d0                	mov    %edx,%eax
  802d9d:	eb 99                	jmp    802d38 <__umoddi3+0x38>
  802d9f:	90                   	nop
  802da0:	89 c8                	mov    %ecx,%eax
  802da2:	89 f2                	mov    %esi,%edx
  802da4:	83 c4 1c             	add    $0x1c,%esp
  802da7:	5b                   	pop    %ebx
  802da8:	5e                   	pop    %esi
  802da9:	5f                   	pop    %edi
  802daa:	5d                   	pop    %ebp
  802dab:	c3                   	ret    
  802dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802db0:	8b 34 24             	mov    (%esp),%esi
  802db3:	bf 20 00 00 00       	mov    $0x20,%edi
  802db8:	89 e9                	mov    %ebp,%ecx
  802dba:	29 ef                	sub    %ebp,%edi
  802dbc:	d3 e0                	shl    %cl,%eax
  802dbe:	89 f9                	mov    %edi,%ecx
  802dc0:	89 f2                	mov    %esi,%edx
  802dc2:	d3 ea                	shr    %cl,%edx
  802dc4:	89 e9                	mov    %ebp,%ecx
  802dc6:	09 c2                	or     %eax,%edx
  802dc8:	89 d8                	mov    %ebx,%eax
  802dca:	89 14 24             	mov    %edx,(%esp)
  802dcd:	89 f2                	mov    %esi,%edx
  802dcf:	d3 e2                	shl    %cl,%edx
  802dd1:	89 f9                	mov    %edi,%ecx
  802dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802ddb:	d3 e8                	shr    %cl,%eax
  802ddd:	89 e9                	mov    %ebp,%ecx
  802ddf:	89 c6                	mov    %eax,%esi
  802de1:	d3 e3                	shl    %cl,%ebx
  802de3:	89 f9                	mov    %edi,%ecx
  802de5:	89 d0                	mov    %edx,%eax
  802de7:	d3 e8                	shr    %cl,%eax
  802de9:	89 e9                	mov    %ebp,%ecx
  802deb:	09 d8                	or     %ebx,%eax
  802ded:	89 d3                	mov    %edx,%ebx
  802def:	89 f2                	mov    %esi,%edx
  802df1:	f7 34 24             	divl   (%esp)
  802df4:	89 d6                	mov    %edx,%esi
  802df6:	d3 e3                	shl    %cl,%ebx
  802df8:	f7 64 24 04          	mull   0x4(%esp)
  802dfc:	39 d6                	cmp    %edx,%esi
  802dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802e02:	89 d1                	mov    %edx,%ecx
  802e04:	89 c3                	mov    %eax,%ebx
  802e06:	72 08                	jb     802e10 <__umoddi3+0x110>
  802e08:	75 11                	jne    802e1b <__umoddi3+0x11b>
  802e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802e0e:	73 0b                	jae    802e1b <__umoddi3+0x11b>
  802e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  802e14:	1b 14 24             	sbb    (%esp),%edx
  802e17:	89 d1                	mov    %edx,%ecx
  802e19:	89 c3                	mov    %eax,%ebx
  802e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802e1f:	29 da                	sub    %ebx,%edx
  802e21:	19 ce                	sbb    %ecx,%esi
  802e23:	89 f9                	mov    %edi,%ecx
  802e25:	89 f0                	mov    %esi,%eax
  802e27:	d3 e0                	shl    %cl,%eax
  802e29:	89 e9                	mov    %ebp,%ecx
  802e2b:	d3 ea                	shr    %cl,%edx
  802e2d:	89 e9                	mov    %ebp,%ecx
  802e2f:	d3 ee                	shr    %cl,%esi
  802e31:	09 d0                	or     %edx,%eax
  802e33:	89 f2                	mov    %esi,%edx
  802e35:	83 c4 1c             	add    $0x1c,%esp
  802e38:	5b                   	pop    %ebx
  802e39:	5e                   	pop    %esi
  802e3a:	5f                   	pop    %edi
  802e3b:	5d                   	pop    %ebp
  802e3c:	c3                   	ret    
  802e3d:	8d 76 00             	lea    0x0(%esi),%esi
  802e40:	29 f9                	sub    %edi,%ecx
  802e42:	19 d6                	sbb    %edx,%esi
  802e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802e4c:	e9 18 ff ff ff       	jmp    802d69 <__umoddi3+0x69>
