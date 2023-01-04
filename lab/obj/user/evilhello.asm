
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
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800096:	e8 87 04 00 00       	call   800522 <close_all>
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
  80010f:	68 8a 1d 80 00       	push   $0x801d8a
  800114:	6a 23                	push   $0x23
  800116:	68 a7 1d 80 00       	push   $0x801da7
  80011b:	e8 f5 0e 00 00       	call   801015 <_panic>

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
  800190:	68 8a 1d 80 00       	push   $0x801d8a
  800195:	6a 23                	push   $0x23
  800197:	68 a7 1d 80 00       	push   $0x801da7
  80019c:	e8 74 0e 00 00       	call   801015 <_panic>

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
  8001d2:	68 8a 1d 80 00       	push   $0x801d8a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 a7 1d 80 00       	push   $0x801da7
  8001de:	e8 32 0e 00 00       	call   801015 <_panic>

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
  800214:	68 8a 1d 80 00       	push   $0x801d8a
  800219:	6a 23                	push   $0x23
  80021b:	68 a7 1d 80 00       	push   $0x801da7
  800220:	e8 f0 0d 00 00       	call   801015 <_panic>

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
  800256:	68 8a 1d 80 00       	push   $0x801d8a
  80025b:	6a 23                	push   $0x23
  80025d:	68 a7 1d 80 00       	push   $0x801da7
  800262:	e8 ae 0d 00 00       	call   801015 <_panic>

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
  800298:	68 8a 1d 80 00       	push   $0x801d8a
  80029d:	6a 23                	push   $0x23
  80029f:	68 a7 1d 80 00       	push   $0x801da7
  8002a4:	e8 6c 0d 00 00       	call   801015 <_panic>

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
  8002da:	68 8a 1d 80 00       	push   $0x801d8a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 a7 1d 80 00       	push   $0x801da7
  8002e6:	e8 2a 0d 00 00       	call   801015 <_panic>

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
  80033e:	68 8a 1d 80 00       	push   $0x801d8a
  800343:	6a 23                	push   $0x23
  800345:	68 a7 1d 80 00       	push   $0x801da7
  80034a:	e8 c6 0c 00 00       	call   801015 <_panic>

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

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba 34 1e 80 00       	mov    $0x801e34,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 b8 1d 80 00       	push   $0x801db8
  80045e:	e8 8b 0c 00 00       	call   8010ee <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 f9 1d 80 00       	push   $0x801df9
  800688:	e8 61 0a 00 00       	call   8010ee <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 15 1e 80 00       	push   $0x801e15
  80075d:	e8 8c 09 00 00       	call   8010ee <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 d8 1d 80 00       	push   $0x801dd8
  800812:	e8 d7 08 00 00       	call   8010ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 b7 01 00 00       	call   800a92 <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 53 11 00 00       	call   801a75 <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 e4 10 00 00       	call   801a21 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 70 10 00 00       	call   8019ba <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 a0 0c 00 00       	call   801673 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009fc:	68 44 1e 80 00       	push   $0x801e44
  800a01:	68 90 00 00 00       	push   $0x90
  800a06:	68 62 1e 80 00       	push   $0x801e62
  800a0b:	e8 05 06 00 00       	call   801015 <_panic>

