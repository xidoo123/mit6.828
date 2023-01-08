
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 bd 0d 00 00       	call   800e01 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 7d 11 00 00       	call   8011d0 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 c0 24 80 00       	push   $0x8024c0
  800065:	6a 0f                	push   $0xf
  800067:	68 cd 24 80 00       	push   $0x8024cd
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 dc 24 80 00       	push   $0x8024dc
  80007b:	6a 11                	push   $0x11
  80007d:	68 cd 24 80 00       	push   $0x8024cd
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 8d 11 00 00       	call   801220 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 f6 24 80 00       	push   $0x8024f6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 cd 24 80 00       	push   $0x8024cd
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 fe 24 80 00       	push   $0x8024fe
  8000b4:	e8 38 08 00 00       	call   8008f1 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 0c 25 80 00       	push   $0x80250c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 41 18 00 00       	call   801911 <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 10 25 80 00       	push   $0x802510
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 2d 18 00 00       	call   801911 <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 28 25 80 00       	push   $0x802528
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 17 09 00 00       	call   800a1d <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 6b 0a 00 00       	call   800baf <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 16 0c 00 00       	call   800d64 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 87 0c 00 00       	call   800e01 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 03 0c 00 00       	call   800d82 <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 ae 0b 00 00       	call   800d64 <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 3e 11 00 00       	call   80130c <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 ae 0e 00 00       	call   8010a6 <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 36 0e 00 00       	call   801057 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 e4 0b 00 00       	call   800e20 <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 cd 0d 00 00       	call   801030 <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800277:	e8 66 0b 00 00       	call   800de2 <sys_getenvid>
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800289:	a3 08 44 80 00       	mov    %eax,0x804408

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7e 07                	jle    800299 <libmain+0x2d>
		binaryname = argv[0];
  800292:	8b 06                	mov    (%esi),%eax
  800294:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	e8 90 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 0a 00 00 00       	call   8002b2 <exit>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b8:	e8 3e 0f 00 00       	call   8011fb <close_all>
	sys_env_destroy(0);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	6a 00                	push   $0x0
  8002c2:	e8 da 0a 00 00       	call   800da1 <sys_env_destroy>
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002da:	e8 03 0b 00 00       	call   800de2 <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	68 40 25 80 00       	push   $0x802540
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 26 25 80 00 	movl   $0x802526,(%esp)
  800307:	e8 99 00 00 00       	call   8003a5 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>

00800312 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	53                   	push   %ebx
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031c:	8b 13                	mov    (%ebx),%edx
  80031e:	8d 42 01             	lea    0x1(%edx),%eax
  800321:	89 03                	mov    %eax,(%ebx)
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 22 0a 00 00       	call   800d64 <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800364:	00 00 00 
	b.cnt = 0;
  800367:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037d:	50                   	push   %eax
  80037e:	68 12 03 80 00       	push   $0x800312
  800383:	e8 54 01 00 00       	call   8004dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	83 c4 08             	add    $0x8,%esp
  80038b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800391:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800397:	50                   	push   %eax
  800398:	e8 c7 09 00 00       	call   800d64 <sys_cputs>

	return b.cnt;
}
  80039d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ae:	50                   	push   %eax
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 9d ff ff ff       	call   800354 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 1c             	sub    $0x1c,%esp
  8003c2:	89 c7                	mov    %eax,%edi
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003e0:	39 d3                	cmp    %edx,%ebx
  8003e2:	72 05                	jb     8003e9 <printnum+0x30>
  8003e4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e7:	77 45                	ja     80042e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e9:	83 ec 0c             	sub    $0xc,%esp
  8003ec:	ff 75 18             	pushl  0x18(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003f5:	53                   	push   %ebx
  8003f6:	ff 75 10             	pushl  0x10(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 23 1e 00 00       	call   802230 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	89 f8                	mov    %edi,%eax
  800416:	e8 9e ff ff ff       	call   8003b9 <printnum>
  80041b:	83 c4 20             	add    $0x20,%esp
  80041e:	eb 18                	jmp    800438 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	ff 75 18             	pushl  0x18(%ebp)
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	eb 03                	jmp    800431 <printnum+0x78>
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	83 eb 01             	sub    $0x1,%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	7f e8                	jg     800420 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	56                   	push   %esi
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 10 1f 00 00       	call   802360 <__umoddi3>
  800450:	83 c4 14             	add    $0x14,%esp
  800453:	0f be 80 63 25 80 00 	movsbl 0x802563(%eax),%eax
  80045a:	50                   	push   %eax
  80045b:	ff d7                	call   *%edi
}
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800463:	5b                   	pop    %ebx
  800464:	5e                   	pop    %esi
  800465:	5f                   	pop    %edi
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046b:	83 fa 01             	cmp    $0x1,%edx
  80046e:	7e 0e                	jle    80047e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 08             	lea    0x8(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	8b 52 04             	mov    0x4(%edx),%edx
  80047c:	eb 22                	jmp    8004a0 <getuint+0x38>
	else if (lflag)
  80047e:	85 d2                	test   %edx,%edx
  800480:	74 10                	je     800492 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800482:	8b 10                	mov    (%eax),%edx
  800484:	8d 4a 04             	lea    0x4(%edx),%ecx
  800487:	89 08                	mov    %ecx,(%eax)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	ba 00 00 00 00       	mov    $0x0,%edx
  800490:	eb 0e                	jmp    8004a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800492:	8b 10                	mov    (%eax),%edx
  800494:	8d 4a 04             	lea    0x4(%edx),%ecx
  800497:	89 08                	mov    %ecx,(%eax)
  800499:	8b 02                	mov    (%edx),%eax
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b1:	73 0a                	jae    8004bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bb:	88 02                	mov    %al,(%edx)
}
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c8:	50                   	push   %eax
  8004c9:	ff 75 10             	pushl  0x10(%ebp)
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 05 00 00 00       	call   8004dc <vprintfmt>
	va_end(ap);
}
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    

