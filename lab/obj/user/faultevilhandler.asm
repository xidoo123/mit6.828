
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 2a 05 00 00       	call   8005e0 <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 ca 22 80 00       	push   $0x8022ca
  80012f:	6a 23                	push   $0x23
  800131:	68 e7 22 80 00       	push   $0x8022e7
  800136:	e8 1e 14 00 00       	call   801559 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 ca 22 80 00       	push   $0x8022ca
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 e7 22 80 00       	push   $0x8022e7
  8001b7:	e8 9d 13 00 00       	call   801559 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 ca 22 80 00       	push   $0x8022ca
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 e7 22 80 00       	push   $0x8022e7
  8001f9:	e8 5b 13 00 00       	call   801559 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 ca 22 80 00       	push   $0x8022ca
  800234:	6a 23                	push   $0x23
  800236:	68 e7 22 80 00       	push   $0x8022e7
  80023b:	e8 19 13 00 00       	call   801559 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 ca 22 80 00       	push   $0x8022ca
  800276:	6a 23                	push   $0x23
  800278:	68 e7 22 80 00       	push   $0x8022e7
  80027d:	e8 d7 12 00 00       	call   801559 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 ca 22 80 00       	push   $0x8022ca
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 e7 22 80 00       	push   $0x8022e7
  8002bf:	e8 95 12 00 00       	call   801559 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 ca 22 80 00       	push   $0x8022ca
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 e7 22 80 00       	push   $0x8022e7
  800301:	e8 53 12 00 00       	call   801559 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 ca 22 80 00       	push   $0x8022ca
  80035e:	6a 23                	push   $0x23
  800360:	68 e7 22 80 00       	push   $0x8022e7
  800365:	e8 ef 11 00 00       	call   801559 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800382:	89 d1                	mov    %edx,%ecx
  800384:	89 d3                	mov    %edx,%ebx
  800386:	89 d7                	mov    %edx,%edi
  800388:	89 d6                	mov    %edx,%esi
  80038a:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80039f:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 df                	mov    %ebx,%edi
  8003ac:	89 de                	mov    %ebx,%esi
  8003ae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b0:	85 c0                	test   %eax,%eax
  8003b2:	7e 17                	jle    8003cb <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b4:	83 ec 0c             	sub    $0xc,%esp
  8003b7:	50                   	push   %eax
  8003b8:	6a 0f                	push   $0xf
  8003ba:	68 ca 22 80 00       	push   $0x8022ca
  8003bf:	6a 23                	push   $0x23
  8003c1:	68 e7 22 80 00       	push   $0x8022e7
  8003c6:	e8 8e 11 00 00       	call   801559 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ce:	5b                   	pop    %ebx
  8003cf:	5e                   	pop    %esi
  8003d0:	5f                   	pop    %edi
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	57                   	push   %edi
  8003d7:	56                   	push   %esi
  8003d8:	53                   	push   %ebx
  8003d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8003e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ec:	89 df                	mov    %ebx,%edi
  8003ee:	89 de                	mov    %ebx,%esi
  8003f0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	7e 17                	jle    80040d <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f6:	83 ec 0c             	sub    $0xc,%esp
  8003f9:	50                   	push   %eax
  8003fa:	6a 10                	push   $0x10
  8003fc:	68 ca 22 80 00       	push   $0x8022ca
  800401:	6a 23                	push   $0x23
  800403:	68 e7 22 80 00       	push   $0x8022e7
  800408:	e8 4c 11 00 00       	call   801559 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  80040d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800410:	5b                   	pop    %ebx
  800411:	5e                   	pop    %esi
  800412:	5f                   	pop    %edi
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800418:	8b 45 08             	mov    0x8(%ebp),%eax
  80041b:	05 00 00 00 30       	add    $0x30000000,%eax
  800420:	c1 e8 0c             	shr    $0xc,%eax
}
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    

00800425 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800428:	8b 45 08             	mov    0x8(%ebp),%eax
  80042b:	05 00 00 00 30       	add    $0x30000000,%eax
  800430:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800435:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800442:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800447:	89 c2                	mov    %eax,%edx
  800449:	c1 ea 16             	shr    $0x16,%edx
  80044c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800453:	f6 c2 01             	test   $0x1,%dl
  800456:	74 11                	je     800469 <fd_alloc+0x2d>
  800458:	89 c2                	mov    %eax,%edx
  80045a:	c1 ea 0c             	shr    $0xc,%edx
  80045d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800464:	f6 c2 01             	test   $0x1,%dl
  800467:	75 09                	jne    800472 <fd_alloc+0x36>
			*fd_store = fd;
  800469:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046b:	b8 00 00 00 00       	mov    $0x0,%eax
  800470:	eb 17                	jmp    800489 <fd_alloc+0x4d>
  800472:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800477:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80047c:	75 c9                	jne    800447 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80047e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800484:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800491:	83 f8 1f             	cmp    $0x1f,%eax
  800494:	77 36                	ja     8004cc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800496:	c1 e0 0c             	shl    $0xc,%eax
  800499:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80049e:	89 c2                	mov    %eax,%edx
  8004a0:	c1 ea 16             	shr    $0x16,%edx
  8004a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004aa:	f6 c2 01             	test   $0x1,%dl
  8004ad:	74 24                	je     8004d3 <fd_lookup+0x48>
  8004af:	89 c2                	mov    %eax,%edx
  8004b1:	c1 ea 0c             	shr    $0xc,%edx
  8004b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004bb:	f6 c2 01             	test   $0x1,%dl
  8004be:	74 1a                	je     8004da <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	eb 13                	jmp    8004df <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004d1:	eb 0c                	jmp    8004df <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004d8:	eb 05                	jmp    8004df <fd_lookup+0x54>
  8004da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ea:	ba 74 23 80 00       	mov    $0x802374,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004ef:	eb 13                	jmp    800504 <dev_lookup+0x23>
  8004f1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004f4:	39 08                	cmp    %ecx,(%eax)
  8004f6:	75 0c                	jne    800504 <dev_lookup+0x23>
			*dev = devtab[i];
  8004f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	eb 2e                	jmp    800532 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800504:	8b 02                	mov    (%edx),%eax
  800506:	85 c0                	test   %eax,%eax
  800508:	75 e7                	jne    8004f1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80050a:	a1 08 40 80 00       	mov    0x804008,%eax
  80050f:	8b 40 48             	mov    0x48(%eax),%eax
  800512:	83 ec 04             	sub    $0x4,%esp
  800515:	51                   	push   %ecx
  800516:	50                   	push   %eax
  800517:	68 f8 22 80 00       	push   $0x8022f8
  80051c:	e8 11 11 00 00       	call   801632 <cprintf>
	*dev = 0;
  800521:	8b 45 0c             	mov    0xc(%ebp),%eax
  800524:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	56                   	push   %esi
  800538:	53                   	push   %ebx
  800539:	83 ec 10             	sub    $0x10,%esp
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800542:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80054c:	c1 e8 0c             	shr    $0xc,%eax
  80054f:	50                   	push   %eax
  800550:	e8 36 ff ff ff       	call   80048b <fd_lookup>
  800555:	83 c4 08             	add    $0x8,%esp
  800558:	85 c0                	test   %eax,%eax
  80055a:	78 05                	js     800561 <fd_close+0x2d>
	    || fd != fd2)
  80055c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80055f:	74 0c                	je     80056d <fd_close+0x39>
		return (must_exist ? r : 0);
  800561:	84 db                	test   %bl,%bl
  800563:	ba 00 00 00 00       	mov    $0x0,%edx
  800568:	0f 44 c2             	cmove  %edx,%eax
  80056b:	eb 41                	jmp    8005ae <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800573:	50                   	push   %eax
  800574:	ff 36                	pushl  (%esi)
  800576:	e8 66 ff ff ff       	call   8004e1 <dev_lookup>
  80057b:	89 c3                	mov    %eax,%ebx
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	85 c0                	test   %eax,%eax
  800582:	78 1a                	js     80059e <fd_close+0x6a>
		if (dev->dev_close)
  800584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800587:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80058a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80058f:	85 c0                	test   %eax,%eax
  800591:	74 0b                	je     80059e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800593:	83 ec 0c             	sub    $0xc,%esp
  800596:	56                   	push   %esi
  800597:	ff d0                	call   *%eax
  800599:	89 c3                	mov    %eax,%ebx
  80059b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	56                   	push   %esi
  8005a2:	6a 00                	push   $0x0
  8005a4:	e8 5d fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	89 d8                	mov    %ebx,%eax
}
  8005ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005b1:	5b                   	pop    %ebx
  8005b2:	5e                   	pop    %esi
  8005b3:	5d                   	pop    %ebp
  8005b4:	c3                   	ret    

008005b5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005be:	50                   	push   %eax
  8005bf:	ff 75 08             	pushl  0x8(%ebp)
  8005c2:	e8 c4 fe ff ff       	call   80048b <fd_lookup>
  8005c7:	83 c4 08             	add    $0x8,%esp
  8005ca:	85 c0                	test   %eax,%eax
  8005cc:	78 10                	js     8005de <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	6a 01                	push   $0x1
  8005d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8005d6:	e8 59 ff ff ff       	call   800534 <fd_close>
  8005db:	83 c4 10             	add    $0x10,%esp
}
  8005de:	c9                   	leave  
  8005df:	c3                   	ret    

008005e0 <close_all>:

void
close_all(void)
{
  8005e0:	55                   	push   %ebp
  8005e1:	89 e5                	mov    %esp,%ebp
  8005e3:	53                   	push   %ebx
  8005e4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	e8 c0 ff ff ff       	call   8005b5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005f5:	83 c3 01             	add    $0x1,%ebx
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	83 fb 20             	cmp    $0x20,%ebx
  8005fe:	75 ec                	jne    8005ec <close_all+0xc>
		close(i);
}
  800600:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800603:	c9                   	leave  
  800604:	c3                   	ret    

