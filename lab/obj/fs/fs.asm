
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 12 1c 00 00       	call   801c43 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 00 3a 80 00       	push   $0x803a00
  8000b7:	e8 c0 1c 00 00       	call   801d7c <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 17 3a 80 00       	push   $0x803a17
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 27 3a 80 00       	push   $0x803a27
  8000e0:	e8 be 1b 00 00       	call   801ca3 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 30 3a 80 00       	push   $0x803a30
  80010b:	68 3d 3a 80 00       	push   $0x803a3d
  800110:	6a 44                	push   $0x44
  800112:	68 27 3a 80 00       	push   $0x803a27
  800117:	e8 87 1b 00 00       	call   801ca3 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 30 3a 80 00       	push   $0x803a30
  8001cf:	68 3d 3a 80 00       	push   $0x803a3d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 27 3a 80 00       	push   $0x803a27
  8001db:	e8 c3 1a 00 00       	call   801ca3 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800280:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800282:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800288:	89 c6                	mov    %eax,%esi
  80028a:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028d:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800292:	76 1b                	jbe    8002af <bc_pgfault+0x3b>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	ff 72 04             	pushl  0x4(%edx)
  80029a:	53                   	push   %ebx
  80029b:	ff 72 28             	pushl  0x28(%edx)
  80029e:	68 54 3a 80 00       	push   $0x803a54
  8002a3:	6a 27                	push   $0x27
  8002a5:	68 30 3b 80 00       	push   $0x803b30
  8002aa:	e8 f4 19 00 00       	call   801ca3 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002af:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 70 04             	cmp    0x4(%eax),%esi
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	56                   	push   %esi
  8002be:	68 84 3a 80 00       	push   $0x803a84
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 30 3b 80 00       	push   $0x803b30
  8002ca:	e8 d4 19 00 00       	call   801ca3 <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:

	void* base_addr = ROUNDDOWN(addr, PGSIZE);
  8002cf:	89 df                	mov    %ebx,%edi
  8002d1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

	r = sys_page_alloc(0, base_addr, PTE_P|PTE_W|PTE_U);
  8002d7:	83 ec 04             	sub    $0x4,%esp
  8002da:	6a 07                	push   $0x7
  8002dc:	57                   	push   %edi
  8002dd:	6a 00                	push   $0x0
  8002df:	e8 20 24 00 00       	call   802704 <sys_page_alloc>
	if (r < 0)
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	79 12                	jns    8002fd <bc_pgfault+0x89>
		panic("bc_pgfault: sys_page_alloc: %e", r);
  8002eb:	50                   	push   %eax
  8002ec:	68 a8 3a 80 00       	push   $0x803aa8
  8002f1:	6a 38                	push   $0x38
  8002f3:	68 30 3b 80 00       	push   $0x803b30
  8002f8:	e8 a6 19 00 00       	call   801ca3 <_panic>

	r =	ide_read(blockno * (BLKSIZE / SECTSIZE), base_addr, (BLKSIZE / SECTSIZE));
  8002fd:	83 ec 04             	sub    $0x4,%esp
  800300:	6a 08                	push   $0x8
  800302:	57                   	push   %edi
  800303:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  80030a:	50                   	push   %eax
  80030b:	e8 dc fd ff ff       	call   8000ec <ide_read>
	if (r < 0)
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	85 c0                	test   %eax,%eax
  800315:	79 12                	jns    800329 <bc_pgfault+0xb5>
		panic("bc_pgfault: ide_read: %e", r);
  800317:	50                   	push   %eax
  800318:	68 38 3b 80 00       	push   $0x803b38
  80031d:	6a 3c                	push   $0x3c
  80031f:	68 30 3b 80 00       	push   $0x803b30
  800324:	e8 7a 19 00 00       	call   801ca3 <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800329:	89 d8                	mov    %ebx,%eax
  80032b:	c1 e8 0c             	shr    $0xc,%eax
  80032e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	25 07 0e 00 00       	and    $0xe07,%eax
  80033d:	50                   	push   %eax
  80033e:	53                   	push   %ebx
  80033f:	6a 00                	push   $0x0
  800341:	53                   	push   %ebx
  800342:	6a 00                	push   $0x0
  800344:	e8 fe 23 00 00       	call   802747 <sys_page_map>
  800349:	83 c4 20             	add    $0x20,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 12                	jns    800362 <bc_pgfault+0xee>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800350:	50                   	push   %eax
  800351:	68 c8 3a 80 00       	push   $0x803ac8
  800356:	6a 41                	push   $0x41
  800358:	68 30 3b 80 00       	push   $0x803b30
  80035d:	e8 41 19 00 00       	call   801ca3 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800362:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800369:	74 22                	je     80038d <bc_pgfault+0x119>
  80036b:	83 ec 0c             	sub    $0xc,%esp
  80036e:	56                   	push   %esi
  80036f:	e8 94 04 00 00       	call   800808 <block_is_free>
  800374:	83 c4 10             	add    $0x10,%esp
  800377:	84 c0                	test   %al,%al
  800379:	74 12                	je     80038d <bc_pgfault+0x119>
		panic("reading free block %08x\n", blockno);
  80037b:	56                   	push   %esi
  80037c:	68 51 3b 80 00       	push   $0x803b51
  800381:	6a 47                	push   $0x47
  800383:	68 30 3b 80 00       	push   $0x803b30
  800388:	e8 16 19 00 00       	call   801ca3 <_panic>
}
  80038d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	74 0f                	je     8003b1 <diskaddr+0x1c>
  8003a2:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003a8:	85 d2                	test   %edx,%edx
  8003aa:	74 17                	je     8003c3 <diskaddr+0x2e>
  8003ac:	3b 42 04             	cmp    0x4(%edx),%eax
  8003af:	72 12                	jb     8003c3 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003b1:	50                   	push   %eax
  8003b2:	68 e8 3a 80 00       	push   $0x803ae8
  8003b7:	6a 09                	push   $0x9
  8003b9:	68 30 3b 80 00       	push   $0x803b30
  8003be:	e8 e0 18 00 00       	call   801ca3 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c3:	05 00 00 01 00       	add    $0x10000,%eax
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
}
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003d3:	89 d0                	mov    %edx,%eax
  8003d5:	c1 e8 16             	shr    $0x16,%eax
  8003d8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003df:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e4:	f6 c1 01             	test   $0x1,%cl
  8003e7:	74 0d                	je     8003f6 <va_is_mapped+0x29>
  8003e9:	c1 ea 0c             	shr    $0xc,%edx
  8003ec:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003f3:	83 e0 01             	and    $0x1,%eax
  8003f6:	83 e0 01             	and    $0x1,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	c1 e8 0c             	shr    $0xc,%eax
  800404:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80040b:	c1 e8 06             	shr    $0x6,%eax
  80040e:	83 e0 01             	and    $0x1,%eax
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	56                   	push   %esi
  800417:	53                   	push   %ebx
  800418:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80041b:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800421:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800426:	76 12                	jbe    80043a <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800428:	53                   	push   %ebx
  800429:	68 6a 3b 80 00       	push   $0x803b6a
  80042e:	6a 57                	push   $0x57
  800430:	68 30 3b 80 00       	push   $0x803b30
  800435:	e8 69 18 00 00       	call   801ca3 <_panic>

	// LAB 5: Your code here.
	// panic("flush_block not implemented");

	if (!va_is_mapped(addr) || !va_is_dirty(addr))
  80043a:	83 ec 0c             	sub    $0xc,%esp
  80043d:	53                   	push   %ebx
  80043e:	e8 8a ff ff ff       	call   8003cd <va_is_mapped>
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	84 c0                	test   %al,%al
  800448:	0f 84 80 00 00 00    	je     8004ce <flush_block+0xbb>
  80044e:	83 ec 0c             	sub    $0xc,%esp
  800451:	53                   	push   %ebx
  800452:	e8 a4 ff ff ff       	call   8003fb <va_is_dirty>
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	84 c0                	test   %al,%al
  80045c:	74 70                	je     8004ce <flush_block+0xbb>
		return;
	
	void* base_addr = ROUNDDOWN(addr, PGSIZE);
  80045e:	89 de                	mov    %ebx,%esi
  800460:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	int r = ide_write(blockno * 8, base_addr, 8);
  800466:	83 ec 04             	sub    $0x4,%esp
  800469:	6a 08                	push   $0x8
  80046b:	56                   	push   %esi
  80046c:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800472:	c1 e8 0c             	shr    $0xc,%eax
  800475:	c1 e0 03             	shl    $0x3,%eax
  800478:	50                   	push   %eax
  800479:	e8 32 fd ff ff       	call   8001b0 <ide_write>
	if (r < 0)
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	85 c0                	test   %eax,%eax
  800483:	79 12                	jns    800497 <flush_block+0x84>
		panic("flush_block: ide_write: %e", r);
  800485:	50                   	push   %eax
  800486:	68 85 3b 80 00       	push   $0x803b85
  80048b:	6a 63                	push   $0x63
  80048d:	68 30 3b 80 00       	push   $0x803b30
  800492:	e8 0c 18 00 00       	call   801ca3 <_panic>

	r = sys_page_map(0, base_addr, 0, base_addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  800497:	c1 eb 0c             	shr    $0xc,%ebx
  80049a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8004a1:	83 ec 0c             	sub    $0xc,%esp
  8004a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a9:	50                   	push   %eax
  8004aa:	56                   	push   %esi
  8004ab:	6a 00                	push   $0x0
  8004ad:	56                   	push   %esi
  8004ae:	6a 00                	push   $0x0
  8004b0:	e8 92 22 00 00       	call   802747 <sys_page_map>
	if (r < 0)
  8004b5:	83 c4 20             	add    $0x20,%esp
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	79 12                	jns    8004ce <flush_block+0xbb>
		panic("flush_block: sys_page_map: %e", r);
  8004bc:	50                   	push   %eax
  8004bd:	68 a0 3b 80 00       	push   $0x803ba0
  8004c2:	6a 67                	push   $0x67
  8004c4:	68 30 3b 80 00       	push   $0x803b30
  8004c9:	e8 d5 17 00 00       	call   801ca3 <_panic>

}
  8004ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	53                   	push   %ebx
  8004d9:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004df:	68 74 02 80 00       	push   $0x800274
  8004e4:	e8 0c 24 00 00       	call   8028f5 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004f0:	e8 a0 fe ff ff       	call   800395 <diskaddr>
  8004f5:	83 c4 0c             	add    $0xc,%esp
  8004f8:	68 08 01 00 00       	push   $0x108
  8004fd:	50                   	push   %eax
  8004fe:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	e8 89 1f 00 00       	call   802493 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80050a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800511:	e8 7f fe ff ff       	call   800395 <diskaddr>
  800516:	83 c4 08             	add    $0x8,%esp
  800519:	68 be 3b 80 00       	push   $0x803bbe
  80051e:	50                   	push   %eax
  80051f:	e8 dd 1d 00 00       	call   802301 <strcpy>
	flush_block(diskaddr(1));
  800524:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80052b:	e8 65 fe ff ff       	call   800395 <diskaddr>
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	e8 db fe ff ff       	call   800413 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800538:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80053f:	e8 51 fe ff ff       	call   800395 <diskaddr>
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	e8 81 fe ff ff       	call   8003cd <va_is_mapped>
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	84 c0                	test   %al,%al
  800551:	75 16                	jne    800569 <bc_init+0x94>
  800553:	68 e0 3b 80 00       	push   $0x803be0
  800558:	68 3d 3a 80 00       	push   $0x803a3d
  80055d:	6a 78                	push   $0x78
  80055f:	68 30 3b 80 00       	push   $0x803b30
  800564:	e8 3a 17 00 00       	call   801ca3 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	6a 01                	push   $0x1
  80056e:	e8 22 fe ff ff       	call   800395 <diskaddr>
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 80 fe ff ff       	call   8003fb <va_is_dirty>
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	84 c0                	test   %al,%al
  800580:	74 16                	je     800598 <bc_init+0xc3>
  800582:	68 c5 3b 80 00       	push   $0x803bc5
  800587:	68 3d 3a 80 00       	push   $0x803a3d
  80058c:	6a 79                	push   $0x79
  80058e:	68 30 3b 80 00       	push   $0x803b30
  800593:	e8 0b 17 00 00       	call   801ca3 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	6a 01                	push   $0x1
  80059d:	e8 f3 fd ff ff       	call   800395 <diskaddr>
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	50                   	push   %eax
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 dc 21 00 00       	call   802789 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b4:	e8 dc fd ff ff       	call   800395 <diskaddr>
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 0c fe ff ff       	call   8003cd <va_is_mapped>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	84 c0                	test   %al,%al
  8005c6:	74 16                	je     8005de <bc_init+0x109>
  8005c8:	68 df 3b 80 00       	push   $0x803bdf
  8005cd:	68 3d 3a 80 00       	push   $0x803a3d
  8005d2:	6a 7d                	push   $0x7d
  8005d4:	68 30 3b 80 00       	push   $0x803b30
  8005d9:	e8 c5 16 00 00       	call   801ca3 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	6a 01                	push   $0x1
  8005e3:	e8 ad fd ff ff       	call   800395 <diskaddr>
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	68 be 3b 80 00       	push   $0x803bbe
  8005f0:	50                   	push   %eax
  8005f1:	e8 b5 1d 00 00       	call   8023ab <strcmp>
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	74 19                	je     800616 <bc_init+0x141>
  8005fd:	68 0c 3b 80 00       	push   $0x803b0c
  800602:	68 3d 3a 80 00       	push   $0x803a3d
  800607:	68 80 00 00 00       	push   $0x80
  80060c:	68 30 3b 80 00       	push   $0x803b30
  800611:	e8 8d 16 00 00       	call   801ca3 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	6a 01                	push   $0x1
  80061b:	e8 75 fd ff ff       	call   800395 <diskaddr>
  800620:	83 c4 0c             	add    $0xc,%esp
  800623:	68 08 01 00 00       	push   $0x108
  800628:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	e8 5e 1e 00 00       	call   802493 <memmove>
	flush_block(diskaddr(1));
  800635:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80063c:	e8 54 fd ff ff       	call   800395 <diskaddr>
  800641:	89 04 24             	mov    %eax,(%esp)
  800644:	e8 ca fd ff ff       	call   800413 <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800649:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800650:	e8 40 fd ff ff       	call   800395 <diskaddr>
  800655:	83 c4 0c             	add    $0xc,%esp
  800658:	68 08 01 00 00       	push   $0x108
  80065d:	50                   	push   %eax
  80065e:	53                   	push   %ebx
  80065f:	e8 2f 1e 00 00       	call   802493 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066b:	e8 25 fd ff ff       	call   800395 <diskaddr>
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	68 be 3b 80 00       	push   $0x803bbe
  800678:	50                   	push   %eax
  800679:	e8 83 1c 00 00       	call   802301 <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  80067e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800685:	e8 0b fd ff ff       	call   800395 <diskaddr>
  80068a:	83 c0 14             	add    $0x14,%eax
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	e8 7e fd ff ff       	call   800413 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800695:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80069c:	e8 f4 fc ff ff       	call   800395 <diskaddr>
  8006a1:	89 04 24             	mov    %eax,(%esp)
  8006a4:	e8 24 fd ff ff       	call   8003cd <va_is_mapped>
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	84 c0                	test   %al,%al
  8006ae:	75 19                	jne    8006c9 <bc_init+0x1f4>
  8006b0:	68 e0 3b 80 00       	push   $0x803be0
  8006b5:	68 3d 3a 80 00       	push   $0x803a3d
  8006ba:	68 91 00 00 00       	push   $0x91
  8006bf:	68 30 3b 80 00       	push   $0x803b30
  8006c4:	e8 da 15 00 00       	call   801ca3 <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	6a 01                	push   $0x1
  8006ce:	e8 c2 fc ff ff       	call   800395 <diskaddr>
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	50                   	push   %eax
  8006d7:	6a 00                	push   $0x0
  8006d9:	e8 ab 20 00 00       	call   802789 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e5:	e8 ab fc ff ff       	call   800395 <diskaddr>
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	e8 db fc ff ff       	call   8003cd <va_is_mapped>
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	84 c0                	test   %al,%al
  8006f7:	74 19                	je     800712 <bc_init+0x23d>
  8006f9:	68 df 3b 80 00       	push   $0x803bdf
  8006fe:	68 3d 3a 80 00       	push   $0x803a3d
  800703:	68 99 00 00 00       	push   $0x99
  800708:	68 30 3b 80 00       	push   $0x803b30
  80070d:	e8 91 15 00 00       	call   801ca3 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800712:	83 ec 0c             	sub    $0xc,%esp
  800715:	6a 01                	push   $0x1
  800717:	e8 79 fc ff ff       	call   800395 <diskaddr>
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	68 be 3b 80 00       	push   $0x803bbe
  800724:	50                   	push   %eax
  800725:	e8 81 1c 00 00       	call   8023ab <strcmp>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 19                	je     80074a <bc_init+0x275>
  800731:	68 0c 3b 80 00       	push   $0x803b0c
  800736:	68 3d 3a 80 00       	push   $0x803a3d
  80073b:	68 9c 00 00 00       	push   $0x9c
  800740:	68 30 3b 80 00       	push   $0x803b30
  800745:	e8 59 15 00 00       	call   801ca3 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80074a:	83 ec 0c             	sub    $0xc,%esp
  80074d:	6a 01                	push   $0x1
  80074f:	e8 41 fc ff ff       	call   800395 <diskaddr>
  800754:	83 c4 0c             	add    $0xc,%esp
  800757:	68 08 01 00 00       	push   $0x108
  80075c:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800762:	52                   	push   %edx
  800763:	50                   	push   %eax
  800764:	e8 2a 1d 00 00       	call   802493 <memmove>
	flush_block(diskaddr(1));
  800769:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800770:	e8 20 fc ff ff       	call   800395 <diskaddr>
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 96 fc ff ff       	call   800413 <flush_block>

	cprintf("block cache is good\n");
  80077d:	c7 04 24 fa 3b 80 00 	movl   $0x803bfa,(%esp)
  800784:	e8 f3 15 00 00       	call   801d7c <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800789:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800790:	e8 00 fc ff ff       	call   800395 <diskaddr>
  800795:	83 c4 0c             	add    $0xc,%esp
  800798:	68 08 01 00 00       	push   $0x108
  80079d:	50                   	push   %eax
  80079e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007a4:	50                   	push   %eax
  8007a5:	e8 e9 1c 00 00       	call   802493 <memmove>
}
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8007b8:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007bd:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007c3:	74 14                	je     8007d9 <check_super+0x27>
		panic("bad file system magic number");
  8007c5:	83 ec 04             	sub    $0x4,%esp
  8007c8:	68 0f 3c 80 00       	push   $0x803c0f
  8007cd:	6a 0f                	push   $0xf
  8007cf:	68 2c 3c 80 00       	push   $0x803c2c
  8007d4:	e8 ca 14 00 00       	call   801ca3 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007d9:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007e0:	76 14                	jbe    8007f6 <check_super+0x44>
		panic("file system is too large");
  8007e2:	83 ec 04             	sub    $0x4,%esp
  8007e5:	68 34 3c 80 00       	push   $0x803c34
  8007ea:	6a 12                	push   $0x12
  8007ec:	68 2c 3c 80 00       	push   $0x803c2c
  8007f1:	e8 ad 14 00 00       	call   801ca3 <_panic>

	cprintf("superblock is good\n");
  8007f6:	83 ec 0c             	sub    $0xc,%esp
  8007f9:	68 4d 3c 80 00       	push   $0x803c4d
  8007fe:	e8 79 15 00 00       	call   801d7c <cprintf>
}
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80080f:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800815:	85 d2                	test   %edx,%edx
  800817:	74 24                	je     80083d <block_is_free+0x35>
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  80081e:	39 4a 04             	cmp    %ecx,0x4(%edx)
  800821:	76 1f                	jbe    800842 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800823:	89 cb                	mov    %ecx,%ebx
  800825:	c1 eb 05             	shr    $0x5,%ebx
  800828:	b8 01 00 00 00       	mov    $0x1,%eax
  80082d:	d3 e0                	shl    %cl,%eax
  80082f:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800835:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800838:	0f 95 c0             	setne  %al
  80083b:	eb 05                	jmp    800842 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	83 ec 04             	sub    $0x4,%esp
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80084f:	85 c9                	test   %ecx,%ecx
  800851:	75 14                	jne    800867 <free_block+0x22>
		panic("attempt to free zero block");
  800853:	83 ec 04             	sub    $0x4,%esp
  800856:	68 61 3c 80 00       	push   $0x803c61
  80085b:	6a 2d                	push   $0x2d
  80085d:	68 2c 3c 80 00       	push   $0x803c2c
  800862:	e8 3c 14 00 00       	call   801ca3 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800867:	89 cb                	mov    %ecx,%ebx
  800869:	c1 eb 05             	shr    $0x5,%ebx
  80086c:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800872:	b8 01 00 00 00       	mov    $0x1,%eax
  800877:	d3 e0                	shl    %cl,%eax
  800879:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  80087c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087f:	c9                   	leave  
  800880:	c3                   	ret    

00800881 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	56                   	push   %esi
  800885:	53                   	push   %ebx
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// panic("alloc_block not implemented");

	for (int i=1; i<super->s_nblocks; i++) {
  800886:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80088b:	8b 70 04             	mov    0x4(%eax),%esi
  80088e:	bb 01 00 00 00       	mov    $0x1,%ebx
  800893:	eb 55                	jmp    8008ea <alloc_block+0x69>
		
		// find a free block
		if (block_is_free(i)) {
  800895:	53                   	push   %ebx
  800896:	e8 6d ff ff ff       	call   800808 <block_is_free>
  80089b:	83 c4 04             	add    $0x4,%esp
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 45                	je     8008e7 <alloc_block+0x66>

			// mark as used in bitmap
			bitmap[i/32] ^= (1<<(i%32));
  8008a2:	8d 43 1f             	lea    0x1f(%ebx),%eax
  8008a5:	85 db                	test   %ebx,%ebx
  8008a7:	0f 49 c3             	cmovns %ebx,%eax
  8008aa:	c1 f8 05             	sar    $0x5,%eax
  8008ad:	c1 e0 02             	shl    $0x2,%eax
  8008b0:	89 c2                	mov    %eax,%edx
  8008b2:	03 15 04 a0 80 00    	add    0x80a004,%edx
  8008b8:	89 de                	mov    %ebx,%esi
  8008ba:	c1 fe 1f             	sar    $0x1f,%esi
  8008bd:	c1 ee 1b             	shr    $0x1b,%esi
  8008c0:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
  8008c3:	83 e1 1f             	and    $0x1f,%ecx
  8008c6:	29 f1                	sub    %esi,%ecx
  8008c8:	be 01 00 00 00       	mov    $0x1,%esi
  8008cd:	d3 e6                	shl    %cl,%esi
  8008cf:	31 32                	xor    %esi,(%edx)
	
			// flush to disk
			flush_block(&bitmap[i/32]);
  8008d1:	83 ec 0c             	sub    $0xc,%esp
  8008d4:	03 05 04 a0 80 00    	add    0x80a004,%eax
  8008da:	50                   	push   %eax
  8008db:	e8 33 fb ff ff       	call   800413 <flush_block>

			return i;
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	89 d8                	mov    %ebx,%eax
  8008e5:	eb 0c                	jmp    8008f3 <alloc_block+0x72>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// panic("alloc_block not implemented");

	for (int i=1; i<super->s_nblocks; i++) {
  8008e7:	83 c3 01             	add    $0x1,%ebx
  8008ea:	39 de                	cmp    %ebx,%esi
  8008ec:	77 a7                	ja     800895 <alloc_block+0x14>

			return i;
		}
	}

	return -E_NO_DISK;
  8008ee:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	83 ec 1c             	sub    $0x1c,%esp
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
  800906:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	// LAB 5: Your code here.
    //    panic("file_block_walk not implemented");

	if (filebno >= NDIRECT + NINDIRECT)
  800909:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80090f:	0f 87 d5 00 00 00    	ja     8009ea <file_block_walk+0xf0>
  800915:	89 ce                	mov    %ecx,%esi
  800917:	89 d3                	mov    %edx,%ebx
  800919:	89 c7                	mov    %eax,%edi
		return -E_INVAL;

	// direct block
	if (filebno < NDIRECT) {
  80091b:	83 fa 09             	cmp    $0x9,%edx
  80091e:	77 2c                	ja     80094c <file_block_walk+0x52>
		if (ppdiskbno != 0)
  800920:	85 c9                	test   %ecx,%ecx
  800922:	74 09                	je     80092d <file_block_walk+0x33>
			*ppdiskbno = &f->f_direct[filebno];
  800924:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  80092b:	89 01                	mov    %eax,(%ecx)
		
		cprintf("[?] 0x%x, 0x%x -->\n", *ppdiskbno, **ppdiskbno);
  80092d:	8b 06                	mov    (%esi),%eax
  80092f:	83 ec 04             	sub    $0x4,%esp
  800932:	ff 30                	pushl  (%eax)
  800934:	50                   	push   %eax
  800935:	68 7c 3c 80 00       	push   $0x803c7c
  80093a:	e8 3d 14 00 00       	call   801d7c <cprintf>
		return 0;
  80093f:	83 c4 10             	add    $0x10,%esp
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
  800947:	e9 aa 00 00 00       	jmp    8009f6 <file_block_walk+0xfc>
	}

	// indirect block, allocated
	if (f->f_indirect != 0) {
  80094c:	8b 90 b0 00 00 00    	mov    0xb0(%eax),%edx
  800952:	85 d2                	test   %edx,%edx
  800954:	74 26                	je     80097c <file_block_walk+0x82>
		if (ppdiskbno != 0)
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
		// cprintf("[?] 0x%x, 0x%x, 0x%x, 0x%x -->\n", f->f_indirect, filebno - NDIRECT, *ppdiskbno, **ppdiskbno);
		return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}

	// indirect block, allocated
	if (f->f_indirect != 0) {
		if (ppdiskbno != 0)
  80095b:	85 c9                	test   %ecx,%ecx
  80095d:	0f 84 93 00 00 00    	je     8009f6 <file_block_walk+0xfc>
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
  800963:	83 ec 0c             	sub    $0xc,%esp
  800966:	52                   	push   %edx
  800967:	e8 29 fa ff ff       	call   800395 <diskaddr>
  80096c:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800970:	89 06                	mov    %eax,(%esi)
  800972:	83 c4 10             	add    $0x10,%esp
		// cprintf("[?] 0x%x, 0x%x, 0x%x, 0x%x -->\n", f->f_indirect, filebno - NDIRECT, *ppdiskbno, **ppdiskbno);
		return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
  80097a:	eb 7a                	jmp    8009f6 <file_block_walk+0xfc>
	}
	else {

		// not allocated
		if (alloc == 0)
  80097c:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
  800980:	74 6f                	je     8009f1 <file_block_walk+0xf7>
			return -E_NOT_FOUND;
		
		int blockno = alloc_block();
  800982:	e8 fa fe ff ff       	call   800881 <alloc_block>

		if (blockno < 0)
  800987:	85 c0                	test   %eax,%eax
  800989:	78 6b                	js     8009f6 <file_block_walk+0xfc>
			return blockno; // E_NO_DISK

		// cprintf("[?] %d\n", blockno);
		
		f->f_indirect = blockno;
  80098b:	89 87 b0 00 00 00    	mov    %eax,0xb0(%edi)

		// flush to disk
		memset(diskaddr(blockno), 0, BLKSIZE);
  800991:	83 ec 0c             	sub    $0xc,%esp
  800994:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800997:	50                   	push   %eax
  800998:	e8 f8 f9 ff ff       	call   800395 <diskaddr>
  80099d:	83 c4 0c             	add    $0xc,%esp
  8009a0:	68 00 10 00 00       	push   $0x1000
  8009a5:	6a 00                	push   $0x0
  8009a7:	50                   	push   %eax
  8009a8:	e8 99 1a 00 00       	call   802446 <memset>
		flush_block(diskaddr(blockno));
  8009ad:	83 c4 04             	add    $0x4,%esp
  8009b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009b3:	e8 dd f9 ff ff       	call   800395 <diskaddr>
  8009b8:	89 04 24             	mov    %eax,(%esp)
  8009bb:	e8 53 fa ff ff       	call   800413 <flush_block>

		if (ppdiskbno != 0)
  8009c0:	83 c4 10             	add    $0x10,%esp
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
		return 0;
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax

		// flush to disk
		memset(diskaddr(blockno), 0, BLKSIZE);
		flush_block(diskaddr(blockno));

		if (ppdiskbno != 0)
  8009c8:	85 f6                	test   %esi,%esi
  8009ca:	74 2a                	je     8009f6 <file_block_walk+0xfc>
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
  8009cc:	83 ec 0c             	sub    $0xc,%esp
  8009cf:	ff b7 b0 00 00 00    	pushl  0xb0(%edi)
  8009d5:	e8 bb f9 ff ff       	call   800395 <diskaddr>
  8009da:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  8009de:	89 06                	mov    %eax,(%esi)
  8009e0:	83 c4 10             	add    $0x10,%esp
		return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e8:	eb 0c                	jmp    8009f6 <file_block_walk+0xfc>
{
	// LAB 5: Your code here.
    //    panic("file_block_walk not implemented");

	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  8009ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ef:	eb 05                	jmp    8009f6 <file_block_walk+0xfc>
	}
	else {

		// not allocated
		if (alloc == 0)
			return -E_NOT_FOUND;
  8009f1:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
		if (ppdiskbno != 0)
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
		return 0;
	}

}
  8009f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a03:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800a08:	8b 70 04             	mov    0x4(%eax),%esi
  800a0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a10:	eb 29                	jmp    800a3b <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800a12:	8d 43 02             	lea    0x2(%ebx),%eax
  800a15:	50                   	push   %eax
  800a16:	e8 ed fd ff ff       	call   800808 <block_is_free>
  800a1b:	83 c4 04             	add    $0x4,%esp
  800a1e:	84 c0                	test   %al,%al
  800a20:	74 16                	je     800a38 <check_bitmap+0x3a>
  800a22:	68 90 3c 80 00       	push   $0x803c90
  800a27:	68 3d 3a 80 00       	push   $0x803a3d
  800a2c:	6a 60                	push   $0x60
  800a2e:	68 2c 3c 80 00       	push   $0x803c2c
  800a33:	e8 6b 12 00 00       	call   801ca3 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a38:	83 c3 01             	add    $0x1,%ebx
  800a3b:	89 d8                	mov    %ebx,%eax
  800a3d:	c1 e0 0f             	shl    $0xf,%eax
  800a40:	39 f0                	cmp    %esi,%eax
  800a42:	72 ce                	jb     800a12 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800a44:	83 ec 0c             	sub    $0xc,%esp
  800a47:	6a 00                	push   $0x0
  800a49:	e8 ba fd ff ff       	call   800808 <block_is_free>
  800a4e:	83 c4 10             	add    $0x10,%esp
  800a51:	84 c0                	test   %al,%al
  800a53:	74 16                	je     800a6b <check_bitmap+0x6d>
  800a55:	68 a4 3c 80 00       	push   $0x803ca4
  800a5a:	68 3d 3a 80 00       	push   $0x803a3d
  800a5f:	6a 63                	push   $0x63
  800a61:	68 2c 3c 80 00       	push   $0x803c2c
  800a66:	e8 38 12 00 00       	call   801ca3 <_panic>
	assert(!block_is_free(1));
  800a6b:	83 ec 0c             	sub    $0xc,%esp
  800a6e:	6a 01                	push   $0x1
  800a70:	e8 93 fd ff ff       	call   800808 <block_is_free>
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	84 c0                	test   %al,%al
  800a7a:	74 16                	je     800a92 <check_bitmap+0x94>
  800a7c:	68 b6 3c 80 00       	push   $0x803cb6
  800a81:	68 3d 3a 80 00       	push   $0x803a3d
  800a86:	6a 64                	push   $0x64
  800a88:	68 2c 3c 80 00       	push   $0x803c2c
  800a8d:	e8 11 12 00 00       	call   801ca3 <_panic>

	cprintf("bitmap is good\n");
  800a92:	83 ec 0c             	sub    $0xc,%esp
  800a95:	68 c8 3c 80 00       	push   $0x803cc8
  800a9a:	e8 dd 12 00 00       	call   801d7c <cprintf>
}
  800a9f:	83 c4 10             	add    $0x10,%esp
  800aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800aaf:	e8 ab f5 ff ff       	call   80005f <ide_probe_disk1>
  800ab4:	84 c0                	test   %al,%al
  800ab6:	74 0f                	je     800ac7 <fs_init+0x1e>
		ide_set_disk(1);
  800ab8:	83 ec 0c             	sub    $0xc,%esp
  800abb:	6a 01                	push   $0x1
  800abd:	e8 01 f6 ff ff       	call   8000c3 <ide_set_disk>
  800ac2:	83 c4 10             	add    $0x10,%esp
  800ac5:	eb 0d                	jmp    800ad4 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	6a 00                	push   $0x0
  800acc:	e8 f2 f5 ff ff       	call   8000c3 <ide_set_disk>
  800ad1:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800ad4:	e8 fc f9 ff ff       	call   8004d5 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	6a 01                	push   $0x1
  800ade:	e8 b2 f8 ff ff       	call   800395 <diskaddr>
  800ae3:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800ae8:	e8 c5 fc ff ff       	call   8007b2 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800aed:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800af4:	e8 9c f8 ff ff       	call   800395 <diskaddr>
  800af9:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800afe:	e8 fb fe ff ff       	call   8009fe <check_bitmap>
	
}
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	c9                   	leave  
  800b07:	c3                   	ret    

