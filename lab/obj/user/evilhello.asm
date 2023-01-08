
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 a6 04 00 00       	call   800541 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 2a 22 80 00       	push   $0x80222a
  800114:	6a 23                	push   $0x23
  800116:	68 47 22 80 00       	push   $0x802247
  80011b:	e8 9a 13 00 00       	call   8014ba <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 2a 22 80 00       	push   $0x80222a
  800195:	6a 23                	push   $0x23
  800197:	68 47 22 80 00       	push   $0x802247
  80019c:	e8 19 13 00 00       	call   8014ba <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 2a 22 80 00       	push   $0x80222a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 47 22 80 00       	push   $0x802247
  8001de:	e8 d7 12 00 00       	call   8014ba <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 2a 22 80 00       	push   $0x80222a
  800219:	6a 23                	push   $0x23
  80021b:	68 47 22 80 00       	push   $0x802247
  800220:	e8 95 12 00 00       	call   8014ba <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 2a 22 80 00       	push   $0x80222a
  80025b:	6a 23                	push   $0x23
  80025d:	68 47 22 80 00       	push   $0x802247
  800262:	e8 53 12 00 00       	call   8014ba <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 2a 22 80 00       	push   $0x80222a
  80029d:	6a 23                	push   $0x23
  80029f:	68 47 22 80 00       	push   $0x802247
  8002a4:	e8 11 12 00 00       	call   8014ba <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 2a 22 80 00       	push   $0x80222a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 47 22 80 00       	push   $0x802247
  8002e6:	e8 cf 11 00 00       	call   8014ba <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 2a 22 80 00       	push   $0x80222a
  800343:	6a 23                	push   $0x23
  800345:	68 47 22 80 00       	push   $0x802247
  80034a:	e8 6b 11 00 00       	call   8014ba <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	05 00 00 00 30       	add    $0x30000000,%eax
  800381:	c1 e8 0c             	shr    $0xc,%eax
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	05 00 00 00 30       	add    $0x30000000,%eax
  800391:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800396:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 16             	shr    $0x16,%edx
  8003ad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	74 11                	je     8003ca <fd_alloc+0x2d>
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 0c             	shr    $0xc,%edx
  8003be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	75 09                	jne    8003d3 <fd_alloc+0x36>
			*fd_store = fd;
  8003ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d1:	eb 17                	jmp    8003ea <fd_alloc+0x4d>
  8003d3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003dd:	75 c9                	jne    8003a8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f2:	83 f8 1f             	cmp    $0x1f,%eax
  8003f5:	77 36                	ja     80042d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f7:	c1 e0 0c             	shl    $0xc,%eax
  8003fa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 16             	shr    $0x16,%edx
  800404:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 24                	je     800434 <fd_lookup+0x48>
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 0c             	shr    $0xc,%edx
  800415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 1a                	je     80043b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 02                	mov    %eax,(%edx)
	return 0;
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb 13                	jmp    800440 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800432:	eb 0c                	jmp    800440 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800439:	eb 05                	jmp    800440 <fd_lookup+0x54>
  80043b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044b:	ba d4 22 80 00       	mov    $0x8022d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800450:	eb 13                	jmp    800465 <dev_lookup+0x23>
  800452:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800455:	39 08                	cmp    %ecx,(%eax)
  800457:	75 0c                	jne    800465 <dev_lookup+0x23>
			*dev = devtab[i];
  800459:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
  800463:	eb 2e                	jmp    800493 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	85 c0                	test   %eax,%eax
  800469:	75 e7                	jne    800452 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046b:	a1 08 40 80 00       	mov    0x804008,%eax
  800470:	8b 40 48             	mov    0x48(%eax),%eax
  800473:	83 ec 04             	sub    $0x4,%esp
  800476:	51                   	push   %ecx
  800477:	50                   	push   %eax
  800478:	68 58 22 80 00       	push   $0x802258
  80047d:	e8 11 11 00 00       	call   801593 <cprintf>
	*dev = 0;
  800482:	8b 45 0c             	mov    0xc(%ebp),%eax
  800485:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800493:	c9                   	leave  
  800494:	c3                   	ret    

00800495 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 10             	sub    $0x10,%esp
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a6:	50                   	push   %eax
  8004a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ad:	c1 e8 0c             	shr    $0xc,%eax
  8004b0:	50                   	push   %eax
  8004b1:	e8 36 ff ff ff       	call   8003ec <fd_lookup>
  8004b6:	83 c4 08             	add    $0x8,%esp
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	78 05                	js     8004c2 <fd_close+0x2d>
	    || fd != fd2)
  8004bd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004c0:	74 0c                	je     8004ce <fd_close+0x39>
		return (must_exist ? r : 0);
  8004c2:	84 db                	test   %bl,%bl
  8004c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c9:	0f 44 c2             	cmove  %edx,%eax
  8004cc:	eb 41                	jmp    80050f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d4:	50                   	push   %eax
  8004d5:	ff 36                	pushl  (%esi)
  8004d7:	e8 66 ff ff ff       	call   800442 <dev_lookup>
  8004dc:	89 c3                	mov    %eax,%ebx
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	78 1a                	js     8004ff <fd_close+0x6a>
		if (dev->dev_close)
  8004e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	74 0b                	je     8004ff <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f4:	83 ec 0c             	sub    $0xc,%esp
  8004f7:	56                   	push   %esi
  8004f8:	ff d0                	call   *%eax
  8004fa:	89 c3                	mov    %eax,%ebx
  8004fc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	56                   	push   %esi
  800503:	6a 00                	push   $0x0
  800505:	e8 e1 fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	89 d8                	mov    %ebx,%eax
}
  80050f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800512:	5b                   	pop    %ebx
  800513:	5e                   	pop    %esi
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80051c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051f:	50                   	push   %eax
  800520:	ff 75 08             	pushl  0x8(%ebp)
  800523:	e8 c4 fe ff ff       	call   8003ec <fd_lookup>
  800528:	83 c4 08             	add    $0x8,%esp
  80052b:	85 c0                	test   %eax,%eax
  80052d:	78 10                	js     80053f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	6a 01                	push   $0x1
  800534:	ff 75 f4             	pushl  -0xc(%ebp)
  800537:	e8 59 ff ff ff       	call   800495 <fd_close>
  80053c:	83 c4 10             	add    $0x10,%esp
}
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <close_all>:

void
close_all(void)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	53                   	push   %ebx
  800545:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800548:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	53                   	push   %ebx
  800551:	e8 c0 ff ff ff       	call   800516 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800556:	83 c3 01             	add    $0x1,%ebx
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	83 fb 20             	cmp    $0x20,%ebx
  80055f:	75 ec                	jne    80054d <close_all+0xc>
		close(i);
}
  800561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800564:	c9                   	leave  
  800565:	c3                   	ret    

