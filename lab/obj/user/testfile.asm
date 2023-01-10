
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
  800054:	e8 9d 13 00 00       	call   8013f6 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 3a 13 00 00       	call   8013a2 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 c2 12 00 00       	call   80133b <ipc_recv>
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
  80008f:	b8 40 28 80 00       	mov    $0x802840,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 4b 28 80 00       	push   $0x80284b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 65 28 80 00       	push   $0x802865
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 00 2a 80 00       	push   $0x802a00
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 65 28 80 00       	push   $0x802865
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 75 28 80 00       	mov    $0x802875,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 7e 28 80 00       	push   $0x80287e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 65 28 80 00       	push   $0x802865
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
  800114:	68 24 2a 80 00       	push   $0x802a24
  800119:	6a 27                	push   $0x27
  80011b:	68 65 28 80 00       	push   $0x802865
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 96 28 80 00       	push   $0x802896
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
  80014f:	68 aa 28 80 00       	push   $0x8028aa
  800154:	6a 2b                	push   $0x2b
  800156:	68 65 28 80 00       	push   $0x802865
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
  80018a:	68 54 2a 80 00       	push   $0x802a54
  80018f:	6a 2d                	push   $0x2d
  800191:	68 65 28 80 00       	push   $0x802865
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 b8 28 80 00       	push   $0x8028b8
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
  8001da:	68 cb 28 80 00       	push   $0x8028cb
  8001df:	6a 32                	push   $0x32
  8001e1:	68 65 28 80 00       	push   $0x802865
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
  80020a:	68 d9 28 80 00       	push   $0x8028d9
  80020f:	6a 34                	push   $0x34
  800211:	68 65 28 80 00       	push   $0x802865
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
		// panic("file_read returned wrong data, buf[%d]: %s\n", strlen(buf), buf);
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 f7 28 80 00       	push   $0x8028f7
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 0a 29 80 00       	push   $0x80290a
  800242:	6a 39                	push   $0x39
  800244:	68 65 28 80 00       	push   $0x802865
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 19 29 80 00       	push   $0x802919
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
  8002ac:	68 7c 2a 80 00       	push   $0x802a7c
  8002b1:	6a 44                	push   $0x44
  8002b3:	68 65 28 80 00       	push   $0x802865
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 2d 29 80 00       	push   $0x80292d
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 43 29 80 00       	mov    $0x802943,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 4d 29 80 00       	push   $0x80294d
  8002e6:	6a 49                	push   $0x49
  8002e8:	68 65 28 80 00       	push   $0x802865
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
  80032f:	68 66 29 80 00       	push   $0x802966
  800334:	6a 4c                	push   $0x4c
  800336:	68 65 28 80 00       	push   $0x802865
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 75 29 80 00       	push   $0x802975
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
  80038b:	68 b4 2a 80 00       	push   $0x802ab4
  800390:	6a 52                	push   $0x52
  800392:	68 65 28 80 00       	push   $0x802865
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
  8003b2:	68 d4 2a 80 00       	push   $0x802ad4
  8003b7:	6a 54                	push   $0x54
  8003b9:	68 65 28 80 00       	push   $0x802865
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
  8003e2:	68 0c 2b 80 00       	push   $0x802b0c
  8003e7:	6a 56                	push   $0x56
  8003e9:	68 65 28 80 00       	push   $0x802865
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 3c 2b 80 00       	push   $0x802b3c
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 40 28 80 00       	push   $0x802840
  80040a:	e8 7a 17 00 00       	call   801b89 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 51 28 80 00       	push   $0x802851
  800426:	6a 5b                	push   $0x5b
  800428:	68 65 28 80 00       	push   $0x802865
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 89 29 80 00       	push   $0x802989
  80043e:	6a 5d                	push   $0x5d
  800440:	68 65 28 80 00       	push   $0x802865
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 75 28 80 00       	push   $0x802875
  800454:	e8 30 17 00 00       	call   801b89 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 84 28 80 00       	push   $0x802884
  800466:	6a 60                	push   $0x60
  800468:	68 65 28 80 00       	push   $0x802865
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
  800493:	68 60 2b 80 00       	push   $0x802b60
  800498:	6a 63                	push   $0x63
  80049a:	68 65 28 80 00       	push   $0x802865
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 9c 28 80 00       	push   $0x80289c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 a4 29 80 00       	push   $0x8029a4
  8004be:	e8 c6 16 00 00       	call   801b89 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 a9 29 80 00       	push   $0x8029a9
  8004d2:	6a 68                	push   $0x68
  8004d4:	68 65 28 80 00       	push   $0x802865
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
  800512:	e8 ce 12 00 00       	call   8017e5 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 b8 29 80 00       	push   $0x8029b8
  800528:	6a 6d                	push   $0x6d
  80052a:	68 65 28 80 00       	push   $0x802865
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
  800547:	e8 83 10 00 00       	call   8015cf <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 a4 29 80 00       	push   $0x8029a4
  800556:	e8 2e 16 00 00       	call   801b89 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 ca 29 80 00       	push   $0x8029ca
  80056a:	6a 72                	push   $0x72
  80056c:	68 65 28 80 00       	push   $0x802865
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
  800591:	e8 06 12 00 00       	call   80179c <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 d8 29 80 00       	push   $0x8029d8
  8005a7:	6a 76                	push   $0x76
  8005a9:	68 65 28 80 00       	push   $0x802865
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 88 2b 80 00       	push   $0x802b88
  8005c9:	6a 79                	push   $0x79
  8005cb:	68 65 28 80 00       	push   $0x802865
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
  8005e4:	68 b4 2b 80 00       	push   $0x802bb4
  8005e9:	6a 7c                	push   $0x7c
  8005eb:	68 65 28 80 00       	push   $0x802865
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
  80060c:	e8 be 0f 00 00       	call   8015cf <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 e9 29 80 00 	movl   $0x8029e9,(%esp)
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
  800674:	e8 81 0f 00 00       	call   8015fa <close_all>
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
  8006a6:	68 0c 2c 80 00       	push   $0x802c0c
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 9c 30 80 00 	movl   $0x80309c,(%esp)
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
  8007c4:	e8 e7 1d 00 00       	call   8025b0 <__udivdi3>
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
  800807:	e8 d4 1e 00 00       	call   8026e0 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 2f 2c 80 00 	movsbl 0x802c2f(%eax),%eax
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
  80090b:	ff 24 85 80 2d 80 00 	jmp    *0x802d80(,%eax,4)
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
  8009cf:	8b 14 85 e0 2e 80 00 	mov    0x802ee0(,%eax,4),%edx
  8009d6:	85 d2                	test   %edx,%edx
  8009d8:	75 18                	jne    8009f2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009da:	50                   	push   %eax
  8009db:	68 47 2c 80 00       	push   $0x802c47
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
  8009f3:	68 31 30 80 00       	push   $0x803031
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
  800a17:	b8 40 2c 80 00       	mov    $0x802c40,%eax
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
  801092:	68 3f 2f 80 00       	push   $0x802f3f
  801097:	6a 23                	push   $0x23
  801099:	68 5c 2f 80 00       	push   $0x802f5c
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
  801113:	68 3f 2f 80 00       	push   $0x802f3f
  801118:	6a 23                	push   $0x23
  80111a:	68 5c 2f 80 00       	push   $0x802f5c
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
  801155:	68 3f 2f 80 00       	push   $0x802f3f
  80115a:	6a 23                	push   $0x23
  80115c:	68 5c 2f 80 00       	push   $0x802f5c
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
  801197:	68 3f 2f 80 00       	push   $0x802f3f
  80119c:	6a 23                	push   $0x23
  80119e:	68 5c 2f 80 00       	push   $0x802f5c
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
  8011d9:	68 3f 2f 80 00       	push   $0x802f3f
  8011de:	6a 23                	push   $0x23
  8011e0:	68 5c 2f 80 00       	push   $0x802f5c
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
  80121b:	68 3f 2f 80 00       	push   $0x802f3f
  801220:	6a 23                	push   $0x23
  801222:	68 5c 2f 80 00       	push   $0x802f5c
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
  80125d:	68 3f 2f 80 00       	push   $0x802f3f
  801262:	6a 23                	push   $0x23
  801264:	68 5c 2f 80 00       	push   $0x802f5c
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
  8012c1:	68 3f 2f 80 00       	push   $0x802f3f
  8012c6:	6a 23                	push   $0x23
  8012c8:	68 5c 2f 80 00       	push   $0x802f5c
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
  801322:	68 3f 2f 80 00       	push   $0x802f3f
  801327:	6a 23                	push   $0x23
  801329:	68 5c 2f 80 00       	push   $0x802f5c
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

0080133b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
  801340:	8b 75 08             	mov    0x8(%ebp),%esi
  801343:	8b 45 0c             	mov    0xc(%ebp),%eax
  801346:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801349:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80134b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801350:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	50                   	push   %eax
  801357:	e8 3d ff ff ff       	call   801299 <sys_ipc_recv>

	if (from_env_store != NULL)
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	85 f6                	test   %esi,%esi
  801361:	74 14                	je     801377 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801363:	ba 00 00 00 00       	mov    $0x0,%edx
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 09                	js     801375 <ipc_recv+0x3a>
  80136c:	8b 15 08 50 80 00    	mov    0x805008,%edx
  801372:	8b 52 74             	mov    0x74(%edx),%edx
  801375:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801377:	85 db                	test   %ebx,%ebx
  801379:	74 14                	je     80138f <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80137b:	ba 00 00 00 00       	mov    $0x0,%edx
  801380:	85 c0                	test   %eax,%eax
  801382:	78 09                	js     80138d <ipc_recv+0x52>
  801384:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80138a:	8b 52 78             	mov    0x78(%edx),%edx
  80138d:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 08                	js     80139b <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801393:	a1 08 50 80 00       	mov    0x805008,%eax
  801398:	8b 40 70             	mov    0x70(%eax),%eax
}
  80139b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139e:	5b                   	pop    %ebx
  80139f:	5e                   	pop    %esi
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    

