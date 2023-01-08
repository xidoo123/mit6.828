
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
  8000b1:	e8 a6 04 00 00       	call   80055c <close_all>
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
  80012a:	68 4a 22 80 00       	push   $0x80224a
  80012f:	6a 23                	push   $0x23
  800131:	68 67 22 80 00       	push   $0x802267
  800136:	e8 9a 13 00 00       	call   8014d5 <_panic>

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
  8001ab:	68 4a 22 80 00       	push   $0x80224a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 67 22 80 00       	push   $0x802267
  8001b7:	e8 19 13 00 00       	call   8014d5 <_panic>

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
  8001ed:	68 4a 22 80 00       	push   $0x80224a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 67 22 80 00       	push   $0x802267
  8001f9:	e8 d7 12 00 00       	call   8014d5 <_panic>

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
  80022f:	68 4a 22 80 00       	push   $0x80224a
  800234:	6a 23                	push   $0x23
  800236:	68 67 22 80 00       	push   $0x802267
  80023b:	e8 95 12 00 00       	call   8014d5 <_panic>

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
  800271:	68 4a 22 80 00       	push   $0x80224a
  800276:	6a 23                	push   $0x23
  800278:	68 67 22 80 00       	push   $0x802267
  80027d:	e8 53 12 00 00       	call   8014d5 <_panic>

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
  8002b3:	68 4a 22 80 00       	push   $0x80224a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 67 22 80 00       	push   $0x802267
  8002bf:	e8 11 12 00 00       	call   8014d5 <_panic>

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
  8002f5:	68 4a 22 80 00       	push   $0x80224a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 67 22 80 00       	push   $0x802267
  800301:	e8 cf 11 00 00       	call   8014d5 <_panic>

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
  800359:	68 4a 22 80 00       	push   $0x80224a
  80035e:	6a 23                	push   $0x23
  800360:	68 67 22 80 00       	push   $0x802267
  800365:	e8 6b 11 00 00       	call   8014d5 <_panic>

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

00800391 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	05 00 00 00 30       	add    $0x30000000,%eax
  80039c:	c1 e8 0c             	shr    $0xc,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c3:	89 c2                	mov    %eax,%edx
  8003c5:	c1 ea 16             	shr    $0x16,%edx
  8003c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003cf:	f6 c2 01             	test   $0x1,%dl
  8003d2:	74 11                	je     8003e5 <fd_alloc+0x2d>
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 0c             	shr    $0xc,%edx
  8003d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	75 09                	jne    8003ee <fd_alloc+0x36>
			*fd_store = fd;
  8003e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ec:	eb 17                	jmp    800405 <fd_alloc+0x4d>
  8003ee:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f8:	75 c9                	jne    8003c3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800400:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040d:	83 f8 1f             	cmp    $0x1f,%eax
  800410:	77 36                	ja     800448 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800412:	c1 e0 0c             	shl    $0xc,%eax
  800415:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 ea 16             	shr    $0x16,%edx
  80041f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800426:	f6 c2 01             	test   $0x1,%dl
  800429:	74 24                	je     80044f <fd_lookup+0x48>
  80042b:	89 c2                	mov    %eax,%edx
  80042d:	c1 ea 0c             	shr    $0xc,%edx
  800430:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800437:	f6 c2 01             	test   $0x1,%dl
  80043a:	74 1a                	je     800456 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043f:	89 02                	mov    %eax,(%edx)
	return 0;
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	eb 13                	jmp    80045b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044d:	eb 0c                	jmp    80045b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800454:	eb 05                	jmp    80045b <fd_lookup+0x54>
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800466:	ba f4 22 80 00       	mov    $0x8022f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046b:	eb 13                	jmp    800480 <dev_lookup+0x23>
  80046d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800470:	39 08                	cmp    %ecx,(%eax)
  800472:	75 0c                	jne    800480 <dev_lookup+0x23>
			*dev = devtab[i];
  800474:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800477:	89 01                	mov    %eax,(%ecx)
			return 0;
  800479:	b8 00 00 00 00       	mov    $0x0,%eax
  80047e:	eb 2e                	jmp    8004ae <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800480:	8b 02                	mov    (%edx),%eax
  800482:	85 c0                	test   %eax,%eax
  800484:	75 e7                	jne    80046d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800486:	a1 08 40 80 00       	mov    0x804008,%eax
  80048b:	8b 40 48             	mov    0x48(%eax),%eax
  80048e:	83 ec 04             	sub    $0x4,%esp
  800491:	51                   	push   %ecx
  800492:	50                   	push   %eax
  800493:	68 78 22 80 00       	push   $0x802278
  800498:	e8 11 11 00 00       	call   8015ae <cprintf>
	*dev = 0;
  80049d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
  8004b5:	83 ec 10             	sub    $0x10,%esp
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c1:	50                   	push   %eax
  8004c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c8:	c1 e8 0c             	shr    $0xc,%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 36 ff ff ff       	call   800407 <fd_lookup>
  8004d1:	83 c4 08             	add    $0x8,%esp
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 05                	js     8004dd <fd_close+0x2d>
	    || fd != fd2)
  8004d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004db:	74 0c                	je     8004e9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004dd:	84 db                	test   %bl,%bl
  8004df:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e4:	0f 44 c2             	cmove  %edx,%eax
  8004e7:	eb 41                	jmp    80052a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 36                	pushl  (%esi)
  8004f2:	e8 66 ff ff ff       	call   80045d <dev_lookup>
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 1a                	js     80051a <fd_close+0x6a>
		if (dev->dev_close)
  800500:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800503:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800506:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050b:	85 c0                	test   %eax,%eax
  80050d:	74 0b                	je     80051a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80050f:	83 ec 0c             	sub    $0xc,%esp
  800512:	56                   	push   %esi
  800513:	ff d0                	call   *%eax
  800515:	89 c3                	mov    %eax,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	56                   	push   %esi
  80051e:	6a 00                	push   $0x0
  800520:	e8 e1 fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	89 d8                	mov    %ebx,%eax
}
  80052a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052d:	5b                   	pop    %ebx
  80052e:	5e                   	pop    %esi
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800537:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053a:	50                   	push   %eax
  80053b:	ff 75 08             	pushl  0x8(%ebp)
  80053e:	e8 c4 fe ff ff       	call   800407 <fd_lookup>
  800543:	83 c4 08             	add    $0x8,%esp
  800546:	85 c0                	test   %eax,%eax
  800548:	78 10                	js     80055a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	6a 01                	push   $0x1
  80054f:	ff 75 f4             	pushl  -0xc(%ebp)
  800552:	e8 59 ff ff ff       	call   8004b0 <fd_close>
  800557:	83 c4 10             	add    $0x10,%esp
}
  80055a:	c9                   	leave  
  80055b:	c3                   	ret    

0080055c <close_all>:

void
close_all(void)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	53                   	push   %ebx
  800560:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800563:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	53                   	push   %ebx
  80056c:	e8 c0 ff ff ff       	call   800531 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800571:	83 c3 01             	add    $0x1,%ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	83 fb 20             	cmp    $0x20,%ebx
  80057a:	75 ec                	jne    800568 <close_all+0xc>
		close(i);
}
  80057c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057f:	c9                   	leave  
  800580:	c3                   	ret    

