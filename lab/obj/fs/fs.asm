
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
  80002c:	e8 b3 12 00 00       	call   8012e4 <libmain>
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
  8000b2:	68 80 30 80 00       	push   $0x803080
  8000b7:	e8 61 13 00 00       	call   80141d <cprintf>
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
  8000d4:	68 97 30 80 00       	push   $0x803097
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 a7 30 80 00       	push   $0x8030a7
  8000e0:	e8 5f 12 00 00       	call   801344 <_panic>
	diskno = d;
  8000e5:	a3 00 40 80 00       	mov    %eax,0x804000
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
  800106:	68 b0 30 80 00       	push   $0x8030b0
  80010b:	68 bd 30 80 00       	push   $0x8030bd
  800110:	6a 44                	push   $0x44
  800112:	68 a7 30 80 00       	push   $0x8030a7
  800117:	e8 28 12 00 00       	call   801344 <_panic>

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
  80014c:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
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
  8001ca:	68 b0 30 80 00       	push   $0x8030b0
  8001cf:	68 bd 30 80 00       	push   $0x8030bd
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 a7 30 80 00       	push   $0x8030a7
  8001db:	e8 64 11 00 00       	call   801344 <_panic>

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
  800210:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
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
  800277:	53                   	push   %ebx
  800278:	83 ec 04             	sub    $0x4,%esp
  80027b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
  80027e:	8b 01                	mov    (%ecx),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800280:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  800286:	89 d3                	mov    %edx,%ebx
  800288:	c1 eb 0c             	shr    $0xc,%ebx
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028b:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800291:	76 1b                	jbe    8002ae <bc_pgfault+0x3a>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	ff 71 04             	pushl  0x4(%ecx)
  800299:	50                   	push   %eax
  80029a:	ff 71 28             	pushl  0x28(%ecx)
  80029d:	68 d4 30 80 00       	push   $0x8030d4
  8002a2:	6a 27                	push   $0x27
  8002a4:	68 6a 31 80 00       	push   $0x80316a
  8002a9:	e8 96 10 00 00       	call   801344 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ae:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8002b4:	85 d2                	test   %edx,%edx
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 5a 04             	cmp    0x4(%edx),%ebx
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	53                   	push   %ebx
  8002be:	68 04 31 80 00       	push   $0x803104
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 6a 31 80 00       	push   $0x80316a
  8002ca:	e8 75 10 00 00       	call   801344 <_panic>
	//
	// LAB 5: you code here:

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002cf:	89 c2                	mov    %eax,%edx
  8002d1:	c1 ea 0c             	shr    $0xc,%edx
  8002d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8002e4:	52                   	push   %edx
  8002e5:	50                   	push   %eax
  8002e6:	6a 00                	push   $0x0
  8002e8:	50                   	push   %eax
  8002e9:	6a 00                	push   $0x0
  8002eb:	e8 f8 1a 00 00       	call   801de8 <sys_page_map>
  8002f0:	83 c4 20             	add    $0x20,%esp
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	79 12                	jns    800309 <bc_pgfault+0x95>
		panic("in bc_pgfault, sys_page_map: %e", r);
  8002f7:	50                   	push   %eax
  8002f8:	68 28 31 80 00       	push   $0x803128
  8002fd:	6a 37                	push   $0x37
  8002ff:	68 6a 31 80 00       	push   $0x80316a
  800304:	e8 3b 10 00 00       	call   801344 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800309:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  800310:	74 22                	je     800334 <bc_pgfault+0xc0>
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	53                   	push   %ebx
  800316:	e8 39 03 00 00       	call   800654 <block_is_free>
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	84 c0                	test   %al,%al
  800320:	74 12                	je     800334 <bc_pgfault+0xc0>
		panic("reading free block %08x\n", blockno);
  800322:	53                   	push   %ebx
  800323:	68 72 31 80 00       	push   $0x803172
  800328:	6a 3d                	push   $0x3d
  80032a:	68 6a 31 80 00       	push   $0x80316a
  80032f:	e8 10 10 00 00       	call   801344 <_panic>
}
  800334:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800337:	c9                   	leave  
  800338:	c3                   	ret    

00800339 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800342:	85 c0                	test   %eax,%eax
  800344:	74 0f                	je     800355 <diskaddr+0x1c>
  800346:	8b 15 08 90 80 00    	mov    0x809008,%edx
  80034c:	85 d2                	test   %edx,%edx
  80034e:	74 17                	je     800367 <diskaddr+0x2e>
  800350:	3b 42 04             	cmp    0x4(%edx),%eax
  800353:	72 12                	jb     800367 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800355:	50                   	push   %eax
  800356:	68 48 31 80 00       	push   $0x803148
  80035b:	6a 09                	push   $0x9
  80035d:	68 6a 31 80 00       	push   $0x80316a
  800362:	e8 dd 0f 00 00       	call   801344 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  800367:	05 00 00 01 00       	add    $0x10000,%eax
  80036c:	c1 e0 0c             	shl    $0xc,%eax
}
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  800377:	89 d0                	mov    %edx,%eax
  800379:	c1 e8 16             	shr    $0x16,%eax
  80037c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	f6 c1 01             	test   $0x1,%cl
  80038b:	74 0d                	je     80039a <va_is_mapped+0x29>
  80038d:	c1 ea 0c             	shr    $0xc,%edx
  800390:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800397:	83 e0 01             	and    $0x1,%eax
  80039a:	83 e0 01             	and    $0x1,%eax
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	c1 e8 0c             	shr    $0xc,%eax
  8003a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003af:	c1 e8 06             	shr    $0x6,%eax
  8003b2:	83 e0 01             	and    $0x1,%eax
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8003c0:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  8003c6:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  8003cc:	76 12                	jbe    8003e0 <flush_block+0x29>
		panic("flush_block of bad va %08x", addr);
  8003ce:	50                   	push   %eax
  8003cf:	68 8b 31 80 00       	push   $0x80318b
  8003d4:	6a 4d                	push   $0x4d
  8003d6:	68 6a 31 80 00       	push   $0x80316a
  8003db:	e8 64 0f 00 00       	call   801344 <_panic>

	// LAB 5: Your code here.
	panic("flush_block not implemented");
  8003e0:	83 ec 04             	sub    $0x4,%esp
  8003e3:	68 a6 31 80 00       	push   $0x8031a6
  8003e8:	6a 50                	push   $0x50
  8003ea:	68 6a 31 80 00       	push   $0x80316a
  8003ef:	e8 50 0f 00 00       	call   801344 <_panic>

008003f4 <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	81 ec 24 01 00 00    	sub    $0x124,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8003fd:	6a 01                	push   $0x1
  8003ff:	e8 35 ff ff ff       	call   800339 <diskaddr>
  800404:	83 c4 0c             	add    $0xc,%esp
  800407:	68 08 01 00 00       	push   $0x108
  80040c:	50                   	push   %eax
  80040d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800413:	50                   	push   %eax
  800414:	e8 1b 17 00 00       	call   801b34 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800419:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800420:	e8 14 ff ff ff       	call   800339 <diskaddr>
  800425:	83 c4 08             	add    $0x8,%esp
  800428:	68 c2 31 80 00       	push   $0x8031c2
  80042d:	50                   	push   %eax
  80042e:	e8 6f 15 00 00       	call   8019a2 <strcpy>
	flush_block(diskaddr(1));
  800433:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80043a:	e8 fa fe ff ff       	call   800339 <diskaddr>
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	e8 70 ff ff ff       	call   8003b7 <flush_block>

00800447 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	83 ec 14             	sub    $0x14,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  80044d:	68 74 02 80 00       	push   $0x800274
  800452:	e8 3f 1b 00 00       	call   801f96 <set_pgfault_handler>
	check_bc();
  800457:	e8 98 ff ff ff       	call   8003f4 <check_bc>

0080045c <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	57                   	push   %edi
  800460:	56                   	push   %esi
  800461:	53                   	push   %ebx
  800462:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  800468:	89 95 64 ff ff ff    	mov    %edx,-0x9c(%ebp)
  80046e:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  800474:	eb 03                	jmp    800479 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800476:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800479:	80 38 2f             	cmpb   $0x2f,(%eax)
  80047c:	74 f8                	je     800476 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  80047e:	8b 3d 08 90 80 00    	mov    0x809008,%edi
  800484:	8d 4f 08             	lea    0x8(%edi),%ecx
  800487:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
	dir = 0;
	name[0] = 0;
  80048d:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800494:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
  80049a:	85 c9                	test   %ecx,%ecx
  80049c:	0f 84 3d 01 00 00    	je     8005df <walk_path+0x183>
		*pdir = 0;
  8004a2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  8004a8:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  8004ae:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  8004b4:	80 38 00             	cmpb   $0x0,(%eax)
  8004b7:	0f 84 f3 00 00 00    	je     8005b0 <walk_path+0x154>
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	eb 03                	jmp    8004c4 <walk_path+0x68>
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  8004c1:	83 c3 01             	add    $0x1,%ebx
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8004c4:	0f b6 13             	movzbl (%ebx),%edx
  8004c7:	80 fa 2f             	cmp    $0x2f,%dl
  8004ca:	74 04                	je     8004d0 <walk_path+0x74>
  8004cc:	84 d2                	test   %dl,%dl
  8004ce:	75 f1                	jne    8004c1 <walk_path+0x65>
			path++;
		if (path - p >= MAXNAMELEN)
  8004d0:	89 de                	mov    %ebx,%esi
  8004d2:	29 c6                	sub    %eax,%esi
  8004d4:	83 fe 7f             	cmp    $0x7f,%esi
  8004d7:	0f 8f f4 00 00 00    	jg     8005d1 <walk_path+0x175>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  8004dd:	83 ec 04             	sub    $0x4,%esp
  8004e0:	56                   	push   %esi
  8004e1:	50                   	push   %eax
  8004e2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8004e8:	50                   	push   %eax
  8004e9:	e8 46 16 00 00       	call   801b34 <memmove>
		name[path - p] = '\0';
  8004ee:	c6 84 35 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%esi,1)
  8004f5:	00 
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 03                	jmp    8004fe <walk_path+0xa2>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8004fb:	83 c3 01             	add    $0x1,%ebx

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8004fe:	0f b6 13             	movzbl (%ebx),%edx
  800501:	80 fa 2f             	cmp    $0x2f,%dl
  800504:	74 f5                	je     8004fb <walk_path+0x9f>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800506:	83 bf 8c 00 00 00 01 	cmpl   $0x1,0x8c(%edi)
  80050d:	0f 85 c5 00 00 00    	jne    8005d8 <walk_path+0x17c>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800513:	8b 8f 88 00 00 00    	mov    0x88(%edi),%ecx
  800519:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
  80051f:	74 19                	je     80053a <walk_path+0xde>
  800521:	68 c9 31 80 00       	push   $0x8031c9
  800526:	68 bd 30 80 00       	push   $0x8030bd
  80052b:	68 ab 00 00 00       	push   $0xab
  800530:	68 e6 31 80 00       	push   $0x8031e6
  800535:	e8 0a 0e 00 00       	call   801344 <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  80053a:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
  800540:	85 c9                	test   %ecx,%ecx
  800542:	0f 49 c1             	cmovns %ecx,%eax
  800545:	c1 f8 0c             	sar    $0xc,%eax
  800548:	85 c0                	test   %eax,%eax
  80054a:	74 17                	je     800563 <walk_path+0x107>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  80054c:	83 ec 04             	sub    $0x4,%esp
  80054f:	68 b8 32 80 00       	push   $0x8032b8
  800554:	68 99 00 00 00       	push   $0x99
  800559:	68 e6 31 80 00       	push   $0x8031e6
  80055e:	e8 e1 0d 00 00       	call   801344 <_panic>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800563:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800568:	84 d2                	test   %dl,%dl
  80056a:	0f 85 86 00 00 00    	jne    8005f6 <walk_path+0x19a>
				if (pdir)
  800570:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800576:	85 c0                	test   %eax,%eax
  800578:	74 08                	je     800582 <walk_path+0x126>
					*pdir = dir;
  80057a:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  800580:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800582:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800586:	74 15                	je     80059d <walk_path+0x141>
					strcpy(lastelem, name);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800591:	50                   	push   %eax
  800592:	ff 75 08             	pushl  0x8(%ebp)
  800595:	e8 08 14 00 00       	call   8019a2 <strcpy>
  80059a:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  80059d:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8005a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  8005a9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8005ae:	eb 46                	jmp    8005f6 <walk_path+0x19a>
		}
	}

	if (pdir)
		*pdir = dir;
  8005b0:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8005b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pf = f;
  8005bc:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8005c2:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  8005c8:	89 08                	mov    %ecx,(%eax)
	return 0;
  8005ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cf:	eb 25                	jmp    8005f6 <walk_path+0x19a>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  8005d1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8005d6:	eb 1e                	jmp    8005f6 <walk_path+0x19a>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  8005d8:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8005dd:	eb 17                	jmp    8005f6 <walk_path+0x19a>
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  8005df:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  8005e5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  8005eb:	80 38 00             	cmpb   $0x0,(%eax)
  8005ee:	0f 85 c9 fe ff ff    	jne    8004bd <walk_path+0x61>
  8005f4:	eb c6                	jmp    8005bc <walk_path+0x160>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  8005f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f9:	5b                   	pop    %ebx
  8005fa:	5e                   	pop    %esi
  8005fb:	5f                   	pop    %edi
  8005fc:	5d                   	pop    %ebp
  8005fd:	c3                   	ret    

008005fe <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800604:	a1 08 90 80 00       	mov    0x809008,%eax
  800609:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80060f:	74 14                	je     800625 <check_super+0x27>
		panic("bad file system magic number");
  800611:	83 ec 04             	sub    $0x4,%esp
  800614:	68 ee 31 80 00       	push   $0x8031ee
  800619:	6a 0f                	push   $0xf
  80061b:	68 e6 31 80 00       	push   $0x8031e6
  800620:	e8 1f 0d 00 00       	call   801344 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800625:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  80062c:	76 14                	jbe    800642 <check_super+0x44>
		panic("file system is too large");
  80062e:	83 ec 04             	sub    $0x4,%esp
  800631:	68 0b 32 80 00       	push   $0x80320b
  800636:	6a 12                	push   $0x12
  800638:	68 e6 31 80 00       	push   $0x8031e6
  80063d:	e8 02 0d 00 00       	call   801344 <_panic>

	cprintf("superblock is good\n");
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	68 24 32 80 00       	push   $0x803224
  80064a:	e8 ce 0d 00 00       	call   80141d <cprintf>
}
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	c9                   	leave  
  800653:	c3                   	ret    

00800654 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	53                   	push   %ebx
  800658:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80065b:	8b 15 08 90 80 00    	mov    0x809008,%edx
  800661:	85 d2                	test   %edx,%edx
  800663:	74 24                	je     800689 <block_is_free+0x35>
		return 0;
  800665:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  80066a:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80066d:	76 1f                	jbe    80068e <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80066f:	89 cb                	mov    %ecx,%ebx
  800671:	c1 eb 05             	shr    $0x5,%ebx
  800674:	b8 01 00 00 00       	mov    $0x1,%eax
  800679:	d3 e0                	shl    %cl,%eax
  80067b:	8b 15 04 90 80 00    	mov    0x809004,%edx
  800681:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800684:	0f 95 c0             	setne  %al
  800687:	eb 05                	jmp    80068e <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800689:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80068e:	5b                   	pop    %ebx
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	53                   	push   %ebx
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80069b:	85 c9                	test   %ecx,%ecx
  80069d:	75 14                	jne    8006b3 <free_block+0x22>
		panic("attempt to free zero block");
  80069f:	83 ec 04             	sub    $0x4,%esp
  8006a2:	68 38 32 80 00       	push   $0x803238
  8006a7:	6a 2d                	push   $0x2d
  8006a9:	68 e6 31 80 00       	push   $0x8031e6
  8006ae:	e8 91 0c 00 00       	call   801344 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  8006b3:	89 cb                	mov    %ecx,%ebx
  8006b5:	c1 eb 05             	shr    $0x5,%ebx
  8006b8:	8b 15 04 90 80 00    	mov    0x809004,%edx
  8006be:	b8 01 00 00 00       	mov    $0x1,%eax
  8006c3:	d3 e0                	shl    %cl,%eax
  8006c5:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  8006c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 0c             	sub    $0xc,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	panic("alloc_block not implemented");
  8006d3:	68 53 32 80 00       	push   $0x803253
  8006d8:	6a 41                	push   $0x41
  8006da:	68 e6 31 80 00       	push   $0x8031e6
  8006df:	e8 60 0c 00 00       	call   801344 <_panic>

008006e4 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8006e9:	a1 08 90 80 00       	mov    0x809008,%eax
  8006ee:	8b 70 04             	mov    0x4(%eax),%esi
  8006f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f6:	eb 29                	jmp    800721 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  8006f8:	8d 43 02             	lea    0x2(%ebx),%eax
  8006fb:	50                   	push   %eax
  8006fc:	e8 53 ff ff ff       	call   800654 <block_is_free>
  800701:	83 c4 04             	add    $0x4,%esp
  800704:	84 c0                	test   %al,%al
  800706:	74 16                	je     80071e <check_bitmap+0x3a>
  800708:	68 6f 32 80 00       	push   $0x80326f
  80070d:	68 bd 30 80 00       	push   $0x8030bd
  800712:	6a 50                	push   $0x50
  800714:	68 e6 31 80 00       	push   $0x8031e6
  800719:	e8 26 0c 00 00       	call   801344 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80071e:	83 c3 01             	add    $0x1,%ebx
  800721:	89 d8                	mov    %ebx,%eax
  800723:	c1 e0 0f             	shl    $0xf,%eax
  800726:	39 f0                	cmp    %esi,%eax
  800728:	72 ce                	jb     8006f8 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  80072a:	83 ec 0c             	sub    $0xc,%esp
  80072d:	6a 00                	push   $0x0
  80072f:	e8 20 ff ff ff       	call   800654 <block_is_free>
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	84 c0                	test   %al,%al
  800739:	74 16                	je     800751 <check_bitmap+0x6d>
  80073b:	68 83 32 80 00       	push   $0x803283
  800740:	68 bd 30 80 00       	push   $0x8030bd
  800745:	6a 53                	push   $0x53
  800747:	68 e6 31 80 00       	push   $0x8031e6
  80074c:	e8 f3 0b 00 00       	call   801344 <_panic>
	assert(!block_is_free(1));
  800751:	83 ec 0c             	sub    $0xc,%esp
  800754:	6a 01                	push   $0x1
  800756:	e8 f9 fe ff ff       	call   800654 <block_is_free>
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	84 c0                	test   %al,%al
  800760:	74 16                	je     800778 <check_bitmap+0x94>
  800762:	68 95 32 80 00       	push   $0x803295
  800767:	68 bd 30 80 00       	push   $0x8030bd
  80076c:	6a 54                	push   $0x54
  80076e:	68 e6 31 80 00       	push   $0x8031e6
  800773:	e8 cc 0b 00 00       	call   801344 <_panic>

	cprintf("bitmap is good\n");
  800778:	83 ec 0c             	sub    $0xc,%esp
  80077b:	68 a7 32 80 00       	push   $0x8032a7
  800780:	e8 98 0c 00 00       	call   80141d <cprintf>
}
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800795:	e8 c5 f8 ff ff       	call   80005f <ide_probe_disk1>
  80079a:	84 c0                	test   %al,%al
  80079c:	74 0f                	je     8007ad <fs_init+0x1e>
		ide_set_disk(1);
  80079e:	83 ec 0c             	sub    $0xc,%esp
  8007a1:	6a 01                	push   $0x1
  8007a3:	e8 1b f9 ff ff       	call   8000c3 <ide_set_disk>
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	eb 0d                	jmp    8007ba <fs_init+0x2b>
	else
		ide_set_disk(0);
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	6a 00                	push   $0x0
  8007b2:	e8 0c f9 ff ff       	call   8000c3 <ide_set_disk>
  8007b7:	83 c4 10             	add    $0x10,%esp
	bc_init();
  8007ba:	e8 88 fc ff ff       	call   800447 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  8007bf:	83 ec 0c             	sub    $0xc,%esp
  8007c2:	6a 01                	push   $0x1
  8007c4:	e8 70 fb ff ff       	call   800339 <diskaddr>
  8007c9:	a3 08 90 80 00       	mov    %eax,0x809008
	check_super();
  8007ce:	e8 2b fe ff ff       	call   8005fe <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8007d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8007da:	e8 5a fb ff ff       	call   800339 <diskaddr>
  8007df:	a3 04 90 80 00       	mov    %eax,0x809004
	check_bitmap();
  8007e4:	e8 fb fe ff ff       	call   8006e4 <check_bitmap>
	
}
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 0c             	sub    $0xc,%esp
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8007f4:	68 b8 32 80 00       	push   $0x8032b8
  8007f9:	68 99 00 00 00       	push   $0x99
  8007fe:	68 e6 31 80 00       	push   $0x8031e6
  800803:	e8 3c 0b 00 00       	call   801344 <_panic>