00800566 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
  800569:	57                   	push   %edi
  80056a:	56                   	push   %esi
  80056b:	53                   	push   %ebx
  80056c:	83 ec 2c             	sub    $0x2c,%esp
  80056f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800572:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800575:	50                   	push   %eax
  800576:	ff 75 08             	pushl  0x8(%ebp)
  800579:	e8 6e fe ff ff       	call   8003ec <fd_lookup>
  80057e:	83 c4 08             	add    $0x8,%esp
  800581:	85 c0                	test   %eax,%eax
  800583:	0f 88 c1 00 00 00    	js     80064a <dup+0xe4>
		return r;
	close(newfdnum);
  800589:	83 ec 0c             	sub    $0xc,%esp
  80058c:	56                   	push   %esi
  80058d:	e8 84 ff ff ff       	call   800516 <close>

	newfd = INDEX2FD(newfdnum);
  800592:	89 f3                	mov    %esi,%ebx
  800594:	c1 e3 0c             	shl    $0xc,%ebx
  800597:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80059d:	83 c4 04             	add    $0x4,%esp
  8005a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a3:	e8 de fd ff ff       	call   800386 <fd2data>
  8005a8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005aa:	89 1c 24             	mov    %ebx,(%esp)
  8005ad:	e8 d4 fd ff ff       	call   800386 <fd2data>
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b8:	89 f8                	mov    %edi,%eax
  8005ba:	c1 e8 16             	shr    $0x16,%eax
  8005bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c4:	a8 01                	test   $0x1,%al
  8005c6:	74 37                	je     8005ff <dup+0x99>
  8005c8:	89 f8                	mov    %edi,%eax
  8005ca:	c1 e8 0c             	shr    $0xc,%eax
  8005cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d4:	f6 c2 01             	test   $0x1,%dl
  8005d7:	74 26                	je     8005ff <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e8:	50                   	push   %eax
  8005e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ec:	6a 00                	push   $0x0
  8005ee:	57                   	push   %edi
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 b3 fb ff ff       	call   8001a9 <sys_page_map>
  8005f6:	89 c7                	mov    %eax,%edi
  8005f8:	83 c4 20             	add    $0x20,%esp
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	78 2e                	js     80062d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800602:	89 d0                	mov    %edx,%eax
  800604:	c1 e8 0c             	shr    $0xc,%eax
  800607:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060e:	83 ec 0c             	sub    $0xc,%esp
  800611:	25 07 0e 00 00       	and    $0xe07,%eax
  800616:	50                   	push   %eax
  800617:	53                   	push   %ebx
  800618:	6a 00                	push   $0x0
  80061a:	52                   	push   %edx
  80061b:	6a 00                	push   $0x0
  80061d:	e8 87 fb ff ff       	call   8001a9 <sys_page_map>
  800622:	89 c7                	mov    %eax,%edi
  800624:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800627:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800629:	85 ff                	test   %edi,%edi
  80062b:	79 1d                	jns    80064a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 00                	push   $0x0
  800633:	e8 b3 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063e:	6a 00                	push   $0x0
  800640:	e8 a6 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	89 f8                	mov    %edi,%eax
}
  80064a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	53                   	push   %ebx
  800656:	83 ec 14             	sub    $0x14,%esp
  800659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80065c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	53                   	push   %ebx
  800661:	e8 86 fd ff ff       	call   8003ec <fd_lookup>
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	89 c2                	mov    %eax,%edx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	78 6d                	js     8006dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800679:	ff 30                	pushl  (%eax)
  80067b:	e8 c2 fd ff ff       	call   800442 <dev_lookup>
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	78 4c                	js     8006d3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800687:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068a:	8b 42 08             	mov    0x8(%edx),%eax
  80068d:	83 e0 03             	and    $0x3,%eax
  800690:	83 f8 01             	cmp    $0x1,%eax
  800693:	75 21                	jne    8006b6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 08 40 80 00       	mov    0x804008,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	50                   	push   %eax
  8006a2:	68 99 22 80 00       	push   $0x802299
  8006a7:	e8 e7 0e 00 00       	call   801593 <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b4:	eb 26                	jmp    8006dc <read+0x8a>
	}
	if (!dev->dev_read)
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	8b 40 08             	mov    0x8(%eax),%eax
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	74 17                	je     8006d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	ff 75 0c             	pushl  0xc(%ebp)
  8006c9:	52                   	push   %edx
  8006ca:	ff d0                	call   *%eax
  8006cc:	89 c2                	mov    %eax,%edx
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 09                	jmp    8006dc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d3:	89 c2                	mov    %eax,%edx
  8006d5:	eb 05                	jmp    8006dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006dc:	89 d0                	mov    %edx,%eax
  8006de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	57                   	push   %edi
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 0c             	sub    $0xc,%esp
  8006ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f7:	eb 21                	jmp    80071a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f9:	83 ec 04             	sub    $0x4,%esp
  8006fc:	89 f0                	mov    %esi,%eax
  8006fe:	29 d8                	sub    %ebx,%eax
  800700:	50                   	push   %eax
  800701:	89 d8                	mov    %ebx,%eax
  800703:	03 45 0c             	add    0xc(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	57                   	push   %edi
  800708:	e8 45 ff ff ff       	call   800652 <read>
		if (m < 0)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	85 c0                	test   %eax,%eax
  800712:	78 10                	js     800724 <readn+0x41>
			return m;
		if (m == 0)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 0a                	je     800722 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800718:	01 c3                	add    %eax,%ebx
  80071a:	39 f3                	cmp    %esi,%ebx
  80071c:	72 db                	jb     8006f9 <readn+0x16>
  80071e:	89 d8                	mov    %ebx,%eax
  800720:	eb 02                	jmp    800724 <readn+0x41>
  800722:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800724:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800727:	5b                   	pop    %ebx
  800728:	5e                   	pop    %esi
  800729:	5f                   	pop    %edi
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	83 ec 14             	sub    $0x14,%esp
  800733:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800736:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	53                   	push   %ebx
  80073b:	e8 ac fc ff ff       	call   8003ec <fd_lookup>
  800740:	83 c4 08             	add    $0x8,%esp
  800743:	89 c2                	mov    %eax,%edx
  800745:	85 c0                	test   %eax,%eax
  800747:	78 68                	js     8007b1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074f:	50                   	push   %eax
  800750:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800753:	ff 30                	pushl  (%eax)
  800755:	e8 e8 fc ff ff       	call   800442 <dev_lookup>
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	85 c0                	test   %eax,%eax
  80075f:	78 47                	js     8007a8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800761:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800764:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800768:	75 21                	jne    80078b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076a:	a1 08 40 80 00       	mov    0x804008,%eax
  80076f:	8b 40 48             	mov    0x48(%eax),%eax
  800772:	83 ec 04             	sub    $0x4,%esp
  800775:	53                   	push   %ebx
  800776:	50                   	push   %eax
  800777:	68 b5 22 80 00       	push   $0x8022b5
  80077c:	e8 12 0e 00 00       	call   801593 <cprintf>
		return -E_INVAL;
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800789:	eb 26                	jmp    8007b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078e:	8b 52 0c             	mov    0xc(%edx),%edx
  800791:	85 d2                	test   %edx,%edx
  800793:	74 17                	je     8007ac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800795:	83 ec 04             	sub    $0x4,%esp
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	ff 75 0c             	pushl  0xc(%ebp)
  80079e:	50                   	push   %eax
  80079f:	ff d2                	call   *%edx
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	eb 09                	jmp    8007b1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a8:	89 c2                	mov    %eax,%edx
  8007aa:	eb 05                	jmp    8007b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007b1:	89 d0                	mov    %edx,%eax
  8007b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	ff 75 08             	pushl  0x8(%ebp)
  8007c5:	e8 22 fc ff ff       	call   8003ec <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 0e                	js     8007df <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 14             	sub    $0x14,%esp
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	53                   	push   %ebx
  8007f0:	e8 f7 fb ff ff       	call   8003ec <fd_lookup>
  8007f5:	83 c4 08             	add    $0x8,%esp
  8007f8:	89 c2                	mov    %eax,%edx
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 65                	js     800863 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	ff 30                	pushl  (%eax)
  80080a:	e8 33 fc ff ff       	call   800442 <dev_lookup>
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	85 c0                	test   %eax,%eax
  800814:	78 44                	js     80085a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081d:	75 21                	jne    800840 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800824:	8b 40 48             	mov    0x48(%eax),%eax
  800827:	83 ec 04             	sub    $0x4,%esp
  80082a:	53                   	push   %ebx
  80082b:	50                   	push   %eax
  80082c:	68 78 22 80 00       	push   $0x802278
  800831:	e8 5d 0d 00 00       	call   801593 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083e:	eb 23                	jmp    800863 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800840:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800843:	8b 52 18             	mov    0x18(%edx),%edx
  800846:	85 d2                	test   %edx,%edx
  800848:	74 14                	je     80085e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	50                   	push   %eax
  800851:	ff d2                	call   *%edx
  800853:	89 c2                	mov    %eax,%edx
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	eb 09                	jmp    800863 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	89 c2                	mov    %eax,%edx
  80085c:	eb 05                	jmp    800863 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800863:	89 d0                	mov    %edx,%eax
  800865:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800868:	c9                   	leave  
  800869:	c3                   	ret    

0080086a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	83 ec 14             	sub    $0x14,%esp
  800871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800874:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800877:	50                   	push   %eax
  800878:	ff 75 08             	pushl  0x8(%ebp)
  80087b:	e8 6c fb ff ff       	call   8003ec <fd_lookup>
  800880:	83 c4 08             	add    $0x8,%esp
  800883:	89 c2                	mov    %eax,%edx
  800885:	85 c0                	test   %eax,%eax
  800887:	78 58                	js     8008e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088f:	50                   	push   %eax
  800890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800893:	ff 30                	pushl  (%eax)
  800895:	e8 a8 fb ff ff       	call   800442 <dev_lookup>
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	85 c0                	test   %eax,%eax
  80089f:	78 37                	js     8008d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a8:	74 32                	je     8008dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b4:	00 00 00 
	stat->st_isdir = 0;
  8008b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008be:	00 00 00 
	stat->st_dev = dev;
  8008c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	53                   	push   %ebx
  8008cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ce:	ff 50 14             	call   *0x14(%eax)
  8008d1:	89 c2                	mov    %eax,%edx
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	eb 09                	jmp    8008e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d8:	89 c2                	mov    %eax,%edx
  8008da:	eb 05                	jmp    8008e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e1:	89 d0                	mov    %edx,%eax
  8008e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	6a 00                	push   $0x0
  8008f2:	ff 75 08             	pushl  0x8(%ebp)
  8008f5:	e8 d6 01 00 00       	call   800ad0 <open>
  8008fa:	89 c3                	mov    %eax,%ebx
  8008fc:	83 c4 10             	add    $0x10,%esp
  8008ff:	85 c0                	test   %eax,%eax
  800901:	78 1b                	js     80091e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800903:	83 ec 08             	sub    $0x8,%esp
  800906:	ff 75 0c             	pushl  0xc(%ebp)
  800909:	50                   	push   %eax
  80090a:	e8 5b ff ff ff       	call   80086a <fstat>
  80090f:	89 c6                	mov    %eax,%esi
	close(fd);
  800911:	89 1c 24             	mov    %ebx,(%esp)
  800914:	e8 fd fb ff ff       	call   800516 <close>
	return r;
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	89 f0                	mov    %esi,%eax
}
  80091e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	89 c6                	mov    %eax,%esi
  80092c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800935:	75 12                	jne    800949 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800937:	83 ec 0c             	sub    $0xc,%esp
  80093a:	6a 01                	push   $0x1
  80093c:	e8 d9 15 00 00       	call   801f1a <ipc_find_env>
  800941:	a3 00 40 80 00       	mov    %eax,0x804000
  800946:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800949:	6a 07                	push   $0x7
  80094b:	68 00 50 80 00       	push   $0x805000
  800950:	56                   	push   %esi
  800951:	ff 35 00 40 80 00    	pushl  0x804000
  800957:	e8 6a 15 00 00       	call   801ec6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80095c:	83 c4 0c             	add    $0xc,%esp
  80095f:	6a 00                	push   $0x0
  800961:	53                   	push   %ebx
  800962:	6a 00                	push   $0x0
  800964:	e8 f6 14 00 00       	call   801e5f <ipc_recv>
}
  800969:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 40 0c             	mov    0xc(%eax),%eax
  80097c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 02 00 00 00       	mov    $0x2,%eax
  800993:	e8 8d ff ff ff       	call   800925 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b5:	e8 6b ff ff ff       	call   800925 <fsipc>
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	83 ec 04             	sub    $0x4,%esp
  8009c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009db:	e8 45 ff ff ff       	call   800925 <fsipc>
  8009e0:	85 c0                	test   %eax,%eax
  8009e2:	78 2c                	js     800a10 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e4:	83 ec 08             	sub    $0x8,%esp
  8009e7:	68 00 50 80 00       	push   $0x805000
  8009ec:	53                   	push   %ebx
  8009ed:	e8 26 11 00 00       	call   801b18 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fd:	a1 84 50 80 00       	mov    0x805084,%eax
  800a02:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a08:	83 c4 10             	add    $0x10,%esp
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	83 ec 0c             	sub    $0xc,%esp
  800a1b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a21:	8b 52 0c             	mov    0xc(%edx),%edx
  800a24:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a2a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a2f:	50                   	push   %eax
  800a30:	ff 75 0c             	pushl  0xc(%ebp)
  800a33:	68 08 50 80 00       	push   $0x805008
  800a38:	e8 6d 12 00 00       	call   801caa <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	b8 04 00 00 00       	mov    $0x4,%eax
  800a47:	e8 d9 fe ff ff       	call   800925 <fsipc>

}
  800a4c:	c9                   	leave  
  800a4d:	c3                   	ret    