00800b08 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	53                   	push   %ebx
  800b0c:	83 ec 20             	sub    $0x20,%esp
    //    panic("file_get_block not implemented");

	uint32_t *ptr;
	int blockno = 0;

	int r = file_block_walk(f, filebno, &ptr, 1);
  800b0f:	6a 01                	push   $0x1
  800b11:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800b14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	e8 db fd ff ff       	call   8008fa <file_block_walk>
	if (r < 0)
  800b1f:	83 c4 10             	add    $0x10,%esp
  800b22:	85 c0                	test   %eax,%eax
  800b24:	0f 88 85 00 00 00    	js     800baf <file_get_block+0xa7>
		return r;
	cprintf("[?] 0x%x -> \n", *ptr);
  800b2a:	83 ec 08             	sub    $0x8,%esp
  800b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b30:	ff 30                	pushl  (%eax)
  800b32:	68 d8 3c 80 00       	push   $0x803cd8
  800b37:	e8 40 12 00 00       	call   801d7c <cprintf>
	// not allocated yet
	if (*ptr == 0) {
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b42:	83 38 00             	cmpl   $0x0,(%eax)
  800b45:	75 3c                	jne    800b83 <file_get_block+0x7b>
		
		blockno = alloc_block();
  800b47:	e8 35 fd ff ff       	call   800881 <alloc_block>
  800b4c:	89 c3                	mov    %eax,%ebx

		// cprintf("[?] %d\n", blockno);

		if (blockno < 0)
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	78 5d                	js     800baf <file_get_block+0xa7>
			return blockno;
		
		*ptr = blockno;
  800b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b55:	89 18                	mov    %ebx,(%eax)

		// flush to disk
		memset(diskaddr(blockno), 0, BLKSIZE);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	53                   	push   %ebx
  800b5b:	e8 35 f8 ff ff       	call   800395 <diskaddr>
  800b60:	83 c4 0c             	add    $0xc,%esp
  800b63:	68 00 10 00 00       	push   $0x1000
  800b68:	6a 00                	push   $0x0
  800b6a:	50                   	push   %eax
  800b6b:	e8 d6 18 00 00       	call   802446 <memset>
		flush_block(diskaddr(blockno));
  800b70:	89 1c 24             	mov    %ebx,(%esp)
  800b73:	e8 1d f8 ff ff       	call   800395 <diskaddr>
  800b78:	89 04 24             	mov    %eax,(%esp)
  800b7b:	e8 93 f8 ff ff       	call   800413 <flush_block>
  800b80:	83 c4 10             	add    $0x10,%esp
	}

	cprintf("[?] 0x%x\n", *ptr);
  800b83:	83 ec 08             	sub    $0x8,%esp
  800b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b89:	ff 30                	pushl  (%eax)
  800b8b:	68 e6 3c 80 00       	push   $0x803ce6
  800b90:	e8 e7 11 00 00       	call   801d7c <cprintf>

	*blk = diskaddr(*ptr);
  800b95:	83 c4 04             	add    $0x4,%esp
  800b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b9b:	ff 30                	pushl  (%eax)
  800b9d:	e8 f3 f7 ff ff       	call   800395 <diskaddr>
  800ba2:	8b 55 10             	mov    0x10(%ebp),%edx
  800ba5:	89 02                	mov    %eax,(%edx)
	return 0;
  800ba7:	83 c4 10             	add    $0x10,%esp
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax

}
  800baf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800bc0:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800bc6:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800bcc:	eb 03                	jmp    800bd1 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800bce:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800bd1:	80 38 2f             	cmpb   $0x2f,(%eax)
  800bd4:	74 f8                	je     800bce <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800bd6:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800bdc:	83 c1 08             	add    $0x8,%ecx
  800bdf:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800be5:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800bec:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800bf2:	85 c9                	test   %ecx,%ecx
  800bf4:	74 06                	je     800bfc <walk_path+0x48>
		*pdir = 0;
  800bf6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800bfc:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800c02:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800c08:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800c0d:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800c13:	e9 5f 01 00 00       	jmp    800d77 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800c18:	83 c7 01             	add    $0x1,%edi
  800c1b:	eb 02                	jmp    800c1f <walk_path+0x6b>
  800c1d:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800c1f:	0f b6 17             	movzbl (%edi),%edx
  800c22:	80 fa 2f             	cmp    $0x2f,%dl
  800c25:	74 04                	je     800c2b <walk_path+0x77>
  800c27:	84 d2                	test   %dl,%dl
  800c29:	75 ed                	jne    800c18 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800c2b:	89 fb                	mov    %edi,%ebx
  800c2d:	29 c3                	sub    %eax,%ebx
  800c2f:	83 fb 7f             	cmp    $0x7f,%ebx
  800c32:	0f 8f 69 01 00 00    	jg     800da1 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800c38:	83 ec 04             	sub    $0x4,%esp
  800c3b:	53                   	push   %ebx
  800c3c:	50                   	push   %eax
  800c3d:	56                   	push   %esi
  800c3e:	e8 50 18 00 00       	call   802493 <memmove>
		name[path - p] = '\0';
  800c43:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800c4a:	00 
  800c4b:	83 c4 10             	add    $0x10,%esp
  800c4e:	eb 03                	jmp    800c53 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800c50:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800c53:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800c56:	74 f8                	je     800c50 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800c58:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800c5e:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c65:	0f 85 3d 01 00 00    	jne    800da8 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800c6b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800c71:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800c76:	74 19                	je     800c91 <walk_path+0xdd>
  800c78:	68 f0 3c 80 00       	push   $0x803cf0
  800c7d:	68 3d 3a 80 00       	push   $0x803a3d
  800c82:	68 05 01 00 00       	push   $0x105
  800c87:	68 2c 3c 80 00       	push   $0x803c2c
  800c8c:	e8 12 10 00 00       	call   801ca3 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800c91:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800c97:	85 c0                	test   %eax,%eax
  800c99:	0f 48 c2             	cmovs  %edx,%eax
  800c9c:	c1 f8 0c             	sar    $0xc,%eax
  800c9f:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800ca5:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800cac:	00 00 00 
  800caf:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800cb5:	eb 5e                	jmp    800d15 <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800cb7:	83 ec 04             	sub    $0x4,%esp
  800cba:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800cc0:	50                   	push   %eax
  800cc1:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800cc7:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800ccd:	e8 36 fe ff ff       	call   800b08 <file_get_block>
  800cd2:	83 c4 10             	add    $0x10,%esp
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	0f 88 ee 00 00 00    	js     800dcb <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800cdd:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800ce3:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800ce9:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800cef:	83 ec 08             	sub    $0x8,%esp
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	e8 b2 16 00 00       	call   8023ab <strcmp>
  800cf9:	83 c4 10             	add    $0x10,%esp
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	0f 84 ab 00 00 00    	je     800daf <walk_path+0x1fb>
  800d04:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800d0a:	39 fb                	cmp    %edi,%ebx
  800d0c:	75 db                	jne    800ce9 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800d0e:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800d15:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800d1b:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800d21:	75 94                	jne    800cb7 <walk_path+0x103>
  800d23:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800d29:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d2e:	80 3f 00             	cmpb   $0x0,(%edi)
  800d31:	0f 85 a3 00 00 00    	jne    800dda <walk_path+0x226>
				if (pdir)
  800d37:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	74 08                	je     800d49 <walk_path+0x195>
					*pdir = dir;
  800d41:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d47:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800d49:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800d4d:	74 15                	je     800d64 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800d4f:	83 ec 08             	sub    $0x8,%esp
  800d52:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800d58:	50                   	push   %eax
  800d59:	ff 75 08             	pushl  0x8(%ebp)
  800d5c:	e8 a0 15 00 00       	call   802301 <strcpy>
  800d61:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800d64:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800d70:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d75:	eb 63                	jmp    800dda <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800d77:	80 38 00             	cmpb   $0x0,(%eax)
  800d7a:	0f 85 9d fe ff ff    	jne    800c1d <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800d80:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d86:	85 c0                	test   %eax,%eax
  800d88:	74 02                	je     800d8c <walk_path+0x1d8>
		*pdir = dir;
  800d8a:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800d8c:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d92:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d98:	89 08                	mov    %ecx,(%eax)
	return 0;
  800d9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9f:	eb 39                	jmp    800dda <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800da1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800da6:	eb 32                	jmp    800dda <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800da8:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800dad:	eb 2b                	jmp    800dda <walk_path+0x226>
  800daf:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800db5:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800dbb:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800dc1:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800dc7:	89 f8                	mov    %edi,%eax
  800dc9:	eb ac                	jmp    800d77 <walk_path+0x1c3>
  800dcb:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800dd1:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800dd4:	0f 84 4f ff ff ff    	je     800d29 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800de8:	6a 00                	push   $0x0
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	ba 00 00 00 00       	mov    $0x0,%edx
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
  800df5:	e8 ba fd ff ff       	call   800bb4 <walk_path>
}
  800dfa:	c9                   	leave  
  800dfb:	c3                   	ret    

00800dfc <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	83 ec 2c             	sub    $0x2c,%esp
  800e05:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e08:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800e19:	39 ca                	cmp    %ecx,%edx
  800e1b:	7e 7c                	jle    800e99 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800e1d:	29 ca                	sub    %ecx,%edx
  800e1f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e22:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800e26:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800e29:	89 ce                	mov    %ecx,%esi
  800e2b:	01 d1                	add    %edx,%ecx
  800e2d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800e30:	eb 5d                	jmp    800e8f <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e32:	83 ec 04             	sub    $0x4,%esp
  800e35:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e38:	50                   	push   %eax
  800e39:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800e3f:	85 f6                	test   %esi,%esi
  800e41:	0f 49 c6             	cmovns %esi,%eax
  800e44:	c1 f8 0c             	sar    $0xc,%eax
  800e47:	50                   	push   %eax
  800e48:	ff 75 08             	pushl  0x8(%ebp)
  800e4b:	e8 b8 fc ff ff       	call   800b08 <file_get_block>
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	78 42                	js     800e99 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e57:	89 f2                	mov    %esi,%edx
  800e59:	c1 fa 1f             	sar    $0x1f,%edx
  800e5c:	c1 ea 14             	shr    $0x14,%edx
  800e5f:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e62:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e67:	29 d0                	sub    %edx,%eax
  800e69:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e6c:	29 da                	sub    %ebx,%edx
  800e6e:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800e73:	29 c3                	sub    %eax,%ebx
  800e75:	39 da                	cmp    %ebx,%edx
  800e77:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	53                   	push   %ebx
  800e7e:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e81:	50                   	push   %eax
  800e82:	57                   	push   %edi
  800e83:	e8 0b 16 00 00       	call   802493 <memmove>
		pos += bn;
  800e88:	01 de                	add    %ebx,%esi
		buf += bn;
  800e8a:	01 df                	add    %ebx,%edi
  800e8c:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800e8f:	89 f3                	mov    %esi,%ebx
  800e91:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e94:	77 9c                	ja     800e32 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e96:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
  800ea7:	83 ec 2c             	sub    $0x2c,%esp
  800eaa:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800ead:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800eb3:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800eb6:	0f 8e a7 00 00 00    	jle    800f63 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800ebc:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800ec2:	05 ff 0f 00 00       	add    $0xfff,%eax
  800ec7:	0f 49 f8             	cmovns %eax,%edi
  800eca:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed0:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800ed5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed8:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800ede:	0f 49 c2             	cmovns %edx,%eax
  800ee1:	c1 f8 0c             	sar    $0xc,%eax
  800ee4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ee7:	89 c3                	mov    %eax,%ebx
  800ee9:	eb 39                	jmp    800f24 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	6a 00                	push   $0x0
  800ef0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800ef3:	89 da                	mov    %ebx,%edx
  800ef5:	89 f0                	mov    %esi,%eax
  800ef7:	e8 fe f9 ff ff       	call   8008fa <file_block_walk>
  800efc:	83 c4 10             	add    $0x10,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	78 4d                	js     800f50 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800f03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f06:	8b 00                	mov    (%eax),%eax
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	74 15                	je     800f21 <file_set_size+0x80>
		free_block(*ptr);
  800f0c:	83 ec 0c             	sub    $0xc,%esp
  800f0f:	50                   	push   %eax
  800f10:	e8 30 f9 ff ff       	call   800845 <free_block>
		*ptr = 0;
  800f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800f1e:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800f21:	83 c3 01             	add    $0x1,%ebx
  800f24:	39 df                	cmp    %ebx,%edi
  800f26:	77 c3                	ja     800eeb <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800f28:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800f2c:	77 35                	ja     800f63 <file_set_size+0xc2>
  800f2e:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800f34:	85 c0                	test   %eax,%eax
  800f36:	74 2b                	je     800f63 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	50                   	push   %eax
  800f3c:	e8 04 f9 ff ff       	call   800845 <free_block>
		f->f_indirect = 0;
  800f41:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800f48:	00 00 00 
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	eb 13                	jmp    800f63 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	50                   	push   %eax
  800f54:	68 0d 3d 80 00       	push   $0x803d0d
  800f59:	e8 1e 0e 00 00       	call   801d7c <cprintf>
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	eb be                	jmp    800f21 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800f63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f66:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	56                   	push   %esi
  800f70:	e8 9e f4 ff ff       	call   800413 <flush_block>
	return 0;
}
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	57                   	push   %edi
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	83 ec 2c             	sub    $0x2c,%esp
  800f8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f8e:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800f91:	89 f0                	mov    %esi,%eax
  800f93:	03 45 10             	add    0x10(%ebp),%eax
  800f96:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9c:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800fa2:	76 72                	jbe    801016 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800fa4:	83 ec 08             	sub    $0x8,%esp
  800fa7:	50                   	push   %eax
  800fa8:	51                   	push   %ecx
  800fa9:	e8 f3 fe ff ff       	call   800ea1 <file_set_size>
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	79 61                	jns    801016 <file_write+0x94>
  800fb5:	eb 69                	jmp    801020 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fbd:	50                   	push   %eax
  800fbe:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800fc4:	85 f6                	test   %esi,%esi
  800fc6:	0f 49 c6             	cmovns %esi,%eax
  800fc9:	c1 f8 0c             	sar    $0xc,%eax
  800fcc:	50                   	push   %eax
  800fcd:	ff 75 08             	pushl  0x8(%ebp)
  800fd0:	e8 33 fb ff ff       	call   800b08 <file_get_block>
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 44                	js     801020 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800fdc:	89 f2                	mov    %esi,%edx
  800fde:	c1 fa 1f             	sar    $0x1f,%edx
  800fe1:	c1 ea 14             	shr    $0x14,%edx
  800fe4:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800fe7:	25 ff 0f 00 00       	and    $0xfff,%eax
  800fec:	29 d0                	sub    %edx,%eax
  800fee:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800ff1:	29 d9                	sub    %ebx,%ecx
  800ff3:	89 cb                	mov    %ecx,%ebx
  800ff5:	ba 00 10 00 00       	mov    $0x1000,%edx
  800ffa:	29 c2                	sub    %eax,%edx
  800ffc:	39 d1                	cmp    %edx,%ecx
  800ffe:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	53                   	push   %ebx
  801005:	57                   	push   %edi
  801006:	03 45 e4             	add    -0x1c(%ebp),%eax
  801009:	50                   	push   %eax
  80100a:	e8 84 14 00 00       	call   802493 <memmove>
		pos += bn;
  80100f:	01 de                	add    %ebx,%esi
		buf += bn;
  801011:	01 df                	add    %ebx,%edi
  801013:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  801016:	89 f3                	mov    %esi,%ebx
  801018:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  80101b:	77 9a                	ja     800fb7 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  80101d:	8b 45 10             	mov    0x10(%ebp),%eax
}
  801020:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801023:	5b                   	pop    %ebx
  801024:	5e                   	pop    %esi
  801025:	5f                   	pop    %edi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 10             	sub    $0x10,%esp
  801030:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
  801038:	eb 3c                	jmp    801076 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	6a 00                	push   $0x0
  80103f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  801042:	89 da                	mov    %ebx,%edx
  801044:	89 f0                	mov    %esi,%eax
  801046:	e8 af f8 ff ff       	call   8008fa <file_block_walk>
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 21                	js     801073 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  801052:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801055:	85 c0                	test   %eax,%eax
  801057:	74 1a                	je     801073 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  801059:	8b 00                	mov    (%eax),%eax
  80105b:	85 c0                	test   %eax,%eax
  80105d:	74 14                	je     801073 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	50                   	push   %eax
  801063:	e8 2d f3 ff ff       	call   800395 <diskaddr>
  801068:	89 04 24             	mov    %eax,(%esp)
  80106b:	e8 a3 f3 ff ff       	call   800413 <flush_block>
  801070:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801073:	83 c3 01             	add    $0x1,%ebx
  801076:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  80107c:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  801082:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  801088:	85 c9                	test   %ecx,%ecx
  80108a:	0f 49 c1             	cmovns %ecx,%eax
  80108d:	c1 f8 0c             	sar    $0xc,%eax
  801090:	39 c3                	cmp    %eax,%ebx
  801092:	7c a6                	jl     80103a <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	56                   	push   %esi
  801098:	e8 76 f3 ff ff       	call   800413 <flush_block>
	if (f->f_indirect)
  80109d:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	74 14                	je     8010be <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	50                   	push   %eax
  8010ae:	e8 e2 f2 ff ff       	call   800395 <diskaddr>
  8010b3:	89 04 24             	mov    %eax,(%esp)
  8010b6:	e8 58 f3 ff ff       	call   800413 <flush_block>
  8010bb:	83 c4 10             	add    $0x10,%esp
}
  8010be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
  8010cb:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  8010d1:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8010d7:	50                   	push   %eax
  8010d8:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  8010de:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	e8 c8 fa ff ff       	call   800bb4 <walk_path>
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	0f 84 d1 00 00 00    	je     8011c8 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  8010f7:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8010fa:	0f 85 0c 01 00 00    	jne    80120c <file_create+0x147>
  801100:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  801106:	85 f6                	test   %esi,%esi
  801108:	0f 84 c1 00 00 00    	je     8011cf <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80110e:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  801114:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801119:	74 19                	je     801134 <file_create+0x6f>
  80111b:	68 f0 3c 80 00       	push   $0x803cf0
  801120:	68 3d 3a 80 00       	push   $0x803a3d
  801125:	68 1e 01 00 00       	push   $0x11e
  80112a:	68 2c 3c 80 00       	push   $0x803c2c
  80112f:	e8 6f 0b 00 00       	call   801ca3 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801134:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80113a:	85 c0                	test   %eax,%eax
  80113c:	0f 48 c2             	cmovs  %edx,%eax
  80113f:	c1 f8 0c             	sar    $0xc,%eax
  801142:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  801148:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80114d:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  801153:	eb 3b                	jmp    801190 <file_create+0xcb>
  801155:	83 ec 04             	sub    $0x4,%esp
  801158:	57                   	push   %edi
  801159:	53                   	push   %ebx
  80115a:	56                   	push   %esi
  80115b:	e8 a8 f9 ff ff       	call   800b08 <file_get_block>
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	0f 88 a1 00 00 00    	js     80120c <file_create+0x147>
			return r;
		f = (struct File*) blk;
  80116b:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801171:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  801177:	80 38 00             	cmpb   $0x0,(%eax)
  80117a:	75 08                	jne    801184 <file_create+0xbf>
				*file = &f[j];
  80117c:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801182:	eb 52                	jmp    8011d6 <file_create+0x111>
  801184:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801189:	39 d0                	cmp    %edx,%eax
  80118b:	75 ea                	jne    801177 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  80118d:	83 c3 01             	add    $0x1,%ebx
  801190:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  801196:	75 bd                	jne    801155 <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  801198:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  80119f:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8011a2:	83 ec 04             	sub    $0x4,%esp
  8011a5:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	53                   	push   %ebx
  8011ad:	56                   	push   %esi
  8011ae:	e8 55 f9 ff ff       	call   800b08 <file_get_block>
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 52                	js     80120c <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  8011ba:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8011c0:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8011c6:	eb 0e                	jmp    8011d6 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  8011c8:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8011cd:	eb 3d                	jmp    80120c <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  8011cf:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8011d4:	eb 36                	jmp    80120c <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  8011e6:	e8 16 11 00 00       	call   802301 <strcpy>
	*pf = f;
  8011eb:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  8011f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f4:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  8011f6:	83 c4 04             	add    $0x4,%esp
  8011f9:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  8011ff:	e8 24 fe ff ff       	call   801028 <file_flush>
	return 0;
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80120c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120f:	5b                   	pop    %ebx
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	53                   	push   %ebx
  801218:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80121b:	bb 01 00 00 00       	mov    $0x1,%ebx
  801220:	eb 17                	jmp    801239 <fs_sync+0x25>
		flush_block(diskaddr(i));
  801222:	83 ec 0c             	sub    $0xc,%esp
  801225:	53                   	push   %ebx
  801226:	e8 6a f1 ff ff       	call   800395 <diskaddr>
  80122b:	89 04 24             	mov    %eax,(%esp)
  80122e:	e8 e0 f1 ff ff       	call   800413 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801233:	83 c3 01             	add    $0x1,%ebx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80123e:	39 58 04             	cmp    %ebx,0x4(%eax)
  801241:	77 df                	ja     801222 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  801243:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801246:	c9                   	leave  
  801247:	c3                   	ret    

