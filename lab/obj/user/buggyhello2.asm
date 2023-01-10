
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 e8 04 00 00       	call   800587 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 98 22 80 00       	push   $0x802298
  800118:	6a 23                	push   $0x23
  80011a:	68 b5 22 80 00       	push   $0x8022b5
  80011f:	e8 dc 13 00 00       	call   801500 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 98 22 80 00       	push   $0x802298
  800199:	6a 23                	push   $0x23
  80019b:	68 b5 22 80 00       	push   $0x8022b5
  8001a0:	e8 5b 13 00 00       	call   801500 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 98 22 80 00       	push   $0x802298
  8001db:	6a 23                	push   $0x23
  8001dd:	68 b5 22 80 00       	push   $0x8022b5
  8001e2:	e8 19 13 00 00       	call   801500 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 98 22 80 00       	push   $0x802298
  80021d:	6a 23                	push   $0x23
  80021f:	68 b5 22 80 00       	push   $0x8022b5
  800224:	e8 d7 12 00 00       	call   801500 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 98 22 80 00       	push   $0x802298
  80025f:	6a 23                	push   $0x23
  800261:	68 b5 22 80 00       	push   $0x8022b5
  800266:	e8 95 12 00 00       	call   801500 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 98 22 80 00       	push   $0x802298
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 b5 22 80 00       	push   $0x8022b5
  8002a8:	e8 53 12 00 00       	call   801500 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 98 22 80 00       	push   $0x802298
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 b5 22 80 00       	push   $0x8022b5
  8002ea:	e8 11 12 00 00       	call   801500 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 98 22 80 00       	push   $0x802298
  800347:	6a 23                	push   $0x23
  800349:	68 b5 22 80 00       	push   $0x8022b5
  80034e:	e8 ad 11 00 00       	call   801500 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
  800380:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800383:	bb 00 00 00 00       	mov    $0x0,%ebx
  800388:	b8 0f 00 00 00       	mov    $0xf,%eax
  80038d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	89 df                	mov    %ebx,%edi
  800395:	89 de                	mov    %ebx,%esi
  800397:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800399:	85 c0                	test   %eax,%eax
  80039b:	7e 17                	jle    8003b4 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039d:	83 ec 0c             	sub    $0xc,%esp
  8003a0:	50                   	push   %eax
  8003a1:	6a 0f                	push   $0xf
  8003a3:	68 98 22 80 00       	push   $0x802298
  8003a8:	6a 23                	push   $0x23
  8003aa:	68 b5 22 80 00       	push   $0x8022b5
  8003af:	e8 4c 11 00 00       	call   801500 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b7:	5b                   	pop    %ebx
  8003b8:	5e                   	pop    %esi
  8003b9:	5f                   	pop    %edi
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c7:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ca:	5d                   	pop    %ebp
  8003cb:	c3                   	ret    

008003cc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003dc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 16             	shr    $0x16,%edx
  8003f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 11                	je     800410 <fd_alloc+0x2d>
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 0c             	shr    $0xc,%edx
  800404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	75 09                	jne    800419 <fd_alloc+0x36>
			*fd_store = fd;
  800410:	89 01                	mov    %eax,(%ecx)
			return 0;
  800412:	b8 00 00 00 00       	mov    $0x0,%eax
  800417:	eb 17                	jmp    800430 <fd_alloc+0x4d>
  800419:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80041e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800423:	75 c9                	jne    8003ee <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800425:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80042b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800438:	83 f8 1f             	cmp    $0x1f,%eax
  80043b:	77 36                	ja     800473 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80043d:	c1 e0 0c             	shl    $0xc,%eax
  800440:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800445:	89 c2                	mov    %eax,%edx
  800447:	c1 ea 16             	shr    $0x16,%edx
  80044a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800451:	f6 c2 01             	test   $0x1,%dl
  800454:	74 24                	je     80047a <fd_lookup+0x48>
  800456:	89 c2                	mov    %eax,%edx
  800458:	c1 ea 0c             	shr    $0xc,%edx
  80045b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800462:	f6 c2 01             	test   $0x1,%dl
  800465:	74 1a                	je     800481 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800467:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046a:	89 02                	mov    %eax,(%edx)
	return 0;
  80046c:	b8 00 00 00 00       	mov    $0x0,%eax
  800471:	eb 13                	jmp    800486 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800478:	eb 0c                	jmp    800486 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80047a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80047f:	eb 05                	jmp    800486 <fd_lookup+0x54>
  800481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800486:	5d                   	pop    %ebp
  800487:	c3                   	ret    

00800488 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800491:	ba 40 23 80 00       	mov    $0x802340,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800496:	eb 13                	jmp    8004ab <dev_lookup+0x23>
  800498:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80049b:	39 08                	cmp    %ecx,(%eax)
  80049d:	75 0c                	jne    8004ab <dev_lookup+0x23>
			*dev = devtab[i];
  80049f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a9:	eb 2e                	jmp    8004d9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004ab:	8b 02                	mov    (%edx),%eax
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	75 e7                	jne    800498 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8004b6:	8b 40 48             	mov    0x48(%eax),%eax
  8004b9:	83 ec 04             	sub    $0x4,%esp
  8004bc:	51                   	push   %ecx
  8004bd:	50                   	push   %eax
  8004be:	68 c4 22 80 00       	push   $0x8022c4
  8004c3:	e8 11 11 00 00       	call   8015d9 <cprintf>
	*dev = 0;
  8004c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004d9:	c9                   	leave  
  8004da:	c3                   	ret    

008004db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	56                   	push   %esi
  8004df:	53                   	push   %ebx
  8004e0:	83 ec 10             	sub    $0x10,%esp
  8004e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ec:	50                   	push   %eax
  8004ed:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004f3:	c1 e8 0c             	shr    $0xc,%eax
  8004f6:	50                   	push   %eax
  8004f7:	e8 36 ff ff ff       	call   800432 <fd_lookup>
  8004fc:	83 c4 08             	add    $0x8,%esp
  8004ff:	85 c0                	test   %eax,%eax
  800501:	78 05                	js     800508 <fd_close+0x2d>
	    || fd != fd2)
  800503:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800506:	74 0c                	je     800514 <fd_close+0x39>
		return (must_exist ? r : 0);
  800508:	84 db                	test   %bl,%bl
  80050a:	ba 00 00 00 00       	mov    $0x0,%edx
  80050f:	0f 44 c2             	cmove  %edx,%eax
  800512:	eb 41                	jmp    800555 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80051a:	50                   	push   %eax
  80051b:	ff 36                	pushl  (%esi)
  80051d:	e8 66 ff ff ff       	call   800488 <dev_lookup>
  800522:	89 c3                	mov    %eax,%ebx
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 1a                	js     800545 <fd_close+0x6a>
		if (dev->dev_close)
  80052b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80052e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800531:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800536:	85 c0                	test   %eax,%eax
  800538:	74 0b                	je     800545 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80053a:	83 ec 0c             	sub    $0xc,%esp
  80053d:	56                   	push   %esi
  80053e:	ff d0                	call   *%eax
  800540:	89 c3                	mov    %eax,%ebx
  800542:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	56                   	push   %esi
  800549:	6a 00                	push   $0x0
  80054b:	e8 9f fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	89 d8                	mov    %ebx,%eax
}
  800555:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800558:	5b                   	pop    %ebx
  800559:	5e                   	pop    %esi
  80055a:	5d                   	pop    %ebp
  80055b:	c3                   	ret    

0080055c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800565:	50                   	push   %eax
  800566:	ff 75 08             	pushl  0x8(%ebp)
  800569:	e8 c4 fe ff ff       	call   800432 <fd_lookup>
  80056e:	83 c4 08             	add    $0x8,%esp
  800571:	85 c0                	test   %eax,%eax
  800573:	78 10                	js     800585 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	6a 01                	push   $0x1
  80057a:	ff 75 f4             	pushl  -0xc(%ebp)
  80057d:	e8 59 ff ff ff       	call   8004db <fd_close>
  800582:	83 c4 10             	add    $0x10,%esp
}
  800585:	c9                   	leave  
  800586:	c3                   	ret    

00800587 <close_all>:

void
close_all(void)
{
  800587:	55                   	push   %ebp
  800588:	89 e5                	mov    %esp,%ebp
  80058a:	53                   	push   %ebx
  80058b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80058e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800593:	83 ec 0c             	sub    $0xc,%esp
  800596:	53                   	push   %ebx
  800597:	e8 c0 ff ff ff       	call   80055c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80059c:	83 c3 01             	add    $0x1,%ebx
  80059f:	83 c4 10             	add    $0x10,%esp
  8005a2:	83 fb 20             	cmp    $0x20,%ebx
  8005a5:	75 ec                	jne    800593 <close_all+0xc>
		close(i);
}
  8005a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005aa:	c9                   	leave  
  8005ab:	c3                   	ret    

008005ac <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	57                   	push   %edi
  8005b0:	56                   	push   %esi
  8005b1:	53                   	push   %ebx
  8005b2:	83 ec 2c             	sub    $0x2c,%esp
  8005b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005bb:	50                   	push   %eax
  8005bc:	ff 75 08             	pushl  0x8(%ebp)
  8005bf:	e8 6e fe ff ff       	call   800432 <fd_lookup>
  8005c4:	83 c4 08             	add    $0x8,%esp
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	0f 88 c1 00 00 00    	js     800690 <dup+0xe4>
		return r;
	close(newfdnum);
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	56                   	push   %esi
  8005d3:	e8 84 ff ff ff       	call   80055c <close>

	newfd = INDEX2FD(newfdnum);
  8005d8:	89 f3                	mov    %esi,%ebx
  8005da:	c1 e3 0c             	shl    $0xc,%ebx
  8005dd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005e3:	83 c4 04             	add    $0x4,%esp
  8005e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e9:	e8 de fd ff ff       	call   8003cc <fd2data>
  8005ee:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005f0:	89 1c 24             	mov    %ebx,(%esp)
  8005f3:	e8 d4 fd ff ff       	call   8003cc <fd2data>
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005fe:	89 f8                	mov    %edi,%eax
  800600:	c1 e8 16             	shr    $0x16,%eax
  800603:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80060a:	a8 01                	test   $0x1,%al
  80060c:	74 37                	je     800645 <dup+0x99>
  80060e:	89 f8                	mov    %edi,%eax
  800610:	c1 e8 0c             	shr    $0xc,%eax
  800613:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80061a:	f6 c2 01             	test   $0x1,%dl
  80061d:	74 26                	je     800645 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80061f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	25 07 0e 00 00       	and    $0xe07,%eax
  80062e:	50                   	push   %eax
  80062f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800632:	6a 00                	push   $0x0
  800634:	57                   	push   %edi
  800635:	6a 00                	push   $0x0
  800637:	e8 71 fb ff ff       	call   8001ad <sys_page_map>
  80063c:	89 c7                	mov    %eax,%edi
  80063e:	83 c4 20             	add    $0x20,%esp
  800641:	85 c0                	test   %eax,%eax
  800643:	78 2e                	js     800673 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800645:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800648:	89 d0                	mov    %edx,%eax
  80064a:	c1 e8 0c             	shr    $0xc,%eax
  80064d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	25 07 0e 00 00       	and    $0xe07,%eax
  80065c:	50                   	push   %eax
  80065d:	53                   	push   %ebx
  80065e:	6a 00                	push   $0x0
  800660:	52                   	push   %edx
  800661:	6a 00                	push   $0x0
  800663:	e8 45 fb ff ff       	call   8001ad <sys_page_map>
  800668:	89 c7                	mov    %eax,%edi
  80066a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80066d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80066f:	85 ff                	test   %edi,%edi
  800671:	79 1d                	jns    800690 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 00                	push   $0x0
  800679:	e8 71 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80067e:	83 c4 08             	add    $0x8,%esp
  800681:	ff 75 d4             	pushl  -0x2c(%ebp)
  800684:	6a 00                	push   $0x0
  800686:	e8 64 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	89 f8                	mov    %edi,%eax
}
  800690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800693:	5b                   	pop    %ebx
  800694:	5e                   	pop    %esi
  800695:	5f                   	pop    %edi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	53                   	push   %ebx
  80069c:	83 ec 14             	sub    $0x14,%esp
  80069f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a5:	50                   	push   %eax
  8006a6:	53                   	push   %ebx
  8006a7:	e8 86 fd ff ff       	call   800432 <fd_lookup>
  8006ac:	83 c4 08             	add    $0x8,%esp
  8006af:	89 c2                	mov    %eax,%edx
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	78 6d                	js     800722 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006bb:	50                   	push   %eax
  8006bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006bf:	ff 30                	pushl  (%eax)
  8006c1:	e8 c2 fd ff ff       	call   800488 <dev_lookup>
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	78 4c                	js     800719 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006d0:	8b 42 08             	mov    0x8(%edx),%eax
  8006d3:	83 e0 03             	and    $0x3,%eax
  8006d6:	83 f8 01             	cmp    $0x1,%eax
  8006d9:	75 21                	jne    8006fc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006db:	a1 08 40 80 00       	mov    0x804008,%eax
  8006e0:	8b 40 48             	mov    0x48(%eax),%eax
  8006e3:	83 ec 04             	sub    $0x4,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	50                   	push   %eax
  8006e8:	68 05 23 80 00       	push   $0x802305
  8006ed:	e8 e7 0e 00 00       	call   8015d9 <cprintf>
		return -E_INVAL;
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006fa:	eb 26                	jmp    800722 <read+0x8a>
	}
	if (!dev->dev_read)
  8006fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ff:	8b 40 08             	mov    0x8(%eax),%eax
  800702:	85 c0                	test   %eax,%eax
  800704:	74 17                	je     80071d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800706:	83 ec 04             	sub    $0x4,%esp
  800709:	ff 75 10             	pushl  0x10(%ebp)
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	52                   	push   %edx
  800710:	ff d0                	call   *%eax
  800712:	89 c2                	mov    %eax,%edx
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 09                	jmp    800722 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	89 c2                	mov    %eax,%edx
  80071b:	eb 05                	jmp    800722 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80071d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800722:	89 d0                	mov    %edx,%eax
  800724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800727:	c9                   	leave  
  800728:	c3                   	ret    