00800808 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800813:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  800819:	50                   	push   %eax
  80081a:	8d 8d 70 ff ff ff    	lea    -0x90(%ebp),%ecx
  800820:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	e8 2e fc ff ff       	call   80045c <walk_path>
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	85 c0                	test   %eax,%eax
  800833:	0f 84 82 00 00 00    	je     8008bb <file_create+0xb3>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800839:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80083c:	0f 85 85 00 00 00    	jne    8008c7 <file_create+0xbf>
  800842:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	74 76                	je     8008c2 <file_create+0xba>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80084c:	8b 99 80 00 00 00    	mov    0x80(%ecx),%ebx
  800852:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  800858:	74 19                	je     800873 <file_create+0x6b>
  80085a:	68 c9 31 80 00       	push   $0x8031c9
  80085f:	68 bd 30 80 00       	push   $0x8030bd
  800864:	68 c4 00 00 00       	push   $0xc4
  800869:	68 e6 31 80 00       	push   $0x8031e6
  80086e:	e8 d1 0a 00 00       	call   801344 <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800873:	be 00 10 00 00       	mov    $0x1000,%esi
  800878:	89 d8                	mov    %ebx,%eax
  80087a:	99                   	cltd   
  80087b:	f7 fe                	idiv   %esi
  80087d:	85 c0                	test   %eax,%eax
  80087f:	74 17                	je     800898 <file_create+0x90>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800881:	83 ec 04             	sub    $0x4,%esp
  800884:	68 b8 32 80 00       	push   $0x8032b8
  800889:	68 99 00 00 00       	push   $0x99
  80088e:	68 e6 31 80 00       	push   $0x8031e6
  800893:	e8 ac 0a 00 00       	call   801344 <_panic>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800898:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80089e:	89 99 80 00 00 00    	mov    %ebx,0x80(%ecx)
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8008a4:	83 ec 04             	sub    $0x4,%esp
  8008a7:	68 b8 32 80 00       	push   $0x8032b8
  8008ac:	68 99 00 00 00       	push   $0x99
  8008b1:	68 e6 31 80 00       	push   $0x8031e6
  8008b6:	e8 89 0a 00 00       	call   801344 <_panic>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  8008bb:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8008c0:	eb 05                	jmp    8008c7 <file_create+0xbf>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  8008c2:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  8008c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  8008d4:	6a 00                	push   $0x0
  8008d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	e8 76 fb ff ff       	call   80045c <walk_path>
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8008fa:	39 d0                	cmp    %edx,%eax
  8008fc:	7e 27                	jle    800925 <file_read+0x3d>
		return 0;

	count = MIN(count, f->f_size - offset);
  8008fe:	29 d0                	sub    %edx,%eax
  800900:	3b 45 10             	cmp    0x10(%ebp),%eax
  800903:	0f 47 45 10          	cmova  0x10(%ebp),%eax

	for (pos = offset; pos < offset + count; ) {
  800907:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80090a:	39 ca                	cmp    %ecx,%edx
  80090c:	73 1c                	jae    80092a <file_read+0x42>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  80090e:	83 ec 04             	sub    $0x4,%esp
  800911:	68 b8 32 80 00       	push   $0x8032b8
  800916:	68 99 00 00 00       	push   $0x99
  80091b:	68 e6 31 80 00       	push   $0x8031e6
  800920:	e8 1f 0a 00 00       	call   801344 <_panic>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800937:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  80093d:	39 f0                	cmp    %esi,%eax
  80093f:	7e 65                	jle    8009a6 <file_set_size+0x7a>
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800941:	8d 96 fe 1f 00 00    	lea    0x1ffe(%esi),%edx
  800947:	89 f1                	mov    %esi,%ecx
  800949:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
  80094f:	0f 49 d1             	cmovns %ecx,%edx
  800952:	c1 fa 0c             	sar    $0xc,%edx
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800955:	8d 88 fe 1f 00 00    	lea    0x1ffe(%eax),%ecx
  80095b:	05 ff 0f 00 00       	add    $0xfff,%eax
  800960:	0f 48 c1             	cmovs  %ecx,%eax
  800963:	c1 f8 0c             	sar    $0xc,%eax
  800966:	39 d0                	cmp    %edx,%eax
  800968:	76 17                	jbe    800981 <file_set_size+0x55>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  80096a:	83 ec 04             	sub    $0x4,%esp
  80096d:	68 d8 32 80 00       	push   $0x8032d8
  800972:	68 8a 00 00 00       	push   $0x8a
  800977:	68 e6 31 80 00       	push   $0x8031e6
  80097c:	e8 c3 09 00 00       	call   801344 <_panic>
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800981:	83 fa 0a             	cmp    $0xa,%edx
  800984:	77 20                	ja     8009a6 <file_set_size+0x7a>
  800986:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  80098c:	85 c0                	test   %eax,%eax
  80098e:	74 16                	je     8009a6 <file_set_size+0x7a>
		free_block(f->f_indirect);
  800990:	83 ec 0c             	sub    $0xc,%esp
  800993:	50                   	push   %eax
  800994:	e8 f8 fc ff ff       	call   800691 <free_block>
		f->f_indirect = 0;
  800999:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
  8009a0:	00 00 00 
  8009a3:	83 c4 10             	add    $0x10,%esp
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  8009a6:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  8009ac:	83 ec 0c             	sub    $0xc,%esp
  8009af:	53                   	push   %ebx
  8009b0:	e8 02 fa ff ff       	call   8003b7 <flush_block>
	return 0;
}
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	83 ec 0c             	sub    $0xc,%esp
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009d0:	8b 7d 14             	mov    0x14(%ebp),%edi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  8009d3:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
  8009d6:	3b b0 80 00 00 00    	cmp    0x80(%eax),%esi
  8009dc:	76 11                	jbe    8009ef <file_write+0x2e>
		if ((r = file_set_size(f, offset + count)) < 0)
  8009de:	83 ec 08             	sub    $0x8,%esp
  8009e1:	56                   	push   %esi
  8009e2:	50                   	push   %eax
  8009e3:	e8 44 ff ff ff       	call   80092c <file_set_size>
  8009e8:	83 c4 10             	add    $0x10,%esp
  8009eb:	85 c0                	test   %eax,%eax
  8009ed:	78 1d                	js     800a0c <file_write+0x4b>
			return r;

	for (pos = offset; pos < offset + count; ) {
  8009ef:	39 f7                	cmp    %esi,%edi
  8009f1:	73 17                	jae    800a0a <file_write+0x49>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8009f3:	83 ec 04             	sub    $0x4,%esp
  8009f6:	68 b8 32 80 00       	push   $0x8032b8
  8009fb:	68 99 00 00 00       	push   $0x99
  800a00:	68 e6 31 80 00       	push   $0x8031e6
  800a05:	e8 3a 09 00 00       	call   801344 <_panic>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800a0a:	89 d8                	mov    %ebx,%eax
}
  800a0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	83 ec 04             	sub    $0x4,%esp
  800a1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800a1e:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800a24:	05 ff 0f 00 00       	add    $0xfff,%eax
  800a29:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800a2e:	7e 17                	jle    800a47 <file_flush+0x33>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  800a30:	83 ec 04             	sub    $0x4,%esp
  800a33:	68 d8 32 80 00       	push   $0x8032d8
  800a38:	68 8a 00 00 00       	push   $0x8a
  800a3d:	68 e6 31 80 00       	push   $0x8031e6
  800a42:	e8 fd 08 00 00       	call   801344 <_panic>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800a47:	83 ec 0c             	sub    $0xc,%esp
  800a4a:	53                   	push   %ebx
  800a4b:	e8 67 f9 ff ff       	call   8003b7 <flush_block>
	if (f->f_indirect)
  800a50:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800a56:	83 c4 10             	add    $0x10,%esp
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	74 14                	je     800a71 <file_flush+0x5d>
		flush_block(diskaddr(f->f_indirect));
  800a5d:	83 ec 0c             	sub    $0xc,%esp
  800a60:	50                   	push   %eax
  800a61:	e8 d3 f8 ff ff       	call   800339 <diskaddr>
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	e8 49 f9 ff ff       	call   8003b7 <flush_block>
  800a6e:	83 c4 10             	add    $0x10,%esp
}
  800a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	53                   	push   %ebx
  800a7a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800a7d:	bb 01 00 00 00       	mov    $0x1,%ebx
  800a82:	eb 17                	jmp    800a9b <fs_sync+0x25>
		flush_block(diskaddr(i));
  800a84:	83 ec 0c             	sub    $0xc,%esp
  800a87:	53                   	push   %ebx
  800a88:	e8 ac f8 ff ff       	call   800339 <diskaddr>
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 22 f9 ff ff       	call   8003b7 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800a95:	83 c3 01             	add    $0x1,%ebx
  800a98:	83 c4 10             	add    $0x10,%esp
  800a9b:	a1 08 90 80 00       	mov    0x809008,%eax
  800aa0:	39 58 04             	cmp    %ebx,0x4(%eax)
  800aa3:	77 df                	ja     800a84 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  800aa5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa8:	c9                   	leave  
  800aa9:	c3                   	ret    

00800aaa <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	83 ec 0c             	sub    $0xc,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  800aba:	68 f8 32 80 00       	push   $0x8032f8
  800abf:	68 e8 00 00 00       	push   $0xe8
  800ac4:	68 14 33 80 00       	push   $0x803314
  800ac9:	e8 76 08 00 00       	call   801344 <_panic>

00800ace <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  800ad4:	e8 9d ff ff ff       	call   800a76 <fs_sync>
	return 0;
}
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	c9                   	leave  
  800adf:	c3                   	ret    

00800ae0 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	ba 60 40 80 00       	mov    $0x804060,%edx
	int i;
	uintptr_t va = FILEVA;
  800ae8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800af2:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800af4:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800af7:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800afd:	83 c0 01             	add    $0x1,%eax
  800b00:	83 c2 10             	add    $0x10,%edx
  800b03:	3d 00 04 00 00       	cmp    $0x400,%eax
  800b08:	75 e8                	jne    800af2 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800b14:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	89 d8                	mov    %ebx,%eax
  800b1e:	c1 e0 04             	shl    $0x4,%eax
  800b21:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800b27:	e8 a8 1d 00 00       	call   8028d4 <pageref>
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	74 07                	je     800b3a <openfile_alloc+0x2e>
  800b33:	83 f8 01             	cmp    $0x1,%eax
  800b36:	74 20                	je     800b58 <openfile_alloc+0x4c>
  800b38:	eb 51                	jmp    800b8b <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800b3a:	83 ec 04             	sub    $0x4,%esp
  800b3d:	6a 07                	push   $0x7
  800b3f:	89 d8                	mov    %ebx,%eax
  800b41:	c1 e0 04             	shl    $0x4,%eax
  800b44:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800b4a:	6a 00                	push   $0x0
  800b4c:	e8 54 12 00 00       	call   801da5 <sys_page_alloc>
  800b51:	83 c4 10             	add    $0x10,%esp
  800b54:	85 c0                	test   %eax,%eax
  800b56:	78 43                	js     800b9b <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  800b58:	c1 e3 04             	shl    $0x4,%ebx
  800b5b:	8d 83 60 40 80 00    	lea    0x804060(%ebx),%eax
  800b61:	81 83 60 40 80 00 00 	addl   $0x400,0x804060(%ebx)
  800b68:	04 00 00 
			*o = &opentab[i];
  800b6b:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  800b6d:	83 ec 04             	sub    $0x4,%esp
  800b70:	68 00 10 00 00       	push   $0x1000
  800b75:	6a 00                	push   $0x0
  800b77:	ff b3 6c 40 80 00    	pushl  0x80406c(%ebx)
  800b7d:	e8 65 0f 00 00       	call   801ae7 <memset>
			return (*o)->o_fileid;
  800b82:	8b 06                	mov    (%esi),%eax
  800b84:	8b 00                	mov    (%eax),%eax
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	eb 10                	jmp    800b9b <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800b8b:	83 c3 01             	add    $0x1,%ebx
  800b8e:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800b94:	75 83                	jne    800b19 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800b96:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 18             	sub    $0x18,%esp
  800bab:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800bae:	89 fb                	mov    %edi,%ebx
  800bb0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800bb6:	89 de                	mov    %ebx,%esi
  800bb8:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800bbb:	ff b6 6c 40 80 00    	pushl  0x80406c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800bc1:	81 c6 60 40 80 00    	add    $0x804060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800bc7:	e8 08 1d 00 00       	call   8028d4 <pageref>
  800bcc:	83 c4 10             	add    $0x10,%esp
  800bcf:	83 f8 01             	cmp    $0x1,%eax
  800bd2:	7e 17                	jle    800beb <openfile_lookup+0x49>
  800bd4:	c1 e3 04             	shl    $0x4,%ebx
  800bd7:	3b bb 60 40 80 00    	cmp    0x804060(%ebx),%edi
  800bdd:	75 13                	jne    800bf2 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  800bdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800be2:	89 30                	mov    %esi,(%eax)
	return 0;
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
  800be9:	eb 0c                	jmp    800bf7 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  800beb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bf0:	eb 05                	jmp    800bf7 <openfile_lookup+0x55>
  800bf2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	53                   	push   %ebx
  800c03:	83 ec 18             	sub    $0x18,%esp
  800c06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800c09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c0c:	50                   	push   %eax
  800c0d:	ff 33                	pushl  (%ebx)
  800c0f:	ff 75 08             	pushl  0x8(%ebp)
  800c12:	e8 8b ff ff ff       	call   800ba2 <openfile_lookup>
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	78 14                	js     800c32 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  800c1e:	83 ec 08             	sub    $0x8,%esp
  800c21:	ff 73 04             	pushl  0x4(%ebx)
  800c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c27:	ff 70 04             	pushl  0x4(%eax)
  800c2a:	e8 fd fc ff ff       	call   80092c <file_set_size>
  800c2f:	83 c4 10             	add    $0x10,%esp
}
  800c32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 18             	sub    $0x18,%esp
  800c3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800c41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c44:	50                   	push   %eax
  800c45:	ff 33                	pushl  (%ebx)
  800c47:	ff 75 08             	pushl  0x8(%ebp)
  800c4a:	e8 53 ff ff ff       	call   800ba2 <openfile_lookup>
  800c4f:	83 c4 10             	add    $0x10,%esp
  800c52:	85 c0                	test   %eax,%eax
  800c54:	78 3f                	js     800c95 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  800c56:	83 ec 08             	sub    $0x8,%esp
  800c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5c:	ff 70 04             	pushl  0x4(%eax)
  800c5f:	53                   	push   %ebx
  800c60:	e8 3d 0d 00 00       	call   8019a2 <strcpy>
	ret->ret_size = o->o_file->f_size;
  800c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c68:	8b 50 04             	mov    0x4(%eax),%edx
  800c6b:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800c71:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  800c77:	8b 40 04             	mov    0x4(%eax),%eax
  800c7a:	83 c4 10             	add    $0x10,%esp
  800c7d:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c84:	0f 94 c0             	sete   %al
  800c87:	0f b6 c0             	movzbl %al,%eax
  800c8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800ca0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca3:	50                   	push   %eax
  800ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca7:	ff 30                	pushl  (%eax)
  800ca9:	ff 75 08             	pushl  0x8(%ebp)
  800cac:	e8 f1 fe ff ff       	call   800ba2 <openfile_lookup>
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	78 16                	js     800cce <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbe:	ff 70 04             	pushl  0x4(%eax)
  800cc1:	e8 4e fd ff ff       	call   800a14 <file_flush>
	return 0;
  800cc6:	83 c4 10             	add    $0x10,%esp
  800cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cce:	c9                   	leave  
  800ccf:	c3                   	ret    

00800cd0 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	53                   	push   %ebx
  800cd4:	81 ec 18 04 00 00    	sub    $0x418,%esp
  800cda:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  800cdd:	68 00 04 00 00       	push   $0x400
  800ce2:	53                   	push   %ebx
  800ce3:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800ce9:	50                   	push   %eax
  800cea:	e8 45 0e 00 00       	call   801b34 <memmove>
	path[MAXPATHLEN-1] = 0;
  800cef:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  800cf3:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  800cf9:	89 04 24             	mov    %eax,(%esp)
  800cfc:	e8 0b fe ff ff       	call   800b0c <openfile_alloc>
  800d01:	83 c4 10             	add    $0x10,%esp
  800d04:	85 c0                	test   %eax,%eax
  800d06:	0f 88 f0 00 00 00    	js     800dfc <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  800d0c:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  800d13:	74 33                	je     800d48 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  800d15:	83 ec 08             	sub    $0x8,%esp
  800d18:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800d1e:	50                   	push   %eax
  800d1f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800d25:	50                   	push   %eax
  800d26:	e8 dd fa ff ff       	call   800808 <file_create>
  800d2b:	83 c4 10             	add    $0x10,%esp
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	79 37                	jns    800d69 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  800d32:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  800d39:	0f 85 bd 00 00 00    	jne    800dfc <serve_open+0x12c>
  800d3f:	83 f8 f3             	cmp    $0xfffffff3,%eax
  800d42:	0f 85 b4 00 00 00    	jne    800dfc <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  800d48:	83 ec 08             	sub    $0x8,%esp
  800d4b:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800d51:	50                   	push   %eax
  800d52:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800d58:	50                   	push   %eax
  800d59:	e8 70 fb ff ff       	call   8008ce <file_open>
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	85 c0                	test   %eax,%eax
  800d63:	0f 88 93 00 00 00    	js     800dfc <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  800d69:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  800d70:	74 17                	je     800d89 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  800d72:	83 ec 08             	sub    $0x8,%esp
  800d75:	6a 00                	push   $0x0
  800d77:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  800d7d:	e8 aa fb ff ff       	call   80092c <file_set_size>
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	85 c0                	test   %eax,%eax
  800d87:	78 73                	js     800dfc <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  800d89:	83 ec 08             	sub    $0x8,%esp
  800d8c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800d92:	50                   	push   %eax
  800d93:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800d99:	50                   	push   %eax
  800d9a:	e8 2f fb ff ff       	call   8008ce <file_open>
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	78 56                	js     800dfc <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  800da6:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800dac:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  800db2:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  800db5:	8b 50 0c             	mov    0xc(%eax),%edx
  800db8:	8b 08                	mov    (%eax),%ecx
  800dba:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  800dbd:	8b 48 0c             	mov    0xc(%eax),%ecx
  800dc0:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800dc6:	83 e2 03             	and    $0x3,%edx
  800dc9:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  800dcc:	8b 40 0c             	mov    0xc(%eax),%eax
  800dcf:	8b 15 64 80 80 00    	mov    0x808064,%edx
  800dd5:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  800dd7:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800ddd:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800de3:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  800de6:	8b 50 0c             	mov    0xc(%eax),%edx
  800de9:	8b 45 10             	mov    0x10(%ebp),%eax
  800dec:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  800dee:	8b 45 14             	mov    0x14(%ebp),%eax
  800df1:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  800df7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    

00800e01 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800e09:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800e0c:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  800e0f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	53                   	push   %ebx
  800e1a:	ff 35 44 40 80 00    	pushl  0x804044
  800e20:	56                   	push   %esi
  800e21:	e8 db 11 00 00       	call   802001 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  800e2d:	75 15                	jne    800e44 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	ff 75 f4             	pushl  -0xc(%ebp)
  800e35:	68 40 33 80 00       	push   $0x803340
  800e3a:	e8 de 05 00 00       	call   80141d <cprintf>
				whom);
			continue; // just leave it hanging...
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	eb cb                	jmp    800e0f <serve+0xe>
		}

		pg = NULL;
  800e44:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  800e4b:	83 f8 01             	cmp    $0x1,%eax
  800e4e:	75 18                	jne    800e68 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  800e50:	53                   	push   %ebx
  800e51:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e54:	50                   	push   %eax
  800e55:	ff 35 44 40 80 00    	pushl  0x804044
  800e5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5e:	e8 6d fe ff ff       	call   800cd0 <serve_open>
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	eb 3c                	jmp    800ea4 <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  800e68:	83 f8 08             	cmp    $0x8,%eax
  800e6b:	77 1e                	ja     800e8b <serve+0x8a>
  800e6d:	8b 14 85 20 40 80 00 	mov    0x804020(,%eax,4),%edx
  800e74:	85 d2                	test   %edx,%edx
  800e76:	74 13                	je     800e8b <serve+0x8a>
			r = handlers[req](whom, fsreq);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	ff 35 44 40 80 00    	pushl  0x804044
  800e81:	ff 75 f4             	pushl  -0xc(%ebp)
  800e84:	ff d2                	call   *%edx
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	eb 19                	jmp    800ea4 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	50                   	push   %eax
  800e92:	68 70 33 80 00       	push   $0x803370
  800e97:	e8 81 05 00 00       	call   80141d <cprintf>
  800e9c:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  800e9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  800ea4:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea7:	ff 75 ec             	pushl  -0x14(%ebp)
  800eaa:	50                   	push   %eax
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	e8 b5 11 00 00       	call   802068 <ipc_send>
		sys_page_unmap(0, fsreq);
  800eb3:	83 c4 08             	add    $0x8,%esp
  800eb6:	ff 35 44 40 80 00    	pushl  0x804044
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 67 0f 00 00       	call   801e2a <sys_page_unmap>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	e9 44 ff ff ff       	jmp    800e0f <serve+0xe>

00800ecb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  800ed1:	c7 05 60 80 80 00 1e 	movl   $0x80331e,0x808060
  800ed8:	33 80 00 
	cprintf("FS is running\n");
  800edb:	68 21 33 80 00       	push   $0x803321
  800ee0:	e8 38 05 00 00       	call   80141d <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  800ee5:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  800eea:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  800eef:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  800ef1:	c7 04 24 30 33 80 00 	movl   $0x803330,(%esp)
  800ef8:	e8 20 05 00 00       	call   80141d <cprintf>

	serve_init();
  800efd:	e8 de fb ff ff       	call   800ae0 <serve_init>
	fs_init();
  800f02:	e8 88 f8 ff ff       	call   80078f <fs_init>
        fs_test();
  800f07:	e8 05 00 00 00       	call   800f11 <fs_test>
	serve();
  800f0c:	e8 f0 fe ff ff       	call   800e01 <serve>