008004dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 2c             	sub    $0x2c,%esp
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ee:	eb 12                	jmp    800502 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	0f 84 89 03 00 00    	je     800881 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	50                   	push   %eax
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	83 f8 25             	cmp    $0x25,%eax
  80050c:	75 e2                	jne    8004f0 <vprintfmt+0x14>
  80050e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800512:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800519:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800520:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800527:	ba 00 00 00 00       	mov    $0x0,%edx
  80052c:	eb 07                	jmp    800535 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800531:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8d 47 01             	lea    0x1(%edi),%eax
  800538:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053b:	0f b6 07             	movzbl (%edi),%eax
  80053e:	0f b6 c8             	movzbl %al,%ecx
  800541:	83 e8 23             	sub    $0x23,%eax
  800544:	3c 55                	cmp    $0x55,%al
  800546:	0f 87 1a 03 00 00    	ja     800866 <vprintfmt+0x38a>
  80054c:	0f b6 c0             	movzbl %al,%eax
  80054f:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800559:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80055d:	eb d6                	jmp    800535 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	b8 00 00 00 00       	mov    $0x0,%eax
  800567:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80056a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80056d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800571:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800574:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800577:	83 fa 09             	cmp    $0x9,%edx
  80057a:	77 39                	ja     8005b5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80057c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80057f:	eb e9                	jmp    80056a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 48 04             	lea    0x4(%eax),%ecx
  800587:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800592:	eb 27                	jmp    8005bb <vprintfmt+0xdf>
  800594:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059e:	0f 49 c8             	cmovns %eax,%ecx
  8005a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	eb 8c                	jmp    800535 <vprintfmt+0x59>
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ac:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b3:	eb 80                	jmp    800535 <vprintfmt+0x59>
  8005b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bf:	0f 89 70 ff ff ff    	jns    800535 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005d2:	e9 5e ff ff ff       	jmp    800535 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005dd:	e9 53 ff ff ff       	jmp    800535 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	ff 30                	pushl  (%eax)
  8005f1:	ff d6                	call   *%esi
			break;
  8005f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f9:	e9 04 ff ff ff       	jmp    800502 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	99                   	cltd   
  80060a:	31 d0                	xor    %edx,%eax
  80060c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060e:	83 f8 0f             	cmp    $0xf,%eax
  800611:	7f 0b                	jg     80061e <vprintfmt+0x142>
  800613:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  80061a:	85 d2                	test   %edx,%edx
  80061c:	75 18                	jne    800636 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80061e:	50                   	push   %eax
  80061f:	68 7b 25 80 00       	push   $0x80257b
  800624:	53                   	push   %ebx
  800625:	56                   	push   %esi
  800626:	e8 94 fe ff ff       	call   8004bf <printfmt>
  80062b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800631:	e9 cc fe ff ff       	jmp    800502 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800636:	52                   	push   %edx
  800637:	68 49 29 80 00       	push   $0x802949
  80063c:	53                   	push   %ebx
  80063d:	56                   	push   %esi
  80063e:	e8 7c fe ff ff       	call   8004bf <printfmt>
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800649:	e9 b4 fe ff ff       	jmp    800502 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800659:	85 ff                	test   %edi,%edi
  80065b:	b8 74 25 80 00       	mov    $0x802574,%eax
  800660:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800663:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800667:	0f 8e 94 00 00 00    	jle    800701 <vprintfmt+0x225>
  80066d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800671:	0f 84 98 00 00 00    	je     80070f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	ff 75 d0             	pushl  -0x30(%ebp)
  80067d:	57                   	push   %edi
  80067e:	e8 79 03 00 00       	call   8009fc <strnlen>
  800683:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800686:	29 c1                	sub    %eax,%ecx
  800688:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80068b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800692:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800695:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800698:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	eb 0f                	jmp    8006ab <vprintfmt+0x1cf>
					putch(padc, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a5:	83 ef 01             	sub    $0x1,%edi
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	85 ff                	test   %edi,%edi
  8006ad:	7f ed                	jg     80069c <vprintfmt+0x1c0>
  8006af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	0f 49 c1             	cmovns %ecx,%eax
  8006bf:	29 c1                	sub    %eax,%ecx
  8006c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ca:	89 cb                	mov    %ecx,%ebx
  8006cc:	eb 4d                	jmp    80071b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d2:	74 1b                	je     8006ef <vprintfmt+0x213>
  8006d4:	0f be c0             	movsbl %al,%eax
  8006d7:	83 e8 20             	sub    $0x20,%eax
  8006da:	83 f8 5e             	cmp    $0x5e,%eax
  8006dd:	76 10                	jbe    8006ef <vprintfmt+0x213>
					putch('?', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	6a 3f                	push   $0x3f
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 0d                	jmp    8006fc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	52                   	push   %edx
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	83 eb 01             	sub    $0x1,%ebx
  8006ff:	eb 1a                	jmp    80071b <vprintfmt+0x23f>
  800701:	89 75 08             	mov    %esi,0x8(%ebp)
  800704:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800707:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070d:	eb 0c                	jmp    80071b <vprintfmt+0x23f>
  80070f:	89 75 08             	mov    %esi,0x8(%ebp)
  800712:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800715:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800718:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071b:	83 c7 01             	add    $0x1,%edi
  80071e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800722:	0f be d0             	movsbl %al,%edx
  800725:	85 d2                	test   %edx,%edx
  800727:	74 23                	je     80074c <vprintfmt+0x270>
  800729:	85 f6                	test   %esi,%esi
  80072b:	78 a1                	js     8006ce <vprintfmt+0x1f2>
  80072d:	83 ee 01             	sub    $0x1,%esi
  800730:	79 9c                	jns    8006ce <vprintfmt+0x1f2>
  800732:	89 df                	mov    %ebx,%edi
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073a:	eb 18                	jmp    800754 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 20                	push   $0x20
  800742:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 ef 01             	sub    $0x1,%edi
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 08                	jmp    800754 <vprintfmt+0x278>
  80074c:	89 df                	mov    %ebx,%edi
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800754:	85 ff                	test   %edi,%edi
  800756:	7f e4                	jg     80073c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 a2 fd ff ff       	jmp    800502 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800760:	83 fa 01             	cmp    $0x1,%edx
  800763:	7e 16                	jle    80077b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 50 08             	lea    0x8(%eax),%edx
  80076b:	89 55 14             	mov    %edx,0x14(%ebp)
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800776:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800779:	eb 32                	jmp    8007ad <vprintfmt+0x2d1>
	else if (lflag)
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 18                	je     800797 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078d:	89 c1                	mov    %eax,%ecx
  80078f:	c1 f9 1f             	sar    $0x1f,%ecx
  800792:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800795:	eb 16                	jmp    8007ad <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 04             	lea    0x4(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a5:	89 c1                	mov    %eax,%ecx
  8007a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007bc:	79 74                	jns    800832 <vprintfmt+0x356>
				putch('-', putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	6a 2d                	push   $0x2d
  8007c4:	ff d6                	call   *%esi
				num = -(long long) num;
  8007c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007cc:	f7 d8                	neg    %eax
  8007ce:	83 d2 00             	adc    $0x0,%edx
  8007d1:	f7 da                	neg    %edx
  8007d3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007db:	eb 55                	jmp    800832 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e0:	e8 83 fc ff ff       	call   800468 <getuint>
			base = 10;
  8007e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007ea:	eb 46                	jmp    800832 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ef:	e8 74 fc ff ff       	call   800468 <getuint>
			base = 8;
  8007f4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007f9:	eb 37                	jmp    800832 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	6a 30                	push   $0x30
  800801:	ff d6                	call   *%esi
			putch('x', putdat);
  800803:	83 c4 08             	add    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	6a 78                	push   $0x78
  800809:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 50 04             	lea    0x4(%eax),%edx
  800811:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800814:	8b 00                	mov    (%eax),%eax
  800816:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80081b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80081e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800823:	eb 0d                	jmp    800832 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
  800828:	e8 3b fc ff ff       	call   800468 <getuint>
			base = 16;
  80082d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800832:	83 ec 0c             	sub    $0xc,%esp
  800835:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800839:	57                   	push   %edi
  80083a:	ff 75 e0             	pushl  -0x20(%ebp)
  80083d:	51                   	push   %ecx
  80083e:	52                   	push   %edx
  80083f:	50                   	push   %eax
  800840:	89 da                	mov    %ebx,%edx
  800842:	89 f0                	mov    %esi,%eax
  800844:	e8 70 fb ff ff       	call   8003b9 <printnum>
			break;
  800849:	83 c4 20             	add    $0x20,%esp
  80084c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80084f:	e9 ae fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	53                   	push   %ebx
  800858:	51                   	push   %ecx
  800859:	ff d6                	call   *%esi
			break;
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800861:	e9 9c fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	53                   	push   %ebx
  80086a:	6a 25                	push   $0x25
  80086c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	eb 03                	jmp    800876 <vprintfmt+0x39a>
  800873:	83 ef 01             	sub    $0x1,%edi
  800876:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80087a:	75 f7                	jne    800873 <vprintfmt+0x397>
  80087c:	e9 81 fc ff ff       	jmp    800502 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800881:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5f                   	pop    %edi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 18             	sub    $0x18,%esp
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800895:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800898:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	74 26                	je     8008d0 <vsnprintf+0x47>
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	7e 22                	jle    8008d0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ae:	ff 75 14             	pushl  0x14(%ebp)
  8008b1:	ff 75 10             	pushl  0x10(%ebp)
  8008b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b7:	50                   	push   %eax
  8008b8:	68 a2 04 80 00       	push   $0x8004a2
  8008bd:	e8 1a fc ff ff       	call   8004dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	eb 05                	jmp    8008d5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e0:	50                   	push   %eax
  8008e1:	ff 75 10             	pushl  0x10(%ebp)
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	ff 75 08             	pushl  0x8(%ebp)
  8008ea:	e8 9a ff ff ff       	call   800889 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	83 ec 0c             	sub    $0xc,%esp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	74 13                	je     800914 <readline+0x23>
		fprintf(1, "%s", prompt);
  800901:	83 ec 04             	sub    $0x4,%esp
  800904:	50                   	push   %eax
  800905:	68 49 29 80 00       	push   $0x802949
  80090a:	6a 01                	push   $0x1
  80090c:	e8 00 10 00 00       	call   801911 <fprintf>
  800911:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800914:	83 ec 0c             	sub    $0xc,%esp
  800917:	6a 00                	push   $0x0
  800919:	e8 c8 f8 ff ff       	call   8001e6 <iscons>
  80091e:	89 c7                	mov    %eax,%edi
  800920:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800923:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800928:	e8 8e f8 ff ff       	call   8001bb <getchar>
  80092d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80092f:	85 c0                	test   %eax,%eax
  800931:	79 29                	jns    80095c <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800938:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80093b:	0f 84 9b 00 00 00    	je     8009dc <readline+0xeb>
				cprintf("read error: %e\n", c);
  800941:	83 ec 08             	sub    $0x8,%esp
  800944:	53                   	push   %ebx
  800945:	68 5f 28 80 00       	push   $0x80285f
  80094a:	e8 56 fa ff ff       	call   8003a5 <cprintf>
  80094f:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
  800957:	e9 80 00 00 00       	jmp    8009dc <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80095c:	83 f8 08             	cmp    $0x8,%eax
  80095f:	0f 94 c2             	sete   %dl
  800962:	83 f8 7f             	cmp    $0x7f,%eax
  800965:	0f 94 c0             	sete   %al
  800968:	08 c2                	or     %al,%dl
  80096a:	74 1a                	je     800986 <readline+0x95>
  80096c:	85 f6                	test   %esi,%esi
  80096e:	7e 16                	jle    800986 <readline+0x95>
			if (echoing)
  800970:	85 ff                	test   %edi,%edi
  800972:	74 0d                	je     800981 <readline+0x90>
				cputchar('\b');
  800974:	83 ec 0c             	sub    $0xc,%esp
  800977:	6a 08                	push   $0x8
  800979:	e8 21 f8 ff ff       	call   80019f <cputchar>
  80097e:	83 c4 10             	add    $0x10,%esp
			i--;
  800981:	83 ee 01             	sub    $0x1,%esi
  800984:	eb a2                	jmp    800928 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800986:	83 fb 1f             	cmp    $0x1f,%ebx
  800989:	7e 26                	jle    8009b1 <readline+0xc0>
  80098b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800991:	7f 1e                	jg     8009b1 <readline+0xc0>
			if (echoing)
  800993:	85 ff                	test   %edi,%edi
  800995:	74 0c                	je     8009a3 <readline+0xb2>
				cputchar(c);
  800997:	83 ec 0c             	sub    $0xc,%esp
  80099a:	53                   	push   %ebx
  80099b:	e8 ff f7 ff ff       	call   80019f <cputchar>
  8009a0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009a3:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009a9:	8d 76 01             	lea    0x1(%esi),%esi
  8009ac:	e9 77 ff ff ff       	jmp    800928 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009b1:	83 fb 0a             	cmp    $0xa,%ebx
  8009b4:	74 09                	je     8009bf <readline+0xce>
  8009b6:	83 fb 0d             	cmp    $0xd,%ebx
  8009b9:	0f 85 69 ff ff ff    	jne    800928 <readline+0x37>
			if (echoing)
  8009bf:	85 ff                	test   %edi,%edi
  8009c1:	74 0d                	je     8009d0 <readline+0xdf>
				cputchar('\n');
  8009c3:	83 ec 0c             	sub    $0xc,%esp
  8009c6:	6a 0a                	push   $0xa
  8009c8:	e8 d2 f7 ff ff       	call   80019f <cputchar>
  8009cd:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009d0:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009d7:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  8009dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ef:	eb 03                	jmp    8009f4 <strlen+0x10>
		n++;
  8009f1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f8:	75 f7                	jne    8009f1 <strlen+0xd>
		n++;
	return n;
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a05:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0a:	eb 03                	jmp    800a0f <strnlen+0x13>
		n++;
  800a0c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0f:	39 c2                	cmp    %eax,%edx
  800a11:	74 08                	je     800a1b <strnlen+0x1f>
  800a13:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a17:	75 f3                	jne    800a0c <strnlen+0x10>
  800a19:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	53                   	push   %ebx
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	83 c2 01             	add    $0x1,%edx
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a33:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a36:	84 db                	test   %bl,%bl
  800a38:	75 ef                	jne    800a29 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	53                   	push   %ebx
  800a41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a44:	53                   	push   %ebx
  800a45:	e8 9a ff ff ff       	call   8009e4 <strlen>
  800a4a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a4d:	ff 75 0c             	pushl  0xc(%ebp)
  800a50:	01 d8                	add    %ebx,%eax
  800a52:	50                   	push   %eax
  800a53:	e8 c5 ff ff ff       	call   800a1d <strcpy>
	return dst;
}
  800a58:	89 d8                	mov    %ebx,%eax
  800a5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 75 08             	mov    0x8(%ebp),%esi
  800a67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a6f:	89 f2                	mov    %esi,%edx
  800a71:	eb 0f                	jmp    800a82 <strncpy+0x23>
		*dst++ = *src;
  800a73:	83 c2 01             	add    $0x1,%edx
  800a76:	0f b6 01             	movzbl (%ecx),%eax
  800a79:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a7c:	80 39 01             	cmpb   $0x1,(%ecx)
  800a7f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a82:	39 da                	cmp    %ebx,%edx
  800a84:	75 ed                	jne    800a73 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a86:	89 f0                	mov    %esi,%eax
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 75 08             	mov    0x8(%ebp),%esi
  800a94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a97:	8b 55 10             	mov    0x10(%ebp),%edx
  800a9a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a9c:	85 d2                	test   %edx,%edx
  800a9e:	74 21                	je     800ac1 <strlcpy+0x35>
  800aa0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aa4:	89 f2                	mov    %esi,%edx
  800aa6:	eb 09                	jmp    800ab1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aa8:	83 c2 01             	add    $0x1,%edx
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab1:	39 c2                	cmp    %eax,%edx
  800ab3:	74 09                	je     800abe <strlcpy+0x32>
  800ab5:	0f b6 19             	movzbl (%ecx),%ebx
  800ab8:	84 db                	test   %bl,%bl
  800aba:	75 ec                	jne    800aa8 <strlcpy+0x1c>
  800abc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800abe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac1:	29 f0                	sub    %esi,%eax
}
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad0:	eb 06                	jmp    800ad8 <strcmp+0x11>
		p++, q++;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ad8:	0f b6 01             	movzbl (%ecx),%eax
  800adb:	84 c0                	test   %al,%al
  800add:	74 04                	je     800ae3 <strcmp+0x1c>
  800adf:	3a 02                	cmp    (%edx),%al
  800ae1:	74 ef                	je     800ad2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae3:	0f b6 c0             	movzbl %al,%eax
  800ae6:	0f b6 12             	movzbl (%edx),%edx
  800ae9:	29 d0                	sub    %edx,%eax
}
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	53                   	push   %ebx
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800afc:	eb 06                	jmp    800b04 <strncmp+0x17>
		n--, p++, q++;
  800afe:	83 c0 01             	add    $0x1,%eax
  800b01:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b04:	39 d8                	cmp    %ebx,%eax
  800b06:	74 15                	je     800b1d <strncmp+0x30>
  800b08:	0f b6 08             	movzbl (%eax),%ecx
  800b0b:	84 c9                	test   %cl,%cl
  800b0d:	74 04                	je     800b13 <strncmp+0x26>
  800b0f:	3a 0a                	cmp    (%edx),%cl
  800b11:	74 eb                	je     800afe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b13:	0f b6 00             	movzbl (%eax),%eax
  800b16:	0f b6 12             	movzbl (%edx),%edx
  800b19:	29 d0                	sub    %edx,%eax
  800b1b:	eb 05                	jmp    800b22 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b2f:	eb 07                	jmp    800b38 <strchr+0x13>
		if (*s == c)
  800b31:	38 ca                	cmp    %cl,%dl
  800b33:	74 0f                	je     800b44 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b35:	83 c0 01             	add    $0x1,%eax
  800b38:	0f b6 10             	movzbl (%eax),%edx
  800b3b:	84 d2                	test   %dl,%dl
  800b3d:	75 f2                	jne    800b31 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b50:	eb 03                	jmp    800b55 <strfind+0xf>
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b58:	38 ca                	cmp    %cl,%dl
  800b5a:	74 04                	je     800b60 <strfind+0x1a>
  800b5c:	84 d2                	test   %dl,%dl
  800b5e:	75 f2                	jne    800b52 <strfind+0xc>
			break;
	return (char *) s;
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b6e:	85 c9                	test   %ecx,%ecx
  800b70:	74 36                	je     800ba8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b72:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b78:	75 28                	jne    800ba2 <memset+0x40>
  800b7a:	f6 c1 03             	test   $0x3,%cl
  800b7d:	75 23                	jne    800ba2 <memset+0x40>
		c &= 0xFF;
  800b7f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	c1 e3 08             	shl    $0x8,%ebx
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	c1 e6 18             	shl    $0x18,%esi
  800b8d:	89 d0                	mov    %edx,%eax
  800b8f:	c1 e0 10             	shl    $0x10,%eax
  800b92:	09 f0                	or     %esi,%eax
  800b94:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b96:	89 d8                	mov    %ebx,%eax
  800b98:	09 d0                	or     %edx,%eax
  800b9a:	c1 e9 02             	shr    $0x2,%ecx
  800b9d:	fc                   	cld    
  800b9e:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba0:	eb 06                	jmp    800ba8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	fc                   	cld    
  800ba6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba8:	89 f8                	mov    %edi,%eax
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bbd:	39 c6                	cmp    %eax,%esi
  800bbf:	73 35                	jae    800bf6 <memmove+0x47>
  800bc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc4:	39 d0                	cmp    %edx,%eax
  800bc6:	73 2e                	jae    800bf6 <memmove+0x47>
		s += n;
		d += n;
  800bc8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcb:	89 d6                	mov    %edx,%esi
  800bcd:	09 fe                	or     %edi,%esi
  800bcf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd5:	75 13                	jne    800bea <memmove+0x3b>
  800bd7:	f6 c1 03             	test   $0x3,%cl
  800bda:	75 0e                	jne    800bea <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bdc:	83 ef 04             	sub    $0x4,%edi
  800bdf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be2:	c1 e9 02             	shr    $0x2,%ecx
  800be5:	fd                   	std    
  800be6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be8:	eb 09                	jmp    800bf3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bea:	83 ef 01             	sub    $0x1,%edi
  800bed:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bf0:	fd                   	std    
  800bf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf3:	fc                   	cld    
  800bf4:	eb 1d                	jmp    800c13 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf6:	89 f2                	mov    %esi,%edx
  800bf8:	09 c2                	or     %eax,%edx
  800bfa:	f6 c2 03             	test   $0x3,%dl
  800bfd:	75 0f                	jne    800c0e <memmove+0x5f>
  800bff:	f6 c1 03             	test   $0x3,%cl
  800c02:	75 0a                	jne    800c0e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c04:	c1 e9 02             	shr    $0x2,%ecx
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	fc                   	cld    
  800c0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0c:	eb 05                	jmp    800c13 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	fc                   	cld    
  800c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c1a:	ff 75 10             	pushl  0x10(%ebp)
  800c1d:	ff 75 0c             	pushl  0xc(%ebp)
  800c20:	ff 75 08             	pushl  0x8(%ebp)
  800c23:	e8 87 ff ff ff       	call   800baf <memmove>
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c35:	89 c6                	mov    %eax,%esi
  800c37:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3a:	eb 1a                	jmp    800c56 <memcmp+0x2c>
		if (*s1 != *s2)
  800c3c:	0f b6 08             	movzbl (%eax),%ecx
  800c3f:	0f b6 1a             	movzbl (%edx),%ebx
  800c42:	38 d9                	cmp    %bl,%cl
  800c44:	74 0a                	je     800c50 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c46:	0f b6 c1             	movzbl %cl,%eax
  800c49:	0f b6 db             	movzbl %bl,%ebx
  800c4c:	29 d8                	sub    %ebx,%eax
  800c4e:	eb 0f                	jmp    800c5f <memcmp+0x35>
		s1++, s2++;
  800c50:	83 c0 01             	add    $0x1,%eax
  800c53:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c56:	39 f0                	cmp    %esi,%eax
  800c58:	75 e2                	jne    800c3c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	53                   	push   %ebx
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c6a:	89 c1                	mov    %eax,%ecx
  800c6c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c6f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c73:	eb 0a                	jmp    800c7f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c75:	0f b6 10             	movzbl (%eax),%edx
  800c78:	39 da                	cmp    %ebx,%edx
  800c7a:	74 07                	je     800c83 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7c:	83 c0 01             	add    $0x1,%eax
  800c7f:	39 c8                	cmp    %ecx,%eax
  800c81:	72 f2                	jb     800c75 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c83:	5b                   	pop    %ebx
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c92:	eb 03                	jmp    800c97 <strtol+0x11>
		s++;
  800c94:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c97:	0f b6 01             	movzbl (%ecx),%eax
  800c9a:	3c 20                	cmp    $0x20,%al
  800c9c:	74 f6                	je     800c94 <strtol+0xe>
  800c9e:	3c 09                	cmp    $0x9,%al
  800ca0:	74 f2                	je     800c94 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca2:	3c 2b                	cmp    $0x2b,%al
  800ca4:	75 0a                	jne    800cb0 <strtol+0x2a>
		s++;
  800ca6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cae:	eb 11                	jmp    800cc1 <strtol+0x3b>
  800cb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb5:	3c 2d                	cmp    $0x2d,%al
  800cb7:	75 08                	jne    800cc1 <strtol+0x3b>
		s++, neg = 1;
  800cb9:	83 c1 01             	add    $0x1,%ecx
  800cbc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc7:	75 15                	jne    800cde <strtol+0x58>
  800cc9:	80 39 30             	cmpb   $0x30,(%ecx)
  800ccc:	75 10                	jne    800cde <strtol+0x58>
  800cce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd2:	75 7c                	jne    800d50 <strtol+0xca>
		s += 2, base = 16;
  800cd4:	83 c1 02             	add    $0x2,%ecx
  800cd7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cdc:	eb 16                	jmp    800cf4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cde:	85 db                	test   %ebx,%ebx
  800ce0:	75 12                	jne    800cf4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ce2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce7:	80 39 30             	cmpb   $0x30,(%ecx)
  800cea:	75 08                	jne    800cf4 <strtol+0x6e>
		s++, base = 8;
  800cec:	83 c1 01             	add    $0x1,%ecx
  800cef:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cf4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cfc:	0f b6 11             	movzbl (%ecx),%edx
  800cff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d02:	89 f3                	mov    %esi,%ebx
  800d04:	80 fb 09             	cmp    $0x9,%bl
  800d07:	77 08                	ja     800d11 <strtol+0x8b>
			dig = *s - '0';
  800d09:	0f be d2             	movsbl %dl,%edx
  800d0c:	83 ea 30             	sub    $0x30,%edx
  800d0f:	eb 22                	jmp    800d33 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d11:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d14:	89 f3                	mov    %esi,%ebx
  800d16:	80 fb 19             	cmp    $0x19,%bl
  800d19:	77 08                	ja     800d23 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d1b:	0f be d2             	movsbl %dl,%edx
  800d1e:	83 ea 57             	sub    $0x57,%edx
  800d21:	eb 10                	jmp    800d33 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d23:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d26:	89 f3                	mov    %esi,%ebx
  800d28:	80 fb 19             	cmp    $0x19,%bl
  800d2b:	77 16                	ja     800d43 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d2d:	0f be d2             	movsbl %dl,%edx
  800d30:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d33:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d36:	7d 0b                	jge    800d43 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d38:	83 c1 01             	add    $0x1,%ecx
  800d3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d3f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d41:	eb b9                	jmp    800cfc <strtol+0x76>

	if (endptr)
  800d43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d47:	74 0d                	je     800d56 <strtol+0xd0>
		*endptr = (char *) s;
  800d49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d4c:	89 0e                	mov    %ecx,(%esi)
  800d4e:	eb 06                	jmp    800d56 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d50:	85 db                	test   %ebx,%ebx
  800d52:	74 98                	je     800cec <strtol+0x66>
  800d54:	eb 9e                	jmp    800cf4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d56:	89 c2                	mov    %eax,%edx
  800d58:	f7 da                	neg    %edx
  800d5a:	85 ff                	test   %edi,%edi
  800d5c:	0f 45 c2             	cmovne %edx,%eax
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 c3                	mov    %eax,%ebx
  800d77:	89 c7                	mov    %eax,%edi
  800d79:	89 c6                	mov    %eax,%esi
  800d7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d92:	89 d1                	mov    %edx,%ecx
  800d94:	89 d3                	mov    %edx,%ebx
  800d96:	89 d7                	mov    %edx,%edi
  800d98:	89 d6                	mov    %edx,%esi
  800d9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800daf:	b8 03 00 00 00       	mov    $0x3,%eax
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 cb                	mov    %ecx,%ebx
  800db9:	89 cf                	mov    %ecx,%edi
  800dbb:	89 ce                	mov    %ecx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 03                	push   $0x3
  800dc9:	68 6f 28 80 00       	push   $0x80286f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 8c 28 80 00       	push   $0x80288c
  800dd5:	e8 f2 f4 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ded:	b8 02 00 00 00       	mov    $0x2,%eax
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	89 d3                	mov    %edx,%ebx
  800df6:	89 d7                	mov    %edx,%edi
  800df8:	89 d6                	mov    %edx,%esi
  800dfa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_yield>:

void
sys_yield(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e11:	89 d1                	mov    %edx,%ecx
  800e13:	89 d3                	mov    %edx,%ebx
  800e15:	89 d7                	mov    %edx,%edi
  800e17:	89 d6                	mov    %edx,%esi
  800e19:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	be 00 00 00 00       	mov    $0x0,%esi
  800e2e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3c:	89 f7                	mov    %esi,%edi
  800e3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7e 17                	jle    800e5b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	83 ec 0c             	sub    $0xc,%esp
  800e47:	50                   	push   %eax
  800e48:	6a 04                	push   $0x4
  800e4a:	68 6f 28 80 00       	push   $0x80286f
  800e4f:	6a 23                	push   $0x23
  800e51:	68 8c 28 80 00       	push   $0x80288c
  800e56:	e8 71 f4 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	b8 05 00 00 00       	mov    $0x5,%eax
  800e71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7d:	8b 75 18             	mov    0x18(%ebp),%esi
  800e80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e82:	85 c0                	test   %eax,%eax
  800e84:	7e 17                	jle    800e9d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	83 ec 0c             	sub    $0xc,%esp
  800e89:	50                   	push   %eax
  800e8a:	6a 05                	push   $0x5
  800e8c:	68 6f 28 80 00       	push   $0x80286f
  800e91:	6a 23                	push   $0x23
  800e93:	68 8c 28 80 00       	push   $0x80288c
  800e98:	e8 2f f4 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb3:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 df                	mov    %ebx,%edi
  800ec0:	89 de                	mov    %ebx,%esi
  800ec2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	7e 17                	jle    800edf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	83 ec 0c             	sub    $0xc,%esp
  800ecb:	50                   	push   %eax
  800ecc:	6a 06                	push   $0x6
  800ece:	68 6f 28 80 00       	push   $0x80286f
  800ed3:	6a 23                	push   $0x23
  800ed5:	68 8c 28 80 00       	push   $0x80288c
  800eda:	e8 ed f3 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef5:	b8 08 00 00 00       	mov    $0x8,%eax
  800efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efd:	8b 55 08             	mov    0x8(%ebp),%edx
  800f00:	89 df                	mov    %ebx,%edi
  800f02:	89 de                	mov    %ebx,%esi
  800f04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f06:	85 c0                	test   %eax,%eax
  800f08:	7e 17                	jle    800f21 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	50                   	push   %eax
  800f0e:	6a 08                	push   $0x8
  800f10:	68 6f 28 80 00       	push   $0x80286f
  800f15:	6a 23                	push   $0x23
  800f17:	68 8c 28 80 00       	push   $0x80288c
  800f1c:	e8 ab f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f37:	b8 09 00 00 00       	mov    $0x9,%eax
  800f3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f42:	89 df                	mov    %ebx,%edi
  800f44:	89 de                	mov    %ebx,%esi
  800f46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	7e 17                	jle    800f63 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	50                   	push   %eax
  800f50:	6a 09                	push   $0x9
  800f52:	68 6f 28 80 00       	push   $0x80286f
  800f57:	6a 23                	push   $0x23
  800f59:	68 8c 28 80 00       	push   $0x80288c
  800f5e:	e8 69 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
  800f71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	89 df                	mov    %ebx,%edi
  800f86:	89 de                	mov    %ebx,%esi
  800f88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	7e 17                	jle    800fa5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	50                   	push   %eax
  800f92:	6a 0a                	push   $0xa
  800f94:	68 6f 28 80 00       	push   $0x80286f
  800f99:	6a 23                	push   $0x23
  800f9b:	68 8c 28 80 00       	push   $0x80288c
  800fa0:	e8 27 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb3:	be 00 00 00 00       	mov    $0x0,%esi
  800fb8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fde:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	89 cb                	mov    %ecx,%ebx
  800fe8:	89 cf                	mov    %ecx,%edi
  800fea:	89 ce                	mov    %ecx,%esi
  800fec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 17                	jle    801009 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	50                   	push   %eax
  800ff6:	6a 0d                	push   $0xd
  800ff8:	68 6f 28 80 00       	push   $0x80286f
  800ffd:	6a 23                	push   $0x23
  800fff:	68 8c 28 80 00       	push   $0x80288c
  801004:	e8 c3 f2 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801009:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5f                   	pop    %edi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	57                   	push   %edi
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801017:	ba 00 00 00 00       	mov    $0x0,%edx
  80101c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801021:	89 d1                	mov    %edx,%ecx
  801023:	89 d3                	mov    %edx,%ebx
  801025:	89 d7                	mov    %edx,%edi
  801027:	89 d6                	mov    %edx,%esi
  801029:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
  80103b:	c1 e8 0c             	shr    $0xc,%eax
}
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	05 00 00 00 30       	add    $0x30000000,%eax
  80104b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801050:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801062:	89 c2                	mov    %eax,%edx
  801064:	c1 ea 16             	shr    $0x16,%edx
  801067:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80106e:	f6 c2 01             	test   $0x1,%dl
  801071:	74 11                	je     801084 <fd_alloc+0x2d>
  801073:	89 c2                	mov    %eax,%edx
  801075:	c1 ea 0c             	shr    $0xc,%edx
  801078:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80107f:	f6 c2 01             	test   $0x1,%dl
  801082:	75 09                	jne    80108d <fd_alloc+0x36>
			*fd_store = fd;
  801084:	89 01                	mov    %eax,(%ecx)
			return 0;
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
  80108b:	eb 17                	jmp    8010a4 <fd_alloc+0x4d>
  80108d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801092:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801097:	75 c9                	jne    801062 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801099:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80109f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ac:	83 f8 1f             	cmp    $0x1f,%eax
  8010af:	77 36                	ja     8010e7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010b1:	c1 e0 0c             	shl    $0xc,%eax
  8010b4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010b9:	89 c2                	mov    %eax,%edx
  8010bb:	c1 ea 16             	shr    $0x16,%edx
  8010be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c5:	f6 c2 01             	test   $0x1,%dl
  8010c8:	74 24                	je     8010ee <fd_lookup+0x48>
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 0c             	shr    $0xc,%edx
  8010cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	74 1a                	je     8010f5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010de:	89 02                	mov    %eax,(%edx)
	return 0;
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e5:	eb 13                	jmp    8010fa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ec:	eb 0c                	jmp    8010fa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f3:	eb 05                	jmp    8010fa <fd_lookup+0x54>
  8010f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 08             	sub    $0x8,%esp
  801102:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801105:	ba 1c 29 80 00       	mov    $0x80291c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80110a:	eb 13                	jmp    80111f <dev_lookup+0x23>
  80110c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80110f:	39 08                	cmp    %ecx,(%eax)
  801111:	75 0c                	jne    80111f <dev_lookup+0x23>
			*dev = devtab[i];
  801113:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801116:	89 01                	mov    %eax,(%ecx)
			return 0;
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	eb 2e                	jmp    80114d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80111f:	8b 02                	mov    (%edx),%eax
  801121:	85 c0                	test   %eax,%eax
  801123:	75 e7                	jne    80110c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801125:	a1 08 44 80 00       	mov    0x804408,%eax
  80112a:	8b 40 48             	mov    0x48(%eax),%eax
  80112d:	83 ec 04             	sub    $0x4,%esp
  801130:	51                   	push   %ecx
  801131:	50                   	push   %eax
  801132:	68 9c 28 80 00       	push   $0x80289c
  801137:	e8 69 f2 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  80113c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    

0080114f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
  801154:	83 ec 10             	sub    $0x10,%esp
  801157:	8b 75 08             	mov    0x8(%ebp),%esi
  80115a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80115d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801160:	50                   	push   %eax
  801161:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801167:	c1 e8 0c             	shr    $0xc,%eax
  80116a:	50                   	push   %eax
  80116b:	e8 36 ff ff ff       	call   8010a6 <fd_lookup>
  801170:	83 c4 08             	add    $0x8,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	78 05                	js     80117c <fd_close+0x2d>
	    || fd != fd2)
  801177:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80117a:	74 0c                	je     801188 <fd_close+0x39>
		return (must_exist ? r : 0);
  80117c:	84 db                	test   %bl,%bl
  80117e:	ba 00 00 00 00       	mov    $0x0,%edx
  801183:	0f 44 c2             	cmove  %edx,%eax
  801186:	eb 41                	jmp    8011c9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118e:	50                   	push   %eax
  80118f:	ff 36                	pushl  (%esi)
  801191:	e8 66 ff ff ff       	call   8010fc <dev_lookup>
  801196:	89 c3                	mov    %eax,%ebx
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 1a                	js     8011b9 <fd_close+0x6a>
		if (dev->dev_close)
  80119f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011a5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	74 0b                	je     8011b9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ae:	83 ec 0c             	sub    $0xc,%esp
  8011b1:	56                   	push   %esi
  8011b2:	ff d0                	call   *%eax
  8011b4:	89 c3                	mov    %eax,%ebx
  8011b6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011b9:	83 ec 08             	sub    $0x8,%esp
  8011bc:	56                   	push   %esi
  8011bd:	6a 00                	push   $0x0
  8011bf:	e8 e1 fc ff ff       	call   800ea5 <sys_page_unmap>
	return r;
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	89 d8                	mov    %ebx,%eax
}
  8011c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	ff 75 08             	pushl  0x8(%ebp)
  8011dd:	e8 c4 fe ff ff       	call   8010a6 <fd_lookup>
  8011e2:	83 c4 08             	add    $0x8,%esp
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	78 10                	js     8011f9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011e9:	83 ec 08             	sub    $0x8,%esp
  8011ec:	6a 01                	push   $0x1
  8011ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f1:	e8 59 ff ff ff       	call   80114f <fd_close>
  8011f6:	83 c4 10             	add    $0x10,%esp
}
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <close_all>:

void
close_all(void)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	53                   	push   %ebx
  80120b:	e8 c0 ff ff ff       	call   8011d0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801210:	83 c3 01             	add    $0x1,%ebx
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	83 fb 20             	cmp    $0x20,%ebx
  801219:	75 ec                	jne    801207 <close_all+0xc>
		close(i);
}
  80121b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 2c             	sub    $0x2c,%esp
  801229:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80122c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	ff 75 08             	pushl  0x8(%ebp)
  801233:	e8 6e fe ff ff       	call   8010a6 <fd_lookup>
  801238:	83 c4 08             	add    $0x8,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	0f 88 c1 00 00 00    	js     801304 <dup+0xe4>
		return r;
	close(newfdnum);
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	56                   	push   %esi
  801247:	e8 84 ff ff ff       	call   8011d0 <close>

	newfd = INDEX2FD(newfdnum);
  80124c:	89 f3                	mov    %esi,%ebx
  80124e:	c1 e3 0c             	shl    $0xc,%ebx
  801251:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801257:	83 c4 04             	add    $0x4,%esp
  80125a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125d:	e8 de fd ff ff       	call   801040 <fd2data>
  801262:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801264:	89 1c 24             	mov    %ebx,(%esp)
  801267:	e8 d4 fd ff ff       	call   801040 <fd2data>
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801272:	89 f8                	mov    %edi,%eax
  801274:	c1 e8 16             	shr    $0x16,%eax
  801277:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80127e:	a8 01                	test   $0x1,%al
  801280:	74 37                	je     8012b9 <dup+0x99>
  801282:	89 f8                	mov    %edi,%eax
  801284:	c1 e8 0c             	shr    $0xc,%eax
  801287:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80128e:	f6 c2 01             	test   $0x1,%dl
  801291:	74 26                	je     8012b9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801293:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	25 07 0e 00 00       	and    $0xe07,%eax
  8012a2:	50                   	push   %eax
  8012a3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012a6:	6a 00                	push   $0x0
  8012a8:	57                   	push   %edi
  8012a9:	6a 00                	push   $0x0
  8012ab:	e8 b3 fb ff ff       	call   800e63 <sys_page_map>
  8012b0:	89 c7                	mov    %eax,%edi
  8012b2:	83 c4 20             	add    $0x20,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 2e                	js     8012e7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012bc:	89 d0                	mov    %edx,%eax
  8012be:	c1 e8 0c             	shr    $0xc,%eax
  8012c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d0:	50                   	push   %eax
  8012d1:	53                   	push   %ebx
  8012d2:	6a 00                	push   $0x0
  8012d4:	52                   	push   %edx
  8012d5:	6a 00                	push   $0x0
  8012d7:	e8 87 fb ff ff       	call   800e63 <sys_page_map>
  8012dc:	89 c7                	mov    %eax,%edi
  8012de:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012e1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e3:	85 ff                	test   %edi,%edi
  8012e5:	79 1d                	jns    801304 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	53                   	push   %ebx
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 b3 fb ff ff       	call   800ea5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012f2:	83 c4 08             	add    $0x8,%esp
  8012f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f8:	6a 00                	push   $0x0
  8012fa:	e8 a6 fb ff ff       	call   800ea5 <sys_page_unmap>
	return r;
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	89 f8                	mov    %edi,%eax
}
  801304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	53                   	push   %ebx
  801310:	83 ec 14             	sub    $0x14,%esp
  801313:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801316:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	53                   	push   %ebx
  80131b:	e8 86 fd ff ff       	call   8010a6 <fd_lookup>
  801320:	83 c4 08             	add    $0x8,%esp
  801323:	89 c2                	mov    %eax,%edx
  801325:	85 c0                	test   %eax,%eax
  801327:	78 6d                	js     801396 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801333:	ff 30                	pushl  (%eax)
  801335:	e8 c2 fd ff ff       	call   8010fc <dev_lookup>
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 4c                	js     80138d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801341:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801344:	8b 42 08             	mov    0x8(%edx),%eax
  801347:	83 e0 03             	and    $0x3,%eax
  80134a:	83 f8 01             	cmp    $0x1,%eax
  80134d:	75 21                	jne    801370 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80134f:	a1 08 44 80 00       	mov    0x804408,%eax
  801354:	8b 40 48             	mov    0x48(%eax),%eax
  801357:	83 ec 04             	sub    $0x4,%esp
  80135a:	53                   	push   %ebx
  80135b:	50                   	push   %eax
  80135c:	68 e0 28 80 00       	push   $0x8028e0
  801361:	e8 3f f0 ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80136e:	eb 26                	jmp    801396 <read+0x8a>
	}
	if (!dev->dev_read)
  801370:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801373:	8b 40 08             	mov    0x8(%eax),%eax
  801376:	85 c0                	test   %eax,%eax
  801378:	74 17                	je     801391 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80137a:	83 ec 04             	sub    $0x4,%esp
  80137d:	ff 75 10             	pushl  0x10(%ebp)
  801380:	ff 75 0c             	pushl  0xc(%ebp)
  801383:	52                   	push   %edx
  801384:	ff d0                	call   *%eax
  801386:	89 c2                	mov    %eax,%edx
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	eb 09                	jmp    801396 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	eb 05                	jmp    801396 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801391:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801396:	89 d0                	mov    %edx,%eax
  801398:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	57                   	push   %edi
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 0c             	sub    $0xc,%esp
  8013a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b1:	eb 21                	jmp    8013d4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013b3:	83 ec 04             	sub    $0x4,%esp
  8013b6:	89 f0                	mov    %esi,%eax
  8013b8:	29 d8                	sub    %ebx,%eax
  8013ba:	50                   	push   %eax
  8013bb:	89 d8                	mov    %ebx,%eax
  8013bd:	03 45 0c             	add    0xc(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	57                   	push   %edi
  8013c2:	e8 45 ff ff ff       	call   80130c <read>
		if (m < 0)
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 10                	js     8013de <readn+0x41>
			return m;
		if (m == 0)
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	74 0a                	je     8013dc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d2:	01 c3                	add    %eax,%ebx
  8013d4:	39 f3                	cmp    %esi,%ebx
  8013d6:	72 db                	jb     8013b3 <readn+0x16>
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	eb 02                	jmp    8013de <readn+0x41>
  8013dc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 14             	sub    $0x14,%esp
  8013ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f3:	50                   	push   %eax
  8013f4:	53                   	push   %ebx
  8013f5:	e8 ac fc ff ff       	call   8010a6 <fd_lookup>
  8013fa:	83 c4 08             	add    $0x8,%esp
  8013fd:	89 c2                	mov    %eax,%edx
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 68                	js     80146b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801409:	50                   	push   %eax
  80140a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140d:	ff 30                	pushl  (%eax)
  80140f:	e8 e8 fc ff ff       	call   8010fc <dev_lookup>
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 47                	js     801462 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801422:	75 21                	jne    801445 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801424:	a1 08 44 80 00       	mov    0x804408,%eax
  801429:	8b 40 48             	mov    0x48(%eax),%eax
  80142c:	83 ec 04             	sub    $0x4,%esp
  80142f:	53                   	push   %ebx
  801430:	50                   	push   %eax
  801431:	68 fc 28 80 00       	push   $0x8028fc
  801436:	e8 6a ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801443:	eb 26                	jmp    80146b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801445:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801448:	8b 52 0c             	mov    0xc(%edx),%edx
  80144b:	85 d2                	test   %edx,%edx
  80144d:	74 17                	je     801466 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80144f:	83 ec 04             	sub    $0x4,%esp
  801452:	ff 75 10             	pushl  0x10(%ebp)
  801455:	ff 75 0c             	pushl  0xc(%ebp)
  801458:	50                   	push   %eax
  801459:	ff d2                	call   *%edx
  80145b:	89 c2                	mov    %eax,%edx
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	eb 09                	jmp    80146b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801462:	89 c2                	mov    %eax,%edx
  801464:	eb 05                	jmp    80146b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801466:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801470:	c9                   	leave  
  801471:	c3                   	ret    

00801472 <seek>:

int
seek(int fdnum, off_t offset)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801478:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	ff 75 08             	pushl  0x8(%ebp)
  80147f:	e8 22 fc ff ff       	call   8010a6 <fd_lookup>
  801484:	83 c4 08             	add    $0x8,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 0e                	js     801499 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80148b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80148e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801491:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801494:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	83 ec 14             	sub    $0x14,%esp
  8014a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	53                   	push   %ebx
  8014aa:	e8 f7 fb ff ff       	call   8010a6 <fd_lookup>
  8014af:	83 c4 08             	add    $0x8,%esp
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 65                	js     80151d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c2:	ff 30                	pushl  (%eax)
  8014c4:	e8 33 fc ff ff       	call   8010fc <dev_lookup>
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 44                	js     801514 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d7:	75 21                	jne    8014fa <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014d9:	a1 08 44 80 00       	mov    0x804408,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014de:	8b 40 48             	mov    0x48(%eax),%eax
  8014e1:	83 ec 04             	sub    $0x4,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	50                   	push   %eax
  8014e6:	68 bc 28 80 00       	push   $0x8028bc
  8014eb:	e8 b5 ee ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f8:	eb 23                	jmp    80151d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fd:	8b 52 18             	mov    0x18(%edx),%edx
  801500:	85 d2                	test   %edx,%edx
  801502:	74 14                	je     801518 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	ff 75 0c             	pushl  0xc(%ebp)
  80150a:	50                   	push   %eax
  80150b:	ff d2                	call   *%edx
  80150d:	89 c2                	mov    %eax,%edx
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	eb 09                	jmp    80151d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801514:	89 c2                	mov    %eax,%edx
  801516:	eb 05                	jmp    80151d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801518:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80151d:	89 d0                	mov    %edx,%eax
  80151f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801522:	c9                   	leave  
  801523:	c3                   	ret    

00801524 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	53                   	push   %ebx
  801528:	83 ec 14             	sub    $0x14,%esp
  80152b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801531:	50                   	push   %eax
  801532:	ff 75 08             	pushl  0x8(%ebp)
  801535:	e8 6c fb ff ff       	call   8010a6 <fd_lookup>
  80153a:	83 c4 08             	add    $0x8,%esp
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 58                	js     80159b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	ff 30                	pushl  (%eax)
  80154f:	e8 a8 fb ff ff       	call   8010fc <dev_lookup>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 37                	js     801592 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80155b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801562:	74 32                	je     801596 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801564:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801567:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80156e:	00 00 00 
	stat->st_isdir = 0;
  801571:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801578:	00 00 00 
	stat->st_dev = dev;
  80157b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	ff 75 f0             	pushl  -0x10(%ebp)
  801588:	ff 50 14             	call   *0x14(%eax)
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	eb 09                	jmp    80159b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801592:	89 c2                	mov    %eax,%edx
  801594:	eb 05                	jmp    80159b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801596:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	6a 00                	push   $0x0
  8015ac:	ff 75 08             	pushl  0x8(%ebp)
  8015af:	e8 d6 01 00 00       	call   80178a <open>
  8015b4:	89 c3                	mov    %eax,%ebx
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 1b                	js     8015d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	ff 75 0c             	pushl  0xc(%ebp)
  8015c3:	50                   	push   %eax
  8015c4:	e8 5b ff ff ff       	call   801524 <fstat>
  8015c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8015cb:	89 1c 24             	mov    %ebx,(%esp)
  8015ce:	e8 fd fb ff ff       	call   8011d0 <close>
	return r;
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	89 f0                	mov    %esi,%eax
}
  8015d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5e                   	pop    %esi
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    