00800a10 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a23:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a33:	e8 ce fe ff ff       	call   800906 <fsipc>
  800a38:	89 c3                	mov    %eax,%ebx
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	78 4b                	js     800a89 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a3e:	39 c6                	cmp    %eax,%esi
  800a40:	73 16                	jae    800a58 <devfile_read+0x48>
  800a42:	68 6d 1e 80 00       	push   $0x801e6d
  800a47:	68 74 1e 80 00       	push   $0x801e74
  800a4c:	6a 7c                	push   $0x7c
  800a4e:	68 62 1e 80 00       	push   $0x801e62
  800a53:	e8 bd 05 00 00       	call   801015 <_panic>
	assert(r <= PGSIZE);
  800a58:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a5d:	7e 16                	jle    800a75 <devfile_read+0x65>
  800a5f:	68 89 1e 80 00       	push   $0x801e89
  800a64:	68 74 1e 80 00       	push   $0x801e74
  800a69:	6a 7d                	push   $0x7d
  800a6b:	68 62 1e 80 00       	push   $0x801e62
  800a70:	e8 a0 05 00 00       	call   801015 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a75:	83 ec 04             	sub    $0x4,%esp
  800a78:	50                   	push   %eax
  800a79:	68 00 50 80 00       	push   $0x805000
  800a7e:	ff 75 0c             	pushl  0xc(%ebp)
  800a81:	e8 7f 0d 00 00       	call   801805 <memmove>
	return r;
  800a86:	83 c4 10             	add    $0x10,%esp
}
  800a89:	89 d8                	mov    %ebx,%eax
  800a8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	53                   	push   %ebx
  800a96:	83 ec 20             	sub    $0x20,%esp
  800a99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a9c:	53                   	push   %ebx
  800a9d:	e8 98 0b 00 00       	call   80163a <strlen>
  800aa2:	83 c4 10             	add    $0x10,%esp
  800aa5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aaa:	7f 67                	jg     800b13 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aac:	83 ec 0c             	sub    $0xc,%esp
  800aaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab2:	50                   	push   %eax
  800ab3:	e8 c6 f8 ff ff       	call   80037e <fd_alloc>
  800ab8:	83 c4 10             	add    $0x10,%esp
		return r;
  800abb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800abd:	85 c0                	test   %eax,%eax
  800abf:	78 57                	js     800b18 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ac1:	83 ec 08             	sub    $0x8,%esp
  800ac4:	53                   	push   %ebx
  800ac5:	68 00 50 80 00       	push   $0x805000
  800aca:	e8 a4 0b 00 00       	call   801673 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ada:	b8 01 00 00 00       	mov    $0x1,%eax
  800adf:	e8 22 fe ff ff       	call   800906 <fsipc>
  800ae4:	89 c3                	mov    %eax,%ebx
  800ae6:	83 c4 10             	add    $0x10,%esp
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	79 14                	jns    800b01 <open+0x6f>
		fd_close(fd, 0);
  800aed:	83 ec 08             	sub    $0x8,%esp
  800af0:	6a 00                	push   $0x0
  800af2:	ff 75 f4             	pushl  -0xc(%ebp)
  800af5:	e8 7c f9 ff ff       	call   800476 <fd_close>
		return r;
  800afa:	83 c4 10             	add    $0x10,%esp
  800afd:	89 da                	mov    %ebx,%edx
  800aff:	eb 17                	jmp    800b18 <open+0x86>
	}

	return fd2num(fd);
  800b01:	83 ec 0c             	sub    $0xc,%esp
  800b04:	ff 75 f4             	pushl  -0xc(%ebp)
  800b07:	e8 4b f8 ff ff       	call   800357 <fd2num>
  800b0c:	89 c2                	mov    %eax,%edx
  800b0e:	83 c4 10             	add    $0x10,%esp
  800b11:	eb 05                	jmp    800b18 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b13:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b18:	89 d0                	mov    %edx,%eax
  800b1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b2f:	e8 d2 fd ff ff       	call   800906 <fsipc>
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	ff 75 08             	pushl  0x8(%ebp)
  800b44:	e8 1e f8 ff ff       	call   800367 <fd2data>
  800b49:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b4b:	83 c4 08             	add    $0x8,%esp
  800b4e:	68 95 1e 80 00       	push   $0x801e95
  800b53:	53                   	push   %ebx
  800b54:	e8 1a 0b 00 00       	call   801673 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b59:	8b 46 04             	mov    0x4(%esi),%eax
  800b5c:	2b 06                	sub    (%esi),%eax
  800b5e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b64:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b6b:	00 00 00 
	stat->st_dev = &devpipe;
  800b6e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b75:	30 80 00 
	return 0;
}
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b8e:	53                   	push   %ebx
  800b8f:	6a 00                	push   $0x0
  800b91:	e8 55 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b96:	89 1c 24             	mov    %ebx,(%esp)
  800b99:	e8 c9 f7 ff ff       	call   800367 <fd2data>
  800b9e:	83 c4 08             	add    $0x8,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 00                	push   $0x0
  800ba4:	e8 42 f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 1c             	sub    $0x1c,%esp
  800bb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bba:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bbc:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bca:	e8 df 0e 00 00       	call   801aae <pageref>
  800bcf:	89 c3                	mov    %eax,%ebx
  800bd1:	89 3c 24             	mov    %edi,(%esp)
  800bd4:	e8 d5 0e 00 00       	call   801aae <pageref>
  800bd9:	83 c4 10             	add    $0x10,%esp
  800bdc:	39 c3                	cmp    %eax,%ebx
  800bde:	0f 94 c1             	sete   %cl
  800be1:	0f b6 c9             	movzbl %cl,%ecx
  800be4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800be7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bed:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bf0:	39 ce                	cmp    %ecx,%esi
  800bf2:	74 1b                	je     800c0f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bf4:	39 c3                	cmp    %eax,%ebx
  800bf6:	75 c4                	jne    800bbc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf8:	8b 42 58             	mov    0x58(%edx),%eax
  800bfb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bfe:	50                   	push   %eax
  800bff:	56                   	push   %esi
  800c00:	68 9c 1e 80 00       	push   $0x801e9c
  800c05:	e8 e4 04 00 00       	call   8010ee <cprintf>
  800c0a:	83 c4 10             	add    $0x10,%esp
  800c0d:	eb ad                	jmp    800bbc <_pipeisclosed+0xe>
	}
}
  800c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 28             	sub    $0x28,%esp
  800c23:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c26:	56                   	push   %esi
  800c27:	e8 3b f7 ff ff       	call   800367 <fd2data>
  800c2c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	bf 00 00 00 00       	mov    $0x0,%edi
  800c36:	eb 4b                	jmp    800c83 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c38:	89 da                	mov    %ebx,%edx
  800c3a:	89 f0                	mov    %esi,%eax
  800c3c:	e8 6d ff ff ff       	call   800bae <_pipeisclosed>
  800c41:	85 c0                	test   %eax,%eax
  800c43:	75 48                	jne    800c8d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c45:	e8 fd f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c4d:	8b 0b                	mov    (%ebx),%ecx
  800c4f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c52:	39 d0                	cmp    %edx,%eax
  800c54:	73 e2                	jae    800c38 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c5d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c60:	89 c2                	mov    %eax,%edx
  800c62:	c1 fa 1f             	sar    $0x1f,%edx
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	c1 e9 1b             	shr    $0x1b,%ecx
  800c6a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c6d:	83 e2 1f             	and    $0x1f,%edx
  800c70:	29 ca                	sub    %ecx,%edx
  800c72:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c76:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c80:	83 c7 01             	add    $0x1,%edi
  800c83:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c86:	75 c2                	jne    800c4a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c88:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8b:	eb 05                	jmp    800c92 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 18             	sub    $0x18,%esp
  800ca3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ca6:	57                   	push   %edi
  800ca7:	e8 bb f6 ff ff       	call   800367 <fd2data>
  800cac:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	eb 3d                	jmp    800cf5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cb8:	85 db                	test   %ebx,%ebx
  800cba:	74 04                	je     800cc0 <devpipe_read+0x26>
				return i;
  800cbc:	89 d8                	mov    %ebx,%eax
  800cbe:	eb 44                	jmp    800d04 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cc0:	89 f2                	mov    %esi,%edx
  800cc2:	89 f8                	mov    %edi,%eax
  800cc4:	e8 e5 fe ff ff       	call   800bae <_pipeisclosed>
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	75 32                	jne    800cff <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ccd:	e8 75 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cd2:	8b 06                	mov    (%esi),%eax
  800cd4:	3b 46 04             	cmp    0x4(%esi),%eax
  800cd7:	74 df                	je     800cb8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd9:	99                   	cltd   
  800cda:	c1 ea 1b             	shr    $0x1b,%edx
  800cdd:	01 d0                	add    %edx,%eax
  800cdf:	83 e0 1f             	and    $0x1f,%eax
  800ce2:	29 d0                	sub    %edx,%eax
  800ce4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cef:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf2:	83 c3 01             	add    $0x1,%ebx
  800cf5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800cf8:	75 d8                	jne    800cd2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfd:	eb 05                	jmp    800d04 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cff:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d17:	50                   	push   %eax
  800d18:	e8 61 f6 ff ff       	call   80037e <fd_alloc>
  800d1d:	83 c4 10             	add    $0x10,%esp
  800d20:	89 c2                	mov    %eax,%edx
  800d22:	85 c0                	test   %eax,%eax
  800d24:	0f 88 2c 01 00 00    	js     800e56 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d2a:	83 ec 04             	sub    $0x4,%esp
  800d2d:	68 07 04 00 00       	push   $0x407
  800d32:	ff 75 f4             	pushl  -0xc(%ebp)
  800d35:	6a 00                	push   $0x0
  800d37:	e8 2a f4 ff ff       	call   800166 <sys_page_alloc>
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	89 c2                	mov    %eax,%edx
  800d41:	85 c0                	test   %eax,%eax
  800d43:	0f 88 0d 01 00 00    	js     800e56 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4f:	50                   	push   %eax
  800d50:	e8 29 f6 ff ff       	call   80037e <fd_alloc>
  800d55:	89 c3                	mov    %eax,%ebx
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	0f 88 e2 00 00 00    	js     800e44 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d62:	83 ec 04             	sub    $0x4,%esp
  800d65:	68 07 04 00 00       	push   $0x407
  800d6a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d6d:	6a 00                	push   $0x0
  800d6f:	e8 f2 f3 ff ff       	call   800166 <sys_page_alloc>
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	0f 88 c3 00 00 00    	js     800e44 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	ff 75 f4             	pushl  -0xc(%ebp)
  800d87:	e8 db f5 ff ff       	call   800367 <fd2data>
  800d8c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8e:	83 c4 0c             	add    $0xc,%esp
  800d91:	68 07 04 00 00       	push   $0x407
  800d96:	50                   	push   %eax
  800d97:	6a 00                	push   $0x0
  800d99:	e8 c8 f3 ff ff       	call   800166 <sys_page_alloc>
  800d9e:	89 c3                	mov    %eax,%ebx
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	0f 88 89 00 00 00    	js     800e34 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	ff 75 f0             	pushl  -0x10(%ebp)
  800db1:	e8 b1 f5 ff ff       	call   800367 <fd2data>
  800db6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dbd:	50                   	push   %eax
  800dbe:	6a 00                	push   $0x0
  800dc0:	56                   	push   %esi
  800dc1:	6a 00                	push   $0x0
  800dc3:	e8 e1 f3 ff ff       	call   8001a9 <sys_page_map>
  800dc8:	89 c3                	mov    %eax,%ebx
  800dca:	83 c4 20             	add    $0x20,%esp
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	78 55                	js     800e26 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dd1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dda:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800de6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800def:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	ff 75 f4             	pushl  -0xc(%ebp)
  800e01:	e8 51 f5 ff ff       	call   800357 <fd2num>
  800e06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e09:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e0b:	83 c4 04             	add    $0x4,%esp
  800e0e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e11:	e8 41 f5 ff ff       	call   800357 <fd2num>
  800e16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e19:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e24:	eb 30                	jmp    800e56 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e26:	83 ec 08             	sub    $0x8,%esp
  800e29:	56                   	push   %esi
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 ba f3 ff ff       	call   8001eb <sys_page_unmap>
  800e31:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 aa f3 ff ff       	call   8001eb <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4a:	6a 00                	push   $0x0
  800e4c:	e8 9a f3 ff ff       	call   8001eb <sys_page_unmap>
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e68:	50                   	push   %eax
  800e69:	ff 75 08             	pushl  0x8(%ebp)
  800e6c:	e8 5c f5 ff ff       	call   8003cd <fd_lookup>
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	78 18                	js     800e90 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7e:	e8 e4 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e88:	e8 21 fd ff ff       	call   800bae <_pipeisclosed>
  800e8d:	83 c4 10             	add    $0x10,%esp
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ea2:	68 b4 1e 80 00       	push   $0x801eb4
  800ea7:	ff 75 0c             	pushl  0xc(%ebp)
  800eaa:	e8 c4 07 00 00       	call   801673 <strcpy>
	return 0;
}
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
  800ebc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ec7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ecd:	eb 2d                	jmp    800efc <devcons_write+0x46>
		m = n - tot;
  800ecf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ed4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ed7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800edc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	53                   	push   %ebx
  800ee3:	03 45 0c             	add    0xc(%ebp),%eax
  800ee6:	50                   	push   %eax
  800ee7:	57                   	push   %edi
  800ee8:	e8 18 09 00 00       	call   801805 <memmove>
		sys_cputs(buf, m);
  800eed:	83 c4 08             	add    $0x8,%esp
  800ef0:	53                   	push   %ebx
  800ef1:	57                   	push   %edi
  800ef2:	e8 b3 f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef7:	01 de                	add    %ebx,%esi
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	89 f0                	mov    %esi,%eax
  800efe:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f01:	72 cc                	jb     800ecf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 08             	sub    $0x8,%esp
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f1a:	74 2a                	je     800f46 <devcons_read+0x3b>
  800f1c:	eb 05                	jmp    800f23 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f1e:	e8 24 f2 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f23:	e8 a0 f1 ff ff       	call   8000c8 <sys_cgetc>
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	74 f2                	je     800f1e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 16                	js     800f46 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f30:	83 f8 04             	cmp    $0x4,%eax
  800f33:	74 0c                	je     800f41 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f38:	88 02                	mov    %al,(%edx)
	return 1;
  800f3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3f:	eb 05                	jmp    800f46 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f46:	c9                   	leave  
  800f47:	c3                   	ret    

