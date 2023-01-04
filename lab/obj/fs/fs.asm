
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
  80002c:	e8 f6 19 00 00       	call   801a27 <libmain>
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
  8000b2:	68 e0 37 80 00       	push   $0x8037e0
  8000b7:	e8 a4 1a 00 00       	call   801b60 <cprintf>
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
  8000d4:	68 f7 37 80 00       	push   $0x8037f7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 07 38 80 00       	push   $0x803807
  8000e0:	e8 a2 19 00 00       	call   801a87 <_panic>
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
  800106:	68 10 38 80 00       	push   $0x803810
  80010b:	68 1d 38 80 00       	push   $0x80381d
  800110:	6a 44                	push   $0x44
  800112:	68 07 38 80 00       	push   $0x803807
  800117:	e8 6b 19 00 00       	call   801a87 <_panic>

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
  8001ca:	68 10 38 80 00       	push   $0x803810
  8001cf:	68 1d 38 80 00       	push   $0x80381d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 07 38 80 00       	push   $0x803807
  8001db:	e8 a7 18 00 00       	call   801a87 <_panic>

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
  80029e:	68 34 38 80 00       	push   $0x803834
  8002a3:	6a 27                	push   $0x27
  8002a5:	68 10 39 80 00       	push   $0x803910
  8002aa:	e8 d8 17 00 00       	call   801a87 <_panic>
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
  8002be:	68 64 38 80 00       	push   $0x803864
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 10 39 80 00       	push   $0x803910
  8002ca:	e8 b8 17 00 00       	call   801a87 <_panic>
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
  8002df:	e8 04 22 00 00       	call   8024e8 <sys_page_alloc>
	if (r < 0)
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	79 12                	jns    8002fd <bc_pgfault+0x89>
		panic("bc_pgfault: sys_page_alloc: %e", r);
  8002eb:	50                   	push   %eax
  8002ec:	68 88 38 80 00       	push   $0x803888
  8002f1:	6a 38                	push   $0x38
  8002f3:	68 10 39 80 00       	push   $0x803910
  8002f8:	e8 8a 17 00 00       	call   801a87 <_panic>

	r =	ide_read(blockno * 8, base_addr, 8);
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
  800318:	68 18 39 80 00       	push   $0x803918
  80031d:	6a 3c                	push   $0x3c
  80031f:	68 10 39 80 00       	push   $0x803910
  800324:	e8 5e 17 00 00       	call   801a87 <_panic>

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
  800344:	e8 e2 21 00 00       	call   80252b <sys_page_map>
  800349:	83 c4 20             	add    $0x20,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 12                	jns    800362 <bc_pgfault+0xee>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800350:	50                   	push   %eax
  800351:	68 a8 38 80 00       	push   $0x8038a8
  800356:	6a 41                	push   $0x41
  800358:	68 10 39 80 00       	push   $0x803910
  80035d:	e8 25 17 00 00       	call   801a87 <_panic>

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
  80037c:	68 31 39 80 00       	push   $0x803931
  800381:	6a 47                	push   $0x47
  800383:	68 10 39 80 00       	push   $0x803910
  800388:	e8 fa 16 00 00       	call   801a87 <_panic>
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
  8003b2:	68 c8 38 80 00       	push   $0x8038c8
  8003b7:	6a 09                	push   $0x9
  8003b9:	68 10 39 80 00       	push   $0x803910
  8003be:	e8 c4 16 00 00       	call   801a87 <_panic>
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
  800429:	68 4a 39 80 00       	push   $0x80394a
  80042e:	6a 57                	push   $0x57
  800430:	68 10 39 80 00       	push   $0x803910
  800435:	e8 4d 16 00 00       	call   801a87 <_panic>

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
  800486:	68 65 39 80 00       	push   $0x803965
  80048b:	6a 63                	push   $0x63
  80048d:	68 10 39 80 00       	push   $0x803910
  800492:	e8 f0 15 00 00       	call   801a87 <_panic>

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
  8004b0:	e8 76 20 00 00       	call   80252b <sys_page_map>
	if (r < 0)
  8004b5:	83 c4 20             	add    $0x20,%esp
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	79 12                	jns    8004ce <flush_block+0xbb>
		panic("flush_block: sys_page_map: %e", r);
  8004bc:	50                   	push   %eax
  8004bd:	68 80 39 80 00       	push   $0x803980
  8004c2:	6a 67                	push   $0x67
  8004c4:	68 10 39 80 00       	push   $0x803910
  8004c9:	e8 b9 15 00 00       	call   801a87 <_panic>

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
  8004e4:	e8 f0 21 00 00       	call   8026d9 <set_pgfault_handler>
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
  800505:	e8 6d 1d 00 00       	call   802277 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80050a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800511:	e8 7f fe ff ff       	call   800395 <diskaddr>
  800516:	83 c4 08             	add    $0x8,%esp
  800519:	68 9e 39 80 00       	push   $0x80399e
  80051e:	50                   	push   %eax
  80051f:	e8 c1 1b 00 00       	call   8020e5 <strcpy>
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
  800553:	68 c0 39 80 00       	push   $0x8039c0
  800558:	68 1d 38 80 00       	push   $0x80381d
  80055d:	6a 78                	push   $0x78
  80055f:	68 10 39 80 00       	push   $0x803910
  800564:	e8 1e 15 00 00       	call   801a87 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	6a 01                	push   $0x1
  80056e:	e8 22 fe ff ff       	call   800395 <diskaddr>
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 80 fe ff ff       	call   8003fb <va_is_dirty>
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	84 c0                	test   %al,%al
  800580:	74 16                	je     800598 <bc_init+0xc3>
  800582:	68 a5 39 80 00       	push   $0x8039a5
  800587:	68 1d 38 80 00       	push   $0x80381d
  80058c:	6a 79                	push   $0x79
  80058e:	68 10 39 80 00       	push   $0x803910
  800593:	e8 ef 14 00 00       	call   801a87 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	6a 01                	push   $0x1
  80059d:	e8 f3 fd ff ff       	call   800395 <diskaddr>
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	50                   	push   %eax
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 c0 1f 00 00       	call   80256d <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b4:	e8 dc fd ff ff       	call   800395 <diskaddr>
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 0c fe ff ff       	call   8003cd <va_is_mapped>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	84 c0                	test   %al,%al
  8005c6:	74 16                	je     8005de <bc_init+0x109>
  8005c8:	68 bf 39 80 00       	push   $0x8039bf
  8005cd:	68 1d 38 80 00       	push   $0x80381d
  8005d2:	6a 7d                	push   $0x7d
  8005d4:	68 10 39 80 00       	push   $0x803910
  8005d9:	e8 a9 14 00 00       	call   801a87 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	6a 01                	push   $0x1
  8005e3:	e8 ad fd ff ff       	call   800395 <diskaddr>
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	68 9e 39 80 00       	push   $0x80399e
  8005f0:	50                   	push   %eax
  8005f1:	e8 99 1b 00 00       	call   80218f <strcmp>
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	74 19                	je     800616 <bc_init+0x141>
  8005fd:	68 ec 38 80 00       	push   $0x8038ec
  800602:	68 1d 38 80 00       	push   $0x80381d
  800607:	68 80 00 00 00       	push   $0x80
  80060c:	68 10 39 80 00       	push   $0x803910
  800611:	e8 71 14 00 00       	call   801a87 <_panic>

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
  800630:	e8 42 1c 00 00       	call   802277 <memmove>
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
  80065f:	e8 13 1c 00 00       	call   802277 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066b:	e8 25 fd ff ff       	call   800395 <diskaddr>
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	68 9e 39 80 00       	push   $0x80399e
  800678:	50                   	push   %eax
  800679:	e8 67 1a 00 00       	call   8020e5 <strcpy>

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
  8006b0:	68 c0 39 80 00       	push   $0x8039c0
  8006b5:	68 1d 38 80 00       	push   $0x80381d
  8006ba:	68 91 00 00 00       	push   $0x91
  8006bf:	68 10 39 80 00       	push   $0x803910
  8006c4:	e8 be 13 00 00       	call   801a87 <_panic>
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
  8006d9:	e8 8f 1e 00 00       	call   80256d <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e5:	e8 ab fc ff ff       	call   800395 <diskaddr>
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	e8 db fc ff ff       	call   8003cd <va_is_mapped>
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	84 c0                	test   %al,%al
  8006f7:	74 19                	je     800712 <bc_init+0x23d>
  8006f9:	68 bf 39 80 00       	push   $0x8039bf
  8006fe:	68 1d 38 80 00       	push   $0x80381d
  800703:	68 99 00 00 00       	push   $0x99
  800708:	68 10 39 80 00       	push   $0x803910
  80070d:	e8 75 13 00 00       	call   801a87 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800712:	83 ec 0c             	sub    $0xc,%esp
  800715:	6a 01                	push   $0x1
  800717:	e8 79 fc ff ff       	call   800395 <diskaddr>
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	68 9e 39 80 00       	push   $0x80399e
  800724:	50                   	push   %eax
  800725:	e8 65 1a 00 00       	call   80218f <strcmp>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 19                	je     80074a <bc_init+0x275>
  800731:	68 ec 38 80 00       	push   $0x8038ec
  800736:	68 1d 38 80 00       	push   $0x80381d
  80073b:	68 9c 00 00 00       	push   $0x9c
  800740:	68 10 39 80 00       	push   $0x803910
  800745:	e8 3d 13 00 00       	call   801a87 <_panic>

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
  800764:	e8 0e 1b 00 00       	call   802277 <memmove>
	flush_block(diskaddr(1));
  800769:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800770:	e8 20 fc ff ff       	call   800395 <diskaddr>
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 96 fc ff ff       	call   800413 <flush_block>

	cprintf("block cache is good\n");
  80077d:	c7 04 24 da 39 80 00 	movl   $0x8039da,(%esp)
  800784:	e8 d7 13 00 00       	call   801b60 <cprintf>
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
  8007a5:	e8 cd 1a 00 00       	call   802277 <memmove>
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
  8007c8:	68 ef 39 80 00       	push   $0x8039ef
  8007cd:	6a 0f                	push   $0xf
  8007cf:	68 0c 3a 80 00       	push   $0x803a0c
  8007d4:	e8 ae 12 00 00       	call   801a87 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007d9:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007e0:	76 14                	jbe    8007f6 <check_super+0x44>
		panic("file system is too large");
  8007e2:	83 ec 04             	sub    $0x4,%esp
  8007e5:	68 14 3a 80 00       	push   $0x803a14
  8007ea:	6a 12                	push   $0x12
  8007ec:	68 0c 3a 80 00       	push   $0x803a0c
  8007f1:	e8 91 12 00 00       	call   801a87 <_panic>

	cprintf("superblock is good\n");
  8007f6:	83 ec 0c             	sub    $0xc,%esp
  8007f9:	68 2d 3a 80 00       	push   $0x803a2d
  8007fe:	e8 5d 13 00 00       	call   801b60 <cprintf>
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
  800856:	68 41 3a 80 00       	push   $0x803a41
  80085b:	6a 2d                	push   $0x2d
  80085d:	68 0c 3a 80 00       	push   $0x803a0c
  800862:	e8 20 12 00 00       	call   801a87 <_panic>
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
  800900:	83 ec 0c             	sub    $0xc,%esp
  800903:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// LAB 5: Your code here.
    //    panic("file_block_walk not implemented");

	if (filebno >= NDIRECT + NINDIRECT)
  800906:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80090c:	0f 87 93 00 00 00    	ja     8009a5 <file_block_walk+0xab>
		return -E_INVAL;

	// direct block
	if (filebno < NDIRECT) {
  800912:	83 fa 09             	cmp    $0x9,%edx
  800915:	77 1b                	ja     800932 <file_block_walk+0x38>
		if (ppdiskbno != 0)
  800917:	85 c9                	test   %ecx,%ecx
  800919:	0f 84 8d 00 00 00    	je     8009ac <file_block_walk+0xb2>
			*ppdiskbno = &f->f_direct[filebno];
  80091f:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  800926:	89 01                	mov    %eax,(%ecx)
		return 0;
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	e9 94 00 00 00       	jmp    8009c6 <file_block_walk+0xcc>
	}

	// indirect block, allocated
	if (f->f_indirect != 0) {
  800932:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  800939:	74 12                	je     80094d <file_block_walk+0x53>
		if (ppdiskbno != 0)
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	74 74                	je     8009b3 <file_block_walk+0xb9>
			*ppdiskbno = &f->f_indirect;
  80093f:	05 b0 00 00 00       	add    $0xb0,%eax
  800944:	89 01                	mov    %eax,(%ecx)
		return 0;
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	eb 79                	jmp    8009c6 <file_block_walk+0xcc>
	}
	else {

		// not allocated
		if (alloc == 0)
  80094d:	84 db                	test   %bl,%bl
  80094f:	74 69                	je     8009ba <file_block_walk+0xc0>
  800951:	89 ce                	mov    %ecx,%esi
  800953:	89 c3                	mov    %eax,%ebx
			return -E_NOT_FOUND;
		
		int blockno = alloc_block();
  800955:	e8 27 ff ff ff       	call   800881 <alloc_block>
  80095a:	89 c7                	mov    %eax,%edi

		if (blockno < 0)
  80095c:	85 c0                	test   %eax,%eax
  80095e:	78 66                	js     8009c6 <file_block_walk+0xcc>
			return blockno; // E_NO_DISK

		// cprintf("[?] %d\n", blockno);
		
		f->f_indirect = blockno;
  800960:	89 83 b0 00 00 00    	mov    %eax,0xb0(%ebx)

		// flush to disk
		memset(diskaddr(blockno), 0, 512);
  800966:	83 ec 0c             	sub    $0xc,%esp
  800969:	50                   	push   %eax
  80096a:	e8 26 fa ff ff       	call   800395 <diskaddr>
  80096f:	83 c4 0c             	add    $0xc,%esp
  800972:	68 00 02 00 00       	push   $0x200
  800977:	6a 00                	push   $0x0
  800979:	50                   	push   %eax
  80097a:	e8 ab 18 00 00       	call   80222a <memset>
		flush_block(diskaddr(blockno));
  80097f:	89 3c 24             	mov    %edi,(%esp)
  800982:	e8 0e fa ff ff       	call   800395 <diskaddr>
  800987:	89 04 24             	mov    %eax,(%esp)
  80098a:	e8 84 fa ff ff       	call   800413 <flush_block>

		if (ppdiskbno != 0)
  80098f:	83 c4 10             	add    $0x10,%esp
  800992:	85 f6                	test   %esi,%esi
  800994:	74 2b                	je     8009c1 <file_block_walk+0xc7>
			*ppdiskbno = &f->f_indirect;
  800996:	8d 83 b0 00 00 00    	lea    0xb0(%ebx),%eax
  80099c:	89 06                	mov    %eax,(%esi)
		return 0;
  80099e:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a3:	eb 21                	jmp    8009c6 <file_block_walk+0xcc>
{
	// LAB 5: Your code here.
    //    panic("file_block_walk not implemented");

	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  8009a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009aa:	eb 1a                	jmp    8009c6 <file_block_walk+0xcc>

	// direct block
	if (filebno < NDIRECT) {
		if (ppdiskbno != 0)
			*ppdiskbno = &f->f_direct[filebno];
		return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb 13                	jmp    8009c6 <file_block_walk+0xcc>

	// indirect block, allocated
	if (f->f_indirect != 0) {
		if (ppdiskbno != 0)
			*ppdiskbno = &f->f_indirect;
		return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b8:	eb 0c                	jmp    8009c6 <file_block_walk+0xcc>
	}
	else {

		// not allocated
		if (alloc == 0)
			return -E_NOT_FOUND;
  8009ba:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8009bf:	eb 05                	jmp    8009c6 <file_block_walk+0xcc>
		memset(diskaddr(blockno), 0, 512);
		flush_block(diskaddr(blockno));

		if (ppdiskbno != 0)
			*ppdiskbno = &f->f_indirect;
		return 0;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
  8009c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	5f                   	pop    %edi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009d3:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8009d8:	8b 70 04             	mov    0x4(%eax),%esi
  8009db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009e0:	eb 29                	jmp    800a0b <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  8009e2:	8d 43 02             	lea    0x2(%ebx),%eax
  8009e5:	50                   	push   %eax
  8009e6:	e8 1d fe ff ff       	call   800808 <block_is_free>
  8009eb:	83 c4 04             	add    $0x4,%esp
  8009ee:	84 c0                	test   %al,%al
  8009f0:	74 16                	je     800a08 <check_bitmap+0x3a>
  8009f2:	68 5c 3a 80 00       	push   $0x803a5c
  8009f7:	68 1d 38 80 00       	push   $0x80381d
  8009fc:	6a 60                	push   $0x60
  8009fe:	68 0c 3a 80 00       	push   $0x803a0c
  800a03:	e8 7f 10 00 00       	call   801a87 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a08:	83 c3 01             	add    $0x1,%ebx
  800a0b:	89 d8                	mov    %ebx,%eax
  800a0d:	c1 e0 0f             	shl    $0xf,%eax
  800a10:	39 f0                	cmp    %esi,%eax
  800a12:	72 ce                	jb     8009e2 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	6a 00                	push   $0x0
  800a19:	e8 ea fd ff ff       	call   800808 <block_is_free>
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	84 c0                	test   %al,%al
  800a23:	74 16                	je     800a3b <check_bitmap+0x6d>
  800a25:	68 70 3a 80 00       	push   $0x803a70
  800a2a:	68 1d 38 80 00       	push   $0x80381d
  800a2f:	6a 63                	push   $0x63
  800a31:	68 0c 3a 80 00       	push   $0x803a0c
  800a36:	e8 4c 10 00 00       	call   801a87 <_panic>
	assert(!block_is_free(1));
  800a3b:	83 ec 0c             	sub    $0xc,%esp
  800a3e:	6a 01                	push   $0x1
  800a40:	e8 c3 fd ff ff       	call   800808 <block_is_free>
  800a45:	83 c4 10             	add    $0x10,%esp
  800a48:	84 c0                	test   %al,%al
  800a4a:	74 16                	je     800a62 <check_bitmap+0x94>
  800a4c:	68 82 3a 80 00       	push   $0x803a82
  800a51:	68 1d 38 80 00       	push   $0x80381d
  800a56:	6a 64                	push   $0x64
  800a58:	68 0c 3a 80 00       	push   $0x803a0c
  800a5d:	e8 25 10 00 00       	call   801a87 <_panic>

	cprintf("bitmap is good\n");
  800a62:	83 ec 0c             	sub    $0xc,%esp
  800a65:	68 94 3a 80 00       	push   $0x803a94
  800a6a:	e8 f1 10 00 00       	call   801b60 <cprintf>
}
  800a6f:	83 c4 10             	add    $0x10,%esp
  800a72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800a7f:	e8 db f5 ff ff       	call   80005f <ide_probe_disk1>
  800a84:	84 c0                	test   %al,%al
  800a86:	74 0f                	je     800a97 <fs_init+0x1e>
		ide_set_disk(1);
  800a88:	83 ec 0c             	sub    $0xc,%esp
  800a8b:	6a 01                	push   $0x1
  800a8d:	e8 31 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a92:	83 c4 10             	add    $0x10,%esp
  800a95:	eb 0d                	jmp    800aa4 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800a97:	83 ec 0c             	sub    $0xc,%esp
  800a9a:	6a 00                	push   $0x0
  800a9c:	e8 22 f6 ff ff       	call   8000c3 <ide_set_disk>
  800aa1:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800aa4:	e8 2c fa ff ff       	call   8004d5 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	6a 01                	push   $0x1
  800aae:	e8 e2 f8 ff ff       	call   800395 <diskaddr>
  800ab3:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800ab8:	e8 f5 fc ff ff       	call   8007b2 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800abd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ac4:	e8 cc f8 ff ff       	call   800395 <diskaddr>
  800ac9:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800ace:	e8 fb fe ff ff       	call   8009ce <check_bitmap>
	
}
  800ad3:	83 c4 10             	add    $0x10,%esp
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	53                   	push   %ebx
  800adc:	83 ec 20             	sub    $0x20,%esp
    //    panic("file_get_block not implemented");

	uint32_t *ppdiskbno;
	int blockno = 0;

	int r = file_block_walk(f, filebno, &ppdiskbno, 1);
  800adf:	6a 01                	push   $0x1
  800ae1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800ae4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	e8 0b fe ff ff       	call   8008fa <file_block_walk>
	if (r < 0)
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	85 c0                	test   %eax,%eax
  800af4:	78 5e                	js     800b54 <file_get_block+0x7c>
		return r;
	
	// not allocated yet
	if (*ppdiskbno == 0) {
  800af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af9:	83 38 00             	cmpl   $0x0,(%eax)
  800afc:	75 3c                	jne    800b3a <file_get_block+0x62>
		
		blockno = alloc_block();
  800afe:	e8 7e fd ff ff       	call   800881 <alloc_block>
  800b03:	89 c3                	mov    %eax,%ebx

		// cprintf("[?] %d\n", blockno);

		if (blockno < 0)
  800b05:	85 c0                	test   %eax,%eax
  800b07:	78 4b                	js     800b54 <file_get_block+0x7c>
			return blockno;
		
		*ppdiskbno = blockno;
  800b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b0c:	89 18                	mov    %ebx,(%eax)

		// flush to disk
		memset(diskaddr(blockno), 0, 512);
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	53                   	push   %ebx
  800b12:	e8 7e f8 ff ff       	call   800395 <diskaddr>
  800b17:	83 c4 0c             	add    $0xc,%esp
  800b1a:	68 00 02 00 00       	push   $0x200
  800b1f:	6a 00                	push   $0x0
  800b21:	50                   	push   %eax
  800b22:	e8 03 17 00 00       	call   80222a <memset>
		flush_block(diskaddr(blockno));
  800b27:	89 1c 24             	mov    %ebx,(%esp)
  800b2a:	e8 66 f8 ff ff       	call   800395 <diskaddr>
  800b2f:	89 04 24             	mov    %eax,(%esp)
  800b32:	e8 dc f8 ff ff       	call   800413 <flush_block>
  800b37:	83 c4 10             	add    $0x10,%esp
	}

	// cprintf("[?] %d\n", blockno);

	*blk = diskaddr(*ppdiskbno);
  800b3a:	83 ec 0c             	sub    $0xc,%esp
  800b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b40:	ff 30                	pushl  (%eax)
  800b42:	e8 4e f8 ff ff       	call   800395 <diskaddr>
  800b47:	8b 55 10             	mov    0x10(%ebp),%edx
  800b4a:	89 02                	mov    %eax,(%edx)
	return 0;
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax

}
  800b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800b65:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800b6b:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800b71:	eb 03                	jmp    800b76 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b73:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b76:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b79:	74 f8                	je     800b73 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800b7b:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800b81:	83 c1 08             	add    $0x8,%ecx
  800b84:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800b8a:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b91:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b97:	85 c9                	test   %ecx,%ecx
  800b99:	74 06                	je     800ba1 <walk_path+0x48>
		*pdir = 0;
  800b9b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800ba1:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800ba7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800bb2:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800bb8:	e9 5f 01 00 00       	jmp    800d1c <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800bbd:	83 c7 01             	add    $0x1,%edi
  800bc0:	eb 02                	jmp    800bc4 <walk_path+0x6b>
  800bc2:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800bc4:	0f b6 17             	movzbl (%edi),%edx
  800bc7:	80 fa 2f             	cmp    $0x2f,%dl
  800bca:	74 04                	je     800bd0 <walk_path+0x77>
  800bcc:	84 d2                	test   %dl,%dl
  800bce:	75 ed                	jne    800bbd <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800bd0:	89 fb                	mov    %edi,%ebx
  800bd2:	29 c3                	sub    %eax,%ebx
  800bd4:	83 fb 7f             	cmp    $0x7f,%ebx
  800bd7:	0f 8f 69 01 00 00    	jg     800d46 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800bdd:	83 ec 04             	sub    $0x4,%esp
  800be0:	53                   	push   %ebx
  800be1:	50                   	push   %eax
  800be2:	56                   	push   %esi
  800be3:	e8 8f 16 00 00       	call   802277 <memmove>
		name[path - p] = '\0';
  800be8:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800bef:	00 
  800bf0:	83 c4 10             	add    $0x10,%esp
  800bf3:	eb 03                	jmp    800bf8 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800bf5:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800bf8:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800bfb:	74 f8                	je     800bf5 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800bfd:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800c03:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c0a:	0f 85 3d 01 00 00    	jne    800d4d <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800c10:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800c16:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800c1b:	74 19                	je     800c36 <walk_path+0xdd>
  800c1d:	68 a4 3a 80 00       	push   $0x803aa4
  800c22:	68 1d 38 80 00       	push   $0x80381d
  800c27:	68 01 01 00 00       	push   $0x101
  800c2c:	68 0c 3a 80 00       	push   $0x803a0c
  800c31:	e8 51 0e 00 00       	call   801a87 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800c36:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	0f 48 c2             	cmovs  %edx,%eax
  800c41:	c1 f8 0c             	sar    $0xc,%eax
  800c44:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800c4a:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800c51:	00 00 00 
  800c54:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800c5a:	eb 5e                	jmp    800cba <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800c5c:	83 ec 04             	sub    $0x4,%esp
  800c5f:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c65:	50                   	push   %eax
  800c66:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800c6c:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800c72:	e8 61 fe ff ff       	call   800ad8 <file_get_block>
  800c77:	83 c4 10             	add    $0x10,%esp
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	0f 88 ee 00 00 00    	js     800d70 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800c82:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800c88:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800c8e:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800c94:	83 ec 08             	sub    $0x8,%esp
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	e8 f1 14 00 00       	call   80218f <strcmp>
  800c9e:	83 c4 10             	add    $0x10,%esp
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	0f 84 ab 00 00 00    	je     800d54 <walk_path+0x1fb>
  800ca9:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800caf:	39 fb                	cmp    %edi,%ebx
  800cb1:	75 db                	jne    800c8e <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800cb3:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800cba:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800cc0:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800cc6:	75 94                	jne    800c5c <walk_path+0x103>
  800cc8:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800cce:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800cd3:	80 3f 00             	cmpb   $0x0,(%edi)
  800cd6:	0f 85 a3 00 00 00    	jne    800d7f <walk_path+0x226>
				if (pdir)
  800cdc:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	74 08                	je     800cee <walk_path+0x195>
					*pdir = dir;
  800ce6:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800cec:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800cee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800cf2:	74 15                	je     800d09 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800cf4:	83 ec 08             	sub    $0x8,%esp
  800cf7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800cfd:	50                   	push   %eax
  800cfe:	ff 75 08             	pushl  0x8(%ebp)
  800d01:	e8 df 13 00 00       	call   8020e5 <strcpy>
  800d06:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800d09:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800d15:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d1a:	eb 63                	jmp    800d7f <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800d1c:	80 38 00             	cmpb   $0x0,(%eax)
  800d1f:	0f 85 9d fe ff ff    	jne    800bc2 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800d25:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	74 02                	je     800d31 <walk_path+0x1d8>
		*pdir = dir;
  800d2f:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800d31:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d37:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d3d:	89 08                	mov    %ecx,(%eax)
	return 0;
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d44:	eb 39                	jmp    800d7f <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800d46:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d4b:	eb 32                	jmp    800d7f <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800d4d:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d52:	eb 2b                	jmp    800d7f <walk_path+0x226>
  800d54:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800d5a:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800d60:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800d66:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800d6c:	89 f8                	mov    %edi,%eax
  800d6e:	eb ac                	jmp    800d1c <walk_path+0x1c3>
  800d70:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d76:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d79:	0f 84 4f ff ff ff    	je     800cce <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800d8d:	6a 00                	push   $0x0
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	ba 00 00 00 00       	mov    $0x0,%edx
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	e8 ba fd ff ff       	call   800b59 <walk_path>
}
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 2c             	sub    $0x2c,%esp
  800daa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dad:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800dbe:	39 ca                	cmp    %ecx,%edx
  800dc0:	7e 7c                	jle    800e3e <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800dc2:	29 ca                	sub    %ecx,%edx
  800dc4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dc7:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800dcb:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800dce:	89 ce                	mov    %ecx,%esi
  800dd0:	01 d1                	add    %edx,%ecx
  800dd2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800dd5:	eb 5d                	jmp    800e34 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800dd7:	83 ec 04             	sub    $0x4,%esp
  800dda:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ddd:	50                   	push   %eax
  800dde:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800de4:	85 f6                	test   %esi,%esi
  800de6:	0f 49 c6             	cmovns %esi,%eax
  800de9:	c1 f8 0c             	sar    $0xc,%eax
  800dec:	50                   	push   %eax
  800ded:	ff 75 08             	pushl  0x8(%ebp)
  800df0:	e8 e3 fc ff ff       	call   800ad8 <file_get_block>
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	78 42                	js     800e3e <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800dfc:	89 f2                	mov    %esi,%edx
  800dfe:	c1 fa 1f             	sar    $0x1f,%edx
  800e01:	c1 ea 14             	shr    $0x14,%edx
  800e04:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e07:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e0c:	29 d0                	sub    %edx,%eax
  800e0e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e11:	29 da                	sub    %ebx,%edx
  800e13:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800e18:	29 c3                	sub    %eax,%ebx
  800e1a:	39 da                	cmp    %ebx,%edx
  800e1c:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	53                   	push   %ebx
  800e23:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e26:	50                   	push   %eax
  800e27:	57                   	push   %edi
  800e28:	e8 4a 14 00 00       	call   802277 <memmove>
		pos += bn;
  800e2d:	01 de                	add    %ebx,%esi
		buf += bn;
  800e2f:	01 df                	add    %ebx,%edi
  800e31:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800e34:	89 f3                	mov    %esi,%ebx
  800e36:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e39:	77 9c                	ja     800dd7 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 2c             	sub    $0x2c,%esp
  800e4f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800e52:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e58:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800e5b:	0f 8e a7 00 00 00    	jle    800f08 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e61:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e67:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e6c:	0f 49 f8             	cmovns %eax,%edi
  800e6f:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e75:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7d:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800e83:	0f 49 c2             	cmovns %edx,%eax
  800e86:	c1 f8 0c             	sar    $0xc,%eax
  800e89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e8c:	89 c3                	mov    %eax,%ebx
  800e8e:	eb 39                	jmp    800ec9 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	6a 00                	push   $0x0
  800e95:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800e98:	89 da                	mov    %ebx,%edx
  800e9a:	89 f0                	mov    %esi,%eax
  800e9c:	e8 59 fa ff ff       	call   8008fa <file_block_walk>
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 4d                	js     800ef5 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800ea8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eab:	8b 00                	mov    (%eax),%eax
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	74 15                	je     800ec6 <file_set_size+0x80>
		free_block(*ptr);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	50                   	push   %eax
  800eb5:	e8 8b f9 ff ff       	call   800845 <free_block>
		*ptr = 0;
  800eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ebd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800ec3:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ec6:	83 c3 01             	add    $0x1,%ebx
  800ec9:	39 df                	cmp    %ebx,%edi
  800ecb:	77 c3                	ja     800e90 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800ecd:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800ed1:	77 35                	ja     800f08 <file_set_size+0xc2>
  800ed3:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	74 2b                	je     800f08 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	50                   	push   %eax
  800ee1:	e8 5f f9 ff ff       	call   800845 <free_block>
		f->f_indirect = 0;
  800ee6:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800eed:	00 00 00 
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	eb 13                	jmp    800f08 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	50                   	push   %eax
  800ef9:	68 c1 3a 80 00       	push   $0x803ac1
  800efe:	e8 5d 0c 00 00       	call   801b60 <cprintf>
  800f03:	83 c4 10             	add    $0x10,%esp
  800f06:	eb be                	jmp    800ec6 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0b:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	56                   	push   %esi
  800f15:	e8 f9 f4 ff ff       	call   800413 <flush_block>
	return 0;
}
  800f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 2c             	sub    $0x2c,%esp
  800f30:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f33:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800f36:	89 f0                	mov    %esi,%eax
  800f38:	03 45 10             	add    0x10(%ebp),%eax
  800f3b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f41:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800f47:	76 72                	jbe    800fbb <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800f49:	83 ec 08             	sub    $0x8,%esp
  800f4c:	50                   	push   %eax
  800f4d:	51                   	push   %ecx
  800f4e:	e8 f3 fe ff ff       	call   800e46 <file_set_size>
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	79 61                	jns    800fbb <file_write+0x94>
  800f5a:	eb 69                	jmp    800fc5 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f62:	50                   	push   %eax
  800f63:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800f69:	85 f6                	test   %esi,%esi
  800f6b:	0f 49 c6             	cmovns %esi,%eax
  800f6e:	c1 f8 0c             	sar    $0xc,%eax
  800f71:	50                   	push   %eax
  800f72:	ff 75 08             	pushl  0x8(%ebp)
  800f75:	e8 5e fb ff ff       	call   800ad8 <file_get_block>
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	78 44                	js     800fc5 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f81:	89 f2                	mov    %esi,%edx
  800f83:	c1 fa 1f             	sar    $0x1f,%edx
  800f86:	c1 ea 14             	shr    $0x14,%edx
  800f89:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800f8c:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f91:	29 d0                	sub    %edx,%eax
  800f93:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f96:	29 d9                	sub    %ebx,%ecx
  800f98:	89 cb                	mov    %ecx,%ebx
  800f9a:	ba 00 10 00 00       	mov    $0x1000,%edx
  800f9f:	29 c2                	sub    %eax,%edx
  800fa1:	39 d1                	cmp    %edx,%ecx
  800fa3:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	53                   	push   %ebx
  800faa:	57                   	push   %edi
  800fab:	03 45 e4             	add    -0x1c(%ebp),%eax
  800fae:	50                   	push   %eax
  800faf:	e8 c3 12 00 00       	call   802277 <memmove>
		pos += bn;
  800fb4:	01 de                	add    %ebx,%esi
		buf += bn;
  800fb6:	01 df                	add    %ebx,%edi
  800fb8:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800fbb:	89 f3                	mov    %esi,%ebx
  800fbd:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800fc0:	77 9a                	ja     800f5c <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800fc2:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800fc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	56                   	push   %esi
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 10             	sub    $0x10,%esp
  800fd5:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdd:	eb 3c                	jmp    80101b <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	6a 00                	push   $0x0
  800fe4:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800fe7:	89 da                	mov    %ebx,%edx
  800fe9:	89 f0                	mov    %esi,%eax
  800feb:	e8 0a f9 ff ff       	call   8008fa <file_block_walk>
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 21                	js     801018 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	74 1a                	je     801018 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800ffe:	8b 00                	mov    (%eax),%eax
  801000:	85 c0                	test   %eax,%eax
  801002:	74 14                	je     801018 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	50                   	push   %eax
  801008:	e8 88 f3 ff ff       	call   800395 <diskaddr>
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	e8 fe f3 ff ff       	call   800413 <flush_block>
  801015:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801018:	83 c3 01             	add    $0x1,%ebx
  80101b:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  801021:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  801027:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  80102d:	85 c9                	test   %ecx,%ecx
  80102f:	0f 49 c1             	cmovns %ecx,%eax
  801032:	c1 f8 0c             	sar    $0xc,%eax
  801035:	39 c3                	cmp    %eax,%ebx
  801037:	7c a6                	jl     800fdf <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	56                   	push   %esi
  80103d:	e8 d1 f3 ff ff       	call   800413 <flush_block>
	if (f->f_indirect)
  801042:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	74 14                	je     801063 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	50                   	push   %eax
  801053:	e8 3d f3 ff ff       	call   800395 <diskaddr>
  801058:	89 04 24             	mov    %eax,(%esp)
  80105b:	e8 b3 f3 ff ff       	call   800413 <flush_block>
  801060:	83 c4 10             	add    $0x10,%esp
}
  801063:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	57                   	push   %edi
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
  801070:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801076:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80107c:	50                   	push   %eax
  80107d:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801083:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	e8 c8 fa ff ff       	call   800b59 <walk_path>
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	0f 84 d1 00 00 00    	je     80116d <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  80109c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80109f:	0f 85 0c 01 00 00    	jne    8011b1 <file_create+0x147>
  8010a5:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  8010ab:	85 f6                	test   %esi,%esi
  8010ad:	0f 84 c1 00 00 00    	je     801174 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  8010b3:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  8010b9:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8010be:	74 19                	je     8010d9 <file_create+0x6f>
  8010c0:	68 a4 3a 80 00       	push   $0x803aa4
  8010c5:	68 1d 38 80 00       	push   $0x80381d
  8010ca:	68 1a 01 00 00       	push   $0x11a
  8010cf:	68 0c 3a 80 00       	push   $0x803a0c
  8010d4:	e8 ae 09 00 00       	call   801a87 <_panic>
	nblock = dir->f_size / BLKSIZE;
  8010d9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	0f 48 c2             	cmovs  %edx,%eax
  8010e4:	c1 f8 0c             	sar    $0xc,%eax
  8010e7:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8010f2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8010f8:	eb 3b                	jmp    801135 <file_create+0xcb>
  8010fa:	83 ec 04             	sub    $0x4,%esp
  8010fd:	57                   	push   %edi
  8010fe:	53                   	push   %ebx
  8010ff:	56                   	push   %esi
  801100:	e8 d3 f9 ff ff       	call   800ad8 <file_get_block>
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	0f 88 a1 00 00 00    	js     8011b1 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  801110:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801116:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  80111c:	80 38 00             	cmpb   $0x0,(%eax)
  80111f:	75 08                	jne    801129 <file_create+0xbf>
				*file = &f[j];
  801121:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801127:	eb 52                	jmp    80117b <file_create+0x111>
  801129:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  80112e:	39 d0                	cmp    %edx,%eax
  801130:	75 ea                	jne    80111c <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  801132:	83 c3 01             	add    $0x1,%ebx
  801135:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  80113b:	75 bd                	jne    8010fa <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  80113d:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  801144:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	53                   	push   %ebx
  801152:	56                   	push   %esi
  801153:	e8 80 f9 ff ff       	call   800ad8 <file_get_block>
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 52                	js     8011b1 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  80115f:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801165:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80116b:	eb 0e                	jmp    80117b <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  80116d:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801172:	eb 3d                	jmp    8011b1 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  801174:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801179:	eb 36                	jmp    8011b1 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801184:	50                   	push   %eax
  801185:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  80118b:	e8 55 0f 00 00       	call   8020e5 <strcpy>
	*pf = f;
  801190:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801196:	8b 45 0c             	mov    0xc(%ebp),%eax
  801199:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80119b:	83 c4 04             	add    $0x4,%esp
  80119e:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  8011a4:	e8 24 fe ff ff       	call   800fcd <file_flush>
	return 0;
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8011c0:	bb 01 00 00 00       	mov    $0x1,%ebx
  8011c5:	eb 17                	jmp    8011de <fs_sync+0x25>
		flush_block(diskaddr(i));
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	53                   	push   %ebx
  8011cb:	e8 c5 f1 ff ff       	call   800395 <diskaddr>
  8011d0:	89 04 24             	mov    %eax,(%esp)
  8011d3:	e8 3b f2 ff ff       	call   800413 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8011d8:	83 c3 01             	add    $0x1,%ebx
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8011e3:	39 58 04             	cmp    %ebx,0x4(%eax)
  8011e6:	77 df                	ja     8011c7 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  8011e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011eb:	c9                   	leave  
  8011ec:	c3                   	ret    

