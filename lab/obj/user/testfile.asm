
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 60 80 00       	push   $0x806000
  800042:	e8 9f 0c 00 00       	call   800ce6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 df 13 00 00       	call   801438 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 7c 13 00 00       	call   8013e4 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 04 13 00 00       	call   80137d <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 80 28 80 00       	mov    $0x802880,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 8b 28 80 00       	push   $0x80288b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 a5 28 80 00       	push   $0x8028a5
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 40 2a 80 00       	push   $0x802a40
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 a5 28 80 00       	push   $0x8028a5
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 b5 28 80 00       	mov    $0x8028b5,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 be 28 80 00       	push   $0x8028be
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 a5 28 80 00       	push   $0x8028a5
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 64 2a 80 00       	push   $0x802a64
  800119:	6a 27                	push   $0x27
  80011b:	68 a5 28 80 00       	push   $0x8028a5
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 d6 28 80 00       	push   $0x8028d6
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 40 80 00    	call   *0x80401c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 ea 28 80 00       	push   $0x8028ea
  800154:	6a 2b                	push   $0x2b
  800156:	68 a5 28 80 00       	push   $0x8028a5
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 40 80 00    	pushl  0x804000
  800169:	e8 3f 0b 00 00       	call   800cad <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 40 80 00    	pushl  0x804000
  80017f:	e8 29 0b 00 00       	call   800cad <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 94 2a 80 00       	push   $0x802a94
  80018f:	6a 2d                	push   $0x2d
  800191:	68 a5 28 80 00       	push   $0x8028a5
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 f8 28 80 00       	push   $0x8028f8
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 6d 0c 00 00       	call   800e2b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 40 80 00    	call   *0x804010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 0b 29 80 00       	push   $0x80290b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 a5 28 80 00       	push   $0x8028a5
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 40 80 00    	pushl  0x804000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 90 0b 00 00       	call   800d90 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 19 29 80 00       	push   $0x802919
  80020f:	6a 34                	push   $0x34
  800211:	68 a5 28 80 00       	push   $0x8028a5
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
		// panic("file_read returned wrong data, buf[%d]: %s\n", strlen(buf), buf);
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 37 29 80 00       	push   $0x802937
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 4a 29 80 00       	push   $0x80294a
  800242:	6a 39                	push   $0x39
  800244:	68 a5 28 80 00       	push   $0x8028a5
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 59 29 80 00       	push   $0x802959
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 e4 0e 00 00       	call   80116e <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 40 80 00    	call   *0x804010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 bc 2a 80 00       	push   $0x802abc
  8002b1:	6a 44                	push   $0x44
  8002b3:	68 a5 28 80 00       	push   $0x8028a5
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 6d 29 80 00       	push   $0x80296d
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 83 29 80 00       	mov    $0x802983,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 8d 29 80 00       	push   $0x80298d
  8002e6:	6a 49                	push   $0x49
  8002e8:	68 a5 28 80 00       	push   $0x8028a5
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 40 80 00    	pushl  0x804000
  800301:	e8 a7 09 00 00       	call   800cad <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 40 80 00    	pushl  0x804000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 40 80 00    	pushl  0x804000
  800322:	e8 86 09 00 00       	call   800cad <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 a6 29 80 00       	push   $0x8029a6
  800334:	6a 4c                	push   $0x4c
  800336:	68 a5 28 80 00       	push   $0x8028a5
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 b5 29 80 00       	push   $0x8029b5
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 be 0a 00 00       	call   800e2b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 40 80 00    	call   *0x804010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 f4 2a 80 00       	push   $0x802af4
  800390:	6a 52                	push   $0x52
  800392:	68 a5 28 80 00       	push   $0x8028a5
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 40 80 00    	pushl  0x804000
  8003a5:	e8 03 09 00 00       	call   800cad <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 14 2b 80 00       	push   $0x802b14
  8003b7:	6a 54                	push   $0x54
  8003b9:	68 a5 28 80 00       	push   $0x8028a5
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 40 80 00    	pushl  0x804000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 b8 09 00 00       	call   800d90 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 4c 2b 80 00       	push   $0x802b4c
  8003e7:	6a 56                	push   $0x56
  8003e9:	68 a5 28 80 00       	push   $0x8028a5
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 7c 2b 80 00       	push   $0x802b7c
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 80 28 80 00       	push   $0x802880
  80040a:	e8 bc 17 00 00       	call   801bcb <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 91 28 80 00       	push   $0x802891
  800426:	6a 5b                	push   $0x5b
  800428:	68 a5 28 80 00       	push   $0x8028a5
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 c9 29 80 00       	push   $0x8029c9
  80043e:	6a 5d                	push   $0x5d
  800440:	68 a5 28 80 00       	push   $0x8028a5
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 b5 28 80 00       	push   $0x8028b5
  800454:	e8 72 17 00 00       	call   801bcb <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 c4 28 80 00       	push   $0x8028c4
  800466:	6a 60                	push   $0x60
  800468:	68 a5 28 80 00       	push   $0x8028a5
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 a0 2b 80 00       	push   $0x802ba0
  800498:	6a 63                	push   $0x63
  80049a:	68 a5 28 80 00       	push   $0x8028a5
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 dc 28 80 00       	push   $0x8028dc
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 e4 29 80 00       	push   $0x8029e4
  8004be:	e8 08 17 00 00       	call   801bcb <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 e9 29 80 00       	push   $0x8029e9
  8004d2:	6a 68                	push   $0x68
  8004d4:	68 a5 28 80 00       	push   $0x8028a5
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 37 09 00 00       	call   800e2b <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 10 13 00 00       	call   801827 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 f8 29 80 00       	push   $0x8029f8
  800528:	6a 6d                	push   $0x6d
  80052a:	68 a5 28 80 00       	push   $0x8028a5
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 c5 10 00 00       	call   801611 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 e4 29 80 00       	push   $0x8029e4
  800556:	e8 70 16 00 00       	call   801bcb <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 0a 2a 80 00       	push   $0x802a0a
  80056a:	6a 72                	push   $0x72
  80056c:	68 a5 28 80 00       	push   $0x8028a5
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 48 12 00 00       	call   8017de <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 18 2a 80 00       	push   $0x802a18
  8005a7:	6a 76                	push   $0x76
  8005a9:	68 a5 28 80 00       	push   $0x8028a5
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 c8 2b 80 00       	push   $0x802bc8
  8005c9:	6a 79                	push   $0x79
  8005cb:	68 a5 28 80 00       	push   $0x8028a5
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 f4 2b 80 00       	push   $0x802bf4
  8005e9:	6a 7c                	push   $0x7c
  8005eb:	68 a5 28 80 00       	push   $0x8028a5
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 00 10 00 00       	call   801611 <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 29 2a 80 00 	movl   $0x802a29,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 73 0a 00 00       	call   8010ab <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 c3 0f 00 00       	call   80163c <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 e7 09 00 00       	call   80106a <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800696:	e8 10 0a 00 00       	call   8010ab <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 4c 2c 80 00       	push   $0x802c4c
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 2f 09 00 00       	call   80102d <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 54 01 00 00       	call   800898 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 d4 08 00 00       	call   80102d <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 27 1e 00 00       	call   8025f0 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 14 1f 00 00       	call   802720 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 6f 2c 80 00 	movsbl 0x802c6f(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800827:	83 fa 01             	cmp    $0x1,%edx
  80082a:	7e 0e                	jle    80083a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800831:	89 08                	mov    %ecx,(%eax)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	8b 52 04             	mov    0x4(%edx),%edx
  800838:	eb 22                	jmp    80085c <getuint+0x38>
	else if (lflag)
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 10                	je     80084e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8d 4a 04             	lea    0x4(%edx),%ecx
  800843:	89 08                	mov    %ecx,(%eax)
  800845:	8b 02                	mov    (%edx),%eax
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 0e                	jmp    80085c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8d 4a 04             	lea    0x4(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 02                	mov    (%edx),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800864:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	3b 50 04             	cmp    0x4(%eax),%edx
  80086d:	73 0a                	jae    800879 <sprintputch+0x1b>
		*b->buf++ = ch;
  80086f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800872:	89 08                	mov    %ecx,(%eax)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	88 02                	mov    %al,(%edx)
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 05 00 00 00       	call   800898 <vprintfmt>
	va_end(ap);
}
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	83 ec 2c             	sub    $0x2c,%esp
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008aa:	eb 12                	jmp    8008be <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	0f 84 89 03 00 00    	je     800c3d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	50                   	push   %eax
  8008b9:	ff d6                	call   *%esi
  8008bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c5:	83 f8 25             	cmp    $0x25,%eax
  8008c8:	75 e2                	jne    8008ac <vprintfmt+0x14>
  8008ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e8:	eb 07                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008ed:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	8d 47 01             	lea    0x1(%edi),%eax
  8008f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f7:	0f b6 07             	movzbl (%edi),%eax
  8008fa:	0f b6 c8             	movzbl %al,%ecx
  8008fd:	83 e8 23             	sub    $0x23,%eax
  800900:	3c 55                	cmp    $0x55,%al
  800902:	0f 87 1a 03 00 00    	ja     800c22 <vprintfmt+0x38a>
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	ff 24 85 c0 2d 80 00 	jmp    *0x802dc0(,%eax,4)
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800915:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800919:	eb d6                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800926:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800929:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80092d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800930:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800933:	83 fa 09             	cmp    $0x9,%edx
  800936:	77 39                	ja     800971 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800938:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80093b:	eb e9                	jmp    800926 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8d 48 04             	lea    0x4(%eax),%ecx
  800943:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800946:	8b 00                	mov    (%eax),%eax
  800948:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80094e:	eb 27                	jmp    800977 <vprintfmt+0xdf>
  800950:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800953:	85 c0                	test   %eax,%eax
  800955:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095a:	0f 49 c8             	cmovns %eax,%ecx
  80095d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800960:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800963:	eb 8c                	jmp    8008f1 <vprintfmt+0x59>
  800965:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800968:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80096f:	eb 80                	jmp    8008f1 <vprintfmt+0x59>
  800971:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800974:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800977:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80097b:	0f 89 70 ff ff ff    	jns    8008f1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800981:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800984:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800987:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80098e:	e9 5e ff ff ff       	jmp    8008f1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800993:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800996:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800999:	e9 53 ff ff ff       	jmp    8008f1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8d 50 04             	lea    0x4(%eax),%edx
  8009a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	53                   	push   %ebx
  8009ab:	ff 30                	pushl  (%eax)
  8009ad:	ff d6                	call   *%esi
			break;
  8009af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009b5:	e9 04 ff ff ff       	jmp    8008be <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8d 50 04             	lea    0x4(%eax),%edx
  8009c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c3:	8b 00                	mov    (%eax),%eax
  8009c5:	99                   	cltd   
  8009c6:	31 d0                	xor    %edx,%eax
  8009c8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ca:	83 f8 0f             	cmp    $0xf,%eax
  8009cd:	7f 0b                	jg     8009da <vprintfmt+0x142>
  8009cf:	8b 14 85 20 2f 80 00 	mov    0x802f20(,%eax,4),%edx
  8009d6:	85 d2                	test   %edx,%edx
  8009d8:	75 18                	jne    8009f2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009da:	50                   	push   %eax
  8009db:	68 87 2c 80 00       	push   $0x802c87
  8009e0:	53                   	push   %ebx
  8009e1:	56                   	push   %esi
  8009e2:	e8 94 fe ff ff       	call   80087b <printfmt>
  8009e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009ed:	e9 cc fe ff ff       	jmp    8008be <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009f2:	52                   	push   %edx
  8009f3:	68 71 30 80 00       	push   $0x803071
  8009f8:	53                   	push   %ebx
  8009f9:	56                   	push   %esi
  8009fa:	e8 7c fe ff ff       	call   80087b <printfmt>
  8009ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a05:	e9 b4 fe ff ff       	jmp    8008be <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0d:	8d 50 04             	lea    0x4(%eax),%edx
  800a10:	89 55 14             	mov    %edx,0x14(%ebp)
  800a13:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a15:	85 ff                	test   %edi,%edi
  800a17:	b8 80 2c 80 00       	mov    $0x802c80,%eax
  800a1c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a23:	0f 8e 94 00 00 00    	jle    800abd <vprintfmt+0x225>
  800a29:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a2d:	0f 84 98 00 00 00    	je     800acb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	ff 75 d0             	pushl  -0x30(%ebp)
  800a39:	57                   	push   %edi
  800a3a:	e8 86 02 00 00       	call   800cc5 <strnlen>
  800a3f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a42:	29 c1                	sub    %eax,%ecx
  800a44:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a47:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a4a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a51:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a54:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a56:	eb 0f                	jmp    800a67 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	53                   	push   %ebx
  800a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a5f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	83 c4 10             	add    $0x10,%esp
  800a67:	85 ff                	test   %edi,%edi
  800a69:	7f ed                	jg     800a58 <vprintfmt+0x1c0>
  800a6b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a6e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	0f 49 c1             	cmovns %ecx,%eax
  800a7b:	29 c1                	sub    %eax,%ecx
  800a7d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a80:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a86:	89 cb                	mov    %ecx,%ebx
  800a88:	eb 4d                	jmp    800ad7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a8a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a8e:	74 1b                	je     800aab <vprintfmt+0x213>
  800a90:	0f be c0             	movsbl %al,%eax
  800a93:	83 e8 20             	sub    $0x20,%eax
  800a96:	83 f8 5e             	cmp    $0x5e,%eax
  800a99:	76 10                	jbe    800aab <vprintfmt+0x213>
					putch('?', putdat);
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	6a 3f                	push   $0x3f
  800aa3:	ff 55 08             	call   *0x8(%ebp)
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	eb 0d                	jmp    800ab8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	52                   	push   %edx
  800ab2:	ff 55 08             	call   *0x8(%ebp)
  800ab5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab8:	83 eb 01             	sub    $0x1,%ebx
  800abb:	eb 1a                	jmp    800ad7 <vprintfmt+0x23f>
  800abd:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ac3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ac6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ac9:	eb 0c                	jmp    800ad7 <vprintfmt+0x23f>
  800acb:	89 75 08             	mov    %esi,0x8(%ebp)
  800ace:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ad1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad7:	83 c7 01             	add    $0x1,%edi
  800ada:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ade:	0f be d0             	movsbl %al,%edx
  800ae1:	85 d2                	test   %edx,%edx
  800ae3:	74 23                	je     800b08 <vprintfmt+0x270>
  800ae5:	85 f6                	test   %esi,%esi
  800ae7:	78 a1                	js     800a8a <vprintfmt+0x1f2>
  800ae9:	83 ee 01             	sub    $0x1,%esi
  800aec:	79 9c                	jns    800a8a <vprintfmt+0x1f2>
  800aee:	89 df                	mov    %ebx,%edi
  800af0:	8b 75 08             	mov    0x8(%ebp),%esi
  800af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af6:	eb 18                	jmp    800b10 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	53                   	push   %ebx
  800afc:	6a 20                	push   $0x20
  800afe:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb 08                	jmp    800b10 <vprintfmt+0x278>
  800b08:	89 df                	mov    %ebx,%edi
  800b0a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	7f e4                	jg     800af8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b17:	e9 a2 fd ff ff       	jmp    8008be <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1c:	83 fa 01             	cmp    $0x1,%edx
  800b1f:	7e 16                	jle    800b37 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b21:	8b 45 14             	mov    0x14(%ebp),%eax
  800b24:	8d 50 08             	lea    0x8(%eax),%edx
  800b27:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2a:	8b 50 04             	mov    0x4(%eax),%edx
  800b2d:	8b 00                	mov    (%eax),%eax
  800b2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b32:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b35:	eb 32                	jmp    800b69 <vprintfmt+0x2d1>
	else if (lflag)
  800b37:	85 d2                	test   %edx,%edx
  800b39:	74 18                	je     800b53 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3e:	8d 50 04             	lea    0x4(%eax),%edx
  800b41:	89 55 14             	mov    %edx,0x14(%ebp)
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b49:	89 c1                	mov    %eax,%ecx
  800b4b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b4e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b51:	eb 16                	jmp    800b69 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b53:	8b 45 14             	mov    0x14(%ebp),%eax
  800b56:	8d 50 04             	lea    0x4(%eax),%edx
  800b59:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5c:	8b 00                	mov    (%eax),%eax
  800b5e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b61:	89 c1                	mov    %eax,%ecx
  800b63:	c1 f9 1f             	sar    $0x1f,%ecx
  800b66:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b69:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b6f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b74:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b78:	79 74                	jns    800bee <vprintfmt+0x356>
				putch('-', putdat);
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	53                   	push   %ebx
  800b7e:	6a 2d                	push   $0x2d
  800b80:	ff d6                	call   *%esi
				num = -(long long) num;
  800b82:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b85:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b88:	f7 d8                	neg    %eax
  800b8a:	83 d2 00             	adc    $0x0,%edx
  800b8d:	f7 da                	neg    %edx
  800b8f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b92:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b97:	eb 55                	jmp    800bee <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b99:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9c:	e8 83 fc ff ff       	call   800824 <getuint>
			base = 10;
  800ba1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ba6:	eb 46                	jmp    800bee <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800ba8:	8d 45 14             	lea    0x14(%ebp),%eax
  800bab:	e8 74 fc ff ff       	call   800824 <getuint>
			base = 8;
  800bb0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bb5:	eb 37                	jmp    800bee <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800bb7:	83 ec 08             	sub    $0x8,%esp
  800bba:	53                   	push   %ebx
  800bbb:	6a 30                	push   $0x30
  800bbd:	ff d6                	call   *%esi
			putch('x', putdat);
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	53                   	push   %ebx
  800bc3:	6a 78                	push   $0x78
  800bc5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	8d 50 04             	lea    0x4(%eax),%edx
  800bcd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bd0:	8b 00                	mov    (%eax),%eax
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bd7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bda:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bdf:	eb 0d                	jmp    800bee <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800be1:	8d 45 14             	lea    0x14(%ebp),%eax
  800be4:	e8 3b fc ff ff       	call   800824 <getuint>
			base = 16;
  800be9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bf5:	57                   	push   %edi
  800bf6:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf9:	51                   	push   %ecx
  800bfa:	52                   	push   %edx
  800bfb:	50                   	push   %eax
  800bfc:	89 da                	mov    %ebx,%edx
  800bfe:	89 f0                	mov    %esi,%eax
  800c00:	e8 70 fb ff ff       	call   800775 <printnum>
			break;
  800c05:	83 c4 20             	add    $0x20,%esp
  800c08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c0b:	e9 ae fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	53                   	push   %ebx
  800c14:	51                   	push   %ecx
  800c15:	ff d6                	call   *%esi
			break;
  800c17:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c1d:	e9 9c fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c22:	83 ec 08             	sub    $0x8,%esp
  800c25:	53                   	push   %ebx
  800c26:	6a 25                	push   $0x25
  800c28:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	eb 03                	jmp    800c32 <vprintfmt+0x39a>
  800c2f:	83 ef 01             	sub    $0x1,%edi
  800c32:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c36:	75 f7                	jne    800c2f <vprintfmt+0x397>
  800c38:	e9 81 fc ff ff       	jmp    8008be <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 18             	sub    $0x18,%esp
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c51:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c54:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c58:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	74 26                	je     800c8c <vsnprintf+0x47>
  800c66:	85 d2                	test   %edx,%edx
  800c68:	7e 22                	jle    800c8c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c6a:	ff 75 14             	pushl  0x14(%ebp)
  800c6d:	ff 75 10             	pushl  0x10(%ebp)
  800c70:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c73:	50                   	push   %eax
  800c74:	68 5e 08 80 00       	push   $0x80085e
  800c79:	e8 1a fc ff ff       	call   800898 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c81:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c87:	83 c4 10             	add    $0x10,%esp
  800c8a:	eb 05                	jmp    800c91 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c99:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c9c:	50                   	push   %eax
  800c9d:	ff 75 10             	pushl  0x10(%ebp)
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	ff 75 08             	pushl  0x8(%ebp)
  800ca6:	e8 9a ff ff ff       	call   800c45 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb8:	eb 03                	jmp    800cbd <strlen+0x10>
		n++;
  800cba:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cbd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cc1:	75 f7                	jne    800cba <strlen+0xd>
		n++;
	return n;
}
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd3:	eb 03                	jmp    800cd8 <strnlen+0x13>
		n++;
  800cd5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd8:	39 c2                	cmp    %eax,%edx
  800cda:	74 08                	je     800ce4 <strnlen+0x1f>
  800cdc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ce0:	75 f3                	jne    800cd5 <strnlen+0x10>
  800ce2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	53                   	push   %ebx
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	83 c2 01             	add    $0x1,%edx
  800cf5:	83 c1 01             	add    $0x1,%ecx
  800cf8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cfc:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cff:	84 db                	test   %bl,%bl
  800d01:	75 ef                	jne    800cf2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d03:	5b                   	pop    %ebx
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	53                   	push   %ebx
  800d0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d0d:	53                   	push   %ebx
  800d0e:	e8 9a ff ff ff       	call   800cad <strlen>
  800d13:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d16:	ff 75 0c             	pushl  0xc(%ebp)
  800d19:	01 d8                	add    %ebx,%eax
  800d1b:	50                   	push   %eax
  800d1c:	e8 c5 ff ff ff       	call   800ce6 <strcpy>
	return dst;
}
  800d21:	89 d8                	mov    %ebx,%eax
  800d23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	eb 0f                	jmp    800d4b <strncpy+0x23>
		*dst++ = *src;
  800d3c:	83 c2 01             	add    $0x1,%edx
  800d3f:	0f b6 01             	movzbl (%ecx),%eax
  800d42:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d45:	80 39 01             	cmpb   $0x1,(%ecx)
  800d48:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d4b:	39 da                	cmp    %ebx,%edx
  800d4d:	75 ed                	jne    800d3c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d4f:	89 f0                	mov    %esi,%eax
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 10             	mov    0x10(%ebp),%edx
  800d63:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d65:	85 d2                	test   %edx,%edx
  800d67:	74 21                	je     800d8a <strlcpy+0x35>
  800d69:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d6d:	89 f2                	mov    %esi,%edx
  800d6f:	eb 09                	jmp    800d7a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d71:	83 c2 01             	add    $0x1,%edx
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d7a:	39 c2                	cmp    %eax,%edx
  800d7c:	74 09                	je     800d87 <strlcpy+0x32>
  800d7e:	0f b6 19             	movzbl (%ecx),%ebx
  800d81:	84 db                	test   %bl,%bl
  800d83:	75 ec                	jne    800d71 <strlcpy+0x1c>
  800d85:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d87:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d8a:	29 f0                	sub    %esi,%eax
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d99:	eb 06                	jmp    800da1 <strcmp+0x11>
		p++, q++;
  800d9b:	83 c1 01             	add    $0x1,%ecx
  800d9e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800da1:	0f b6 01             	movzbl (%ecx),%eax
  800da4:	84 c0                	test   %al,%al
  800da6:	74 04                	je     800dac <strcmp+0x1c>
  800da8:	3a 02                	cmp    (%edx),%al
  800daa:	74 ef                	je     800d9b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dac:	0f b6 c0             	movzbl %al,%eax
  800daf:	0f b6 12             	movzbl (%edx),%edx
  800db2:	29 d0                	sub    %edx,%eax
}
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	53                   	push   %ebx
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dc5:	eb 06                	jmp    800dcd <strncmp+0x17>
		n--, p++, q++;
  800dc7:	83 c0 01             	add    $0x1,%eax
  800dca:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dcd:	39 d8                	cmp    %ebx,%eax
  800dcf:	74 15                	je     800de6 <strncmp+0x30>
  800dd1:	0f b6 08             	movzbl (%eax),%ecx
  800dd4:	84 c9                	test   %cl,%cl
  800dd6:	74 04                	je     800ddc <strncmp+0x26>
  800dd8:	3a 0a                	cmp    (%edx),%cl
  800dda:	74 eb                	je     800dc7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ddc:	0f b6 00             	movzbl (%eax),%eax
  800ddf:	0f b6 12             	movzbl (%edx),%edx
  800de2:	29 d0                	sub    %edx,%eax
  800de4:	eb 05                	jmp    800deb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800de6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800deb:	5b                   	pop    %ebx
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df8:	eb 07                	jmp    800e01 <strchr+0x13>
		if (*s == c)
  800dfa:	38 ca                	cmp    %cl,%dl
  800dfc:	74 0f                	je     800e0d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfe:	83 c0 01             	add    $0x1,%eax
  800e01:	0f b6 10             	movzbl (%eax),%edx
  800e04:	84 d2                	test   %dl,%dl
  800e06:	75 f2                	jne    800dfa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e19:	eb 03                	jmp    800e1e <strfind+0xf>
  800e1b:	83 c0 01             	add    $0x1,%eax
  800e1e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e21:	38 ca                	cmp    %cl,%dl
  800e23:	74 04                	je     800e29 <strfind+0x1a>
  800e25:	84 d2                	test   %dl,%dl
  800e27:	75 f2                	jne    800e1b <strfind+0xc>
			break;
	return (char *) s;
}
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e37:	85 c9                	test   %ecx,%ecx
  800e39:	74 36                	je     800e71 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e3b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e41:	75 28                	jne    800e6b <memset+0x40>
  800e43:	f6 c1 03             	test   $0x3,%cl
  800e46:	75 23                	jne    800e6b <memset+0x40>
		c &= 0xFF;
  800e48:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e4c:	89 d3                	mov    %edx,%ebx
  800e4e:	c1 e3 08             	shl    $0x8,%ebx
  800e51:	89 d6                	mov    %edx,%esi
  800e53:	c1 e6 18             	shl    $0x18,%esi
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	c1 e0 10             	shl    $0x10,%eax
  800e5b:	09 f0                	or     %esi,%eax
  800e5d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e5f:	89 d8                	mov    %ebx,%eax
  800e61:	09 d0                	or     %edx,%eax
  800e63:	c1 e9 02             	shr    $0x2,%ecx
  800e66:	fc                   	cld    
  800e67:	f3 ab                	rep stos %eax,%es:(%edi)
  800e69:	eb 06                	jmp    800e71 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	fc                   	cld    
  800e6f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e71:	89 f8                	mov    %edi,%eax
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e86:	39 c6                	cmp    %eax,%esi
  800e88:	73 35                	jae    800ebf <memmove+0x47>
  800e8a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e8d:	39 d0                	cmp    %edx,%eax
  800e8f:	73 2e                	jae    800ebf <memmove+0x47>
		s += n;
		d += n;
  800e91:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e94:	89 d6                	mov    %edx,%esi
  800e96:	09 fe                	or     %edi,%esi
  800e98:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e9e:	75 13                	jne    800eb3 <memmove+0x3b>
  800ea0:	f6 c1 03             	test   $0x3,%cl
  800ea3:	75 0e                	jne    800eb3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ea5:	83 ef 04             	sub    $0x4,%edi
  800ea8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eab:	c1 e9 02             	shr    $0x2,%ecx
  800eae:	fd                   	std    
  800eaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eb1:	eb 09                	jmp    800ebc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eb3:	83 ef 01             	sub    $0x1,%edi
  800eb6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800eb9:	fd                   	std    
  800eba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ebc:	fc                   	cld    
  800ebd:	eb 1d                	jmp    800edc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ebf:	89 f2                	mov    %esi,%edx
  800ec1:	09 c2                	or     %eax,%edx
  800ec3:	f6 c2 03             	test   $0x3,%dl
  800ec6:	75 0f                	jne    800ed7 <memmove+0x5f>
  800ec8:	f6 c1 03             	test   $0x3,%cl
  800ecb:	75 0a                	jne    800ed7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ecd:	c1 e9 02             	shr    $0x2,%ecx
  800ed0:	89 c7                	mov    %eax,%edi
  800ed2:	fc                   	cld    
  800ed3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed5:	eb 05                	jmp    800edc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ed7:	89 c7                	mov    %eax,%edi
  800ed9:	fc                   	cld    
  800eda:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ee3:	ff 75 10             	pushl  0x10(%ebp)
  800ee6:	ff 75 0c             	pushl  0xc(%ebp)
  800ee9:	ff 75 08             	pushl  0x8(%ebp)
  800eec:	e8 87 ff ff ff       	call   800e78 <memmove>
}
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  800efb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efe:	89 c6                	mov    %eax,%esi
  800f00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f03:	eb 1a                	jmp    800f1f <memcmp+0x2c>
		if (*s1 != *s2)
  800f05:	0f b6 08             	movzbl (%eax),%ecx
  800f08:	0f b6 1a             	movzbl (%edx),%ebx
  800f0b:	38 d9                	cmp    %bl,%cl
  800f0d:	74 0a                	je     800f19 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f0f:	0f b6 c1             	movzbl %cl,%eax
  800f12:	0f b6 db             	movzbl %bl,%ebx
  800f15:	29 d8                	sub    %ebx,%eax
  800f17:	eb 0f                	jmp    800f28 <memcmp+0x35>
		s1++, s2++;
  800f19:	83 c0 01             	add    $0x1,%eax
  800f1c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f1f:	39 f0                	cmp    %esi,%eax
  800f21:	75 e2                	jne    800f05 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f33:	89 c1                	mov    %eax,%ecx
  800f35:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f38:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f3c:	eb 0a                	jmp    800f48 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f3e:	0f b6 10             	movzbl (%eax),%edx
  800f41:	39 da                	cmp    %ebx,%edx
  800f43:	74 07                	je     800f4c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f45:	83 c0 01             	add    $0x1,%eax
  800f48:	39 c8                	cmp    %ecx,%eax
  800f4a:	72 f2                	jb     800f3e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f4c:	5b                   	pop    %ebx
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f5b:	eb 03                	jmp    800f60 <strtol+0x11>
		s++;
  800f5d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f60:	0f b6 01             	movzbl (%ecx),%eax
  800f63:	3c 20                	cmp    $0x20,%al
  800f65:	74 f6                	je     800f5d <strtol+0xe>
  800f67:	3c 09                	cmp    $0x9,%al
  800f69:	74 f2                	je     800f5d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f6b:	3c 2b                	cmp    $0x2b,%al
  800f6d:	75 0a                	jne    800f79 <strtol+0x2a>
		s++;
  800f6f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f72:	bf 00 00 00 00       	mov    $0x0,%edi
  800f77:	eb 11                	jmp    800f8a <strtol+0x3b>
  800f79:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f7e:	3c 2d                	cmp    $0x2d,%al
  800f80:	75 08                	jne    800f8a <strtol+0x3b>
		s++, neg = 1;
  800f82:	83 c1 01             	add    $0x1,%ecx
  800f85:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f8a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f90:	75 15                	jne    800fa7 <strtol+0x58>
  800f92:	80 39 30             	cmpb   $0x30,(%ecx)
  800f95:	75 10                	jne    800fa7 <strtol+0x58>
  800f97:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f9b:	75 7c                	jne    801019 <strtol+0xca>
		s += 2, base = 16;
  800f9d:	83 c1 02             	add    $0x2,%ecx
  800fa0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fa5:	eb 16                	jmp    800fbd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fa7:	85 db                	test   %ebx,%ebx
  800fa9:	75 12                	jne    800fbd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fab:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fb0:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb3:	75 08                	jne    800fbd <strtol+0x6e>
		s++, base = 8;
  800fb5:	83 c1 01             	add    $0x1,%ecx
  800fb8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fc5:	0f b6 11             	movzbl (%ecx),%edx
  800fc8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fcb:	89 f3                	mov    %esi,%ebx
  800fcd:	80 fb 09             	cmp    $0x9,%bl
  800fd0:	77 08                	ja     800fda <strtol+0x8b>
			dig = *s - '0';
  800fd2:	0f be d2             	movsbl %dl,%edx
  800fd5:	83 ea 30             	sub    $0x30,%edx
  800fd8:	eb 22                	jmp    800ffc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fda:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fdd:	89 f3                	mov    %esi,%ebx
  800fdf:	80 fb 19             	cmp    $0x19,%bl
  800fe2:	77 08                	ja     800fec <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fe4:	0f be d2             	movsbl %dl,%edx
  800fe7:	83 ea 57             	sub    $0x57,%edx
  800fea:	eb 10                	jmp    800ffc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fec:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fef:	89 f3                	mov    %esi,%ebx
  800ff1:	80 fb 19             	cmp    $0x19,%bl
  800ff4:	77 16                	ja     80100c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ff6:	0f be d2             	movsbl %dl,%edx
  800ff9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ffc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fff:	7d 0b                	jge    80100c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801001:	83 c1 01             	add    $0x1,%ecx
  801004:	0f af 45 10          	imul   0x10(%ebp),%eax
  801008:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80100a:	eb b9                	jmp    800fc5 <strtol+0x76>

	if (endptr)
  80100c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801010:	74 0d                	je     80101f <strtol+0xd0>
		*endptr = (char *) s;
  801012:	8b 75 0c             	mov    0xc(%ebp),%esi
  801015:	89 0e                	mov    %ecx,(%esi)
  801017:	eb 06                	jmp    80101f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801019:	85 db                	test   %ebx,%ebx
  80101b:	74 98                	je     800fb5 <strtol+0x66>
  80101d:	eb 9e                	jmp    800fbd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80101f:	89 c2                	mov    %eax,%edx
  801021:	f7 da                	neg    %edx
  801023:	85 ff                	test   %edi,%edi
  801025:	0f 45 c2             	cmovne %edx,%eax
}
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801033:	b8 00 00 00 00       	mov    $0x0,%eax
  801038:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103b:	8b 55 08             	mov    0x8(%ebp),%edx
  80103e:	89 c3                	mov    %eax,%ebx
  801040:	89 c7                	mov    %eax,%edi
  801042:	89 c6                	mov    %eax,%esi
  801044:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <sys_cgetc>:

int
sys_cgetc(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801051:	ba 00 00 00 00       	mov    $0x0,%edx
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	89 d1                	mov    %edx,%ecx
  80105d:	89 d3                	mov    %edx,%ebx
  80105f:	89 d7                	mov    %edx,%edi
  801061:	89 d6                	mov    %edx,%esi
  801063:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	57                   	push   %edi
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
  801070:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801073:	b9 00 00 00 00       	mov    $0x0,%ecx
  801078:	b8 03 00 00 00       	mov    $0x3,%eax
  80107d:	8b 55 08             	mov    0x8(%ebp),%edx
  801080:	89 cb                	mov    %ecx,%ebx
  801082:	89 cf                	mov    %ecx,%edi
  801084:	89 ce                	mov    %ecx,%esi
  801086:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801088:	85 c0                	test   %eax,%eax
  80108a:	7e 17                	jle    8010a3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	50                   	push   %eax
  801090:	6a 03                	push   $0x3
  801092:	68 7f 2f 80 00       	push   $0x802f7f
  801097:	6a 23                	push   $0x23
  801099:	68 9c 2f 80 00       	push   $0x802f9c
  80109e:	e8 e5 f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010bb:	89 d1                	mov    %edx,%ecx
  8010bd:	89 d3                	mov    %edx,%ebx
  8010bf:	89 d7                	mov    %edx,%edi
  8010c1:	89 d6                	mov    %edx,%esi
  8010c3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_yield>:

void
sys_yield(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010da:	89 d1                	mov    %edx,%ecx
  8010dc:	89 d3                	mov    %edx,%ebx
  8010de:	89 d7                	mov    %edx,%edi
  8010e0:	89 d6                	mov    %edx,%esi
  8010e2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	be 00 00 00 00       	mov    $0x0,%esi
  8010f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801105:	89 f7                	mov    %esi,%edi
  801107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801109:	85 c0                	test   %eax,%eax
  80110b:	7e 17                	jle    801124 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	50                   	push   %eax
  801111:	6a 04                	push   $0x4
  801113:	68 7f 2f 80 00       	push   $0x802f7f
  801118:	6a 23                	push   $0x23
  80111a:	68 9c 2f 80 00       	push   $0x802f9c
  80111f:	e8 64 f5 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801135:	b8 05 00 00 00       	mov    $0x5,%eax
  80113a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113d:	8b 55 08             	mov    0x8(%ebp),%edx
  801140:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801143:	8b 7d 14             	mov    0x14(%ebp),%edi
  801146:	8b 75 18             	mov    0x18(%ebp),%esi
  801149:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80114b:	85 c0                	test   %eax,%eax
  80114d:	7e 17                	jle    801166 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	50                   	push   %eax
  801153:	6a 05                	push   $0x5
  801155:	68 7f 2f 80 00       	push   $0x802f7f
  80115a:	6a 23                	push   $0x23
  80115c:	68 9c 2f 80 00       	push   $0x802f9c
  801161:	e8 22 f5 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801177:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117c:	b8 06 00 00 00       	mov    $0x6,%eax
  801181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801184:	8b 55 08             	mov    0x8(%ebp),%edx
  801187:	89 df                	mov    %ebx,%edi
  801189:	89 de                	mov    %ebx,%esi
  80118b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80118d:	85 c0                	test   %eax,%eax
  80118f:	7e 17                	jle    8011a8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	50                   	push   %eax
  801195:	6a 06                	push   $0x6
  801197:	68 7f 2f 80 00       	push   $0x802f7f
  80119c:	6a 23                	push   $0x23
  80119e:	68 9c 2f 80 00       	push   $0x802f9c
  8011a3:	e8 e0 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	57                   	push   %edi
  8011b4:	56                   	push   %esi
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011be:	b8 08 00 00 00       	mov    $0x8,%eax
  8011c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c9:	89 df                	mov    %ebx,%edi
  8011cb:	89 de                	mov    %ebx,%esi
  8011cd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	7e 17                	jle    8011ea <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	50                   	push   %eax
  8011d7:	6a 08                	push   $0x8
  8011d9:	68 7f 2f 80 00       	push   $0x802f7f
  8011de:	6a 23                	push   $0x23
  8011e0:	68 9c 2f 80 00       	push   $0x802f9c
  8011e5:	e8 9e f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	57                   	push   %edi
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801200:	b8 09 00 00 00       	mov    $0x9,%eax
  801205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801208:	8b 55 08             	mov    0x8(%ebp),%edx
  80120b:	89 df                	mov    %ebx,%edi
  80120d:	89 de                	mov    %ebx,%esi
  80120f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801211:	85 c0                	test   %eax,%eax
  801213:	7e 17                	jle    80122c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801215:	83 ec 0c             	sub    $0xc,%esp
  801218:	50                   	push   %eax
  801219:	6a 09                	push   $0x9
  80121b:	68 7f 2f 80 00       	push   $0x802f7f
  801220:	6a 23                	push   $0x23
  801222:	68 9c 2f 80 00       	push   $0x802f9c
  801227:	e8 5c f4 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80122c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	57                   	push   %edi
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	b8 0a 00 00 00       	mov    $0xa,%eax
  801247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124a:	8b 55 08             	mov    0x8(%ebp),%edx
  80124d:	89 df                	mov    %ebx,%edi
  80124f:	89 de                	mov    %ebx,%esi
  801251:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	7e 17                	jle    80126e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	50                   	push   %eax
  80125b:	6a 0a                	push   $0xa
  80125d:	68 7f 2f 80 00       	push   $0x802f7f
  801262:	6a 23                	push   $0x23
  801264:	68 9c 2f 80 00       	push   $0x802f9c
  801269:	e8 1a f4 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80126e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801271:	5b                   	pop    %ebx
  801272:	5e                   	pop    %esi
  801273:	5f                   	pop    %edi
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	57                   	push   %edi
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127c:	be 00 00 00 00       	mov    $0x0,%esi
  801281:	b8 0c 00 00 00       	mov    $0xc,%eax
  801286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801289:	8b 55 08             	mov    0x8(%ebp),%edx
  80128c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801292:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5f                   	pop    %edi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	57                   	push   %edi
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8012af:	89 cb                	mov    %ecx,%ebx
  8012b1:	89 cf                	mov    %ecx,%edi
  8012b3:	89 ce                	mov    %ecx,%esi
  8012b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	7e 17                	jle    8012d2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	50                   	push   %eax
  8012bf:	6a 0d                	push   $0xd
  8012c1:	68 7f 2f 80 00       	push   $0x802f7f
  8012c6:	6a 23                	push   $0x23
  8012c8:	68 9c 2f 80 00       	push   $0x802f9c
  8012cd:	e8 b6 f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	57                   	push   %edi
  8012de:	56                   	push   %esi
  8012df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e5:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012ea:	89 d1                	mov    %edx,%ecx
  8012ec:	89 d3                	mov    %edx,%ebx
  8012ee:	89 d7                	mov    %edx,%edi
  8012f0:	89 d6                	mov    %edx,%esi
  8012f2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	57                   	push   %edi
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801302:	bb 00 00 00 00       	mov    $0x0,%ebx
  801307:	b8 0f 00 00 00       	mov    $0xf,%eax
  80130c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130f:	8b 55 08             	mov    0x8(%ebp),%edx
  801312:	89 df                	mov    %ebx,%edi
  801314:	89 de                	mov    %ebx,%esi
  801316:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801318:	85 c0                	test   %eax,%eax
  80131a:	7e 17                	jle    801333 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131c:	83 ec 0c             	sub    $0xc,%esp
  80131f:	50                   	push   %eax
  801320:	6a 0f                	push   $0xf
  801322:	68 7f 2f 80 00       	push   $0x802f7f
  801327:	6a 23                	push   $0x23
  801329:	68 9c 2f 80 00       	push   $0x802f9c
  80132e:	e8 55 f3 ff ff       	call   800688 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  801333:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801336:	5b                   	pop    %ebx
  801337:	5e                   	pop    %esi
  801338:	5f                   	pop    %edi
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    

0080133b <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	57                   	push   %edi
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
  801341:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801344:	bb 00 00 00 00       	mov    $0x0,%ebx
  801349:	b8 10 00 00 00       	mov    $0x10,%eax
  80134e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801351:	8b 55 08             	mov    0x8(%ebp),%edx
  801354:	89 df                	mov    %ebx,%edi
  801356:	89 de                	mov    %ebx,%esi
  801358:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80135a:	85 c0                	test   %eax,%eax
  80135c:	7e 17                	jle    801375 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135e:	83 ec 0c             	sub    $0xc,%esp
  801361:	50                   	push   %eax
  801362:	6a 10                	push   $0x10
  801364:	68 7f 2f 80 00       	push   $0x802f7f
  801369:	6a 23                	push   $0x23
  80136b:	68 9c 2f 80 00       	push   $0x802f9c
  801370:	e8 13 f3 ff ff       	call   800688 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  801375:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	56                   	push   %esi
  801381:	53                   	push   %ebx
  801382:	8b 75 08             	mov    0x8(%ebp),%esi
  801385:	8b 45 0c             	mov    0xc(%ebp),%eax
  801388:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80138b:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80138d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801392:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	50                   	push   %eax
  801399:	e8 fb fe ff ff       	call   801299 <sys_ipc_recv>

	if (from_env_store != NULL)
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	85 f6                	test   %esi,%esi
  8013a3:	74 14                	je     8013b9 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8013a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 09                	js     8013b7 <ipc_recv+0x3a>
  8013ae:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8013b4:	8b 52 74             	mov    0x74(%edx),%edx
  8013b7:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8013b9:	85 db                	test   %ebx,%ebx
  8013bb:	74 14                	je     8013d1 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8013bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 09                	js     8013cf <ipc_recv+0x52>
  8013c6:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8013cc:	8b 52 78             	mov    0x78(%edx),%edx
  8013cf:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 08                	js     8013dd <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8013d5:	a1 08 50 80 00       	mov    0x805008,%eax
  8013da:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	57                   	push   %edi
  8013e8:	56                   	push   %esi
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8013f6:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8013f8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013fd:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801400:	ff 75 14             	pushl  0x14(%ebp)
  801403:	53                   	push   %ebx
  801404:	56                   	push   %esi
  801405:	57                   	push   %edi
  801406:	e8 6b fe ff ff       	call   801276 <sys_ipc_try_send>

		if (err < 0) {
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	79 1e                	jns    801430 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801412:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801415:	75 07                	jne    80141e <ipc_send+0x3a>
				sys_yield();
  801417:	e8 ae fc ff ff       	call   8010ca <sys_yield>
  80141c:	eb e2                	jmp    801400 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80141e:	50                   	push   %eax
  80141f:	68 aa 2f 80 00       	push   $0x802faa
  801424:	6a 49                	push   $0x49
  801426:	68 b7 2f 80 00       	push   $0x802fb7
  80142b:	e8 58 f2 ff ff       	call   800688 <_panic>
		}

	} while (err < 0);

}
  801430:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801433:	5b                   	pop    %ebx
  801434:	5e                   	pop    %esi
  801435:	5f                   	pop    %edi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80143e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801443:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801446:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80144c:	8b 52 50             	mov    0x50(%edx),%edx
  80144f:	39 ca                	cmp    %ecx,%edx
  801451:	75 0d                	jne    801460 <ipc_find_env+0x28>
			return envs[i].env_id;
  801453:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801456:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80145b:	8b 40 48             	mov    0x48(%eax),%eax
  80145e:	eb 0f                	jmp    80146f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801460:	83 c0 01             	add    $0x1,%eax
  801463:	3d 00 04 00 00       	cmp    $0x400,%eax
  801468:	75 d9                	jne    801443 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80146a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801474:	8b 45 08             	mov    0x8(%ebp),%eax
  801477:	05 00 00 00 30       	add    $0x30000000,%eax
  80147c:	c1 e8 0c             	shr    $0xc,%eax
}
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    