00800581 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 2c             	sub    $0x2c,%esp
  80058a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800590:	50                   	push   %eax
  800591:	ff 75 08             	pushl  0x8(%ebp)
  800594:	e8 6e fe ff ff       	call   800407 <fd_lookup>
  800599:	83 c4 08             	add    $0x8,%esp
  80059c:	85 c0                	test   %eax,%eax
  80059e:	0f 88 c1 00 00 00    	js     800665 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	56                   	push   %esi
  8005a8:	e8 84 ff ff ff       	call   800531 <close>

	newfd = INDEX2FD(newfdnum);
  8005ad:	89 f3                	mov    %esi,%ebx
  8005af:	c1 e3 0c             	shl    $0xc,%ebx
  8005b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b8:	83 c4 04             	add    $0x4,%esp
  8005bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005be:	e8 de fd ff ff       	call   8003a1 <fd2data>
  8005c3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c5:	89 1c 24             	mov    %ebx,(%esp)
  8005c8:	e8 d4 fd ff ff       	call   8003a1 <fd2data>
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d3:	89 f8                	mov    %edi,%eax
  8005d5:	c1 e8 16             	shr    $0x16,%eax
  8005d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005df:	a8 01                	test   $0x1,%al
  8005e1:	74 37                	je     80061a <dup+0x99>
  8005e3:	89 f8                	mov    %edi,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ef:	f6 c2 01             	test   $0x1,%dl
  8005f2:	74 26                	je     80061a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	25 07 0e 00 00       	and    $0xe07,%eax
  800603:	50                   	push   %eax
  800604:	ff 75 d4             	pushl  -0x2c(%ebp)
  800607:	6a 00                	push   $0x0
  800609:	57                   	push   %edi
  80060a:	6a 00                	push   $0x0
  80060c:	e8 b3 fb ff ff       	call   8001c4 <sys_page_map>
  800611:	89 c7                	mov    %eax,%edi
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	85 c0                	test   %eax,%eax
  800618:	78 2e                	js     800648 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061d:	89 d0                	mov    %edx,%eax
  80061f:	c1 e8 0c             	shr    $0xc,%eax
  800622:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800629:	83 ec 0c             	sub    $0xc,%esp
  80062c:	25 07 0e 00 00       	and    $0xe07,%eax
  800631:	50                   	push   %eax
  800632:	53                   	push   %ebx
  800633:	6a 00                	push   $0x0
  800635:	52                   	push   %edx
  800636:	6a 00                	push   $0x0
  800638:	e8 87 fb ff ff       	call   8001c4 <sys_page_map>
  80063d:	89 c7                	mov    %eax,%edi
  80063f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800642:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800644:	85 ff                	test   %edi,%edi
  800646:	79 1d                	jns    800665 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 00                	push   $0x0
  80064e:	e8 b3 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	ff 75 d4             	pushl  -0x2c(%ebp)
  800659:	6a 00                	push   $0x0
  80065b:	e8 a6 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	89 f8                	mov    %edi,%eax
}
  800665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800668:	5b                   	pop    %ebx
  800669:	5e                   	pop    %esi
  80066a:	5f                   	pop    %edi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	53                   	push   %ebx
  800671:	83 ec 14             	sub    $0x14,%esp
  800674:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800677:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	53                   	push   %ebx
  80067c:	e8 86 fd ff ff       	call   800407 <fd_lookup>
  800681:	83 c4 08             	add    $0x8,%esp
  800684:	89 c2                	mov    %eax,%edx
  800686:	85 c0                	test   %eax,%eax
  800688:	78 6d                	js     8006f7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800690:	50                   	push   %eax
  800691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800694:	ff 30                	pushl  (%eax)
  800696:	e8 c2 fd ff ff       	call   80045d <dev_lookup>
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	78 4c                	js     8006ee <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a5:	8b 42 08             	mov    0x8(%edx),%eax
  8006a8:	83 e0 03             	and    $0x3,%eax
  8006ab:	83 f8 01             	cmp    $0x1,%eax
  8006ae:	75 21                	jne    8006d1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8006b5:	8b 40 48             	mov    0x48(%eax),%eax
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	50                   	push   %eax
  8006bd:	68 b9 22 80 00       	push   $0x8022b9
  8006c2:	e8 e7 0e 00 00       	call   8015ae <cprintf>
		return -E_INVAL;
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006cf:	eb 26                	jmp    8006f7 <read+0x8a>
	}
	if (!dev->dev_read)
  8006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d4:	8b 40 08             	mov    0x8(%eax),%eax
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	74 17                	je     8006f2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006db:	83 ec 04             	sub    $0x4,%esp
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	ff 75 0c             	pushl  0xc(%ebp)
  8006e4:	52                   	push   %edx
  8006e5:	ff d0                	call   *%eax
  8006e7:	89 c2                	mov    %eax,%edx
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	eb 09                	jmp    8006f7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ee:	89 c2                	mov    %eax,%edx
  8006f0:	eb 05                	jmp    8006f7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006f7:	89 d0                	mov    %edx,%eax
  8006f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	57                   	push   %edi
  800702:	56                   	push   %esi
  800703:	53                   	push   %ebx
  800704:	83 ec 0c             	sub    $0xc,%esp
  800707:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800712:	eb 21                	jmp    800735 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800714:	83 ec 04             	sub    $0x4,%esp
  800717:	89 f0                	mov    %esi,%eax
  800719:	29 d8                	sub    %ebx,%eax
  80071b:	50                   	push   %eax
  80071c:	89 d8                	mov    %ebx,%eax
  80071e:	03 45 0c             	add    0xc(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	57                   	push   %edi
  800723:	e8 45 ff ff ff       	call   80066d <read>
		if (m < 0)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 10                	js     80073f <readn+0x41>
			return m;
		if (m == 0)
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 0a                	je     80073d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800733:	01 c3                	add    %eax,%ebx
  800735:	39 f3                	cmp    %esi,%ebx
  800737:	72 db                	jb     800714 <readn+0x16>
  800739:	89 d8                	mov    %ebx,%eax
  80073b:	eb 02                	jmp    80073f <readn+0x41>
  80073d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	83 ec 14             	sub    $0x14,%esp
  80074e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800751:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800754:	50                   	push   %eax
  800755:	53                   	push   %ebx
  800756:	e8 ac fc ff ff       	call   800407 <fd_lookup>
  80075b:	83 c4 08             	add    $0x8,%esp
  80075e:	89 c2                	mov    %eax,%edx
  800760:	85 c0                	test   %eax,%eax
  800762:	78 68                	js     8007cc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076e:	ff 30                	pushl  (%eax)
  800770:	e8 e8 fc ff ff       	call   80045d <dev_lookup>
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	85 c0                	test   %eax,%eax
  80077a:	78 47                	js     8007c3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800783:	75 21                	jne    8007a6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800785:	a1 08 40 80 00       	mov    0x804008,%eax
  80078a:	8b 40 48             	mov    0x48(%eax),%eax
  80078d:	83 ec 04             	sub    $0x4,%esp
  800790:	53                   	push   %ebx
  800791:	50                   	push   %eax
  800792:	68 d5 22 80 00       	push   $0x8022d5
  800797:	e8 12 0e 00 00       	call   8015ae <cprintf>
		return -E_INVAL;
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a4:	eb 26                	jmp    8007cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 17                	je     8007c7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b0:	83 ec 04             	sub    $0x4,%esp
  8007b3:	ff 75 10             	pushl  0x10(%ebp)
  8007b6:	ff 75 0c             	pushl  0xc(%ebp)
  8007b9:	50                   	push   %eax
  8007ba:	ff d2                	call   *%edx
  8007bc:	89 c2                	mov    %eax,%edx
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 09                	jmp    8007cc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	eb 05                	jmp    8007cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007cc:	89 d0                	mov    %edx,%eax
  8007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	ff 75 08             	pushl  0x8(%ebp)
  8007e0:	e8 22 fc ff ff       	call   800407 <fd_lookup>
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	78 0e                	js     8007fa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	83 ec 14             	sub    $0x14,%esp
  800803:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800806:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800809:	50                   	push   %eax
  80080a:	53                   	push   %ebx
  80080b:	e8 f7 fb ff ff       	call   800407 <fd_lookup>
  800810:	83 c4 08             	add    $0x8,%esp
  800813:	89 c2                	mov    %eax,%edx
  800815:	85 c0                	test   %eax,%eax
  800817:	78 65                	js     80087e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800823:	ff 30                	pushl  (%eax)
  800825:	e8 33 fc ff ff       	call   80045d <dev_lookup>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	85 c0                	test   %eax,%eax
  80082f:	78 44                	js     800875 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800834:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800838:	75 21                	jne    80085b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083f:	8b 40 48             	mov    0x48(%eax),%eax
  800842:	83 ec 04             	sub    $0x4,%esp
  800845:	53                   	push   %ebx
  800846:	50                   	push   %eax
  800847:	68 98 22 80 00       	push   $0x802298
  80084c:	e8 5d 0d 00 00       	call   8015ae <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800859:	eb 23                	jmp    80087e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085e:	8b 52 18             	mov    0x18(%edx),%edx
  800861:	85 d2                	test   %edx,%edx
  800863:	74 14                	je     800879 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	ff 75 0c             	pushl  0xc(%ebp)
  80086b:	50                   	push   %eax
  80086c:	ff d2                	call   *%edx
  80086e:	89 c2                	mov    %eax,%edx
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	eb 09                	jmp    80087e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800875:	89 c2                	mov    %eax,%edx
  800877:	eb 05                	jmp    80087e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800879:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087e:	89 d0                	mov    %edx,%eax
  800880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	83 ec 14             	sub    $0x14,%esp
  80088c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800892:	50                   	push   %eax
  800893:	ff 75 08             	pushl  0x8(%ebp)
  800896:	e8 6c fb ff ff       	call   800407 <fd_lookup>
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	78 58                	js     8008fc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ae:	ff 30                	pushl  (%eax)
  8008b0:	e8 a8 fb ff ff       	call   80045d <dev_lookup>
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	78 37                	js     8008f3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c3:	74 32                	je     8008f7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008cf:	00 00 00 
	stat->st_isdir = 0;
  8008d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d9:	00 00 00 
	stat->st_dev = dev;
  8008dc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	53                   	push   %ebx
  8008e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e9:	ff 50 14             	call   *0x14(%eax)
  8008ec:	89 c2                	mov    %eax,%edx
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	eb 09                	jmp    8008fc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f3:	89 c2                	mov    %eax,%edx
  8008f5:	eb 05                	jmp    8008fc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	6a 00                	push   $0x0
  80090d:	ff 75 08             	pushl  0x8(%ebp)
  800910:	e8 d6 01 00 00       	call   800aeb <open>
  800915:	89 c3                	mov    %eax,%ebx
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 1b                	js     800939 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	ff 75 0c             	pushl  0xc(%ebp)
  800924:	50                   	push   %eax
  800925:	e8 5b ff ff ff       	call   800885 <fstat>
  80092a:	89 c6                	mov    %eax,%esi
	close(fd);
  80092c:	89 1c 24             	mov    %ebx,(%esp)
  80092f:	e8 fd fb ff ff       	call   800531 <close>
	return r;
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	89 f0                	mov    %esi,%eax
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	89 c6                	mov    %eax,%esi
  800947:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800949:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800950:	75 12                	jne    800964 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800952:	83 ec 0c             	sub    $0xc,%esp
  800955:	6a 01                	push   $0x1
  800957:	e8 d9 15 00 00       	call   801f35 <ipc_find_env>
  80095c:	a3 00 40 80 00       	mov    %eax,0x804000
  800961:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800964:	6a 07                	push   $0x7
  800966:	68 00 50 80 00       	push   $0x805000
  80096b:	56                   	push   %esi
  80096c:	ff 35 00 40 80 00    	pushl  0x804000
  800972:	e8 6a 15 00 00       	call   801ee1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800977:	83 c4 0c             	add    $0xc,%esp
  80097a:	6a 00                	push   $0x0
  80097c:	53                   	push   %ebx
  80097d:	6a 00                	push   $0x0
  80097f:	e8 f6 14 00 00       	call   801e7a <ipc_recv>
}
  800984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 40 0c             	mov    0xc(%eax),%eax
  800997:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ae:	e8 8d ff ff ff       	call   800940 <fsipc>
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d0:	e8 6b ff ff ff       	call   800940 <fsipc>
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	83 ec 04             	sub    $0x4,%esp
  8009de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f6:	e8 45 ff ff ff       	call   800940 <fsipc>
  8009fb:	85 c0                	test   %eax,%eax
  8009fd:	78 2c                	js     800a2b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	68 00 50 80 00       	push   $0x805000
  800a07:	53                   	push   %ebx
  800a08:	e8 26 11 00 00       	call   801b33 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0d:	a1 80 50 80 00       	mov    0x805080,%eax
  800a12:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a18:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a23:	83 c4 10             	add    $0x10,%esp
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 0c             	sub    $0xc,%esp
  800a36:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a39:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3c:	8b 52 0c             	mov    0xc(%edx),%edx
  800a3f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a45:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4a:	50                   	push   %eax
  800a4b:	ff 75 0c             	pushl  0xc(%ebp)
  800a4e:	68 08 50 80 00       	push   $0x805008
  800a53:	e8 6d 12 00 00       	call   801cc5 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a62:	e8 d9 fe ff ff       	call   800940 <fsipc>

}
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 40 0c             	mov    0xc(%eax),%eax
  800a77:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a82:	ba 00 00 00 00       	mov    $0x0,%edx
  800a87:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8c:	e8 af fe ff ff       	call   800940 <fsipc>
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	85 c0                	test   %eax,%eax
  800a95:	78 4b                	js     800ae2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a97:	39 c6                	cmp    %eax,%esi
  800a99:	73 16                	jae    800ab1 <devfile_read+0x48>
  800a9b:	68 08 23 80 00       	push   $0x802308
  800aa0:	68 0f 23 80 00       	push   $0x80230f
  800aa5:	6a 7c                	push   $0x7c
  800aa7:	68 24 23 80 00       	push   $0x802324
  800aac:	e8 24 0a 00 00       	call   8014d5 <_panic>
	assert(r <= PGSIZE);
  800ab1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab6:	7e 16                	jle    800ace <devfile_read+0x65>
  800ab8:	68 2f 23 80 00       	push   $0x80232f
  800abd:	68 0f 23 80 00       	push   $0x80230f
  800ac2:	6a 7d                	push   $0x7d
  800ac4:	68 24 23 80 00       	push   $0x802324
  800ac9:	e8 07 0a 00 00       	call   8014d5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ace:	83 ec 04             	sub    $0x4,%esp
  800ad1:	50                   	push   %eax
  800ad2:	68 00 50 80 00       	push   $0x805000
  800ad7:	ff 75 0c             	pushl  0xc(%ebp)
  800ada:	e8 e6 11 00 00       	call   801cc5 <memmove>
	return r;
  800adf:	83 c4 10             	add    $0x10,%esp
}
  800ae2:	89 d8                	mov    %ebx,%eax
  800ae4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	53                   	push   %ebx
  800aef:	83 ec 20             	sub    $0x20,%esp
  800af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af5:	53                   	push   %ebx
  800af6:	e8 ff 0f 00 00       	call   801afa <strlen>
  800afb:	83 c4 10             	add    $0x10,%esp
  800afe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b03:	7f 67                	jg     800b6c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0b:	50                   	push   %eax
  800b0c:	e8 a7 f8 ff ff       	call   8003b8 <fd_alloc>
  800b11:	83 c4 10             	add    $0x10,%esp
		return r;
  800b14:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b16:	85 c0                	test   %eax,%eax
  800b18:	78 57                	js     800b71 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b1a:	83 ec 08             	sub    $0x8,%esp
  800b1d:	53                   	push   %ebx
  800b1e:	68 00 50 80 00       	push   $0x805000
  800b23:	e8 0b 10 00 00       	call   801b33 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b33:	b8 01 00 00 00       	mov    $0x1,%eax
  800b38:	e8 03 fe ff ff       	call   800940 <fsipc>
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	85 c0                	test   %eax,%eax
  800b44:	79 14                	jns    800b5a <open+0x6f>
		fd_close(fd, 0);
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	6a 00                	push   $0x0
  800b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4e:	e8 5d f9 ff ff       	call   8004b0 <fd_close>
		return r;
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	89 da                	mov    %ebx,%edx
  800b58:	eb 17                	jmp    800b71 <open+0x86>
	}

	return fd2num(fd);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b60:	e8 2c f8 ff ff       	call   800391 <fd2num>
  800b65:	89 c2                	mov    %eax,%edx
  800b67:	83 c4 10             	add    $0x10,%esp
  800b6a:	eb 05                	jmp    800b71 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b6c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b71:	89 d0                	mov    %edx,%eax
  800b73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 08 00 00 00       	mov    $0x8,%eax
  800b88:	e8 b3 fd ff ff       	call   800940 <fsipc>
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b95:	68 3b 23 80 00       	push   $0x80233b
  800b9a:	ff 75 0c             	pushl  0xc(%ebp)
  800b9d:	e8 91 0f 00 00       	call   801b33 <strcpy>
	return 0;
}
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	53                   	push   %ebx
  800bad:	83 ec 10             	sub    $0x10,%esp
  800bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb3:	53                   	push   %ebx
  800bb4:	e8 b5 13 00 00       	call   801f6e <pageref>
  800bb9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bc1:	83 f8 01             	cmp    $0x1,%eax
  800bc4:	75 10                	jne    800bd6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	ff 73 0c             	pushl  0xc(%ebx)
  800bcc:	e8 c0 02 00 00       	call   800e91 <nsipc_close>
  800bd1:	89 c2                	mov    %eax,%edx
  800bd3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bd6:	89 d0                	mov    %edx,%eax
  800bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be3:	6a 00                	push   $0x0
  800be5:	ff 75 10             	pushl  0x10(%ebp)
  800be8:	ff 75 0c             	pushl  0xc(%ebp)
  800beb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bee:	ff 70 0c             	pushl  0xc(%eax)
  800bf1:	e8 78 03 00 00       	call   800f6e <nsipc_send>
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bfe:	6a 00                	push   $0x0
  800c00:	ff 75 10             	pushl  0x10(%ebp)
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	8b 45 08             	mov    0x8(%ebp),%eax
  800c09:	ff 70 0c             	pushl  0xc(%eax)
  800c0c:	e8 f1 02 00 00       	call   800f02 <nsipc_recv>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c19:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c1c:	52                   	push   %edx
  800c1d:	50                   	push   %eax
  800c1e:	e8 e4 f7 ff ff       	call   800407 <fd_lookup>
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	85 c0                	test   %eax,%eax
  800c28:	78 17                	js     800c41 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c33:	39 08                	cmp    %ecx,(%eax)
  800c35:	75 05                	jne    800c3c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c37:	8b 40 0c             	mov    0xc(%eax),%eax
  800c3a:	eb 05                	jmp    800c41 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 1c             	sub    $0x1c,%esp
  800c4b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c50:	50                   	push   %eax
  800c51:	e8 62 f7 ff ff       	call   8003b8 <fd_alloc>
  800c56:	89 c3                	mov    %eax,%ebx
  800c58:	83 c4 10             	add    $0x10,%esp
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	78 1b                	js     800c7a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c5f:	83 ec 04             	sub    $0x4,%esp
  800c62:	68 07 04 00 00       	push   $0x407
  800c67:	ff 75 f4             	pushl  -0xc(%ebp)
  800c6a:	6a 00                	push   $0x0
  800c6c:	e8 10 f5 ff ff       	call   800181 <sys_page_alloc>
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	85 c0                	test   %eax,%eax
  800c78:	79 10                	jns    800c8a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	56                   	push   %esi
  800c7e:	e8 0e 02 00 00       	call   800e91 <nsipc_close>
		return r;
  800c83:	83 c4 10             	add    $0x10,%esp
  800c86:	89 d8                	mov    %ebx,%eax
  800c88:	eb 24                	jmp    800cae <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c8a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c93:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c98:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c9f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	e8 e6 f6 ff ff       	call   800391 <fd2num>
  800cab:	83 c4 10             	add    $0x10,%esp
}
  800cae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	e8 50 ff ff ff       	call   800c13 <fd2sockid>
		return r;
  800cc3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	78 1f                	js     800ce8 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cc9:	83 ec 04             	sub    $0x4,%esp
  800ccc:	ff 75 10             	pushl  0x10(%ebp)
  800ccf:	ff 75 0c             	pushl  0xc(%ebp)
  800cd2:	50                   	push   %eax
  800cd3:	e8 12 01 00 00       	call   800dea <nsipc_accept>
  800cd8:	83 c4 10             	add    $0x10,%esp
		return r;
  800cdb:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	78 07                	js     800ce8 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800ce1:	e8 5d ff ff ff       	call   800c43 <alloc_sockfd>
  800ce6:	89 c1                	mov    %eax,%ecx
}
  800ce8:	89 c8                	mov    %ecx,%eax
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    