008015df <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	56                   	push   %esi
  8015e3:	53                   	push   %ebx
  8015e4:	89 c6                	mov    %eax,%esi
  8015e6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015e8:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  8015ef:	75 12                	jne    801603 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015f1:	83 ec 0c             	sub    $0xc,%esp
  8015f4:	6a 01                	push   $0x1
  8015f6:	e8 c1 0b 00 00       	call   8021bc <ipc_find_env>
  8015fb:	a3 00 44 80 00       	mov    %eax,0x804400
  801600:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801603:	6a 07                	push   $0x7
  801605:	68 00 50 80 00       	push   $0x805000
  80160a:	56                   	push   %esi
  80160b:	ff 35 00 44 80 00    	pushl  0x804400
  801611:	e8 52 0b 00 00       	call   802168 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801616:	83 c4 0c             	add    $0xc,%esp
  801619:	6a 00                	push   $0x0
  80161b:	53                   	push   %ebx
  80161c:	6a 00                	push   $0x0
  80161e:	e8 de 0a 00 00       	call   802101 <ipc_recv>
}
  801623:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    

0080162a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801630:	8b 45 08             	mov    0x8(%ebp),%eax
  801633:	8b 40 0c             	mov    0xc(%eax),%eax
  801636:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80163b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801643:	ba 00 00 00 00       	mov    $0x0,%edx
  801648:	b8 02 00 00 00       	mov    $0x2,%eax
  80164d:	e8 8d ff ff ff       	call   8015df <fsipc>
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80165a:	8b 45 08             	mov    0x8(%ebp),%eax
  80165d:	8b 40 0c             	mov    0xc(%eax),%eax
  801660:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801665:	ba 00 00 00 00       	mov    $0x0,%edx
  80166a:	b8 06 00 00 00       	mov    $0x6,%eax
  80166f:	e8 6b ff ff ff       	call   8015df <fsipc>
}
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	53                   	push   %ebx
  80167a:	83 ec 04             	sub    $0x4,%esp
  80167d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	8b 40 0c             	mov    0xc(%eax),%eax
  801686:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80168b:	ba 00 00 00 00       	mov    $0x0,%edx
  801690:	b8 05 00 00 00       	mov    $0x5,%eax
  801695:	e8 45 ff ff ff       	call   8015df <fsipc>
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 2c                	js     8016ca <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	68 00 50 80 00       	push   $0x805000
  8016a6:	53                   	push   %ebx
  8016a7:	e8 71 f3 ff ff       	call   800a1d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ac:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016b7:	a1 84 50 80 00       	mov    0x805084,%eax
  8016bc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016db:	8b 52 0c             	mov    0xc(%edx),%edx
  8016de:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016e4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016e9:	50                   	push   %eax
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	68 08 50 80 00       	push   $0x805008
  8016f2:	e8 b8 f4 ff ff       	call   800baf <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8016f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801701:	e8 d9 fe ff ff       	call   8015df <fsipc>

}
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	56                   	push   %esi
  80170c:	53                   	push   %ebx
  80170d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801710:	8b 45 08             	mov    0x8(%ebp),%eax
  801713:	8b 40 0c             	mov    0xc(%eax),%eax
  801716:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80171b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801721:	ba 00 00 00 00       	mov    $0x0,%edx
  801726:	b8 03 00 00 00       	mov    $0x3,%eax
  80172b:	e8 af fe ff ff       	call   8015df <fsipc>
  801730:	89 c3                	mov    %eax,%ebx
  801732:	85 c0                	test   %eax,%eax
  801734:	78 4b                	js     801781 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801736:	39 c6                	cmp    %eax,%esi
  801738:	73 16                	jae    801750 <devfile_read+0x48>
  80173a:	68 30 29 80 00       	push   $0x802930
  80173f:	68 37 29 80 00       	push   $0x802937
  801744:	6a 7c                	push   $0x7c
  801746:	68 4c 29 80 00       	push   $0x80294c
  80174b:	e8 7c eb ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  801750:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801755:	7e 16                	jle    80176d <devfile_read+0x65>
  801757:	68 57 29 80 00       	push   $0x802957
  80175c:	68 37 29 80 00       	push   $0x802937
  801761:	6a 7d                	push   $0x7d
  801763:	68 4c 29 80 00       	push   $0x80294c
  801768:	e8 5f eb ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176d:	83 ec 04             	sub    $0x4,%esp
  801770:	50                   	push   %eax
  801771:	68 00 50 80 00       	push   $0x805000
  801776:	ff 75 0c             	pushl  0xc(%ebp)
  801779:	e8 31 f4 ff ff       	call   800baf <memmove>
	return r;
  80177e:	83 c4 10             	add    $0x10,%esp
}
  801781:	89 d8                	mov    %ebx,%eax
  801783:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801786:	5b                   	pop    %ebx
  801787:	5e                   	pop    %esi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	53                   	push   %ebx
  80178e:	83 ec 20             	sub    $0x20,%esp
  801791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801794:	53                   	push   %ebx
  801795:	e8 4a f2 ff ff       	call   8009e4 <strlen>
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a2:	7f 67                	jg     80180b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017aa:	50                   	push   %eax
  8017ab:	e8 a7 f8 ff ff       	call   801057 <fd_alloc>
  8017b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 57                	js     801810 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	53                   	push   %ebx
  8017bd:	68 00 50 80 00       	push   $0x805000
  8017c2:	e8 56 f2 ff ff       	call   800a1d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ca:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d7:	e8 03 fe ff ff       	call   8015df <fsipc>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	79 14                	jns    8017f9 <open+0x6f>
		fd_close(fd, 0);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	6a 00                	push   $0x0
  8017ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ed:	e8 5d f9 ff ff       	call   80114f <fd_close>
		return r;
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	89 da                	mov    %ebx,%edx
  8017f7:	eb 17                	jmp    801810 <open+0x86>
	}

	return fd2num(fd);
  8017f9:	83 ec 0c             	sub    $0xc,%esp
  8017fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ff:	e8 2c f8 ff ff       	call   801030 <fd2num>
  801804:	89 c2                	mov    %eax,%edx
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	eb 05                	jmp    801810 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80180b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801810:	89 d0                	mov    %edx,%eax
  801812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	b8 08 00 00 00       	mov    $0x8,%eax
  801827:	e8 b3 fd ff ff       	call   8015df <fsipc>
}
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80182e:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801832:	7e 37                	jle    80186b <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	53                   	push   %ebx
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80183d:	ff 70 04             	pushl  0x4(%eax)
  801840:	8d 40 10             	lea    0x10(%eax),%eax
  801843:	50                   	push   %eax
  801844:	ff 33                	pushl  (%ebx)
  801846:	e8 9b fb ff ff       	call   8013e6 <write>
		if (result > 0)
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	7e 03                	jle    801855 <writebuf+0x27>
			b->result += result;
  801852:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801855:	3b 43 04             	cmp    0x4(%ebx),%eax
  801858:	74 0d                	je     801867 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80185a:	85 c0                	test   %eax,%eax
  80185c:	ba 00 00 00 00       	mov    $0x0,%edx
  801861:	0f 4f c2             	cmovg  %edx,%eax
  801864:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186a:	c9                   	leave  
  80186b:	f3 c3                	repz ret 