00801481 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	05 00 00 00 30       	add    $0x30000000,%eax
  80148c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801491:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80149e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	c1 ea 16             	shr    $0x16,%edx
  8014a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014af:	f6 c2 01             	test   $0x1,%dl
  8014b2:	74 11                	je     8014c5 <fd_alloc+0x2d>
  8014b4:	89 c2                	mov    %eax,%edx
  8014b6:	c1 ea 0c             	shr    $0xc,%edx
  8014b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014c0:	f6 c2 01             	test   $0x1,%dl
  8014c3:	75 09                	jne    8014ce <fd_alloc+0x36>
			*fd_store = fd;
  8014c5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cc:	eb 17                	jmp    8014e5 <fd_alloc+0x4d>
  8014ce:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014d3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014d8:	75 c9                	jne    8014a3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014da:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014e0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    

008014e7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014ed:	83 f8 1f             	cmp    $0x1f,%eax
  8014f0:	77 36                	ja     801528 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014f2:	c1 e0 0c             	shl    $0xc,%eax
  8014f5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014fa:	89 c2                	mov    %eax,%edx
  8014fc:	c1 ea 16             	shr    $0x16,%edx
  8014ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801506:	f6 c2 01             	test   $0x1,%dl
  801509:	74 24                	je     80152f <fd_lookup+0x48>
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	c1 ea 0c             	shr    $0xc,%edx
  801510:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801517:	f6 c2 01             	test   $0x1,%dl
  80151a:	74 1a                	je     801536 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80151c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80151f:	89 02                	mov    %eax,(%edx)
	return 0;
  801521:	b8 00 00 00 00       	mov    $0x0,%eax
  801526:	eb 13                	jmp    80153b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801528:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152d:	eb 0c                	jmp    80153b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80152f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801534:	eb 05                	jmp    80153b <fd_lookup+0x54>
  801536:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801546:	ba 44 30 80 00       	mov    $0x803044,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80154b:	eb 13                	jmp    801560 <dev_lookup+0x23>
  80154d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801550:	39 08                	cmp    %ecx,(%eax)
  801552:	75 0c                	jne    801560 <dev_lookup+0x23>
			*dev = devtab[i];
  801554:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801557:	89 01                	mov    %eax,(%ecx)
			return 0;
  801559:	b8 00 00 00 00       	mov    $0x0,%eax
  80155e:	eb 2e                	jmp    80158e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801560:	8b 02                	mov    (%edx),%eax
  801562:	85 c0                	test   %eax,%eax
  801564:	75 e7                	jne    80154d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801566:	a1 08 50 80 00       	mov    0x805008,%eax
  80156b:	8b 40 48             	mov    0x48(%eax),%eax
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	51                   	push   %ecx
  801572:	50                   	push   %eax
  801573:	68 c4 2f 80 00       	push   $0x802fc4
  801578:	e8 e4 f1 ff ff       	call   800761 <cprintf>
	*dev = 0;
  80157d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801580:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	56                   	push   %esi
  801594:	53                   	push   %ebx
  801595:	83 ec 10             	sub    $0x10,%esp
  801598:	8b 75 08             	mov    0x8(%ebp),%esi
  80159b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80159e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015a8:	c1 e8 0c             	shr    $0xc,%eax
  8015ab:	50                   	push   %eax
  8015ac:	e8 36 ff ff ff       	call   8014e7 <fd_lookup>
  8015b1:	83 c4 08             	add    $0x8,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 05                	js     8015bd <fd_close+0x2d>
	    || fd != fd2)
  8015b8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015bb:	74 0c                	je     8015c9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015bd:	84 db                	test   %bl,%bl
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c4:	0f 44 c2             	cmove  %edx,%eax
  8015c7:	eb 41                	jmp    80160a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	ff 36                	pushl  (%esi)
  8015d2:	e8 66 ff ff ff       	call   80153d <dev_lookup>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 1a                	js     8015fa <fd_close+0x6a>
		if (dev->dev_close)
  8015e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	74 0b                	je     8015fa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015ef:	83 ec 0c             	sub    $0xc,%esp
  8015f2:	56                   	push   %esi
  8015f3:	ff d0                	call   *%eax
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015fa:	83 ec 08             	sub    $0x8,%esp
  8015fd:	56                   	push   %esi
  8015fe:	6a 00                	push   $0x0
  801600:	e8 69 fb ff ff       	call   80116e <sys_page_unmap>
	return r;
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	89 d8                	mov    %ebx,%eax
}
  80160a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5d                   	pop    %ebp
  801610:	c3                   	ret    