008011ed <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  8011f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	83 ec 0c             	sub    $0xc,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  8011fd:	68 de 3a 80 00       	push   $0x803ade
  801202:	68 e8 00 00 00       	push   $0xe8
  801207:	68 fa 3a 80 00       	push   $0x803afa
  80120c:	e8 76 08 00 00       	call   801a87 <_panic>

00801211 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801217:	e8 9d ff ff ff       	call   8011b9 <fs_sync>
	return 0;
}
  80121c:	b8 00 00 00 00       	mov    $0x0,%eax
  801221:	c9                   	leave  
  801222:	c3                   	ret    

00801223 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  80122b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801235:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801237:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80123a:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801240:	83 c0 01             	add    $0x1,%eax
  801243:	83 c2 10             	add    $0x10,%edx
  801246:	3d 00 04 00 00       	cmp    $0x400,%eax
  80124b:	75 e8                	jne    801235 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	56                   	push   %esi
  801253:	53                   	push   %ebx
  801254:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801257:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  80125c:	83 ec 0c             	sub    $0xc,%esp
  80125f:	89 d8                	mov    %ebx,%eax
  801261:	c1 e0 04             	shl    $0x4,%eax
  801264:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80126a:	e8 a8 1d 00 00       	call   803017 <pageref>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	74 07                	je     80127d <openfile_alloc+0x2e>
  801276:	83 f8 01             	cmp    $0x1,%eax
  801279:	74 20                	je     80129b <openfile_alloc+0x4c>
  80127b:	eb 51                	jmp    8012ce <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  80127d:	83 ec 04             	sub    $0x4,%esp
  801280:	6a 07                	push   $0x7
  801282:	89 d8                	mov    %ebx,%eax
  801284:	c1 e0 04             	shl    $0x4,%eax
  801287:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80128d:	6a 00                	push   $0x0
  80128f:	e8 54 12 00 00       	call   8024e8 <sys_page_alloc>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 43                	js     8012de <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  80129b:	c1 e3 04             	shl    $0x4,%ebx
  80129e:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8012a4:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8012ab:	04 00 00 
			*o = &opentab[i];
  8012ae:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8012b0:	83 ec 04             	sub    $0x4,%esp
  8012b3:	68 00 10 00 00       	push   $0x1000
  8012b8:	6a 00                	push   $0x0
  8012ba:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  8012c0:	e8 65 0f 00 00       	call   80222a <memset>
			return (*o)->o_fileid;
  8012c5:	8b 06                	mov    (%esi),%eax
  8012c7:	8b 00                	mov    (%eax),%eax
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	eb 10                	jmp    8012de <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8012ce:	83 c3 01             	add    $0x1,%ebx
  8012d1:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8012d7:	75 83                	jne    80125c <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  8012d9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	57                   	push   %edi
  8012e9:	56                   	push   %esi
  8012ea:	53                   	push   %ebx
  8012eb:	83 ec 18             	sub    $0x18,%esp
  8012ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8012f1:	89 fb                	mov    %edi,%ebx
  8012f3:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8012f9:	89 de                	mov    %ebx,%esi
  8012fb:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012fe:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801304:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80130a:	e8 08 1d 00 00       	call   803017 <pageref>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	83 f8 01             	cmp    $0x1,%eax
  801315:	7e 17                	jle    80132e <openfile_lookup+0x49>
  801317:	c1 e3 04             	shl    $0x4,%ebx
  80131a:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801320:	75 13                	jne    801335 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801322:	8b 45 10             	mov    0x10(%ebp),%eax
  801325:	89 30                	mov    %esi,(%eax)
	return 0;
  801327:	b8 00 00 00 00       	mov    $0x0,%eax
  80132c:	eb 0c                	jmp    80133a <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80132e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801333:	eb 05                	jmp    80133a <openfile_lookup+0x55>
  801335:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80133a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	53                   	push   %ebx
  801346:	83 ec 18             	sub    $0x18,%esp
  801349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80134c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	ff 33                	pushl  (%ebx)
  801352:	ff 75 08             	pushl  0x8(%ebp)
  801355:	e8 8b ff ff ff       	call   8012e5 <openfile_lookup>
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 14                	js     801375 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	ff 73 04             	pushl  0x4(%ebx)
  801367:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136a:	ff 70 04             	pushl  0x4(%eax)
  80136d:	e8 d4 fa ff ff       	call   800e46 <file_set_size>
  801372:	83 c4 10             	add    $0x10,%esp
}
  801375:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801378:	c9                   	leave  
  801379:	c3                   	ret    

0080137a <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	53                   	push   %ebx
  80137e:	83 ec 18             	sub    $0x18,%esp
  801381:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801384:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801387:	50                   	push   %eax
  801388:	ff 33                	pushl  (%ebx)
  80138a:	ff 75 08             	pushl  0x8(%ebp)
  80138d:	e8 53 ff ff ff       	call   8012e5 <openfile_lookup>
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 3f                	js     8013d8 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139f:	ff 70 04             	pushl  0x4(%eax)
  8013a2:	53                   	push   %ebx
  8013a3:	e8 3d 0d 00 00       	call   8020e5 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ab:	8b 50 04             	mov    0x4(%eax),%edx
  8013ae:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8013b4:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8013ba:	8b 40 04             	mov    0x4(%eax),%eax
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8013c7:	0f 94 c0             	sete   %al
  8013ca:	0f b6 c0             	movzbl %al,%eax
  8013cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ea:	ff 30                	pushl  (%eax)
  8013ec:	ff 75 08             	pushl  0x8(%ebp)
  8013ef:	e8 f1 fe ff ff       	call   8012e5 <openfile_lookup>
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 16                	js     801411 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  8013fb:	83 ec 0c             	sub    $0xc,%esp
  8013fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801401:	ff 70 04             	pushl  0x4(%eax)
  801404:	e8 c4 fb ff ff       	call   800fcd <file_flush>
	return 0;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	53                   	push   %ebx
  801417:	81 ec 18 04 00 00    	sub    $0x418,%esp
  80141d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801420:	68 00 04 00 00       	push   $0x400
  801425:	53                   	push   %ebx
  801426:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80142c:	50                   	push   %eax
  80142d:	e8 45 0e 00 00       	call   802277 <memmove>
	path[MAXPATHLEN-1] = 0;
  801432:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801436:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80143c:	89 04 24             	mov    %eax,(%esp)
  80143f:	e8 0b fe ff ff       	call   80124f <openfile_alloc>
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	0f 88 f0 00 00 00    	js     80153f <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  80144f:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801456:	74 33                	je     80148b <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	e8 fc fb ff ff       	call   80106a <file_create>
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	79 37                	jns    8014ac <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801475:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  80147c:	0f 85 bd 00 00 00    	jne    80153f <serve_open+0x12c>
  801482:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801485:	0f 85 b4 00 00 00    	jne    80153f <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	e8 e6 f8 ff ff       	call   800d87 <file_open>
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	0f 88 93 00 00 00    	js     80153f <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8014ac:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8014b3:	74 17                	je     8014cc <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	6a 00                	push   $0x0
  8014ba:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8014c0:	e8 81 f9 ff ff       	call   800e46 <file_set_size>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 73                	js     80153f <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	e8 a5 f8 ff ff       	call   800d87 <file_open>
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 56                	js     80153f <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8014e9:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8014ef:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8014f5:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8014f8:	8b 50 0c             	mov    0xc(%eax),%edx
  8014fb:	8b 08                	mov    (%eax),%ecx
  8014fd:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801500:	8b 48 0c             	mov    0xc(%eax),%ecx
  801503:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801509:	83 e2 03             	and    $0x3,%edx
  80150c:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  80150f:	8b 40 0c             	mov    0xc(%eax),%eax
  801512:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801518:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80151a:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801520:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801526:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801529:	8b 50 0c             	mov    0xc(%eax),%edx
  80152c:	8b 45 10             	mov    0x10(%ebp),%eax
  80152f:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801531:	8b 45 14             	mov    0x14(%ebp),%eax
  801534:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80153a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	56                   	push   %esi
  801548:	53                   	push   %ebx
  801549:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80154c:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  80154f:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801552:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801559:	83 ec 04             	sub    $0x4,%esp
  80155c:	53                   	push   %ebx
  80155d:	ff 35 44 50 80 00    	pushl  0x805044
  801563:	56                   	push   %esi
  801564:	e8 db 11 00 00       	call   802744 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801570:	75 15                	jne    801587 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	ff 75 f4             	pushl  -0xc(%ebp)
  801578:	68 28 3b 80 00       	push   $0x803b28
  80157d:	e8 de 05 00 00       	call   801b60 <cprintf>
				whom);
			continue; // just leave it hanging...
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	eb cb                	jmp    801552 <serve+0xe>
		}

		pg = NULL;
  801587:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  80158e:	83 f8 01             	cmp    $0x1,%eax
  801591:	75 18                	jne    8015ab <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801593:	53                   	push   %ebx
  801594:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	ff 35 44 50 80 00    	pushl  0x805044
  80159e:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a1:	e8 6d fe ff ff       	call   801413 <serve_open>
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	eb 3c                	jmp    8015e7 <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8015ab:	83 f8 08             	cmp    $0x8,%eax
  8015ae:	77 1e                	ja     8015ce <serve+0x8a>
  8015b0:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8015b7:	85 d2                	test   %edx,%edx
  8015b9:	74 13                	je     8015ce <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8015bb:	83 ec 08             	sub    $0x8,%esp
  8015be:	ff 35 44 50 80 00    	pushl  0x805044
  8015c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c7:	ff d2                	call   *%edx
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	eb 19                	jmp    8015e7 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8015ce:	83 ec 04             	sub    $0x4,%esp
  8015d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d4:	50                   	push   %eax
  8015d5:	68 58 3b 80 00       	push   $0x803b58
  8015da:	e8 81 05 00 00       	call   801b60 <cprintf>
  8015df:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8015e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8015e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8015ea:	ff 75 ec             	pushl  -0x14(%ebp)
  8015ed:	50                   	push   %eax
  8015ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f1:	e8 b5 11 00 00       	call   8027ab <ipc_send>
		sys_page_unmap(0, fsreq);
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	ff 35 44 50 80 00    	pushl  0x805044
  8015ff:	6a 00                	push   $0x0
  801601:	e8 67 0f 00 00       	call   80256d <sys_page_unmap>
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	e9 44 ff ff ff       	jmp    801552 <serve+0xe>