00800729 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	57                   	push   %edi
  80072d:	56                   	push   %esi
  80072e:	53                   	push   %ebx
  80072f:	83 ec 0c             	sub    $0xc,%esp
  800732:	8b 7d 08             	mov    0x8(%ebp),%edi
  800735:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800738:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073d:	eb 21                	jmp    800760 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80073f:	83 ec 04             	sub    $0x4,%esp
  800742:	89 f0                	mov    %esi,%eax
  800744:	29 d8                	sub    %ebx,%eax
  800746:	50                   	push   %eax
  800747:	89 d8                	mov    %ebx,%eax
  800749:	03 45 0c             	add    0xc(%ebp),%eax
  80074c:	50                   	push   %eax
  80074d:	57                   	push   %edi
  80074e:	e8 45 ff ff ff       	call   800698 <read>
		if (m < 0)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	85 c0                	test   %eax,%eax
  800758:	78 10                	js     80076a <readn+0x41>
			return m;
		if (m == 0)
  80075a:	85 c0                	test   %eax,%eax
  80075c:	74 0a                	je     800768 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80075e:	01 c3                	add    %eax,%ebx
  800760:	39 f3                	cmp    %esi,%ebx
  800762:	72 db                	jb     80073f <readn+0x16>
  800764:	89 d8                	mov    %ebx,%eax
  800766:	eb 02                	jmp    80076a <readn+0x41>
  800768:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80076a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5f                   	pop    %edi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	53                   	push   %ebx
  800776:	83 ec 14             	sub    $0x14,%esp
  800779:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80077c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	53                   	push   %ebx
  800781:	e8 ac fc ff ff       	call   800432 <fd_lookup>
  800786:	83 c4 08             	add    $0x8,%esp
  800789:	89 c2                	mov    %eax,%edx
  80078b:	85 c0                	test   %eax,%eax
  80078d:	78 68                	js     8007f7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800795:	50                   	push   %eax
  800796:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800799:	ff 30                	pushl  (%eax)
  80079b:	e8 e8 fc ff ff       	call   800488 <dev_lookup>
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	78 47                	js     8007ee <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ae:	75 21                	jne    8007d1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8007b5:	8b 40 48             	mov    0x48(%eax),%eax
  8007b8:	83 ec 04             	sub    $0x4,%esp
  8007bb:	53                   	push   %ebx
  8007bc:	50                   	push   %eax
  8007bd:	68 21 23 80 00       	push   $0x802321
  8007c2:	e8 12 0e 00 00       	call   8015d9 <cprintf>
		return -E_INVAL;
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007cf:	eb 26                	jmp    8007f7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d4:	8b 52 0c             	mov    0xc(%edx),%edx
  8007d7:	85 d2                	test   %edx,%edx
  8007d9:	74 17                	je     8007f2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007db:	83 ec 04             	sub    $0x4,%esp
  8007de:	ff 75 10             	pushl  0x10(%ebp)
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	50                   	push   %eax
  8007e5:	ff d2                	call   *%edx
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	eb 09                	jmp    8007f7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ee:	89 c2                	mov    %eax,%edx
  8007f0:	eb 05                	jmp    8007f7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007f7:	89 d0                	mov    %edx,%eax
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <seek>:

int
seek(int fdnum, off_t offset)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800804:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800807:	50                   	push   %eax
  800808:	ff 75 08             	pushl  0x8(%ebp)
  80080b:	e8 22 fc ff ff       	call   800432 <fd_lookup>
  800810:	83 c4 08             	add    $0x8,%esp
  800813:	85 c0                	test   %eax,%eax
  800815:	78 0e                	js     800825 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800817:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	83 ec 14             	sub    $0x14,%esp
  80082e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800831:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800834:	50                   	push   %eax
  800835:	53                   	push   %ebx
  800836:	e8 f7 fb ff ff       	call   800432 <fd_lookup>
  80083b:	83 c4 08             	add    $0x8,%esp
  80083e:	89 c2                	mov    %eax,%edx
  800840:	85 c0                	test   %eax,%eax
  800842:	78 65                	js     8008a9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084a:	50                   	push   %eax
  80084b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084e:	ff 30                	pushl  (%eax)
  800850:	e8 33 fc ff ff       	call   800488 <dev_lookup>
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	85 c0                	test   %eax,%eax
  80085a:	78 44                	js     8008a0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80085c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800863:	75 21                	jne    800886 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800865:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80086a:	8b 40 48             	mov    0x48(%eax),%eax
  80086d:	83 ec 04             	sub    $0x4,%esp
  800870:	53                   	push   %ebx
  800871:	50                   	push   %eax
  800872:	68 e4 22 80 00       	push   $0x8022e4
  800877:	e8 5d 0d 00 00       	call   8015d9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80087c:	83 c4 10             	add    $0x10,%esp
  80087f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800884:	eb 23                	jmp    8008a9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800886:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800889:	8b 52 18             	mov    0x18(%edx),%edx
  80088c:	85 d2                	test   %edx,%edx
  80088e:	74 14                	je     8008a4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	ff 75 0c             	pushl  0xc(%ebp)
  800896:	50                   	push   %eax
  800897:	ff d2                	call   *%edx
  800899:	89 c2                	mov    %eax,%edx
  80089b:	83 c4 10             	add    $0x10,%esp
  80089e:	eb 09                	jmp    8008a9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	eb 05                	jmp    8008a9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	83 ec 14             	sub    $0x14,%esp
  8008b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008bd:	50                   	push   %eax
  8008be:	ff 75 08             	pushl  0x8(%ebp)
  8008c1:	e8 6c fb ff ff       	call   800432 <fd_lookup>
  8008c6:	83 c4 08             	add    $0x8,%esp
  8008c9:	89 c2                	mov    %eax,%edx
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	78 58                	js     800927 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d5:	50                   	push   %eax
  8008d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d9:	ff 30                	pushl  (%eax)
  8008db:	e8 a8 fb ff ff       	call   800488 <dev_lookup>
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	78 37                	js     80091e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ea:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ee:	74 32                	je     800922 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008fa:	00 00 00 
	stat->st_isdir = 0;
  8008fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800904:	00 00 00 
	stat->st_dev = dev;
  800907:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	53                   	push   %ebx
  800911:	ff 75 f0             	pushl  -0x10(%ebp)
  800914:	ff 50 14             	call   *0x14(%eax)
  800917:	89 c2                	mov    %eax,%edx
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	eb 09                	jmp    800927 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80091e:	89 c2                	mov    %eax,%edx
  800920:	eb 05                	jmp    800927 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800922:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800927:	89 d0                	mov    %edx,%eax
  800929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	6a 00                	push   $0x0
  800938:	ff 75 08             	pushl  0x8(%ebp)
  80093b:	e8 d6 01 00 00       	call   800b16 <open>
  800940:	89 c3                	mov    %eax,%ebx
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	85 c0                	test   %eax,%eax
  800947:	78 1b                	js     800964 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800949:	83 ec 08             	sub    $0x8,%esp
  80094c:	ff 75 0c             	pushl  0xc(%ebp)
  80094f:	50                   	push   %eax
  800950:	e8 5b ff ff ff       	call   8008b0 <fstat>
  800955:	89 c6                	mov    %eax,%esi
	close(fd);
  800957:	89 1c 24             	mov    %ebx,(%esp)
  80095a:	e8 fd fb ff ff       	call   80055c <close>
	return r;
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	89 f0                	mov    %esi,%eax
}
  800964:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	89 c6                	mov    %eax,%esi
  800972:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800974:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80097b:	75 12                	jne    80098f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80097d:	83 ec 0c             	sub    $0xc,%esp
  800980:	6a 01                	push   $0x1
  800982:	e8 d9 15 00 00       	call   801f60 <ipc_find_env>
  800987:	a3 00 40 80 00       	mov    %eax,0x804000
  80098c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80098f:	6a 07                	push   $0x7
  800991:	68 00 50 80 00       	push   $0x805000
  800996:	56                   	push   %esi
  800997:	ff 35 00 40 80 00    	pushl  0x804000
  80099d:	e8 6a 15 00 00       	call   801f0c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009a2:	83 c4 0c             	add    $0xc,%esp
  8009a5:	6a 00                	push   $0x0
  8009a7:	53                   	push   %ebx
  8009a8:	6a 00                	push   $0x0
  8009aa:	e8 f6 14 00 00       	call   801ea5 <ipc_recv>
}
  8009af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ca:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8009d9:	e8 8d ff ff ff       	call   80096b <fsipc>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8009fb:	e8 6b ff ff ff       	call   80096b <fsipc>
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	53                   	push   %ebx
  800a06:	83 ec 04             	sub    $0x4,%esp
  800a09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a12:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a17:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1c:	b8 05 00 00 00       	mov    $0x5,%eax
  800a21:	e8 45 ff ff ff       	call   80096b <fsipc>
  800a26:	85 c0                	test   %eax,%eax
  800a28:	78 2c                	js     800a56 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	68 00 50 80 00       	push   $0x805000
  800a32:	53                   	push   %ebx
  800a33:	e8 26 11 00 00       	call   801b5e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a38:	a1 80 50 80 00       	mov    0x805080,%eax
  800a3d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a43:	a1 84 50 80 00       	mov    0x805084,%eax
  800a48:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a4e:	83 c4 10             	add    $0x10,%esp
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	83 ec 0c             	sub    $0xc,%esp
  800a61:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a64:	8b 55 08             	mov    0x8(%ebp),%edx
  800a67:	8b 52 0c             	mov    0xc(%edx),%edx
  800a6a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a70:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a75:	50                   	push   %eax
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	68 08 50 80 00       	push   $0x805008
  800a7e:	e8 6d 12 00 00       	call   801cf0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	b8 04 00 00 00       	mov    $0x4,%eax
  800a8d:	e8 d9 fe ff ff       	call   80096b <fsipc>

}
  800a92:	c9                   	leave  
  800a93:	c3                   	ret    