00800a4e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a61:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a71:	e8 af fe ff ff       	call   800925 <fsipc>
  800a76:	89 c3                	mov    %eax,%ebx
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	78 4b                	js     800ac7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a7c:	39 c6                	cmp    %eax,%esi
  800a7e:	73 16                	jae    800a96 <devfile_read+0x48>
  800a80:	68 e8 22 80 00       	push   $0x8022e8
  800a85:	68 ef 22 80 00       	push   $0x8022ef
  800a8a:	6a 7c                	push   $0x7c
  800a8c:	68 04 23 80 00       	push   $0x802304
  800a91:	e8 24 0a 00 00       	call   8014ba <_panic>
	assert(r <= PGSIZE);
  800a96:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9b:	7e 16                	jle    800ab3 <devfile_read+0x65>
  800a9d:	68 0f 23 80 00       	push   $0x80230f
  800aa2:	68 ef 22 80 00       	push   $0x8022ef
  800aa7:	6a 7d                	push   $0x7d
  800aa9:	68 04 23 80 00       	push   $0x802304
  800aae:	e8 07 0a 00 00       	call   8014ba <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab3:	83 ec 04             	sub    $0x4,%esp
  800ab6:	50                   	push   %eax
  800ab7:	68 00 50 80 00       	push   $0x805000
  800abc:	ff 75 0c             	pushl  0xc(%ebp)
  800abf:	e8 e6 11 00 00       	call   801caa <memmove>
	return r;
  800ac4:	83 c4 10             	add    $0x10,%esp
}
  800ac7:	89 d8                	mov    %ebx,%eax
  800ac9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	83 ec 20             	sub    $0x20,%esp
  800ad7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ada:	53                   	push   %ebx
  800adb:	e8 ff 0f 00 00       	call   801adf <strlen>
  800ae0:	83 c4 10             	add    $0x10,%esp
  800ae3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ae8:	7f 67                	jg     800b51 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aea:	83 ec 0c             	sub    $0xc,%esp
  800aed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af0:	50                   	push   %eax
  800af1:	e8 a7 f8 ff ff       	call   80039d <fd_alloc>
  800af6:	83 c4 10             	add    $0x10,%esp
		return r;
  800af9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	78 57                	js     800b56 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aff:	83 ec 08             	sub    $0x8,%esp
  800b02:	53                   	push   %ebx
  800b03:	68 00 50 80 00       	push   $0x805000
  800b08:	e8 0b 10 00 00       	call   801b18 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b10:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b18:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1d:	e8 03 fe ff ff       	call   800925 <fsipc>
  800b22:	89 c3                	mov    %eax,%ebx
  800b24:	83 c4 10             	add    $0x10,%esp
  800b27:	85 c0                	test   %eax,%eax
  800b29:	79 14                	jns    800b3f <open+0x6f>
		fd_close(fd, 0);
  800b2b:	83 ec 08             	sub    $0x8,%esp
  800b2e:	6a 00                	push   $0x0
  800b30:	ff 75 f4             	pushl  -0xc(%ebp)
  800b33:	e8 5d f9 ff ff       	call   800495 <fd_close>
		return r;
  800b38:	83 c4 10             	add    $0x10,%esp
  800b3b:	89 da                	mov    %ebx,%edx
  800b3d:	eb 17                	jmp    800b56 <open+0x86>
	}

	return fd2num(fd);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	ff 75 f4             	pushl  -0xc(%ebp)
  800b45:	e8 2c f8 ff ff       	call   800376 <fd2num>
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	eb 05                	jmp    800b56 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b51:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b56:	89 d0                	mov    %edx,%eax
  800b58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6d:	e8 b3 fd ff ff       	call   800925 <fsipc>
}
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	ff 75 08             	pushl  0x8(%ebp)
  800b82:	e8 ff f7 ff ff       	call   800386 <fd2data>
  800b87:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b89:	83 c4 08             	add    $0x8,%esp
  800b8c:	68 1b 23 80 00       	push   $0x80231b
  800b91:	53                   	push   %ebx
  800b92:	e8 81 0f 00 00       	call   801b18 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b97:	8b 46 04             	mov    0x4(%esi),%eax
  800b9a:	2b 06                	sub    (%esi),%eax
  800b9c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba9:	00 00 00 
	stat->st_dev = &devpipe;
  800bac:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb3:	30 80 00 
	return 0;
}
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bcc:	53                   	push   %ebx
  800bcd:	6a 00                	push   $0x0
  800bcf:	e8 17 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd4:	89 1c 24             	mov    %ebx,(%esp)
  800bd7:	e8 aa f7 ff ff       	call   800386 <fd2data>
  800bdc:	83 c4 08             	add    $0x8,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 00                	push   $0x0
  800be2:	e8 04 f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800be7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 1c             	sub    $0x1c,%esp
  800bf5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bf8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bfa:	a1 08 40 80 00       	mov    0x804008,%eax
  800bff:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	ff 75 e0             	pushl  -0x20(%ebp)
  800c08:	e8 46 13 00 00       	call   801f53 <pageref>
  800c0d:	89 c3                	mov    %eax,%ebx
  800c0f:	89 3c 24             	mov    %edi,(%esp)
  800c12:	e8 3c 13 00 00       	call   801f53 <pageref>
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	39 c3                	cmp    %eax,%ebx
  800c1c:	0f 94 c1             	sete   %cl
  800c1f:	0f b6 c9             	movzbl %cl,%ecx
  800c22:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c25:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c2b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c2e:	39 ce                	cmp    %ecx,%esi
  800c30:	74 1b                	je     800c4d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c32:	39 c3                	cmp    %eax,%ebx
  800c34:	75 c4                	jne    800bfa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c36:	8b 42 58             	mov    0x58(%edx),%eax
  800c39:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c3c:	50                   	push   %eax
  800c3d:	56                   	push   %esi
  800c3e:	68 22 23 80 00       	push   $0x802322
  800c43:	e8 4b 09 00 00       	call   801593 <cprintf>
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	eb ad                	jmp    800bfa <_pipeisclosed+0xe>
	}
}
  800c4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 28             	sub    $0x28,%esp
  800c61:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c64:	56                   	push   %esi
  800c65:	e8 1c f7 ff ff       	call   800386 <fd2data>
  800c6a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6c:	83 c4 10             	add    $0x10,%esp
  800c6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c74:	eb 4b                	jmp    800cc1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c76:	89 da                	mov    %ebx,%edx
  800c78:	89 f0                	mov    %esi,%eax
  800c7a:	e8 6d ff ff ff       	call   800bec <_pipeisclosed>
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	75 48                	jne    800ccb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c83:	e8 bf f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c88:	8b 43 04             	mov    0x4(%ebx),%eax
  800c8b:	8b 0b                	mov    (%ebx),%ecx
  800c8d:	8d 51 20             	lea    0x20(%ecx),%edx
  800c90:	39 d0                	cmp    %edx,%eax
  800c92:	73 e2                	jae    800c76 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9e:	89 c2                	mov    %eax,%edx
  800ca0:	c1 fa 1f             	sar    $0x1f,%edx
  800ca3:	89 d1                	mov    %edx,%ecx
  800ca5:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cab:	83 e2 1f             	and    $0x1f,%edx
  800cae:	29 ca                	sub    %ecx,%edx
  800cb0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb8:	83 c0 01             	add    $0x1,%eax
  800cbb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbe:	83 c7 01             	add    $0x1,%edi
  800cc1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc4:	75 c2                	jne    800c88 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cc6:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc9:	eb 05                	jmp    800cd0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 18             	sub    $0x18,%esp
  800ce1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce4:	57                   	push   %edi
  800ce5:	e8 9c f6 ff ff       	call   800386 <fd2data>
  800cea:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	eb 3d                	jmp    800d33 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cf6:	85 db                	test   %ebx,%ebx
  800cf8:	74 04                	je     800cfe <devpipe_read+0x26>
				return i;
  800cfa:	89 d8                	mov    %ebx,%eax
  800cfc:	eb 44                	jmp    800d42 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cfe:	89 f2                	mov    %esi,%edx
  800d00:	89 f8                	mov    %edi,%eax
  800d02:	e8 e5 fe ff ff       	call   800bec <_pipeisclosed>
  800d07:	85 c0                	test   %eax,%eax
  800d09:	75 32                	jne    800d3d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d0b:	e8 37 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d10:	8b 06                	mov    (%esi),%eax
  800d12:	3b 46 04             	cmp    0x4(%esi),%eax
  800d15:	74 df                	je     800cf6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d17:	99                   	cltd   
  800d18:	c1 ea 1b             	shr    $0x1b,%edx
  800d1b:	01 d0                	add    %edx,%eax
  800d1d:	83 e0 1f             	and    $0x1f,%eax
  800d20:	29 d0                	sub    %edx,%eax
  800d22:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d2d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d30:	83 c3 01             	add    $0x1,%ebx
  800d33:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d36:	75 d8                	jne    800d10 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d38:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3b:	eb 05                	jmp    800d42 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d55:	50                   	push   %eax
  800d56:	e8 42 f6 ff ff       	call   80039d <fd_alloc>
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	89 c2                	mov    %eax,%edx
  800d60:	85 c0                	test   %eax,%eax
  800d62:	0f 88 2c 01 00 00    	js     800e94 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d68:	83 ec 04             	sub    $0x4,%esp
  800d6b:	68 07 04 00 00       	push   $0x407
  800d70:	ff 75 f4             	pushl  -0xc(%ebp)
  800d73:	6a 00                	push   $0x0
  800d75:	e8 ec f3 ff ff       	call   800166 <sys_page_alloc>
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	89 c2                	mov    %eax,%edx
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	0f 88 0d 01 00 00    	js     800e94 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d8d:	50                   	push   %eax
  800d8e:	e8 0a f6 ff ff       	call   80039d <fd_alloc>
  800d93:	89 c3                	mov    %eax,%ebx
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	0f 88 e2 00 00 00    	js     800e82 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	68 07 04 00 00       	push   $0x407
  800da8:	ff 75 f0             	pushl  -0x10(%ebp)
  800dab:	6a 00                	push   $0x0
  800dad:	e8 b4 f3 ff ff       	call   800166 <sys_page_alloc>
  800db2:	89 c3                	mov    %eax,%ebx
  800db4:	83 c4 10             	add    $0x10,%esp
  800db7:	85 c0                	test   %eax,%eax
  800db9:	0f 88 c3 00 00 00    	js     800e82 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc5:	e8 bc f5 ff ff       	call   800386 <fd2data>
  800dca:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcc:	83 c4 0c             	add    $0xc,%esp
  800dcf:	68 07 04 00 00       	push   $0x407
  800dd4:	50                   	push   %eax
  800dd5:	6a 00                	push   $0x0
  800dd7:	e8 8a f3 ff ff       	call   800166 <sys_page_alloc>
  800ddc:	89 c3                	mov    %eax,%ebx
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	0f 88 89 00 00 00    	js     800e72 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de9:	83 ec 0c             	sub    $0xc,%esp
  800dec:	ff 75 f0             	pushl  -0x10(%ebp)
  800def:	e8 92 f5 ff ff       	call   800386 <fd2data>
  800df4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dfb:	50                   	push   %eax
  800dfc:	6a 00                	push   $0x0
  800dfe:	56                   	push   %esi
  800dff:	6a 00                	push   $0x0
  800e01:	e8 a3 f3 ff ff       	call   8001a9 <sys_page_map>
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	83 c4 20             	add    $0x20,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	78 55                	js     800e64 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e0f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e18:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e24:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e32:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e39:	83 ec 0c             	sub    $0xc,%esp
  800e3c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3f:	e8 32 f5 ff ff       	call   800376 <fd2num>
  800e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e47:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e49:	83 c4 04             	add    $0x4,%esp
  800e4c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4f:	e8 22 f5 ff ff       	call   800376 <fd2num>
  800e54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e57:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e62:	eb 30                	jmp    800e94 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e64:	83 ec 08             	sub    $0x8,%esp
  800e67:	56                   	push   %esi
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 7c f3 ff ff       	call   8001eb <sys_page_unmap>
  800e6f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	ff 75 f0             	pushl  -0x10(%ebp)
  800e78:	6a 00                	push   $0x0
  800e7a:	e8 6c f3 ff ff       	call   8001eb <sys_page_unmap>
  800e7f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	ff 75 f4             	pushl  -0xc(%ebp)
  800e88:	6a 00                	push   $0x0
  800e8a:	e8 5c f3 ff ff       	call   8001eb <sys_page_unmap>
  800e8f:	83 c4 10             	add    $0x10,%esp
  800e92:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e94:	89 d0                	mov    %edx,%eax
  800e96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea6:	50                   	push   %eax
  800ea7:	ff 75 08             	pushl  0x8(%ebp)
  800eaa:	e8 3d f5 ff ff       	call   8003ec <fd_lookup>
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	78 18                	js     800ece <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eb6:	83 ec 0c             	sub    $0xc,%esp
  800eb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebc:	e8 c5 f4 ff ff       	call   800386 <fd2data>
	return _pipeisclosed(fd, p);
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec6:	e8 21 fd ff ff       	call   800bec <_pipeisclosed>
  800ecb:	83 c4 10             	add    $0x10,%esp
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ed6:	68 3a 23 80 00       	push   $0x80233a
  800edb:	ff 75 0c             	pushl  0xc(%ebp)
  800ede:	e8 35 0c 00 00       	call   801b18 <strcpy>
	return 0;
}
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	53                   	push   %ebx
  800eee:	83 ec 10             	sub    $0x10,%esp
  800ef1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800ef4:	53                   	push   %ebx
  800ef5:	e8 59 10 00 00       	call   801f53 <pageref>
  800efa:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800efd:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f02:	83 f8 01             	cmp    $0x1,%eax
  800f05:	75 10                	jne    800f17 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	ff 73 0c             	pushl  0xc(%ebx)
  800f0d:	e8 c0 02 00 00       	call   8011d2 <nsipc_close>
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f17:	89 d0                	mov    %edx,%eax
  800f19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f24:	6a 00                	push   $0x0
  800f26:	ff 75 10             	pushl  0x10(%ebp)
  800f29:	ff 75 0c             	pushl  0xc(%ebp)
  800f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2f:	ff 70 0c             	pushl  0xc(%eax)
  800f32:	e8 78 03 00 00       	call   8012af <nsipc_send>
}
  800f37:	c9                   	leave  
  800f38:	c3                   	ret    