0080160e <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801614:	c7 05 60 90 80 00 04 	movl   $0x803b04,0x809060
  80161b:	3b 80 00 
	cprintf("FS is running\n");
  80161e:	68 07 3b 80 00       	push   $0x803b07
  801623:	e8 38 05 00 00       	call   801b60 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801628:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80162d:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801632:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801634:	c7 04 24 16 3b 80 00 	movl   $0x803b16,(%esp)
  80163b:	e8 20 05 00 00       	call   801b60 <cprintf>

	serve_init();
  801640:	e8 de fb ff ff       	call   801223 <serve_init>
	fs_init();
  801645:	e8 2f f4 ff ff       	call   800a79 <fs_init>
        fs_test();
  80164a:	e8 05 00 00 00       	call   801654 <fs_test>
	serve();
  80164f:	e8 f0 fe ff ff       	call   801544 <serve>

00801654 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	53                   	push   %ebx
  801658:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80165b:	6a 07                	push   $0x7
  80165d:	68 00 10 00 00       	push   $0x1000
  801662:	6a 00                	push   $0x0
  801664:	e8 7f 0e 00 00       	call   8024e8 <sys_page_alloc>
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	85 c0                	test   %eax,%eax
  80166e:	79 12                	jns    801682 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801670:	50                   	push   %eax
  801671:	68 7b 3b 80 00       	push   $0x803b7b
  801676:	6a 12                	push   $0x12
  801678:	68 8e 3b 80 00       	push   $0x803b8e
  80167d:	e8 05 04 00 00       	call   801a87 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801682:	83 ec 04             	sub    $0x4,%esp
  801685:	68 00 10 00 00       	push   $0x1000
  80168a:	ff 35 04 a0 80 00    	pushl  0x80a004
  801690:	68 00 10 00 00       	push   $0x1000
  801695:	e8 dd 0b 00 00       	call   802277 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80169a:	e8 e2 f1 ff ff       	call   800881 <alloc_block>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	79 12                	jns    8016b8 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016a6:	50                   	push   %eax
  8016a7:	68 98 3b 80 00       	push   $0x803b98
  8016ac:	6a 17                	push   $0x17
  8016ae:	68 8e 3b 80 00       	push   $0x803b8e
  8016b3:	e8 cf 03 00 00       	call   801a87 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016b8:	8d 50 1f             	lea    0x1f(%eax),%edx
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	0f 49 d0             	cmovns %eax,%edx
  8016c0:	c1 fa 05             	sar    $0x5,%edx
  8016c3:	89 c3                	mov    %eax,%ebx
  8016c5:	c1 fb 1f             	sar    $0x1f,%ebx
  8016c8:	c1 eb 1b             	shr    $0x1b,%ebx
  8016cb:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8016ce:	83 e1 1f             	and    $0x1f,%ecx
  8016d1:	29 d9                	sub    %ebx,%ecx
  8016d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d8:	d3 e0                	shl    %cl,%eax
  8016da:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8016e1:	75 16                	jne    8016f9 <fs_test+0xa5>
  8016e3:	68 a8 3b 80 00       	push   $0x803ba8
  8016e8:	68 1d 38 80 00       	push   $0x80381d
  8016ed:	6a 19                	push   $0x19
  8016ef:	68 8e 3b 80 00       	push   $0x803b8e
  8016f4:	e8 8e 03 00 00       	call   801a87 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8016f9:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8016ff:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801702:	74 16                	je     80171a <fs_test+0xc6>
  801704:	68 20 3d 80 00       	push   $0x803d20
  801709:	68 1d 38 80 00       	push   $0x80381d
  80170e:	6a 1b                	push   $0x1b
  801710:	68 8e 3b 80 00       	push   $0x803b8e
  801715:	e8 6d 03 00 00       	call   801a87 <_panic>
	cprintf("alloc_block is good\n");
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	68 c3 3b 80 00       	push   $0x803bc3
  801722:	e8 39 04 00 00       	call   801b60 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801727:	83 c4 08             	add    $0x8,%esp
  80172a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172d:	50                   	push   %eax
  80172e:	68 d8 3b 80 00       	push   $0x803bd8
  801733:	e8 4f f6 ff ff       	call   800d87 <file_open>
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80173e:	74 1b                	je     80175b <fs_test+0x107>
  801740:	89 c2                	mov    %eax,%edx
  801742:	c1 ea 1f             	shr    $0x1f,%edx
  801745:	84 d2                	test   %dl,%dl
  801747:	74 12                	je     80175b <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801749:	50                   	push   %eax
  80174a:	68 e3 3b 80 00       	push   $0x803be3
  80174f:	6a 1f                	push   $0x1f
  801751:	68 8e 3b 80 00       	push   $0x803b8e
  801756:	e8 2c 03 00 00       	call   801a87 <_panic>
	else if (r == 0)
  80175b:	85 c0                	test   %eax,%eax
  80175d:	75 14                	jne    801773 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80175f:	83 ec 04             	sub    $0x4,%esp
  801762:	68 40 3d 80 00       	push   $0x803d40
  801767:	6a 21                	push   $0x21
  801769:	68 8e 3b 80 00       	push   $0x803b8e
  80176e:	e8 14 03 00 00       	call   801a87 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801773:	83 ec 08             	sub    $0x8,%esp
  801776:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	68 fc 3b 80 00       	push   $0x803bfc
  80177f:	e8 03 f6 ff ff       	call   800d87 <file_open>
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	79 12                	jns    80179d <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  80178b:	50                   	push   %eax
  80178c:	68 05 3c 80 00       	push   $0x803c05
  801791:	6a 23                	push   $0x23
  801793:	68 8e 3b 80 00       	push   $0x803b8e
  801798:	e8 ea 02 00 00       	call   801a87 <_panic>
	cprintf("file_open is good\n");
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	68 1c 3c 80 00       	push   $0x803c1c
  8017a5:	e8 b6 03 00 00       	call   801b60 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017aa:	83 c4 0c             	add    $0xc,%esp
  8017ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b0:	50                   	push   %eax
  8017b1:	6a 00                	push   $0x0
  8017b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b6:	e8 1d f3 ff ff       	call   800ad8 <file_get_block>
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	79 12                	jns    8017d4 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8017c2:	50                   	push   %eax
  8017c3:	68 2f 3c 80 00       	push   $0x803c2f
  8017c8:	6a 27                	push   $0x27
  8017ca:	68 8e 3b 80 00       	push   $0x803b8e
  8017cf:	e8 b3 02 00 00       	call   801a87 <_panic>
	if (strcmp(blk, msg) != 0)
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	68 60 3d 80 00       	push   $0x803d60
  8017dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8017df:	e8 ab 09 00 00       	call   80218f <strcmp>
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	74 14                	je     8017ff <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	68 88 3d 80 00       	push   $0x803d88
  8017f3:	6a 29                	push   $0x29
  8017f5:	68 8e 3b 80 00       	push   $0x803b8e
  8017fa:	e8 88 02 00 00       	call   801a87 <_panic>
	cprintf("file_get_block is good\n");
  8017ff:	83 ec 0c             	sub    $0xc,%esp
  801802:	68 42 3c 80 00       	push   $0x803c42
  801807:	e8 54 03 00 00       	call   801b60 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80180c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180f:	0f b6 10             	movzbl (%eax),%edx
  801812:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801817:	c1 e8 0c             	shr    $0xc,%eax
  80181a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	a8 40                	test   $0x40,%al
  801826:	75 16                	jne    80183e <fs_test+0x1ea>
  801828:	68 5b 3c 80 00       	push   $0x803c5b
  80182d:	68 1d 38 80 00       	push   $0x80381d
  801832:	6a 2d                	push   $0x2d
  801834:	68 8e 3b 80 00       	push   $0x803b8e
  801839:	e8 49 02 00 00       	call   801a87 <_panic>
	file_flush(f);
  80183e:	83 ec 0c             	sub    $0xc,%esp
  801841:	ff 75 f4             	pushl  -0xc(%ebp)
  801844:	e8 84 f7 ff ff       	call   800fcd <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801849:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184c:	c1 e8 0c             	shr    $0xc,%eax
  80184f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	a8 40                	test   $0x40,%al
  80185b:	74 16                	je     801873 <fs_test+0x21f>
  80185d:	68 5a 3c 80 00       	push   $0x803c5a
  801862:	68 1d 38 80 00       	push   $0x80381d
  801867:	6a 2f                	push   $0x2f
  801869:	68 8e 3b 80 00       	push   $0x803b8e
  80186e:	e8 14 02 00 00       	call   801a87 <_panic>
	cprintf("file_flush is good\n");
  801873:	83 ec 0c             	sub    $0xc,%esp
  801876:	68 76 3c 80 00       	push   $0x803c76
  80187b:	e8 e0 02 00 00       	call   801b60 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801880:	83 c4 08             	add    $0x8,%esp
  801883:	6a 00                	push   $0x0
  801885:	ff 75 f4             	pushl  -0xc(%ebp)
  801888:	e8 b9 f5 ff ff       	call   800e46 <file_set_size>
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	85 c0                	test   %eax,%eax
  801892:	79 12                	jns    8018a6 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801894:	50                   	push   %eax
  801895:	68 8a 3c 80 00       	push   $0x803c8a
  80189a:	6a 33                	push   $0x33
  80189c:	68 8e 3b 80 00       	push   $0x803b8e
  8018a1:	e8 e1 01 00 00       	call   801a87 <_panic>
	assert(f->f_direct[0] == 0);
  8018a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a9:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018b0:	74 16                	je     8018c8 <fs_test+0x274>
  8018b2:	68 9c 3c 80 00       	push   $0x803c9c
  8018b7:	68 1d 38 80 00       	push   $0x80381d
  8018bc:	6a 34                	push   $0x34
  8018be:	68 8e 3b 80 00       	push   $0x803b8e
  8018c3:	e8 bf 01 00 00       	call   801a87 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018c8:	c1 e8 0c             	shr    $0xc,%eax
  8018cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d2:	a8 40                	test   $0x40,%al
  8018d4:	74 16                	je     8018ec <fs_test+0x298>
  8018d6:	68 b0 3c 80 00       	push   $0x803cb0
  8018db:	68 1d 38 80 00       	push   $0x80381d
  8018e0:	6a 35                	push   $0x35
  8018e2:	68 8e 3b 80 00       	push   $0x803b8e
  8018e7:	e8 9b 01 00 00       	call   801a87 <_panic>
	cprintf("file_truncate is good\n");
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	68 ca 3c 80 00       	push   $0x803cca
  8018f4:	e8 67 02 00 00       	call   801b60 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8018f9:	c7 04 24 60 3d 80 00 	movl   $0x803d60,(%esp)
  801900:	e8 a7 07 00 00       	call   8020ac <strlen>
  801905:	83 c4 08             	add    $0x8,%esp
  801908:	50                   	push   %eax
  801909:	ff 75 f4             	pushl  -0xc(%ebp)
  80190c:	e8 35 f5 ff ff       	call   800e46 <file_set_size>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 c0                	test   %eax,%eax
  801916:	79 12                	jns    80192a <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801918:	50                   	push   %eax
  801919:	68 e1 3c 80 00       	push   $0x803ce1
  80191e:	6a 39                	push   $0x39
  801920:	68 8e 3b 80 00       	push   $0x803b8e
  801925:	e8 5d 01 00 00       	call   801a87 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192d:	89 c2                	mov    %eax,%edx
  80192f:	c1 ea 0c             	shr    $0xc,%edx
  801932:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801939:	f6 c2 40             	test   $0x40,%dl
  80193c:	74 16                	je     801954 <fs_test+0x300>
  80193e:	68 b0 3c 80 00       	push   $0x803cb0
  801943:	68 1d 38 80 00       	push   $0x80381d
  801948:	6a 3a                	push   $0x3a
  80194a:	68 8e 3b 80 00       	push   $0x803b8e
  80194f:	e8 33 01 00 00       	call   801a87 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801954:	83 ec 04             	sub    $0x4,%esp
  801957:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80195a:	52                   	push   %edx
  80195b:	6a 00                	push   $0x0
  80195d:	50                   	push   %eax
  80195e:	e8 75 f1 ff ff       	call   800ad8 <file_get_block>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	79 12                	jns    80197c <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80196a:	50                   	push   %eax
  80196b:	68 f5 3c 80 00       	push   $0x803cf5
  801970:	6a 3c                	push   $0x3c
  801972:	68 8e 3b 80 00       	push   $0x803b8e
  801977:	e8 0b 01 00 00       	call   801a87 <_panic>
	strcpy(blk, msg);
  80197c:	83 ec 08             	sub    $0x8,%esp
  80197f:	68 60 3d 80 00       	push   $0x803d60
  801984:	ff 75 f0             	pushl  -0x10(%ebp)
  801987:	e8 59 07 00 00       	call   8020e5 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80198c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198f:	c1 e8 0c             	shr    $0xc,%eax
  801992:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	a8 40                	test   $0x40,%al
  80199e:	75 16                	jne    8019b6 <fs_test+0x362>
  8019a0:	68 5b 3c 80 00       	push   $0x803c5b
  8019a5:	68 1d 38 80 00       	push   $0x80381d
  8019aa:	6a 3e                	push   $0x3e
  8019ac:	68 8e 3b 80 00       	push   $0x803b8e
  8019b1:	e8 d1 00 00 00       	call   801a87 <_panic>
	file_flush(f);
  8019b6:	83 ec 0c             	sub    $0xc,%esp
  8019b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bc:	e8 0c f6 ff ff       	call   800fcd <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c4:	c1 e8 0c             	shr    $0xc,%eax
  8019c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	a8 40                	test   $0x40,%al
  8019d3:	74 16                	je     8019eb <fs_test+0x397>
  8019d5:	68 5a 3c 80 00       	push   $0x803c5a
  8019da:	68 1d 38 80 00       	push   $0x80381d
  8019df:	6a 40                	push   $0x40
  8019e1:	68 8e 3b 80 00       	push   $0x803b8e
  8019e6:	e8 9c 00 00 00       	call   801a87 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ee:	c1 e8 0c             	shr    $0xc,%eax
  8019f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f8:	a8 40                	test   $0x40,%al
  8019fa:	74 16                	je     801a12 <fs_test+0x3be>
  8019fc:	68 b0 3c 80 00       	push   $0x803cb0
  801a01:	68 1d 38 80 00       	push   $0x80381d
  801a06:	6a 41                	push   $0x41
  801a08:	68 8e 3b 80 00       	push   $0x803b8e
  801a0d:	e8 75 00 00 00       	call   801a87 <_panic>
	cprintf("file rewrite is good\n");
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	68 0a 3d 80 00       	push   $0x803d0a
  801a1a:	e8 41 01 00 00       	call   801b60 <cprintf>
}
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
  801a2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a2f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801a32:	e8 73 0a 00 00       	call   8024aa <sys_getenvid>
  801a37:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a3c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a3f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a44:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a49:	85 db                	test   %ebx,%ebx
  801a4b:	7e 07                	jle    801a54 <libmain+0x2d>
		binaryname = argv[0];
  801a4d:	8b 06                	mov    (%esi),%eax
  801a4f:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801a54:	83 ec 08             	sub    $0x8,%esp
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	e8 b0 fb ff ff       	call   80160e <umain>

	// exit gracefully
	exit();
  801a5e:	e8 0a 00 00 00       	call   801a6d <exit>
}
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801a73:	e8 8b 0f 00 00       	call   802a03 <close_all>
	sys_env_destroy(0);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	6a 00                	push   $0x0
  801a7d:	e8 e7 09 00 00       	call   802469 <sys_env_destroy>
}
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a8c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a8f:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801a95:	e8 10 0a 00 00       	call   8024aa <sys_getenvid>
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	ff 75 0c             	pushl  0xc(%ebp)
  801aa0:	ff 75 08             	pushl  0x8(%ebp)
  801aa3:	56                   	push   %esi
  801aa4:	50                   	push   %eax
  801aa5:	68 b8 3d 80 00       	push   $0x803db8
  801aaa:	e8 b1 00 00 00       	call   801b60 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801aaf:	83 c4 18             	add    $0x18,%esp
  801ab2:	53                   	push   %ebx
  801ab3:	ff 75 10             	pushl  0x10(%ebp)
  801ab6:	e8 54 00 00 00       	call   801b0f <vcprintf>
	cprintf("\n");
  801abb:	c7 04 24 a3 39 80 00 	movl   $0x8039a3,(%esp)
  801ac2:	e8 99 00 00 00       	call   801b60 <cprintf>
  801ac7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aca:	cc                   	int3   
  801acb:	eb fd                	jmp    801aca <_panic+0x43>

00801acd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	53                   	push   %ebx
  801ad1:	83 ec 04             	sub    $0x4,%esp
  801ad4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801ad7:	8b 13                	mov    (%ebx),%edx
  801ad9:	8d 42 01             	lea    0x1(%edx),%eax
  801adc:	89 03                	mov    %eax,(%ebx)
  801ade:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801ae5:	3d ff 00 00 00       	cmp    $0xff,%eax
  801aea:	75 1a                	jne    801b06 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801aec:	83 ec 08             	sub    $0x8,%esp
  801aef:	68 ff 00 00 00       	push   $0xff
  801af4:	8d 43 08             	lea    0x8(%ebx),%eax
  801af7:	50                   	push   %eax
  801af8:	e8 2f 09 00 00       	call   80242c <sys_cputs>
		b->idx = 0;
  801afd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b03:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b06:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b18:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b1f:	00 00 00 
	b.cnt = 0;
  801b22:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b29:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b2c:	ff 75 0c             	pushl  0xc(%ebp)
  801b2f:	ff 75 08             	pushl  0x8(%ebp)
  801b32:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b38:	50                   	push   %eax
  801b39:	68 cd 1a 80 00       	push   $0x801acd
  801b3e:	e8 54 01 00 00       	call   801c97 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b43:	83 c4 08             	add    $0x8,%esp
  801b46:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b4c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b52:	50                   	push   %eax
  801b53:	e8 d4 08 00 00       	call   80242c <sys_cputs>

	return b.cnt;
}
  801b58:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b66:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801b69:	50                   	push   %eax
  801b6a:	ff 75 08             	pushl  0x8(%ebp)
  801b6d:	e8 9d ff ff ff       	call   801b0f <vcprintf>
	va_end(ap);

	return cnt;
}
  801b72:	c9                   	leave  
  801b73:	c3                   	ret    