00800a94 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aad:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab7:	e8 af fe ff ff       	call   80096b <fsipc>
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	78 4b                	js     800b0d <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ac2:	39 c6                	cmp    %eax,%esi
  800ac4:	73 16                	jae    800adc <devfile_read+0x48>
  800ac6:	68 54 23 80 00       	push   $0x802354
  800acb:	68 5b 23 80 00       	push   $0x80235b
  800ad0:	6a 7c                	push   $0x7c
  800ad2:	68 70 23 80 00       	push   $0x802370
  800ad7:	e8 24 0a 00 00       	call   801500 <_panic>
	assert(r <= PGSIZE);
  800adc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ae1:	7e 16                	jle    800af9 <devfile_read+0x65>
  800ae3:	68 7b 23 80 00       	push   $0x80237b
  800ae8:	68 5b 23 80 00       	push   $0x80235b
  800aed:	6a 7d                	push   $0x7d
  800aef:	68 70 23 80 00       	push   $0x802370
  800af4:	e8 07 0a 00 00       	call   801500 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800af9:	83 ec 04             	sub    $0x4,%esp
  800afc:	50                   	push   %eax
  800afd:	68 00 50 80 00       	push   $0x805000
  800b02:	ff 75 0c             	pushl  0xc(%ebp)
  800b05:	e8 e6 11 00 00       	call   801cf0 <memmove>
	return r;
  800b0a:	83 c4 10             	add    $0x10,%esp
}
  800b0d:	89 d8                	mov    %ebx,%eax
  800b0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 20             	sub    $0x20,%esp
  800b1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b20:	53                   	push   %ebx
  800b21:	e8 ff 0f 00 00       	call   801b25 <strlen>
  800b26:	83 c4 10             	add    $0x10,%esp
  800b29:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b2e:	7f 67                	jg     800b97 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b30:	83 ec 0c             	sub    $0xc,%esp
  800b33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b36:	50                   	push   %eax
  800b37:	e8 a7 f8 ff ff       	call   8003e3 <fd_alloc>
  800b3c:	83 c4 10             	add    $0x10,%esp
		return r;
  800b3f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	78 57                	js     800b9c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b45:	83 ec 08             	sub    $0x8,%esp
  800b48:	53                   	push   %ebx
  800b49:	68 00 50 80 00       	push   $0x805000
  800b4e:	e8 0b 10 00 00       	call   801b5e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b56:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b63:	e8 03 fe ff ff       	call   80096b <fsipc>
  800b68:	89 c3                	mov    %eax,%ebx
  800b6a:	83 c4 10             	add    $0x10,%esp
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	79 14                	jns    800b85 <open+0x6f>
		fd_close(fd, 0);
  800b71:	83 ec 08             	sub    $0x8,%esp
  800b74:	6a 00                	push   $0x0
  800b76:	ff 75 f4             	pushl  -0xc(%ebp)
  800b79:	e8 5d f9 ff ff       	call   8004db <fd_close>
		return r;
  800b7e:	83 c4 10             	add    $0x10,%esp
  800b81:	89 da                	mov    %ebx,%edx
  800b83:	eb 17                	jmp    800b9c <open+0x86>
	}

	return fd2num(fd);
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	ff 75 f4             	pushl  -0xc(%ebp)
  800b8b:	e8 2c f8 ff ff       	call   8003bc <fd2num>
  800b90:	89 c2                	mov    %eax,%edx
  800b92:	83 c4 10             	add    $0x10,%esp
  800b95:	eb 05                	jmp    800b9c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b97:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b9c:	89 d0                	mov    %edx,%eax
  800b9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb3:	e8 b3 fd ff ff       	call   80096b <fsipc>
}
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bc0:	68 87 23 80 00       	push   $0x802387
  800bc5:	ff 75 0c             	pushl  0xc(%ebp)
  800bc8:	e8 91 0f 00 00       	call   801b5e <strcpy>
	return 0;
}
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	c9                   	leave  
  800bd3:	c3                   	ret    

00800bd4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 10             	sub    $0x10,%esp
  800bdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bde:	53                   	push   %ebx
  800bdf:	e8 b5 13 00 00       	call   801f99 <pageref>
  800be4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bec:	83 f8 01             	cmp    $0x1,%eax
  800bef:	75 10                	jne    800c01 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	ff 73 0c             	pushl  0xc(%ebx)
  800bf7:	e8 c0 02 00 00       	call   800ebc <nsipc_close>
  800bfc:	89 c2                	mov    %eax,%edx
  800bfe:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c01:	89 d0                	mov    %edx,%eax
  800c03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c0e:	6a 00                	push   $0x0
  800c10:	ff 75 10             	pushl  0x10(%ebp)
  800c13:	ff 75 0c             	pushl  0xc(%ebp)
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	ff 70 0c             	pushl  0xc(%eax)
  800c1c:	e8 78 03 00 00       	call   800f99 <nsipc_send>
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c29:	6a 00                	push   $0x0
  800c2b:	ff 75 10             	pushl  0x10(%ebp)
  800c2e:	ff 75 0c             	pushl  0xc(%ebp)
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	ff 70 0c             	pushl  0xc(%eax)
  800c37:	e8 f1 02 00 00       	call   800f2d <nsipc_recv>
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c44:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c47:	52                   	push   %edx
  800c48:	50                   	push   %eax
  800c49:	e8 e4 f7 ff ff       	call   800432 <fd_lookup>
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	85 c0                	test   %eax,%eax
  800c53:	78 17                	js     800c6c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c58:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800c5e:	39 08                	cmp    %ecx,(%eax)
  800c60:	75 05                	jne    800c67 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c62:	8b 40 0c             	mov    0xc(%eax),%eax
  800c65:	eb 05                	jmp    800c6c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c67:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 1c             	sub    $0x1c,%esp
  800c76:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c7b:	50                   	push   %eax
  800c7c:	e8 62 f7 ff ff       	call   8003e3 <fd_alloc>
  800c81:	89 c3                	mov    %eax,%ebx
  800c83:	83 c4 10             	add    $0x10,%esp
  800c86:	85 c0                	test   %eax,%eax
  800c88:	78 1b                	js     800ca5 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c8a:	83 ec 04             	sub    $0x4,%esp
  800c8d:	68 07 04 00 00       	push   $0x407
  800c92:	ff 75 f4             	pushl  -0xc(%ebp)
  800c95:	6a 00                	push   $0x0
  800c97:	e8 ce f4 ff ff       	call   80016a <sys_page_alloc>
  800c9c:	89 c3                	mov    %eax,%ebx
  800c9e:	83 c4 10             	add    $0x10,%esp
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	79 10                	jns    800cb5 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	56                   	push   %esi
  800ca9:	e8 0e 02 00 00       	call   800ebc <nsipc_close>
		return r;
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	89 d8                	mov    %ebx,%eax
  800cb3:	eb 24                	jmp    800cd9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cb5:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbe:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cca:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	e8 e6 f6 ff ff       	call   8003bc <fd2num>
  800cd6:	83 c4 10             	add    $0x10,%esp
}
  800cd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	e8 50 ff ff ff       	call   800c3e <fd2sockid>
		return r;
  800cee:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	78 1f                	js     800d13 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf4:	83 ec 04             	sub    $0x4,%esp
  800cf7:	ff 75 10             	pushl  0x10(%ebp)
  800cfa:	ff 75 0c             	pushl  0xc(%ebp)
  800cfd:	50                   	push   %eax
  800cfe:	e8 12 01 00 00       	call   800e15 <nsipc_accept>
  800d03:	83 c4 10             	add    $0x10,%esp
		return r;
  800d06:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	78 07                	js     800d13 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d0c:	e8 5d ff ff ff       	call   800c6e <alloc_sockfd>
  800d11:	89 c1                	mov    %eax,%ecx
}
  800d13:	89 c8                	mov    %ecx,%eax
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    

00800d17 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	e8 19 ff ff ff       	call   800c3e <fd2sockid>
  800d25:	85 c0                	test   %eax,%eax
  800d27:	78 12                	js     800d3b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d29:	83 ec 04             	sub    $0x4,%esp
  800d2c:	ff 75 10             	pushl  0x10(%ebp)
  800d2f:	ff 75 0c             	pushl  0xc(%ebp)
  800d32:	50                   	push   %eax
  800d33:	e8 2d 01 00 00       	call   800e65 <nsipc_bind>
  800d38:	83 c4 10             	add    $0x10,%esp
}
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    

00800d3d <shutdown>:

int
shutdown(int s, int how)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	e8 f3 fe ff ff       	call   800c3e <fd2sockid>
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	78 0f                	js     800d5e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d4f:	83 ec 08             	sub    $0x8,%esp
  800d52:	ff 75 0c             	pushl  0xc(%ebp)
  800d55:	50                   	push   %eax
  800d56:	e8 3f 01 00 00       	call   800e9a <nsipc_shutdown>
  800d5b:	83 c4 10             	add    $0x10,%esp
}
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	e8 d0 fe ff ff       	call   800c3e <fd2sockid>
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	78 12                	js     800d84 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d72:	83 ec 04             	sub    $0x4,%esp
  800d75:	ff 75 10             	pushl  0x10(%ebp)
  800d78:	ff 75 0c             	pushl  0xc(%ebp)
  800d7b:	50                   	push   %eax
  800d7c:	e8 55 01 00 00       	call   800ed6 <nsipc_connect>
  800d81:	83 c4 10             	add    $0x10,%esp
}
  800d84:	c9                   	leave  
  800d85:	c3                   	ret    

00800d86 <listen>:

int
listen(int s, int backlog)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8f:	e8 aa fe ff ff       	call   800c3e <fd2sockid>
  800d94:	85 c0                	test   %eax,%eax
  800d96:	78 0f                	js     800da7 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d98:	83 ec 08             	sub    $0x8,%esp
  800d9b:	ff 75 0c             	pushl  0xc(%ebp)
  800d9e:	50                   	push   %eax
  800d9f:	e8 67 01 00 00       	call   800f0b <nsipc_listen>
  800da4:	83 c4 10             	add    $0x10,%esp
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800daf:	ff 75 10             	pushl  0x10(%ebp)
  800db2:	ff 75 0c             	pushl  0xc(%ebp)
  800db5:	ff 75 08             	pushl  0x8(%ebp)
  800db8:	e8 3a 02 00 00       	call   800ff7 <nsipc_socket>
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	78 05                	js     800dc9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dc4:	e8 a5 fe ff ff       	call   800c6e <alloc_sockfd>
}
  800dc9:	c9                   	leave  
  800dca:	c3                   	ret    

00800dcb <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	53                   	push   %ebx
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dd4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800ddb:	75 12                	jne    800def <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800ddd:	83 ec 0c             	sub    $0xc,%esp
  800de0:	6a 02                	push   $0x2
  800de2:	e8 79 11 00 00       	call   801f60 <ipc_find_env>
  800de7:	a3 04 40 80 00       	mov    %eax,0x804004
  800dec:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800def:	6a 07                	push   $0x7
  800df1:	68 00 60 80 00       	push   $0x806000
  800df6:	53                   	push   %ebx
  800df7:	ff 35 04 40 80 00    	pushl  0x804004
  800dfd:	e8 0a 11 00 00       	call   801f0c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e02:	83 c4 0c             	add    $0xc,%esp
  800e05:	6a 00                	push   $0x0
  800e07:	6a 00                	push   $0x0
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 95 10 00 00       	call   801ea5 <ipc_recv>
}
  800e10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    

00800e15 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e25:	8b 06                	mov    (%esi),%eax
  800e27:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e31:	e8 95 ff ff ff       	call   800dcb <nsipc>
  800e36:	89 c3                	mov    %eax,%ebx
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	78 20                	js     800e5c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	ff 35 10 60 80 00    	pushl  0x806010
  800e45:	68 00 60 80 00       	push   $0x806000
  800e4a:	ff 75 0c             	pushl  0xc(%ebp)
  800e4d:	e8 9e 0e 00 00       	call   801cf0 <memmove>
		*addrlen = ret->ret_addrlen;
  800e52:	a1 10 60 80 00       	mov    0x806010,%eax
  800e57:	89 06                	mov    %eax,(%esi)
  800e59:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	53                   	push   %ebx
  800e69:	83 ec 08             	sub    $0x8,%esp
  800e6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e77:	53                   	push   %ebx
  800e78:	ff 75 0c             	pushl  0xc(%ebp)
  800e7b:	68 04 60 80 00       	push   $0x806004
  800e80:	e8 6b 0e 00 00       	call   801cf0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e85:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e8b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e90:	e8 36 ff ff ff       	call   800dcb <nsipc>
}
  800e95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eab:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800eb0:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb5:	e8 11 ff ff ff       	call   800dcb <nsipc>
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <nsipc_close>:

int
nsipc_close(int s)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ec2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec5:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eca:	b8 04 00 00 00       	mov    $0x4,%eax
  800ecf:	e8 f7 fe ff ff       	call   800dcb <nsipc>
}
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    

