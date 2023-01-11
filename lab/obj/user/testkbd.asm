
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
  80004e:	e8 01 12 00 00       	call   801254 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 60 25 80 00       	push   $0x802560
  800065:	6a 0f                	push   $0xf
  800067:	68 6d 25 80 00       	push   $0x80256d
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 7c 25 80 00       	push   $0x80257c
  80007b:	6a 11                	push   $0x11
  80007d:	68 6d 25 80 00       	push   $0x80256d
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 11 12 00 00       	call   8012a4 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 96 25 80 00       	push   $0x802596
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 6d 25 80 00       	push   $0x80256d
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 9e 25 80 00       	push   $0x80259e
  8000b4:	e8 38 08 00 00       	call   8008f1 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 ac 25 80 00       	push   $0x8025ac
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 c5 18 00 00       	call   801995 <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 b0 25 80 00       	push   $0x8025b0
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 b1 18 00 00       	call   801995 <fprintf>
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
  8000f9:	68 c8 25 80 00       	push   $0x8025c8
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
  8001c9:	e8 c2 11 00 00       	call   801390 <read>
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
  8001f3:	e8 32 0f 00 00       	call   80112a <fd_lookup>
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
  80021c:	e8 ba 0e 00 00       	call   8010db <fd_alloc>
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
  80025e:	e8 51 0e 00 00       	call   8010b4 <fd2num>
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
  8002b8:	e8 c2 0f 00 00       	call   80127f <close_all>
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
  8002ea:	68 e0 25 80 00       	push   $0x8025e0
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 c6 25 80 00 	movl   $0x8025c6,(%esp)
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
  800408:	e8 b3 1e 00 00       	call   8022c0 <__udivdi3>
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
  80044b:	e8 a0 1f 00 00       	call   8023f0 <__umoddi3>
  800450:	83 c4 14             	add    $0x14,%esp
  800453:	0f be 80 03 26 80 00 	movsbl 0x802603(%eax),%eax
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
  80054f:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
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
  800613:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  80061a:	85 d2                	test   %edx,%edx
  80061c:	75 18                	jne    800636 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80061e:	50                   	push   %eax
  80061f:	68 1b 26 80 00       	push   $0x80261b
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
  800637:	68 e9 29 80 00       	push   $0x8029e9
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
  80065b:	b8 14 26 80 00       	mov    $0x802614,%eax
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
  800905:	68 e9 29 80 00       	push   $0x8029e9
  80090a:	6a 01                	push   $0x1
  80090c:	e8 84 10 00 00       	call   801995 <fprintf>
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
  800945:	68 ff 28 80 00       	push   $0x8028ff
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
  800dc9:	68 0f 29 80 00       	push   $0x80290f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 2c 29 80 00       	push   $0x80292c
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
  800e4a:	68 0f 29 80 00       	push   $0x80290f
  800e4f:	6a 23                	push   $0x23
  800e51:	68 2c 29 80 00       	push   $0x80292c
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
  800e8c:	68 0f 29 80 00       	push   $0x80290f
  800e91:	6a 23                	push   $0x23
  800e93:	68 2c 29 80 00       	push   $0x80292c
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
  800ece:	68 0f 29 80 00       	push   $0x80290f
  800ed3:	6a 23                	push   $0x23
  800ed5:	68 2c 29 80 00       	push   $0x80292c
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
  800f10:	68 0f 29 80 00       	push   $0x80290f
  800f15:	6a 23                	push   $0x23
  800f17:	68 2c 29 80 00       	push   $0x80292c
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
  800f52:	68 0f 29 80 00       	push   $0x80290f
  800f57:	6a 23                	push   $0x23
  800f59:	68 2c 29 80 00       	push   $0x80292c
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
  800f94:	68 0f 29 80 00       	push   $0x80290f
  800f99:	6a 23                	push   $0x23
  800f9b:	68 2c 29 80 00       	push   $0x80292c
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
  800ff8:	68 0f 29 80 00       	push   $0x80290f
  800ffd:	6a 23                	push   $0x23
  800fff:	68 2c 29 80 00       	push   $0x80292c
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

00801030 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
  801036:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103e:	b8 0f 00 00 00       	mov    $0xf,%eax
  801043:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801046:	8b 55 08             	mov    0x8(%ebp),%edx
  801049:	89 df                	mov    %ebx,%edi
  80104b:	89 de                	mov    %ebx,%esi
  80104d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80104f:	85 c0                	test   %eax,%eax
  801051:	7e 17                	jle    80106a <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	50                   	push   %eax
  801057:	6a 0f                	push   $0xf
  801059:	68 0f 29 80 00       	push   $0x80290f
  80105e:	6a 23                	push   $0x23
  801060:	68 2c 29 80 00       	push   $0x80292c
  801065:	e8 62 f2 ff ff       	call   8002cc <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  80106a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5f                   	pop    %edi
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
  801078:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801080:	b8 10 00 00 00       	mov    $0x10,%eax
  801085:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801088:	8b 55 08             	mov    0x8(%ebp),%edx
  80108b:	89 df                	mov    %ebx,%edi
  80108d:	89 de                	mov    %ebx,%esi
  80108f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801091:	85 c0                	test   %eax,%eax
  801093:	7e 17                	jle    8010ac <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	50                   	push   %eax
  801099:	6a 10                	push   $0x10
  80109b:	68 0f 29 80 00       	push   $0x80290f
  8010a0:	6a 23                	push   $0x23
  8010a2:	68 2c 29 80 00       	push   $0x80292c
  8010a7:	e8 20 f2 ff ff       	call   8002cc <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8010ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010e6:	89 c2                	mov    %eax,%edx
  8010e8:	c1 ea 16             	shr    $0x16,%edx
  8010eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f2:	f6 c2 01             	test   $0x1,%dl
  8010f5:	74 11                	je     801108 <fd_alloc+0x2d>
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	c1 ea 0c             	shr    $0xc,%edx
  8010fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801103:	f6 c2 01             	test   $0x1,%dl
  801106:	75 09                	jne    801111 <fd_alloc+0x36>
			*fd_store = fd;
  801108:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110a:	b8 00 00 00 00       	mov    $0x0,%eax
  80110f:	eb 17                	jmp    801128 <fd_alloc+0x4d>
  801111:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801116:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80111b:	75 c9                	jne    8010e6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80111d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801123:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801130:	83 f8 1f             	cmp    $0x1f,%eax
  801133:	77 36                	ja     80116b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801135:	c1 e0 0c             	shl    $0xc,%eax
  801138:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	c1 ea 16             	shr    $0x16,%edx
  801142:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801149:	f6 c2 01             	test   $0x1,%dl
  80114c:	74 24                	je     801172 <fd_lookup+0x48>
  80114e:	89 c2                	mov    %eax,%edx
  801150:	c1 ea 0c             	shr    $0xc,%edx
  801153:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115a:	f6 c2 01             	test   $0x1,%dl
  80115d:	74 1a                	je     801179 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80115f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801162:	89 02                	mov    %eax,(%edx)
	return 0;
  801164:	b8 00 00 00 00       	mov    $0x0,%eax
  801169:	eb 13                	jmp    80117e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80116b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801170:	eb 0c                	jmp    80117e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801172:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801177:	eb 05                	jmp    80117e <fd_lookup+0x54>
  801179:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 08             	sub    $0x8,%esp
  801186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801189:	ba bc 29 80 00       	mov    $0x8029bc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80118e:	eb 13                	jmp    8011a3 <dev_lookup+0x23>
  801190:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801193:	39 08                	cmp    %ecx,(%eax)
  801195:	75 0c                	jne    8011a3 <dev_lookup+0x23>
			*dev = devtab[i];
  801197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a1:	eb 2e                	jmp    8011d1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a3:	8b 02                	mov    (%edx),%eax
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	75 e7                	jne    801190 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a9:	a1 08 44 80 00       	mov    0x804408,%eax
  8011ae:	8b 40 48             	mov    0x48(%eax),%eax
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	51                   	push   %ecx
  8011b5:	50                   	push   %eax
  8011b6:	68 3c 29 80 00       	push   $0x80293c
  8011bb:	e8 e5 f1 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  8011c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011d1:	c9                   	leave  
  8011d2:	c3                   	ret    

008011d3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	56                   	push   %esi
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 10             	sub    $0x10,%esp
  8011db:	8b 75 08             	mov    0x8(%ebp),%esi
  8011de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e4:	50                   	push   %eax
  8011e5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011eb:	c1 e8 0c             	shr    $0xc,%eax
  8011ee:	50                   	push   %eax
  8011ef:	e8 36 ff ff ff       	call   80112a <fd_lookup>
  8011f4:	83 c4 08             	add    $0x8,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 05                	js     801200 <fd_close+0x2d>
	    || fd != fd2)
  8011fb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011fe:	74 0c                	je     80120c <fd_close+0x39>
		return (must_exist ? r : 0);
  801200:	84 db                	test   %bl,%bl
  801202:	ba 00 00 00 00       	mov    $0x0,%edx
  801207:	0f 44 c2             	cmove  %edx,%eax
  80120a:	eb 41                	jmp    80124d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80120c:	83 ec 08             	sub    $0x8,%esp
  80120f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	ff 36                	pushl  (%esi)
  801215:	e8 66 ff ff ff       	call   801180 <dev_lookup>
  80121a:	89 c3                	mov    %eax,%ebx
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 1a                	js     80123d <fd_close+0x6a>
		if (dev->dev_close)
  801223:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801226:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801229:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80122e:	85 c0                	test   %eax,%eax
  801230:	74 0b                	je     80123d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	56                   	push   %esi
  801236:	ff d0                	call   *%eax
  801238:	89 c3                	mov    %eax,%ebx
  80123a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	56                   	push   %esi
  801241:	6a 00                	push   $0x0
  801243:	e8 5d fc ff ff       	call   800ea5 <sys_page_unmap>
	return r;
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	89 d8                	mov    %ebx,%eax
}
  80124d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	ff 75 08             	pushl  0x8(%ebp)
  801261:	e8 c4 fe ff ff       	call   80112a <fd_lookup>
  801266:	83 c4 08             	add    $0x8,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 10                	js     80127d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	6a 01                	push   $0x1
  801272:	ff 75 f4             	pushl  -0xc(%ebp)
  801275:	e8 59 ff ff ff       	call   8011d3 <fd_close>
  80127a:	83 c4 10             	add    $0x10,%esp
}
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <close_all>:

void
close_all(void)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	53                   	push   %ebx
  801283:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801286:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	53                   	push   %ebx
  80128f:	e8 c0 ff ff ff       	call   801254 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801294:	83 c3 01             	add    $0x1,%ebx
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	83 fb 20             	cmp    $0x20,%ebx
  80129d:	75 ec                	jne    80128b <close_all+0xc>
		close(i);
}
  80129f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	57                   	push   %edi
  8012a8:	56                   	push   %esi
  8012a9:	53                   	push   %ebx
  8012aa:	83 ec 2c             	sub    $0x2c,%esp
  8012ad:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 08             	pushl  0x8(%ebp)
  8012b7:	e8 6e fe ff ff       	call   80112a <fd_lookup>
  8012bc:	83 c4 08             	add    $0x8,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	0f 88 c1 00 00 00    	js     801388 <dup+0xe4>
		return r;
	close(newfdnum);
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	56                   	push   %esi
  8012cb:	e8 84 ff ff ff       	call   801254 <close>

	newfd = INDEX2FD(newfdnum);
  8012d0:	89 f3                	mov    %esi,%ebx
  8012d2:	c1 e3 0c             	shl    $0xc,%ebx
  8012d5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012db:	83 c4 04             	add    $0x4,%esp
  8012de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012e1:	e8 de fd ff ff       	call   8010c4 <fd2data>
  8012e6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012e8:	89 1c 24             	mov    %ebx,(%esp)
  8012eb:	e8 d4 fd ff ff       	call   8010c4 <fd2data>
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f6:	89 f8                	mov    %edi,%eax
  8012f8:	c1 e8 16             	shr    $0x16,%eax
  8012fb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801302:	a8 01                	test   $0x1,%al
  801304:	74 37                	je     80133d <dup+0x99>
  801306:	89 f8                	mov    %edi,%eax
  801308:	c1 e8 0c             	shr    $0xc,%eax
  80130b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801312:	f6 c2 01             	test   $0x1,%dl
  801315:	74 26                	je     80133d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801317:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131e:	83 ec 0c             	sub    $0xc,%esp
  801321:	25 07 0e 00 00       	and    $0xe07,%eax
  801326:	50                   	push   %eax
  801327:	ff 75 d4             	pushl  -0x2c(%ebp)
  80132a:	6a 00                	push   $0x0
  80132c:	57                   	push   %edi
  80132d:	6a 00                	push   $0x0
  80132f:	e8 2f fb ff ff       	call   800e63 <sys_page_map>
  801334:	89 c7                	mov    %eax,%edi
  801336:	83 c4 20             	add    $0x20,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 2e                	js     80136b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801340:	89 d0                	mov    %edx,%eax
  801342:	c1 e8 0c             	shr    $0xc,%eax
  801345:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80134c:	83 ec 0c             	sub    $0xc,%esp
  80134f:	25 07 0e 00 00       	and    $0xe07,%eax
  801354:	50                   	push   %eax
  801355:	53                   	push   %ebx
  801356:	6a 00                	push   $0x0
  801358:	52                   	push   %edx
  801359:	6a 00                	push   $0x0
  80135b:	e8 03 fb ff ff       	call   800e63 <sys_page_map>
  801360:	89 c7                	mov    %eax,%edi
  801362:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801365:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801367:	85 ff                	test   %edi,%edi
  801369:	79 1d                	jns    801388 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	53                   	push   %ebx
  80136f:	6a 00                	push   $0x0
  801371:	e8 2f fb ff ff       	call   800ea5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801376:	83 c4 08             	add    $0x8,%esp
  801379:	ff 75 d4             	pushl  -0x2c(%ebp)
  80137c:	6a 00                	push   $0x0
  80137e:	e8 22 fb ff ff       	call   800ea5 <sys_page_unmap>
	return r;
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	89 f8                	mov    %edi,%eax
}
  801388:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5f                   	pop    %edi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	53                   	push   %ebx
  801394:	83 ec 14             	sub    $0x14,%esp
  801397:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	53                   	push   %ebx
  80139f:	e8 86 fd ff ff       	call   80112a <fd_lookup>
  8013a4:	83 c4 08             	add    $0x8,%esp
  8013a7:	89 c2                	mov    %eax,%edx
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 6d                	js     80141a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b7:	ff 30                	pushl  (%eax)
  8013b9:	e8 c2 fd ff ff       	call   801180 <dev_lookup>
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 4c                	js     801411 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c8:	8b 42 08             	mov    0x8(%edx),%eax
  8013cb:	83 e0 03             	and    $0x3,%eax
  8013ce:	83 f8 01             	cmp    $0x1,%eax
  8013d1:	75 21                	jne    8013f4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d3:	a1 08 44 80 00       	mov    0x804408,%eax
  8013d8:	8b 40 48             	mov    0x48(%eax),%eax
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	53                   	push   %ebx
  8013df:	50                   	push   %eax
  8013e0:	68 80 29 80 00       	push   $0x802980
  8013e5:	e8 bb ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f2:	eb 26                	jmp    80141a <read+0x8a>
	}
	if (!dev->dev_read)
  8013f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f7:	8b 40 08             	mov    0x8(%eax),%eax
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	74 17                	je     801415 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013fe:	83 ec 04             	sub    $0x4,%esp
  801401:	ff 75 10             	pushl  0x10(%ebp)
  801404:	ff 75 0c             	pushl  0xc(%ebp)
  801407:	52                   	push   %edx
  801408:	ff d0                	call   *%eax
  80140a:	89 c2                	mov    %eax,%edx
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	eb 09                	jmp    80141a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801411:	89 c2                	mov    %eax,%edx
  801413:	eb 05                	jmp    80141a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801415:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80141a:	89 d0                	mov    %edx,%eax
  80141c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141f:	c9                   	leave  
  801420:	c3                   	ret    