00801248 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80124e:	e8 c1 ff ff ff       	call   801214 <fs_sync>
	return 0;
}
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  801262:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801267:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  80126c:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80126e:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801271:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801277:	83 c0 01             	add    $0x1,%eax
  80127a:	83 c2 10             	add    $0x10,%edx
  80127d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801282:	75 e8                	jne    80126c <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	56                   	push   %esi
  80128a:	53                   	push   %ebx
  80128b:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80128e:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  801293:	83 ec 0c             	sub    $0xc,%esp
  801296:	89 d8                	mov    %ebx,%eax
  801298:	c1 e0 04             	shl    $0x4,%eax
  80129b:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8012a1:	e8 ac 1f 00 00       	call   803252 <pageref>
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	74 07                	je     8012b4 <openfile_alloc+0x2e>
  8012ad:	83 f8 01             	cmp    $0x1,%eax
  8012b0:	74 20                	je     8012d2 <openfile_alloc+0x4c>
  8012b2:	eb 51                	jmp    801305 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8012b4:	83 ec 04             	sub    $0x4,%esp
  8012b7:	6a 07                	push   $0x7
  8012b9:	89 d8                	mov    %ebx,%eax
  8012bb:	c1 e0 04             	shl    $0x4,%eax
  8012be:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8012c4:	6a 00                	push   $0x0
  8012c6:	e8 39 14 00 00       	call   802704 <sys_page_alloc>
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 43                	js     801315 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8012d2:	c1 e3 04             	shl    $0x4,%ebx
  8012d5:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8012db:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8012e2:	04 00 00 
			*o = &opentab[i];
  8012e5:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8012e7:	83 ec 04             	sub    $0x4,%esp
  8012ea:	68 00 10 00 00       	push   $0x1000
  8012ef:	6a 00                	push   $0x0
  8012f1:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  8012f7:	e8 4a 11 00 00       	call   802446 <memset>
			return (*o)->o_fileid;
  8012fc:	8b 06                	mov    (%esi),%eax
  8012fe:	8b 00                	mov    (%eax),%eax
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	eb 10                	jmp    801315 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801305:	83 c3 01             	add    $0x1,%ebx
  801308:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80130e:	75 83                	jne    801293 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801310:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801315:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	57                   	push   %edi
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 18             	sub    $0x18,%esp
  801325:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801328:	89 fb                	mov    %edi,%ebx
  80132a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801330:	89 de                	mov    %ebx,%esi
  801332:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801335:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80133b:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801341:	e8 0c 1f 00 00       	call   803252 <pageref>
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	83 f8 01             	cmp    $0x1,%eax
  80134c:	7e 17                	jle    801365 <openfile_lookup+0x49>
  80134e:	c1 e3 04             	shl    $0x4,%ebx
  801351:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801357:	75 13                	jne    80136c <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801359:	8b 45 10             	mov    0x10(%ebp),%eax
  80135c:	89 30                	mov    %esi,(%eax)
	return 0;
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
  801363:	eb 0c                	jmp    801371 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  801365:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136a:	eb 05                	jmp    801371 <openfile_lookup+0x55>
  80136c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  801371:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801374:	5b                   	pop    %ebx
  801375:	5e                   	pop    %esi
  801376:	5f                   	pop    %edi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	83 ec 10             	sub    $0x10,%esp
  801381:	8b 75 08             	mov    0x8(%ebp),%esi
  801384:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_set_size %08x %08x %08x\n", envid, req->req_fileid, req->req_size);
  801387:	ff 73 04             	pushl  0x4(%ebx)
  80138a:	ff 33                	pushl  (%ebx)
  80138c:	56                   	push   %esi
  80138d:	68 2c 3d 80 00       	push   $0x803d2c
  801392:	e8 e5 09 00 00       	call   801d7c <cprintf>
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801397:	83 c4 0c             	add    $0xc,%esp
  80139a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	ff 33                	pushl  (%ebx)
  8013a0:	56                   	push   %esi
  8013a1:	e8 76 ff ff ff       	call   80131c <openfile_lookup>
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 14                	js     8013c1 <serve_set_size+0x48>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	ff 73 04             	pushl  0x4(%ebx)
  8013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b6:	ff 70 04             	pushl  0x4(%eax)
  8013b9:	e8 e3 fa ff ff       	call   800ea1 <file_set_size>
  8013be:	83 c4 10             	add    $0x10,%esp
}
  8013c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5e                   	pop    %esi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 10             	sub    $0x10,%esp
  8013d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fsreq_read *req = &ipc->read;
	struct Fsret_read *ret = &ipc->readRet;

	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
  8013d6:	ff 73 04             	pushl  0x4(%ebx)
  8013d9:	ff 33                	pushl  (%ebx)
  8013db:	56                   	push   %esi
  8013dc:	68 c7 3d 80 00       	push   $0x803dc7
  8013e1:	e8 96 09 00 00       	call   801d7c <cprintf>
	// Lab 5: Your code here:

	struct OpenFile *o;
	int r;

    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013e6:	83 c4 0c             	add    $0xc,%esp
  8013e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	ff 33                	pushl  (%ebx)
  8013ef:	56                   	push   %esi
  8013f0:	e8 27 ff ff ff       	call   80131c <openfile_lookup>
  8013f5:	83 c4 10             	add    $0x10,%esp
		return r;
  8013f8:	89 c2                	mov    %eax,%edx
	// Lab 5: Your code here:

	struct OpenFile *o;
	int r;

    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 2b                	js     801429 <serve_read+0x61>
		return r;

	r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
  8013fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801401:	8b 50 0c             	mov    0xc(%eax),%edx
  801404:	ff 72 04             	pushl  0x4(%edx)
  801407:	ff 73 04             	pushl  0x4(%ebx)
  80140a:	53                   	push   %ebx
  80140b:	ff 70 04             	pushl  0x4(%eax)
  80140e:	e8 e9 f9 ff ff       	call   800dfc <file_read>
	if (r < 0)
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 0d                	js     801427 <serve_read+0x5f>
		return r;

	// req->req_fileid += r; 
	o->o_fd->fd_offset += r;
  80141a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80141d:	8b 52 0c             	mov    0xc(%edx),%edx
  801420:	01 42 04             	add    %eax,0x4(%edx)

	return r;
  801423:	89 c2                	mov    %eax,%edx
  801425:	eb 02                	jmp    801429 <serve_read+0x61>
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
	if (r < 0)
		return r;
  801427:	89 c2                	mov    %eax,%edx

	// req->req_fileid += r; 
	o->o_fd->fd_offset += r;

	return r;
}
  801429:	89 d0                	mov    %edx,%eax
  80142b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142e:	5b                   	pop    %ebx
  80142f:	5e                   	pop    %esi
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 10             	sub    $0x10,%esp
  80143a:	8b 75 08             	mov    0x8(%ebp),%esi
  80143d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
  801440:	ff 73 04             	pushl  0x4(%ebx)
  801443:	ff 33                	pushl  (%ebx)
  801445:	56                   	push   %esi
  801446:	68 e2 3d 80 00       	push   $0x803de2
  80144b:	e8 2c 09 00 00       	call   801d7c <cprintf>
	// LAB 5: Your code here.
	// panic("serve_write not implemented");

	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801450:	83 c4 0c             	add    $0xc,%esp
  801453:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	ff 33                	pushl  (%ebx)
  801459:	56                   	push   %esi
  80145a:	e8 bd fe ff ff       	call   80131c <openfile_lookup>
  80145f:	83 c4 10             	add    $0x10,%esp
		return r;
  801462:	89 c2                	mov    %eax,%edx
	// LAB 5: Your code here.
	// panic("serve_write not implemented");

	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801464:	85 c0                	test   %eax,%eax
  801466:	78 31                	js     801499 <serve_write+0x67>
		return r;
	if ((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	8b 50 0c             	mov    0xc(%eax),%edx
  80146e:	ff 72 04             	pushl  0x4(%edx)
  801471:	ff 73 04             	pushl  0x4(%ebx)
  801474:	8d 53 08             	lea    0x8(%ebx),%edx
  801477:	52                   	push   %edx
  801478:	ff 70 04             	pushl  0x4(%eax)
  80147b:	e8 02 fb ff ff       	call   800f82 <file_write>
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 10                	js     801497 <serve_write+0x65>
		return r;
	o->o_fd->fd_offset += req->req_n;
  801487:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148a:	8b 52 0c             	mov    0xc(%edx),%edx
  80148d:	8b 4b 04             	mov    0x4(%ebx),%ecx
  801490:	01 4a 04             	add    %ecx,0x4(%edx)
	return r;
  801493:	89 c2                	mov    %eax,%edx
  801495:	eb 02                	jmp    801499 <serve_write+0x67>
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;
	if ((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
		return r;
  801497:	89 c2                	mov    %eax,%edx
	o->o_fd->fd_offset += req->req_n;
	return r;

}
  801499:	89 d0                	mov    %edx,%eax
  80149b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 14             	sub    $0x14,%esp
  8014aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fsret_stat *ret = &ipc->statRet;
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);
  8014b0:	ff 33                	pushl  (%ebx)
  8014b2:	56                   	push   %esi
  8014b3:	68 fe 3d 80 00       	push   $0x803dfe
  8014b8:	e8 bf 08 00 00       	call   801d7c <cprintf>

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014bd:	83 c4 0c             	add    $0xc,%esp
  8014c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	ff 33                	pushl  (%ebx)
  8014c6:	56                   	push   %esi
  8014c7:	e8 50 fe ff ff       	call   80131c <openfile_lookup>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 3f                	js     801512 <serve_stat+0x70>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d9:	ff 70 04             	pushl  0x4(%eax)
  8014dc:	53                   	push   %ebx
  8014dd:	e8 1f 0e 00 00       	call   802301 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8014e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e5:	8b 50 04             	mov    0x4(%eax),%edx
  8014e8:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8014ee:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8014f4:	8b 40 04             	mov    0x4(%eax),%eax
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801501:	0f 94 c0             	sete   %al
  801504:	0f b6 c0             	movzbl %al,%eax
  801507:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80150d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801512:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801515:	5b                   	pop    %ebx
  801516:	5e                   	pop    %esi
  801517:	5d                   	pop    %ebp
  801518:	c3                   	ret    

00801519 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	56                   	push   %esi
  80151d:	53                   	push   %ebx
  80151e:	83 ec 14             	sub    $0x14,%esp
  801521:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801524:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);
  801527:	ff 36                	pushl  (%esi)
  801529:	53                   	push   %ebx
  80152a:	68 14 3e 80 00       	push   $0x803e14
  80152f:	e8 48 08 00 00       	call   801d7c <cprintf>

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801534:	83 c4 0c             	add    $0xc,%esp
  801537:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	ff 36                	pushl  (%esi)
  80153d:	53                   	push   %ebx
  80153e:	e8 d9 fd ff ff       	call   80131c <openfile_lookup>
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	78 16                	js     801560 <serve_flush+0x47>
		return r;
	file_flush(o->o_file);
  80154a:	83 ec 0c             	sub    $0xc,%esp
  80154d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801550:	ff 70 04             	pushl  0x4(%eax)
  801553:	e8 d0 fa ff ff       	call   801028 <file_flush>
	return 0;
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801560:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    

00801567 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	56                   	push   %esi
  80156b:	53                   	push   %ebx
  80156c:	81 ec 10 04 00 00    	sub    $0x410,%esp
  801572:	8b 75 0c             	mov    0xc(%ebp),%esi
	int fileid;
	int r;
	struct OpenFile *o;

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);
  801575:	ff b6 00 04 00 00    	pushl  0x400(%esi)
  80157b:	56                   	push   %esi
  80157c:	ff 75 08             	pushl  0x8(%ebp)
  80157f:	68 2b 3e 80 00       	push   $0x803e2b
  801584:	e8 f3 07 00 00       	call   801d7c <cprintf>

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801589:	83 c4 0c             	add    $0xc,%esp
  80158c:	68 00 04 00 00       	push   $0x400
  801591:	56                   	push   %esi
  801592:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	e8 f5 0e 00 00       	call   802493 <memmove>
	path[MAXPATHLEN-1] = 0;
  80159e:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  8015a2:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8015a8:	89 04 24             	mov    %eax,(%esp)
  8015ab:	e8 d6 fc ff ff       	call   801286 <openfile_alloc>
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	79 1a                	jns    8015d1 <serve_open+0x6a>
  8015b7:	89 c3                	mov    %eax,%ebx
		if (debug)
			cprintf("openfile_alloc failed: %e", r);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	50                   	push   %eax
  8015bd:	68 44 3e 80 00       	push   $0x803e44
  8015c2:	e8 b5 07 00 00       	call   801d7c <cprintf>
		return r;
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	89 d8                	mov    %ebx,%eax
  8015cc:	e9 62 01 00 00       	jmp    801733 <serve_open+0x1cc>
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  8015d1:	f6 86 01 04 00 00 01 	testb  $0x1,0x401(%esi)
  8015d8:	74 45                	je     80161f <serve_open+0xb8>
		if ((r = file_create(path, &f)) < 0) {
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	e8 d5 fa ff ff       	call   8010c5 <file_create>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	79 5d                	jns    801656 <serve_open+0xef>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8015f9:	f6 86 01 04 00 00 04 	testb  $0x4,0x401(%esi)
  801600:	75 05                	jne    801607 <serve_open+0xa0>
  801602:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801605:	74 18                	je     80161f <serve_open+0xb8>
				goto try_open;
			if (debug)
				cprintf("file_create failed: %e", r);
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	53                   	push   %ebx
  80160b:	68 5e 3e 80 00       	push   $0x803e5e
  801610:	e8 67 07 00 00       	call   801d7c <cprintf>
			return r;
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	89 d8                	mov    %ebx,%eax
  80161a:	e9 14 01 00 00       	jmp    801733 <serve_open+0x1cc>
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	e8 ad f7 ff ff       	call   800de2 <file_open>
  801635:	89 c3                	mov    %eax,%ebx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	79 18                	jns    801656 <serve_open+0xef>
			if (debug)
				cprintf("file_open failed: %e", r);
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	50                   	push   %eax
  801642:	68 75 3e 80 00       	push   $0x803e75
  801647:	e8 30 07 00 00       	call   801d7c <cprintf>
			return r;
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	89 d8                	mov    %ebx,%eax
  801651:	e9 dd 00 00 00       	jmp    801733 <serve_open+0x1cc>
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  801656:	f6 86 01 04 00 00 02 	testb  $0x2,0x401(%esi)
  80165d:	74 31                	je     801690 <serve_open+0x129>
		if ((r = file_set_size(f, 0)) < 0) {
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	6a 00                	push   $0x0
  801664:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  80166a:	e8 32 f8 ff ff       	call   800ea1 <file_set_size>
  80166f:	89 c3                	mov    %eax,%ebx
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	79 18                	jns    801690 <serve_open+0x129>
			if (debug)
				cprintf("file_set_size failed: %e", r);
  801678:	83 ec 08             	sub    $0x8,%esp
  80167b:	50                   	push   %eax
  80167c:	68 8a 3e 80 00       	push   $0x803e8a
  801681:	e8 f6 06 00 00       	call   801d7c <cprintf>
			return r;
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	89 d8                	mov    %ebx,%eax
  80168b:	e9 a3 00 00 00       	jmp    801733 <serve_open+0x1cc>
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	e8 3c f7 ff ff       	call   800de2 <file_open>
  8016a6:	89 c3                	mov    %eax,%ebx
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	79 15                	jns    8016c4 <serve_open+0x15d>
		if (debug)
			cprintf("file_open failed: %e", r);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	50                   	push   %eax
  8016b3:	68 75 3e 80 00       	push   $0x803e75
  8016b8:	e8 bf 06 00 00       	call   801d7c <cprintf>
		return r;
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	eb 6f                	jmp    801733 <serve_open+0x1cc>
	}

	// Save the file pointer
	o->o_file = f;
  8016c4:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016ca:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8016d0:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8016d3:	8b 50 0c             	mov    0xc(%eax),%edx
  8016d6:	8b 08                	mov    (%eax),%ecx
  8016d8:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8016db:	8b 48 0c             	mov    0xc(%eax),%ecx
  8016de:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  8016e4:	83 e2 03             	and    $0x3,%edx
  8016e7:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8016ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ed:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8016f3:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8016f5:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016fb:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  801701:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);
  801704:	83 ec 08             	sub    $0x8,%esp
  801707:	ff 70 0c             	pushl  0xc(%eax)
  80170a:	68 a3 3e 80 00       	push   $0x803ea3
  80170f:	e8 68 06 00 00       	call   801d7c <cprintf>

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801714:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80171a:	8b 50 0c             	mov    0xc(%eax),%edx
  80171d:	8b 45 10             	mov    0x10(%ebp),%eax
  801720:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801722:	8b 45 14             	mov    0x14(%ebp),%eax
  801725:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801733:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801736:	5b                   	pop    %ebx
  801737:	5e                   	pop    %esi
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	57                   	push   %edi
  80173e:	56                   	push   %esi
  80173f:	53                   	push   %ebx
  801740:	83 ec 1c             	sub    $0x1c,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801743:	8d 75 e0             	lea    -0x20(%ebp),%esi
  801746:	8d 7d e4             	lea    -0x1c(%ebp),%edi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801749:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	56                   	push   %esi
  801754:	ff 35 44 50 80 00    	pushl  0x805044
  80175a:	57                   	push   %edi
  80175b:	e8 00 12 00 00       	call   802960 <ipc_recv>
  801760:	89 c3                	mov    %eax,%ebx
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);
  801762:	a1 44 50 80 00       	mov    0x805044,%eax
  801767:	89 c2                	mov    %eax,%edx
  801769:	c1 ea 0c             	shr    $0xc,%edx

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
  80176c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801773:	89 04 24             	mov    %eax,(%esp)
  801776:	52                   	push   %edx
  801777:	ff 75 e4             	pushl  -0x1c(%ebp)
  80177a:	53                   	push   %ebx
  80177b:	68 4c 3d 80 00       	push   $0x803d4c
  801780:	e8 f7 05 00 00       	call   801d7c <cprintf>
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801785:	83 c4 20             	add    $0x20,%esp
  801788:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
  80178c:	75 15                	jne    8017a3 <serve+0x69>
			cprintf("Invalid request from %08x: no argument page\n",
  80178e:	83 ec 08             	sub    $0x8,%esp
  801791:	ff 75 e4             	pushl  -0x1c(%ebp)
  801794:	68 74 3d 80 00       	push   $0x803d74
  801799:	e8 de 05 00 00       	call   801d7c <cprintf>
				whom);
			continue; // just leave it hanging...
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	eb a6                	jmp    801749 <serve+0xf>
		}

		pg = NULL;
  8017a3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		if (req == FSREQ_OPEN) {
  8017aa:	83 fb 01             	cmp    $0x1,%ebx
  8017ad:	75 18                	jne    8017c7 <serve+0x8d>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8017af:	56                   	push   %esi
  8017b0:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8017b3:	50                   	push   %eax
  8017b4:	ff 35 44 50 80 00    	pushl  0x805044
  8017ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017bd:	e8 a5 fd ff ff       	call   801567 <serve_open>
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	eb 3c                	jmp    801803 <serve+0xc9>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8017c7:	83 fb 08             	cmp    $0x8,%ebx
  8017ca:	77 1e                	ja     8017ea <serve+0xb0>
  8017cc:	8b 04 9d 20 50 80 00 	mov    0x805020(,%ebx,4),%eax
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	74 13                	je     8017ea <serve+0xb0>
			r = handlers[req](whom, fsreq);
  8017d7:	83 ec 08             	sub    $0x8,%esp
  8017da:	ff 35 44 50 80 00    	pushl  0x805044
  8017e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e3:	ff d0                	call   *%eax
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	eb 19                	jmp    801803 <serve+0xc9>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8017ea:	83 ec 04             	sub    $0x4,%esp
  8017ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017f0:	53                   	push   %ebx
  8017f1:	68 a4 3d 80 00       	push   $0x803da4
  8017f6:	e8 81 05 00 00       	call   801d7c <cprintf>
  8017fb:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8017fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801803:	ff 75 e0             	pushl  -0x20(%ebp)
  801806:	ff 75 dc             	pushl  -0x24(%ebp)
  801809:	50                   	push   %eax
  80180a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80180d:	e8 b5 11 00 00       	call   8029c7 <ipc_send>
		sys_page_unmap(0, fsreq);
  801812:	83 c4 08             	add    $0x8,%esp
  801815:	ff 35 44 50 80 00    	pushl  0x805044
  80181b:	6a 00                	push   $0x0
  80181d:	e8 67 0f 00 00       	call   802789 <sys_page_unmap>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	e9 1f ff ff ff       	jmp    801749 <serve+0xf>

0080182a <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801830:	c7 05 60 90 80 00 bf 	movl   $0x803ebf,0x809060
  801837:	3e 80 00 
	cprintf("FS is running\n");
  80183a:	68 c2 3e 80 00       	push   $0x803ec2
  80183f:	e8 38 05 00 00       	call   801d7c <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801844:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801849:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80184e:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801850:	c7 04 24 d1 3e 80 00 	movl   $0x803ed1,(%esp)
  801857:	e8 20 05 00 00       	call   801d7c <cprintf>

	serve_init();
  80185c:	e8 f9 f9 ff ff       	call   80125a <serve_init>
	fs_init();
  801861:	e8 43 f2 ff ff       	call   800aa9 <fs_init>
        fs_test();
  801866:	e8 05 00 00 00       	call   801870 <fs_test>
	serve();
  80186b:	e8 ca fe ff ff       	call   80173a <serve>

00801870 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	53                   	push   %ebx
  801874:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801877:	6a 07                	push   $0x7
  801879:	68 00 10 00 00       	push   $0x1000
  80187e:	6a 00                	push   $0x0
  801880:	e8 7f 0e 00 00       	call   802704 <sys_page_alloc>
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	79 12                	jns    80189e <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80188c:	50                   	push   %eax
  80188d:	68 e0 3e 80 00       	push   $0x803ee0
  801892:	6a 12                	push   $0x12
  801894:	68 f3 3e 80 00       	push   $0x803ef3
  801899:	e8 05 04 00 00       	call   801ca3 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	68 00 10 00 00       	push   $0x1000
  8018a6:	ff 35 04 a0 80 00    	pushl  0x80a004
  8018ac:	68 00 10 00 00       	push   $0x1000
  8018b1:	e8 dd 0b 00 00       	call   802493 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8018b6:	e8 c6 ef ff ff       	call   800881 <alloc_block>
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	79 12                	jns    8018d4 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8018c2:	50                   	push   %eax
  8018c3:	68 fd 3e 80 00       	push   $0x803efd
  8018c8:	6a 17                	push   $0x17
  8018ca:	68 f3 3e 80 00       	push   $0x803ef3
  8018cf:	e8 cf 03 00 00       	call   801ca3 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8018d4:	8d 50 1f             	lea    0x1f(%eax),%edx
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	0f 49 d0             	cmovns %eax,%edx
  8018dc:	c1 fa 05             	sar    $0x5,%edx
  8018df:	89 c3                	mov    %eax,%ebx
  8018e1:	c1 fb 1f             	sar    $0x1f,%ebx
  8018e4:	c1 eb 1b             	shr    $0x1b,%ebx
  8018e7:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8018ea:	83 e1 1f             	and    $0x1f,%ecx
  8018ed:	29 d9                	sub    %ebx,%ecx
  8018ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f4:	d3 e0                	shl    %cl,%eax
  8018f6:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8018fd:	75 16                	jne    801915 <fs_test+0xa5>
  8018ff:	68 0d 3f 80 00       	push   $0x803f0d
  801904:	68 3d 3a 80 00       	push   $0x803a3d
  801909:	6a 19                	push   $0x19
  80190b:	68 f3 3e 80 00       	push   $0x803ef3
  801910:	e8 8e 03 00 00       	call   801ca3 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801915:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  80191b:	85 04 91             	test   %eax,(%ecx,%edx,4)
  80191e:	74 16                	je     801936 <fs_test+0xc6>
  801920:	68 88 40 80 00       	push   $0x804088
  801925:	68 3d 3a 80 00       	push   $0x803a3d
  80192a:	6a 1b                	push   $0x1b
  80192c:	68 f3 3e 80 00       	push   $0x803ef3
  801931:	e8 6d 03 00 00       	call   801ca3 <_panic>
	cprintf("alloc_block is good\n");
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	68 28 3f 80 00       	push   $0x803f28
  80193e:	e8 39 04 00 00       	call   801d7c <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801943:	83 c4 08             	add    $0x8,%esp
  801946:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801949:	50                   	push   %eax
  80194a:	68 3d 3f 80 00       	push   $0x803f3d
  80194f:	e8 8e f4 ff ff       	call   800de2 <file_open>
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80195a:	74 1b                	je     801977 <fs_test+0x107>
  80195c:	89 c2                	mov    %eax,%edx
  80195e:	c1 ea 1f             	shr    $0x1f,%edx
  801961:	84 d2                	test   %dl,%dl
  801963:	74 12                	je     801977 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801965:	50                   	push   %eax
  801966:	68 48 3f 80 00       	push   $0x803f48
  80196b:	6a 1f                	push   $0x1f
  80196d:	68 f3 3e 80 00       	push   $0x803ef3
  801972:	e8 2c 03 00 00       	call   801ca3 <_panic>
	else if (r == 0)
  801977:	85 c0                	test   %eax,%eax
  801979:	75 14                	jne    80198f <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80197b:	83 ec 04             	sub    $0x4,%esp
  80197e:	68 a8 40 80 00       	push   $0x8040a8
  801983:	6a 21                	push   $0x21
  801985:	68 f3 3e 80 00       	push   $0x803ef3
  80198a:	e8 14 03 00 00       	call   801ca3 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801995:	50                   	push   %eax
  801996:	68 61 3f 80 00       	push   $0x803f61
  80199b:	e8 42 f4 ff ff       	call   800de2 <file_open>
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	79 12                	jns    8019b9 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8019a7:	50                   	push   %eax
  8019a8:	68 6a 3f 80 00       	push   $0x803f6a
  8019ad:	6a 23                	push   $0x23
  8019af:	68 f3 3e 80 00       	push   $0x803ef3
  8019b4:	e8 ea 02 00 00       	call   801ca3 <_panic>
	cprintf("file_open is good\n");
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	68 81 3f 80 00       	push   $0x803f81
  8019c1:	e8 b6 03 00 00       	call   801d7c <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8019c6:	83 c4 0c             	add    $0xc,%esp
  8019c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019cc:	50                   	push   %eax
  8019cd:	6a 00                	push   $0x0
  8019cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d2:	e8 31 f1 ff ff       	call   800b08 <file_get_block>
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	79 12                	jns    8019f0 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8019de:	50                   	push   %eax
  8019df:	68 94 3f 80 00       	push   $0x803f94
  8019e4:	6a 27                	push   $0x27
  8019e6:	68 f3 3e 80 00       	push   $0x803ef3
  8019eb:	e8 b3 02 00 00       	call   801ca3 <_panic>
	if (strcmp(blk, msg) != 0)
  8019f0:	83 ec 08             	sub    $0x8,%esp
  8019f3:	68 c8 40 80 00       	push   $0x8040c8
  8019f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019fb:	e8 ab 09 00 00       	call   8023ab <strcmp>
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	85 c0                	test   %eax,%eax
  801a05:	74 14                	je     801a1b <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  801a07:	83 ec 04             	sub    $0x4,%esp
  801a0a:	68 f0 40 80 00       	push   $0x8040f0
  801a0f:	6a 29                	push   $0x29
  801a11:	68 f3 3e 80 00       	push   $0x803ef3
  801a16:	e8 88 02 00 00       	call   801ca3 <_panic>
	cprintf("file_get_block is good\n");
  801a1b:	83 ec 0c             	sub    $0xc,%esp
  801a1e:	68 a7 3f 80 00       	push   $0x803fa7
  801a23:	e8 54 03 00 00       	call   801d7c <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a2b:	0f b6 10             	movzbl (%eax),%edx
  801a2e:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a33:	c1 e8 0c             	shr    $0xc,%eax
  801a36:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	a8 40                	test   $0x40,%al
  801a42:	75 16                	jne    801a5a <fs_test+0x1ea>
  801a44:	68 c0 3f 80 00       	push   $0x803fc0
  801a49:	68 3d 3a 80 00       	push   $0x803a3d
  801a4e:	6a 2d                	push   $0x2d
  801a50:	68 f3 3e 80 00       	push   $0x803ef3
  801a55:	e8 49 02 00 00       	call   801ca3 <_panic>
	file_flush(f);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a60:	e8 c3 f5 ff ff       	call   801028 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a68:	c1 e8 0c             	shr    $0xc,%eax
  801a6b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	a8 40                	test   $0x40,%al
  801a77:	74 16                	je     801a8f <fs_test+0x21f>
  801a79:	68 bf 3f 80 00       	push   $0x803fbf
  801a7e:	68 3d 3a 80 00       	push   $0x803a3d
  801a83:	6a 2f                	push   $0x2f
  801a85:	68 f3 3e 80 00       	push   $0x803ef3
  801a8a:	e8 14 02 00 00       	call   801ca3 <_panic>
	cprintf("file_flush is good\n");
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	68 db 3f 80 00       	push   $0x803fdb
  801a97:	e8 e0 02 00 00       	call   801d7c <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801a9c:	83 c4 08             	add    $0x8,%esp
  801a9f:	6a 00                	push   $0x0
  801aa1:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa4:	e8 f8 f3 ff ff       	call   800ea1 <file_set_size>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	79 12                	jns    801ac2 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801ab0:	50                   	push   %eax
  801ab1:	68 ef 3f 80 00       	push   $0x803fef
  801ab6:	6a 33                	push   $0x33
  801ab8:	68 f3 3e 80 00       	push   $0x803ef3
  801abd:	e8 e1 01 00 00       	call   801ca3 <_panic>
	assert(f->f_direct[0] == 0);
  801ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac5:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801acc:	74 16                	je     801ae4 <fs_test+0x274>
  801ace:	68 01 40 80 00       	push   $0x804001
  801ad3:	68 3d 3a 80 00       	push   $0x803a3d
  801ad8:	6a 34                	push   $0x34
  801ada:	68 f3 3e 80 00       	push   $0x803ef3
  801adf:	e8 bf 01 00 00       	call   801ca3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801ae4:	c1 e8 0c             	shr    $0xc,%eax
  801ae7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801aee:	a8 40                	test   $0x40,%al
  801af0:	74 16                	je     801b08 <fs_test+0x298>
  801af2:	68 15 40 80 00       	push   $0x804015
  801af7:	68 3d 3a 80 00       	push   $0x803a3d
  801afc:	6a 35                	push   $0x35
  801afe:	68 f3 3e 80 00       	push   $0x803ef3
  801b03:	e8 9b 01 00 00       	call   801ca3 <_panic>
	cprintf("file_truncate is good\n");
  801b08:	83 ec 0c             	sub    $0xc,%esp
  801b0b:	68 2f 40 80 00       	push   $0x80402f
  801b10:	e8 67 02 00 00       	call   801d7c <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801b15:	c7 04 24 c8 40 80 00 	movl   $0x8040c8,(%esp)
  801b1c:	e8 a7 07 00 00       	call   8022c8 <strlen>
  801b21:	83 c4 08             	add    $0x8,%esp
  801b24:	50                   	push   %eax
  801b25:	ff 75 f4             	pushl  -0xc(%ebp)
  801b28:	e8 74 f3 ff ff       	call   800ea1 <file_set_size>
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	85 c0                	test   %eax,%eax
  801b32:	79 12                	jns    801b46 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801b34:	50                   	push   %eax
  801b35:	68 46 40 80 00       	push   $0x804046
  801b3a:	6a 39                	push   $0x39
  801b3c:	68 f3 3e 80 00       	push   $0x803ef3
  801b41:	e8 5d 01 00 00       	call   801ca3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b49:	89 c2                	mov    %eax,%edx
  801b4b:	c1 ea 0c             	shr    $0xc,%edx
  801b4e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b55:	f6 c2 40             	test   $0x40,%dl
  801b58:	74 16                	je     801b70 <fs_test+0x300>
  801b5a:	68 15 40 80 00       	push   $0x804015
  801b5f:	68 3d 3a 80 00       	push   $0x803a3d
  801b64:	6a 3a                	push   $0x3a
  801b66:	68 f3 3e 80 00       	push   $0x803ef3
  801b6b:	e8 33 01 00 00       	call   801ca3 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801b70:	83 ec 04             	sub    $0x4,%esp
  801b73:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801b76:	52                   	push   %edx
  801b77:	6a 00                	push   $0x0
  801b79:	50                   	push   %eax
  801b7a:	e8 89 ef ff ff       	call   800b08 <file_get_block>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	85 c0                	test   %eax,%eax
  801b84:	79 12                	jns    801b98 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801b86:	50                   	push   %eax
  801b87:	68 5a 40 80 00       	push   $0x80405a
  801b8c:	6a 3c                	push   $0x3c
  801b8e:	68 f3 3e 80 00       	push   $0x803ef3
  801b93:	e8 0b 01 00 00       	call   801ca3 <_panic>
	strcpy(blk, msg);
  801b98:	83 ec 08             	sub    $0x8,%esp
  801b9b:	68 c8 40 80 00       	push   $0x8040c8
  801ba0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba3:	e8 59 07 00 00       	call   802301 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bab:	c1 e8 0c             	shr    $0xc,%eax
  801bae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	a8 40                	test   $0x40,%al
  801bba:	75 16                	jne    801bd2 <fs_test+0x362>
  801bbc:	68 c0 3f 80 00       	push   $0x803fc0
  801bc1:	68 3d 3a 80 00       	push   $0x803a3d
  801bc6:	6a 3e                	push   $0x3e
  801bc8:	68 f3 3e 80 00       	push   $0x803ef3
  801bcd:	e8 d1 00 00 00       	call   801ca3 <_panic>
	file_flush(f);
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd8:	e8 4b f4 ff ff       	call   801028 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be0:	c1 e8 0c             	shr    $0xc,%eax
  801be3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	a8 40                	test   $0x40,%al
  801bef:	74 16                	je     801c07 <fs_test+0x397>
  801bf1:	68 bf 3f 80 00       	push   $0x803fbf
  801bf6:	68 3d 3a 80 00       	push   $0x803a3d
  801bfb:	6a 40                	push   $0x40
  801bfd:	68 f3 3e 80 00       	push   $0x803ef3
  801c02:	e8 9c 00 00 00       	call   801ca3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0a:	c1 e8 0c             	shr    $0xc,%eax
  801c0d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c14:	a8 40                	test   $0x40,%al
  801c16:	74 16                	je     801c2e <fs_test+0x3be>
  801c18:	68 15 40 80 00       	push   $0x804015
  801c1d:	68 3d 3a 80 00       	push   $0x803a3d
  801c22:	6a 41                	push   $0x41
  801c24:	68 f3 3e 80 00       	push   $0x803ef3
  801c29:	e8 75 00 00 00       	call   801ca3 <_panic>
	cprintf("file rewrite is good\n");
  801c2e:	83 ec 0c             	sub    $0xc,%esp
  801c31:	68 6f 40 80 00       	push   $0x80406f
  801c36:	e8 41 01 00 00       	call   801d7c <cprintf>
}
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c4b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801c4e:	e8 73 0a 00 00       	call   8026c6 <sys_getenvid>
  801c53:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c58:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c5b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c60:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801c65:	85 db                	test   %ebx,%ebx
  801c67:	7e 07                	jle    801c70 <libmain+0x2d>
		binaryname = argv[0];
  801c69:	8b 06                	mov    (%esi),%eax
  801c6b:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801c70:	83 ec 08             	sub    $0x8,%esp
  801c73:	56                   	push   %esi
  801c74:	53                   	push   %ebx
  801c75:	e8 b0 fb ff ff       	call   80182a <umain>

	// exit gracefully
	exit();
  801c7a:	e8 0a 00 00 00       	call   801c89 <exit>
}
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801c8f:	e8 8b 0f 00 00       	call   802c1f <close_all>
	sys_env_destroy(0);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	6a 00                	push   $0x0
  801c99:	e8 e7 09 00 00       	call   802685 <sys_env_destroy>
}
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ca8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cab:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801cb1:	e8 10 0a 00 00       	call   8026c6 <sys_getenvid>
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	ff 75 0c             	pushl  0xc(%ebp)
  801cbc:	ff 75 08             	pushl  0x8(%ebp)
  801cbf:	56                   	push   %esi
  801cc0:	50                   	push   %eax
  801cc1:	68 20 41 80 00       	push   $0x804120
  801cc6:	e8 b1 00 00 00       	call   801d7c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ccb:	83 c4 18             	add    $0x18,%esp
  801cce:	53                   	push   %ebx
  801ccf:	ff 75 10             	pushl  0x10(%ebp)
  801cd2:	e8 54 00 00 00       	call   801d2b <vcprintf>
	cprintf("\n");
  801cd7:	c7 04 24 e4 3c 80 00 	movl   $0x803ce4,(%esp)
  801cde:	e8 99 00 00 00       	call   801d7c <cprintf>
  801ce3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ce6:	cc                   	int3   
  801ce7:	eb fd                	jmp    801ce6 <_panic+0x43>