00800605 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	57                   	push   %edi
  800609:	56                   	push   %esi
  80060a:	53                   	push   %ebx
  80060b:	83 ec 2c             	sub    $0x2c,%esp
  80060e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800611:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800614:	50                   	push   %eax
  800615:	ff 75 08             	pushl  0x8(%ebp)
  800618:	e8 6e fe ff ff       	call   80048b <fd_lookup>
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	85 c0                	test   %eax,%eax
  800622:	0f 88 c1 00 00 00    	js     8006e9 <dup+0xe4>
		return r;
	close(newfdnum);
  800628:	83 ec 0c             	sub    $0xc,%esp
  80062b:	56                   	push   %esi
  80062c:	e8 84 ff ff ff       	call   8005b5 <close>

	newfd = INDEX2FD(newfdnum);
  800631:	89 f3                	mov    %esi,%ebx
  800633:	c1 e3 0c             	shl    $0xc,%ebx
  800636:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80063c:	83 c4 04             	add    $0x4,%esp
  80063f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800642:	e8 de fd ff ff       	call   800425 <fd2data>
  800647:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800649:	89 1c 24             	mov    %ebx,(%esp)
  80064c:	e8 d4 fd ff ff       	call   800425 <fd2data>
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800657:	89 f8                	mov    %edi,%eax
  800659:	c1 e8 16             	shr    $0x16,%eax
  80065c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800663:	a8 01                	test   $0x1,%al
  800665:	74 37                	je     80069e <dup+0x99>
  800667:	89 f8                	mov    %edi,%eax
  800669:	c1 e8 0c             	shr    $0xc,%eax
  80066c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800673:	f6 c2 01             	test   $0x1,%dl
  800676:	74 26                	je     80069e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800678:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80067f:	83 ec 0c             	sub    $0xc,%esp
  800682:	25 07 0e 00 00       	and    $0xe07,%eax
  800687:	50                   	push   %eax
  800688:	ff 75 d4             	pushl  -0x2c(%ebp)
  80068b:	6a 00                	push   $0x0
  80068d:	57                   	push   %edi
  80068e:	6a 00                	push   $0x0
  800690:	e8 2f fb ff ff       	call   8001c4 <sys_page_map>
  800695:	89 c7                	mov    %eax,%edi
  800697:	83 c4 20             	add    $0x20,%esp
  80069a:	85 c0                	test   %eax,%eax
  80069c:	78 2e                	js     8006cc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80069e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a1:	89 d0                	mov    %edx,%eax
  8006a3:	c1 e8 0c             	shr    $0xc,%eax
  8006a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006ad:	83 ec 0c             	sub    $0xc,%esp
  8006b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8006b5:	50                   	push   %eax
  8006b6:	53                   	push   %ebx
  8006b7:	6a 00                	push   $0x0
  8006b9:	52                   	push   %edx
  8006ba:	6a 00                	push   $0x0
  8006bc:	e8 03 fb ff ff       	call   8001c4 <sys_page_map>
  8006c1:	89 c7                	mov    %eax,%edi
  8006c3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006c6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006c8:	85 ff                	test   %edi,%edi
  8006ca:	79 1d                	jns    8006e9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	6a 00                	push   $0x0
  8006d2:	e8 2f fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006d7:	83 c4 08             	add    $0x8,%esp
  8006da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006dd:	6a 00                	push   $0x0
  8006df:	e8 22 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	89 f8                	mov    %edi,%eax
}
  8006e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	53                   	push   %ebx
  8006f5:	83 ec 14             	sub    $0x14,%esp
  8006f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	53                   	push   %ebx
  800700:	e8 86 fd ff ff       	call   80048b <fd_lookup>
  800705:	83 c4 08             	add    $0x8,%esp
  800708:	89 c2                	mov    %eax,%edx
  80070a:	85 c0                	test   %eax,%eax
  80070c:	78 6d                	js     80077b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800714:	50                   	push   %eax
  800715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800718:	ff 30                	pushl  (%eax)
  80071a:	e8 c2 fd ff ff       	call   8004e1 <dev_lookup>
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	85 c0                	test   %eax,%eax
  800724:	78 4c                	js     800772 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800726:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800729:	8b 42 08             	mov    0x8(%edx),%eax
  80072c:	83 e0 03             	and    $0x3,%eax
  80072f:	83 f8 01             	cmp    $0x1,%eax
  800732:	75 21                	jne    800755 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800734:	a1 08 40 80 00       	mov    0x804008,%eax
  800739:	8b 40 48             	mov    0x48(%eax),%eax
  80073c:	83 ec 04             	sub    $0x4,%esp
  80073f:	53                   	push   %ebx
  800740:	50                   	push   %eax
  800741:	68 39 23 80 00       	push   $0x802339
  800746:	e8 e7 0e 00 00       	call   801632 <cprintf>
		return -E_INVAL;
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800753:	eb 26                	jmp    80077b <read+0x8a>
	}
	if (!dev->dev_read)
  800755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800758:	8b 40 08             	mov    0x8(%eax),%eax
  80075b:	85 c0                	test   %eax,%eax
  80075d:	74 17                	je     800776 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80075f:	83 ec 04             	sub    $0x4,%esp
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	52                   	push   %edx
  800769:	ff d0                	call   *%eax
  80076b:	89 c2                	mov    %eax,%edx
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	eb 09                	jmp    80077b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800772:	89 c2                	mov    %eax,%edx
  800774:	eb 05                	jmp    80077b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800776:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80077b:	89 d0                	mov    %edx,%eax
  80077d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	57                   	push   %edi
  800786:	56                   	push   %esi
  800787:	53                   	push   %ebx
  800788:	83 ec 0c             	sub    $0xc,%esp
  80078b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80078e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	eb 21                	jmp    8007b9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800798:	83 ec 04             	sub    $0x4,%esp
  80079b:	89 f0                	mov    %esi,%eax
  80079d:	29 d8                	sub    %ebx,%eax
  80079f:	50                   	push   %eax
  8007a0:	89 d8                	mov    %ebx,%eax
  8007a2:	03 45 0c             	add    0xc(%ebp),%eax
  8007a5:	50                   	push   %eax
  8007a6:	57                   	push   %edi
  8007a7:	e8 45 ff ff ff       	call   8006f1 <read>
		if (m < 0)
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	78 10                	js     8007c3 <readn+0x41>
			return m;
		if (m == 0)
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	74 0a                	je     8007c1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007b7:	01 c3                	add    %eax,%ebx
  8007b9:	39 f3                	cmp    %esi,%ebx
  8007bb:	72 db                	jb     800798 <readn+0x16>
  8007bd:	89 d8                	mov    %ebx,%eax
  8007bf:	eb 02                	jmp    8007c3 <readn+0x41>
  8007c1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007c6:	5b                   	pop    %ebx
  8007c7:	5e                   	pop    %esi
  8007c8:	5f                   	pop    %edi
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	83 ec 14             	sub    $0x14,%esp
  8007d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d8:	50                   	push   %eax
  8007d9:	53                   	push   %ebx
  8007da:	e8 ac fc ff ff       	call   80048b <fd_lookup>
  8007df:	83 c4 08             	add    $0x8,%esp
  8007e2:	89 c2                	mov    %eax,%edx
  8007e4:	85 c0                	test   %eax,%eax
  8007e6:	78 68                	js     800850 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f2:	ff 30                	pushl  (%eax)
  8007f4:	e8 e8 fc ff ff       	call   8004e1 <dev_lookup>
  8007f9:	83 c4 10             	add    $0x10,%esp
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	78 47                	js     800847 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800803:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800807:	75 21                	jne    80082a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800809:	a1 08 40 80 00       	mov    0x804008,%eax
  80080e:	8b 40 48             	mov    0x48(%eax),%eax
  800811:	83 ec 04             	sub    $0x4,%esp
  800814:	53                   	push   %ebx
  800815:	50                   	push   %eax
  800816:	68 55 23 80 00       	push   $0x802355
  80081b:	e8 12 0e 00 00       	call   801632 <cprintf>
		return -E_INVAL;
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800828:	eb 26                	jmp    800850 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80082a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80082d:	8b 52 0c             	mov    0xc(%edx),%edx
  800830:	85 d2                	test   %edx,%edx
  800832:	74 17                	je     80084b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800834:	83 ec 04             	sub    $0x4,%esp
  800837:	ff 75 10             	pushl  0x10(%ebp)
  80083a:	ff 75 0c             	pushl  0xc(%ebp)
  80083d:	50                   	push   %eax
  80083e:	ff d2                	call   *%edx
  800840:	89 c2                	mov    %eax,%edx
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	eb 09                	jmp    800850 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800847:	89 c2                	mov    %eax,%edx
  800849:	eb 05                	jmp    800850 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80084b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800850:	89 d0                	mov    %edx,%eax
  800852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <seek>:

int
seek(int fdnum, off_t offset)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80085d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	ff 75 08             	pushl  0x8(%ebp)
  800864:	e8 22 fc ff ff       	call   80048b <fd_lookup>
  800869:	83 c4 08             	add    $0x8,%esp
  80086c:	85 c0                	test   %eax,%eax
  80086e:	78 0e                	js     80087e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800870:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
  800876:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	53                   	push   %ebx
  800884:	83 ec 14             	sub    $0x14,%esp
  800887:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088d:	50                   	push   %eax
  80088e:	53                   	push   %ebx
  80088f:	e8 f7 fb ff ff       	call   80048b <fd_lookup>
  800894:	83 c4 08             	add    $0x8,%esp
  800897:	89 c2                	mov    %eax,%edx
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 65                	js     800902 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a3:	50                   	push   %eax
  8008a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a7:	ff 30                	pushl  (%eax)
  8008a9:	e8 33 fc ff ff       	call   8004e1 <dev_lookup>
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	78 44                	js     8008f9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008bc:	75 21                	jne    8008df <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008be:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008c3:	8b 40 48             	mov    0x48(%eax),%eax
  8008c6:	83 ec 04             	sub    $0x4,%esp
  8008c9:	53                   	push   %ebx
  8008ca:	50                   	push   %eax
  8008cb:	68 18 23 80 00       	push   $0x802318
  8008d0:	e8 5d 0d 00 00       	call   801632 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008dd:	eb 23                	jmp    800902 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008e2:	8b 52 18             	mov    0x18(%edx),%edx
  8008e5:	85 d2                	test   %edx,%edx
  8008e7:	74 14                	je     8008fd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	ff 75 0c             	pushl  0xc(%ebp)
  8008ef:	50                   	push   %eax
  8008f0:	ff d2                	call   *%edx
  8008f2:	89 c2                	mov    %eax,%edx
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	eb 09                	jmp    800902 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f9:	89 c2                	mov    %eax,%edx
  8008fb:	eb 05                	jmp    800902 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800902:	89 d0                	mov    %edx,%eax
  800904:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800907:	c9                   	leave  
  800908:	c3                   	ret    

00800909 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	53                   	push   %ebx
  80090d:	83 ec 14             	sub    $0x14,%esp
  800910:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800913:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800916:	50                   	push   %eax
  800917:	ff 75 08             	pushl  0x8(%ebp)
  80091a:	e8 6c fb ff ff       	call   80048b <fd_lookup>
  80091f:	83 c4 08             	add    $0x8,%esp
  800922:	89 c2                	mov    %eax,%edx
  800924:	85 c0                	test   %eax,%eax
  800926:	78 58                	js     800980 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800928:	83 ec 08             	sub    $0x8,%esp
  80092b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80092e:	50                   	push   %eax
  80092f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800932:	ff 30                	pushl  (%eax)
  800934:	e8 a8 fb ff ff       	call   8004e1 <dev_lookup>
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	85 c0                	test   %eax,%eax
  80093e:	78 37                	js     800977 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800940:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800943:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800947:	74 32                	je     80097b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800949:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80094c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800953:	00 00 00 
	stat->st_isdir = 0;
  800956:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80095d:	00 00 00 
	stat->st_dev = dev;
  800960:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800966:	83 ec 08             	sub    $0x8,%esp
  800969:	53                   	push   %ebx
  80096a:	ff 75 f0             	pushl  -0x10(%ebp)
  80096d:	ff 50 14             	call   *0x14(%eax)
  800970:	89 c2                	mov    %eax,%edx
  800972:	83 c4 10             	add    $0x10,%esp
  800975:	eb 09                	jmp    800980 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800977:	89 c2                	mov    %eax,%edx
  800979:	eb 05                	jmp    800980 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80097b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800980:	89 d0                	mov    %edx,%eax
  800982:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80098c:	83 ec 08             	sub    $0x8,%esp
  80098f:	6a 00                	push   $0x0
  800991:	ff 75 08             	pushl  0x8(%ebp)
  800994:	e8 d6 01 00 00       	call   800b6f <open>
  800999:	89 c3                	mov    %eax,%ebx
  80099b:	83 c4 10             	add    $0x10,%esp
  80099e:	85 c0                	test   %eax,%eax
  8009a0:	78 1b                	js     8009bd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	50                   	push   %eax
  8009a9:	e8 5b ff ff ff       	call   800909 <fstat>
  8009ae:	89 c6                	mov    %eax,%esi
	close(fd);
  8009b0:	89 1c 24             	mov    %ebx,(%esp)
  8009b3:	e8 fd fb ff ff       	call   8005b5 <close>
	return r;
  8009b8:	83 c4 10             	add    $0x10,%esp
  8009bb:	89 f0                	mov    %esi,%eax
}
  8009bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	89 c6                	mov    %eax,%esi
  8009cb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009d4:	75 12                	jne    8009e8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009d6:	83 ec 0c             	sub    $0xc,%esp
  8009d9:	6a 01                	push   $0x1
  8009db:	e8 d9 15 00 00       	call   801fb9 <ipc_find_env>
  8009e0:	a3 00 40 80 00       	mov    %eax,0x804000
  8009e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009e8:	6a 07                	push   $0x7
  8009ea:	68 00 50 80 00       	push   $0x805000
  8009ef:	56                   	push   %esi
  8009f0:	ff 35 00 40 80 00    	pushl  0x804000
  8009f6:	e8 6a 15 00 00       	call   801f65 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009fb:	83 c4 0c             	add    $0xc,%esp
  8009fe:	6a 00                	push   $0x0
  800a00:	53                   	push   %ebx
  800a01:	6a 00                	push   $0x0
  800a03:	e8 f6 14 00 00       	call   801efe <ipc_recv>
}
  800a08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a23:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a28:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800a32:	e8 8d ff ff ff       	call   8009c4 <fsipc>
}
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 40 0c             	mov    0xc(%eax),%eax
  800a45:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4f:	b8 06 00 00 00       	mov    $0x6,%eax
  800a54:	e8 6b ff ff ff       	call   8009c4 <fsipc>
}
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a70:	ba 00 00 00 00       	mov    $0x0,%edx
  800a75:	b8 05 00 00 00       	mov    $0x5,%eax
  800a7a:	e8 45 ff ff ff       	call   8009c4 <fsipc>
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	78 2c                	js     800aaf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a83:	83 ec 08             	sub    $0x8,%esp
  800a86:	68 00 50 80 00       	push   $0x805000
  800a8b:	53                   	push   %ebx
  800a8c:	e8 26 11 00 00       	call   801bb7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a91:	a1 80 50 80 00       	mov    0x805080,%eax
  800a96:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a9c:	a1 84 50 80 00       	mov    0x805084,%eax
  800aa1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800aa7:	83 c4 10             	add    $0x10,%esp
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab2:	c9                   	leave  
  800ab3:	c3                   	ret    