00800f11 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	53                   	push   %ebx
  800f15:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  800f18:	6a 07                	push   $0x7
  800f1a:	68 00 10 00 00       	push   $0x1000
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 7f 0e 00 00       	call   801da5 <sys_page_alloc>
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 12                	jns    800f3f <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  800f2d:	50                   	push   %eax
  800f2e:	68 93 33 80 00       	push   $0x803393
  800f33:	6a 12                	push   $0x12
  800f35:	68 a6 33 80 00       	push   $0x8033a6
  800f3a:	e8 05 04 00 00       	call   801344 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  800f3f:	83 ec 04             	sub    $0x4,%esp
  800f42:	68 00 10 00 00       	push   $0x1000
  800f47:	ff 35 04 90 80 00    	pushl  0x809004
  800f4d:	68 00 10 00 00       	push   $0x1000
  800f52:	e8 dd 0b 00 00       	call   801b34 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  800f57:	e8 71 f7 ff ff       	call   8006cd <alloc_block>
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 12                	jns    800f75 <fs_test+0x64>
		panic("alloc_block: %e", r);
  800f63:	50                   	push   %eax
  800f64:	68 b0 33 80 00       	push   $0x8033b0
  800f69:	6a 17                	push   $0x17
  800f6b:	68 a6 33 80 00       	push   $0x8033a6
  800f70:	e8 cf 03 00 00       	call   801344 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  800f75:	8d 50 1f             	lea    0x1f(%eax),%edx
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	0f 49 d0             	cmovns %eax,%edx
  800f7d:	c1 fa 05             	sar    $0x5,%edx
  800f80:	89 c3                	mov    %eax,%ebx
  800f82:	c1 fb 1f             	sar    $0x1f,%ebx
  800f85:	c1 eb 1b             	shr    $0x1b,%ebx
  800f88:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  800f8b:	83 e1 1f             	and    $0x1f,%ecx
  800f8e:	29 d9                	sub    %ebx,%ecx
  800f90:	b8 01 00 00 00       	mov    $0x1,%eax
  800f95:	d3 e0                	shl    %cl,%eax
  800f97:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  800f9e:	75 16                	jne    800fb6 <fs_test+0xa5>
  800fa0:	68 c0 33 80 00       	push   $0x8033c0
  800fa5:	68 bd 30 80 00       	push   $0x8030bd
  800faa:	6a 19                	push   $0x19
  800fac:	68 a6 33 80 00       	push   $0x8033a6
  800fb1:	e8 8e 03 00 00       	call   801344 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  800fb6:	8b 0d 04 90 80 00    	mov    0x809004,%ecx
  800fbc:	85 04 91             	test   %eax,(%ecx,%edx,4)
  800fbf:	74 16                	je     800fd7 <fs_test+0xc6>
  800fc1:	68 38 35 80 00       	push   $0x803538
  800fc6:	68 bd 30 80 00       	push   $0x8030bd
  800fcb:	6a 1b                	push   $0x1b
  800fcd:	68 a6 33 80 00       	push   $0x8033a6
  800fd2:	e8 6d 03 00 00       	call   801344 <_panic>
	cprintf("alloc_block is good\n");
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	68 db 33 80 00       	push   $0x8033db
  800fdf:	e8 39 04 00 00       	call   80141d <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fea:	50                   	push   %eax
  800feb:	68 f0 33 80 00       	push   $0x8033f0
  800ff0:	e8 d9 f8 ff ff       	call   8008ce <file_open>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ffb:	74 1b                	je     801018 <fs_test+0x107>
  800ffd:	89 c2                	mov    %eax,%edx
  800fff:	c1 ea 1f             	shr    $0x1f,%edx
  801002:	84 d2                	test   %dl,%dl
  801004:	74 12                	je     801018 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801006:	50                   	push   %eax
  801007:	68 fb 33 80 00       	push   $0x8033fb
  80100c:	6a 1f                	push   $0x1f
  80100e:	68 a6 33 80 00       	push   $0x8033a6
  801013:	e8 2c 03 00 00       	call   801344 <_panic>
	else if (r == 0)
  801018:	85 c0                	test   %eax,%eax
  80101a:	75 14                	jne    801030 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	68 58 35 80 00       	push   $0x803558
  801024:	6a 21                	push   $0x21
  801026:	68 a6 33 80 00       	push   $0x8033a6
  80102b:	e8 14 03 00 00       	call   801344 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801030:	83 ec 08             	sub    $0x8,%esp
  801033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	68 14 34 80 00       	push   $0x803414
  80103c:	e8 8d f8 ff ff       	call   8008ce <file_open>
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 12                	jns    80105a <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801048:	50                   	push   %eax
  801049:	68 1d 34 80 00       	push   $0x80341d
  80104e:	6a 23                	push   $0x23
  801050:	68 a6 33 80 00       	push   $0x8033a6
  801055:	e8 ea 02 00 00       	call   801344 <_panic>
	cprintf("file_open is good\n");
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	68 34 34 80 00       	push   $0x803434
  801062:	e8 b6 03 00 00       	call   80141d <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801067:	83 c4 0c             	add    $0xc,%esp
  80106a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106d:	50                   	push   %eax
  80106e:	6a 00                	push   $0x0
  801070:	ff 75 f4             	pushl  -0xc(%ebp)
  801073:	e8 76 f7 ff ff       	call   8007ee <file_get_block>
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	79 12                	jns    801091 <fs_test+0x180>
		panic("file_get_block: %e", r);
  80107f:	50                   	push   %eax
  801080:	68 47 34 80 00       	push   $0x803447
  801085:	6a 27                	push   $0x27
  801087:	68 a6 33 80 00       	push   $0x8033a6
  80108c:	e8 b3 02 00 00       	call   801344 <_panic>
	if (strcmp(blk, msg) != 0)
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	68 78 35 80 00       	push   $0x803578
  801099:	ff 75 f0             	pushl  -0x10(%ebp)
  80109c:	e8 ab 09 00 00       	call   801a4c <strcmp>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	74 14                	je     8010bc <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	68 a0 35 80 00       	push   $0x8035a0
  8010b0:	6a 29                	push   $0x29
  8010b2:	68 a6 33 80 00       	push   $0x8033a6
  8010b7:	e8 88 02 00 00       	call   801344 <_panic>
	cprintf("file_get_block is good\n");
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	68 5a 34 80 00       	push   $0x80345a
  8010c4:	e8 54 03 00 00       	call   80141d <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8010c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cc:	0f b6 10             	movzbl (%eax),%edx
  8010cf:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8010d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d4:	c1 e8 0c             	shr    $0xc,%eax
  8010d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	a8 40                	test   $0x40,%al
  8010e3:	75 16                	jne    8010fb <fs_test+0x1ea>
  8010e5:	68 73 34 80 00       	push   $0x803473
  8010ea:	68 bd 30 80 00       	push   $0x8030bd
  8010ef:	6a 2d                	push   $0x2d
  8010f1:	68 a6 33 80 00       	push   $0x8033a6
  8010f6:	e8 49 02 00 00       	call   801344 <_panic>
	file_flush(f);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801101:	e8 0e f9 ff ff       	call   800a14 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801106:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801109:	c1 e8 0c             	shr    $0xc,%eax
  80110c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	a8 40                	test   $0x40,%al
  801118:	74 16                	je     801130 <fs_test+0x21f>
  80111a:	68 72 34 80 00       	push   $0x803472
  80111f:	68 bd 30 80 00       	push   $0x8030bd
  801124:	6a 2f                	push   $0x2f
  801126:	68 a6 33 80 00       	push   $0x8033a6
  80112b:	e8 14 02 00 00       	call   801344 <_panic>
	cprintf("file_flush is good\n");
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	68 8e 34 80 00       	push   $0x80348e
  801138:	e8 e0 02 00 00       	call   80141d <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80113d:	83 c4 08             	add    $0x8,%esp
  801140:	6a 00                	push   $0x0
  801142:	ff 75 f4             	pushl  -0xc(%ebp)
  801145:	e8 e2 f7 ff ff       	call   80092c <file_set_size>
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 12                	jns    801163 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801151:	50                   	push   %eax
  801152:	68 a2 34 80 00       	push   $0x8034a2
  801157:	6a 33                	push   $0x33
  801159:	68 a6 33 80 00       	push   $0x8033a6
  80115e:	e8 e1 01 00 00       	call   801344 <_panic>
	assert(f->f_direct[0] == 0);
  801163:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801166:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80116d:	74 16                	je     801185 <fs_test+0x274>
  80116f:	68 b4 34 80 00       	push   $0x8034b4
  801174:	68 bd 30 80 00       	push   $0x8030bd
  801179:	6a 34                	push   $0x34
  80117b:	68 a6 33 80 00       	push   $0x8033a6
  801180:	e8 bf 01 00 00       	call   801344 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801185:	c1 e8 0c             	shr    $0xc,%eax
  801188:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118f:	a8 40                	test   $0x40,%al
  801191:	74 16                	je     8011a9 <fs_test+0x298>
  801193:	68 c8 34 80 00       	push   $0x8034c8
  801198:	68 bd 30 80 00       	push   $0x8030bd
  80119d:	6a 35                	push   $0x35
  80119f:	68 a6 33 80 00       	push   $0x8033a6
  8011a4:	e8 9b 01 00 00       	call   801344 <_panic>
	cprintf("file_truncate is good\n");
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	68 e2 34 80 00       	push   $0x8034e2
  8011b1:	e8 67 02 00 00       	call   80141d <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8011b6:	c7 04 24 78 35 80 00 	movl   $0x803578,(%esp)
  8011bd:	e8 a7 07 00 00       	call   801969 <strlen>
  8011c2:	83 c4 08             	add    $0x8,%esp
  8011c5:	50                   	push   %eax
  8011c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c9:	e8 5e f7 ff ff       	call   80092c <file_set_size>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	79 12                	jns    8011e7 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  8011d5:	50                   	push   %eax
  8011d6:	68 f9 34 80 00       	push   $0x8034f9
  8011db:	6a 39                	push   $0x39
  8011dd:	68 a6 33 80 00       	push   $0x8033a6
  8011e2:	e8 5d 01 00 00       	call   801344 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	c1 ea 0c             	shr    $0xc,%edx
  8011ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f6:	f6 c2 40             	test   $0x40,%dl
  8011f9:	74 16                	je     801211 <fs_test+0x300>
  8011fb:	68 c8 34 80 00       	push   $0x8034c8
  801200:	68 bd 30 80 00       	push   $0x8030bd
  801205:	6a 3a                	push   $0x3a
  801207:	68 a6 33 80 00       	push   $0x8033a6
  80120c:	e8 33 01 00 00       	call   801344 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801217:	52                   	push   %edx
  801218:	6a 00                	push   $0x0
  80121a:	50                   	push   %eax
  80121b:	e8 ce f5 ff ff       	call   8007ee <file_get_block>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	79 12                	jns    801239 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801227:	50                   	push   %eax
  801228:	68 0d 35 80 00       	push   $0x80350d
  80122d:	6a 3c                	push   $0x3c
  80122f:	68 a6 33 80 00       	push   $0x8033a6
  801234:	e8 0b 01 00 00       	call   801344 <_panic>
	strcpy(blk, msg);
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	68 78 35 80 00       	push   $0x803578
  801241:	ff 75 f0             	pushl  -0x10(%ebp)
  801244:	e8 59 07 00 00       	call   8019a2 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124c:	c1 e8 0c             	shr    $0xc,%eax
  80124f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	a8 40                	test   $0x40,%al
  80125b:	75 16                	jne    801273 <fs_test+0x362>
  80125d:	68 73 34 80 00       	push   $0x803473
  801262:	68 bd 30 80 00       	push   $0x8030bd
  801267:	6a 3e                	push   $0x3e
  801269:	68 a6 33 80 00       	push   $0x8033a6
  80126e:	e8 d1 00 00 00       	call   801344 <_panic>
	file_flush(f);
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	ff 75 f4             	pushl  -0xc(%ebp)
  801279:	e8 96 f7 ff ff       	call   800a14 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	c1 e8 0c             	shr    $0xc,%eax
  801284:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	a8 40                	test   $0x40,%al
  801290:	74 16                	je     8012a8 <fs_test+0x397>
  801292:	68 72 34 80 00       	push   $0x803472
  801297:	68 bd 30 80 00       	push   $0x8030bd
  80129c:	6a 40                	push   $0x40
  80129e:	68 a6 33 80 00       	push   $0x8033a6
  8012a3:	e8 9c 00 00 00       	call   801344 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8012a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ab:	c1 e8 0c             	shr    $0xc,%eax
  8012ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b5:	a8 40                	test   $0x40,%al
  8012b7:	74 16                	je     8012cf <fs_test+0x3be>
  8012b9:	68 c8 34 80 00       	push   $0x8034c8
  8012be:	68 bd 30 80 00       	push   $0x8030bd
  8012c3:	6a 41                	push   $0x41
  8012c5:	68 a6 33 80 00       	push   $0x8033a6
  8012ca:	e8 75 00 00 00       	call   801344 <_panic>
	cprintf("file rewrite is good\n");
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	68 22 35 80 00       	push   $0x803522
  8012d7:	e8 41 01 00 00       	call   80141d <cprintf>
}
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    

008012e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
  8012e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8012ef:	e8 73 0a 00 00       	call   801d67 <sys_getenvid>
  8012f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801301:	a3 0c 90 80 00       	mov    %eax,0x80900c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801306:	85 db                	test   %ebx,%ebx
  801308:	7e 07                	jle    801311 <libmain+0x2d>
		binaryname = argv[0];
  80130a:	8b 06                	mov    (%esi),%eax
  80130c:	a3 60 80 80 00       	mov    %eax,0x808060

	// call user main routine
	umain(argc, argv);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	56                   	push   %esi
  801315:	53                   	push   %ebx
  801316:	e8 b0 fb ff ff       	call   800ecb <umain>

	// exit gracefully
	exit();
  80131b:	e8 0a 00 00 00       	call   80132a <exit>
}
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801330:	e8 8b 0f 00 00       	call   8022c0 <close_all>
	sys_env_destroy(0);
  801335:	83 ec 0c             	sub    $0xc,%esp
  801338:	6a 00                	push   $0x0
  80133a:	e8 e7 09 00 00       	call   801d26 <sys_env_destroy>
}
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801349:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80134c:	8b 35 60 80 80 00    	mov    0x808060,%esi
  801352:	e8 10 0a 00 00       	call   801d67 <sys_getenvid>
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	ff 75 0c             	pushl  0xc(%ebp)
  80135d:	ff 75 08             	pushl  0x8(%ebp)
  801360:	56                   	push   %esi
  801361:	50                   	push   %eax
  801362:	68 d0 35 80 00       	push   $0x8035d0
  801367:	e8 b1 00 00 00       	call   80141d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80136c:	83 c4 18             	add    $0x18,%esp
  80136f:	53                   	push   %ebx
  801370:	ff 75 10             	pushl  0x10(%ebp)
  801373:	e8 54 00 00 00       	call   8013cc <vcprintf>
	cprintf("\n");
  801378:	c7 04 24 c7 31 80 00 	movl   $0x8031c7,(%esp)
  80137f:	e8 99 00 00 00       	call   80141d <cprintf>
  801384:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801387:	cc                   	int3   
  801388:	eb fd                	jmp    801387 <_panic+0x43>

0080138a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	53                   	push   %ebx
  80138e:	83 ec 04             	sub    $0x4,%esp
  801391:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801394:	8b 13                	mov    (%ebx),%edx
  801396:	8d 42 01             	lea    0x1(%edx),%eax
  801399:	89 03                	mov    %eax,(%ebx)
  80139b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013a7:	75 1a                	jne    8013c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	68 ff 00 00 00       	push   $0xff
  8013b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8013b4:	50                   	push   %eax
  8013b5:	e8 2f 09 00 00       	call   801ce9 <sys_cputs>
		b->idx = 0;
  8013ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8013c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8013c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8013d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8013dc:	00 00 00 
	b.cnt = 0;
  8013df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8013e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8013e9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ec:	ff 75 08             	pushl  0x8(%ebp)
  8013ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	68 8a 13 80 00       	push   $0x80138a
  8013fb:	e8 54 01 00 00       	call   801554 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801400:	83 c4 08             	add    $0x8,%esp
  801403:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801409:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80140f:	50                   	push   %eax
  801410:	e8 d4 08 00 00       	call   801ce9 <sys_cputs>

	return b.cnt;
}
  801415:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801423:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801426:	50                   	push   %eax
  801427:	ff 75 08             	pushl  0x8(%ebp)
  80142a:	e8 9d ff ff ff       	call   8013cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	57                   	push   %edi
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 1c             	sub    $0x1c,%esp
  80143a:	89 c7                	mov    %eax,%edi
  80143c:	89 d6                	mov    %edx,%esi
  80143e:	8b 45 08             	mov    0x8(%ebp),%eax
  801441:	8b 55 0c             	mov    0xc(%ebp),%edx
  801444:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801447:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80144a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80144d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801452:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801455:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801458:	39 d3                	cmp    %edx,%ebx
  80145a:	72 05                	jb     801461 <printnum+0x30>
  80145c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80145f:	77 45                	ja     8014a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801461:	83 ec 0c             	sub    $0xc,%esp
  801464:	ff 75 18             	pushl  0x18(%ebp)
  801467:	8b 45 14             	mov    0x14(%ebp),%eax
  80146a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80146d:	53                   	push   %ebx
  80146e:	ff 75 10             	pushl  0x10(%ebp)
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 e4             	pushl  -0x1c(%ebp)
  801477:	ff 75 e0             	pushl  -0x20(%ebp)
  80147a:	ff 75 dc             	pushl  -0x24(%ebp)
  80147d:	ff 75 d8             	pushl  -0x28(%ebp)
  801480:	e8 6b 19 00 00       	call   802df0 <__udivdi3>
  801485:	83 c4 18             	add    $0x18,%esp
  801488:	52                   	push   %edx
  801489:	50                   	push   %eax
  80148a:	89 f2                	mov    %esi,%edx
  80148c:	89 f8                	mov    %edi,%eax
  80148e:	e8 9e ff ff ff       	call   801431 <printnum>
  801493:	83 c4 20             	add    $0x20,%esp
  801496:	eb 18                	jmp    8014b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	56                   	push   %esi
  80149c:	ff 75 18             	pushl  0x18(%ebp)
  80149f:	ff d7                	call   *%edi
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	eb 03                	jmp    8014a9 <printnum+0x78>
  8014a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014a9:	83 eb 01             	sub    $0x1,%ebx
  8014ac:	85 db                	test   %ebx,%ebx
  8014ae:	7f e8                	jg     801498 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	56                   	push   %esi
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8014bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8014c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8014c3:	e8 58 1a 00 00       	call   802f20 <__umoddi3>
  8014c8:	83 c4 14             	add    $0x14,%esp
  8014cb:	0f be 80 f3 35 80 00 	movsbl 0x8035f3(%eax),%eax
  8014d2:	50                   	push   %eax
  8014d3:	ff d7                	call   *%edi
}
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5f                   	pop    %edi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014e3:	83 fa 01             	cmp    $0x1,%edx
  8014e6:	7e 0e                	jle    8014f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014e8:	8b 10                	mov    (%eax),%edx
  8014ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8014ed:	89 08                	mov    %ecx,(%eax)
  8014ef:	8b 02                	mov    (%edx),%eax
  8014f1:	8b 52 04             	mov    0x4(%edx),%edx
  8014f4:	eb 22                	jmp    801518 <getuint+0x38>
	else if (lflag)
  8014f6:	85 d2                	test   %edx,%edx
  8014f8:	74 10                	je     80150a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8014fa:	8b 10                	mov    (%eax),%edx
  8014fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014ff:	89 08                	mov    %ecx,(%eax)
  801501:	8b 02                	mov    (%edx),%eax
  801503:	ba 00 00 00 00       	mov    $0x0,%edx
  801508:	eb 0e                	jmp    801518 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80150a:	8b 10                	mov    (%eax),%edx
  80150c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80150f:	89 08                	mov    %ecx,(%eax)
  801511:	8b 02                	mov    (%edx),%eax
  801513:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801520:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801524:	8b 10                	mov    (%eax),%edx
  801526:	3b 50 04             	cmp    0x4(%eax),%edx
  801529:	73 0a                	jae    801535 <sprintputch+0x1b>
		*b->buf++ = ch;
  80152b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80152e:	89 08                	mov    %ecx,(%eax)
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	88 02                	mov    %al,(%edx)
}
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    