00801ce9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	53                   	push   %ebx
  801ced:	83 ec 04             	sub    $0x4,%esp
  801cf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801cf3:	8b 13                	mov    (%ebx),%edx
  801cf5:	8d 42 01             	lea    0x1(%edx),%eax
  801cf8:	89 03                	mov    %eax,(%ebx)
  801cfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cfd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801d01:	3d ff 00 00 00       	cmp    $0xff,%eax
  801d06:	75 1a                	jne    801d22 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	68 ff 00 00 00       	push   $0xff
  801d10:	8d 43 08             	lea    0x8(%ebx),%eax
  801d13:	50                   	push   %eax
  801d14:	e8 2f 09 00 00       	call   802648 <sys_cputs>
		b->idx = 0;
  801d19:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d1f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801d22:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801d26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801d34:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801d3b:	00 00 00 
	b.cnt = 0;
  801d3e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801d45:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801d48:	ff 75 0c             	pushl  0xc(%ebp)
  801d4b:	ff 75 08             	pushl  0x8(%ebp)
  801d4e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801d54:	50                   	push   %eax
  801d55:	68 e9 1c 80 00       	push   $0x801ce9
  801d5a:	e8 54 01 00 00       	call   801eb3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801d5f:	83 c4 08             	add    $0x8,%esp
  801d62:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801d68:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d6e:	50                   	push   %eax
  801d6f:	e8 d4 08 00 00       	call   802648 <sys_cputs>

	return b.cnt;
}
  801d74:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d82:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801d85:	50                   	push   %eax
  801d86:	ff 75 08             	pushl  0x8(%ebp)
  801d89:	e8 9d ff ff ff       	call   801d2b <vcprintf>
	va_end(ap);

	return cnt;
}
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	57                   	push   %edi
  801d94:	56                   	push   %esi
  801d95:	53                   	push   %ebx
  801d96:	83 ec 1c             	sub    $0x1c,%esp
  801d99:	89 c7                	mov    %eax,%edi
  801d9b:	89 d6                	mov    %edx,%esi
  801d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801da0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801da6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801da9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801dac:	bb 00 00 00 00       	mov    $0x0,%ebx
  801db1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801db4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801db7:	39 d3                	cmp    %edx,%ebx
  801db9:	72 05                	jb     801dc0 <printnum+0x30>
  801dbb:	39 45 10             	cmp    %eax,0x10(%ebp)
  801dbe:	77 45                	ja     801e05 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801dc0:	83 ec 0c             	sub    $0xc,%esp
  801dc3:	ff 75 18             	pushl  0x18(%ebp)
  801dc6:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801dcc:	53                   	push   %ebx
  801dcd:	ff 75 10             	pushl  0x10(%ebp)
  801dd0:	83 ec 08             	sub    $0x8,%esp
  801dd3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dd6:	ff 75 e0             	pushl  -0x20(%ebp)
  801dd9:	ff 75 dc             	pushl  -0x24(%ebp)
  801ddc:	ff 75 d8             	pushl  -0x28(%ebp)
  801ddf:	e8 8c 19 00 00       	call   803770 <__udivdi3>
  801de4:	83 c4 18             	add    $0x18,%esp
  801de7:	52                   	push   %edx
  801de8:	50                   	push   %eax
  801de9:	89 f2                	mov    %esi,%edx
  801deb:	89 f8                	mov    %edi,%eax
  801ded:	e8 9e ff ff ff       	call   801d90 <printnum>
  801df2:	83 c4 20             	add    $0x20,%esp
  801df5:	eb 18                	jmp    801e0f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801df7:	83 ec 08             	sub    $0x8,%esp
  801dfa:	56                   	push   %esi
  801dfb:	ff 75 18             	pushl  0x18(%ebp)
  801dfe:	ff d7                	call   *%edi
  801e00:	83 c4 10             	add    $0x10,%esp
  801e03:	eb 03                	jmp    801e08 <printnum+0x78>
  801e05:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801e08:	83 eb 01             	sub    $0x1,%ebx
  801e0b:	85 db                	test   %ebx,%ebx
  801e0d:	7f e8                	jg     801df7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801e0f:	83 ec 08             	sub    $0x8,%esp
  801e12:	56                   	push   %esi
  801e13:	83 ec 04             	sub    $0x4,%esp
  801e16:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e19:	ff 75 e0             	pushl  -0x20(%ebp)
  801e1c:	ff 75 dc             	pushl  -0x24(%ebp)
  801e1f:	ff 75 d8             	pushl  -0x28(%ebp)
  801e22:	e8 79 1a 00 00       	call   8038a0 <__umoddi3>
  801e27:	83 c4 14             	add    $0x14,%esp
  801e2a:	0f be 80 43 41 80 00 	movsbl 0x804143(%eax),%eax
  801e31:	50                   	push   %eax
  801e32:	ff d7                	call   *%edi
}
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e3a:	5b                   	pop    %ebx
  801e3b:	5e                   	pop    %esi
  801e3c:	5f                   	pop    %edi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801e42:	83 fa 01             	cmp    $0x1,%edx
  801e45:	7e 0e                	jle    801e55 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801e47:	8b 10                	mov    (%eax),%edx
  801e49:	8d 4a 08             	lea    0x8(%edx),%ecx
  801e4c:	89 08                	mov    %ecx,(%eax)
  801e4e:	8b 02                	mov    (%edx),%eax
  801e50:	8b 52 04             	mov    0x4(%edx),%edx
  801e53:	eb 22                	jmp    801e77 <getuint+0x38>
	else if (lflag)
  801e55:	85 d2                	test   %edx,%edx
  801e57:	74 10                	je     801e69 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801e59:	8b 10                	mov    (%eax),%edx
  801e5b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e5e:	89 08                	mov    %ecx,(%eax)
  801e60:	8b 02                	mov    (%edx),%eax
  801e62:	ba 00 00 00 00       	mov    $0x0,%edx
  801e67:	eb 0e                	jmp    801e77 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801e69:	8b 10                	mov    (%eax),%edx
  801e6b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e6e:	89 08                	mov    %ecx,(%eax)
  801e70:	8b 02                	mov    (%edx),%eax
  801e72:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    

00801e79 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801e7f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801e83:	8b 10                	mov    (%eax),%edx
  801e85:	3b 50 04             	cmp    0x4(%eax),%edx
  801e88:	73 0a                	jae    801e94 <sprintputch+0x1b>
		*b->buf++ = ch;
  801e8a:	8d 4a 01             	lea    0x1(%edx),%ecx
  801e8d:	89 08                	mov    %ecx,(%eax)
  801e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e92:	88 02                	mov    %al,(%edx)
}
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801e9c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801e9f:	50                   	push   %eax
  801ea0:	ff 75 10             	pushl  0x10(%ebp)
  801ea3:	ff 75 0c             	pushl  0xc(%ebp)
  801ea6:	ff 75 08             	pushl  0x8(%ebp)
  801ea9:	e8 05 00 00 00       	call   801eb3 <vprintfmt>
	va_end(ap);
}
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	c9                   	leave  
  801eb2:	c3                   	ret    

00801eb3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	57                   	push   %edi
  801eb7:	56                   	push   %esi
  801eb8:	53                   	push   %ebx
  801eb9:	83 ec 2c             	sub    $0x2c,%esp
  801ebc:	8b 75 08             	mov    0x8(%ebp),%esi
  801ebf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ec2:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ec5:	eb 12                	jmp    801ed9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	0f 84 89 03 00 00    	je     802258 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801ecf:	83 ec 08             	sub    $0x8,%esp
  801ed2:	53                   	push   %ebx
  801ed3:	50                   	push   %eax
  801ed4:	ff d6                	call   *%esi
  801ed6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ed9:	83 c7 01             	add    $0x1,%edi
  801edc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ee0:	83 f8 25             	cmp    $0x25,%eax
  801ee3:	75 e2                	jne    801ec7 <vprintfmt+0x14>
  801ee5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801ee9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801ef0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801ef7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801efe:	ba 00 00 00 00       	mov    $0x0,%edx
  801f03:	eb 07                	jmp    801f0c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f05:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801f08:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f0c:	8d 47 01             	lea    0x1(%edi),%eax
  801f0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f12:	0f b6 07             	movzbl (%edi),%eax
  801f15:	0f b6 c8             	movzbl %al,%ecx
  801f18:	83 e8 23             	sub    $0x23,%eax
  801f1b:	3c 55                	cmp    $0x55,%al
  801f1d:	0f 87 1a 03 00 00    	ja     80223d <vprintfmt+0x38a>
  801f23:	0f b6 c0             	movzbl %al,%eax
  801f26:	ff 24 85 80 42 80 00 	jmp    *0x804280(,%eax,4)
  801f2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801f30:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801f34:	eb d6                	jmp    801f0c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801f41:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801f44:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801f48:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801f4b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801f4e:	83 fa 09             	cmp    $0x9,%edx
  801f51:	77 39                	ja     801f8c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801f53:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801f56:	eb e9                	jmp    801f41 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801f58:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5b:	8d 48 04             	lea    0x4(%eax),%ecx
  801f5e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801f61:	8b 00                	mov    (%eax),%eax
  801f63:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801f69:	eb 27                	jmp    801f92 <vprintfmt+0xdf>
  801f6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f75:	0f 49 c8             	cmovns %eax,%ecx
  801f78:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f7e:	eb 8c                	jmp    801f0c <vprintfmt+0x59>
  801f80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801f83:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801f8a:	eb 80                	jmp    801f0c <vprintfmt+0x59>
  801f8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801f8f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801f92:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801f96:	0f 89 70 ff ff ff    	jns    801f0c <vprintfmt+0x59>
				width = precision, precision = -1;
  801f9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801f9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fa2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801fa9:	e9 5e ff ff ff       	jmp    801f0c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801fae:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fb1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801fb4:	e9 53 ff ff ff       	jmp    801f0c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801fb9:	8b 45 14             	mov    0x14(%ebp),%eax
  801fbc:	8d 50 04             	lea    0x4(%eax),%edx
  801fbf:	89 55 14             	mov    %edx,0x14(%ebp)
  801fc2:	83 ec 08             	sub    $0x8,%esp
  801fc5:	53                   	push   %ebx
  801fc6:	ff 30                	pushl  (%eax)
  801fc8:	ff d6                	call   *%esi
			break;
  801fca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fcd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801fd0:	e9 04 ff ff ff       	jmp    801ed9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801fd5:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd8:	8d 50 04             	lea    0x4(%eax),%edx
  801fdb:	89 55 14             	mov    %edx,0x14(%ebp)
  801fde:	8b 00                	mov    (%eax),%eax
  801fe0:	99                   	cltd   
  801fe1:	31 d0                	xor    %edx,%eax
  801fe3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801fe5:	83 f8 0f             	cmp    $0xf,%eax
  801fe8:	7f 0b                	jg     801ff5 <vprintfmt+0x142>
  801fea:	8b 14 85 e0 43 80 00 	mov    0x8043e0(,%eax,4),%edx
  801ff1:	85 d2                	test   %edx,%edx
  801ff3:	75 18                	jne    80200d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801ff5:	50                   	push   %eax
  801ff6:	68 5b 41 80 00       	push   $0x80415b
  801ffb:	53                   	push   %ebx
  801ffc:	56                   	push   %esi
  801ffd:	e8 94 fe ff ff       	call   801e96 <printfmt>
  802002:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802005:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  802008:	e9 cc fe ff ff       	jmp    801ed9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80200d:	52                   	push   %edx
  80200e:	68 4f 3a 80 00       	push   $0x803a4f
  802013:	53                   	push   %ebx
  802014:	56                   	push   %esi
  802015:	e8 7c fe ff ff       	call   801e96 <printfmt>
  80201a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80201d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802020:	e9 b4 fe ff ff       	jmp    801ed9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  802025:	8b 45 14             	mov    0x14(%ebp),%eax
  802028:	8d 50 04             	lea    0x4(%eax),%edx
  80202b:	89 55 14             	mov    %edx,0x14(%ebp)
  80202e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  802030:	85 ff                	test   %edi,%edi
  802032:	b8 54 41 80 00       	mov    $0x804154,%eax
  802037:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80203a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80203e:	0f 8e 94 00 00 00    	jle    8020d8 <vprintfmt+0x225>
  802044:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  802048:	0f 84 98 00 00 00    	je     8020e6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80204e:	83 ec 08             	sub    $0x8,%esp
  802051:	ff 75 d0             	pushl  -0x30(%ebp)
  802054:	57                   	push   %edi
  802055:	e8 86 02 00 00       	call   8022e0 <strnlen>
  80205a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80205d:	29 c1                	sub    %eax,%ecx
  80205f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  802062:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  802065:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  802069:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80206c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80206f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802071:	eb 0f                	jmp    802082 <vprintfmt+0x1cf>
					putch(padc, putdat);
  802073:	83 ec 08             	sub    $0x8,%esp
  802076:	53                   	push   %ebx
  802077:	ff 75 e0             	pushl  -0x20(%ebp)
  80207a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80207c:	83 ef 01             	sub    $0x1,%edi
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	85 ff                	test   %edi,%edi
  802084:	7f ed                	jg     802073 <vprintfmt+0x1c0>
  802086:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  802089:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80208c:	85 c9                	test   %ecx,%ecx
  80208e:	b8 00 00 00 00       	mov    $0x0,%eax
  802093:	0f 49 c1             	cmovns %ecx,%eax
  802096:	29 c1                	sub    %eax,%ecx
  802098:	89 75 08             	mov    %esi,0x8(%ebp)
  80209b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80209e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8020a1:	89 cb                	mov    %ecx,%ebx
  8020a3:	eb 4d                	jmp    8020f2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8020a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8020a9:	74 1b                	je     8020c6 <vprintfmt+0x213>
  8020ab:	0f be c0             	movsbl %al,%eax
  8020ae:	83 e8 20             	sub    $0x20,%eax
  8020b1:	83 f8 5e             	cmp    $0x5e,%eax
  8020b4:	76 10                	jbe    8020c6 <vprintfmt+0x213>
					putch('?', putdat);
  8020b6:	83 ec 08             	sub    $0x8,%esp
  8020b9:	ff 75 0c             	pushl  0xc(%ebp)
  8020bc:	6a 3f                	push   $0x3f
  8020be:	ff 55 08             	call   *0x8(%ebp)
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	eb 0d                	jmp    8020d3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8020c6:	83 ec 08             	sub    $0x8,%esp
  8020c9:	ff 75 0c             	pushl  0xc(%ebp)
  8020cc:	52                   	push   %edx
  8020cd:	ff 55 08             	call   *0x8(%ebp)
  8020d0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8020d3:	83 eb 01             	sub    $0x1,%ebx
  8020d6:	eb 1a                	jmp    8020f2 <vprintfmt+0x23f>
  8020d8:	89 75 08             	mov    %esi,0x8(%ebp)
  8020db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8020de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8020e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8020e4:	eb 0c                	jmp    8020f2 <vprintfmt+0x23f>
  8020e6:	89 75 08             	mov    %esi,0x8(%ebp)
  8020e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8020ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8020ef:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8020f2:	83 c7 01             	add    $0x1,%edi
  8020f5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8020f9:	0f be d0             	movsbl %al,%edx
  8020fc:	85 d2                	test   %edx,%edx
  8020fe:	74 23                	je     802123 <vprintfmt+0x270>
  802100:	85 f6                	test   %esi,%esi
  802102:	78 a1                	js     8020a5 <vprintfmt+0x1f2>
  802104:	83 ee 01             	sub    $0x1,%esi
  802107:	79 9c                	jns    8020a5 <vprintfmt+0x1f2>
  802109:	89 df                	mov    %ebx,%edi
  80210b:	8b 75 08             	mov    0x8(%ebp),%esi
  80210e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802111:	eb 18                	jmp    80212b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  802113:	83 ec 08             	sub    $0x8,%esp
  802116:	53                   	push   %ebx
  802117:	6a 20                	push   $0x20
  802119:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80211b:	83 ef 01             	sub    $0x1,%edi
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	eb 08                	jmp    80212b <vprintfmt+0x278>
  802123:	89 df                	mov    %ebx,%edi
  802125:	8b 75 08             	mov    0x8(%ebp),%esi
  802128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80212b:	85 ff                	test   %edi,%edi
  80212d:	7f e4                	jg     802113 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80212f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802132:	e9 a2 fd ff ff       	jmp    801ed9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  802137:	83 fa 01             	cmp    $0x1,%edx
  80213a:	7e 16                	jle    802152 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80213c:	8b 45 14             	mov    0x14(%ebp),%eax
  80213f:	8d 50 08             	lea    0x8(%eax),%edx
  802142:	89 55 14             	mov    %edx,0x14(%ebp)
  802145:	8b 50 04             	mov    0x4(%eax),%edx
  802148:	8b 00                	mov    (%eax),%eax
  80214a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80214d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  802150:	eb 32                	jmp    802184 <vprintfmt+0x2d1>
	else if (lflag)
  802152:	85 d2                	test   %edx,%edx
  802154:	74 18                	je     80216e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  802156:	8b 45 14             	mov    0x14(%ebp),%eax
  802159:	8d 50 04             	lea    0x4(%eax),%edx
  80215c:	89 55 14             	mov    %edx,0x14(%ebp)
  80215f:	8b 00                	mov    (%eax),%eax
  802161:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802164:	89 c1                	mov    %eax,%ecx
  802166:	c1 f9 1f             	sar    $0x1f,%ecx
  802169:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80216c:	eb 16                	jmp    802184 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80216e:	8b 45 14             	mov    0x14(%ebp),%eax
  802171:	8d 50 04             	lea    0x4(%eax),%edx
  802174:	89 55 14             	mov    %edx,0x14(%ebp)
  802177:	8b 00                	mov    (%eax),%eax
  802179:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80217c:	89 c1                	mov    %eax,%ecx
  80217e:	c1 f9 1f             	sar    $0x1f,%ecx
  802181:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  802184:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802187:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80218a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80218f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  802193:	79 74                	jns    802209 <vprintfmt+0x356>
				putch('-', putdat);
  802195:	83 ec 08             	sub    $0x8,%esp
  802198:	53                   	push   %ebx
  802199:	6a 2d                	push   $0x2d
  80219b:	ff d6                	call   *%esi
				num = -(long long) num;
  80219d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8021a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8021a3:	f7 d8                	neg    %eax
  8021a5:	83 d2 00             	adc    $0x0,%edx
  8021a8:	f7 da                	neg    %edx
  8021aa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8021ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8021b2:	eb 55                	jmp    802209 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8021b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8021b7:	e8 83 fc ff ff       	call   801e3f <getuint>
			base = 10;
  8021bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8021c1:	eb 46                	jmp    802209 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8021c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8021c6:	e8 74 fc ff ff       	call   801e3f <getuint>
			base = 8;
  8021cb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8021d0:	eb 37                	jmp    802209 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8021d2:	83 ec 08             	sub    $0x8,%esp
  8021d5:	53                   	push   %ebx
  8021d6:	6a 30                	push   $0x30
  8021d8:	ff d6                	call   *%esi
			putch('x', putdat);
  8021da:	83 c4 08             	add    $0x8,%esp
  8021dd:	53                   	push   %ebx
  8021de:	6a 78                	push   $0x78
  8021e0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8021e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e5:	8d 50 04             	lea    0x4(%eax),%edx
  8021e8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8021eb:	8b 00                	mov    (%eax),%eax
  8021ed:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8021f2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8021f5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8021fa:	eb 0d                	jmp    802209 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8021fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8021ff:	e8 3b fc ff ff       	call   801e3f <getuint>
			base = 16;
  802204:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  802209:	83 ec 0c             	sub    $0xc,%esp
  80220c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802210:	57                   	push   %edi
  802211:	ff 75 e0             	pushl  -0x20(%ebp)
  802214:	51                   	push   %ecx
  802215:	52                   	push   %edx
  802216:	50                   	push   %eax
  802217:	89 da                	mov    %ebx,%edx
  802219:	89 f0                	mov    %esi,%eax
  80221b:	e8 70 fb ff ff       	call   801d90 <printnum>
			break;
  802220:	83 c4 20             	add    $0x20,%esp
  802223:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802226:	e9 ae fc ff ff       	jmp    801ed9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80222b:	83 ec 08             	sub    $0x8,%esp
  80222e:	53                   	push   %ebx
  80222f:	51                   	push   %ecx
  802230:	ff d6                	call   *%esi
			break;
  802232:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802235:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  802238:	e9 9c fc ff ff       	jmp    801ed9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80223d:	83 ec 08             	sub    $0x8,%esp
  802240:	53                   	push   %ebx
  802241:	6a 25                	push   $0x25
  802243:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	eb 03                	jmp    80224d <vprintfmt+0x39a>
  80224a:	83 ef 01             	sub    $0x1,%edi
  80224d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802251:	75 f7                	jne    80224a <vprintfmt+0x397>
  802253:	e9 81 fc ff ff       	jmp    801ed9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  802258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80225b:	5b                   	pop    %ebx
  80225c:	5e                   	pop    %esi
  80225d:	5f                   	pop    %edi
  80225e:	5d                   	pop    %ebp
  80225f:	c3                   	ret    