00801b74 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	57                   	push   %edi
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 1c             	sub    $0x1c,%esp
  801b7d:	89 c7                	mov    %eax,%edi
  801b7f:	89 d6                	mov    %edx,%esi
  801b81:	8b 45 08             	mov    0x8(%ebp),%eax
  801b84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b8a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801b8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b90:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b95:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801b98:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801b9b:	39 d3                	cmp    %edx,%ebx
  801b9d:	72 05                	jb     801ba4 <printnum+0x30>
  801b9f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801ba2:	77 45                	ja     801be9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801ba4:	83 ec 0c             	sub    $0xc,%esp
  801ba7:	ff 75 18             	pushl  0x18(%ebp)
  801baa:	8b 45 14             	mov    0x14(%ebp),%eax
  801bad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801bb0:	53                   	push   %ebx
  801bb1:	ff 75 10             	pushl  0x10(%ebp)
  801bb4:	83 ec 08             	sub    $0x8,%esp
  801bb7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bba:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbd:	ff 75 dc             	pushl  -0x24(%ebp)
  801bc0:	ff 75 d8             	pushl  -0x28(%ebp)
  801bc3:	e8 78 19 00 00       	call   803540 <__udivdi3>
  801bc8:	83 c4 18             	add    $0x18,%esp
  801bcb:	52                   	push   %edx
  801bcc:	50                   	push   %eax
  801bcd:	89 f2                	mov    %esi,%edx
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	e8 9e ff ff ff       	call   801b74 <printnum>
  801bd6:	83 c4 20             	add    $0x20,%esp
  801bd9:	eb 18                	jmp    801bf3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801bdb:	83 ec 08             	sub    $0x8,%esp
  801bde:	56                   	push   %esi
  801bdf:	ff 75 18             	pushl  0x18(%ebp)
  801be2:	ff d7                	call   *%edi
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	eb 03                	jmp    801bec <printnum+0x78>
  801be9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801bec:	83 eb 01             	sub    $0x1,%ebx
  801bef:	85 db                	test   %ebx,%ebx
  801bf1:	7f e8                	jg     801bdb <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801bf3:	83 ec 08             	sub    $0x8,%esp
  801bf6:	56                   	push   %esi
  801bf7:	83 ec 04             	sub    $0x4,%esp
  801bfa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bfd:	ff 75 e0             	pushl  -0x20(%ebp)
  801c00:	ff 75 dc             	pushl  -0x24(%ebp)
  801c03:	ff 75 d8             	pushl  -0x28(%ebp)
  801c06:	e8 65 1a 00 00       	call   803670 <__umoddi3>
  801c0b:	83 c4 14             	add    $0x14,%esp
  801c0e:	0f be 80 db 3d 80 00 	movsbl 0x803ddb(%eax),%eax
  801c15:	50                   	push   %eax
  801c16:	ff d7                	call   *%edi
}
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1e:	5b                   	pop    %ebx
  801c1f:	5e                   	pop    %esi
  801c20:	5f                   	pop    %edi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c26:	83 fa 01             	cmp    $0x1,%edx
  801c29:	7e 0e                	jle    801c39 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c2b:	8b 10                	mov    (%eax),%edx
  801c2d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c30:	89 08                	mov    %ecx,(%eax)
  801c32:	8b 02                	mov    (%edx),%eax
  801c34:	8b 52 04             	mov    0x4(%edx),%edx
  801c37:	eb 22                	jmp    801c5b <getuint+0x38>
	else if (lflag)
  801c39:	85 d2                	test   %edx,%edx
  801c3b:	74 10                	je     801c4d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c3d:	8b 10                	mov    (%eax),%edx
  801c3f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c42:	89 08                	mov    %ecx,(%eax)
  801c44:	8b 02                	mov    (%edx),%eax
  801c46:	ba 00 00 00 00       	mov    $0x0,%edx
  801c4b:	eb 0e                	jmp    801c5b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801c4d:	8b 10                	mov    (%eax),%edx
  801c4f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c52:	89 08                	mov    %ecx,(%eax)
  801c54:	8b 02                	mov    (%edx),%eax
  801c56:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c63:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c67:	8b 10                	mov    (%eax),%edx
  801c69:	3b 50 04             	cmp    0x4(%eax),%edx
  801c6c:	73 0a                	jae    801c78 <sprintputch+0x1b>
		*b->buf++ = ch;
  801c6e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c71:	89 08                	mov    %ecx,(%eax)
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	88 02                	mov    %al,(%edx)
}
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801c80:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801c83:	50                   	push   %eax
  801c84:	ff 75 10             	pushl  0x10(%ebp)
  801c87:	ff 75 0c             	pushl  0xc(%ebp)
  801c8a:	ff 75 08             	pushl  0x8(%ebp)
  801c8d:	e8 05 00 00 00       	call   801c97 <vprintfmt>
	va_end(ap);
}
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	57                   	push   %edi
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 2c             	sub    $0x2c,%esp
  801ca0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ca3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ca6:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ca9:	eb 12                	jmp    801cbd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801cab:	85 c0                	test   %eax,%eax
  801cad:	0f 84 89 03 00 00    	je     80203c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801cb3:	83 ec 08             	sub    $0x8,%esp
  801cb6:	53                   	push   %ebx
  801cb7:	50                   	push   %eax
  801cb8:	ff d6                	call   *%esi
  801cba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801cbd:	83 c7 01             	add    $0x1,%edi
  801cc0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801cc4:	83 f8 25             	cmp    $0x25,%eax
  801cc7:	75 e2                	jne    801cab <vprintfmt+0x14>
  801cc9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801ccd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801cd4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cdb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce7:	eb 07                	jmp    801cf0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ce9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801cec:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cf0:	8d 47 01             	lea    0x1(%edi),%eax
  801cf3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cf6:	0f b6 07             	movzbl (%edi),%eax
  801cf9:	0f b6 c8             	movzbl %al,%ecx
  801cfc:	83 e8 23             	sub    $0x23,%eax
  801cff:	3c 55                	cmp    $0x55,%al
  801d01:	0f 87 1a 03 00 00    	ja     802021 <vprintfmt+0x38a>
  801d07:	0f b6 c0             	movzbl %al,%eax
  801d0a:	ff 24 85 20 3f 80 00 	jmp    *0x803f20(,%eax,4)
  801d11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d14:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d18:	eb d6                	jmp    801cf0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d25:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d28:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801d2c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801d2f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801d32:	83 fa 09             	cmp    $0x9,%edx
  801d35:	77 39                	ja     801d70 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d37:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d3a:	eb e9                	jmp    801d25 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d3c:	8b 45 14             	mov    0x14(%ebp),%eax
  801d3f:	8d 48 04             	lea    0x4(%eax),%ecx
  801d42:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801d45:	8b 00                	mov    (%eax),%eax
  801d47:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d4d:	eb 27                	jmp    801d76 <vprintfmt+0xdf>
  801d4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d52:	85 c0                	test   %eax,%eax
  801d54:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d59:	0f 49 c8             	cmovns %eax,%ecx
  801d5c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d62:	eb 8c                	jmp    801cf0 <vprintfmt+0x59>
  801d64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801d67:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801d6e:	eb 80                	jmp    801cf0 <vprintfmt+0x59>
  801d70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d73:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d7a:	0f 89 70 ff ff ff    	jns    801cf0 <vprintfmt+0x59>
				width = precision, precision = -1;
  801d80:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801d83:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d86:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d8d:	e9 5e ff ff ff       	jmp    801cf0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801d92:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801d98:	e9 53 ff ff ff       	jmp    801cf0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801d9d:	8b 45 14             	mov    0x14(%ebp),%eax
  801da0:	8d 50 04             	lea    0x4(%eax),%edx
  801da3:	89 55 14             	mov    %edx,0x14(%ebp)
  801da6:	83 ec 08             	sub    $0x8,%esp
  801da9:	53                   	push   %ebx
  801daa:	ff 30                	pushl  (%eax)
  801dac:	ff d6                	call   *%esi
			break;
  801dae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801db1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801db4:	e9 04 ff ff ff       	jmp    801cbd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801db9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dbc:	8d 50 04             	lea    0x4(%eax),%edx
  801dbf:	89 55 14             	mov    %edx,0x14(%ebp)
  801dc2:	8b 00                	mov    (%eax),%eax
  801dc4:	99                   	cltd   
  801dc5:	31 d0                	xor    %edx,%eax
  801dc7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801dc9:	83 f8 0f             	cmp    $0xf,%eax
  801dcc:	7f 0b                	jg     801dd9 <vprintfmt+0x142>
  801dce:	8b 14 85 80 40 80 00 	mov    0x804080(,%eax,4),%edx
  801dd5:	85 d2                	test   %edx,%edx
  801dd7:	75 18                	jne    801df1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801dd9:	50                   	push   %eax
  801dda:	68 f3 3d 80 00       	push   $0x803df3
  801ddf:	53                   	push   %ebx
  801de0:	56                   	push   %esi
  801de1:	e8 94 fe ff ff       	call   801c7a <printfmt>
  801de6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801de9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801dec:	e9 cc fe ff ff       	jmp    801cbd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801df1:	52                   	push   %edx
  801df2:	68 2f 38 80 00       	push   $0x80382f
  801df7:	53                   	push   %ebx
  801df8:	56                   	push   %esi
  801df9:	e8 7c fe ff ff       	call   801c7a <printfmt>
  801dfe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e04:	e9 b4 fe ff ff       	jmp    801cbd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801e09:	8b 45 14             	mov    0x14(%ebp),%eax
  801e0c:	8d 50 04             	lea    0x4(%eax),%edx
  801e0f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e12:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e14:	85 ff                	test   %edi,%edi
  801e16:	b8 ec 3d 80 00       	mov    $0x803dec,%eax
  801e1b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e1e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e22:	0f 8e 94 00 00 00    	jle    801ebc <vprintfmt+0x225>
  801e28:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e2c:	0f 84 98 00 00 00    	je     801eca <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e32:	83 ec 08             	sub    $0x8,%esp
  801e35:	ff 75 d0             	pushl  -0x30(%ebp)
  801e38:	57                   	push   %edi
  801e39:	e8 86 02 00 00       	call   8020c4 <strnlen>
  801e3e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e41:	29 c1                	sub    %eax,%ecx
  801e43:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801e46:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e49:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e50:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e53:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e55:	eb 0f                	jmp    801e66 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801e57:	83 ec 08             	sub    $0x8,%esp
  801e5a:	53                   	push   %ebx
  801e5b:	ff 75 e0             	pushl  -0x20(%ebp)
  801e5e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e60:	83 ef 01             	sub    $0x1,%edi
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	85 ff                	test   %edi,%edi
  801e68:	7f ed                	jg     801e57 <vprintfmt+0x1c0>
  801e6a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801e6d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e70:	85 c9                	test   %ecx,%ecx
  801e72:	b8 00 00 00 00       	mov    $0x0,%eax
  801e77:	0f 49 c1             	cmovns %ecx,%eax
  801e7a:	29 c1                	sub    %eax,%ecx
  801e7c:	89 75 08             	mov    %esi,0x8(%ebp)
  801e7f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e82:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e85:	89 cb                	mov    %ecx,%ebx
  801e87:	eb 4d                	jmp    801ed6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801e89:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801e8d:	74 1b                	je     801eaa <vprintfmt+0x213>
  801e8f:	0f be c0             	movsbl %al,%eax
  801e92:	83 e8 20             	sub    $0x20,%eax
  801e95:	83 f8 5e             	cmp    $0x5e,%eax
  801e98:	76 10                	jbe    801eaa <vprintfmt+0x213>
					putch('?', putdat);
  801e9a:	83 ec 08             	sub    $0x8,%esp
  801e9d:	ff 75 0c             	pushl  0xc(%ebp)
  801ea0:	6a 3f                	push   $0x3f
  801ea2:	ff 55 08             	call   *0x8(%ebp)
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	eb 0d                	jmp    801eb7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801eaa:	83 ec 08             	sub    $0x8,%esp
  801ead:	ff 75 0c             	pushl  0xc(%ebp)
  801eb0:	52                   	push   %edx
  801eb1:	ff 55 08             	call   *0x8(%ebp)
  801eb4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801eb7:	83 eb 01             	sub    $0x1,%ebx
  801eba:	eb 1a                	jmp    801ed6 <vprintfmt+0x23f>
  801ebc:	89 75 08             	mov    %esi,0x8(%ebp)
  801ebf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ec2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ec5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ec8:	eb 0c                	jmp    801ed6 <vprintfmt+0x23f>
  801eca:	89 75 08             	mov    %esi,0x8(%ebp)
  801ecd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ed0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ed3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ed6:	83 c7 01             	add    $0x1,%edi
  801ed9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801edd:	0f be d0             	movsbl %al,%edx
  801ee0:	85 d2                	test   %edx,%edx
  801ee2:	74 23                	je     801f07 <vprintfmt+0x270>
  801ee4:	85 f6                	test   %esi,%esi
  801ee6:	78 a1                	js     801e89 <vprintfmt+0x1f2>
  801ee8:	83 ee 01             	sub    $0x1,%esi
  801eeb:	79 9c                	jns    801e89 <vprintfmt+0x1f2>
  801eed:	89 df                	mov    %ebx,%edi
  801eef:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ef5:	eb 18                	jmp    801f0f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ef7:	83 ec 08             	sub    $0x8,%esp
  801efa:	53                   	push   %ebx
  801efb:	6a 20                	push   $0x20
  801efd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801eff:	83 ef 01             	sub    $0x1,%edi
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	eb 08                	jmp    801f0f <vprintfmt+0x278>
  801f07:	89 df                	mov    %ebx,%edi
  801f09:	8b 75 08             	mov    0x8(%ebp),%esi
  801f0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f0f:	85 ff                	test   %edi,%edi
  801f11:	7f e4                	jg     801ef7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f16:	e9 a2 fd ff ff       	jmp    801cbd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f1b:	83 fa 01             	cmp    $0x1,%edx
  801f1e:	7e 16                	jle    801f36 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801f20:	8b 45 14             	mov    0x14(%ebp),%eax
  801f23:	8d 50 08             	lea    0x8(%eax),%edx
  801f26:	89 55 14             	mov    %edx,0x14(%ebp)
  801f29:	8b 50 04             	mov    0x4(%eax),%edx
  801f2c:	8b 00                	mov    (%eax),%eax
  801f2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f31:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f34:	eb 32                	jmp    801f68 <vprintfmt+0x2d1>
	else if (lflag)
  801f36:	85 d2                	test   %edx,%edx
  801f38:	74 18                	je     801f52 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801f3a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f3d:	8d 50 04             	lea    0x4(%eax),%edx
  801f40:	89 55 14             	mov    %edx,0x14(%ebp)
  801f43:	8b 00                	mov    (%eax),%eax
  801f45:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f48:	89 c1                	mov    %eax,%ecx
  801f4a:	c1 f9 1f             	sar    $0x1f,%ecx
  801f4d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f50:	eb 16                	jmp    801f68 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801f52:	8b 45 14             	mov    0x14(%ebp),%eax
  801f55:	8d 50 04             	lea    0x4(%eax),%edx
  801f58:	89 55 14             	mov    %edx,0x14(%ebp)
  801f5b:	8b 00                	mov    (%eax),%eax
  801f5d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f60:	89 c1                	mov    %eax,%ecx
  801f62:	c1 f9 1f             	sar    $0x1f,%ecx
  801f65:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801f68:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801f6e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801f73:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f77:	79 74                	jns    801fed <vprintfmt+0x356>
				putch('-', putdat);
  801f79:	83 ec 08             	sub    $0x8,%esp
  801f7c:	53                   	push   %ebx
  801f7d:	6a 2d                	push   $0x2d
  801f7f:	ff d6                	call   *%esi
				num = -(long long) num;
  801f81:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f84:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801f87:	f7 d8                	neg    %eax
  801f89:	83 d2 00             	adc    $0x0,%edx
  801f8c:	f7 da                	neg    %edx
  801f8e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801f91:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801f96:	eb 55                	jmp    801fed <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801f98:	8d 45 14             	lea    0x14(%ebp),%eax
  801f9b:	e8 83 fc ff ff       	call   801c23 <getuint>
			base = 10;
  801fa0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801fa5:	eb 46                	jmp    801fed <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801fa7:	8d 45 14             	lea    0x14(%ebp),%eax
  801faa:	e8 74 fc ff ff       	call   801c23 <getuint>
			base = 8;
  801faf:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801fb4:	eb 37                	jmp    801fed <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801fb6:	83 ec 08             	sub    $0x8,%esp
  801fb9:	53                   	push   %ebx
  801fba:	6a 30                	push   $0x30
  801fbc:	ff d6                	call   *%esi
			putch('x', putdat);
  801fbe:	83 c4 08             	add    $0x8,%esp
  801fc1:	53                   	push   %ebx
  801fc2:	6a 78                	push   $0x78
  801fc4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801fc6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fc9:	8d 50 04             	lea    0x4(%eax),%edx
  801fcc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801fcf:	8b 00                	mov    (%eax),%eax
  801fd1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801fd6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801fd9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801fde:	eb 0d                	jmp    801fed <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801fe0:	8d 45 14             	lea    0x14(%ebp),%eax
  801fe3:	e8 3b fc ff ff       	call   801c23 <getuint>
			base = 16;
  801fe8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801fed:	83 ec 0c             	sub    $0xc,%esp
  801ff0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ff4:	57                   	push   %edi
  801ff5:	ff 75 e0             	pushl  -0x20(%ebp)
  801ff8:	51                   	push   %ecx
  801ff9:	52                   	push   %edx
  801ffa:	50                   	push   %eax
  801ffb:	89 da                	mov    %ebx,%edx
  801ffd:	89 f0                	mov    %esi,%eax
  801fff:	e8 70 fb ff ff       	call   801b74 <printnum>
			break;
  802004:	83 c4 20             	add    $0x20,%esp
  802007:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80200a:	e9 ae fc ff ff       	jmp    801cbd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80200f:	83 ec 08             	sub    $0x8,%esp
  802012:	53                   	push   %ebx
  802013:	51                   	push   %ecx
  802014:	ff d6                	call   *%esi
			break;
  802016:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802019:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80201c:	e9 9c fc ff ff       	jmp    801cbd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802021:	83 ec 08             	sub    $0x8,%esp
  802024:	53                   	push   %ebx
  802025:	6a 25                	push   $0x25
  802027:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	eb 03                	jmp    802031 <vprintfmt+0x39a>
  80202e:	83 ef 01             	sub    $0x1,%edi
  802031:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802035:	75 f7                	jne    80202e <vprintfmt+0x397>
  802037:	e9 81 fc ff ff       	jmp    801cbd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80203c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    

00802044 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	83 ec 18             	sub    $0x18,%esp
  80204a:	8b 45 08             	mov    0x8(%ebp),%eax
  80204d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802050:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802053:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802057:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80205a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802061:	85 c0                	test   %eax,%eax
  802063:	74 26                	je     80208b <vsnprintf+0x47>
  802065:	85 d2                	test   %edx,%edx
  802067:	7e 22                	jle    80208b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802069:	ff 75 14             	pushl  0x14(%ebp)
  80206c:	ff 75 10             	pushl  0x10(%ebp)
  80206f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802072:	50                   	push   %eax
  802073:	68 5d 1c 80 00       	push   $0x801c5d
  802078:	e8 1a fc ff ff       	call   801c97 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80207d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802080:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802083:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	eb 05                	jmp    802090 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80208b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802090:	c9                   	leave  
  802091:	c3                   	ret    

00802092 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802098:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80209b:	50                   	push   %eax
  80209c:	ff 75 10             	pushl  0x10(%ebp)
  80209f:	ff 75 0c             	pushl  0xc(%ebp)
  8020a2:	ff 75 08             	pushl  0x8(%ebp)
  8020a5:	e8 9a ff ff ff       	call   802044 <vsnprintf>
	va_end(ap);

	return rc;
}
  8020aa:	c9                   	leave  
  8020ab:	c3                   	ret    

008020ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8020b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b7:	eb 03                	jmp    8020bc <strlen+0x10>
		n++;
  8020b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8020bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8020c0:	75 f7                	jne    8020b9 <strlen+0xd>
		n++;
	return n;
}
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    

008020c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8020d2:	eb 03                	jmp    8020d7 <strnlen+0x13>
		n++;
  8020d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020d7:	39 c2                	cmp    %eax,%edx
  8020d9:	74 08                	je     8020e3 <strnlen+0x1f>
  8020db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8020df:	75 f3                	jne    8020d4 <strnlen+0x10>
  8020e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    

008020e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	53                   	push   %ebx
  8020e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8020ef:	89 c2                	mov    %eax,%edx
  8020f1:	83 c2 01             	add    $0x1,%edx
  8020f4:	83 c1 01             	add    $0x1,%ecx
  8020f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8020fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8020fe:	84 db                	test   %bl,%bl
  802100:	75 ef                	jne    8020f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802102:	5b                   	pop    %ebx
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	53                   	push   %ebx
  802109:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80210c:	53                   	push   %ebx
  80210d:	e8 9a ff ff ff       	call   8020ac <strlen>
  802112:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802115:	ff 75 0c             	pushl  0xc(%ebp)
  802118:	01 d8                	add    %ebx,%eax
  80211a:	50                   	push   %eax
  80211b:	e8 c5 ff ff ff       	call   8020e5 <strcpy>
	return dst;
}
  802120:	89 d8                	mov    %ebx,%eax
  802122:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802125:	c9                   	leave  
  802126:	c3                   	ret    

00802127 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802127:	55                   	push   %ebp
  802128:	89 e5                	mov    %esp,%ebp
  80212a:	56                   	push   %esi
  80212b:	53                   	push   %ebx
  80212c:	8b 75 08             	mov    0x8(%ebp),%esi
  80212f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802132:	89 f3                	mov    %esi,%ebx
  802134:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802137:	89 f2                	mov    %esi,%edx
  802139:	eb 0f                	jmp    80214a <strncpy+0x23>
		*dst++ = *src;
  80213b:	83 c2 01             	add    $0x1,%edx
  80213e:	0f b6 01             	movzbl (%ecx),%eax
  802141:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802144:	80 39 01             	cmpb   $0x1,(%ecx)
  802147:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80214a:	39 da                	cmp    %ebx,%edx
  80214c:	75 ed                	jne    80213b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80214e:	89 f0                	mov    %esi,%eax
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    

00802154 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
  802159:	8b 75 08             	mov    0x8(%ebp),%esi
  80215c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80215f:	8b 55 10             	mov    0x10(%ebp),%edx
  802162:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802164:	85 d2                	test   %edx,%edx
  802166:	74 21                	je     802189 <strlcpy+0x35>
  802168:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80216c:	89 f2                	mov    %esi,%edx
  80216e:	eb 09                	jmp    802179 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802170:	83 c2 01             	add    $0x1,%edx
  802173:	83 c1 01             	add    $0x1,%ecx
  802176:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802179:	39 c2                	cmp    %eax,%edx
  80217b:	74 09                	je     802186 <strlcpy+0x32>
  80217d:	0f b6 19             	movzbl (%ecx),%ebx
  802180:	84 db                	test   %bl,%bl
  802182:	75 ec                	jne    802170 <strlcpy+0x1c>
  802184:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  802186:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802189:	29 f0                	sub    %esi,%eax
}
  80218b:	5b                   	pop    %ebx
  80218c:	5e                   	pop    %esi
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    

0080218f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802195:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802198:	eb 06                	jmp    8021a0 <strcmp+0x11>
		p++, q++;
  80219a:	83 c1 01             	add    $0x1,%ecx
  80219d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8021a0:	0f b6 01             	movzbl (%ecx),%eax
  8021a3:	84 c0                	test   %al,%al
  8021a5:	74 04                	je     8021ab <strcmp+0x1c>
  8021a7:	3a 02                	cmp    (%edx),%al
  8021a9:	74 ef                	je     80219a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8021ab:	0f b6 c0             	movzbl %al,%eax
  8021ae:	0f b6 12             	movzbl (%edx),%edx
  8021b1:	29 d0                	sub    %edx,%eax
}
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    

008021b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	53                   	push   %ebx
  8021b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021bf:	89 c3                	mov    %eax,%ebx
  8021c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8021c4:	eb 06                	jmp    8021cc <strncmp+0x17>
		n--, p++, q++;
  8021c6:	83 c0 01             	add    $0x1,%eax
  8021c9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8021cc:	39 d8                	cmp    %ebx,%eax
  8021ce:	74 15                	je     8021e5 <strncmp+0x30>
  8021d0:	0f b6 08             	movzbl (%eax),%ecx
  8021d3:	84 c9                	test   %cl,%cl
  8021d5:	74 04                	je     8021db <strncmp+0x26>
  8021d7:	3a 0a                	cmp    (%edx),%cl
  8021d9:	74 eb                	je     8021c6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8021db:	0f b6 00             	movzbl (%eax),%eax
  8021de:	0f b6 12             	movzbl (%edx),%edx
  8021e1:	29 d0                	sub    %edx,%eax
  8021e3:	eb 05                	jmp    8021ea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8021e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8021ea:	5b                   	pop    %ebx
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    

008021ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8021ed:	55                   	push   %ebp
  8021ee:	89 e5                	mov    %esp,%ebp
  8021f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8021f7:	eb 07                	jmp    802200 <strchr+0x13>
		if (*s == c)
  8021f9:	38 ca                	cmp    %cl,%dl
  8021fb:	74 0f                	je     80220c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8021fd:	83 c0 01             	add    $0x1,%eax
  802200:	0f b6 10             	movzbl (%eax),%edx
  802203:	84 d2                	test   %dl,%dl
  802205:	75 f2                	jne    8021f9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802207:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    

0080220e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	8b 45 08             	mov    0x8(%ebp),%eax
  802214:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802218:	eb 03                	jmp    80221d <strfind+0xf>
  80221a:	83 c0 01             	add    $0x1,%eax
  80221d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802220:	38 ca                	cmp    %cl,%dl
  802222:	74 04                	je     802228 <strfind+0x1a>
  802224:	84 d2                	test   %dl,%dl
  802226:	75 f2                	jne    80221a <strfind+0xc>
			break;
	return (char *) s;
}
  802228:	5d                   	pop    %ebp
  802229:	c3                   	ret    

0080222a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80222a:	55                   	push   %ebp
  80222b:	89 e5                	mov    %esp,%ebp
  80222d:	57                   	push   %edi
  80222e:	56                   	push   %esi
  80222f:	53                   	push   %ebx
  802230:	8b 7d 08             	mov    0x8(%ebp),%edi
  802233:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802236:	85 c9                	test   %ecx,%ecx
  802238:	74 36                	je     802270 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80223a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802240:	75 28                	jne    80226a <memset+0x40>
  802242:	f6 c1 03             	test   $0x3,%cl
  802245:	75 23                	jne    80226a <memset+0x40>
		c &= 0xFF;
  802247:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80224b:	89 d3                	mov    %edx,%ebx
  80224d:	c1 e3 08             	shl    $0x8,%ebx
  802250:	89 d6                	mov    %edx,%esi
  802252:	c1 e6 18             	shl    $0x18,%esi
  802255:	89 d0                	mov    %edx,%eax
  802257:	c1 e0 10             	shl    $0x10,%eax
  80225a:	09 f0                	or     %esi,%eax
  80225c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80225e:	89 d8                	mov    %ebx,%eax
  802260:	09 d0                	or     %edx,%eax
  802262:	c1 e9 02             	shr    $0x2,%ecx
  802265:	fc                   	cld    
  802266:	f3 ab                	rep stos %eax,%es:(%edi)
  802268:	eb 06                	jmp    802270 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80226a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226d:	fc                   	cld    
  80226e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802270:	89 f8                	mov    %edi,%eax
  802272:	5b                   	pop    %ebx
  802273:	5e                   	pop    %esi
  802274:	5f                   	pop    %edi
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    

00802277 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	57                   	push   %edi
  80227b:	56                   	push   %esi
  80227c:	8b 45 08             	mov    0x8(%ebp),%eax
  80227f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802282:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802285:	39 c6                	cmp    %eax,%esi
  802287:	73 35                	jae    8022be <memmove+0x47>
  802289:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80228c:	39 d0                	cmp    %edx,%eax
  80228e:	73 2e                	jae    8022be <memmove+0x47>
		s += n;
		d += n;
  802290:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802293:	89 d6                	mov    %edx,%esi
  802295:	09 fe                	or     %edi,%esi
  802297:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80229d:	75 13                	jne    8022b2 <memmove+0x3b>
  80229f:	f6 c1 03             	test   $0x3,%cl
  8022a2:	75 0e                	jne    8022b2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8022a4:	83 ef 04             	sub    $0x4,%edi
  8022a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8022aa:	c1 e9 02             	shr    $0x2,%ecx
  8022ad:	fd                   	std    
  8022ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022b0:	eb 09                	jmp    8022bb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8022b2:	83 ef 01             	sub    $0x1,%edi
  8022b5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8022b8:	fd                   	std    
  8022b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8022bb:	fc                   	cld    
  8022bc:	eb 1d                	jmp    8022db <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022be:	89 f2                	mov    %esi,%edx
  8022c0:	09 c2                	or     %eax,%edx
  8022c2:	f6 c2 03             	test   $0x3,%dl
  8022c5:	75 0f                	jne    8022d6 <memmove+0x5f>
  8022c7:	f6 c1 03             	test   $0x3,%cl
  8022ca:	75 0a                	jne    8022d6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8022cc:	c1 e9 02             	shr    $0x2,%ecx
  8022cf:	89 c7                	mov    %eax,%edi
  8022d1:	fc                   	cld    
  8022d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022d4:	eb 05                	jmp    8022db <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8022d6:	89 c7                	mov    %eax,%edi
  8022d8:	fc                   	cld    
  8022d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8022db:	5e                   	pop    %esi
  8022dc:	5f                   	pop    %edi
  8022dd:	5d                   	pop    %ebp
  8022de:	c3                   	ret    