00800f39 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f3f:	6a 00                	push   $0x0
  800f41:	ff 75 10             	pushl  0x10(%ebp)
  800f44:	ff 75 0c             	pushl  0xc(%ebp)
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4a:	ff 70 0c             	pushl  0xc(%eax)
  800f4d:	e8 f1 02 00 00       	call   801243 <nsipc_recv>
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f5a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f5d:	52                   	push   %edx
  800f5e:	50                   	push   %eax
  800f5f:	e8 88 f4 ff ff       	call   8003ec <fd_lookup>
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 17                	js     800f82 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6e:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800f74:	39 08                	cmp    %ecx,(%eax)
  800f76:	75 05                	jne    800f7d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f78:	8b 40 0c             	mov    0xc(%eax),%eax
  800f7b:	eb 05                	jmp    800f82 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f7d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 1c             	sub    $0x1c,%esp
  800f8c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f91:	50                   	push   %eax
  800f92:	e8 06 f4 ff ff       	call   80039d <fd_alloc>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 1b                	js     800fbb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fa0:	83 ec 04             	sub    $0x4,%esp
  800fa3:	68 07 04 00 00       	push   $0x407
  800fa8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fab:	6a 00                	push   $0x0
  800fad:	e8 b4 f1 ff ff       	call   800166 <sys_page_alloc>
  800fb2:	89 c3                	mov    %eax,%ebx
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	79 10                	jns    800fcb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	56                   	push   %esi
  800fbf:	e8 0e 02 00 00       	call   8011d2 <nsipc_close>
		return r;
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	89 d8                	mov    %ebx,%eax
  800fc9:	eb 24                	jmp    800fef <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fcb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800fe0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	50                   	push   %eax
  800fe7:	e8 8a f3 ff ff       	call   800376 <fd2num>
  800fec:	83 c4 10             	add    $0x10,%esp
}
  800fef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	e8 50 ff ff ff       	call   800f54 <fd2sockid>
		return r;
  801004:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801006:	85 c0                	test   %eax,%eax
  801008:	78 1f                	js     801029 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80100a:	83 ec 04             	sub    $0x4,%esp
  80100d:	ff 75 10             	pushl  0x10(%ebp)
  801010:	ff 75 0c             	pushl  0xc(%ebp)
  801013:	50                   	push   %eax
  801014:	e8 12 01 00 00       	call   80112b <nsipc_accept>
  801019:	83 c4 10             	add    $0x10,%esp
		return r;
  80101c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 07                	js     801029 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801022:	e8 5d ff ff ff       	call   800f84 <alloc_sockfd>
  801027:	89 c1                	mov    %eax,%ecx
}
  801029:	89 c8                	mov    %ecx,%eax
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	e8 19 ff ff ff       	call   800f54 <fd2sockid>
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 12                	js     801051 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	ff 75 10             	pushl  0x10(%ebp)
  801045:	ff 75 0c             	pushl  0xc(%ebp)
  801048:	50                   	push   %eax
  801049:	e8 2d 01 00 00       	call   80117b <nsipc_bind>
  80104e:	83 c4 10             	add    $0x10,%esp
}
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <shutdown>:

int
shutdown(int s, int how)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	e8 f3 fe ff ff       	call   800f54 <fd2sockid>
  801061:	85 c0                	test   %eax,%eax
  801063:	78 0f                	js     801074 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	ff 75 0c             	pushl  0xc(%ebp)
  80106b:	50                   	push   %eax
  80106c:	e8 3f 01 00 00       	call   8011b0 <nsipc_shutdown>
  801071:	83 c4 10             	add    $0x10,%esp
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80107c:	8b 45 08             	mov    0x8(%ebp),%eax
  80107f:	e8 d0 fe ff ff       	call   800f54 <fd2sockid>
  801084:	85 c0                	test   %eax,%eax
  801086:	78 12                	js     80109a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	ff 75 10             	pushl  0x10(%ebp)
  80108e:	ff 75 0c             	pushl  0xc(%ebp)
  801091:	50                   	push   %eax
  801092:	e8 55 01 00 00       	call   8011ec <nsipc_connect>
  801097:	83 c4 10             	add    $0x10,%esp
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <listen>:

int
listen(int s, int backlog)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	e8 aa fe ff ff       	call   800f54 <fd2sockid>
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 0f                	js     8010bd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010ae:	83 ec 08             	sub    $0x8,%esp
  8010b1:	ff 75 0c             	pushl  0xc(%ebp)
  8010b4:	50                   	push   %eax
  8010b5:	e8 67 01 00 00       	call   801221 <nsipc_listen>
  8010ba:	83 c4 10             	add    $0x10,%esp
}
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010c5:	ff 75 10             	pushl  0x10(%ebp)
  8010c8:	ff 75 0c             	pushl  0xc(%ebp)
  8010cb:	ff 75 08             	pushl  0x8(%ebp)
  8010ce:	e8 3a 02 00 00       	call   80130d <nsipc_socket>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 05                	js     8010df <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010da:	e8 a5 fe ff ff       	call   800f84 <alloc_sockfd>
}
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    

008010e1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 04             	sub    $0x4,%esp
  8010e8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8010ea:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8010f1:	75 12                	jne    801105 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	6a 02                	push   $0x2
  8010f8:	e8 1d 0e 00 00       	call   801f1a <ipc_find_env>
  8010fd:	a3 04 40 80 00       	mov    %eax,0x804004
  801102:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801105:	6a 07                	push   $0x7
  801107:	68 00 60 80 00       	push   $0x806000
  80110c:	53                   	push   %ebx
  80110d:	ff 35 04 40 80 00    	pushl  0x804004
  801113:	e8 ae 0d 00 00       	call   801ec6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801118:	83 c4 0c             	add    $0xc,%esp
  80111b:	6a 00                	push   $0x0
  80111d:	6a 00                	push   $0x0
  80111f:	6a 00                	push   $0x0
  801121:	e8 39 0d 00 00       	call   801e5f <ipc_recv>
}
  801126:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
  801130:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
  801136:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80113b:	8b 06                	mov    (%esi),%eax
  80113d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801142:	b8 01 00 00 00       	mov    $0x1,%eax
  801147:	e8 95 ff ff ff       	call   8010e1 <nsipc>
  80114c:	89 c3                	mov    %eax,%ebx
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 20                	js     801172 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801152:	83 ec 04             	sub    $0x4,%esp
  801155:	ff 35 10 60 80 00    	pushl  0x806010
  80115b:	68 00 60 80 00       	push   $0x806000
  801160:	ff 75 0c             	pushl  0xc(%ebp)
  801163:	e8 42 0b 00 00       	call   801caa <memmove>
		*addrlen = ret->ret_addrlen;
  801168:	a1 10 60 80 00       	mov    0x806010,%eax
  80116d:	89 06                	mov    %eax,(%esi)
  80116f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801172:	89 d8                	mov    %ebx,%eax
  801174:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801177:	5b                   	pop    %ebx
  801178:	5e                   	pop    %esi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	53                   	push   %ebx
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801185:	8b 45 08             	mov    0x8(%ebp),%eax
  801188:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80118d:	53                   	push   %ebx
  80118e:	ff 75 0c             	pushl  0xc(%ebp)
  801191:	68 04 60 80 00       	push   $0x806004
  801196:	e8 0f 0b 00 00       	call   801caa <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80119b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011a1:	b8 02 00 00 00       	mov    $0x2,%eax
  8011a6:	e8 36 ff ff ff       	call   8010e1 <nsipc>
}
  8011ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ae:	c9                   	leave  
  8011af:	c3                   	ret    

008011b0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011c6:	b8 03 00 00 00       	mov    $0x3,%eax
  8011cb:	e8 11 ff ff ff       	call   8010e1 <nsipc>
}
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    

008011d2 <nsipc_close>:

int
nsipc_close(int s)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011db:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8011e5:	e8 f7 fe ff ff       	call   8010e1 <nsipc>
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8011fe:	53                   	push   %ebx
  8011ff:	ff 75 0c             	pushl  0xc(%ebp)
  801202:	68 04 60 80 00       	push   $0x806004
  801207:	e8 9e 0a 00 00       	call   801caa <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80120c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801212:	b8 05 00 00 00       	mov    $0x5,%eax
  801217:	e8 c5 fe ff ff       	call   8010e1 <nsipc>
}
  80121c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801227:	8b 45 08             	mov    0x8(%ebp),%eax
  80122a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80122f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801232:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801237:	b8 06 00 00 00       	mov    $0x6,%eax
  80123c:	e8 a0 fe ff ff       	call   8010e1 <nsipc>
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80124b:	8b 45 08             	mov    0x8(%ebp),%eax
  80124e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801253:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801259:	8b 45 14             	mov    0x14(%ebp),%eax
  80125c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801261:	b8 07 00 00 00       	mov    $0x7,%eax
  801266:	e8 76 fe ff ff       	call   8010e1 <nsipc>
  80126b:	89 c3                	mov    %eax,%ebx
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 35                	js     8012a6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801271:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801276:	7f 04                	jg     80127c <nsipc_recv+0x39>
  801278:	39 c6                	cmp    %eax,%esi
  80127a:	7d 16                	jge    801292 <nsipc_recv+0x4f>
  80127c:	68 46 23 80 00       	push   $0x802346
  801281:	68 ef 22 80 00       	push   $0x8022ef
  801286:	6a 62                	push   $0x62
  801288:	68 5b 23 80 00       	push   $0x80235b
  80128d:	e8 28 02 00 00       	call   8014ba <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801292:	83 ec 04             	sub    $0x4,%esp
  801295:	50                   	push   %eax
  801296:	68 00 60 80 00       	push   $0x806000
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	e8 07 0a 00 00       	call   801caa <memmove>
  8012a3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012a6:	89 d8                	mov    %ebx,%eax
  8012a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ab:	5b                   	pop    %ebx
  8012ac:	5e                   	pop    %esi
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	53                   	push   %ebx
  8012b3:	83 ec 04             	sub    $0x4,%esp
  8012b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012c1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012c7:	7e 16                	jle    8012df <nsipc_send+0x30>
  8012c9:	68 67 23 80 00       	push   $0x802367
  8012ce:	68 ef 22 80 00       	push   $0x8022ef
  8012d3:	6a 6d                	push   $0x6d
  8012d5:	68 5b 23 80 00       	push   $0x80235b
  8012da:	e8 db 01 00 00       	call   8014ba <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012df:	83 ec 04             	sub    $0x4,%esp
  8012e2:	53                   	push   %ebx
  8012e3:	ff 75 0c             	pushl  0xc(%ebp)
  8012e6:	68 0c 60 80 00       	push   $0x80600c
  8012eb:	e8 ba 09 00 00       	call   801caa <memmove>
	nsipcbuf.send.req_size = size;
  8012f0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8012f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8012fe:	b8 08 00 00 00       	mov    $0x8,%eax
  801303:	e8 d9 fd ff ff       	call   8010e1 <nsipc>
}
  801308:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    