008013a2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	57                   	push   %edi
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8013b4:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8013b6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013bb:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8013be:	ff 75 14             	pushl  0x14(%ebp)
  8013c1:	53                   	push   %ebx
  8013c2:	56                   	push   %esi
  8013c3:	57                   	push   %edi
  8013c4:	e8 ad fe ff ff       	call   801276 <sys_ipc_try_send>

		if (err < 0) {
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	79 1e                	jns    8013ee <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8013d0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013d3:	75 07                	jne    8013dc <ipc_send+0x3a>
				sys_yield();
  8013d5:	e8 f0 fc ff ff       	call   8010ca <sys_yield>
  8013da:	eb e2                	jmp    8013be <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8013dc:	50                   	push   %eax
  8013dd:	68 6a 2f 80 00       	push   $0x802f6a
  8013e2:	6a 49                	push   $0x49
  8013e4:	68 77 2f 80 00       	push   $0x802f77
  8013e9:	e8 9a f2 ff ff       	call   800688 <_panic>
		}

	} while (err < 0);

}
  8013ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5e                   	pop    %esi
  8013f3:	5f                   	pop    %edi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801401:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801404:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80140a:	8b 52 50             	mov    0x50(%edx),%edx
  80140d:	39 ca                	cmp    %ecx,%edx
  80140f:	75 0d                	jne    80141e <ipc_find_env+0x28>
			return envs[i].env_id;
  801411:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801414:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801419:	8b 40 48             	mov    0x48(%eax),%eax
  80141c:	eb 0f                	jmp    80142d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80141e:	83 c0 01             	add    $0x1,%eax
  801421:	3d 00 04 00 00       	cmp    $0x400,%eax
  801426:	75 d9                	jne    801401 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801428:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	05 00 00 00 30       	add    $0x30000000,%eax
  80143a:	c1 e8 0c             	shr    $0xc,%eax
}
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	05 00 00 00 30       	add    $0x30000000,%eax
  80144a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80144f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80145c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801461:	89 c2                	mov    %eax,%edx
  801463:	c1 ea 16             	shr    $0x16,%edx
  801466:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80146d:	f6 c2 01             	test   $0x1,%dl
  801470:	74 11                	je     801483 <fd_alloc+0x2d>
  801472:	89 c2                	mov    %eax,%edx
  801474:	c1 ea 0c             	shr    $0xc,%edx
  801477:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80147e:	f6 c2 01             	test   $0x1,%dl
  801481:	75 09                	jne    80148c <fd_alloc+0x36>
			*fd_store = fd;
  801483:	89 01                	mov    %eax,(%ecx)
			return 0;
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
  80148a:	eb 17                	jmp    8014a3 <fd_alloc+0x4d>
  80148c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801491:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801496:	75 c9                	jne    801461 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801498:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80149e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    

008014a5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014ab:	83 f8 1f             	cmp    $0x1f,%eax
  8014ae:	77 36                	ja     8014e6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014b0:	c1 e0 0c             	shl    $0xc,%eax
  8014b3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014b8:	89 c2                	mov    %eax,%edx
  8014ba:	c1 ea 16             	shr    $0x16,%edx
  8014bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014c4:	f6 c2 01             	test   $0x1,%dl
  8014c7:	74 24                	je     8014ed <fd_lookup+0x48>
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	c1 ea 0c             	shr    $0xc,%edx
  8014ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014d5:	f6 c2 01             	test   $0x1,%dl
  8014d8:	74 1a                	je     8014f4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014dd:	89 02                	mov    %eax,(%edx)
	return 0;
  8014df:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e4:	eb 13                	jmp    8014f9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014eb:	eb 0c                	jmp    8014f9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f2:	eb 05                	jmp    8014f9 <fd_lookup+0x54>
  8014f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801504:	ba 04 30 80 00       	mov    $0x803004,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801509:	eb 13                	jmp    80151e <dev_lookup+0x23>
  80150b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80150e:	39 08                	cmp    %ecx,(%eax)
  801510:	75 0c                	jne    80151e <dev_lookup+0x23>
			*dev = devtab[i];
  801512:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801515:	89 01                	mov    %eax,(%ecx)
			return 0;
  801517:	b8 00 00 00 00       	mov    $0x0,%eax
  80151c:	eb 2e                	jmp    80154c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80151e:	8b 02                	mov    (%edx),%eax
  801520:	85 c0                	test   %eax,%eax
  801522:	75 e7                	jne    80150b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801524:	a1 08 50 80 00       	mov    0x805008,%eax
  801529:	8b 40 48             	mov    0x48(%eax),%eax
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	51                   	push   %ecx
  801530:	50                   	push   %eax
  801531:	68 84 2f 80 00       	push   $0x802f84
  801536:	e8 26 f2 ff ff       	call   800761 <cprintf>
	*dev = 0;
  80153b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80154c:	c9                   	leave  
  80154d:	c3                   	ret    

0080154e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 10             	sub    $0x10,%esp
  801556:	8b 75 08             	mov    0x8(%ebp),%esi
  801559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80155c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801566:	c1 e8 0c             	shr    $0xc,%eax
  801569:	50                   	push   %eax
  80156a:	e8 36 ff ff ff       	call   8014a5 <fd_lookup>
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	78 05                	js     80157b <fd_close+0x2d>
	    || fd != fd2)
  801576:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801579:	74 0c                	je     801587 <fd_close+0x39>
		return (must_exist ? r : 0);
  80157b:	84 db                	test   %bl,%bl
  80157d:	ba 00 00 00 00       	mov    $0x0,%edx
  801582:	0f 44 c2             	cmove  %edx,%eax
  801585:	eb 41                	jmp    8015c8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	ff 36                	pushl  (%esi)
  801590:	e8 66 ff ff ff       	call   8014fb <dev_lookup>
  801595:	89 c3                	mov    %eax,%ebx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 1a                	js     8015b8 <fd_close+0x6a>
		if (dev->dev_close)
  80159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	74 0b                	je     8015b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015ad:	83 ec 0c             	sub    $0xc,%esp
  8015b0:	56                   	push   %esi
  8015b1:	ff d0                	call   *%eax
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	56                   	push   %esi
  8015bc:	6a 00                	push   $0x0
  8015be:	e8 ab fb ff ff       	call   80116e <sys_page_unmap>
	return r;
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	89 d8                	mov    %ebx,%eax
}
  8015c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	ff 75 08             	pushl  0x8(%ebp)
  8015dc:	e8 c4 fe ff ff       	call   8014a5 <fd_lookup>
  8015e1:	83 c4 08             	add    $0x8,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 10                	js     8015f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	6a 01                	push   $0x1
  8015ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f0:	e8 59 ff ff ff       	call   80154e <fd_close>
  8015f5:	83 c4 10             	add    $0x10,%esp
}
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <close_all>:

void
close_all(void)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801601:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801606:	83 ec 0c             	sub    $0xc,%esp
  801609:	53                   	push   %ebx
  80160a:	e8 c0 ff ff ff       	call   8015cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80160f:	83 c3 01             	add    $0x1,%ebx
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	83 fb 20             	cmp    $0x20,%ebx
  801618:	75 ec                	jne    801606 <close_all+0xc>
		close(i);
}
  80161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	57                   	push   %edi
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
  801625:	83 ec 2c             	sub    $0x2c,%esp
  801628:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80162b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	ff 75 08             	pushl  0x8(%ebp)
  801632:	e8 6e fe ff ff       	call   8014a5 <fd_lookup>
  801637:	83 c4 08             	add    $0x8,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	0f 88 c1 00 00 00    	js     801703 <dup+0xe4>
		return r;
	close(newfdnum);
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	56                   	push   %esi
  801646:	e8 84 ff ff ff       	call   8015cf <close>

	newfd = INDEX2FD(newfdnum);
  80164b:	89 f3                	mov    %esi,%ebx
  80164d:	c1 e3 0c             	shl    $0xc,%ebx
  801650:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801656:	83 c4 04             	add    $0x4,%esp
  801659:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165c:	e8 de fd ff ff       	call   80143f <fd2data>
  801661:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801663:	89 1c 24             	mov    %ebx,(%esp)
  801666:	e8 d4 fd ff ff       	call   80143f <fd2data>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801671:	89 f8                	mov    %edi,%eax
  801673:	c1 e8 16             	shr    $0x16,%eax
  801676:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80167d:	a8 01                	test   $0x1,%al
  80167f:	74 37                	je     8016b8 <dup+0x99>
  801681:	89 f8                	mov    %edi,%eax
  801683:	c1 e8 0c             	shr    $0xc,%eax
  801686:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80168d:	f6 c2 01             	test   $0x1,%dl
  801690:	74 26                	je     8016b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801692:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801699:	83 ec 0c             	sub    $0xc,%esp
  80169c:	25 07 0e 00 00       	and    $0xe07,%eax
  8016a1:	50                   	push   %eax
  8016a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016a5:	6a 00                	push   $0x0
  8016a7:	57                   	push   %edi
  8016a8:	6a 00                	push   $0x0
  8016aa:	e8 7d fa ff ff       	call   80112c <sys_page_map>
  8016af:	89 c7                	mov    %eax,%edi
  8016b1:	83 c4 20             	add    $0x20,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 2e                	js     8016e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016bb:	89 d0                	mov    %edx,%eax
  8016bd:	c1 e8 0c             	shr    $0xc,%eax
  8016c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016c7:	83 ec 0c             	sub    $0xc,%esp
  8016ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8016cf:	50                   	push   %eax
  8016d0:	53                   	push   %ebx
  8016d1:	6a 00                	push   $0x0
  8016d3:	52                   	push   %edx
  8016d4:	6a 00                	push   $0x0
  8016d6:	e8 51 fa ff ff       	call   80112c <sys_page_map>
  8016db:	89 c7                	mov    %eax,%edi
  8016dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e2:	85 ff                	test   %edi,%edi
  8016e4:	79 1d                	jns    801703 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	53                   	push   %ebx
  8016ea:	6a 00                	push   $0x0
  8016ec:	e8 7d fa ff ff       	call   80116e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016f1:	83 c4 08             	add    $0x8,%esp
  8016f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016f7:	6a 00                	push   $0x0
  8016f9:	e8 70 fa ff ff       	call   80116e <sys_page_unmap>
	return r;
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	89 f8                	mov    %edi,%eax
}
  801703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801706:	5b                   	pop    %ebx
  801707:	5e                   	pop    %esi
  801708:	5f                   	pop    %edi
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	53                   	push   %ebx
  80170f:	83 ec 14             	sub    $0x14,%esp
  801712:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801715:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801718:	50                   	push   %eax
  801719:	53                   	push   %ebx
  80171a:	e8 86 fd ff ff       	call   8014a5 <fd_lookup>
  80171f:	83 c4 08             	add    $0x8,%esp
  801722:	89 c2                	mov    %eax,%edx
  801724:	85 c0                	test   %eax,%eax
  801726:	78 6d                	js     801795 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801732:	ff 30                	pushl  (%eax)
  801734:	e8 c2 fd ff ff       	call   8014fb <dev_lookup>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 4c                	js     80178c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801740:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801743:	8b 42 08             	mov    0x8(%edx),%eax
  801746:	83 e0 03             	and    $0x3,%eax
  801749:	83 f8 01             	cmp    $0x1,%eax
  80174c:	75 21                	jne    80176f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80174e:	a1 08 50 80 00       	mov    0x805008,%eax
  801753:	8b 40 48             	mov    0x48(%eax),%eax
  801756:	83 ec 04             	sub    $0x4,%esp
  801759:	53                   	push   %ebx
  80175a:	50                   	push   %eax
  80175b:	68 c8 2f 80 00       	push   $0x802fc8
  801760:	e8 fc ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80176d:	eb 26                	jmp    801795 <read+0x8a>
	}
	if (!dev->dev_read)
  80176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801772:	8b 40 08             	mov    0x8(%eax),%eax
  801775:	85 c0                	test   %eax,%eax
  801777:	74 17                	je     801790 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	ff 75 10             	pushl  0x10(%ebp)
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	52                   	push   %edx
  801783:	ff d0                	call   *%eax
  801785:	89 c2                	mov    %eax,%edx
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	eb 09                	jmp    801795 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	eb 05                	jmp    801795 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801790:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801795:	89 d0                	mov    %edx,%eax
  801797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	57                   	push   %edi
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b0:	eb 21                	jmp    8017d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017b2:	83 ec 04             	sub    $0x4,%esp
  8017b5:	89 f0                	mov    %esi,%eax
  8017b7:	29 d8                	sub    %ebx,%eax
  8017b9:	50                   	push   %eax
  8017ba:	89 d8                	mov    %ebx,%eax
  8017bc:	03 45 0c             	add    0xc(%ebp),%eax
  8017bf:	50                   	push   %eax
  8017c0:	57                   	push   %edi
  8017c1:	e8 45 ff ff ff       	call   80170b <read>
		if (m < 0)
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	78 10                	js     8017dd <readn+0x41>
			return m;
		if (m == 0)
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	74 0a                	je     8017db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017d1:	01 c3                	add    %eax,%ebx
  8017d3:	39 f3                	cmp    %esi,%ebx
  8017d5:	72 db                	jb     8017b2 <readn+0x16>
  8017d7:	89 d8                	mov    %ebx,%eax
  8017d9:	eb 02                	jmp    8017dd <readn+0x41>
  8017db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5f                   	pop    %edi
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 14             	sub    $0x14,%esp
  8017ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f2:	50                   	push   %eax
  8017f3:	53                   	push   %ebx
  8017f4:	e8 ac fc ff ff       	call   8014a5 <fd_lookup>
  8017f9:	83 c4 08             	add    $0x8,%esp
  8017fc:	89 c2                	mov    %eax,%edx
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 68                	js     80186a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801808:	50                   	push   %eax
  801809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180c:	ff 30                	pushl  (%eax)
  80180e:	e8 e8 fc ff ff       	call   8014fb <dev_lookup>
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	85 c0                	test   %eax,%eax
  801818:	78 47                	js     801861 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801821:	75 21                	jne    801844 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801823:	a1 08 50 80 00       	mov    0x805008,%eax
  801828:	8b 40 48             	mov    0x48(%eax),%eax
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	53                   	push   %ebx
  80182f:	50                   	push   %eax
  801830:	68 e4 2f 80 00       	push   $0x802fe4
  801835:	e8 27 ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801842:	eb 26                	jmp    80186a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801847:	8b 52 0c             	mov    0xc(%edx),%edx
  80184a:	85 d2                	test   %edx,%edx
  80184c:	74 17                	je     801865 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80184e:	83 ec 04             	sub    $0x4,%esp
  801851:	ff 75 10             	pushl  0x10(%ebp)
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	50                   	push   %eax
  801858:	ff d2                	call   *%edx
  80185a:	89 c2                	mov    %eax,%edx
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	eb 09                	jmp    80186a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801861:	89 c2                	mov    %eax,%edx
  801863:	eb 05                	jmp    80186a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801865:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80186a:	89 d0                	mov    %edx,%eax
  80186c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <seek>:

int
seek(int fdnum, off_t offset)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801877:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80187a:	50                   	push   %eax
  80187b:	ff 75 08             	pushl  0x8(%ebp)
  80187e:	e8 22 fc ff ff       	call   8014a5 <fd_lookup>
  801883:	83 c4 08             	add    $0x8,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	78 0e                	js     801898 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80188a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80188d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801890:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801893:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	53                   	push   %ebx
  80189e:	83 ec 14             	sub    $0x14,%esp
  8018a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a7:	50                   	push   %eax
  8018a8:	53                   	push   %ebx
  8018a9:	e8 f7 fb ff ff       	call   8014a5 <fd_lookup>
  8018ae:	83 c4 08             	add    $0x8,%esp
  8018b1:	89 c2                	mov    %eax,%edx
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 65                	js     80191c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018bd:	50                   	push   %eax
  8018be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c1:	ff 30                	pushl  (%eax)
  8018c3:	e8 33 fc ff ff       	call   8014fb <dev_lookup>
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 44                	js     801913 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018d6:	75 21                	jne    8018f9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018d8:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018dd:	8b 40 48             	mov    0x48(%eax),%eax
  8018e0:	83 ec 04             	sub    $0x4,%esp
  8018e3:	53                   	push   %ebx
  8018e4:	50                   	push   %eax
  8018e5:	68 a4 2f 80 00       	push   $0x802fa4
  8018ea:	e8 72 ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018f7:	eb 23                	jmp    80191c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018fc:	8b 52 18             	mov    0x18(%edx),%edx
  8018ff:	85 d2                	test   %edx,%edx
  801901:	74 14                	je     801917 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	ff 75 0c             	pushl  0xc(%ebp)
  801909:	50                   	push   %eax
  80190a:	ff d2                	call   *%edx
  80190c:	89 c2                	mov    %eax,%edx
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	eb 09                	jmp    80191c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801913:	89 c2                	mov    %eax,%edx
  801915:	eb 05                	jmp    80191c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801917:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80191c:	89 d0                	mov    %edx,%eax
  80191e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 14             	sub    $0x14,%esp
  80192a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80192d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	ff 75 08             	pushl  0x8(%ebp)
  801934:	e8 6c fb ff ff       	call   8014a5 <fd_lookup>
  801939:	83 c4 08             	add    $0x8,%esp
  80193c:	89 c2                	mov    %eax,%edx
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 58                	js     80199a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801942:	83 ec 08             	sub    $0x8,%esp
  801945:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801948:	50                   	push   %eax
  801949:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194c:	ff 30                	pushl  (%eax)
  80194e:	e8 a8 fb ff ff       	call   8014fb <dev_lookup>
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	85 c0                	test   %eax,%eax
  801958:	78 37                	js     801991 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80195a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801961:	74 32                	je     801995 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801963:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801966:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80196d:	00 00 00 
	stat->st_isdir = 0;
  801970:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801977:	00 00 00 
	stat->st_dev = dev;
  80197a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	53                   	push   %ebx
  801984:	ff 75 f0             	pushl  -0x10(%ebp)
  801987:	ff 50 14             	call   *0x14(%eax)
  80198a:	89 c2                	mov    %eax,%edx
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	eb 09                	jmp    80199a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801991:	89 c2                	mov    %eax,%edx
  801993:	eb 05                	jmp    80199a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801995:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80199a:	89 d0                	mov    %edx,%eax
  80199c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	6a 00                	push   $0x0
  8019ab:	ff 75 08             	pushl  0x8(%ebp)
  8019ae:	e8 d6 01 00 00       	call   801b89 <open>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	78 1b                	js     8019d7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019bc:	83 ec 08             	sub    $0x8,%esp
  8019bf:	ff 75 0c             	pushl  0xc(%ebp)
  8019c2:	50                   	push   %eax
  8019c3:	e8 5b ff ff ff       	call   801923 <fstat>
  8019c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8019ca:	89 1c 24             	mov    %ebx,(%esp)
  8019cd:	e8 fd fb ff ff       	call   8015cf <close>
	return r;
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	89 f0                	mov    %esi,%eax
}
  8019d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	56                   	push   %esi
  8019e2:	53                   	push   %ebx
  8019e3:	89 c6                	mov    %eax,%esi
  8019e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019ee:	75 12                	jne    801a02 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	6a 01                	push   $0x1
  8019f5:	e8 fc f9 ff ff       	call   8013f6 <ipc_find_env>
  8019fa:	a3 00 50 80 00       	mov    %eax,0x805000
  8019ff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a02:	6a 07                	push   $0x7
  801a04:	68 00 60 80 00       	push   $0x806000
  801a09:	56                   	push   %esi
  801a0a:	ff 35 00 50 80 00    	pushl  0x805000
  801a10:	e8 8d f9 ff ff       	call   8013a2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a15:	83 c4 0c             	add    $0xc,%esp
  801a18:	6a 00                	push   $0x0
  801a1a:	53                   	push   %ebx
  801a1b:	6a 00                	push   $0x0
  801a1d:	e8 19 f9 ff ff       	call   80133b <ipc_recv>
}
  801a22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	8b 40 0c             	mov    0xc(%eax),%eax
  801a35:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a42:	ba 00 00 00 00       	mov    $0x0,%edx
  801a47:	b8 02 00 00 00       	mov    $0x2,%eax
  801a4c:	e8 8d ff ff ff       	call   8019de <fsipc>
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a64:	ba 00 00 00 00       	mov    $0x0,%edx
  801a69:	b8 06 00 00 00       	mov    $0x6,%eax
  801a6e:	e8 6b ff ff ff       	call   8019de <fsipc>
}
  801a73:	c9                   	leave  
  801a74:	c3                   	ret    