00801421 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	57                   	push   %edi
  801425:	56                   	push   %esi
  801426:	53                   	push   %ebx
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80142d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801430:	bb 00 00 00 00       	mov    $0x0,%ebx
  801435:	eb 21                	jmp    801458 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801437:	83 ec 04             	sub    $0x4,%esp
  80143a:	89 f0                	mov    %esi,%eax
  80143c:	29 d8                	sub    %ebx,%eax
  80143e:	50                   	push   %eax
  80143f:	89 d8                	mov    %ebx,%eax
  801441:	03 45 0c             	add    0xc(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	57                   	push   %edi
  801446:	e8 45 ff ff ff       	call   801390 <read>
		if (m < 0)
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 10                	js     801462 <readn+0x41>
			return m;
		if (m == 0)
  801452:	85 c0                	test   %eax,%eax
  801454:	74 0a                	je     801460 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801456:	01 c3                	add    %eax,%ebx
  801458:	39 f3                	cmp    %esi,%ebx
  80145a:	72 db                	jb     801437 <readn+0x16>
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	eb 02                	jmp    801462 <readn+0x41>
  801460:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801462:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801465:	5b                   	pop    %ebx
  801466:	5e                   	pop    %esi
  801467:	5f                   	pop    %edi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	53                   	push   %ebx
  80146e:	83 ec 14             	sub    $0x14,%esp
  801471:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801474:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	53                   	push   %ebx
  801479:	e8 ac fc ff ff       	call   80112a <fd_lookup>
  80147e:	83 c4 08             	add    $0x8,%esp
  801481:	89 c2                	mov    %eax,%edx
  801483:	85 c0                	test   %eax,%eax
  801485:	78 68                	js     8014ef <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	ff 30                	pushl  (%eax)
  801493:	e8 e8 fc ff ff       	call   801180 <dev_lookup>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 47                	js     8014e6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a6:	75 21                	jne    8014c9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a8:	a1 08 44 80 00       	mov    0x804408,%eax
  8014ad:	8b 40 48             	mov    0x48(%eax),%eax
  8014b0:	83 ec 04             	sub    $0x4,%esp
  8014b3:	53                   	push   %ebx
  8014b4:	50                   	push   %eax
  8014b5:	68 9c 29 80 00       	push   $0x80299c
  8014ba:	e8 e6 ee ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c7:	eb 26                	jmp    8014ef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014cf:	85 d2                	test   %edx,%edx
  8014d1:	74 17                	je     8014ea <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	ff 75 10             	pushl  0x10(%ebp)
  8014d9:	ff 75 0c             	pushl  0xc(%ebp)
  8014dc:	50                   	push   %eax
  8014dd:	ff d2                	call   *%edx
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	eb 09                	jmp    8014ef <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e6:	89 c2                	mov    %eax,%edx
  8014e8:	eb 05                	jmp    8014ef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ef:	89 d0                	mov    %edx,%eax
  8014f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	ff 75 08             	pushl  0x8(%ebp)
  801503:	e8 22 fc ff ff       	call   80112a <fd_lookup>
  801508:	83 c4 08             	add    $0x8,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 0e                	js     80151d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80150f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801512:	8b 55 0c             	mov    0xc(%ebp),%edx
  801515:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801518:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	53                   	push   %ebx
  801523:	83 ec 14             	sub    $0x14,%esp
  801526:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801529:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152c:	50                   	push   %eax
  80152d:	53                   	push   %ebx
  80152e:	e8 f7 fb ff ff       	call   80112a <fd_lookup>
  801533:	83 c4 08             	add    $0x8,%esp
  801536:	89 c2                	mov    %eax,%edx
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 65                	js     8015a1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801542:	50                   	push   %eax
  801543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801546:	ff 30                	pushl  (%eax)
  801548:	e8 33 fc ff ff       	call   801180 <dev_lookup>
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 44                	js     801598 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801554:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801557:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155b:	75 21                	jne    80157e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80155d:	a1 08 44 80 00       	mov    0x804408,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801562:	8b 40 48             	mov    0x48(%eax),%eax
  801565:	83 ec 04             	sub    $0x4,%esp
  801568:	53                   	push   %ebx
  801569:	50                   	push   %eax
  80156a:	68 5c 29 80 00       	push   $0x80295c
  80156f:	e8 31 ee ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157c:	eb 23                	jmp    8015a1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80157e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801581:	8b 52 18             	mov    0x18(%edx),%edx
  801584:	85 d2                	test   %edx,%edx
  801586:	74 14                	je     80159c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	ff 75 0c             	pushl  0xc(%ebp)
  80158e:	50                   	push   %eax
  80158f:	ff d2                	call   *%edx
  801591:	89 c2                	mov    %eax,%edx
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	eb 09                	jmp    8015a1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801598:	89 c2                	mov    %eax,%edx
  80159a:	eb 05                	jmp    8015a1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80159c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015a1:	89 d0                	mov    %edx,%eax
  8015a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 14             	sub    $0x14,%esp
  8015af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	ff 75 08             	pushl  0x8(%ebp)
  8015b9:	e8 6c fb ff ff       	call   80112a <fd_lookup>
  8015be:	83 c4 08             	add    $0x8,%esp
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 58                	js     80161f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d1:	ff 30                	pushl  (%eax)
  8015d3:	e8 a8 fb ff ff       	call   801180 <dev_lookup>
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 37                	js     801616 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015e6:	74 32                	je     80161a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015eb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f2:	00 00 00 
	stat->st_isdir = 0;
  8015f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015fc:	00 00 00 
	stat->st_dev = dev;
  8015ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	53                   	push   %ebx
  801609:	ff 75 f0             	pushl  -0x10(%ebp)
  80160c:	ff 50 14             	call   *0x14(%eax)
  80160f:	89 c2                	mov    %eax,%edx
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	eb 09                	jmp    80161f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801616:	89 c2                	mov    %eax,%edx
  801618:	eb 05                	jmp    80161f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80161a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80161f:	89 d0                	mov    %edx,%eax
  801621:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	56                   	push   %esi
  80162a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	6a 00                	push   $0x0
  801630:	ff 75 08             	pushl  0x8(%ebp)
  801633:	e8 d6 01 00 00       	call   80180e <open>
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 1b                	js     80165c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	ff 75 0c             	pushl  0xc(%ebp)
  801647:	50                   	push   %eax
  801648:	e8 5b ff ff ff       	call   8015a8 <fstat>
  80164d:	89 c6                	mov    %eax,%esi
	close(fd);
  80164f:	89 1c 24             	mov    %ebx,(%esp)
  801652:	e8 fd fb ff ff       	call   801254 <close>
	return r;
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	89 f0                	mov    %esi,%eax
}
  80165c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	5d                   	pop    %ebp
  801662:	c3                   	ret    

00801663 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
  801668:	89 c6                	mov    %eax,%esi
  80166a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80166c:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801673:	75 12                	jne    801687 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801675:	83 ec 0c             	sub    $0xc,%esp
  801678:	6a 01                	push   $0x1
  80167a:	e8 c1 0b 00 00       	call   802240 <ipc_find_env>
  80167f:	a3 00 44 80 00       	mov    %eax,0x804400
  801684:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801687:	6a 07                	push   $0x7
  801689:	68 00 50 80 00       	push   $0x805000
  80168e:	56                   	push   %esi
  80168f:	ff 35 00 44 80 00    	pushl  0x804400
  801695:	e8 52 0b 00 00       	call   8021ec <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169a:	83 c4 0c             	add    $0xc,%esp
  80169d:	6a 00                	push   $0x0
  80169f:	53                   	push   %ebx
  8016a0:	6a 00                	push   $0x0
  8016a2:	e8 de 0a 00 00       	call   802185 <ipc_recv>
}
  8016a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cc:	b8 02 00 00 00       	mov    $0x2,%eax
  8016d1:	e8 8d ff ff ff       	call   801663 <fsipc>
}
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016de:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f3:	e8 6b ff ff ff       	call   801663 <fsipc>
}
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 04             	sub    $0x4,%esp
  801701:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801704:	8b 45 08             	mov    0x8(%ebp),%eax
  801707:	8b 40 0c             	mov    0xc(%eax),%eax
  80170a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80170f:	ba 00 00 00 00       	mov    $0x0,%edx
  801714:	b8 05 00 00 00       	mov    $0x5,%eax
  801719:	e8 45 ff ff ff       	call   801663 <fsipc>
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 2c                	js     80174e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801722:	83 ec 08             	sub    $0x8,%esp
  801725:	68 00 50 80 00       	push   $0x805000
  80172a:	53                   	push   %ebx
  80172b:	e8 ed f2 ff ff       	call   800a1d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801730:	a1 80 50 80 00       	mov    0x805080,%eax
  801735:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173b:	a1 84 50 80 00       	mov    0x805084,%eax
  801740:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	83 ec 0c             	sub    $0xc,%esp
  801759:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80175c:	8b 55 08             	mov    0x8(%ebp),%edx
  80175f:	8b 52 0c             	mov    0xc(%edx),%edx
  801762:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801768:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80176d:	50                   	push   %eax
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	68 08 50 80 00       	push   $0x805008
  801776:	e8 34 f4 ff ff       	call   800baf <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
  801780:	b8 04 00 00 00       	mov    $0x4,%eax
  801785:	e8 d9 fe ff ff       	call   801663 <fsipc>

}
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801794:	8b 45 08             	mov    0x8(%ebp),%eax
  801797:	8b 40 0c             	mov    0xc(%eax),%eax
  80179a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80179f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017aa:	b8 03 00 00 00       	mov    $0x3,%eax
  8017af:	e8 af fe ff ff       	call   801663 <fsipc>
  8017b4:	89 c3                	mov    %eax,%ebx
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	78 4b                	js     801805 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017ba:	39 c6                	cmp    %eax,%esi
  8017bc:	73 16                	jae    8017d4 <devfile_read+0x48>
  8017be:	68 d0 29 80 00       	push   $0x8029d0
  8017c3:	68 d7 29 80 00       	push   $0x8029d7
  8017c8:	6a 7c                	push   $0x7c
  8017ca:	68 ec 29 80 00       	push   $0x8029ec
  8017cf:	e8 f8 ea ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  8017d4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d9:	7e 16                	jle    8017f1 <devfile_read+0x65>
  8017db:	68 f7 29 80 00       	push   $0x8029f7
  8017e0:	68 d7 29 80 00       	push   $0x8029d7
  8017e5:	6a 7d                	push   $0x7d
  8017e7:	68 ec 29 80 00       	push   $0x8029ec
  8017ec:	e8 db ea ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017f1:	83 ec 04             	sub    $0x4,%esp
  8017f4:	50                   	push   %eax
  8017f5:	68 00 50 80 00       	push   $0x805000
  8017fa:	ff 75 0c             	pushl  0xc(%ebp)
  8017fd:	e8 ad f3 ff ff       	call   800baf <memmove>
	return r;
  801802:	83 c4 10             	add    $0x10,%esp
}
  801805:	89 d8                	mov    %ebx,%eax
  801807:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 20             	sub    $0x20,%esp
  801815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801818:	53                   	push   %ebx
  801819:	e8 c6 f1 ff ff       	call   8009e4 <strlen>
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801826:	7f 67                	jg     80188f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801828:	83 ec 0c             	sub    $0xc,%esp
  80182b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182e:	50                   	push   %eax
  80182f:	e8 a7 f8 ff ff       	call   8010db <fd_alloc>
  801834:	83 c4 10             	add    $0x10,%esp
		return r;
  801837:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 57                	js     801894 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80183d:	83 ec 08             	sub    $0x8,%esp
  801840:	53                   	push   %ebx
  801841:	68 00 50 80 00       	push   $0x805000
  801846:	e8 d2 f1 ff ff       	call   800a1d <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801853:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801856:	b8 01 00 00 00       	mov    $0x1,%eax
  80185b:	e8 03 fe ff ff       	call   801663 <fsipc>
  801860:	89 c3                	mov    %eax,%ebx
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	85 c0                	test   %eax,%eax
  801867:	79 14                	jns    80187d <open+0x6f>
		fd_close(fd, 0);
  801869:	83 ec 08             	sub    $0x8,%esp
  80186c:	6a 00                	push   $0x0
  80186e:	ff 75 f4             	pushl  -0xc(%ebp)
  801871:	e8 5d f9 ff ff       	call   8011d3 <fd_close>
		return r;
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	89 da                	mov    %ebx,%edx
  80187b:	eb 17                	jmp    801894 <open+0x86>
	}

	return fd2num(fd);
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	ff 75 f4             	pushl  -0xc(%ebp)
  801883:	e8 2c f8 ff ff       	call   8010b4 <fd2num>
  801888:	89 c2                	mov    %eax,%edx
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	eb 05                	jmp    801894 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801894:	89 d0                	mov    %edx,%eax
  801896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8018ab:	e8 b3 fd ff ff       	call   801663 <fsipc>
}
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8018b2:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018b6:	7e 37                	jle    8018ef <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	53                   	push   %ebx
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018c1:	ff 70 04             	pushl  0x4(%eax)
  8018c4:	8d 40 10             	lea    0x10(%eax),%eax
  8018c7:	50                   	push   %eax
  8018c8:	ff 33                	pushl  (%ebx)
  8018ca:	e8 9b fb ff ff       	call   80146a <write>
		if (result > 0)
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	7e 03                	jle    8018d9 <writebuf+0x27>
			b->result += result;
  8018d6:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018d9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018dc:	74 0d                	je     8018eb <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e5:	0f 4f c2             	cmovg  %edx,%eax
  8018e8:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ee:	c9                   	leave  
  8018ef:	f3 c3                	repz ret 