00802260 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	83 ec 18             	sub    $0x18,%esp
  802266:	8b 45 08             	mov    0x8(%ebp),%eax
  802269:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80226c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80226f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802273:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802276:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80227d:	85 c0                	test   %eax,%eax
  80227f:	74 26                	je     8022a7 <vsnprintf+0x47>
  802281:	85 d2                	test   %edx,%edx
  802283:	7e 22                	jle    8022a7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802285:	ff 75 14             	pushl  0x14(%ebp)
  802288:	ff 75 10             	pushl  0x10(%ebp)
  80228b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80228e:	50                   	push   %eax
  80228f:	68 79 1e 80 00       	push   $0x801e79
  802294:	e8 1a fc ff ff       	call   801eb3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802299:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80229c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80229f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a2:	83 c4 10             	add    $0x10,%esp
  8022a5:	eb 05                	jmp    8022ac <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8022a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8022ac:	c9                   	leave  
  8022ad:	c3                   	ret    

008022ae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8022b4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8022b7:	50                   	push   %eax
  8022b8:	ff 75 10             	pushl  0x10(%ebp)
  8022bb:	ff 75 0c             	pushl  0xc(%ebp)
  8022be:	ff 75 08             	pushl  0x8(%ebp)
  8022c1:	e8 9a ff ff ff       	call   802260 <vsnprintf>
	va_end(ap);

	return rc;
}
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8022ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d3:	eb 03                	jmp    8022d8 <strlen+0x10>
		n++;
  8022d5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8022d8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8022dc:	75 f7                	jne    8022d5 <strlen+0xd>
		n++;
	return n;
}
  8022de:	5d                   	pop    %ebp
  8022df:	c3                   	ret    

008022e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
  8022e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8022e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ee:	eb 03                	jmp    8022f3 <strnlen+0x13>
		n++;
  8022f0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8022f3:	39 c2                	cmp    %eax,%edx
  8022f5:	74 08                	je     8022ff <strnlen+0x1f>
  8022f7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8022fb:	75 f3                	jne    8022f0 <strnlen+0x10>
  8022fd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8022ff:	5d                   	pop    %ebp
  802300:	c3                   	ret    

00802301 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802301:	55                   	push   %ebp
  802302:	89 e5                	mov    %esp,%ebp
  802304:	53                   	push   %ebx
  802305:	8b 45 08             	mov    0x8(%ebp),%eax
  802308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80230b:	89 c2                	mov    %eax,%edx
  80230d:	83 c2 01             	add    $0x1,%edx
  802310:	83 c1 01             	add    $0x1,%ecx
  802313:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  802317:	88 5a ff             	mov    %bl,-0x1(%edx)
  80231a:	84 db                	test   %bl,%bl
  80231c:	75 ef                	jne    80230d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80231e:	5b                   	pop    %ebx
  80231f:	5d                   	pop    %ebp
  802320:	c3                   	ret    

00802321 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802321:	55                   	push   %ebp
  802322:	89 e5                	mov    %esp,%ebp
  802324:	53                   	push   %ebx
  802325:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802328:	53                   	push   %ebx
  802329:	e8 9a ff ff ff       	call   8022c8 <strlen>
  80232e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802331:	ff 75 0c             	pushl  0xc(%ebp)
  802334:	01 d8                	add    %ebx,%eax
  802336:	50                   	push   %eax
  802337:	e8 c5 ff ff ff       	call   802301 <strcpy>
	return dst;
}
  80233c:	89 d8                	mov    %ebx,%eax
  80233e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802341:	c9                   	leave  
  802342:	c3                   	ret    

00802343 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802343:	55                   	push   %ebp
  802344:	89 e5                	mov    %esp,%ebp
  802346:	56                   	push   %esi
  802347:	53                   	push   %ebx
  802348:	8b 75 08             	mov    0x8(%ebp),%esi
  80234b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80234e:	89 f3                	mov    %esi,%ebx
  802350:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802353:	89 f2                	mov    %esi,%edx
  802355:	eb 0f                	jmp    802366 <strncpy+0x23>
		*dst++ = *src;
  802357:	83 c2 01             	add    $0x1,%edx
  80235a:	0f b6 01             	movzbl (%ecx),%eax
  80235d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802360:	80 39 01             	cmpb   $0x1,(%ecx)
  802363:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802366:	39 da                	cmp    %ebx,%edx
  802368:	75 ed                	jne    802357 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80236a:	89 f0                	mov    %esi,%eax
  80236c:	5b                   	pop    %ebx
  80236d:	5e                   	pop    %esi
  80236e:	5d                   	pop    %ebp
  80236f:	c3                   	ret    

00802370 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	56                   	push   %esi
  802374:	53                   	push   %ebx
  802375:	8b 75 08             	mov    0x8(%ebp),%esi
  802378:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80237b:	8b 55 10             	mov    0x10(%ebp),%edx
  80237e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802380:	85 d2                	test   %edx,%edx
  802382:	74 21                	je     8023a5 <strlcpy+0x35>
  802384:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802388:	89 f2                	mov    %esi,%edx
  80238a:	eb 09                	jmp    802395 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80238c:	83 c2 01             	add    $0x1,%edx
  80238f:	83 c1 01             	add    $0x1,%ecx
  802392:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802395:	39 c2                	cmp    %eax,%edx
  802397:	74 09                	je     8023a2 <strlcpy+0x32>
  802399:	0f b6 19             	movzbl (%ecx),%ebx
  80239c:	84 db                	test   %bl,%bl
  80239e:	75 ec                	jne    80238c <strlcpy+0x1c>
  8023a0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8023a2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8023a5:	29 f0                	sub    %esi,%eax
}
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    

008023ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8023b4:	eb 06                	jmp    8023bc <strcmp+0x11>
		p++, q++;
  8023b6:	83 c1 01             	add    $0x1,%ecx
  8023b9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8023bc:	0f b6 01             	movzbl (%ecx),%eax
  8023bf:	84 c0                	test   %al,%al
  8023c1:	74 04                	je     8023c7 <strcmp+0x1c>
  8023c3:	3a 02                	cmp    (%edx),%al
  8023c5:	74 ef                	je     8023b6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8023c7:	0f b6 c0             	movzbl %al,%eax
  8023ca:	0f b6 12             	movzbl (%edx),%edx
  8023cd:	29 d0                	sub    %edx,%eax
}
  8023cf:	5d                   	pop    %ebp
  8023d0:	c3                   	ret    

008023d1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8023d1:	55                   	push   %ebp
  8023d2:	89 e5                	mov    %esp,%ebp
  8023d4:	53                   	push   %ebx
  8023d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023db:	89 c3                	mov    %eax,%ebx
  8023dd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8023e0:	eb 06                	jmp    8023e8 <strncmp+0x17>
		n--, p++, q++;
  8023e2:	83 c0 01             	add    $0x1,%eax
  8023e5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8023e8:	39 d8                	cmp    %ebx,%eax
  8023ea:	74 15                	je     802401 <strncmp+0x30>
  8023ec:	0f b6 08             	movzbl (%eax),%ecx
  8023ef:	84 c9                	test   %cl,%cl
  8023f1:	74 04                	je     8023f7 <strncmp+0x26>
  8023f3:	3a 0a                	cmp    (%edx),%cl
  8023f5:	74 eb                	je     8023e2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8023f7:	0f b6 00             	movzbl (%eax),%eax
  8023fa:	0f b6 12             	movzbl (%edx),%edx
  8023fd:	29 d0                	sub    %edx,%eax
  8023ff:	eb 05                	jmp    802406 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802401:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802406:	5b                   	pop    %ebx
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    

00802409 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	8b 45 08             	mov    0x8(%ebp),%eax
  80240f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802413:	eb 07                	jmp    80241c <strchr+0x13>
		if (*s == c)
  802415:	38 ca                	cmp    %cl,%dl
  802417:	74 0f                	je     802428 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802419:	83 c0 01             	add    $0x1,%eax
  80241c:	0f b6 10             	movzbl (%eax),%edx
  80241f:	84 d2                	test   %dl,%dl
  802421:	75 f2                	jne    802415 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802423:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802428:	5d                   	pop    %ebp
  802429:	c3                   	ret    

0080242a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80242a:	55                   	push   %ebp
  80242b:	89 e5                	mov    %esp,%ebp
  80242d:	8b 45 08             	mov    0x8(%ebp),%eax
  802430:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802434:	eb 03                	jmp    802439 <strfind+0xf>
  802436:	83 c0 01             	add    $0x1,%eax
  802439:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80243c:	38 ca                	cmp    %cl,%dl
  80243e:	74 04                	je     802444 <strfind+0x1a>
  802440:	84 d2                	test   %dl,%dl
  802442:	75 f2                	jne    802436 <strfind+0xc>
			break;
	return (char *) s;
}
  802444:	5d                   	pop    %ebp
  802445:	c3                   	ret    

00802446 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802446:	55                   	push   %ebp
  802447:	89 e5                	mov    %esp,%ebp
  802449:	57                   	push   %edi
  80244a:	56                   	push   %esi
  80244b:	53                   	push   %ebx
  80244c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80244f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802452:	85 c9                	test   %ecx,%ecx
  802454:	74 36                	je     80248c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802456:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80245c:	75 28                	jne    802486 <memset+0x40>
  80245e:	f6 c1 03             	test   $0x3,%cl
  802461:	75 23                	jne    802486 <memset+0x40>
		c &= 0xFF;
  802463:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802467:	89 d3                	mov    %edx,%ebx
  802469:	c1 e3 08             	shl    $0x8,%ebx
  80246c:	89 d6                	mov    %edx,%esi
  80246e:	c1 e6 18             	shl    $0x18,%esi
  802471:	89 d0                	mov    %edx,%eax
  802473:	c1 e0 10             	shl    $0x10,%eax
  802476:	09 f0                	or     %esi,%eax
  802478:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80247a:	89 d8                	mov    %ebx,%eax
  80247c:	09 d0                	or     %edx,%eax
  80247e:	c1 e9 02             	shr    $0x2,%ecx
  802481:	fc                   	cld    
  802482:	f3 ab                	rep stos %eax,%es:(%edi)
  802484:	eb 06                	jmp    80248c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802486:	8b 45 0c             	mov    0xc(%ebp),%eax
  802489:	fc                   	cld    
  80248a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80248c:	89 f8                	mov    %edi,%eax
  80248e:	5b                   	pop    %ebx
  80248f:	5e                   	pop    %esi
  802490:	5f                   	pop    %edi
  802491:	5d                   	pop    %ebp
  802492:	c3                   	ret    

00802493 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802493:	55                   	push   %ebp
  802494:	89 e5                	mov    %esp,%ebp
  802496:	57                   	push   %edi
  802497:	56                   	push   %esi
  802498:	8b 45 08             	mov    0x8(%ebp),%eax
  80249b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80249e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8024a1:	39 c6                	cmp    %eax,%esi
  8024a3:	73 35                	jae    8024da <memmove+0x47>
  8024a5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8024a8:	39 d0                	cmp    %edx,%eax
  8024aa:	73 2e                	jae    8024da <memmove+0x47>
		s += n;
		d += n;
  8024ac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024af:	89 d6                	mov    %edx,%esi
  8024b1:	09 fe                	or     %edi,%esi
  8024b3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8024b9:	75 13                	jne    8024ce <memmove+0x3b>
  8024bb:	f6 c1 03             	test   $0x3,%cl
  8024be:	75 0e                	jne    8024ce <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8024c0:	83 ef 04             	sub    $0x4,%edi
  8024c3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8024c6:	c1 e9 02             	shr    $0x2,%ecx
  8024c9:	fd                   	std    
  8024ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8024cc:	eb 09                	jmp    8024d7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8024ce:	83 ef 01             	sub    $0x1,%edi
  8024d1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8024d4:	fd                   	std    
  8024d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8024d7:	fc                   	cld    
  8024d8:	eb 1d                	jmp    8024f7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024da:	89 f2                	mov    %esi,%edx
  8024dc:	09 c2                	or     %eax,%edx
  8024de:	f6 c2 03             	test   $0x3,%dl
  8024e1:	75 0f                	jne    8024f2 <memmove+0x5f>
  8024e3:	f6 c1 03             	test   $0x3,%cl
  8024e6:	75 0a                	jne    8024f2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8024e8:	c1 e9 02             	shr    $0x2,%ecx
  8024eb:	89 c7                	mov    %eax,%edi
  8024ed:	fc                   	cld    
  8024ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8024f0:	eb 05                	jmp    8024f7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8024f2:	89 c7                	mov    %eax,%edi
  8024f4:	fc                   	cld    
  8024f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8024f7:	5e                   	pop    %esi
  8024f8:	5f                   	pop    %edi
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    

008024fb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8024fb:	55                   	push   %ebp
  8024fc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8024fe:	ff 75 10             	pushl  0x10(%ebp)
  802501:	ff 75 0c             	pushl  0xc(%ebp)
  802504:	ff 75 08             	pushl  0x8(%ebp)
  802507:	e8 87 ff ff ff       	call   802493 <memmove>
}
  80250c:	c9                   	leave  
  80250d:	c3                   	ret    

0080250e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	56                   	push   %esi
  802512:	53                   	push   %ebx
  802513:	8b 45 08             	mov    0x8(%ebp),%eax
  802516:	8b 55 0c             	mov    0xc(%ebp),%edx
  802519:	89 c6                	mov    %eax,%esi
  80251b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80251e:	eb 1a                	jmp    80253a <memcmp+0x2c>
		if (*s1 != *s2)
  802520:	0f b6 08             	movzbl (%eax),%ecx
  802523:	0f b6 1a             	movzbl (%edx),%ebx
  802526:	38 d9                	cmp    %bl,%cl
  802528:	74 0a                	je     802534 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80252a:	0f b6 c1             	movzbl %cl,%eax
  80252d:	0f b6 db             	movzbl %bl,%ebx
  802530:	29 d8                	sub    %ebx,%eax
  802532:	eb 0f                	jmp    802543 <memcmp+0x35>
		s1++, s2++;
  802534:	83 c0 01             	add    $0x1,%eax
  802537:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80253a:	39 f0                	cmp    %esi,%eax
  80253c:	75 e2                	jne    802520 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80253e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802543:	5b                   	pop    %ebx
  802544:	5e                   	pop    %esi
  802545:	5d                   	pop    %ebp
  802546:	c3                   	ret    

00802547 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802547:	55                   	push   %ebp
  802548:	89 e5                	mov    %esp,%ebp
  80254a:	53                   	push   %ebx
  80254b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80254e:	89 c1                	mov    %eax,%ecx
  802550:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802553:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802557:	eb 0a                	jmp    802563 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802559:	0f b6 10             	movzbl (%eax),%edx
  80255c:	39 da                	cmp    %ebx,%edx
  80255e:	74 07                	je     802567 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802560:	83 c0 01             	add    $0x1,%eax
  802563:	39 c8                	cmp    %ecx,%eax
  802565:	72 f2                	jb     802559 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802567:	5b                   	pop    %ebx
  802568:	5d                   	pop    %ebp
  802569:	c3                   	ret    

0080256a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	57                   	push   %edi
  80256e:	56                   	push   %esi
  80256f:	53                   	push   %ebx
  802570:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802573:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802576:	eb 03                	jmp    80257b <strtol+0x11>
		s++;
  802578:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80257b:	0f b6 01             	movzbl (%ecx),%eax
  80257e:	3c 20                	cmp    $0x20,%al
  802580:	74 f6                	je     802578 <strtol+0xe>
  802582:	3c 09                	cmp    $0x9,%al
  802584:	74 f2                	je     802578 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802586:	3c 2b                	cmp    $0x2b,%al
  802588:	75 0a                	jne    802594 <strtol+0x2a>
		s++;
  80258a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80258d:	bf 00 00 00 00       	mov    $0x0,%edi
  802592:	eb 11                	jmp    8025a5 <strtol+0x3b>
  802594:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802599:	3c 2d                	cmp    $0x2d,%al
  80259b:	75 08                	jne    8025a5 <strtol+0x3b>
		s++, neg = 1;
  80259d:	83 c1 01             	add    $0x1,%ecx
  8025a0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8025a5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8025ab:	75 15                	jne    8025c2 <strtol+0x58>
  8025ad:	80 39 30             	cmpb   $0x30,(%ecx)
  8025b0:	75 10                	jne    8025c2 <strtol+0x58>
  8025b2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8025b6:	75 7c                	jne    802634 <strtol+0xca>
		s += 2, base = 16;
  8025b8:	83 c1 02             	add    $0x2,%ecx
  8025bb:	bb 10 00 00 00       	mov    $0x10,%ebx
  8025c0:	eb 16                	jmp    8025d8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8025c2:	85 db                	test   %ebx,%ebx
  8025c4:	75 12                	jne    8025d8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8025c6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8025cb:	80 39 30             	cmpb   $0x30,(%ecx)
  8025ce:	75 08                	jne    8025d8 <strtol+0x6e>
		s++, base = 8;
  8025d0:	83 c1 01             	add    $0x1,%ecx
  8025d3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8025d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8025dd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8025e0:	0f b6 11             	movzbl (%ecx),%edx
  8025e3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8025e6:	89 f3                	mov    %esi,%ebx
  8025e8:	80 fb 09             	cmp    $0x9,%bl
  8025eb:	77 08                	ja     8025f5 <strtol+0x8b>
			dig = *s - '0';
  8025ed:	0f be d2             	movsbl %dl,%edx
  8025f0:	83 ea 30             	sub    $0x30,%edx
  8025f3:	eb 22                	jmp    802617 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8025f5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8025f8:	89 f3                	mov    %esi,%ebx
  8025fa:	80 fb 19             	cmp    $0x19,%bl
  8025fd:	77 08                	ja     802607 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8025ff:	0f be d2             	movsbl %dl,%edx
  802602:	83 ea 57             	sub    $0x57,%edx
  802605:	eb 10                	jmp    802617 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802607:	8d 72 bf             	lea    -0x41(%edx),%esi
  80260a:	89 f3                	mov    %esi,%ebx
  80260c:	80 fb 19             	cmp    $0x19,%bl
  80260f:	77 16                	ja     802627 <strtol+0xbd>
			dig = *s - 'A' + 10;
  802611:	0f be d2             	movsbl %dl,%edx
  802614:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  802617:	3b 55 10             	cmp    0x10(%ebp),%edx
  80261a:	7d 0b                	jge    802627 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80261c:	83 c1 01             	add    $0x1,%ecx
  80261f:	0f af 45 10          	imul   0x10(%ebp),%eax
  802623:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802625:	eb b9                	jmp    8025e0 <strtol+0x76>

	if (endptr)
  802627:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80262b:	74 0d                	je     80263a <strtol+0xd0>
		*endptr = (char *) s;
  80262d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802630:	89 0e                	mov    %ecx,(%esi)
  802632:	eb 06                	jmp    80263a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802634:	85 db                	test   %ebx,%ebx
  802636:	74 98                	je     8025d0 <strtol+0x66>
  802638:	eb 9e                	jmp    8025d8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80263a:	89 c2                	mov    %eax,%edx
  80263c:	f7 da                	neg    %edx
  80263e:	85 ff                	test   %edi,%edi
  802640:	0f 45 c2             	cmovne %edx,%eax
}
  802643:	5b                   	pop    %ebx
  802644:	5e                   	pop    %esi
  802645:	5f                   	pop    %edi
  802646:	5d                   	pop    %ebp
  802647:	c3                   	ret    

00802648 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802648:	55                   	push   %ebp
  802649:	89 e5                	mov    %esp,%ebp
  80264b:	57                   	push   %edi
  80264c:	56                   	push   %esi
  80264d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80264e:	b8 00 00 00 00       	mov    $0x0,%eax
  802653:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802656:	8b 55 08             	mov    0x8(%ebp),%edx
  802659:	89 c3                	mov    %eax,%ebx
  80265b:	89 c7                	mov    %eax,%edi
  80265d:	89 c6                	mov    %eax,%esi
  80265f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802661:	5b                   	pop    %ebx
  802662:	5e                   	pop    %esi
  802663:	5f                   	pop    %edi
  802664:	5d                   	pop    %ebp
  802665:	c3                   	ret    

00802666 <sys_cgetc>:

int
sys_cgetc(void)
{
  802666:	55                   	push   %ebp
  802667:	89 e5                	mov    %esp,%ebp
  802669:	57                   	push   %edi
  80266a:	56                   	push   %esi
  80266b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80266c:	ba 00 00 00 00       	mov    $0x0,%edx
  802671:	b8 01 00 00 00       	mov    $0x1,%eax
  802676:	89 d1                	mov    %edx,%ecx
  802678:	89 d3                	mov    %edx,%ebx
  80267a:	89 d7                	mov    %edx,%edi
  80267c:	89 d6                	mov    %edx,%esi
  80267e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802680:	5b                   	pop    %ebx
  802681:	5e                   	pop    %esi
  802682:	5f                   	pop    %edi
  802683:	5d                   	pop    %ebp
  802684:	c3                   	ret    

00802685 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802685:	55                   	push   %ebp
  802686:	89 e5                	mov    %esp,%ebp
  802688:	57                   	push   %edi
  802689:	56                   	push   %esi
  80268a:	53                   	push   %ebx
  80268b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80268e:	b9 00 00 00 00       	mov    $0x0,%ecx
  802693:	b8 03 00 00 00       	mov    $0x3,%eax
  802698:	8b 55 08             	mov    0x8(%ebp),%edx
  80269b:	89 cb                	mov    %ecx,%ebx
  80269d:	89 cf                	mov    %ecx,%edi
  80269f:	89 ce                	mov    %ecx,%esi
  8026a1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026a3:	85 c0                	test   %eax,%eax
  8026a5:	7e 17                	jle    8026be <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026a7:	83 ec 0c             	sub    $0xc,%esp
  8026aa:	50                   	push   %eax
  8026ab:	6a 03                	push   $0x3
  8026ad:	68 3f 44 80 00       	push   $0x80443f
  8026b2:	6a 23                	push   $0x23
  8026b4:	68 5c 44 80 00       	push   $0x80445c
  8026b9:	e8 e5 f5 ff ff       	call   801ca3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8026be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026c1:	5b                   	pop    %ebx
  8026c2:	5e                   	pop    %esi
  8026c3:	5f                   	pop    %edi
  8026c4:	5d                   	pop    %ebp
  8026c5:	c3                   	ret    

008026c6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8026c6:	55                   	push   %ebp
  8026c7:	89 e5                	mov    %esp,%ebp
  8026c9:	57                   	push   %edi
  8026ca:	56                   	push   %esi
  8026cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8026d1:	b8 02 00 00 00       	mov    $0x2,%eax
  8026d6:	89 d1                	mov    %edx,%ecx
  8026d8:	89 d3                	mov    %edx,%ebx
  8026da:	89 d7                	mov    %edx,%edi
  8026dc:	89 d6                	mov    %edx,%esi
  8026de:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8026e0:	5b                   	pop    %ebx
  8026e1:	5e                   	pop    %esi
  8026e2:	5f                   	pop    %edi
  8026e3:	5d                   	pop    %ebp
  8026e4:	c3                   	ret    

008026e5 <sys_yield>:

void
sys_yield(void)
{
  8026e5:	55                   	push   %ebp
  8026e6:	89 e5                	mov    %esp,%ebp
  8026e8:	57                   	push   %edi
  8026e9:	56                   	push   %esi
  8026ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8026f0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8026f5:	89 d1                	mov    %edx,%ecx
  8026f7:	89 d3                	mov    %edx,%ebx
  8026f9:	89 d7                	mov    %edx,%edi
  8026fb:	89 d6                	mov    %edx,%esi
  8026fd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8026ff:	5b                   	pop    %ebx
  802700:	5e                   	pop    %esi
  802701:	5f                   	pop    %edi
  802702:	5d                   	pop    %ebp
  802703:	c3                   	ret    

00802704 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802704:	55                   	push   %ebp
  802705:	89 e5                	mov    %esp,%ebp
  802707:	57                   	push   %edi
  802708:	56                   	push   %esi
  802709:	53                   	push   %ebx
  80270a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80270d:	be 00 00 00 00       	mov    $0x0,%esi
  802712:	b8 04 00 00 00       	mov    $0x4,%eax
  802717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80271a:	8b 55 08             	mov    0x8(%ebp),%edx
  80271d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802720:	89 f7                	mov    %esi,%edi
  802722:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802724:	85 c0                	test   %eax,%eax
  802726:	7e 17                	jle    80273f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802728:	83 ec 0c             	sub    $0xc,%esp
  80272b:	50                   	push   %eax
  80272c:	6a 04                	push   $0x4
  80272e:	68 3f 44 80 00       	push   $0x80443f
  802733:	6a 23                	push   $0x23
  802735:	68 5c 44 80 00       	push   $0x80445c
  80273a:	e8 64 f5 ff ff       	call   801ca3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80273f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802742:	5b                   	pop    %ebx
  802743:	5e                   	pop    %esi
  802744:	5f                   	pop    %edi
  802745:	5d                   	pop    %ebp
  802746:	c3                   	ret    

00802747 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802747:	55                   	push   %ebp
  802748:	89 e5                	mov    %esp,%ebp
  80274a:	57                   	push   %edi
  80274b:	56                   	push   %esi
  80274c:	53                   	push   %ebx
  80274d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802750:	b8 05 00 00 00       	mov    $0x5,%eax
  802755:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802758:	8b 55 08             	mov    0x8(%ebp),%edx
  80275b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80275e:	8b 7d 14             	mov    0x14(%ebp),%edi
  802761:	8b 75 18             	mov    0x18(%ebp),%esi
  802764:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802766:	85 c0                	test   %eax,%eax
  802768:	7e 17                	jle    802781 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80276a:	83 ec 0c             	sub    $0xc,%esp
  80276d:	50                   	push   %eax
  80276e:	6a 05                	push   $0x5
  802770:	68 3f 44 80 00       	push   $0x80443f
  802775:	6a 23                	push   $0x23
  802777:	68 5c 44 80 00       	push   $0x80445c
  80277c:	e8 22 f5 ff ff       	call   801ca3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802784:	5b                   	pop    %ebx
  802785:	5e                   	pop    %esi
  802786:	5f                   	pop    %edi
  802787:	5d                   	pop    %ebp
  802788:	c3                   	ret    

00802789 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802789:	55                   	push   %ebp
  80278a:	89 e5                	mov    %esp,%ebp
  80278c:	57                   	push   %edi
  80278d:	56                   	push   %esi
  80278e:	53                   	push   %ebx
  80278f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802792:	bb 00 00 00 00       	mov    $0x0,%ebx
  802797:	b8 06 00 00 00       	mov    $0x6,%eax
  80279c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80279f:	8b 55 08             	mov    0x8(%ebp),%edx
  8027a2:	89 df                	mov    %ebx,%edi
  8027a4:	89 de                	mov    %ebx,%esi
  8027a6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8027a8:	85 c0                	test   %eax,%eax
  8027aa:	7e 17                	jle    8027c3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027ac:	83 ec 0c             	sub    $0xc,%esp
  8027af:	50                   	push   %eax
  8027b0:	6a 06                	push   $0x6
  8027b2:	68 3f 44 80 00       	push   $0x80443f
  8027b7:	6a 23                	push   $0x23
  8027b9:	68 5c 44 80 00       	push   $0x80445c
  8027be:	e8 e0 f4 ff ff       	call   801ca3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8027c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027c6:	5b                   	pop    %ebx
  8027c7:	5e                   	pop    %esi
  8027c8:	5f                   	pop    %edi
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    

008027cb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8027cb:	55                   	push   %ebp
  8027cc:	89 e5                	mov    %esp,%ebp
  8027ce:	57                   	push   %edi
  8027cf:	56                   	push   %esi
  8027d0:	53                   	push   %ebx
  8027d1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8027de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8027e4:	89 df                	mov    %ebx,%edi
  8027e6:	89 de                	mov    %ebx,%esi
  8027e8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8027ea:	85 c0                	test   %eax,%eax
  8027ec:	7e 17                	jle    802805 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027ee:	83 ec 0c             	sub    $0xc,%esp
  8027f1:	50                   	push   %eax
  8027f2:	6a 08                	push   $0x8
  8027f4:	68 3f 44 80 00       	push   $0x80443f
  8027f9:	6a 23                	push   $0x23
  8027fb:	68 5c 44 80 00       	push   $0x80445c
  802800:	e8 9e f4 ff ff       	call   801ca3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802805:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802808:	5b                   	pop    %ebx
  802809:	5e                   	pop    %esi
  80280a:	5f                   	pop    %edi
  80280b:	5d                   	pop    %ebp
  80280c:	c3                   	ret    

0080280d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80280d:	55                   	push   %ebp
  80280e:	89 e5                	mov    %esp,%ebp
  802810:	57                   	push   %edi
  802811:	56                   	push   %esi
  802812:	53                   	push   %ebx
  802813:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802816:	bb 00 00 00 00       	mov    $0x0,%ebx
  80281b:	b8 09 00 00 00       	mov    $0x9,%eax
  802820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802823:	8b 55 08             	mov    0x8(%ebp),%edx
  802826:	89 df                	mov    %ebx,%edi
  802828:	89 de                	mov    %ebx,%esi
  80282a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80282c:	85 c0                	test   %eax,%eax
  80282e:	7e 17                	jle    802847 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802830:	83 ec 0c             	sub    $0xc,%esp
  802833:	50                   	push   %eax
  802834:	6a 09                	push   $0x9
  802836:	68 3f 44 80 00       	push   $0x80443f
  80283b:	6a 23                	push   $0x23
  80283d:	68 5c 44 80 00       	push   $0x80445c
  802842:	e8 5c f4 ff ff       	call   801ca3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802847:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80284a:	5b                   	pop    %ebx
  80284b:	5e                   	pop    %esi
  80284c:	5f                   	pop    %edi
  80284d:	5d                   	pop    %ebp
  80284e:	c3                   	ret    

0080284f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80284f:	55                   	push   %ebp
  802850:	89 e5                	mov    %esp,%ebp
  802852:	57                   	push   %edi
  802853:	56                   	push   %esi
  802854:	53                   	push   %ebx
  802855:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802858:	bb 00 00 00 00       	mov    $0x0,%ebx
  80285d:	b8 0a 00 00 00       	mov    $0xa,%eax
  802862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802865:	8b 55 08             	mov    0x8(%ebp),%edx
  802868:	89 df                	mov    %ebx,%edi
  80286a:	89 de                	mov    %ebx,%esi
  80286c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80286e:	85 c0                	test   %eax,%eax
  802870:	7e 17                	jle    802889 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802872:	83 ec 0c             	sub    $0xc,%esp
  802875:	50                   	push   %eax
  802876:	6a 0a                	push   $0xa
  802878:	68 3f 44 80 00       	push   $0x80443f
  80287d:	6a 23                	push   $0x23
  80287f:	68 5c 44 80 00       	push   $0x80445c
  802884:	e8 1a f4 ff ff       	call   801ca3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802889:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80288c:	5b                   	pop    %ebx
  80288d:	5e                   	pop    %esi
  80288e:	5f                   	pop    %edi
  80288f:	5d                   	pop    %ebp
  802890:	c3                   	ret    

00802891 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802891:	55                   	push   %ebp
  802892:	89 e5                	mov    %esp,%ebp
  802894:	57                   	push   %edi
  802895:	56                   	push   %esi
  802896:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802897:	be 00 00 00 00       	mov    $0x0,%esi
  80289c:	b8 0c 00 00 00       	mov    $0xc,%eax
  8028a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8028a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028aa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8028ad:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8028af:	5b                   	pop    %ebx
  8028b0:	5e                   	pop    %esi
  8028b1:	5f                   	pop    %edi
  8028b2:	5d                   	pop    %ebp
  8028b3:	c3                   	ret    

008028b4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8028b4:	55                   	push   %ebp
  8028b5:	89 e5                	mov    %esp,%ebp
  8028b7:	57                   	push   %edi
  8028b8:	56                   	push   %esi
  8028b9:	53                   	push   %ebx
  8028ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8028c2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8028c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8028ca:	89 cb                	mov    %ecx,%ebx
  8028cc:	89 cf                	mov    %ecx,%edi
  8028ce:	89 ce                	mov    %ecx,%esi
  8028d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8028d2:	85 c0                	test   %eax,%eax
  8028d4:	7e 17                	jle    8028ed <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028d6:	83 ec 0c             	sub    $0xc,%esp
  8028d9:	50                   	push   %eax
  8028da:	6a 0d                	push   $0xd
  8028dc:	68 3f 44 80 00       	push   $0x80443f
  8028e1:	6a 23                	push   $0x23
  8028e3:	68 5c 44 80 00       	push   $0x80445c
  8028e8:	e8 b6 f3 ff ff       	call   801ca3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8028ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028f0:	5b                   	pop    %ebx
  8028f1:	5e                   	pop    %esi
  8028f2:	5f                   	pop    %edi
  8028f3:	5d                   	pop    %ebp
  8028f4:	c3                   	ret    

008028f5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028f5:	55                   	push   %ebp
  8028f6:	89 e5                	mov    %esp,%ebp
  8028f8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028fb:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802902:	75 2e                	jne    802932 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802904:	e8 bd fd ff ff       	call   8026c6 <sys_getenvid>
  802909:	83 ec 04             	sub    $0x4,%esp
  80290c:	68 07 0e 00 00       	push   $0xe07
  802911:	68 00 f0 bf ee       	push   $0xeebff000
  802916:	50                   	push   %eax
  802917:	e8 e8 fd ff ff       	call   802704 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80291c:	e8 a5 fd ff ff       	call   8026c6 <sys_getenvid>
  802921:	83 c4 08             	add    $0x8,%esp
  802924:	68 3c 29 80 00       	push   $0x80293c
  802929:	50                   	push   %eax
  80292a:	e8 20 ff ff ff       	call   80284f <sys_env_set_pgfault_upcall>
  80292f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802932:	8b 45 08             	mov    0x8(%ebp),%eax
  802935:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  80293a:	c9                   	leave  
  80293b:	c3                   	ret    

0080293c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80293c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80293d:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802942:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802944:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802947:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80294b:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80294f:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802952:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802955:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802956:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802959:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80295a:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80295b:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80295f:	c3                   	ret    

00802960 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802960:	55                   	push   %ebp
  802961:	89 e5                	mov    %esp,%ebp
  802963:	56                   	push   %esi
  802964:	53                   	push   %ebx
  802965:	8b 75 08             	mov    0x8(%ebp),%esi
  802968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80296b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80296e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802970:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802975:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802978:	83 ec 0c             	sub    $0xc,%esp
  80297b:	50                   	push   %eax
  80297c:	e8 33 ff ff ff       	call   8028b4 <sys_ipc_recv>

	if (from_env_store != NULL)
  802981:	83 c4 10             	add    $0x10,%esp
  802984:	85 f6                	test   %esi,%esi
  802986:	74 14                	je     80299c <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802988:	ba 00 00 00 00       	mov    $0x0,%edx
  80298d:	85 c0                	test   %eax,%eax
  80298f:	78 09                	js     80299a <ipc_recv+0x3a>
  802991:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  802997:	8b 52 74             	mov    0x74(%edx),%edx
  80299a:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80299c:	85 db                	test   %ebx,%ebx
  80299e:	74 14                	je     8029b4 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8029a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8029a5:	85 c0                	test   %eax,%eax
  8029a7:	78 09                	js     8029b2 <ipc_recv+0x52>
  8029a9:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8029af:	8b 52 78             	mov    0x78(%edx),%edx
  8029b2:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8029b4:	85 c0                	test   %eax,%eax
  8029b6:	78 08                	js     8029c0 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8029b8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029bd:	8b 40 70             	mov    0x70(%eax),%eax
}
  8029c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029c3:	5b                   	pop    %ebx
  8029c4:	5e                   	pop    %esi
  8029c5:	5d                   	pop    %ebp
  8029c6:	c3                   	ret    

008029c7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029c7:	55                   	push   %ebp
  8029c8:	89 e5                	mov    %esp,%ebp
  8029ca:	57                   	push   %edi
  8029cb:	56                   	push   %esi
  8029cc:	53                   	push   %ebx
  8029cd:	83 ec 0c             	sub    $0xc,%esp
  8029d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8029d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8029d9:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8029db:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8029e0:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8029e3:	ff 75 14             	pushl  0x14(%ebp)
  8029e6:	53                   	push   %ebx
  8029e7:	56                   	push   %esi
  8029e8:	57                   	push   %edi
  8029e9:	e8 a3 fe ff ff       	call   802891 <sys_ipc_try_send>

		if (err < 0) {
  8029ee:	83 c4 10             	add    $0x10,%esp
  8029f1:	85 c0                	test   %eax,%eax
  8029f3:	79 1e                	jns    802a13 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8029f5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029f8:	75 07                	jne    802a01 <ipc_send+0x3a>
				sys_yield();
  8029fa:	e8 e6 fc ff ff       	call   8026e5 <sys_yield>
  8029ff:	eb e2                	jmp    8029e3 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802a01:	50                   	push   %eax
  802a02:	68 6a 44 80 00       	push   $0x80446a
  802a07:	6a 49                	push   $0x49
  802a09:	68 77 44 80 00       	push   $0x804477
  802a0e:	e8 90 f2 ff ff       	call   801ca3 <_panic>
		}

	} while (err < 0);

}
  802a13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a16:	5b                   	pop    %ebx
  802a17:	5e                   	pop    %esi
  802a18:	5f                   	pop    %edi
  802a19:	5d                   	pop    %ebp
  802a1a:	c3                   	ret    

00802a1b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a1b:	55                   	push   %ebp
  802a1c:	89 e5                	mov    %esp,%ebp
  802a1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a21:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a26:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a29:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a2f:	8b 52 50             	mov    0x50(%edx),%edx
  802a32:	39 ca                	cmp    %ecx,%edx
  802a34:	75 0d                	jne    802a43 <ipc_find_env+0x28>
			return envs[i].env_id;
  802a36:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a39:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a3e:	8b 40 48             	mov    0x48(%eax),%eax
  802a41:	eb 0f                	jmp    802a52 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a43:	83 c0 01             	add    $0x1,%eax
  802a46:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a4b:	75 d9                	jne    802a26 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a52:	5d                   	pop    %ebp
  802a53:	c3                   	ret    

00802a54 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802a54:	55                   	push   %ebp
  802a55:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802a57:	8b 45 08             	mov    0x8(%ebp),%eax
  802a5a:	05 00 00 00 30       	add    $0x30000000,%eax
  802a5f:	c1 e8 0c             	shr    $0xc,%eax
}
  802a62:	5d                   	pop    %ebp
  802a63:	c3                   	ret    

00802a64 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802a64:	55                   	push   %ebp
  802a65:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802a67:	8b 45 08             	mov    0x8(%ebp),%eax
  802a6a:	05 00 00 00 30       	add    $0x30000000,%eax
  802a6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802a74:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802a79:	5d                   	pop    %ebp
  802a7a:	c3                   	ret    

00802a7b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802a7b:	55                   	push   %ebp
  802a7c:	89 e5                	mov    %esp,%ebp
  802a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a81:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802a86:	89 c2                	mov    %eax,%edx
  802a88:	c1 ea 16             	shr    $0x16,%edx
  802a8b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a92:	f6 c2 01             	test   $0x1,%dl
  802a95:	74 11                	je     802aa8 <fd_alloc+0x2d>
  802a97:	89 c2                	mov    %eax,%edx
  802a99:	c1 ea 0c             	shr    $0xc,%edx
  802a9c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802aa3:	f6 c2 01             	test   $0x1,%dl
  802aa6:	75 09                	jne    802ab1 <fd_alloc+0x36>
			*fd_store = fd;
  802aa8:	89 01                	mov    %eax,(%ecx)
			return 0;
  802aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  802aaf:	eb 17                	jmp    802ac8 <fd_alloc+0x4d>
  802ab1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802ab6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802abb:	75 c9                	jne    802a86 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802abd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802ac3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802ac8:	5d                   	pop    %ebp
  802ac9:	c3                   	ret    

00802aca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802aca:	55                   	push   %ebp
  802acb:	89 e5                	mov    %esp,%ebp
  802acd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802ad0:	83 f8 1f             	cmp    $0x1f,%eax
  802ad3:	77 36                	ja     802b0b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802ad5:	c1 e0 0c             	shl    $0xc,%eax
  802ad8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802add:	89 c2                	mov    %eax,%edx
  802adf:	c1 ea 16             	shr    $0x16,%edx
  802ae2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802ae9:	f6 c2 01             	test   $0x1,%dl
  802aec:	74 24                	je     802b12 <fd_lookup+0x48>
  802aee:	89 c2                	mov    %eax,%edx
  802af0:	c1 ea 0c             	shr    $0xc,%edx
  802af3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802afa:	f6 c2 01             	test   $0x1,%dl
  802afd:	74 1a                	je     802b19 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b02:	89 02                	mov    %eax,(%edx)
	return 0;
  802b04:	b8 00 00 00 00       	mov    $0x0,%eax
  802b09:	eb 13                	jmp    802b1e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802b0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b10:	eb 0c                	jmp    802b1e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802b12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b17:	eb 05                	jmp    802b1e <fd_lookup+0x54>
  802b19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802b1e:	5d                   	pop    %ebp
  802b1f:	c3                   	ret    

00802b20 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802b20:	55                   	push   %ebp
  802b21:	89 e5                	mov    %esp,%ebp
  802b23:	83 ec 08             	sub    $0x8,%esp
  802b26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b29:	ba 04 45 80 00       	mov    $0x804504,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802b2e:	eb 13                	jmp    802b43 <dev_lookup+0x23>
  802b30:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802b33:	39 08                	cmp    %ecx,(%eax)
  802b35:	75 0c                	jne    802b43 <dev_lookup+0x23>
			*dev = devtab[i];
  802b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b3a:	89 01                	mov    %eax,(%ecx)
			return 0;
  802b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  802b41:	eb 2e                	jmp    802b71 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802b43:	8b 02                	mov    (%edx),%eax
  802b45:	85 c0                	test   %eax,%eax
  802b47:	75 e7                	jne    802b30 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802b49:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b4e:	8b 40 48             	mov    0x48(%eax),%eax
  802b51:	83 ec 04             	sub    $0x4,%esp
  802b54:	51                   	push   %ecx
  802b55:	50                   	push   %eax
  802b56:	68 84 44 80 00       	push   $0x804484
  802b5b:	e8 1c f2 ff ff       	call   801d7c <cprintf>
	*dev = 0;
  802b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b63:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802b69:	83 c4 10             	add    $0x10,%esp
  802b6c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802b71:	c9                   	leave  
  802b72:	c3                   	ret    

00802b73 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802b73:	55                   	push   %ebp
  802b74:	89 e5                	mov    %esp,%ebp
  802b76:	56                   	push   %esi
  802b77:	53                   	push   %ebx
  802b78:	83 ec 10             	sub    $0x10,%esp
  802b7b:	8b 75 08             	mov    0x8(%ebp),%esi
  802b7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802b81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b84:	50                   	push   %eax
  802b85:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802b8b:	c1 e8 0c             	shr    $0xc,%eax
  802b8e:	50                   	push   %eax
  802b8f:	e8 36 ff ff ff       	call   802aca <fd_lookup>
  802b94:	83 c4 08             	add    $0x8,%esp
  802b97:	85 c0                	test   %eax,%eax
  802b99:	78 05                	js     802ba0 <fd_close+0x2d>
	    || fd != fd2)
  802b9b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802b9e:	74 0c                	je     802bac <fd_close+0x39>
		return (must_exist ? r : 0);
  802ba0:	84 db                	test   %bl,%bl
  802ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  802ba7:	0f 44 c2             	cmove  %edx,%eax
  802baa:	eb 41                	jmp    802bed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802bac:	83 ec 08             	sub    $0x8,%esp
  802baf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bb2:	50                   	push   %eax
  802bb3:	ff 36                	pushl  (%esi)
  802bb5:	e8 66 ff ff ff       	call   802b20 <dev_lookup>
  802bba:	89 c3                	mov    %eax,%ebx
  802bbc:	83 c4 10             	add    $0x10,%esp
  802bbf:	85 c0                	test   %eax,%eax
  802bc1:	78 1a                	js     802bdd <fd_close+0x6a>
		if (dev->dev_close)
  802bc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bc6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802bce:	85 c0                	test   %eax,%eax
  802bd0:	74 0b                	je     802bdd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802bd2:	83 ec 0c             	sub    $0xc,%esp
  802bd5:	56                   	push   %esi
  802bd6:	ff d0                	call   *%eax
  802bd8:	89 c3                	mov    %eax,%ebx
  802bda:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802bdd:	83 ec 08             	sub    $0x8,%esp
  802be0:	56                   	push   %esi
  802be1:	6a 00                	push   $0x0
  802be3:	e8 a1 fb ff ff       	call   802789 <sys_page_unmap>
	return r;
  802be8:	83 c4 10             	add    $0x10,%esp
  802beb:	89 d8                	mov    %ebx,%eax
}
  802bed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802bf0:	5b                   	pop    %ebx
  802bf1:	5e                   	pop    %esi
  802bf2:	5d                   	pop    %ebp
  802bf3:	c3                   	ret    

00802bf4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802bf4:	55                   	push   %ebp
  802bf5:	89 e5                	mov    %esp,%ebp
  802bf7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bfd:	50                   	push   %eax
  802bfe:	ff 75 08             	pushl  0x8(%ebp)
  802c01:	e8 c4 fe ff ff       	call   802aca <fd_lookup>
  802c06:	83 c4 08             	add    $0x8,%esp
  802c09:	85 c0                	test   %eax,%eax
  802c0b:	78 10                	js     802c1d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802c0d:	83 ec 08             	sub    $0x8,%esp
  802c10:	6a 01                	push   $0x1
  802c12:	ff 75 f4             	pushl  -0xc(%ebp)
  802c15:	e8 59 ff ff ff       	call   802b73 <fd_close>
  802c1a:	83 c4 10             	add    $0x10,%esp
}
  802c1d:	c9                   	leave  
  802c1e:	c3                   	ret    

00802c1f <close_all>:

void
close_all(void)
{
  802c1f:	55                   	push   %ebp
  802c20:	89 e5                	mov    %esp,%ebp
  802c22:	53                   	push   %ebx
  802c23:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802c26:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802c2b:	83 ec 0c             	sub    $0xc,%esp
  802c2e:	53                   	push   %ebx
  802c2f:	e8 c0 ff ff ff       	call   802bf4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802c34:	83 c3 01             	add    $0x1,%ebx
  802c37:	83 c4 10             	add    $0x10,%esp
  802c3a:	83 fb 20             	cmp    $0x20,%ebx
  802c3d:	75 ec                	jne    802c2b <close_all+0xc>
		close(i);
}
  802c3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c42:	c9                   	leave  
  802c43:	c3                   	ret    

00802c44 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802c44:	55                   	push   %ebp
  802c45:	89 e5                	mov    %esp,%ebp
  802c47:	57                   	push   %edi
  802c48:	56                   	push   %esi
  802c49:	53                   	push   %ebx
  802c4a:	83 ec 2c             	sub    $0x2c,%esp
  802c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802c50:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802c53:	50                   	push   %eax
  802c54:	ff 75 08             	pushl  0x8(%ebp)
  802c57:	e8 6e fe ff ff       	call   802aca <fd_lookup>
  802c5c:	83 c4 08             	add    $0x8,%esp
  802c5f:	85 c0                	test   %eax,%eax
  802c61:	0f 88 c1 00 00 00    	js     802d28 <dup+0xe4>
		return r;
	close(newfdnum);
  802c67:	83 ec 0c             	sub    $0xc,%esp
  802c6a:	56                   	push   %esi
  802c6b:	e8 84 ff ff ff       	call   802bf4 <close>

	newfd = INDEX2FD(newfdnum);
  802c70:	89 f3                	mov    %esi,%ebx
  802c72:	c1 e3 0c             	shl    $0xc,%ebx
  802c75:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802c7b:	83 c4 04             	add    $0x4,%esp
  802c7e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c81:	e8 de fd ff ff       	call   802a64 <fd2data>
  802c86:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802c88:	89 1c 24             	mov    %ebx,(%esp)
  802c8b:	e8 d4 fd ff ff       	call   802a64 <fd2data>
  802c90:	83 c4 10             	add    $0x10,%esp
  802c93:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802c96:	89 f8                	mov    %edi,%eax
  802c98:	c1 e8 16             	shr    $0x16,%eax
  802c9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802ca2:	a8 01                	test   $0x1,%al
  802ca4:	74 37                	je     802cdd <dup+0x99>
  802ca6:	89 f8                	mov    %edi,%eax
  802ca8:	c1 e8 0c             	shr    $0xc,%eax
  802cab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802cb2:	f6 c2 01             	test   $0x1,%dl
  802cb5:	74 26                	je     802cdd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802cb7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802cbe:	83 ec 0c             	sub    $0xc,%esp
  802cc1:	25 07 0e 00 00       	and    $0xe07,%eax
  802cc6:	50                   	push   %eax
  802cc7:	ff 75 d4             	pushl  -0x2c(%ebp)
  802cca:	6a 00                	push   $0x0
  802ccc:	57                   	push   %edi
  802ccd:	6a 00                	push   $0x0
  802ccf:	e8 73 fa ff ff       	call   802747 <sys_page_map>
  802cd4:	89 c7                	mov    %eax,%edi
  802cd6:	83 c4 20             	add    $0x20,%esp
  802cd9:	85 c0                	test   %eax,%eax
  802cdb:	78 2e                	js     802d0b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802cdd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802ce0:	89 d0                	mov    %edx,%eax
  802ce2:	c1 e8 0c             	shr    $0xc,%eax
  802ce5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802cec:	83 ec 0c             	sub    $0xc,%esp
  802cef:	25 07 0e 00 00       	and    $0xe07,%eax
  802cf4:	50                   	push   %eax
  802cf5:	53                   	push   %ebx
  802cf6:	6a 00                	push   $0x0
  802cf8:	52                   	push   %edx
  802cf9:	6a 00                	push   $0x0
  802cfb:	e8 47 fa ff ff       	call   802747 <sys_page_map>
  802d00:	89 c7                	mov    %eax,%edi
  802d02:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802d05:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802d07:	85 ff                	test   %edi,%edi
  802d09:	79 1d                	jns    802d28 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802d0b:	83 ec 08             	sub    $0x8,%esp
  802d0e:	53                   	push   %ebx
  802d0f:	6a 00                	push   $0x0
  802d11:	e8 73 fa ff ff       	call   802789 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802d16:	83 c4 08             	add    $0x8,%esp
  802d19:	ff 75 d4             	pushl  -0x2c(%ebp)
  802d1c:	6a 00                	push   $0x0
  802d1e:	e8 66 fa ff ff       	call   802789 <sys_page_unmap>
	return r;
  802d23:	83 c4 10             	add    $0x10,%esp
  802d26:	89 f8                	mov    %edi,%eax
}
  802d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d2b:	5b                   	pop    %ebx
  802d2c:	5e                   	pop    %esi
  802d2d:	5f                   	pop    %edi
  802d2e:	5d                   	pop    %ebp
  802d2f:	c3                   	ret    

00802d30 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802d30:	55                   	push   %ebp
  802d31:	89 e5                	mov    %esp,%ebp
  802d33:	53                   	push   %ebx
  802d34:	83 ec 14             	sub    $0x14,%esp
  802d37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d3d:	50                   	push   %eax
  802d3e:	53                   	push   %ebx
  802d3f:	e8 86 fd ff ff       	call   802aca <fd_lookup>
  802d44:	83 c4 08             	add    $0x8,%esp
  802d47:	89 c2                	mov    %eax,%edx
  802d49:	85 c0                	test   %eax,%eax
  802d4b:	78 6d                	js     802dba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d4d:	83 ec 08             	sub    $0x8,%esp
  802d50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d53:	50                   	push   %eax
  802d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d57:	ff 30                	pushl  (%eax)
  802d59:	e8 c2 fd ff ff       	call   802b20 <dev_lookup>
  802d5e:	83 c4 10             	add    $0x10,%esp
  802d61:	85 c0                	test   %eax,%eax
  802d63:	78 4c                	js     802db1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802d65:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802d68:	8b 42 08             	mov    0x8(%edx),%eax
  802d6b:	83 e0 03             	and    $0x3,%eax
  802d6e:	83 f8 01             	cmp    $0x1,%eax
  802d71:	75 21                	jne    802d94 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802d73:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d78:	8b 40 48             	mov    0x48(%eax),%eax
  802d7b:	83 ec 04             	sub    $0x4,%esp
  802d7e:	53                   	push   %ebx
  802d7f:	50                   	push   %eax
  802d80:	68 c8 44 80 00       	push   $0x8044c8
  802d85:	e8 f2 ef ff ff       	call   801d7c <cprintf>
		return -E_INVAL;
  802d8a:	83 c4 10             	add    $0x10,%esp
  802d8d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d92:	eb 26                	jmp    802dba <read+0x8a>
	}
	if (!dev->dev_read)
  802d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d97:	8b 40 08             	mov    0x8(%eax),%eax
  802d9a:	85 c0                	test   %eax,%eax
  802d9c:	74 17                	je     802db5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802d9e:	83 ec 04             	sub    $0x4,%esp
  802da1:	ff 75 10             	pushl  0x10(%ebp)
  802da4:	ff 75 0c             	pushl  0xc(%ebp)
  802da7:	52                   	push   %edx
  802da8:	ff d0                	call   *%eax
  802daa:	89 c2                	mov    %eax,%edx
  802dac:	83 c4 10             	add    $0x10,%esp
  802daf:	eb 09                	jmp    802dba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802db1:	89 c2                	mov    %eax,%edx
  802db3:	eb 05                	jmp    802dba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802db5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802dba:	89 d0                	mov    %edx,%eax
  802dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dbf:	c9                   	leave  
  802dc0:	c3                   	ret    