00801537 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80153d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801540:	50                   	push   %eax
  801541:	ff 75 10             	pushl  0x10(%ebp)
  801544:	ff 75 0c             	pushl  0xc(%ebp)
  801547:	ff 75 08             	pushl  0x8(%ebp)
  80154a:	e8 05 00 00 00       	call   801554 <vprintfmt>
	va_end(ap);
}
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	57                   	push   %edi
  801558:	56                   	push   %esi
  801559:	53                   	push   %ebx
  80155a:	83 ec 2c             	sub    $0x2c,%esp
  80155d:	8b 75 08             	mov    0x8(%ebp),%esi
  801560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801563:	8b 7d 10             	mov    0x10(%ebp),%edi
  801566:	eb 12                	jmp    80157a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801568:	85 c0                	test   %eax,%eax
  80156a:	0f 84 89 03 00 00    	je     8018f9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	53                   	push   %ebx
  801574:	50                   	push   %eax
  801575:	ff d6                	call   *%esi
  801577:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80157a:	83 c7 01             	add    $0x1,%edi
  80157d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801581:	83 f8 25             	cmp    $0x25,%eax
  801584:	75 e2                	jne    801568 <vprintfmt+0x14>
  801586:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80158a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801591:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801598:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80159f:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a4:	eb 07                	jmp    8015ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ad:	8d 47 01             	lea    0x1(%edi),%eax
  8015b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015b3:	0f b6 07             	movzbl (%edi),%eax
  8015b6:	0f b6 c8             	movzbl %al,%ecx
  8015b9:	83 e8 23             	sub    $0x23,%eax
  8015bc:	3c 55                	cmp    $0x55,%al
  8015be:	0f 87 1a 03 00 00    	ja     8018de <vprintfmt+0x38a>
  8015c4:	0f b6 c0             	movzbl %al,%eax
  8015c7:	ff 24 85 40 37 80 00 	jmp    *0x803740(,%eax,4)
  8015ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8015d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8015d5:	eb d6                	jmp    8015ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015da:	b8 00 00 00 00       	mov    $0x0,%eax
  8015df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8015e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8015e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8015ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8015ef:	83 fa 09             	cmp    $0x9,%edx
  8015f2:	77 39                	ja     80162d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8015f7:	eb e9                	jmp    8015e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8015ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801602:	8b 00                	mov    (%eax),%eax
  801604:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801607:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80160a:	eb 27                	jmp    801633 <vprintfmt+0xdf>
  80160c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80160f:	85 c0                	test   %eax,%eax
  801611:	b9 00 00 00 00       	mov    $0x0,%ecx
  801616:	0f 49 c8             	cmovns %eax,%ecx
  801619:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80161f:	eb 8c                	jmp    8015ad <vprintfmt+0x59>
  801621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801624:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80162b:	eb 80                	jmp    8015ad <vprintfmt+0x59>
  80162d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801630:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801633:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801637:	0f 89 70 ff ff ff    	jns    8015ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80163d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801640:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801643:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80164a:	e9 5e ff ff ff       	jmp    8015ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80164f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801655:	e9 53 ff ff ff       	jmp    8015ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80165a:	8b 45 14             	mov    0x14(%ebp),%eax
  80165d:	8d 50 04             	lea    0x4(%eax),%edx
  801660:	89 55 14             	mov    %edx,0x14(%ebp)
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	53                   	push   %ebx
  801667:	ff 30                	pushl  (%eax)
  801669:	ff d6                	call   *%esi
			break;
  80166b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80166e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801671:	e9 04 ff ff ff       	jmp    80157a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801676:	8b 45 14             	mov    0x14(%ebp),%eax
  801679:	8d 50 04             	lea    0x4(%eax),%edx
  80167c:	89 55 14             	mov    %edx,0x14(%ebp)
  80167f:	8b 00                	mov    (%eax),%eax
  801681:	99                   	cltd   
  801682:	31 d0                	xor    %edx,%eax
  801684:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801686:	83 f8 0f             	cmp    $0xf,%eax
  801689:	7f 0b                	jg     801696 <vprintfmt+0x142>
  80168b:	8b 14 85 a0 38 80 00 	mov    0x8038a0(,%eax,4),%edx
  801692:	85 d2                	test   %edx,%edx
  801694:	75 18                	jne    8016ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801696:	50                   	push   %eax
  801697:	68 0b 36 80 00       	push   $0x80360b
  80169c:	53                   	push   %ebx
  80169d:	56                   	push   %esi
  80169e:	e8 94 fe ff ff       	call   801537 <printfmt>
  8016a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016a9:	e9 cc fe ff ff       	jmp    80157a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016ae:	52                   	push   %edx
  8016af:	68 cf 30 80 00       	push   $0x8030cf
  8016b4:	53                   	push   %ebx
  8016b5:	56                   	push   %esi
  8016b6:	e8 7c fe ff ff       	call   801537 <printfmt>
  8016bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016c1:	e9 b4 fe ff ff       	jmp    80157a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8016c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c9:	8d 50 04             	lea    0x4(%eax),%edx
  8016cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8016cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8016d1:	85 ff                	test   %edi,%edi
  8016d3:	b8 04 36 80 00       	mov    $0x803604,%eax
  8016d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8016db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016df:	0f 8e 94 00 00 00    	jle    801779 <vprintfmt+0x225>
  8016e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8016e9:	0f 84 98 00 00 00    	je     801787 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	ff 75 d0             	pushl  -0x30(%ebp)
  8016f5:	57                   	push   %edi
  8016f6:	e8 86 02 00 00       	call   801981 <strnlen>
  8016fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8016fe:	29 c1                	sub    %eax,%ecx
  801700:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801703:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801706:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80170a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80170d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801710:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801712:	eb 0f                	jmp    801723 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	53                   	push   %ebx
  801718:	ff 75 e0             	pushl  -0x20(%ebp)
  80171b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80171d:	83 ef 01             	sub    $0x1,%edi
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	85 ff                	test   %edi,%edi
  801725:	7f ed                	jg     801714 <vprintfmt+0x1c0>
  801727:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80172a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80172d:	85 c9                	test   %ecx,%ecx
  80172f:	b8 00 00 00 00       	mov    $0x0,%eax
  801734:	0f 49 c1             	cmovns %ecx,%eax
  801737:	29 c1                	sub    %eax,%ecx
  801739:	89 75 08             	mov    %esi,0x8(%ebp)
  80173c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80173f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801742:	89 cb                	mov    %ecx,%ebx
  801744:	eb 4d                	jmp    801793 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801746:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80174a:	74 1b                	je     801767 <vprintfmt+0x213>
  80174c:	0f be c0             	movsbl %al,%eax
  80174f:	83 e8 20             	sub    $0x20,%eax
  801752:	83 f8 5e             	cmp    $0x5e,%eax
  801755:	76 10                	jbe    801767 <vprintfmt+0x213>
					putch('?', putdat);
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	ff 75 0c             	pushl  0xc(%ebp)
  80175d:	6a 3f                	push   $0x3f
  80175f:	ff 55 08             	call   *0x8(%ebp)
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	eb 0d                	jmp    801774 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	ff 75 0c             	pushl  0xc(%ebp)
  80176d:	52                   	push   %edx
  80176e:	ff 55 08             	call   *0x8(%ebp)
  801771:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801774:	83 eb 01             	sub    $0x1,%ebx
  801777:	eb 1a                	jmp    801793 <vprintfmt+0x23f>
  801779:	89 75 08             	mov    %esi,0x8(%ebp)
  80177c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80177f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801782:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801785:	eb 0c                	jmp    801793 <vprintfmt+0x23f>
  801787:	89 75 08             	mov    %esi,0x8(%ebp)
  80178a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80178d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801790:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801793:	83 c7 01             	add    $0x1,%edi
  801796:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80179a:	0f be d0             	movsbl %al,%edx
  80179d:	85 d2                	test   %edx,%edx
  80179f:	74 23                	je     8017c4 <vprintfmt+0x270>
  8017a1:	85 f6                	test   %esi,%esi
  8017a3:	78 a1                	js     801746 <vprintfmt+0x1f2>
  8017a5:	83 ee 01             	sub    $0x1,%esi
  8017a8:	79 9c                	jns    801746 <vprintfmt+0x1f2>
  8017aa:	89 df                	mov    %ebx,%edi
  8017ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8017af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017b2:	eb 18                	jmp    8017cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017b4:	83 ec 08             	sub    $0x8,%esp
  8017b7:	53                   	push   %ebx
  8017b8:	6a 20                	push   $0x20
  8017ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8017bc:	83 ef 01             	sub    $0x1,%edi
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	eb 08                	jmp    8017cc <vprintfmt+0x278>
  8017c4:	89 df                	mov    %ebx,%edi
  8017c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017cc:	85 ff                	test   %edi,%edi
  8017ce:	7f e4                	jg     8017b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017d3:	e9 a2 fd ff ff       	jmp    80157a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8017d8:	83 fa 01             	cmp    $0x1,%edx
  8017db:	7e 16                	jle    8017f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8017dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e0:	8d 50 08             	lea    0x8(%eax),%edx
  8017e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8017e6:	8b 50 04             	mov    0x4(%eax),%edx
  8017e9:	8b 00                	mov    (%eax),%eax
  8017eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8017f1:	eb 32                	jmp    801825 <vprintfmt+0x2d1>
	else if (lflag)
  8017f3:	85 d2                	test   %edx,%edx
  8017f5:	74 18                	je     80180f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8017f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fa:	8d 50 04             	lea    0x4(%eax),%edx
  8017fd:	89 55 14             	mov    %edx,0x14(%ebp)
  801800:	8b 00                	mov    (%eax),%eax
  801802:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801805:	89 c1                	mov    %eax,%ecx
  801807:	c1 f9 1f             	sar    $0x1f,%ecx
  80180a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80180d:	eb 16                	jmp    801825 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80180f:	8b 45 14             	mov    0x14(%ebp),%eax
  801812:	8d 50 04             	lea    0x4(%eax),%edx
  801815:	89 55 14             	mov    %edx,0x14(%ebp)
  801818:	8b 00                	mov    (%eax),%eax
  80181a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80181d:	89 c1                	mov    %eax,%ecx
  80181f:	c1 f9 1f             	sar    $0x1f,%ecx
  801822:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801825:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801828:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80182b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801830:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801834:	79 74                	jns    8018aa <vprintfmt+0x356>
				putch('-', putdat);
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	53                   	push   %ebx
  80183a:	6a 2d                	push   $0x2d
  80183c:	ff d6                	call   *%esi
				num = -(long long) num;
  80183e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801841:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801844:	f7 d8                	neg    %eax
  801846:	83 d2 00             	adc    $0x0,%edx
  801849:	f7 da                	neg    %edx
  80184b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80184e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801853:	eb 55                	jmp    8018aa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801855:	8d 45 14             	lea    0x14(%ebp),%eax
  801858:	e8 83 fc ff ff       	call   8014e0 <getuint>
			base = 10;
  80185d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801862:	eb 46                	jmp    8018aa <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801864:	8d 45 14             	lea    0x14(%ebp),%eax
  801867:	e8 74 fc ff ff       	call   8014e0 <getuint>
			base = 8;
  80186c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801871:	eb 37                	jmp    8018aa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	53                   	push   %ebx
  801877:	6a 30                	push   $0x30
  801879:	ff d6                	call   *%esi
			putch('x', putdat);
  80187b:	83 c4 08             	add    $0x8,%esp
  80187e:	53                   	push   %ebx
  80187f:	6a 78                	push   $0x78
  801881:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801883:	8b 45 14             	mov    0x14(%ebp),%eax
  801886:	8d 50 04             	lea    0x4(%eax),%edx
  801889:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80188c:	8b 00                	mov    (%eax),%eax
  80188e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801893:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801896:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80189b:	eb 0d                	jmp    8018aa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80189d:	8d 45 14             	lea    0x14(%ebp),%eax
  8018a0:	e8 3b fc ff ff       	call   8014e0 <getuint>
			base = 16;
  8018a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018aa:	83 ec 0c             	sub    $0xc,%esp
  8018ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8018b1:	57                   	push   %edi
  8018b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8018b5:	51                   	push   %ecx
  8018b6:	52                   	push   %edx
  8018b7:	50                   	push   %eax
  8018b8:	89 da                	mov    %ebx,%edx
  8018ba:	89 f0                	mov    %esi,%eax
  8018bc:	e8 70 fb ff ff       	call   801431 <printnum>
			break;
  8018c1:	83 c4 20             	add    $0x20,%esp
  8018c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018c7:	e9 ae fc ff ff       	jmp    80157a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	53                   	push   %ebx
  8018d0:	51                   	push   %ecx
  8018d1:	ff d6                	call   *%esi
			break;
  8018d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8018d9:	e9 9c fc ff ff       	jmp    80157a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	53                   	push   %ebx
  8018e2:	6a 25                	push   $0x25
  8018e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	eb 03                	jmp    8018ee <vprintfmt+0x39a>
  8018eb:	83 ef 01             	sub    $0x1,%edi
  8018ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8018f2:	75 f7                	jne    8018eb <vprintfmt+0x397>
  8018f4:	e9 81 fc ff ff       	jmp    80157a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8018f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fc:	5b                   	pop    %ebx
  8018fd:	5e                   	pop    %esi
  8018fe:	5f                   	pop    %edi
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	83 ec 18             	sub    $0x18,%esp
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
  80190a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80190d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801910:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801914:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801917:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80191e:	85 c0                	test   %eax,%eax
  801920:	74 26                	je     801948 <vsnprintf+0x47>
  801922:	85 d2                	test   %edx,%edx
  801924:	7e 22                	jle    801948 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801926:	ff 75 14             	pushl  0x14(%ebp)
  801929:	ff 75 10             	pushl  0x10(%ebp)
  80192c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	68 1a 15 80 00       	push   $0x80151a
  801935:	e8 1a fc ff ff       	call   801554 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80193a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80193d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801940:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	eb 05                	jmp    80194d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801948:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801955:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801958:	50                   	push   %eax
  801959:	ff 75 10             	pushl  0x10(%ebp)
  80195c:	ff 75 0c             	pushl  0xc(%ebp)
  80195f:	ff 75 08             	pushl  0x8(%ebp)
  801962:	e8 9a ff ff ff       	call   801901 <vsnprintf>
	va_end(ap);

	return rc;
}
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80196f:	b8 00 00 00 00       	mov    $0x0,%eax
  801974:	eb 03                	jmp    801979 <strlen+0x10>
		n++;
  801976:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801979:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80197d:	75 f7                	jne    801976 <strlen+0xd>
		n++;
	return n;
}
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801987:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	eb 03                	jmp    801994 <strnlen+0x13>
		n++;
  801991:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801994:	39 c2                	cmp    %eax,%edx
  801996:	74 08                	je     8019a0 <strnlen+0x1f>
  801998:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80199c:	75 f3                	jne    801991 <strnlen+0x10>
  80199e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	53                   	push   %ebx
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019ac:	89 c2                	mov    %eax,%edx
  8019ae:	83 c2 01             	add    $0x1,%edx
  8019b1:	83 c1 01             	add    $0x1,%ecx
  8019b4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8019b8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8019bb:	84 db                	test   %bl,%bl
  8019bd:	75 ef                	jne    8019ae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8019bf:	5b                   	pop    %ebx
  8019c0:	5d                   	pop    %ebp
  8019c1:	c3                   	ret    

008019c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	53                   	push   %ebx
  8019c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8019c9:	53                   	push   %ebx
  8019ca:	e8 9a ff ff ff       	call   801969 <strlen>
  8019cf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8019d2:	ff 75 0c             	pushl  0xc(%ebp)
  8019d5:	01 d8                	add    %ebx,%eax
  8019d7:	50                   	push   %eax
  8019d8:	e8 c5 ff ff ff       	call   8019a2 <strcpy>
	return dst;
}
  8019dd:	89 d8                	mov    %ebx,%eax
  8019df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ef:	89 f3                	mov    %esi,%ebx
  8019f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019f4:	89 f2                	mov    %esi,%edx
  8019f6:	eb 0f                	jmp    801a07 <strncpy+0x23>
		*dst++ = *src;
  8019f8:	83 c2 01             	add    $0x1,%edx
  8019fb:	0f b6 01             	movzbl (%ecx),%eax
  8019fe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a01:	80 39 01             	cmpb   $0x1,(%ecx)
  801a04:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a07:	39 da                	cmp    %ebx,%edx
  801a09:	75 ed                	jne    8019f8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a0b:	89 f0                	mov    %esi,%eax
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	8b 75 08             	mov    0x8(%ebp),%esi
  801a19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a1c:	8b 55 10             	mov    0x10(%ebp),%edx
  801a1f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a21:	85 d2                	test   %edx,%edx
  801a23:	74 21                	je     801a46 <strlcpy+0x35>
  801a25:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a29:	89 f2                	mov    %esi,%edx
  801a2b:	eb 09                	jmp    801a36 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a2d:	83 c2 01             	add    $0x1,%edx
  801a30:	83 c1 01             	add    $0x1,%ecx
  801a33:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a36:	39 c2                	cmp    %eax,%edx
  801a38:	74 09                	je     801a43 <strlcpy+0x32>
  801a3a:	0f b6 19             	movzbl (%ecx),%ebx
  801a3d:	84 db                	test   %bl,%bl
  801a3f:	75 ec                	jne    801a2d <strlcpy+0x1c>
  801a41:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a43:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a46:	29 f0                	sub    %esi,%eax
}
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801a55:	eb 06                	jmp    801a5d <strcmp+0x11>
		p++, q++;
  801a57:	83 c1 01             	add    $0x1,%ecx
  801a5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801a5d:	0f b6 01             	movzbl (%ecx),%eax
  801a60:	84 c0                	test   %al,%al
  801a62:	74 04                	je     801a68 <strcmp+0x1c>
  801a64:	3a 02                	cmp    (%edx),%al
  801a66:	74 ef                	je     801a57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801a68:	0f b6 c0             	movzbl %al,%eax
  801a6b:	0f b6 12             	movzbl (%edx),%edx
  801a6e:	29 d0                	sub    %edx,%eax
}
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    

00801a72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	53                   	push   %ebx
  801a76:	8b 45 08             	mov    0x8(%ebp),%eax
  801a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a7c:	89 c3                	mov    %eax,%ebx
  801a7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801a81:	eb 06                	jmp    801a89 <strncmp+0x17>
		n--, p++, q++;
  801a83:	83 c0 01             	add    $0x1,%eax
  801a86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801a89:	39 d8                	cmp    %ebx,%eax
  801a8b:	74 15                	je     801aa2 <strncmp+0x30>
  801a8d:	0f b6 08             	movzbl (%eax),%ecx
  801a90:	84 c9                	test   %cl,%cl
  801a92:	74 04                	je     801a98 <strncmp+0x26>
  801a94:	3a 0a                	cmp    (%edx),%cl
  801a96:	74 eb                	je     801a83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801a98:	0f b6 00             	movzbl (%eax),%eax
  801a9b:	0f b6 12             	movzbl (%edx),%edx
  801a9e:	29 d0                	sub    %edx,%eax
  801aa0:	eb 05                	jmp    801aa7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801aa7:	5b                   	pop    %ebx
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ab4:	eb 07                	jmp    801abd <strchr+0x13>
		if (*s == c)
  801ab6:	38 ca                	cmp    %cl,%dl
  801ab8:	74 0f                	je     801ac9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801aba:	83 c0 01             	add    $0x1,%eax
  801abd:	0f b6 10             	movzbl (%eax),%edx
  801ac0:	84 d2                	test   %dl,%dl
  801ac2:	75 f2                	jne    801ab6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ad5:	eb 03                	jmp    801ada <strfind+0xf>
  801ad7:	83 c0 01             	add    $0x1,%eax
  801ada:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801add:	38 ca                	cmp    %cl,%dl
  801adf:	74 04                	je     801ae5 <strfind+0x1a>
  801ae1:	84 d2                	test   %dl,%dl
  801ae3:	75 f2                	jne    801ad7 <strfind+0xc>
			break;
	return (char *) s;
}
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	57                   	push   %edi
  801aeb:	56                   	push   %esi
  801aec:	53                   	push   %ebx
  801aed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801af3:	85 c9                	test   %ecx,%ecx
  801af5:	74 36                	je     801b2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801af7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801afd:	75 28                	jne    801b27 <memset+0x40>
  801aff:	f6 c1 03             	test   $0x3,%cl
  801b02:	75 23                	jne    801b27 <memset+0x40>
		c &= 0xFF;
  801b04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b08:	89 d3                	mov    %edx,%ebx
  801b0a:	c1 e3 08             	shl    $0x8,%ebx
  801b0d:	89 d6                	mov    %edx,%esi
  801b0f:	c1 e6 18             	shl    $0x18,%esi
  801b12:	89 d0                	mov    %edx,%eax
  801b14:	c1 e0 10             	shl    $0x10,%eax
  801b17:	09 f0                	or     %esi,%eax
  801b19:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b1b:	89 d8                	mov    %ebx,%eax
  801b1d:	09 d0                	or     %edx,%eax
  801b1f:	c1 e9 02             	shr    $0x2,%ecx
  801b22:	fc                   	cld    
  801b23:	f3 ab                	rep stos %eax,%es:(%edi)
  801b25:	eb 06                	jmp    801b2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2a:	fc                   	cld    
  801b2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b2d:	89 f8                	mov    %edi,%eax
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5f                   	pop    %edi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	57                   	push   %edi
  801b38:	56                   	push   %esi
  801b39:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b42:	39 c6                	cmp    %eax,%esi
  801b44:	73 35                	jae    801b7b <memmove+0x47>
  801b46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b49:	39 d0                	cmp    %edx,%eax
  801b4b:	73 2e                	jae    801b7b <memmove+0x47>
		s += n;
		d += n;
  801b4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b50:	89 d6                	mov    %edx,%esi
  801b52:	09 fe                	or     %edi,%esi
  801b54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801b5a:	75 13                	jne    801b6f <memmove+0x3b>
  801b5c:	f6 c1 03             	test   $0x3,%cl
  801b5f:	75 0e                	jne    801b6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801b61:	83 ef 04             	sub    $0x4,%edi
  801b64:	8d 72 fc             	lea    -0x4(%edx),%esi
  801b67:	c1 e9 02             	shr    $0x2,%ecx
  801b6a:	fd                   	std    
  801b6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801b6d:	eb 09                	jmp    801b78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801b6f:	83 ef 01             	sub    $0x1,%edi
  801b72:	8d 72 ff             	lea    -0x1(%edx),%esi
  801b75:	fd                   	std    
  801b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801b78:	fc                   	cld    
  801b79:	eb 1d                	jmp    801b98 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b7b:	89 f2                	mov    %esi,%edx
  801b7d:	09 c2                	or     %eax,%edx
  801b7f:	f6 c2 03             	test   $0x3,%dl
  801b82:	75 0f                	jne    801b93 <memmove+0x5f>
  801b84:	f6 c1 03             	test   $0x3,%cl
  801b87:	75 0a                	jne    801b93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801b89:	c1 e9 02             	shr    $0x2,%ecx
  801b8c:	89 c7                	mov    %eax,%edi
  801b8e:	fc                   	cld    
  801b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801b91:	eb 05                	jmp    801b98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801b93:	89 c7                	mov    %eax,%edi
  801b95:	fc                   	cld    
  801b96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801b98:	5e                   	pop    %esi
  801b99:	5f                   	pop    %edi
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    