00800ed6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 08             	sub    $0x8,%esp
  800edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ee8:	53                   	push   %ebx
  800ee9:	ff 75 0c             	pushl  0xc(%ebp)
  800eec:	68 04 60 80 00       	push   $0x806004
  800ef1:	e8 fa 0d 00 00       	call   801cf0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ef6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800efc:	b8 05 00 00 00       	mov    $0x5,%eax
  800f01:	e8 c5 fe ff ff       	call   800dcb <nsipc>
}
  800f06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f11:	8b 45 08             	mov    0x8(%ebp),%eax
  800f14:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f21:	b8 06 00 00 00       	mov    $0x6,%eax
  800f26:	e8 a0 fe ff ff       	call   800dcb <nsipc>
}
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
  800f32:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f3d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f43:	8b 45 14             	mov    0x14(%ebp),%eax
  800f46:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f4b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f50:	e8 76 fe ff ff       	call   800dcb <nsipc>
  800f55:	89 c3                	mov    %eax,%ebx
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 35                	js     800f90 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f5b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f60:	7f 04                	jg     800f66 <nsipc_recv+0x39>
  800f62:	39 c6                	cmp    %eax,%esi
  800f64:	7d 16                	jge    800f7c <nsipc_recv+0x4f>
  800f66:	68 93 23 80 00       	push   $0x802393
  800f6b:	68 5b 23 80 00       	push   $0x80235b
  800f70:	6a 62                	push   $0x62
  800f72:	68 a8 23 80 00       	push   $0x8023a8
  800f77:	e8 84 05 00 00       	call   801500 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f7c:	83 ec 04             	sub    $0x4,%esp
  800f7f:	50                   	push   %eax
  800f80:	68 00 60 80 00       	push   $0x806000
  800f85:	ff 75 0c             	pushl  0xc(%ebp)
  800f88:	e8 63 0d 00 00       	call   801cf0 <memmove>
  800f8d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f90:	89 d8                	mov    %ebx,%eax
  800f92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	53                   	push   %ebx
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fab:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fb1:	7e 16                	jle    800fc9 <nsipc_send+0x30>
  800fb3:	68 b4 23 80 00       	push   $0x8023b4
  800fb8:	68 5b 23 80 00       	push   $0x80235b
  800fbd:	6a 6d                	push   $0x6d
  800fbf:	68 a8 23 80 00       	push   $0x8023a8
  800fc4:	e8 37 05 00 00       	call   801500 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fc9:	83 ec 04             	sub    $0x4,%esp
  800fcc:	53                   	push   %ebx
  800fcd:	ff 75 0c             	pushl  0xc(%ebp)
  800fd0:	68 0c 60 80 00       	push   $0x80600c
  800fd5:	e8 16 0d 00 00       	call   801cf0 <memmove>
	nsipcbuf.send.req_size = size;
  800fda:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fe0:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fe8:	b8 08 00 00 00       	mov    $0x8,%eax
  800fed:	e8 d9 fd ff ff       	call   800dcb <nsipc>
}
  800ff2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  801000:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801005:	8b 45 0c             	mov    0xc(%ebp),%eax
  801008:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80100d:	8b 45 10             	mov    0x10(%ebp),%eax
  801010:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801015:	b8 09 00 00 00       	mov    $0x9,%eax
  80101a:	e8 ac fd ff ff       	call   800dcb <nsipc>
}
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
  801026:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	ff 75 08             	pushl  0x8(%ebp)
  80102f:	e8 98 f3 ff ff       	call   8003cc <fd2data>
  801034:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801036:	83 c4 08             	add    $0x8,%esp
  801039:	68 c0 23 80 00       	push   $0x8023c0
  80103e:	53                   	push   %ebx
  80103f:	e8 1a 0b 00 00       	call   801b5e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801044:	8b 46 04             	mov    0x4(%esi),%eax
  801047:	2b 06                	sub    (%esi),%eax
  801049:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80104f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801056:	00 00 00 
	stat->st_dev = &devpipe;
  801059:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801060:	30 80 00 
	return 0;
}
  801063:	b8 00 00 00 00       	mov    $0x0,%eax
  801068:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	53                   	push   %ebx
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801079:	53                   	push   %ebx
  80107a:	6a 00                	push   $0x0
  80107c:	e8 6e f1 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801081:	89 1c 24             	mov    %ebx,(%esp)
  801084:	e8 43 f3 ff ff       	call   8003cc <fd2data>
  801089:	83 c4 08             	add    $0x8,%esp
  80108c:	50                   	push   %eax
  80108d:	6a 00                	push   $0x0
  80108f:	e8 5b f1 ff ff       	call   8001ef <sys_page_unmap>
}
  801094:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801097:	c9                   	leave  
  801098:	c3                   	ret    

00801099 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	57                   	push   %edi
  80109d:	56                   	push   %esi
  80109e:	53                   	push   %ebx
  80109f:	83 ec 1c             	sub    $0x1c,%esp
  8010a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010a5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010a7:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ac:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8010b5:	e8 df 0e 00 00       	call   801f99 <pageref>
  8010ba:	89 c3                	mov    %eax,%ebx
  8010bc:	89 3c 24             	mov    %edi,(%esp)
  8010bf:	e8 d5 0e 00 00       	call   801f99 <pageref>
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	39 c3                	cmp    %eax,%ebx
  8010c9:	0f 94 c1             	sete   %cl
  8010cc:	0f b6 c9             	movzbl %cl,%ecx
  8010cf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010d2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010d8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010db:	39 ce                	cmp    %ecx,%esi
  8010dd:	74 1b                	je     8010fa <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010df:	39 c3                	cmp    %eax,%ebx
  8010e1:	75 c4                	jne    8010a7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010e3:	8b 42 58             	mov    0x58(%edx),%eax
  8010e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e9:	50                   	push   %eax
  8010ea:	56                   	push   %esi
  8010eb:	68 c7 23 80 00       	push   $0x8023c7
  8010f0:	e8 e4 04 00 00       	call   8015d9 <cprintf>
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	eb ad                	jmp    8010a7 <_pipeisclosed+0xe>
	}
}
  8010fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5f                   	pop    %edi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 28             	sub    $0x28,%esp
  80110e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801111:	56                   	push   %esi
  801112:	e8 b5 f2 ff ff       	call   8003cc <fd2data>
  801117:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	bf 00 00 00 00       	mov    $0x0,%edi
  801121:	eb 4b                	jmp    80116e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801123:	89 da                	mov    %ebx,%edx
  801125:	89 f0                	mov    %esi,%eax
  801127:	e8 6d ff ff ff       	call   801099 <_pipeisclosed>
  80112c:	85 c0                	test   %eax,%eax
  80112e:	75 48                	jne    801178 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801130:	e8 16 f0 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801135:	8b 43 04             	mov    0x4(%ebx),%eax
  801138:	8b 0b                	mov    (%ebx),%ecx
  80113a:	8d 51 20             	lea    0x20(%ecx),%edx
  80113d:	39 d0                	cmp    %edx,%eax
  80113f:	73 e2                	jae    801123 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801141:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801144:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801148:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80114b:	89 c2                	mov    %eax,%edx
  80114d:	c1 fa 1f             	sar    $0x1f,%edx
  801150:	89 d1                	mov    %edx,%ecx
  801152:	c1 e9 1b             	shr    $0x1b,%ecx
  801155:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801158:	83 e2 1f             	and    $0x1f,%edx
  80115b:	29 ca                	sub    %ecx,%edx
  80115d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801161:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801165:	83 c0 01             	add    $0x1,%eax
  801168:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80116b:	83 c7 01             	add    $0x1,%edi
  80116e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801171:	75 c2                	jne    801135 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801173:	8b 45 10             	mov    0x10(%ebp),%eax
  801176:	eb 05                	jmp    80117d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	57                   	push   %edi
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 18             	sub    $0x18,%esp
  80118e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801191:	57                   	push   %edi
  801192:	e8 35 f2 ff ff       	call   8003cc <fd2data>
  801197:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a1:	eb 3d                	jmp    8011e0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011a3:	85 db                	test   %ebx,%ebx
  8011a5:	74 04                	je     8011ab <devpipe_read+0x26>
				return i;
  8011a7:	89 d8                	mov    %ebx,%eax
  8011a9:	eb 44                	jmp    8011ef <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011ab:	89 f2                	mov    %esi,%edx
  8011ad:	89 f8                	mov    %edi,%eax
  8011af:	e8 e5 fe ff ff       	call   801099 <_pipeisclosed>
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	75 32                	jne    8011ea <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011b8:	e8 8e ef ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011bd:	8b 06                	mov    (%esi),%eax
  8011bf:	3b 46 04             	cmp    0x4(%esi),%eax
  8011c2:	74 df                	je     8011a3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011c4:	99                   	cltd   
  8011c5:	c1 ea 1b             	shr    $0x1b,%edx
  8011c8:	01 d0                	add    %edx,%eax
  8011ca:	83 e0 1f             	and    $0x1f,%eax
  8011cd:	29 d0                	sub    %edx,%eax
  8011cf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011da:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011dd:	83 c3 01             	add    $0x1,%ebx
  8011e0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011e3:	75 d8                	jne    8011bd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e8:	eb 05                	jmp    8011ef <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	56                   	push   %esi
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	e8 db f1 ff ff       	call   8003e3 <fd_alloc>
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	85 c0                	test   %eax,%eax
  80120f:	0f 88 2c 01 00 00    	js     801341 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	68 07 04 00 00       	push   $0x407
  80121d:	ff 75 f4             	pushl  -0xc(%ebp)
  801220:	6a 00                	push   $0x0
  801222:	e8 43 ef ff ff       	call   80016a <sys_page_alloc>
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	85 c0                	test   %eax,%eax
  80122e:	0f 88 0d 01 00 00    	js     801341 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	e8 a3 f1 ff ff       	call   8003e3 <fd_alloc>
  801240:	89 c3                	mov    %eax,%ebx
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	0f 88 e2 00 00 00    	js     80132f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	68 07 04 00 00       	push   $0x407
  801255:	ff 75 f0             	pushl  -0x10(%ebp)
  801258:	6a 00                	push   $0x0
  80125a:	e8 0b ef ff ff       	call   80016a <sys_page_alloc>
  80125f:	89 c3                	mov    %eax,%ebx
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	0f 88 c3 00 00 00    	js     80132f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80126c:	83 ec 0c             	sub    $0xc,%esp
  80126f:	ff 75 f4             	pushl  -0xc(%ebp)
  801272:	e8 55 f1 ff ff       	call   8003cc <fd2data>
  801277:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801279:	83 c4 0c             	add    $0xc,%esp
  80127c:	68 07 04 00 00       	push   $0x407
  801281:	50                   	push   %eax
  801282:	6a 00                	push   $0x0
  801284:	e8 e1 ee ff ff       	call   80016a <sys_page_alloc>
  801289:	89 c3                	mov    %eax,%ebx
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	0f 88 89 00 00 00    	js     80131f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	ff 75 f0             	pushl  -0x10(%ebp)
  80129c:	e8 2b f1 ff ff       	call   8003cc <fd2data>
  8012a1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012a8:	50                   	push   %eax
  8012a9:	6a 00                	push   $0x0
  8012ab:	56                   	push   %esi
  8012ac:	6a 00                	push   $0x0
  8012ae:	e8 fa ee ff ff       	call   8001ad <sys_page_map>
  8012b3:	89 c3                	mov    %eax,%ebx
  8012b5:	83 c4 20             	add    $0x20,%esp
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 55                	js     801311 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012bc:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8012c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012d1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8012d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012da:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012e6:	83 ec 0c             	sub    $0xc,%esp
  8012e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ec:	e8 cb f0 ff ff       	call   8003bc <fd2num>
  8012f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012f6:	83 c4 04             	add    $0x4,%esp
  8012f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012fc:	e8 bb f0 ff ff       	call   8003bc <fd2num>
  801301:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801304:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	ba 00 00 00 00       	mov    $0x0,%edx
  80130f:	eb 30                	jmp    801341 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	56                   	push   %esi
  801315:	6a 00                	push   $0x0
  801317:	e8 d3 ee ff ff       	call   8001ef <sys_page_unmap>
  80131c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	ff 75 f0             	pushl  -0x10(%ebp)
  801325:	6a 00                	push   $0x0
  801327:	e8 c3 ee ff ff       	call   8001ef <sys_page_unmap>
  80132c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	ff 75 f4             	pushl  -0xc(%ebp)
  801335:	6a 00                	push   $0x0
  801337:	e8 b3 ee ff ff       	call   8001ef <sys_page_unmap>
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801341:	89 d0                	mov    %edx,%eax
  801343:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	ff 75 08             	pushl  0x8(%ebp)
  801357:	e8 d6 f0 ff ff       	call   800432 <fd_lookup>
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 18                	js     80137b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	ff 75 f4             	pushl  -0xc(%ebp)
  801369:	e8 5e f0 ff ff       	call   8003cc <fd2data>
	return _pipeisclosed(fd, p);
  80136e:	89 c2                	mov    %eax,%edx
  801370:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801373:	e8 21 fd ff ff       	call   801099 <_pipeisclosed>
  801378:	83 c4 10             	add    $0x10,%esp
}
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80138d:	68 df 23 80 00       	push   $0x8023df
  801392:	ff 75 0c             	pushl  0xc(%ebp)
  801395:	e8 c4 07 00 00       	call   801b5e <strcpy>
	return 0;
}
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	57                   	push   %edi
  8013a5:	56                   	push   %esi
  8013a6:	53                   	push   %ebx
  8013a7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ad:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b8:	eb 2d                	jmp    8013e7 <devcons_write+0x46>
		m = n - tot;
  8013ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013bd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013bf:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013c2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013c7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ca:	83 ec 04             	sub    $0x4,%esp
  8013cd:	53                   	push   %ebx
  8013ce:	03 45 0c             	add    0xc(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	57                   	push   %edi
  8013d3:	e8 18 09 00 00       	call   801cf0 <memmove>
		sys_cputs(buf, m);
  8013d8:	83 c4 08             	add    $0x8,%esp
  8013db:	53                   	push   %ebx
  8013dc:	57                   	push   %edi
  8013dd:	e8 cc ec ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013e2:	01 de                	add    %ebx,%esi
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	89 f0                	mov    %esi,%eax
  8013e9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013ec:	72 cc                	jb     8013ba <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5e                   	pop    %esi
  8013f3:	5f                   	pop    %edi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801401:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801405:	74 2a                	je     801431 <devcons_read+0x3b>
  801407:	eb 05                	jmp    80140e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801409:	e8 3d ed ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80140e:	e8 b9 ec ff ff       	call   8000cc <sys_cgetc>
  801413:	85 c0                	test   %eax,%eax
  801415:	74 f2                	je     801409 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801417:	85 c0                	test   %eax,%eax
  801419:	78 16                	js     801431 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80141b:	83 f8 04             	cmp    $0x4,%eax
  80141e:	74 0c                	je     80142c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801420:	8b 55 0c             	mov    0xc(%ebp),%edx
  801423:	88 02                	mov    %al,(%edx)
	return 1;
  801425:	b8 01 00 00 00       	mov    $0x1,%eax
  80142a:	eb 05                	jmp    801431 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
  80143c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80143f:	6a 01                	push   $0x1
  801441:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	e8 64 ec ff ff       	call   8000ae <sys_cputs>
}
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <getchar>:

int
getchar(void)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801455:	6a 01                	push   $0x1
  801457:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80145a:	50                   	push   %eax
  80145b:	6a 00                	push   $0x0
  80145d:	e8 36 f2 ff ff       	call   800698 <read>
	if (r < 0)
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 0f                	js     801478 <getchar+0x29>
		return r;
	if (r < 1)
  801469:	85 c0                	test   %eax,%eax
  80146b:	7e 06                	jle    801473 <getchar+0x24>
		return -E_EOF;
	return c;
  80146d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801471:	eb 05                	jmp    801478 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801473:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801480:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	ff 75 08             	pushl  0x8(%ebp)
  801487:	e8 a6 ef ff ff       	call   800432 <fd_lookup>
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 11                	js     8014a4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801493:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801496:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80149c:	39 10                	cmp    %edx,(%eax)
  80149e:	0f 94 c0             	sete   %al
  8014a1:	0f b6 c0             	movzbl %al,%eax
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <opencons>:

int
opencons(void)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	e8 2e ef ff ff       	call   8003e3 <fd_alloc>
  8014b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 3e                	js     8014fc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014be:	83 ec 04             	sub    $0x4,%esp
  8014c1:	68 07 04 00 00       	push   $0x407
  8014c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c9:	6a 00                	push   $0x0
  8014cb:	e8 9a ec ff ff       	call   80016a <sys_page_alloc>
  8014d0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014d3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 23                	js     8014fc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014d9:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8014df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	50                   	push   %eax
  8014f2:	e8 c5 ee ff ff       	call   8003bc <fd2num>
  8014f7:	89 c2                	mov    %eax,%edx
  8014f9:	83 c4 10             	add    $0x10,%esp
}
  8014fc:	89 d0                	mov    %edx,%eax
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	56                   	push   %esi
  801504:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801505:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801508:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80150e:	e8 19 ec ff ff       	call   80012c <sys_getenvid>
  801513:	83 ec 0c             	sub    $0xc,%esp
  801516:	ff 75 0c             	pushl  0xc(%ebp)
  801519:	ff 75 08             	pushl  0x8(%ebp)
  80151c:	56                   	push   %esi
  80151d:	50                   	push   %eax
  80151e:	68 ec 23 80 00       	push   $0x8023ec
  801523:	e8 b1 00 00 00       	call   8015d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801528:	83 c4 18             	add    $0x18,%esp
  80152b:	53                   	push   %ebx
  80152c:	ff 75 10             	pushl  0x10(%ebp)
  80152f:	e8 54 00 00 00       	call   801588 <vcprintf>
	cprintf("\n");
  801534:	c7 04 24 d8 23 80 00 	movl   $0x8023d8,(%esp)
  80153b:	e8 99 00 00 00       	call   8015d9 <cprintf>
  801540:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801543:	cc                   	int3   
  801544:	eb fd                	jmp    801543 <_panic+0x43>

00801546 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	53                   	push   %ebx
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801550:	8b 13                	mov    (%ebx),%edx
  801552:	8d 42 01             	lea    0x1(%edx),%eax
  801555:	89 03                	mov    %eax,(%ebx)
  801557:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80155a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80155e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801563:	75 1a                	jne    80157f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801565:	83 ec 08             	sub    $0x8,%esp
  801568:	68 ff 00 00 00       	push   $0xff
  80156d:	8d 43 08             	lea    0x8(%ebx),%eax
  801570:	50                   	push   %eax
  801571:	e8 38 eb ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  801576:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80157c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80157f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801583:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801586:	c9                   	leave  
  801587:	c3                   	ret    

00801588 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801591:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801598:	00 00 00 
	b.cnt = 0;
  80159b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015a2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015a5:	ff 75 0c             	pushl  0xc(%ebp)
  8015a8:	ff 75 08             	pushl  0x8(%ebp)
  8015ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	68 46 15 80 00       	push   $0x801546
  8015b7:	e8 54 01 00 00       	call   801710 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015c5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	e8 dd ea ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  8015d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015d7:	c9                   	leave  
  8015d8:	c3                   	ret    

008015d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015e2:	50                   	push   %eax
  8015e3:	ff 75 08             	pushl  0x8(%ebp)
  8015e6:	e8 9d ff ff ff       	call   801588 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	57                   	push   %edi
  8015f1:	56                   	push   %esi
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 1c             	sub    $0x1c,%esp
  8015f6:	89 c7                	mov    %eax,%edi
  8015f8:	89 d6                	mov    %edx,%esi
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801603:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801606:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801609:	bb 00 00 00 00       	mov    $0x0,%ebx
  80160e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801611:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801614:	39 d3                	cmp    %edx,%ebx
  801616:	72 05                	jb     80161d <printnum+0x30>
  801618:	39 45 10             	cmp    %eax,0x10(%ebp)
  80161b:	77 45                	ja     801662 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80161d:	83 ec 0c             	sub    $0xc,%esp
  801620:	ff 75 18             	pushl  0x18(%ebp)
  801623:	8b 45 14             	mov    0x14(%ebp),%eax
  801626:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801629:	53                   	push   %ebx
  80162a:	ff 75 10             	pushl  0x10(%ebp)
  80162d:	83 ec 08             	sub    $0x8,%esp
  801630:	ff 75 e4             	pushl  -0x1c(%ebp)
  801633:	ff 75 e0             	pushl  -0x20(%ebp)
  801636:	ff 75 dc             	pushl  -0x24(%ebp)
  801639:	ff 75 d8             	pushl  -0x28(%ebp)
  80163c:	e8 9f 09 00 00       	call   801fe0 <__udivdi3>
  801641:	83 c4 18             	add    $0x18,%esp
  801644:	52                   	push   %edx
  801645:	50                   	push   %eax
  801646:	89 f2                	mov    %esi,%edx
  801648:	89 f8                	mov    %edi,%eax
  80164a:	e8 9e ff ff ff       	call   8015ed <printnum>
  80164f:	83 c4 20             	add    $0x20,%esp
  801652:	eb 18                	jmp    80166c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	56                   	push   %esi
  801658:	ff 75 18             	pushl  0x18(%ebp)
  80165b:	ff d7                	call   *%edi
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	eb 03                	jmp    801665 <printnum+0x78>
  801662:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801665:	83 eb 01             	sub    $0x1,%ebx
  801668:	85 db                	test   %ebx,%ebx
  80166a:	7f e8                	jg     801654 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	56                   	push   %esi
  801670:	83 ec 04             	sub    $0x4,%esp
  801673:	ff 75 e4             	pushl  -0x1c(%ebp)
  801676:	ff 75 e0             	pushl  -0x20(%ebp)
  801679:	ff 75 dc             	pushl  -0x24(%ebp)
  80167c:	ff 75 d8             	pushl  -0x28(%ebp)
  80167f:	e8 8c 0a 00 00       	call   802110 <__umoddi3>
  801684:	83 c4 14             	add    $0x14,%esp
  801687:	0f be 80 0f 24 80 00 	movsbl 0x80240f(%eax),%eax
  80168e:	50                   	push   %eax
  80168f:	ff d7                	call   *%edi
}
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801697:	5b                   	pop    %ebx
  801698:	5e                   	pop    %esi
  801699:	5f                   	pop    %edi
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80169f:	83 fa 01             	cmp    $0x1,%edx
  8016a2:	7e 0e                	jle    8016b2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016a4:	8b 10                	mov    (%eax),%edx
  8016a6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016a9:	89 08                	mov    %ecx,(%eax)
  8016ab:	8b 02                	mov    (%edx),%eax
  8016ad:	8b 52 04             	mov    0x4(%edx),%edx
  8016b0:	eb 22                	jmp    8016d4 <getuint+0x38>
	else if (lflag)
  8016b2:	85 d2                	test   %edx,%edx
  8016b4:	74 10                	je     8016c6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016b6:	8b 10                	mov    (%eax),%edx
  8016b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016bb:	89 08                	mov    %ecx,(%eax)
  8016bd:	8b 02                	mov    (%edx),%eax
  8016bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c4:	eb 0e                	jmp    8016d4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016c6:	8b 10                	mov    (%eax),%edx
  8016c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016cb:	89 08                	mov    %ecx,(%eax)
  8016cd:	8b 02                	mov    (%edx),%eax
  8016cf:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016dc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016e0:	8b 10                	mov    (%eax),%edx
  8016e2:	3b 50 04             	cmp    0x4(%eax),%edx
  8016e5:	73 0a                	jae    8016f1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016e7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016ea:	89 08                	mov    %ecx,(%eax)
  8016ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ef:	88 02                	mov    %al,(%edx)
}
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016f9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016fc:	50                   	push   %eax
  8016fd:	ff 75 10             	pushl  0x10(%ebp)
  801700:	ff 75 0c             	pushl  0xc(%ebp)
  801703:	ff 75 08             	pushl  0x8(%ebp)
  801706:	e8 05 00 00 00       	call   801710 <vprintfmt>
	va_end(ap);
}
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	c9                   	leave  
  80170f:	c3                   	ret    