008022df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8022df:	55                   	push   %ebp
  8022e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8022e2:	ff 75 10             	pushl  0x10(%ebp)
  8022e5:	ff 75 0c             	pushl  0xc(%ebp)
  8022e8:	ff 75 08             	pushl  0x8(%ebp)
  8022eb:	e8 87 ff ff ff       	call   802277 <memmove>
}
  8022f0:	c9                   	leave  
  8022f1:	c3                   	ret    

008022f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
  8022f5:	56                   	push   %esi
  8022f6:	53                   	push   %ebx
  8022f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022fd:	89 c6                	mov    %eax,%esi
  8022ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802302:	eb 1a                	jmp    80231e <memcmp+0x2c>
		if (*s1 != *s2)
  802304:	0f b6 08             	movzbl (%eax),%ecx
  802307:	0f b6 1a             	movzbl (%edx),%ebx
  80230a:	38 d9                	cmp    %bl,%cl
  80230c:	74 0a                	je     802318 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80230e:	0f b6 c1             	movzbl %cl,%eax
  802311:	0f b6 db             	movzbl %bl,%ebx
  802314:	29 d8                	sub    %ebx,%eax
  802316:	eb 0f                	jmp    802327 <memcmp+0x35>
		s1++, s2++;
  802318:	83 c0 01             	add    $0x1,%eax
  80231b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80231e:	39 f0                	cmp    %esi,%eax
  802320:	75 e2                	jne    802304 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802322:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802327:	5b                   	pop    %ebx
  802328:	5e                   	pop    %esi
  802329:	5d                   	pop    %ebp
  80232a:	c3                   	ret    

0080232b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	53                   	push   %ebx
  80232f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802332:	89 c1                	mov    %eax,%ecx
  802334:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802337:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80233b:	eb 0a                	jmp    802347 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80233d:	0f b6 10             	movzbl (%eax),%edx
  802340:	39 da                	cmp    %ebx,%edx
  802342:	74 07                	je     80234b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802344:	83 c0 01             	add    $0x1,%eax
  802347:	39 c8                	cmp    %ecx,%eax
  802349:	72 f2                	jb     80233d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80234b:	5b                   	pop    %ebx
  80234c:	5d                   	pop    %ebp
  80234d:	c3                   	ret    

0080234e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802357:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80235a:	eb 03                	jmp    80235f <strtol+0x11>
		s++;
  80235c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80235f:	0f b6 01             	movzbl (%ecx),%eax
  802362:	3c 20                	cmp    $0x20,%al
  802364:	74 f6                	je     80235c <strtol+0xe>
  802366:	3c 09                	cmp    $0x9,%al
  802368:	74 f2                	je     80235c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80236a:	3c 2b                	cmp    $0x2b,%al
  80236c:	75 0a                	jne    802378 <strtol+0x2a>
		s++;
  80236e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802371:	bf 00 00 00 00       	mov    $0x0,%edi
  802376:	eb 11                	jmp    802389 <strtol+0x3b>
  802378:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80237d:	3c 2d                	cmp    $0x2d,%al
  80237f:	75 08                	jne    802389 <strtol+0x3b>
		s++, neg = 1;
  802381:	83 c1 01             	add    $0x1,%ecx
  802384:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802389:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80238f:	75 15                	jne    8023a6 <strtol+0x58>
  802391:	80 39 30             	cmpb   $0x30,(%ecx)
  802394:	75 10                	jne    8023a6 <strtol+0x58>
  802396:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80239a:	75 7c                	jne    802418 <strtol+0xca>
		s += 2, base = 16;
  80239c:	83 c1 02             	add    $0x2,%ecx
  80239f:	bb 10 00 00 00       	mov    $0x10,%ebx
  8023a4:	eb 16                	jmp    8023bc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8023a6:	85 db                	test   %ebx,%ebx
  8023a8:	75 12                	jne    8023bc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8023aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8023af:	80 39 30             	cmpb   $0x30,(%ecx)
  8023b2:	75 08                	jne    8023bc <strtol+0x6e>
		s++, base = 8;
  8023b4:	83 c1 01             	add    $0x1,%ecx
  8023b7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8023bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8023c1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8023c4:	0f b6 11             	movzbl (%ecx),%edx
  8023c7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8023ca:	89 f3                	mov    %esi,%ebx
  8023cc:	80 fb 09             	cmp    $0x9,%bl
  8023cf:	77 08                	ja     8023d9 <strtol+0x8b>
			dig = *s - '0';
  8023d1:	0f be d2             	movsbl %dl,%edx
  8023d4:	83 ea 30             	sub    $0x30,%edx
  8023d7:	eb 22                	jmp    8023fb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8023d9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8023dc:	89 f3                	mov    %esi,%ebx
  8023de:	80 fb 19             	cmp    $0x19,%bl
  8023e1:	77 08                	ja     8023eb <strtol+0x9d>
			dig = *s - 'a' + 10;
  8023e3:	0f be d2             	movsbl %dl,%edx
  8023e6:	83 ea 57             	sub    $0x57,%edx
  8023e9:	eb 10                	jmp    8023fb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8023eb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8023ee:	89 f3                	mov    %esi,%ebx
  8023f0:	80 fb 19             	cmp    $0x19,%bl
  8023f3:	77 16                	ja     80240b <strtol+0xbd>
			dig = *s - 'A' + 10;
  8023f5:	0f be d2             	movsbl %dl,%edx
  8023f8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8023fb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8023fe:	7d 0b                	jge    80240b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802400:	83 c1 01             	add    $0x1,%ecx
  802403:	0f af 45 10          	imul   0x10(%ebp),%eax
  802407:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802409:	eb b9                	jmp    8023c4 <strtol+0x76>

	if (endptr)
  80240b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80240f:	74 0d                	je     80241e <strtol+0xd0>
		*endptr = (char *) s;
  802411:	8b 75 0c             	mov    0xc(%ebp),%esi
  802414:	89 0e                	mov    %ecx,(%esi)
  802416:	eb 06                	jmp    80241e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802418:	85 db                	test   %ebx,%ebx
  80241a:	74 98                	je     8023b4 <strtol+0x66>
  80241c:	eb 9e                	jmp    8023bc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80241e:	89 c2                	mov    %eax,%edx
  802420:	f7 da                	neg    %edx
  802422:	85 ff                	test   %edi,%edi
  802424:	0f 45 c2             	cmovne %edx,%eax
}
  802427:	5b                   	pop    %ebx
  802428:	5e                   	pop    %esi
  802429:	5f                   	pop    %edi
  80242a:	5d                   	pop    %ebp
  80242b:	c3                   	ret    

0080242c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80242c:	55                   	push   %ebp
  80242d:	89 e5                	mov    %esp,%ebp
  80242f:	57                   	push   %edi
  802430:	56                   	push   %esi
  802431:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802432:	b8 00 00 00 00       	mov    $0x0,%eax
  802437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80243a:	8b 55 08             	mov    0x8(%ebp),%edx
  80243d:	89 c3                	mov    %eax,%ebx
  80243f:	89 c7                	mov    %eax,%edi
  802441:	89 c6                	mov    %eax,%esi
  802443:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802445:	5b                   	pop    %ebx
  802446:	5e                   	pop    %esi
  802447:	5f                   	pop    %edi
  802448:	5d                   	pop    %ebp
  802449:	c3                   	ret    

0080244a <sys_cgetc>:

int
sys_cgetc(void)
{
  80244a:	55                   	push   %ebp
  80244b:	89 e5                	mov    %esp,%ebp
  80244d:	57                   	push   %edi
  80244e:	56                   	push   %esi
  80244f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802450:	ba 00 00 00 00       	mov    $0x0,%edx
  802455:	b8 01 00 00 00       	mov    $0x1,%eax
  80245a:	89 d1                	mov    %edx,%ecx
  80245c:	89 d3                	mov    %edx,%ebx
  80245e:	89 d7                	mov    %edx,%edi
  802460:	89 d6                	mov    %edx,%esi
  802462:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802464:	5b                   	pop    %ebx
  802465:	5e                   	pop    %esi
  802466:	5f                   	pop    %edi
  802467:	5d                   	pop    %ebp
  802468:	c3                   	ret    

00802469 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802469:	55                   	push   %ebp
  80246a:	89 e5                	mov    %esp,%ebp
  80246c:	57                   	push   %edi
  80246d:	56                   	push   %esi
  80246e:	53                   	push   %ebx
  80246f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802472:	b9 00 00 00 00       	mov    $0x0,%ecx
  802477:	b8 03 00 00 00       	mov    $0x3,%eax
  80247c:	8b 55 08             	mov    0x8(%ebp),%edx
  80247f:	89 cb                	mov    %ecx,%ebx
  802481:	89 cf                	mov    %ecx,%edi
  802483:	89 ce                	mov    %ecx,%esi
  802485:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802487:	85 c0                	test   %eax,%eax
  802489:	7e 17                	jle    8024a2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80248b:	83 ec 0c             	sub    $0xc,%esp
  80248e:	50                   	push   %eax
  80248f:	6a 03                	push   $0x3
  802491:	68 df 40 80 00       	push   $0x8040df
  802496:	6a 23                	push   $0x23
  802498:	68 fc 40 80 00       	push   $0x8040fc
  80249d:	e8 e5 f5 ff ff       	call   801a87 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8024a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a5:	5b                   	pop    %ebx
  8024a6:	5e                   	pop    %esi
  8024a7:	5f                   	pop    %edi
  8024a8:	5d                   	pop    %ebp
  8024a9:	c3                   	ret    

008024aa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8024aa:	55                   	push   %ebp
  8024ab:	89 e5                	mov    %esp,%ebp
  8024ad:	57                   	push   %edi
  8024ae:	56                   	push   %esi
  8024af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8024b5:	b8 02 00 00 00       	mov    $0x2,%eax
  8024ba:	89 d1                	mov    %edx,%ecx
  8024bc:	89 d3                	mov    %edx,%ebx
  8024be:	89 d7                	mov    %edx,%edi
  8024c0:	89 d6                	mov    %edx,%esi
  8024c2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8024c4:	5b                   	pop    %ebx
  8024c5:	5e                   	pop    %esi
  8024c6:	5f                   	pop    %edi
  8024c7:	5d                   	pop    %ebp
  8024c8:	c3                   	ret    

008024c9 <sys_yield>:

void
sys_yield(void)
{
  8024c9:	55                   	push   %ebp
  8024ca:	89 e5                	mov    %esp,%ebp
  8024cc:	57                   	push   %edi
  8024cd:	56                   	push   %esi
  8024ce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8024d4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8024d9:	89 d1                	mov    %edx,%ecx
  8024db:	89 d3                	mov    %edx,%ebx
  8024dd:	89 d7                	mov    %edx,%edi
  8024df:	89 d6                	mov    %edx,%esi
  8024e1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5f                   	pop    %edi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    

008024e8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8024e8:	55                   	push   %ebp
  8024e9:	89 e5                	mov    %esp,%ebp
  8024eb:	57                   	push   %edi
  8024ec:	56                   	push   %esi
  8024ed:	53                   	push   %ebx
  8024ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024f1:	be 00 00 00 00       	mov    $0x0,%esi
  8024f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8024fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024fe:	8b 55 08             	mov    0x8(%ebp),%edx
  802501:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802504:	89 f7                	mov    %esi,%edi
  802506:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802508:	85 c0                	test   %eax,%eax
  80250a:	7e 17                	jle    802523 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80250c:	83 ec 0c             	sub    $0xc,%esp
  80250f:	50                   	push   %eax
  802510:	6a 04                	push   $0x4
  802512:	68 df 40 80 00       	push   $0x8040df
  802517:	6a 23                	push   $0x23
  802519:	68 fc 40 80 00       	push   $0x8040fc
  80251e:	e8 64 f5 ff ff       	call   801a87 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802523:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802526:	5b                   	pop    %ebx
  802527:	5e                   	pop    %esi
  802528:	5f                   	pop    %edi
  802529:	5d                   	pop    %ebp
  80252a:	c3                   	ret    

0080252b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80252b:	55                   	push   %ebp
  80252c:	89 e5                	mov    %esp,%ebp
  80252e:	57                   	push   %edi
  80252f:	56                   	push   %esi
  802530:	53                   	push   %ebx
  802531:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802534:	b8 05 00 00 00       	mov    $0x5,%eax
  802539:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80253c:	8b 55 08             	mov    0x8(%ebp),%edx
  80253f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802542:	8b 7d 14             	mov    0x14(%ebp),%edi
  802545:	8b 75 18             	mov    0x18(%ebp),%esi
  802548:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80254a:	85 c0                	test   %eax,%eax
  80254c:	7e 17                	jle    802565 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80254e:	83 ec 0c             	sub    $0xc,%esp
  802551:	50                   	push   %eax
  802552:	6a 05                	push   $0x5
  802554:	68 df 40 80 00       	push   $0x8040df
  802559:	6a 23                	push   $0x23
  80255b:	68 fc 40 80 00       	push   $0x8040fc
  802560:	e8 22 f5 ff ff       	call   801a87 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802565:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802568:	5b                   	pop    %ebx
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    

0080256d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80256d:	55                   	push   %ebp
  80256e:	89 e5                	mov    %esp,%ebp
  802570:	57                   	push   %edi
  802571:	56                   	push   %esi
  802572:	53                   	push   %ebx
  802573:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802576:	bb 00 00 00 00       	mov    $0x0,%ebx
  80257b:	b8 06 00 00 00       	mov    $0x6,%eax
  802580:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802583:	8b 55 08             	mov    0x8(%ebp),%edx
  802586:	89 df                	mov    %ebx,%edi
  802588:	89 de                	mov    %ebx,%esi
  80258a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80258c:	85 c0                	test   %eax,%eax
  80258e:	7e 17                	jle    8025a7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802590:	83 ec 0c             	sub    $0xc,%esp
  802593:	50                   	push   %eax
  802594:	6a 06                	push   $0x6
  802596:	68 df 40 80 00       	push   $0x8040df
  80259b:	6a 23                	push   $0x23
  80259d:	68 fc 40 80 00       	push   $0x8040fc
  8025a2:	e8 e0 f4 ff ff       	call   801a87 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8025a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025aa:	5b                   	pop    %ebx
  8025ab:	5e                   	pop    %esi
  8025ac:	5f                   	pop    %edi
  8025ad:	5d                   	pop    %ebp
  8025ae:	c3                   	ret    

008025af <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8025af:	55                   	push   %ebp
  8025b0:	89 e5                	mov    %esp,%ebp
  8025b2:	57                   	push   %edi
  8025b3:	56                   	push   %esi
  8025b4:	53                   	push   %ebx
  8025b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8025c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8025c8:	89 df                	mov    %ebx,%edi
  8025ca:	89 de                	mov    %ebx,%esi
  8025cc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025ce:	85 c0                	test   %eax,%eax
  8025d0:	7e 17                	jle    8025e9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025d2:	83 ec 0c             	sub    $0xc,%esp
  8025d5:	50                   	push   %eax
  8025d6:	6a 08                	push   $0x8
  8025d8:	68 df 40 80 00       	push   $0x8040df
  8025dd:	6a 23                	push   $0x23
  8025df:	68 fc 40 80 00       	push   $0x8040fc
  8025e4:	e8 9e f4 ff ff       	call   801a87 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8025e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ec:	5b                   	pop    %ebx
  8025ed:	5e                   	pop    %esi
  8025ee:	5f                   	pop    %edi
  8025ef:	5d                   	pop    %ebp
  8025f0:	c3                   	ret    

008025f1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8025f1:	55                   	push   %ebp
  8025f2:	89 e5                	mov    %esp,%ebp
  8025f4:	57                   	push   %edi
  8025f5:	56                   	push   %esi
  8025f6:	53                   	push   %ebx
  8025f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025ff:	b8 09 00 00 00       	mov    $0x9,%eax
  802604:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802607:	8b 55 08             	mov    0x8(%ebp),%edx
  80260a:	89 df                	mov    %ebx,%edi
  80260c:	89 de                	mov    %ebx,%esi
  80260e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802610:	85 c0                	test   %eax,%eax
  802612:	7e 17                	jle    80262b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802614:	83 ec 0c             	sub    $0xc,%esp
  802617:	50                   	push   %eax
  802618:	6a 09                	push   $0x9
  80261a:	68 df 40 80 00       	push   $0x8040df
  80261f:	6a 23                	push   $0x23
  802621:	68 fc 40 80 00       	push   $0x8040fc
  802626:	e8 5c f4 ff ff       	call   801a87 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80262b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80262e:	5b                   	pop    %ebx
  80262f:	5e                   	pop    %esi
  802630:	5f                   	pop    %edi
  802631:	5d                   	pop    %ebp
  802632:	c3                   	ret    

00802633 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802633:	55                   	push   %ebp
  802634:	89 e5                	mov    %esp,%ebp
  802636:	57                   	push   %edi
  802637:	56                   	push   %esi
  802638:	53                   	push   %ebx
  802639:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80263c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802641:	b8 0a 00 00 00       	mov    $0xa,%eax
  802646:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802649:	8b 55 08             	mov    0x8(%ebp),%edx
  80264c:	89 df                	mov    %ebx,%edi
  80264e:	89 de                	mov    %ebx,%esi
  802650:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802652:	85 c0                	test   %eax,%eax
  802654:	7e 17                	jle    80266d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802656:	83 ec 0c             	sub    $0xc,%esp
  802659:	50                   	push   %eax
  80265a:	6a 0a                	push   $0xa
  80265c:	68 df 40 80 00       	push   $0x8040df
  802661:	6a 23                	push   $0x23
  802663:	68 fc 40 80 00       	push   $0x8040fc
  802668:	e8 1a f4 ff ff       	call   801a87 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80266d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802670:	5b                   	pop    %ebx
  802671:	5e                   	pop    %esi
  802672:	5f                   	pop    %edi
  802673:	5d                   	pop    %ebp
  802674:	c3                   	ret    

00802675 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802675:	55                   	push   %ebp
  802676:	89 e5                	mov    %esp,%ebp
  802678:	57                   	push   %edi
  802679:	56                   	push   %esi
  80267a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80267b:	be 00 00 00 00       	mov    $0x0,%esi
  802680:	b8 0c 00 00 00       	mov    $0xc,%eax
  802685:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802688:	8b 55 08             	mov    0x8(%ebp),%edx
  80268b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80268e:	8b 7d 14             	mov    0x14(%ebp),%edi
  802691:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802693:	5b                   	pop    %ebx
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    

00802698 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802698:	55                   	push   %ebp
  802699:	89 e5                	mov    %esp,%ebp
  80269b:	57                   	push   %edi
  80269c:	56                   	push   %esi
  80269d:	53                   	push   %ebx
  80269e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026a6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8026ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ae:	89 cb                	mov    %ecx,%ebx
  8026b0:	89 cf                	mov    %ecx,%edi
  8026b2:	89 ce                	mov    %ecx,%esi
  8026b4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026b6:	85 c0                	test   %eax,%eax
  8026b8:	7e 17                	jle    8026d1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026ba:	83 ec 0c             	sub    $0xc,%esp
  8026bd:	50                   	push   %eax
  8026be:	6a 0d                	push   $0xd
  8026c0:	68 df 40 80 00       	push   $0x8040df
  8026c5:	6a 23                	push   $0x23
  8026c7:	68 fc 40 80 00       	push   $0x8040fc
  8026cc:	e8 b6 f3 ff ff       	call   801a87 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8026d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5e                   	pop    %esi
  8026d6:	5f                   	pop    %edi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    

008026d9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026d9:	55                   	push   %ebp
  8026da:	89 e5                	mov    %esp,%ebp
  8026dc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026df:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  8026e6:	75 2e                	jne    802716 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8026e8:	e8 bd fd ff ff       	call   8024aa <sys_getenvid>
  8026ed:	83 ec 04             	sub    $0x4,%esp
  8026f0:	68 07 0e 00 00       	push   $0xe07
  8026f5:	68 00 f0 bf ee       	push   $0xeebff000
  8026fa:	50                   	push   %eax
  8026fb:	e8 e8 fd ff ff       	call   8024e8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802700:	e8 a5 fd ff ff       	call   8024aa <sys_getenvid>
  802705:	83 c4 08             	add    $0x8,%esp
  802708:	68 20 27 80 00       	push   $0x802720
  80270d:	50                   	push   %eax
  80270e:	e8 20 ff ff ff       	call   802633 <sys_env_set_pgfault_upcall>
  802713:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802716:	8b 45 08             	mov    0x8(%ebp),%eax
  802719:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  80271e:	c9                   	leave  
  80271f:	c3                   	ret    

00802720 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802720:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802721:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802726:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802728:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80272b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80272f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802733:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802736:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802739:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80273a:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80273d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80273e:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80273f:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802743:	c3                   	ret    

00802744 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802744:	55                   	push   %ebp
  802745:	89 e5                	mov    %esp,%ebp
  802747:	56                   	push   %esi
  802748:	53                   	push   %ebx
  802749:	8b 75 08             	mov    0x8(%ebp),%esi
  80274c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80274f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802752:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802754:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802759:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80275c:	83 ec 0c             	sub    $0xc,%esp
  80275f:	50                   	push   %eax
  802760:	e8 33 ff ff ff       	call   802698 <sys_ipc_recv>

	if (from_env_store != NULL)
  802765:	83 c4 10             	add    $0x10,%esp
  802768:	85 f6                	test   %esi,%esi
  80276a:	74 14                	je     802780 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80276c:	ba 00 00 00 00       	mov    $0x0,%edx
  802771:	85 c0                	test   %eax,%eax
  802773:	78 09                	js     80277e <ipc_recv+0x3a>
  802775:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  80277b:	8b 52 74             	mov    0x74(%edx),%edx
  80277e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802780:	85 db                	test   %ebx,%ebx
  802782:	74 14                	je     802798 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802784:	ba 00 00 00 00       	mov    $0x0,%edx
  802789:	85 c0                	test   %eax,%eax
  80278b:	78 09                	js     802796 <ipc_recv+0x52>
  80278d:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  802793:	8b 52 78             	mov    0x78(%edx),%edx
  802796:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802798:	85 c0                	test   %eax,%eax
  80279a:	78 08                	js     8027a4 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80279c:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8027a1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8027a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027a7:	5b                   	pop    %ebx
  8027a8:	5e                   	pop    %esi
  8027a9:	5d                   	pop    %ebp
  8027aa:	c3                   	ret    

008027ab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027ab:	55                   	push   %ebp
  8027ac:	89 e5                	mov    %esp,%ebp
  8027ae:	57                   	push   %edi
  8027af:	56                   	push   %esi
  8027b0:	53                   	push   %ebx
  8027b1:	83 ec 0c             	sub    $0xc,%esp
  8027b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8027bd:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8027bf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8027c4:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8027c7:	ff 75 14             	pushl  0x14(%ebp)
  8027ca:	53                   	push   %ebx
  8027cb:	56                   	push   %esi
  8027cc:	57                   	push   %edi
  8027cd:	e8 a3 fe ff ff       	call   802675 <sys_ipc_try_send>

		if (err < 0) {
  8027d2:	83 c4 10             	add    $0x10,%esp
  8027d5:	85 c0                	test   %eax,%eax
  8027d7:	79 1e                	jns    8027f7 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8027d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8027dc:	75 07                	jne    8027e5 <ipc_send+0x3a>
				sys_yield();
  8027de:	e8 e6 fc ff ff       	call   8024c9 <sys_yield>
  8027e3:	eb e2                	jmp    8027c7 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8027e5:	50                   	push   %eax
  8027e6:	68 0a 41 80 00       	push   $0x80410a
  8027eb:	6a 49                	push   $0x49
  8027ed:	68 17 41 80 00       	push   $0x804117
  8027f2:	e8 90 f2 ff ff       	call   801a87 <_panic>
		}

	} while (err < 0);

}
  8027f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027fa:	5b                   	pop    %ebx
  8027fb:	5e                   	pop    %esi
  8027fc:	5f                   	pop    %edi
  8027fd:	5d                   	pop    %ebp
  8027fe:	c3                   	ret    