008018f1 <putch>:

static void
putch(int ch, void *thunk)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 04             	sub    $0x4,%esp
  8018f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018fb:	8b 53 04             	mov    0x4(%ebx),%edx
  8018fe:	8d 42 01             	lea    0x1(%edx),%eax
  801901:	89 43 04             	mov    %eax,0x4(%ebx)
  801904:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801907:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80190b:	3d 00 01 00 00       	cmp    $0x100,%eax
  801910:	75 0e                	jne    801920 <putch+0x2f>
		writebuf(b);
  801912:	89 d8                	mov    %ebx,%eax
  801914:	e8 99 ff ff ff       	call   8018b2 <writebuf>
		b->idx = 0;
  801919:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801920:	83 c4 04             	add    $0x4,%esp
  801923:	5b                   	pop    %ebx
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801938:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80193f:	00 00 00 
	b.result = 0;
  801942:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801949:	00 00 00 
	b.error = 1;
  80194c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801953:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801956:	ff 75 10             	pushl  0x10(%ebp)
  801959:	ff 75 0c             	pushl  0xc(%ebp)
  80195c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801962:	50                   	push   %eax
  801963:	68 f1 18 80 00       	push   $0x8018f1
  801968:	e8 6f eb ff ff       	call   8004dc <vprintfmt>
	if (b.idx > 0)
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801977:	7e 0b                	jle    801984 <vfprintf+0x5e>
		writebuf(&b);
  801979:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80197f:	e8 2e ff ff ff       	call   8018b2 <writebuf>

	return (b.result ? b.result : b.error);
  801984:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80198a:	85 c0                	test   %eax,%eax
  80198c:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80199b:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80199e:	50                   	push   %eax
  80199f:	ff 75 0c             	pushl  0xc(%ebp)
  8019a2:	ff 75 08             	pushl  0x8(%ebp)
  8019a5:	e8 7c ff ff ff       	call   801926 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <printf>:

int
printf(const char *fmt, ...)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019b5:	50                   	push   %eax
  8019b6:	ff 75 08             	pushl  0x8(%ebp)
  8019b9:	6a 01                	push   $0x1
  8019bb:	e8 66 ff ff ff       	call   801926 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019c8:	68 03 2a 80 00       	push   $0x802a03
  8019cd:	ff 75 0c             	pushl  0xc(%ebp)
  8019d0:	e8 48 f0 ff ff       	call   800a1d <strcpy>
	return 0;
}
  8019d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	53                   	push   %ebx
  8019e0:	83 ec 10             	sub    $0x10,%esp
  8019e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019e6:	53                   	push   %ebx
  8019e7:	e8 8d 08 00 00       	call   802279 <pageref>
  8019ec:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019ef:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019f4:	83 f8 01             	cmp    $0x1,%eax
  8019f7:	75 10                	jne    801a09 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	ff 73 0c             	pushl  0xc(%ebx)
  8019ff:	e8 c0 02 00 00       	call   801cc4 <nsipc_close>
  801a04:	89 c2                	mov    %eax,%edx
  801a06:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a09:	89 d0                	mov    %edx,%eax
  801a0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a16:	6a 00                	push   $0x0
  801a18:	ff 75 10             	pushl  0x10(%ebp)
  801a1b:	ff 75 0c             	pushl  0xc(%ebp)
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	ff 70 0c             	pushl  0xc(%eax)
  801a24:	e8 78 03 00 00       	call   801da1 <nsipc_send>
}
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a31:	6a 00                	push   $0x0
  801a33:	ff 75 10             	pushl  0x10(%ebp)
  801a36:	ff 75 0c             	pushl  0xc(%ebp)
  801a39:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3c:	ff 70 0c             	pushl  0xc(%eax)
  801a3f:	e8 f1 02 00 00       	call   801d35 <nsipc_recv>
}
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a4c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a4f:	52                   	push   %edx
  801a50:	50                   	push   %eax
  801a51:	e8 d4 f6 ff ff       	call   80112a <fd_lookup>
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	78 17                	js     801a74 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a60:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801a66:	39 08                	cmp    %ecx,(%eax)
  801a68:	75 05                	jne    801a6f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6d:	eb 05                	jmp    801a74 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a6f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	56                   	push   %esi
  801a7a:	53                   	push   %ebx
  801a7b:	83 ec 1c             	sub    $0x1c,%esp
  801a7e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a83:	50                   	push   %eax
  801a84:	e8 52 f6 ff ff       	call   8010db <fd_alloc>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 1b                	js     801aad <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a92:	83 ec 04             	sub    $0x4,%esp
  801a95:	68 07 04 00 00       	push   $0x407
  801a9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9d:	6a 00                	push   $0x0
  801a9f:	e8 7c f3 ff ff       	call   800e20 <sys_page_alloc>
  801aa4:	89 c3                	mov    %eax,%ebx
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	79 10                	jns    801abd <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	56                   	push   %esi
  801ab1:	e8 0e 02 00 00       	call   801cc4 <nsipc_close>
		return r;
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	89 d8                	mov    %ebx,%eax
  801abb:	eb 24                	jmp    801ae1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801abd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ad2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	50                   	push   %eax
  801ad9:	e8 d6 f5 ff ff       	call   8010b4 <fd2num>
  801ade:	83 c4 10             	add    $0x10,%esp
}
  801ae1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    

00801ae8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aee:	8b 45 08             	mov    0x8(%ebp),%eax
  801af1:	e8 50 ff ff ff       	call   801a46 <fd2sockid>
		return r;
  801af6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af8:	85 c0                	test   %eax,%eax
  801afa:	78 1f                	js     801b1b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801afc:	83 ec 04             	sub    $0x4,%esp
  801aff:	ff 75 10             	pushl  0x10(%ebp)
  801b02:	ff 75 0c             	pushl  0xc(%ebp)
  801b05:	50                   	push   %eax
  801b06:	e8 12 01 00 00       	call   801c1d <nsipc_accept>
  801b0b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b0e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 07                	js     801b1b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b14:	e8 5d ff ff ff       	call   801a76 <alloc_sockfd>
  801b19:	89 c1                	mov    %eax,%ecx
}
  801b1b:	89 c8                	mov    %ecx,%eax
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	e8 19 ff ff ff       	call   801a46 <fd2sockid>
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 12                	js     801b43 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b31:	83 ec 04             	sub    $0x4,%esp
  801b34:	ff 75 10             	pushl  0x10(%ebp)
  801b37:	ff 75 0c             	pushl  0xc(%ebp)
  801b3a:	50                   	push   %eax
  801b3b:	e8 2d 01 00 00       	call   801c6d <nsipc_bind>
  801b40:	83 c4 10             	add    $0x10,%esp
}
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    

00801b45 <shutdown>:

int
shutdown(int s, int how)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	e8 f3 fe ff ff       	call   801a46 <fd2sockid>
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 0f                	js     801b66 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b57:	83 ec 08             	sub    $0x8,%esp
  801b5a:	ff 75 0c             	pushl  0xc(%ebp)
  801b5d:	50                   	push   %eax
  801b5e:	e8 3f 01 00 00       	call   801ca2 <nsipc_shutdown>
  801b63:	83 c4 10             	add    $0x10,%esp
}
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b71:	e8 d0 fe ff ff       	call   801a46 <fd2sockid>
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 12                	js     801b8c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b7a:	83 ec 04             	sub    $0x4,%esp
  801b7d:	ff 75 10             	pushl  0x10(%ebp)
  801b80:	ff 75 0c             	pushl  0xc(%ebp)
  801b83:	50                   	push   %eax
  801b84:	e8 55 01 00 00       	call   801cde <nsipc_connect>
  801b89:	83 c4 10             	add    $0x10,%esp
}
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <listen>:

int
listen(int s, int backlog)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b94:	8b 45 08             	mov    0x8(%ebp),%eax
  801b97:	e8 aa fe ff ff       	call   801a46 <fd2sockid>
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	78 0f                	js     801baf <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ba0:	83 ec 08             	sub    $0x8,%esp
  801ba3:	ff 75 0c             	pushl  0xc(%ebp)
  801ba6:	50                   	push   %eax
  801ba7:	e8 67 01 00 00       	call   801d13 <nsipc_listen>
  801bac:	83 c4 10             	add    $0x10,%esp
}
  801baf:	c9                   	leave  
  801bb0:	c3                   	ret    

00801bb1 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bb7:	ff 75 10             	pushl  0x10(%ebp)
  801bba:	ff 75 0c             	pushl  0xc(%ebp)
  801bbd:	ff 75 08             	pushl  0x8(%ebp)
  801bc0:	e8 3a 02 00 00       	call   801dff <nsipc_socket>
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 05                	js     801bd1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bcc:	e8 a5 fe ff ff       	call   801a76 <alloc_sockfd>
}
  801bd1:	c9                   	leave  
  801bd2:	c3                   	ret    

00801bd3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 04             	sub    $0x4,%esp
  801bda:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bdc:	83 3d 04 44 80 00 00 	cmpl   $0x0,0x804404
  801be3:	75 12                	jne    801bf7 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	6a 02                	push   $0x2
  801bea:	e8 51 06 00 00       	call   802240 <ipc_find_env>
  801bef:	a3 04 44 80 00       	mov    %eax,0x804404
  801bf4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bf7:	6a 07                	push   $0x7
  801bf9:	68 00 60 80 00       	push   $0x806000
  801bfe:	53                   	push   %ebx
  801bff:	ff 35 04 44 80 00    	pushl  0x804404
  801c05:	e8 e2 05 00 00       	call   8021ec <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c0a:	83 c4 0c             	add    $0xc,%esp
  801c0d:	6a 00                	push   $0x0
  801c0f:	6a 00                	push   $0x0
  801c11:	6a 00                	push   $0x0
  801c13:	e8 6d 05 00 00       	call   802185 <ipc_recv>
}
  801c18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c2d:	8b 06                	mov    (%esi),%eax
  801c2f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c34:	b8 01 00 00 00       	mov    $0x1,%eax
  801c39:	e8 95 ff ff ff       	call   801bd3 <nsipc>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 20                	js     801c64 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c44:	83 ec 04             	sub    $0x4,%esp
  801c47:	ff 35 10 60 80 00    	pushl  0x806010
  801c4d:	68 00 60 80 00       	push   $0x806000
  801c52:	ff 75 0c             	pushl  0xc(%ebp)
  801c55:	e8 55 ef ff ff       	call   800baf <memmove>
		*addrlen = ret->ret_addrlen;
  801c5a:	a1 10 60 80 00       	mov    0x806010,%eax
  801c5f:	89 06                	mov    %eax,(%esi)
  801c61:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c64:	89 d8                	mov    %ebx,%eax
  801c66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	53                   	push   %ebx
  801c71:	83 ec 08             	sub    $0x8,%esp
  801c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c7f:	53                   	push   %ebx
  801c80:	ff 75 0c             	pushl  0xc(%ebp)
  801c83:	68 04 60 80 00       	push   $0x806004
  801c88:	e8 22 ef ff ff       	call   800baf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c8d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c93:	b8 02 00 00 00       	mov    $0x2,%eax
  801c98:	e8 36 ff ff ff       	call   801bd3 <nsipc>
}
  801c9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cb8:	b8 03 00 00 00       	mov    $0x3,%eax
  801cbd:	e8 11 ff ff ff       	call   801bd3 <nsipc>
}
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <nsipc_close>:

int
nsipc_close(int s)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccd:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cd2:	b8 04 00 00 00       	mov    $0x4,%eax
  801cd7:	e8 f7 fe ff ff       	call   801bd3 <nsipc>
}
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	53                   	push   %ebx
  801ce2:	83 ec 08             	sub    $0x8,%esp
  801ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cf0:	53                   	push   %ebx
  801cf1:	ff 75 0c             	pushl  0xc(%ebp)
  801cf4:	68 04 60 80 00       	push   $0x806004
  801cf9:	e8 b1 ee ff ff       	call   800baf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cfe:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d04:	b8 05 00 00 00       	mov    $0x5,%eax
  801d09:	e8 c5 fe ff ff       	call   801bd3 <nsipc>
}
  801d0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d24:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d29:	b8 06 00 00 00       	mov    $0x6,%eax
  801d2e:	e8 a0 fe ff ff       	call   801bd3 <nsipc>
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	56                   	push   %esi
  801d39:	53                   	push   %ebx
  801d3a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d40:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d45:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d4b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d4e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d53:	b8 07 00 00 00       	mov    $0x7,%eax
  801d58:	e8 76 fe ff ff       	call   801bd3 <nsipc>
  801d5d:	89 c3                	mov    %eax,%ebx
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	78 35                	js     801d98 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d63:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d68:	7f 04                	jg     801d6e <nsipc_recv+0x39>
  801d6a:	39 c6                	cmp    %eax,%esi
  801d6c:	7d 16                	jge    801d84 <nsipc_recv+0x4f>
  801d6e:	68 0f 2a 80 00       	push   $0x802a0f
  801d73:	68 d7 29 80 00       	push   $0x8029d7
  801d78:	6a 62                	push   $0x62
  801d7a:	68 24 2a 80 00       	push   $0x802a24
  801d7f:	e8 48 e5 ff ff       	call   8002cc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d84:	83 ec 04             	sub    $0x4,%esp
  801d87:	50                   	push   %eax
  801d88:	68 00 60 80 00       	push   $0x806000
  801d8d:	ff 75 0c             	pushl  0xc(%ebp)
  801d90:	e8 1a ee ff ff       	call   800baf <memmove>
  801d95:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5d                   	pop    %ebp
  801da0:	c3                   	ret    

00801da1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	53                   	push   %ebx
  801da5:	83 ec 04             	sub    $0x4,%esp
  801da8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dab:	8b 45 08             	mov    0x8(%ebp),%eax
  801dae:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801db3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801db9:	7e 16                	jle    801dd1 <nsipc_send+0x30>
  801dbb:	68 30 2a 80 00       	push   $0x802a30
  801dc0:	68 d7 29 80 00       	push   $0x8029d7
  801dc5:	6a 6d                	push   $0x6d
  801dc7:	68 24 2a 80 00       	push   $0x802a24
  801dcc:	e8 fb e4 ff ff       	call   8002cc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dd1:	83 ec 04             	sub    $0x4,%esp
  801dd4:	53                   	push   %ebx
  801dd5:	ff 75 0c             	pushl  0xc(%ebp)
  801dd8:	68 0c 60 80 00       	push   $0x80600c
  801ddd:	e8 cd ed ff ff       	call   800baf <memmove>
	nsipcbuf.send.req_size = size;
  801de2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801de8:	8b 45 14             	mov    0x14(%ebp),%eax
  801deb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801df0:	b8 08 00 00 00       	mov    $0x8,%eax
  801df5:	e8 d9 fd ff ff       	call   801bd3 <nsipc>
}
  801dfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e05:	8b 45 08             	mov    0x8(%ebp),%eax
  801e08:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e10:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e15:	8b 45 10             	mov    0x10(%ebp),%eax
  801e18:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e1d:	b8 09 00 00 00       	mov    $0x9,%eax
  801e22:	e8 ac fd ff ff       	call   801bd3 <nsipc>
}
  801e27:	c9                   	leave  
  801e28:	c3                   	ret    

00801e29 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	56                   	push   %esi
  801e2d:	53                   	push   %ebx
  801e2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e31:	83 ec 0c             	sub    $0xc,%esp
  801e34:	ff 75 08             	pushl  0x8(%ebp)
  801e37:	e8 88 f2 ff ff       	call   8010c4 <fd2data>
  801e3c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e3e:	83 c4 08             	add    $0x8,%esp
  801e41:	68 3c 2a 80 00       	push   $0x802a3c
  801e46:	53                   	push   %ebx
  801e47:	e8 d1 eb ff ff       	call   800a1d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e4c:	8b 46 04             	mov    0x4(%esi),%eax
  801e4f:	2b 06                	sub    (%esi),%eax
  801e51:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e57:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e5e:	00 00 00 
	stat->st_dev = &devpipe;
  801e61:	c7 83 88 00 00 00 58 	movl   $0x803058,0x88(%ebx)
  801e68:	30 80 00 
	return 0;
}
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5d                   	pop    %ebp
  801e76:	c3                   	ret    