0080130d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801313:	8b 45 08             	mov    0x8(%ebp),%eax
  801316:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80131b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801323:	8b 45 10             	mov    0x10(%ebp),%eax
  801326:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80132b:	b8 09 00 00 00       	mov    $0x9,%eax
  801330:	e8 ac fd ff ff       	call   8010e1 <nsipc>
}
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801347:	68 73 23 80 00       	push   $0x802373
  80134c:	ff 75 0c             	pushl  0xc(%ebp)
  80134f:	e8 c4 07 00 00       	call   801b18 <strcpy>
	return 0;
}
  801354:	b8 00 00 00 00       	mov    $0x0,%eax
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	57                   	push   %edi
  80135f:	56                   	push   %esi
  801360:	53                   	push   %ebx
  801361:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801367:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80136c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801372:	eb 2d                	jmp    8013a1 <devcons_write+0x46>
		m = n - tot;
  801374:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801377:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801379:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80137c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801381:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801384:	83 ec 04             	sub    $0x4,%esp
  801387:	53                   	push   %ebx
  801388:	03 45 0c             	add    0xc(%ebp),%eax
  80138b:	50                   	push   %eax
  80138c:	57                   	push   %edi
  80138d:	e8 18 09 00 00       	call   801caa <memmove>
		sys_cputs(buf, m);
  801392:	83 c4 08             	add    $0x8,%esp
  801395:	53                   	push   %ebx
  801396:	57                   	push   %edi
  801397:	e8 0e ed ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139c:	01 de                	add    %ebx,%esi
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	89 f0                	mov    %esi,%eax
  8013a3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a6:	72 cc                	jb     801374 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5e                   	pop    %esi
  8013ad:	5f                   	pop    %edi
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013bf:	74 2a                	je     8013eb <devcons_read+0x3b>
  8013c1:	eb 05                	jmp    8013c8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013c3:	e8 7f ed ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013c8:	e8 fb ec ff ff       	call   8000c8 <sys_cgetc>
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 f2                	je     8013c3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 16                	js     8013eb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013d5:	83 f8 04             	cmp    $0x4,%eax
  8013d8:	74 0c                	je     8013e6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013dd:	88 02                	mov    %al,(%edx)
	return 1;
  8013df:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e4:	eb 05                	jmp    8013eb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013e6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013f9:	6a 01                	push   $0x1
  8013fb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	e8 a6 ec ff ff       	call   8000aa <sys_cputs>
}
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	c9                   	leave  
  801408:	c3                   	ret    

00801409 <getchar>:

int
getchar(void)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80140f:	6a 01                	push   $0x1
  801411:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	6a 00                	push   $0x0
  801417:	e8 36 f2 ff ff       	call   800652 <read>
	if (r < 0)
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 0f                	js     801432 <getchar+0x29>
		return r;
	if (r < 1)
  801423:	85 c0                	test   %eax,%eax
  801425:	7e 06                	jle    80142d <getchar+0x24>
		return -E_EOF;
	return c;
  801427:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80142b:	eb 05                	jmp    801432 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80142d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	ff 75 08             	pushl  0x8(%ebp)
  801441:	e8 a6 ef ff ff       	call   8003ec <fd_lookup>
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 11                	js     80145e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80144d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801450:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801456:	39 10                	cmp    %edx,(%eax)
  801458:	0f 94 c0             	sete   %al
  80145b:	0f b6 c0             	movzbl %al,%eax
}
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <opencons>:

int
opencons(void)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	e8 2e ef ff ff       	call   80039d <fd_alloc>
  80146f:	83 c4 10             	add    $0x10,%esp
		return r;
  801472:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801474:	85 c0                	test   %eax,%eax
  801476:	78 3e                	js     8014b6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	68 07 04 00 00       	push   $0x407
  801480:	ff 75 f4             	pushl  -0xc(%ebp)
  801483:	6a 00                	push   $0x0
  801485:	e8 dc ec ff ff       	call   800166 <sys_page_alloc>
  80148a:	83 c4 10             	add    $0x10,%esp
		return r;
  80148d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 23                	js     8014b6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801493:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801499:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80149e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014a8:	83 ec 0c             	sub    $0xc,%esp
  8014ab:	50                   	push   %eax
  8014ac:	e8 c5 ee ff ff       	call   800376 <fd2num>
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	83 c4 10             	add    $0x10,%esp
}
  8014b6:	89 d0                	mov    %edx,%eax
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014bf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014c2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014c8:	e8 5b ec ff ff       	call   800128 <sys_getenvid>
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	ff 75 0c             	pushl  0xc(%ebp)
  8014d3:	ff 75 08             	pushl  0x8(%ebp)
  8014d6:	56                   	push   %esi
  8014d7:	50                   	push   %eax
  8014d8:	68 80 23 80 00       	push   $0x802380
  8014dd:	e8 b1 00 00 00       	call   801593 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014e2:	83 c4 18             	add    $0x18,%esp
  8014e5:	53                   	push   %ebx
  8014e6:	ff 75 10             	pushl  0x10(%ebp)
  8014e9:	e8 54 00 00 00       	call   801542 <vcprintf>
	cprintf("\n");
  8014ee:	c7 04 24 33 23 80 00 	movl   $0x802333,(%esp)
  8014f5:	e8 99 00 00 00       	call   801593 <cprintf>
  8014fa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014fd:	cc                   	int3   
  8014fe:	eb fd                	jmp    8014fd <_panic+0x43>

00801500 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	53                   	push   %ebx
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80150a:	8b 13                	mov    (%ebx),%edx
  80150c:	8d 42 01             	lea    0x1(%edx),%eax
  80150f:	89 03                	mov    %eax,(%ebx)
  801511:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801514:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801518:	3d ff 00 00 00       	cmp    $0xff,%eax
  80151d:	75 1a                	jne    801539 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80151f:	83 ec 08             	sub    $0x8,%esp
  801522:	68 ff 00 00 00       	push   $0xff
  801527:	8d 43 08             	lea    0x8(%ebx),%eax
  80152a:	50                   	push   %eax
  80152b:	e8 7a eb ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  801530:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801536:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801539:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80154b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801552:	00 00 00 
	b.cnt = 0;
  801555:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80155c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80155f:	ff 75 0c             	pushl  0xc(%ebp)
  801562:	ff 75 08             	pushl  0x8(%ebp)
  801565:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	68 00 15 80 00       	push   $0x801500
  801571:	e8 54 01 00 00       	call   8016ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801576:	83 c4 08             	add    $0x8,%esp
  801579:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80157f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	e8 1f eb ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  80158b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801599:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80159c:	50                   	push   %eax
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 9d ff ff ff       	call   801542 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	57                   	push   %edi
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 1c             	sub    $0x1c,%esp
  8015b0:	89 c7                	mov    %eax,%edi
  8015b2:	89 d6                	mov    %edx,%esi
  8015b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015cb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015ce:	39 d3                	cmp    %edx,%ebx
  8015d0:	72 05                	jb     8015d7 <printnum+0x30>
  8015d2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015d5:	77 45                	ja     80161c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	ff 75 18             	pushl  0x18(%ebp)
  8015dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015e3:	53                   	push   %ebx
  8015e4:	ff 75 10             	pushl  0x10(%ebp)
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8015f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8015f6:	e8 95 09 00 00       	call   801f90 <__udivdi3>
  8015fb:	83 c4 18             	add    $0x18,%esp
  8015fe:	52                   	push   %edx
  8015ff:	50                   	push   %eax
  801600:	89 f2                	mov    %esi,%edx
  801602:	89 f8                	mov    %edi,%eax
  801604:	e8 9e ff ff ff       	call   8015a7 <printnum>
  801609:	83 c4 20             	add    $0x20,%esp
  80160c:	eb 18                	jmp    801626 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	56                   	push   %esi
  801612:	ff 75 18             	pushl  0x18(%ebp)
  801615:	ff d7                	call   *%edi
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	eb 03                	jmp    80161f <printnum+0x78>
  80161c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80161f:	83 eb 01             	sub    $0x1,%ebx
  801622:	85 db                	test   %ebx,%ebx
  801624:	7f e8                	jg     80160e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	56                   	push   %esi
  80162a:	83 ec 04             	sub    $0x4,%esp
  80162d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801630:	ff 75 e0             	pushl  -0x20(%ebp)
  801633:	ff 75 dc             	pushl  -0x24(%ebp)
  801636:	ff 75 d8             	pushl  -0x28(%ebp)
  801639:	e8 82 0a 00 00       	call   8020c0 <__umoddi3>
  80163e:	83 c4 14             	add    $0x14,%esp
  801641:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  801648:	50                   	push   %eax
  801649:	ff d7                	call   *%edi
}
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801651:	5b                   	pop    %ebx
  801652:	5e                   	pop    %esi
  801653:	5f                   	pop    %edi
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    