00800cec <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	e8 19 ff ff ff       	call   800c13 <fd2sockid>
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	78 12                	js     800d10 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800cfe:	83 ec 04             	sub    $0x4,%esp
  800d01:	ff 75 10             	pushl  0x10(%ebp)
  800d04:	ff 75 0c             	pushl  0xc(%ebp)
  800d07:	50                   	push   %eax
  800d08:	e8 2d 01 00 00       	call   800e3a <nsipc_bind>
  800d0d:	83 c4 10             	add    $0x10,%esp
}
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <shutdown>:

int
shutdown(int s, int how)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	e8 f3 fe ff ff       	call   800c13 <fd2sockid>
  800d20:	85 c0                	test   %eax,%eax
  800d22:	78 0f                	js     800d33 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d24:	83 ec 08             	sub    $0x8,%esp
  800d27:	ff 75 0c             	pushl  0xc(%ebp)
  800d2a:	50                   	push   %eax
  800d2b:	e8 3f 01 00 00       	call   800e6f <nsipc_shutdown>
  800d30:	83 c4 10             	add    $0x10,%esp
}
  800d33:	c9                   	leave  
  800d34:	c3                   	ret    

00800d35 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3e:	e8 d0 fe ff ff       	call   800c13 <fd2sockid>
  800d43:	85 c0                	test   %eax,%eax
  800d45:	78 12                	js     800d59 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d47:	83 ec 04             	sub    $0x4,%esp
  800d4a:	ff 75 10             	pushl  0x10(%ebp)
  800d4d:	ff 75 0c             	pushl  0xc(%ebp)
  800d50:	50                   	push   %eax
  800d51:	e8 55 01 00 00       	call   800eab <nsipc_connect>
  800d56:	83 c4 10             	add    $0x10,%esp
}
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    

00800d5b <listen>:

int
listen(int s, int backlog)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	e8 aa fe ff ff       	call   800c13 <fd2sockid>
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	78 0f                	js     800d7c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d6d:	83 ec 08             	sub    $0x8,%esp
  800d70:	ff 75 0c             	pushl  0xc(%ebp)
  800d73:	50                   	push   %eax
  800d74:	e8 67 01 00 00       	call   800ee0 <nsipc_listen>
  800d79:	83 c4 10             	add    $0x10,%esp
}
  800d7c:	c9                   	leave  
  800d7d:	c3                   	ret    

00800d7e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d84:	ff 75 10             	pushl  0x10(%ebp)
  800d87:	ff 75 0c             	pushl  0xc(%ebp)
  800d8a:	ff 75 08             	pushl  0x8(%ebp)
  800d8d:	e8 3a 02 00 00       	call   800fcc <nsipc_socket>
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	78 05                	js     800d9e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d99:	e8 a5 fe ff ff       	call   800c43 <alloc_sockfd>
}
  800d9e:	c9                   	leave  
  800d9f:	c3                   	ret    

00800da0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	53                   	push   %ebx
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800da9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800db0:	75 12                	jne    800dc4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	6a 02                	push   $0x2
  800db7:	e8 79 11 00 00       	call   801f35 <ipc_find_env>
  800dbc:	a3 04 40 80 00       	mov    %eax,0x804004
  800dc1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dc4:	6a 07                	push   $0x7
  800dc6:	68 00 60 80 00       	push   $0x806000
  800dcb:	53                   	push   %ebx
  800dcc:	ff 35 04 40 80 00    	pushl  0x804004
  800dd2:	e8 0a 11 00 00       	call   801ee1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dd7:	83 c4 0c             	add    $0xc,%esp
  800dda:	6a 00                	push   $0x0
  800ddc:	6a 00                	push   $0x0
  800dde:	6a 00                	push   $0x0
  800de0:	e8 95 10 00 00       	call   801e7a <ipc_recv>
}
  800de5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    

00800dea <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
  800df5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dfa:	8b 06                	mov    (%esi),%eax
  800dfc:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e01:	b8 01 00 00 00       	mov    $0x1,%eax
  800e06:	e8 95 ff ff ff       	call   800da0 <nsipc>
  800e0b:	89 c3                	mov    %eax,%ebx
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	78 20                	js     800e31 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	ff 35 10 60 80 00    	pushl  0x806010
  800e1a:	68 00 60 80 00       	push   $0x806000
  800e1f:	ff 75 0c             	pushl  0xc(%ebp)
  800e22:	e8 9e 0e 00 00       	call   801cc5 <memmove>
		*addrlen = ret->ret_addrlen;
  800e27:	a1 10 60 80 00       	mov    0x806010,%eax
  800e2c:	89 06                	mov    %eax,(%esi)
  800e2e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e31:	89 d8                	mov    %ebx,%eax
  800e33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e36:	5b                   	pop    %ebx
  800e37:	5e                   	pop    %esi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	53                   	push   %ebx
  800e3e:	83 ec 08             	sub    $0x8,%esp
  800e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e44:	8b 45 08             	mov    0x8(%ebp),%eax
  800e47:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e4c:	53                   	push   %ebx
  800e4d:	ff 75 0c             	pushl  0xc(%ebp)
  800e50:	68 04 60 80 00       	push   $0x806004
  800e55:	e8 6b 0e 00 00       	call   801cc5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e5a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e60:	b8 02 00 00 00       	mov    $0x2,%eax
  800e65:	e8 36 ff ff ff       	call   800da0 <nsipc>
}
  800e6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e80:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e85:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8a:	e8 11 ff ff ff       	call   800da0 <nsipc>
}
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    

00800e91 <nsipc_close>:

int
nsipc_close(int s)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea4:	e8 f7 fe ff ff       	call   800da0 <nsipc>
}
  800ea9:	c9                   	leave  
  800eaa:	c3                   	ret    

00800eab <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ebd:	53                   	push   %ebx
  800ebe:	ff 75 0c             	pushl  0xc(%ebp)
  800ec1:	68 04 60 80 00       	push   $0x806004
  800ec6:	e8 fa 0d 00 00       	call   801cc5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ecb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ed1:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed6:	e8 c5 fe ff ff       	call   800da0 <nsipc>
}
  800edb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ede:	c9                   	leave  
  800edf:	c3                   	ret    

00800ee0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ef6:	b8 06 00 00 00       	mov    $0x6,%eax
  800efb:	e8 a0 fe ff ff       	call   800da0 <nsipc>
}
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
  800f07:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f12:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f18:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f20:	b8 07 00 00 00       	mov    $0x7,%eax
  800f25:	e8 76 fe ff ff       	call   800da0 <nsipc>
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 35                	js     800f65 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f30:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f35:	7f 04                	jg     800f3b <nsipc_recv+0x39>
  800f37:	39 c6                	cmp    %eax,%esi
  800f39:	7d 16                	jge    800f51 <nsipc_recv+0x4f>
  800f3b:	68 47 23 80 00       	push   $0x802347
  800f40:	68 0f 23 80 00       	push   $0x80230f
  800f45:	6a 62                	push   $0x62
  800f47:	68 5c 23 80 00       	push   $0x80235c
  800f4c:	e8 84 05 00 00       	call   8014d5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	50                   	push   %eax
  800f55:	68 00 60 80 00       	push   $0x806000
  800f5a:	ff 75 0c             	pushl  0xc(%ebp)
  800f5d:	e8 63 0d 00 00       	call   801cc5 <memmove>
  800f62:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f65:	89 d8                	mov    %ebx,%eax
  800f67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	53                   	push   %ebx
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f80:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f86:	7e 16                	jle    800f9e <nsipc_send+0x30>
  800f88:	68 68 23 80 00       	push   $0x802368
  800f8d:	68 0f 23 80 00       	push   $0x80230f
  800f92:	6a 6d                	push   $0x6d
  800f94:	68 5c 23 80 00       	push   $0x80235c
  800f99:	e8 37 05 00 00       	call   8014d5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	53                   	push   %ebx
  800fa2:	ff 75 0c             	pushl  0xc(%ebp)
  800fa5:	68 0c 60 80 00       	push   $0x80600c
  800faa:	e8 16 0d 00 00       	call   801cc5 <memmove>
	nsipcbuf.send.req_size = size;
  800faf:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fb5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fbd:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc2:	e8 d9 fd ff ff       	call   800da0 <nsipc>
}
  800fc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    

00800fcc <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdd:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fe2:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fea:	b8 09 00 00 00       	mov    $0x9,%eax
  800fef:	e8 ac fd ff ff       	call   800da0 <nsipc>
}
  800ff4:	c9                   	leave  
  800ff5:	c3                   	ret    