00801e77 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	53                   	push   %ebx
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e81:	53                   	push   %ebx
  801e82:	6a 00                	push   $0x0
  801e84:	e8 1c f0 ff ff       	call   800ea5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e89:	89 1c 24             	mov    %ebx,(%esp)
  801e8c:	e8 33 f2 ff ff       	call   8010c4 <fd2data>
  801e91:	83 c4 08             	add    $0x8,%esp
  801e94:	50                   	push   %eax
  801e95:	6a 00                	push   $0x0
  801e97:	e8 09 f0 ff ff       	call   800ea5 <sys_page_unmap>
}
  801e9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	57                   	push   %edi
  801ea5:	56                   	push   %esi
  801ea6:	53                   	push   %ebx
  801ea7:	83 ec 1c             	sub    $0x1c,%esp
  801eaa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ead:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801eaf:	a1 08 44 80 00       	mov    0x804408,%eax
  801eb4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801eb7:	83 ec 0c             	sub    $0xc,%esp
  801eba:	ff 75 e0             	pushl  -0x20(%ebp)
  801ebd:	e8 b7 03 00 00       	call   802279 <pageref>
  801ec2:	89 c3                	mov    %eax,%ebx
  801ec4:	89 3c 24             	mov    %edi,(%esp)
  801ec7:	e8 ad 03 00 00       	call   802279 <pageref>
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	39 c3                	cmp    %eax,%ebx
  801ed1:	0f 94 c1             	sete   %cl
  801ed4:	0f b6 c9             	movzbl %cl,%ecx
  801ed7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801eda:	8b 15 08 44 80 00    	mov    0x804408,%edx
  801ee0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ee3:	39 ce                	cmp    %ecx,%esi
  801ee5:	74 1b                	je     801f02 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ee7:	39 c3                	cmp    %eax,%ebx
  801ee9:	75 c4                	jne    801eaf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eeb:	8b 42 58             	mov    0x58(%edx),%eax
  801eee:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ef1:	50                   	push   %eax
  801ef2:	56                   	push   %esi
  801ef3:	68 43 2a 80 00       	push   $0x802a43
  801ef8:	e8 a8 e4 ff ff       	call   8003a5 <cprintf>
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	eb ad                	jmp    801eaf <_pipeisclosed+0xe>
	}
}
  801f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5f                   	pop    %edi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    

00801f0d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	57                   	push   %edi
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	83 ec 28             	sub    $0x28,%esp
  801f16:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f19:	56                   	push   %esi
  801f1a:	e8 a5 f1 ff ff       	call   8010c4 <fd2data>
  801f1f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	bf 00 00 00 00       	mov    $0x0,%edi
  801f29:	eb 4b                	jmp    801f76 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f2b:	89 da                	mov    %ebx,%edx
  801f2d:	89 f0                	mov    %esi,%eax
  801f2f:	e8 6d ff ff ff       	call   801ea1 <_pipeisclosed>
  801f34:	85 c0                	test   %eax,%eax
  801f36:	75 48                	jne    801f80 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f38:	e8 c4 ee ff ff       	call   800e01 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f3d:	8b 43 04             	mov    0x4(%ebx),%eax
  801f40:	8b 0b                	mov    (%ebx),%ecx
  801f42:	8d 51 20             	lea    0x20(%ecx),%edx
  801f45:	39 d0                	cmp    %edx,%eax
  801f47:	73 e2                	jae    801f2b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f4c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f50:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f53:	89 c2                	mov    %eax,%edx
  801f55:	c1 fa 1f             	sar    $0x1f,%edx
  801f58:	89 d1                	mov    %edx,%ecx
  801f5a:	c1 e9 1b             	shr    $0x1b,%ecx
  801f5d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f60:	83 e2 1f             	and    $0x1f,%edx
  801f63:	29 ca                	sub    %ecx,%edx
  801f65:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f69:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f6d:	83 c0 01             	add    $0x1,%eax
  801f70:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f73:	83 c7 01             	add    $0x1,%edi
  801f76:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f79:	75 c2                	jne    801f3d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f7e:	eb 05                	jmp    801f85 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f80:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f88:	5b                   	pop    %ebx
  801f89:	5e                   	pop    %esi
  801f8a:	5f                   	pop    %edi
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    

00801f8d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	57                   	push   %edi
  801f91:	56                   	push   %esi
  801f92:	53                   	push   %ebx
  801f93:	83 ec 18             	sub    $0x18,%esp
  801f96:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f99:	57                   	push   %edi
  801f9a:	e8 25 f1 ff ff       	call   8010c4 <fd2data>
  801f9f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fa9:	eb 3d                	jmp    801fe8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fab:	85 db                	test   %ebx,%ebx
  801fad:	74 04                	je     801fb3 <devpipe_read+0x26>
				return i;
  801faf:	89 d8                	mov    %ebx,%eax
  801fb1:	eb 44                	jmp    801ff7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fb3:	89 f2                	mov    %esi,%edx
  801fb5:	89 f8                	mov    %edi,%eax
  801fb7:	e8 e5 fe ff ff       	call   801ea1 <_pipeisclosed>
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	75 32                	jne    801ff2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fc0:	e8 3c ee ff ff       	call   800e01 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fc5:	8b 06                	mov    (%esi),%eax
  801fc7:	3b 46 04             	cmp    0x4(%esi),%eax
  801fca:	74 df                	je     801fab <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fcc:	99                   	cltd   
  801fcd:	c1 ea 1b             	shr    $0x1b,%edx
  801fd0:	01 d0                	add    %edx,%eax
  801fd2:	83 e0 1f             	and    $0x1f,%eax
  801fd5:	29 d0                	sub    %edx,%eax
  801fd7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fdf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fe2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe5:	83 c3 01             	add    $0x1,%ebx
  801fe8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801feb:	75 d8                	jne    801fc5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fed:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff0:	eb 05                	jmp    801ff7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ff2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ff7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffa:	5b                   	pop    %ebx
  801ffb:	5e                   	pop    %esi
  801ffc:	5f                   	pop    %edi
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    

00801fff <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802007:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200a:	50                   	push   %eax
  80200b:	e8 cb f0 ff ff       	call   8010db <fd_alloc>
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	89 c2                	mov    %eax,%edx
  802015:	85 c0                	test   %eax,%eax
  802017:	0f 88 2c 01 00 00    	js     802149 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201d:	83 ec 04             	sub    $0x4,%esp
  802020:	68 07 04 00 00       	push   $0x407
  802025:	ff 75 f4             	pushl  -0xc(%ebp)
  802028:	6a 00                	push   $0x0
  80202a:	e8 f1 ed ff ff       	call   800e20 <sys_page_alloc>
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	89 c2                	mov    %eax,%edx
  802034:	85 c0                	test   %eax,%eax
  802036:	0f 88 0d 01 00 00    	js     802149 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80203c:	83 ec 0c             	sub    $0xc,%esp
  80203f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802042:	50                   	push   %eax
  802043:	e8 93 f0 ff ff       	call   8010db <fd_alloc>
  802048:	89 c3                	mov    %eax,%ebx
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	85 c0                	test   %eax,%eax
  80204f:	0f 88 e2 00 00 00    	js     802137 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802055:	83 ec 04             	sub    $0x4,%esp
  802058:	68 07 04 00 00       	push   $0x407
  80205d:	ff 75 f0             	pushl  -0x10(%ebp)
  802060:	6a 00                	push   $0x0
  802062:	e8 b9 ed ff ff       	call   800e20 <sys_page_alloc>
  802067:	89 c3                	mov    %eax,%ebx
  802069:	83 c4 10             	add    $0x10,%esp
  80206c:	85 c0                	test   %eax,%eax
  80206e:	0f 88 c3 00 00 00    	js     802137 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802074:	83 ec 0c             	sub    $0xc,%esp
  802077:	ff 75 f4             	pushl  -0xc(%ebp)
  80207a:	e8 45 f0 ff ff       	call   8010c4 <fd2data>
  80207f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802081:	83 c4 0c             	add    $0xc,%esp
  802084:	68 07 04 00 00       	push   $0x407
  802089:	50                   	push   %eax
  80208a:	6a 00                	push   $0x0
  80208c:	e8 8f ed ff ff       	call   800e20 <sys_page_alloc>
  802091:	89 c3                	mov    %eax,%ebx
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	85 c0                	test   %eax,%eax
  802098:	0f 88 89 00 00 00    	js     802127 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209e:	83 ec 0c             	sub    $0xc,%esp
  8020a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a4:	e8 1b f0 ff ff       	call   8010c4 <fd2data>
  8020a9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020b0:	50                   	push   %eax
  8020b1:	6a 00                	push   $0x0
  8020b3:	56                   	push   %esi
  8020b4:	6a 00                	push   $0x0
  8020b6:	e8 a8 ed ff ff       	call   800e63 <sys_page_map>
  8020bb:	89 c3                	mov    %eax,%ebx
  8020bd:	83 c4 20             	add    $0x20,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	78 55                	js     802119 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020c4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020d9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020e2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020e7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020ee:	83 ec 0c             	sub    $0xc,%esp
  8020f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f4:	e8 bb ef ff ff       	call   8010b4 <fd2num>
  8020f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020fc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020fe:	83 c4 04             	add    $0x4,%esp
  802101:	ff 75 f0             	pushl  -0x10(%ebp)
  802104:	e8 ab ef ff ff       	call   8010b4 <fd2num>
  802109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80210c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	ba 00 00 00 00       	mov    $0x0,%edx
  802117:	eb 30                	jmp    802149 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802119:	83 ec 08             	sub    $0x8,%esp
  80211c:	56                   	push   %esi
  80211d:	6a 00                	push   $0x0
  80211f:	e8 81 ed ff ff       	call   800ea5 <sys_page_unmap>
  802124:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802127:	83 ec 08             	sub    $0x8,%esp
  80212a:	ff 75 f0             	pushl  -0x10(%ebp)
  80212d:	6a 00                	push   $0x0
  80212f:	e8 71 ed ff ff       	call   800ea5 <sys_page_unmap>
  802134:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802137:	83 ec 08             	sub    $0x8,%esp
  80213a:	ff 75 f4             	pushl  -0xc(%ebp)
  80213d:	6a 00                	push   $0x0
  80213f:	e8 61 ed ff ff       	call   800ea5 <sys_page_unmap>
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802149:	89 d0                	mov    %edx,%eax
  80214b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214e:	5b                   	pop    %ebx
  80214f:	5e                   	pop    %esi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    