008027ff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027ff:	55                   	push   %ebp
  802800:	89 e5                	mov    %esp,%ebp
  802802:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802805:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80280a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80280d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802813:	8b 52 50             	mov    0x50(%edx),%edx
  802816:	39 ca                	cmp    %ecx,%edx
  802818:	75 0d                	jne    802827 <ipc_find_env+0x28>
			return envs[i].env_id;
  80281a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80281d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802822:	8b 40 48             	mov    0x48(%eax),%eax
  802825:	eb 0f                	jmp    802836 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802827:	83 c0 01             	add    $0x1,%eax
  80282a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80282f:	75 d9                	jne    80280a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802831:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802836:	5d                   	pop    %ebp
  802837:	c3                   	ret    

00802838 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802838:	55                   	push   %ebp
  802839:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80283b:	8b 45 08             	mov    0x8(%ebp),%eax
  80283e:	05 00 00 00 30       	add    $0x30000000,%eax
  802843:	c1 e8 0c             	shr    $0xc,%eax
}
  802846:	5d                   	pop    %ebp
  802847:	c3                   	ret    

00802848 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802848:	55                   	push   %ebp
  802849:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80284b:	8b 45 08             	mov    0x8(%ebp),%eax
  80284e:	05 00 00 00 30       	add    $0x30000000,%eax
  802853:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802858:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80285d:	5d                   	pop    %ebp
  80285e:	c3                   	ret    

0080285f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80285f:	55                   	push   %ebp
  802860:	89 e5                	mov    %esp,%ebp
  802862:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802865:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80286a:	89 c2                	mov    %eax,%edx
  80286c:	c1 ea 16             	shr    $0x16,%edx
  80286f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802876:	f6 c2 01             	test   $0x1,%dl
  802879:	74 11                	je     80288c <fd_alloc+0x2d>
  80287b:	89 c2                	mov    %eax,%edx
  80287d:	c1 ea 0c             	shr    $0xc,%edx
  802880:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802887:	f6 c2 01             	test   $0x1,%dl
  80288a:	75 09                	jne    802895 <fd_alloc+0x36>
			*fd_store = fd;
  80288c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80288e:	b8 00 00 00 00       	mov    $0x0,%eax
  802893:	eb 17                	jmp    8028ac <fd_alloc+0x4d>
  802895:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80289a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80289f:	75 c9                	jne    80286a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8028a1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8028a7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8028ac:	5d                   	pop    %ebp
  8028ad:	c3                   	ret    

008028ae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8028ae:	55                   	push   %ebp
  8028af:	89 e5                	mov    %esp,%ebp
  8028b1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8028b4:	83 f8 1f             	cmp    $0x1f,%eax
  8028b7:	77 36                	ja     8028ef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8028b9:	c1 e0 0c             	shl    $0xc,%eax
  8028bc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8028c1:	89 c2                	mov    %eax,%edx
  8028c3:	c1 ea 16             	shr    $0x16,%edx
  8028c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028cd:	f6 c2 01             	test   $0x1,%dl
  8028d0:	74 24                	je     8028f6 <fd_lookup+0x48>
  8028d2:	89 c2                	mov    %eax,%edx
  8028d4:	c1 ea 0c             	shr    $0xc,%edx
  8028d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8028de:	f6 c2 01             	test   $0x1,%dl
  8028e1:	74 1a                	je     8028fd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8028e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028e6:	89 02                	mov    %eax,(%edx)
	return 0;
  8028e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8028ed:	eb 13                	jmp    802902 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8028ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028f4:	eb 0c                	jmp    802902 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8028f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028fb:	eb 05                	jmp    802902 <fd_lookup+0x54>
  8028fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802902:	5d                   	pop    %ebp
  802903:	c3                   	ret    

00802904 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802904:	55                   	push   %ebp
  802905:	89 e5                	mov    %esp,%ebp
  802907:	83 ec 08             	sub    $0x8,%esp
  80290a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80290d:	ba a4 41 80 00       	mov    $0x8041a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802912:	eb 13                	jmp    802927 <dev_lookup+0x23>
  802914:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802917:	39 08                	cmp    %ecx,(%eax)
  802919:	75 0c                	jne    802927 <dev_lookup+0x23>
			*dev = devtab[i];
  80291b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80291e:	89 01                	mov    %eax,(%ecx)
			return 0;
  802920:	b8 00 00 00 00       	mov    $0x0,%eax
  802925:	eb 2e                	jmp    802955 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802927:	8b 02                	mov    (%edx),%eax
  802929:	85 c0                	test   %eax,%eax
  80292b:	75 e7                	jne    802914 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80292d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802932:	8b 40 48             	mov    0x48(%eax),%eax
  802935:	83 ec 04             	sub    $0x4,%esp
  802938:	51                   	push   %ecx
  802939:	50                   	push   %eax
  80293a:	68 24 41 80 00       	push   $0x804124
  80293f:	e8 1c f2 ff ff       	call   801b60 <cprintf>
	*dev = 0;
  802944:	8b 45 0c             	mov    0xc(%ebp),%eax
  802947:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80294d:	83 c4 10             	add    $0x10,%esp
  802950:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802955:	c9                   	leave  
  802956:	c3                   	ret    

00802957 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802957:	55                   	push   %ebp
  802958:	89 e5                	mov    %esp,%ebp
  80295a:	56                   	push   %esi
  80295b:	53                   	push   %ebx
  80295c:	83 ec 10             	sub    $0x10,%esp
  80295f:	8b 75 08             	mov    0x8(%ebp),%esi
  802962:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802965:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802968:	50                   	push   %eax
  802969:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80296f:	c1 e8 0c             	shr    $0xc,%eax
  802972:	50                   	push   %eax
  802973:	e8 36 ff ff ff       	call   8028ae <fd_lookup>
  802978:	83 c4 08             	add    $0x8,%esp
  80297b:	85 c0                	test   %eax,%eax
  80297d:	78 05                	js     802984 <fd_close+0x2d>
	    || fd != fd2)
  80297f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802982:	74 0c                	je     802990 <fd_close+0x39>
		return (must_exist ? r : 0);
  802984:	84 db                	test   %bl,%bl
  802986:	ba 00 00 00 00       	mov    $0x0,%edx
  80298b:	0f 44 c2             	cmove  %edx,%eax
  80298e:	eb 41                	jmp    8029d1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802990:	83 ec 08             	sub    $0x8,%esp
  802993:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802996:	50                   	push   %eax
  802997:	ff 36                	pushl  (%esi)
  802999:	e8 66 ff ff ff       	call   802904 <dev_lookup>
  80299e:	89 c3                	mov    %eax,%ebx
  8029a0:	83 c4 10             	add    $0x10,%esp
  8029a3:	85 c0                	test   %eax,%eax
  8029a5:	78 1a                	js     8029c1 <fd_close+0x6a>
		if (dev->dev_close)
  8029a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029aa:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8029ad:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8029b2:	85 c0                	test   %eax,%eax
  8029b4:	74 0b                	je     8029c1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8029b6:	83 ec 0c             	sub    $0xc,%esp
  8029b9:	56                   	push   %esi
  8029ba:	ff d0                	call   *%eax
  8029bc:	89 c3                	mov    %eax,%ebx
  8029be:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8029c1:	83 ec 08             	sub    $0x8,%esp
  8029c4:	56                   	push   %esi
  8029c5:	6a 00                	push   $0x0
  8029c7:	e8 a1 fb ff ff       	call   80256d <sys_page_unmap>
	return r;
  8029cc:	83 c4 10             	add    $0x10,%esp
  8029cf:	89 d8                	mov    %ebx,%eax
}
  8029d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029d4:	5b                   	pop    %ebx
  8029d5:	5e                   	pop    %esi
  8029d6:	5d                   	pop    %ebp
  8029d7:	c3                   	ret    

008029d8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8029d8:	55                   	push   %ebp
  8029d9:	89 e5                	mov    %esp,%ebp
  8029db:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029e1:	50                   	push   %eax
  8029e2:	ff 75 08             	pushl  0x8(%ebp)
  8029e5:	e8 c4 fe ff ff       	call   8028ae <fd_lookup>
  8029ea:	83 c4 08             	add    $0x8,%esp
  8029ed:	85 c0                	test   %eax,%eax
  8029ef:	78 10                	js     802a01 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8029f1:	83 ec 08             	sub    $0x8,%esp
  8029f4:	6a 01                	push   $0x1
  8029f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8029f9:	e8 59 ff ff ff       	call   802957 <fd_close>
  8029fe:	83 c4 10             	add    $0x10,%esp
}
  802a01:	c9                   	leave  
  802a02:	c3                   	ret    

00802a03 <close_all>:

void
close_all(void)
{
  802a03:	55                   	push   %ebp
  802a04:	89 e5                	mov    %esp,%ebp
  802a06:	53                   	push   %ebx
  802a07:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802a0a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802a0f:	83 ec 0c             	sub    $0xc,%esp
  802a12:	53                   	push   %ebx
  802a13:	e8 c0 ff ff ff       	call   8029d8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802a18:	83 c3 01             	add    $0x1,%ebx
  802a1b:	83 c4 10             	add    $0x10,%esp
  802a1e:	83 fb 20             	cmp    $0x20,%ebx
  802a21:	75 ec                	jne    802a0f <close_all+0xc>
		close(i);
}
  802a23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a26:	c9                   	leave  
  802a27:	c3                   	ret    

00802a28 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802a28:	55                   	push   %ebp
  802a29:	89 e5                	mov    %esp,%ebp
  802a2b:	57                   	push   %edi
  802a2c:	56                   	push   %esi
  802a2d:	53                   	push   %ebx
  802a2e:	83 ec 2c             	sub    $0x2c,%esp
  802a31:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802a34:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802a37:	50                   	push   %eax
  802a38:	ff 75 08             	pushl  0x8(%ebp)
  802a3b:	e8 6e fe ff ff       	call   8028ae <fd_lookup>
  802a40:	83 c4 08             	add    $0x8,%esp
  802a43:	85 c0                	test   %eax,%eax
  802a45:	0f 88 c1 00 00 00    	js     802b0c <dup+0xe4>
		return r;
	close(newfdnum);
  802a4b:	83 ec 0c             	sub    $0xc,%esp
  802a4e:	56                   	push   %esi
  802a4f:	e8 84 ff ff ff       	call   8029d8 <close>

	newfd = INDEX2FD(newfdnum);
  802a54:	89 f3                	mov    %esi,%ebx
  802a56:	c1 e3 0c             	shl    $0xc,%ebx
  802a59:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802a5f:	83 c4 04             	add    $0x4,%esp
  802a62:	ff 75 e4             	pushl  -0x1c(%ebp)
  802a65:	e8 de fd ff ff       	call   802848 <fd2data>
  802a6a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802a6c:	89 1c 24             	mov    %ebx,(%esp)
  802a6f:	e8 d4 fd ff ff       	call   802848 <fd2data>
  802a74:	83 c4 10             	add    $0x10,%esp
  802a77:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802a7a:	89 f8                	mov    %edi,%eax
  802a7c:	c1 e8 16             	shr    $0x16,%eax
  802a7f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802a86:	a8 01                	test   $0x1,%al
  802a88:	74 37                	je     802ac1 <dup+0x99>
  802a8a:	89 f8                	mov    %edi,%eax
  802a8c:	c1 e8 0c             	shr    $0xc,%eax
  802a8f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a96:	f6 c2 01             	test   $0x1,%dl
  802a99:	74 26                	je     802ac1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802a9b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802aa2:	83 ec 0c             	sub    $0xc,%esp
  802aa5:	25 07 0e 00 00       	and    $0xe07,%eax
  802aaa:	50                   	push   %eax
  802aab:	ff 75 d4             	pushl  -0x2c(%ebp)
  802aae:	6a 00                	push   $0x0
  802ab0:	57                   	push   %edi
  802ab1:	6a 00                	push   $0x0
  802ab3:	e8 73 fa ff ff       	call   80252b <sys_page_map>
  802ab8:	89 c7                	mov    %eax,%edi
  802aba:	83 c4 20             	add    $0x20,%esp
  802abd:	85 c0                	test   %eax,%eax
  802abf:	78 2e                	js     802aef <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802ac1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802ac4:	89 d0                	mov    %edx,%eax
  802ac6:	c1 e8 0c             	shr    $0xc,%eax
  802ac9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802ad0:	83 ec 0c             	sub    $0xc,%esp
  802ad3:	25 07 0e 00 00       	and    $0xe07,%eax
  802ad8:	50                   	push   %eax
  802ad9:	53                   	push   %ebx
  802ada:	6a 00                	push   $0x0
  802adc:	52                   	push   %edx
  802add:	6a 00                	push   $0x0
  802adf:	e8 47 fa ff ff       	call   80252b <sys_page_map>
  802ae4:	89 c7                	mov    %eax,%edi
  802ae6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802ae9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802aeb:	85 ff                	test   %edi,%edi
  802aed:	79 1d                	jns    802b0c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802aef:	83 ec 08             	sub    $0x8,%esp
  802af2:	53                   	push   %ebx
  802af3:	6a 00                	push   $0x0
  802af5:	e8 73 fa ff ff       	call   80256d <sys_page_unmap>
	sys_page_unmap(0, nva);
  802afa:	83 c4 08             	add    $0x8,%esp
  802afd:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b00:	6a 00                	push   $0x0
  802b02:	e8 66 fa ff ff       	call   80256d <sys_page_unmap>
	return r;
  802b07:	83 c4 10             	add    $0x10,%esp
  802b0a:	89 f8                	mov    %edi,%eax
}
  802b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b0f:	5b                   	pop    %ebx
  802b10:	5e                   	pop    %esi
  802b11:	5f                   	pop    %edi
  802b12:	5d                   	pop    %ebp
  802b13:	c3                   	ret    

00802b14 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802b14:	55                   	push   %ebp
  802b15:	89 e5                	mov    %esp,%ebp
  802b17:	53                   	push   %ebx
  802b18:	83 ec 14             	sub    $0x14,%esp
  802b1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b1e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b21:	50                   	push   %eax
  802b22:	53                   	push   %ebx
  802b23:	e8 86 fd ff ff       	call   8028ae <fd_lookup>
  802b28:	83 c4 08             	add    $0x8,%esp
  802b2b:	89 c2                	mov    %eax,%edx
  802b2d:	85 c0                	test   %eax,%eax
  802b2f:	78 6d                	js     802b9e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b31:	83 ec 08             	sub    $0x8,%esp
  802b34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b37:	50                   	push   %eax
  802b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b3b:	ff 30                	pushl  (%eax)
  802b3d:	e8 c2 fd ff ff       	call   802904 <dev_lookup>
  802b42:	83 c4 10             	add    $0x10,%esp
  802b45:	85 c0                	test   %eax,%eax
  802b47:	78 4c                	js     802b95 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802b49:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b4c:	8b 42 08             	mov    0x8(%edx),%eax
  802b4f:	83 e0 03             	and    $0x3,%eax
  802b52:	83 f8 01             	cmp    $0x1,%eax
  802b55:	75 21                	jne    802b78 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802b57:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b5c:	8b 40 48             	mov    0x48(%eax),%eax
  802b5f:	83 ec 04             	sub    $0x4,%esp
  802b62:	53                   	push   %ebx
  802b63:	50                   	push   %eax
  802b64:	68 68 41 80 00       	push   $0x804168
  802b69:	e8 f2 ef ff ff       	call   801b60 <cprintf>
		return -E_INVAL;
  802b6e:	83 c4 10             	add    $0x10,%esp
  802b71:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802b76:	eb 26                	jmp    802b9e <read+0x8a>
	}
	if (!dev->dev_read)
  802b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b7b:	8b 40 08             	mov    0x8(%eax),%eax
  802b7e:	85 c0                	test   %eax,%eax
  802b80:	74 17                	je     802b99 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802b82:	83 ec 04             	sub    $0x4,%esp
  802b85:	ff 75 10             	pushl  0x10(%ebp)
  802b88:	ff 75 0c             	pushl  0xc(%ebp)
  802b8b:	52                   	push   %edx
  802b8c:	ff d0                	call   *%eax
  802b8e:	89 c2                	mov    %eax,%edx
  802b90:	83 c4 10             	add    $0x10,%esp
  802b93:	eb 09                	jmp    802b9e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b95:	89 c2                	mov    %eax,%edx
  802b97:	eb 05                	jmp    802b9e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802b99:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802b9e:	89 d0                	mov    %edx,%eax
  802ba0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ba3:	c9                   	leave  
  802ba4:	c3                   	ret    

00802ba5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802ba5:	55                   	push   %ebp
  802ba6:	89 e5                	mov    %esp,%ebp
  802ba8:	57                   	push   %edi
  802ba9:	56                   	push   %esi
  802baa:	53                   	push   %ebx
  802bab:	83 ec 0c             	sub    $0xc,%esp
  802bae:	8b 7d 08             	mov    0x8(%ebp),%edi
  802bb1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802bb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bb9:	eb 21                	jmp    802bdc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802bbb:	83 ec 04             	sub    $0x4,%esp
  802bbe:	89 f0                	mov    %esi,%eax
  802bc0:	29 d8                	sub    %ebx,%eax
  802bc2:	50                   	push   %eax
  802bc3:	89 d8                	mov    %ebx,%eax
  802bc5:	03 45 0c             	add    0xc(%ebp),%eax
  802bc8:	50                   	push   %eax
  802bc9:	57                   	push   %edi
  802bca:	e8 45 ff ff ff       	call   802b14 <read>
		if (m < 0)
  802bcf:	83 c4 10             	add    $0x10,%esp
  802bd2:	85 c0                	test   %eax,%eax
  802bd4:	78 10                	js     802be6 <readn+0x41>
			return m;
		if (m == 0)
  802bd6:	85 c0                	test   %eax,%eax
  802bd8:	74 0a                	je     802be4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802bda:	01 c3                	add    %eax,%ebx
  802bdc:	39 f3                	cmp    %esi,%ebx
  802bde:	72 db                	jb     802bbb <readn+0x16>
  802be0:	89 d8                	mov    %ebx,%eax
  802be2:	eb 02                	jmp    802be6 <readn+0x41>
  802be4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802be9:	5b                   	pop    %ebx
  802bea:	5e                   	pop    %esi
  802beb:	5f                   	pop    %edi
  802bec:	5d                   	pop    %ebp
  802bed:	c3                   	ret    

00802bee <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802bee:	55                   	push   %ebp
  802bef:	89 e5                	mov    %esp,%ebp
  802bf1:	53                   	push   %ebx
  802bf2:	83 ec 14             	sub    $0x14,%esp
  802bf5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802bf8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bfb:	50                   	push   %eax
  802bfc:	53                   	push   %ebx
  802bfd:	e8 ac fc ff ff       	call   8028ae <fd_lookup>
  802c02:	83 c4 08             	add    $0x8,%esp
  802c05:	89 c2                	mov    %eax,%edx
  802c07:	85 c0                	test   %eax,%eax
  802c09:	78 68                	js     802c73 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c0b:	83 ec 08             	sub    $0x8,%esp
  802c0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c11:	50                   	push   %eax
  802c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c15:	ff 30                	pushl  (%eax)
  802c17:	e8 e8 fc ff ff       	call   802904 <dev_lookup>
  802c1c:	83 c4 10             	add    $0x10,%esp
  802c1f:	85 c0                	test   %eax,%eax
  802c21:	78 47                	js     802c6a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c26:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c2a:	75 21                	jne    802c4d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802c2c:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802c31:	8b 40 48             	mov    0x48(%eax),%eax
  802c34:	83 ec 04             	sub    $0x4,%esp
  802c37:	53                   	push   %ebx
  802c38:	50                   	push   %eax
  802c39:	68 84 41 80 00       	push   $0x804184
  802c3e:	e8 1d ef ff ff       	call   801b60 <cprintf>
		return -E_INVAL;
  802c43:	83 c4 10             	add    $0x10,%esp
  802c46:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c4b:	eb 26                	jmp    802c73 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c50:	8b 52 0c             	mov    0xc(%edx),%edx
  802c53:	85 d2                	test   %edx,%edx
  802c55:	74 17                	je     802c6e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802c57:	83 ec 04             	sub    $0x4,%esp
  802c5a:	ff 75 10             	pushl  0x10(%ebp)
  802c5d:	ff 75 0c             	pushl  0xc(%ebp)
  802c60:	50                   	push   %eax
  802c61:	ff d2                	call   *%edx
  802c63:	89 c2                	mov    %eax,%edx
  802c65:	83 c4 10             	add    $0x10,%esp
  802c68:	eb 09                	jmp    802c73 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c6a:	89 c2                	mov    %eax,%edx
  802c6c:	eb 05                	jmp    802c73 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802c6e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802c73:	89 d0                	mov    %edx,%eax
  802c75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c78:	c9                   	leave  
  802c79:	c3                   	ret    

00802c7a <seek>:

int
seek(int fdnum, off_t offset)
{
  802c7a:	55                   	push   %ebp
  802c7b:	89 e5                	mov    %esp,%ebp
  802c7d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c80:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802c83:	50                   	push   %eax
  802c84:	ff 75 08             	pushl  0x8(%ebp)
  802c87:	e8 22 fc ff ff       	call   8028ae <fd_lookup>
  802c8c:	83 c4 08             	add    $0x8,%esp
  802c8f:	85 c0                	test   %eax,%eax
  802c91:	78 0e                	js     802ca1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802c93:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802c96:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c99:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802c9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ca1:	c9                   	leave  
  802ca2:	c3                   	ret    

00802ca3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802ca3:	55                   	push   %ebp
  802ca4:	89 e5                	mov    %esp,%ebp
  802ca6:	53                   	push   %ebx
  802ca7:	83 ec 14             	sub    $0x14,%esp
  802caa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cb0:	50                   	push   %eax
  802cb1:	53                   	push   %ebx
  802cb2:	e8 f7 fb ff ff       	call   8028ae <fd_lookup>
  802cb7:	83 c4 08             	add    $0x8,%esp
  802cba:	89 c2                	mov    %eax,%edx
  802cbc:	85 c0                	test   %eax,%eax
  802cbe:	78 65                	js     802d25 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cc0:	83 ec 08             	sub    $0x8,%esp
  802cc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cc6:	50                   	push   %eax
  802cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cca:	ff 30                	pushl  (%eax)
  802ccc:	e8 33 fc ff ff       	call   802904 <dev_lookup>
  802cd1:	83 c4 10             	add    $0x10,%esp
  802cd4:	85 c0                	test   %eax,%eax
  802cd6:	78 44                	js     802d1c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cdb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802cdf:	75 21                	jne    802d02 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802ce1:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802ce6:	8b 40 48             	mov    0x48(%eax),%eax
  802ce9:	83 ec 04             	sub    $0x4,%esp
  802cec:	53                   	push   %ebx
  802ced:	50                   	push   %eax
  802cee:	68 44 41 80 00       	push   $0x804144
  802cf3:	e8 68 ee ff ff       	call   801b60 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802cf8:	83 c4 10             	add    $0x10,%esp
  802cfb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d00:	eb 23                	jmp    802d25 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802d02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d05:	8b 52 18             	mov    0x18(%edx),%edx
  802d08:	85 d2                	test   %edx,%edx
  802d0a:	74 14                	je     802d20 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802d0c:	83 ec 08             	sub    $0x8,%esp
  802d0f:	ff 75 0c             	pushl  0xc(%ebp)
  802d12:	50                   	push   %eax
  802d13:	ff d2                	call   *%edx
  802d15:	89 c2                	mov    %eax,%edx
  802d17:	83 c4 10             	add    $0x10,%esp
  802d1a:	eb 09                	jmp    802d25 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d1c:	89 c2                	mov    %eax,%edx
  802d1e:	eb 05                	jmp    802d25 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802d20:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802d25:	89 d0                	mov    %edx,%eax
  802d27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d2a:	c9                   	leave  
  802d2b:	c3                   	ret    

00802d2c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802d2c:	55                   	push   %ebp
  802d2d:	89 e5                	mov    %esp,%ebp
  802d2f:	53                   	push   %ebx
  802d30:	83 ec 14             	sub    $0x14,%esp
  802d33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d39:	50                   	push   %eax
  802d3a:	ff 75 08             	pushl  0x8(%ebp)
  802d3d:	e8 6c fb ff ff       	call   8028ae <fd_lookup>
  802d42:	83 c4 08             	add    $0x8,%esp
  802d45:	89 c2                	mov    %eax,%edx
  802d47:	85 c0                	test   %eax,%eax
  802d49:	78 58                	js     802da3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d4b:	83 ec 08             	sub    $0x8,%esp
  802d4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d51:	50                   	push   %eax
  802d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d55:	ff 30                	pushl  (%eax)
  802d57:	e8 a8 fb ff ff       	call   802904 <dev_lookup>
  802d5c:	83 c4 10             	add    $0x10,%esp
  802d5f:	85 c0                	test   %eax,%eax
  802d61:	78 37                	js     802d9a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d66:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802d6a:	74 32                	je     802d9e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802d6c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802d6f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802d76:	00 00 00 
	stat->st_isdir = 0;
  802d79:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802d80:	00 00 00 
	stat->st_dev = dev;
  802d83:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802d89:	83 ec 08             	sub    $0x8,%esp
  802d8c:	53                   	push   %ebx
  802d8d:	ff 75 f0             	pushl  -0x10(%ebp)
  802d90:	ff 50 14             	call   *0x14(%eax)
  802d93:	89 c2                	mov    %eax,%edx
  802d95:	83 c4 10             	add    $0x10,%esp
  802d98:	eb 09                	jmp    802da3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d9a:	89 c2                	mov    %eax,%edx
  802d9c:	eb 05                	jmp    802da3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802d9e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802da3:	89 d0                	mov    %edx,%eax
  802da5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802da8:	c9                   	leave  
  802da9:	c3                   	ret    

00802daa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802daa:	55                   	push   %ebp
  802dab:	89 e5                	mov    %esp,%ebp
  802dad:	56                   	push   %esi
  802dae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802daf:	83 ec 08             	sub    $0x8,%esp
  802db2:	6a 00                	push   $0x0
  802db4:	ff 75 08             	pushl  0x8(%ebp)
  802db7:	e8 b7 01 00 00       	call   802f73 <open>
  802dbc:	89 c3                	mov    %eax,%ebx
  802dbe:	83 c4 10             	add    $0x10,%esp
  802dc1:	85 c0                	test   %eax,%eax
  802dc3:	78 1b                	js     802de0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802dc5:	83 ec 08             	sub    $0x8,%esp
  802dc8:	ff 75 0c             	pushl  0xc(%ebp)
  802dcb:	50                   	push   %eax
  802dcc:	e8 5b ff ff ff       	call   802d2c <fstat>
  802dd1:	89 c6                	mov    %eax,%esi
	close(fd);
  802dd3:	89 1c 24             	mov    %ebx,(%esp)
  802dd6:	e8 fd fb ff ff       	call   8029d8 <close>
	return r;
  802ddb:	83 c4 10             	add    $0x10,%esp
  802dde:	89 f0                	mov    %esi,%eax
}
  802de0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802de3:	5b                   	pop    %ebx
  802de4:	5e                   	pop    %esi
  802de5:	5d                   	pop    %ebp
  802de6:	c3                   	ret    