00800ab4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	83 ec 0c             	sub    $0xc,%esp
  800aba:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800abd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac0:	8b 52 0c             	mov    0xc(%edx),%edx
  800ac3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800ac9:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800ace:	50                   	push   %eax
  800acf:	ff 75 0c             	pushl  0xc(%ebp)
  800ad2:	68 08 50 80 00       	push   $0x805008
  800ad7:	e8 6d 12 00 00       	call   801d49 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800adc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae6:	e8 d9 fe ff ff       	call   8009c4 <fsipc>

}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	8b 40 0c             	mov    0xc(%eax),%eax
  800afb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b00:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b10:	e8 af fe ff ff       	call   8009c4 <fsipc>
  800b15:	89 c3                	mov    %eax,%ebx
  800b17:	85 c0                	test   %eax,%eax
  800b19:	78 4b                	js     800b66 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b1b:	39 c6                	cmp    %eax,%esi
  800b1d:	73 16                	jae    800b35 <devfile_read+0x48>
  800b1f:	68 88 23 80 00       	push   $0x802388
  800b24:	68 8f 23 80 00       	push   $0x80238f
  800b29:	6a 7c                	push   $0x7c
  800b2b:	68 a4 23 80 00       	push   $0x8023a4
  800b30:	e8 24 0a 00 00       	call   801559 <_panic>
	assert(r <= PGSIZE);
  800b35:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b3a:	7e 16                	jle    800b52 <devfile_read+0x65>
  800b3c:	68 af 23 80 00       	push   $0x8023af
  800b41:	68 8f 23 80 00       	push   $0x80238f
  800b46:	6a 7d                	push   $0x7d
  800b48:	68 a4 23 80 00       	push   $0x8023a4
  800b4d:	e8 07 0a 00 00       	call   801559 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b52:	83 ec 04             	sub    $0x4,%esp
  800b55:	50                   	push   %eax
  800b56:	68 00 50 80 00       	push   $0x805000
  800b5b:	ff 75 0c             	pushl  0xc(%ebp)
  800b5e:	e8 e6 11 00 00       	call   801d49 <memmove>
	return r;
  800b63:	83 c4 10             	add    $0x10,%esp
}
  800b66:	89 d8                	mov    %ebx,%eax
  800b68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	53                   	push   %ebx
  800b73:	83 ec 20             	sub    $0x20,%esp
  800b76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b79:	53                   	push   %ebx
  800b7a:	e8 ff 0f 00 00       	call   801b7e <strlen>
  800b7f:	83 c4 10             	add    $0x10,%esp
  800b82:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b87:	7f 67                	jg     800bf0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b8f:	50                   	push   %eax
  800b90:	e8 a7 f8 ff ff       	call   80043c <fd_alloc>
  800b95:	83 c4 10             	add    $0x10,%esp
		return r;
  800b98:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	78 57                	js     800bf5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b9e:	83 ec 08             	sub    $0x8,%esp
  800ba1:	53                   	push   %ebx
  800ba2:	68 00 50 80 00       	push   $0x805000
  800ba7:	e8 0b 10 00 00       	call   801bb7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bb7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbc:	e8 03 fe ff ff       	call   8009c4 <fsipc>
  800bc1:	89 c3                	mov    %eax,%ebx
  800bc3:	83 c4 10             	add    $0x10,%esp
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	79 14                	jns    800bde <open+0x6f>
		fd_close(fd, 0);
  800bca:	83 ec 08             	sub    $0x8,%esp
  800bcd:	6a 00                	push   $0x0
  800bcf:	ff 75 f4             	pushl  -0xc(%ebp)
  800bd2:	e8 5d f9 ff ff       	call   800534 <fd_close>
		return r;
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	89 da                	mov    %ebx,%edx
  800bdc:	eb 17                	jmp    800bf5 <open+0x86>
	}

	return fd2num(fd);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	ff 75 f4             	pushl  -0xc(%ebp)
  800be4:	e8 2c f8 ff ff       	call   800415 <fd2num>
  800be9:	89 c2                	mov    %eax,%edx
  800beb:	83 c4 10             	add    $0x10,%esp
  800bee:	eb 05                	jmp    800bf5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bf0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bf5:	89 d0                	mov    %edx,%eax
  800bf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
  800c07:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0c:	e8 b3 fd ff ff       	call   8009c4 <fsipc>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c19:	68 bb 23 80 00       	push   $0x8023bb
  800c1e:	ff 75 0c             	pushl  0xc(%ebp)
  800c21:	e8 91 0f 00 00       	call   801bb7 <strcpy>
	return 0;
}
  800c26:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    

00800c2d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	53                   	push   %ebx
  800c31:	83 ec 10             	sub    $0x10,%esp
  800c34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c37:	53                   	push   %ebx
  800c38:	e8 b5 13 00 00       	call   801ff2 <pageref>
  800c3d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c40:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c45:	83 f8 01             	cmp    $0x1,%eax
  800c48:	75 10                	jne    800c5a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	ff 73 0c             	pushl  0xc(%ebx)
  800c50:	e8 c0 02 00 00       	call   800f15 <nsipc_close>
  800c55:	89 c2                	mov    %eax,%edx
  800c57:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c5a:	89 d0                	mov    %edx,%eax
  800c5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c5f:	c9                   	leave  
  800c60:	c3                   	ret    

00800c61 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c67:	6a 00                	push   $0x0
  800c69:	ff 75 10             	pushl  0x10(%ebp)
  800c6c:	ff 75 0c             	pushl  0xc(%ebp)
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	ff 70 0c             	pushl  0xc(%eax)
  800c75:	e8 78 03 00 00       	call   800ff2 <nsipc_send>
}
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c82:	6a 00                	push   $0x0
  800c84:	ff 75 10             	pushl  0x10(%ebp)
  800c87:	ff 75 0c             	pushl  0xc(%ebp)
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	ff 70 0c             	pushl  0xc(%eax)
  800c90:	e8 f1 02 00 00       	call   800f86 <nsipc_recv>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c9d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ca0:	52                   	push   %edx
  800ca1:	50                   	push   %eax
  800ca2:	e8 e4 f7 ff ff       	call   80048b <fd_lookup>
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	85 c0                	test   %eax,%eax
  800cac:	78 17                	js     800cc5 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb1:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800cb7:	39 08                	cmp    %ecx,(%eax)
  800cb9:	75 05                	jne    800cc0 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cbb:	8b 40 0c             	mov    0xc(%eax),%eax
  800cbe:	eb 05                	jmp    800cc5 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800cc0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800cc5:	c9                   	leave  
  800cc6:	c3                   	ret    

00800cc7 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 1c             	sub    $0x1c,%esp
  800ccf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800cd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cd4:	50                   	push   %eax
  800cd5:	e8 62 f7 ff ff       	call   80043c <fd_alloc>
  800cda:	89 c3                	mov    %eax,%ebx
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	78 1b                	js     800cfe <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800ce3:	83 ec 04             	sub    $0x4,%esp
  800ce6:	68 07 04 00 00       	push   $0x407
  800ceb:	ff 75 f4             	pushl  -0xc(%ebp)
  800cee:	6a 00                	push   $0x0
  800cf0:	e8 8c f4 ff ff       	call   800181 <sys_page_alloc>
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	79 10                	jns    800d0e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	56                   	push   %esi
  800d02:	e8 0e 02 00 00       	call   800f15 <nsipc_close>
		return r;
  800d07:	83 c4 10             	add    $0x10,%esp
  800d0a:	89 d8                	mov    %ebx,%eax
  800d0c:	eb 24                	jmp    800d32 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d0e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d17:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d1c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d23:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	e8 e6 f6 ff ff       	call   800415 <fd2num>
  800d2f:	83 c4 10             	add    $0x10,%esp
}
  800d32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	e8 50 ff ff ff       	call   800c97 <fd2sockid>
		return r;
  800d47:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	78 1f                	js     800d6c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d4d:	83 ec 04             	sub    $0x4,%esp
  800d50:	ff 75 10             	pushl  0x10(%ebp)
  800d53:	ff 75 0c             	pushl  0xc(%ebp)
  800d56:	50                   	push   %eax
  800d57:	e8 12 01 00 00       	call   800e6e <nsipc_accept>
  800d5c:	83 c4 10             	add    $0x10,%esp
		return r;
  800d5f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	78 07                	js     800d6c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d65:	e8 5d ff ff ff       	call   800cc7 <alloc_sockfd>
  800d6a:	89 c1                	mov    %eax,%ecx
}
  800d6c:	89 c8                	mov    %ecx,%eax
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	e8 19 ff ff ff       	call   800c97 <fd2sockid>
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	78 12                	js     800d94 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	ff 75 10             	pushl  0x10(%ebp)
  800d88:	ff 75 0c             	pushl  0xc(%ebp)
  800d8b:	50                   	push   %eax
  800d8c:	e8 2d 01 00 00       	call   800ebe <nsipc_bind>
  800d91:	83 c4 10             	add    $0x10,%esp
}
  800d94:	c9                   	leave  
  800d95:	c3                   	ret    

00800d96 <shutdown>:

int
shutdown(int s, int how)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9f:	e8 f3 fe ff ff       	call   800c97 <fd2sockid>
  800da4:	85 c0                	test   %eax,%eax
  800da6:	78 0f                	js     800db7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	ff 75 0c             	pushl  0xc(%ebp)
  800dae:	50                   	push   %eax
  800daf:	e8 3f 01 00 00       	call   800ef3 <nsipc_shutdown>
  800db4:	83 c4 10             	add    $0x10,%esp
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	e8 d0 fe ff ff       	call   800c97 <fd2sockid>
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	78 12                	js     800ddd <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800dcb:	83 ec 04             	sub    $0x4,%esp
  800dce:	ff 75 10             	pushl  0x10(%ebp)
  800dd1:	ff 75 0c             	pushl  0xc(%ebp)
  800dd4:	50                   	push   %eax
  800dd5:	e8 55 01 00 00       	call   800f2f <nsipc_connect>
  800dda:	83 c4 10             	add    $0x10,%esp
}
  800ddd:	c9                   	leave  
  800dde:	c3                   	ret    

00800ddf <listen>:

int
listen(int s, int backlog)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	e8 aa fe ff ff       	call   800c97 <fd2sockid>
  800ded:	85 c0                	test   %eax,%eax
  800def:	78 0f                	js     800e00 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800df1:	83 ec 08             	sub    $0x8,%esp
  800df4:	ff 75 0c             	pushl  0xc(%ebp)
  800df7:	50                   	push   %eax
  800df8:	e8 67 01 00 00       	call   800f64 <nsipc_listen>
  800dfd:	83 c4 10             	add    $0x10,%esp
}
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e08:	ff 75 10             	pushl  0x10(%ebp)
  800e0b:	ff 75 0c             	pushl  0xc(%ebp)
  800e0e:	ff 75 08             	pushl  0x8(%ebp)
  800e11:	e8 3a 02 00 00       	call   801050 <nsipc_socket>
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	78 05                	js     800e22 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800e1d:	e8 a5 fe ff ff       	call   800cc7 <alloc_sockfd>
}
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    