00800ff6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	ff 75 08             	pushl  0x8(%ebp)
  801004:	e8 98 f3 ff ff       	call   8003a1 <fd2data>
  801009:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80100b:	83 c4 08             	add    $0x8,%esp
  80100e:	68 74 23 80 00       	push   $0x802374
  801013:	53                   	push   %ebx
  801014:	e8 1a 0b 00 00       	call   801b33 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801019:	8b 46 04             	mov    0x4(%esi),%eax
  80101c:	2b 06                	sub    (%esi),%eax
  80101e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801024:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80102b:	00 00 00 
	stat->st_dev = &devpipe;
  80102e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801035:	30 80 00 
	return 0;
}
  801038:	b8 00 00 00 00       	mov    $0x0,%eax
  80103d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	53                   	push   %ebx
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80104e:	53                   	push   %ebx
  80104f:	6a 00                	push   $0x0
  801051:	e8 b0 f1 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801056:	89 1c 24             	mov    %ebx,(%esp)
  801059:	e8 43 f3 ff ff       	call   8003a1 <fd2data>
  80105e:	83 c4 08             	add    $0x8,%esp
  801061:	50                   	push   %eax
  801062:	6a 00                	push   $0x0
  801064:	e8 9d f1 ff ff       	call   800206 <sys_page_unmap>
}
  801069:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 1c             	sub    $0x1c,%esp
  801077:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80107a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80107c:	a1 08 40 80 00       	mov    0x804008,%eax
  801081:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	ff 75 e0             	pushl  -0x20(%ebp)
  80108a:	e8 df 0e 00 00       	call   801f6e <pageref>
  80108f:	89 c3                	mov    %eax,%ebx
  801091:	89 3c 24             	mov    %edi,(%esp)
  801094:	e8 d5 0e 00 00       	call   801f6e <pageref>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	39 c3                	cmp    %eax,%ebx
  80109e:	0f 94 c1             	sete   %cl
  8010a1:	0f b6 c9             	movzbl %cl,%ecx
  8010a4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010a7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010ad:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010b0:	39 ce                	cmp    %ecx,%esi
  8010b2:	74 1b                	je     8010cf <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010b4:	39 c3                	cmp    %eax,%ebx
  8010b6:	75 c4                	jne    80107c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010b8:	8b 42 58             	mov    0x58(%edx),%eax
  8010bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010be:	50                   	push   %eax
  8010bf:	56                   	push   %esi
  8010c0:	68 7b 23 80 00       	push   $0x80237b
  8010c5:	e8 e4 04 00 00       	call   8015ae <cprintf>
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	eb ad                	jmp    80107c <_pipeisclosed+0xe>
	}
}
  8010cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	57                   	push   %edi
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
  8010e0:	83 ec 28             	sub    $0x28,%esp
  8010e3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010e6:	56                   	push   %esi
  8010e7:	e8 b5 f2 ff ff       	call   8003a1 <fd2data>
  8010ec:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f6:	eb 4b                	jmp    801143 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010f8:	89 da                	mov    %ebx,%edx
  8010fa:	89 f0                	mov    %esi,%eax
  8010fc:	e8 6d ff ff ff       	call   80106e <_pipeisclosed>
  801101:	85 c0                	test   %eax,%eax
  801103:	75 48                	jne    80114d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801105:	e8 58 f0 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80110a:	8b 43 04             	mov    0x4(%ebx),%eax
  80110d:	8b 0b                	mov    (%ebx),%ecx
  80110f:	8d 51 20             	lea    0x20(%ecx),%edx
  801112:	39 d0                	cmp    %edx,%eax
  801114:	73 e2                	jae    8010f8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801116:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801119:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80111d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801120:	89 c2                	mov    %eax,%edx
  801122:	c1 fa 1f             	sar    $0x1f,%edx
  801125:	89 d1                	mov    %edx,%ecx
  801127:	c1 e9 1b             	shr    $0x1b,%ecx
  80112a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80112d:	83 e2 1f             	and    $0x1f,%edx
  801130:	29 ca                	sub    %ecx,%edx
  801132:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801136:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80113a:	83 c0 01             	add    $0x1,%eax
  80113d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801140:	83 c7 01             	add    $0x1,%edi
  801143:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801146:	75 c2                	jne    80110a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801148:	8b 45 10             	mov    0x10(%ebp),%eax
  80114b:	eb 05                	jmp    801152 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80114d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801152:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5f                   	pop    %edi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	57                   	push   %edi
  80115e:	56                   	push   %esi
  80115f:	53                   	push   %ebx
  801160:	83 ec 18             	sub    $0x18,%esp
  801163:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801166:	57                   	push   %edi
  801167:	e8 35 f2 ff ff       	call   8003a1 <fd2data>
  80116c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	bb 00 00 00 00       	mov    $0x0,%ebx
  801176:	eb 3d                	jmp    8011b5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801178:	85 db                	test   %ebx,%ebx
  80117a:	74 04                	je     801180 <devpipe_read+0x26>
				return i;
  80117c:	89 d8                	mov    %ebx,%eax
  80117e:	eb 44                	jmp    8011c4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801180:	89 f2                	mov    %esi,%edx
  801182:	89 f8                	mov    %edi,%eax
  801184:	e8 e5 fe ff ff       	call   80106e <_pipeisclosed>
  801189:	85 c0                	test   %eax,%eax
  80118b:	75 32                	jne    8011bf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80118d:	e8 d0 ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801192:	8b 06                	mov    (%esi),%eax
  801194:	3b 46 04             	cmp    0x4(%esi),%eax
  801197:	74 df                	je     801178 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801199:	99                   	cltd   
  80119a:	c1 ea 1b             	shr    $0x1b,%edx
  80119d:	01 d0                	add    %edx,%eax
  80119f:	83 e0 1f             	and    $0x1f,%eax
  8011a2:	29 d0                	sub    %edx,%eax
  8011a4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ac:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011af:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011b2:	83 c3 01             	add    $0x1,%ebx
  8011b5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011b8:	75 d8                	jne    801192 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8011bd:	eb 05                	jmp    8011c4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011bf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5f                   	pop    %edi
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d7:	50                   	push   %eax
  8011d8:	e8 db f1 ff ff       	call   8003b8 <fd_alloc>
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	89 c2                	mov    %eax,%edx
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	0f 88 2c 01 00 00    	js     801316 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	68 07 04 00 00       	push   $0x407
  8011f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 85 ef ff ff       	call   800181 <sys_page_alloc>
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	85 c0                	test   %eax,%eax
  801203:	0f 88 0d 01 00 00    	js     801316 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	e8 a3 f1 ff ff       	call   8003b8 <fd_alloc>
  801215:	89 c3                	mov    %eax,%ebx
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	0f 88 e2 00 00 00    	js     801304 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	68 07 04 00 00       	push   $0x407
  80122a:	ff 75 f0             	pushl  -0x10(%ebp)
  80122d:	6a 00                	push   $0x0
  80122f:	e8 4d ef ff ff       	call   800181 <sys_page_alloc>
  801234:	89 c3                	mov    %eax,%ebx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	0f 88 c3 00 00 00    	js     801304 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801241:	83 ec 0c             	sub    $0xc,%esp
  801244:	ff 75 f4             	pushl  -0xc(%ebp)
  801247:	e8 55 f1 ff ff       	call   8003a1 <fd2data>
  80124c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80124e:	83 c4 0c             	add    $0xc,%esp
  801251:	68 07 04 00 00       	push   $0x407
  801256:	50                   	push   %eax
  801257:	6a 00                	push   $0x0
  801259:	e8 23 ef ff ff       	call   800181 <sys_page_alloc>
  80125e:	89 c3                	mov    %eax,%ebx
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	0f 88 89 00 00 00    	js     8012f4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126b:	83 ec 0c             	sub    $0xc,%esp
  80126e:	ff 75 f0             	pushl  -0x10(%ebp)
  801271:	e8 2b f1 ff ff       	call   8003a1 <fd2data>
  801276:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80127d:	50                   	push   %eax
  80127e:	6a 00                	push   $0x0
  801280:	56                   	push   %esi
  801281:	6a 00                	push   $0x0
  801283:	e8 3c ef ff ff       	call   8001c4 <sys_page_map>
  801288:	89 c3                	mov    %eax,%ebx
  80128a:	83 c4 20             	add    $0x20,%esp
  80128d:	85 c0                	test   %eax,%eax
  80128f:	78 55                	js     8012e6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801291:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801297:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80129c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012a6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012af:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c1:	e8 cb f0 ff ff       	call   800391 <fd2num>
  8012c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012cb:	83 c4 04             	add    $0x4,%esp
  8012ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d1:	e8 bb f0 ff ff       	call   800391 <fd2num>
  8012d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e4:	eb 30                	jmp    801316 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	56                   	push   %esi
  8012ea:	6a 00                	push   $0x0
  8012ec:	e8 15 ef ff ff       	call   800206 <sys_page_unmap>
  8012f1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012f4:	83 ec 08             	sub    $0x8,%esp
  8012f7:	ff 75 f0             	pushl  -0x10(%ebp)
  8012fa:	6a 00                	push   $0x0
  8012fc:	e8 05 ef ff ff       	call   800206 <sys_page_unmap>
  801301:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	ff 75 f4             	pushl  -0xc(%ebp)
  80130a:	6a 00                	push   $0x0
  80130c:	e8 f5 ee ff ff       	call   800206 <sys_page_unmap>
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801316:	89 d0                	mov    %edx,%eax
  801318:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    

0080131f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801325:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	ff 75 08             	pushl  0x8(%ebp)
  80132c:	e8 d6 f0 ff ff       	call   800407 <fd_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 18                	js     801350 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	ff 75 f4             	pushl  -0xc(%ebp)
  80133e:	e8 5e f0 ff ff       	call   8003a1 <fd2data>
	return _pipeisclosed(fd, p);
  801343:	89 c2                	mov    %eax,%edx
  801345:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801348:	e8 21 fd ff ff       	call   80106e <_pipeisclosed>
  80134d:	83 c4 10             	add    $0x10,%esp
}
  801350:	c9                   	leave  
  801351:	c3                   	ret    

00801352 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801355:	b8 00 00 00 00       	mov    $0x0,%eax
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801362:	68 93 23 80 00       	push   $0x802393
  801367:	ff 75 0c             	pushl  0xc(%ebp)
  80136a:	e8 c4 07 00 00       	call   801b33 <strcpy>
	return 0;
}
  80136f:	b8 00 00 00 00       	mov    $0x0,%eax
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	57                   	push   %edi
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
  80137c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801382:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801387:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138d:	eb 2d                	jmp    8013bc <devcons_write+0x46>
		m = n - tot;
  80138f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801392:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801394:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801397:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80139c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139f:	83 ec 04             	sub    $0x4,%esp
  8013a2:	53                   	push   %ebx
  8013a3:	03 45 0c             	add    0xc(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	57                   	push   %edi
  8013a8:	e8 18 09 00 00       	call   801cc5 <memmove>
		sys_cputs(buf, m);
  8013ad:	83 c4 08             	add    $0x8,%esp
  8013b0:	53                   	push   %ebx
  8013b1:	57                   	push   %edi
  8013b2:	e8 0e ed ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b7:	01 de                	add    %ebx,%esi
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	89 f0                	mov    %esi,%eax
  8013be:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013c1:	72 cc                	jb     80138f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013da:	74 2a                	je     801406 <devcons_read+0x3b>
  8013dc:	eb 05                	jmp    8013e3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013de:	e8 7f ed ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013e3:	e8 fb ec ff ff       	call   8000e3 <sys_cgetc>
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	74 f2                	je     8013de <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 16                	js     801406 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013f0:	83 f8 04             	cmp    $0x4,%eax
  8013f3:	74 0c                	je     801401 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f8:	88 02                	mov    %al,(%edx)
	return 1;
  8013fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ff:	eb 05                	jmp    801406 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801401:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801406:	c9                   	leave  
  801407:	c3                   	ret    

00801408 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
  801411:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801414:	6a 01                	push   $0x1
  801416:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	e8 a6 ec ff ff       	call   8000c5 <sys_cputs>
}
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <getchar>:

int
getchar(void)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80142a:	6a 01                	push   $0x1
  80142c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	6a 00                	push   $0x0
  801432:	e8 36 f2 ff ff       	call   80066d <read>
	if (r < 0)
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 0f                	js     80144d <getchar+0x29>
		return r;
	if (r < 1)
  80143e:	85 c0                	test   %eax,%eax
  801440:	7e 06                	jle    801448 <getchar+0x24>
		return -E_EOF;
	return c;
  801442:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801446:	eb 05                	jmp    80144d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801448:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801455:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	ff 75 08             	pushl  0x8(%ebp)
  80145c:	e8 a6 ef ff ff       	call   800407 <fd_lookup>
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 11                	js     801479 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801471:	39 10                	cmp    %edx,(%eax)
  801473:	0f 94 c0             	sete   %al
  801476:	0f b6 c0             	movzbl %al,%eax
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <opencons>:

int
opencons(void)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	e8 2e ef ff ff       	call   8003b8 <fd_alloc>
  80148a:	83 c4 10             	add    $0x10,%esp
		return r;
  80148d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 3e                	js     8014d1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801493:	83 ec 04             	sub    $0x4,%esp
  801496:	68 07 04 00 00       	push   $0x407
  80149b:	ff 75 f4             	pushl  -0xc(%ebp)
  80149e:	6a 00                	push   $0x0
  8014a0:	e8 dc ec ff ff       	call   800181 <sys_page_alloc>
  8014a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 23                	js     8014d1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014ae:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	50                   	push   %eax
  8014c7:	e8 c5 ee ff ff       	call   800391 <fd2num>
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	83 c4 10             	add    $0x10,%esp
}
  8014d1:	89 d0                	mov    %edx,%eax
  8014d3:	c9                   	leave  
  8014d4:	c3                   	ret    

008014d5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	56                   	push   %esi
  8014d9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014da:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014dd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014e3:	e8 5b ec ff ff       	call   800143 <sys_getenvid>
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ee:	ff 75 08             	pushl  0x8(%ebp)
  8014f1:	56                   	push   %esi
  8014f2:	50                   	push   %eax
  8014f3:	68 a0 23 80 00       	push   $0x8023a0
  8014f8:	e8 b1 00 00 00       	call   8015ae <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014fd:	83 c4 18             	add    $0x18,%esp
  801500:	53                   	push   %ebx
  801501:	ff 75 10             	pushl  0x10(%ebp)
  801504:	e8 54 00 00 00       	call   80155d <vcprintf>
	cprintf("\n");
  801509:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  801510:	e8 99 00 00 00       	call   8015ae <cprintf>
  801515:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801518:	cc                   	int3   
  801519:	eb fd                	jmp    801518 <_panic+0x43>

0080151b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	53                   	push   %ebx
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801525:	8b 13                	mov    (%ebx),%edx
  801527:	8d 42 01             	lea    0x1(%edx),%eax
  80152a:	89 03                	mov    %eax,(%ebx)
  80152c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801533:	3d ff 00 00 00       	cmp    $0xff,%eax
  801538:	75 1a                	jne    801554 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	68 ff 00 00 00       	push   $0xff
  801542:	8d 43 08             	lea    0x8(%ebx),%eax
  801545:	50                   	push   %eax
  801546:	e8 7a eb ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  80154b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801551:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801554:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801566:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80156d:	00 00 00 
	b.cnt = 0;
  801570:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801577:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80157a:	ff 75 0c             	pushl  0xc(%ebp)
  80157d:	ff 75 08             	pushl  0x8(%ebp)
  801580:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	68 1b 15 80 00       	push   $0x80151b
  80158c:	e8 54 01 00 00       	call   8016e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80159a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	e8 1f eb ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8015a6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015ac:	c9                   	leave  
  8015ad:	c3                   	ret    