00801a75 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	53                   	push   %ebx
  801a79:	83 ec 04             	sub    $0x4,%esp
  801a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a82:	8b 40 0c             	mov    0xc(%eax),%eax
  801a85:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a94:	e8 45 ff ff ff       	call   8019de <fsipc>
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	78 2c                	js     801ac9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	68 00 60 80 00       	push   $0x806000
  801aa5:	53                   	push   %ebx
  801aa6:	e8 3b f2 ff ff       	call   800ce6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aab:	a1 80 60 80 00       	mov    0x806080,%eax
  801ab0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ab6:	a1 84 60 80 00       	mov    0x806084,%eax
  801abb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 0c             	sub    $0xc,%esp
  801ad4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ad7:	8b 55 08             	mov    0x8(%ebp),%edx
  801ada:	8b 52 0c             	mov    0xc(%edx),%edx
  801add:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801ae3:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ae8:	50                   	push   %eax
  801ae9:	ff 75 0c             	pushl  0xc(%ebp)
  801aec:	68 08 60 80 00       	push   $0x806008
  801af1:	e8 82 f3 ff ff       	call   800e78 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801af6:	ba 00 00 00 00       	mov    $0x0,%edx
  801afb:	b8 04 00 00 00       	mov    $0x4,%eax
  801b00:	e8 d9 fe ff ff       	call   8019de <fsipc>

}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b12:	8b 40 0c             	mov    0xc(%eax),%eax
  801b15:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b1a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b20:	ba 00 00 00 00       	mov    $0x0,%edx
  801b25:	b8 03 00 00 00       	mov    $0x3,%eax
  801b2a:	e8 af fe ff ff       	call   8019de <fsipc>
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	85 c0                	test   %eax,%eax
  801b33:	78 4b                	js     801b80 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b35:	39 c6                	cmp    %eax,%esi
  801b37:	73 16                	jae    801b4f <devfile_read+0x48>
  801b39:	68 18 30 80 00       	push   $0x803018
  801b3e:	68 1f 30 80 00       	push   $0x80301f
  801b43:	6a 7c                	push   $0x7c
  801b45:	68 34 30 80 00       	push   $0x803034
  801b4a:	e8 39 eb ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801b4f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b54:	7e 16                	jle    801b6c <devfile_read+0x65>
  801b56:	68 3f 30 80 00       	push   $0x80303f
  801b5b:	68 1f 30 80 00       	push   $0x80301f
  801b60:	6a 7d                	push   $0x7d
  801b62:	68 34 30 80 00       	push   $0x803034
  801b67:	e8 1c eb ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b6c:	83 ec 04             	sub    $0x4,%esp
  801b6f:	50                   	push   %eax
  801b70:	68 00 60 80 00       	push   $0x806000
  801b75:	ff 75 0c             	pushl  0xc(%ebp)
  801b78:	e8 fb f2 ff ff       	call   800e78 <memmove>
	return r;
  801b7d:	83 c4 10             	add    $0x10,%esp
}
  801b80:	89 d8                	mov    %ebx,%eax
  801b82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 20             	sub    $0x20,%esp
  801b90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b93:	53                   	push   %ebx
  801b94:	e8 14 f1 ff ff       	call   800cad <strlen>
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ba1:	7f 67                	jg     801c0a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba9:	50                   	push   %eax
  801baa:	e8 a7 f8 ff ff       	call   801456 <fd_alloc>
  801baf:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	78 57                	js     801c0f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bb8:	83 ec 08             	sub    $0x8,%esp
  801bbb:	53                   	push   %ebx
  801bbc:	68 00 60 80 00       	push   $0x806000
  801bc1:	e8 20 f1 ff ff       	call   800ce6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc9:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	e8 03 fe ff ff       	call   8019de <fsipc>
  801bdb:	89 c3                	mov    %eax,%ebx
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	85 c0                	test   %eax,%eax
  801be2:	79 14                	jns    801bf8 <open+0x6f>
		fd_close(fd, 0);
  801be4:	83 ec 08             	sub    $0x8,%esp
  801be7:	6a 00                	push   $0x0
  801be9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bec:	e8 5d f9 ff ff       	call   80154e <fd_close>
		return r;
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	89 da                	mov    %ebx,%edx
  801bf6:	eb 17                	jmp    801c0f <open+0x86>
	}

	return fd2num(fd);
  801bf8:	83 ec 0c             	sub    $0xc,%esp
  801bfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfe:	e8 2c f8 ff ff       	call   80142f <fd2num>
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	eb 05                	jmp    801c0f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c0a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c0f:	89 d0                	mov    %edx,%eax
  801c11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c21:	b8 08 00 00 00       	mov    $0x8,%eax
  801c26:	e8 b3 fd ff ff       	call   8019de <fsipc>
}
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c33:	68 4b 30 80 00       	push   $0x80304b
  801c38:	ff 75 0c             	pushl  0xc(%ebp)
  801c3b:	e8 a6 f0 ff ff       	call   800ce6 <strcpy>
	return 0;
}
  801c40:	b8 00 00 00 00       	mov    $0x0,%eax
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	53                   	push   %ebx
  801c4b:	83 ec 10             	sub    $0x10,%esp
  801c4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c51:	53                   	push   %ebx
  801c52:	e8 1c 09 00 00       	call   802573 <pageref>
  801c57:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c5a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c5f:	83 f8 01             	cmp    $0x1,%eax
  801c62:	75 10                	jne    801c74 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c64:	83 ec 0c             	sub    $0xc,%esp
  801c67:	ff 73 0c             	pushl  0xc(%ebx)
  801c6a:	e8 c0 02 00 00       	call   801f2f <nsipc_close>
  801c6f:	89 c2                	mov    %eax,%edx
  801c71:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c74:	89 d0                	mov    %edx,%eax
  801c76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c81:	6a 00                	push   $0x0
  801c83:	ff 75 10             	pushl  0x10(%ebp)
  801c86:	ff 75 0c             	pushl  0xc(%ebp)
  801c89:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8c:	ff 70 0c             	pushl  0xc(%eax)
  801c8f:	e8 78 03 00 00       	call   80200c <nsipc_send>
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c9c:	6a 00                	push   $0x0
  801c9e:	ff 75 10             	pushl  0x10(%ebp)
  801ca1:	ff 75 0c             	pushl  0xc(%ebp)
  801ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca7:	ff 70 0c             	pushl  0xc(%eax)
  801caa:	e8 f1 02 00 00       	call   801fa0 <nsipc_recv>
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cb7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cba:	52                   	push   %edx
  801cbb:	50                   	push   %eax
  801cbc:	e8 e4 f7 ff ff       	call   8014a5 <fd_lookup>
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 17                	js     801cdf <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccb:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801cd1:	39 08                	cmp    %ecx,(%eax)
  801cd3:	75 05                	jne    801cda <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801cd5:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd8:	eb 05                	jmp    801cdf <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801cda:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    

00801ce1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	56                   	push   %esi
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 1c             	sub    $0x1c,%esp
  801ce9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ceb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cee:	50                   	push   %eax
  801cef:	e8 62 f7 ff ff       	call   801456 <fd_alloc>
  801cf4:	89 c3                	mov    %eax,%ebx
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 1b                	js     801d18 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	68 07 04 00 00       	push   $0x407
  801d05:	ff 75 f4             	pushl  -0xc(%ebp)
  801d08:	6a 00                	push   $0x0
  801d0a:	e8 da f3 ff ff       	call   8010e9 <sys_page_alloc>
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	85 c0                	test   %eax,%eax
  801d16:	79 10                	jns    801d28 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	56                   	push   %esi
  801d1c:	e8 0e 02 00 00       	call   801f2f <nsipc_close>
		return r;
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	89 d8                	mov    %ebx,%eax
  801d26:	eb 24                	jmp    801d4c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d28:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d31:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d36:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d3d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d40:	83 ec 0c             	sub    $0xc,%esp
  801d43:	50                   	push   %eax
  801d44:	e8 e6 f6 ff ff       	call   80142f <fd2num>
  801d49:	83 c4 10             	add    $0x10,%esp
}
  801d4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	e8 50 ff ff ff       	call   801cb1 <fd2sockid>
		return r;
  801d61:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 1f                	js     801d86 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d67:	83 ec 04             	sub    $0x4,%esp
  801d6a:	ff 75 10             	pushl  0x10(%ebp)
  801d6d:	ff 75 0c             	pushl  0xc(%ebp)
  801d70:	50                   	push   %eax
  801d71:	e8 12 01 00 00       	call   801e88 <nsipc_accept>
  801d76:	83 c4 10             	add    $0x10,%esp
		return r;
  801d79:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	78 07                	js     801d86 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d7f:	e8 5d ff ff ff       	call   801ce1 <alloc_sockfd>
  801d84:	89 c1                	mov    %eax,%ecx
}
  801d86:	89 c8                	mov    %ecx,%eax
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    

00801d8a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	e8 19 ff ff ff       	call   801cb1 <fd2sockid>
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	78 12                	js     801dae <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	ff 75 10             	pushl  0x10(%ebp)
  801da2:	ff 75 0c             	pushl  0xc(%ebp)
  801da5:	50                   	push   %eax
  801da6:	e8 2d 01 00 00       	call   801ed8 <nsipc_bind>
  801dab:	83 c4 10             	add    $0x10,%esp
}
  801dae:	c9                   	leave  
  801daf:	c3                   	ret    

00801db0 <shutdown>:

int
shutdown(int s, int how)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
  801db9:	e8 f3 fe ff ff       	call   801cb1 <fd2sockid>
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	78 0f                	js     801dd1 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801dc2:	83 ec 08             	sub    $0x8,%esp
  801dc5:	ff 75 0c             	pushl  0xc(%ebp)
  801dc8:	50                   	push   %eax
  801dc9:	e8 3f 01 00 00       	call   801f0d <nsipc_shutdown>
  801dce:	83 c4 10             	add    $0x10,%esp
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	e8 d0 fe ff ff       	call   801cb1 <fd2sockid>
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 12                	js     801df7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	ff 75 10             	pushl  0x10(%ebp)
  801deb:	ff 75 0c             	pushl  0xc(%ebp)
  801dee:	50                   	push   %eax
  801def:	e8 55 01 00 00       	call   801f49 <nsipc_connect>
  801df4:	83 c4 10             	add    $0x10,%esp
}
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    

00801df9 <listen>:

int
listen(int s, int backlog)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dff:	8b 45 08             	mov    0x8(%ebp),%eax
  801e02:	e8 aa fe ff ff       	call   801cb1 <fd2sockid>
  801e07:	85 c0                	test   %eax,%eax
  801e09:	78 0f                	js     801e1a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e0b:	83 ec 08             	sub    $0x8,%esp
  801e0e:	ff 75 0c             	pushl  0xc(%ebp)
  801e11:	50                   	push   %eax
  801e12:	e8 67 01 00 00       	call   801f7e <nsipc_listen>
  801e17:	83 c4 10             	add    $0x10,%esp
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e22:	ff 75 10             	pushl  0x10(%ebp)
  801e25:	ff 75 0c             	pushl  0xc(%ebp)
  801e28:	ff 75 08             	pushl  0x8(%ebp)
  801e2b:	e8 3a 02 00 00       	call   80206a <nsipc_socket>
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 05                	js     801e3c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e37:	e8 a5 fe ff ff       	call   801ce1 <alloc_sockfd>
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 04             	sub    $0x4,%esp
  801e45:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e47:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801e4e:	75 12                	jne    801e62 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e50:	83 ec 0c             	sub    $0xc,%esp
  801e53:	6a 02                	push   $0x2
  801e55:	e8 9c f5 ff ff       	call   8013f6 <ipc_find_env>
  801e5a:	a3 04 50 80 00       	mov    %eax,0x805004
  801e5f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e62:	6a 07                	push   $0x7
  801e64:	68 00 70 80 00       	push   $0x807000
  801e69:	53                   	push   %ebx
  801e6a:	ff 35 04 50 80 00    	pushl  0x805004
  801e70:	e8 2d f5 ff ff       	call   8013a2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e75:	83 c4 0c             	add    $0xc,%esp
  801e78:	6a 00                	push   $0x0
  801e7a:	6a 00                	push   $0x0
  801e7c:	6a 00                	push   $0x0
  801e7e:	e8 b8 f4 ff ff       	call   80133b <ipc_recv>
}
  801e83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	56                   	push   %esi
  801e8c:	53                   	push   %ebx
  801e8d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e90:	8b 45 08             	mov    0x8(%ebp),%eax
  801e93:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e98:	8b 06                	mov    (%esi),%eax
  801e9a:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e9f:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea4:	e8 95 ff ff ff       	call   801e3e <nsipc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	85 c0                	test   %eax,%eax
  801ead:	78 20                	js     801ecf <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801eaf:	83 ec 04             	sub    $0x4,%esp
  801eb2:	ff 35 10 70 80 00    	pushl  0x807010
  801eb8:	68 00 70 80 00       	push   $0x807000
  801ebd:	ff 75 0c             	pushl  0xc(%ebp)
  801ec0:	e8 b3 ef ff ff       	call   800e78 <memmove>
		*addrlen = ret->ret_addrlen;
  801ec5:	a1 10 70 80 00       	mov    0x807010,%eax
  801eca:	89 06                	mov    %eax,(%esi)
  801ecc:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ecf:	89 d8                	mov    %ebx,%eax
  801ed1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	53                   	push   %ebx
  801edc:	83 ec 08             	sub    $0x8,%esp
  801edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801eea:	53                   	push   %ebx
  801eeb:	ff 75 0c             	pushl  0xc(%ebp)
  801eee:	68 04 70 80 00       	push   $0x807004
  801ef3:	e8 80 ef ff ff       	call   800e78 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ef8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801efe:	b8 02 00 00 00       	mov    $0x2,%eax
  801f03:	e8 36 ff ff ff       	call   801e3e <nsipc>
}
  801f08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f0b:	c9                   	leave  
  801f0c:	c3                   	ret    

00801f0d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f13:	8b 45 08             	mov    0x8(%ebp),%eax
  801f16:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f23:	b8 03 00 00 00       	mov    $0x3,%eax
  801f28:	e8 11 ff ff ff       	call   801e3e <nsipc>
}
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    

00801f2f <nsipc_close>:

int
nsipc_close(int s)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
  801f38:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801f3d:	b8 04 00 00 00       	mov    $0x4,%eax
  801f42:	e8 f7 fe ff ff       	call   801e3e <nsipc>
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	53                   	push   %ebx
  801f4d:	83 ec 08             	sub    $0x8,%esp
  801f50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f53:	8b 45 08             	mov    0x8(%ebp),%eax
  801f56:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f5b:	53                   	push   %ebx
  801f5c:	ff 75 0c             	pushl  0xc(%ebp)
  801f5f:	68 04 70 80 00       	push   $0x807004
  801f64:	e8 0f ef ff ff       	call   800e78 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f69:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801f6f:	b8 05 00 00 00       	mov    $0x5,%eax
  801f74:	e8 c5 fe ff ff       	call   801e3e <nsipc>
}
  801f79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7c:	c9                   	leave  
  801f7d:	c3                   	ret    

00801f7e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f84:	8b 45 08             	mov    0x8(%ebp),%eax
  801f87:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801f94:	b8 06 00 00 00       	mov    $0x6,%eax
  801f99:	e8 a0 fe ff ff       	call   801e3e <nsipc>
}
  801f9e:	c9                   	leave  
  801f9f:	c3                   	ret    

00801fa0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	56                   	push   %esi
  801fa4:	53                   	push   %ebx
  801fa5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fab:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801fb0:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801fb6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb9:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801fbe:	b8 07 00 00 00       	mov    $0x7,%eax
  801fc3:	e8 76 fe ff ff       	call   801e3e <nsipc>
  801fc8:	89 c3                	mov    %eax,%ebx
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	78 35                	js     802003 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801fce:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801fd3:	7f 04                	jg     801fd9 <nsipc_recv+0x39>
  801fd5:	39 c6                	cmp    %eax,%esi
  801fd7:	7d 16                	jge    801fef <nsipc_recv+0x4f>
  801fd9:	68 57 30 80 00       	push   $0x803057
  801fde:	68 1f 30 80 00       	push   $0x80301f
  801fe3:	6a 62                	push   $0x62
  801fe5:	68 6c 30 80 00       	push   $0x80306c
  801fea:	e8 99 e6 ff ff       	call   800688 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801fef:	83 ec 04             	sub    $0x4,%esp
  801ff2:	50                   	push   %eax
  801ff3:	68 00 70 80 00       	push   $0x807000
  801ff8:	ff 75 0c             	pushl  0xc(%ebp)
  801ffb:	e8 78 ee ff ff       	call   800e78 <memmove>
  802000:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802003:	89 d8                	mov    %ebx,%eax
  802005:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802008:	5b                   	pop    %ebx
  802009:	5e                   	pop    %esi
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    

0080200c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	53                   	push   %ebx
  802010:	83 ec 04             	sub    $0x4,%esp
  802013:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802016:	8b 45 08             	mov    0x8(%ebp),%eax
  802019:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80201e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802024:	7e 16                	jle    80203c <nsipc_send+0x30>
  802026:	68 78 30 80 00       	push   $0x803078
  80202b:	68 1f 30 80 00       	push   $0x80301f
  802030:	6a 6d                	push   $0x6d
  802032:	68 6c 30 80 00       	push   $0x80306c
  802037:	e8 4c e6 ff ff       	call   800688 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80203c:	83 ec 04             	sub    $0x4,%esp
  80203f:	53                   	push   %ebx
  802040:	ff 75 0c             	pushl  0xc(%ebp)
  802043:	68 0c 70 80 00       	push   $0x80700c
  802048:	e8 2b ee ff ff       	call   800e78 <memmove>
	nsipcbuf.send.req_size = size;
  80204d:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802053:	8b 45 14             	mov    0x14(%ebp),%eax
  802056:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80205b:	b8 08 00 00 00       	mov    $0x8,%eax
  802060:	e8 d9 fd ff ff       	call   801e3e <nsipc>
}
  802065:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802068:	c9                   	leave  
  802069:	c3                   	ret    

0080206a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802070:	8b 45 08             	mov    0x8(%ebp),%eax
  802073:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802078:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207b:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802080:	8b 45 10             	mov    0x10(%ebp),%eax
  802083:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802088:	b8 09 00 00 00       	mov    $0x9,%eax
  80208d:	e8 ac fd ff ff       	call   801e3e <nsipc>
}
  802092:	c9                   	leave  
  802093:	c3                   	ret    

00802094 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	56                   	push   %esi
  802098:	53                   	push   %ebx
  802099:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80209c:	83 ec 0c             	sub    $0xc,%esp
  80209f:	ff 75 08             	pushl  0x8(%ebp)
  8020a2:	e8 98 f3 ff ff       	call   80143f <fd2data>
  8020a7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020a9:	83 c4 08             	add    $0x8,%esp
  8020ac:	68 84 30 80 00       	push   $0x803084
  8020b1:	53                   	push   %ebx
  8020b2:	e8 2f ec ff ff       	call   800ce6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020b7:	8b 46 04             	mov    0x4(%esi),%eax
  8020ba:	2b 06                	sub    (%esi),%eax
  8020bc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020c9:	00 00 00 
	stat->st_dev = &devpipe;
  8020cc:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  8020d3:	40 80 00 
	return 0;
}
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020de:	5b                   	pop    %ebx
  8020df:	5e                   	pop    %esi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    