00800e24 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	53                   	push   %ebx
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e2d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e34:	75 12                	jne    800e48 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	6a 02                	push   $0x2
  800e3b:	e8 79 11 00 00       	call   801fb9 <ipc_find_env>
  800e40:	a3 04 40 80 00       	mov    %eax,0x804004
  800e45:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e48:	6a 07                	push   $0x7
  800e4a:	68 00 60 80 00       	push   $0x806000
  800e4f:	53                   	push   %ebx
  800e50:	ff 35 04 40 80 00    	pushl  0x804004
  800e56:	e8 0a 11 00 00       	call   801f65 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e5b:	83 c4 0c             	add    $0xc,%esp
  800e5e:	6a 00                	push   $0x0
  800e60:	6a 00                	push   $0x0
  800e62:	6a 00                	push   $0x0
  800e64:	e8 95 10 00 00       	call   801efe <ipc_recv>
}
  800e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
  800e79:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e7e:	8b 06                	mov    (%esi),%eax
  800e80:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e85:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8a:	e8 95 ff ff ff       	call   800e24 <nsipc>
  800e8f:	89 c3                	mov    %eax,%ebx
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 20                	js     800eb5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	ff 35 10 60 80 00    	pushl  0x806010
  800e9e:	68 00 60 80 00       	push   $0x806000
  800ea3:	ff 75 0c             	pushl  0xc(%ebp)
  800ea6:	e8 9e 0e 00 00       	call   801d49 <memmove>
		*addrlen = ret->ret_addrlen;
  800eab:	a1 10 60 80 00       	mov    0x806010,%eax
  800eb0:	89 06                	mov    %eax,(%esi)
  800eb2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800eb5:	89 d8                	mov    %ebx,%eax
  800eb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ed0:	53                   	push   %ebx
  800ed1:	ff 75 0c             	pushl  0xc(%ebp)
  800ed4:	68 04 60 80 00       	push   $0x806004
  800ed9:	e8 6b 0e 00 00       	call   801d49 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ede:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ee4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ee9:	e8 36 ff ff ff       	call   800e24 <nsipc>
}
  800eee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f04:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f09:	b8 03 00 00 00       	mov    $0x3,%eax
  800f0e:	e8 11 ff ff ff       	call   800e24 <nsipc>
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <nsipc_close>:

int
nsipc_close(int s)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f23:	b8 04 00 00 00       	mov    $0x4,%eax
  800f28:	e8 f7 fe ff ff       	call   800e24 <nsipc>
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	53                   	push   %ebx
  800f33:	83 ec 08             	sub    $0x8,%esp
  800f36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f41:	53                   	push   %ebx
  800f42:	ff 75 0c             	pushl  0xc(%ebp)
  800f45:	68 04 60 80 00       	push   $0x806004
  800f4a:	e8 fa 0d 00 00       	call   801d49 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f4f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f55:	b8 05 00 00 00       	mov    $0x5,%eax
  800f5a:	e8 c5 fe ff ff       	call   800e24 <nsipc>
}
  800f5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f75:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f7f:	e8 a0 fe ff ff       	call   800e24 <nsipc>
}
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	56                   	push   %esi
  800f8a:	53                   	push   %ebx
  800f8b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f96:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f9f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fa4:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa9:	e8 76 fe ff ff       	call   800e24 <nsipc>
  800fae:	89 c3                	mov    %eax,%ebx
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 35                	js     800fe9 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800fb4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fb9:	7f 04                	jg     800fbf <nsipc_recv+0x39>
  800fbb:	39 c6                	cmp    %eax,%esi
  800fbd:	7d 16                	jge    800fd5 <nsipc_recv+0x4f>
  800fbf:	68 c7 23 80 00       	push   $0x8023c7
  800fc4:	68 8f 23 80 00       	push   $0x80238f
  800fc9:	6a 62                	push   $0x62
  800fcb:	68 dc 23 80 00       	push   $0x8023dc
  800fd0:	e8 84 05 00 00       	call   801559 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fd5:	83 ec 04             	sub    $0x4,%esp
  800fd8:	50                   	push   %eax
  800fd9:	68 00 60 80 00       	push   $0x806000
  800fde:	ff 75 0c             	pushl  0xc(%ebp)
  800fe1:	e8 63 0d 00 00       	call   801d49 <memmove>
  800fe6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	53                   	push   %ebx
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801004:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80100a:	7e 16                	jle    801022 <nsipc_send+0x30>
  80100c:	68 e8 23 80 00       	push   $0x8023e8
  801011:	68 8f 23 80 00       	push   $0x80238f
  801016:	6a 6d                	push   $0x6d
  801018:	68 dc 23 80 00       	push   $0x8023dc
  80101d:	e8 37 05 00 00       	call   801559 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	53                   	push   %ebx
  801026:	ff 75 0c             	pushl  0xc(%ebp)
  801029:	68 0c 60 80 00       	push   $0x80600c
  80102e:	e8 16 0d 00 00       	call   801d49 <memmove>
	nsipcbuf.send.req_size = size;
  801033:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801039:	8b 45 14             	mov    0x14(%ebp),%eax
  80103c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801041:	b8 08 00 00 00       	mov    $0x8,%eax
  801046:	e8 d9 fd ff ff       	call   800e24 <nsipc>
}
  80104b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104e:	c9                   	leave  
  80104f:	c3                   	ret    

00801050 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801056:	8b 45 08             	mov    0x8(%ebp),%eax
  801059:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80105e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801061:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801066:	8b 45 10             	mov    0x10(%ebp),%eax
  801069:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80106e:	b8 09 00 00 00       	mov    $0x9,%eax
  801073:	e8 ac fd ff ff       	call   800e24 <nsipc>
}
  801078:	c9                   	leave  
  801079:	c3                   	ret    