00800f48 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f51:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f54:	6a 01                	push   $0x1
  800f56:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f59:	50                   	push   %eax
  800f5a:	e8 4b f1 ff ff       	call   8000aa <sys_cputs>
}
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <getchar>:

int
getchar(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f6a:	6a 01                	push   $0x1
  800f6c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f6f:	50                   	push   %eax
  800f70:	6a 00                	push   $0x0
  800f72:	e8 bc f6 ff ff       	call   800633 <read>
	if (r < 0)
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	78 0f                	js     800f8d <getchar+0x29>
		return r;
	if (r < 1)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 06                	jle    800f88 <getchar+0x24>
		return -E_EOF;
	return c;
  800f82:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f86:	eb 05                	jmp    800f8d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f88:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	ff 75 08             	pushl  0x8(%ebp)
  800f9c:	e8 2c f4 ff ff       	call   8003cd <fd_lookup>
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 11                	js     800fb9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb1:	39 10                	cmp    %edx,(%eax)
  800fb3:	0f 94 c0             	sete   %al
  800fb6:	0f b6 c0             	movzbl %al,%eax
}
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <opencons>:

int
opencons(void)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	e8 b4 f3 ff ff       	call   80037e <fd_alloc>
  800fca:	83 c4 10             	add    $0x10,%esp
		return r;
  800fcd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 3e                	js     801011 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd3:	83 ec 04             	sub    $0x4,%esp
  800fd6:	68 07 04 00 00       	push   $0x407
  800fdb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 81 f1 ff ff       	call   800166 <sys_page_alloc>
  800fe5:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 23                	js     801011 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	50                   	push   %eax
  801007:	e8 4b f3 ff ff       	call   800357 <fd2num>
  80100c:	89 c2                	mov    %eax,%edx
  80100e:	83 c4 10             	add    $0x10,%esp
}
  801011:	89 d0                	mov    %edx,%eax
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80101a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80101d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801023:	e8 00 f1 ff ff       	call   800128 <sys_getenvid>
  801028:	83 ec 0c             	sub    $0xc,%esp
  80102b:	ff 75 0c             	pushl  0xc(%ebp)
  80102e:	ff 75 08             	pushl  0x8(%ebp)
  801031:	56                   	push   %esi
  801032:	50                   	push   %eax
  801033:	68 c0 1e 80 00       	push   $0x801ec0
  801038:	e8 b1 00 00 00       	call   8010ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103d:	83 c4 18             	add    $0x18,%esp
  801040:	53                   	push   %ebx
  801041:	ff 75 10             	pushl  0x10(%ebp)
  801044:	e8 54 00 00 00       	call   80109d <vcprintf>
	cprintf("\n");
  801049:	c7 04 24 ad 1e 80 00 	movl   $0x801ead,(%esp)
  801050:	e8 99 00 00 00       	call   8010ee <cprintf>
  801055:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801058:	cc                   	int3   
  801059:	eb fd                	jmp    801058 <_panic+0x43>

0080105b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	53                   	push   %ebx
  80105f:	83 ec 04             	sub    $0x4,%esp
  801062:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801065:	8b 13                	mov    (%ebx),%edx
  801067:	8d 42 01             	lea    0x1(%edx),%eax
  80106a:	89 03                	mov    %eax,(%ebx)
  80106c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801073:	3d ff 00 00 00       	cmp    $0xff,%eax
  801078:	75 1a                	jne    801094 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	68 ff 00 00 00       	push   $0xff
  801082:	8d 43 08             	lea    0x8(%ebx),%eax
  801085:	50                   	push   %eax
  801086:	e8 1f f0 ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  80108b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801091:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801094:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801098:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ad:	00 00 00 
	b.cnt = 0;
  8010b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ba:	ff 75 0c             	pushl  0xc(%ebp)
  8010bd:	ff 75 08             	pushl  0x8(%ebp)
  8010c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	68 5b 10 80 00       	push   $0x80105b
  8010cc:	e8 54 01 00 00       	call   801225 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010d1:	83 c4 08             	add    $0x8,%esp
  8010d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010e0:	50                   	push   %eax
  8010e1:	e8 c4 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8010e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ec:	c9                   	leave  
  8010ed:	c3                   	ret    

008010ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f7:	50                   	push   %eax
  8010f8:	ff 75 08             	pushl  0x8(%ebp)
  8010fb:	e8 9d ff ff ff       	call   80109d <vcprintf>
	va_end(ap);

	return cnt;
}
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	57                   	push   %edi
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	83 ec 1c             	sub    $0x1c,%esp
  80110b:	89 c7                	mov    %eax,%edi
  80110d:	89 d6                	mov    %edx,%esi
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	8b 55 0c             	mov    0xc(%ebp),%edx
  801115:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801118:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80111b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80111e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801123:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801126:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801129:	39 d3                	cmp    %edx,%ebx
  80112b:	72 05                	jb     801132 <printnum+0x30>
  80112d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801130:	77 45                	ja     801177 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801132:	83 ec 0c             	sub    $0xc,%esp
  801135:	ff 75 18             	pushl  0x18(%ebp)
  801138:	8b 45 14             	mov    0x14(%ebp),%eax
  80113b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80113e:	53                   	push   %ebx
  80113f:	ff 75 10             	pushl  0x10(%ebp)
  801142:	83 ec 08             	sub    $0x8,%esp
  801145:	ff 75 e4             	pushl  -0x1c(%ebp)
  801148:	ff 75 e0             	pushl  -0x20(%ebp)
  80114b:	ff 75 dc             	pushl  -0x24(%ebp)
  80114e:	ff 75 d8             	pushl  -0x28(%ebp)
  801151:	e8 9a 09 00 00       	call   801af0 <__udivdi3>
  801156:	83 c4 18             	add    $0x18,%esp
  801159:	52                   	push   %edx
  80115a:	50                   	push   %eax
  80115b:	89 f2                	mov    %esi,%edx
  80115d:	89 f8                	mov    %edi,%eax
  80115f:	e8 9e ff ff ff       	call   801102 <printnum>
  801164:	83 c4 20             	add    $0x20,%esp
  801167:	eb 18                	jmp    801181 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	56                   	push   %esi
  80116d:	ff 75 18             	pushl  0x18(%ebp)
  801170:	ff d7                	call   *%edi
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	eb 03                	jmp    80117a <printnum+0x78>
  801177:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80117a:	83 eb 01             	sub    $0x1,%ebx
  80117d:	85 db                	test   %ebx,%ebx
  80117f:	7f e8                	jg     801169 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	56                   	push   %esi
  801185:	83 ec 04             	sub    $0x4,%esp
  801188:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118b:	ff 75 e0             	pushl  -0x20(%ebp)
  80118e:	ff 75 dc             	pushl  -0x24(%ebp)
  801191:	ff 75 d8             	pushl  -0x28(%ebp)
  801194:	e8 87 0a 00 00       	call   801c20 <__umoddi3>
  801199:	83 c4 14             	add    $0x14,%esp
  80119c:	0f be 80 e3 1e 80 00 	movsbl 0x801ee3(%eax),%eax
  8011a3:	50                   	push   %eax
  8011a4:	ff d7                	call   *%edi
}
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011b4:	83 fa 01             	cmp    $0x1,%edx
  8011b7:	7e 0e                	jle    8011c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011b9:	8b 10                	mov    (%eax),%edx
  8011bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011be:	89 08                	mov    %ecx,(%eax)
  8011c0:	8b 02                	mov    (%edx),%eax
  8011c2:	8b 52 04             	mov    0x4(%edx),%edx
  8011c5:	eb 22                	jmp    8011e9 <getuint+0x38>
	else if (lflag)
  8011c7:	85 d2                	test   %edx,%edx
  8011c9:	74 10                	je     8011db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011cb:	8b 10                	mov    (%eax),%edx
  8011cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d0:	89 08                	mov    %ecx,(%eax)
  8011d2:	8b 02                	mov    (%edx),%eax
  8011d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d9:	eb 0e                	jmp    8011e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011db:	8b 10                	mov    (%eax),%edx
  8011dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e0:	89 08                	mov    %ecx,(%eax)
  8011e2:	8b 02                	mov    (%edx),%eax
  8011e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011f5:	8b 10                	mov    (%eax),%edx
  8011f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8011fa:	73 0a                	jae    801206 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011ff:	89 08                	mov    %ecx,(%eax)
  801201:	8b 45 08             	mov    0x8(%ebp),%eax
  801204:	88 02                	mov    %al,(%edx)
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80120e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801211:	50                   	push   %eax
  801212:	ff 75 10             	pushl  0x10(%ebp)
  801215:	ff 75 0c             	pushl  0xc(%ebp)
  801218:	ff 75 08             	pushl  0x8(%ebp)
  80121b:	e8 05 00 00 00       	call   801225 <vprintfmt>
	va_end(ap);
}
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	c9                   	leave  
  801224:	c3                   	ret    