00801b9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801b9f:	ff 75 10             	pushl  0x10(%ebp)
  801ba2:	ff 75 0c             	pushl  0xc(%ebp)
  801ba5:	ff 75 08             	pushl  0x8(%ebp)
  801ba8:	e8 87 ff ff ff       	call   801b34 <memmove>
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bba:	89 c6                	mov    %eax,%esi
  801bbc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801bbf:	eb 1a                	jmp    801bdb <memcmp+0x2c>
		if (*s1 != *s2)
  801bc1:	0f b6 08             	movzbl (%eax),%ecx
  801bc4:	0f b6 1a             	movzbl (%edx),%ebx
  801bc7:	38 d9                	cmp    %bl,%cl
  801bc9:	74 0a                	je     801bd5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801bcb:	0f b6 c1             	movzbl %cl,%eax
  801bce:	0f b6 db             	movzbl %bl,%ebx
  801bd1:	29 d8                	sub    %ebx,%eax
  801bd3:	eb 0f                	jmp    801be4 <memcmp+0x35>
		s1++, s2++;
  801bd5:	83 c0 01             	add    $0x1,%eax
  801bd8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801bdb:	39 f0                	cmp    %esi,%eax
  801bdd:	75 e2                	jne    801bc1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	53                   	push   %ebx
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801bef:	89 c1                	mov    %eax,%ecx
  801bf1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801bf4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801bf8:	eb 0a                	jmp    801c04 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801bfa:	0f b6 10             	movzbl (%eax),%edx
  801bfd:	39 da                	cmp    %ebx,%edx
  801bff:	74 07                	je     801c08 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c01:	83 c0 01             	add    $0x1,%eax
  801c04:	39 c8                	cmp    %ecx,%eax
  801c06:	72 f2                	jb     801bfa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c08:	5b                   	pop    %ebx
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	57                   	push   %edi
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c17:	eb 03                	jmp    801c1c <strtol+0x11>
		s++;
  801c19:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c1c:	0f b6 01             	movzbl (%ecx),%eax
  801c1f:	3c 20                	cmp    $0x20,%al
  801c21:	74 f6                	je     801c19 <strtol+0xe>
  801c23:	3c 09                	cmp    $0x9,%al
  801c25:	74 f2                	je     801c19 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c27:	3c 2b                	cmp    $0x2b,%al
  801c29:	75 0a                	jne    801c35 <strtol+0x2a>
		s++;
  801c2b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c2e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c33:	eb 11                	jmp    801c46 <strtol+0x3b>
  801c35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c3a:	3c 2d                	cmp    $0x2d,%al
  801c3c:	75 08                	jne    801c46 <strtol+0x3b>
		s++, neg = 1;
  801c3e:	83 c1 01             	add    $0x1,%ecx
  801c41:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c4c:	75 15                	jne    801c63 <strtol+0x58>
  801c4e:	80 39 30             	cmpb   $0x30,(%ecx)
  801c51:	75 10                	jne    801c63 <strtol+0x58>
  801c53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801c57:	75 7c                	jne    801cd5 <strtol+0xca>
		s += 2, base = 16;
  801c59:	83 c1 02             	add    $0x2,%ecx
  801c5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801c61:	eb 16                	jmp    801c79 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801c63:	85 db                	test   %ebx,%ebx
  801c65:	75 12                	jne    801c79 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801c67:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801c6c:	80 39 30             	cmpb   $0x30,(%ecx)
  801c6f:	75 08                	jne    801c79 <strtol+0x6e>
		s++, base = 8;
  801c71:	83 c1 01             	add    $0x1,%ecx
  801c74:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801c79:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801c81:	0f b6 11             	movzbl (%ecx),%edx
  801c84:	8d 72 d0             	lea    -0x30(%edx),%esi
  801c87:	89 f3                	mov    %esi,%ebx
  801c89:	80 fb 09             	cmp    $0x9,%bl
  801c8c:	77 08                	ja     801c96 <strtol+0x8b>
			dig = *s - '0';
  801c8e:	0f be d2             	movsbl %dl,%edx
  801c91:	83 ea 30             	sub    $0x30,%edx
  801c94:	eb 22                	jmp    801cb8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801c96:	8d 72 9f             	lea    -0x61(%edx),%esi
  801c99:	89 f3                	mov    %esi,%ebx
  801c9b:	80 fb 19             	cmp    $0x19,%bl
  801c9e:	77 08                	ja     801ca8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ca0:	0f be d2             	movsbl %dl,%edx
  801ca3:	83 ea 57             	sub    $0x57,%edx
  801ca6:	eb 10                	jmp    801cb8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ca8:	8d 72 bf             	lea    -0x41(%edx),%esi
  801cab:	89 f3                	mov    %esi,%ebx
  801cad:	80 fb 19             	cmp    $0x19,%bl
  801cb0:	77 16                	ja     801cc8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801cb2:	0f be d2             	movsbl %dl,%edx
  801cb5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801cb8:	3b 55 10             	cmp    0x10(%ebp),%edx
  801cbb:	7d 0b                	jge    801cc8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801cbd:	83 c1 01             	add    $0x1,%ecx
  801cc0:	0f af 45 10          	imul   0x10(%ebp),%eax
  801cc4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801cc6:	eb b9                	jmp    801c81 <strtol+0x76>

	if (endptr)
  801cc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ccc:	74 0d                	je     801cdb <strtol+0xd0>
		*endptr = (char *) s;
  801cce:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cd1:	89 0e                	mov    %ecx,(%esi)
  801cd3:	eb 06                	jmp    801cdb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cd5:	85 db                	test   %ebx,%ebx
  801cd7:	74 98                	je     801c71 <strtol+0x66>
  801cd9:	eb 9e                	jmp    801c79 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801cdb:	89 c2                	mov    %eax,%edx
  801cdd:	f7 da                	neg    %edx
  801cdf:	85 ff                	test   %edi,%edi
  801ce1:	0f 45 c2             	cmovne %edx,%eax
}
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    

00801ce9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	57                   	push   %edi
  801ced:	56                   	push   %esi
  801cee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801cef:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	89 c7                	mov    %eax,%edi
  801cfe:	89 c6                	mov    %eax,%esi
  801d00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801d02:	5b                   	pop    %ebx
  801d03:	5e                   	pop    %esi
  801d04:	5f                   	pop    %edi
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <sys_cgetc>:

int
sys_cgetc(void)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	57                   	push   %edi
  801d0b:	56                   	push   %esi
  801d0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d12:	b8 01 00 00 00       	mov    $0x1,%eax
  801d17:	89 d1                	mov    %edx,%ecx
  801d19:	89 d3                	mov    %edx,%ebx
  801d1b:	89 d7                	mov    %edx,%edi
  801d1d:	89 d6                	mov    %edx,%esi
  801d1f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5f                   	pop    %edi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	57                   	push   %edi
  801d2a:	56                   	push   %esi
  801d2b:	53                   	push   %ebx
  801d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801d2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d34:	b8 03 00 00 00       	mov    $0x3,%eax
  801d39:	8b 55 08             	mov    0x8(%ebp),%edx
  801d3c:	89 cb                	mov    %ecx,%ebx
  801d3e:	89 cf                	mov    %ecx,%edi
  801d40:	89 ce                	mov    %ecx,%esi
  801d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801d44:	85 c0                	test   %eax,%eax
  801d46:	7e 17                	jle    801d5f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801d48:	83 ec 0c             	sub    $0xc,%esp
  801d4b:	50                   	push   %eax
  801d4c:	6a 03                	push   $0x3
  801d4e:	68 ff 38 80 00       	push   $0x8038ff
  801d53:	6a 23                	push   $0x23
  801d55:	68 1c 39 80 00       	push   $0x80391c
  801d5a:	e8 e5 f5 ff ff       	call   801344 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d62:	5b                   	pop    %ebx
  801d63:	5e                   	pop    %esi
  801d64:	5f                   	pop    %edi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	57                   	push   %edi
  801d6b:	56                   	push   %esi
  801d6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801d6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d72:	b8 02 00 00 00       	mov    $0x2,%eax
  801d77:	89 d1                	mov    %edx,%ecx
  801d79:	89 d3                	mov    %edx,%ebx
  801d7b:	89 d7                	mov    %edx,%edi
  801d7d:	89 d6                	mov    %edx,%esi
  801d7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801d81:	5b                   	pop    %ebx
  801d82:	5e                   	pop    %esi
  801d83:	5f                   	pop    %edi
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <sys_yield>:

void
sys_yield(void)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	57                   	push   %edi
  801d8a:	56                   	push   %esi
  801d8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801d8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d91:	b8 0b 00 00 00       	mov    $0xb,%eax
  801d96:	89 d1                	mov    %edx,%ecx
  801d98:	89 d3                	mov    %edx,%ebx
  801d9a:	89 d7                	mov    %edx,%edi
  801d9c:	89 d6                	mov    %edx,%esi
  801d9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	57                   	push   %edi
  801da9:	56                   	push   %esi
  801daa:	53                   	push   %ebx
  801dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801dae:	be 00 00 00 00       	mov    $0x0,%esi
  801db3:	b8 04 00 00 00       	mov    $0x4,%eax
  801db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  801dbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc1:	89 f7                	mov    %esi,%edi
  801dc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	7e 17                	jle    801de0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801dc9:	83 ec 0c             	sub    $0xc,%esp
  801dcc:	50                   	push   %eax
  801dcd:	6a 04                	push   $0x4
  801dcf:	68 ff 38 80 00       	push   $0x8038ff
  801dd4:	6a 23                	push   $0x23
  801dd6:	68 1c 39 80 00       	push   $0x80391c
  801ddb:	e8 64 f5 ff ff       	call   801344 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

00801de8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	57                   	push   %edi
  801dec:	56                   	push   %esi
  801ded:	53                   	push   %ebx
  801dee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801df1:	b8 05 00 00 00       	mov    $0x5,%eax
  801df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df9:	8b 55 08             	mov    0x8(%ebp),%edx
  801dfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dff:	8b 7d 14             	mov    0x14(%ebp),%edi
  801e02:	8b 75 18             	mov    0x18(%ebp),%esi
  801e05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801e07:	85 c0                	test   %eax,%eax
  801e09:	7e 17                	jle    801e22 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801e0b:	83 ec 0c             	sub    $0xc,%esp
  801e0e:	50                   	push   %eax
  801e0f:	6a 05                	push   $0x5
  801e11:	68 ff 38 80 00       	push   $0x8038ff
  801e16:	6a 23                	push   $0x23
  801e18:	68 1c 39 80 00       	push   $0x80391c
  801e1d:	e8 22 f5 ff ff       	call   801344 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e25:	5b                   	pop    %ebx
  801e26:	5e                   	pop    %esi
  801e27:	5f                   	pop    %edi
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    

00801e2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	57                   	push   %edi
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
  801e30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801e33:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e38:	b8 06 00 00 00       	mov    $0x6,%eax
  801e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e40:	8b 55 08             	mov    0x8(%ebp),%edx
  801e43:	89 df                	mov    %ebx,%edi
  801e45:	89 de                	mov    %ebx,%esi
  801e47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	7e 17                	jle    801e64 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	50                   	push   %eax
  801e51:	6a 06                	push   $0x6
  801e53:	68 ff 38 80 00       	push   $0x8038ff
  801e58:	6a 23                	push   $0x23
  801e5a:	68 1c 39 80 00       	push   $0x80391c
  801e5f:	e8 e0 f4 ff ff       	call   801344 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    

00801e6c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	57                   	push   %edi
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801e75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e7a:	b8 08 00 00 00       	mov    $0x8,%eax
  801e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e82:	8b 55 08             	mov    0x8(%ebp),%edx
  801e85:	89 df                	mov    %ebx,%edi
  801e87:	89 de                	mov    %ebx,%esi
  801e89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	7e 17                	jle    801ea6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	50                   	push   %eax
  801e93:	6a 08                	push   $0x8
  801e95:	68 ff 38 80 00       	push   $0x8038ff
  801e9a:	6a 23                	push   $0x23
  801e9c:	68 1c 39 80 00       	push   $0x80391c
  801ea1:	e8 9e f4 ff ff       	call   801344 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea9:	5b                   	pop    %ebx
  801eaa:	5e                   	pop    %esi
  801eab:	5f                   	pop    %edi
  801eac:	5d                   	pop    %ebp
  801ead:	c3                   	ret    

00801eae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ebc:	b8 09 00 00 00       	mov    $0x9,%eax
  801ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  801ec7:	89 df                	mov    %ebx,%edi
  801ec9:	89 de                	mov    %ebx,%esi
  801ecb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	7e 17                	jle    801ee8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801ed1:	83 ec 0c             	sub    $0xc,%esp
  801ed4:	50                   	push   %eax
  801ed5:	6a 09                	push   $0x9
  801ed7:	68 ff 38 80 00       	push   $0x8038ff
  801edc:	6a 23                	push   $0x23
  801ede:	68 1c 39 80 00       	push   $0x80391c
  801ee3:	e8 5c f4 ff ff       	call   801344 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801ee8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eeb:	5b                   	pop    %ebx
  801eec:	5e                   	pop    %esi
  801eed:	5f                   	pop    %edi
  801eee:	5d                   	pop    %ebp
  801eef:	c3                   	ret    

00801ef0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	57                   	push   %edi
  801ef4:	56                   	push   %esi
  801ef5:	53                   	push   %ebx
  801ef6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801efe:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f06:	8b 55 08             	mov    0x8(%ebp),%edx
  801f09:	89 df                	mov    %ebx,%edi
  801f0b:	89 de                	mov    %ebx,%esi
  801f0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	7e 17                	jle    801f2a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801f13:	83 ec 0c             	sub    $0xc,%esp
  801f16:	50                   	push   %eax
  801f17:	6a 0a                	push   $0xa
  801f19:	68 ff 38 80 00       	push   $0x8038ff
  801f1e:	6a 23                	push   $0x23
  801f20:	68 1c 39 80 00       	push   $0x80391c
  801f25:	e8 1a f4 ff ff       	call   801344 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5f                   	pop    %edi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	57                   	push   %edi
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801f38:	be 00 00 00 00       	mov    $0x0,%esi
  801f3d:	b8 0c 00 00 00       	mov    $0xc,%eax
  801f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f45:	8b 55 08             	mov    0x8(%ebp),%edx
  801f48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  801f4e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801f50:	5b                   	pop    %ebx
  801f51:	5e                   	pop    %esi
  801f52:	5f                   	pop    %edi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	57                   	push   %edi
  801f59:	56                   	push   %esi
  801f5a:	53                   	push   %ebx
  801f5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801f5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f63:	b8 0d 00 00 00       	mov    $0xd,%eax
  801f68:	8b 55 08             	mov    0x8(%ebp),%edx
  801f6b:	89 cb                	mov    %ecx,%ebx
  801f6d:	89 cf                	mov    %ecx,%edi
  801f6f:	89 ce                	mov    %ecx,%esi
  801f71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801f73:	85 c0                	test   %eax,%eax
  801f75:	7e 17                	jle    801f8e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	50                   	push   %eax
  801f7b:	6a 0d                	push   $0xd
  801f7d:	68 ff 38 80 00       	push   $0x8038ff
  801f82:	6a 23                	push   $0x23
  801f84:	68 1c 39 80 00       	push   $0x80391c
  801f89:	e8 b6 f3 ff ff       	call   801344 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801f8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	5f                   	pop    %edi
  801f94:	5d                   	pop    %ebp
  801f95:	c3                   	ret    

00801f96 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f9c:	83 3d 10 90 80 00 00 	cmpl   $0x0,0x809010
  801fa3:	75 2e                	jne    801fd3 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801fa5:	e8 bd fd ff ff       	call   801d67 <sys_getenvid>
  801faa:	83 ec 04             	sub    $0x4,%esp
  801fad:	68 07 0e 00 00       	push   $0xe07
  801fb2:	68 00 f0 bf ee       	push   $0xeebff000
  801fb7:	50                   	push   %eax
  801fb8:	e8 e8 fd ff ff       	call   801da5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801fbd:	e8 a5 fd ff ff       	call   801d67 <sys_getenvid>
  801fc2:	83 c4 08             	add    $0x8,%esp
  801fc5:	68 dd 1f 80 00       	push   $0x801fdd
  801fca:	50                   	push   %eax
  801fcb:	e8 20 ff ff ff       	call   801ef0 <sys_env_set_pgfault_upcall>
  801fd0:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd6:	a3 10 90 80 00       	mov    %eax,0x809010
}
  801fdb:	c9                   	leave  
  801fdc:	c3                   	ret    

00801fdd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fdd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fde:	a1 10 90 80 00       	mov    0x809010,%eax
	call *%eax
  801fe3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fe5:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801fe8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801fec:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801ff0:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801ff3:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801ff6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801ff7:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801ffa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801ffb:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801ffc:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802000:	c3                   	ret    

00802001 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	56                   	push   %esi
  802005:	53                   	push   %ebx
  802006:	8b 75 08             	mov    0x8(%ebp),%esi
  802009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80200f:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802011:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802016:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802019:	83 ec 0c             	sub    $0xc,%esp
  80201c:	50                   	push   %eax
  80201d:	e8 33 ff ff ff       	call   801f55 <sys_ipc_recv>

	if (from_env_store != NULL)
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	85 f6                	test   %esi,%esi
  802027:	74 14                	je     80203d <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802029:	ba 00 00 00 00       	mov    $0x0,%edx
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 09                	js     80203b <ipc_recv+0x3a>
  802032:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  802038:	8b 52 74             	mov    0x74(%edx),%edx
  80203b:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80203d:	85 db                	test   %ebx,%ebx
  80203f:	74 14                	je     802055 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802041:	ba 00 00 00 00       	mov    $0x0,%edx
  802046:	85 c0                	test   %eax,%eax
  802048:	78 09                	js     802053 <ipc_recv+0x52>
  80204a:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  802050:	8b 52 78             	mov    0x78(%edx),%edx
  802053:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802055:	85 c0                	test   %eax,%eax
  802057:	78 08                	js     802061 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802059:	a1 0c 90 80 00       	mov    0x80900c,%eax
  80205e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802061:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802064:	5b                   	pop    %ebx
  802065:	5e                   	pop    %esi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    

00802068 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	57                   	push   %edi
  80206c:	56                   	push   %esi
  80206d:	53                   	push   %ebx
  80206e:	83 ec 0c             	sub    $0xc,%esp
  802071:	8b 7d 08             	mov    0x8(%ebp),%edi
  802074:	8b 75 0c             	mov    0xc(%ebp),%esi
  802077:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80207a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80207c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802081:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802084:	ff 75 14             	pushl  0x14(%ebp)
  802087:	53                   	push   %ebx
  802088:	56                   	push   %esi
  802089:	57                   	push   %edi
  80208a:	e8 a3 fe ff ff       	call   801f32 <sys_ipc_try_send>

		if (err < 0) {
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	85 c0                	test   %eax,%eax
  802094:	79 1e                	jns    8020b4 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802096:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802099:	75 07                	jne    8020a2 <ipc_send+0x3a>
				sys_yield();
  80209b:	e8 e6 fc ff ff       	call   801d86 <sys_yield>
  8020a0:	eb e2                	jmp    802084 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8020a2:	50                   	push   %eax
  8020a3:	68 2a 39 80 00       	push   $0x80392a
  8020a8:	6a 49                	push   $0x49
  8020aa:	68 37 39 80 00       	push   $0x803937
  8020af:	e8 90 f2 ff ff       	call   801344 <_panic>
		}

	} while (err < 0);

}
  8020b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    

008020bc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020c7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020d0:	8b 52 50             	mov    0x50(%edx),%edx
  8020d3:	39 ca                	cmp    %ecx,%edx
  8020d5:	75 0d                	jne    8020e4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020df:	8b 40 48             	mov    0x48(%eax),%eax
  8020e2:	eb 0f                	jmp    8020f3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020e4:	83 c0 01             	add    $0x1,%eax
  8020e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020ec:	75 d9                	jne    8020c7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    

008020f5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8020f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fb:	05 00 00 00 30       	add    $0x30000000,%eax
  802100:	c1 e8 0c             	shr    $0xc,%eax
}
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
  80210b:	05 00 00 00 30       	add    $0x30000000,%eax
  802110:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802115:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

0080211c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802122:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802127:	89 c2                	mov    %eax,%edx
  802129:	c1 ea 16             	shr    $0x16,%edx
  80212c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802133:	f6 c2 01             	test   $0x1,%dl
  802136:	74 11                	je     802149 <fd_alloc+0x2d>
  802138:	89 c2                	mov    %eax,%edx
  80213a:	c1 ea 0c             	shr    $0xc,%edx
  80213d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802144:	f6 c2 01             	test   $0x1,%dl
  802147:	75 09                	jne    802152 <fd_alloc+0x36>
			*fd_store = fd;
  802149:	89 01                	mov    %eax,(%ecx)
			return 0;
  80214b:	b8 00 00 00 00       	mov    $0x0,%eax
  802150:	eb 17                	jmp    802169 <fd_alloc+0x4d>
  802152:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802157:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80215c:	75 c9                	jne    802127 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80215e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802164:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    

0080216b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802171:	83 f8 1f             	cmp    $0x1f,%eax
  802174:	77 36                	ja     8021ac <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802176:	c1 e0 0c             	shl    $0xc,%eax
  802179:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80217e:	89 c2                	mov    %eax,%edx
  802180:	c1 ea 16             	shr    $0x16,%edx
  802183:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80218a:	f6 c2 01             	test   $0x1,%dl
  80218d:	74 24                	je     8021b3 <fd_lookup+0x48>
  80218f:	89 c2                	mov    %eax,%edx
  802191:	c1 ea 0c             	shr    $0xc,%edx
  802194:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80219b:	f6 c2 01             	test   $0x1,%dl
  80219e:	74 1a                	je     8021ba <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8021a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021a3:	89 02                	mov    %eax,(%edx)
	return 0;
  8021a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021aa:	eb 13                	jmp    8021bf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8021ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021b1:	eb 0c                	jmp    8021bf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8021b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021b8:	eb 05                	jmp    8021bf <fd_lookup+0x54>
  8021ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    

008021c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	83 ec 08             	sub    $0x8,%esp
  8021c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ca:	ba c4 39 80 00       	mov    $0x8039c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8021cf:	eb 13                	jmp    8021e4 <dev_lookup+0x23>
  8021d1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8021d4:	39 08                	cmp    %ecx,(%eax)
  8021d6:	75 0c                	jne    8021e4 <dev_lookup+0x23>
			*dev = devtab[i];
  8021d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021db:	89 01                	mov    %eax,(%ecx)
			return 0;
  8021dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e2:	eb 2e                	jmp    802212 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8021e4:	8b 02                	mov    (%edx),%eax
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	75 e7                	jne    8021d1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8021ea:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8021ef:	8b 40 48             	mov    0x48(%eax),%eax
  8021f2:	83 ec 04             	sub    $0x4,%esp
  8021f5:	51                   	push   %ecx
  8021f6:	50                   	push   %eax
  8021f7:	68 44 39 80 00       	push   $0x803944
  8021fc:	e8 1c f2 ff ff       	call   80141d <cprintf>
	*dev = 0;
  802201:	8b 45 0c             	mov    0xc(%ebp),%eax
  802204:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80220a:	83 c4 10             	add    $0x10,%esp
  80220d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802212:	c9                   	leave  
  802213:	c3                   	ret    