0080107a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	ff 75 08             	pushl  0x8(%ebp)
  801088:	e8 98 f3 ff ff       	call   800425 <fd2data>
  80108d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80108f:	83 c4 08             	add    $0x8,%esp
  801092:	68 f4 23 80 00       	push   $0x8023f4
  801097:	53                   	push   %ebx
  801098:	e8 1a 0b 00 00       	call   801bb7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80109d:	8b 46 04             	mov    0x4(%esi),%eax
  8010a0:	2b 06                	sub    (%esi),%eax
  8010a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010af:	00 00 00 
	stat->st_dev = &devpipe;
  8010b2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8010b9:	30 80 00 
	return 0;
}
  8010bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c4:	5b                   	pop    %ebx
  8010c5:	5e                   	pop    %esi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	53                   	push   %ebx
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010d2:	53                   	push   %ebx
  8010d3:	6a 00                	push   $0x0
  8010d5:	e8 2c f1 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010da:	89 1c 24             	mov    %ebx,(%esp)
  8010dd:	e8 43 f3 ff ff       	call   800425 <fd2data>
  8010e2:	83 c4 08             	add    $0x8,%esp
  8010e5:	50                   	push   %eax
  8010e6:	6a 00                	push   $0x0
  8010e8:	e8 19 f1 ff ff       	call   800206 <sys_page_unmap>
}
  8010ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 1c             	sub    $0x1c,%esp
  8010fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010fe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801100:	a1 08 40 80 00       	mov    0x804008,%eax
  801105:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	ff 75 e0             	pushl  -0x20(%ebp)
  80110e:	e8 df 0e 00 00       	call   801ff2 <pageref>
  801113:	89 c3                	mov    %eax,%ebx
  801115:	89 3c 24             	mov    %edi,(%esp)
  801118:	e8 d5 0e 00 00       	call   801ff2 <pageref>
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	39 c3                	cmp    %eax,%ebx
  801122:	0f 94 c1             	sete   %cl
  801125:	0f b6 c9             	movzbl %cl,%ecx
  801128:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80112b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801131:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801134:	39 ce                	cmp    %ecx,%esi
  801136:	74 1b                	je     801153 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801138:	39 c3                	cmp    %eax,%ebx
  80113a:	75 c4                	jne    801100 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80113c:	8b 42 58             	mov    0x58(%edx),%eax
  80113f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801142:	50                   	push   %eax
  801143:	56                   	push   %esi
  801144:	68 fb 23 80 00       	push   $0x8023fb
  801149:	e8 e4 04 00 00       	call   801632 <cprintf>
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	eb ad                	jmp    801100 <_pipeisclosed+0xe>
	}
}
  801153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5f                   	pop    %edi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 28             	sub    $0x28,%esp
  801167:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80116a:	56                   	push   %esi
  80116b:	e8 b5 f2 ff ff       	call   800425 <fd2data>
  801170:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	bf 00 00 00 00       	mov    $0x0,%edi
  80117a:	eb 4b                	jmp    8011c7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80117c:	89 da                	mov    %ebx,%edx
  80117e:	89 f0                	mov    %esi,%eax
  801180:	e8 6d ff ff ff       	call   8010f2 <_pipeisclosed>
  801185:	85 c0                	test   %eax,%eax
  801187:	75 48                	jne    8011d1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801189:	e8 d4 ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80118e:	8b 43 04             	mov    0x4(%ebx),%eax
  801191:	8b 0b                	mov    (%ebx),%ecx
  801193:	8d 51 20             	lea    0x20(%ecx),%edx
  801196:	39 d0                	cmp    %edx,%eax
  801198:	73 e2                	jae    80117c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80119a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011a1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 fa 1f             	sar    $0x1f,%edx
  8011a9:	89 d1                	mov    %edx,%ecx
  8011ab:	c1 e9 1b             	shr    $0x1b,%ecx
  8011ae:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011b1:	83 e2 1f             	and    $0x1f,%edx
  8011b4:	29 ca                	sub    %ecx,%edx
  8011b6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011be:	83 c0 01             	add    $0x1,%eax
  8011c1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c4:	83 c7 01             	add    $0x1,%edi
  8011c7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011ca:	75 c2                	jne    80118e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8011cf:	eb 05                	jmp    8011d6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d9:	5b                   	pop    %ebx
  8011da:	5e                   	pop    %esi
  8011db:	5f                   	pop    %edi
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	57                   	push   %edi
  8011e2:	56                   	push   %esi
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 18             	sub    $0x18,%esp
  8011e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011ea:	57                   	push   %edi
  8011eb:	e8 35 f2 ff ff       	call   800425 <fd2data>
  8011f0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fa:	eb 3d                	jmp    801239 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011fc:	85 db                	test   %ebx,%ebx
  8011fe:	74 04                	je     801204 <devpipe_read+0x26>
				return i;
  801200:	89 d8                	mov    %ebx,%eax
  801202:	eb 44                	jmp    801248 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801204:	89 f2                	mov    %esi,%edx
  801206:	89 f8                	mov    %edi,%eax
  801208:	e8 e5 fe ff ff       	call   8010f2 <_pipeisclosed>
  80120d:	85 c0                	test   %eax,%eax
  80120f:	75 32                	jne    801243 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801211:	e8 4c ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801216:	8b 06                	mov    (%esi),%eax
  801218:	3b 46 04             	cmp    0x4(%esi),%eax
  80121b:	74 df                	je     8011fc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80121d:	99                   	cltd   
  80121e:	c1 ea 1b             	shr    $0x1b,%edx
  801221:	01 d0                	add    %edx,%eax
  801223:	83 e0 1f             	and    $0x1f,%eax
  801226:	29 d0                	sub    %edx,%eax
  801228:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80122d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801230:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801233:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801236:	83 c3 01             	add    $0x1,%ebx
  801239:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80123c:	75 d8                	jne    801216 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80123e:	8b 45 10             	mov    0x10(%ebp),%eax
  801241:	eb 05                	jmp    801248 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801243:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
  801255:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	e8 db f1 ff ff       	call   80043c <fd_alloc>
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	89 c2                	mov    %eax,%edx
  801266:	85 c0                	test   %eax,%eax
  801268:	0f 88 2c 01 00 00    	js     80139a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126e:	83 ec 04             	sub    $0x4,%esp
  801271:	68 07 04 00 00       	push   $0x407
  801276:	ff 75 f4             	pushl  -0xc(%ebp)
  801279:	6a 00                	push   $0x0
  80127b:	e8 01 ef ff ff       	call   800181 <sys_page_alloc>
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	89 c2                	mov    %eax,%edx
  801285:	85 c0                	test   %eax,%eax
  801287:	0f 88 0d 01 00 00    	js     80139a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	e8 a3 f1 ff ff       	call   80043c <fd_alloc>
  801299:	89 c3                	mov    %eax,%ebx
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	0f 88 e2 00 00 00    	js     801388 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	68 07 04 00 00       	push   $0x407
  8012ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b1:	6a 00                	push   $0x0
  8012b3:	e8 c9 ee ff ff       	call   800181 <sys_page_alloc>
  8012b8:	89 c3                	mov    %eax,%ebx
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	0f 88 c3 00 00 00    	js     801388 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012cb:	e8 55 f1 ff ff       	call   800425 <fd2data>
  8012d0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012d2:	83 c4 0c             	add    $0xc,%esp
  8012d5:	68 07 04 00 00       	push   $0x407
  8012da:	50                   	push   %eax
  8012db:	6a 00                	push   $0x0
  8012dd:	e8 9f ee ff ff       	call   800181 <sys_page_alloc>
  8012e2:	89 c3                	mov    %eax,%ebx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	0f 88 89 00 00 00    	js     801378 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f5:	e8 2b f1 ff ff       	call   800425 <fd2data>
  8012fa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801301:	50                   	push   %eax
  801302:	6a 00                	push   $0x0
  801304:	56                   	push   %esi
  801305:	6a 00                	push   $0x0
  801307:	e8 b8 ee ff ff       	call   8001c4 <sys_page_map>
  80130c:	89 c3                	mov    %eax,%ebx
  80130e:	83 c4 20             	add    $0x20,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 55                	js     80136a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801315:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80131b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801320:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801323:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80132a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801330:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801333:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801335:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801338:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80133f:	83 ec 0c             	sub    $0xc,%esp
  801342:	ff 75 f4             	pushl  -0xc(%ebp)
  801345:	e8 cb f0 ff ff       	call   800415 <fd2num>
  80134a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80134f:	83 c4 04             	add    $0x4,%esp
  801352:	ff 75 f0             	pushl  -0x10(%ebp)
  801355:	e8 bb f0 ff ff       	call   800415 <fd2num>
  80135a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80135d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	ba 00 00 00 00       	mov    $0x0,%edx
  801368:	eb 30                	jmp    80139a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	56                   	push   %esi
  80136e:	6a 00                	push   $0x0
  801370:	e8 91 ee ff ff       	call   800206 <sys_page_unmap>
  801375:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	ff 75 f0             	pushl  -0x10(%ebp)
  80137e:	6a 00                	push   $0x0
  801380:	e8 81 ee ff ff       	call   800206 <sys_page_unmap>
  801385:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	ff 75 f4             	pushl  -0xc(%ebp)
  80138e:	6a 00                	push   $0x0
  801390:	e8 71 ee ff ff       	call   800206 <sys_page_unmap>
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80139a:	89 d0                	mov    %edx,%eax
  80139c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	ff 75 08             	pushl  0x8(%ebp)
  8013b0:	e8 d6 f0 ff ff       	call   80048b <fd_lookup>
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 18                	js     8013d4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c2:	e8 5e f0 ff ff       	call   800425 <fd2data>
	return _pipeisclosed(fd, p);
  8013c7:	89 c2                	mov    %eax,%edx
  8013c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cc:	e8 21 fd ff ff       	call   8010f2 <_pipeisclosed>
  8013d1:	83 c4 10             	add    $0x10,%esp
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013e6:	68 13 24 80 00       	push   $0x802413
  8013eb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ee:	e8 c4 07 00 00       	call   801bb7 <strcpy>
	return 0;
}
  8013f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	57                   	push   %edi
  8013fe:	56                   	push   %esi
  8013ff:	53                   	push   %ebx
  801400:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801406:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80140b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801411:	eb 2d                	jmp    801440 <devcons_write+0x46>
		m = n - tot;
  801413:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801416:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801418:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80141b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801420:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801423:	83 ec 04             	sub    $0x4,%esp
  801426:	53                   	push   %ebx
  801427:	03 45 0c             	add    0xc(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	57                   	push   %edi
  80142c:	e8 18 09 00 00       	call   801d49 <memmove>
		sys_cputs(buf, m);
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	53                   	push   %ebx
  801435:	57                   	push   %edi
  801436:	e8 8a ec ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80143b:	01 de                	add    %ebx,%esi
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	89 f0                	mov    %esi,%eax
  801442:	3b 75 10             	cmp    0x10(%ebp),%esi
  801445:	72 cc                	jb     801413 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801447:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144a:	5b                   	pop    %ebx
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 08             	sub    $0x8,%esp
  801455:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80145a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80145e:	74 2a                	je     80148a <devcons_read+0x3b>
  801460:	eb 05                	jmp    801467 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801462:	e8 fb ec ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801467:	e8 77 ec ff ff       	call   8000e3 <sys_cgetc>
  80146c:	85 c0                	test   %eax,%eax
  80146e:	74 f2                	je     801462 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801470:	85 c0                	test   %eax,%eax
  801472:	78 16                	js     80148a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801474:	83 f8 04             	cmp    $0x4,%eax
  801477:	74 0c                	je     801485 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801479:	8b 55 0c             	mov    0xc(%ebp),%edx
  80147c:	88 02                	mov    %al,(%edx)
	return 1;
  80147e:	b8 01 00 00 00       	mov    $0x1,%eax
  801483:	eb 05                	jmp    80148a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80148a:	c9                   	leave  
  80148b:	c3                   	ret    

0080148c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801498:	6a 01                	push   $0x1
  80149a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	e8 22 ec ff ff       	call   8000c5 <sys_cputs>
}
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <getchar>:

int
getchar(void)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014ae:	6a 01                	push   $0x1
  8014b0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014b3:	50                   	push   %eax
  8014b4:	6a 00                	push   $0x0
  8014b6:	e8 36 f2 ff ff       	call   8006f1 <read>
	if (r < 0)
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 0f                	js     8014d1 <getchar+0x29>
		return r;
	if (r < 1)
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	7e 06                	jle    8014cc <getchar+0x24>
		return -E_EOF;
	return c;
  8014c6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014ca:	eb 05                	jmp    8014d1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014cc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	ff 75 08             	pushl  0x8(%ebp)
  8014e0:	e8 a6 ef ff ff       	call   80048b <fd_lookup>
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 11                	js     8014fd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ef:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014f5:	39 10                	cmp    %edx,(%eax)
  8014f7:	0f 94 c0             	sete   %al
  8014fa:	0f b6 c0             	movzbl %al,%eax
}
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <opencons>:

int
opencons(void)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	e8 2e ef ff ff       	call   80043c <fd_alloc>
  80150e:	83 c4 10             	add    $0x10,%esp
		return r;
  801511:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801513:	85 c0                	test   %eax,%eax
  801515:	78 3e                	js     801555 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	68 07 04 00 00       	push   $0x407
  80151f:	ff 75 f4             	pushl  -0xc(%ebp)
  801522:	6a 00                	push   $0x0
  801524:	e8 58 ec ff ff       	call   800181 <sys_page_alloc>
  801529:	83 c4 10             	add    $0x10,%esp
		return r;
  80152c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 23                	js     801555 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801532:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801538:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80153d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801540:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	50                   	push   %eax
  80154b:	e8 c5 ee ff ff       	call   800415 <fd2num>
  801550:	89 c2                	mov    %eax,%edx
  801552:	83 c4 10             	add    $0x10,%esp
}
  801555:	89 d0                	mov    %edx,%eax
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80155e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801561:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801567:	e8 d7 eb ff ff       	call   800143 <sys_getenvid>
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	ff 75 0c             	pushl  0xc(%ebp)
  801572:	ff 75 08             	pushl  0x8(%ebp)
  801575:	56                   	push   %esi
  801576:	50                   	push   %eax
  801577:	68 20 24 80 00       	push   $0x802420
  80157c:	e8 b1 00 00 00       	call   801632 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801581:	83 c4 18             	add    $0x18,%esp
  801584:	53                   	push   %ebx
  801585:	ff 75 10             	pushl  0x10(%ebp)
  801588:	e8 54 00 00 00       	call   8015e1 <vcprintf>
	cprintf("\n");
  80158d:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  801594:	e8 99 00 00 00       	call   801632 <cprintf>
  801599:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80159c:	cc                   	int3   
  80159d:	eb fd                	jmp    80159c <_panic+0x43>

0080159f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 04             	sub    $0x4,%esp
  8015a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015a9:	8b 13                	mov    (%ebx),%edx
  8015ab:	8d 42 01             	lea    0x1(%edx),%eax
  8015ae:	89 03                	mov    %eax,(%ebx)
  8015b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015bc:	75 1a                	jne    8015d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	68 ff 00 00 00       	push   $0xff
  8015c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8015c9:	50                   	push   %eax
  8015ca:	e8 f6 ea ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8015cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015f1:	00 00 00 
	b.cnt = 0;
  8015f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015fe:	ff 75 0c             	pushl  0xc(%ebp)
  801601:	ff 75 08             	pushl  0x8(%ebp)
  801604:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80160a:	50                   	push   %eax
  80160b:	68 9f 15 80 00       	push   $0x80159f
  801610:	e8 54 01 00 00       	call   801769 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801615:	83 c4 08             	add    $0x8,%esp
  801618:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80161e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	e8 9b ea ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80162a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801638:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80163b:	50                   	push   %eax
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 9d ff ff ff       	call   8015e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	57                   	push   %edi
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
  80164c:	83 ec 1c             	sub    $0x1c,%esp
  80164f:	89 c7                	mov    %eax,%edi
  801651:	89 d6                	mov    %edx,%esi
  801653:	8b 45 08             	mov    0x8(%ebp),%eax
  801656:	8b 55 0c             	mov    0xc(%ebp),%edx
  801659:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80165c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80165f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801662:	bb 00 00 00 00       	mov    $0x0,%ebx
  801667:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80166a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80166d:	39 d3                	cmp    %edx,%ebx
  80166f:	72 05                	jb     801676 <printnum+0x30>
  801671:	39 45 10             	cmp    %eax,0x10(%ebp)
  801674:	77 45                	ja     8016bb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801676:	83 ec 0c             	sub    $0xc,%esp
  801679:	ff 75 18             	pushl  0x18(%ebp)
  80167c:	8b 45 14             	mov    0x14(%ebp),%eax
  80167f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801682:	53                   	push   %ebx
  801683:	ff 75 10             	pushl  0x10(%ebp)
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	ff 75 e4             	pushl  -0x1c(%ebp)
  80168c:	ff 75 e0             	pushl  -0x20(%ebp)
  80168f:	ff 75 dc             	pushl  -0x24(%ebp)
  801692:	ff 75 d8             	pushl  -0x28(%ebp)
  801695:	e8 96 09 00 00       	call   802030 <__udivdi3>
  80169a:	83 c4 18             	add    $0x18,%esp
  80169d:	52                   	push   %edx
  80169e:	50                   	push   %eax
  80169f:	89 f2                	mov    %esi,%edx
  8016a1:	89 f8                	mov    %edi,%eax
  8016a3:	e8 9e ff ff ff       	call   801646 <printnum>
  8016a8:	83 c4 20             	add    $0x20,%esp
  8016ab:	eb 18                	jmp    8016c5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	56                   	push   %esi
  8016b1:	ff 75 18             	pushl  0x18(%ebp)
  8016b4:	ff d7                	call   *%edi
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	eb 03                	jmp    8016be <printnum+0x78>
  8016bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016be:	83 eb 01             	sub    $0x1,%ebx
  8016c1:	85 db                	test   %ebx,%ebx
  8016c3:	7f e8                	jg     8016ad <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	56                   	push   %esi
  8016c9:	83 ec 04             	sub    $0x4,%esp
  8016cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8016d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8016d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8016d8:	e8 83 0a 00 00       	call   802160 <__umoddi3>
  8016dd:	83 c4 14             	add    $0x14,%esp
  8016e0:	0f be 80 43 24 80 00 	movsbl 0x802443(%eax),%eax
  8016e7:	50                   	push   %eax
  8016e8:	ff d7                	call   *%edi
}
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5e                   	pop    %esi
  8016f2:	5f                   	pop    %edi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016f8:	83 fa 01             	cmp    $0x1,%edx
  8016fb:	7e 0e                	jle    80170b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016fd:	8b 10                	mov    (%eax),%edx
  8016ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  801702:	89 08                	mov    %ecx,(%eax)
  801704:	8b 02                	mov    (%edx),%eax
  801706:	8b 52 04             	mov    0x4(%edx),%edx
  801709:	eb 22                	jmp    80172d <getuint+0x38>
	else if (lflag)
  80170b:	85 d2                	test   %edx,%edx
  80170d:	74 10                	je     80171f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80170f:	8b 10                	mov    (%eax),%edx
  801711:	8d 4a 04             	lea    0x4(%edx),%ecx
  801714:	89 08                	mov    %ecx,(%eax)
  801716:	8b 02                	mov    (%edx),%eax
  801718:	ba 00 00 00 00       	mov    $0x0,%edx
  80171d:	eb 0e                	jmp    80172d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80171f:	8b 10                	mov    (%eax),%edx
  801721:	8d 4a 04             	lea    0x4(%edx),%ecx
  801724:	89 08                	mov    %ecx,(%eax)
  801726:	8b 02                	mov    (%edx),%eax
  801728:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    