00801225 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	57                   	push   %edi
  801229:	56                   	push   %esi
  80122a:	53                   	push   %ebx
  80122b:	83 ec 2c             	sub    $0x2c,%esp
  80122e:	8b 75 08             	mov    0x8(%ebp),%esi
  801231:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801234:	8b 7d 10             	mov    0x10(%ebp),%edi
  801237:	eb 12                	jmp    80124b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801239:	85 c0                	test   %eax,%eax
  80123b:	0f 84 89 03 00 00    	je     8015ca <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	53                   	push   %ebx
  801245:	50                   	push   %eax
  801246:	ff d6                	call   *%esi
  801248:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80124b:	83 c7 01             	add    $0x1,%edi
  80124e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801252:	83 f8 25             	cmp    $0x25,%eax
  801255:	75 e2                	jne    801239 <vprintfmt+0x14>
  801257:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80125b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801262:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801269:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801270:	ba 00 00 00 00       	mov    $0x0,%edx
  801275:	eb 07                	jmp    80127e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801277:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80127a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80127e:	8d 47 01             	lea    0x1(%edi),%eax
  801281:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801284:	0f b6 07             	movzbl (%edi),%eax
  801287:	0f b6 c8             	movzbl %al,%ecx
  80128a:	83 e8 23             	sub    $0x23,%eax
  80128d:	3c 55                	cmp    $0x55,%al
  80128f:	0f 87 1a 03 00 00    	ja     8015af <vprintfmt+0x38a>
  801295:	0f b6 c0             	movzbl %al,%eax
  801298:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  80129f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012a6:	eb d6                	jmp    80127e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012b6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012ba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012bd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012c0:	83 fa 09             	cmp    $0x9,%edx
  8012c3:	77 39                	ja     8012fe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012c8:	eb e9                	jmp    8012b3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8012cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8012d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012d3:	8b 00                	mov    (%eax),%eax
  8012d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012db:	eb 27                	jmp    801304 <vprintfmt+0xdf>
  8012dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012e7:	0f 49 c8             	cmovns %eax,%ecx
  8012ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f0:	eb 8c                	jmp    80127e <vprintfmt+0x59>
  8012f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012fc:	eb 80                	jmp    80127e <vprintfmt+0x59>
  8012fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801301:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801304:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801308:	0f 89 70 ff ff ff    	jns    80127e <vprintfmt+0x59>
				width = precision, precision = -1;
  80130e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801311:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801314:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80131b:	e9 5e ff ff ff       	jmp    80127e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801320:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801323:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801326:	e9 53 ff ff ff       	jmp    80127e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80132b:	8b 45 14             	mov    0x14(%ebp),%eax
  80132e:	8d 50 04             	lea    0x4(%eax),%edx
  801331:	89 55 14             	mov    %edx,0x14(%ebp)
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	53                   	push   %ebx
  801338:	ff 30                	pushl  (%eax)
  80133a:	ff d6                	call   *%esi
			break;
  80133c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801342:	e9 04 ff ff ff       	jmp    80124b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801347:	8b 45 14             	mov    0x14(%ebp),%eax
  80134a:	8d 50 04             	lea    0x4(%eax),%edx
  80134d:	89 55 14             	mov    %edx,0x14(%ebp)
  801350:	8b 00                	mov    (%eax),%eax
  801352:	99                   	cltd   
  801353:	31 d0                	xor    %edx,%eax
  801355:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801357:	83 f8 0f             	cmp    $0xf,%eax
  80135a:	7f 0b                	jg     801367 <vprintfmt+0x142>
  80135c:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801363:	85 d2                	test   %edx,%edx
  801365:	75 18                	jne    80137f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801367:	50                   	push   %eax
  801368:	68 fb 1e 80 00       	push   $0x801efb
  80136d:	53                   	push   %ebx
  80136e:	56                   	push   %esi
  80136f:	e8 94 fe ff ff       	call   801208 <printfmt>
  801374:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80137a:	e9 cc fe ff ff       	jmp    80124b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80137f:	52                   	push   %edx
  801380:	68 86 1e 80 00       	push   $0x801e86
  801385:	53                   	push   %ebx
  801386:	56                   	push   %esi
  801387:	e8 7c fe ff ff       	call   801208 <printfmt>
  80138c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801392:	e9 b4 fe ff ff       	jmp    80124b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801397:	8b 45 14             	mov    0x14(%ebp),%eax
  80139a:	8d 50 04             	lea    0x4(%eax),%edx
  80139d:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013a2:	85 ff                	test   %edi,%edi
  8013a4:	b8 f4 1e 80 00       	mov    $0x801ef4,%eax
  8013a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013b0:	0f 8e 94 00 00 00    	jle    80144a <vprintfmt+0x225>
  8013b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013ba:	0f 84 98 00 00 00    	je     801458 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c6:	57                   	push   %edi
  8013c7:	e8 86 02 00 00       	call   801652 <strnlen>
  8013cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013cf:	29 c1                	sub    %eax,%ecx
  8013d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e3:	eb 0f                	jmp    8013f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	53                   	push   %ebx
  8013e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ee:	83 ef 01             	sub    $0x1,%edi
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	85 ff                	test   %edi,%edi
  8013f6:	7f ed                	jg     8013e5 <vprintfmt+0x1c0>
  8013f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8013fe:	85 c9                	test   %ecx,%ecx
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
  801405:	0f 49 c1             	cmovns %ecx,%eax
  801408:	29 c1                	sub    %eax,%ecx
  80140a:	89 75 08             	mov    %esi,0x8(%ebp)
  80140d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801410:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801413:	89 cb                	mov    %ecx,%ebx
  801415:	eb 4d                	jmp    801464 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801417:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80141b:	74 1b                	je     801438 <vprintfmt+0x213>
  80141d:	0f be c0             	movsbl %al,%eax
  801420:	83 e8 20             	sub    $0x20,%eax
  801423:	83 f8 5e             	cmp    $0x5e,%eax
  801426:	76 10                	jbe    801438 <vprintfmt+0x213>
					putch('?', putdat);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	ff 75 0c             	pushl  0xc(%ebp)
  80142e:	6a 3f                	push   $0x3f
  801430:	ff 55 08             	call   *0x8(%ebp)
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	eb 0d                	jmp    801445 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	ff 75 0c             	pushl  0xc(%ebp)
  80143e:	52                   	push   %edx
  80143f:	ff 55 08             	call   *0x8(%ebp)
  801442:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801445:	83 eb 01             	sub    $0x1,%ebx
  801448:	eb 1a                	jmp    801464 <vprintfmt+0x23f>
  80144a:	89 75 08             	mov    %esi,0x8(%ebp)
  80144d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801450:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801453:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801456:	eb 0c                	jmp    801464 <vprintfmt+0x23f>
  801458:	89 75 08             	mov    %esi,0x8(%ebp)
  80145b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80145e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801461:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801464:	83 c7 01             	add    $0x1,%edi
  801467:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80146b:	0f be d0             	movsbl %al,%edx
  80146e:	85 d2                	test   %edx,%edx
  801470:	74 23                	je     801495 <vprintfmt+0x270>
  801472:	85 f6                	test   %esi,%esi
  801474:	78 a1                	js     801417 <vprintfmt+0x1f2>
  801476:	83 ee 01             	sub    $0x1,%esi
  801479:	79 9c                	jns    801417 <vprintfmt+0x1f2>
  80147b:	89 df                	mov    %ebx,%edi
  80147d:	8b 75 08             	mov    0x8(%ebp),%esi
  801480:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801483:	eb 18                	jmp    80149d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	53                   	push   %ebx
  801489:	6a 20                	push   $0x20
  80148b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80148d:	83 ef 01             	sub    $0x1,%edi
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	eb 08                	jmp    80149d <vprintfmt+0x278>
  801495:	89 df                	mov    %ebx,%edi
  801497:	8b 75 08             	mov    0x8(%ebp),%esi
  80149a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149d:	85 ff                	test   %edi,%edi
  80149f:	7f e4                	jg     801485 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a4:	e9 a2 fd ff ff       	jmp    80124b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014a9:	83 fa 01             	cmp    $0x1,%edx
  8014ac:	7e 16                	jle    8014c4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b1:	8d 50 08             	lea    0x8(%eax),%edx
  8014b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b7:	8b 50 04             	mov    0x4(%eax),%edx
  8014ba:	8b 00                	mov    (%eax),%eax
  8014bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014c2:	eb 32                	jmp    8014f6 <vprintfmt+0x2d1>
	else if (lflag)
  8014c4:	85 d2                	test   %edx,%edx
  8014c6:	74 18                	je     8014e0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cb:	8d 50 04             	lea    0x4(%eax),%edx
  8014ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d1:	8b 00                	mov    (%eax),%eax
  8014d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d6:	89 c1                	mov    %eax,%ecx
  8014d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8014db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014de:	eb 16                	jmp    8014f6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e3:	8d 50 04             	lea    0x4(%eax),%edx
  8014e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e9:	8b 00                	mov    (%eax),%eax
  8014eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ee:	89 c1                	mov    %eax,%ecx
  8014f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801501:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801505:	79 74                	jns    80157b <vprintfmt+0x356>
				putch('-', putdat);
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	53                   	push   %ebx
  80150b:	6a 2d                	push   $0x2d
  80150d:	ff d6                	call   *%esi
				num = -(long long) num;
  80150f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801512:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801515:	f7 d8                	neg    %eax
  801517:	83 d2 00             	adc    $0x0,%edx
  80151a:	f7 da                	neg    %edx
  80151c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80151f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801524:	eb 55                	jmp    80157b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801526:	8d 45 14             	lea    0x14(%ebp),%eax
  801529:	e8 83 fc ff ff       	call   8011b1 <getuint>
			base = 10;
  80152e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801533:	eb 46                	jmp    80157b <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801535:	8d 45 14             	lea    0x14(%ebp),%eax
  801538:	e8 74 fc ff ff       	call   8011b1 <getuint>
			base = 8;
  80153d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801542:	eb 37                	jmp    80157b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	53                   	push   %ebx
  801548:	6a 30                	push   $0x30
  80154a:	ff d6                	call   *%esi
			putch('x', putdat);
  80154c:	83 c4 08             	add    $0x8,%esp
  80154f:	53                   	push   %ebx
  801550:	6a 78                	push   $0x78
  801552:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801554:	8b 45 14             	mov    0x14(%ebp),%eax
  801557:	8d 50 04             	lea    0x4(%eax),%edx
  80155a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80155d:	8b 00                	mov    (%eax),%eax
  80155f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801564:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801567:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80156c:	eb 0d                	jmp    80157b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80156e:	8d 45 14             	lea    0x14(%ebp),%eax
  801571:	e8 3b fc ff ff       	call   8011b1 <getuint>
			base = 16;
  801576:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80157b:	83 ec 0c             	sub    $0xc,%esp
  80157e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801582:	57                   	push   %edi
  801583:	ff 75 e0             	pushl  -0x20(%ebp)
  801586:	51                   	push   %ecx
  801587:	52                   	push   %edx
  801588:	50                   	push   %eax
  801589:	89 da                	mov    %ebx,%edx
  80158b:	89 f0                	mov    %esi,%eax
  80158d:	e8 70 fb ff ff       	call   801102 <printnum>
			break;
  801592:	83 c4 20             	add    $0x20,%esp
  801595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801598:	e9 ae fc ff ff       	jmp    80124b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	53                   	push   %ebx
  8015a1:	51                   	push   %ecx
  8015a2:	ff d6                	call   *%esi
			break;
  8015a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015aa:	e9 9c fc ff ff       	jmp    80124b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	6a 25                	push   $0x25
  8015b5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	eb 03                	jmp    8015bf <vprintfmt+0x39a>
  8015bc:	83 ef 01             	sub    $0x1,%edi
  8015bf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015c3:	75 f7                	jne    8015bc <vprintfmt+0x397>
  8015c5:	e9 81 fc ff ff       	jmp    80124b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5f                   	pop    %edi
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    