008015ae <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015b4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015b7:	50                   	push   %eax
  8015b8:	ff 75 08             	pushl  0x8(%ebp)
  8015bb:	e8 9d ff ff ff       	call   80155d <vcprintf>
	va_end(ap);

	return cnt;
}
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	57                   	push   %edi
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 1c             	sub    $0x1c,%esp
  8015cb:	89 c7                	mov    %eax,%edi
  8015cd:	89 d6                	mov    %edx,%esi
  8015cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015db:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015e6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015e9:	39 d3                	cmp    %edx,%ebx
  8015eb:	72 05                	jb     8015f2 <printnum+0x30>
  8015ed:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015f0:	77 45                	ja     801637 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	ff 75 18             	pushl  0x18(%ebp)
  8015f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015fe:	53                   	push   %ebx
  8015ff:	ff 75 10             	pushl  0x10(%ebp)
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	ff 75 e4             	pushl  -0x1c(%ebp)
  801608:	ff 75 e0             	pushl  -0x20(%ebp)
  80160b:	ff 75 dc             	pushl  -0x24(%ebp)
  80160e:	ff 75 d8             	pushl  -0x28(%ebp)
  801611:	e8 9a 09 00 00       	call   801fb0 <__udivdi3>
  801616:	83 c4 18             	add    $0x18,%esp
  801619:	52                   	push   %edx
  80161a:	50                   	push   %eax
  80161b:	89 f2                	mov    %esi,%edx
  80161d:	89 f8                	mov    %edi,%eax
  80161f:	e8 9e ff ff ff       	call   8015c2 <printnum>
  801624:	83 c4 20             	add    $0x20,%esp
  801627:	eb 18                	jmp    801641 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	56                   	push   %esi
  80162d:	ff 75 18             	pushl  0x18(%ebp)
  801630:	ff d7                	call   *%edi
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	eb 03                	jmp    80163a <printnum+0x78>
  801637:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80163a:	83 eb 01             	sub    $0x1,%ebx
  80163d:	85 db                	test   %ebx,%ebx
  80163f:	7f e8                	jg     801629 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	56                   	push   %esi
  801645:	83 ec 04             	sub    $0x4,%esp
  801648:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164b:	ff 75 e0             	pushl  -0x20(%ebp)
  80164e:	ff 75 dc             	pushl  -0x24(%ebp)
  801651:	ff 75 d8             	pushl  -0x28(%ebp)
  801654:	e8 87 0a 00 00       	call   8020e0 <__umoddi3>
  801659:	83 c4 14             	add    $0x14,%esp
  80165c:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  801663:	50                   	push   %eax
  801664:	ff d7                	call   *%edi
}
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5e                   	pop    %esi
  80166e:	5f                   	pop    %edi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801674:	83 fa 01             	cmp    $0x1,%edx
  801677:	7e 0e                	jle    801687 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801679:	8b 10                	mov    (%eax),%edx
  80167b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80167e:	89 08                	mov    %ecx,(%eax)
  801680:	8b 02                	mov    (%edx),%eax
  801682:	8b 52 04             	mov    0x4(%edx),%edx
  801685:	eb 22                	jmp    8016a9 <getuint+0x38>
	else if (lflag)
  801687:	85 d2                	test   %edx,%edx
  801689:	74 10                	je     80169b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80168b:	8b 10                	mov    (%eax),%edx
  80168d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801690:	89 08                	mov    %ecx,(%eax)
  801692:	8b 02                	mov    (%edx),%eax
  801694:	ba 00 00 00 00       	mov    $0x0,%edx
  801699:	eb 0e                	jmp    8016a9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80169b:	8b 10                	mov    (%eax),%edx
  80169d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a0:	89 08                	mov    %ecx,(%eax)
  8016a2:	8b 02                	mov    (%edx),%eax
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016b1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016b5:	8b 10                	mov    (%eax),%edx
  8016b7:	3b 50 04             	cmp    0x4(%eax),%edx
  8016ba:	73 0a                	jae    8016c6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016bc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016bf:	89 08                	mov    %ecx,(%eax)
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	88 02                	mov    %al,(%edx)
}
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016d1:	50                   	push   %eax
  8016d2:	ff 75 10             	pushl  0x10(%ebp)
  8016d5:	ff 75 0c             	pushl  0xc(%ebp)
  8016d8:	ff 75 08             	pushl  0x8(%ebp)
  8016db:	e8 05 00 00 00       	call   8016e5 <vprintfmt>
	va_end(ap);
}
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	57                   	push   %edi
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 2c             	sub    $0x2c,%esp
  8016ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016f4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016f7:	eb 12                	jmp    80170b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	0f 84 89 03 00 00    	je     801a8a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	53                   	push   %ebx
  801705:	50                   	push   %eax
  801706:	ff d6                	call   *%esi
  801708:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80170b:	83 c7 01             	add    $0x1,%edi
  80170e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801712:	83 f8 25             	cmp    $0x25,%eax
  801715:	75 e2                	jne    8016f9 <vprintfmt+0x14>
  801717:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80171b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801722:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801729:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801730:	ba 00 00 00 00       	mov    $0x0,%edx
  801735:	eb 07                	jmp    80173e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801737:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80173a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173e:	8d 47 01             	lea    0x1(%edi),%eax
  801741:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801744:	0f b6 07             	movzbl (%edi),%eax
  801747:	0f b6 c8             	movzbl %al,%ecx
  80174a:	83 e8 23             	sub    $0x23,%eax
  80174d:	3c 55                	cmp    $0x55,%al
  80174f:	0f 87 1a 03 00 00    	ja     801a6f <vprintfmt+0x38a>
  801755:	0f b6 c0             	movzbl %al,%eax
  801758:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  80175f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801762:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801766:	eb d6                	jmp    80173e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801768:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80176b:	b8 00 00 00 00       	mov    $0x0,%eax
  801770:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801773:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801776:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80177a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80177d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801780:	83 fa 09             	cmp    $0x9,%edx
  801783:	77 39                	ja     8017be <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801785:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801788:	eb e9                	jmp    801773 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80178a:	8b 45 14             	mov    0x14(%ebp),%eax
  80178d:	8d 48 04             	lea    0x4(%eax),%ecx
  801790:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801793:	8b 00                	mov    (%eax),%eax
  801795:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80179b:	eb 27                	jmp    8017c4 <vprintfmt+0xdf>
  80179d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a7:	0f 49 c8             	cmovns %eax,%ecx
  8017aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017b0:	eb 8c                	jmp    80173e <vprintfmt+0x59>
  8017b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017b5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017bc:	eb 80                	jmp    80173e <vprintfmt+0x59>
  8017be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017c1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017c8:	0f 89 70 ff ff ff    	jns    80173e <vprintfmt+0x59>
				width = precision, precision = -1;
  8017ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017db:	e9 5e ff ff ff       	jmp    80173e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017e0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017e6:	e9 53 ff ff ff       	jmp    80173e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ee:	8d 50 04             	lea    0x4(%eax),%edx
  8017f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8017f4:	83 ec 08             	sub    $0x8,%esp
  8017f7:	53                   	push   %ebx
  8017f8:	ff 30                	pushl  (%eax)
  8017fa:	ff d6                	call   *%esi
			break;
  8017fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801802:	e9 04 ff ff ff       	jmp    80170b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801807:	8b 45 14             	mov    0x14(%ebp),%eax
  80180a:	8d 50 04             	lea    0x4(%eax),%edx
  80180d:	89 55 14             	mov    %edx,0x14(%ebp)
  801810:	8b 00                	mov    (%eax),%eax
  801812:	99                   	cltd   
  801813:	31 d0                	xor    %edx,%eax
  801815:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801817:	83 f8 0f             	cmp    $0xf,%eax
  80181a:	7f 0b                	jg     801827 <vprintfmt+0x142>
  80181c:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  801823:	85 d2                	test   %edx,%edx
  801825:	75 18                	jne    80183f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801827:	50                   	push   %eax
  801828:	68 db 23 80 00       	push   $0x8023db
  80182d:	53                   	push   %ebx
  80182e:	56                   	push   %esi
  80182f:	e8 94 fe ff ff       	call   8016c8 <printfmt>
  801834:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801837:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80183a:	e9 cc fe ff ff       	jmp    80170b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80183f:	52                   	push   %edx
  801840:	68 21 23 80 00       	push   $0x802321
  801845:	53                   	push   %ebx
  801846:	56                   	push   %esi
  801847:	e8 7c fe ff ff       	call   8016c8 <printfmt>
  80184c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801852:	e9 b4 fe ff ff       	jmp    80170b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801857:	8b 45 14             	mov    0x14(%ebp),%eax
  80185a:	8d 50 04             	lea    0x4(%eax),%edx
  80185d:	89 55 14             	mov    %edx,0x14(%ebp)
  801860:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801862:	85 ff                	test   %edi,%edi
  801864:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  801869:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80186c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801870:	0f 8e 94 00 00 00    	jle    80190a <vprintfmt+0x225>
  801876:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80187a:	0f 84 98 00 00 00    	je     801918 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	ff 75 d0             	pushl  -0x30(%ebp)
  801886:	57                   	push   %edi
  801887:	e8 86 02 00 00       	call   801b12 <strnlen>
  80188c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80188f:	29 c1                	sub    %eax,%ecx
  801891:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801894:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801897:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80189b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80189e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018a1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a3:	eb 0f                	jmp    8018b4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	53                   	push   %ebx
  8018a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ac:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ae:	83 ef 01             	sub    $0x1,%edi
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 ff                	test   %edi,%edi
  8018b6:	7f ed                	jg     8018a5 <vprintfmt+0x1c0>
  8018b8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018bb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018be:	85 c9                	test   %ecx,%ecx
  8018c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c5:	0f 49 c1             	cmovns %ecx,%eax
  8018c8:	29 c1                	sub    %eax,%ecx
  8018ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8018cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018d3:	89 cb                	mov    %ecx,%ebx
  8018d5:	eb 4d                	jmp    801924 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018d7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018db:	74 1b                	je     8018f8 <vprintfmt+0x213>
  8018dd:	0f be c0             	movsbl %al,%eax
  8018e0:	83 e8 20             	sub    $0x20,%eax
  8018e3:	83 f8 5e             	cmp    $0x5e,%eax
  8018e6:	76 10                	jbe    8018f8 <vprintfmt+0x213>
					putch('?', putdat);
  8018e8:	83 ec 08             	sub    $0x8,%esp
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	6a 3f                	push   $0x3f
  8018f0:	ff 55 08             	call   *0x8(%ebp)
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	eb 0d                	jmp    801905 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	ff 75 0c             	pushl  0xc(%ebp)
  8018fe:	52                   	push   %edx
  8018ff:	ff 55 08             	call   *0x8(%ebp)
  801902:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801905:	83 eb 01             	sub    $0x1,%ebx
  801908:	eb 1a                	jmp    801924 <vprintfmt+0x23f>
  80190a:	89 75 08             	mov    %esi,0x8(%ebp)
  80190d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801910:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801913:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801916:	eb 0c                	jmp    801924 <vprintfmt+0x23f>
  801918:	89 75 08             	mov    %esi,0x8(%ebp)
  80191b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80191e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801921:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801924:	83 c7 01             	add    $0x1,%edi
  801927:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80192b:	0f be d0             	movsbl %al,%edx
  80192e:	85 d2                	test   %edx,%edx
  801930:	74 23                	je     801955 <vprintfmt+0x270>
  801932:	85 f6                	test   %esi,%esi
  801934:	78 a1                	js     8018d7 <vprintfmt+0x1f2>
  801936:	83 ee 01             	sub    $0x1,%esi
  801939:	79 9c                	jns    8018d7 <vprintfmt+0x1f2>
  80193b:	89 df                	mov    %ebx,%edi
  80193d:	8b 75 08             	mov    0x8(%ebp),%esi
  801940:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801943:	eb 18                	jmp    80195d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	53                   	push   %ebx
  801949:	6a 20                	push   $0x20
  80194b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80194d:	83 ef 01             	sub    $0x1,%edi
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	eb 08                	jmp    80195d <vprintfmt+0x278>
  801955:	89 df                	mov    %ebx,%edi
  801957:	8b 75 08             	mov    0x8(%ebp),%esi
  80195a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195d:	85 ff                	test   %edi,%edi
  80195f:	7f e4                	jg     801945 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801961:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801964:	e9 a2 fd ff ff       	jmp    80170b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801969:	83 fa 01             	cmp    $0x1,%edx
  80196c:	7e 16                	jle    801984 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80196e:	8b 45 14             	mov    0x14(%ebp),%eax
  801971:	8d 50 08             	lea    0x8(%eax),%edx
  801974:	89 55 14             	mov    %edx,0x14(%ebp)
  801977:	8b 50 04             	mov    0x4(%eax),%edx
  80197a:	8b 00                	mov    (%eax),%eax
  80197c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80197f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801982:	eb 32                	jmp    8019b6 <vprintfmt+0x2d1>
	else if (lflag)
  801984:	85 d2                	test   %edx,%edx
  801986:	74 18                	je     8019a0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801988:	8b 45 14             	mov    0x14(%ebp),%eax
  80198b:	8d 50 04             	lea    0x4(%eax),%edx
  80198e:	89 55 14             	mov    %edx,0x14(%ebp)
  801991:	8b 00                	mov    (%eax),%eax
  801993:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801996:	89 c1                	mov    %eax,%ecx
  801998:	c1 f9 1f             	sar    $0x1f,%ecx
  80199b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80199e:	eb 16                	jmp    8019b6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a3:	8d 50 04             	lea    0x4(%eax),%edx
  8019a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a9:	8b 00                	mov    (%eax),%eax
  8019ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ae:	89 c1                	mov    %eax,%ecx
  8019b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019c5:	79 74                	jns    801a3b <vprintfmt+0x356>
				putch('-', putdat);
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	53                   	push   %ebx
  8019cb:	6a 2d                	push   $0x2d
  8019cd:	ff d6                	call   *%esi
				num = -(long long) num;
  8019cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019d5:	f7 d8                	neg    %eax
  8019d7:	83 d2 00             	adc    $0x0,%edx
  8019da:	f7 da                	neg    %edx
  8019dc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019df:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019e4:	eb 55                	jmp    801a3b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8019e9:	e8 83 fc ff ff       	call   801671 <getuint>
			base = 10;
  8019ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019f3:	eb 46                	jmp    801a3b <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8019f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8019f8:	e8 74 fc ff ff       	call   801671 <getuint>
			base = 8;
  8019fd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a02:	eb 37                	jmp    801a3b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a04:	83 ec 08             	sub    $0x8,%esp
  801a07:	53                   	push   %ebx
  801a08:	6a 30                	push   $0x30
  801a0a:	ff d6                	call   *%esi
			putch('x', putdat);
  801a0c:	83 c4 08             	add    $0x8,%esp
  801a0f:	53                   	push   %ebx
  801a10:	6a 78                	push   $0x78
  801a12:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a14:	8b 45 14             	mov    0x14(%ebp),%eax
  801a17:	8d 50 04             	lea    0x4(%eax),%edx
  801a1a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a1d:	8b 00                	mov    (%eax),%eax
  801a1f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a24:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a27:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a2c:	eb 0d                	jmp    801a3b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a2e:	8d 45 14             	lea    0x14(%ebp),%eax
  801a31:	e8 3b fc ff ff       	call   801671 <getuint>
			base = 16;
  801a36:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a42:	57                   	push   %edi
  801a43:	ff 75 e0             	pushl  -0x20(%ebp)
  801a46:	51                   	push   %ecx
  801a47:	52                   	push   %edx
  801a48:	50                   	push   %eax
  801a49:	89 da                	mov    %ebx,%edx
  801a4b:	89 f0                	mov    %esi,%eax
  801a4d:	e8 70 fb ff ff       	call   8015c2 <printnum>
			break;
  801a52:	83 c4 20             	add    $0x20,%esp
  801a55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a58:	e9 ae fc ff ff       	jmp    80170b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a5d:	83 ec 08             	sub    $0x8,%esp
  801a60:	53                   	push   %ebx
  801a61:	51                   	push   %ecx
  801a62:	ff d6                	call   *%esi
			break;
  801a64:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a6a:	e9 9c fc ff ff       	jmp    80170b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a6f:	83 ec 08             	sub    $0x8,%esp
  801a72:	53                   	push   %ebx
  801a73:	6a 25                	push   $0x25
  801a75:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	eb 03                	jmp    801a7f <vprintfmt+0x39a>
  801a7c:	83 ef 01             	sub    $0x1,%edi
  801a7f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a83:	75 f7                	jne    801a7c <vprintfmt+0x397>
  801a85:	e9 81 fc ff ff       	jmp    80170b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5f                   	pop    %edi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 18             	sub    $0x18,%esp
  801a98:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aa1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801aa5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801aa8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	74 26                	je     801ad9 <vsnprintf+0x47>
  801ab3:	85 d2                	test   %edx,%edx
  801ab5:	7e 22                	jle    801ad9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ab7:	ff 75 14             	pushl  0x14(%ebp)
  801aba:	ff 75 10             	pushl  0x10(%ebp)
  801abd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ac0:	50                   	push   %eax
  801ac1:	68 ab 16 80 00       	push   $0x8016ab
  801ac6:	e8 1a fc ff ff       	call   8016e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801acb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ace:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	eb 05                	jmp    801ade <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ad9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ae6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ae9:	50                   	push   %eax
  801aea:	ff 75 10             	pushl  0x10(%ebp)
  801aed:	ff 75 0c             	pushl  0xc(%ebp)
  801af0:	ff 75 08             	pushl  0x8(%ebp)
  801af3:	e8 9a ff ff ff       	call   801a92 <vsnprintf>
	va_end(ap);

	return rc;
}
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b00:	b8 00 00 00 00       	mov    $0x0,%eax
  801b05:	eb 03                	jmp    801b0a <strlen+0x10>
		n++;
  801b07:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b0a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b0e:	75 f7                	jne    801b07 <strlen+0xd>
		n++;
	return n;
}
  801b10:	5d                   	pop    %ebp
  801b11:	c3                   	ret    