008020e2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	53                   	push   %ebx
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020ec:	53                   	push   %ebx
  8020ed:	6a 00                	push   $0x0
  8020ef:	e8 7a f0 ff ff       	call   80116e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020f4:	89 1c 24             	mov    %ebx,(%esp)
  8020f7:	e8 43 f3 ff ff       	call   80143f <fd2data>
  8020fc:	83 c4 08             	add    $0x8,%esp
  8020ff:	50                   	push   %eax
  802100:	6a 00                	push   $0x0
  802102:	e8 67 f0 ff ff       	call   80116e <sys_page_unmap>
}
  802107:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	57                   	push   %edi
  802110:	56                   	push   %esi
  802111:	53                   	push   %ebx
  802112:	83 ec 1c             	sub    $0x1c,%esp
  802115:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802118:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80211a:	a1 08 50 80 00       	mov    0x805008,%eax
  80211f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802122:	83 ec 0c             	sub    $0xc,%esp
  802125:	ff 75 e0             	pushl  -0x20(%ebp)
  802128:	e8 46 04 00 00       	call   802573 <pageref>
  80212d:	89 c3                	mov    %eax,%ebx
  80212f:	89 3c 24             	mov    %edi,(%esp)
  802132:	e8 3c 04 00 00       	call   802573 <pageref>
  802137:	83 c4 10             	add    $0x10,%esp
  80213a:	39 c3                	cmp    %eax,%ebx
  80213c:	0f 94 c1             	sete   %cl
  80213f:	0f b6 c9             	movzbl %cl,%ecx
  802142:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802145:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80214b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80214e:	39 ce                	cmp    %ecx,%esi
  802150:	74 1b                	je     80216d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802152:	39 c3                	cmp    %eax,%ebx
  802154:	75 c4                	jne    80211a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802156:	8b 42 58             	mov    0x58(%edx),%eax
  802159:	ff 75 e4             	pushl  -0x1c(%ebp)
  80215c:	50                   	push   %eax
  80215d:	56                   	push   %esi
  80215e:	68 8b 30 80 00       	push   $0x80308b
  802163:	e8 f9 e5 ff ff       	call   800761 <cprintf>
  802168:	83 c4 10             	add    $0x10,%esp
  80216b:	eb ad                	jmp    80211a <_pipeisclosed+0xe>
	}
}
  80216d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    

00802178 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	57                   	push   %edi
  80217c:	56                   	push   %esi
  80217d:	53                   	push   %ebx
  80217e:	83 ec 28             	sub    $0x28,%esp
  802181:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802184:	56                   	push   %esi
  802185:	e8 b5 f2 ff ff       	call   80143f <fd2data>
  80218a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80218c:	83 c4 10             	add    $0x10,%esp
  80218f:	bf 00 00 00 00       	mov    $0x0,%edi
  802194:	eb 4b                	jmp    8021e1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802196:	89 da                	mov    %ebx,%edx
  802198:	89 f0                	mov    %esi,%eax
  80219a:	e8 6d ff ff ff       	call   80210c <_pipeisclosed>
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	75 48                	jne    8021eb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021a3:	e8 22 ef ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8021ab:	8b 0b                	mov    (%ebx),%ecx
  8021ad:	8d 51 20             	lea    0x20(%ecx),%edx
  8021b0:	39 d0                	cmp    %edx,%eax
  8021b2:	73 e2                	jae    802196 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021b7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021bb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	c1 fa 1f             	sar    $0x1f,%edx
  8021c3:	89 d1                	mov    %edx,%ecx
  8021c5:	c1 e9 1b             	shr    $0x1b,%ecx
  8021c8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8021cb:	83 e2 1f             	and    $0x1f,%edx
  8021ce:	29 ca                	sub    %ecx,%edx
  8021d0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8021d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021d8:	83 c0 01             	add    $0x1,%eax
  8021db:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021de:	83 c7 01             	add    $0x1,%edi
  8021e1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021e4:	75 c2                	jne    8021a8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8021e9:	eb 05                	jmp    8021f0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021eb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    

008021f8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	57                   	push   %edi
  8021fc:	56                   	push   %esi
  8021fd:	53                   	push   %ebx
  8021fe:	83 ec 18             	sub    $0x18,%esp
  802201:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802204:	57                   	push   %edi
  802205:	e8 35 f2 ff ff       	call   80143f <fd2data>
  80220a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80220c:	83 c4 10             	add    $0x10,%esp
  80220f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802214:	eb 3d                	jmp    802253 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802216:	85 db                	test   %ebx,%ebx
  802218:	74 04                	je     80221e <devpipe_read+0x26>
				return i;
  80221a:	89 d8                	mov    %ebx,%eax
  80221c:	eb 44                	jmp    802262 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80221e:	89 f2                	mov    %esi,%edx
  802220:	89 f8                	mov    %edi,%eax
  802222:	e8 e5 fe ff ff       	call   80210c <_pipeisclosed>
  802227:	85 c0                	test   %eax,%eax
  802229:	75 32                	jne    80225d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80222b:	e8 9a ee ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802230:	8b 06                	mov    (%esi),%eax
  802232:	3b 46 04             	cmp    0x4(%esi),%eax
  802235:	74 df                	je     802216 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802237:	99                   	cltd   
  802238:	c1 ea 1b             	shr    $0x1b,%edx
  80223b:	01 d0                	add    %edx,%eax
  80223d:	83 e0 1f             	and    $0x1f,%eax
  802240:	29 d0                	sub    %edx,%eax
  802242:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80224a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80224d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802250:	83 c3 01             	add    $0x1,%ebx
  802253:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802256:	75 d8                	jne    802230 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802258:	8b 45 10             	mov    0x10(%ebp),%eax
  80225b:	eb 05                	jmp    802262 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80225d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802265:	5b                   	pop    %ebx
  802266:	5e                   	pop    %esi
  802267:	5f                   	pop    %edi
  802268:	5d                   	pop    %ebp
  802269:	c3                   	ret    

0080226a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	56                   	push   %esi
  80226e:	53                   	push   %ebx
  80226f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802272:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802275:	50                   	push   %eax
  802276:	e8 db f1 ff ff       	call   801456 <fd_alloc>
  80227b:	83 c4 10             	add    $0x10,%esp
  80227e:	89 c2                	mov    %eax,%edx
  802280:	85 c0                	test   %eax,%eax
  802282:	0f 88 2c 01 00 00    	js     8023b4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802288:	83 ec 04             	sub    $0x4,%esp
  80228b:	68 07 04 00 00       	push   $0x407
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	6a 00                	push   $0x0
  802295:	e8 4f ee ff ff       	call   8010e9 <sys_page_alloc>
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	89 c2                	mov    %eax,%edx
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	0f 88 0d 01 00 00    	js     8023b4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022a7:	83 ec 0c             	sub    $0xc,%esp
  8022aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022ad:	50                   	push   %eax
  8022ae:	e8 a3 f1 ff ff       	call   801456 <fd_alloc>
  8022b3:	89 c3                	mov    %eax,%ebx
  8022b5:	83 c4 10             	add    $0x10,%esp
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	0f 88 e2 00 00 00    	js     8023a2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c0:	83 ec 04             	sub    $0x4,%esp
  8022c3:	68 07 04 00 00       	push   $0x407
  8022c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8022cb:	6a 00                	push   $0x0
  8022cd:	e8 17 ee ff ff       	call   8010e9 <sys_page_alloc>
  8022d2:	89 c3                	mov    %eax,%ebx
  8022d4:	83 c4 10             	add    $0x10,%esp
  8022d7:	85 c0                	test   %eax,%eax
  8022d9:	0f 88 c3 00 00 00    	js     8023a2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022df:	83 ec 0c             	sub    $0xc,%esp
  8022e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e5:	e8 55 f1 ff ff       	call   80143f <fd2data>
  8022ea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ec:	83 c4 0c             	add    $0xc,%esp
  8022ef:	68 07 04 00 00       	push   $0x407
  8022f4:	50                   	push   %eax
  8022f5:	6a 00                	push   $0x0
  8022f7:	e8 ed ed ff ff       	call   8010e9 <sys_page_alloc>
  8022fc:	89 c3                	mov    %eax,%ebx
  8022fe:	83 c4 10             	add    $0x10,%esp
  802301:	85 c0                	test   %eax,%eax
  802303:	0f 88 89 00 00 00    	js     802392 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802309:	83 ec 0c             	sub    $0xc,%esp
  80230c:	ff 75 f0             	pushl  -0x10(%ebp)
  80230f:	e8 2b f1 ff ff       	call   80143f <fd2data>
  802314:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80231b:	50                   	push   %eax
  80231c:	6a 00                	push   $0x0
  80231e:	56                   	push   %esi
  80231f:	6a 00                	push   $0x0
  802321:	e8 06 ee ff ff       	call   80112c <sys_page_map>
  802326:	89 c3                	mov    %eax,%ebx
  802328:	83 c4 20             	add    $0x20,%esp
  80232b:	85 c0                	test   %eax,%eax
  80232d:	78 55                	js     802384 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80232f:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802338:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80233a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802344:	8b 15 40 40 80 00    	mov    0x804040,%edx
  80234a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80234d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80234f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802352:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802359:	83 ec 0c             	sub    $0xc,%esp
  80235c:	ff 75 f4             	pushl  -0xc(%ebp)
  80235f:	e8 cb f0 ff ff       	call   80142f <fd2num>
  802364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802367:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802369:	83 c4 04             	add    $0x4,%esp
  80236c:	ff 75 f0             	pushl  -0x10(%ebp)
  80236f:	e8 bb f0 ff ff       	call   80142f <fd2num>
  802374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802377:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80237a:	83 c4 10             	add    $0x10,%esp
  80237d:	ba 00 00 00 00       	mov    $0x0,%edx
  802382:	eb 30                	jmp    8023b4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802384:	83 ec 08             	sub    $0x8,%esp
  802387:	56                   	push   %esi
  802388:	6a 00                	push   $0x0
  80238a:	e8 df ed ff ff       	call   80116e <sys_page_unmap>
  80238f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802392:	83 ec 08             	sub    $0x8,%esp
  802395:	ff 75 f0             	pushl  -0x10(%ebp)
  802398:	6a 00                	push   $0x0
  80239a:	e8 cf ed ff ff       	call   80116e <sys_page_unmap>
  80239f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023a2:	83 ec 08             	sub    $0x8,%esp
  8023a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a8:	6a 00                	push   $0x0
  8023aa:	e8 bf ed ff ff       	call   80116e <sys_page_unmap>
  8023af:	83 c4 10             	add    $0x10,%esp
  8023b2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8023b4:	89 d0                	mov    %edx,%eax
  8023b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023b9:	5b                   	pop    %ebx
  8023ba:	5e                   	pop    %esi
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    