00802de7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802de7:	55                   	push   %ebp
  802de8:	89 e5                	mov    %esp,%ebp
  802dea:	56                   	push   %esi
  802deb:	53                   	push   %ebx
  802dec:	89 c6                	mov    %eax,%esi
  802dee:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802df0:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802df7:	75 12                	jne    802e0b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802df9:	83 ec 0c             	sub    $0xc,%esp
  802dfc:	6a 01                	push   $0x1
  802dfe:	e8 fc f9 ff ff       	call   8027ff <ipc_find_env>
  802e03:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802e08:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802e0b:	6a 07                	push   $0x7
  802e0d:	68 00 b0 80 00       	push   $0x80b000
  802e12:	56                   	push   %esi
  802e13:	ff 35 00 a0 80 00    	pushl  0x80a000
  802e19:	e8 8d f9 ff ff       	call   8027ab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802e1e:	83 c4 0c             	add    $0xc,%esp
  802e21:	6a 00                	push   $0x0
  802e23:	53                   	push   %ebx
  802e24:	6a 00                	push   $0x0
  802e26:	e8 19 f9 ff ff       	call   802744 <ipc_recv>
}
  802e2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e2e:	5b                   	pop    %ebx
  802e2f:	5e                   	pop    %esi
  802e30:	5d                   	pop    %ebp
  802e31:	c3                   	ret    

00802e32 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802e32:	55                   	push   %ebp
  802e33:	89 e5                	mov    %esp,%ebp
  802e35:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802e38:	8b 45 08             	mov    0x8(%ebp),%eax
  802e3b:	8b 40 0c             	mov    0xc(%eax),%eax
  802e3e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802e43:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e46:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  802e50:	b8 02 00 00 00       	mov    $0x2,%eax
  802e55:	e8 8d ff ff ff       	call   802de7 <fsipc>
}
  802e5a:	c9                   	leave  
  802e5b:	c3                   	ret    

00802e5c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802e5c:	55                   	push   %ebp
  802e5d:	89 e5                	mov    %esp,%ebp
  802e5f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802e62:	8b 45 08             	mov    0x8(%ebp),%eax
  802e65:	8b 40 0c             	mov    0xc(%eax),%eax
  802e68:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  802e72:	b8 06 00 00 00       	mov    $0x6,%eax
  802e77:	e8 6b ff ff ff       	call   802de7 <fsipc>
}
  802e7c:	c9                   	leave  
  802e7d:	c3                   	ret    

00802e7e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802e7e:	55                   	push   %ebp
  802e7f:	89 e5                	mov    %esp,%ebp
  802e81:	53                   	push   %ebx
  802e82:	83 ec 04             	sub    $0x4,%esp
  802e85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802e88:	8b 45 08             	mov    0x8(%ebp),%eax
  802e8b:	8b 40 0c             	mov    0xc(%eax),%eax
  802e8e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802e93:	ba 00 00 00 00       	mov    $0x0,%edx
  802e98:	b8 05 00 00 00       	mov    $0x5,%eax
  802e9d:	e8 45 ff ff ff       	call   802de7 <fsipc>
  802ea2:	85 c0                	test   %eax,%eax
  802ea4:	78 2c                	js     802ed2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802ea6:	83 ec 08             	sub    $0x8,%esp
  802ea9:	68 00 b0 80 00       	push   $0x80b000
  802eae:	53                   	push   %ebx
  802eaf:	e8 31 f2 ff ff       	call   8020e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802eb4:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802eb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802ebf:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802ec4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802eca:	83 c4 10             	add    $0x10,%esp
  802ecd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ed2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ed5:	c9                   	leave  
  802ed6:	c3                   	ret    

00802ed7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802ed7:	55                   	push   %ebp
  802ed8:	89 e5                	mov    %esp,%ebp
  802eda:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802edd:	68 b4 41 80 00       	push   $0x8041b4
  802ee2:	68 90 00 00 00       	push   $0x90
  802ee7:	68 d2 41 80 00       	push   $0x8041d2
  802eec:	e8 96 eb ff ff       	call   801a87 <_panic>

00802ef1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802ef1:	55                   	push   %ebp
  802ef2:	89 e5                	mov    %esp,%ebp
  802ef4:	56                   	push   %esi
  802ef5:	53                   	push   %ebx
  802ef6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  802efc:	8b 40 0c             	mov    0xc(%eax),%eax
  802eff:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802f04:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802f0a:	ba 00 00 00 00       	mov    $0x0,%edx
  802f0f:	b8 03 00 00 00       	mov    $0x3,%eax
  802f14:	e8 ce fe ff ff       	call   802de7 <fsipc>
  802f19:	89 c3                	mov    %eax,%ebx
  802f1b:	85 c0                	test   %eax,%eax
  802f1d:	78 4b                	js     802f6a <devfile_read+0x79>
		return r;
	assert(r <= n);
  802f1f:	39 c6                	cmp    %eax,%esi
  802f21:	73 16                	jae    802f39 <devfile_read+0x48>
  802f23:	68 dd 41 80 00       	push   $0x8041dd
  802f28:	68 1d 38 80 00       	push   $0x80381d
  802f2d:	6a 7c                	push   $0x7c
  802f2f:	68 d2 41 80 00       	push   $0x8041d2
  802f34:	e8 4e eb ff ff       	call   801a87 <_panic>
	assert(r <= PGSIZE);
  802f39:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802f3e:	7e 16                	jle    802f56 <devfile_read+0x65>
  802f40:	68 e4 41 80 00       	push   $0x8041e4
  802f45:	68 1d 38 80 00       	push   $0x80381d
  802f4a:	6a 7d                	push   $0x7d
  802f4c:	68 d2 41 80 00       	push   $0x8041d2
  802f51:	e8 31 eb ff ff       	call   801a87 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802f56:	83 ec 04             	sub    $0x4,%esp
  802f59:	50                   	push   %eax
  802f5a:	68 00 b0 80 00       	push   $0x80b000
  802f5f:	ff 75 0c             	pushl  0xc(%ebp)
  802f62:	e8 10 f3 ff ff       	call   802277 <memmove>
	return r;
  802f67:	83 c4 10             	add    $0x10,%esp
}
  802f6a:	89 d8                	mov    %ebx,%eax
  802f6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f6f:	5b                   	pop    %ebx
  802f70:	5e                   	pop    %esi
  802f71:	5d                   	pop    %ebp
  802f72:	c3                   	ret    

00802f73 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802f73:	55                   	push   %ebp
  802f74:	89 e5                	mov    %esp,%ebp
  802f76:	53                   	push   %ebx
  802f77:	83 ec 20             	sub    $0x20,%esp
  802f7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802f7d:	53                   	push   %ebx
  802f7e:	e8 29 f1 ff ff       	call   8020ac <strlen>
  802f83:	83 c4 10             	add    $0x10,%esp
  802f86:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802f8b:	7f 67                	jg     802ff4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f8d:	83 ec 0c             	sub    $0xc,%esp
  802f90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f93:	50                   	push   %eax
  802f94:	e8 c6 f8 ff ff       	call   80285f <fd_alloc>
  802f99:	83 c4 10             	add    $0x10,%esp
		return r;
  802f9c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f9e:	85 c0                	test   %eax,%eax
  802fa0:	78 57                	js     802ff9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802fa2:	83 ec 08             	sub    $0x8,%esp
  802fa5:	53                   	push   %ebx
  802fa6:	68 00 b0 80 00       	push   $0x80b000
  802fab:	e8 35 f1 ff ff       	call   8020e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fb3:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802fb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802fbb:	b8 01 00 00 00       	mov    $0x1,%eax
  802fc0:	e8 22 fe ff ff       	call   802de7 <fsipc>
  802fc5:	89 c3                	mov    %eax,%ebx
  802fc7:	83 c4 10             	add    $0x10,%esp
  802fca:	85 c0                	test   %eax,%eax
  802fcc:	79 14                	jns    802fe2 <open+0x6f>
		fd_close(fd, 0);
  802fce:	83 ec 08             	sub    $0x8,%esp
  802fd1:	6a 00                	push   $0x0
  802fd3:	ff 75 f4             	pushl  -0xc(%ebp)
  802fd6:	e8 7c f9 ff ff       	call   802957 <fd_close>
		return r;
  802fdb:	83 c4 10             	add    $0x10,%esp
  802fde:	89 da                	mov    %ebx,%edx
  802fe0:	eb 17                	jmp    802ff9 <open+0x86>
	}

	return fd2num(fd);
  802fe2:	83 ec 0c             	sub    $0xc,%esp
  802fe5:	ff 75 f4             	pushl  -0xc(%ebp)
  802fe8:	e8 4b f8 ff ff       	call   802838 <fd2num>
  802fed:	89 c2                	mov    %eax,%edx
  802fef:	83 c4 10             	add    $0x10,%esp
  802ff2:	eb 05                	jmp    802ff9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802ff4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802ff9:	89 d0                	mov    %edx,%eax
  802ffb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ffe:	c9                   	leave  
  802fff:	c3                   	ret    

00803000 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803000:	55                   	push   %ebp
  803001:	89 e5                	mov    %esp,%ebp
  803003:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803006:	ba 00 00 00 00       	mov    $0x0,%edx
  80300b:	b8 08 00 00 00       	mov    $0x8,%eax
  803010:	e8 d2 fd ff ff       	call   802de7 <fsipc>
}
  803015:	c9                   	leave  
  803016:	c3                   	ret    

00803017 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803017:	55                   	push   %ebp
  803018:	89 e5                	mov    %esp,%ebp
  80301a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80301d:	89 d0                	mov    %edx,%eax
  80301f:	c1 e8 16             	shr    $0x16,%eax
  803022:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803029:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80302e:	f6 c1 01             	test   $0x1,%cl
  803031:	74 1d                	je     803050 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803033:	c1 ea 0c             	shr    $0xc,%edx
  803036:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80303d:	f6 c2 01             	test   $0x1,%dl
  803040:	74 0e                	je     803050 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803042:	c1 ea 0c             	shr    $0xc,%edx
  803045:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80304c:	ef 
  80304d:	0f b7 c0             	movzwl %ax,%eax
}
  803050:	5d                   	pop    %ebp
  803051:	c3                   	ret    

00803052 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803052:	55                   	push   %ebp
  803053:	89 e5                	mov    %esp,%ebp
  803055:	56                   	push   %esi
  803056:	53                   	push   %ebx
  803057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80305a:	83 ec 0c             	sub    $0xc,%esp
  80305d:	ff 75 08             	pushl  0x8(%ebp)
  803060:	e8 e3 f7 ff ff       	call   802848 <fd2data>
  803065:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803067:	83 c4 08             	add    $0x8,%esp
  80306a:	68 f0 41 80 00       	push   $0x8041f0
  80306f:	53                   	push   %ebx
  803070:	e8 70 f0 ff ff       	call   8020e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803075:	8b 46 04             	mov    0x4(%esi),%eax
  803078:	2b 06                	sub    (%esi),%eax
  80307a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803080:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803087:	00 00 00 
	stat->st_dev = &devpipe;
  80308a:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  803091:	90 80 00 
	return 0;
}
  803094:	b8 00 00 00 00       	mov    $0x0,%eax
  803099:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80309c:	5b                   	pop    %ebx
  80309d:	5e                   	pop    %esi
  80309e:	5d                   	pop    %ebp
  80309f:	c3                   	ret    

008030a0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8030a0:	55                   	push   %ebp
  8030a1:	89 e5                	mov    %esp,%ebp
  8030a3:	53                   	push   %ebx
  8030a4:	83 ec 0c             	sub    $0xc,%esp
  8030a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8030aa:	53                   	push   %ebx
  8030ab:	6a 00                	push   $0x0
  8030ad:	e8 bb f4 ff ff       	call   80256d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8030b2:	89 1c 24             	mov    %ebx,(%esp)
  8030b5:	e8 8e f7 ff ff       	call   802848 <fd2data>
  8030ba:	83 c4 08             	add    $0x8,%esp
  8030bd:	50                   	push   %eax
  8030be:	6a 00                	push   $0x0
  8030c0:	e8 a8 f4 ff ff       	call   80256d <sys_page_unmap>
}
  8030c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030c8:	c9                   	leave  
  8030c9:	c3                   	ret    

008030ca <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8030ca:	55                   	push   %ebp
  8030cb:	89 e5                	mov    %esp,%ebp
  8030cd:	57                   	push   %edi
  8030ce:	56                   	push   %esi
  8030cf:	53                   	push   %ebx
  8030d0:	83 ec 1c             	sub    $0x1c,%esp
  8030d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8030d6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8030d8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8030dd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8030e0:	83 ec 0c             	sub    $0xc,%esp
  8030e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8030e6:	e8 2c ff ff ff       	call   803017 <pageref>
  8030eb:	89 c3                	mov    %eax,%ebx
  8030ed:	89 3c 24             	mov    %edi,(%esp)
  8030f0:	e8 22 ff ff ff       	call   803017 <pageref>
  8030f5:	83 c4 10             	add    $0x10,%esp
  8030f8:	39 c3                	cmp    %eax,%ebx
  8030fa:	0f 94 c1             	sete   %cl
  8030fd:	0f b6 c9             	movzbl %cl,%ecx
  803100:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  803103:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803109:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80310c:	39 ce                	cmp    %ecx,%esi
  80310e:	74 1b                	je     80312b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803110:	39 c3                	cmp    %eax,%ebx
  803112:	75 c4                	jne    8030d8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803114:	8b 42 58             	mov    0x58(%edx),%eax
  803117:	ff 75 e4             	pushl  -0x1c(%ebp)
  80311a:	50                   	push   %eax
  80311b:	56                   	push   %esi
  80311c:	68 f7 41 80 00       	push   $0x8041f7
  803121:	e8 3a ea ff ff       	call   801b60 <cprintf>
  803126:	83 c4 10             	add    $0x10,%esp
  803129:	eb ad                	jmp    8030d8 <_pipeisclosed+0xe>
	}
}
  80312b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80312e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803131:	5b                   	pop    %ebx
  803132:	5e                   	pop    %esi
  803133:	5f                   	pop    %edi
  803134:	5d                   	pop    %ebp
  803135:	c3                   	ret    

00803136 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803136:	55                   	push   %ebp
  803137:	89 e5                	mov    %esp,%ebp
  803139:	57                   	push   %edi
  80313a:	56                   	push   %esi
  80313b:	53                   	push   %ebx
  80313c:	83 ec 28             	sub    $0x28,%esp
  80313f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803142:	56                   	push   %esi
  803143:	e8 00 f7 ff ff       	call   802848 <fd2data>
  803148:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80314a:	83 c4 10             	add    $0x10,%esp
  80314d:	bf 00 00 00 00       	mov    $0x0,%edi
  803152:	eb 4b                	jmp    80319f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803154:	89 da                	mov    %ebx,%edx
  803156:	89 f0                	mov    %esi,%eax
  803158:	e8 6d ff ff ff       	call   8030ca <_pipeisclosed>
  80315d:	85 c0                	test   %eax,%eax
  80315f:	75 48                	jne    8031a9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803161:	e8 63 f3 ff ff       	call   8024c9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803166:	8b 43 04             	mov    0x4(%ebx),%eax
  803169:	8b 0b                	mov    (%ebx),%ecx
  80316b:	8d 51 20             	lea    0x20(%ecx),%edx
  80316e:	39 d0                	cmp    %edx,%eax
  803170:	73 e2                	jae    803154 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803175:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803179:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80317c:	89 c2                	mov    %eax,%edx
  80317e:	c1 fa 1f             	sar    $0x1f,%edx
  803181:	89 d1                	mov    %edx,%ecx
  803183:	c1 e9 1b             	shr    $0x1b,%ecx
  803186:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803189:	83 e2 1f             	and    $0x1f,%edx
  80318c:	29 ca                	sub    %ecx,%edx
  80318e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803192:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803196:	83 c0 01             	add    $0x1,%eax
  803199:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80319c:	83 c7 01             	add    $0x1,%edi
  80319f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8031a2:	75 c2                	jne    803166 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8031a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8031a7:	eb 05                	jmp    8031ae <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8031a9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8031ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031b1:	5b                   	pop    %ebx
  8031b2:	5e                   	pop    %esi
  8031b3:	5f                   	pop    %edi
  8031b4:	5d                   	pop    %ebp
  8031b5:	c3                   	ret    

008031b6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8031b6:	55                   	push   %ebp
  8031b7:	89 e5                	mov    %esp,%ebp
  8031b9:	57                   	push   %edi
  8031ba:	56                   	push   %esi
  8031bb:	53                   	push   %ebx
  8031bc:	83 ec 18             	sub    $0x18,%esp
  8031bf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8031c2:	57                   	push   %edi
  8031c3:	e8 80 f6 ff ff       	call   802848 <fd2data>
  8031c8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8031ca:	83 c4 10             	add    $0x10,%esp
  8031cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8031d2:	eb 3d                	jmp    803211 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8031d4:	85 db                	test   %ebx,%ebx
  8031d6:	74 04                	je     8031dc <devpipe_read+0x26>
				return i;
  8031d8:	89 d8                	mov    %ebx,%eax
  8031da:	eb 44                	jmp    803220 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8031dc:	89 f2                	mov    %esi,%edx
  8031de:	89 f8                	mov    %edi,%eax
  8031e0:	e8 e5 fe ff ff       	call   8030ca <_pipeisclosed>
  8031e5:	85 c0                	test   %eax,%eax
  8031e7:	75 32                	jne    80321b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8031e9:	e8 db f2 ff ff       	call   8024c9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8031ee:	8b 06                	mov    (%esi),%eax
  8031f0:	3b 46 04             	cmp    0x4(%esi),%eax
  8031f3:	74 df                	je     8031d4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8031f5:	99                   	cltd   
  8031f6:	c1 ea 1b             	shr    $0x1b,%edx
  8031f9:	01 d0                	add    %edx,%eax
  8031fb:	83 e0 1f             	and    $0x1f,%eax
  8031fe:	29 d0                	sub    %edx,%eax
  803200:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803208:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80320b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80320e:	83 c3 01             	add    $0x1,%ebx
  803211:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803214:	75 d8                	jne    8031ee <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803216:	8b 45 10             	mov    0x10(%ebp),%eax
  803219:	eb 05                	jmp    803220 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80321b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803223:	5b                   	pop    %ebx
  803224:	5e                   	pop    %esi
  803225:	5f                   	pop    %edi
  803226:	5d                   	pop    %ebp
  803227:	c3                   	ret    

00803228 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803228:	55                   	push   %ebp
  803229:	89 e5                	mov    %esp,%ebp
  80322b:	56                   	push   %esi
  80322c:	53                   	push   %ebx
  80322d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803230:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803233:	50                   	push   %eax
  803234:	e8 26 f6 ff ff       	call   80285f <fd_alloc>
  803239:	83 c4 10             	add    $0x10,%esp
  80323c:	89 c2                	mov    %eax,%edx
  80323e:	85 c0                	test   %eax,%eax
  803240:	0f 88 2c 01 00 00    	js     803372 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803246:	83 ec 04             	sub    $0x4,%esp
  803249:	68 07 04 00 00       	push   $0x407
  80324e:	ff 75 f4             	pushl  -0xc(%ebp)
  803251:	6a 00                	push   $0x0
  803253:	e8 90 f2 ff ff       	call   8024e8 <sys_page_alloc>
  803258:	83 c4 10             	add    $0x10,%esp
  80325b:	89 c2                	mov    %eax,%edx
  80325d:	85 c0                	test   %eax,%eax
  80325f:	0f 88 0d 01 00 00    	js     803372 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803265:	83 ec 0c             	sub    $0xc,%esp
  803268:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80326b:	50                   	push   %eax
  80326c:	e8 ee f5 ff ff       	call   80285f <fd_alloc>
  803271:	89 c3                	mov    %eax,%ebx
  803273:	83 c4 10             	add    $0x10,%esp
  803276:	85 c0                	test   %eax,%eax
  803278:	0f 88 e2 00 00 00    	js     803360 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80327e:	83 ec 04             	sub    $0x4,%esp
  803281:	68 07 04 00 00       	push   $0x407
  803286:	ff 75 f0             	pushl  -0x10(%ebp)
  803289:	6a 00                	push   $0x0
  80328b:	e8 58 f2 ff ff       	call   8024e8 <sys_page_alloc>
  803290:	89 c3                	mov    %eax,%ebx
  803292:	83 c4 10             	add    $0x10,%esp
  803295:	85 c0                	test   %eax,%eax
  803297:	0f 88 c3 00 00 00    	js     803360 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80329d:	83 ec 0c             	sub    $0xc,%esp
  8032a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8032a3:	e8 a0 f5 ff ff       	call   802848 <fd2data>
  8032a8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8032aa:	83 c4 0c             	add    $0xc,%esp
  8032ad:	68 07 04 00 00       	push   $0x407
  8032b2:	50                   	push   %eax
  8032b3:	6a 00                	push   $0x0
  8032b5:	e8 2e f2 ff ff       	call   8024e8 <sys_page_alloc>
  8032ba:	89 c3                	mov    %eax,%ebx
  8032bc:	83 c4 10             	add    $0x10,%esp
  8032bf:	85 c0                	test   %eax,%eax
  8032c1:	0f 88 89 00 00 00    	js     803350 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8032c7:	83 ec 0c             	sub    $0xc,%esp
  8032ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8032cd:	e8 76 f5 ff ff       	call   802848 <fd2data>
  8032d2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8032d9:	50                   	push   %eax
  8032da:	6a 00                	push   $0x0
  8032dc:	56                   	push   %esi
  8032dd:	6a 00                	push   $0x0
  8032df:	e8 47 f2 ff ff       	call   80252b <sys_page_map>
  8032e4:	89 c3                	mov    %eax,%ebx
  8032e6:	83 c4 20             	add    $0x20,%esp
  8032e9:	85 c0                	test   %eax,%eax
  8032eb:	78 55                	js     803342 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8032ed:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8032f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032f6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8032f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032fb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803302:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803308:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80330b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80330d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803310:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803317:	83 ec 0c             	sub    $0xc,%esp
  80331a:	ff 75 f4             	pushl  -0xc(%ebp)
  80331d:	e8 16 f5 ff ff       	call   802838 <fd2num>
  803322:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803325:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803327:	83 c4 04             	add    $0x4,%esp
  80332a:	ff 75 f0             	pushl  -0x10(%ebp)
  80332d:	e8 06 f5 ff ff       	call   802838 <fd2num>
  803332:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803335:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803338:	83 c4 10             	add    $0x10,%esp
  80333b:	ba 00 00 00 00       	mov    $0x0,%edx
  803340:	eb 30                	jmp    803372 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803342:	83 ec 08             	sub    $0x8,%esp
  803345:	56                   	push   %esi
  803346:	6a 00                	push   $0x0
  803348:	e8 20 f2 ff ff       	call   80256d <sys_page_unmap>
  80334d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803350:	83 ec 08             	sub    $0x8,%esp
  803353:	ff 75 f0             	pushl  -0x10(%ebp)
  803356:	6a 00                	push   $0x0
  803358:	e8 10 f2 ff ff       	call   80256d <sys_page_unmap>
  80335d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803360:	83 ec 08             	sub    $0x8,%esp
  803363:	ff 75 f4             	pushl  -0xc(%ebp)
  803366:	6a 00                	push   $0x0
  803368:	e8 00 f2 ff ff       	call   80256d <sys_page_unmap>
  80336d:	83 c4 10             	add    $0x10,%esp
  803370:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803372:	89 d0                	mov    %edx,%eax
  803374:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803377:	5b                   	pop    %ebx
  803378:	5e                   	pop    %esi
  803379:	5d                   	pop    %ebp
  80337a:	c3                   	ret    