0080186d <putch>:

static void
putch(int ch, void *thunk)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	53                   	push   %ebx
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801877:	8b 53 04             	mov    0x4(%ebx),%edx
  80187a:	8d 42 01             	lea    0x1(%edx),%eax
  80187d:	89 43 04             	mov    %eax,0x4(%ebx)
  801880:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801883:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801887:	3d 00 01 00 00       	cmp    $0x100,%eax
  80188c:	75 0e                	jne    80189c <putch+0x2f>
		writebuf(b);
  80188e:	89 d8                	mov    %ebx,%eax
  801890:	e8 99 ff ff ff       	call   80182e <writebuf>
		b->idx = 0;
  801895:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80189c:	83 c4 04             	add    $0x4,%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018b4:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018bb:	00 00 00 
	b.result = 0;
  8018be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018c5:	00 00 00 
	b.error = 1;
  8018c8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018cf:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018d2:	ff 75 10             	pushl  0x10(%ebp)
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018de:	50                   	push   %eax
  8018df:	68 6d 18 80 00       	push   $0x80186d
  8018e4:	e8 f3 eb ff ff       	call   8004dc <vprintfmt>
	if (b.idx > 0)
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018f3:	7e 0b                	jle    801900 <vfprintf+0x5e>
		writebuf(&b);
  8018f5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018fb:	e8 2e ff ff ff       	call   80182e <writebuf>

	return (b.result ? b.result : b.error);
  801900:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801906:	85 c0                	test   %eax,%eax
  801908:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801917:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80191a:	50                   	push   %eax
  80191b:	ff 75 0c             	pushl  0xc(%ebp)
  80191e:	ff 75 08             	pushl  0x8(%ebp)
  801921:	e8 7c ff ff ff       	call   8018a2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <printf>:

int
printf(const char *fmt, ...)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80192e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801931:	50                   	push   %eax
  801932:	ff 75 08             	pushl  0x8(%ebp)
  801935:	6a 01                	push   $0x1
  801937:	e8 66 ff ff ff       	call   8018a2 <vfprintf>
	va_end(ap);

	return cnt;
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	56                   	push   %esi
  801942:	53                   	push   %ebx
  801943:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	ff 75 08             	pushl  0x8(%ebp)
  80194c:	e8 ef f6 ff ff       	call   801040 <fd2data>
  801951:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801953:	83 c4 08             	add    $0x8,%esp
  801956:	68 63 29 80 00       	push   $0x802963
  80195b:	53                   	push   %ebx
  80195c:	e8 bc f0 ff ff       	call   800a1d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801961:	8b 46 04             	mov    0x4(%esi),%eax
  801964:	2b 06                	sub    (%esi),%eax
  801966:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80196c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801973:	00 00 00 
	stat->st_dev = &devpipe;
  801976:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80197d:	30 80 00 
	return 0;
}
  801980:	b8 00 00 00 00       	mov    $0x0,%eax
  801985:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801988:	5b                   	pop    %ebx
  801989:	5e                   	pop    %esi
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	53                   	push   %ebx
  801990:	83 ec 0c             	sub    $0xc,%esp
  801993:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801996:	53                   	push   %ebx
  801997:	6a 00                	push   $0x0
  801999:	e8 07 f5 ff ff       	call   800ea5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80199e:	89 1c 24             	mov    %ebx,(%esp)
  8019a1:	e8 9a f6 ff ff       	call   801040 <fd2data>
  8019a6:	83 c4 08             	add    $0x8,%esp
  8019a9:	50                   	push   %eax
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 f4 f4 ff ff       	call   800ea5 <sys_page_unmap>
}
  8019b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	57                   	push   %edi
  8019ba:	56                   	push   %esi
  8019bb:	53                   	push   %ebx
  8019bc:	83 ec 1c             	sub    $0x1c,%esp
  8019bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019c2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019c4:	a1 08 44 80 00       	mov    0x804408,%eax
  8019c9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8019d2:	e8 1e 08 00 00       	call   8021f5 <pageref>
  8019d7:	89 c3                	mov    %eax,%ebx
  8019d9:	89 3c 24             	mov    %edi,(%esp)
  8019dc:	e8 14 08 00 00       	call   8021f5 <pageref>
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	39 c3                	cmp    %eax,%ebx
  8019e6:	0f 94 c1             	sete   %cl
  8019e9:	0f b6 c9             	movzbl %cl,%ecx
  8019ec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019ef:	8b 15 08 44 80 00    	mov    0x804408,%edx
  8019f5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019f8:	39 ce                	cmp    %ecx,%esi
  8019fa:	74 1b                	je     801a17 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019fc:	39 c3                	cmp    %eax,%ebx
  8019fe:	75 c4                	jne    8019c4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a00:	8b 42 58             	mov    0x58(%edx),%eax
  801a03:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a06:	50                   	push   %eax
  801a07:	56                   	push   %esi
  801a08:	68 6a 29 80 00       	push   $0x80296a
  801a0d:	e8 93 e9 ff ff       	call   8003a5 <cprintf>
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	eb ad                	jmp    8019c4 <_pipeisclosed+0xe>
	}
}
  801a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5f                   	pop    %edi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	57                   	push   %edi
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	83 ec 28             	sub    $0x28,%esp
  801a2b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a2e:	56                   	push   %esi
  801a2f:	e8 0c f6 ff ff       	call   801040 <fd2data>
  801a34:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	bf 00 00 00 00       	mov    $0x0,%edi
  801a3e:	eb 4b                	jmp    801a8b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a40:	89 da                	mov    %ebx,%edx
  801a42:	89 f0                	mov    %esi,%eax
  801a44:	e8 6d ff ff ff       	call   8019b6 <_pipeisclosed>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	75 48                	jne    801a95 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a4d:	e8 af f3 ff ff       	call   800e01 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a52:	8b 43 04             	mov    0x4(%ebx),%eax
  801a55:	8b 0b                	mov    (%ebx),%ecx
  801a57:	8d 51 20             	lea    0x20(%ecx),%edx
  801a5a:	39 d0                	cmp    %edx,%eax
  801a5c:	73 e2                	jae    801a40 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a61:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a65:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a68:	89 c2                	mov    %eax,%edx
  801a6a:	c1 fa 1f             	sar    $0x1f,%edx
  801a6d:	89 d1                	mov    %edx,%ecx
  801a6f:	c1 e9 1b             	shr    $0x1b,%ecx
  801a72:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a75:	83 e2 1f             	and    $0x1f,%edx
  801a78:	29 ca                	sub    %ecx,%edx
  801a7a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a7e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a82:	83 c0 01             	add    $0x1,%eax
  801a85:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a88:	83 c7 01             	add    $0x1,%edi
  801a8b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a8e:	75 c2                	jne    801a52 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a90:	8b 45 10             	mov    0x10(%ebp),%eax
  801a93:	eb 05                	jmp    801a9a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a95:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5f                   	pop    %edi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	57                   	push   %edi
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	83 ec 18             	sub    $0x18,%esp
  801aab:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aae:	57                   	push   %edi
  801aaf:	e8 8c f5 ff ff       	call   801040 <fd2data>
  801ab4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801abe:	eb 3d                	jmp    801afd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ac0:	85 db                	test   %ebx,%ebx
  801ac2:	74 04                	je     801ac8 <devpipe_read+0x26>
				return i;
  801ac4:	89 d8                	mov    %ebx,%eax
  801ac6:	eb 44                	jmp    801b0c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ac8:	89 f2                	mov    %esi,%edx
  801aca:	89 f8                	mov    %edi,%eax
  801acc:	e8 e5 fe ff ff       	call   8019b6 <_pipeisclosed>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	75 32                	jne    801b07 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ad5:	e8 27 f3 ff ff       	call   800e01 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ada:	8b 06                	mov    (%esi),%eax
  801adc:	3b 46 04             	cmp    0x4(%esi),%eax
  801adf:	74 df                	je     801ac0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ae1:	99                   	cltd   
  801ae2:	c1 ea 1b             	shr    $0x1b,%edx
  801ae5:	01 d0                	add    %edx,%eax
  801ae7:	83 e0 1f             	and    $0x1f,%eax
  801aea:	29 d0                	sub    %edx,%eax
  801aec:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801af7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afa:	83 c3 01             	add    $0x1,%ebx
  801afd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b00:	75 d8                	jne    801ada <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b02:	8b 45 10             	mov    0x10(%ebp),%eax
  801b05:	eb 05                	jmp    801b0c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5f                   	pop    %edi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1f:	50                   	push   %eax
  801b20:	e8 32 f5 ff ff       	call   801057 <fd_alloc>
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	89 c2                	mov    %eax,%edx
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	0f 88 2c 01 00 00    	js     801c5e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	68 07 04 00 00       	push   $0x407
  801b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3d:	6a 00                	push   $0x0
  801b3f:	e8 dc f2 ff ff       	call   800e20 <sys_page_alloc>
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	89 c2                	mov    %eax,%edx
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	0f 88 0d 01 00 00    	js     801c5e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b51:	83 ec 0c             	sub    $0xc,%esp
  801b54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b57:	50                   	push   %eax
  801b58:	e8 fa f4 ff ff       	call   801057 <fd_alloc>
  801b5d:	89 c3                	mov    %eax,%ebx
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	0f 88 e2 00 00 00    	js     801c4c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6a:	83 ec 04             	sub    $0x4,%esp
  801b6d:	68 07 04 00 00       	push   $0x407
  801b72:	ff 75 f0             	pushl  -0x10(%ebp)
  801b75:	6a 00                	push   $0x0
  801b77:	e8 a4 f2 ff ff       	call   800e20 <sys_page_alloc>
  801b7c:	89 c3                	mov    %eax,%ebx
  801b7e:	83 c4 10             	add    $0x10,%esp
  801b81:	85 c0                	test   %eax,%eax
  801b83:	0f 88 c3 00 00 00    	js     801c4c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b89:	83 ec 0c             	sub    $0xc,%esp
  801b8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8f:	e8 ac f4 ff ff       	call   801040 <fd2data>
  801b94:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b96:	83 c4 0c             	add    $0xc,%esp
  801b99:	68 07 04 00 00       	push   $0x407
  801b9e:	50                   	push   %eax
  801b9f:	6a 00                	push   $0x0
  801ba1:	e8 7a f2 ff ff       	call   800e20 <sys_page_alloc>
  801ba6:	89 c3                	mov    %eax,%ebx
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	85 c0                	test   %eax,%eax
  801bad:	0f 88 89 00 00 00    	js     801c3c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb9:	e8 82 f4 ff ff       	call   801040 <fd2data>
  801bbe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bc5:	50                   	push   %eax
  801bc6:	6a 00                	push   $0x0
  801bc8:	56                   	push   %esi
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 93 f2 ff ff       	call   800e63 <sys_page_map>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	83 c4 20             	add    $0x20,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 55                	js     801c2e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bd9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bfc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c03:	83 ec 0c             	sub    $0xc,%esp
  801c06:	ff 75 f4             	pushl  -0xc(%ebp)
  801c09:	e8 22 f4 ff ff       	call   801030 <fd2num>
  801c0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c11:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c13:	83 c4 04             	add    $0x4,%esp
  801c16:	ff 75 f0             	pushl  -0x10(%ebp)
  801c19:	e8 12 f4 ff ff       	call   801030 <fd2num>
  801c1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c21:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2c:	eb 30                	jmp    801c5e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c2e:	83 ec 08             	sub    $0x8,%esp
  801c31:	56                   	push   %esi
  801c32:	6a 00                	push   $0x0
  801c34:	e8 6c f2 ff ff       	call   800ea5 <sys_page_unmap>
  801c39:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c42:	6a 00                	push   $0x0
  801c44:	e8 5c f2 ff ff       	call   800ea5 <sys_page_unmap>
  801c49:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c4c:	83 ec 08             	sub    $0x8,%esp
  801c4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c52:	6a 00                	push   $0x0
  801c54:	e8 4c f2 ff ff       	call   800ea5 <sys_page_unmap>
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c5e:	89 d0                	mov    %edx,%eax
  801c60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c70:	50                   	push   %eax
  801c71:	ff 75 08             	pushl  0x8(%ebp)
  801c74:	e8 2d f4 ff ff       	call   8010a6 <fd_lookup>
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	78 18                	js     801c98 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c80:	83 ec 0c             	sub    $0xc,%esp
  801c83:	ff 75 f4             	pushl  -0xc(%ebp)
  801c86:	e8 b5 f3 ff ff       	call   801040 <fd2data>
	return _pipeisclosed(fd, p);
  801c8b:	89 c2                	mov    %eax,%edx
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	e8 21 fd ff ff       	call   8019b6 <_pipeisclosed>
  801c95:	83 c4 10             	add    $0x10,%esp
}
  801c98:	c9                   	leave  
  801c99:	c3                   	ret    

00801c9a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ca0:	68 82 29 80 00       	push   $0x802982
  801ca5:	ff 75 0c             	pushl  0xc(%ebp)
  801ca8:	e8 70 ed ff ff       	call   800a1d <strcpy>
	return 0;
}
  801cad:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	53                   	push   %ebx
  801cb8:	83 ec 10             	sub    $0x10,%esp
  801cbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cbe:	53                   	push   %ebx
  801cbf:	e8 31 05 00 00       	call   8021f5 <pageref>
  801cc4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cc7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ccc:	83 f8 01             	cmp    $0x1,%eax
  801ccf:	75 10                	jne    801ce1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	ff 73 0c             	pushl  0xc(%ebx)
  801cd7:	e8 c0 02 00 00       	call   801f9c <nsipc_close>
  801cdc:	89 c2                	mov    %eax,%edx
  801cde:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ce1:	89 d0                	mov    %edx,%eax
  801ce3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cee:	6a 00                	push   $0x0
  801cf0:	ff 75 10             	pushl  0x10(%ebp)
  801cf3:	ff 75 0c             	pushl  0xc(%ebp)
  801cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf9:	ff 70 0c             	pushl  0xc(%eax)
  801cfc:	e8 78 03 00 00       	call   802079 <nsipc_send>
}
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d09:	6a 00                	push   $0x0
  801d0b:	ff 75 10             	pushl  0x10(%ebp)
  801d0e:	ff 75 0c             	pushl  0xc(%ebp)
  801d11:	8b 45 08             	mov    0x8(%ebp),%eax
  801d14:	ff 70 0c             	pushl  0xc(%eax)
  801d17:	e8 f1 02 00 00       	call   80200d <nsipc_recv>
}
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d24:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d27:	52                   	push   %edx
  801d28:	50                   	push   %eax
  801d29:	e8 78 f3 ff ff       	call   8010a6 <fd_lookup>
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	78 17                	js     801d4c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d38:	8b 0d 58 30 80 00    	mov    0x803058,%ecx
  801d3e:	39 08                	cmp    %ecx,(%eax)
  801d40:	75 05                	jne    801d47 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d42:	8b 40 0c             	mov    0xc(%eax),%eax
  801d45:	eb 05                	jmp    801d4c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d47:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	56                   	push   %esi
  801d52:	53                   	push   %ebx
  801d53:	83 ec 1c             	sub    $0x1c,%esp
  801d56:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5b:	50                   	push   %eax
  801d5c:	e8 f6 f2 ff ff       	call   801057 <fd_alloc>
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	85 c0                	test   %eax,%eax
  801d68:	78 1b                	js     801d85 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d6a:	83 ec 04             	sub    $0x4,%esp
  801d6d:	68 07 04 00 00       	push   $0x407
  801d72:	ff 75 f4             	pushl  -0xc(%ebp)
  801d75:	6a 00                	push   $0x0
  801d77:	e8 a4 f0 ff ff       	call   800e20 <sys_page_alloc>
  801d7c:	89 c3                	mov    %eax,%ebx
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	79 10                	jns    801d95 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d85:	83 ec 0c             	sub    $0xc,%esp
  801d88:	56                   	push   %esi
  801d89:	e8 0e 02 00 00       	call   801f9c <nsipc_close>
		return r;
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	89 d8                	mov    %ebx,%eax
  801d93:	eb 24                	jmp    801db9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d95:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801daa:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801dad:	83 ec 0c             	sub    $0xc,%esp
  801db0:	50                   	push   %eax
  801db1:	e8 7a f2 ff ff       	call   801030 <fd2num>
  801db6:	83 c4 10             	add    $0x10,%esp
}
  801db9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbc:	5b                   	pop    %ebx
  801dbd:	5e                   	pop    %esi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	e8 50 ff ff ff       	call   801d1e <fd2sockid>
		return r;
  801dce:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	78 1f                	js     801df3 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dd4:	83 ec 04             	sub    $0x4,%esp
  801dd7:	ff 75 10             	pushl  0x10(%ebp)
  801dda:	ff 75 0c             	pushl  0xc(%ebp)
  801ddd:	50                   	push   %eax
  801dde:	e8 12 01 00 00       	call   801ef5 <nsipc_accept>
  801de3:	83 c4 10             	add    $0x10,%esp
		return r;
  801de6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 07                	js     801df3 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801dec:	e8 5d ff ff ff       	call   801d4e <alloc_sockfd>
  801df1:	89 c1                	mov    %eax,%ecx
}
  801df3:	89 c8                	mov    %ecx,%eax
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801e00:	e8 19 ff ff ff       	call   801d1e <fd2sockid>
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 12                	js     801e1b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e09:	83 ec 04             	sub    $0x4,%esp
  801e0c:	ff 75 10             	pushl  0x10(%ebp)
  801e0f:	ff 75 0c             	pushl  0xc(%ebp)
  801e12:	50                   	push   %eax
  801e13:	e8 2d 01 00 00       	call   801f45 <nsipc_bind>
  801e18:	83 c4 10             	add    $0x10,%esp
}
  801e1b:	c9                   	leave  
  801e1c:	c3                   	ret    