00801611 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	ff 75 08             	pushl  0x8(%ebp)
  80161e:	e8 c4 fe ff ff       	call   8014e7 <fd_lookup>
  801623:	83 c4 08             	add    $0x8,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 10                	js     80163a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	6a 01                	push   $0x1
  80162f:	ff 75 f4             	pushl  -0xc(%ebp)
  801632:	e8 59 ff ff ff       	call   801590 <fd_close>
  801637:	83 c4 10             	add    $0x10,%esp
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <close_all>:

void
close_all(void)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801643:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	53                   	push   %ebx
  80164c:	e8 c0 ff ff ff       	call   801611 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801651:	83 c3 01             	add    $0x1,%ebx
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	83 fb 20             	cmp    $0x20,%ebx
  80165a:	75 ec                	jne    801648 <close_all+0xc>
		close(i);
}
  80165c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	57                   	push   %edi
  801665:	56                   	push   %esi
  801666:	53                   	push   %ebx
  801667:	83 ec 2c             	sub    $0x2c,%esp
  80166a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80166d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	ff 75 08             	pushl  0x8(%ebp)
  801674:	e8 6e fe ff ff       	call   8014e7 <fd_lookup>
  801679:	83 c4 08             	add    $0x8,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	0f 88 c1 00 00 00    	js     801745 <dup+0xe4>
		return r;
	close(newfdnum);
  801684:	83 ec 0c             	sub    $0xc,%esp
  801687:	56                   	push   %esi
  801688:	e8 84 ff ff ff       	call   801611 <close>

	newfd = INDEX2FD(newfdnum);
  80168d:	89 f3                	mov    %esi,%ebx
  80168f:	c1 e3 0c             	shl    $0xc,%ebx
  801692:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801698:	83 c4 04             	add    $0x4,%esp
  80169b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80169e:	e8 de fd ff ff       	call   801481 <fd2data>
  8016a3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016a5:	89 1c 24             	mov    %ebx,(%esp)
  8016a8:	e8 d4 fd ff ff       	call   801481 <fd2data>
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016b3:	89 f8                	mov    %edi,%eax
  8016b5:	c1 e8 16             	shr    $0x16,%eax
  8016b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016bf:	a8 01                	test   $0x1,%al
  8016c1:	74 37                	je     8016fa <dup+0x99>
  8016c3:	89 f8                	mov    %edi,%eax
  8016c5:	c1 e8 0c             	shr    $0xc,%eax
  8016c8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016cf:	f6 c2 01             	test   $0x1,%dl
  8016d2:	74 26                	je     8016fa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016d4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e3:	50                   	push   %eax
  8016e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e7:	6a 00                	push   $0x0
  8016e9:	57                   	push   %edi
  8016ea:	6a 00                	push   $0x0
  8016ec:	e8 3b fa ff ff       	call   80112c <sys_page_map>
  8016f1:	89 c7                	mov    %eax,%edi
  8016f3:	83 c4 20             	add    $0x20,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 2e                	js     801728 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016fd:	89 d0                	mov    %edx,%eax
  8016ff:	c1 e8 0c             	shr    $0xc,%eax
  801702:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801709:	83 ec 0c             	sub    $0xc,%esp
  80170c:	25 07 0e 00 00       	and    $0xe07,%eax
  801711:	50                   	push   %eax
  801712:	53                   	push   %ebx
  801713:	6a 00                	push   $0x0
  801715:	52                   	push   %edx
  801716:	6a 00                	push   $0x0
  801718:	e8 0f fa ff ff       	call   80112c <sys_page_map>
  80171d:	89 c7                	mov    %eax,%edi
  80171f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801722:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801724:	85 ff                	test   %edi,%edi
  801726:	79 1d                	jns    801745 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	53                   	push   %ebx
  80172c:	6a 00                	push   $0x0
  80172e:	e8 3b fa ff ff       	call   80116e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801733:	83 c4 08             	add    $0x8,%esp
  801736:	ff 75 d4             	pushl  -0x2c(%ebp)
  801739:	6a 00                	push   $0x0
  80173b:	e8 2e fa ff ff       	call   80116e <sys_page_unmap>
	return r;
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	89 f8                	mov    %edi,%eax
}
  801745:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5f                   	pop    %edi
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    

0080174d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	53                   	push   %ebx
  801751:	83 ec 14             	sub    $0x14,%esp
  801754:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801757:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	53                   	push   %ebx
  80175c:	e8 86 fd ff ff       	call   8014e7 <fd_lookup>
  801761:	83 c4 08             	add    $0x8,%esp
  801764:	89 c2                	mov    %eax,%edx
  801766:	85 c0                	test   %eax,%eax
  801768:	78 6d                	js     8017d7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801774:	ff 30                	pushl  (%eax)
  801776:	e8 c2 fd ff ff       	call   80153d <dev_lookup>
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 4c                	js     8017ce <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801782:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801785:	8b 42 08             	mov    0x8(%edx),%eax
  801788:	83 e0 03             	and    $0x3,%eax
  80178b:	83 f8 01             	cmp    $0x1,%eax
  80178e:	75 21                	jne    8017b1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801790:	a1 08 50 80 00       	mov    0x805008,%eax
  801795:	8b 40 48             	mov    0x48(%eax),%eax
  801798:	83 ec 04             	sub    $0x4,%esp
  80179b:	53                   	push   %ebx
  80179c:	50                   	push   %eax
  80179d:	68 08 30 80 00       	push   $0x803008
  8017a2:	e8 ba ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017af:	eb 26                	jmp    8017d7 <read+0x8a>
	}
	if (!dev->dev_read)
  8017b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b4:	8b 40 08             	mov    0x8(%eax),%eax
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	74 17                	je     8017d2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	ff 75 10             	pushl  0x10(%ebp)
  8017c1:	ff 75 0c             	pushl  0xc(%ebp)
  8017c4:	52                   	push   %edx
  8017c5:	ff d0                	call   *%eax
  8017c7:	89 c2                	mov    %eax,%edx
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	eb 09                	jmp    8017d7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ce:	89 c2                	mov    %eax,%edx
  8017d0:	eb 05                	jmp    8017d7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017d7:	89 d0                	mov    %edx,%eax
  8017d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	57                   	push   %edi
  8017e2:	56                   	push   %esi
  8017e3:	53                   	push   %ebx
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f2:	eb 21                	jmp    801815 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	89 f0                	mov    %esi,%eax
  8017f9:	29 d8                	sub    %ebx,%eax
  8017fb:	50                   	push   %eax
  8017fc:	89 d8                	mov    %ebx,%eax
  8017fe:	03 45 0c             	add    0xc(%ebp),%eax
  801801:	50                   	push   %eax
  801802:	57                   	push   %edi
  801803:	e8 45 ff ff ff       	call   80174d <read>
		if (m < 0)
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 10                	js     80181f <readn+0x41>
			return m;
		if (m == 0)
  80180f:	85 c0                	test   %eax,%eax
  801811:	74 0a                	je     80181d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801813:	01 c3                	add    %eax,%ebx
  801815:	39 f3                	cmp    %esi,%ebx
  801817:	72 db                	jb     8017f4 <readn+0x16>
  801819:	89 d8                	mov    %ebx,%eax
  80181b:	eb 02                	jmp    80181f <readn+0x41>
  80181d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80181f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5f                   	pop    %edi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	53                   	push   %ebx
  80182b:	83 ec 14             	sub    $0x14,%esp
  80182e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801831:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801834:	50                   	push   %eax
  801835:	53                   	push   %ebx
  801836:	e8 ac fc ff ff       	call   8014e7 <fd_lookup>
  80183b:	83 c4 08             	add    $0x8,%esp
  80183e:	89 c2                	mov    %eax,%edx
  801840:	85 c0                	test   %eax,%eax
  801842:	78 68                	js     8018ac <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184a:	50                   	push   %eax
  80184b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184e:	ff 30                	pushl  (%eax)
  801850:	e8 e8 fc ff ff       	call   80153d <dev_lookup>
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 47                	js     8018a3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80185c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801863:	75 21                	jne    801886 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801865:	a1 08 50 80 00       	mov    0x805008,%eax
  80186a:	8b 40 48             	mov    0x48(%eax),%eax
  80186d:	83 ec 04             	sub    $0x4,%esp
  801870:	53                   	push   %ebx
  801871:	50                   	push   %eax
  801872:	68 24 30 80 00       	push   $0x803024
  801877:	e8 e5 ee ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801884:	eb 26                	jmp    8018ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801886:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801889:	8b 52 0c             	mov    0xc(%edx),%edx
  80188c:	85 d2                	test   %edx,%edx
  80188e:	74 17                	je     8018a7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801890:	83 ec 04             	sub    $0x4,%esp
  801893:	ff 75 10             	pushl  0x10(%ebp)
  801896:	ff 75 0c             	pushl  0xc(%ebp)
  801899:	50                   	push   %eax
  80189a:	ff d2                	call   *%edx
  80189c:	89 c2                	mov    %eax,%edx
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	eb 09                	jmp    8018ac <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a3:	89 c2                	mov    %eax,%edx
  8018a5:	eb 05                	jmp    8018ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018ac:	89 d0                	mov    %edx,%eax
  8018ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018bc:	50                   	push   %eax
  8018bd:	ff 75 08             	pushl  0x8(%ebp)
  8018c0:	e8 22 fc ff ff       	call   8014e7 <fd_lookup>
  8018c5:	83 c4 08             	add    $0x8,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 0e                	js     8018da <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	53                   	push   %ebx
  8018e0:	83 ec 14             	sub    $0x14,%esp
  8018e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e9:	50                   	push   %eax
  8018ea:	53                   	push   %ebx
  8018eb:	e8 f7 fb ff ff       	call   8014e7 <fd_lookup>
  8018f0:	83 c4 08             	add    $0x8,%esp
  8018f3:	89 c2                	mov    %eax,%edx
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 65                	js     80195e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f9:	83 ec 08             	sub    $0x8,%esp
  8018fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ff:	50                   	push   %eax
  801900:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801903:	ff 30                	pushl  (%eax)
  801905:	e8 33 fc ff ff       	call   80153d <dev_lookup>
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	85 c0                	test   %eax,%eax
  80190f:	78 44                	js     801955 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801911:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801914:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801918:	75 21                	jne    80193b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80191a:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80191f:	8b 40 48             	mov    0x48(%eax),%eax
  801922:	83 ec 04             	sub    $0x4,%esp
  801925:	53                   	push   %ebx
  801926:	50                   	push   %eax
  801927:	68 e4 2f 80 00       	push   $0x802fe4
  80192c:	e8 30 ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801939:	eb 23                	jmp    80195e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80193b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193e:	8b 52 18             	mov    0x18(%edx),%edx
  801941:	85 d2                	test   %edx,%edx
  801943:	74 14                	je     801959 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	ff 75 0c             	pushl  0xc(%ebp)
  80194b:	50                   	push   %eax
  80194c:	ff d2                	call   *%edx
  80194e:	89 c2                	mov    %eax,%edx
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	eb 09                	jmp    80195e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801955:	89 c2                	mov    %eax,%edx
  801957:	eb 05                	jmp    80195e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801959:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80195e:	89 d0                	mov    %edx,%eax
  801960:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801963:	c9                   	leave  
  801964:	c3                   	ret    