008015d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	83 ec 18             	sub    $0x18,%esp
  8015d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	74 26                	je     801619 <vsnprintf+0x47>
  8015f3:	85 d2                	test   %edx,%edx
  8015f5:	7e 22                	jle    801619 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015f7:	ff 75 14             	pushl  0x14(%ebp)
  8015fa:	ff 75 10             	pushl  0x10(%ebp)
  8015fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	68 eb 11 80 00       	push   $0x8011eb
  801606:	e8 1a fc ff ff       	call   801225 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80160b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80160e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801611:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb 05                	jmp    80161e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801619:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801626:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801629:	50                   	push   %eax
  80162a:	ff 75 10             	pushl  0x10(%ebp)
  80162d:	ff 75 0c             	pushl  0xc(%ebp)
  801630:	ff 75 08             	pushl  0x8(%ebp)
  801633:	e8 9a ff ff ff       	call   8015d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801638:	c9                   	leave  
  801639:	c3                   	ret    

0080163a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
  801645:	eb 03                	jmp    80164a <strlen+0x10>
		n++;
  801647:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80164a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80164e:	75 f7                	jne    801647 <strlen+0xd>
		n++;
	return n;
}
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    

00801652 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801658:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80165b:	ba 00 00 00 00       	mov    $0x0,%edx
  801660:	eb 03                	jmp    801665 <strnlen+0x13>
		n++;
  801662:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801665:	39 c2                	cmp    %eax,%edx
  801667:	74 08                	je     801671 <strnlen+0x1f>
  801669:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80166d:	75 f3                	jne    801662 <strnlen+0x10>
  80166f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	53                   	push   %ebx
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	83 c2 01             	add    $0x1,%edx
  801682:	83 c1 01             	add    $0x1,%ecx
  801685:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801689:	88 5a ff             	mov    %bl,-0x1(%edx)
  80168c:	84 db                	test   %bl,%bl
  80168e:	75 ef                	jne    80167f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801690:	5b                   	pop    %ebx
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80169a:	53                   	push   %ebx
  80169b:	e8 9a ff ff ff       	call   80163a <strlen>
  8016a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016a3:	ff 75 0c             	pushl  0xc(%ebp)
  8016a6:	01 d8                	add    %ebx,%eax
  8016a8:	50                   	push   %eax
  8016a9:	e8 c5 ff ff ff       	call   801673 <strcpy>
	return dst;
}
  8016ae:	89 d8                	mov    %ebx,%eax
  8016b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8016bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c0:	89 f3                	mov    %esi,%ebx
  8016c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c5:	89 f2                	mov    %esi,%edx
  8016c7:	eb 0f                	jmp    8016d8 <strncpy+0x23>
		*dst++ = *src;
  8016c9:	83 c2 01             	add    $0x1,%edx
  8016cc:	0f b6 01             	movzbl (%ecx),%eax
  8016cf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016d2:	80 39 01             	cmpb   $0x1,(%ecx)
  8016d5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016d8:	39 da                	cmp    %ebx,%edx
  8016da:	75 ed                	jne    8016c9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016dc:	89 f0                	mov    %esi,%eax
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8016f0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016f2:	85 d2                	test   %edx,%edx
  8016f4:	74 21                	je     801717 <strlcpy+0x35>
  8016f6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8016fa:	89 f2                	mov    %esi,%edx
  8016fc:	eb 09                	jmp    801707 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016fe:	83 c2 01             	add    $0x1,%edx
  801701:	83 c1 01             	add    $0x1,%ecx
  801704:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801707:	39 c2                	cmp    %eax,%edx
  801709:	74 09                	je     801714 <strlcpy+0x32>
  80170b:	0f b6 19             	movzbl (%ecx),%ebx
  80170e:	84 db                	test   %bl,%bl
  801710:	75 ec                	jne    8016fe <strlcpy+0x1c>
  801712:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801714:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801717:	29 f0                	sub    %esi,%eax
}
  801719:	5b                   	pop    %ebx
  80171a:	5e                   	pop    %esi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801723:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801726:	eb 06                	jmp    80172e <strcmp+0x11>
		p++, q++;
  801728:	83 c1 01             	add    $0x1,%ecx
  80172b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80172e:	0f b6 01             	movzbl (%ecx),%eax
  801731:	84 c0                	test   %al,%al
  801733:	74 04                	je     801739 <strcmp+0x1c>
  801735:	3a 02                	cmp    (%edx),%al
  801737:	74 ef                	je     801728 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801739:	0f b6 c0             	movzbl %al,%eax
  80173c:	0f b6 12             	movzbl (%edx),%edx
  80173f:	29 d0                	sub    %edx,%eax
}
  801741:	5d                   	pop    %ebp
  801742:	c3                   	ret    