00801e1d <shutdown>:

int
shutdown(int s, int how)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e23:	8b 45 08             	mov    0x8(%ebp),%eax
  801e26:	e8 f3 fe ff ff       	call   801d1e <fd2sockid>
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	78 0f                	js     801e3e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e2f:	83 ec 08             	sub    $0x8,%esp
  801e32:	ff 75 0c             	pushl  0xc(%ebp)
  801e35:	50                   	push   %eax
  801e36:	e8 3f 01 00 00       	call   801f7a <nsipc_shutdown>
  801e3b:	83 c4 10             	add    $0x10,%esp
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e46:	8b 45 08             	mov    0x8(%ebp),%eax
  801e49:	e8 d0 fe ff ff       	call   801d1e <fd2sockid>
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 12                	js     801e64 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e52:	83 ec 04             	sub    $0x4,%esp
  801e55:	ff 75 10             	pushl  0x10(%ebp)
  801e58:	ff 75 0c             	pushl  0xc(%ebp)
  801e5b:	50                   	push   %eax
  801e5c:	e8 55 01 00 00       	call   801fb6 <nsipc_connect>
  801e61:	83 c4 10             	add    $0x10,%esp
}
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <listen>:

int
listen(int s, int backlog)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6f:	e8 aa fe ff ff       	call   801d1e <fd2sockid>
  801e74:	85 c0                	test   %eax,%eax
  801e76:	78 0f                	js     801e87 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e78:	83 ec 08             	sub    $0x8,%esp
  801e7b:	ff 75 0c             	pushl  0xc(%ebp)
  801e7e:	50                   	push   %eax
  801e7f:	e8 67 01 00 00       	call   801feb <nsipc_listen>
  801e84:	83 c4 10             	add    $0x10,%esp
}
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e8f:	ff 75 10             	pushl  0x10(%ebp)
  801e92:	ff 75 0c             	pushl  0xc(%ebp)
  801e95:	ff 75 08             	pushl  0x8(%ebp)
  801e98:	e8 3a 02 00 00       	call   8020d7 <nsipc_socket>
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	78 05                	js     801ea9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ea4:	e8 a5 fe ff ff       	call   801d4e <alloc_sockfd>
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	53                   	push   %ebx
  801eaf:	83 ec 04             	sub    $0x4,%esp
  801eb2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801eb4:	83 3d 04 44 80 00 00 	cmpl   $0x0,0x804404
  801ebb:	75 12                	jne    801ecf <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ebd:	83 ec 0c             	sub    $0xc,%esp
  801ec0:	6a 02                	push   $0x2
  801ec2:	e8 f5 02 00 00       	call   8021bc <ipc_find_env>
  801ec7:	a3 04 44 80 00       	mov    %eax,0x804404
  801ecc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ecf:	6a 07                	push   $0x7
  801ed1:	68 00 60 80 00       	push   $0x806000
  801ed6:	53                   	push   %ebx
  801ed7:	ff 35 04 44 80 00    	pushl  0x804404
  801edd:	e8 86 02 00 00       	call   802168 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ee2:	83 c4 0c             	add    $0xc,%esp
  801ee5:	6a 00                	push   $0x0
  801ee7:	6a 00                	push   $0x0
  801ee9:	6a 00                	push   $0x0
  801eeb:	e8 11 02 00 00       	call   802101 <ipc_recv>
}
  801ef0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	56                   	push   %esi
  801ef9:	53                   	push   %ebx
  801efa:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801efd:	8b 45 08             	mov    0x8(%ebp),%eax
  801f00:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f05:	8b 06                	mov    (%esi),%eax
  801f07:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f0c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f11:	e8 95 ff ff ff       	call   801eab <nsipc>
  801f16:	89 c3                	mov    %eax,%ebx
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	78 20                	js     801f3c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f1c:	83 ec 04             	sub    $0x4,%esp
  801f1f:	ff 35 10 60 80 00    	pushl  0x806010
  801f25:	68 00 60 80 00       	push   $0x806000
  801f2a:	ff 75 0c             	pushl  0xc(%ebp)
  801f2d:	e8 7d ec ff ff       	call   800baf <memmove>
		*addrlen = ret->ret_addrlen;
  801f32:	a1 10 60 80 00       	mov    0x806010,%eax
  801f37:	89 06                	mov    %eax,(%esi)
  801f39:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f3c:	89 d8                	mov    %ebx,%eax
  801f3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f41:	5b                   	pop    %ebx
  801f42:	5e                   	pop    %esi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    

00801f45 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	53                   	push   %ebx
  801f49:	83 ec 08             	sub    $0x8,%esp
  801f4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f52:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f57:	53                   	push   %ebx
  801f58:	ff 75 0c             	pushl  0xc(%ebp)
  801f5b:	68 04 60 80 00       	push   $0x806004
  801f60:	e8 4a ec ff ff       	call   800baf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f65:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f6b:	b8 02 00 00 00       	mov    $0x2,%eax
  801f70:	e8 36 ff ff ff       	call   801eab <nsipc>
}
  801f75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f78:	c9                   	leave  
  801f79:	c3                   	ret    

00801f7a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f80:	8b 45 08             	mov    0x8(%ebp),%eax
  801f83:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f90:	b8 03 00 00 00       	mov    $0x3,%eax
  801f95:	e8 11 ff ff ff       	call   801eab <nsipc>
}
  801f9a:	c9                   	leave  
  801f9b:	c3                   	ret    

00801f9c <nsipc_close>:

int
nsipc_close(int s)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa5:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801faa:	b8 04 00 00 00       	mov    $0x4,%eax
  801faf:	e8 f7 fe ff ff       	call   801eab <nsipc>
}
  801fb4:	c9                   	leave  
  801fb5:	c3                   	ret    

00801fb6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	53                   	push   %ebx
  801fba:	83 ec 08             	sub    $0x8,%esp
  801fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fc8:	53                   	push   %ebx
  801fc9:	ff 75 0c             	pushl  0xc(%ebp)
  801fcc:	68 04 60 80 00       	push   $0x806004
  801fd1:	e8 d9 eb ff ff       	call   800baf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fd6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fdc:	b8 05 00 00 00       	mov    $0x5,%eax
  801fe1:	e8 c5 fe ff ff       	call   801eab <nsipc>
}
  801fe6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ff1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802001:	b8 06 00 00 00       	mov    $0x6,%eax
  802006:	e8 a0 fe ff ff       	call   801eab <nsipc>
}
  80200b:	c9                   	leave  
  80200c:	c3                   	ret    

0080200d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	56                   	push   %esi
  802011:	53                   	push   %ebx
  802012:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802015:	8b 45 08             	mov    0x8(%ebp),%eax
  802018:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80201d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802023:	8b 45 14             	mov    0x14(%ebp),%eax
  802026:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80202b:	b8 07 00 00 00       	mov    $0x7,%eax
  802030:	e8 76 fe ff ff       	call   801eab <nsipc>
  802035:	89 c3                	mov    %eax,%ebx
  802037:	85 c0                	test   %eax,%eax
  802039:	78 35                	js     802070 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80203b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802040:	7f 04                	jg     802046 <nsipc_recv+0x39>
  802042:	39 c6                	cmp    %eax,%esi
  802044:	7d 16                	jge    80205c <nsipc_recv+0x4f>
  802046:	68 8e 29 80 00       	push   $0x80298e
  80204b:	68 37 29 80 00       	push   $0x802937
  802050:	6a 62                	push   $0x62
  802052:	68 a3 29 80 00       	push   $0x8029a3
  802057:	e8 70 e2 ff ff       	call   8002cc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80205c:	83 ec 04             	sub    $0x4,%esp
  80205f:	50                   	push   %eax
  802060:	68 00 60 80 00       	push   $0x806000
  802065:	ff 75 0c             	pushl  0xc(%ebp)
  802068:	e8 42 eb ff ff       	call   800baf <memmove>
  80206d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802070:	89 d8                	mov    %ebx,%eax
  802072:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802075:	5b                   	pop    %ebx
  802076:	5e                   	pop    %esi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    

00802079 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	53                   	push   %ebx
  80207d:	83 ec 04             	sub    $0x4,%esp
  802080:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802083:	8b 45 08             	mov    0x8(%ebp),%eax
  802086:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80208b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802091:	7e 16                	jle    8020a9 <nsipc_send+0x30>
  802093:	68 af 29 80 00       	push   $0x8029af
  802098:	68 37 29 80 00       	push   $0x802937
  80209d:	6a 6d                	push   $0x6d
  80209f:	68 a3 29 80 00       	push   $0x8029a3
  8020a4:	e8 23 e2 ff ff       	call   8002cc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020a9:	83 ec 04             	sub    $0x4,%esp
  8020ac:	53                   	push   %ebx
  8020ad:	ff 75 0c             	pushl  0xc(%ebp)
  8020b0:	68 0c 60 80 00       	push   $0x80600c
  8020b5:	e8 f5 ea ff ff       	call   800baf <memmove>
	nsipcbuf.send.req_size = size;
  8020ba:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8020c3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8020cd:	e8 d9 fd ff ff       	call   801eab <nsipc>
}
  8020d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    

008020d7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020f5:	b8 09 00 00 00       	mov    $0x9,%eax
  8020fa:	e8 ac fd ff ff       	call   801eab <nsipc>
}
  8020ff:	c9                   	leave  
  802100:	c3                   	ret    

00802101 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802101:	55                   	push   %ebp
  802102:	89 e5                	mov    %esp,%ebp
  802104:	56                   	push   %esi
  802105:	53                   	push   %ebx
  802106:	8b 75 08             	mov    0x8(%ebp),%esi
  802109:	8b 45 0c             	mov    0xc(%ebp),%eax
  80210c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80210f:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802111:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802116:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802119:	83 ec 0c             	sub    $0xc,%esp
  80211c:	50                   	push   %eax
  80211d:	e8 ae ee ff ff       	call   800fd0 <sys_ipc_recv>

	if (from_env_store != NULL)
  802122:	83 c4 10             	add    $0x10,%esp
  802125:	85 f6                	test   %esi,%esi
  802127:	74 14                	je     80213d <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802129:	ba 00 00 00 00       	mov    $0x0,%edx
  80212e:	85 c0                	test   %eax,%eax
  802130:	78 09                	js     80213b <ipc_recv+0x3a>
  802132:	8b 15 08 44 80 00    	mov    0x804408,%edx
  802138:	8b 52 74             	mov    0x74(%edx),%edx
  80213b:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80213d:	85 db                	test   %ebx,%ebx
  80213f:	74 14                	je     802155 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802141:	ba 00 00 00 00       	mov    $0x0,%edx
  802146:	85 c0                	test   %eax,%eax
  802148:	78 09                	js     802153 <ipc_recv+0x52>
  80214a:	8b 15 08 44 80 00    	mov    0x804408,%edx
  802150:	8b 52 78             	mov    0x78(%edx),%edx
  802153:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802155:	85 c0                	test   %eax,%eax
  802157:	78 08                	js     802161 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802159:	a1 08 44 80 00       	mov    0x804408,%eax
  80215e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802161:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    

00802168 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	57                   	push   %edi
  80216c:	56                   	push   %esi
  80216d:	53                   	push   %ebx
  80216e:	83 ec 0c             	sub    $0xc,%esp
  802171:	8b 7d 08             	mov    0x8(%ebp),%edi
  802174:	8b 75 0c             	mov    0xc(%ebp),%esi
  802177:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80217a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80217c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802181:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802184:	ff 75 14             	pushl  0x14(%ebp)
  802187:	53                   	push   %ebx
  802188:	56                   	push   %esi
  802189:	57                   	push   %edi
  80218a:	e8 1e ee ff ff       	call   800fad <sys_ipc_try_send>

		if (err < 0) {
  80218f:	83 c4 10             	add    $0x10,%esp
  802192:	85 c0                	test   %eax,%eax
  802194:	79 1e                	jns    8021b4 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802196:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802199:	75 07                	jne    8021a2 <ipc_send+0x3a>
				sys_yield();
  80219b:	e8 61 ec ff ff       	call   800e01 <sys_yield>
  8021a0:	eb e2                	jmp    802184 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8021a2:	50                   	push   %eax
  8021a3:	68 bb 29 80 00       	push   $0x8029bb
  8021a8:	6a 49                	push   $0x49
  8021aa:	68 c8 29 80 00       	push   $0x8029c8
  8021af:	e8 18 e1 ff ff       	call   8002cc <_panic>
		}

	} while (err < 0);

}
  8021b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    