008023bd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023bd:	55                   	push   %ebp
  8023be:	89 e5                	mov    %esp,%ebp
  8023c0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c6:	50                   	push   %eax
  8023c7:	ff 75 08             	pushl  0x8(%ebp)
  8023ca:	e8 d6 f0 ff ff       	call   8014a5 <fd_lookup>
  8023cf:	83 c4 10             	add    $0x10,%esp
  8023d2:	85 c0                	test   %eax,%eax
  8023d4:	78 18                	js     8023ee <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023d6:	83 ec 0c             	sub    $0xc,%esp
  8023d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8023dc:	e8 5e f0 ff ff       	call   80143f <fd2data>
	return _pipeisclosed(fd, p);
  8023e1:	89 c2                	mov    %eax,%edx
  8023e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e6:	e8 21 fd ff ff       	call   80210c <_pipeisclosed>
  8023eb:	83 c4 10             	add    $0x10,%esp
}
  8023ee:	c9                   	leave  
  8023ef:	c3                   	ret    

008023f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023f0:	55                   	push   %ebp
  8023f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    

008023fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023fa:	55                   	push   %ebp
  8023fb:	89 e5                	mov    %esp,%ebp
  8023fd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802400:	68 a3 30 80 00       	push   $0x8030a3
  802405:	ff 75 0c             	pushl  0xc(%ebp)
  802408:	e8 d9 e8 ff ff       	call   800ce6 <strcpy>
	return 0;
}
  80240d:	b8 00 00 00 00       	mov    $0x0,%eax
  802412:	c9                   	leave  
  802413:	c3                   	ret    

00802414 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802414:	55                   	push   %ebp
  802415:	89 e5                	mov    %esp,%ebp
  802417:	57                   	push   %edi
  802418:	56                   	push   %esi
  802419:	53                   	push   %ebx
  80241a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802420:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802425:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80242b:	eb 2d                	jmp    80245a <devcons_write+0x46>
		m = n - tot;
  80242d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802430:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802432:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802435:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80243a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80243d:	83 ec 04             	sub    $0x4,%esp
  802440:	53                   	push   %ebx
  802441:	03 45 0c             	add    0xc(%ebp),%eax
  802444:	50                   	push   %eax
  802445:	57                   	push   %edi
  802446:	e8 2d ea ff ff       	call   800e78 <memmove>
		sys_cputs(buf, m);
  80244b:	83 c4 08             	add    $0x8,%esp
  80244e:	53                   	push   %ebx
  80244f:	57                   	push   %edi
  802450:	e8 d8 eb ff ff       	call   80102d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802455:	01 de                	add    %ebx,%esi
  802457:	83 c4 10             	add    $0x10,%esp
  80245a:	89 f0                	mov    %esi,%eax
  80245c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80245f:	72 cc                	jb     80242d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802461:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802464:	5b                   	pop    %ebx
  802465:	5e                   	pop    %esi
  802466:	5f                   	pop    %edi
  802467:	5d                   	pop    %ebp
  802468:	c3                   	ret    

00802469 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802469:	55                   	push   %ebp
  80246a:	89 e5                	mov    %esp,%ebp
  80246c:	83 ec 08             	sub    $0x8,%esp
  80246f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802474:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802478:	74 2a                	je     8024a4 <devcons_read+0x3b>
  80247a:	eb 05                	jmp    802481 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80247c:	e8 49 ec ff ff       	call   8010ca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802481:	e8 c5 eb ff ff       	call   80104b <sys_cgetc>
  802486:	85 c0                	test   %eax,%eax
  802488:	74 f2                	je     80247c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80248a:	85 c0                	test   %eax,%eax
  80248c:	78 16                	js     8024a4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80248e:	83 f8 04             	cmp    $0x4,%eax
  802491:	74 0c                	je     80249f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802493:	8b 55 0c             	mov    0xc(%ebp),%edx
  802496:	88 02                	mov    %al,(%edx)
	return 1;
  802498:	b8 01 00 00 00       	mov    $0x1,%eax
  80249d:	eb 05                	jmp    8024a4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80249f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024a4:	c9                   	leave  
  8024a5:	c3                   	ret    

008024a6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024a6:	55                   	push   %ebp
  8024a7:	89 e5                	mov    %esp,%ebp
  8024a9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8024af:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024b2:	6a 01                	push   $0x1
  8024b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024b7:	50                   	push   %eax
  8024b8:	e8 70 eb ff ff       	call   80102d <sys_cputs>
}
  8024bd:	83 c4 10             	add    $0x10,%esp
  8024c0:	c9                   	leave  
  8024c1:	c3                   	ret    

008024c2 <getchar>:

int
getchar(void)
{
  8024c2:	55                   	push   %ebp
  8024c3:	89 e5                	mov    %esp,%ebp
  8024c5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024c8:	6a 01                	push   $0x1
  8024ca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024cd:	50                   	push   %eax
  8024ce:	6a 00                	push   $0x0
  8024d0:	e8 36 f2 ff ff       	call   80170b <read>
	if (r < 0)
  8024d5:	83 c4 10             	add    $0x10,%esp
  8024d8:	85 c0                	test   %eax,%eax
  8024da:	78 0f                	js     8024eb <getchar+0x29>
		return r;
	if (r < 1)
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	7e 06                	jle    8024e6 <getchar+0x24>
		return -E_EOF;
	return c;
  8024e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024e4:	eb 05                	jmp    8024eb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024eb:	c9                   	leave  
  8024ec:	c3                   	ret    

008024ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024ed:	55                   	push   %ebp
  8024ee:	89 e5                	mov    %esp,%ebp
  8024f0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024f6:	50                   	push   %eax
  8024f7:	ff 75 08             	pushl  0x8(%ebp)
  8024fa:	e8 a6 ef ff ff       	call   8014a5 <fd_lookup>
  8024ff:	83 c4 10             	add    $0x10,%esp
  802502:	85 c0                	test   %eax,%eax
  802504:	78 11                	js     802517 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802506:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802509:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80250f:	39 10                	cmp    %edx,(%eax)
  802511:	0f 94 c0             	sete   %al
  802514:	0f b6 c0             	movzbl %al,%eax
}
  802517:	c9                   	leave  
  802518:	c3                   	ret    

00802519 <opencons>:

int
opencons(void)
{
  802519:	55                   	push   %ebp
  80251a:	89 e5                	mov    %esp,%ebp
  80251c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80251f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802522:	50                   	push   %eax
  802523:	e8 2e ef ff ff       	call   801456 <fd_alloc>
  802528:	83 c4 10             	add    $0x10,%esp
		return r;
  80252b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80252d:	85 c0                	test   %eax,%eax
  80252f:	78 3e                	js     80256f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802531:	83 ec 04             	sub    $0x4,%esp
  802534:	68 07 04 00 00       	push   $0x407
  802539:	ff 75 f4             	pushl  -0xc(%ebp)
  80253c:	6a 00                	push   $0x0
  80253e:	e8 a6 eb ff ff       	call   8010e9 <sys_page_alloc>
  802543:	83 c4 10             	add    $0x10,%esp
		return r;
  802546:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802548:	85 c0                	test   %eax,%eax
  80254a:	78 23                	js     80256f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80254c:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802555:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802557:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802561:	83 ec 0c             	sub    $0xc,%esp
  802564:	50                   	push   %eax
  802565:	e8 c5 ee ff ff       	call   80142f <fd2num>
  80256a:	89 c2                	mov    %eax,%edx
  80256c:	83 c4 10             	add    $0x10,%esp
}
  80256f:	89 d0                	mov    %edx,%eax
  802571:	c9                   	leave  
  802572:	c3                   	ret    