00801710 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	57                   	push   %edi
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
  801716:	83 ec 2c             	sub    $0x2c,%esp
  801719:	8b 75 08             	mov    0x8(%ebp),%esi
  80171c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80171f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801722:	eb 12                	jmp    801736 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801724:	85 c0                	test   %eax,%eax
  801726:	0f 84 89 03 00 00    	je     801ab5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	53                   	push   %ebx
  801730:	50                   	push   %eax
  801731:	ff d6                	call   *%esi
  801733:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801736:	83 c7 01             	add    $0x1,%edi
  801739:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80173d:	83 f8 25             	cmp    $0x25,%eax
  801740:	75 e2                	jne    801724 <vprintfmt+0x14>
  801742:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801746:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80174d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801754:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80175b:	ba 00 00 00 00       	mov    $0x0,%edx
  801760:	eb 07                	jmp    801769 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801762:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801765:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801769:	8d 47 01             	lea    0x1(%edi),%eax
  80176c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80176f:	0f b6 07             	movzbl (%edi),%eax
  801772:	0f b6 c8             	movzbl %al,%ecx
  801775:	83 e8 23             	sub    $0x23,%eax
  801778:	3c 55                	cmp    $0x55,%al
  80177a:	0f 87 1a 03 00 00    	ja     801a9a <vprintfmt+0x38a>
  801780:	0f b6 c0             	movzbl %al,%eax
  801783:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  80178a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80178d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801791:	eb d6                	jmp    801769 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801796:	b8 00 00 00 00       	mov    $0x0,%eax
  80179b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80179e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017a1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017a5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017a8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017ab:	83 fa 09             	cmp    $0x9,%edx
  8017ae:	77 39                	ja     8017e9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017b3:	eb e9                	jmp    80179e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b8:	8d 48 04             	lea    0x4(%eax),%ecx
  8017bb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017be:	8b 00                	mov    (%eax),%eax
  8017c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017c6:	eb 27                	jmp    8017ef <vprintfmt+0xdf>
  8017c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017d2:	0f 49 c8             	cmovns %eax,%ecx
  8017d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017db:	eb 8c                	jmp    801769 <vprintfmt+0x59>
  8017dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017e0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017e7:	eb 80                	jmp    801769 <vprintfmt+0x59>
  8017e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017ec:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017f3:	0f 89 70 ff ff ff    	jns    801769 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801806:	e9 5e ff ff ff       	jmp    801769 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80180b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801811:	e9 53 ff ff ff       	jmp    801769 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801816:	8b 45 14             	mov    0x14(%ebp),%eax
  801819:	8d 50 04             	lea    0x4(%eax),%edx
  80181c:	89 55 14             	mov    %edx,0x14(%ebp)
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	53                   	push   %ebx
  801823:	ff 30                	pushl  (%eax)
  801825:	ff d6                	call   *%esi
			break;
  801827:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80182d:	e9 04 ff ff ff       	jmp    801736 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801832:	8b 45 14             	mov    0x14(%ebp),%eax
  801835:	8d 50 04             	lea    0x4(%eax),%edx
  801838:	89 55 14             	mov    %edx,0x14(%ebp)
  80183b:	8b 00                	mov    (%eax),%eax
  80183d:	99                   	cltd   
  80183e:	31 d0                	xor    %edx,%eax
  801840:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801842:	83 f8 0f             	cmp    $0xf,%eax
  801845:	7f 0b                	jg     801852 <vprintfmt+0x142>
  801847:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80184e:	85 d2                	test   %edx,%edx
  801850:	75 18                	jne    80186a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801852:	50                   	push   %eax
  801853:	68 27 24 80 00       	push   $0x802427
  801858:	53                   	push   %ebx
  801859:	56                   	push   %esi
  80185a:	e8 94 fe ff ff       	call   8016f3 <printfmt>
  80185f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801862:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801865:	e9 cc fe ff ff       	jmp    801736 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80186a:	52                   	push   %edx
  80186b:	68 6d 23 80 00       	push   $0x80236d
  801870:	53                   	push   %ebx
  801871:	56                   	push   %esi
  801872:	e8 7c fe ff ff       	call   8016f3 <printfmt>
  801877:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80187a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80187d:	e9 b4 fe ff ff       	jmp    801736 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801882:	8b 45 14             	mov    0x14(%ebp),%eax
  801885:	8d 50 04             	lea    0x4(%eax),%edx
  801888:	89 55 14             	mov    %edx,0x14(%ebp)
  80188b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80188d:	85 ff                	test   %edi,%edi
  80188f:	b8 20 24 80 00       	mov    $0x802420,%eax
  801894:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801897:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80189b:	0f 8e 94 00 00 00    	jle    801935 <vprintfmt+0x225>
  8018a1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018a5:	0f 84 98 00 00 00    	je     801943 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ab:	83 ec 08             	sub    $0x8,%esp
  8018ae:	ff 75 d0             	pushl  -0x30(%ebp)
  8018b1:	57                   	push   %edi
  8018b2:	e8 86 02 00 00       	call   801b3d <strnlen>
  8018b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018ba:	29 c1                	sub    %eax,%ecx
  8018bc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018bf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018c2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018cc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ce:	eb 0f                	jmp    8018df <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	53                   	push   %ebx
  8018d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018d7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d9:	83 ef 01             	sub    $0x1,%edi
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 ff                	test   %edi,%edi
  8018e1:	7f ed                	jg     8018d0 <vprintfmt+0x1c0>
  8018e3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018e6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018e9:	85 c9                	test   %ecx,%ecx
  8018eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f0:	0f 49 c1             	cmovns %ecx,%eax
  8018f3:	29 c1                	sub    %eax,%ecx
  8018f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018fe:	89 cb                	mov    %ecx,%ebx
  801900:	eb 4d                	jmp    80194f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801902:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801906:	74 1b                	je     801923 <vprintfmt+0x213>
  801908:	0f be c0             	movsbl %al,%eax
  80190b:	83 e8 20             	sub    $0x20,%eax
  80190e:	83 f8 5e             	cmp    $0x5e,%eax
  801911:	76 10                	jbe    801923 <vprintfmt+0x213>
					putch('?', putdat);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	6a 3f                	push   $0x3f
  80191b:	ff 55 08             	call   *0x8(%ebp)
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	eb 0d                	jmp    801930 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	52                   	push   %edx
  80192a:	ff 55 08             	call   *0x8(%ebp)
  80192d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801930:	83 eb 01             	sub    $0x1,%ebx
  801933:	eb 1a                	jmp    80194f <vprintfmt+0x23f>
  801935:	89 75 08             	mov    %esi,0x8(%ebp)
  801938:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80193b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80193e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801941:	eb 0c                	jmp    80194f <vprintfmt+0x23f>
  801943:	89 75 08             	mov    %esi,0x8(%ebp)
  801946:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801949:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80194c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80194f:	83 c7 01             	add    $0x1,%edi
  801952:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801956:	0f be d0             	movsbl %al,%edx
  801959:	85 d2                	test   %edx,%edx
  80195b:	74 23                	je     801980 <vprintfmt+0x270>
  80195d:	85 f6                	test   %esi,%esi
  80195f:	78 a1                	js     801902 <vprintfmt+0x1f2>
  801961:	83 ee 01             	sub    $0x1,%esi
  801964:	79 9c                	jns    801902 <vprintfmt+0x1f2>
  801966:	89 df                	mov    %ebx,%edi
  801968:	8b 75 08             	mov    0x8(%ebp),%esi
  80196b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80196e:	eb 18                	jmp    801988 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801970:	83 ec 08             	sub    $0x8,%esp
  801973:	53                   	push   %ebx
  801974:	6a 20                	push   $0x20
  801976:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801978:	83 ef 01             	sub    $0x1,%edi
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	eb 08                	jmp    801988 <vprintfmt+0x278>
  801980:	89 df                	mov    %ebx,%edi
  801982:	8b 75 08             	mov    0x8(%ebp),%esi
  801985:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801988:	85 ff                	test   %edi,%edi
  80198a:	7f e4                	jg     801970 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80198c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80198f:	e9 a2 fd ff ff       	jmp    801736 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801994:	83 fa 01             	cmp    $0x1,%edx
  801997:	7e 16                	jle    8019af <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801999:	8b 45 14             	mov    0x14(%ebp),%eax
  80199c:	8d 50 08             	lea    0x8(%eax),%edx
  80199f:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a2:	8b 50 04             	mov    0x4(%eax),%edx
  8019a5:	8b 00                	mov    (%eax),%eax
  8019a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019ad:	eb 32                	jmp    8019e1 <vprintfmt+0x2d1>
	else if (lflag)
  8019af:	85 d2                	test   %edx,%edx
  8019b1:	74 18                	je     8019cb <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b6:	8d 50 04             	lea    0x4(%eax),%edx
  8019b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8019bc:	8b 00                	mov    (%eax),%eax
  8019be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c1:	89 c1                	mov    %eax,%ecx
  8019c3:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019c9:	eb 16                	jmp    8019e1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ce:	8d 50 04             	lea    0x4(%eax),%edx
  8019d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d4:	8b 00                	mov    (%eax),%eax
  8019d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d9:	89 c1                	mov    %eax,%ecx
  8019db:	c1 f9 1f             	sar    $0x1f,%ecx
  8019de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019ec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019f0:	79 74                	jns    801a66 <vprintfmt+0x356>
				putch('-', putdat);
  8019f2:	83 ec 08             	sub    $0x8,%esp
  8019f5:	53                   	push   %ebx
  8019f6:	6a 2d                	push   $0x2d
  8019f8:	ff d6                	call   *%esi
				num = -(long long) num;
  8019fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a00:	f7 d8                	neg    %eax
  801a02:	83 d2 00             	adc    $0x0,%edx
  801a05:	f7 da                	neg    %edx
  801a07:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a0a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a0f:	eb 55                	jmp    801a66 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a11:	8d 45 14             	lea    0x14(%ebp),%eax
  801a14:	e8 83 fc ff ff       	call   80169c <getuint>
			base = 10;
  801a19:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a1e:	eb 46                	jmp    801a66 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a20:	8d 45 14             	lea    0x14(%ebp),%eax
  801a23:	e8 74 fc ff ff       	call   80169c <getuint>
			base = 8;
  801a28:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a2d:	eb 37                	jmp    801a66 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a2f:	83 ec 08             	sub    $0x8,%esp
  801a32:	53                   	push   %ebx
  801a33:	6a 30                	push   $0x30
  801a35:	ff d6                	call   *%esi
			putch('x', putdat);
  801a37:	83 c4 08             	add    $0x8,%esp
  801a3a:	53                   	push   %ebx
  801a3b:	6a 78                	push   $0x78
  801a3d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a3f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a42:	8d 50 04             	lea    0x4(%eax),%edx
  801a45:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a48:	8b 00                	mov    (%eax),%eax
  801a4a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a4f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a52:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a57:	eb 0d                	jmp    801a66 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a59:	8d 45 14             	lea    0x14(%ebp),%eax
  801a5c:	e8 3b fc ff ff       	call   80169c <getuint>
			base = 16;
  801a61:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a6d:	57                   	push   %edi
  801a6e:	ff 75 e0             	pushl  -0x20(%ebp)
  801a71:	51                   	push   %ecx
  801a72:	52                   	push   %edx
  801a73:	50                   	push   %eax
  801a74:	89 da                	mov    %ebx,%edx
  801a76:	89 f0                	mov    %esi,%eax
  801a78:	e8 70 fb ff ff       	call   8015ed <printnum>
			break;
  801a7d:	83 c4 20             	add    $0x20,%esp
  801a80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a83:	e9 ae fc ff ff       	jmp    801736 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a88:	83 ec 08             	sub    $0x8,%esp
  801a8b:	53                   	push   %ebx
  801a8c:	51                   	push   %ecx
  801a8d:	ff d6                	call   *%esi
			break;
  801a8f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a95:	e9 9c fc ff ff       	jmp    801736 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a9a:	83 ec 08             	sub    $0x8,%esp
  801a9d:	53                   	push   %ebx
  801a9e:	6a 25                	push   $0x25
  801aa0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	eb 03                	jmp    801aaa <vprintfmt+0x39a>
  801aa7:	83 ef 01             	sub    $0x1,%edi
  801aaa:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aae:	75 f7                	jne    801aa7 <vprintfmt+0x397>
  801ab0:	e9 81 fc ff ff       	jmp    801736 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab8:	5b                   	pop    %ebx
  801ab9:	5e                   	pop    %esi
  801aba:	5f                   	pop    %edi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	83 ec 18             	sub    $0x18,%esp
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ac9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801acc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ad0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ad3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ada:	85 c0                	test   %eax,%eax
  801adc:	74 26                	je     801b04 <vsnprintf+0x47>
  801ade:	85 d2                	test   %edx,%edx
  801ae0:	7e 22                	jle    801b04 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ae2:	ff 75 14             	pushl  0x14(%ebp)
  801ae5:	ff 75 10             	pushl  0x10(%ebp)
  801ae8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801aeb:	50                   	push   %eax
  801aec:	68 d6 16 80 00       	push   $0x8016d6
  801af1:	e8 1a fc ff ff       	call   801710 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801af6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801af9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	eb 05                	jmp    801b09 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b11:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b14:	50                   	push   %eax
  801b15:	ff 75 10             	pushl  0x10(%ebp)
  801b18:	ff 75 0c             	pushl  0xc(%ebp)
  801b1b:	ff 75 08             	pushl  0x8(%ebp)
  801b1e:	e8 9a ff ff ff       	call   801abd <vsnprintf>
	va_end(ap);

	return rc;
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b30:	eb 03                	jmp    801b35 <strlen+0x10>
		n++;
  801b32:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b35:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b39:	75 f7                	jne    801b32 <strlen+0xd>
		n++;
	return n;
}
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b43:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b46:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4b:	eb 03                	jmp    801b50 <strnlen+0x13>
		n++;
  801b4d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b50:	39 c2                	cmp    %eax,%edx
  801b52:	74 08                	je     801b5c <strnlen+0x1f>
  801b54:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b58:	75 f3                	jne    801b4d <strnlen+0x10>
  801b5a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	53                   	push   %ebx
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b68:	89 c2                	mov    %eax,%edx
  801b6a:	83 c2 01             	add    $0x1,%edx
  801b6d:	83 c1 01             	add    $0x1,%ecx
  801b70:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b74:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b77:	84 db                	test   %bl,%bl
  801b79:	75 ef                	jne    801b6a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b7b:	5b                   	pop    %ebx
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	53                   	push   %ebx
  801b82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b85:	53                   	push   %ebx
  801b86:	e8 9a ff ff ff       	call   801b25 <strlen>
  801b8b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b8e:	ff 75 0c             	pushl  0xc(%ebp)
  801b91:	01 d8                	add    %ebx,%eax
  801b93:	50                   	push   %eax
  801b94:	e8 c5 ff ff ff       	call   801b5e <strcpy>
	return dst;
}
  801b99:	89 d8                	mov    %ebx,%eax
  801b9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9e:	c9                   	leave  
  801b9f:	c3                   	ret    