00801656 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801659:	83 fa 01             	cmp    $0x1,%edx
  80165c:	7e 0e                	jle    80166c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80165e:	8b 10                	mov    (%eax),%edx
  801660:	8d 4a 08             	lea    0x8(%edx),%ecx
  801663:	89 08                	mov    %ecx,(%eax)
  801665:	8b 02                	mov    (%edx),%eax
  801667:	8b 52 04             	mov    0x4(%edx),%edx
  80166a:	eb 22                	jmp    80168e <getuint+0x38>
	else if (lflag)
  80166c:	85 d2                	test   %edx,%edx
  80166e:	74 10                	je     801680 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801670:	8b 10                	mov    (%eax),%edx
  801672:	8d 4a 04             	lea    0x4(%edx),%ecx
  801675:	89 08                	mov    %ecx,(%eax)
  801677:	8b 02                	mov    (%edx),%eax
  801679:	ba 00 00 00 00       	mov    $0x0,%edx
  80167e:	eb 0e                	jmp    80168e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801680:	8b 10                	mov    (%eax),%edx
  801682:	8d 4a 04             	lea    0x4(%edx),%ecx
  801685:	89 08                	mov    %ecx,(%eax)
  801687:	8b 02                	mov    (%edx),%eax
  801689:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801696:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80169a:	8b 10                	mov    (%eax),%edx
  80169c:	3b 50 04             	cmp    0x4(%eax),%edx
  80169f:	73 0a                	jae    8016ab <sprintputch+0x1b>
		*b->buf++ = ch;
  8016a1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016a4:	89 08                	mov    %ecx,(%eax)
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	88 02                	mov    %al,(%edx)
}
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016b3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016b6:	50                   	push   %eax
  8016b7:	ff 75 10             	pushl  0x10(%ebp)
  8016ba:	ff 75 0c             	pushl  0xc(%ebp)
  8016bd:	ff 75 08             	pushl  0x8(%ebp)
  8016c0:	e8 05 00 00 00       	call   8016ca <vprintfmt>
	va_end(ap);
}
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	57                   	push   %edi
  8016ce:	56                   	push   %esi
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 2c             	sub    $0x2c,%esp
  8016d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8016d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016dc:	eb 12                	jmp    8016f0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	0f 84 89 03 00 00    	je     801a6f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	53                   	push   %ebx
  8016ea:	50                   	push   %eax
  8016eb:	ff d6                	call   *%esi
  8016ed:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016f0:	83 c7 01             	add    $0x1,%edi
  8016f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016f7:	83 f8 25             	cmp    $0x25,%eax
  8016fa:	75 e2                	jne    8016de <vprintfmt+0x14>
  8016fc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801700:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801707:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80170e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801715:	ba 00 00 00 00       	mov    $0x0,%edx
  80171a:	eb 07                	jmp    801723 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80171f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801723:	8d 47 01             	lea    0x1(%edi),%eax
  801726:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801729:	0f b6 07             	movzbl (%edi),%eax
  80172c:	0f b6 c8             	movzbl %al,%ecx
  80172f:	83 e8 23             	sub    $0x23,%eax
  801732:	3c 55                	cmp    $0x55,%al
  801734:	0f 87 1a 03 00 00    	ja     801a54 <vprintfmt+0x38a>
  80173a:	0f b6 c0             	movzbl %al,%eax
  80173d:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  801744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801747:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80174b:	eb d6                	jmp    801723 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801750:	b8 00 00 00 00       	mov    $0x0,%eax
  801755:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801758:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80175b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80175f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801762:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801765:	83 fa 09             	cmp    $0x9,%edx
  801768:	77 39                	ja     8017a3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80176a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80176d:	eb e9                	jmp    801758 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80176f:	8b 45 14             	mov    0x14(%ebp),%eax
  801772:	8d 48 04             	lea    0x4(%eax),%ecx
  801775:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801778:	8b 00                	mov    (%eax),%eax
  80177a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801780:	eb 27                	jmp    8017a9 <vprintfmt+0xdf>
  801782:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801785:	85 c0                	test   %eax,%eax
  801787:	b9 00 00 00 00       	mov    $0x0,%ecx
  80178c:	0f 49 c8             	cmovns %eax,%ecx
  80178f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801792:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801795:	eb 8c                	jmp    801723 <vprintfmt+0x59>
  801797:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80179a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017a1:	eb 80                	jmp    801723 <vprintfmt+0x59>
  8017a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017a6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017ad:	0f 89 70 ff ff ff    	jns    801723 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017b9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017c0:	e9 5e ff ff ff       	jmp    801723 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017c5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017cb:	e9 53 ff ff ff       	jmp    801723 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d3:	8d 50 04             	lea    0x4(%eax),%edx
  8017d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8017d9:	83 ec 08             	sub    $0x8,%esp
  8017dc:	53                   	push   %ebx
  8017dd:	ff 30                	pushl  (%eax)
  8017df:	ff d6                	call   *%esi
			break;
  8017e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017e7:	e9 04 ff ff ff       	jmp    8016f0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ef:	8d 50 04             	lea    0x4(%eax),%edx
  8017f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8017f5:	8b 00                	mov    (%eax),%eax
  8017f7:	99                   	cltd   
  8017f8:	31 d0                	xor    %edx,%eax
  8017fa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017fc:	83 f8 0f             	cmp    $0xf,%eax
  8017ff:	7f 0b                	jg     80180c <vprintfmt+0x142>
  801801:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  801808:	85 d2                	test   %edx,%edx
  80180a:	75 18                	jne    801824 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80180c:	50                   	push   %eax
  80180d:	68 bb 23 80 00       	push   $0x8023bb
  801812:	53                   	push   %ebx
  801813:	56                   	push   %esi
  801814:	e8 94 fe ff ff       	call   8016ad <printfmt>
  801819:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80181f:	e9 cc fe ff ff       	jmp    8016f0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801824:	52                   	push   %edx
  801825:	68 01 23 80 00       	push   $0x802301
  80182a:	53                   	push   %ebx
  80182b:	56                   	push   %esi
  80182c:	e8 7c fe ff ff       	call   8016ad <printfmt>
  801831:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801834:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801837:	e9 b4 fe ff ff       	jmp    8016f0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80183c:	8b 45 14             	mov    0x14(%ebp),%eax
  80183f:	8d 50 04             	lea    0x4(%eax),%edx
  801842:	89 55 14             	mov    %edx,0x14(%ebp)
  801845:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801847:	85 ff                	test   %edi,%edi
  801849:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  80184e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801851:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801855:	0f 8e 94 00 00 00    	jle    8018ef <vprintfmt+0x225>
  80185b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80185f:	0f 84 98 00 00 00    	je     8018fd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801865:	83 ec 08             	sub    $0x8,%esp
  801868:	ff 75 d0             	pushl  -0x30(%ebp)
  80186b:	57                   	push   %edi
  80186c:	e8 86 02 00 00       	call   801af7 <strnlen>
  801871:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801874:	29 c1                	sub    %eax,%ecx
  801876:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801879:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80187c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801880:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801883:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801886:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801888:	eb 0f                	jmp    801899 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80188a:	83 ec 08             	sub    $0x8,%esp
  80188d:	53                   	push   %ebx
  80188e:	ff 75 e0             	pushl  -0x20(%ebp)
  801891:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801893:	83 ef 01             	sub    $0x1,%edi
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 ff                	test   %edi,%edi
  80189b:	7f ed                	jg     80188a <vprintfmt+0x1c0>
  80189d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018a0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018a3:	85 c9                	test   %ecx,%ecx
  8018a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018aa:	0f 49 c1             	cmovns %ecx,%eax
  8018ad:	29 c1                	sub    %eax,%ecx
  8018af:	89 75 08             	mov    %esi,0x8(%ebp)
  8018b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018b8:	89 cb                	mov    %ecx,%ebx
  8018ba:	eb 4d                	jmp    801909 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018c0:	74 1b                	je     8018dd <vprintfmt+0x213>
  8018c2:	0f be c0             	movsbl %al,%eax
  8018c5:	83 e8 20             	sub    $0x20,%eax
  8018c8:	83 f8 5e             	cmp    $0x5e,%eax
  8018cb:	76 10                	jbe    8018dd <vprintfmt+0x213>
					putch('?', putdat);
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	ff 75 0c             	pushl  0xc(%ebp)
  8018d3:	6a 3f                	push   $0x3f
  8018d5:	ff 55 08             	call   *0x8(%ebp)
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	eb 0d                	jmp    8018ea <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	52                   	push   %edx
  8018e4:	ff 55 08             	call   *0x8(%ebp)
  8018e7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ea:	83 eb 01             	sub    $0x1,%ebx
  8018ed:	eb 1a                	jmp    801909 <vprintfmt+0x23f>
  8018ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018fb:	eb 0c                	jmp    801909 <vprintfmt+0x23f>
  8018fd:	89 75 08             	mov    %esi,0x8(%ebp)
  801900:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801903:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801906:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801909:	83 c7 01             	add    $0x1,%edi
  80190c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801910:	0f be d0             	movsbl %al,%edx
  801913:	85 d2                	test   %edx,%edx
  801915:	74 23                	je     80193a <vprintfmt+0x270>
  801917:	85 f6                	test   %esi,%esi
  801919:	78 a1                	js     8018bc <vprintfmt+0x1f2>
  80191b:	83 ee 01             	sub    $0x1,%esi
  80191e:	79 9c                	jns    8018bc <vprintfmt+0x1f2>
  801920:	89 df                	mov    %ebx,%edi
  801922:	8b 75 08             	mov    0x8(%ebp),%esi
  801925:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801928:	eb 18                	jmp    801942 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	53                   	push   %ebx
  80192e:	6a 20                	push   $0x20
  801930:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801932:	83 ef 01             	sub    $0x1,%edi
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	eb 08                	jmp    801942 <vprintfmt+0x278>
  80193a:	89 df                	mov    %ebx,%edi
  80193c:	8b 75 08             	mov    0x8(%ebp),%esi
  80193f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801942:	85 ff                	test   %edi,%edi
  801944:	7f e4                	jg     80192a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801946:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801949:	e9 a2 fd ff ff       	jmp    8016f0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80194e:	83 fa 01             	cmp    $0x1,%edx
  801951:	7e 16                	jle    801969 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801953:	8b 45 14             	mov    0x14(%ebp),%eax
  801956:	8d 50 08             	lea    0x8(%eax),%edx
  801959:	89 55 14             	mov    %edx,0x14(%ebp)
  80195c:	8b 50 04             	mov    0x4(%eax),%edx
  80195f:	8b 00                	mov    (%eax),%eax
  801961:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801964:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801967:	eb 32                	jmp    80199b <vprintfmt+0x2d1>
	else if (lflag)
  801969:	85 d2                	test   %edx,%edx
  80196b:	74 18                	je     801985 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80196d:	8b 45 14             	mov    0x14(%ebp),%eax
  801970:	8d 50 04             	lea    0x4(%eax),%edx
  801973:	89 55 14             	mov    %edx,0x14(%ebp)
  801976:	8b 00                	mov    (%eax),%eax
  801978:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80197b:	89 c1                	mov    %eax,%ecx
  80197d:	c1 f9 1f             	sar    $0x1f,%ecx
  801980:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801983:	eb 16                	jmp    80199b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801985:	8b 45 14             	mov    0x14(%ebp),%eax
  801988:	8d 50 04             	lea    0x4(%eax),%edx
  80198b:	89 55 14             	mov    %edx,0x14(%ebp)
  80198e:	8b 00                	mov    (%eax),%eax
  801990:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801993:	89 c1                	mov    %eax,%ecx
  801995:	c1 f9 1f             	sar    $0x1f,%ecx
  801998:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80199b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80199e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019a1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019aa:	79 74                	jns    801a20 <vprintfmt+0x356>
				putch('-', putdat);
  8019ac:	83 ec 08             	sub    $0x8,%esp
  8019af:	53                   	push   %ebx
  8019b0:	6a 2d                	push   $0x2d
  8019b2:	ff d6                	call   *%esi
				num = -(long long) num;
  8019b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019ba:	f7 d8                	neg    %eax
  8019bc:	83 d2 00             	adc    $0x0,%edx
  8019bf:	f7 da                	neg    %edx
  8019c1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019c9:	eb 55                	jmp    801a20 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8019ce:	e8 83 fc ff ff       	call   801656 <getuint>
			base = 10;
  8019d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019d8:	eb 46                	jmp    801a20 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8019da:	8d 45 14             	lea    0x14(%ebp),%eax
  8019dd:	e8 74 fc ff ff       	call   801656 <getuint>
			base = 8;
  8019e2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019e7:	eb 37                	jmp    801a20 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8019e9:	83 ec 08             	sub    $0x8,%esp
  8019ec:	53                   	push   %ebx
  8019ed:	6a 30                	push   $0x30
  8019ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8019f1:	83 c4 08             	add    $0x8,%esp
  8019f4:	53                   	push   %ebx
  8019f5:	6a 78                	push   $0x78
  8019f7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019fc:	8d 50 04             	lea    0x4(%eax),%edx
  8019ff:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a02:	8b 00                	mov    (%eax),%eax
  801a04:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a09:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a0c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a11:	eb 0d                	jmp    801a20 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a13:	8d 45 14             	lea    0x14(%ebp),%eax
  801a16:	e8 3b fc ff ff       	call   801656 <getuint>
			base = 16;
  801a1b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a27:	57                   	push   %edi
  801a28:	ff 75 e0             	pushl  -0x20(%ebp)
  801a2b:	51                   	push   %ecx
  801a2c:	52                   	push   %edx
  801a2d:	50                   	push   %eax
  801a2e:	89 da                	mov    %ebx,%edx
  801a30:	89 f0                	mov    %esi,%eax
  801a32:	e8 70 fb ff ff       	call   8015a7 <printnum>
			break;
  801a37:	83 c4 20             	add    $0x20,%esp
  801a3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a3d:	e9 ae fc ff ff       	jmp    8016f0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a42:	83 ec 08             	sub    $0x8,%esp
  801a45:	53                   	push   %ebx
  801a46:	51                   	push   %ecx
  801a47:	ff d6                	call   *%esi
			break;
  801a49:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a4f:	e9 9c fc ff ff       	jmp    8016f0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a54:	83 ec 08             	sub    $0x8,%esp
  801a57:	53                   	push   %ebx
  801a58:	6a 25                	push   $0x25
  801a5a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	eb 03                	jmp    801a64 <vprintfmt+0x39a>
  801a61:	83 ef 01             	sub    $0x1,%edi
  801a64:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a68:	75 f7                	jne    801a61 <vprintfmt+0x397>
  801a6a:	e9 81 fc ff ff       	jmp    8016f0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5f                   	pop    %edi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    