00801965 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	53                   	push   %ebx
  801969:	83 ec 14             	sub    $0x14,%esp
  80196c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801972:	50                   	push   %eax
  801973:	ff 75 08             	pushl  0x8(%ebp)
  801976:	e8 6c fb ff ff       	call   8014e7 <fd_lookup>
  80197b:	83 c4 08             	add    $0x8,%esp
  80197e:	89 c2                	mov    %eax,%edx
  801980:	85 c0                	test   %eax,%eax
  801982:	78 58                	js     8019dc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801984:	83 ec 08             	sub    $0x8,%esp
  801987:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198a:	50                   	push   %eax
  80198b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198e:	ff 30                	pushl  (%eax)
  801990:	e8 a8 fb ff ff       	call   80153d <dev_lookup>
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	78 37                	js     8019d3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019a3:	74 32                	je     8019d7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019af:	00 00 00 
	stat->st_isdir = 0;
  8019b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b9:	00 00 00 
	stat->st_dev = dev;
  8019bc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	53                   	push   %ebx
  8019c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c9:	ff 50 14             	call   *0x14(%eax)
  8019cc:	89 c2                	mov    %eax,%edx
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	eb 09                	jmp    8019dc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d3:	89 c2                	mov    %eax,%edx
  8019d5:	eb 05                	jmp    8019dc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019dc:	89 d0                	mov    %edx,%eax
  8019de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	56                   	push   %esi
  8019e7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019e8:	83 ec 08             	sub    $0x8,%esp
  8019eb:	6a 00                	push   $0x0
  8019ed:	ff 75 08             	pushl  0x8(%ebp)
  8019f0:	e8 d6 01 00 00       	call   801bcb <open>
  8019f5:	89 c3                	mov    %eax,%ebx
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 1b                	js     801a19 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019fe:	83 ec 08             	sub    $0x8,%esp
  801a01:	ff 75 0c             	pushl  0xc(%ebp)
  801a04:	50                   	push   %eax
  801a05:	e8 5b ff ff ff       	call   801965 <fstat>
  801a0a:	89 c6                	mov    %eax,%esi
	close(fd);
  801a0c:	89 1c 24             	mov    %ebx,(%esp)
  801a0f:	e8 fd fb ff ff       	call   801611 <close>
	return r;
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	89 f0                	mov    %esi,%eax
}
  801a19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	89 c6                	mov    %eax,%esi
  801a27:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a29:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a30:	75 12                	jne    801a44 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	6a 01                	push   $0x1
  801a37:	e8 fc f9 ff ff       	call   801438 <ipc_find_env>
  801a3c:	a3 00 50 80 00       	mov    %eax,0x805000
  801a41:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a44:	6a 07                	push   $0x7
  801a46:	68 00 60 80 00       	push   $0x806000
  801a4b:	56                   	push   %esi
  801a4c:	ff 35 00 50 80 00    	pushl  0x805000
  801a52:	e8 8d f9 ff ff       	call   8013e4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a57:	83 c4 0c             	add    $0xc,%esp
  801a5a:	6a 00                	push   $0x0
  801a5c:	53                   	push   %ebx
  801a5d:	6a 00                	push   $0x0
  801a5f:	e8 19 f9 ff ff       	call   80137d <ipc_recv>
}
  801a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a71:	8b 45 08             	mov    0x8(%ebp),%eax
  801a74:	8b 40 0c             	mov    0xc(%eax),%eax
  801a77:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7f:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a84:	ba 00 00 00 00       	mov    $0x0,%edx
  801a89:	b8 02 00 00 00       	mov    $0x2,%eax
  801a8e:	e8 8d ff ff ff       	call   801a20 <fsipc>
}
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9e:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa1:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  801aab:	b8 06 00 00 00       	mov    $0x6,%eax
  801ab0:	e8 6b ff ff ff       	call   801a20 <fsipc>
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	53                   	push   %ebx
  801abb:	83 ec 04             	sub    $0x4,%esp
  801abe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac7:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801acc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad1:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad6:	e8 45 ff ff ff       	call   801a20 <fsipc>
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 2c                	js     801b0b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	68 00 60 80 00       	push   $0x806000
  801ae7:	53                   	push   %ebx
  801ae8:	e8 f9 f1 ff ff       	call   800ce6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aed:	a1 80 60 80 00       	mov    0x806080,%eax
  801af2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801af8:	a1 84 60 80 00       	mov    0x806084,%eax
  801afd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b19:	8b 55 08             	mov    0x8(%ebp),%edx
  801b1c:	8b 52 0c             	mov    0xc(%edx),%edx
  801b1f:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b25:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b2a:	50                   	push   %eax
  801b2b:	ff 75 0c             	pushl  0xc(%ebp)
  801b2e:	68 08 60 80 00       	push   $0x806008
  801b33:	e8 40 f3 ff ff       	call   800e78 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801b38:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3d:	b8 04 00 00 00       	mov    $0x4,%eax
  801b42:	e8 d9 fe ff ff       	call   801a20 <fsipc>

}
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	8b 40 0c             	mov    0xc(%eax),%eax
  801b57:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b5c:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b62:	ba 00 00 00 00       	mov    $0x0,%edx
  801b67:	b8 03 00 00 00       	mov    $0x3,%eax
  801b6c:	e8 af fe ff ff       	call   801a20 <fsipc>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 4b                	js     801bc2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b77:	39 c6                	cmp    %eax,%esi
  801b79:	73 16                	jae    801b91 <devfile_read+0x48>
  801b7b:	68 58 30 80 00       	push   $0x803058
  801b80:	68 5f 30 80 00       	push   $0x80305f
  801b85:	6a 7c                	push   $0x7c
  801b87:	68 74 30 80 00       	push   $0x803074
  801b8c:	e8 f7 ea ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801b91:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b96:	7e 16                	jle    801bae <devfile_read+0x65>
  801b98:	68 7f 30 80 00       	push   $0x80307f
  801b9d:	68 5f 30 80 00       	push   $0x80305f
  801ba2:	6a 7d                	push   $0x7d
  801ba4:	68 74 30 80 00       	push   $0x803074
  801ba9:	e8 da ea ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bae:	83 ec 04             	sub    $0x4,%esp
  801bb1:	50                   	push   %eax
  801bb2:	68 00 60 80 00       	push   $0x806000
  801bb7:	ff 75 0c             	pushl  0xc(%ebp)
  801bba:	e8 b9 f2 ff ff       	call   800e78 <memmove>
	return r;
  801bbf:	83 c4 10             	add    $0x10,%esp
}
  801bc2:	89 d8                	mov    %ebx,%eax
  801bc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 20             	sub    $0x20,%esp
  801bd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bd5:	53                   	push   %ebx
  801bd6:	e8 d2 f0 ff ff       	call   800cad <strlen>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801be3:	7f 67                	jg     801c4c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801beb:	50                   	push   %eax
  801bec:	e8 a7 f8 ff ff       	call   801498 <fd_alloc>
  801bf1:	83 c4 10             	add    $0x10,%esp
		return r;
  801bf4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 57                	js     801c51 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bfa:	83 ec 08             	sub    $0x8,%esp
  801bfd:	53                   	push   %ebx
  801bfe:	68 00 60 80 00       	push   $0x806000
  801c03:	e8 de f0 ff ff       	call   800ce6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0b:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c13:	b8 01 00 00 00       	mov    $0x1,%eax
  801c18:	e8 03 fe ff ff       	call   801a20 <fsipc>
  801c1d:	89 c3                	mov    %eax,%ebx
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	85 c0                	test   %eax,%eax
  801c24:	79 14                	jns    801c3a <open+0x6f>
		fd_close(fd, 0);
  801c26:	83 ec 08             	sub    $0x8,%esp
  801c29:	6a 00                	push   $0x0
  801c2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2e:	e8 5d f9 ff ff       	call   801590 <fd_close>
		return r;
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	89 da                	mov    %ebx,%edx
  801c38:	eb 17                	jmp    801c51 <open+0x86>
	}

	return fd2num(fd);
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c40:	e8 2c f8 ff ff       	call   801471 <fd2num>
  801c45:	89 c2                	mov    %eax,%edx
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	eb 05                	jmp    801c51 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c4c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c51:	89 d0                	mov    %edx,%eax
  801c53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c63:	b8 08 00 00 00       	mov    $0x8,%eax
  801c68:	e8 b3 fd ff ff       	call   801a20 <fsipc>
}
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c75:	68 8b 30 80 00       	push   $0x80308b
  801c7a:	ff 75 0c             	pushl  0xc(%ebp)
  801c7d:	e8 64 f0 ff ff       	call   800ce6 <strcpy>
	return 0;
}
  801c82:	b8 00 00 00 00       	mov    $0x0,%eax
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	53                   	push   %ebx
  801c8d:	83 ec 10             	sub    $0x10,%esp
  801c90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c93:	53                   	push   %ebx
  801c94:	e8 1c 09 00 00       	call   8025b5 <pageref>
  801c99:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c9c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ca1:	83 f8 01             	cmp    $0x1,%eax
  801ca4:	75 10                	jne    801cb6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ca6:	83 ec 0c             	sub    $0xc,%esp
  801ca9:	ff 73 0c             	pushl  0xc(%ebx)
  801cac:	e8 c0 02 00 00       	call   801f71 <nsipc_close>
  801cb1:	89 c2                	mov    %eax,%edx
  801cb3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    

00801cbd <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cc3:	6a 00                	push   $0x0
  801cc5:	ff 75 10             	pushl  0x10(%ebp)
  801cc8:	ff 75 0c             	pushl  0xc(%ebp)
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	ff 70 0c             	pushl  0xc(%eax)
  801cd1:	e8 78 03 00 00       	call   80204e <nsipc_send>
}
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cde:	6a 00                	push   $0x0
  801ce0:	ff 75 10             	pushl  0x10(%ebp)
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce9:	ff 70 0c             	pushl  0xc(%eax)
  801cec:	e8 f1 02 00 00       	call   801fe2 <nsipc_recv>
}
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cf9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cfc:	52                   	push   %edx
  801cfd:	50                   	push   %eax
  801cfe:	e8 e4 f7 ff ff       	call   8014e7 <fd_lookup>
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 17                	js     801d21 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801d13:	39 08                	cmp    %ecx,(%eax)
  801d15:	75 05                	jne    801d1c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d17:	8b 40 0c             	mov    0xc(%eax),%eax
  801d1a:	eb 05                	jmp    801d21 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d1c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	83 ec 1c             	sub    $0x1c,%esp
  801d2b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d30:	50                   	push   %eax
  801d31:	e8 62 f7 ff ff       	call   801498 <fd_alloc>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	78 1b                	js     801d5a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d3f:	83 ec 04             	sub    $0x4,%esp
  801d42:	68 07 04 00 00       	push   $0x407
  801d47:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4a:	6a 00                	push   $0x0
  801d4c:	e8 98 f3 ff ff       	call   8010e9 <sys_page_alloc>
  801d51:	89 c3                	mov    %eax,%ebx
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	85 c0                	test   %eax,%eax
  801d58:	79 10                	jns    801d6a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	56                   	push   %esi
  801d5e:	e8 0e 02 00 00       	call   801f71 <nsipc_close>
		return r;
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	89 d8                	mov    %ebx,%eax
  801d68:	eb 24                	jmp    801d8e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d6a:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d73:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d78:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d7f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	50                   	push   %eax
  801d86:	e8 e6 f6 ff ff       	call   801471 <fd2num>
  801d8b:	83 c4 10             	add    $0x10,%esp
}
  801d8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d91:	5b                   	pop    %ebx
  801d92:	5e                   	pop    %esi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	e8 50 ff ff ff       	call   801cf3 <fd2sockid>
		return r;
  801da3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801da5:	85 c0                	test   %eax,%eax
  801da7:	78 1f                	js     801dc8 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801da9:	83 ec 04             	sub    $0x4,%esp
  801dac:	ff 75 10             	pushl  0x10(%ebp)
  801daf:	ff 75 0c             	pushl  0xc(%ebp)
  801db2:	50                   	push   %eax
  801db3:	e8 12 01 00 00       	call   801eca <nsipc_accept>
  801db8:	83 c4 10             	add    $0x10,%esp
		return r;
  801dbb:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	78 07                	js     801dc8 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801dc1:	e8 5d ff ff ff       	call   801d23 <alloc_sockfd>
  801dc6:	89 c1                	mov    %eax,%ecx
}
  801dc8:	89 c8                	mov    %ecx,%eax
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd5:	e8 19 ff ff ff       	call   801cf3 <fd2sockid>
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	78 12                	js     801df0 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801dde:	83 ec 04             	sub    $0x4,%esp
  801de1:	ff 75 10             	pushl  0x10(%ebp)
  801de4:	ff 75 0c             	pushl  0xc(%ebp)
  801de7:	50                   	push   %eax
  801de8:	e8 2d 01 00 00       	call   801f1a <nsipc_bind>
  801ded:	83 c4 10             	add    $0x10,%esp
}
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <shutdown>:

int
shutdown(int s, int how)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfb:	e8 f3 fe ff ff       	call   801cf3 <fd2sockid>
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 0f                	js     801e13 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e04:	83 ec 08             	sub    $0x8,%esp
  801e07:	ff 75 0c             	pushl  0xc(%ebp)
  801e0a:	50                   	push   %eax
  801e0b:	e8 3f 01 00 00       	call   801f4f <nsipc_shutdown>
  801e10:	83 c4 10             	add    $0x10,%esp
}
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    

00801e15 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1e:	e8 d0 fe ff ff       	call   801cf3 <fd2sockid>
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 12                	js     801e39 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e27:	83 ec 04             	sub    $0x4,%esp
  801e2a:	ff 75 10             	pushl  0x10(%ebp)
  801e2d:	ff 75 0c             	pushl  0xc(%ebp)
  801e30:	50                   	push   %eax
  801e31:	e8 55 01 00 00       	call   801f8b <nsipc_connect>
  801e36:	83 c4 10             	add    $0x10,%esp
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <listen>:

int
listen(int s, int backlog)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e41:	8b 45 08             	mov    0x8(%ebp),%eax
  801e44:	e8 aa fe ff ff       	call   801cf3 <fd2sockid>
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 0f                	js     801e5c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e4d:	83 ec 08             	sub    $0x8,%esp
  801e50:	ff 75 0c             	pushl  0xc(%ebp)
  801e53:	50                   	push   %eax
  801e54:	e8 67 01 00 00       	call   801fc0 <nsipc_listen>
  801e59:	83 c4 10             	add    $0x10,%esp
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e64:	ff 75 10             	pushl  0x10(%ebp)
  801e67:	ff 75 0c             	pushl  0xc(%ebp)
  801e6a:	ff 75 08             	pushl  0x8(%ebp)
  801e6d:	e8 3a 02 00 00       	call   8020ac <nsipc_socket>
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	85 c0                	test   %eax,%eax
  801e77:	78 05                	js     801e7e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e79:	e8 a5 fe ff ff       	call   801d23 <alloc_sockfd>
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	53                   	push   %ebx
  801e84:	83 ec 04             	sub    $0x4,%esp
  801e87:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e89:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801e90:	75 12                	jne    801ea4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	6a 02                	push   $0x2
  801e97:	e8 9c f5 ff ff       	call   801438 <ipc_find_env>
  801e9c:	a3 04 50 80 00       	mov    %eax,0x805004
  801ea1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ea4:	6a 07                	push   $0x7
  801ea6:	68 00 70 80 00       	push   $0x807000
  801eab:	53                   	push   %ebx
  801eac:	ff 35 04 50 80 00    	pushl  0x805004
  801eb2:	e8 2d f5 ff ff       	call   8013e4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801eb7:	83 c4 0c             	add    $0xc,%esp
  801eba:	6a 00                	push   $0x0
  801ebc:	6a 00                	push   $0x0
  801ebe:	6a 00                	push   $0x0
  801ec0:	e8 b8 f4 ff ff       	call   80137d <ipc_recv>
}
  801ec5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	56                   	push   %esi
  801ece:	53                   	push   %ebx
  801ecf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801eda:	8b 06                	mov    (%esi),%eax
  801edc:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ee1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee6:	e8 95 ff ff ff       	call   801e80 <nsipc>
  801eeb:	89 c3                	mov    %eax,%ebx
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 20                	js     801f11 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ef1:	83 ec 04             	sub    $0x4,%esp
  801ef4:	ff 35 10 70 80 00    	pushl  0x807010
  801efa:	68 00 70 80 00       	push   $0x807000
  801eff:	ff 75 0c             	pushl  0xc(%ebp)
  801f02:	e8 71 ef ff ff       	call   800e78 <memmove>
		*addrlen = ret->ret_addrlen;
  801f07:	a1 10 70 80 00       	mov    0x807010,%eax
  801f0c:	89 06                	mov    %eax,(%esi)
  801f0e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f11:	89 d8                	mov    %ebx,%eax
  801f13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f16:	5b                   	pop    %ebx
  801f17:	5e                   	pop    %esi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    

00801f1a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	53                   	push   %ebx
  801f1e:	83 ec 08             	sub    $0x8,%esp
  801f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f24:	8b 45 08             	mov    0x8(%ebp),%eax
  801f27:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f2c:	53                   	push   %ebx
  801f2d:	ff 75 0c             	pushl  0xc(%ebp)
  801f30:	68 04 70 80 00       	push   $0x807004
  801f35:	e8 3e ef ff ff       	call   800e78 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f3a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f40:	b8 02 00 00 00       	mov    $0x2,%eax
  801f45:	e8 36 ff ff ff       	call   801e80 <nsipc>
}
  801f4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f4d:	c9                   	leave  
  801f4e:	c3                   	ret    

00801f4f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f55:	8b 45 08             	mov    0x8(%ebp),%eax
  801f58:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f60:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f65:	b8 03 00 00 00       	mov    $0x3,%eax
  801f6a:	e8 11 ff ff ff       	call   801e80 <nsipc>
}
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <nsipc_close>:

int
nsipc_close(int s)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f77:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7a:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801f7f:	b8 04 00 00 00       	mov    $0x4,%eax
  801f84:	e8 f7 fe ff ff       	call   801e80 <nsipc>
}
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    

00801f8b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	53                   	push   %ebx
  801f8f:	83 ec 08             	sub    $0x8,%esp
  801f92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f95:	8b 45 08             	mov    0x8(%ebp),%eax
  801f98:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f9d:	53                   	push   %ebx
  801f9e:	ff 75 0c             	pushl  0xc(%ebp)
  801fa1:	68 04 70 80 00       	push   $0x807004
  801fa6:	e8 cd ee ff ff       	call   800e78 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fab:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801fb1:	b8 05 00 00 00       	mov    $0x5,%eax
  801fb6:	e8 c5 fe ff ff       	call   801e80 <nsipc>
}
  801fbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fbe:	c9                   	leave  
  801fbf:	c3                   	ret    

00801fc0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801fce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801fd6:	b8 06 00 00 00       	mov    $0x6,%eax
  801fdb:	e8 a0 fe ff ff       	call   801e80 <nsipc>
}
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	56                   	push   %esi
  801fe6:	53                   	push   %ebx
  801fe7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fea:	8b 45 08             	mov    0x8(%ebp),%eax
  801fed:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801ff2:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801ff8:	8b 45 14             	mov    0x14(%ebp),%eax
  801ffb:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802000:	b8 07 00 00 00       	mov    $0x7,%eax
  802005:	e8 76 fe ff ff       	call   801e80 <nsipc>
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	85 c0                	test   %eax,%eax
  80200e:	78 35                	js     802045 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802010:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802015:	7f 04                	jg     80201b <nsipc_recv+0x39>
  802017:	39 c6                	cmp    %eax,%esi
  802019:	7d 16                	jge    802031 <nsipc_recv+0x4f>
  80201b:	68 97 30 80 00       	push   $0x803097
  802020:	68 5f 30 80 00       	push   $0x80305f
  802025:	6a 62                	push   $0x62
  802027:	68 ac 30 80 00       	push   $0x8030ac
  80202c:	e8 57 e6 ff ff       	call   800688 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802031:	83 ec 04             	sub    $0x4,%esp
  802034:	50                   	push   %eax
  802035:	68 00 70 80 00       	push   $0x807000
  80203a:	ff 75 0c             	pushl  0xc(%ebp)
  80203d:	e8 36 ee ff ff       	call   800e78 <memmove>
  802042:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802045:	89 d8                	mov    %ebx,%eax
  802047:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80204a:	5b                   	pop    %ebx
  80204b:	5e                   	pop    %esi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	53                   	push   %ebx
  802052:	83 ec 04             	sub    $0x4,%esp
  802055:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802058:	8b 45 08             	mov    0x8(%ebp),%eax
  80205b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802060:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802066:	7e 16                	jle    80207e <nsipc_send+0x30>
  802068:	68 b8 30 80 00       	push   $0x8030b8
  80206d:	68 5f 30 80 00       	push   $0x80305f
  802072:	6a 6d                	push   $0x6d
  802074:	68 ac 30 80 00       	push   $0x8030ac
  802079:	e8 0a e6 ff ff       	call   800688 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80207e:	83 ec 04             	sub    $0x4,%esp
  802081:	53                   	push   %ebx
  802082:	ff 75 0c             	pushl  0xc(%ebp)
  802085:	68 0c 70 80 00       	push   $0x80700c
  80208a:	e8 e9 ed ff ff       	call   800e78 <memmove>
	nsipcbuf.send.req_size = size;
  80208f:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802095:	8b 45 14             	mov    0x14(%ebp),%eax
  802098:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80209d:	b8 08 00 00 00       	mov    $0x8,%eax
  8020a2:	e8 d9 fd ff ff       	call   801e80 <nsipc>
}
  8020a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020aa:	c9                   	leave  
  8020ab:	c3                   	ret    

008020ac <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8020ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020bd:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8020c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8020ca:	b8 09 00 00 00       	mov    $0x9,%eax
  8020cf:	e8 ac fd ff ff       	call   801e80 <nsipc>
}
  8020d4:	c9                   	leave  
  8020d5:	c3                   	ret    

008020d6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	56                   	push   %esi
  8020da:	53                   	push   %ebx
  8020db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020de:	83 ec 0c             	sub    $0xc,%esp
  8020e1:	ff 75 08             	pushl  0x8(%ebp)
  8020e4:	e8 98 f3 ff ff       	call   801481 <fd2data>
  8020e9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020eb:	83 c4 08             	add    $0x8,%esp
  8020ee:	68 c4 30 80 00       	push   $0x8030c4
  8020f3:	53                   	push   %ebx
  8020f4:	e8 ed eb ff ff       	call   800ce6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020f9:	8b 46 04             	mov    0x4(%esi),%eax
  8020fc:	2b 06                	sub    (%esi),%eax
  8020fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802104:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80210b:	00 00 00 
	stat->st_dev = &devpipe;
  80210e:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  802115:	40 80 00 
	return 0;
}
  802118:	b8 00 00 00 00       	mov    $0x0,%eax
  80211d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	53                   	push   %ebx
  802128:	83 ec 0c             	sub    $0xc,%esp
  80212b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80212e:	53                   	push   %ebx
  80212f:	6a 00                	push   $0x0
  802131:	e8 38 f0 ff ff       	call   80116e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802136:	89 1c 24             	mov    %ebx,(%esp)
  802139:	e8 43 f3 ff ff       	call   801481 <fd2data>
  80213e:	83 c4 08             	add    $0x8,%esp
  802141:	50                   	push   %eax
  802142:	6a 00                	push   $0x0
  802144:	e8 25 f0 ff ff       	call   80116e <sys_page_unmap>
}
  802149:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80214c:	c9                   	leave  
  80214d:	c3                   	ret    

0080214e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80215a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80215c:	a1 08 50 80 00       	mov    0x805008,%eax
  802161:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802164:	83 ec 0c             	sub    $0xc,%esp
  802167:	ff 75 e0             	pushl  -0x20(%ebp)
  80216a:	e8 46 04 00 00       	call   8025b5 <pageref>
  80216f:	89 c3                	mov    %eax,%ebx
  802171:	89 3c 24             	mov    %edi,(%esp)
  802174:	e8 3c 04 00 00       	call   8025b5 <pageref>
  802179:	83 c4 10             	add    $0x10,%esp
  80217c:	39 c3                	cmp    %eax,%ebx
  80217e:	0f 94 c1             	sete   %cl
  802181:	0f b6 c9             	movzbl %cl,%ecx
  802184:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802187:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80218d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802190:	39 ce                	cmp    %ecx,%esi
  802192:	74 1b                	je     8021af <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802194:	39 c3                	cmp    %eax,%ebx
  802196:	75 c4                	jne    80215c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802198:	8b 42 58             	mov    0x58(%edx),%eax
  80219b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80219e:	50                   	push   %eax
  80219f:	56                   	push   %esi
  8021a0:	68 cb 30 80 00       	push   $0x8030cb
  8021a5:	e8 b7 e5 ff ff       	call   800761 <cprintf>
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	eb ad                	jmp    80215c <_pipeisclosed+0xe>
	}
}
  8021af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b5:	5b                   	pop    %ebx
  8021b6:	5e                   	pop    %esi
  8021b7:	5f                   	pop    %edi
  8021b8:	5d                   	pop    %ebp
  8021b9:	c3                   	ret    

008021ba <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
  8021bd:	57                   	push   %edi
  8021be:	56                   	push   %esi
  8021bf:	53                   	push   %ebx
  8021c0:	83 ec 28             	sub    $0x28,%esp
  8021c3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021c6:	56                   	push   %esi
  8021c7:	e8 b5 f2 ff ff       	call   801481 <fd2data>
  8021cc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021ce:	83 c4 10             	add    $0x10,%esp
  8021d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8021d6:	eb 4b                	jmp    802223 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021d8:	89 da                	mov    %ebx,%edx
  8021da:	89 f0                	mov    %esi,%eax
  8021dc:	e8 6d ff ff ff       	call   80214e <_pipeisclosed>
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	75 48                	jne    80222d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021e5:	e8 e0 ee ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021ea:	8b 43 04             	mov    0x4(%ebx),%eax
  8021ed:	8b 0b                	mov    (%ebx),%ecx
  8021ef:	8d 51 20             	lea    0x20(%ecx),%edx
  8021f2:	39 d0                	cmp    %edx,%eax
  8021f4:	73 e2                	jae    8021d8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021f9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021fd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802200:	89 c2                	mov    %eax,%edx
  802202:	c1 fa 1f             	sar    $0x1f,%edx
  802205:	89 d1                	mov    %edx,%ecx
  802207:	c1 e9 1b             	shr    $0x1b,%ecx
  80220a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80220d:	83 e2 1f             	and    $0x1f,%edx
  802210:	29 ca                	sub    %ecx,%edx
  802212:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802216:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80221a:	83 c0 01             	add    $0x1,%eax
  80221d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802220:	83 c7 01             	add    $0x1,%edi
  802223:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802226:	75 c2                	jne    8021ea <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802228:	8b 45 10             	mov    0x10(%ebp),%eax
  80222b:	eb 05                	jmp    802232 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80222d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802235:	5b                   	pop    %ebx
  802236:	5e                   	pop    %esi
  802237:	5f                   	pop    %edi
  802238:	5d                   	pop    %ebp
  802239:	c3                   	ret    