00802573 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802573:	55                   	push   %ebp
  802574:	89 e5                	mov    %esp,%ebp
  802576:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802579:	89 d0                	mov    %edx,%eax
  80257b:	c1 e8 16             	shr    $0x16,%eax
  80257e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802585:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80258a:	f6 c1 01             	test   $0x1,%cl
  80258d:	74 1d                	je     8025ac <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80258f:	c1 ea 0c             	shr    $0xc,%edx
  802592:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802599:	f6 c2 01             	test   $0x1,%dl
  80259c:	74 0e                	je     8025ac <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80259e:	c1 ea 0c             	shr    $0xc,%edx
  8025a1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025a8:	ef 
  8025a9:	0f b7 c0             	movzwl %ax,%eax
}
  8025ac:	5d                   	pop    %ebp
  8025ad:	c3                   	ret    
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__udivdi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 f6                	test   %esi,%esi
  8025c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025cd:	89 ca                	mov    %ecx,%edx
  8025cf:	89 f8                	mov    %edi,%eax
  8025d1:	75 3d                	jne    802610 <__udivdi3+0x60>
  8025d3:	39 cf                	cmp    %ecx,%edi
  8025d5:	0f 87 c5 00 00 00    	ja     8026a0 <__udivdi3+0xf0>
  8025db:	85 ff                	test   %edi,%edi
  8025dd:	89 fd                	mov    %edi,%ebp
  8025df:	75 0b                	jne    8025ec <__udivdi3+0x3c>
  8025e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e6:	31 d2                	xor    %edx,%edx
  8025e8:	f7 f7                	div    %edi
  8025ea:	89 c5                	mov    %eax,%ebp
  8025ec:	89 c8                	mov    %ecx,%eax
  8025ee:	31 d2                	xor    %edx,%edx
  8025f0:	f7 f5                	div    %ebp
  8025f2:	89 c1                	mov    %eax,%ecx
  8025f4:	89 d8                	mov    %ebx,%eax
  8025f6:	89 cf                	mov    %ecx,%edi
  8025f8:	f7 f5                	div    %ebp
  8025fa:	89 c3                	mov    %eax,%ebx
  8025fc:	89 d8                	mov    %ebx,%eax
  8025fe:	89 fa                	mov    %edi,%edx
  802600:	83 c4 1c             	add    $0x1c,%esp
  802603:	5b                   	pop    %ebx
  802604:	5e                   	pop    %esi
  802605:	5f                   	pop    %edi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    
  802608:	90                   	nop
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	39 ce                	cmp    %ecx,%esi
  802612:	77 74                	ja     802688 <__udivdi3+0xd8>
  802614:	0f bd fe             	bsr    %esi,%edi
  802617:	83 f7 1f             	xor    $0x1f,%edi
  80261a:	0f 84 98 00 00 00    	je     8026b8 <__udivdi3+0x108>
  802620:	bb 20 00 00 00       	mov    $0x20,%ebx
  802625:	89 f9                	mov    %edi,%ecx
  802627:	89 c5                	mov    %eax,%ebp
  802629:	29 fb                	sub    %edi,%ebx
  80262b:	d3 e6                	shl    %cl,%esi
  80262d:	89 d9                	mov    %ebx,%ecx
  80262f:	d3 ed                	shr    %cl,%ebp
  802631:	89 f9                	mov    %edi,%ecx
  802633:	d3 e0                	shl    %cl,%eax
  802635:	09 ee                	or     %ebp,%esi
  802637:	89 d9                	mov    %ebx,%ecx
  802639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263d:	89 d5                	mov    %edx,%ebp
  80263f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802643:	d3 ed                	shr    %cl,%ebp
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e2                	shl    %cl,%edx
  802649:	89 d9                	mov    %ebx,%ecx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	09 c2                	or     %eax,%edx
  80264f:	89 d0                	mov    %edx,%eax
  802651:	89 ea                	mov    %ebp,%edx
  802653:	f7 f6                	div    %esi
  802655:	89 d5                	mov    %edx,%ebp
  802657:	89 c3                	mov    %eax,%ebx
  802659:	f7 64 24 0c          	mull   0xc(%esp)
  80265d:	39 d5                	cmp    %edx,%ebp
  80265f:	72 10                	jb     802671 <__udivdi3+0xc1>
  802661:	8b 74 24 08          	mov    0x8(%esp),%esi
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e6                	shl    %cl,%esi
  802669:	39 c6                	cmp    %eax,%esi
  80266b:	73 07                	jae    802674 <__udivdi3+0xc4>
  80266d:	39 d5                	cmp    %edx,%ebp
  80266f:	75 03                	jne    802674 <__udivdi3+0xc4>
  802671:	83 eb 01             	sub    $0x1,%ebx
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 d8                	mov    %ebx,%eax
  802678:	89 fa                	mov    %edi,%edx
  80267a:	83 c4 1c             	add    $0x1c,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	31 ff                	xor    %edi,%edi
  80268a:	31 db                	xor    %ebx,%ebx
  80268c:	89 d8                	mov    %ebx,%eax
  80268e:	89 fa                	mov    %edi,%edx
  802690:	83 c4 1c             	add    $0x1c,%esp
  802693:	5b                   	pop    %ebx
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    
  802698:	90                   	nop
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d8                	mov    %ebx,%eax
  8026a2:	f7 f7                	div    %edi
  8026a4:	31 ff                	xor    %edi,%edi
  8026a6:	89 c3                	mov    %eax,%ebx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 fa                	mov    %edi,%edx
  8026ac:	83 c4 1c             	add    $0x1c,%esp
  8026af:	5b                   	pop    %ebx
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
  8026b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	39 ce                	cmp    %ecx,%esi
  8026ba:	72 0c                	jb     8026c8 <__udivdi3+0x118>
  8026bc:	31 db                	xor    %ebx,%ebx
  8026be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026c2:	0f 87 34 ff ff ff    	ja     8025fc <__udivdi3+0x4c>
  8026c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026cd:	e9 2a ff ff ff       	jmp    8025fc <__udivdi3+0x4c>
  8026d2:	66 90                	xchg   %ax,%ax
  8026d4:	66 90                	xchg   %ax,%ax
  8026d6:	66 90                	xchg   %ax,%ax
  8026d8:	66 90                	xchg   %ax,%ax
  8026da:	66 90                	xchg   %ax,%ax
  8026dc:	66 90                	xchg   %ax,%ax
  8026de:	66 90                	xchg   %ax,%ax

008026e0 <__umoddi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	57                   	push   %edi
  8026e2:	56                   	push   %esi
  8026e3:	53                   	push   %ebx
  8026e4:	83 ec 1c             	sub    $0x1c,%esp
  8026e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026f7:	85 d2                	test   %edx,%edx
  8026f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802701:	89 f3                	mov    %esi,%ebx
  802703:	89 3c 24             	mov    %edi,(%esp)
  802706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80270a:	75 1c                	jne    802728 <__umoddi3+0x48>
  80270c:	39 f7                	cmp    %esi,%edi
  80270e:	76 50                	jbe    802760 <__umoddi3+0x80>
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	f7 f7                	div    %edi
  802716:	89 d0                	mov    %edx,%eax
  802718:	31 d2                	xor    %edx,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	39 f2                	cmp    %esi,%edx
  80272a:	89 d0                	mov    %edx,%eax
  80272c:	77 52                	ja     802780 <__umoddi3+0xa0>
  80272e:	0f bd ea             	bsr    %edx,%ebp
  802731:	83 f5 1f             	xor    $0x1f,%ebp
  802734:	75 5a                	jne    802790 <__umoddi3+0xb0>
  802736:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80273a:	0f 82 e0 00 00 00    	jb     802820 <__umoddi3+0x140>
  802740:	39 0c 24             	cmp    %ecx,(%esp)
  802743:	0f 86 d7 00 00 00    	jbe    802820 <__umoddi3+0x140>
  802749:	8b 44 24 08          	mov    0x8(%esp),%eax
  80274d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802751:	83 c4 1c             	add    $0x1c,%esp
  802754:	5b                   	pop    %ebx
  802755:	5e                   	pop    %esi
  802756:	5f                   	pop    %edi
  802757:	5d                   	pop    %ebp
  802758:	c3                   	ret    
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	85 ff                	test   %edi,%edi
  802762:	89 fd                	mov    %edi,%ebp
  802764:	75 0b                	jne    802771 <__umoddi3+0x91>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f7                	div    %edi
  80276f:	89 c5                	mov    %eax,%ebp
  802771:	89 f0                	mov    %esi,%eax
  802773:	31 d2                	xor    %edx,%edx
  802775:	f7 f5                	div    %ebp
  802777:	89 c8                	mov    %ecx,%eax
  802779:	f7 f5                	div    %ebp
  80277b:	89 d0                	mov    %edx,%eax
  80277d:	eb 99                	jmp    802718 <__umoddi3+0x38>
  80277f:	90                   	nop
  802780:	89 c8                	mov    %ecx,%eax
  802782:	89 f2                	mov    %esi,%edx
  802784:	83 c4 1c             	add    $0x1c,%esp
  802787:	5b                   	pop    %ebx
  802788:	5e                   	pop    %esi
  802789:	5f                   	pop    %edi
  80278a:	5d                   	pop    %ebp
  80278b:	c3                   	ret    
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	8b 34 24             	mov    (%esp),%esi
  802793:	bf 20 00 00 00       	mov    $0x20,%edi
  802798:	89 e9                	mov    %ebp,%ecx
  80279a:	29 ef                	sub    %ebp,%edi
  80279c:	d3 e0                	shl    %cl,%eax
  80279e:	89 f9                	mov    %edi,%ecx
  8027a0:	89 f2                	mov    %esi,%edx
  8027a2:	d3 ea                	shr    %cl,%edx
  8027a4:	89 e9                	mov    %ebp,%ecx
  8027a6:	09 c2                	or     %eax,%edx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 14 24             	mov    %edx,(%esp)
  8027ad:	89 f2                	mov    %esi,%edx
  8027af:	d3 e2                	shl    %cl,%edx
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027bb:	d3 e8                	shr    %cl,%eax
  8027bd:	89 e9                	mov    %ebp,%ecx
  8027bf:	89 c6                	mov    %eax,%esi
  8027c1:	d3 e3                	shl    %cl,%ebx
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 d0                	mov    %edx,%eax
  8027c7:	d3 e8                	shr    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	09 d8                	or     %ebx,%eax
  8027cd:	89 d3                	mov    %edx,%ebx
  8027cf:	89 f2                	mov    %esi,%edx
  8027d1:	f7 34 24             	divl   (%esp)
  8027d4:	89 d6                	mov    %edx,%esi
  8027d6:	d3 e3                	shl    %cl,%ebx
  8027d8:	f7 64 24 04          	mull   0x4(%esp)
  8027dc:	39 d6                	cmp    %edx,%esi
  8027de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027e2:	89 d1                	mov    %edx,%ecx
  8027e4:	89 c3                	mov    %eax,%ebx
  8027e6:	72 08                	jb     8027f0 <__umoddi3+0x110>
  8027e8:	75 11                	jne    8027fb <__umoddi3+0x11b>
  8027ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ee:	73 0b                	jae    8027fb <__umoddi3+0x11b>
  8027f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027f4:	1b 14 24             	sbb    (%esp),%edx
  8027f7:	89 d1                	mov    %edx,%ecx
  8027f9:	89 c3                	mov    %eax,%ebx
  8027fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027ff:	29 da                	sub    %ebx,%edx
  802801:	19 ce                	sbb    %ecx,%esi
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 f0                	mov    %esi,%eax
  802807:	d3 e0                	shl    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	d3 ea                	shr    %cl,%edx
  80280d:	89 e9                	mov    %ebp,%ecx
  80280f:	d3 ee                	shr    %cl,%esi
  802811:	09 d0                	or     %edx,%eax
  802813:	89 f2                	mov    %esi,%edx
  802815:	83 c4 1c             	add    $0x1c,%esp
  802818:	5b                   	pop    %ebx
  802819:	5e                   	pop    %esi
  80281a:	5f                   	pop    %edi
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    
  80281d:	8d 76 00             	lea    0x0(%esi),%esi
  802820:	29 f9                	sub    %edi,%ecx
  802822:	19 d6                	sbb    %edx,%esi
  802824:	89 74 24 04          	mov    %esi,0x4(%esp)
  802828:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80282c:	e9 18 ff ff ff       	jmp    802749 <__umoddi3+0x69>