0080172f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801735:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801739:	8b 10                	mov    (%eax),%edx
  80173b:	3b 50 04             	cmp    0x4(%eax),%edx
  80173e:	73 0a                	jae    80174a <sprintputch+0x1b>
		*b->buf++ = ch;
  801740:	8d 4a 01             	lea    0x1(%edx),%ecx
  801743:	89 08                	mov    %ecx,(%eax)
  801745:	8b 45 08             	mov    0x8(%ebp),%eax
  801748:	88 02                	mov    %al,(%edx)
}
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801752:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801755:	50                   	push   %eax
  801756:	ff 75 10             	pushl  0x10(%ebp)
  801759:	ff 75 0c             	pushl  0xc(%ebp)
  80175c:	ff 75 08             	pushl  0x8(%ebp)
  80175f:	e8 05 00 00 00       	call   801769 <vprintfmt>
	va_end(ap);
}
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	57                   	push   %edi
  80176d:	56                   	push   %esi
  80176e:	53                   	push   %ebx
  80176f:	83 ec 2c             	sub    $0x2c,%esp
  801772:	8b 75 08             	mov    0x8(%ebp),%esi
  801775:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801778:	8b 7d 10             	mov    0x10(%ebp),%edi
  80177b:	eb 12                	jmp    80178f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80177d:	85 c0                	test   %eax,%eax
  80177f:	0f 84 89 03 00 00    	je     801b0e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	53                   	push   %ebx
  801789:	50                   	push   %eax
  80178a:	ff d6                	call   *%esi
  80178c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80178f:	83 c7 01             	add    $0x1,%edi
  801792:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801796:	83 f8 25             	cmp    $0x25,%eax
  801799:	75 e2                	jne    80177d <vprintfmt+0x14>
  80179b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80179f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b9:	eb 07                	jmp    8017c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c2:	8d 47 01             	lea    0x1(%edi),%eax
  8017c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017c8:	0f b6 07             	movzbl (%edi),%eax
  8017cb:	0f b6 c8             	movzbl %al,%ecx
  8017ce:	83 e8 23             	sub    $0x23,%eax
  8017d1:	3c 55                	cmp    $0x55,%al
  8017d3:	0f 87 1a 03 00 00    	ja     801af3 <vprintfmt+0x38a>
  8017d9:	0f b6 c0             	movzbl %al,%eax
  8017dc:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  8017e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017e6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017ea:	eb d6                	jmp    8017c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017fa:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017fe:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801801:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801804:	83 fa 09             	cmp    $0x9,%edx
  801807:	77 39                	ja     801842 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801809:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80180c:	eb e9                	jmp    8017f7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80180e:	8b 45 14             	mov    0x14(%ebp),%eax
  801811:	8d 48 04             	lea    0x4(%eax),%ecx
  801814:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801817:	8b 00                	mov    (%eax),%eax
  801819:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80181f:	eb 27                	jmp    801848 <vprintfmt+0xdf>
  801821:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801824:	85 c0                	test   %eax,%eax
  801826:	b9 00 00 00 00       	mov    $0x0,%ecx
  80182b:	0f 49 c8             	cmovns %eax,%ecx
  80182e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801831:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801834:	eb 8c                	jmp    8017c2 <vprintfmt+0x59>
  801836:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801839:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801840:	eb 80                	jmp    8017c2 <vprintfmt+0x59>
  801842:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801845:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801848:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80184c:	0f 89 70 ff ff ff    	jns    8017c2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801852:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801855:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801858:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80185f:	e9 5e ff ff ff       	jmp    8017c2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801864:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801867:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80186a:	e9 53 ff ff ff       	jmp    8017c2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80186f:	8b 45 14             	mov    0x14(%ebp),%eax
  801872:	8d 50 04             	lea    0x4(%eax),%edx
  801875:	89 55 14             	mov    %edx,0x14(%ebp)
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	53                   	push   %ebx
  80187c:	ff 30                	pushl  (%eax)
  80187e:	ff d6                	call   *%esi
			break;
  801880:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801883:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801886:	e9 04 ff ff ff       	jmp    80178f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80188b:	8b 45 14             	mov    0x14(%ebp),%eax
  80188e:	8d 50 04             	lea    0x4(%eax),%edx
  801891:	89 55 14             	mov    %edx,0x14(%ebp)
  801894:	8b 00                	mov    (%eax),%eax
  801896:	99                   	cltd   
  801897:	31 d0                	xor    %edx,%eax
  801899:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80189b:	83 f8 0f             	cmp    $0xf,%eax
  80189e:	7f 0b                	jg     8018ab <vprintfmt+0x142>
  8018a0:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8018a7:	85 d2                	test   %edx,%edx
  8018a9:	75 18                	jne    8018c3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018ab:	50                   	push   %eax
  8018ac:	68 5b 24 80 00       	push   $0x80245b
  8018b1:	53                   	push   %ebx
  8018b2:	56                   	push   %esi
  8018b3:	e8 94 fe ff ff       	call   80174c <printfmt>
  8018b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018be:	e9 cc fe ff ff       	jmp    80178f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018c3:	52                   	push   %edx
  8018c4:	68 a1 23 80 00       	push   $0x8023a1
  8018c9:	53                   	push   %ebx
  8018ca:	56                   	push   %esi
  8018cb:	e8 7c fe ff ff       	call   80174c <printfmt>
  8018d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018d6:	e9 b4 fe ff ff       	jmp    80178f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018db:	8b 45 14             	mov    0x14(%ebp),%eax
  8018de:	8d 50 04             	lea    0x4(%eax),%edx
  8018e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018e6:	85 ff                	test   %edi,%edi
  8018e8:	b8 54 24 80 00       	mov    $0x802454,%eax
  8018ed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018f4:	0f 8e 94 00 00 00    	jle    80198e <vprintfmt+0x225>
  8018fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018fe:	0f 84 98 00 00 00    	je     80199c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	ff 75 d0             	pushl  -0x30(%ebp)
  80190a:	57                   	push   %edi
  80190b:	e8 86 02 00 00       	call   801b96 <strnlen>
  801910:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801913:	29 c1                	sub    %eax,%ecx
  801915:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801918:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80191b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80191f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801922:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801925:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801927:	eb 0f                	jmp    801938 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	53                   	push   %ebx
  80192d:	ff 75 e0             	pushl  -0x20(%ebp)
  801930:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801932:	83 ef 01             	sub    $0x1,%edi
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	85 ff                	test   %edi,%edi
  80193a:	7f ed                	jg     801929 <vprintfmt+0x1c0>
  80193c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80193f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801942:	85 c9                	test   %ecx,%ecx
  801944:	b8 00 00 00 00       	mov    $0x0,%eax
  801949:	0f 49 c1             	cmovns %ecx,%eax
  80194c:	29 c1                	sub    %eax,%ecx
  80194e:	89 75 08             	mov    %esi,0x8(%ebp)
  801951:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801954:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801957:	89 cb                	mov    %ecx,%ebx
  801959:	eb 4d                	jmp    8019a8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80195b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80195f:	74 1b                	je     80197c <vprintfmt+0x213>
  801961:	0f be c0             	movsbl %al,%eax
  801964:	83 e8 20             	sub    $0x20,%eax
  801967:	83 f8 5e             	cmp    $0x5e,%eax
  80196a:	76 10                	jbe    80197c <vprintfmt+0x213>
					putch('?', putdat);
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	ff 75 0c             	pushl  0xc(%ebp)
  801972:	6a 3f                	push   $0x3f
  801974:	ff 55 08             	call   *0x8(%ebp)
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	eb 0d                	jmp    801989 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80197c:	83 ec 08             	sub    $0x8,%esp
  80197f:	ff 75 0c             	pushl  0xc(%ebp)
  801982:	52                   	push   %edx
  801983:	ff 55 08             	call   *0x8(%ebp)
  801986:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801989:	83 eb 01             	sub    $0x1,%ebx
  80198c:	eb 1a                	jmp    8019a8 <vprintfmt+0x23f>
  80198e:	89 75 08             	mov    %esi,0x8(%ebp)
  801991:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801994:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801997:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80199a:	eb 0c                	jmp    8019a8 <vprintfmt+0x23f>
  80199c:	89 75 08             	mov    %esi,0x8(%ebp)
  80199f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019a8:	83 c7 01             	add    $0x1,%edi
  8019ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019af:	0f be d0             	movsbl %al,%edx
  8019b2:	85 d2                	test   %edx,%edx
  8019b4:	74 23                	je     8019d9 <vprintfmt+0x270>
  8019b6:	85 f6                	test   %esi,%esi
  8019b8:	78 a1                	js     80195b <vprintfmt+0x1f2>
  8019ba:	83 ee 01             	sub    $0x1,%esi
  8019bd:	79 9c                	jns    80195b <vprintfmt+0x1f2>
  8019bf:	89 df                	mov    %ebx,%edi
  8019c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019c7:	eb 18                	jmp    8019e1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019c9:	83 ec 08             	sub    $0x8,%esp
  8019cc:	53                   	push   %ebx
  8019cd:	6a 20                	push   $0x20
  8019cf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019d1:	83 ef 01             	sub    $0x1,%edi
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	eb 08                	jmp    8019e1 <vprintfmt+0x278>
  8019d9:	89 df                	mov    %ebx,%edi
  8019db:	8b 75 08             	mov    0x8(%ebp),%esi
  8019de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019e1:	85 ff                	test   %edi,%edi
  8019e3:	7f e4                	jg     8019c9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019e8:	e9 a2 fd ff ff       	jmp    80178f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019ed:	83 fa 01             	cmp    $0x1,%edx
  8019f0:	7e 16                	jle    801a08 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f5:	8d 50 08             	lea    0x8(%eax),%edx
  8019f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8019fb:	8b 50 04             	mov    0x4(%eax),%edx
  8019fe:	8b 00                	mov    (%eax),%eax
  801a00:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a03:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a06:	eb 32                	jmp    801a3a <vprintfmt+0x2d1>
	else if (lflag)
  801a08:	85 d2                	test   %edx,%edx
  801a0a:	74 18                	je     801a24 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a0c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0f:	8d 50 04             	lea    0x4(%eax),%edx
  801a12:	89 55 14             	mov    %edx,0x14(%ebp)
  801a15:	8b 00                	mov    (%eax),%eax
  801a17:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a1a:	89 c1                	mov    %eax,%ecx
  801a1c:	c1 f9 1f             	sar    $0x1f,%ecx
  801a1f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a22:	eb 16                	jmp    801a3a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a24:	8b 45 14             	mov    0x14(%ebp),%eax
  801a27:	8d 50 04             	lea    0x4(%eax),%edx
  801a2a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a2d:	8b 00                	mov    (%eax),%eax
  801a2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a32:	89 c1                	mov    %eax,%ecx
  801a34:	c1 f9 1f             	sar    $0x1f,%ecx
  801a37:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a3a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a40:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a45:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a49:	79 74                	jns    801abf <vprintfmt+0x356>
				putch('-', putdat);
  801a4b:	83 ec 08             	sub    $0x8,%esp
  801a4e:	53                   	push   %ebx
  801a4f:	6a 2d                	push   $0x2d
  801a51:	ff d6                	call   *%esi
				num = -(long long) num;
  801a53:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a56:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a59:	f7 d8                	neg    %eax
  801a5b:	83 d2 00             	adc    $0x0,%edx
  801a5e:	f7 da                	neg    %edx
  801a60:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a63:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a68:	eb 55                	jmp    801abf <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a6a:	8d 45 14             	lea    0x14(%ebp),%eax
  801a6d:	e8 83 fc ff ff       	call   8016f5 <getuint>
			base = 10;
  801a72:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a77:	eb 46                	jmp    801abf <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a79:	8d 45 14             	lea    0x14(%ebp),%eax
  801a7c:	e8 74 fc ff ff       	call   8016f5 <getuint>
			base = 8;
  801a81:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a86:	eb 37                	jmp    801abf <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a88:	83 ec 08             	sub    $0x8,%esp
  801a8b:	53                   	push   %ebx
  801a8c:	6a 30                	push   $0x30
  801a8e:	ff d6                	call   *%esi
			putch('x', putdat);
  801a90:	83 c4 08             	add    $0x8,%esp
  801a93:	53                   	push   %ebx
  801a94:	6a 78                	push   $0x78
  801a96:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a98:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9b:	8d 50 04             	lea    0x4(%eax),%edx
  801a9e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801aa1:	8b 00                	mov    (%eax),%eax
  801aa3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801aa8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801aab:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ab0:	eb 0d                	jmp    801abf <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ab2:	8d 45 14             	lea    0x14(%ebp),%eax
  801ab5:	e8 3b fc ff ff       	call   8016f5 <getuint>
			base = 16;
  801aba:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801abf:	83 ec 0c             	sub    $0xc,%esp
  801ac2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ac6:	57                   	push   %edi
  801ac7:	ff 75 e0             	pushl  -0x20(%ebp)
  801aca:	51                   	push   %ecx
  801acb:	52                   	push   %edx
  801acc:	50                   	push   %eax
  801acd:	89 da                	mov    %ebx,%edx
  801acf:	89 f0                	mov    %esi,%eax
  801ad1:	e8 70 fb ff ff       	call   801646 <printnum>
			break;
  801ad6:	83 c4 20             	add    $0x20,%esp
  801ad9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801adc:	e9 ae fc ff ff       	jmp    80178f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ae1:	83 ec 08             	sub    $0x8,%esp
  801ae4:	53                   	push   %ebx
  801ae5:	51                   	push   %ecx
  801ae6:	ff d6                	call   *%esi
			break;
  801ae8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aeb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801aee:	e9 9c fc ff ff       	jmp    80178f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801af3:	83 ec 08             	sub    $0x8,%esp
  801af6:	53                   	push   %ebx
  801af7:	6a 25                	push   $0x25
  801af9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	eb 03                	jmp    801b03 <vprintfmt+0x39a>
  801b00:	83 ef 01             	sub    $0x1,%edi
  801b03:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b07:	75 f7                	jne    801b00 <vprintfmt+0x397>
  801b09:	e9 81 fc ff ff       	jmp    80178f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5f                   	pop    %edi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 18             	sub    $0x18,%esp
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b25:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b29:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b33:	85 c0                	test   %eax,%eax
  801b35:	74 26                	je     801b5d <vsnprintf+0x47>
  801b37:	85 d2                	test   %edx,%edx
  801b39:	7e 22                	jle    801b5d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b3b:	ff 75 14             	pushl  0x14(%ebp)
  801b3e:	ff 75 10             	pushl  0x10(%ebp)
  801b41:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b44:	50                   	push   %eax
  801b45:	68 2f 17 80 00       	push   $0x80172f
  801b4a:	e8 1a fc ff ff       	call   801769 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b52:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	eb 05                	jmp    801b62 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b6a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b6d:	50                   	push   %eax
  801b6e:	ff 75 10             	pushl  0x10(%ebp)
  801b71:	ff 75 0c             	pushl  0xc(%ebp)
  801b74:	ff 75 08             	pushl  0x8(%ebp)
  801b77:	e8 9a ff ff ff       	call   801b16 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	eb 03                	jmp    801b8e <strlen+0x10>
		n++;
  801b8b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b8e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b92:	75 f7                	jne    801b8b <strlen+0xd>
		n++;
	return n;
}
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba4:	eb 03                	jmp    801ba9 <strnlen+0x13>
		n++;
  801ba6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ba9:	39 c2                	cmp    %eax,%edx
  801bab:	74 08                	je     801bb5 <strnlen+0x1f>
  801bad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bb1:	75 f3                	jne    801ba6 <strnlen+0x10>
  801bb3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bb5:	5d                   	pop    %ebp
  801bb6:	c3                   	ret    