008021bc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021c7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021d0:	8b 52 50             	mov    0x50(%edx),%edx
  8021d3:	39 ca                	cmp    %ecx,%edx
  8021d5:	75 0d                	jne    8021e4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8021d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021df:	8b 40 48             	mov    0x48(%eax),%eax
  8021e2:	eb 0f                	jmp    8021f3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021e4:	83 c0 01             	add    $0x1,%eax
  8021e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021ec:	75 d9                	jne    8021c7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	c1 e8 16             	shr    $0x16,%eax
  802200:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802207:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80220c:	f6 c1 01             	test   $0x1,%cl
  80220f:	74 1d                	je     80222e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802211:	c1 ea 0c             	shr    $0xc,%edx
  802214:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80221b:	f6 c2 01             	test   $0x1,%dl
  80221e:	74 0e                	je     80222e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802220:	c1 ea 0c             	shr    $0xc,%edx
  802223:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80222a:	ef 
  80222b:	0f b7 c0             	movzwl %ax,%eax
}
  80222e:	5d                   	pop    %ebp
  80222f:	c3                   	ret    

00802230 <__udivdi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 1c             	sub    $0x1c,%esp
  802237:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80223b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80223f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802247:	85 f6                	test   %esi,%esi
  802249:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80224d:	89 ca                	mov    %ecx,%edx
  80224f:	89 f8                	mov    %edi,%eax
  802251:	75 3d                	jne    802290 <__udivdi3+0x60>
  802253:	39 cf                	cmp    %ecx,%edi
  802255:	0f 87 c5 00 00 00    	ja     802320 <__udivdi3+0xf0>
  80225b:	85 ff                	test   %edi,%edi
  80225d:	89 fd                	mov    %edi,%ebp
  80225f:	75 0b                	jne    80226c <__udivdi3+0x3c>
  802261:	b8 01 00 00 00       	mov    $0x1,%eax
  802266:	31 d2                	xor    %edx,%edx
  802268:	f7 f7                	div    %edi
  80226a:	89 c5                	mov    %eax,%ebp
  80226c:	89 c8                	mov    %ecx,%eax
  80226e:	31 d2                	xor    %edx,%edx
  802270:	f7 f5                	div    %ebp
  802272:	89 c1                	mov    %eax,%ecx
  802274:	89 d8                	mov    %ebx,%eax
  802276:	89 cf                	mov    %ecx,%edi
  802278:	f7 f5                	div    %ebp
  80227a:	89 c3                	mov    %eax,%ebx
  80227c:	89 d8                	mov    %ebx,%eax
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	39 ce                	cmp    %ecx,%esi
  802292:	77 74                	ja     802308 <__udivdi3+0xd8>
  802294:	0f bd fe             	bsr    %esi,%edi
  802297:	83 f7 1f             	xor    $0x1f,%edi
  80229a:	0f 84 98 00 00 00    	je     802338 <__udivdi3+0x108>
  8022a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	89 c5                	mov    %eax,%ebp
  8022a9:	29 fb                	sub    %edi,%ebx
  8022ab:	d3 e6                	shl    %cl,%esi
  8022ad:	89 d9                	mov    %ebx,%ecx
  8022af:	d3 ed                	shr    %cl,%ebp
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	d3 e0                	shl    %cl,%eax
  8022b5:	09 ee                	or     %ebp,%esi
  8022b7:	89 d9                	mov    %ebx,%ecx
  8022b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022bd:	89 d5                	mov    %edx,%ebp
  8022bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022c3:	d3 ed                	shr    %cl,%ebp
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	d3 e2                	shl    %cl,%edx
  8022c9:	89 d9                	mov    %ebx,%ecx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	09 c2                	or     %eax,%edx
  8022cf:	89 d0                	mov    %edx,%eax
  8022d1:	89 ea                	mov    %ebp,%edx
  8022d3:	f7 f6                	div    %esi
  8022d5:	89 d5                	mov    %edx,%ebp
  8022d7:	89 c3                	mov    %eax,%ebx
  8022d9:	f7 64 24 0c          	mull   0xc(%esp)
  8022dd:	39 d5                	cmp    %edx,%ebp
  8022df:	72 10                	jb     8022f1 <__udivdi3+0xc1>
  8022e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	d3 e6                	shl    %cl,%esi
  8022e9:	39 c6                	cmp    %eax,%esi
  8022eb:	73 07                	jae    8022f4 <__udivdi3+0xc4>
  8022ed:	39 d5                	cmp    %edx,%ebp
  8022ef:	75 03                	jne    8022f4 <__udivdi3+0xc4>
  8022f1:	83 eb 01             	sub    $0x1,%ebx
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	89 d8                	mov    %ebx,%eax
  8022f8:	89 fa                	mov    %edi,%edx
  8022fa:	83 c4 1c             	add    $0x1c,%esp
  8022fd:	5b                   	pop    %ebx
  8022fe:	5e                   	pop    %esi
  8022ff:	5f                   	pop    %edi
  802300:	5d                   	pop    %ebp
  802301:	c3                   	ret    
  802302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802308:	31 ff                	xor    %edi,%edi
  80230a:	31 db                	xor    %ebx,%ebx
  80230c:	89 d8                	mov    %ebx,%eax
  80230e:	89 fa                	mov    %edi,%edx
  802310:	83 c4 1c             	add    $0x1c,%esp
  802313:	5b                   	pop    %ebx
  802314:	5e                   	pop    %esi
  802315:	5f                   	pop    %edi
  802316:	5d                   	pop    %ebp
  802317:	c3                   	ret    
  802318:	90                   	nop
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	89 d8                	mov    %ebx,%eax
  802322:	f7 f7                	div    %edi
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 c3                	mov    %eax,%ebx
  802328:	89 d8                	mov    %ebx,%eax
  80232a:	89 fa                	mov    %edi,%edx
  80232c:	83 c4 1c             	add    $0x1c,%esp
  80232f:	5b                   	pop    %ebx
  802330:	5e                   	pop    %esi
  802331:	5f                   	pop    %edi
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    
  802334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802338:	39 ce                	cmp    %ecx,%esi
  80233a:	72 0c                	jb     802348 <__udivdi3+0x118>
  80233c:	31 db                	xor    %ebx,%ebx
  80233e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802342:	0f 87 34 ff ff ff    	ja     80227c <__udivdi3+0x4c>
  802348:	bb 01 00 00 00       	mov    $0x1,%ebx
  80234d:	e9 2a ff ff ff       	jmp    80227c <__udivdi3+0x4c>
  802352:	66 90                	xchg   %ax,%ax
  802354:	66 90                	xchg   %ax,%ax
  802356:	66 90                	xchg   %ax,%ax
  802358:	66 90                	xchg   %ax,%ax
  80235a:	66 90                	xchg   %ax,%ax
  80235c:	66 90                	xchg   %ax,%ax
  80235e:	66 90                	xchg   %ax,%ax

00802360 <__umoddi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	83 ec 1c             	sub    $0x1c,%esp
  802367:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80236b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80236f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802373:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802377:	85 d2                	test   %edx,%edx
  802379:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80237d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802381:	89 f3                	mov    %esi,%ebx
  802383:	89 3c 24             	mov    %edi,(%esp)
  802386:	89 74 24 04          	mov    %esi,0x4(%esp)
  80238a:	75 1c                	jne    8023a8 <__umoddi3+0x48>
  80238c:	39 f7                	cmp    %esi,%edi
  80238e:	76 50                	jbe    8023e0 <__umoddi3+0x80>
  802390:	89 c8                	mov    %ecx,%eax
  802392:	89 f2                	mov    %esi,%edx
  802394:	f7 f7                	div    %edi
  802396:	89 d0                	mov    %edx,%eax
  802398:	31 d2                	xor    %edx,%edx
  80239a:	83 c4 1c             	add    $0x1c,%esp
  80239d:	5b                   	pop    %ebx
  80239e:	5e                   	pop    %esi
  80239f:	5f                   	pop    %edi
  8023a0:	5d                   	pop    %ebp
  8023a1:	c3                   	ret    
  8023a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023a8:	39 f2                	cmp    %esi,%edx
  8023aa:	89 d0                	mov    %edx,%eax
  8023ac:	77 52                	ja     802400 <__umoddi3+0xa0>
  8023ae:	0f bd ea             	bsr    %edx,%ebp
  8023b1:	83 f5 1f             	xor    $0x1f,%ebp
  8023b4:	75 5a                	jne    802410 <__umoddi3+0xb0>
  8023b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ba:	0f 82 e0 00 00 00    	jb     8024a0 <__umoddi3+0x140>
  8023c0:	39 0c 24             	cmp    %ecx,(%esp)
  8023c3:	0f 86 d7 00 00 00    	jbe    8024a0 <__umoddi3+0x140>
  8023c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023d1:	83 c4 1c             	add    $0x1c,%esp
  8023d4:	5b                   	pop    %ebx
  8023d5:	5e                   	pop    %esi
  8023d6:	5f                   	pop    %edi
  8023d7:	5d                   	pop    %ebp
  8023d8:	c3                   	ret    
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	85 ff                	test   %edi,%edi
  8023e2:	89 fd                	mov    %edi,%ebp
  8023e4:	75 0b                	jne    8023f1 <__umoddi3+0x91>
  8023e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023eb:	31 d2                	xor    %edx,%edx
  8023ed:	f7 f7                	div    %edi
  8023ef:	89 c5                	mov    %eax,%ebp
  8023f1:	89 f0                	mov    %esi,%eax
  8023f3:	31 d2                	xor    %edx,%edx
  8023f5:	f7 f5                	div    %ebp
  8023f7:	89 c8                	mov    %ecx,%eax
  8023f9:	f7 f5                	div    %ebp
  8023fb:	89 d0                	mov    %edx,%eax
  8023fd:	eb 99                	jmp    802398 <__umoddi3+0x38>
  8023ff:	90                   	nop
  802400:	89 c8                	mov    %ecx,%eax
  802402:	89 f2                	mov    %esi,%edx
  802404:	83 c4 1c             	add    $0x1c,%esp
  802407:	5b                   	pop    %ebx
  802408:	5e                   	pop    %esi
  802409:	5f                   	pop    %edi
  80240a:	5d                   	pop    %ebp
  80240b:	c3                   	ret    
  80240c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802410:	8b 34 24             	mov    (%esp),%esi
  802413:	bf 20 00 00 00       	mov    $0x20,%edi
  802418:	89 e9                	mov    %ebp,%ecx
  80241a:	29 ef                	sub    %ebp,%edi
  80241c:	d3 e0                	shl    %cl,%eax
  80241e:	89 f9                	mov    %edi,%ecx
  802420:	89 f2                	mov    %esi,%edx
  802422:	d3 ea                	shr    %cl,%edx
  802424:	89 e9                	mov    %ebp,%ecx
  802426:	09 c2                	or     %eax,%edx
  802428:	89 d8                	mov    %ebx,%eax
  80242a:	89 14 24             	mov    %edx,(%esp)
  80242d:	89 f2                	mov    %esi,%edx
  80242f:	d3 e2                	shl    %cl,%edx
  802431:	89 f9                	mov    %edi,%ecx
  802433:	89 54 24 04          	mov    %edx,0x4(%esp)
  802437:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80243b:	d3 e8                	shr    %cl,%eax
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	89 c6                	mov    %eax,%esi
  802441:	d3 e3                	shl    %cl,%ebx
  802443:	89 f9                	mov    %edi,%ecx
  802445:	89 d0                	mov    %edx,%eax
  802447:	d3 e8                	shr    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	09 d8                	or     %ebx,%eax
  80244d:	89 d3                	mov    %edx,%ebx
  80244f:	89 f2                	mov    %esi,%edx
  802451:	f7 34 24             	divl   (%esp)
  802454:	89 d6                	mov    %edx,%esi
  802456:	d3 e3                	shl    %cl,%ebx
  802458:	f7 64 24 04          	mull   0x4(%esp)
  80245c:	39 d6                	cmp    %edx,%esi
  80245e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802462:	89 d1                	mov    %edx,%ecx
  802464:	89 c3                	mov    %eax,%ebx
  802466:	72 08                	jb     802470 <__umoddi3+0x110>
  802468:	75 11                	jne    80247b <__umoddi3+0x11b>
  80246a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80246e:	73 0b                	jae    80247b <__umoddi3+0x11b>
  802470:	2b 44 24 04          	sub    0x4(%esp),%eax
  802474:	1b 14 24             	sbb    (%esp),%edx
  802477:	89 d1                	mov    %edx,%ecx
  802479:	89 c3                	mov    %eax,%ebx
  80247b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80247f:	29 da                	sub    %ebx,%edx
  802481:	19 ce                	sbb    %ecx,%esi
  802483:	89 f9                	mov    %edi,%ecx
  802485:	89 f0                	mov    %esi,%eax
  802487:	d3 e0                	shl    %cl,%eax
  802489:	89 e9                	mov    %ebp,%ecx
  80248b:	d3 ea                	shr    %cl,%edx
  80248d:	89 e9                	mov    %ebp,%ecx
  80248f:	d3 ee                	shr    %cl,%esi
  802491:	09 d0                	or     %edx,%eax
  802493:	89 f2                	mov    %esi,%edx
  802495:	83 c4 1c             	add    $0x1c,%esp
  802498:	5b                   	pop    %ebx
  802499:	5e                   	pop    %esi
  80249a:	5f                   	pop    %edi
  80249b:	5d                   	pop    %ebp
  80249c:	c3                   	ret    
  80249d:	8d 76 00             	lea    0x0(%esi),%esi
  8024a0:	29 f9                	sub    %edi,%ecx
  8024a2:	19 d6                	sbb    %edx,%esi
  8024a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ac:	e9 18 ff ff ff       	jmp    8023c9 <__umoddi3+0x69>