00802152 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802152:	55                   	push   %ebp
  802153:	89 e5                	mov    %esp,%ebp
  802155:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802158:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80215b:	50                   	push   %eax
  80215c:	ff 75 08             	pushl  0x8(%ebp)
  80215f:	e8 c6 ef ff ff       	call   80112a <fd_lookup>
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	85 c0                	test   %eax,%eax
  802169:	78 18                	js     802183 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80216b:	83 ec 0c             	sub    $0xc,%esp
  80216e:	ff 75 f4             	pushl  -0xc(%ebp)
  802171:	e8 4e ef ff ff       	call   8010c4 <fd2data>
	return _pipeisclosed(fd, p);
  802176:	89 c2                	mov    %eax,%edx
  802178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217b:	e8 21 fd ff ff       	call   801ea1 <_pipeisclosed>
  802180:	83 c4 10             	add    $0x10,%esp
}
  802183:	c9                   	leave  
  802184:	c3                   	ret    

00802185 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802185:	55                   	push   %ebp
  802186:	89 e5                	mov    %esp,%ebp
  802188:	56                   	push   %esi
  802189:	53                   	push   %ebx
  80218a:	8b 75 08             	mov    0x8(%ebp),%esi
  80218d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802190:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802193:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802195:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80219a:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80219d:	83 ec 0c             	sub    $0xc,%esp
  8021a0:	50                   	push   %eax
  8021a1:	e8 2a ee ff ff       	call   800fd0 <sys_ipc_recv>

	if (from_env_store != NULL)
  8021a6:	83 c4 10             	add    $0x10,%esp
  8021a9:	85 f6                	test   %esi,%esi
  8021ab:	74 14                	je     8021c1 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8021ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8021b2:	85 c0                	test   %eax,%eax
  8021b4:	78 09                	js     8021bf <ipc_recv+0x3a>
  8021b6:	8b 15 08 44 80 00    	mov    0x804408,%edx
  8021bc:	8b 52 74             	mov    0x74(%edx),%edx
  8021bf:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8021c1:	85 db                	test   %ebx,%ebx
  8021c3:	74 14                	je     8021d9 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8021c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8021ca:	85 c0                	test   %eax,%eax
  8021cc:	78 09                	js     8021d7 <ipc_recv+0x52>
  8021ce:	8b 15 08 44 80 00    	mov    0x804408,%edx
  8021d4:	8b 52 78             	mov    0x78(%edx),%edx
  8021d7:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	78 08                	js     8021e5 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8021dd:	a1 08 44 80 00       	mov    0x804408,%eax
  8021e2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    

008021ec <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	57                   	push   %edi
  8021f0:	56                   	push   %esi
  8021f1:	53                   	push   %ebx
  8021f2:	83 ec 0c             	sub    $0xc,%esp
  8021f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8021fe:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802200:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802205:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802208:	ff 75 14             	pushl  0x14(%ebp)
  80220b:	53                   	push   %ebx
  80220c:	56                   	push   %esi
  80220d:	57                   	push   %edi
  80220e:	e8 9a ed ff ff       	call   800fad <sys_ipc_try_send>

		if (err < 0) {
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	85 c0                	test   %eax,%eax
  802218:	79 1e                	jns    802238 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80221a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80221d:	75 07                	jne    802226 <ipc_send+0x3a>
				sys_yield();
  80221f:	e8 dd eb ff ff       	call   800e01 <sys_yield>
  802224:	eb e2                	jmp    802208 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802226:	50                   	push   %eax
  802227:	68 5b 2a 80 00       	push   $0x802a5b
  80222c:	6a 49                	push   $0x49
  80222e:	68 68 2a 80 00       	push   $0x802a68
  802233:	e8 94 e0 ff ff       	call   8002cc <_panic>
		}

	} while (err < 0);

}
  802238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80223b:	5b                   	pop    %ebx
  80223c:	5e                   	pop    %esi
  80223d:	5f                   	pop    %edi
  80223e:	5d                   	pop    %ebp
  80223f:	c3                   	ret    

00802240 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802246:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80224b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80224e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802254:	8b 52 50             	mov    0x50(%edx),%edx
  802257:	39 ca                	cmp    %ecx,%edx
  802259:	75 0d                	jne    802268 <ipc_find_env+0x28>
			return envs[i].env_id;
  80225b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80225e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802263:	8b 40 48             	mov    0x48(%eax),%eax
  802266:	eb 0f                	jmp    802277 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802268:	83 c0 01             	add    $0x1,%eax
  80226b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802270:	75 d9                	jne    80224b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802272:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    

00802279 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80227f:	89 d0                	mov    %edx,%eax
  802281:	c1 e8 16             	shr    $0x16,%eax
  802284:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80228b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802290:	f6 c1 01             	test   $0x1,%cl
  802293:	74 1d                	je     8022b2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802295:	c1 ea 0c             	shr    $0xc,%edx
  802298:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80229f:	f6 c2 01             	test   $0x1,%dl
  8022a2:	74 0e                	je     8022b2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022a4:	c1 ea 0c             	shr    $0xc,%edx
  8022a7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022ae:	ef 
  8022af:	0f b7 c0             	movzwl %ax,%eax
}
  8022b2:	5d                   	pop    %ebp
  8022b3:	c3                   	ret    
  8022b4:	66 90                	xchg   %ax,%ax
  8022b6:	66 90                	xchg   %ax,%ax
  8022b8:	66 90                	xchg   %ax,%ax
  8022ba:	66 90                	xchg   %ax,%ax
  8022bc:	66 90                	xchg   %ax,%ax
  8022be:	66 90                	xchg   %ax,%ax

008022c0 <__udivdi3>:
  8022c0:	55                   	push   %ebp
  8022c1:	57                   	push   %edi
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	83 ec 1c             	sub    $0x1c,%esp
  8022c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8022cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8022cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8022d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022d7:	85 f6                	test   %esi,%esi
  8022d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022dd:	89 ca                	mov    %ecx,%edx
  8022df:	89 f8                	mov    %edi,%eax
  8022e1:	75 3d                	jne    802320 <__udivdi3+0x60>
  8022e3:	39 cf                	cmp    %ecx,%edi
  8022e5:	0f 87 c5 00 00 00    	ja     8023b0 <__udivdi3+0xf0>
  8022eb:	85 ff                	test   %edi,%edi
  8022ed:	89 fd                	mov    %edi,%ebp
  8022ef:	75 0b                	jne    8022fc <__udivdi3+0x3c>
  8022f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f6:	31 d2                	xor    %edx,%edx
  8022f8:	f7 f7                	div    %edi
  8022fa:	89 c5                	mov    %eax,%ebp
  8022fc:	89 c8                	mov    %ecx,%eax
  8022fe:	31 d2                	xor    %edx,%edx
  802300:	f7 f5                	div    %ebp
  802302:	89 c1                	mov    %eax,%ecx
  802304:	89 d8                	mov    %ebx,%eax
  802306:	89 cf                	mov    %ecx,%edi
  802308:	f7 f5                	div    %ebp
  80230a:	89 c3                	mov    %eax,%ebx
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
  802320:	39 ce                	cmp    %ecx,%esi
  802322:	77 74                	ja     802398 <__udivdi3+0xd8>
  802324:	0f bd fe             	bsr    %esi,%edi
  802327:	83 f7 1f             	xor    $0x1f,%edi
  80232a:	0f 84 98 00 00 00    	je     8023c8 <__udivdi3+0x108>
  802330:	bb 20 00 00 00       	mov    $0x20,%ebx
  802335:	89 f9                	mov    %edi,%ecx
  802337:	89 c5                	mov    %eax,%ebp
  802339:	29 fb                	sub    %edi,%ebx
  80233b:	d3 e6                	shl    %cl,%esi
  80233d:	89 d9                	mov    %ebx,%ecx
  80233f:	d3 ed                	shr    %cl,%ebp
  802341:	89 f9                	mov    %edi,%ecx
  802343:	d3 e0                	shl    %cl,%eax
  802345:	09 ee                	or     %ebp,%esi
  802347:	89 d9                	mov    %ebx,%ecx
  802349:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80234d:	89 d5                	mov    %edx,%ebp
  80234f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802353:	d3 ed                	shr    %cl,%ebp
  802355:	89 f9                	mov    %edi,%ecx
  802357:	d3 e2                	shl    %cl,%edx
  802359:	89 d9                	mov    %ebx,%ecx
  80235b:	d3 e8                	shr    %cl,%eax
  80235d:	09 c2                	or     %eax,%edx
  80235f:	89 d0                	mov    %edx,%eax
  802361:	89 ea                	mov    %ebp,%edx
  802363:	f7 f6                	div    %esi
  802365:	89 d5                	mov    %edx,%ebp
  802367:	89 c3                	mov    %eax,%ebx
  802369:	f7 64 24 0c          	mull   0xc(%esp)
  80236d:	39 d5                	cmp    %edx,%ebp
  80236f:	72 10                	jb     802381 <__udivdi3+0xc1>
  802371:	8b 74 24 08          	mov    0x8(%esp),%esi
  802375:	89 f9                	mov    %edi,%ecx
  802377:	d3 e6                	shl    %cl,%esi
  802379:	39 c6                	cmp    %eax,%esi
  80237b:	73 07                	jae    802384 <__udivdi3+0xc4>
  80237d:	39 d5                	cmp    %edx,%ebp
  80237f:	75 03                	jne    802384 <__udivdi3+0xc4>
  802381:	83 eb 01             	sub    $0x1,%ebx
  802384:	31 ff                	xor    %edi,%edi
  802386:	89 d8                	mov    %ebx,%eax
  802388:	89 fa                	mov    %edi,%edx
  80238a:	83 c4 1c             	add    $0x1c,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	31 ff                	xor    %edi,%edi
  80239a:	31 db                	xor    %ebx,%ebx
  80239c:	89 d8                	mov    %ebx,%eax
  80239e:	89 fa                	mov    %edi,%edx
  8023a0:	83 c4 1c             	add    $0x1c,%esp
  8023a3:	5b                   	pop    %ebx
  8023a4:	5e                   	pop    %esi
  8023a5:	5f                   	pop    %edi
  8023a6:	5d                   	pop    %ebp
  8023a7:	c3                   	ret    
  8023a8:	90                   	nop
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	89 d8                	mov    %ebx,%eax
  8023b2:	f7 f7                	div    %edi
  8023b4:	31 ff                	xor    %edi,%edi
  8023b6:	89 c3                	mov    %eax,%ebx
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	89 fa                	mov    %edi,%edx
  8023bc:	83 c4 1c             	add    $0x1c,%esp
  8023bf:	5b                   	pop    %ebx
  8023c0:	5e                   	pop    %esi
  8023c1:	5f                   	pop    %edi
  8023c2:	5d                   	pop    %ebp
  8023c3:	c3                   	ret    
  8023c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	39 ce                	cmp    %ecx,%esi
  8023ca:	72 0c                	jb     8023d8 <__udivdi3+0x118>
  8023cc:	31 db                	xor    %ebx,%ebx
  8023ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8023d2:	0f 87 34 ff ff ff    	ja     80230c <__udivdi3+0x4c>
  8023d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8023dd:	e9 2a ff ff ff       	jmp    80230c <__udivdi3+0x4c>
  8023e2:	66 90                	xchg   %ax,%ax
  8023e4:	66 90                	xchg   %ax,%ax
  8023e6:	66 90                	xchg   %ax,%ax
  8023e8:	66 90                	xchg   %ax,%ax
  8023ea:	66 90                	xchg   %ax,%ax
  8023ec:	66 90                	xchg   %ax,%ax
  8023ee:	66 90                	xchg   %ax,%ax