00801bb7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	53                   	push   %ebx
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bc1:	89 c2                	mov    %eax,%edx
  801bc3:	83 c2 01             	add    $0x1,%edx
  801bc6:	83 c1 01             	add    $0x1,%ecx
  801bc9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bcd:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bd0:	84 db                	test   %bl,%bl
  801bd2:	75 ef                	jne    801bc3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bd4:	5b                   	pop    %ebx
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	53                   	push   %ebx
  801bdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bde:	53                   	push   %ebx
  801bdf:	e8 9a ff ff ff       	call   801b7e <strlen>
  801be4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801be7:	ff 75 0c             	pushl  0xc(%ebp)
  801bea:	01 d8                	add    %ebx,%eax
  801bec:	50                   	push   %eax
  801bed:	e8 c5 ff ff ff       	call   801bb7 <strcpy>
	return dst;
}
  801bf2:	89 d8                	mov    %ebx,%eax
  801bf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	56                   	push   %esi
  801bfd:	53                   	push   %ebx
  801bfe:	8b 75 08             	mov    0x8(%ebp),%esi
  801c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c04:	89 f3                	mov    %esi,%ebx
  801c06:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c09:	89 f2                	mov    %esi,%edx
  801c0b:	eb 0f                	jmp    801c1c <strncpy+0x23>
		*dst++ = *src;
  801c0d:	83 c2 01             	add    $0x1,%edx
  801c10:	0f b6 01             	movzbl (%ecx),%eax
  801c13:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c16:	80 39 01             	cmpb   $0x1,(%ecx)
  801c19:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c1c:	39 da                	cmp    %ebx,%edx
  801c1e:	75 ed                	jne    801c0d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c20:	89 f0                	mov    %esi,%eax
  801c22:	5b                   	pop    %ebx
  801c23:	5e                   	pop    %esi
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    

00801c26 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	56                   	push   %esi
  801c2a:	53                   	push   %ebx
  801c2b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c31:	8b 55 10             	mov    0x10(%ebp),%edx
  801c34:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c36:	85 d2                	test   %edx,%edx
  801c38:	74 21                	je     801c5b <strlcpy+0x35>
  801c3a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c3e:	89 f2                	mov    %esi,%edx
  801c40:	eb 09                	jmp    801c4b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c42:	83 c2 01             	add    $0x1,%edx
  801c45:	83 c1 01             	add    $0x1,%ecx
  801c48:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c4b:	39 c2                	cmp    %eax,%edx
  801c4d:	74 09                	je     801c58 <strlcpy+0x32>
  801c4f:	0f b6 19             	movzbl (%ecx),%ebx
  801c52:	84 db                	test   %bl,%bl
  801c54:	75 ec                	jne    801c42 <strlcpy+0x1c>
  801c56:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c58:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c5b:	29 f0                	sub    %esi,%eax
}
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c67:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c6a:	eb 06                	jmp    801c72 <strcmp+0x11>
		p++, q++;
  801c6c:	83 c1 01             	add    $0x1,%ecx
  801c6f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c72:	0f b6 01             	movzbl (%ecx),%eax
  801c75:	84 c0                	test   %al,%al
  801c77:	74 04                	je     801c7d <strcmp+0x1c>
  801c79:	3a 02                	cmp    (%edx),%al
  801c7b:	74 ef                	je     801c6c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c7d:	0f b6 c0             	movzbl %al,%eax
  801c80:	0f b6 12             	movzbl (%edx),%edx
  801c83:	29 d0                	sub    %edx,%eax
}
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	53                   	push   %ebx
  801c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c91:	89 c3                	mov    %eax,%ebx
  801c93:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c96:	eb 06                	jmp    801c9e <strncmp+0x17>
		n--, p++, q++;
  801c98:	83 c0 01             	add    $0x1,%eax
  801c9b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c9e:	39 d8                	cmp    %ebx,%eax
  801ca0:	74 15                	je     801cb7 <strncmp+0x30>
  801ca2:	0f b6 08             	movzbl (%eax),%ecx
  801ca5:	84 c9                	test   %cl,%cl
  801ca7:	74 04                	je     801cad <strncmp+0x26>
  801ca9:	3a 0a                	cmp    (%edx),%cl
  801cab:	74 eb                	je     801c98 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cad:	0f b6 00             	movzbl (%eax),%eax
  801cb0:	0f b6 12             	movzbl (%edx),%edx
  801cb3:	29 d0                	sub    %edx,%eax
  801cb5:	eb 05                	jmp    801cbc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cbc:	5b                   	pop    %ebx
  801cbd:	5d                   	pop    %ebp
  801cbe:	c3                   	ret    