0080337b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80337b:	55                   	push   %ebp
  80337c:	89 e5                	mov    %esp,%ebp
  80337e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803384:	50                   	push   %eax
  803385:	ff 75 08             	pushl  0x8(%ebp)
  803388:	e8 21 f5 ff ff       	call   8028ae <fd_lookup>
  80338d:	83 c4 10             	add    $0x10,%esp
  803390:	85 c0                	test   %eax,%eax
  803392:	78 18                	js     8033ac <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803394:	83 ec 0c             	sub    $0xc,%esp
  803397:	ff 75 f4             	pushl  -0xc(%ebp)
  80339a:	e8 a9 f4 ff ff       	call   802848 <fd2data>
	return _pipeisclosed(fd, p);
  80339f:	89 c2                	mov    %eax,%edx
  8033a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033a4:	e8 21 fd ff ff       	call   8030ca <_pipeisclosed>
  8033a9:	83 c4 10             	add    $0x10,%esp
}
  8033ac:	c9                   	leave  
  8033ad:	c3                   	ret    

008033ae <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8033ae:	55                   	push   %ebp
  8033af:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8033b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8033b6:	5d                   	pop    %ebp
  8033b7:	c3                   	ret    

008033b8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8033b8:	55                   	push   %ebp
  8033b9:	89 e5                	mov    %esp,%ebp
  8033bb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8033be:	68 0f 42 80 00       	push   $0x80420f
  8033c3:	ff 75 0c             	pushl  0xc(%ebp)
  8033c6:	e8 1a ed ff ff       	call   8020e5 <strcpy>
	return 0;
}
  8033cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8033d0:	c9                   	leave  
  8033d1:	c3                   	ret    

008033d2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8033d2:	55                   	push   %ebp
  8033d3:	89 e5                	mov    %esp,%ebp
  8033d5:	57                   	push   %edi
  8033d6:	56                   	push   %esi
  8033d7:	53                   	push   %ebx
  8033d8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8033de:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8033e3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8033e9:	eb 2d                	jmp    803418 <devcons_write+0x46>
		m = n - tot;
  8033eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8033ee:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8033f0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8033f3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8033f8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8033fb:	83 ec 04             	sub    $0x4,%esp
  8033fe:	53                   	push   %ebx
  8033ff:	03 45 0c             	add    0xc(%ebp),%eax
  803402:	50                   	push   %eax
  803403:	57                   	push   %edi
  803404:	e8 6e ee ff ff       	call   802277 <memmove>
		sys_cputs(buf, m);
  803409:	83 c4 08             	add    $0x8,%esp
  80340c:	53                   	push   %ebx
  80340d:	57                   	push   %edi
  80340e:	e8 19 f0 ff ff       	call   80242c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803413:	01 de                	add    %ebx,%esi
  803415:	83 c4 10             	add    $0x10,%esp
  803418:	89 f0                	mov    %esi,%eax
  80341a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80341d:	72 cc                	jb     8033eb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80341f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803422:	5b                   	pop    %ebx
  803423:	5e                   	pop    %esi
  803424:	5f                   	pop    %edi
  803425:	5d                   	pop    %ebp
  803426:	c3                   	ret    

00803427 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803427:	55                   	push   %ebp
  803428:	89 e5                	mov    %esp,%ebp
  80342a:	83 ec 08             	sub    $0x8,%esp
  80342d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803432:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803436:	74 2a                	je     803462 <devcons_read+0x3b>
  803438:	eb 05                	jmp    80343f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80343a:	e8 8a f0 ff ff       	call   8024c9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80343f:	e8 06 f0 ff ff       	call   80244a <sys_cgetc>
  803444:	85 c0                	test   %eax,%eax
  803446:	74 f2                	je     80343a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803448:	85 c0                	test   %eax,%eax
  80344a:	78 16                	js     803462 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80344c:	83 f8 04             	cmp    $0x4,%eax
  80344f:	74 0c                	je     80345d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803451:	8b 55 0c             	mov    0xc(%ebp),%edx
  803454:	88 02                	mov    %al,(%edx)
	return 1;
  803456:	b8 01 00 00 00       	mov    $0x1,%eax
  80345b:	eb 05                	jmp    803462 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80345d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803462:	c9                   	leave  
  803463:	c3                   	ret    

00803464 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803464:	55                   	push   %ebp
  803465:	89 e5                	mov    %esp,%ebp
  803467:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80346a:	8b 45 08             	mov    0x8(%ebp),%eax
  80346d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803470:	6a 01                	push   $0x1
  803472:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803475:	50                   	push   %eax
  803476:	e8 b1 ef ff ff       	call   80242c <sys_cputs>
}
  80347b:	83 c4 10             	add    $0x10,%esp
  80347e:	c9                   	leave  
  80347f:	c3                   	ret    

00803480 <getchar>:

int
getchar(void)
{
  803480:	55                   	push   %ebp
  803481:	89 e5                	mov    %esp,%ebp
  803483:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803486:	6a 01                	push   $0x1
  803488:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80348b:	50                   	push   %eax
  80348c:	6a 00                	push   $0x0
  80348e:	e8 81 f6 ff ff       	call   802b14 <read>
	if (r < 0)
  803493:	83 c4 10             	add    $0x10,%esp
  803496:	85 c0                	test   %eax,%eax
  803498:	78 0f                	js     8034a9 <getchar+0x29>
		return r;
	if (r < 1)
  80349a:	85 c0                	test   %eax,%eax
  80349c:	7e 06                	jle    8034a4 <getchar+0x24>
		return -E_EOF;
	return c;
  80349e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8034a2:	eb 05                	jmp    8034a9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8034a4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8034a9:	c9                   	leave  
  8034aa:	c3                   	ret    

008034ab <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8034ab:	55                   	push   %ebp
  8034ac:	89 e5                	mov    %esp,%ebp
  8034ae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8034b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8034b4:	50                   	push   %eax
  8034b5:	ff 75 08             	pushl  0x8(%ebp)
  8034b8:	e8 f1 f3 ff ff       	call   8028ae <fd_lookup>
  8034bd:	83 c4 10             	add    $0x10,%esp
  8034c0:	85 c0                	test   %eax,%eax
  8034c2:	78 11                	js     8034d5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8034c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034c7:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8034cd:	39 10                	cmp    %edx,(%eax)
  8034cf:	0f 94 c0             	sete   %al
  8034d2:	0f b6 c0             	movzbl %al,%eax
}
  8034d5:	c9                   	leave  
  8034d6:	c3                   	ret    

008034d7 <opencons>:

int
opencons(void)
{
  8034d7:	55                   	push   %ebp
  8034d8:	89 e5                	mov    %esp,%ebp
  8034da:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8034dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8034e0:	50                   	push   %eax
  8034e1:	e8 79 f3 ff ff       	call   80285f <fd_alloc>
  8034e6:	83 c4 10             	add    $0x10,%esp
		return r;
  8034e9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8034eb:	85 c0                	test   %eax,%eax
  8034ed:	78 3e                	js     80352d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8034ef:	83 ec 04             	sub    $0x4,%esp
  8034f2:	68 07 04 00 00       	push   $0x407
  8034f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8034fa:	6a 00                	push   $0x0
  8034fc:	e8 e7 ef ff ff       	call   8024e8 <sys_page_alloc>
  803501:	83 c4 10             	add    $0x10,%esp
		return r;
  803504:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803506:	85 c0                	test   %eax,%eax
  803508:	78 23                	js     80352d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80350a:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803510:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803513:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803515:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803518:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80351f:	83 ec 0c             	sub    $0xc,%esp
  803522:	50                   	push   %eax
  803523:	e8 10 f3 ff ff       	call   802838 <fd2num>
  803528:	89 c2                	mov    %eax,%edx
  80352a:	83 c4 10             	add    $0x10,%esp
}
  80352d:	89 d0                	mov    %edx,%eax
  80352f:	c9                   	leave  
  803530:	c3                   	ret    
  803531:	66 90                	xchg   %ax,%ax
  803533:	66 90                	xchg   %ax,%ax
  803535:	66 90                	xchg   %ax,%ax
  803537:	66 90                	xchg   %ax,%ax
  803539:	66 90                	xchg   %ax,%ax
  80353b:	66 90                	xchg   %ax,%ax
  80353d:	66 90                	xchg   %ax,%ax
  80353f:	90                   	nop

00803540 <__udivdi3>:
  803540:	55                   	push   %ebp
  803541:	57                   	push   %edi
  803542:	56                   	push   %esi
  803543:	53                   	push   %ebx
  803544:	83 ec 1c             	sub    $0x1c,%esp
  803547:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80354b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80354f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803557:	85 f6                	test   %esi,%esi
  803559:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80355d:	89 ca                	mov    %ecx,%edx
  80355f:	89 f8                	mov    %edi,%eax
  803561:	75 3d                	jne    8035a0 <__udivdi3+0x60>
  803563:	39 cf                	cmp    %ecx,%edi
  803565:	0f 87 c5 00 00 00    	ja     803630 <__udivdi3+0xf0>
  80356b:	85 ff                	test   %edi,%edi
  80356d:	89 fd                	mov    %edi,%ebp
  80356f:	75 0b                	jne    80357c <__udivdi3+0x3c>
  803571:	b8 01 00 00 00       	mov    $0x1,%eax
  803576:	31 d2                	xor    %edx,%edx
  803578:	f7 f7                	div    %edi
  80357a:	89 c5                	mov    %eax,%ebp
  80357c:	89 c8                	mov    %ecx,%eax
  80357e:	31 d2                	xor    %edx,%edx
  803580:	f7 f5                	div    %ebp
  803582:	89 c1                	mov    %eax,%ecx
  803584:	89 d8                	mov    %ebx,%eax
  803586:	89 cf                	mov    %ecx,%edi
  803588:	f7 f5                	div    %ebp
  80358a:	89 c3                	mov    %eax,%ebx
  80358c:	89 d8                	mov    %ebx,%eax
  80358e:	89 fa                	mov    %edi,%edx
  803590:	83 c4 1c             	add    $0x1c,%esp
  803593:	5b                   	pop    %ebx
  803594:	5e                   	pop    %esi
  803595:	5f                   	pop    %edi
  803596:	5d                   	pop    %ebp
  803597:	c3                   	ret    
  803598:	90                   	nop
  803599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035a0:	39 ce                	cmp    %ecx,%esi
  8035a2:	77 74                	ja     803618 <__udivdi3+0xd8>
  8035a4:	0f bd fe             	bsr    %esi,%edi
  8035a7:	83 f7 1f             	xor    $0x1f,%edi
  8035aa:	0f 84 98 00 00 00    	je     803648 <__udivdi3+0x108>
  8035b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8035b5:	89 f9                	mov    %edi,%ecx
  8035b7:	89 c5                	mov    %eax,%ebp
  8035b9:	29 fb                	sub    %edi,%ebx
  8035bb:	d3 e6                	shl    %cl,%esi
  8035bd:	89 d9                	mov    %ebx,%ecx
  8035bf:	d3 ed                	shr    %cl,%ebp
  8035c1:	89 f9                	mov    %edi,%ecx
  8035c3:	d3 e0                	shl    %cl,%eax
  8035c5:	09 ee                	or     %ebp,%esi
  8035c7:	89 d9                	mov    %ebx,%ecx
  8035c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8035cd:	89 d5                	mov    %edx,%ebp
  8035cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8035d3:	d3 ed                	shr    %cl,%ebp
  8035d5:	89 f9                	mov    %edi,%ecx
  8035d7:	d3 e2                	shl    %cl,%edx
  8035d9:	89 d9                	mov    %ebx,%ecx
  8035db:	d3 e8                	shr    %cl,%eax
  8035dd:	09 c2                	or     %eax,%edx
  8035df:	89 d0                	mov    %edx,%eax
  8035e1:	89 ea                	mov    %ebp,%edx
  8035e3:	f7 f6                	div    %esi
  8035e5:	89 d5                	mov    %edx,%ebp
  8035e7:	89 c3                	mov    %eax,%ebx
  8035e9:	f7 64 24 0c          	mull   0xc(%esp)
  8035ed:	39 d5                	cmp    %edx,%ebp
  8035ef:	72 10                	jb     803601 <__udivdi3+0xc1>
  8035f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8035f5:	89 f9                	mov    %edi,%ecx
  8035f7:	d3 e6                	shl    %cl,%esi
  8035f9:	39 c6                	cmp    %eax,%esi
  8035fb:	73 07                	jae    803604 <__udivdi3+0xc4>
  8035fd:	39 d5                	cmp    %edx,%ebp
  8035ff:	75 03                	jne    803604 <__udivdi3+0xc4>
  803601:	83 eb 01             	sub    $0x1,%ebx
  803604:	31 ff                	xor    %edi,%edi
  803606:	89 d8                	mov    %ebx,%eax
  803608:	89 fa                	mov    %edi,%edx
  80360a:	83 c4 1c             	add    $0x1c,%esp
  80360d:	5b                   	pop    %ebx
  80360e:	5e                   	pop    %esi
  80360f:	5f                   	pop    %edi
  803610:	5d                   	pop    %ebp
  803611:	c3                   	ret    
  803612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803618:	31 ff                	xor    %edi,%edi
  80361a:	31 db                	xor    %ebx,%ebx
  80361c:	89 d8                	mov    %ebx,%eax
  80361e:	89 fa                	mov    %edi,%edx
  803620:	83 c4 1c             	add    $0x1c,%esp
  803623:	5b                   	pop    %ebx
  803624:	5e                   	pop    %esi
  803625:	5f                   	pop    %edi
  803626:	5d                   	pop    %ebp
  803627:	c3                   	ret    
  803628:	90                   	nop
  803629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803630:	89 d8                	mov    %ebx,%eax
  803632:	f7 f7                	div    %edi
  803634:	31 ff                	xor    %edi,%edi
  803636:	89 c3                	mov    %eax,%ebx
  803638:	89 d8                	mov    %ebx,%eax
  80363a:	89 fa                	mov    %edi,%edx
  80363c:	83 c4 1c             	add    $0x1c,%esp
  80363f:	5b                   	pop    %ebx
  803640:	5e                   	pop    %esi
  803641:	5f                   	pop    %edi
  803642:	5d                   	pop    %ebp
  803643:	c3                   	ret    
  803644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803648:	39 ce                	cmp    %ecx,%esi
  80364a:	72 0c                	jb     803658 <__udivdi3+0x118>
  80364c:	31 db                	xor    %ebx,%ebx
  80364e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803652:	0f 87 34 ff ff ff    	ja     80358c <__udivdi3+0x4c>
  803658:	bb 01 00 00 00       	mov    $0x1,%ebx
  80365d:	e9 2a ff ff ff       	jmp    80358c <__udivdi3+0x4c>
  803662:	66 90                	xchg   %ax,%ax
  803664:	66 90                	xchg   %ax,%ax
  803666:	66 90                	xchg   %ax,%ax
  803668:	66 90                	xchg   %ax,%ax
  80366a:	66 90                	xchg   %ax,%ax
  80366c:	66 90                	xchg   %ax,%ax
  80366e:	66 90                	xchg   %ax,%ax

00803670 <__umoddi3>:
  803670:	55                   	push   %ebp
  803671:	57                   	push   %edi
  803672:	56                   	push   %esi
  803673:	53                   	push   %ebx
  803674:	83 ec 1c             	sub    $0x1c,%esp
  803677:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80367b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80367f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803683:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803687:	85 d2                	test   %edx,%edx
  803689:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80368d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803691:	89 f3                	mov    %esi,%ebx
  803693:	89 3c 24             	mov    %edi,(%esp)
  803696:	89 74 24 04          	mov    %esi,0x4(%esp)
  80369a:	75 1c                	jne    8036b8 <__umoddi3+0x48>
  80369c:	39 f7                	cmp    %esi,%edi
  80369e:	76 50                	jbe    8036f0 <__umoddi3+0x80>
  8036a0:	89 c8                	mov    %ecx,%eax
  8036a2:	89 f2                	mov    %esi,%edx
  8036a4:	f7 f7                	div    %edi
  8036a6:	89 d0                	mov    %edx,%eax
  8036a8:	31 d2                	xor    %edx,%edx
  8036aa:	83 c4 1c             	add    $0x1c,%esp
  8036ad:	5b                   	pop    %ebx
  8036ae:	5e                   	pop    %esi
  8036af:	5f                   	pop    %edi
  8036b0:	5d                   	pop    %ebp
  8036b1:	c3                   	ret    
  8036b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036b8:	39 f2                	cmp    %esi,%edx
  8036ba:	89 d0                	mov    %edx,%eax
  8036bc:	77 52                	ja     803710 <__umoddi3+0xa0>
  8036be:	0f bd ea             	bsr    %edx,%ebp
  8036c1:	83 f5 1f             	xor    $0x1f,%ebp
  8036c4:	75 5a                	jne    803720 <__umoddi3+0xb0>
  8036c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8036ca:	0f 82 e0 00 00 00    	jb     8037b0 <__umoddi3+0x140>
  8036d0:	39 0c 24             	cmp    %ecx,(%esp)
  8036d3:	0f 86 d7 00 00 00    	jbe    8037b0 <__umoddi3+0x140>
  8036d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8036dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8036e1:	83 c4 1c             	add    $0x1c,%esp
  8036e4:	5b                   	pop    %ebx
  8036e5:	5e                   	pop    %esi
  8036e6:	5f                   	pop    %edi
  8036e7:	5d                   	pop    %ebp
  8036e8:	c3                   	ret    
  8036e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036f0:	85 ff                	test   %edi,%edi
  8036f2:	89 fd                	mov    %edi,%ebp
  8036f4:	75 0b                	jne    803701 <__umoddi3+0x91>
  8036f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8036fb:	31 d2                	xor    %edx,%edx
  8036fd:	f7 f7                	div    %edi
  8036ff:	89 c5                	mov    %eax,%ebp
  803701:	89 f0                	mov    %esi,%eax
  803703:	31 d2                	xor    %edx,%edx
  803705:	f7 f5                	div    %ebp
  803707:	89 c8                	mov    %ecx,%eax
  803709:	f7 f5                	div    %ebp
  80370b:	89 d0                	mov    %edx,%eax
  80370d:	eb 99                	jmp    8036a8 <__umoddi3+0x38>
  80370f:	90                   	nop
  803710:	89 c8                	mov    %ecx,%eax
  803712:	89 f2                	mov    %esi,%edx
  803714:	83 c4 1c             	add    $0x1c,%esp
  803717:	5b                   	pop    %ebx
  803718:	5e                   	pop    %esi
  803719:	5f                   	pop    %edi
  80371a:	5d                   	pop    %ebp
  80371b:	c3                   	ret    
  80371c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803720:	8b 34 24             	mov    (%esp),%esi
  803723:	bf 20 00 00 00       	mov    $0x20,%edi
  803728:	89 e9                	mov    %ebp,%ecx
  80372a:	29 ef                	sub    %ebp,%edi
  80372c:	d3 e0                	shl    %cl,%eax
  80372e:	89 f9                	mov    %edi,%ecx
  803730:	89 f2                	mov    %esi,%edx
  803732:	d3 ea                	shr    %cl,%edx
  803734:	89 e9                	mov    %ebp,%ecx
  803736:	09 c2                	or     %eax,%edx
  803738:	89 d8                	mov    %ebx,%eax
  80373a:	89 14 24             	mov    %edx,(%esp)
  80373d:	89 f2                	mov    %esi,%edx
  80373f:	d3 e2                	shl    %cl,%edx
  803741:	89 f9                	mov    %edi,%ecx
  803743:	89 54 24 04          	mov    %edx,0x4(%esp)
  803747:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80374b:	d3 e8                	shr    %cl,%eax
  80374d:	89 e9                	mov    %ebp,%ecx
  80374f:	89 c6                	mov    %eax,%esi
  803751:	d3 e3                	shl    %cl,%ebx
  803753:	89 f9                	mov    %edi,%ecx
  803755:	89 d0                	mov    %edx,%eax
  803757:	d3 e8                	shr    %cl,%eax
  803759:	89 e9                	mov    %ebp,%ecx
  80375b:	09 d8                	or     %ebx,%eax
  80375d:	89 d3                	mov    %edx,%ebx
  80375f:	89 f2                	mov    %esi,%edx
  803761:	f7 34 24             	divl   (%esp)
  803764:	89 d6                	mov    %edx,%esi
  803766:	d3 e3                	shl    %cl,%ebx
  803768:	f7 64 24 04          	mull   0x4(%esp)
  80376c:	39 d6                	cmp    %edx,%esi
  80376e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803772:	89 d1                	mov    %edx,%ecx
  803774:	89 c3                	mov    %eax,%ebx
  803776:	72 08                	jb     803780 <__umoddi3+0x110>
  803778:	75 11                	jne    80378b <__umoddi3+0x11b>
  80377a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80377e:	73 0b                	jae    80378b <__umoddi3+0x11b>
  803780:	2b 44 24 04          	sub    0x4(%esp),%eax
  803784:	1b 14 24             	sbb    (%esp),%edx
  803787:	89 d1                	mov    %edx,%ecx
  803789:	89 c3                	mov    %eax,%ebx
  80378b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80378f:	29 da                	sub    %ebx,%edx
  803791:	19 ce                	sbb    %ecx,%esi
  803793:	89 f9                	mov    %edi,%ecx
  803795:	89 f0                	mov    %esi,%eax
  803797:	d3 e0                	shl    %cl,%eax
  803799:	89 e9                	mov    %ebp,%ecx
  80379b:	d3 ea                	shr    %cl,%edx
  80379d:	89 e9                	mov    %ebp,%ecx
  80379f:	d3 ee                	shr    %cl,%esi
  8037a1:	09 d0                	or     %edx,%eax
  8037a3:	89 f2                	mov    %esi,%edx
  8037a5:	83 c4 1c             	add    $0x1c,%esp
  8037a8:	5b                   	pop    %ebx
  8037a9:	5e                   	pop    %esi
  8037aa:	5f                   	pop    %edi
  8037ab:	5d                   	pop    %ebp
  8037ac:	c3                   	ret    
  8037ad:	8d 76 00             	lea    0x0(%esi),%esi
  8037b0:	29 f9                	sub    %edi,%ecx
  8037b2:	19 d6                	sbb    %edx,%esi
  8037b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8037b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8037bc:	e9 18 ff ff ff       	jmp    8036d9 <__umoddi3+0x69>