00801b12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b18:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b20:	eb 03                	jmp    801b25 <strnlen+0x13>
		n++;
  801b22:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b25:	39 c2                	cmp    %eax,%edx
  801b27:	74 08                	je     801b31 <strnlen+0x1f>
  801b29:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b2d:	75 f3                	jne    801b22 <strnlen+0x10>
  801b2f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	53                   	push   %ebx
  801b37:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b3d:	89 c2                	mov    %eax,%edx
  801b3f:	83 c2 01             	add    $0x1,%edx
  801b42:	83 c1 01             	add    $0x1,%ecx
  801b45:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b49:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b4c:	84 db                	test   %bl,%bl
  801b4e:	75 ef                	jne    801b3f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b50:	5b                   	pop    %ebx
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	53                   	push   %ebx
  801b57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b5a:	53                   	push   %ebx
  801b5b:	e8 9a ff ff ff       	call   801afa <strlen>
  801b60:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b63:	ff 75 0c             	pushl  0xc(%ebp)
  801b66:	01 d8                	add    %ebx,%eax
  801b68:	50                   	push   %eax
  801b69:	e8 c5 ff ff ff       	call   801b33 <strcpy>
	return dst;
}
  801b6e:	89 d8                	mov    %ebx,%eax
  801b70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
  801b7a:	8b 75 08             	mov    0x8(%ebp),%esi
  801b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b80:	89 f3                	mov    %esi,%ebx
  801b82:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b85:	89 f2                	mov    %esi,%edx
  801b87:	eb 0f                	jmp    801b98 <strncpy+0x23>
		*dst++ = *src;
  801b89:	83 c2 01             	add    $0x1,%edx
  801b8c:	0f b6 01             	movzbl (%ecx),%eax
  801b8f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b92:	80 39 01             	cmpb   $0x1,(%ecx)
  801b95:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b98:	39 da                	cmp    %ebx,%edx
  801b9a:	75 ed                	jne    801b89 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b9c:	89 f0                	mov    %esi,%eax
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	56                   	push   %esi
  801ba6:	53                   	push   %ebx
  801ba7:	8b 75 08             	mov    0x8(%ebp),%esi
  801baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bad:	8b 55 10             	mov    0x10(%ebp),%edx
  801bb0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bb2:	85 d2                	test   %edx,%edx
  801bb4:	74 21                	je     801bd7 <strlcpy+0x35>
  801bb6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bba:	89 f2                	mov    %esi,%edx
  801bbc:	eb 09                	jmp    801bc7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bbe:	83 c2 01             	add    $0x1,%edx
  801bc1:	83 c1 01             	add    $0x1,%ecx
  801bc4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bc7:	39 c2                	cmp    %eax,%edx
  801bc9:	74 09                	je     801bd4 <strlcpy+0x32>
  801bcb:	0f b6 19             	movzbl (%ecx),%ebx
  801bce:	84 db                	test   %bl,%bl
  801bd0:	75 ec                	jne    801bbe <strlcpy+0x1c>
  801bd2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bd4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bd7:	29 f0                	sub    %esi,%eax
}
  801bd9:	5b                   	pop    %ebx
  801bda:	5e                   	pop    %esi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801be6:	eb 06                	jmp    801bee <strcmp+0x11>
		p++, q++;
  801be8:	83 c1 01             	add    $0x1,%ecx
  801beb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bee:	0f b6 01             	movzbl (%ecx),%eax
  801bf1:	84 c0                	test   %al,%al
  801bf3:	74 04                	je     801bf9 <strcmp+0x1c>
  801bf5:	3a 02                	cmp    (%edx),%al
  801bf7:	74 ef                	je     801be8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801bf9:	0f b6 c0             	movzbl %al,%eax
  801bfc:	0f b6 12             	movzbl (%edx),%edx
  801bff:	29 d0                	sub    %edx,%eax
}
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	53                   	push   %ebx
  801c07:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0d:	89 c3                	mov    %eax,%ebx
  801c0f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c12:	eb 06                	jmp    801c1a <strncmp+0x17>
		n--, p++, q++;
  801c14:	83 c0 01             	add    $0x1,%eax
  801c17:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c1a:	39 d8                	cmp    %ebx,%eax
  801c1c:	74 15                	je     801c33 <strncmp+0x30>
  801c1e:	0f b6 08             	movzbl (%eax),%ecx
  801c21:	84 c9                	test   %cl,%cl
  801c23:	74 04                	je     801c29 <strncmp+0x26>
  801c25:	3a 0a                	cmp    (%edx),%cl
  801c27:	74 eb                	je     801c14 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c29:	0f b6 00             	movzbl (%eax),%eax
  801c2c:	0f b6 12             	movzbl (%edx),%edx
  801c2f:	29 d0                	sub    %edx,%eax
  801c31:	eb 05                	jmp    801c38 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c33:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c38:	5b                   	pop    %ebx
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c45:	eb 07                	jmp    801c4e <strchr+0x13>
		if (*s == c)
  801c47:	38 ca                	cmp    %cl,%dl
  801c49:	74 0f                	je     801c5a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c4b:	83 c0 01             	add    $0x1,%eax
  801c4e:	0f b6 10             	movzbl (%eax),%edx
  801c51:	84 d2                	test   %dl,%dl
  801c53:	75 f2                	jne    801c47 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c62:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c66:	eb 03                	jmp    801c6b <strfind+0xf>
  801c68:	83 c0 01             	add    $0x1,%eax
  801c6b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c6e:	38 ca                	cmp    %cl,%dl
  801c70:	74 04                	je     801c76 <strfind+0x1a>
  801c72:	84 d2                	test   %dl,%dl
  801c74:	75 f2                	jne    801c68 <strfind+0xc>
			break;
	return (char *) s;
}
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    

00801c78 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	57                   	push   %edi
  801c7c:	56                   	push   %esi
  801c7d:	53                   	push   %ebx
  801c7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c81:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c84:	85 c9                	test   %ecx,%ecx
  801c86:	74 36                	je     801cbe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c88:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c8e:	75 28                	jne    801cb8 <memset+0x40>
  801c90:	f6 c1 03             	test   $0x3,%cl
  801c93:	75 23                	jne    801cb8 <memset+0x40>
		c &= 0xFF;
  801c95:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c99:	89 d3                	mov    %edx,%ebx
  801c9b:	c1 e3 08             	shl    $0x8,%ebx
  801c9e:	89 d6                	mov    %edx,%esi
  801ca0:	c1 e6 18             	shl    $0x18,%esi
  801ca3:	89 d0                	mov    %edx,%eax
  801ca5:	c1 e0 10             	shl    $0x10,%eax
  801ca8:	09 f0                	or     %esi,%eax
  801caa:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	09 d0                	or     %edx,%eax
  801cb0:	c1 e9 02             	shr    $0x2,%ecx
  801cb3:	fc                   	cld    
  801cb4:	f3 ab                	rep stos %eax,%es:(%edi)
  801cb6:	eb 06                	jmp    801cbe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbb:	fc                   	cld    
  801cbc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cbe:	89 f8                	mov    %edi,%eax
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	57                   	push   %edi
  801cc9:	56                   	push   %esi
  801cca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cd3:	39 c6                	cmp    %eax,%esi
  801cd5:	73 35                	jae    801d0c <memmove+0x47>
  801cd7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cda:	39 d0                	cmp    %edx,%eax
  801cdc:	73 2e                	jae    801d0c <memmove+0x47>
		s += n;
		d += n;
  801cde:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ce1:	89 d6                	mov    %edx,%esi
  801ce3:	09 fe                	or     %edi,%esi
  801ce5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801ceb:	75 13                	jne    801d00 <memmove+0x3b>
  801ced:	f6 c1 03             	test   $0x3,%cl
  801cf0:	75 0e                	jne    801d00 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801cf2:	83 ef 04             	sub    $0x4,%edi
  801cf5:	8d 72 fc             	lea    -0x4(%edx),%esi
  801cf8:	c1 e9 02             	shr    $0x2,%ecx
  801cfb:	fd                   	std    
  801cfc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cfe:	eb 09                	jmp    801d09 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d00:	83 ef 01             	sub    $0x1,%edi
  801d03:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d06:	fd                   	std    
  801d07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d09:	fc                   	cld    
  801d0a:	eb 1d                	jmp    801d29 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d0c:	89 f2                	mov    %esi,%edx
  801d0e:	09 c2                	or     %eax,%edx
  801d10:	f6 c2 03             	test   $0x3,%dl
  801d13:	75 0f                	jne    801d24 <memmove+0x5f>
  801d15:	f6 c1 03             	test   $0x3,%cl
  801d18:	75 0a                	jne    801d24 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d1a:	c1 e9 02             	shr    $0x2,%ecx
  801d1d:	89 c7                	mov    %eax,%edi
  801d1f:	fc                   	cld    
  801d20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d22:	eb 05                	jmp    801d29 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d24:	89 c7                	mov    %eax,%edi
  801d26:	fc                   	cld    
  801d27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d29:	5e                   	pop    %esi
  801d2a:	5f                   	pop    %edi
  801d2b:	5d                   	pop    %ebp
  801d2c:	c3                   	ret    

00801d2d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d30:	ff 75 10             	pushl  0x10(%ebp)
  801d33:	ff 75 0c             	pushl  0xc(%ebp)
  801d36:	ff 75 08             	pushl  0x8(%ebp)
  801d39:	e8 87 ff ff ff       	call   801cc5 <memmove>
}
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	56                   	push   %esi
  801d44:	53                   	push   %ebx
  801d45:	8b 45 08             	mov    0x8(%ebp),%eax
  801d48:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4b:	89 c6                	mov    %eax,%esi
  801d4d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d50:	eb 1a                	jmp    801d6c <memcmp+0x2c>
		if (*s1 != *s2)
  801d52:	0f b6 08             	movzbl (%eax),%ecx
  801d55:	0f b6 1a             	movzbl (%edx),%ebx
  801d58:	38 d9                	cmp    %bl,%cl
  801d5a:	74 0a                	je     801d66 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d5c:	0f b6 c1             	movzbl %cl,%eax
  801d5f:	0f b6 db             	movzbl %bl,%ebx
  801d62:	29 d8                	sub    %ebx,%eax
  801d64:	eb 0f                	jmp    801d75 <memcmp+0x35>
		s1++, s2++;
  801d66:	83 c0 01             	add    $0x1,%eax
  801d69:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d6c:	39 f0                	cmp    %esi,%eax
  801d6e:	75 e2                	jne    801d52 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d75:	5b                   	pop    %ebx
  801d76:	5e                   	pop    %esi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	53                   	push   %ebx
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d80:	89 c1                	mov    %eax,%ecx
  801d82:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d85:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d89:	eb 0a                	jmp    801d95 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d8b:	0f b6 10             	movzbl (%eax),%edx
  801d8e:	39 da                	cmp    %ebx,%edx
  801d90:	74 07                	je     801d99 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d92:	83 c0 01             	add    $0x1,%eax
  801d95:	39 c8                	cmp    %ecx,%eax
  801d97:	72 f2                	jb     801d8b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d99:	5b                   	pop    %ebx
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    

00801d9c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	57                   	push   %edi
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
  801da2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801da8:	eb 03                	jmp    801dad <strtol+0x11>
		s++;
  801daa:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dad:	0f b6 01             	movzbl (%ecx),%eax
  801db0:	3c 20                	cmp    $0x20,%al
  801db2:	74 f6                	je     801daa <strtol+0xe>
  801db4:	3c 09                	cmp    $0x9,%al
  801db6:	74 f2                	je     801daa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801db8:	3c 2b                	cmp    $0x2b,%al
  801dba:	75 0a                	jne    801dc6 <strtol+0x2a>
		s++;
  801dbc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dbf:	bf 00 00 00 00       	mov    $0x0,%edi
  801dc4:	eb 11                	jmp    801dd7 <strtol+0x3b>
  801dc6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dcb:	3c 2d                	cmp    $0x2d,%al
  801dcd:	75 08                	jne    801dd7 <strtol+0x3b>
		s++, neg = 1;
  801dcf:	83 c1 01             	add    $0x1,%ecx
  801dd2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dd7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ddd:	75 15                	jne    801df4 <strtol+0x58>
  801ddf:	80 39 30             	cmpb   $0x30,(%ecx)
  801de2:	75 10                	jne    801df4 <strtol+0x58>
  801de4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801de8:	75 7c                	jne    801e66 <strtol+0xca>
		s += 2, base = 16;
  801dea:	83 c1 02             	add    $0x2,%ecx
  801ded:	bb 10 00 00 00       	mov    $0x10,%ebx
  801df2:	eb 16                	jmp    801e0a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801df4:	85 db                	test   %ebx,%ebx
  801df6:	75 12                	jne    801e0a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801df8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801dfd:	80 39 30             	cmpb   $0x30,(%ecx)
  801e00:	75 08                	jne    801e0a <strtol+0x6e>
		s++, base = 8;
  801e02:	83 c1 01             	add    $0x1,%ecx
  801e05:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e12:	0f b6 11             	movzbl (%ecx),%edx
  801e15:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e18:	89 f3                	mov    %esi,%ebx
  801e1a:	80 fb 09             	cmp    $0x9,%bl
  801e1d:	77 08                	ja     801e27 <strtol+0x8b>
			dig = *s - '0';
  801e1f:	0f be d2             	movsbl %dl,%edx
  801e22:	83 ea 30             	sub    $0x30,%edx
  801e25:	eb 22                	jmp    801e49 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e27:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e2a:	89 f3                	mov    %esi,%ebx
  801e2c:	80 fb 19             	cmp    $0x19,%bl
  801e2f:	77 08                	ja     801e39 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e31:	0f be d2             	movsbl %dl,%edx
  801e34:	83 ea 57             	sub    $0x57,%edx
  801e37:	eb 10                	jmp    801e49 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e39:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e3c:	89 f3                	mov    %esi,%ebx
  801e3e:	80 fb 19             	cmp    $0x19,%bl
  801e41:	77 16                	ja     801e59 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e43:	0f be d2             	movsbl %dl,%edx
  801e46:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e49:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e4c:	7d 0b                	jge    801e59 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e4e:	83 c1 01             	add    $0x1,%ecx
  801e51:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e55:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e57:	eb b9                	jmp    801e12 <strtol+0x76>

	if (endptr)
  801e59:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e5d:	74 0d                	je     801e6c <strtol+0xd0>
		*endptr = (char *) s;
  801e5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e62:	89 0e                	mov    %ecx,(%esi)
  801e64:	eb 06                	jmp    801e6c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e66:	85 db                	test   %ebx,%ebx
  801e68:	74 98                	je     801e02 <strtol+0x66>
  801e6a:	eb 9e                	jmp    801e0a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e6c:	89 c2                	mov    %eax,%edx
  801e6e:	f7 da                	neg    %edx
  801e70:	85 ff                	test   %edi,%edi
  801e72:	0f 45 c2             	cmovne %edx,%eax
}
  801e75:	5b                   	pop    %ebx
  801e76:	5e                   	pop    %esi
  801e77:	5f                   	pop    %edi
  801e78:	5d                   	pop    %ebp
  801e79:	c3                   	ret    