00802214 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	56                   	push   %esi
  802218:	53                   	push   %ebx
  802219:	83 ec 10             	sub    $0x10,%esp
  80221c:	8b 75 08             	mov    0x8(%ebp),%esi
  80221f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802222:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802225:	50                   	push   %eax
  802226:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80222c:	c1 e8 0c             	shr    $0xc,%eax
  80222f:	50                   	push   %eax
  802230:	e8 36 ff ff ff       	call   80216b <fd_lookup>
  802235:	83 c4 08             	add    $0x8,%esp
  802238:	85 c0                	test   %eax,%eax
  80223a:	78 05                	js     802241 <fd_close+0x2d>
	    || fd != fd2)
  80223c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80223f:	74 0c                	je     80224d <fd_close+0x39>
		return (must_exist ? r : 0);
  802241:	84 db                	test   %bl,%bl
  802243:	ba 00 00 00 00       	mov    $0x0,%edx
  802248:	0f 44 c2             	cmove  %edx,%eax
  80224b:	eb 41                	jmp    80228e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80224d:	83 ec 08             	sub    $0x8,%esp
  802250:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802253:	50                   	push   %eax
  802254:	ff 36                	pushl  (%esi)
  802256:	e8 66 ff ff ff       	call   8021c1 <dev_lookup>
  80225b:	89 c3                	mov    %eax,%ebx
  80225d:	83 c4 10             	add    $0x10,%esp
  802260:	85 c0                	test   %eax,%eax
  802262:	78 1a                	js     80227e <fd_close+0x6a>
		if (dev->dev_close)
  802264:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802267:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80226a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80226f:	85 c0                	test   %eax,%eax
  802271:	74 0b                	je     80227e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802273:	83 ec 0c             	sub    $0xc,%esp
  802276:	56                   	push   %esi
  802277:	ff d0                	call   *%eax
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80227e:	83 ec 08             	sub    $0x8,%esp
  802281:	56                   	push   %esi
  802282:	6a 00                	push   $0x0
  802284:	e8 a1 fb ff ff       	call   801e2a <sys_page_unmap>
	return r;
  802289:	83 c4 10             	add    $0x10,%esp
  80228c:	89 d8                	mov    %ebx,%eax
}
  80228e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802291:	5b                   	pop    %ebx
  802292:	5e                   	pop    %esi
  802293:	5d                   	pop    %ebp
  802294:	c3                   	ret    

00802295 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802295:	55                   	push   %ebp
  802296:	89 e5                	mov    %esp,%ebp
  802298:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80229b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229e:	50                   	push   %eax
  80229f:	ff 75 08             	pushl  0x8(%ebp)
  8022a2:	e8 c4 fe ff ff       	call   80216b <fd_lookup>
  8022a7:	83 c4 08             	add    $0x8,%esp
  8022aa:	85 c0                	test   %eax,%eax
  8022ac:	78 10                	js     8022be <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8022ae:	83 ec 08             	sub    $0x8,%esp
  8022b1:	6a 01                	push   $0x1
  8022b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8022b6:	e8 59 ff ff ff       	call   802214 <fd_close>
  8022bb:	83 c4 10             	add    $0x10,%esp
}
  8022be:	c9                   	leave  
  8022bf:	c3                   	ret    

008022c0 <close_all>:

void
close_all(void)
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	53                   	push   %ebx
  8022c4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8022c7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8022cc:	83 ec 0c             	sub    $0xc,%esp
  8022cf:	53                   	push   %ebx
  8022d0:	e8 c0 ff ff ff       	call   802295 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8022d5:	83 c3 01             	add    $0x1,%ebx
  8022d8:	83 c4 10             	add    $0x10,%esp
  8022db:	83 fb 20             	cmp    $0x20,%ebx
  8022de:	75 ec                	jne    8022cc <close_all+0xc>
		close(i);
}
  8022e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022e3:	c9                   	leave  
  8022e4:	c3                   	ret    

008022e5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8022e5:	55                   	push   %ebp
  8022e6:	89 e5                	mov    %esp,%ebp
  8022e8:	57                   	push   %edi
  8022e9:	56                   	push   %esi
  8022ea:	53                   	push   %ebx
  8022eb:	83 ec 2c             	sub    $0x2c,%esp
  8022ee:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8022f1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8022f4:	50                   	push   %eax
  8022f5:	ff 75 08             	pushl  0x8(%ebp)
  8022f8:	e8 6e fe ff ff       	call   80216b <fd_lookup>
  8022fd:	83 c4 08             	add    $0x8,%esp
  802300:	85 c0                	test   %eax,%eax
  802302:	0f 88 c1 00 00 00    	js     8023c9 <dup+0xe4>
		return r;
	close(newfdnum);
  802308:	83 ec 0c             	sub    $0xc,%esp
  80230b:	56                   	push   %esi
  80230c:	e8 84 ff ff ff       	call   802295 <close>

	newfd = INDEX2FD(newfdnum);
  802311:	89 f3                	mov    %esi,%ebx
  802313:	c1 e3 0c             	shl    $0xc,%ebx
  802316:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80231c:	83 c4 04             	add    $0x4,%esp
  80231f:	ff 75 e4             	pushl  -0x1c(%ebp)
  802322:	e8 de fd ff ff       	call   802105 <fd2data>
  802327:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802329:	89 1c 24             	mov    %ebx,(%esp)
  80232c:	e8 d4 fd ff ff       	call   802105 <fd2data>
  802331:	83 c4 10             	add    $0x10,%esp
  802334:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802337:	89 f8                	mov    %edi,%eax
  802339:	c1 e8 16             	shr    $0x16,%eax
  80233c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802343:	a8 01                	test   $0x1,%al
  802345:	74 37                	je     80237e <dup+0x99>
  802347:	89 f8                	mov    %edi,%eax
  802349:	c1 e8 0c             	shr    $0xc,%eax
  80234c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802353:	f6 c2 01             	test   $0x1,%dl
  802356:	74 26                	je     80237e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802358:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80235f:	83 ec 0c             	sub    $0xc,%esp
  802362:	25 07 0e 00 00       	and    $0xe07,%eax
  802367:	50                   	push   %eax
  802368:	ff 75 d4             	pushl  -0x2c(%ebp)
  80236b:	6a 00                	push   $0x0
  80236d:	57                   	push   %edi
  80236e:	6a 00                	push   $0x0
  802370:	e8 73 fa ff ff       	call   801de8 <sys_page_map>
  802375:	89 c7                	mov    %eax,%edi
  802377:	83 c4 20             	add    $0x20,%esp
  80237a:	85 c0                	test   %eax,%eax
  80237c:	78 2e                	js     8023ac <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80237e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802381:	89 d0                	mov    %edx,%eax
  802383:	c1 e8 0c             	shr    $0xc,%eax
  802386:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80238d:	83 ec 0c             	sub    $0xc,%esp
  802390:	25 07 0e 00 00       	and    $0xe07,%eax
  802395:	50                   	push   %eax
  802396:	53                   	push   %ebx
  802397:	6a 00                	push   $0x0
  802399:	52                   	push   %edx
  80239a:	6a 00                	push   $0x0
  80239c:	e8 47 fa ff ff       	call   801de8 <sys_page_map>
  8023a1:	89 c7                	mov    %eax,%edi
  8023a3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8023a6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8023a8:	85 ff                	test   %edi,%edi
  8023aa:	79 1d                	jns    8023c9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8023ac:	83 ec 08             	sub    $0x8,%esp
  8023af:	53                   	push   %ebx
  8023b0:	6a 00                	push   $0x0
  8023b2:	e8 73 fa ff ff       	call   801e2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8023b7:	83 c4 08             	add    $0x8,%esp
  8023ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8023bd:	6a 00                	push   $0x0
  8023bf:	e8 66 fa ff ff       	call   801e2a <sys_page_unmap>
	return r;
  8023c4:	83 c4 10             	add    $0x10,%esp
  8023c7:	89 f8                	mov    %edi,%eax
}
  8023c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023cc:	5b                   	pop    %ebx
  8023cd:	5e                   	pop    %esi
  8023ce:	5f                   	pop    %edi
  8023cf:	5d                   	pop    %ebp
  8023d0:	c3                   	ret    

008023d1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8023d1:	55                   	push   %ebp
  8023d2:	89 e5                	mov    %esp,%ebp
  8023d4:	53                   	push   %ebx
  8023d5:	83 ec 14             	sub    $0x14,%esp
  8023d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8023db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023de:	50                   	push   %eax
  8023df:	53                   	push   %ebx
  8023e0:	e8 86 fd ff ff       	call   80216b <fd_lookup>
  8023e5:	83 c4 08             	add    $0x8,%esp
  8023e8:	89 c2                	mov    %eax,%edx
  8023ea:	85 c0                	test   %eax,%eax
  8023ec:	78 6d                	js     80245b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8023ee:	83 ec 08             	sub    $0x8,%esp
  8023f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f4:	50                   	push   %eax
  8023f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023f8:	ff 30                	pushl  (%eax)
  8023fa:	e8 c2 fd ff ff       	call   8021c1 <dev_lookup>
  8023ff:	83 c4 10             	add    $0x10,%esp
  802402:	85 c0                	test   %eax,%eax
  802404:	78 4c                	js     802452 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802406:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802409:	8b 42 08             	mov    0x8(%edx),%eax
  80240c:	83 e0 03             	and    $0x3,%eax
  80240f:	83 f8 01             	cmp    $0x1,%eax
  802412:	75 21                	jne    802435 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802414:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802419:	8b 40 48             	mov    0x48(%eax),%eax
  80241c:	83 ec 04             	sub    $0x4,%esp
  80241f:	53                   	push   %ebx
  802420:	50                   	push   %eax
  802421:	68 88 39 80 00       	push   $0x803988
  802426:	e8 f2 ef ff ff       	call   80141d <cprintf>
		return -E_INVAL;
  80242b:	83 c4 10             	add    $0x10,%esp
  80242e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802433:	eb 26                	jmp    80245b <read+0x8a>
	}
	if (!dev->dev_read)
  802435:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802438:	8b 40 08             	mov    0x8(%eax),%eax
  80243b:	85 c0                	test   %eax,%eax
  80243d:	74 17                	je     802456 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80243f:	83 ec 04             	sub    $0x4,%esp
  802442:	ff 75 10             	pushl  0x10(%ebp)
  802445:	ff 75 0c             	pushl  0xc(%ebp)
  802448:	52                   	push   %edx
  802449:	ff d0                	call   *%eax
  80244b:	89 c2                	mov    %eax,%edx
  80244d:	83 c4 10             	add    $0x10,%esp
  802450:	eb 09                	jmp    80245b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802452:	89 c2                	mov    %eax,%edx
  802454:	eb 05                	jmp    80245b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802456:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80245b:	89 d0                	mov    %edx,%eax
  80245d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802460:	c9                   	leave  
  802461:	c3                   	ret    

00802462 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802462:	55                   	push   %ebp
  802463:	89 e5                	mov    %esp,%ebp
  802465:	57                   	push   %edi
  802466:	56                   	push   %esi
  802467:	53                   	push   %ebx
  802468:	83 ec 0c             	sub    $0xc,%esp
  80246b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80246e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802471:	bb 00 00 00 00       	mov    $0x0,%ebx
  802476:	eb 21                	jmp    802499 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802478:	83 ec 04             	sub    $0x4,%esp
  80247b:	89 f0                	mov    %esi,%eax
  80247d:	29 d8                	sub    %ebx,%eax
  80247f:	50                   	push   %eax
  802480:	89 d8                	mov    %ebx,%eax
  802482:	03 45 0c             	add    0xc(%ebp),%eax
  802485:	50                   	push   %eax
  802486:	57                   	push   %edi
  802487:	e8 45 ff ff ff       	call   8023d1 <read>
		if (m < 0)
  80248c:	83 c4 10             	add    $0x10,%esp
  80248f:	85 c0                	test   %eax,%eax
  802491:	78 10                	js     8024a3 <readn+0x41>
			return m;
		if (m == 0)
  802493:	85 c0                	test   %eax,%eax
  802495:	74 0a                	je     8024a1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802497:	01 c3                	add    %eax,%ebx
  802499:	39 f3                	cmp    %esi,%ebx
  80249b:	72 db                	jb     802478 <readn+0x16>
  80249d:	89 d8                	mov    %ebx,%eax
  80249f:	eb 02                	jmp    8024a3 <readn+0x41>
  8024a1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8024a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a6:	5b                   	pop    %ebx
  8024a7:	5e                   	pop    %esi
  8024a8:	5f                   	pop    %edi
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    

008024ab <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	53                   	push   %ebx
  8024af:	83 ec 14             	sub    $0x14,%esp
  8024b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8024b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8024b8:	50                   	push   %eax
  8024b9:	53                   	push   %ebx
  8024ba:	e8 ac fc ff ff       	call   80216b <fd_lookup>
  8024bf:	83 c4 08             	add    $0x8,%esp
  8024c2:	89 c2                	mov    %eax,%edx
  8024c4:	85 c0                	test   %eax,%eax
  8024c6:	78 68                	js     802530 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8024c8:	83 ec 08             	sub    $0x8,%esp
  8024cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ce:	50                   	push   %eax
  8024cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024d2:	ff 30                	pushl  (%eax)
  8024d4:	e8 e8 fc ff ff       	call   8021c1 <dev_lookup>
  8024d9:	83 c4 10             	add    $0x10,%esp
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	78 47                	js     802527 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8024e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8024e7:	75 21                	jne    80250a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8024e9:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8024ee:	8b 40 48             	mov    0x48(%eax),%eax
  8024f1:	83 ec 04             	sub    $0x4,%esp
  8024f4:	53                   	push   %ebx
  8024f5:	50                   	push   %eax
  8024f6:	68 a4 39 80 00       	push   $0x8039a4
  8024fb:	e8 1d ef ff ff       	call   80141d <cprintf>
		return -E_INVAL;
  802500:	83 c4 10             	add    $0x10,%esp
  802503:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802508:	eb 26                	jmp    802530 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80250a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80250d:	8b 52 0c             	mov    0xc(%edx),%edx
  802510:	85 d2                	test   %edx,%edx
  802512:	74 17                	je     80252b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802514:	83 ec 04             	sub    $0x4,%esp
  802517:	ff 75 10             	pushl  0x10(%ebp)
  80251a:	ff 75 0c             	pushl  0xc(%ebp)
  80251d:	50                   	push   %eax
  80251e:	ff d2                	call   *%edx
  802520:	89 c2                	mov    %eax,%edx
  802522:	83 c4 10             	add    $0x10,%esp
  802525:	eb 09                	jmp    802530 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802527:	89 c2                	mov    %eax,%edx
  802529:	eb 05                	jmp    802530 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80252b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802530:	89 d0                	mov    %edx,%eax
  802532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802535:	c9                   	leave  
  802536:	c3                   	ret    

00802537 <seek>:

int
seek(int fdnum, off_t offset)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80253d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802540:	50                   	push   %eax
  802541:	ff 75 08             	pushl  0x8(%ebp)
  802544:	e8 22 fc ff ff       	call   80216b <fd_lookup>
  802549:	83 c4 08             	add    $0x8,%esp
  80254c:	85 c0                	test   %eax,%eax
  80254e:	78 0e                	js     80255e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802550:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802553:	8b 55 0c             	mov    0xc(%ebp),%edx
  802556:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802559:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80255e:	c9                   	leave  
  80255f:	c3                   	ret    

00802560 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
  802563:	53                   	push   %ebx
  802564:	83 ec 14             	sub    $0x14,%esp
  802567:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80256a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80256d:	50                   	push   %eax
  80256e:	53                   	push   %ebx
  80256f:	e8 f7 fb ff ff       	call   80216b <fd_lookup>
  802574:	83 c4 08             	add    $0x8,%esp
  802577:	89 c2                	mov    %eax,%edx
  802579:	85 c0                	test   %eax,%eax
  80257b:	78 65                	js     8025e2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80257d:	83 ec 08             	sub    $0x8,%esp
  802580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802583:	50                   	push   %eax
  802584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802587:	ff 30                	pushl  (%eax)
  802589:	e8 33 fc ff ff       	call   8021c1 <dev_lookup>
  80258e:	83 c4 10             	add    $0x10,%esp
  802591:	85 c0                	test   %eax,%eax
  802593:	78 44                	js     8025d9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802595:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802598:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80259c:	75 21                	jne    8025bf <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80259e:	a1 0c 90 80 00       	mov    0x80900c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8025a3:	8b 40 48             	mov    0x48(%eax),%eax
  8025a6:	83 ec 04             	sub    $0x4,%esp
  8025a9:	53                   	push   %ebx
  8025aa:	50                   	push   %eax
  8025ab:	68 64 39 80 00       	push   $0x803964
  8025b0:	e8 68 ee ff ff       	call   80141d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8025b5:	83 c4 10             	add    $0x10,%esp
  8025b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8025bd:	eb 23                	jmp    8025e2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8025bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025c2:	8b 52 18             	mov    0x18(%edx),%edx
  8025c5:	85 d2                	test   %edx,%edx
  8025c7:	74 14                	je     8025dd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8025c9:	83 ec 08             	sub    $0x8,%esp
  8025cc:	ff 75 0c             	pushl  0xc(%ebp)
  8025cf:	50                   	push   %eax
  8025d0:	ff d2                	call   *%edx
  8025d2:	89 c2                	mov    %eax,%edx
  8025d4:	83 c4 10             	add    $0x10,%esp
  8025d7:	eb 09                	jmp    8025e2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8025d9:	89 c2                	mov    %eax,%edx
  8025db:	eb 05                	jmp    8025e2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8025dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8025e2:	89 d0                	mov    %edx,%eax
  8025e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025e7:	c9                   	leave  
  8025e8:	c3                   	ret    

008025e9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8025e9:	55                   	push   %ebp
  8025ea:	89 e5                	mov    %esp,%ebp
  8025ec:	53                   	push   %ebx
  8025ed:	83 ec 14             	sub    $0x14,%esp
  8025f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8025f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8025f6:	50                   	push   %eax
  8025f7:	ff 75 08             	pushl  0x8(%ebp)
  8025fa:	e8 6c fb ff ff       	call   80216b <fd_lookup>
  8025ff:	83 c4 08             	add    $0x8,%esp
  802602:	89 c2                	mov    %eax,%edx
  802604:	85 c0                	test   %eax,%eax
  802606:	78 58                	js     802660 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802608:	83 ec 08             	sub    $0x8,%esp
  80260b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80260e:	50                   	push   %eax
  80260f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802612:	ff 30                	pushl  (%eax)
  802614:	e8 a8 fb ff ff       	call   8021c1 <dev_lookup>
  802619:	83 c4 10             	add    $0x10,%esp
  80261c:	85 c0                	test   %eax,%eax
  80261e:	78 37                	js     802657 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802620:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802623:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802627:	74 32                	je     80265b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802629:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80262c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802633:	00 00 00 
	stat->st_isdir = 0;
  802636:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80263d:	00 00 00 
	stat->st_dev = dev;
  802640:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802646:	83 ec 08             	sub    $0x8,%esp
  802649:	53                   	push   %ebx
  80264a:	ff 75 f0             	pushl  -0x10(%ebp)
  80264d:	ff 50 14             	call   *0x14(%eax)
  802650:	89 c2                	mov    %eax,%edx
  802652:	83 c4 10             	add    $0x10,%esp
  802655:	eb 09                	jmp    802660 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802657:	89 c2                	mov    %eax,%edx
  802659:	eb 05                	jmp    802660 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80265b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802660:	89 d0                	mov    %edx,%eax
  802662:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802665:	c9                   	leave  
  802666:	c3                   	ret    

00802667 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802667:	55                   	push   %ebp
  802668:	89 e5                	mov    %esp,%ebp
  80266a:	56                   	push   %esi
  80266b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80266c:	83 ec 08             	sub    $0x8,%esp
  80266f:	6a 00                	push   $0x0
  802671:	ff 75 08             	pushl  0x8(%ebp)
  802674:	e8 b7 01 00 00       	call   802830 <open>
  802679:	89 c3                	mov    %eax,%ebx
  80267b:	83 c4 10             	add    $0x10,%esp
  80267e:	85 c0                	test   %eax,%eax
  802680:	78 1b                	js     80269d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802682:	83 ec 08             	sub    $0x8,%esp
  802685:	ff 75 0c             	pushl  0xc(%ebp)
  802688:	50                   	push   %eax
  802689:	e8 5b ff ff ff       	call   8025e9 <fstat>
  80268e:	89 c6                	mov    %eax,%esi
	close(fd);
  802690:	89 1c 24             	mov    %ebx,(%esp)
  802693:	e8 fd fb ff ff       	call   802295 <close>
	return r;
  802698:	83 c4 10             	add    $0x10,%esp
  80269b:	89 f0                	mov    %esi,%eax
}
  80269d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026a0:	5b                   	pop    %ebx
  8026a1:	5e                   	pop    %esi
  8026a2:	5d                   	pop    %ebp
  8026a3:	c3                   	ret    

008026a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8026a4:	55                   	push   %ebp
  8026a5:	89 e5                	mov    %esp,%ebp
  8026a7:	56                   	push   %esi
  8026a8:	53                   	push   %ebx
  8026a9:	89 c6                	mov    %eax,%esi
  8026ab:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8026ad:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  8026b4:	75 12                	jne    8026c8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8026b6:	83 ec 0c             	sub    $0xc,%esp
  8026b9:	6a 01                	push   $0x1
  8026bb:	e8 fc f9 ff ff       	call   8020bc <ipc_find_env>
  8026c0:	a3 00 90 80 00       	mov    %eax,0x809000
  8026c5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8026c8:	6a 07                	push   $0x7
  8026ca:	68 00 a0 80 00       	push   $0x80a000
  8026cf:	56                   	push   %esi
  8026d0:	ff 35 00 90 80 00    	pushl  0x809000
  8026d6:	e8 8d f9 ff ff       	call   802068 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8026db:	83 c4 0c             	add    $0xc,%esp
  8026de:	6a 00                	push   $0x0
  8026e0:	53                   	push   %ebx
  8026e1:	6a 00                	push   $0x0
  8026e3:	e8 19 f9 ff ff       	call   802001 <ipc_recv>
}
  8026e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026eb:	5b                   	pop    %ebx
  8026ec:	5e                   	pop    %esi
  8026ed:	5d                   	pop    %ebp
  8026ee:	c3                   	ret    

008026ef <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8026ef:	55                   	push   %ebp
  8026f0:	89 e5                	mov    %esp,%ebp
  8026f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8026f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8026fb:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.set_size.req_size = newsize;
  802700:	8b 45 0c             	mov    0xc(%ebp),%eax
  802703:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802708:	ba 00 00 00 00       	mov    $0x0,%edx
  80270d:	b8 02 00 00 00       	mov    $0x2,%eax
  802712:	e8 8d ff ff ff       	call   8026a4 <fsipc>
}
  802717:	c9                   	leave  
  802718:	c3                   	ret    