00801a77 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	83 ec 18             	sub    $0x18,%esp
  801a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a80:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a83:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a86:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a8a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a94:	85 c0                	test   %eax,%eax
  801a96:	74 26                	je     801abe <vsnprintf+0x47>
  801a98:	85 d2                	test   %edx,%edx
  801a9a:	7e 22                	jle    801abe <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a9c:	ff 75 14             	pushl  0x14(%ebp)
  801a9f:	ff 75 10             	pushl  0x10(%ebp)
  801aa2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801aa5:	50                   	push   %eax
  801aa6:	68 90 16 80 00       	push   $0x801690
  801aab:	e8 1a fc ff ff       	call   8016ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ab0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ab3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	eb 05                	jmp    801ac3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801abe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ac3:	c9                   	leave  
  801ac4:	c3                   	ret    

00801ac5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801acb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ace:	50                   	push   %eax
  801acf:	ff 75 10             	pushl  0x10(%ebp)
  801ad2:	ff 75 0c             	pushl  0xc(%ebp)
  801ad5:	ff 75 08             	pushl  0x8(%ebp)
  801ad8:	e8 9a ff ff ff       	call   801a77 <vsnprintf>
	va_end(ap);

	return rc;
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aea:	eb 03                	jmp    801aef <strlen+0x10>
		n++;
  801aec:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801aef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801af3:	75 f7                	jne    801aec <strlen+0xd>
		n++;
	return n;
}
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801afd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b00:	ba 00 00 00 00       	mov    $0x0,%edx
  801b05:	eb 03                	jmp    801b0a <strnlen+0x13>
		n++;
  801b07:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b0a:	39 c2                	cmp    %eax,%edx
  801b0c:	74 08                	je     801b16 <strnlen+0x1f>
  801b0e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b12:	75 f3                	jne    801b07 <strnlen+0x10>
  801b14:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	53                   	push   %ebx
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b22:	89 c2                	mov    %eax,%edx
  801b24:	83 c2 01             	add    $0x1,%edx
  801b27:	83 c1 01             	add    $0x1,%ecx
  801b2a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b2e:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b31:	84 db                	test   %bl,%bl
  801b33:	75 ef                	jne    801b24 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b35:	5b                   	pop    %ebx
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	53                   	push   %ebx
  801b3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b3f:	53                   	push   %ebx
  801b40:	e8 9a ff ff ff       	call   801adf <strlen>
  801b45:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b48:	ff 75 0c             	pushl  0xc(%ebp)
  801b4b:	01 d8                	add    %ebx,%eax
  801b4d:	50                   	push   %eax
  801b4e:	e8 c5 ff ff ff       	call   801b18 <strcpy>
	return dst;
}
  801b53:	89 d8                	mov    %ebx,%eax
  801b55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	56                   	push   %esi
  801b5e:	53                   	push   %ebx
  801b5f:	8b 75 08             	mov    0x8(%ebp),%esi
  801b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b65:	89 f3                	mov    %esi,%ebx
  801b67:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b6a:	89 f2                	mov    %esi,%edx
  801b6c:	eb 0f                	jmp    801b7d <strncpy+0x23>
		*dst++ = *src;
  801b6e:	83 c2 01             	add    $0x1,%edx
  801b71:	0f b6 01             	movzbl (%ecx),%eax
  801b74:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b77:	80 39 01             	cmpb   $0x1,(%ecx)
  801b7a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b7d:	39 da                	cmp    %ebx,%edx
  801b7f:	75 ed                	jne    801b6e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b81:	89 f0                	mov    %esi,%eax
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b92:	8b 55 10             	mov    0x10(%ebp),%edx
  801b95:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b97:	85 d2                	test   %edx,%edx
  801b99:	74 21                	je     801bbc <strlcpy+0x35>
  801b9b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801b9f:	89 f2                	mov    %esi,%edx
  801ba1:	eb 09                	jmp    801bac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ba3:	83 c2 01             	add    $0x1,%edx
  801ba6:	83 c1 01             	add    $0x1,%ecx
  801ba9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bac:	39 c2                	cmp    %eax,%edx
  801bae:	74 09                	je     801bb9 <strlcpy+0x32>
  801bb0:	0f b6 19             	movzbl (%ecx),%ebx
  801bb3:	84 db                	test   %bl,%bl
  801bb5:	75 ec                	jne    801ba3 <strlcpy+0x1c>
  801bb7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bb9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bbc:	29 f0                	sub    %esi,%eax
}
  801bbe:	5b                   	pop    %ebx
  801bbf:	5e                   	pop    %esi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bcb:	eb 06                	jmp    801bd3 <strcmp+0x11>
		p++, q++;
  801bcd:	83 c1 01             	add    $0x1,%ecx
  801bd0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bd3:	0f b6 01             	movzbl (%ecx),%eax
  801bd6:	84 c0                	test   %al,%al
  801bd8:	74 04                	je     801bde <strcmp+0x1c>
  801bda:	3a 02                	cmp    (%edx),%al
  801bdc:	74 ef                	je     801bcd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801bde:	0f b6 c0             	movzbl %al,%eax
  801be1:	0f b6 12             	movzbl (%edx),%edx
  801be4:	29 d0                	sub    %edx,%eax
}
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	53                   	push   %ebx
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
  801bef:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801bf7:	eb 06                	jmp    801bff <strncmp+0x17>
		n--, p++, q++;
  801bf9:	83 c0 01             	add    $0x1,%eax
  801bfc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bff:	39 d8                	cmp    %ebx,%eax
  801c01:	74 15                	je     801c18 <strncmp+0x30>
  801c03:	0f b6 08             	movzbl (%eax),%ecx
  801c06:	84 c9                	test   %cl,%cl
  801c08:	74 04                	je     801c0e <strncmp+0x26>
  801c0a:	3a 0a                	cmp    (%edx),%cl
  801c0c:	74 eb                	je     801bf9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c0e:	0f b6 00             	movzbl (%eax),%eax
  801c11:	0f b6 12             	movzbl (%edx),%edx
  801c14:	29 d0                	sub    %edx,%eax
  801c16:	eb 05                	jmp    801c1d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c18:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c1d:	5b                   	pop    %ebx
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	8b 45 08             	mov    0x8(%ebp),%eax
  801c26:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c2a:	eb 07                	jmp    801c33 <strchr+0x13>
		if (*s == c)
  801c2c:	38 ca                	cmp    %cl,%dl
  801c2e:	74 0f                	je     801c3f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c30:	83 c0 01             	add    $0x1,%eax
  801c33:	0f b6 10             	movzbl (%eax),%edx
  801c36:	84 d2                	test   %dl,%dl
  801c38:	75 f2                	jne    801c2c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c4b:	eb 03                	jmp    801c50 <strfind+0xf>
  801c4d:	83 c0 01             	add    $0x1,%eax
  801c50:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c53:	38 ca                	cmp    %cl,%dl
  801c55:	74 04                	je     801c5b <strfind+0x1a>
  801c57:	84 d2                	test   %dl,%dl
  801c59:	75 f2                	jne    801c4d <strfind+0xc>
			break;
	return (char *) s;
}
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	57                   	push   %edi
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c69:	85 c9                	test   %ecx,%ecx
  801c6b:	74 36                	je     801ca3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c73:	75 28                	jne    801c9d <memset+0x40>
  801c75:	f6 c1 03             	test   $0x3,%cl
  801c78:	75 23                	jne    801c9d <memset+0x40>
		c &= 0xFF;
  801c7a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c7e:	89 d3                	mov    %edx,%ebx
  801c80:	c1 e3 08             	shl    $0x8,%ebx
  801c83:	89 d6                	mov    %edx,%esi
  801c85:	c1 e6 18             	shl    $0x18,%esi
  801c88:	89 d0                	mov    %edx,%eax
  801c8a:	c1 e0 10             	shl    $0x10,%eax
  801c8d:	09 f0                	or     %esi,%eax
  801c8f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801c91:	89 d8                	mov    %ebx,%eax
  801c93:	09 d0                	or     %edx,%eax
  801c95:	c1 e9 02             	shr    $0x2,%ecx
  801c98:	fc                   	cld    
  801c99:	f3 ab                	rep stos %eax,%es:(%edi)
  801c9b:	eb 06                	jmp    801ca3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca0:	fc                   	cld    
  801ca1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ca3:	89 f8                	mov    %edi,%eax
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	5f                   	pop    %edi
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    