00801cbf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cc9:	eb 07                	jmp    801cd2 <strchr+0x13>
		if (*s == c)
  801ccb:	38 ca                	cmp    %cl,%dl
  801ccd:	74 0f                	je     801cde <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ccf:	83 c0 01             	add    $0x1,%eax
  801cd2:	0f b6 10             	movzbl (%eax),%edx
  801cd5:	84 d2                	test   %dl,%dl
  801cd7:	75 f2                	jne    801ccb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cea:	eb 03                	jmp    801cef <strfind+0xf>
  801cec:	83 c0 01             	add    $0x1,%eax
  801cef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cf2:	38 ca                	cmp    %cl,%dl
  801cf4:	74 04                	je     801cfa <strfind+0x1a>
  801cf6:	84 d2                	test   %dl,%dl
  801cf8:	75 f2                	jne    801cec <strfind+0xc>
			break;
	return (char *) s;
}
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	57                   	push   %edi
  801d00:	56                   	push   %esi
  801d01:	53                   	push   %ebx
  801d02:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d08:	85 c9                	test   %ecx,%ecx
  801d0a:	74 36                	je     801d42 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d0c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d12:	75 28                	jne    801d3c <memset+0x40>
  801d14:	f6 c1 03             	test   $0x3,%cl
  801d17:	75 23                	jne    801d3c <memset+0x40>
		c &= 0xFF;
  801d19:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d1d:	89 d3                	mov    %edx,%ebx
  801d1f:	c1 e3 08             	shl    $0x8,%ebx
  801d22:	89 d6                	mov    %edx,%esi
  801d24:	c1 e6 18             	shl    $0x18,%esi
  801d27:	89 d0                	mov    %edx,%eax
  801d29:	c1 e0 10             	shl    $0x10,%eax
  801d2c:	09 f0                	or     %esi,%eax
  801d2e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d30:	89 d8                	mov    %ebx,%eax
  801d32:	09 d0                	or     %edx,%eax
  801d34:	c1 e9 02             	shr    $0x2,%ecx
  801d37:	fc                   	cld    
  801d38:	f3 ab                	rep stos %eax,%es:(%edi)
  801d3a:	eb 06                	jmp    801d42 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3f:	fc                   	cld    
  801d40:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d42:	89 f8                	mov    %edi,%eax
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d51:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d57:	39 c6                	cmp    %eax,%esi
  801d59:	73 35                	jae    801d90 <memmove+0x47>
  801d5b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d5e:	39 d0                	cmp    %edx,%eax
  801d60:	73 2e                	jae    801d90 <memmove+0x47>
		s += n;
		d += n;
  801d62:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d65:	89 d6                	mov    %edx,%esi
  801d67:	09 fe                	or     %edi,%esi
  801d69:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d6f:	75 13                	jne    801d84 <memmove+0x3b>
  801d71:	f6 c1 03             	test   $0x3,%cl
  801d74:	75 0e                	jne    801d84 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d76:	83 ef 04             	sub    $0x4,%edi
  801d79:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d7c:	c1 e9 02             	shr    $0x2,%ecx
  801d7f:	fd                   	std    
  801d80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d82:	eb 09                	jmp    801d8d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d84:	83 ef 01             	sub    $0x1,%edi
  801d87:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d8a:	fd                   	std    
  801d8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d8d:	fc                   	cld    
  801d8e:	eb 1d                	jmp    801dad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d90:	89 f2                	mov    %esi,%edx
  801d92:	09 c2                	or     %eax,%edx
  801d94:	f6 c2 03             	test   $0x3,%dl
  801d97:	75 0f                	jne    801da8 <memmove+0x5f>
  801d99:	f6 c1 03             	test   $0x3,%cl
  801d9c:	75 0a                	jne    801da8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d9e:	c1 e9 02             	shr    $0x2,%ecx
  801da1:	89 c7                	mov    %eax,%edi
  801da3:	fc                   	cld    
  801da4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801da6:	eb 05                	jmp    801dad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801da8:	89 c7                	mov    %eax,%edi
  801daa:	fc                   	cld    
  801dab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dad:	5e                   	pop    %esi
  801dae:	5f                   	pop    %edi
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801db4:	ff 75 10             	pushl  0x10(%ebp)
  801db7:	ff 75 0c             	pushl  0xc(%ebp)
  801dba:	ff 75 08             	pushl  0x8(%ebp)
  801dbd:	e8 87 ff ff ff       	call   801d49 <memmove>
}
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	56                   	push   %esi
  801dc8:	53                   	push   %ebx
  801dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dd4:	eb 1a                	jmp    801df0 <memcmp+0x2c>
		if (*s1 != *s2)
  801dd6:	0f b6 08             	movzbl (%eax),%ecx
  801dd9:	0f b6 1a             	movzbl (%edx),%ebx
  801ddc:	38 d9                	cmp    %bl,%cl
  801dde:	74 0a                	je     801dea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801de0:	0f b6 c1             	movzbl %cl,%eax
  801de3:	0f b6 db             	movzbl %bl,%ebx
  801de6:	29 d8                	sub    %ebx,%eax
  801de8:	eb 0f                	jmp    801df9 <memcmp+0x35>
		s1++, s2++;
  801dea:	83 c0 01             	add    $0x1,%eax
  801ded:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801df0:	39 f0                	cmp    %esi,%eax
  801df2:	75 e2                	jne    801dd6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df9:	5b                   	pop    %ebx
  801dfa:	5e                   	pop    %esi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	53                   	push   %ebx
  801e01:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e04:	89 c1                	mov    %eax,%ecx
  801e06:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e09:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e0d:	eb 0a                	jmp    801e19 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e0f:	0f b6 10             	movzbl (%eax),%edx
  801e12:	39 da                	cmp    %ebx,%edx
  801e14:	74 07                	je     801e1d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e16:	83 c0 01             	add    $0x1,%eax
  801e19:	39 c8                	cmp    %ecx,%eax
  801e1b:	72 f2                	jb     801e0f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e1d:	5b                   	pop    %ebx
  801e1e:	5d                   	pop    %ebp
  801e1f:	c3                   	ret    

00801e20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	57                   	push   %edi
  801e24:	56                   	push   %esi
  801e25:	53                   	push   %ebx
  801e26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e2c:	eb 03                	jmp    801e31 <strtol+0x11>
		s++;
  801e2e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e31:	0f b6 01             	movzbl (%ecx),%eax
  801e34:	3c 20                	cmp    $0x20,%al
  801e36:	74 f6                	je     801e2e <strtol+0xe>
  801e38:	3c 09                	cmp    $0x9,%al
  801e3a:	74 f2                	je     801e2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e3c:	3c 2b                	cmp    $0x2b,%al
  801e3e:	75 0a                	jne    801e4a <strtol+0x2a>
		s++;
  801e40:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e43:	bf 00 00 00 00       	mov    $0x0,%edi
  801e48:	eb 11                	jmp    801e5b <strtol+0x3b>
  801e4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e4f:	3c 2d                	cmp    $0x2d,%al
  801e51:	75 08                	jne    801e5b <strtol+0x3b>
		s++, neg = 1;
  801e53:	83 c1 01             	add    $0x1,%ecx
  801e56:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e61:	75 15                	jne    801e78 <strtol+0x58>
  801e63:	80 39 30             	cmpb   $0x30,(%ecx)
  801e66:	75 10                	jne    801e78 <strtol+0x58>
  801e68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e6c:	75 7c                	jne    801eea <strtol+0xca>
		s += 2, base = 16;
  801e6e:	83 c1 02             	add    $0x2,%ecx
  801e71:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e76:	eb 16                	jmp    801e8e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e78:	85 db                	test   %ebx,%ebx
  801e7a:	75 12                	jne    801e8e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e81:	80 39 30             	cmpb   $0x30,(%ecx)
  801e84:	75 08                	jne    801e8e <strtol+0x6e>
		s++, base = 8;
  801e86:	83 c1 01             	add    $0x1,%ecx
  801e89:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e93:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e96:	0f b6 11             	movzbl (%ecx),%edx
  801e99:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e9c:	89 f3                	mov    %esi,%ebx
  801e9e:	80 fb 09             	cmp    $0x9,%bl
  801ea1:	77 08                	ja     801eab <strtol+0x8b>
			dig = *s - '0';
  801ea3:	0f be d2             	movsbl %dl,%edx
  801ea6:	83 ea 30             	sub    $0x30,%edx
  801ea9:	eb 22                	jmp    801ecd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801eab:	8d 72 9f             	lea    -0x61(%edx),%esi
  801eae:	89 f3                	mov    %esi,%ebx
  801eb0:	80 fb 19             	cmp    $0x19,%bl
  801eb3:	77 08                	ja     801ebd <strtol+0x9d>
			dig = *s - 'a' + 10;
  801eb5:	0f be d2             	movsbl %dl,%edx
  801eb8:	83 ea 57             	sub    $0x57,%edx
  801ebb:	eb 10                	jmp    801ecd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ebd:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ec0:	89 f3                	mov    %esi,%ebx
  801ec2:	80 fb 19             	cmp    $0x19,%bl
  801ec5:	77 16                	ja     801edd <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ec7:	0f be d2             	movsbl %dl,%edx
  801eca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ecd:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ed0:	7d 0b                	jge    801edd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ed2:	83 c1 01             	add    $0x1,%ecx
  801ed5:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ed9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801edb:	eb b9                	jmp    801e96 <strtol+0x76>

	if (endptr)
  801edd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ee1:	74 0d                	je     801ef0 <strtol+0xd0>
		*endptr = (char *) s;
  801ee3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee6:	89 0e                	mov    %ecx,(%esi)
  801ee8:	eb 06                	jmp    801ef0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eea:	85 db                	test   %ebx,%ebx
  801eec:	74 98                	je     801e86 <strtol+0x66>
  801eee:	eb 9e                	jmp    801e8e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ef0:	89 c2                	mov    %eax,%edx
  801ef2:	f7 da                	neg    %edx
  801ef4:	85 ff                	test   %edi,%edi
  801ef6:	0f 45 c2             	cmovne %edx,%eax
}
  801ef9:	5b                   	pop    %ebx
  801efa:	5e                   	pop    %esi
  801efb:	5f                   	pop    %edi
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	56                   	push   %esi
  801f02:	53                   	push   %ebx
  801f03:	8b 75 08             	mov    0x8(%ebp),%esi
  801f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f0c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f0e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f13:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	50                   	push   %eax
  801f1a:	e8 12 e4 ff ff       	call   800331 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	85 f6                	test   %esi,%esi
  801f24:	74 14                	je     801f3a <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f26:	ba 00 00 00 00       	mov    $0x0,%edx
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	78 09                	js     801f38 <ipc_recv+0x3a>
  801f2f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f35:	8b 52 74             	mov    0x74(%edx),%edx
  801f38:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f3a:	85 db                	test   %ebx,%ebx
  801f3c:	74 14                	je     801f52 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f43:	85 c0                	test   %eax,%eax
  801f45:	78 09                	js     801f50 <ipc_recv+0x52>
  801f47:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f4d:	8b 52 78             	mov    0x78(%edx),%edx
  801f50:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f52:	85 c0                	test   %eax,%eax
  801f54:	78 08                	js     801f5e <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f56:	a1 08 40 80 00       	mov    0x804008,%eax
  801f5b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f61:	5b                   	pop    %ebx
  801f62:	5e                   	pop    %esi
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    

00801f65 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	57                   	push   %edi
  801f69:	56                   	push   %esi
  801f6a:	53                   	push   %ebx
  801f6b:	83 ec 0c             	sub    $0xc,%esp
  801f6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f71:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f77:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f79:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f7e:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f81:	ff 75 14             	pushl  0x14(%ebp)
  801f84:	53                   	push   %ebx
  801f85:	56                   	push   %esi
  801f86:	57                   	push   %edi
  801f87:	e8 82 e3 ff ff       	call   80030e <sys_ipc_try_send>

		if (err < 0) {
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	79 1e                	jns    801fb1 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f93:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f96:	75 07                	jne    801f9f <ipc_send+0x3a>
				sys_yield();
  801f98:	e8 c5 e1 ff ff       	call   800162 <sys_yield>
  801f9d:	eb e2                	jmp    801f81 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f9f:	50                   	push   %eax
  801fa0:	68 40 27 80 00       	push   $0x802740
  801fa5:	6a 49                	push   $0x49
  801fa7:	68 4d 27 80 00       	push   $0x80274d
  801fac:	e8 a8 f5 ff ff       	call   801559 <_panic>
		}

	} while (err < 0);

}
  801fb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb4:	5b                   	pop    %ebx
  801fb5:	5e                   	pop    %esi
  801fb6:	5f                   	pop    %edi
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    

00801fb9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fbf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fc4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fc7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fcd:	8b 52 50             	mov    0x50(%edx),%edx
  801fd0:	39 ca                	cmp    %ecx,%edx
  801fd2:	75 0d                	jne    801fe1 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fd4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fd7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fdc:	8b 40 48             	mov    0x48(%eax),%eax
  801fdf:	eb 0f                	jmp    801ff0 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe1:	83 c0 01             	add    $0x1,%eax
  801fe4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fe9:	75 d9                	jne    801fc4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801feb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    

00801ff2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff8:	89 d0                	mov    %edx,%eax
  801ffa:	c1 e8 16             	shr    $0x16,%eax
  801ffd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802004:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802009:	f6 c1 01             	test   $0x1,%cl
  80200c:	74 1d                	je     80202b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80200e:	c1 ea 0c             	shr    $0xc,%edx
  802011:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802018:	f6 c2 01             	test   $0x1,%dl
  80201b:	74 0e                	je     80202b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80201d:	c1 ea 0c             	shr    $0xc,%edx
  802020:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802027:	ef 
  802028:	0f b7 c0             	movzwl %ax,%eax
}
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