00802719 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802719:	55                   	push   %ebp
  80271a:	89 e5                	mov    %esp,%ebp
  80271c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80271f:	8b 45 08             	mov    0x8(%ebp),%eax
  802722:	8b 40 0c             	mov    0xc(%eax),%eax
  802725:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return fsipc(FSREQ_FLUSH, NULL);
  80272a:	ba 00 00 00 00       	mov    $0x0,%edx
  80272f:	b8 06 00 00 00       	mov    $0x6,%eax
  802734:	e8 6b ff ff ff       	call   8026a4 <fsipc>
}
  802739:	c9                   	leave  
  80273a:	c3                   	ret    

0080273b <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80273b:	55                   	push   %ebp
  80273c:	89 e5                	mov    %esp,%ebp
  80273e:	53                   	push   %ebx
  80273f:	83 ec 04             	sub    $0x4,%esp
  802742:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802745:	8b 45 08             	mov    0x8(%ebp),%eax
  802748:	8b 40 0c             	mov    0xc(%eax),%eax
  80274b:	a3 00 a0 80 00       	mov    %eax,0x80a000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802750:	ba 00 00 00 00       	mov    $0x0,%edx
  802755:	b8 05 00 00 00       	mov    $0x5,%eax
  80275a:	e8 45 ff ff ff       	call   8026a4 <fsipc>
  80275f:	85 c0                	test   %eax,%eax
  802761:	78 2c                	js     80278f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802763:	83 ec 08             	sub    $0x8,%esp
  802766:	68 00 a0 80 00       	push   $0x80a000
  80276b:	53                   	push   %ebx
  80276c:	e8 31 f2 ff ff       	call   8019a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802771:	a1 80 a0 80 00       	mov    0x80a080,%eax
  802776:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80277c:	a1 84 a0 80 00       	mov    0x80a084,%eax
  802781:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802787:	83 c4 10             	add    $0x10,%esp
  80278a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80278f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802792:	c9                   	leave  
  802793:	c3                   	ret    

00802794 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802794:	55                   	push   %ebp
  802795:	89 e5                	mov    %esp,%ebp
  802797:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80279a:	68 d4 39 80 00       	push   $0x8039d4
  80279f:	68 90 00 00 00       	push   $0x90
  8027a4:	68 f2 39 80 00       	push   $0x8039f2
  8027a9:	e8 96 eb ff ff       	call   801344 <_panic>

008027ae <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8027ae:	55                   	push   %ebp
  8027af:	89 e5                	mov    %esp,%ebp
  8027b1:	56                   	push   %esi
  8027b2:	53                   	push   %ebx
  8027b3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8027b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8027bc:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.read.req_n = n;
  8027c1:	89 35 04 a0 80 00    	mov    %esi,0x80a004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8027c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8027cc:	b8 03 00 00 00       	mov    $0x3,%eax
  8027d1:	e8 ce fe ff ff       	call   8026a4 <fsipc>
  8027d6:	89 c3                	mov    %eax,%ebx
  8027d8:	85 c0                	test   %eax,%eax
  8027da:	78 4b                	js     802827 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8027dc:	39 c6                	cmp    %eax,%esi
  8027de:	73 16                	jae    8027f6 <devfile_read+0x48>
  8027e0:	68 fd 39 80 00       	push   $0x8039fd
  8027e5:	68 bd 30 80 00       	push   $0x8030bd
  8027ea:	6a 7c                	push   $0x7c
  8027ec:	68 f2 39 80 00       	push   $0x8039f2
  8027f1:	e8 4e eb ff ff       	call   801344 <_panic>
	assert(r <= PGSIZE);
  8027f6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8027fb:	7e 16                	jle    802813 <devfile_read+0x65>
  8027fd:	68 04 3a 80 00       	push   $0x803a04
  802802:	68 bd 30 80 00       	push   $0x8030bd
  802807:	6a 7d                	push   $0x7d
  802809:	68 f2 39 80 00       	push   $0x8039f2
  80280e:	e8 31 eb ff ff       	call   801344 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802813:	83 ec 04             	sub    $0x4,%esp
  802816:	50                   	push   %eax
  802817:	68 00 a0 80 00       	push   $0x80a000
  80281c:	ff 75 0c             	pushl  0xc(%ebp)
  80281f:	e8 10 f3 ff ff       	call   801b34 <memmove>
	return r;
  802824:	83 c4 10             	add    $0x10,%esp
}
  802827:	89 d8                	mov    %ebx,%eax
  802829:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80282c:	5b                   	pop    %ebx
  80282d:	5e                   	pop    %esi
  80282e:	5d                   	pop    %ebp
  80282f:	c3                   	ret    

00802830 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802830:	55                   	push   %ebp
  802831:	89 e5                	mov    %esp,%ebp
  802833:	53                   	push   %ebx
  802834:	83 ec 20             	sub    $0x20,%esp
  802837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80283a:	53                   	push   %ebx
  80283b:	e8 29 f1 ff ff       	call   801969 <strlen>
  802840:	83 c4 10             	add    $0x10,%esp
  802843:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802848:	7f 67                	jg     8028b1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80284a:	83 ec 0c             	sub    $0xc,%esp
  80284d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802850:	50                   	push   %eax
  802851:	e8 c6 f8 ff ff       	call   80211c <fd_alloc>
  802856:	83 c4 10             	add    $0x10,%esp
		return r;
  802859:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80285b:	85 c0                	test   %eax,%eax
  80285d:	78 57                	js     8028b6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80285f:	83 ec 08             	sub    $0x8,%esp
  802862:	53                   	push   %ebx
  802863:	68 00 a0 80 00       	push   $0x80a000
  802868:	e8 35 f1 ff ff       	call   8019a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80286d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802870:	a3 00 a4 80 00       	mov    %eax,0x80a400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802875:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802878:	b8 01 00 00 00       	mov    $0x1,%eax
  80287d:	e8 22 fe ff ff       	call   8026a4 <fsipc>
  802882:	89 c3                	mov    %eax,%ebx
  802884:	83 c4 10             	add    $0x10,%esp
  802887:	85 c0                	test   %eax,%eax
  802889:	79 14                	jns    80289f <open+0x6f>
		fd_close(fd, 0);
  80288b:	83 ec 08             	sub    $0x8,%esp
  80288e:	6a 00                	push   $0x0
  802890:	ff 75 f4             	pushl  -0xc(%ebp)
  802893:	e8 7c f9 ff ff       	call   802214 <fd_close>
		return r;
  802898:	83 c4 10             	add    $0x10,%esp
  80289b:	89 da                	mov    %ebx,%edx
  80289d:	eb 17                	jmp    8028b6 <open+0x86>
	}

	return fd2num(fd);
  80289f:	83 ec 0c             	sub    $0xc,%esp
  8028a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8028a5:	e8 4b f8 ff ff       	call   8020f5 <fd2num>
  8028aa:	89 c2                	mov    %eax,%edx
  8028ac:	83 c4 10             	add    $0x10,%esp
  8028af:	eb 05                	jmp    8028b6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8028b1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8028b6:	89 d0                	mov    %edx,%eax
  8028b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8028bb:	c9                   	leave  
  8028bc:	c3                   	ret    

008028bd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8028bd:	55                   	push   %ebp
  8028be:	89 e5                	mov    %esp,%ebp
  8028c0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8028c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8028c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8028cd:	e8 d2 fd ff ff       	call   8026a4 <fsipc>
}
  8028d2:	c9                   	leave  
  8028d3:	c3                   	ret    

008028d4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028d4:	55                   	push   %ebp
  8028d5:	89 e5                	mov    %esp,%ebp
  8028d7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028da:	89 d0                	mov    %edx,%eax
  8028dc:	c1 e8 16             	shr    $0x16,%eax
  8028df:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8028e6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028eb:	f6 c1 01             	test   $0x1,%cl
  8028ee:	74 1d                	je     80290d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028f0:	c1 ea 0c             	shr    $0xc,%edx
  8028f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8028fa:	f6 c2 01             	test   $0x1,%dl
  8028fd:	74 0e                	je     80290d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028ff:	c1 ea 0c             	shr    $0xc,%edx
  802902:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802909:	ef 
  80290a:	0f b7 c0             	movzwl %ax,%eax
}
  80290d:	5d                   	pop    %ebp
  80290e:	c3                   	ret    

0080290f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80290f:	55                   	push   %ebp
  802910:	89 e5                	mov    %esp,%ebp
  802912:	56                   	push   %esi
  802913:	53                   	push   %ebx
  802914:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802917:	83 ec 0c             	sub    $0xc,%esp
  80291a:	ff 75 08             	pushl  0x8(%ebp)
  80291d:	e8 e3 f7 ff ff       	call   802105 <fd2data>
  802922:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802924:	83 c4 08             	add    $0x8,%esp
  802927:	68 10 3a 80 00       	push   $0x803a10
  80292c:	53                   	push   %ebx
  80292d:	e8 70 f0 ff ff       	call   8019a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802932:	8b 46 04             	mov    0x4(%esi),%eax
  802935:	2b 06                	sub    (%esi),%eax
  802937:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80293d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802944:	00 00 00 
	stat->st_dev = &devpipe;
  802947:	c7 83 88 00 00 00 80 	movl   $0x808080,0x88(%ebx)
  80294e:	80 80 00 
	return 0;
}
  802951:	b8 00 00 00 00       	mov    $0x0,%eax
  802956:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802959:	5b                   	pop    %ebx
  80295a:	5e                   	pop    %esi
  80295b:	5d                   	pop    %ebp
  80295c:	c3                   	ret    

0080295d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80295d:	55                   	push   %ebp
  80295e:	89 e5                	mov    %esp,%ebp
  802960:	53                   	push   %ebx
  802961:	83 ec 0c             	sub    $0xc,%esp
  802964:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802967:	53                   	push   %ebx
  802968:	6a 00                	push   $0x0
  80296a:	e8 bb f4 ff ff       	call   801e2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80296f:	89 1c 24             	mov    %ebx,(%esp)
  802972:	e8 8e f7 ff ff       	call   802105 <fd2data>
  802977:	83 c4 08             	add    $0x8,%esp
  80297a:	50                   	push   %eax
  80297b:	6a 00                	push   $0x0
  80297d:	e8 a8 f4 ff ff       	call   801e2a <sys_page_unmap>
}
  802982:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802985:	c9                   	leave  
  802986:	c3                   	ret    

00802987 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802987:	55                   	push   %ebp
  802988:	89 e5                	mov    %esp,%ebp
  80298a:	57                   	push   %edi
  80298b:	56                   	push   %esi
  80298c:	53                   	push   %ebx
  80298d:	83 ec 1c             	sub    $0x1c,%esp
  802990:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802993:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802995:	a1 0c 90 80 00       	mov    0x80900c,%eax
  80299a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80299d:	83 ec 0c             	sub    $0xc,%esp
  8029a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8029a3:	e8 2c ff ff ff       	call   8028d4 <pageref>
  8029a8:	89 c3                	mov    %eax,%ebx
  8029aa:	89 3c 24             	mov    %edi,(%esp)
  8029ad:	e8 22 ff ff ff       	call   8028d4 <pageref>
  8029b2:	83 c4 10             	add    $0x10,%esp
  8029b5:	39 c3                	cmp    %eax,%ebx
  8029b7:	0f 94 c1             	sete   %cl
  8029ba:	0f b6 c9             	movzbl %cl,%ecx
  8029bd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8029c0:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  8029c6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8029c9:	39 ce                	cmp    %ecx,%esi
  8029cb:	74 1b                	je     8029e8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8029cd:	39 c3                	cmp    %eax,%ebx
  8029cf:	75 c4                	jne    802995 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8029d1:	8b 42 58             	mov    0x58(%edx),%eax
  8029d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8029d7:	50                   	push   %eax
  8029d8:	56                   	push   %esi
  8029d9:	68 17 3a 80 00       	push   $0x803a17
  8029de:	e8 3a ea ff ff       	call   80141d <cprintf>
  8029e3:	83 c4 10             	add    $0x10,%esp
  8029e6:	eb ad                	jmp    802995 <_pipeisclosed+0xe>
	}
}
  8029e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8029eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029ee:	5b                   	pop    %ebx
  8029ef:	5e                   	pop    %esi
  8029f0:	5f                   	pop    %edi
  8029f1:	5d                   	pop    %ebp
  8029f2:	c3                   	ret    

008029f3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8029f3:	55                   	push   %ebp
  8029f4:	89 e5                	mov    %esp,%ebp
  8029f6:	57                   	push   %edi
  8029f7:	56                   	push   %esi
  8029f8:	53                   	push   %ebx
  8029f9:	83 ec 28             	sub    $0x28,%esp
  8029fc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8029ff:	56                   	push   %esi
  802a00:	e8 00 f7 ff ff       	call   802105 <fd2data>
  802a05:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802a07:	83 c4 10             	add    $0x10,%esp
  802a0a:	bf 00 00 00 00       	mov    $0x0,%edi
  802a0f:	eb 4b                	jmp    802a5c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802a11:	89 da                	mov    %ebx,%edx
  802a13:	89 f0                	mov    %esi,%eax
  802a15:	e8 6d ff ff ff       	call   802987 <_pipeisclosed>
  802a1a:	85 c0                	test   %eax,%eax
  802a1c:	75 48                	jne    802a66 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802a1e:	e8 63 f3 ff ff       	call   801d86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802a23:	8b 43 04             	mov    0x4(%ebx),%eax
  802a26:	8b 0b                	mov    (%ebx),%ecx
  802a28:	8d 51 20             	lea    0x20(%ecx),%edx
  802a2b:	39 d0                	cmp    %edx,%eax
  802a2d:	73 e2                	jae    802a11 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a32:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802a36:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802a39:	89 c2                	mov    %eax,%edx
  802a3b:	c1 fa 1f             	sar    $0x1f,%edx
  802a3e:	89 d1                	mov    %edx,%ecx
  802a40:	c1 e9 1b             	shr    $0x1b,%ecx
  802a43:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802a46:	83 e2 1f             	and    $0x1f,%edx
  802a49:	29 ca                	sub    %ecx,%edx
  802a4b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802a4f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802a53:	83 c0 01             	add    $0x1,%eax
  802a56:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802a59:	83 c7 01             	add    $0x1,%edi
  802a5c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802a5f:	75 c2                	jne    802a23 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802a61:	8b 45 10             	mov    0x10(%ebp),%eax
  802a64:	eb 05                	jmp    802a6b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802a66:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802a6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a6e:	5b                   	pop    %ebx
  802a6f:	5e                   	pop    %esi
  802a70:	5f                   	pop    %edi
  802a71:	5d                   	pop    %ebp
  802a72:	c3                   	ret    

00802a73 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802a73:	55                   	push   %ebp
  802a74:	89 e5                	mov    %esp,%ebp
  802a76:	57                   	push   %edi
  802a77:	56                   	push   %esi
  802a78:	53                   	push   %ebx
  802a79:	83 ec 18             	sub    $0x18,%esp
  802a7c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802a7f:	57                   	push   %edi
  802a80:	e8 80 f6 ff ff       	call   802105 <fd2data>
  802a85:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802a87:	83 c4 10             	add    $0x10,%esp
  802a8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a8f:	eb 3d                	jmp    802ace <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802a91:	85 db                	test   %ebx,%ebx
  802a93:	74 04                	je     802a99 <devpipe_read+0x26>
				return i;
  802a95:	89 d8                	mov    %ebx,%eax
  802a97:	eb 44                	jmp    802add <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802a99:	89 f2                	mov    %esi,%edx
  802a9b:	89 f8                	mov    %edi,%eax
  802a9d:	e8 e5 fe ff ff       	call   802987 <_pipeisclosed>
  802aa2:	85 c0                	test   %eax,%eax
  802aa4:	75 32                	jne    802ad8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802aa6:	e8 db f2 ff ff       	call   801d86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802aab:	8b 06                	mov    (%esi),%eax
  802aad:	3b 46 04             	cmp    0x4(%esi),%eax
  802ab0:	74 df                	je     802a91 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802ab2:	99                   	cltd   
  802ab3:	c1 ea 1b             	shr    $0x1b,%edx
  802ab6:	01 d0                	add    %edx,%eax
  802ab8:	83 e0 1f             	and    $0x1f,%eax
  802abb:	29 d0                	sub    %edx,%eax
  802abd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802ac2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ac5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802ac8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802acb:	83 c3 01             	add    $0x1,%ebx
  802ace:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802ad1:	75 d8                	jne    802aab <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802ad3:	8b 45 10             	mov    0x10(%ebp),%eax
  802ad6:	eb 05                	jmp    802add <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802ad8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802add:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ae0:	5b                   	pop    %ebx
  802ae1:	5e                   	pop    %esi
  802ae2:	5f                   	pop    %edi
  802ae3:	5d                   	pop    %ebp
  802ae4:	c3                   	ret    

00802ae5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802ae5:	55                   	push   %ebp
  802ae6:	89 e5                	mov    %esp,%ebp
  802ae8:	56                   	push   %esi
  802ae9:	53                   	push   %ebx
  802aea:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802aed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802af0:	50                   	push   %eax
  802af1:	e8 26 f6 ff ff       	call   80211c <fd_alloc>
  802af6:	83 c4 10             	add    $0x10,%esp
  802af9:	89 c2                	mov    %eax,%edx
  802afb:	85 c0                	test   %eax,%eax
  802afd:	0f 88 2c 01 00 00    	js     802c2f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802b03:	83 ec 04             	sub    $0x4,%esp
  802b06:	68 07 04 00 00       	push   $0x407
  802b0b:	ff 75 f4             	pushl  -0xc(%ebp)
  802b0e:	6a 00                	push   $0x0
  802b10:	e8 90 f2 ff ff       	call   801da5 <sys_page_alloc>
  802b15:	83 c4 10             	add    $0x10,%esp
  802b18:	89 c2                	mov    %eax,%edx
  802b1a:	85 c0                	test   %eax,%eax
  802b1c:	0f 88 0d 01 00 00    	js     802c2f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802b22:	83 ec 0c             	sub    $0xc,%esp
  802b25:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b28:	50                   	push   %eax
  802b29:	e8 ee f5 ff ff       	call   80211c <fd_alloc>
  802b2e:	89 c3                	mov    %eax,%ebx
  802b30:	83 c4 10             	add    $0x10,%esp
  802b33:	85 c0                	test   %eax,%eax
  802b35:	0f 88 e2 00 00 00    	js     802c1d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802b3b:	83 ec 04             	sub    $0x4,%esp
  802b3e:	68 07 04 00 00       	push   $0x407
  802b43:	ff 75 f0             	pushl  -0x10(%ebp)
  802b46:	6a 00                	push   $0x0
  802b48:	e8 58 f2 ff ff       	call   801da5 <sys_page_alloc>
  802b4d:	89 c3                	mov    %eax,%ebx
  802b4f:	83 c4 10             	add    $0x10,%esp
  802b52:	85 c0                	test   %eax,%eax
  802b54:	0f 88 c3 00 00 00    	js     802c1d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802b5a:	83 ec 0c             	sub    $0xc,%esp
  802b5d:	ff 75 f4             	pushl  -0xc(%ebp)
  802b60:	e8 a0 f5 ff ff       	call   802105 <fd2data>
  802b65:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802b67:	83 c4 0c             	add    $0xc,%esp
  802b6a:	68 07 04 00 00       	push   $0x407
  802b6f:	50                   	push   %eax
  802b70:	6a 00                	push   $0x0
  802b72:	e8 2e f2 ff ff       	call   801da5 <sys_page_alloc>
  802b77:	89 c3                	mov    %eax,%ebx
  802b79:	83 c4 10             	add    $0x10,%esp
  802b7c:	85 c0                	test   %eax,%eax
  802b7e:	0f 88 89 00 00 00    	js     802c0d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802b84:	83 ec 0c             	sub    $0xc,%esp
  802b87:	ff 75 f0             	pushl  -0x10(%ebp)
  802b8a:	e8 76 f5 ff ff       	call   802105 <fd2data>
  802b8f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802b96:	50                   	push   %eax
  802b97:	6a 00                	push   $0x0
  802b99:	56                   	push   %esi
  802b9a:	6a 00                	push   $0x0
  802b9c:	e8 47 f2 ff ff       	call   801de8 <sys_page_map>
  802ba1:	89 c3                	mov    %eax,%ebx
  802ba3:	83 c4 20             	add    $0x20,%esp
  802ba6:	85 c0                	test   %eax,%eax
  802ba8:	78 55                	js     802bff <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802baa:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bb3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bb8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802bbf:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bc8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bcd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802bd4:	83 ec 0c             	sub    $0xc,%esp
  802bd7:	ff 75 f4             	pushl  -0xc(%ebp)
  802bda:	e8 16 f5 ff ff       	call   8020f5 <fd2num>
  802bdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802be2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802be4:	83 c4 04             	add    $0x4,%esp
  802be7:	ff 75 f0             	pushl  -0x10(%ebp)
  802bea:	e8 06 f5 ff ff       	call   8020f5 <fd2num>
  802bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802bf2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802bf5:	83 c4 10             	add    $0x10,%esp
  802bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  802bfd:	eb 30                	jmp    802c2f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802bff:	83 ec 08             	sub    $0x8,%esp
  802c02:	56                   	push   %esi
  802c03:	6a 00                	push   $0x0
  802c05:	e8 20 f2 ff ff       	call   801e2a <sys_page_unmap>
  802c0a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802c0d:	83 ec 08             	sub    $0x8,%esp
  802c10:	ff 75 f0             	pushl  -0x10(%ebp)
  802c13:	6a 00                	push   $0x0
  802c15:	e8 10 f2 ff ff       	call   801e2a <sys_page_unmap>
  802c1a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802c1d:	83 ec 08             	sub    $0x8,%esp
  802c20:	ff 75 f4             	pushl  -0xc(%ebp)
  802c23:	6a 00                	push   $0x0
  802c25:	e8 00 f2 ff ff       	call   801e2a <sys_page_unmap>
  802c2a:	83 c4 10             	add    $0x10,%esp
  802c2d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802c2f:	89 d0                	mov    %edx,%eax
  802c31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c34:	5b                   	pop    %ebx
  802c35:	5e                   	pop    %esi
  802c36:	5d                   	pop    %ebp
  802c37:	c3                   	ret    