00801ba0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	56                   	push   %esi
  801ba4:	53                   	push   %ebx
  801ba5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bab:	89 f3                	mov    %esi,%ebx
  801bad:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb0:	89 f2                	mov    %esi,%edx
  801bb2:	eb 0f                	jmp    801bc3 <strncpy+0x23>
		*dst++ = *src;
  801bb4:	83 c2 01             	add    $0x1,%edx
  801bb7:	0f b6 01             	movzbl (%ecx),%eax
  801bba:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bbd:	80 39 01             	cmpb   $0x1,(%ecx)
  801bc0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bc3:	39 da                	cmp    %ebx,%edx
  801bc5:	75 ed                	jne    801bb4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bc7:	89 f0                	mov    %esi,%eax
  801bc9:	5b                   	pop    %ebx
  801bca:	5e                   	pop    %esi
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd8:	8b 55 10             	mov    0x10(%ebp),%edx
  801bdb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bdd:	85 d2                	test   %edx,%edx
  801bdf:	74 21                	je     801c02 <strlcpy+0x35>
  801be1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801be5:	89 f2                	mov    %esi,%edx
  801be7:	eb 09                	jmp    801bf2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801be9:	83 c2 01             	add    $0x1,%edx
  801bec:	83 c1 01             	add    $0x1,%ecx
  801bef:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bf2:	39 c2                	cmp    %eax,%edx
  801bf4:	74 09                	je     801bff <strlcpy+0x32>
  801bf6:	0f b6 19             	movzbl (%ecx),%ebx
  801bf9:	84 db                	test   %bl,%bl
  801bfb:	75 ec                	jne    801be9 <strlcpy+0x1c>
  801bfd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bff:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c02:	29 f0                	sub    %esi,%eax
}
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c11:	eb 06                	jmp    801c19 <strcmp+0x11>
		p++, q++;
  801c13:	83 c1 01             	add    $0x1,%ecx
  801c16:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c19:	0f b6 01             	movzbl (%ecx),%eax
  801c1c:	84 c0                	test   %al,%al
  801c1e:	74 04                	je     801c24 <strcmp+0x1c>
  801c20:	3a 02                	cmp    (%edx),%al
  801c22:	74 ef                	je     801c13 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c24:	0f b6 c0             	movzbl %al,%eax
  801c27:	0f b6 12             	movzbl (%edx),%edx
  801c2a:	29 d0                	sub    %edx,%eax
}
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	53                   	push   %ebx
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c3d:	eb 06                	jmp    801c45 <strncmp+0x17>
		n--, p++, q++;
  801c3f:	83 c0 01             	add    $0x1,%eax
  801c42:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c45:	39 d8                	cmp    %ebx,%eax
  801c47:	74 15                	je     801c5e <strncmp+0x30>
  801c49:	0f b6 08             	movzbl (%eax),%ecx
  801c4c:	84 c9                	test   %cl,%cl
  801c4e:	74 04                	je     801c54 <strncmp+0x26>
  801c50:	3a 0a                	cmp    (%edx),%cl
  801c52:	74 eb                	je     801c3f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c54:	0f b6 00             	movzbl (%eax),%eax
  801c57:	0f b6 12             	movzbl (%edx),%edx
  801c5a:	29 d0                	sub    %edx,%eax
  801c5c:	eb 05                	jmp    801c63 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c5e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c63:	5b                   	pop    %ebx
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c70:	eb 07                	jmp    801c79 <strchr+0x13>
		if (*s == c)
  801c72:	38 ca                	cmp    %cl,%dl
  801c74:	74 0f                	je     801c85 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c76:	83 c0 01             	add    $0x1,%eax
  801c79:	0f b6 10             	movzbl (%eax),%edx
  801c7c:	84 d2                	test   %dl,%dl
  801c7e:	75 f2                	jne    801c72 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c91:	eb 03                	jmp    801c96 <strfind+0xf>
  801c93:	83 c0 01             	add    $0x1,%eax
  801c96:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c99:	38 ca                	cmp    %cl,%dl
  801c9b:	74 04                	je     801ca1 <strfind+0x1a>
  801c9d:	84 d2                	test   %dl,%dl
  801c9f:	75 f2                	jne    801c93 <strfind+0xc>
			break;
	return (char *) s;
}
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	57                   	push   %edi
  801ca7:	56                   	push   %esi
  801ca8:	53                   	push   %ebx
  801ca9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801caf:	85 c9                	test   %ecx,%ecx
  801cb1:	74 36                	je     801ce9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cb3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cb9:	75 28                	jne    801ce3 <memset+0x40>
  801cbb:	f6 c1 03             	test   $0x3,%cl
  801cbe:	75 23                	jne    801ce3 <memset+0x40>
		c &= 0xFF;
  801cc0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cc4:	89 d3                	mov    %edx,%ebx
  801cc6:	c1 e3 08             	shl    $0x8,%ebx
  801cc9:	89 d6                	mov    %edx,%esi
  801ccb:	c1 e6 18             	shl    $0x18,%esi
  801cce:	89 d0                	mov    %edx,%eax
  801cd0:	c1 e0 10             	shl    $0x10,%eax
  801cd3:	09 f0                	or     %esi,%eax
  801cd5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cd7:	89 d8                	mov    %ebx,%eax
  801cd9:	09 d0                	or     %edx,%eax
  801cdb:	c1 e9 02             	shr    $0x2,%ecx
  801cde:	fc                   	cld    
  801cdf:	f3 ab                	rep stos %eax,%es:(%edi)
  801ce1:	eb 06                	jmp    801ce9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce6:	fc                   	cld    
  801ce7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ce9:	89 f8                	mov    %edi,%eax
  801ceb:	5b                   	pop    %ebx
  801cec:	5e                   	pop    %esi
  801ced:	5f                   	pop    %edi
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	57                   	push   %edi
  801cf4:	56                   	push   %esi
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cfb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cfe:	39 c6                	cmp    %eax,%esi
  801d00:	73 35                	jae    801d37 <memmove+0x47>
  801d02:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d05:	39 d0                	cmp    %edx,%eax
  801d07:	73 2e                	jae    801d37 <memmove+0x47>
		s += n;
		d += n;
  801d09:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d0c:	89 d6                	mov    %edx,%esi
  801d0e:	09 fe                	or     %edi,%esi
  801d10:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d16:	75 13                	jne    801d2b <memmove+0x3b>
  801d18:	f6 c1 03             	test   $0x3,%cl
  801d1b:	75 0e                	jne    801d2b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d1d:	83 ef 04             	sub    $0x4,%edi
  801d20:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d23:	c1 e9 02             	shr    $0x2,%ecx
  801d26:	fd                   	std    
  801d27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d29:	eb 09                	jmp    801d34 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d2b:	83 ef 01             	sub    $0x1,%edi
  801d2e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d31:	fd                   	std    
  801d32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d34:	fc                   	cld    
  801d35:	eb 1d                	jmp    801d54 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d37:	89 f2                	mov    %esi,%edx
  801d39:	09 c2                	or     %eax,%edx
  801d3b:	f6 c2 03             	test   $0x3,%dl
  801d3e:	75 0f                	jne    801d4f <memmove+0x5f>
  801d40:	f6 c1 03             	test   $0x3,%cl
  801d43:	75 0a                	jne    801d4f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d45:	c1 e9 02             	shr    $0x2,%ecx
  801d48:	89 c7                	mov    %eax,%edi
  801d4a:	fc                   	cld    
  801d4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d4d:	eb 05                	jmp    801d54 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d4f:	89 c7                	mov    %eax,%edi
  801d51:	fc                   	cld    
  801d52:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d54:	5e                   	pop    %esi
  801d55:	5f                   	pop    %edi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d5b:	ff 75 10             	pushl  0x10(%ebp)
  801d5e:	ff 75 0c             	pushl  0xc(%ebp)
  801d61:	ff 75 08             	pushl  0x8(%ebp)
  801d64:	e8 87 ff ff ff       	call   801cf0 <memmove>
}
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    

00801d6b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	56                   	push   %esi
  801d6f:	53                   	push   %ebx
  801d70:	8b 45 08             	mov    0x8(%ebp),%eax
  801d73:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d76:	89 c6                	mov    %eax,%esi
  801d78:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d7b:	eb 1a                	jmp    801d97 <memcmp+0x2c>
		if (*s1 != *s2)
  801d7d:	0f b6 08             	movzbl (%eax),%ecx
  801d80:	0f b6 1a             	movzbl (%edx),%ebx
  801d83:	38 d9                	cmp    %bl,%cl
  801d85:	74 0a                	je     801d91 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d87:	0f b6 c1             	movzbl %cl,%eax
  801d8a:	0f b6 db             	movzbl %bl,%ebx
  801d8d:	29 d8                	sub    %ebx,%eax
  801d8f:	eb 0f                	jmp    801da0 <memcmp+0x35>
		s1++, s2++;
  801d91:	83 c0 01             	add    $0x1,%eax
  801d94:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d97:	39 f0                	cmp    %esi,%eax
  801d99:	75 e2                	jne    801d7d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	53                   	push   %ebx
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dab:	89 c1                	mov    %eax,%ecx
  801dad:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801db0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db4:	eb 0a                	jmp    801dc0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801db6:	0f b6 10             	movzbl (%eax),%edx
  801db9:	39 da                	cmp    %ebx,%edx
  801dbb:	74 07                	je     801dc4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dbd:	83 c0 01             	add    $0x1,%eax
  801dc0:	39 c8                	cmp    %ecx,%eax
  801dc2:	72 f2                	jb     801db6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dc4:	5b                   	pop    %ebx
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	57                   	push   %edi
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dd3:	eb 03                	jmp    801dd8 <strtol+0x11>
		s++;
  801dd5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dd8:	0f b6 01             	movzbl (%ecx),%eax
  801ddb:	3c 20                	cmp    $0x20,%al
  801ddd:	74 f6                	je     801dd5 <strtol+0xe>
  801ddf:	3c 09                	cmp    $0x9,%al
  801de1:	74 f2                	je     801dd5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801de3:	3c 2b                	cmp    $0x2b,%al
  801de5:	75 0a                	jne    801df1 <strtol+0x2a>
		s++;
  801de7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dea:	bf 00 00 00 00       	mov    $0x0,%edi
  801def:	eb 11                	jmp    801e02 <strtol+0x3b>
  801df1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801df6:	3c 2d                	cmp    $0x2d,%al
  801df8:	75 08                	jne    801e02 <strtol+0x3b>
		s++, neg = 1;
  801dfa:	83 c1 01             	add    $0x1,%ecx
  801dfd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e02:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e08:	75 15                	jne    801e1f <strtol+0x58>
  801e0a:	80 39 30             	cmpb   $0x30,(%ecx)
  801e0d:	75 10                	jne    801e1f <strtol+0x58>
  801e0f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e13:	75 7c                	jne    801e91 <strtol+0xca>
		s += 2, base = 16;
  801e15:	83 c1 02             	add    $0x2,%ecx
  801e18:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e1d:	eb 16                	jmp    801e35 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e1f:	85 db                	test   %ebx,%ebx
  801e21:	75 12                	jne    801e35 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e23:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e28:	80 39 30             	cmpb   $0x30,(%ecx)
  801e2b:	75 08                	jne    801e35 <strtol+0x6e>
		s++, base = 8;
  801e2d:	83 c1 01             	add    $0x1,%ecx
  801e30:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e35:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e3d:	0f b6 11             	movzbl (%ecx),%edx
  801e40:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e43:	89 f3                	mov    %esi,%ebx
  801e45:	80 fb 09             	cmp    $0x9,%bl
  801e48:	77 08                	ja     801e52 <strtol+0x8b>
			dig = *s - '0';
  801e4a:	0f be d2             	movsbl %dl,%edx
  801e4d:	83 ea 30             	sub    $0x30,%edx
  801e50:	eb 22                	jmp    801e74 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e52:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e55:	89 f3                	mov    %esi,%ebx
  801e57:	80 fb 19             	cmp    $0x19,%bl
  801e5a:	77 08                	ja     801e64 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e5c:	0f be d2             	movsbl %dl,%edx
  801e5f:	83 ea 57             	sub    $0x57,%edx
  801e62:	eb 10                	jmp    801e74 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e64:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e67:	89 f3                	mov    %esi,%ebx
  801e69:	80 fb 19             	cmp    $0x19,%bl
  801e6c:	77 16                	ja     801e84 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e6e:	0f be d2             	movsbl %dl,%edx
  801e71:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e74:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e77:	7d 0b                	jge    801e84 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e79:	83 c1 01             	add    $0x1,%ecx
  801e7c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e80:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e82:	eb b9                	jmp    801e3d <strtol+0x76>

	if (endptr)
  801e84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e88:	74 0d                	je     801e97 <strtol+0xd0>
		*endptr = (char *) s;
  801e8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e8d:	89 0e                	mov    %ecx,(%esi)
  801e8f:	eb 06                	jmp    801e97 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e91:	85 db                	test   %ebx,%ebx
  801e93:	74 98                	je     801e2d <strtol+0x66>
  801e95:	eb 9e                	jmp    801e35 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e97:	89 c2                	mov    %eax,%edx
  801e99:	f7 da                	neg    %edx
  801e9b:	85 ff                	test   %edi,%edi
  801e9d:	0f 45 c2             	cmovne %edx,%eax
}
  801ea0:	5b                   	pop    %ebx
  801ea1:	5e                   	pop    %esi
  801ea2:	5f                   	pop    %edi
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    