008023f0 <__umoddi3>:
  8023f0:	55                   	push   %ebp
  8023f1:	57                   	push   %edi
  8023f2:	56                   	push   %esi
  8023f3:	53                   	push   %ebx
  8023f4:	83 ec 1c             	sub    $0x1c,%esp
  8023f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802403:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802407:	85 d2                	test   %edx,%edx
  802409:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80240d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802411:	89 f3                	mov    %esi,%ebx
  802413:	89 3c 24             	mov    %edi,(%esp)
  802416:	89 74 24 04          	mov    %esi,0x4(%esp)
  80241a:	75 1c                	jne    802438 <__umoddi3+0x48>
  80241c:	39 f7                	cmp    %esi,%edi
  80241e:	76 50                	jbe    802470 <__umoddi3+0x80>
  802420:	89 c8                	mov    %ecx,%eax
  802422:	89 f2                	mov    %esi,%edx
  802424:	f7 f7                	div    %edi
  802426:	89 d0                	mov    %edx,%eax
  802428:	31 d2                	xor    %edx,%edx
  80242a:	83 c4 1c             	add    $0x1c,%esp
  80242d:	5b                   	pop    %ebx
  80242e:	5e                   	pop    %esi
  80242f:	5f                   	pop    %edi
  802430:	5d                   	pop    %ebp
  802431:	c3                   	ret    
  802432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802438:	39 f2                	cmp    %esi,%edx
  80243a:	89 d0                	mov    %edx,%eax
  80243c:	77 52                	ja     802490 <__umoddi3+0xa0>
  80243e:	0f bd ea             	bsr    %edx,%ebp
  802441:	83 f5 1f             	xor    $0x1f,%ebp
  802444:	75 5a                	jne    8024a0 <__umoddi3+0xb0>
  802446:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80244a:	0f 82 e0 00 00 00    	jb     802530 <__umoddi3+0x140>
  802450:	39 0c 24             	cmp    %ecx,(%esp)
  802453:	0f 86 d7 00 00 00    	jbe    802530 <__umoddi3+0x140>
  802459:	8b 44 24 08          	mov    0x8(%esp),%eax
  80245d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802461:	83 c4 1c             	add    $0x1c,%esp
  802464:	5b                   	pop    %ebx
  802465:	5e                   	pop    %esi
  802466:	5f                   	pop    %edi
  802467:	5d                   	pop    %ebp
  802468:	c3                   	ret    
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	85 ff                	test   %edi,%edi
  802472:	89 fd                	mov    %edi,%ebp
  802474:	75 0b                	jne    802481 <__umoddi3+0x91>
  802476:	b8 01 00 00 00       	mov    $0x1,%eax
  80247b:	31 d2                	xor    %edx,%edx
  80247d:	f7 f7                	div    %edi
  80247f:	89 c5                	mov    %eax,%ebp
  802481:	89 f0                	mov    %esi,%eax
  802483:	31 d2                	xor    %edx,%edx
  802485:	f7 f5                	div    %ebp
  802487:	89 c8                	mov    %ecx,%eax
  802489:	f7 f5                	div    %ebp
  80248b:	89 d0                	mov    %edx,%eax
  80248d:	eb 99                	jmp    802428 <__umoddi3+0x38>
  80248f:	90                   	nop
  802490:	89 c8                	mov    %ecx,%eax
  802492:	89 f2                	mov    %esi,%edx
  802494:	83 c4 1c             	add    $0x1c,%esp
  802497:	5b                   	pop    %ebx
  802498:	5e                   	pop    %esi
  802499:	5f                   	pop    %edi
  80249a:	5d                   	pop    %ebp
  80249b:	c3                   	ret    
  80249c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	8b 34 24             	mov    (%esp),%esi
  8024a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024a8:	89 e9                	mov    %ebp,%ecx
  8024aa:	29 ef                	sub    %ebp,%edi
  8024ac:	d3 e0                	shl    %cl,%eax
  8024ae:	89 f9                	mov    %edi,%ecx
  8024b0:	89 f2                	mov    %esi,%edx
  8024b2:	d3 ea                	shr    %cl,%edx
  8024b4:	89 e9                	mov    %ebp,%ecx
  8024b6:	09 c2                	or     %eax,%edx
  8024b8:	89 d8                	mov    %ebx,%eax
  8024ba:	89 14 24             	mov    %edx,(%esp)
  8024bd:	89 f2                	mov    %esi,%edx
  8024bf:	d3 e2                	shl    %cl,%edx
  8024c1:	89 f9                	mov    %edi,%ecx
  8024c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024cb:	d3 e8                	shr    %cl,%eax
  8024cd:	89 e9                	mov    %ebp,%ecx
  8024cf:	89 c6                	mov    %eax,%esi
  8024d1:	d3 e3                	shl    %cl,%ebx
  8024d3:	89 f9                	mov    %edi,%ecx
  8024d5:	89 d0                	mov    %edx,%eax
  8024d7:	d3 e8                	shr    %cl,%eax
  8024d9:	89 e9                	mov    %ebp,%ecx
  8024db:	09 d8                	or     %ebx,%eax
  8024dd:	89 d3                	mov    %edx,%ebx
  8024df:	89 f2                	mov    %esi,%edx
  8024e1:	f7 34 24             	divl   (%esp)
  8024e4:	89 d6                	mov    %edx,%esi
  8024e6:	d3 e3                	shl    %cl,%ebx
  8024e8:	f7 64 24 04          	mull   0x4(%esp)
  8024ec:	39 d6                	cmp    %edx,%esi
  8024ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024f2:	89 d1                	mov    %edx,%ecx
  8024f4:	89 c3                	mov    %eax,%ebx
  8024f6:	72 08                	jb     802500 <__umoddi3+0x110>
  8024f8:	75 11                	jne    80250b <__umoddi3+0x11b>
  8024fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024fe:	73 0b                	jae    80250b <__umoddi3+0x11b>
  802500:	2b 44 24 04          	sub    0x4(%esp),%eax
  802504:	1b 14 24             	sbb    (%esp),%edx
  802507:	89 d1                	mov    %edx,%ecx
  802509:	89 c3                	mov    %eax,%ebx
  80250b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80250f:	29 da                	sub    %ebx,%edx
  802511:	19 ce                	sbb    %ecx,%esi
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 f0                	mov    %esi,%eax
  802517:	d3 e0                	shl    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	d3 ea                	shr    %cl,%edx
  80251d:	89 e9                	mov    %ebp,%ecx
  80251f:	d3 ee                	shr    %cl,%esi
  802521:	09 d0                	or     %edx,%eax
  802523:	89 f2                	mov    %esi,%edx
  802525:	83 c4 1c             	add    $0x1c,%esp
  802528:	5b                   	pop    %ebx
  802529:	5e                   	pop    %esi
  80252a:	5f                   	pop    %edi
  80252b:	5d                   	pop    %ebp
  80252c:	c3                   	ret    
  80252d:	8d 76 00             	lea    0x0(%esi),%esi
  802530:	29 f9                	sub    %edi,%ecx
  802532:	19 d6                	sbb    %edx,%esi
  802534:	89 74 24 04          	mov    %esi,0x4(%esp)
  802538:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80253c:	e9 18 ff ff ff       	jmp    802459 <__umoddi3+0x69>