00802c38 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802c38:	55                   	push   %ebp
  802c39:	89 e5                	mov    %esp,%ebp
  802c3b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c41:	50                   	push   %eax
  802c42:	ff 75 08             	pushl  0x8(%ebp)
  802c45:	e8 21 f5 ff ff       	call   80216b <fd_lookup>
  802c4a:	83 c4 10             	add    $0x10,%esp
  802c4d:	85 c0                	test   %eax,%eax
  802c4f:	78 18                	js     802c69 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802c51:	83 ec 0c             	sub    $0xc,%esp
  802c54:	ff 75 f4             	pushl  -0xc(%ebp)
  802c57:	e8 a9 f4 ff ff       	call   802105 <fd2data>
	return _pipeisclosed(fd, p);
  802c5c:	89 c2                	mov    %eax,%edx
  802c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c61:	e8 21 fd ff ff       	call   802987 <_pipeisclosed>
  802c66:	83 c4 10             	add    $0x10,%esp
}
  802c69:	c9                   	leave  
  802c6a:	c3                   	ret    

00802c6b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802c6b:	55                   	push   %ebp
  802c6c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  802c73:	5d                   	pop    %ebp
  802c74:	c3                   	ret    

00802c75 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802c75:	55                   	push   %ebp
  802c76:	89 e5                	mov    %esp,%ebp
  802c78:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802c7b:	68 2f 3a 80 00       	push   $0x803a2f
  802c80:	ff 75 0c             	pushl  0xc(%ebp)
  802c83:	e8 1a ed ff ff       	call   8019a2 <strcpy>
	return 0;
}
  802c88:	b8 00 00 00 00       	mov    $0x0,%eax
  802c8d:	c9                   	leave  
  802c8e:	c3                   	ret    

00802c8f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802c8f:	55                   	push   %ebp
  802c90:	89 e5                	mov    %esp,%ebp
  802c92:	57                   	push   %edi
  802c93:	56                   	push   %esi
  802c94:	53                   	push   %ebx
  802c95:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802c9b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802ca0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802ca6:	eb 2d                	jmp    802cd5 <devcons_write+0x46>
		m = n - tot;
  802ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802cab:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802cad:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802cb0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802cb5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802cb8:	83 ec 04             	sub    $0x4,%esp
  802cbb:	53                   	push   %ebx
  802cbc:	03 45 0c             	add    0xc(%ebp),%eax
  802cbf:	50                   	push   %eax
  802cc0:	57                   	push   %edi
  802cc1:	e8 6e ee ff ff       	call   801b34 <memmove>
		sys_cputs(buf, m);
  802cc6:	83 c4 08             	add    $0x8,%esp
  802cc9:	53                   	push   %ebx
  802cca:	57                   	push   %edi
  802ccb:	e8 19 f0 ff ff       	call   801ce9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802cd0:	01 de                	add    %ebx,%esi
  802cd2:	83 c4 10             	add    $0x10,%esp
  802cd5:	89 f0                	mov    %esi,%eax
  802cd7:	3b 75 10             	cmp    0x10(%ebp),%esi
  802cda:	72 cc                	jb     802ca8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cdf:	5b                   	pop    %ebx
  802ce0:	5e                   	pop    %esi
  802ce1:	5f                   	pop    %edi
  802ce2:	5d                   	pop    %ebp
  802ce3:	c3                   	ret    

00802ce4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802ce4:	55                   	push   %ebp
  802ce5:	89 e5                	mov    %esp,%ebp
  802ce7:	83 ec 08             	sub    $0x8,%esp
  802cea:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802cef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802cf3:	74 2a                	je     802d1f <devcons_read+0x3b>
  802cf5:	eb 05                	jmp    802cfc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802cf7:	e8 8a f0 ff ff       	call   801d86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802cfc:	e8 06 f0 ff ff       	call   801d07 <sys_cgetc>
  802d01:	85 c0                	test   %eax,%eax
  802d03:	74 f2                	je     802cf7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802d05:	85 c0                	test   %eax,%eax
  802d07:	78 16                	js     802d1f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802d09:	83 f8 04             	cmp    $0x4,%eax
  802d0c:	74 0c                	je     802d1a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d11:	88 02                	mov    %al,(%edx)
	return 1;
  802d13:	b8 01 00 00 00       	mov    $0x1,%eax
  802d18:	eb 05                	jmp    802d1f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802d1a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802d1f:	c9                   	leave  
  802d20:	c3                   	ret    

00802d21 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802d21:	55                   	push   %ebp
  802d22:	89 e5                	mov    %esp,%ebp
  802d24:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802d27:	8b 45 08             	mov    0x8(%ebp),%eax
  802d2a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802d2d:	6a 01                	push   $0x1
  802d2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802d32:	50                   	push   %eax
  802d33:	e8 b1 ef ff ff       	call   801ce9 <sys_cputs>
}
  802d38:	83 c4 10             	add    $0x10,%esp
  802d3b:	c9                   	leave  
  802d3c:	c3                   	ret    

00802d3d <getchar>:

int
getchar(void)
{
  802d3d:	55                   	push   %ebp
  802d3e:	89 e5                	mov    %esp,%ebp
  802d40:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802d43:	6a 01                	push   $0x1
  802d45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802d48:	50                   	push   %eax
  802d49:	6a 00                	push   $0x0
  802d4b:	e8 81 f6 ff ff       	call   8023d1 <read>
	if (r < 0)
  802d50:	83 c4 10             	add    $0x10,%esp
  802d53:	85 c0                	test   %eax,%eax
  802d55:	78 0f                	js     802d66 <getchar+0x29>
		return r;
	if (r < 1)
  802d57:	85 c0                	test   %eax,%eax
  802d59:	7e 06                	jle    802d61 <getchar+0x24>
		return -E_EOF;
	return c;
  802d5b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802d5f:	eb 05                	jmp    802d66 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802d61:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802d66:	c9                   	leave  
  802d67:	c3                   	ret    

00802d68 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802d68:	55                   	push   %ebp
  802d69:	89 e5                	mov    %esp,%ebp
  802d6b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d71:	50                   	push   %eax
  802d72:	ff 75 08             	pushl  0x8(%ebp)
  802d75:	e8 f1 f3 ff ff       	call   80216b <fd_lookup>
  802d7a:	83 c4 10             	add    $0x10,%esp
  802d7d:	85 c0                	test   %eax,%eax
  802d7f:	78 11                	js     802d92 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d84:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  802d8a:	39 10                	cmp    %edx,(%eax)
  802d8c:	0f 94 c0             	sete   %al
  802d8f:	0f b6 c0             	movzbl %al,%eax
}
  802d92:	c9                   	leave  
  802d93:	c3                   	ret    

00802d94 <opencons>:

int
opencons(void)
{
  802d94:	55                   	push   %ebp
  802d95:	89 e5                	mov    %esp,%ebp
  802d97:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802d9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d9d:	50                   	push   %eax
  802d9e:	e8 79 f3 ff ff       	call   80211c <fd_alloc>
  802da3:	83 c4 10             	add    $0x10,%esp
		return r;
  802da6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802da8:	85 c0                	test   %eax,%eax
  802daa:	78 3e                	js     802dea <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802dac:	83 ec 04             	sub    $0x4,%esp
  802daf:	68 07 04 00 00       	push   $0x407
  802db4:	ff 75 f4             	pushl  -0xc(%ebp)
  802db7:	6a 00                	push   $0x0
  802db9:	e8 e7 ef ff ff       	call   801da5 <sys_page_alloc>
  802dbe:	83 c4 10             	add    $0x10,%esp
		return r;
  802dc1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802dc3:	85 c0                	test   %eax,%eax
  802dc5:	78 23                	js     802dea <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802dc7:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  802dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dd0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dd5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802ddc:	83 ec 0c             	sub    $0xc,%esp
  802ddf:	50                   	push   %eax
  802de0:	e8 10 f3 ff ff       	call   8020f5 <fd2num>
  802de5:	89 c2                	mov    %eax,%edx
  802de7:	83 c4 10             	add    $0x10,%esp
}
  802dea:	89 d0                	mov    %edx,%eax
  802dec:	c9                   	leave  
  802ded:	c3                   	ret    
  802dee:	66 90                	xchg   %ax,%ax

00802df0 <__udivdi3>:
  802df0:	55                   	push   %ebp
  802df1:	57                   	push   %edi
  802df2:	56                   	push   %esi
  802df3:	53                   	push   %ebx
  802df4:	83 ec 1c             	sub    $0x1c,%esp
  802df7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802dfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802dff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802e07:	85 f6                	test   %esi,%esi
  802e09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802e0d:	89 ca                	mov    %ecx,%edx
  802e0f:	89 f8                	mov    %edi,%eax
  802e11:	75 3d                	jne    802e50 <__udivdi3+0x60>
  802e13:	39 cf                	cmp    %ecx,%edi
  802e15:	0f 87 c5 00 00 00    	ja     802ee0 <__udivdi3+0xf0>
  802e1b:	85 ff                	test   %edi,%edi
  802e1d:	89 fd                	mov    %edi,%ebp
  802e1f:	75 0b                	jne    802e2c <__udivdi3+0x3c>
  802e21:	b8 01 00 00 00       	mov    $0x1,%eax
  802e26:	31 d2                	xor    %edx,%edx
  802e28:	f7 f7                	div    %edi
  802e2a:	89 c5                	mov    %eax,%ebp
  802e2c:	89 c8                	mov    %ecx,%eax
  802e2e:	31 d2                	xor    %edx,%edx
  802e30:	f7 f5                	div    %ebp
  802e32:	89 c1                	mov    %eax,%ecx
  802e34:	89 d8                	mov    %ebx,%eax
  802e36:	89 cf                	mov    %ecx,%edi
  802e38:	f7 f5                	div    %ebp
  802e3a:	89 c3                	mov    %eax,%ebx
  802e3c:	89 d8                	mov    %ebx,%eax
  802e3e:	89 fa                	mov    %edi,%edx
  802e40:	83 c4 1c             	add    $0x1c,%esp
  802e43:	5b                   	pop    %ebx
  802e44:	5e                   	pop    %esi
  802e45:	5f                   	pop    %edi
  802e46:	5d                   	pop    %ebp
  802e47:	c3                   	ret    
  802e48:	90                   	nop
  802e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802e50:	39 ce                	cmp    %ecx,%esi
  802e52:	77 74                	ja     802ec8 <__udivdi3+0xd8>
  802e54:	0f bd fe             	bsr    %esi,%edi
  802e57:	83 f7 1f             	xor    $0x1f,%edi
  802e5a:	0f 84 98 00 00 00    	je     802ef8 <__udivdi3+0x108>
  802e60:	bb 20 00 00 00       	mov    $0x20,%ebx
  802e65:	89 f9                	mov    %edi,%ecx
  802e67:	89 c5                	mov    %eax,%ebp
  802e69:	29 fb                	sub    %edi,%ebx
  802e6b:	d3 e6                	shl    %cl,%esi
  802e6d:	89 d9                	mov    %ebx,%ecx
  802e6f:	d3 ed                	shr    %cl,%ebp
  802e71:	89 f9                	mov    %edi,%ecx
  802e73:	d3 e0                	shl    %cl,%eax
  802e75:	09 ee                	or     %ebp,%esi
  802e77:	89 d9                	mov    %ebx,%ecx
  802e79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e7d:	89 d5                	mov    %edx,%ebp
  802e7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802e83:	d3 ed                	shr    %cl,%ebp
  802e85:	89 f9                	mov    %edi,%ecx
  802e87:	d3 e2                	shl    %cl,%edx
  802e89:	89 d9                	mov    %ebx,%ecx
  802e8b:	d3 e8                	shr    %cl,%eax
  802e8d:	09 c2                	or     %eax,%edx
  802e8f:	89 d0                	mov    %edx,%eax
  802e91:	89 ea                	mov    %ebp,%edx
  802e93:	f7 f6                	div    %esi
  802e95:	89 d5                	mov    %edx,%ebp
  802e97:	89 c3                	mov    %eax,%ebx
  802e99:	f7 64 24 0c          	mull   0xc(%esp)
  802e9d:	39 d5                	cmp    %edx,%ebp
  802e9f:	72 10                	jb     802eb1 <__udivdi3+0xc1>
  802ea1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802ea5:	89 f9                	mov    %edi,%ecx
  802ea7:	d3 e6                	shl    %cl,%esi
  802ea9:	39 c6                	cmp    %eax,%esi
  802eab:	73 07                	jae    802eb4 <__udivdi3+0xc4>
  802ead:	39 d5                	cmp    %edx,%ebp
  802eaf:	75 03                	jne    802eb4 <__udivdi3+0xc4>
  802eb1:	83 eb 01             	sub    $0x1,%ebx
  802eb4:	31 ff                	xor    %edi,%edi
  802eb6:	89 d8                	mov    %ebx,%eax
  802eb8:	89 fa                	mov    %edi,%edx
  802eba:	83 c4 1c             	add    $0x1c,%esp
  802ebd:	5b                   	pop    %ebx
  802ebe:	5e                   	pop    %esi
  802ebf:	5f                   	pop    %edi
  802ec0:	5d                   	pop    %ebp
  802ec1:	c3                   	ret    
  802ec2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ec8:	31 ff                	xor    %edi,%edi
  802eca:	31 db                	xor    %ebx,%ebx
  802ecc:	89 d8                	mov    %ebx,%eax
  802ece:	89 fa                	mov    %edi,%edx
  802ed0:	83 c4 1c             	add    $0x1c,%esp
  802ed3:	5b                   	pop    %ebx
  802ed4:	5e                   	pop    %esi
  802ed5:	5f                   	pop    %edi
  802ed6:	5d                   	pop    %ebp
  802ed7:	c3                   	ret    
  802ed8:	90                   	nop
  802ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ee0:	89 d8                	mov    %ebx,%eax
  802ee2:	f7 f7                	div    %edi
  802ee4:	31 ff                	xor    %edi,%edi
  802ee6:	89 c3                	mov    %eax,%ebx
  802ee8:	89 d8                	mov    %ebx,%eax
  802eea:	89 fa                	mov    %edi,%edx
  802eec:	83 c4 1c             	add    $0x1c,%esp
  802eef:	5b                   	pop    %ebx
  802ef0:	5e                   	pop    %esi
  802ef1:	5f                   	pop    %edi
  802ef2:	5d                   	pop    %ebp
  802ef3:	c3                   	ret    
  802ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ef8:	39 ce                	cmp    %ecx,%esi
  802efa:	72 0c                	jb     802f08 <__udivdi3+0x118>
  802efc:	31 db                	xor    %ebx,%ebx
  802efe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802f02:	0f 87 34 ff ff ff    	ja     802e3c <__udivdi3+0x4c>
  802f08:	bb 01 00 00 00       	mov    $0x1,%ebx
  802f0d:	e9 2a ff ff ff       	jmp    802e3c <__udivdi3+0x4c>
  802f12:	66 90                	xchg   %ax,%ax
  802f14:	66 90                	xchg   %ax,%ax
  802f16:	66 90                	xchg   %ax,%ax
  802f18:	66 90                	xchg   %ax,%ax
  802f1a:	66 90                	xchg   %ax,%ax
  802f1c:	66 90                	xchg   %ax,%ax
  802f1e:	66 90                	xchg   %ax,%ax

00802f20 <__umoddi3>:
  802f20:	55                   	push   %ebp
  802f21:	57                   	push   %edi
  802f22:	56                   	push   %esi
  802f23:	53                   	push   %ebx
  802f24:	83 ec 1c             	sub    $0x1c,%esp
  802f27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802f2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802f2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802f37:	85 d2                	test   %edx,%edx
  802f39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802f3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802f41:	89 f3                	mov    %esi,%ebx
  802f43:	89 3c 24             	mov    %edi,(%esp)
  802f46:	89 74 24 04          	mov    %esi,0x4(%esp)
  802f4a:	75 1c                	jne    802f68 <__umoddi3+0x48>
  802f4c:	39 f7                	cmp    %esi,%edi
  802f4e:	76 50                	jbe    802fa0 <__umoddi3+0x80>
  802f50:	89 c8                	mov    %ecx,%eax
  802f52:	89 f2                	mov    %esi,%edx
  802f54:	f7 f7                	div    %edi
  802f56:	89 d0                	mov    %edx,%eax
  802f58:	31 d2                	xor    %edx,%edx
  802f5a:	83 c4 1c             	add    $0x1c,%esp
  802f5d:	5b                   	pop    %ebx
  802f5e:	5e                   	pop    %esi
  802f5f:	5f                   	pop    %edi
  802f60:	5d                   	pop    %ebp
  802f61:	c3                   	ret    
  802f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802f68:	39 f2                	cmp    %esi,%edx
  802f6a:	89 d0                	mov    %edx,%eax
  802f6c:	77 52                	ja     802fc0 <__umoddi3+0xa0>
  802f6e:	0f bd ea             	bsr    %edx,%ebp
  802f71:	83 f5 1f             	xor    $0x1f,%ebp
  802f74:	75 5a                	jne    802fd0 <__umoddi3+0xb0>
  802f76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802f7a:	0f 82 e0 00 00 00    	jb     803060 <__umoddi3+0x140>
  802f80:	39 0c 24             	cmp    %ecx,(%esp)
  802f83:	0f 86 d7 00 00 00    	jbe    803060 <__umoddi3+0x140>
  802f89:	8b 44 24 08          	mov    0x8(%esp),%eax
  802f8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802f91:	83 c4 1c             	add    $0x1c,%esp
  802f94:	5b                   	pop    %ebx
  802f95:	5e                   	pop    %esi
  802f96:	5f                   	pop    %edi
  802f97:	5d                   	pop    %ebp
  802f98:	c3                   	ret    
  802f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802fa0:	85 ff                	test   %edi,%edi
  802fa2:	89 fd                	mov    %edi,%ebp
  802fa4:	75 0b                	jne    802fb1 <__umoddi3+0x91>
  802fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  802fab:	31 d2                	xor    %edx,%edx
  802fad:	f7 f7                	div    %edi
  802faf:	89 c5                	mov    %eax,%ebp
  802fb1:	89 f0                	mov    %esi,%eax
  802fb3:	31 d2                	xor    %edx,%edx
  802fb5:	f7 f5                	div    %ebp
  802fb7:	89 c8                	mov    %ecx,%eax
  802fb9:	f7 f5                	div    %ebp
  802fbb:	89 d0                	mov    %edx,%eax
  802fbd:	eb 99                	jmp    802f58 <__umoddi3+0x38>
  802fbf:	90                   	nop
  802fc0:	89 c8                	mov    %ecx,%eax
  802fc2:	89 f2                	mov    %esi,%edx
  802fc4:	83 c4 1c             	add    $0x1c,%esp
  802fc7:	5b                   	pop    %ebx
  802fc8:	5e                   	pop    %esi
  802fc9:	5f                   	pop    %edi
  802fca:	5d                   	pop    %ebp
  802fcb:	c3                   	ret    
  802fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802fd0:	8b 34 24             	mov    (%esp),%esi
  802fd3:	bf 20 00 00 00       	mov    $0x20,%edi
  802fd8:	89 e9                	mov    %ebp,%ecx
  802fda:	29 ef                	sub    %ebp,%edi
  802fdc:	d3 e0                	shl    %cl,%eax
  802fde:	89 f9                	mov    %edi,%ecx
  802fe0:	89 f2                	mov    %esi,%edx
  802fe2:	d3 ea                	shr    %cl,%edx
  802fe4:	89 e9                	mov    %ebp,%ecx
  802fe6:	09 c2                	or     %eax,%edx
  802fe8:	89 d8                	mov    %ebx,%eax
  802fea:	89 14 24             	mov    %edx,(%esp)
  802fed:	89 f2                	mov    %esi,%edx
  802fef:	d3 e2                	shl    %cl,%edx
  802ff1:	89 f9                	mov    %edi,%ecx
  802ff3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ff7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802ffb:	d3 e8                	shr    %cl,%eax
  802ffd:	89 e9                	mov    %ebp,%ecx
  802fff:	89 c6                	mov    %eax,%esi
  803001:	d3 e3                	shl    %cl,%ebx
  803003:	89 f9                	mov    %edi,%ecx
  803005:	89 d0                	mov    %edx,%eax
  803007:	d3 e8                	shr    %cl,%eax
  803009:	89 e9                	mov    %ebp,%ecx
  80300b:	09 d8                	or     %ebx,%eax
  80300d:	89 d3                	mov    %edx,%ebx
  80300f:	89 f2                	mov    %esi,%edx
  803011:	f7 34 24             	divl   (%esp)
  803014:	89 d6                	mov    %edx,%esi
  803016:	d3 e3                	shl    %cl,%ebx
  803018:	f7 64 24 04          	mull   0x4(%esp)
  80301c:	39 d6                	cmp    %edx,%esi
  80301e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803022:	89 d1                	mov    %edx,%ecx
  803024:	89 c3                	mov    %eax,%ebx
  803026:	72 08                	jb     803030 <__umoddi3+0x110>
  803028:	75 11                	jne    80303b <__umoddi3+0x11b>
  80302a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80302e:	73 0b                	jae    80303b <__umoddi3+0x11b>
  803030:	2b 44 24 04          	sub    0x4(%esp),%eax
  803034:	1b 14 24             	sbb    (%esp),%edx
  803037:	89 d1                	mov    %edx,%ecx
  803039:	89 c3                	mov    %eax,%ebx
  80303b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80303f:	29 da                	sub    %ebx,%edx
  803041:	19 ce                	sbb    %ecx,%esi
  803043:	89 f9                	mov    %edi,%ecx
  803045:	89 f0                	mov    %esi,%eax
  803047:	d3 e0                	shl    %cl,%eax
  803049:	89 e9                	mov    %ebp,%ecx
  80304b:	d3 ea                	shr    %cl,%edx
  80304d:	89 e9                	mov    %ebp,%ecx
  80304f:	d3 ee                	shr    %cl,%esi
  803051:	09 d0                	or     %edx,%eax
  803053:	89 f2                	mov    %esi,%edx
  803055:	83 c4 1c             	add    $0x1c,%esp
  803058:	5b                   	pop    %ebx
  803059:	5e                   	pop    %esi
  80305a:	5f                   	pop    %edi
  80305b:	5d                   	pop    %ebp
  80305c:	c3                   	ret    
  80305d:	8d 76 00             	lea    0x0(%esi),%esi
  803060:	29 f9                	sub    %edi,%ecx
  803062:	19 d6                	sbb    %edx,%esi
  803064:	89 74 24 04          	mov    %esi,0x4(%esp)
  803068:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80306c:	e9 18 ff ff ff       	jmp    802f89 <__umoddi3+0x69>