00802dc1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802dc1:	55                   	push   %ebp
  802dc2:	89 e5                	mov    %esp,%ebp
  802dc4:	57                   	push   %edi
  802dc5:	56                   	push   %esi
  802dc6:	53                   	push   %ebx
  802dc7:	83 ec 0c             	sub    $0xc,%esp
  802dca:	8b 7d 08             	mov    0x8(%ebp),%edi
  802dcd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802dd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  802dd5:	eb 21                	jmp    802df8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802dd7:	83 ec 04             	sub    $0x4,%esp
  802dda:	89 f0                	mov    %esi,%eax
  802ddc:	29 d8                	sub    %ebx,%eax
  802dde:	50                   	push   %eax
  802ddf:	89 d8                	mov    %ebx,%eax
  802de1:	03 45 0c             	add    0xc(%ebp),%eax
  802de4:	50                   	push   %eax
  802de5:	57                   	push   %edi
  802de6:	e8 45 ff ff ff       	call   802d30 <read>
		if (m < 0)
  802deb:	83 c4 10             	add    $0x10,%esp
  802dee:	85 c0                	test   %eax,%eax
  802df0:	78 10                	js     802e02 <readn+0x41>
			return m;
		if (m == 0)
  802df2:	85 c0                	test   %eax,%eax
  802df4:	74 0a                	je     802e00 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802df6:	01 c3                	add    %eax,%ebx
  802df8:	39 f3                	cmp    %esi,%ebx
  802dfa:	72 db                	jb     802dd7 <readn+0x16>
  802dfc:	89 d8                	mov    %ebx,%eax
  802dfe:	eb 02                	jmp    802e02 <readn+0x41>
  802e00:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e05:	5b                   	pop    %ebx
  802e06:	5e                   	pop    %esi
  802e07:	5f                   	pop    %edi
  802e08:	5d                   	pop    %ebp
  802e09:	c3                   	ret    

00802e0a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802e0a:	55                   	push   %ebp
  802e0b:	89 e5                	mov    %esp,%ebp
  802e0d:	53                   	push   %ebx
  802e0e:	83 ec 14             	sub    $0x14,%esp
  802e11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e17:	50                   	push   %eax
  802e18:	53                   	push   %ebx
  802e19:	e8 ac fc ff ff       	call   802aca <fd_lookup>
  802e1e:	83 c4 08             	add    $0x8,%esp
  802e21:	89 c2                	mov    %eax,%edx
  802e23:	85 c0                	test   %eax,%eax
  802e25:	78 68                	js     802e8f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e27:	83 ec 08             	sub    $0x8,%esp
  802e2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e2d:	50                   	push   %eax
  802e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e31:	ff 30                	pushl  (%eax)
  802e33:	e8 e8 fc ff ff       	call   802b20 <dev_lookup>
  802e38:	83 c4 10             	add    $0x10,%esp
  802e3b:	85 c0                	test   %eax,%eax
  802e3d:	78 47                	js     802e86 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e42:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802e46:	75 21                	jne    802e69 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802e48:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802e4d:	8b 40 48             	mov    0x48(%eax),%eax
  802e50:	83 ec 04             	sub    $0x4,%esp
  802e53:	53                   	push   %ebx
  802e54:	50                   	push   %eax
  802e55:	68 e4 44 80 00       	push   $0x8044e4
  802e5a:	e8 1d ef ff ff       	call   801d7c <cprintf>
		return -E_INVAL;
  802e5f:	83 c4 10             	add    $0x10,%esp
  802e62:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802e67:	eb 26                	jmp    802e8f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802e69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e6c:	8b 52 0c             	mov    0xc(%edx),%edx
  802e6f:	85 d2                	test   %edx,%edx
  802e71:	74 17                	je     802e8a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802e73:	83 ec 04             	sub    $0x4,%esp
  802e76:	ff 75 10             	pushl  0x10(%ebp)
  802e79:	ff 75 0c             	pushl  0xc(%ebp)
  802e7c:	50                   	push   %eax
  802e7d:	ff d2                	call   *%edx
  802e7f:	89 c2                	mov    %eax,%edx
  802e81:	83 c4 10             	add    $0x10,%esp
  802e84:	eb 09                	jmp    802e8f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e86:	89 c2                	mov    %eax,%edx
  802e88:	eb 05                	jmp    802e8f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802e8a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802e8f:	89 d0                	mov    %edx,%eax
  802e91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e94:	c9                   	leave  
  802e95:	c3                   	ret    

00802e96 <seek>:

int
seek(int fdnum, off_t offset)
{
  802e96:	55                   	push   %ebp
  802e97:	89 e5                	mov    %esp,%ebp
  802e99:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e9c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802e9f:	50                   	push   %eax
  802ea0:	ff 75 08             	pushl  0x8(%ebp)
  802ea3:	e8 22 fc ff ff       	call   802aca <fd_lookup>
  802ea8:	83 c4 08             	add    $0x8,%esp
  802eab:	85 c0                	test   %eax,%eax
  802ead:	78 0e                	js     802ebd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  802eb5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802eb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ebd:	c9                   	leave  
  802ebe:	c3                   	ret    

00802ebf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802ebf:	55                   	push   %ebp
  802ec0:	89 e5                	mov    %esp,%ebp
  802ec2:	53                   	push   %ebx
  802ec3:	83 ec 14             	sub    $0x14,%esp
  802ec6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ec9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ecc:	50                   	push   %eax
  802ecd:	53                   	push   %ebx
  802ece:	e8 f7 fb ff ff       	call   802aca <fd_lookup>
  802ed3:	83 c4 08             	add    $0x8,%esp
  802ed6:	89 c2                	mov    %eax,%edx
  802ed8:	85 c0                	test   %eax,%eax
  802eda:	78 65                	js     802f41 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802edc:	83 ec 08             	sub    $0x8,%esp
  802edf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ee2:	50                   	push   %eax
  802ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ee6:	ff 30                	pushl  (%eax)
  802ee8:	e8 33 fc ff ff       	call   802b20 <dev_lookup>
  802eed:	83 c4 10             	add    $0x10,%esp
  802ef0:	85 c0                	test   %eax,%eax
  802ef2:	78 44                	js     802f38 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ef7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802efb:	75 21                	jne    802f1e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802efd:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802f02:	8b 40 48             	mov    0x48(%eax),%eax
  802f05:	83 ec 04             	sub    $0x4,%esp
  802f08:	53                   	push   %ebx
  802f09:	50                   	push   %eax
  802f0a:	68 a4 44 80 00       	push   $0x8044a4
  802f0f:	e8 68 ee ff ff       	call   801d7c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802f14:	83 c4 10             	add    $0x10,%esp
  802f17:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802f1c:	eb 23                	jmp    802f41 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802f1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f21:	8b 52 18             	mov    0x18(%edx),%edx
  802f24:	85 d2                	test   %edx,%edx
  802f26:	74 14                	je     802f3c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802f28:	83 ec 08             	sub    $0x8,%esp
  802f2b:	ff 75 0c             	pushl  0xc(%ebp)
  802f2e:	50                   	push   %eax
  802f2f:	ff d2                	call   *%edx
  802f31:	89 c2                	mov    %eax,%edx
  802f33:	83 c4 10             	add    $0x10,%esp
  802f36:	eb 09                	jmp    802f41 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f38:	89 c2                	mov    %eax,%edx
  802f3a:	eb 05                	jmp    802f41 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802f3c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802f41:	89 d0                	mov    %edx,%eax
  802f43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f46:	c9                   	leave  
  802f47:	c3                   	ret    

00802f48 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802f48:	55                   	push   %ebp
  802f49:	89 e5                	mov    %esp,%ebp
  802f4b:	53                   	push   %ebx
  802f4c:	83 ec 14             	sub    $0x14,%esp
  802f4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f52:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f55:	50                   	push   %eax
  802f56:	ff 75 08             	pushl  0x8(%ebp)
  802f59:	e8 6c fb ff ff       	call   802aca <fd_lookup>
  802f5e:	83 c4 08             	add    $0x8,%esp
  802f61:	89 c2                	mov    %eax,%edx
  802f63:	85 c0                	test   %eax,%eax
  802f65:	78 58                	js     802fbf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f67:	83 ec 08             	sub    $0x8,%esp
  802f6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f6d:	50                   	push   %eax
  802f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f71:	ff 30                	pushl  (%eax)
  802f73:	e8 a8 fb ff ff       	call   802b20 <dev_lookup>
  802f78:	83 c4 10             	add    $0x10,%esp
  802f7b:	85 c0                	test   %eax,%eax
  802f7d:	78 37                	js     802fb6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f82:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802f86:	74 32                	je     802fba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802f88:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802f8b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802f92:	00 00 00 
	stat->st_isdir = 0;
  802f95:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802f9c:	00 00 00 
	stat->st_dev = dev;
  802f9f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802fa5:	83 ec 08             	sub    $0x8,%esp
  802fa8:	53                   	push   %ebx
  802fa9:	ff 75 f0             	pushl  -0x10(%ebp)
  802fac:	ff 50 14             	call   *0x14(%eax)
  802faf:	89 c2                	mov    %eax,%edx
  802fb1:	83 c4 10             	add    $0x10,%esp
  802fb4:	eb 09                	jmp    802fbf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802fb6:	89 c2                	mov    %eax,%edx
  802fb8:	eb 05                	jmp    802fbf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802fba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802fbf:	89 d0                	mov    %edx,%eax
  802fc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fc4:	c9                   	leave  
  802fc5:	c3                   	ret    

00802fc6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802fc6:	55                   	push   %ebp
  802fc7:	89 e5                	mov    %esp,%ebp
  802fc9:	56                   	push   %esi
  802fca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802fcb:	83 ec 08             	sub    $0x8,%esp
  802fce:	6a 00                	push   $0x0
  802fd0:	ff 75 08             	pushl  0x8(%ebp)
  802fd3:	e8 d6 01 00 00       	call   8031ae <open>
  802fd8:	89 c3                	mov    %eax,%ebx
  802fda:	83 c4 10             	add    $0x10,%esp
  802fdd:	85 c0                	test   %eax,%eax
  802fdf:	78 1b                	js     802ffc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802fe1:	83 ec 08             	sub    $0x8,%esp
  802fe4:	ff 75 0c             	pushl  0xc(%ebp)
  802fe7:	50                   	push   %eax
  802fe8:	e8 5b ff ff ff       	call   802f48 <fstat>
  802fed:	89 c6                	mov    %eax,%esi
	close(fd);
  802fef:	89 1c 24             	mov    %ebx,(%esp)
  802ff2:	e8 fd fb ff ff       	call   802bf4 <close>
	return r;
  802ff7:	83 c4 10             	add    $0x10,%esp
  802ffa:	89 f0                	mov    %esi,%eax
}
  802ffc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fff:	5b                   	pop    %ebx
  803000:	5e                   	pop    %esi
  803001:	5d                   	pop    %ebp
  803002:	c3                   	ret    

00803003 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  803003:	55                   	push   %ebp
  803004:	89 e5                	mov    %esp,%ebp
  803006:	56                   	push   %esi
  803007:	53                   	push   %ebx
  803008:	89 c6                	mov    %eax,%esi
  80300a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80300c:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  803013:	75 12                	jne    803027 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  803015:	83 ec 0c             	sub    $0xc,%esp
  803018:	6a 01                	push   $0x1
  80301a:	e8 fc f9 ff ff       	call   802a1b <ipc_find_env>
  80301f:	a3 00 a0 80 00       	mov    %eax,0x80a000
  803024:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  803027:	6a 07                	push   $0x7
  803029:	68 00 b0 80 00       	push   $0x80b000
  80302e:	56                   	push   %esi
  80302f:	ff 35 00 a0 80 00    	pushl  0x80a000
  803035:	e8 8d f9 ff ff       	call   8029c7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80303a:	83 c4 0c             	add    $0xc,%esp
  80303d:	6a 00                	push   $0x0
  80303f:	53                   	push   %ebx
  803040:	6a 00                	push   $0x0
  803042:	e8 19 f9 ff ff       	call   802960 <ipc_recv>
}
  803047:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80304a:	5b                   	pop    %ebx
  80304b:	5e                   	pop    %esi
  80304c:	5d                   	pop    %ebp
  80304d:	c3                   	ret    

0080304e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80304e:	55                   	push   %ebp
  80304f:	89 e5                	mov    %esp,%ebp
  803051:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  803054:	8b 45 08             	mov    0x8(%ebp),%eax
  803057:	8b 40 0c             	mov    0xc(%eax),%eax
  80305a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  80305f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803062:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  803067:	ba 00 00 00 00       	mov    $0x0,%edx
  80306c:	b8 02 00 00 00       	mov    $0x2,%eax
  803071:	e8 8d ff ff ff       	call   803003 <fsipc>
}
  803076:	c9                   	leave  
  803077:	c3                   	ret    

00803078 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  803078:	55                   	push   %ebp
  803079:	89 e5                	mov    %esp,%ebp
  80307b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80307e:	8b 45 08             	mov    0x8(%ebp),%eax
  803081:	8b 40 0c             	mov    0xc(%eax),%eax
  803084:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  803089:	ba 00 00 00 00       	mov    $0x0,%edx
  80308e:	b8 06 00 00 00       	mov    $0x6,%eax
  803093:	e8 6b ff ff ff       	call   803003 <fsipc>
}
  803098:	c9                   	leave  
  803099:	c3                   	ret    

0080309a <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80309a:	55                   	push   %ebp
  80309b:	89 e5                	mov    %esp,%ebp
  80309d:	53                   	push   %ebx
  80309e:	83 ec 04             	sub    $0x4,%esp
  8030a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8030a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8030a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8030aa:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8030af:	ba 00 00 00 00       	mov    $0x0,%edx
  8030b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8030b9:	e8 45 ff ff ff       	call   803003 <fsipc>
  8030be:	85 c0                	test   %eax,%eax
  8030c0:	78 2c                	js     8030ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8030c2:	83 ec 08             	sub    $0x8,%esp
  8030c5:	68 00 b0 80 00       	push   $0x80b000
  8030ca:	53                   	push   %ebx
  8030cb:	e8 31 f2 ff ff       	call   802301 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8030d0:	a1 80 b0 80 00       	mov    0x80b080,%eax
  8030d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8030db:	a1 84 b0 80 00       	mov    0x80b084,%eax
  8030e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8030e6:	83 c4 10             	add    $0x10,%esp
  8030e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8030ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030f1:	c9                   	leave  
  8030f2:	c3                   	ret    

008030f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8030f3:	55                   	push   %ebp
  8030f4:	89 e5                	mov    %esp,%ebp
  8030f6:	83 ec 0c             	sub    $0xc,%esp
  8030f9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8030fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8030ff:	8b 52 0c             	mov    0xc(%edx),%edx
  803102:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  803108:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80310d:	50                   	push   %eax
  80310e:	ff 75 0c             	pushl  0xc(%ebp)
  803111:	68 08 b0 80 00       	push   $0x80b008
  803116:	e8 78 f3 ff ff       	call   802493 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80311b:	ba 00 00 00 00       	mov    $0x0,%edx
  803120:	b8 04 00 00 00       	mov    $0x4,%eax
  803125:	e8 d9 fe ff ff       	call   803003 <fsipc>

}
  80312a:	c9                   	leave  
  80312b:	c3                   	ret    

0080312c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80312c:	55                   	push   %ebp
  80312d:	89 e5                	mov    %esp,%ebp
  80312f:	56                   	push   %esi
  803130:	53                   	push   %ebx
  803131:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  803134:	8b 45 08             	mov    0x8(%ebp),%eax
  803137:	8b 40 0c             	mov    0xc(%eax),%eax
  80313a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  80313f:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  803145:	ba 00 00 00 00       	mov    $0x0,%edx
  80314a:	b8 03 00 00 00       	mov    $0x3,%eax
  80314f:	e8 af fe ff ff       	call   803003 <fsipc>
  803154:	89 c3                	mov    %eax,%ebx
  803156:	85 c0                	test   %eax,%eax
  803158:	78 4b                	js     8031a5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80315a:	39 c6                	cmp    %eax,%esi
  80315c:	73 16                	jae    803174 <devfile_read+0x48>
  80315e:	68 14 45 80 00       	push   $0x804514
  803163:	68 3d 3a 80 00       	push   $0x803a3d
  803168:	6a 7c                	push   $0x7c
  80316a:	68 1b 45 80 00       	push   $0x80451b
  80316f:	e8 2f eb ff ff       	call   801ca3 <_panic>
	assert(r <= PGSIZE);
  803174:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803179:	7e 16                	jle    803191 <devfile_read+0x65>
  80317b:	68 26 45 80 00       	push   $0x804526
  803180:	68 3d 3a 80 00       	push   $0x803a3d
  803185:	6a 7d                	push   $0x7d
  803187:	68 1b 45 80 00       	push   $0x80451b
  80318c:	e8 12 eb ff ff       	call   801ca3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803191:	83 ec 04             	sub    $0x4,%esp
  803194:	50                   	push   %eax
  803195:	68 00 b0 80 00       	push   $0x80b000
  80319a:	ff 75 0c             	pushl  0xc(%ebp)
  80319d:	e8 f1 f2 ff ff       	call   802493 <memmove>
	return r;
  8031a2:	83 c4 10             	add    $0x10,%esp
}
  8031a5:	89 d8                	mov    %ebx,%eax
  8031a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031aa:	5b                   	pop    %ebx
  8031ab:	5e                   	pop    %esi
  8031ac:	5d                   	pop    %ebp
  8031ad:	c3                   	ret    

008031ae <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8031ae:	55                   	push   %ebp
  8031af:	89 e5                	mov    %esp,%ebp
  8031b1:	53                   	push   %ebx
  8031b2:	83 ec 20             	sub    $0x20,%esp
  8031b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8031b8:	53                   	push   %ebx
  8031b9:	e8 0a f1 ff ff       	call   8022c8 <strlen>
  8031be:	83 c4 10             	add    $0x10,%esp
  8031c1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8031c6:	7f 67                	jg     80322f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8031c8:	83 ec 0c             	sub    $0xc,%esp
  8031cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031ce:	50                   	push   %eax
  8031cf:	e8 a7 f8 ff ff       	call   802a7b <fd_alloc>
  8031d4:	83 c4 10             	add    $0x10,%esp
		return r;
  8031d7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8031d9:	85 c0                	test   %eax,%eax
  8031db:	78 57                	js     803234 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8031dd:	83 ec 08             	sub    $0x8,%esp
  8031e0:	53                   	push   %ebx
  8031e1:	68 00 b0 80 00       	push   $0x80b000
  8031e6:	e8 16 f1 ff ff       	call   802301 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8031eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031ee:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8031f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8031fb:	e8 03 fe ff ff       	call   803003 <fsipc>
  803200:	89 c3                	mov    %eax,%ebx
  803202:	83 c4 10             	add    $0x10,%esp
  803205:	85 c0                	test   %eax,%eax
  803207:	79 14                	jns    80321d <open+0x6f>
		fd_close(fd, 0);
  803209:	83 ec 08             	sub    $0x8,%esp
  80320c:	6a 00                	push   $0x0
  80320e:	ff 75 f4             	pushl  -0xc(%ebp)
  803211:	e8 5d f9 ff ff       	call   802b73 <fd_close>
		return r;
  803216:	83 c4 10             	add    $0x10,%esp
  803219:	89 da                	mov    %ebx,%edx
  80321b:	eb 17                	jmp    803234 <open+0x86>
	}

	return fd2num(fd);
  80321d:	83 ec 0c             	sub    $0xc,%esp
  803220:	ff 75 f4             	pushl  -0xc(%ebp)
  803223:	e8 2c f8 ff ff       	call   802a54 <fd2num>
  803228:	89 c2                	mov    %eax,%edx
  80322a:	83 c4 10             	add    $0x10,%esp
  80322d:	eb 05                	jmp    803234 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80322f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  803234:	89 d0                	mov    %edx,%eax
  803236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803239:	c9                   	leave  
  80323a:	c3                   	ret    

0080323b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80323b:	55                   	push   %ebp
  80323c:	89 e5                	mov    %esp,%ebp
  80323e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803241:	ba 00 00 00 00       	mov    $0x0,%edx
  803246:	b8 08 00 00 00       	mov    $0x8,%eax
  80324b:	e8 b3 fd ff ff       	call   803003 <fsipc>
}
  803250:	c9                   	leave  
  803251:	c3                   	ret    

00803252 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803252:	55                   	push   %ebp
  803253:	89 e5                	mov    %esp,%ebp
  803255:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803258:	89 d0                	mov    %edx,%eax
  80325a:	c1 e8 16             	shr    $0x16,%eax
  80325d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803264:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803269:	f6 c1 01             	test   $0x1,%cl
  80326c:	74 1d                	je     80328b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80326e:	c1 ea 0c             	shr    $0xc,%edx
  803271:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803278:	f6 c2 01             	test   $0x1,%dl
  80327b:	74 0e                	je     80328b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80327d:	c1 ea 0c             	shr    $0xc,%edx
  803280:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803287:	ef 
  803288:	0f b7 c0             	movzwl %ax,%eax
}
  80328b:	5d                   	pop    %ebp
  80328c:	c3                   	ret    

0080328d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80328d:	55                   	push   %ebp
  80328e:	89 e5                	mov    %esp,%ebp
  803290:	56                   	push   %esi
  803291:	53                   	push   %ebx
  803292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803295:	83 ec 0c             	sub    $0xc,%esp
  803298:	ff 75 08             	pushl  0x8(%ebp)
  80329b:	e8 c4 f7 ff ff       	call   802a64 <fd2data>
  8032a0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8032a2:	83 c4 08             	add    $0x8,%esp
  8032a5:	68 32 45 80 00       	push   $0x804532
  8032aa:	53                   	push   %ebx
  8032ab:	e8 51 f0 ff ff       	call   802301 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8032b0:	8b 46 04             	mov    0x4(%esi),%eax
  8032b3:	2b 06                	sub    (%esi),%eax
  8032b5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8032bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8032c2:	00 00 00 
	stat->st_dev = &devpipe;
  8032c5:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  8032cc:	90 80 00 
	return 0;
}
  8032cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8032d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032d7:	5b                   	pop    %ebx
  8032d8:	5e                   	pop    %esi
  8032d9:	5d                   	pop    %ebp
  8032da:	c3                   	ret    

008032db <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8032db:	55                   	push   %ebp
  8032dc:	89 e5                	mov    %esp,%ebp
  8032de:	53                   	push   %ebx
  8032df:	83 ec 0c             	sub    $0xc,%esp
  8032e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8032e5:	53                   	push   %ebx
  8032e6:	6a 00                	push   $0x0
  8032e8:	e8 9c f4 ff ff       	call   802789 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8032ed:	89 1c 24             	mov    %ebx,(%esp)
  8032f0:	e8 6f f7 ff ff       	call   802a64 <fd2data>
  8032f5:	83 c4 08             	add    $0x8,%esp
  8032f8:	50                   	push   %eax
  8032f9:	6a 00                	push   $0x0
  8032fb:	e8 89 f4 ff ff       	call   802789 <sys_page_unmap>
}
  803300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803303:	c9                   	leave  
  803304:	c3                   	ret    

00803305 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803305:	55                   	push   %ebp
  803306:	89 e5                	mov    %esp,%ebp
  803308:	57                   	push   %edi
  803309:	56                   	push   %esi
  80330a:	53                   	push   %ebx
  80330b:	83 ec 1c             	sub    $0x1c,%esp
  80330e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803311:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803313:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803318:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80331b:	83 ec 0c             	sub    $0xc,%esp
  80331e:	ff 75 e0             	pushl  -0x20(%ebp)
  803321:	e8 2c ff ff ff       	call   803252 <pageref>
  803326:	89 c3                	mov    %eax,%ebx
  803328:	89 3c 24             	mov    %edi,(%esp)
  80332b:	e8 22 ff ff ff       	call   803252 <pageref>
  803330:	83 c4 10             	add    $0x10,%esp
  803333:	39 c3                	cmp    %eax,%ebx
  803335:	0f 94 c1             	sete   %cl
  803338:	0f b6 c9             	movzbl %cl,%ecx
  80333b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80333e:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803344:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803347:	39 ce                	cmp    %ecx,%esi
  803349:	74 1b                	je     803366 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80334b:	39 c3                	cmp    %eax,%ebx
  80334d:	75 c4                	jne    803313 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80334f:	8b 42 58             	mov    0x58(%edx),%eax
  803352:	ff 75 e4             	pushl  -0x1c(%ebp)
  803355:	50                   	push   %eax
  803356:	56                   	push   %esi
  803357:	68 39 45 80 00       	push   $0x804539
  80335c:	e8 1b ea ff ff       	call   801d7c <cprintf>
  803361:	83 c4 10             	add    $0x10,%esp
  803364:	eb ad                	jmp    803313 <_pipeisclosed+0xe>
	}
}
  803366:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803369:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80336c:	5b                   	pop    %ebx
  80336d:	5e                   	pop    %esi
  80336e:	5f                   	pop    %edi
  80336f:	5d                   	pop    %ebp
  803370:	c3                   	ret    

00803371 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803371:	55                   	push   %ebp
  803372:	89 e5                	mov    %esp,%ebp
  803374:	57                   	push   %edi
  803375:	56                   	push   %esi
  803376:	53                   	push   %ebx
  803377:	83 ec 28             	sub    $0x28,%esp
  80337a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80337d:	56                   	push   %esi
  80337e:	e8 e1 f6 ff ff       	call   802a64 <fd2data>
  803383:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803385:	83 c4 10             	add    $0x10,%esp
  803388:	bf 00 00 00 00       	mov    $0x0,%edi
  80338d:	eb 4b                	jmp    8033da <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80338f:	89 da                	mov    %ebx,%edx
  803391:	89 f0                	mov    %esi,%eax
  803393:	e8 6d ff ff ff       	call   803305 <_pipeisclosed>
  803398:	85 c0                	test   %eax,%eax
  80339a:	75 48                	jne    8033e4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80339c:	e8 44 f3 ff ff       	call   8026e5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8033a1:	8b 43 04             	mov    0x4(%ebx),%eax
  8033a4:	8b 0b                	mov    (%ebx),%ecx
  8033a6:	8d 51 20             	lea    0x20(%ecx),%edx
  8033a9:	39 d0                	cmp    %edx,%eax
  8033ab:	73 e2                	jae    80338f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8033ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8033b0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8033b4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8033b7:	89 c2                	mov    %eax,%edx
  8033b9:	c1 fa 1f             	sar    $0x1f,%edx
  8033bc:	89 d1                	mov    %edx,%ecx
  8033be:	c1 e9 1b             	shr    $0x1b,%ecx
  8033c1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8033c4:	83 e2 1f             	and    $0x1f,%edx
  8033c7:	29 ca                	sub    %ecx,%edx
  8033c9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8033cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8033d1:	83 c0 01             	add    $0x1,%eax
  8033d4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8033d7:	83 c7 01             	add    $0x1,%edi
  8033da:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8033dd:	75 c2                	jne    8033a1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8033df:	8b 45 10             	mov    0x10(%ebp),%eax
  8033e2:	eb 05                	jmp    8033e9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8033e4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8033e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033ec:	5b                   	pop    %ebx
  8033ed:	5e                   	pop    %esi
  8033ee:	5f                   	pop    %edi
  8033ef:	5d                   	pop    %ebp
  8033f0:	c3                   	ret    

008033f1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8033f1:	55                   	push   %ebp
  8033f2:	89 e5                	mov    %esp,%ebp
  8033f4:	57                   	push   %edi
  8033f5:	56                   	push   %esi
  8033f6:	53                   	push   %ebx
  8033f7:	83 ec 18             	sub    $0x18,%esp
  8033fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8033fd:	57                   	push   %edi
  8033fe:	e8 61 f6 ff ff       	call   802a64 <fd2data>
  803403:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803405:	83 c4 10             	add    $0x10,%esp
  803408:	bb 00 00 00 00       	mov    $0x0,%ebx
  80340d:	eb 3d                	jmp    80344c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80340f:	85 db                	test   %ebx,%ebx
  803411:	74 04                	je     803417 <devpipe_read+0x26>
				return i;
  803413:	89 d8                	mov    %ebx,%eax
  803415:	eb 44                	jmp    80345b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803417:	89 f2                	mov    %esi,%edx
  803419:	89 f8                	mov    %edi,%eax
  80341b:	e8 e5 fe ff ff       	call   803305 <_pipeisclosed>
  803420:	85 c0                	test   %eax,%eax
  803422:	75 32                	jne    803456 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803424:	e8 bc f2 ff ff       	call   8026e5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803429:	8b 06                	mov    (%esi),%eax
  80342b:	3b 46 04             	cmp    0x4(%esi),%eax
  80342e:	74 df                	je     80340f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803430:	99                   	cltd   
  803431:	c1 ea 1b             	shr    $0x1b,%edx
  803434:	01 d0                	add    %edx,%eax
  803436:	83 e0 1f             	and    $0x1f,%eax
  803439:	29 d0                	sub    %edx,%eax
  80343b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803440:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803443:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  803446:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803449:	83 c3 01             	add    $0x1,%ebx
  80344c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80344f:	75 d8                	jne    803429 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803451:	8b 45 10             	mov    0x10(%ebp),%eax
  803454:	eb 05                	jmp    80345b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803456:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80345b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80345e:	5b                   	pop    %ebx
  80345f:	5e                   	pop    %esi
  803460:	5f                   	pop    %edi
  803461:	5d                   	pop    %ebp
  803462:	c3                   	ret    