0080223a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	57                   	push   %edi
  80223e:	56                   	push   %esi
  80223f:	53                   	push   %ebx
  802240:	83 ec 18             	sub    $0x18,%esp
  802243:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802246:	57                   	push   %edi
  802247:	e8 35 f2 ff ff       	call   801481 <fd2data>
  80224c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80224e:	83 c4 10             	add    $0x10,%esp
  802251:	bb 00 00 00 00       	mov    $0x0,%ebx
  802256:	eb 3d                	jmp    802295 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802258:	85 db                	test   %ebx,%ebx
  80225a:	74 04                	je     802260 <devpipe_read+0x26>
				return i;
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	eb 44                	jmp    8022a4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802260:	89 f2                	mov    %esi,%edx
  802262:	89 f8                	mov    %edi,%eax
  802264:	e8 e5 fe ff ff       	call   80214e <_pipeisclosed>
  802269:	85 c0                	test   %eax,%eax
  80226b:	75 32                	jne    80229f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80226d:	e8 58 ee ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802272:	8b 06                	mov    (%esi),%eax
  802274:	3b 46 04             	cmp    0x4(%esi),%eax
  802277:	74 df                	je     802258 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802279:	99                   	cltd   
  80227a:	c1 ea 1b             	shr    $0x1b,%edx
  80227d:	01 d0                	add    %edx,%eax
  80227f:	83 e0 1f             	and    $0x1f,%eax
  802282:	29 d0                	sub    %edx,%eax
  802284:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802289:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80228c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80228f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802292:	83 c3 01             	add    $0x1,%ebx
  802295:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802298:	75 d8                	jne    802272 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80229a:	8b 45 10             	mov    0x10(%ebp),%eax
  80229d:	eb 05                	jmp    8022a4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80229f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    

008022ac <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022ac:	55                   	push   %ebp
  8022ad:	89 e5                	mov    %esp,%ebp
  8022af:	56                   	push   %esi
  8022b0:	53                   	push   %ebx
  8022b1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b7:	50                   	push   %eax
  8022b8:	e8 db f1 ff ff       	call   801498 <fd_alloc>
  8022bd:	83 c4 10             	add    $0x10,%esp
  8022c0:	89 c2                	mov    %eax,%edx
  8022c2:	85 c0                	test   %eax,%eax
  8022c4:	0f 88 2c 01 00 00    	js     8023f6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ca:	83 ec 04             	sub    $0x4,%esp
  8022cd:	68 07 04 00 00       	push   $0x407
  8022d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022d5:	6a 00                	push   $0x0
  8022d7:	e8 0d ee ff ff       	call   8010e9 <sys_page_alloc>
  8022dc:	83 c4 10             	add    $0x10,%esp
  8022df:	89 c2                	mov    %eax,%edx
  8022e1:	85 c0                	test   %eax,%eax
  8022e3:	0f 88 0d 01 00 00    	js     8023f6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022e9:	83 ec 0c             	sub    $0xc,%esp
  8022ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022ef:	50                   	push   %eax
  8022f0:	e8 a3 f1 ff ff       	call   801498 <fd_alloc>
  8022f5:	89 c3                	mov    %eax,%ebx
  8022f7:	83 c4 10             	add    $0x10,%esp
  8022fa:	85 c0                	test   %eax,%eax
  8022fc:	0f 88 e2 00 00 00    	js     8023e4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802302:	83 ec 04             	sub    $0x4,%esp
  802305:	68 07 04 00 00       	push   $0x407
  80230a:	ff 75 f0             	pushl  -0x10(%ebp)
  80230d:	6a 00                	push   $0x0
  80230f:	e8 d5 ed ff ff       	call   8010e9 <sys_page_alloc>
  802314:	89 c3                	mov    %eax,%ebx
  802316:	83 c4 10             	add    $0x10,%esp
  802319:	85 c0                	test   %eax,%eax
  80231b:	0f 88 c3 00 00 00    	js     8023e4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802321:	83 ec 0c             	sub    $0xc,%esp
  802324:	ff 75 f4             	pushl  -0xc(%ebp)
  802327:	e8 55 f1 ff ff       	call   801481 <fd2data>
  80232c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80232e:	83 c4 0c             	add    $0xc,%esp
  802331:	68 07 04 00 00       	push   $0x407
  802336:	50                   	push   %eax
  802337:	6a 00                	push   $0x0
  802339:	e8 ab ed ff ff       	call   8010e9 <sys_page_alloc>
  80233e:	89 c3                	mov    %eax,%ebx
  802340:	83 c4 10             	add    $0x10,%esp
  802343:	85 c0                	test   %eax,%eax
  802345:	0f 88 89 00 00 00    	js     8023d4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80234b:	83 ec 0c             	sub    $0xc,%esp
  80234e:	ff 75 f0             	pushl  -0x10(%ebp)
  802351:	e8 2b f1 ff ff       	call   801481 <fd2data>
  802356:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80235d:	50                   	push   %eax
  80235e:	6a 00                	push   $0x0
  802360:	56                   	push   %esi
  802361:	6a 00                	push   $0x0
  802363:	e8 c4 ed ff ff       	call   80112c <sys_page_map>
  802368:	89 c3                	mov    %eax,%ebx
  80236a:	83 c4 20             	add    $0x20,%esp
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 55                	js     8023c6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802371:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802377:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80237c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802386:	8b 15 40 40 80 00    	mov    0x804040,%edx
  80238c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80238f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802391:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802394:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80239b:	83 ec 0c             	sub    $0xc,%esp
  80239e:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a1:	e8 cb f0 ff ff       	call   801471 <fd2num>
  8023a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023a9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023ab:	83 c4 04             	add    $0x4,%esp
  8023ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8023b1:	e8 bb f0 ff ff       	call   801471 <fd2num>
  8023b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023b9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023bc:	83 c4 10             	add    $0x10,%esp
  8023bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c4:	eb 30                	jmp    8023f6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8023c6:	83 ec 08             	sub    $0x8,%esp
  8023c9:	56                   	push   %esi
  8023ca:	6a 00                	push   $0x0
  8023cc:	e8 9d ed ff ff       	call   80116e <sys_page_unmap>
  8023d1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023d4:	83 ec 08             	sub    $0x8,%esp
  8023d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8023da:	6a 00                	push   $0x0
  8023dc:	e8 8d ed ff ff       	call   80116e <sys_page_unmap>
  8023e1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023e4:	83 ec 08             	sub    $0x8,%esp
  8023e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ea:	6a 00                	push   $0x0
  8023ec:	e8 7d ed ff ff       	call   80116e <sys_page_unmap>
  8023f1:	83 c4 10             	add    $0x10,%esp
  8023f4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8023f6:	89 d0                	mov    %edx,%eax
  8023f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023fb:	5b                   	pop    %ebx
  8023fc:	5e                   	pop    %esi
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802408:	50                   	push   %eax
  802409:	ff 75 08             	pushl  0x8(%ebp)
  80240c:	e8 d6 f0 ff ff       	call   8014e7 <fd_lookup>
  802411:	83 c4 10             	add    $0x10,%esp
  802414:	85 c0                	test   %eax,%eax
  802416:	78 18                	js     802430 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802418:	83 ec 0c             	sub    $0xc,%esp
  80241b:	ff 75 f4             	pushl  -0xc(%ebp)
  80241e:	e8 5e f0 ff ff       	call   801481 <fd2data>
	return _pipeisclosed(fd, p);
  802423:	89 c2                	mov    %eax,%edx
  802425:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802428:	e8 21 fd ff ff       	call   80214e <_pipeisclosed>
  80242d:	83 c4 10             	add    $0x10,%esp
}
  802430:	c9                   	leave  
  802431:	c3                   	ret    

00802432 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802432:	55                   	push   %ebp
  802433:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802435:	b8 00 00 00 00       	mov    $0x0,%eax
  80243a:	5d                   	pop    %ebp
  80243b:	c3                   	ret    

0080243c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80243c:	55                   	push   %ebp
  80243d:	89 e5                	mov    %esp,%ebp
  80243f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802442:	68 e3 30 80 00       	push   $0x8030e3
  802447:	ff 75 0c             	pushl  0xc(%ebp)
  80244a:	e8 97 e8 ff ff       	call   800ce6 <strcpy>
	return 0;
}
  80244f:	b8 00 00 00 00       	mov    $0x0,%eax
  802454:	c9                   	leave  
  802455:	c3                   	ret    

00802456 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802456:	55                   	push   %ebp
  802457:	89 e5                	mov    %esp,%ebp
  802459:	57                   	push   %edi
  80245a:	56                   	push   %esi
  80245b:	53                   	push   %ebx
  80245c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802462:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802467:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80246d:	eb 2d                	jmp    80249c <devcons_write+0x46>
		m = n - tot;
  80246f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802472:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802474:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802477:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80247c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80247f:	83 ec 04             	sub    $0x4,%esp
  802482:	53                   	push   %ebx
  802483:	03 45 0c             	add    0xc(%ebp),%eax
  802486:	50                   	push   %eax
  802487:	57                   	push   %edi
  802488:	e8 eb e9 ff ff       	call   800e78 <memmove>
		sys_cputs(buf, m);
  80248d:	83 c4 08             	add    $0x8,%esp
  802490:	53                   	push   %ebx
  802491:	57                   	push   %edi
  802492:	e8 96 eb ff ff       	call   80102d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802497:	01 de                	add    %ebx,%esi
  802499:	83 c4 10             	add    $0x10,%esp
  80249c:	89 f0                	mov    %esi,%eax
  80249e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024a1:	72 cc                	jb     80246f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a6:	5b                   	pop    %ebx
  8024a7:	5e                   	pop    %esi
  8024a8:	5f                   	pop    %edi
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    

008024ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	83 ec 08             	sub    $0x8,%esp
  8024b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8024b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024ba:	74 2a                	je     8024e6 <devcons_read+0x3b>
  8024bc:	eb 05                	jmp    8024c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024be:	e8 07 ec ff ff       	call   8010ca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8024c3:	e8 83 eb ff ff       	call   80104b <sys_cgetc>
  8024c8:	85 c0                	test   %eax,%eax
  8024ca:	74 f2                	je     8024be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024cc:	85 c0                	test   %eax,%eax
  8024ce:	78 16                	js     8024e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024d0:	83 f8 04             	cmp    $0x4,%eax
  8024d3:	74 0c                	je     8024e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8024d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024d8:	88 02                	mov    %al,(%edx)
	return 1;
  8024da:	b8 01 00 00 00       	mov    $0x1,%eax
  8024df:	eb 05                	jmp    8024e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024e6:	c9                   	leave  
  8024e7:	c3                   	ret    

008024e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024e8:	55                   	push   %ebp
  8024e9:	89 e5                	mov    %esp,%ebp
  8024eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024f4:	6a 01                	push   $0x1
  8024f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024f9:	50                   	push   %eax
  8024fa:	e8 2e eb ff ff       	call   80102d <sys_cputs>
}
  8024ff:	83 c4 10             	add    $0x10,%esp
  802502:	c9                   	leave  
  802503:	c3                   	ret    

00802504 <getchar>:

int
getchar(void)
{
  802504:	55                   	push   %ebp
  802505:	89 e5                	mov    %esp,%ebp
  802507:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80250a:	6a 01                	push   $0x1
  80250c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80250f:	50                   	push   %eax
  802510:	6a 00                	push   $0x0
  802512:	e8 36 f2 ff ff       	call   80174d <read>
	if (r < 0)
  802517:	83 c4 10             	add    $0x10,%esp
  80251a:	85 c0                	test   %eax,%eax
  80251c:	78 0f                	js     80252d <getchar+0x29>
		return r;
	if (r < 1)
  80251e:	85 c0                	test   %eax,%eax
  802520:	7e 06                	jle    802528 <getchar+0x24>
		return -E_EOF;
	return c;
  802522:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802526:	eb 05                	jmp    80252d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802528:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80252d:	c9                   	leave  
  80252e:	c3                   	ret    

0080252f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80252f:	55                   	push   %ebp
  802530:	89 e5                	mov    %esp,%ebp
  802532:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802538:	50                   	push   %eax
  802539:	ff 75 08             	pushl  0x8(%ebp)
  80253c:	e8 a6 ef ff ff       	call   8014e7 <fd_lookup>
  802541:	83 c4 10             	add    $0x10,%esp
  802544:	85 c0                	test   %eax,%eax
  802546:	78 11                	js     802559 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80254b:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802551:	39 10                	cmp    %edx,(%eax)
  802553:	0f 94 c0             	sete   %al
  802556:	0f b6 c0             	movzbl %al,%eax
}
  802559:	c9                   	leave  
  80255a:	c3                   	ret    

0080255b <opencons>:

int
opencons(void)
{
  80255b:	55                   	push   %ebp
  80255c:	89 e5                	mov    %esp,%ebp
  80255e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802561:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802564:	50                   	push   %eax
  802565:	e8 2e ef ff ff       	call   801498 <fd_alloc>
  80256a:	83 c4 10             	add    $0x10,%esp
		return r;
  80256d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80256f:	85 c0                	test   %eax,%eax
  802571:	78 3e                	js     8025b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802573:	83 ec 04             	sub    $0x4,%esp
  802576:	68 07 04 00 00       	push   $0x407
  80257b:	ff 75 f4             	pushl  -0xc(%ebp)
  80257e:	6a 00                	push   $0x0
  802580:	e8 64 eb ff ff       	call   8010e9 <sys_page_alloc>
  802585:	83 c4 10             	add    $0x10,%esp
		return r;
  802588:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80258a:	85 c0                	test   %eax,%eax
  80258c:	78 23                	js     8025b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80258e:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802597:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80259c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025a3:	83 ec 0c             	sub    $0xc,%esp
  8025a6:	50                   	push   %eax
  8025a7:	e8 c5 ee ff ff       	call   801471 <fd2num>
  8025ac:	89 c2                	mov    %eax,%edx
  8025ae:	83 c4 10             	add    $0x10,%esp
}
  8025b1:	89 d0                	mov    %edx,%eax
  8025b3:	c9                   	leave  
  8025b4:	c3                   	ret    