00801e7a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	56                   	push   %esi
  801e7e:	53                   	push   %ebx
  801e7f:	8b 75 08             	mov    0x8(%ebp),%esi
  801e82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e88:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e8a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e8f:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	50                   	push   %eax
  801e96:	e8 96 e4 ff ff       	call   800331 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 f6                	test   %esi,%esi
  801ea0:	74 14                	je     801eb6 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ea2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 09                	js     801eb4 <ipc_recv+0x3a>
  801eab:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eb1:	8b 52 74             	mov    0x74(%edx),%edx
  801eb4:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801eb6:	85 db                	test   %ebx,%ebx
  801eb8:	74 14                	je     801ece <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801eba:	ba 00 00 00 00       	mov    $0x0,%edx
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 09                	js     801ecc <ipc_recv+0x52>
  801ec3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ec9:	8b 52 78             	mov    0x78(%edx),%edx
  801ecc:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	78 08                	js     801eda <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ed2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801edd:	5b                   	pop    %ebx
  801ede:	5e                   	pop    %esi
  801edf:	5d                   	pop    %ebp
  801ee0:	c3                   	ret    

00801ee1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	57                   	push   %edi
  801ee5:	56                   	push   %esi
  801ee6:	53                   	push   %ebx
  801ee7:	83 ec 0c             	sub    $0xc,%esp
  801eea:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eed:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ef3:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ef5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801efa:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801efd:	ff 75 14             	pushl  0x14(%ebp)
  801f00:	53                   	push   %ebx
  801f01:	56                   	push   %esi
  801f02:	57                   	push   %edi
  801f03:	e8 06 e4 ff ff       	call   80030e <sys_ipc_try_send>

		if (err < 0) {
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	79 1e                	jns    801f2d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f0f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f12:	75 07                	jne    801f1b <ipc_send+0x3a>
				sys_yield();
  801f14:	e8 49 e2 ff ff       	call   800162 <sys_yield>
  801f19:	eb e2                	jmp    801efd <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f1b:	50                   	push   %eax
  801f1c:	68 c0 26 80 00       	push   $0x8026c0
  801f21:	6a 49                	push   $0x49
  801f23:	68 cd 26 80 00       	push   $0x8026cd
  801f28:	e8 a8 f5 ff ff       	call   8014d5 <_panic>
		}

	} while (err < 0);

}
  801f2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f30:	5b                   	pop    %ebx
  801f31:	5e                   	pop    %esi
  801f32:	5f                   	pop    %edi
  801f33:	5d                   	pop    %ebp
  801f34:	c3                   	ret    

00801f35 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f3b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f40:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f43:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f49:	8b 52 50             	mov    0x50(%edx),%edx
  801f4c:	39 ca                	cmp    %ecx,%edx
  801f4e:	75 0d                	jne    801f5d <ipc_find_env+0x28>
			return envs[i].env_id;
  801f50:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f53:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f58:	8b 40 48             	mov    0x48(%eax),%eax
  801f5b:	eb 0f                	jmp    801f6c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f5d:	83 c0 01             	add    $0x1,%eax
  801f60:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f65:	75 d9                	jne    801f40 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f6c:	5d                   	pop    %ebp
  801f6d:	c3                   	ret    

00801f6e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f74:	89 d0                	mov    %edx,%eax
  801f76:	c1 e8 16             	shr    $0x16,%eax
  801f79:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f80:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f85:	f6 c1 01             	test   $0x1,%cl
  801f88:	74 1d                	je     801fa7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f8a:	c1 ea 0c             	shr    $0xc,%edx
  801f8d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f94:	f6 c2 01             	test   $0x1,%dl
  801f97:	74 0e                	je     801fa7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f99:	c1 ea 0c             	shr    $0xc,%edx
  801f9c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fa3:	ef 
  801fa4:	0f b7 c0             	movzwl %ax,%eax
}
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    
  801fa9:	66 90                	xchg   %ax,%ax
  801fab:	66 90                	xchg   %ax,%ax
  801fad:	66 90                	xchg   %ax,%ax
  801faf:	90                   	nop

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fcd:	89 ca                	mov    %ecx,%edx
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	75 3d                	jne    802010 <__udivdi3+0x60>
  801fd3:	39 cf                	cmp    %ecx,%edi
  801fd5:	0f 87 c5 00 00 00    	ja     8020a0 <__udivdi3+0xf0>
  801fdb:	85 ff                	test   %edi,%edi
  801fdd:	89 fd                	mov    %edi,%ebp
  801fdf:	75 0b                	jne    801fec <__udivdi3+0x3c>
  801fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe6:	31 d2                	xor    %edx,%edx
  801fe8:	f7 f7                	div    %edi
  801fea:	89 c5                	mov    %eax,%ebp
  801fec:	89 c8                	mov    %ecx,%eax
  801fee:	31 d2                	xor    %edx,%edx
  801ff0:	f7 f5                	div    %ebp
  801ff2:	89 c1                	mov    %eax,%ecx
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	89 cf                	mov    %ecx,%edi
  801ff8:	f7 f5                	div    %ebp
  801ffa:	89 c3                	mov    %eax,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	39 ce                	cmp    %ecx,%esi
  802012:	77 74                	ja     802088 <__udivdi3+0xd8>
  802014:	0f bd fe             	bsr    %esi,%edi
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	0f 84 98 00 00 00    	je     8020b8 <__udivdi3+0x108>
  802020:	bb 20 00 00 00       	mov    $0x20,%ebx
  802025:	89 f9                	mov    %edi,%ecx
  802027:	89 c5                	mov    %eax,%ebp
  802029:	29 fb                	sub    %edi,%ebx
  80202b:	d3 e6                	shl    %cl,%esi
  80202d:	89 d9                	mov    %ebx,%ecx
  80202f:	d3 ed                	shr    %cl,%ebp
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e0                	shl    %cl,%eax
  802035:	09 ee                	or     %ebp,%esi
  802037:	89 d9                	mov    %ebx,%ecx
  802039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203d:	89 d5                	mov    %edx,%ebp
  80203f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802043:	d3 ed                	shr    %cl,%ebp
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e2                	shl    %cl,%edx
  802049:	89 d9                	mov    %ebx,%ecx
  80204b:	d3 e8                	shr    %cl,%eax
  80204d:	09 c2                	or     %eax,%edx
  80204f:	89 d0                	mov    %edx,%eax
  802051:	89 ea                	mov    %ebp,%edx
  802053:	f7 f6                	div    %esi
  802055:	89 d5                	mov    %edx,%ebp
  802057:	89 c3                	mov    %eax,%ebx
  802059:	f7 64 24 0c          	mull   0xc(%esp)
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	72 10                	jb     802071 <__udivdi3+0xc1>
  802061:	8b 74 24 08          	mov    0x8(%esp),%esi
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e6                	shl    %cl,%esi
  802069:	39 c6                	cmp    %eax,%esi
  80206b:	73 07                	jae    802074 <__udivdi3+0xc4>
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	75 03                	jne    802074 <__udivdi3+0xc4>
  802071:	83 eb 01             	sub    $0x1,%ebx
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 d8                	mov    %ebx,%eax
  802078:	89 fa                	mov    %edi,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	31 ff                	xor    %edi,%edi
  80208a:	31 db                	xor    %ebx,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	f7 f7                	div    %edi
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 c3                	mov    %eax,%ebx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	39 ce                	cmp    %ecx,%esi
  8020ba:	72 0c                	jb     8020c8 <__udivdi3+0x118>
  8020bc:	31 db                	xor    %ebx,%ebx
  8020be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020c2:	0f 87 34 ff ff ff    	ja     801ffc <__udivdi3+0x4c>
  8020c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020cd:	e9 2a ff ff ff       	jmp    801ffc <__udivdi3+0x4c>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802101:	89 f3                	mov    %esi,%ebx
  802103:	89 3c 24             	mov    %edi,(%esp)
  802106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210a:	75 1c                	jne    802128 <__umoddi3+0x48>
  80210c:	39 f7                	cmp    %esi,%edi
  80210e:	76 50                	jbe    802160 <__umoddi3+0x80>
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	f7 f7                	div    %edi
  802116:	89 d0                	mov    %edx,%eax
  802118:	31 d2                	xor    %edx,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	39 f2                	cmp    %esi,%edx
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	77 52                	ja     802180 <__umoddi3+0xa0>
  80212e:	0f bd ea             	bsr    %edx,%ebp
  802131:	83 f5 1f             	xor    $0x1f,%ebp
  802134:	75 5a                	jne    802190 <__umoddi3+0xb0>
  802136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80213a:	0f 82 e0 00 00 00    	jb     802220 <__umoddi3+0x140>
  802140:	39 0c 24             	cmp    %ecx,(%esp)
  802143:	0f 86 d7 00 00 00    	jbe    802220 <__umoddi3+0x140>
  802149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80214d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	85 ff                	test   %edi,%edi
  802162:	89 fd                	mov    %edi,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x91>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f7                	div    %edi
  80216f:	89 c5                	mov    %eax,%ebp
  802171:	89 f0                	mov    %esi,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f5                	div    %ebp
  802177:	89 c8                	mov    %ecx,%eax
  802179:	f7 f5                	div    %ebp
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	eb 99                	jmp    802118 <__umoddi3+0x38>
  80217f:	90                   	nop
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	83 c4 1c             	add    $0x1c,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	8b 34 24             	mov    (%esp),%esi
  802193:	bf 20 00 00 00       	mov    $0x20,%edi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	29 ef                	sub    %ebp,%edi
  80219c:	d3 e0                	shl    %cl,%eax
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	d3 ea                	shr    %cl,%edx
  8021a4:	89 e9                	mov    %ebp,%ecx
  8021a6:	09 c2                	or     %eax,%edx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 14 24             	mov    %edx,(%esp)
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	d3 e2                	shl    %cl,%edx
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	89 c6                	mov    %eax,%esi
  8021c1:	d3 e3                	shl    %cl,%ebx
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	09 d8                	or     %ebx,%eax
  8021cd:	89 d3                	mov    %edx,%ebx
  8021cf:	89 f2                	mov    %esi,%edx
  8021d1:	f7 34 24             	divl   (%esp)
  8021d4:	89 d6                	mov    %edx,%esi
  8021d6:	d3 e3                	shl    %cl,%ebx
  8021d8:	f7 64 24 04          	mull   0x4(%esp)
  8021dc:	39 d6                	cmp    %edx,%esi
  8021de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e2:	89 d1                	mov    %edx,%ecx
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	72 08                	jb     8021f0 <__umoddi3+0x110>
  8021e8:	75 11                	jne    8021fb <__umoddi3+0x11b>
  8021ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ee:	73 0b                	jae    8021fb <__umoddi3+0x11b>
  8021f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021f4:	1b 14 24             	sbb    (%esp),%edx
  8021f7:	89 d1                	mov    %edx,%ecx
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ff:	29 da                	sub    %ebx,%edx
  802201:	19 ce                	sbb    %ecx,%esi
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 f0                	mov    %esi,%eax
  802207:	d3 e0                	shl    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	d3 ea                	shr    %cl,%edx
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	d3 ee                	shr    %cl,%esi
  802211:	09 d0                	or     %edx,%eax
  802213:	89 f2                	mov    %esi,%edx
  802215:	83 c4 1c             	add    $0x1c,%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5f                   	pop    %edi
  80221b:	5d                   	pop    %ebp
  80221c:	c3                   	ret    
  80221d:	8d 76 00             	lea    0x0(%esi),%esi
  802220:	29 f9                	sub    %edi,%ecx
  802222:	19 d6                	sbb    %edx,%esi
  802224:	89 74 24 04          	mov    %esi,0x4(%esp)
  802228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80222c:	e9 18 ff ff ff       	jmp    802149 <__umoddi3+0x69>