00803463 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803463:	55                   	push   %ebp
  803464:	89 e5                	mov    %esp,%ebp
  803466:	56                   	push   %esi
  803467:	53                   	push   %ebx
  803468:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80346b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80346e:	50                   	push   %eax
  80346f:	e8 07 f6 ff ff       	call   802a7b <fd_alloc>
  803474:	83 c4 10             	add    $0x10,%esp
  803477:	89 c2                	mov    %eax,%edx
  803479:	85 c0                	test   %eax,%eax
  80347b:	0f 88 2c 01 00 00    	js     8035ad <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803481:	83 ec 04             	sub    $0x4,%esp
  803484:	68 07 04 00 00       	push   $0x407
  803489:	ff 75 f4             	pushl  -0xc(%ebp)
  80348c:	6a 00                	push   $0x0
  80348e:	e8 71 f2 ff ff       	call   802704 <sys_page_alloc>
  803493:	83 c4 10             	add    $0x10,%esp
  803496:	89 c2                	mov    %eax,%edx
  803498:	85 c0                	test   %eax,%eax
  80349a:	0f 88 0d 01 00 00    	js     8035ad <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8034a0:	83 ec 0c             	sub    $0xc,%esp
  8034a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8034a6:	50                   	push   %eax
  8034a7:	e8 cf f5 ff ff       	call   802a7b <fd_alloc>
  8034ac:	89 c3                	mov    %eax,%ebx
  8034ae:	83 c4 10             	add    $0x10,%esp
  8034b1:	85 c0                	test   %eax,%eax
  8034b3:	0f 88 e2 00 00 00    	js     80359b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034b9:	83 ec 04             	sub    $0x4,%esp
  8034bc:	68 07 04 00 00       	push   $0x407
  8034c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8034c4:	6a 00                	push   $0x0
  8034c6:	e8 39 f2 ff ff       	call   802704 <sys_page_alloc>
  8034cb:	89 c3                	mov    %eax,%ebx
  8034cd:	83 c4 10             	add    $0x10,%esp
  8034d0:	85 c0                	test   %eax,%eax
  8034d2:	0f 88 c3 00 00 00    	js     80359b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8034d8:	83 ec 0c             	sub    $0xc,%esp
  8034db:	ff 75 f4             	pushl  -0xc(%ebp)
  8034de:	e8 81 f5 ff ff       	call   802a64 <fd2data>
  8034e3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034e5:	83 c4 0c             	add    $0xc,%esp
  8034e8:	68 07 04 00 00       	push   $0x407
  8034ed:	50                   	push   %eax
  8034ee:	6a 00                	push   $0x0
  8034f0:	e8 0f f2 ff ff       	call   802704 <sys_page_alloc>
  8034f5:	89 c3                	mov    %eax,%ebx
  8034f7:	83 c4 10             	add    $0x10,%esp
  8034fa:	85 c0                	test   %eax,%eax
  8034fc:	0f 88 89 00 00 00    	js     80358b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803502:	83 ec 0c             	sub    $0xc,%esp
  803505:	ff 75 f0             	pushl  -0x10(%ebp)
  803508:	e8 57 f5 ff ff       	call   802a64 <fd2data>
  80350d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803514:	50                   	push   %eax
  803515:	6a 00                	push   $0x0
  803517:	56                   	push   %esi
  803518:	6a 00                	push   $0x0
  80351a:	e8 28 f2 ff ff       	call   802747 <sys_page_map>
  80351f:	89 c3                	mov    %eax,%ebx
  803521:	83 c4 20             	add    $0x20,%esp
  803524:	85 c0                	test   %eax,%eax
  803526:	78 55                	js     80357d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803528:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80352e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803531:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803533:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803536:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80353d:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803546:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803548:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80354b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803552:	83 ec 0c             	sub    $0xc,%esp
  803555:	ff 75 f4             	pushl  -0xc(%ebp)
  803558:	e8 f7 f4 ff ff       	call   802a54 <fd2num>
  80355d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803560:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803562:	83 c4 04             	add    $0x4,%esp
  803565:	ff 75 f0             	pushl  -0x10(%ebp)
  803568:	e8 e7 f4 ff ff       	call   802a54 <fd2num>
  80356d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803570:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803573:	83 c4 10             	add    $0x10,%esp
  803576:	ba 00 00 00 00       	mov    $0x0,%edx
  80357b:	eb 30                	jmp    8035ad <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80357d:	83 ec 08             	sub    $0x8,%esp
  803580:	56                   	push   %esi
  803581:	6a 00                	push   $0x0
  803583:	e8 01 f2 ff ff       	call   802789 <sys_page_unmap>
  803588:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80358b:	83 ec 08             	sub    $0x8,%esp
  80358e:	ff 75 f0             	pushl  -0x10(%ebp)
  803591:	6a 00                	push   $0x0
  803593:	e8 f1 f1 ff ff       	call   802789 <sys_page_unmap>
  803598:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80359b:	83 ec 08             	sub    $0x8,%esp
  80359e:	ff 75 f4             	pushl  -0xc(%ebp)
  8035a1:	6a 00                	push   $0x0
  8035a3:	e8 e1 f1 ff ff       	call   802789 <sys_page_unmap>
  8035a8:	83 c4 10             	add    $0x10,%esp
  8035ab:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8035ad:	89 d0                	mov    %edx,%eax
  8035af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8035b2:	5b                   	pop    %ebx
  8035b3:	5e                   	pop    %esi
  8035b4:	5d                   	pop    %ebp
  8035b5:	c3                   	ret    

008035b6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8035b6:	55                   	push   %ebp
  8035b7:	89 e5                	mov    %esp,%ebp
  8035b9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8035bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035bf:	50                   	push   %eax
  8035c0:	ff 75 08             	pushl  0x8(%ebp)
  8035c3:	e8 02 f5 ff ff       	call   802aca <fd_lookup>
  8035c8:	83 c4 10             	add    $0x10,%esp
  8035cb:	85 c0                	test   %eax,%eax
  8035cd:	78 18                	js     8035e7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8035cf:	83 ec 0c             	sub    $0xc,%esp
  8035d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8035d5:	e8 8a f4 ff ff       	call   802a64 <fd2data>
	return _pipeisclosed(fd, p);
  8035da:	89 c2                	mov    %eax,%edx
  8035dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035df:	e8 21 fd ff ff       	call   803305 <_pipeisclosed>
  8035e4:	83 c4 10             	add    $0x10,%esp
}
  8035e7:	c9                   	leave  
  8035e8:	c3                   	ret    

008035e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8035e9:	55                   	push   %ebp
  8035ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8035ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8035f1:	5d                   	pop    %ebp
  8035f2:	c3                   	ret    

008035f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8035f3:	55                   	push   %ebp
  8035f4:	89 e5                	mov    %esp,%ebp
  8035f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8035f9:	68 51 45 80 00       	push   $0x804551
  8035fe:	ff 75 0c             	pushl  0xc(%ebp)
  803601:	e8 fb ec ff ff       	call   802301 <strcpy>
	return 0;
}
  803606:	b8 00 00 00 00       	mov    $0x0,%eax
  80360b:	c9                   	leave  
  80360c:	c3                   	ret    

0080360d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80360d:	55                   	push   %ebp
  80360e:	89 e5                	mov    %esp,%ebp
  803610:	57                   	push   %edi
  803611:	56                   	push   %esi
  803612:	53                   	push   %ebx
  803613:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803619:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80361e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803624:	eb 2d                	jmp    803653 <devcons_write+0x46>
		m = n - tot;
  803626:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803629:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80362b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80362e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803633:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803636:	83 ec 04             	sub    $0x4,%esp
  803639:	53                   	push   %ebx
  80363a:	03 45 0c             	add    0xc(%ebp),%eax
  80363d:	50                   	push   %eax
  80363e:	57                   	push   %edi
  80363f:	e8 4f ee ff ff       	call   802493 <memmove>
		sys_cputs(buf, m);
  803644:	83 c4 08             	add    $0x8,%esp
  803647:	53                   	push   %ebx
  803648:	57                   	push   %edi
  803649:	e8 fa ef ff ff       	call   802648 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80364e:	01 de                	add    %ebx,%esi
  803650:	83 c4 10             	add    $0x10,%esp
  803653:	89 f0                	mov    %esi,%eax
  803655:	3b 75 10             	cmp    0x10(%ebp),%esi
  803658:	72 cc                	jb     803626 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80365a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80365d:	5b                   	pop    %ebx
  80365e:	5e                   	pop    %esi
  80365f:	5f                   	pop    %edi
  803660:	5d                   	pop    %ebp
  803661:	c3                   	ret    

00803662 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803662:	55                   	push   %ebp
  803663:	89 e5                	mov    %esp,%ebp
  803665:	83 ec 08             	sub    $0x8,%esp
  803668:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80366d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803671:	74 2a                	je     80369d <devcons_read+0x3b>
  803673:	eb 05                	jmp    80367a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803675:	e8 6b f0 ff ff       	call   8026e5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80367a:	e8 e7 ef ff ff       	call   802666 <sys_cgetc>
  80367f:	85 c0                	test   %eax,%eax
  803681:	74 f2                	je     803675 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803683:	85 c0                	test   %eax,%eax
  803685:	78 16                	js     80369d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803687:	83 f8 04             	cmp    $0x4,%eax
  80368a:	74 0c                	je     803698 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80368c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80368f:	88 02                	mov    %al,(%edx)
	return 1;
  803691:	b8 01 00 00 00       	mov    $0x1,%eax
  803696:	eb 05                	jmp    80369d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803698:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80369d:	c9                   	leave  
  80369e:	c3                   	ret    

0080369f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80369f:	55                   	push   %ebp
  8036a0:	89 e5                	mov    %esp,%ebp
  8036a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8036a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8036a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8036ab:	6a 01                	push   $0x1
  8036ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8036b0:	50                   	push   %eax
  8036b1:	e8 92 ef ff ff       	call   802648 <sys_cputs>
}
  8036b6:	83 c4 10             	add    $0x10,%esp
  8036b9:	c9                   	leave  
  8036ba:	c3                   	ret    

008036bb <getchar>:

int
getchar(void)
{
  8036bb:	55                   	push   %ebp
  8036bc:	89 e5                	mov    %esp,%ebp
  8036be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8036c1:	6a 01                	push   $0x1
  8036c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8036c6:	50                   	push   %eax
  8036c7:	6a 00                	push   $0x0
  8036c9:	e8 62 f6 ff ff       	call   802d30 <read>
	if (r < 0)
  8036ce:	83 c4 10             	add    $0x10,%esp
  8036d1:	85 c0                	test   %eax,%eax
  8036d3:	78 0f                	js     8036e4 <getchar+0x29>
		return r;
	if (r < 1)
  8036d5:	85 c0                	test   %eax,%eax
  8036d7:	7e 06                	jle    8036df <getchar+0x24>
		return -E_EOF;
	return c;
  8036d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8036dd:	eb 05                	jmp    8036e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8036df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8036e4:	c9                   	leave  
  8036e5:	c3                   	ret    

008036e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8036e6:	55                   	push   %ebp
  8036e7:	89 e5                	mov    %esp,%ebp
  8036e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8036ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8036ef:	50                   	push   %eax
  8036f0:	ff 75 08             	pushl  0x8(%ebp)
  8036f3:	e8 d2 f3 ff ff       	call   802aca <fd_lookup>
  8036f8:	83 c4 10             	add    $0x10,%esp
  8036fb:	85 c0                	test   %eax,%eax
  8036fd:	78 11                	js     803710 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8036ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803702:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803708:	39 10                	cmp    %edx,(%eax)
  80370a:	0f 94 c0             	sete   %al
  80370d:	0f b6 c0             	movzbl %al,%eax
}
  803710:	c9                   	leave  
  803711:	c3                   	ret    

00803712 <opencons>:

int
opencons(void)
{
  803712:	55                   	push   %ebp
  803713:	89 e5                	mov    %esp,%ebp
  803715:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803718:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80371b:	50                   	push   %eax
  80371c:	e8 5a f3 ff ff       	call   802a7b <fd_alloc>
  803721:	83 c4 10             	add    $0x10,%esp
		return r;
  803724:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803726:	85 c0                	test   %eax,%eax
  803728:	78 3e                	js     803768 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80372a:	83 ec 04             	sub    $0x4,%esp
  80372d:	68 07 04 00 00       	push   $0x407
  803732:	ff 75 f4             	pushl  -0xc(%ebp)
  803735:	6a 00                	push   $0x0
  803737:	e8 c8 ef ff ff       	call   802704 <sys_page_alloc>
  80373c:	83 c4 10             	add    $0x10,%esp
		return r;
  80373f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803741:	85 c0                	test   %eax,%eax
  803743:	78 23                	js     803768 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803745:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80374b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80374e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803753:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80375a:	83 ec 0c             	sub    $0xc,%esp
  80375d:	50                   	push   %eax
  80375e:	e8 f1 f2 ff ff       	call   802a54 <fd2num>
  803763:	89 c2                	mov    %eax,%edx
  803765:	83 c4 10             	add    $0x10,%esp
}
  803768:	89 d0                	mov    %edx,%eax
  80376a:	c9                   	leave  
  80376b:	c3                   	ret    
  80376c:	66 90                	xchg   %ax,%ax
  80376e:	66 90                	xchg   %ax,%ax

00803770 <__udivdi3>:
  803770:	55                   	push   %ebp
  803771:	57                   	push   %edi
  803772:	56                   	push   %esi
  803773:	53                   	push   %ebx
  803774:	83 ec 1c             	sub    $0x1c,%esp
  803777:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80377b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80377f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803783:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803787:	85 f6                	test   %esi,%esi
  803789:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80378d:	89 ca                	mov    %ecx,%edx
  80378f:	89 f8                	mov    %edi,%eax
  803791:	75 3d                	jne    8037d0 <__udivdi3+0x60>
  803793:	39 cf                	cmp    %ecx,%edi
  803795:	0f 87 c5 00 00 00    	ja     803860 <__udivdi3+0xf0>
  80379b:	85 ff                	test   %edi,%edi
  80379d:	89 fd                	mov    %edi,%ebp
  80379f:	75 0b                	jne    8037ac <__udivdi3+0x3c>
  8037a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8037a6:	31 d2                	xor    %edx,%edx
  8037a8:	f7 f7                	div    %edi
  8037aa:	89 c5                	mov    %eax,%ebp
  8037ac:	89 c8                	mov    %ecx,%eax
  8037ae:	31 d2                	xor    %edx,%edx
  8037b0:	f7 f5                	div    %ebp
  8037b2:	89 c1                	mov    %eax,%ecx
  8037b4:	89 d8                	mov    %ebx,%eax
  8037b6:	89 cf                	mov    %ecx,%edi
  8037b8:	f7 f5                	div    %ebp
  8037ba:	89 c3                	mov    %eax,%ebx
  8037bc:	89 d8                	mov    %ebx,%eax
  8037be:	89 fa                	mov    %edi,%edx
  8037c0:	83 c4 1c             	add    $0x1c,%esp
  8037c3:	5b                   	pop    %ebx
  8037c4:	5e                   	pop    %esi
  8037c5:	5f                   	pop    %edi
  8037c6:	5d                   	pop    %ebp
  8037c7:	c3                   	ret    
  8037c8:	90                   	nop
  8037c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037d0:	39 ce                	cmp    %ecx,%esi
  8037d2:	77 74                	ja     803848 <__udivdi3+0xd8>
  8037d4:	0f bd fe             	bsr    %esi,%edi
  8037d7:	83 f7 1f             	xor    $0x1f,%edi
  8037da:	0f 84 98 00 00 00    	je     803878 <__udivdi3+0x108>
  8037e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8037e5:	89 f9                	mov    %edi,%ecx
  8037e7:	89 c5                	mov    %eax,%ebp
  8037e9:	29 fb                	sub    %edi,%ebx
  8037eb:	d3 e6                	shl    %cl,%esi
  8037ed:	89 d9                	mov    %ebx,%ecx
  8037ef:	d3 ed                	shr    %cl,%ebp
  8037f1:	89 f9                	mov    %edi,%ecx
  8037f3:	d3 e0                	shl    %cl,%eax
  8037f5:	09 ee                	or     %ebp,%esi
  8037f7:	89 d9                	mov    %ebx,%ecx
  8037f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8037fd:	89 d5                	mov    %edx,%ebp
  8037ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  803803:	d3 ed                	shr    %cl,%ebp
  803805:	89 f9                	mov    %edi,%ecx
  803807:	d3 e2                	shl    %cl,%edx
  803809:	89 d9                	mov    %ebx,%ecx
  80380b:	d3 e8                	shr    %cl,%eax
  80380d:	09 c2                	or     %eax,%edx
  80380f:	89 d0                	mov    %edx,%eax
  803811:	89 ea                	mov    %ebp,%edx
  803813:	f7 f6                	div    %esi
  803815:	89 d5                	mov    %edx,%ebp
  803817:	89 c3                	mov    %eax,%ebx
  803819:	f7 64 24 0c          	mull   0xc(%esp)
  80381d:	39 d5                	cmp    %edx,%ebp
  80381f:	72 10                	jb     803831 <__udivdi3+0xc1>
  803821:	8b 74 24 08          	mov    0x8(%esp),%esi
  803825:	89 f9                	mov    %edi,%ecx
  803827:	d3 e6                	shl    %cl,%esi
  803829:	39 c6                	cmp    %eax,%esi
  80382b:	73 07                	jae    803834 <__udivdi3+0xc4>
  80382d:	39 d5                	cmp    %edx,%ebp
  80382f:	75 03                	jne    803834 <__udivdi3+0xc4>
  803831:	83 eb 01             	sub    $0x1,%ebx
  803834:	31 ff                	xor    %edi,%edi
  803836:	89 d8                	mov    %ebx,%eax
  803838:	89 fa                	mov    %edi,%edx
  80383a:	83 c4 1c             	add    $0x1c,%esp
  80383d:	5b                   	pop    %ebx
  80383e:	5e                   	pop    %esi
  80383f:	5f                   	pop    %edi
  803840:	5d                   	pop    %ebp
  803841:	c3                   	ret    
  803842:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803848:	31 ff                	xor    %edi,%edi
  80384a:	31 db                	xor    %ebx,%ebx
  80384c:	89 d8                	mov    %ebx,%eax
  80384e:	89 fa                	mov    %edi,%edx
  803850:	83 c4 1c             	add    $0x1c,%esp
  803853:	5b                   	pop    %ebx
  803854:	5e                   	pop    %esi
  803855:	5f                   	pop    %edi
  803856:	5d                   	pop    %ebp
  803857:	c3                   	ret    
  803858:	90                   	nop
  803859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803860:	89 d8                	mov    %ebx,%eax
  803862:	f7 f7                	div    %edi
  803864:	31 ff                	xor    %edi,%edi
  803866:	89 c3                	mov    %eax,%ebx
  803868:	89 d8                	mov    %ebx,%eax
  80386a:	89 fa                	mov    %edi,%edx
  80386c:	83 c4 1c             	add    $0x1c,%esp
  80386f:	5b                   	pop    %ebx
  803870:	5e                   	pop    %esi
  803871:	5f                   	pop    %edi
  803872:	5d                   	pop    %ebp
  803873:	c3                   	ret    
  803874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803878:	39 ce                	cmp    %ecx,%esi
  80387a:	72 0c                	jb     803888 <__udivdi3+0x118>
  80387c:	31 db                	xor    %ebx,%ebx
  80387e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803882:	0f 87 34 ff ff ff    	ja     8037bc <__udivdi3+0x4c>
  803888:	bb 01 00 00 00       	mov    $0x1,%ebx
  80388d:	e9 2a ff ff ff       	jmp    8037bc <__udivdi3+0x4c>
  803892:	66 90                	xchg   %ax,%ax
  803894:	66 90                	xchg   %ax,%ax
  803896:	66 90                	xchg   %ax,%ax
  803898:	66 90                	xchg   %ax,%ax
  80389a:	66 90                	xchg   %ax,%ax
  80389c:	66 90                	xchg   %ax,%ax
  80389e:	66 90                	xchg   %ax,%ax

008038a0 <__umoddi3>:
  8038a0:	55                   	push   %ebp
  8038a1:	57                   	push   %edi
  8038a2:	56                   	push   %esi
  8038a3:	53                   	push   %ebx
  8038a4:	83 ec 1c             	sub    $0x1c,%esp
  8038a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8038ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8038af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8038b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8038b7:	85 d2                	test   %edx,%edx
  8038b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8038bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8038c1:	89 f3                	mov    %esi,%ebx
  8038c3:	89 3c 24             	mov    %edi,(%esp)
  8038c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8038ca:	75 1c                	jne    8038e8 <__umoddi3+0x48>
  8038cc:	39 f7                	cmp    %esi,%edi
  8038ce:	76 50                	jbe    803920 <__umoddi3+0x80>
  8038d0:	89 c8                	mov    %ecx,%eax
  8038d2:	89 f2                	mov    %esi,%edx
  8038d4:	f7 f7                	div    %edi
  8038d6:	89 d0                	mov    %edx,%eax
  8038d8:	31 d2                	xor    %edx,%edx
  8038da:	83 c4 1c             	add    $0x1c,%esp
  8038dd:	5b                   	pop    %ebx
  8038de:	5e                   	pop    %esi
  8038df:	5f                   	pop    %edi
  8038e0:	5d                   	pop    %ebp
  8038e1:	c3                   	ret    
  8038e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8038e8:	39 f2                	cmp    %esi,%edx
  8038ea:	89 d0                	mov    %edx,%eax
  8038ec:	77 52                	ja     803940 <__umoddi3+0xa0>
  8038ee:	0f bd ea             	bsr    %edx,%ebp
  8038f1:	83 f5 1f             	xor    $0x1f,%ebp
  8038f4:	75 5a                	jne    803950 <__umoddi3+0xb0>
  8038f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8038fa:	0f 82 e0 00 00 00    	jb     8039e0 <__umoddi3+0x140>
  803900:	39 0c 24             	cmp    %ecx,(%esp)
  803903:	0f 86 d7 00 00 00    	jbe    8039e0 <__umoddi3+0x140>
  803909:	8b 44 24 08          	mov    0x8(%esp),%eax
  80390d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803911:	83 c4 1c             	add    $0x1c,%esp
  803914:	5b                   	pop    %ebx
  803915:	5e                   	pop    %esi
  803916:	5f                   	pop    %edi
  803917:	5d                   	pop    %ebp
  803918:	c3                   	ret    
  803919:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803920:	85 ff                	test   %edi,%edi
  803922:	89 fd                	mov    %edi,%ebp
  803924:	75 0b                	jne    803931 <__umoddi3+0x91>
  803926:	b8 01 00 00 00       	mov    $0x1,%eax
  80392b:	31 d2                	xor    %edx,%edx
  80392d:	f7 f7                	div    %edi
  80392f:	89 c5                	mov    %eax,%ebp
  803931:	89 f0                	mov    %esi,%eax
  803933:	31 d2                	xor    %edx,%edx
  803935:	f7 f5                	div    %ebp
  803937:	89 c8                	mov    %ecx,%eax
  803939:	f7 f5                	div    %ebp
  80393b:	89 d0                	mov    %edx,%eax
  80393d:	eb 99                	jmp    8038d8 <__umoddi3+0x38>
  80393f:	90                   	nop
  803940:	89 c8                	mov    %ecx,%eax
  803942:	89 f2                	mov    %esi,%edx
  803944:	83 c4 1c             	add    $0x1c,%esp
  803947:	5b                   	pop    %ebx
  803948:	5e                   	pop    %esi
  803949:	5f                   	pop    %edi
  80394a:	5d                   	pop    %ebp
  80394b:	c3                   	ret    
  80394c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803950:	8b 34 24             	mov    (%esp),%esi
  803953:	bf 20 00 00 00       	mov    $0x20,%edi
  803958:	89 e9                	mov    %ebp,%ecx
  80395a:	29 ef                	sub    %ebp,%edi
  80395c:	d3 e0                	shl    %cl,%eax
  80395e:	89 f9                	mov    %edi,%ecx
  803960:	89 f2                	mov    %esi,%edx
  803962:	d3 ea                	shr    %cl,%edx
  803964:	89 e9                	mov    %ebp,%ecx
  803966:	09 c2                	or     %eax,%edx
  803968:	89 d8                	mov    %ebx,%eax
  80396a:	89 14 24             	mov    %edx,(%esp)
  80396d:	89 f2                	mov    %esi,%edx
  80396f:	d3 e2                	shl    %cl,%edx
  803971:	89 f9                	mov    %edi,%ecx
  803973:	89 54 24 04          	mov    %edx,0x4(%esp)
  803977:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80397b:	d3 e8                	shr    %cl,%eax
  80397d:	89 e9                	mov    %ebp,%ecx
  80397f:	89 c6                	mov    %eax,%esi
  803981:	d3 e3                	shl    %cl,%ebx
  803983:	89 f9                	mov    %edi,%ecx
  803985:	89 d0                	mov    %edx,%eax
  803987:	d3 e8                	shr    %cl,%eax
  803989:	89 e9                	mov    %ebp,%ecx
  80398b:	09 d8                	or     %ebx,%eax
  80398d:	89 d3                	mov    %edx,%ebx
  80398f:	89 f2                	mov    %esi,%edx
  803991:	f7 34 24             	divl   (%esp)
  803994:	89 d6                	mov    %edx,%esi
  803996:	d3 e3                	shl    %cl,%ebx
  803998:	f7 64 24 04          	mull   0x4(%esp)
  80399c:	39 d6                	cmp    %edx,%esi
  80399e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8039a2:	89 d1                	mov    %edx,%ecx
  8039a4:	89 c3                	mov    %eax,%ebx
  8039a6:	72 08                	jb     8039b0 <__umoddi3+0x110>
  8039a8:	75 11                	jne    8039bb <__umoddi3+0x11b>
  8039aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8039ae:	73 0b                	jae    8039bb <__umoddi3+0x11b>
  8039b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8039b4:	1b 14 24             	sbb    (%esp),%edx
  8039b7:	89 d1                	mov    %edx,%ecx
  8039b9:	89 c3                	mov    %eax,%ebx
  8039bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8039bf:	29 da                	sub    %ebx,%edx
  8039c1:	19 ce                	sbb    %ecx,%esi
  8039c3:	89 f9                	mov    %edi,%ecx
  8039c5:	89 f0                	mov    %esi,%eax
  8039c7:	d3 e0                	shl    %cl,%eax
  8039c9:	89 e9                	mov    %ebp,%ecx
  8039cb:	d3 ea                	shr    %cl,%edx
  8039cd:	89 e9                	mov    %ebp,%ecx
  8039cf:	d3 ee                	shr    %cl,%esi
  8039d1:	09 d0                	or     %edx,%eax
  8039d3:	89 f2                	mov    %esi,%edx
  8039d5:	83 c4 1c             	add    $0x1c,%esp
  8039d8:	5b                   	pop    %ebx
  8039d9:	5e                   	pop    %esi
  8039da:	5f                   	pop    %edi
  8039db:	5d                   	pop    %ebp
  8039dc:	c3                   	ret    
  8039dd:	8d 76 00             	lea    0x0(%esi),%esi
  8039e0:	29 f9                	sub    %edi,%ecx
  8039e2:	19 d6                	sbb    %edx,%esi
  8039e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8039e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8039ec:	e9 18 ff ff ff       	jmp    803909 <__umoddi3+0x69>