00801743 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	53                   	push   %ebx
  801747:	8b 45 08             	mov    0x8(%ebp),%eax
  80174a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174d:	89 c3                	mov    %eax,%ebx
  80174f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801752:	eb 06                	jmp    80175a <strncmp+0x17>
		n--, p++, q++;
  801754:	83 c0 01             	add    $0x1,%eax
  801757:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80175a:	39 d8                	cmp    %ebx,%eax
  80175c:	74 15                	je     801773 <strncmp+0x30>
  80175e:	0f b6 08             	movzbl (%eax),%ecx
  801761:	84 c9                	test   %cl,%cl
  801763:	74 04                	je     801769 <strncmp+0x26>
  801765:	3a 0a                	cmp    (%edx),%cl
  801767:	74 eb                	je     801754 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801769:	0f b6 00             	movzbl (%eax),%eax
  80176c:	0f b6 12             	movzbl (%edx),%edx
  80176f:	29 d0                	sub    %edx,%eax
  801771:	eb 05                	jmp    801778 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801773:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801778:	5b                   	pop    %ebx
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    

0080177b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801785:	eb 07                	jmp    80178e <strchr+0x13>
		if (*s == c)
  801787:	38 ca                	cmp    %cl,%dl
  801789:	74 0f                	je     80179a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80178b:	83 c0 01             	add    $0x1,%eax
  80178e:	0f b6 10             	movzbl (%eax),%edx
  801791:	84 d2                	test   %dl,%dl
  801793:	75 f2                	jne    801787 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801795:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179a:	5d                   	pop    %ebp
  80179b:	c3                   	ret    

0080179c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017a6:	eb 03                	jmp    8017ab <strfind+0xf>
  8017a8:	83 c0 01             	add    $0x1,%eax
  8017ab:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017ae:	38 ca                	cmp    %cl,%dl
  8017b0:	74 04                	je     8017b6 <strfind+0x1a>
  8017b2:	84 d2                	test   %dl,%dl
  8017b4:	75 f2                	jne    8017a8 <strfind+0xc>
			break;
	return (char *) s;
}
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	57                   	push   %edi
  8017bc:	56                   	push   %esi
  8017bd:	53                   	push   %ebx
  8017be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017c4:	85 c9                	test   %ecx,%ecx
  8017c6:	74 36                	je     8017fe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017ce:	75 28                	jne    8017f8 <memset+0x40>
  8017d0:	f6 c1 03             	test   $0x3,%cl
  8017d3:	75 23                	jne    8017f8 <memset+0x40>
		c &= 0xFF;
  8017d5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017d9:	89 d3                	mov    %edx,%ebx
  8017db:	c1 e3 08             	shl    $0x8,%ebx
  8017de:	89 d6                	mov    %edx,%esi
  8017e0:	c1 e6 18             	shl    $0x18,%esi
  8017e3:	89 d0                	mov    %edx,%eax
  8017e5:	c1 e0 10             	shl    $0x10,%eax
  8017e8:	09 f0                	or     %esi,%eax
  8017ea:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017ec:	89 d8                	mov    %ebx,%eax
  8017ee:	09 d0                	or     %edx,%eax
  8017f0:	c1 e9 02             	shr    $0x2,%ecx
  8017f3:	fc                   	cld    
  8017f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8017f6:	eb 06                	jmp    8017fe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fb:	fc                   	cld    
  8017fc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017fe:	89 f8                	mov    %edi,%eax
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5f                   	pop    %edi
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	57                   	push   %edi
  801809:	56                   	push   %esi
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801810:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801813:	39 c6                	cmp    %eax,%esi
  801815:	73 35                	jae    80184c <memmove+0x47>
  801817:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80181a:	39 d0                	cmp    %edx,%eax
  80181c:	73 2e                	jae    80184c <memmove+0x47>
		s += n;
		d += n;
  80181e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801821:	89 d6                	mov    %edx,%esi
  801823:	09 fe                	or     %edi,%esi
  801825:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80182b:	75 13                	jne    801840 <memmove+0x3b>
  80182d:	f6 c1 03             	test   $0x3,%cl
  801830:	75 0e                	jne    801840 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801832:	83 ef 04             	sub    $0x4,%edi
  801835:	8d 72 fc             	lea    -0x4(%edx),%esi
  801838:	c1 e9 02             	shr    $0x2,%ecx
  80183b:	fd                   	std    
  80183c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80183e:	eb 09                	jmp    801849 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801840:	83 ef 01             	sub    $0x1,%edi
  801843:	8d 72 ff             	lea    -0x1(%edx),%esi
  801846:	fd                   	std    
  801847:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801849:	fc                   	cld    
  80184a:	eb 1d                	jmp    801869 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80184c:	89 f2                	mov    %esi,%edx
  80184e:	09 c2                	or     %eax,%edx
  801850:	f6 c2 03             	test   $0x3,%dl
  801853:	75 0f                	jne    801864 <memmove+0x5f>
  801855:	f6 c1 03             	test   $0x3,%cl
  801858:	75 0a                	jne    801864 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80185a:	c1 e9 02             	shr    $0x2,%ecx
  80185d:	89 c7                	mov    %eax,%edi
  80185f:	fc                   	cld    
  801860:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801862:	eb 05                	jmp    801869 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801864:	89 c7                	mov    %eax,%edi
  801866:	fc                   	cld    
  801867:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801869:	5e                   	pop    %esi
  80186a:	5f                   	pop    %edi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    

0080186d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801870:	ff 75 10             	pushl  0x10(%ebp)
  801873:	ff 75 0c             	pushl  0xc(%ebp)
  801876:	ff 75 08             	pushl  0x8(%ebp)
  801879:	e8 87 ff ff ff       	call   801805 <memmove>
}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188b:	89 c6                	mov    %eax,%esi
  80188d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801890:	eb 1a                	jmp    8018ac <memcmp+0x2c>
		if (*s1 != *s2)
  801892:	0f b6 08             	movzbl (%eax),%ecx
  801895:	0f b6 1a             	movzbl (%edx),%ebx
  801898:	38 d9                	cmp    %bl,%cl
  80189a:	74 0a                	je     8018a6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80189c:	0f b6 c1             	movzbl %cl,%eax
  80189f:	0f b6 db             	movzbl %bl,%ebx
  8018a2:	29 d8                	sub    %ebx,%eax
  8018a4:	eb 0f                	jmp    8018b5 <memcmp+0x35>
		s1++, s2++;
  8018a6:	83 c0 01             	add    $0x1,%eax
  8018a9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ac:	39 f0                	cmp    %esi,%eax
  8018ae:	75 e2                	jne    801892 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b5:	5b                   	pop    %ebx
  8018b6:	5e                   	pop    %esi
  8018b7:	5d                   	pop    %ebp
  8018b8:	c3                   	ret    