008025b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025b5:	55                   	push   %ebp
  8025b6:	89 e5                	mov    %esp,%ebp
  8025b8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025bb:	89 d0                	mov    %edx,%eax
  8025bd:	c1 e8 16             	shr    $0x16,%eax
  8025c0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025c7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025cc:	f6 c1 01             	test   $0x1,%cl
  8025cf:	74 1d                	je     8025ee <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025d1:	c1 ea 0c             	shr    $0xc,%edx
  8025d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025db:	f6 c2 01             	test   $0x1,%dl
  8025de:	74 0e                	je     8025ee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025e0:	c1 ea 0c             	shr    $0xc,%edx
  8025e3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025ea:	ef 
  8025eb:	0f b7 c0             	movzwl %ax,%eax
}
  8025ee:	5d                   	pop    %ebp
  8025ef:	c3                   	ret    

008025f0 <__udivdi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	57                   	push   %edi
  8025f2:	56                   	push   %esi
  8025f3:	53                   	push   %ebx
  8025f4:	83 ec 1c             	sub    $0x1c,%esp
  8025f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802603:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802607:	85 f6                	test   %esi,%esi
  802609:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80260d:	89 ca                	mov    %ecx,%edx
  80260f:	89 f8                	mov    %edi,%eax
  802611:	75 3d                	jne    802650 <__udivdi3+0x60>
  802613:	39 cf                	cmp    %ecx,%edi
  802615:	0f 87 c5 00 00 00    	ja     8026e0 <__udivdi3+0xf0>
  80261b:	85 ff                	test   %edi,%edi
  80261d:	89 fd                	mov    %edi,%ebp
  80261f:	75 0b                	jne    80262c <__udivdi3+0x3c>
  802621:	b8 01 00 00 00       	mov    $0x1,%eax
  802626:	31 d2                	xor    %edx,%edx
  802628:	f7 f7                	div    %edi
  80262a:	89 c5                	mov    %eax,%ebp
  80262c:	89 c8                	mov    %ecx,%eax
  80262e:	31 d2                	xor    %edx,%edx
  802630:	f7 f5                	div    %ebp
  802632:	89 c1                	mov    %eax,%ecx
  802634:	89 d8                	mov    %ebx,%eax
  802636:	89 cf                	mov    %ecx,%edi
  802638:	f7 f5                	div    %ebp
  80263a:	89 c3                	mov    %eax,%ebx
  80263c:	89 d8                	mov    %ebx,%eax
  80263e:	89 fa                	mov    %edi,%edx
  802640:	83 c4 1c             	add    $0x1c,%esp
  802643:	5b                   	pop    %ebx
  802644:	5e                   	pop    %esi
  802645:	5f                   	pop    %edi
  802646:	5d                   	pop    %ebp
  802647:	c3                   	ret    
  802648:	90                   	nop
  802649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802650:	39 ce                	cmp    %ecx,%esi
  802652:	77 74                	ja     8026c8 <__udivdi3+0xd8>
  802654:	0f bd fe             	bsr    %esi,%edi
  802657:	83 f7 1f             	xor    $0x1f,%edi
  80265a:	0f 84 98 00 00 00    	je     8026f8 <__udivdi3+0x108>
  802660:	bb 20 00 00 00       	mov    $0x20,%ebx
  802665:	89 f9                	mov    %edi,%ecx
  802667:	89 c5                	mov    %eax,%ebp
  802669:	29 fb                	sub    %edi,%ebx
  80266b:	d3 e6                	shl    %cl,%esi
  80266d:	89 d9                	mov    %ebx,%ecx
  80266f:	d3 ed                	shr    %cl,%ebp
  802671:	89 f9                	mov    %edi,%ecx
  802673:	d3 e0                	shl    %cl,%eax
  802675:	09 ee                	or     %ebp,%esi
  802677:	89 d9                	mov    %ebx,%ecx
  802679:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80267d:	89 d5                	mov    %edx,%ebp
  80267f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802683:	d3 ed                	shr    %cl,%ebp
  802685:	89 f9                	mov    %edi,%ecx
  802687:	d3 e2                	shl    %cl,%edx
  802689:	89 d9                	mov    %ebx,%ecx
  80268b:	d3 e8                	shr    %cl,%eax
  80268d:	09 c2                	or     %eax,%edx
  80268f:	89 d0                	mov    %edx,%eax
  802691:	89 ea                	mov    %ebp,%edx
  802693:	f7 f6                	div    %esi
  802695:	89 d5                	mov    %edx,%ebp
  802697:	89 c3                	mov    %eax,%ebx
  802699:	f7 64 24 0c          	mull   0xc(%esp)
  80269d:	39 d5                	cmp    %edx,%ebp
  80269f:	72 10                	jb     8026b1 <__udivdi3+0xc1>
  8026a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026a5:	89 f9                	mov    %edi,%ecx
  8026a7:	d3 e6                	shl    %cl,%esi
  8026a9:	39 c6                	cmp    %eax,%esi
  8026ab:	73 07                	jae    8026b4 <__udivdi3+0xc4>
  8026ad:	39 d5                	cmp    %edx,%ebp
  8026af:	75 03                	jne    8026b4 <__udivdi3+0xc4>
  8026b1:	83 eb 01             	sub    $0x1,%ebx
  8026b4:	31 ff                	xor    %edi,%edi
  8026b6:	89 d8                	mov    %ebx,%eax
  8026b8:	89 fa                	mov    %edi,%edx
  8026ba:	83 c4 1c             	add    $0x1c,%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5e                   	pop    %esi
  8026bf:	5f                   	pop    %edi
  8026c0:	5d                   	pop    %ebp
  8026c1:	c3                   	ret    
  8026c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026c8:	31 ff                	xor    %edi,%edi
  8026ca:	31 db                	xor    %ebx,%ebx
  8026cc:	89 d8                	mov    %ebx,%eax
  8026ce:	89 fa                	mov    %edi,%edx
  8026d0:	83 c4 1c             	add    $0x1c,%esp
  8026d3:	5b                   	pop    %ebx
  8026d4:	5e                   	pop    %esi
  8026d5:	5f                   	pop    %edi
  8026d6:	5d                   	pop    %ebp
  8026d7:	c3                   	ret    
  8026d8:	90                   	nop
  8026d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	89 d8                	mov    %ebx,%eax
  8026e2:	f7 f7                	div    %edi
  8026e4:	31 ff                	xor    %edi,%edi
  8026e6:	89 c3                	mov    %eax,%ebx
  8026e8:	89 d8                	mov    %ebx,%eax
  8026ea:	89 fa                	mov    %edi,%edx
  8026ec:	83 c4 1c             	add    $0x1c,%esp
  8026ef:	5b                   	pop    %ebx
  8026f0:	5e                   	pop    %esi
  8026f1:	5f                   	pop    %edi
  8026f2:	5d                   	pop    %ebp
  8026f3:	c3                   	ret    
  8026f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f8:	39 ce                	cmp    %ecx,%esi
  8026fa:	72 0c                	jb     802708 <__udivdi3+0x118>
  8026fc:	31 db                	xor    %ebx,%ebx
  8026fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802702:	0f 87 34 ff ff ff    	ja     80263c <__udivdi3+0x4c>
  802708:	bb 01 00 00 00       	mov    $0x1,%ebx
  80270d:	e9 2a ff ff ff       	jmp    80263c <__udivdi3+0x4c>
  802712:	66 90                	xchg   %ax,%ax
  802714:	66 90                	xchg   %ax,%ax
  802716:	66 90                	xchg   %ax,%ax
  802718:	66 90                	xchg   %ax,%ax
  80271a:	66 90                	xchg   %ax,%ax
  80271c:	66 90                	xchg   %ax,%ax
  80271e:	66 90                	xchg   %ax,%ax

00802720 <__umoddi3>:
  802720:	55                   	push   %ebp
  802721:	57                   	push   %edi
  802722:	56                   	push   %esi
  802723:	53                   	push   %ebx
  802724:	83 ec 1c             	sub    $0x1c,%esp
  802727:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80272b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80272f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802733:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802737:	85 d2                	test   %edx,%edx
  802739:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80273d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802741:	89 f3                	mov    %esi,%ebx
  802743:	89 3c 24             	mov    %edi,(%esp)
  802746:	89 74 24 04          	mov    %esi,0x4(%esp)
  80274a:	75 1c                	jne    802768 <__umoddi3+0x48>
  80274c:	39 f7                	cmp    %esi,%edi
  80274e:	76 50                	jbe    8027a0 <__umoddi3+0x80>
  802750:	89 c8                	mov    %ecx,%eax
  802752:	89 f2                	mov    %esi,%edx
  802754:	f7 f7                	div    %edi
  802756:	89 d0                	mov    %edx,%eax
  802758:	31 d2                	xor    %edx,%edx
  80275a:	83 c4 1c             	add    $0x1c,%esp
  80275d:	5b                   	pop    %ebx
  80275e:	5e                   	pop    %esi
  80275f:	5f                   	pop    %edi
  802760:	5d                   	pop    %ebp
  802761:	c3                   	ret    
  802762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802768:	39 f2                	cmp    %esi,%edx
  80276a:	89 d0                	mov    %edx,%eax
  80276c:	77 52                	ja     8027c0 <__umoddi3+0xa0>
  80276e:	0f bd ea             	bsr    %edx,%ebp
  802771:	83 f5 1f             	xor    $0x1f,%ebp
  802774:	75 5a                	jne    8027d0 <__umoddi3+0xb0>
  802776:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80277a:	0f 82 e0 00 00 00    	jb     802860 <__umoddi3+0x140>
  802780:	39 0c 24             	cmp    %ecx,(%esp)
  802783:	0f 86 d7 00 00 00    	jbe    802860 <__umoddi3+0x140>
  802789:	8b 44 24 08          	mov    0x8(%esp),%eax
  80278d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802791:	83 c4 1c             	add    $0x1c,%esp
  802794:	5b                   	pop    %ebx
  802795:	5e                   	pop    %esi
  802796:	5f                   	pop    %edi
  802797:	5d                   	pop    %ebp
  802798:	c3                   	ret    
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	85 ff                	test   %edi,%edi
  8027a2:	89 fd                	mov    %edi,%ebp
  8027a4:	75 0b                	jne    8027b1 <__umoddi3+0x91>
  8027a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027ab:	31 d2                	xor    %edx,%edx
  8027ad:	f7 f7                	div    %edi
  8027af:	89 c5                	mov    %eax,%ebp
  8027b1:	89 f0                	mov    %esi,%eax
  8027b3:	31 d2                	xor    %edx,%edx
  8027b5:	f7 f5                	div    %ebp
  8027b7:	89 c8                	mov    %ecx,%eax
  8027b9:	f7 f5                	div    %ebp
  8027bb:	89 d0                	mov    %edx,%eax
  8027bd:	eb 99                	jmp    802758 <__umoddi3+0x38>
  8027bf:	90                   	nop
  8027c0:	89 c8                	mov    %ecx,%eax
  8027c2:	89 f2                	mov    %esi,%edx
  8027c4:	83 c4 1c             	add    $0x1c,%esp
  8027c7:	5b                   	pop    %ebx
  8027c8:	5e                   	pop    %esi
  8027c9:	5f                   	pop    %edi
  8027ca:	5d                   	pop    %ebp
  8027cb:	c3                   	ret    
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	8b 34 24             	mov    (%esp),%esi
  8027d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027d8:	89 e9                	mov    %ebp,%ecx
  8027da:	29 ef                	sub    %ebp,%edi
  8027dc:	d3 e0                	shl    %cl,%eax
  8027de:	89 f9                	mov    %edi,%ecx
  8027e0:	89 f2                	mov    %esi,%edx
  8027e2:	d3 ea                	shr    %cl,%edx
  8027e4:	89 e9                	mov    %ebp,%ecx
  8027e6:	09 c2                	or     %eax,%edx
  8027e8:	89 d8                	mov    %ebx,%eax
  8027ea:	89 14 24             	mov    %edx,(%esp)
  8027ed:	89 f2                	mov    %esi,%edx
  8027ef:	d3 e2                	shl    %cl,%edx
  8027f1:	89 f9                	mov    %edi,%ecx
  8027f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027fb:	d3 e8                	shr    %cl,%eax
  8027fd:	89 e9                	mov    %ebp,%ecx
  8027ff:	89 c6                	mov    %eax,%esi
  802801:	d3 e3                	shl    %cl,%ebx
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 d0                	mov    %edx,%eax
  802807:	d3 e8                	shr    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	09 d8                	or     %ebx,%eax
  80280d:	89 d3                	mov    %edx,%ebx
  80280f:	89 f2                	mov    %esi,%edx
  802811:	f7 34 24             	divl   (%esp)
  802814:	89 d6                	mov    %edx,%esi
  802816:	d3 e3                	shl    %cl,%ebx
  802818:	f7 64 24 04          	mull   0x4(%esp)
  80281c:	39 d6                	cmp    %edx,%esi
  80281e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802822:	89 d1                	mov    %edx,%ecx
  802824:	89 c3                	mov    %eax,%ebx
  802826:	72 08                	jb     802830 <__umoddi3+0x110>
  802828:	75 11                	jne    80283b <__umoddi3+0x11b>
  80282a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80282e:	73 0b                	jae    80283b <__umoddi3+0x11b>
  802830:	2b 44 24 04          	sub    0x4(%esp),%eax
  802834:	1b 14 24             	sbb    (%esp),%edx
  802837:	89 d1                	mov    %edx,%ecx
  802839:	89 c3                	mov    %eax,%ebx
  80283b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80283f:	29 da                	sub    %ebx,%edx
  802841:	19 ce                	sbb    %ecx,%esi
  802843:	89 f9                	mov    %edi,%ecx
  802845:	89 f0                	mov    %esi,%eax
  802847:	d3 e0                	shl    %cl,%eax
  802849:	89 e9                	mov    %ebp,%ecx
  80284b:	d3 ea                	shr    %cl,%edx
  80284d:	89 e9                	mov    %ebp,%ecx
  80284f:	d3 ee                	shr    %cl,%esi
  802851:	09 d0                	or     %edx,%eax
  802853:	89 f2                	mov    %esi,%edx
  802855:	83 c4 1c             	add    $0x1c,%esp
  802858:	5b                   	pop    %ebx
  802859:	5e                   	pop    %esi
  80285a:	5f                   	pop    %edi
  80285b:	5d                   	pop    %ebp
  80285c:	c3                   	ret    
  80285d:	8d 76 00             	lea    0x0(%esi),%esi
  802860:	29 f9                	sub    %edi,%ecx
  802862:	19 d6                	sbb    %edx,%esi
  802864:	89 74 24 04          	mov    %esi,0x4(%esp)
  802868:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80286c:	e9 18 ff ff ff       	jmp    802789 <__umoddi3+0x69>