00801ea5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	56                   	push   %esi
  801ea9:	53                   	push   %ebx
  801eaa:	8b 75 08             	mov    0x8(%ebp),%esi
  801ead:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801eb3:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801eb5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eba:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ebd:	83 ec 0c             	sub    $0xc,%esp
  801ec0:	50                   	push   %eax
  801ec1:	e8 54 e4 ff ff       	call   80031a <sys_ipc_recv>

	if (from_env_store != NULL)
  801ec6:	83 c4 10             	add    $0x10,%esp
  801ec9:	85 f6                	test   %esi,%esi
  801ecb:	74 14                	je     801ee1 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ecd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	78 09                	js     801edf <ipc_recv+0x3a>
  801ed6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801edc:	8b 52 74             	mov    0x74(%edx),%edx
  801edf:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ee1:	85 db                	test   %ebx,%ebx
  801ee3:	74 14                	je     801ef9 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ee5:	ba 00 00 00 00       	mov    $0x0,%edx
  801eea:	85 c0                	test   %eax,%eax
  801eec:	78 09                	js     801ef7 <ipc_recv+0x52>
  801eee:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ef4:	8b 52 78             	mov    0x78(%edx),%edx
  801ef7:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 08                	js     801f05 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801efd:	a1 08 40 80 00       	mov    0x804008,%eax
  801f02:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	53                   	push   %ebx
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f18:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f1e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f20:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f25:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f28:	ff 75 14             	pushl  0x14(%ebp)
  801f2b:	53                   	push   %ebx
  801f2c:	56                   	push   %esi
  801f2d:	57                   	push   %edi
  801f2e:	e8 c4 e3 ff ff       	call   8002f7 <sys_ipc_try_send>

		if (err < 0) {
  801f33:	83 c4 10             	add    $0x10,%esp
  801f36:	85 c0                	test   %eax,%eax
  801f38:	79 1e                	jns    801f58 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f3a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f3d:	75 07                	jne    801f46 <ipc_send+0x3a>
				sys_yield();
  801f3f:	e8 07 e2 ff ff       	call   80014b <sys_yield>
  801f44:	eb e2                	jmp    801f28 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f46:	50                   	push   %eax
  801f47:	68 20 27 80 00       	push   $0x802720
  801f4c:	6a 49                	push   $0x49
  801f4e:	68 2d 27 80 00       	push   $0x80272d
  801f53:	e8 a8 f5 ff ff       	call   801500 <_panic>
		}

	} while (err < 0);

}
  801f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5f                   	pop    %edi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f74:	8b 52 50             	mov    0x50(%edx),%edx
  801f77:	39 ca                	cmp    %ecx,%edx
  801f79:	75 0d                	jne    801f88 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f7e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f83:	8b 40 48             	mov    0x48(%eax),%eax
  801f86:	eb 0f                	jmp    801f97 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f88:	83 c0 01             	add    $0x1,%eax
  801f8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f90:	75 d9                	jne    801f6b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f97:	5d                   	pop    %ebp
  801f98:	c3                   	ret    

00801f99 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9f:	89 d0                	mov    %edx,%eax
  801fa1:	c1 e8 16             	shr    $0x16,%eax
  801fa4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb0:	f6 c1 01             	test   $0x1,%cl
  801fb3:	74 1d                	je     801fd2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb5:	c1 ea 0c             	shr    $0xc,%edx
  801fb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbf:	f6 c2 01             	test   $0x1,%dl
  801fc2:	74 0e                	je     801fd2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc4:	c1 ea 0c             	shr    $0xc,%edx
  801fc7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fce:	ef 
  801fcf:	0f b7 c0             	movzwl %ax,%eax
}
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    
  801fd4:	66 90                	xchg   %ax,%ax
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffd:	89 ca                	mov    %ecx,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	75 3d                	jne    802040 <__udivdi3+0x60>
  802003:	39 cf                	cmp    %ecx,%edi
  802005:	0f 87 c5 00 00 00    	ja     8020d0 <__udivdi3+0xf0>
  80200b:	85 ff                	test   %edi,%edi
  80200d:	89 fd                	mov    %edi,%ebp
  80200f:	75 0b                	jne    80201c <__udivdi3+0x3c>
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	f7 f7                	div    %edi
  80201a:	89 c5                	mov    %eax,%ebp
  80201c:	89 c8                	mov    %ecx,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f5                	div    %ebp
  802022:	89 c1                	mov    %eax,%ecx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	89 cf                	mov    %ecx,%edi
  802028:	f7 f5                	div    %ebp
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	39 ce                	cmp    %ecx,%esi
  802042:	77 74                	ja     8020b8 <__udivdi3+0xd8>
  802044:	0f bd fe             	bsr    %esi,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0x108>
  802050:	bb 20 00 00 00       	mov    $0x20,%ebx
  802055:	89 f9                	mov    %edi,%ecx
  802057:	89 c5                	mov    %eax,%ebp
  802059:	29 fb                	sub    %edi,%ebx
  80205b:	d3 e6                	shl    %cl,%esi
  80205d:	89 d9                	mov    %ebx,%ecx
  80205f:	d3 ed                	shr    %cl,%ebp
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e0                	shl    %cl,%eax
  802065:	09 ee                	or     %ebp,%esi
  802067:	89 d9                	mov    %ebx,%ecx
  802069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206d:	89 d5                	mov    %edx,%ebp
  80206f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802073:	d3 ed                	shr    %cl,%ebp
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e2                	shl    %cl,%edx
  802079:	89 d9                	mov    %ebx,%ecx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	09 c2                	or     %eax,%edx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	89 ea                	mov    %ebp,%edx
  802083:	f7 f6                	div    %esi
  802085:	89 d5                	mov    %edx,%ebp
  802087:	89 c3                	mov    %eax,%ebx
  802089:	f7 64 24 0c          	mull   0xc(%esp)
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	72 10                	jb     8020a1 <__udivdi3+0xc1>
  802091:	8b 74 24 08          	mov    0x8(%esp),%esi
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e6                	shl    %cl,%esi
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 07                	jae    8020a4 <__udivdi3+0xc4>
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	75 03                	jne    8020a4 <__udivdi3+0xc4>
  8020a1:	83 eb 01             	sub    $0x1,%ebx
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	31 ff                	xor    %edi,%edi
  8020ba:	31 db                	xor    %ebx,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	f7 f7                	div    %edi
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 fa                	mov    %edi,%edx
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 ce                	cmp    %ecx,%esi
  8020ea:	72 0c                	jb     8020f8 <__udivdi3+0x118>
  8020ec:	31 db                	xor    %ebx,%ebx
  8020ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020f2:	0f 87 34 ff ff ff    	ja     80202c <__udivdi3+0x4c>
  8020f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020fd:	e9 2a ff ff ff       	jmp    80202c <__udivdi3+0x4c>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 d2                	test   %edx,%edx
  802129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80212d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802131:	89 f3                	mov    %esi,%ebx
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	89 74 24 04          	mov    %esi,0x4(%esp)
  80213a:	75 1c                	jne    802158 <__umoddi3+0x48>
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	76 50                	jbe    802190 <__umoddi3+0x80>
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	f7 f7                	div    %edi
  802146:	89 d0                	mov    %edx,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	77 52                	ja     8021b0 <__umoddi3+0xa0>
  80215e:	0f bd ea             	bsr    %edx,%ebp
  802161:	83 f5 1f             	xor    $0x1f,%ebp
  802164:	75 5a                	jne    8021c0 <__umoddi3+0xb0>
  802166:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	39 0c 24             	cmp    %ecx,(%esp)
  802173:	0f 86 d7 00 00 00    	jbe    802250 <__umoddi3+0x140>
  802179:	8b 44 24 08          	mov    0x8(%esp),%eax
  80217d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	85 ff                	test   %edi,%edi
  802192:	89 fd                	mov    %edi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 c8                	mov    %ecx,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	eb 99                	jmp    802148 <__umoddi3+0x38>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 34 24             	mov    (%esp),%esi
  8021c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ef                	sub    %ebp,%edi
  8021cc:	d3 e0                	shl    %cl,%eax
  8021ce:	89 f9                	mov    %edi,%ecx
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	d3 ea                	shr    %cl,%edx
  8021d4:	89 e9                	mov    %ebp,%ecx
  8021d6:	09 c2                	or     %eax,%edx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 14 24             	mov    %edx,(%esp)
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	89 c6                	mov    %eax,%esi
  8021f1:	d3 e3                	shl    %cl,%ebx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	09 d8                	or     %ebx,%eax
  8021fd:	89 d3                	mov    %edx,%ebx
  8021ff:	89 f2                	mov    %esi,%edx
  802201:	f7 34 24             	divl   (%esp)
  802204:	89 d6                	mov    %edx,%esi
  802206:	d3 e3                	shl    %cl,%ebx
  802208:	f7 64 24 04          	mull   0x4(%esp)
  80220c:	39 d6                	cmp    %edx,%esi
  80220e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802212:	89 d1                	mov    %edx,%ecx
  802214:	89 c3                	mov    %eax,%ebx
  802216:	72 08                	jb     802220 <__umoddi3+0x110>
  802218:	75 11                	jne    80222b <__umoddi3+0x11b>
  80221a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80221e:	73 0b                	jae    80222b <__umoddi3+0x11b>
  802220:	2b 44 24 04          	sub    0x4(%esp),%eax
  802224:	1b 14 24             	sbb    (%esp),%edx
  802227:	89 d1                	mov    %edx,%ecx
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80222f:	29 da                	sub    %ebx,%edx
  802231:	19 ce                	sbb    %ecx,%esi
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 f0                	mov    %esi,%eax
  802237:	d3 e0                	shl    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	d3 ea                	shr    %cl,%edx
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	09 d0                	or     %edx,%eax
  802243:	89 f2                	mov    %esi,%edx
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 f9                	sub    %edi,%ecx
  802252:	19 d6                	sbb    %edx,%esi
  802254:	89 74 24 04          	mov    %esi,0x4(%esp)
  802258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225c:	e9 18 ff ff ff       	jmp    802179 <__umoddi3+0x69>