008018b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	53                   	push   %ebx
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018c0:	89 c1                	mov    %eax,%ecx
  8018c2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018c5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018c9:	eb 0a                	jmp    8018d5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018cb:	0f b6 10             	movzbl (%eax),%edx
  8018ce:	39 da                	cmp    %ebx,%edx
  8018d0:	74 07                	je     8018d9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018d2:	83 c0 01             	add    $0x1,%eax
  8018d5:	39 c8                	cmp    %ecx,%eax
  8018d7:	72 f2                	jb     8018cb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018d9:	5b                   	pop    %ebx
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	57                   	push   %edi
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018e8:	eb 03                	jmp    8018ed <strtol+0x11>
		s++;
  8018ea:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018ed:	0f b6 01             	movzbl (%ecx),%eax
  8018f0:	3c 20                	cmp    $0x20,%al
  8018f2:	74 f6                	je     8018ea <strtol+0xe>
  8018f4:	3c 09                	cmp    $0x9,%al
  8018f6:	74 f2                	je     8018ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018f8:	3c 2b                	cmp    $0x2b,%al
  8018fa:	75 0a                	jne    801906 <strtol+0x2a>
		s++;
  8018fc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8018ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801904:	eb 11                	jmp    801917 <strtol+0x3b>
  801906:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80190b:	3c 2d                	cmp    $0x2d,%al
  80190d:	75 08                	jne    801917 <strtol+0x3b>
		s++, neg = 1;
  80190f:	83 c1 01             	add    $0x1,%ecx
  801912:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801917:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80191d:	75 15                	jne    801934 <strtol+0x58>
  80191f:	80 39 30             	cmpb   $0x30,(%ecx)
  801922:	75 10                	jne    801934 <strtol+0x58>
  801924:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801928:	75 7c                	jne    8019a6 <strtol+0xca>
		s += 2, base = 16;
  80192a:	83 c1 02             	add    $0x2,%ecx
  80192d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801932:	eb 16                	jmp    80194a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801934:	85 db                	test   %ebx,%ebx
  801936:	75 12                	jne    80194a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801938:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80193d:	80 39 30             	cmpb   $0x30,(%ecx)
  801940:	75 08                	jne    80194a <strtol+0x6e>
		s++, base = 8;
  801942:	83 c1 01             	add    $0x1,%ecx
  801945:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80194a:	b8 00 00 00 00       	mov    $0x0,%eax
  80194f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801952:	0f b6 11             	movzbl (%ecx),%edx
  801955:	8d 72 d0             	lea    -0x30(%edx),%esi
  801958:	89 f3                	mov    %esi,%ebx
  80195a:	80 fb 09             	cmp    $0x9,%bl
  80195d:	77 08                	ja     801967 <strtol+0x8b>
			dig = *s - '0';
  80195f:	0f be d2             	movsbl %dl,%edx
  801962:	83 ea 30             	sub    $0x30,%edx
  801965:	eb 22                	jmp    801989 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801967:	8d 72 9f             	lea    -0x61(%edx),%esi
  80196a:	89 f3                	mov    %esi,%ebx
  80196c:	80 fb 19             	cmp    $0x19,%bl
  80196f:	77 08                	ja     801979 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801971:	0f be d2             	movsbl %dl,%edx
  801974:	83 ea 57             	sub    $0x57,%edx
  801977:	eb 10                	jmp    801989 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801979:	8d 72 bf             	lea    -0x41(%edx),%esi
  80197c:	89 f3                	mov    %esi,%ebx
  80197e:	80 fb 19             	cmp    $0x19,%bl
  801981:	77 16                	ja     801999 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801983:	0f be d2             	movsbl %dl,%edx
  801986:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801989:	3b 55 10             	cmp    0x10(%ebp),%edx
  80198c:	7d 0b                	jge    801999 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80198e:	83 c1 01             	add    $0x1,%ecx
  801991:	0f af 45 10          	imul   0x10(%ebp),%eax
  801995:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801997:	eb b9                	jmp    801952 <strtol+0x76>

	if (endptr)
  801999:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80199d:	74 0d                	je     8019ac <strtol+0xd0>
		*endptr = (char *) s;
  80199f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019a2:	89 0e                	mov    %ecx,(%esi)
  8019a4:	eb 06                	jmp    8019ac <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a6:	85 db                	test   %ebx,%ebx
  8019a8:	74 98                	je     801942 <strtol+0x66>
  8019aa:	eb 9e                	jmp    80194a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019ac:	89 c2                	mov    %eax,%edx
  8019ae:	f7 da                	neg    %edx
  8019b0:	85 ff                	test   %edi,%edi
  8019b2:	0f 45 c2             	cmovne %edx,%eax
}
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	5f                   	pop    %edi
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	56                   	push   %esi
  8019be:	53                   	push   %ebx
  8019bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019c8:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019ca:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019cf:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	50                   	push   %eax
  8019d6:	e8 3b e9 ff ff       	call   800316 <sys_ipc_recv>

	if (from_env_store != NULL)
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	85 f6                	test   %esi,%esi
  8019e0:	74 14                	je     8019f6 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 09                	js     8019f4 <ipc_recv+0x3a>
  8019eb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019f1:	8b 52 74             	mov    0x74(%edx),%edx
  8019f4:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8019f6:	85 db                	test   %ebx,%ebx
  8019f8:	74 14                	je     801a0e <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8019fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 09                	js     801a0c <ipc_recv+0x52>
  801a03:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a09:	8b 52 78             	mov    0x78(%edx),%edx
  801a0c:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 08                	js     801a1a <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a12:	a1 04 40 80 00       	mov    0x804004,%eax
  801a17:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	57                   	push   %edi
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a33:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a35:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a3a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a3d:	ff 75 14             	pushl  0x14(%ebp)
  801a40:	53                   	push   %ebx
  801a41:	56                   	push   %esi
  801a42:	57                   	push   %edi
  801a43:	e8 ab e8 ff ff       	call   8002f3 <sys_ipc_try_send>

		if (err < 0) {
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	79 1e                	jns    801a6d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a4f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a52:	75 07                	jne    801a5b <ipc_send+0x3a>
				sys_yield();
  801a54:	e8 ee e6 ff ff       	call   800147 <sys_yield>
  801a59:	eb e2                	jmp    801a3d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a5b:	50                   	push   %eax
  801a5c:	68 e0 21 80 00       	push   $0x8021e0
  801a61:	6a 49                	push   $0x49
  801a63:	68 ed 21 80 00       	push   $0x8021ed
  801a68:	e8 a8 f5 ff ff       	call   801015 <_panic>
		}

	} while (err < 0);

}
  801a6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a70:	5b                   	pop    %ebx
  801a71:	5e                   	pop    %esi
  801a72:	5f                   	pop    %edi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a7b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a80:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a83:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a89:	8b 52 50             	mov    0x50(%edx),%edx
  801a8c:	39 ca                	cmp    %ecx,%edx
  801a8e:	75 0d                	jne    801a9d <ipc_find_env+0x28>
			return envs[i].env_id;
  801a90:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a93:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a98:	8b 40 48             	mov    0x48(%eax),%eax
  801a9b:	eb 0f                	jmp    801aac <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a9d:	83 c0 01             	add    $0x1,%eax
  801aa0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aa5:	75 d9                	jne    801a80 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab4:	89 d0                	mov    %edx,%eax
  801ab6:	c1 e8 16             	shr    $0x16,%eax
  801ab9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ac0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ac5:	f6 c1 01             	test   $0x1,%cl
  801ac8:	74 1d                	je     801ae7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801aca:	c1 ea 0c             	shr    $0xc,%edx
  801acd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ad4:	f6 c2 01             	test   $0x1,%dl
  801ad7:	74 0e                	je     801ae7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ad9:	c1 ea 0c             	shr    $0xc,%edx
  801adc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ae3:	ef 
  801ae4:	0f b7 c0             	movzwl %ax,%eax
}
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    
  801ae9:	66 90                	xchg   %ax,%ax
  801aeb:	66 90                	xchg   %ax,%ax
  801aed:	66 90                	xchg   %ax,%ax
  801aef:	90                   	nop