00801caa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	57                   	push   %edi
  801cae:	56                   	push   %esi
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cb8:	39 c6                	cmp    %eax,%esi
  801cba:	73 35                	jae    801cf1 <memmove+0x47>
  801cbc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cbf:	39 d0                	cmp    %edx,%eax
  801cc1:	73 2e                	jae    801cf1 <memmove+0x47>
		s += n;
		d += n;
  801cc3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cc6:	89 d6                	mov    %edx,%esi
  801cc8:	09 fe                	or     %edi,%esi
  801cca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cd0:	75 13                	jne    801ce5 <memmove+0x3b>
  801cd2:	f6 c1 03             	test   $0x3,%cl
  801cd5:	75 0e                	jne    801ce5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801cd7:	83 ef 04             	sub    $0x4,%edi
  801cda:	8d 72 fc             	lea    -0x4(%edx),%esi
  801cdd:	c1 e9 02             	shr    $0x2,%ecx
  801ce0:	fd                   	std    
  801ce1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ce3:	eb 09                	jmp    801cee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801ce5:	83 ef 01             	sub    $0x1,%edi
  801ce8:	8d 72 ff             	lea    -0x1(%edx),%esi
  801ceb:	fd                   	std    
  801cec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801cee:	fc                   	cld    
  801cef:	eb 1d                	jmp    801d0e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf1:	89 f2                	mov    %esi,%edx
  801cf3:	09 c2                	or     %eax,%edx
  801cf5:	f6 c2 03             	test   $0x3,%dl
  801cf8:	75 0f                	jne    801d09 <memmove+0x5f>
  801cfa:	f6 c1 03             	test   $0x3,%cl
  801cfd:	75 0a                	jne    801d09 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801cff:	c1 e9 02             	shr    $0x2,%ecx
  801d02:	89 c7                	mov    %eax,%edi
  801d04:	fc                   	cld    
  801d05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d07:	eb 05                	jmp    801d0e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d09:	89 c7                	mov    %eax,%edi
  801d0b:	fc                   	cld    
  801d0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d15:	ff 75 10             	pushl  0x10(%ebp)
  801d18:	ff 75 0c             	pushl  0xc(%ebp)
  801d1b:	ff 75 08             	pushl  0x8(%ebp)
  801d1e:	e8 87 ff ff ff       	call   801caa <memmove>
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	56                   	push   %esi
  801d29:	53                   	push   %ebx
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d30:	89 c6                	mov    %eax,%esi
  801d32:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d35:	eb 1a                	jmp    801d51 <memcmp+0x2c>
		if (*s1 != *s2)
  801d37:	0f b6 08             	movzbl (%eax),%ecx
  801d3a:	0f b6 1a             	movzbl (%edx),%ebx
  801d3d:	38 d9                	cmp    %bl,%cl
  801d3f:	74 0a                	je     801d4b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d41:	0f b6 c1             	movzbl %cl,%eax
  801d44:	0f b6 db             	movzbl %bl,%ebx
  801d47:	29 d8                	sub    %ebx,%eax
  801d49:	eb 0f                	jmp    801d5a <memcmp+0x35>
		s1++, s2++;
  801d4b:	83 c0 01             	add    $0x1,%eax
  801d4e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d51:	39 f0                	cmp    %esi,%eax
  801d53:	75 e2                	jne    801d37 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	53                   	push   %ebx
  801d62:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d65:	89 c1                	mov    %eax,%ecx
  801d67:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d6a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d6e:	eb 0a                	jmp    801d7a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d70:	0f b6 10             	movzbl (%eax),%edx
  801d73:	39 da                	cmp    %ebx,%edx
  801d75:	74 07                	je     801d7e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d77:	83 c0 01             	add    $0x1,%eax
  801d7a:	39 c8                	cmp    %ecx,%eax
  801d7c:	72 f2                	jb     801d70 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d7e:	5b                   	pop    %ebx
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    

00801d81 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	57                   	push   %edi
  801d85:	56                   	push   %esi
  801d86:	53                   	push   %ebx
  801d87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d8d:	eb 03                	jmp    801d92 <strtol+0x11>
		s++;
  801d8f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d92:	0f b6 01             	movzbl (%ecx),%eax
  801d95:	3c 20                	cmp    $0x20,%al
  801d97:	74 f6                	je     801d8f <strtol+0xe>
  801d99:	3c 09                	cmp    $0x9,%al
  801d9b:	74 f2                	je     801d8f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d9d:	3c 2b                	cmp    $0x2b,%al
  801d9f:	75 0a                	jne    801dab <strtol+0x2a>
		s++;
  801da1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801da4:	bf 00 00 00 00       	mov    $0x0,%edi
  801da9:	eb 11                	jmp    801dbc <strtol+0x3b>
  801dab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801db0:	3c 2d                	cmp    $0x2d,%al
  801db2:	75 08                	jne    801dbc <strtol+0x3b>
		s++, neg = 1;
  801db4:	83 c1 01             	add    $0x1,%ecx
  801db7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dbc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dc2:	75 15                	jne    801dd9 <strtol+0x58>
  801dc4:	80 39 30             	cmpb   $0x30,(%ecx)
  801dc7:	75 10                	jne    801dd9 <strtol+0x58>
  801dc9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dcd:	75 7c                	jne    801e4b <strtol+0xca>
		s += 2, base = 16;
  801dcf:	83 c1 02             	add    $0x2,%ecx
  801dd2:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dd7:	eb 16                	jmp    801def <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801dd9:	85 db                	test   %ebx,%ebx
  801ddb:	75 12                	jne    801def <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ddd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801de2:	80 39 30             	cmpb   $0x30,(%ecx)
  801de5:	75 08                	jne    801def <strtol+0x6e>
		s++, base = 8;
  801de7:	83 c1 01             	add    $0x1,%ecx
  801dea:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
  801df4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801df7:	0f b6 11             	movzbl (%ecx),%edx
  801dfa:	8d 72 d0             	lea    -0x30(%edx),%esi
  801dfd:	89 f3                	mov    %esi,%ebx
  801dff:	80 fb 09             	cmp    $0x9,%bl
  801e02:	77 08                	ja     801e0c <strtol+0x8b>
			dig = *s - '0';
  801e04:	0f be d2             	movsbl %dl,%edx
  801e07:	83 ea 30             	sub    $0x30,%edx
  801e0a:	eb 22                	jmp    801e2e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e0c:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e0f:	89 f3                	mov    %esi,%ebx
  801e11:	80 fb 19             	cmp    $0x19,%bl
  801e14:	77 08                	ja     801e1e <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e16:	0f be d2             	movsbl %dl,%edx
  801e19:	83 ea 57             	sub    $0x57,%edx
  801e1c:	eb 10                	jmp    801e2e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e1e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e21:	89 f3                	mov    %esi,%ebx
  801e23:	80 fb 19             	cmp    $0x19,%bl
  801e26:	77 16                	ja     801e3e <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e28:	0f be d2             	movsbl %dl,%edx
  801e2b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e31:	7d 0b                	jge    801e3e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e33:	83 c1 01             	add    $0x1,%ecx
  801e36:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e3a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e3c:	eb b9                	jmp    801df7 <strtol+0x76>

	if (endptr)
  801e3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e42:	74 0d                	je     801e51 <strtol+0xd0>
		*endptr = (char *) s;
  801e44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e47:	89 0e                	mov    %ecx,(%esi)
  801e49:	eb 06                	jmp    801e51 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e4b:	85 db                	test   %ebx,%ebx
  801e4d:	74 98                	je     801de7 <strtol+0x66>
  801e4f:	eb 9e                	jmp    801def <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e51:	89 c2                	mov    %eax,%edx
  801e53:	f7 da                	neg    %edx
  801e55:	85 ff                	test   %edi,%edi
  801e57:	0f 45 c2             	cmovne %edx,%eax
}
  801e5a:	5b                   	pop    %ebx
  801e5b:	5e                   	pop    %esi
  801e5c:	5f                   	pop    %edi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	8b 75 08             	mov    0x8(%ebp),%esi
  801e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e6d:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e6f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e74:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	50                   	push   %eax
  801e7b:	e8 96 e4 ff ff       	call   800316 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 f6                	test   %esi,%esi
  801e85:	74 14                	je     801e9b <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e87:	ba 00 00 00 00       	mov    $0x0,%edx
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 09                	js     801e99 <ipc_recv+0x3a>
  801e90:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e96:	8b 52 74             	mov    0x74(%edx),%edx
  801e99:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e9b:	85 db                	test   %ebx,%ebx
  801e9d:	74 14                	je     801eb3 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801e9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	78 09                	js     801eb1 <ipc_recv+0x52>
  801ea8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eae:	8b 52 78             	mov    0x78(%edx),%edx
  801eb1:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	78 08                	js     801ebf <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801eb7:	a1 08 40 80 00       	mov    0x804008,%eax
  801ebc:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ebf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec2:	5b                   	pop    %ebx
  801ec3:	5e                   	pop    %esi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    

00801ec6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	57                   	push   %edi
  801eca:	56                   	push   %esi
  801ecb:	53                   	push   %ebx
  801ecc:	83 ec 0c             	sub    $0xc,%esp
  801ecf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ed8:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801eda:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801edf:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ee2:	ff 75 14             	pushl  0x14(%ebp)
  801ee5:	53                   	push   %ebx
  801ee6:	56                   	push   %esi
  801ee7:	57                   	push   %edi
  801ee8:	e8 06 e4 ff ff       	call   8002f3 <sys_ipc_try_send>

		if (err < 0) {
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	79 1e                	jns    801f12 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ef4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef7:	75 07                	jne    801f00 <ipc_send+0x3a>
				sys_yield();
  801ef9:	e8 49 e2 ff ff       	call   800147 <sys_yield>
  801efe:	eb e2                	jmp    801ee2 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f00:	50                   	push   %eax
  801f01:	68 a0 26 80 00       	push   $0x8026a0
  801f06:	6a 49                	push   $0x49
  801f08:	68 ad 26 80 00       	push   $0x8026ad
  801f0d:	e8 a8 f5 ff ff       	call   8014ba <_panic>
		}

	} while (err < 0);

}
  801f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5f                   	pop    %edi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    

00801f1a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f20:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f25:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f28:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f2e:	8b 52 50             	mov    0x50(%edx),%edx
  801f31:	39 ca                	cmp    %ecx,%edx
  801f33:	75 0d                	jne    801f42 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f35:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f38:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f3d:	8b 40 48             	mov    0x48(%eax),%eax
  801f40:	eb 0f                	jmp    801f51 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f42:	83 c0 01             	add    $0x1,%eax
  801f45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f4a:	75 d9                	jne    801f25 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f59:	89 d0                	mov    %edx,%eax
  801f5b:	c1 e8 16             	shr    $0x16,%eax
  801f5e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f65:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6a:	f6 c1 01             	test   $0x1,%cl
  801f6d:	74 1d                	je     801f8c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6f:	c1 ea 0c             	shr    $0xc,%edx
  801f72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f79:	f6 c2 01             	test   $0x1,%dl
  801f7c:	74 0e                	je     801f8c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f7e:	c1 ea 0c             	shr    $0xc,%edx
  801f81:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f88:	ef 
  801f89:	0f b7 c0             	movzwl %ax,%eax
}
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