00801af0 <__udivdi3>:
  801af0:	55                   	push   %ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 1c             	sub    $0x1c,%esp
  801af7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801afb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801aff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b07:	85 f6                	test   %esi,%esi
  801b09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b0d:	89 ca                	mov    %ecx,%edx
  801b0f:	89 f8                	mov    %edi,%eax
  801b11:	75 3d                	jne    801b50 <__udivdi3+0x60>
  801b13:	39 cf                	cmp    %ecx,%edi
  801b15:	0f 87 c5 00 00 00    	ja     801be0 <__udivdi3+0xf0>
  801b1b:	85 ff                	test   %edi,%edi
  801b1d:	89 fd                	mov    %edi,%ebp
  801b1f:	75 0b                	jne    801b2c <__udivdi3+0x3c>
  801b21:	b8 01 00 00 00       	mov    $0x1,%eax
  801b26:	31 d2                	xor    %edx,%edx
  801b28:	f7 f7                	div    %edi
  801b2a:	89 c5                	mov    %eax,%ebp
  801b2c:	89 c8                	mov    %ecx,%eax
  801b2e:	31 d2                	xor    %edx,%edx
  801b30:	f7 f5                	div    %ebp
  801b32:	89 c1                	mov    %eax,%ecx
  801b34:	89 d8                	mov    %ebx,%eax
  801b36:	89 cf                	mov    %ecx,%edi
  801b38:	f7 f5                	div    %ebp
  801b3a:	89 c3                	mov    %eax,%ebx
  801b3c:	89 d8                	mov    %ebx,%eax
  801b3e:	89 fa                	mov    %edi,%edx
  801b40:	83 c4 1c             	add    $0x1c,%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5f                   	pop    %edi
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    
  801b48:	90                   	nop
  801b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b50:	39 ce                	cmp    %ecx,%esi
  801b52:	77 74                	ja     801bc8 <__udivdi3+0xd8>
  801b54:	0f bd fe             	bsr    %esi,%edi
  801b57:	83 f7 1f             	xor    $0x1f,%edi
  801b5a:	0f 84 98 00 00 00    	je     801bf8 <__udivdi3+0x108>
  801b60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b65:	89 f9                	mov    %edi,%ecx
  801b67:	89 c5                	mov    %eax,%ebp
  801b69:	29 fb                	sub    %edi,%ebx
  801b6b:	d3 e6                	shl    %cl,%esi
  801b6d:	89 d9                	mov    %ebx,%ecx
  801b6f:	d3 ed                	shr    %cl,%ebp
  801b71:	89 f9                	mov    %edi,%ecx
  801b73:	d3 e0                	shl    %cl,%eax
  801b75:	09 ee                	or     %ebp,%esi
  801b77:	89 d9                	mov    %ebx,%ecx
  801b79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b7d:	89 d5                	mov    %edx,%ebp
  801b7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b83:	d3 ed                	shr    %cl,%ebp
  801b85:	89 f9                	mov    %edi,%ecx
  801b87:	d3 e2                	shl    %cl,%edx
  801b89:	89 d9                	mov    %ebx,%ecx
  801b8b:	d3 e8                	shr    %cl,%eax
  801b8d:	09 c2                	or     %eax,%edx
  801b8f:	89 d0                	mov    %edx,%eax
  801b91:	89 ea                	mov    %ebp,%edx
  801b93:	f7 f6                	div    %esi
  801b95:	89 d5                	mov    %edx,%ebp
  801b97:	89 c3                	mov    %eax,%ebx
  801b99:	f7 64 24 0c          	mull   0xc(%esp)
  801b9d:	39 d5                	cmp    %edx,%ebp
  801b9f:	72 10                	jb     801bb1 <__udivdi3+0xc1>
  801ba1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	d3 e6                	shl    %cl,%esi
  801ba9:	39 c6                	cmp    %eax,%esi
  801bab:	73 07                	jae    801bb4 <__udivdi3+0xc4>
  801bad:	39 d5                	cmp    %edx,%ebp
  801baf:	75 03                	jne    801bb4 <__udivdi3+0xc4>
  801bb1:	83 eb 01             	sub    $0x1,%ebx
  801bb4:	31 ff                	xor    %edi,%edi
  801bb6:	89 d8                	mov    %ebx,%eax
  801bb8:	89 fa                	mov    %edi,%edx
  801bba:	83 c4 1c             	add    $0x1c,%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    
  801bc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc8:	31 ff                	xor    %edi,%edi
  801bca:	31 db                	xor    %ebx,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 d8                	mov    %ebx,%eax
  801be2:	f7 f7                	div    %edi
  801be4:	31 ff                	xor    %edi,%edi
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	89 d8                	mov    %ebx,%eax
  801bea:	89 fa                	mov    %edi,%edx
  801bec:	83 c4 1c             	add    $0x1c,%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5f                   	pop    %edi
  801bf2:	5d                   	pop    %ebp
  801bf3:	c3                   	ret    
  801bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	39 ce                	cmp    %ecx,%esi
  801bfa:	72 0c                	jb     801c08 <__udivdi3+0x118>
  801bfc:	31 db                	xor    %ebx,%ebx
  801bfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c02:	0f 87 34 ff ff ff    	ja     801b3c <__udivdi3+0x4c>
  801c08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c0d:	e9 2a ff ff ff       	jmp    801b3c <__udivdi3+0x4c>
  801c12:	66 90                	xchg   %ax,%ax
  801c14:	66 90                	xchg   %ax,%ax
  801c16:	66 90                	xchg   %ax,%ax
  801c18:	66 90                	xchg   %ax,%ax
  801c1a:	66 90                	xchg   %ax,%ax
  801c1c:	66 90                	xchg   %ax,%ax
  801c1e:	66 90                	xchg   %ax,%ax

00801c20 <__umoddi3>:
  801c20:	55                   	push   %ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 1c             	sub    $0x1c,%esp
  801c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c37:	85 d2                	test   %edx,%edx
  801c39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c41:	89 f3                	mov    %esi,%ebx
  801c43:	89 3c 24             	mov    %edi,(%esp)
  801c46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4a:	75 1c                	jne    801c68 <__umoddi3+0x48>
  801c4c:	39 f7                	cmp    %esi,%edi
  801c4e:	76 50                	jbe    801ca0 <__umoddi3+0x80>
  801c50:	89 c8                	mov    %ecx,%eax
  801c52:	89 f2                	mov    %esi,%edx
  801c54:	f7 f7                	div    %edi
  801c56:	89 d0                	mov    %edx,%eax
  801c58:	31 d2                	xor    %edx,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	39 f2                	cmp    %esi,%edx
  801c6a:	89 d0                	mov    %edx,%eax
  801c6c:	77 52                	ja     801cc0 <__umoddi3+0xa0>
  801c6e:	0f bd ea             	bsr    %edx,%ebp
  801c71:	83 f5 1f             	xor    $0x1f,%ebp
  801c74:	75 5a                	jne    801cd0 <__umoddi3+0xb0>
  801c76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c7a:	0f 82 e0 00 00 00    	jb     801d60 <__umoddi3+0x140>
  801c80:	39 0c 24             	cmp    %ecx,(%esp)
  801c83:	0f 86 d7 00 00 00    	jbe    801d60 <__umoddi3+0x140>
  801c89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c91:	83 c4 1c             	add    $0x1c,%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	85 ff                	test   %edi,%edi
  801ca2:	89 fd                	mov    %edi,%ebp
  801ca4:	75 0b                	jne    801cb1 <__umoddi3+0x91>
  801ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	f7 f7                	div    %edi
  801caf:	89 c5                	mov    %eax,%ebp
  801cb1:	89 f0                	mov    %esi,%eax
  801cb3:	31 d2                	xor    %edx,%edx
  801cb5:	f7 f5                	div    %ebp
  801cb7:	89 c8                	mov    %ecx,%eax
  801cb9:	f7 f5                	div    %ebp
  801cbb:	89 d0                	mov    %edx,%eax
  801cbd:	eb 99                	jmp    801c58 <__umoddi3+0x38>
  801cbf:	90                   	nop
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	83 c4 1c             	add    $0x1c,%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    
  801ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	8b 34 24             	mov    (%esp),%esi
  801cd3:	bf 20 00 00 00       	mov    $0x20,%edi
  801cd8:	89 e9                	mov    %ebp,%ecx
  801cda:	29 ef                	sub    %ebp,%edi
  801cdc:	d3 e0                	shl    %cl,%eax
  801cde:	89 f9                	mov    %edi,%ecx
  801ce0:	89 f2                	mov    %esi,%edx
  801ce2:	d3 ea                	shr    %cl,%edx
  801ce4:	89 e9                	mov    %ebp,%ecx
  801ce6:	09 c2                	or     %eax,%edx
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	89 14 24             	mov    %edx,(%esp)
  801ced:	89 f2                	mov    %esi,%edx
  801cef:	d3 e2                	shl    %cl,%edx
  801cf1:	89 f9                	mov    %edi,%ecx
  801cf3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cf7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801cfb:	d3 e8                	shr    %cl,%eax
  801cfd:	89 e9                	mov    %ebp,%ecx
  801cff:	89 c6                	mov    %eax,%esi
  801d01:	d3 e3                	shl    %cl,%ebx
  801d03:	89 f9                	mov    %edi,%ecx
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	d3 e8                	shr    %cl,%eax
  801d09:	89 e9                	mov    %ebp,%ecx
  801d0b:	09 d8                	or     %ebx,%eax
  801d0d:	89 d3                	mov    %edx,%ebx
  801d0f:	89 f2                	mov    %esi,%edx
  801d11:	f7 34 24             	divl   (%esp)
  801d14:	89 d6                	mov    %edx,%esi
  801d16:	d3 e3                	shl    %cl,%ebx
  801d18:	f7 64 24 04          	mull   0x4(%esp)
  801d1c:	39 d6                	cmp    %edx,%esi
  801d1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d22:	89 d1                	mov    %edx,%ecx
  801d24:	89 c3                	mov    %eax,%ebx
  801d26:	72 08                	jb     801d30 <__umoddi3+0x110>
  801d28:	75 11                	jne    801d3b <__umoddi3+0x11b>
  801d2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d2e:	73 0b                	jae    801d3b <__umoddi3+0x11b>
  801d30:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d34:	1b 14 24             	sbb    (%esp),%edx
  801d37:	89 d1                	mov    %edx,%ecx
  801d39:	89 c3                	mov    %eax,%ebx
  801d3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d3f:	29 da                	sub    %ebx,%edx
  801d41:	19 ce                	sbb    %ecx,%esi
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	89 f0                	mov    %esi,%eax
  801d47:	d3 e0                	shl    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	d3 ea                	shr    %cl,%edx
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	d3 ee                	shr    %cl,%esi
  801d51:	09 d0                	or     %edx,%eax
  801d53:	89 f2                	mov    %esi,%edx
  801d55:	83 c4 1c             	add    $0x1c,%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi
  801d60:	29 f9                	sub    %edi,%ecx
  801d62:	19 d6                	sbb    %edx,%esi
  801d64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d6c:	e9 18 ff ff ff       	jmp    801c89 <__umoddi3+0x69>
