
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 e8 04 00 00       	call   800572 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 6a 22 80 00       	push   $0x80226a
  800103:	6a 23                	push   $0x23
  800105:	68 87 22 80 00       	push   $0x802287
  80010a:	e8 dc 13 00 00       	call   8014eb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 6a 22 80 00       	push   $0x80226a
  800184:	6a 23                	push   $0x23
  800186:	68 87 22 80 00       	push   $0x802287
  80018b:	e8 5b 13 00 00       	call   8014eb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 6a 22 80 00       	push   $0x80226a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 87 22 80 00       	push   $0x802287
  8001cd:	e8 19 13 00 00       	call   8014eb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 6a 22 80 00       	push   $0x80226a
  800208:	6a 23                	push   $0x23
  80020a:	68 87 22 80 00       	push   $0x802287
  80020f:	e8 d7 12 00 00       	call   8014eb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 6a 22 80 00       	push   $0x80226a
  80024a:	6a 23                	push   $0x23
  80024c:	68 87 22 80 00       	push   $0x802287
  800251:	e8 95 12 00 00       	call   8014eb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 6a 22 80 00       	push   $0x80226a
  80028c:	6a 23                	push   $0x23
  80028e:	68 87 22 80 00       	push   $0x802287
  800293:	e8 53 12 00 00       	call   8014eb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 6a 22 80 00       	push   $0x80226a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 87 22 80 00       	push   $0x802287
  8002d5:	e8 11 12 00 00       	call   8014eb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 6a 22 80 00       	push   $0x80226a
  800332:	6a 23                	push   $0x23
  800334:	68 87 22 80 00       	push   $0x802287
  800339:	e8 ad 11 00 00       	call   8014eb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	b8 0e 00 00 00       	mov    $0xe,%eax
  800356:	89 d1                	mov    %edx,%ecx
  800358:	89 d3                	mov    %edx,%ebx
  80035a:	89 d7                	mov    %edx,%edi
  80035c:	89 d6                	mov    %edx,%esi
  80035e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	57                   	push   %edi
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
  80036b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800373:	b8 0f 00 00 00       	mov    $0xf,%eax
  800378:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037b:	8b 55 08             	mov    0x8(%ebp),%edx
  80037e:	89 df                	mov    %ebx,%edi
  800380:	89 de                	mov    %ebx,%esi
  800382:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800384:	85 c0                	test   %eax,%eax
  800386:	7e 17                	jle    80039f <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800388:	83 ec 0c             	sub    $0xc,%esp
  80038b:	50                   	push   %eax
  80038c:	6a 0f                	push   $0xf
  80038e:	68 6a 22 80 00       	push   $0x80226a
  800393:	6a 23                	push   $0x23
  800395:	68 87 22 80 00       	push   $0x802287
  80039a:	e8 4c 11 00 00       	call   8014eb <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  80039f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a2:	5b                   	pop    %ebx
  8003a3:	5e                   	pop    %esi
  8003a4:	5f                   	pop    %edi
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b2:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bd:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d9:	89 c2                	mov    %eax,%edx
  8003db:	c1 ea 16             	shr    $0x16,%edx
  8003de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e5:	f6 c2 01             	test   $0x1,%dl
  8003e8:	74 11                	je     8003fb <fd_alloc+0x2d>
  8003ea:	89 c2                	mov    %eax,%edx
  8003ec:	c1 ea 0c             	shr    $0xc,%edx
  8003ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f6:	f6 c2 01             	test   $0x1,%dl
  8003f9:	75 09                	jne    800404 <fd_alloc+0x36>
			*fd_store = fd;
  8003fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800402:	eb 17                	jmp    80041b <fd_alloc+0x4d>
  800404:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800409:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040e:	75 c9                	jne    8003d9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800410:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800416:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800423:	83 f8 1f             	cmp    $0x1f,%eax
  800426:	77 36                	ja     80045e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800428:	c1 e0 0c             	shl    $0xc,%eax
  80042b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800430:	89 c2                	mov    %eax,%edx
  800432:	c1 ea 16             	shr    $0x16,%edx
  800435:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043c:	f6 c2 01             	test   $0x1,%dl
  80043f:	74 24                	je     800465 <fd_lookup+0x48>
  800441:	89 c2                	mov    %eax,%edx
  800443:	c1 ea 0c             	shr    $0xc,%edx
  800446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044d:	f6 c2 01             	test   $0x1,%dl
  800450:	74 1a                	je     80046c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 02                	mov    %eax,(%edx)
	return 0;
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
  80045c:	eb 13                	jmp    800471 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800463:	eb 0c                	jmp    800471 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046a:	eb 05                	jmp    800471 <fd_lookup+0x54>
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800471:	5d                   	pop    %ebp
  800472:	c3                   	ret    

00800473 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047c:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800481:	eb 13                	jmp    800496 <dev_lookup+0x23>
  800483:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800486:	39 08                	cmp    %ecx,(%eax)
  800488:	75 0c                	jne    800496 <dev_lookup+0x23>
			*dev = devtab[i];
  80048a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	eb 2e                	jmp    8004c4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800496:	8b 02                	mov    (%edx),%eax
  800498:	85 c0                	test   %eax,%eax
  80049a:	75 e7                	jne    800483 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80049c:	a1 08 40 80 00       	mov    0x804008,%eax
  8004a1:	8b 40 48             	mov    0x48(%eax),%eax
  8004a4:	83 ec 04             	sub    $0x4,%esp
  8004a7:	51                   	push   %ecx
  8004a8:	50                   	push   %eax
  8004a9:	68 98 22 80 00       	push   $0x802298
  8004ae:	e8 11 11 00 00       	call   8015c4 <cprintf>
	*dev = 0;
  8004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004c4:	c9                   	leave  
  8004c5:	c3                   	ret    

008004c6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	56                   	push   %esi
  8004ca:	53                   	push   %ebx
  8004cb:	83 ec 10             	sub    $0x10,%esp
  8004ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d7:	50                   	push   %eax
  8004d8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004de:	c1 e8 0c             	shr    $0xc,%eax
  8004e1:	50                   	push   %eax
  8004e2:	e8 36 ff ff ff       	call   80041d <fd_lookup>
  8004e7:	83 c4 08             	add    $0x8,%esp
  8004ea:	85 c0                	test   %eax,%eax
  8004ec:	78 05                	js     8004f3 <fd_close+0x2d>
	    || fd != fd2)
  8004ee:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004f1:	74 0c                	je     8004ff <fd_close+0x39>
		return (must_exist ? r : 0);
  8004f3:	84 db                	test   %bl,%bl
  8004f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fa:	0f 44 c2             	cmove  %edx,%eax
  8004fd:	eb 41                	jmp    800540 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800505:	50                   	push   %eax
  800506:	ff 36                	pushl  (%esi)
  800508:	e8 66 ff ff ff       	call   800473 <dev_lookup>
  80050d:	89 c3                	mov    %eax,%ebx
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	85 c0                	test   %eax,%eax
  800514:	78 1a                	js     800530 <fd_close+0x6a>
		if (dev->dev_close)
  800516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800519:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80051c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800521:	85 c0                	test   %eax,%eax
  800523:	74 0b                	je     800530 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800525:	83 ec 0c             	sub    $0xc,%esp
  800528:	56                   	push   %esi
  800529:	ff d0                	call   *%eax
  80052b:	89 c3                	mov    %eax,%ebx
  80052d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	56                   	push   %esi
  800534:	6a 00                	push   $0x0
  800536:	e8 9f fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	89 d8                	mov    %ebx,%eax
}
  800540:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800543:	5b                   	pop    %ebx
  800544:	5e                   	pop    %esi
  800545:	5d                   	pop    %ebp
  800546:	c3                   	ret    

00800547 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800550:	50                   	push   %eax
  800551:	ff 75 08             	pushl  0x8(%ebp)
  800554:	e8 c4 fe ff ff       	call   80041d <fd_lookup>
  800559:	83 c4 08             	add    $0x8,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	78 10                	js     800570 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	6a 01                	push   $0x1
  800565:	ff 75 f4             	pushl  -0xc(%ebp)
  800568:	e8 59 ff ff ff       	call   8004c6 <fd_close>
  80056d:	83 c4 10             	add    $0x10,%esp
}
  800570:	c9                   	leave  
  800571:	c3                   	ret    

00800572 <close_all>:

void
close_all(void)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	53                   	push   %ebx
  800576:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800579:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057e:	83 ec 0c             	sub    $0xc,%esp
  800581:	53                   	push   %ebx
  800582:	e8 c0 ff ff ff       	call   800547 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800587:	83 c3 01             	add    $0x1,%ebx
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	83 fb 20             	cmp    $0x20,%ebx
  800590:	75 ec                	jne    80057e <close_all+0xc>
		close(i);
}
  800592:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	57                   	push   %edi
  80059b:	56                   	push   %esi
  80059c:	53                   	push   %ebx
  80059d:	83 ec 2c             	sub    $0x2c,%esp
  8005a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a6:	50                   	push   %eax
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 6e fe ff ff       	call   80041d <fd_lookup>
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	0f 88 c1 00 00 00    	js     80067b <dup+0xe4>
		return r;
	close(newfdnum);
  8005ba:	83 ec 0c             	sub    $0xc,%esp
  8005bd:	56                   	push   %esi
  8005be:	e8 84 ff ff ff       	call   800547 <close>

	newfd = INDEX2FD(newfdnum);
  8005c3:	89 f3                	mov    %esi,%ebx
  8005c5:	c1 e3 0c             	shl    $0xc,%ebx
  8005c8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ce:	83 c4 04             	add    $0x4,%esp
  8005d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d4:	e8 de fd ff ff       	call   8003b7 <fd2data>
  8005d9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005db:	89 1c 24             	mov    %ebx,(%esp)
  8005de:	e8 d4 fd ff ff       	call   8003b7 <fd2data>
  8005e3:	83 c4 10             	add    $0x10,%esp
  8005e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e9:	89 f8                	mov    %edi,%eax
  8005eb:	c1 e8 16             	shr    $0x16,%eax
  8005ee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f5:	a8 01                	test   $0x1,%al
  8005f7:	74 37                	je     800630 <dup+0x99>
  8005f9:	89 f8                	mov    %edi,%eax
  8005fb:	c1 e8 0c             	shr    $0xc,%eax
  8005fe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800605:	f6 c2 01             	test   $0x1,%dl
  800608:	74 26                	je     800630 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80060a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	25 07 0e 00 00       	and    $0xe07,%eax
  800619:	50                   	push   %eax
  80061a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061d:	6a 00                	push   $0x0
  80061f:	57                   	push   %edi
  800620:	6a 00                	push   $0x0
  800622:	e8 71 fb ff ff       	call   800198 <sys_page_map>
  800627:	89 c7                	mov    %eax,%edi
  800629:	83 c4 20             	add    $0x20,%esp
  80062c:	85 c0                	test   %eax,%eax
  80062e:	78 2e                	js     80065e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800633:	89 d0                	mov    %edx,%eax
  800635:	c1 e8 0c             	shr    $0xc,%eax
  800638:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063f:	83 ec 0c             	sub    $0xc,%esp
  800642:	25 07 0e 00 00       	and    $0xe07,%eax
  800647:	50                   	push   %eax
  800648:	53                   	push   %ebx
  800649:	6a 00                	push   $0x0
  80064b:	52                   	push   %edx
  80064c:	6a 00                	push   $0x0
  80064e:	e8 45 fb ff ff       	call   800198 <sys_page_map>
  800653:	89 c7                	mov    %eax,%edi
  800655:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800658:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80065a:	85 ff                	test   %edi,%edi
  80065c:	79 1d                	jns    80067b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 00                	push   $0x0
  800664:	e8 71 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800669:	83 c4 08             	add    $0x8,%esp
  80066c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066f:	6a 00                	push   $0x0
  800671:	e8 64 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	89 f8                	mov    %edi,%eax
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	5d                   	pop    %ebp
  800682:	c3                   	ret    

00800683 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	53                   	push   %ebx
  800687:	83 ec 14             	sub    $0x14,%esp
  80068a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800690:	50                   	push   %eax
  800691:	53                   	push   %ebx
  800692:	e8 86 fd ff ff       	call   80041d <fd_lookup>
  800697:	83 c4 08             	add    $0x8,%esp
  80069a:	89 c2                	mov    %eax,%edx
  80069c:	85 c0                	test   %eax,%eax
  80069e:	78 6d                	js     80070d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006aa:	ff 30                	pushl  (%eax)
  8006ac:	e8 c2 fd ff ff       	call   800473 <dev_lookup>
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	78 4c                	js     800704 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006bb:	8b 42 08             	mov    0x8(%edx),%eax
  8006be:	83 e0 03             	and    $0x3,%eax
  8006c1:	83 f8 01             	cmp    $0x1,%eax
  8006c4:	75 21                	jne    8006e7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c6:	a1 08 40 80 00       	mov    0x804008,%eax
  8006cb:	8b 40 48             	mov    0x48(%eax),%eax
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	50                   	push   %eax
  8006d3:	68 d9 22 80 00       	push   $0x8022d9
  8006d8:	e8 e7 0e 00 00       	call   8015c4 <cprintf>
		return -E_INVAL;
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006e5:	eb 26                	jmp    80070d <read+0x8a>
	}
	if (!dev->dev_read)
  8006e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ea:	8b 40 08             	mov    0x8(%eax),%eax
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 17                	je     800708 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006f1:	83 ec 04             	sub    $0x4,%esp
  8006f4:	ff 75 10             	pushl  0x10(%ebp)
  8006f7:	ff 75 0c             	pushl  0xc(%ebp)
  8006fa:	52                   	push   %edx
  8006fb:	ff d0                	call   *%eax
  8006fd:	89 c2                	mov    %eax,%edx
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	eb 09                	jmp    80070d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800704:	89 c2                	mov    %eax,%edx
  800706:	eb 05                	jmp    80070d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800708:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80070d:	89 d0                	mov    %edx,%eax
  80070f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	57                   	push   %edi
  800718:	56                   	push   %esi
  800719:	53                   	push   %ebx
  80071a:	83 ec 0c             	sub    $0xc,%esp
  80071d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800720:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800723:	bb 00 00 00 00       	mov    $0x0,%ebx
  800728:	eb 21                	jmp    80074b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80072a:	83 ec 04             	sub    $0x4,%esp
  80072d:	89 f0                	mov    %esi,%eax
  80072f:	29 d8                	sub    %ebx,%eax
  800731:	50                   	push   %eax
  800732:	89 d8                	mov    %ebx,%eax
  800734:	03 45 0c             	add    0xc(%ebp),%eax
  800737:	50                   	push   %eax
  800738:	57                   	push   %edi
  800739:	e8 45 ff ff ff       	call   800683 <read>
		if (m < 0)
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	85 c0                	test   %eax,%eax
  800743:	78 10                	js     800755 <readn+0x41>
			return m;
		if (m == 0)
  800745:	85 c0                	test   %eax,%eax
  800747:	74 0a                	je     800753 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800749:	01 c3                	add    %eax,%ebx
  80074b:	39 f3                	cmp    %esi,%ebx
  80074d:	72 db                	jb     80072a <readn+0x16>
  80074f:	89 d8                	mov    %ebx,%eax
  800751:	eb 02                	jmp    800755 <readn+0x41>
  800753:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800755:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5f                   	pop    %edi
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	53                   	push   %ebx
  800761:	83 ec 14             	sub    $0x14,%esp
  800764:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800767:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	53                   	push   %ebx
  80076c:	e8 ac fc ff ff       	call   80041d <fd_lookup>
  800771:	83 c4 08             	add    $0x8,%esp
  800774:	89 c2                	mov    %eax,%edx
  800776:	85 c0                	test   %eax,%eax
  800778:	78 68                	js     8007e2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077a:	83 ec 08             	sub    $0x8,%esp
  80077d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800784:	ff 30                	pushl  (%eax)
  800786:	e8 e8 fc ff ff       	call   800473 <dev_lookup>
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	85 c0                	test   %eax,%eax
  800790:	78 47                	js     8007d9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800795:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800799:	75 21                	jne    8007bc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80079b:	a1 08 40 80 00       	mov    0x804008,%eax
  8007a0:	8b 40 48             	mov    0x48(%eax),%eax
  8007a3:	83 ec 04             	sub    $0x4,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	50                   	push   %eax
  8007a8:	68 f5 22 80 00       	push   $0x8022f5
  8007ad:	e8 12 0e 00 00       	call   8015c4 <cprintf>
		return -E_INVAL;
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007ba:	eb 26                	jmp    8007e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	74 17                	je     8007dd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c6:	83 ec 04             	sub    $0x4,%esp
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	50                   	push   %eax
  8007d0:	ff d2                	call   *%edx
  8007d2:	89 c2                	mov    %eax,%edx
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb 09                	jmp    8007e2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	eb 05                	jmp    8007e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007e2:	89 d0                	mov    %edx,%eax
  8007e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007f2:	50                   	push   %eax
  8007f3:	ff 75 08             	pushl  0x8(%ebp)
  8007f6:	e8 22 fc ff ff       	call   80041d <fd_lookup>
  8007fb:	83 c4 08             	add    $0x8,%esp
  8007fe:	85 c0                	test   %eax,%eax
  800800:	78 0e                	js     800810 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800802:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
  800808:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	83 ec 14             	sub    $0x14,%esp
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	53                   	push   %ebx
  800821:	e8 f7 fb ff ff       	call   80041d <fd_lookup>
  800826:	83 c4 08             	add    $0x8,%esp
  800829:	89 c2                	mov    %eax,%edx
  80082b:	85 c0                	test   %eax,%eax
  80082d:	78 65                	js     800894 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800839:	ff 30                	pushl  (%eax)
  80083b:	e8 33 fc ff ff       	call   800473 <dev_lookup>
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	85 c0                	test   %eax,%eax
  800845:	78 44                	js     80088b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80084e:	75 21                	jne    800871 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800850:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800855:	8b 40 48             	mov    0x48(%eax),%eax
  800858:	83 ec 04             	sub    $0x4,%esp
  80085b:	53                   	push   %ebx
  80085c:	50                   	push   %eax
  80085d:	68 b8 22 80 00       	push   $0x8022b8
  800862:	e8 5d 0d 00 00       	call   8015c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80086f:	eb 23                	jmp    800894 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800871:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800874:	8b 52 18             	mov    0x18(%edx),%edx
  800877:	85 d2                	test   %edx,%edx
  800879:	74 14                	je     80088f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	ff 75 0c             	pushl  0xc(%ebp)
  800881:	50                   	push   %eax
  800882:	ff d2                	call   *%edx
  800884:	89 c2                	mov    %eax,%edx
  800886:	83 c4 10             	add    $0x10,%esp
  800889:	eb 09                	jmp    800894 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088b:	89 c2                	mov    %eax,%edx
  80088d:	eb 05                	jmp    800894 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80088f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800894:	89 d0                	mov    %edx,%eax
  800896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	83 ec 14             	sub    $0x14,%esp
  8008a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a8:	50                   	push   %eax
  8008a9:	ff 75 08             	pushl  0x8(%ebp)
  8008ac:	e8 6c fb ff ff       	call   80041d <fd_lookup>
  8008b1:	83 c4 08             	add    $0x8,%esp
  8008b4:	89 c2                	mov    %eax,%edx
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 58                	js     800912 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c0:	50                   	push   %eax
  8008c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c4:	ff 30                	pushl  (%eax)
  8008c6:	e8 a8 fb ff ff       	call   800473 <dev_lookup>
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	85 c0                	test   %eax,%eax
  8008d0:	78 37                	js     800909 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d9:	74 32                	je     80090d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008e5:	00 00 00 
	stat->st_isdir = 0;
  8008e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ef:	00 00 00 
	stat->st_dev = dev;
  8008f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ff:	ff 50 14             	call   *0x14(%eax)
  800902:	89 c2                	mov    %eax,%edx
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb 09                	jmp    800912 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800909:	89 c2                	mov    %eax,%edx
  80090b:	eb 05                	jmp    800912 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80090d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800912:	89 d0                	mov    %edx,%eax
  800914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800917:	c9                   	leave  
  800918:	c3                   	ret    

00800919 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	6a 00                	push   $0x0
  800923:	ff 75 08             	pushl  0x8(%ebp)
  800926:	e8 d6 01 00 00       	call   800b01 <open>
  80092b:	89 c3                	mov    %eax,%ebx
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	85 c0                	test   %eax,%eax
  800932:	78 1b                	js     80094f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800934:	83 ec 08             	sub    $0x8,%esp
  800937:	ff 75 0c             	pushl  0xc(%ebp)
  80093a:	50                   	push   %eax
  80093b:	e8 5b ff ff ff       	call   80089b <fstat>
  800940:	89 c6                	mov    %eax,%esi
	close(fd);
  800942:	89 1c 24             	mov    %ebx,(%esp)
  800945:	e8 fd fb ff ff       	call   800547 <close>
	return r;
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	89 f0                	mov    %esi,%eax
}
  80094f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	89 c6                	mov    %eax,%esi
  80095d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80095f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800966:	75 12                	jne    80097a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800968:	83 ec 0c             	sub    $0xc,%esp
  80096b:	6a 01                	push   $0x1
  80096d:	e8 d9 15 00 00       	call   801f4b <ipc_find_env>
  800972:	a3 00 40 80 00       	mov    %eax,0x804000
  800977:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80097a:	6a 07                	push   $0x7
  80097c:	68 00 50 80 00       	push   $0x805000
  800981:	56                   	push   %esi
  800982:	ff 35 00 40 80 00    	pushl  0x804000
  800988:	e8 6a 15 00 00       	call   801ef7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80098d:	83 c4 0c             	add    $0xc,%esp
  800990:	6a 00                	push   $0x0
  800992:	53                   	push   %ebx
  800993:	6a 00                	push   $0x0
  800995:	e8 f6 14 00 00       	call   801e90 <ipc_recv>
}
  80099a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8009c4:	e8 8d ff ff ff       	call   800956 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e6:	e8 6b ff ff ff       	call   800956 <fsipc>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	53                   	push   %ebx
  8009f1:	83 ec 04             	sub    $0x4,%esp
  8009f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	b8 05 00 00 00       	mov    $0x5,%eax
  800a0c:	e8 45 ff ff ff       	call   800956 <fsipc>
  800a11:	85 c0                	test   %eax,%eax
  800a13:	78 2c                	js     800a41 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	68 00 50 80 00       	push   $0x805000
  800a1d:	53                   	push   %ebx
  800a1e:	e8 26 11 00 00       	call   801b49 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a23:	a1 80 50 80 00       	mov    0x805080,%eax
  800a28:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a2e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a33:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	83 ec 0c             	sub    $0xc,%esp
  800a4c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a52:	8b 52 0c             	mov    0xc(%edx),%edx
  800a55:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a5b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a60:	50                   	push   %eax
  800a61:	ff 75 0c             	pushl  0xc(%ebp)
  800a64:	68 08 50 80 00       	push   $0x805008
  800a69:	e8 6d 12 00 00       	call   801cdb <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a73:	b8 04 00 00 00       	mov    $0x4,%eax
  800a78:	e8 d9 fe ff ff       	call   800956 <fsipc>

}
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a92:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa2:	e8 af fe ff ff       	call   800956 <fsipc>
  800aa7:	89 c3                	mov    %eax,%ebx
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	78 4b                	js     800af8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aad:	39 c6                	cmp    %eax,%esi
  800aaf:	73 16                	jae    800ac7 <devfile_read+0x48>
  800ab1:	68 28 23 80 00       	push   $0x802328
  800ab6:	68 2f 23 80 00       	push   $0x80232f
  800abb:	6a 7c                	push   $0x7c
  800abd:	68 44 23 80 00       	push   $0x802344
  800ac2:	e8 24 0a 00 00       	call   8014eb <_panic>
	assert(r <= PGSIZE);
  800ac7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acc:	7e 16                	jle    800ae4 <devfile_read+0x65>
  800ace:	68 4f 23 80 00       	push   $0x80234f
  800ad3:	68 2f 23 80 00       	push   $0x80232f
  800ad8:	6a 7d                	push   $0x7d
  800ada:	68 44 23 80 00       	push   $0x802344
  800adf:	e8 07 0a 00 00       	call   8014eb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae4:	83 ec 04             	sub    $0x4,%esp
  800ae7:	50                   	push   %eax
  800ae8:	68 00 50 80 00       	push   $0x805000
  800aed:	ff 75 0c             	pushl  0xc(%ebp)
  800af0:	e8 e6 11 00 00       	call   801cdb <memmove>
	return r;
  800af5:	83 c4 10             	add    $0x10,%esp
}
  800af8:	89 d8                	mov    %ebx,%eax
  800afa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	53                   	push   %ebx
  800b05:	83 ec 20             	sub    $0x20,%esp
  800b08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0b:	53                   	push   %ebx
  800b0c:	e8 ff 0f 00 00       	call   801b10 <strlen>
  800b11:	83 c4 10             	add    $0x10,%esp
  800b14:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b19:	7f 67                	jg     800b82 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1b:	83 ec 0c             	sub    $0xc,%esp
  800b1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b21:	50                   	push   %eax
  800b22:	e8 a7 f8 ff ff       	call   8003ce <fd_alloc>
  800b27:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2c:	85 c0                	test   %eax,%eax
  800b2e:	78 57                	js     800b87 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b30:	83 ec 08             	sub    $0x8,%esp
  800b33:	53                   	push   %ebx
  800b34:	68 00 50 80 00       	push   $0x805000
  800b39:	e8 0b 10 00 00       	call   801b49 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b49:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4e:	e8 03 fe ff ff       	call   800956 <fsipc>
  800b53:	89 c3                	mov    %eax,%ebx
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	79 14                	jns    800b70 <open+0x6f>
		fd_close(fd, 0);
  800b5c:	83 ec 08             	sub    $0x8,%esp
  800b5f:	6a 00                	push   $0x0
  800b61:	ff 75 f4             	pushl  -0xc(%ebp)
  800b64:	e8 5d f9 ff ff       	call   8004c6 <fd_close>
		return r;
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	89 da                	mov    %ebx,%edx
  800b6e:	eb 17                	jmp    800b87 <open+0x86>
	}

	return fd2num(fd);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	ff 75 f4             	pushl  -0xc(%ebp)
  800b76:	e8 2c f8 ff ff       	call   8003a7 <fd2num>
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	83 c4 10             	add    $0x10,%esp
  800b80:	eb 05                	jmp    800b87 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b82:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b87:	89 d0                	mov    %edx,%eax
  800b89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
  800b99:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9e:	e8 b3 fd ff ff       	call   800956 <fsipc>
}
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bab:	68 5b 23 80 00       	push   $0x80235b
  800bb0:	ff 75 0c             	pushl  0xc(%ebp)
  800bb3:	e8 91 0f 00 00       	call   801b49 <strcpy>
	return 0;
}
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 10             	sub    $0x10,%esp
  800bc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc9:	53                   	push   %ebx
  800bca:	e8 b5 13 00 00       	call   801f84 <pageref>
  800bcf:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd7:	83 f8 01             	cmp    $0x1,%eax
  800bda:	75 10                	jne    800bec <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	ff 73 0c             	pushl  0xc(%ebx)
  800be2:	e8 c0 02 00 00       	call   800ea7 <nsipc_close>
  800be7:	89 c2                	mov    %eax,%edx
  800be9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bec:	89 d0                	mov    %edx,%eax
  800bee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf1:	c9                   	leave  
  800bf2:	c3                   	ret    

00800bf3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf9:	6a 00                	push   $0x0
  800bfb:	ff 75 10             	pushl  0x10(%ebp)
  800bfe:	ff 75 0c             	pushl  0xc(%ebp)
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	ff 70 0c             	pushl  0xc(%eax)
  800c07:	e8 78 03 00 00       	call   800f84 <nsipc_send>
}
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c14:	6a 00                	push   $0x0
  800c16:	ff 75 10             	pushl  0x10(%ebp)
  800c19:	ff 75 0c             	pushl  0xc(%ebp)
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	ff 70 0c             	pushl  0xc(%eax)
  800c22:	e8 f1 02 00 00       	call   800f18 <nsipc_recv>
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c32:	52                   	push   %edx
  800c33:	50                   	push   %eax
  800c34:	e8 e4 f7 ff ff       	call   80041d <fd_lookup>
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	78 17                	js     800c57 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c43:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c49:	39 08                	cmp    %ecx,(%eax)
  800c4b:	75 05                	jne    800c52 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c4d:	8b 40 0c             	mov    0xc(%eax),%eax
  800c50:	eb 05                	jmp    800c57 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c52:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c57:	c9                   	leave  
  800c58:	c3                   	ret    

00800c59 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 1c             	sub    $0x1c,%esp
  800c61:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c66:	50                   	push   %eax
  800c67:	e8 62 f7 ff ff       	call   8003ce <fd_alloc>
  800c6c:	89 c3                	mov    %eax,%ebx
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	85 c0                	test   %eax,%eax
  800c73:	78 1b                	js     800c90 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c75:	83 ec 04             	sub    $0x4,%esp
  800c78:	68 07 04 00 00       	push   $0x407
  800c7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800c80:	6a 00                	push   $0x0
  800c82:	e8 ce f4 ff ff       	call   800155 <sys_page_alloc>
  800c87:	89 c3                	mov    %eax,%ebx
  800c89:	83 c4 10             	add    $0x10,%esp
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	79 10                	jns    800ca0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	56                   	push   %esi
  800c94:	e8 0e 02 00 00       	call   800ea7 <nsipc_close>
		return r;
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	89 d8                	mov    %ebx,%eax
  800c9e:	eb 24                	jmp    800cc4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ca0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	e8 e6 f6 ff ff       	call   8003a7 <fd2num>
  800cc1:	83 c4 10             	add    $0x10,%esp
}
  800cc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	e8 50 ff ff ff       	call   800c29 <fd2sockid>
		return r;
  800cd9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	78 1f                	js     800cfe <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cdf:	83 ec 04             	sub    $0x4,%esp
  800ce2:	ff 75 10             	pushl  0x10(%ebp)
  800ce5:	ff 75 0c             	pushl  0xc(%ebp)
  800ce8:	50                   	push   %eax
  800ce9:	e8 12 01 00 00       	call   800e00 <nsipc_accept>
  800cee:	83 c4 10             	add    $0x10,%esp
		return r;
  800cf1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	78 07                	js     800cfe <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf7:	e8 5d ff ff ff       	call   800c59 <alloc_sockfd>
  800cfc:	89 c1                	mov    %eax,%ecx
}
  800cfe:	89 c8                	mov    %ecx,%eax
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	e8 19 ff ff ff       	call   800c29 <fd2sockid>
  800d10:	85 c0                	test   %eax,%eax
  800d12:	78 12                	js     800d26 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d14:	83 ec 04             	sub    $0x4,%esp
  800d17:	ff 75 10             	pushl  0x10(%ebp)
  800d1a:	ff 75 0c             	pushl  0xc(%ebp)
  800d1d:	50                   	push   %eax
  800d1e:	e8 2d 01 00 00       	call   800e50 <nsipc_bind>
  800d23:	83 c4 10             	add    $0x10,%esp
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <shutdown>:

int
shutdown(int s, int how)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	e8 f3 fe ff ff       	call   800c29 <fd2sockid>
  800d36:	85 c0                	test   %eax,%eax
  800d38:	78 0f                	js     800d49 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d3a:	83 ec 08             	sub    $0x8,%esp
  800d3d:	ff 75 0c             	pushl  0xc(%ebp)
  800d40:	50                   	push   %eax
  800d41:	e8 3f 01 00 00       	call   800e85 <nsipc_shutdown>
  800d46:	83 c4 10             	add    $0x10,%esp
}
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    

00800d4b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	e8 d0 fe ff ff       	call   800c29 <fd2sockid>
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	78 12                	js     800d6f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d5d:	83 ec 04             	sub    $0x4,%esp
  800d60:	ff 75 10             	pushl  0x10(%ebp)
  800d63:	ff 75 0c             	pushl  0xc(%ebp)
  800d66:	50                   	push   %eax
  800d67:	e8 55 01 00 00       	call   800ec1 <nsipc_connect>
  800d6c:	83 c4 10             	add    $0x10,%esp
}
  800d6f:	c9                   	leave  
  800d70:	c3                   	ret    

00800d71 <listen>:

int
listen(int s, int backlog)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7a:	e8 aa fe ff ff       	call   800c29 <fd2sockid>
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	78 0f                	js     800d92 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d83:	83 ec 08             	sub    $0x8,%esp
  800d86:	ff 75 0c             	pushl  0xc(%ebp)
  800d89:	50                   	push   %eax
  800d8a:	e8 67 01 00 00       	call   800ef6 <nsipc_listen>
  800d8f:	83 c4 10             	add    $0x10,%esp
}
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d9a:	ff 75 10             	pushl  0x10(%ebp)
  800d9d:	ff 75 0c             	pushl  0xc(%ebp)
  800da0:	ff 75 08             	pushl  0x8(%ebp)
  800da3:	e8 3a 02 00 00       	call   800fe2 <nsipc_socket>
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	78 05                	js     800db4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800daf:	e8 a5 fe ff ff       	call   800c59 <alloc_sockfd>
}
  800db4:	c9                   	leave  
  800db5:	c3                   	ret    

00800db6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	53                   	push   %ebx
  800dba:	83 ec 04             	sub    $0x4,%esp
  800dbd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dbf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc6:	75 12                	jne    800dda <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	6a 02                	push   $0x2
  800dcd:	e8 79 11 00 00       	call   801f4b <ipc_find_env>
  800dd2:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dda:	6a 07                	push   $0x7
  800ddc:	68 00 60 80 00       	push   $0x806000
  800de1:	53                   	push   %ebx
  800de2:	ff 35 04 40 80 00    	pushl  0x804004
  800de8:	e8 0a 11 00 00       	call   801ef7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800ded:	83 c4 0c             	add    $0xc,%esp
  800df0:	6a 00                	push   $0x0
  800df2:	6a 00                	push   $0x0
  800df4:	6a 00                	push   $0x0
  800df6:	e8 95 10 00 00       	call   801e90 <ipc_recv>
}
  800dfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    

00800e00 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e10:	8b 06                	mov    (%esi),%eax
  800e12:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e17:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1c:	e8 95 ff ff ff       	call   800db6 <nsipc>
  800e21:	89 c3                	mov    %eax,%ebx
  800e23:	85 c0                	test   %eax,%eax
  800e25:	78 20                	js     800e47 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	ff 35 10 60 80 00    	pushl  0x806010
  800e30:	68 00 60 80 00       	push   $0x806000
  800e35:	ff 75 0c             	pushl  0xc(%ebp)
  800e38:	e8 9e 0e 00 00       	call   801cdb <memmove>
		*addrlen = ret->ret_addrlen;
  800e3d:	a1 10 60 80 00       	mov    0x806010,%eax
  800e42:	89 06                	mov    %eax,(%esi)
  800e44:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e47:	89 d8                	mov    %ebx,%eax
  800e49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	53                   	push   %ebx
  800e54:	83 ec 08             	sub    $0x8,%esp
  800e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e62:	53                   	push   %ebx
  800e63:	ff 75 0c             	pushl  0xc(%ebp)
  800e66:	68 04 60 80 00       	push   $0x806004
  800e6b:	e8 6b 0e 00 00       	call   801cdb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e70:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e76:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7b:	e8 36 ff ff ff       	call   800db6 <nsipc>
}
  800e80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e96:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea0:	e8 11 ff ff ff       	call   800db6 <nsipc>
}
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb5:	b8 04 00 00 00       	mov    $0x4,%eax
  800eba:	e8 f7 fe ff ff       	call   800db6 <nsipc>
}
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	53                   	push   %ebx
  800ec5:	83 ec 08             	sub    $0x8,%esp
  800ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ece:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed3:	53                   	push   %ebx
  800ed4:	ff 75 0c             	pushl  0xc(%ebp)
  800ed7:	68 04 60 80 00       	push   $0x806004
  800edc:	e8 fa 0d 00 00       	call   801cdb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee7:	b8 05 00 00 00       	mov    $0x5,%eax
  800eec:	e8 c5 fe ff ff       	call   800db6 <nsipc>
}
  800ef1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f07:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f11:	e8 a0 fe ff ff       	call   800db6 <nsipc>
}
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    

00800f18 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f20:	8b 45 08             	mov    0x8(%ebp),%eax
  800f23:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f28:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f31:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f36:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3b:	e8 76 fe ff ff       	call   800db6 <nsipc>
  800f40:	89 c3                	mov    %eax,%ebx
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 35                	js     800f7b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f46:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f4b:	7f 04                	jg     800f51 <nsipc_recv+0x39>
  800f4d:	39 c6                	cmp    %eax,%esi
  800f4f:	7d 16                	jge    800f67 <nsipc_recv+0x4f>
  800f51:	68 67 23 80 00       	push   $0x802367
  800f56:	68 2f 23 80 00       	push   $0x80232f
  800f5b:	6a 62                	push   $0x62
  800f5d:	68 7c 23 80 00       	push   $0x80237c
  800f62:	e8 84 05 00 00       	call   8014eb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f67:	83 ec 04             	sub    $0x4,%esp
  800f6a:	50                   	push   %eax
  800f6b:	68 00 60 80 00       	push   $0x806000
  800f70:	ff 75 0c             	pushl  0xc(%ebp)
  800f73:	e8 63 0d 00 00       	call   801cdb <memmove>
  800f78:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	53                   	push   %ebx
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f96:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f9c:	7e 16                	jle    800fb4 <nsipc_send+0x30>
  800f9e:	68 88 23 80 00       	push   $0x802388
  800fa3:	68 2f 23 80 00       	push   $0x80232f
  800fa8:	6a 6d                	push   $0x6d
  800faa:	68 7c 23 80 00       	push   $0x80237c
  800faf:	e8 37 05 00 00       	call   8014eb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	53                   	push   %ebx
  800fb8:	ff 75 0c             	pushl  0xc(%ebp)
  800fbb:	68 0c 60 80 00       	push   $0x80600c
  800fc0:	e8 16 0d 00 00       	call   801cdb <memmove>
	nsipcbuf.send.req_size = size;
  800fc5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fcb:	8b 45 14             	mov    0x14(%ebp),%eax
  800fce:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd3:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd8:	e8 d9 fd ff ff       	call   800db6 <nsipc>
}
  800fdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  800feb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801000:	b8 09 00 00 00       	mov    $0x9,%eax
  801005:	e8 ac fd ff ff       	call   800db6 <nsipc>
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	ff 75 08             	pushl  0x8(%ebp)
  80101a:	e8 98 f3 ff ff       	call   8003b7 <fd2data>
  80101f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801021:	83 c4 08             	add    $0x8,%esp
  801024:	68 94 23 80 00       	push   $0x802394
  801029:	53                   	push   %ebx
  80102a:	e8 1a 0b 00 00       	call   801b49 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102f:	8b 46 04             	mov    0x4(%esi),%eax
  801032:	2b 06                	sub    (%esi),%eax
  801034:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801041:	00 00 00 
	stat->st_dev = &devpipe;
  801044:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80104b:	30 80 00 
	return 0;
}
  80104e:	b8 00 00 00 00       	mov    $0x0,%eax
  801053:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801064:	53                   	push   %ebx
  801065:	6a 00                	push   $0x0
  801067:	e8 6e f1 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106c:	89 1c 24             	mov    %ebx,(%esp)
  80106f:	e8 43 f3 ff ff       	call   8003b7 <fd2data>
  801074:	83 c4 08             	add    $0x8,%esp
  801077:	50                   	push   %eax
  801078:	6a 00                	push   $0x0
  80107a:	e8 5b f1 ff ff       	call   8001da <sys_page_unmap>
}
  80107f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
  80108a:	83 ec 1c             	sub    $0x1c,%esp
  80108d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801090:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801092:	a1 08 40 80 00       	mov    0x804008,%eax
  801097:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a0:	e8 df 0e 00 00       	call   801f84 <pageref>
  8010a5:	89 c3                	mov    %eax,%ebx
  8010a7:	89 3c 24             	mov    %edi,(%esp)
  8010aa:	e8 d5 0e 00 00       	call   801f84 <pageref>
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	39 c3                	cmp    %eax,%ebx
  8010b4:	0f 94 c1             	sete   %cl
  8010b7:	0f b6 c9             	movzbl %cl,%ecx
  8010ba:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010bd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010c3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c6:	39 ce                	cmp    %ecx,%esi
  8010c8:	74 1b                	je     8010e5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010ca:	39 c3                	cmp    %eax,%ebx
  8010cc:	75 c4                	jne    801092 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010ce:	8b 42 58             	mov    0x58(%edx),%eax
  8010d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d4:	50                   	push   %eax
  8010d5:	56                   	push   %esi
  8010d6:	68 9b 23 80 00       	push   $0x80239b
  8010db:	e8 e4 04 00 00       	call   8015c4 <cprintf>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	eb ad                	jmp    801092 <_pipeisclosed+0xe>
	}
}
  8010e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 28             	sub    $0x28,%esp
  8010f9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010fc:	56                   	push   %esi
  8010fd:	e8 b5 f2 ff ff       	call   8003b7 <fd2data>
  801102:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	bf 00 00 00 00       	mov    $0x0,%edi
  80110c:	eb 4b                	jmp    801159 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80110e:	89 da                	mov    %ebx,%edx
  801110:	89 f0                	mov    %esi,%eax
  801112:	e8 6d ff ff ff       	call   801084 <_pipeisclosed>
  801117:	85 c0                	test   %eax,%eax
  801119:	75 48                	jne    801163 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80111b:	e8 16 f0 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801120:	8b 43 04             	mov    0x4(%ebx),%eax
  801123:	8b 0b                	mov    (%ebx),%ecx
  801125:	8d 51 20             	lea    0x20(%ecx),%edx
  801128:	39 d0                	cmp    %edx,%eax
  80112a:	73 e2                	jae    80110e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801133:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801136:	89 c2                	mov    %eax,%edx
  801138:	c1 fa 1f             	sar    $0x1f,%edx
  80113b:	89 d1                	mov    %edx,%ecx
  80113d:	c1 e9 1b             	shr    $0x1b,%ecx
  801140:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801143:	83 e2 1f             	and    $0x1f,%edx
  801146:	29 ca                	sub    %ecx,%edx
  801148:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80114c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801150:	83 c0 01             	add    $0x1,%eax
  801153:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801156:	83 c7 01             	add    $0x1,%edi
  801159:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80115c:	75 c2                	jne    801120 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80115e:	8b 45 10             	mov    0x10(%ebp),%eax
  801161:	eb 05                	jmp    801168 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801163:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801168:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116b:	5b                   	pop    %ebx
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 18             	sub    $0x18,%esp
  801179:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80117c:	57                   	push   %edi
  80117d:	e8 35 f2 ff ff       	call   8003b7 <fd2data>
  801182:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118c:	eb 3d                	jmp    8011cb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80118e:	85 db                	test   %ebx,%ebx
  801190:	74 04                	je     801196 <devpipe_read+0x26>
				return i;
  801192:	89 d8                	mov    %ebx,%eax
  801194:	eb 44                	jmp    8011da <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801196:	89 f2                	mov    %esi,%edx
  801198:	89 f8                	mov    %edi,%eax
  80119a:	e8 e5 fe ff ff       	call   801084 <_pipeisclosed>
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	75 32                	jne    8011d5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011a3:	e8 8e ef ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a8:	8b 06                	mov    (%esi),%eax
  8011aa:	3b 46 04             	cmp    0x4(%esi),%eax
  8011ad:	74 df                	je     80118e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011af:	99                   	cltd   
  8011b0:	c1 ea 1b             	shr    $0x1b,%edx
  8011b3:	01 d0                	add    %edx,%eax
  8011b5:	83 e0 1f             	and    $0x1f,%eax
  8011b8:	29 d0                	sub    %edx,%eax
  8011ba:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c8:	83 c3 01             	add    $0x1,%ebx
  8011cb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011ce:	75 d8                	jne    8011a8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d3:	eb 05                	jmp    8011da <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	e8 db f1 ff ff       	call   8003ce <fd_alloc>
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	0f 88 2c 01 00 00    	js     80132c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	68 07 04 00 00       	push   $0x407
  801208:	ff 75 f4             	pushl  -0xc(%ebp)
  80120b:	6a 00                	push   $0x0
  80120d:	e8 43 ef ff ff       	call   800155 <sys_page_alloc>
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	89 c2                	mov    %eax,%edx
  801217:	85 c0                	test   %eax,%eax
  801219:	0f 88 0d 01 00 00    	js     80132c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	e8 a3 f1 ff ff       	call   8003ce <fd_alloc>
  80122b:	89 c3                	mov    %eax,%ebx
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	0f 88 e2 00 00 00    	js     80131a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	68 07 04 00 00       	push   $0x407
  801240:	ff 75 f0             	pushl  -0x10(%ebp)
  801243:	6a 00                	push   $0x0
  801245:	e8 0b ef ff ff       	call   800155 <sys_page_alloc>
  80124a:	89 c3                	mov    %eax,%ebx
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	0f 88 c3 00 00 00    	js     80131a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	ff 75 f4             	pushl  -0xc(%ebp)
  80125d:	e8 55 f1 ff ff       	call   8003b7 <fd2data>
  801262:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801264:	83 c4 0c             	add    $0xc,%esp
  801267:	68 07 04 00 00       	push   $0x407
  80126c:	50                   	push   %eax
  80126d:	6a 00                	push   $0x0
  80126f:	e8 e1 ee ff ff       	call   800155 <sys_page_alloc>
  801274:	89 c3                	mov    %eax,%ebx
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	0f 88 89 00 00 00    	js     80130a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	ff 75 f0             	pushl  -0x10(%ebp)
  801287:	e8 2b f1 ff ff       	call   8003b7 <fd2data>
  80128c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801293:	50                   	push   %eax
  801294:	6a 00                	push   $0x0
  801296:	56                   	push   %esi
  801297:	6a 00                	push   $0x0
  801299:	e8 fa ee ff ff       	call   800198 <sys_page_map>
  80129e:	89 c3                	mov    %eax,%ebx
  8012a0:	83 c4 20             	add    $0x20,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 55                	js     8012fc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012bc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d7:	e8 cb f0 ff ff       	call   8003a7 <fd2num>
  8012dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012df:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e1:	83 c4 04             	add    $0x4,%esp
  8012e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e7:	e8 bb f0 ff ff       	call   8003a7 <fd2num>
  8012ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ef:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fa:	eb 30                	jmp    80132c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012fc:	83 ec 08             	sub    $0x8,%esp
  8012ff:	56                   	push   %esi
  801300:	6a 00                	push   $0x0
  801302:	e8 d3 ee ff ff       	call   8001da <sys_page_unmap>
  801307:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	ff 75 f0             	pushl  -0x10(%ebp)
  801310:	6a 00                	push   $0x0
  801312:	e8 c3 ee ff ff       	call   8001da <sys_page_unmap>
  801317:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	ff 75 f4             	pushl  -0xc(%ebp)
  801320:	6a 00                	push   $0x0
  801322:	e8 b3 ee ff ff       	call   8001da <sys_page_unmap>
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80132c:	89 d0                	mov    %edx,%eax
  80132e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	ff 75 08             	pushl  0x8(%ebp)
  801342:	e8 d6 f0 ff ff       	call   80041d <fd_lookup>
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	85 c0                	test   %eax,%eax
  80134c:	78 18                	js     801366 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	ff 75 f4             	pushl  -0xc(%ebp)
  801354:	e8 5e f0 ff ff       	call   8003b7 <fd2data>
	return _pipeisclosed(fd, p);
  801359:	89 c2                	mov    %eax,%edx
  80135b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135e:	e8 21 fd ff ff       	call   801084 <_pipeisclosed>
  801363:	83 c4 10             	add    $0x10,%esp
}
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80136b:	b8 00 00 00 00       	mov    $0x0,%eax
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801378:	68 b3 23 80 00       	push   $0x8023b3
  80137d:	ff 75 0c             	pushl  0xc(%ebp)
  801380:	e8 c4 07 00 00       	call   801b49 <strcpy>
	return 0;
}
  801385:	b8 00 00 00 00       	mov    $0x0,%eax
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	57                   	push   %edi
  801390:	56                   	push   %esi
  801391:	53                   	push   %ebx
  801392:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801398:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a3:	eb 2d                	jmp    8013d2 <devcons_write+0x46>
		m = n - tot;
  8013a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013aa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013ad:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013b2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	03 45 0c             	add    0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	57                   	push   %edi
  8013be:	e8 18 09 00 00       	call   801cdb <memmove>
		sys_cputs(buf, m);
  8013c3:	83 c4 08             	add    $0x8,%esp
  8013c6:	53                   	push   %ebx
  8013c7:	57                   	push   %edi
  8013c8:	e8 cc ec ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013cd:	01 de                	add    %ebx,%esi
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	89 f0                	mov    %esi,%eax
  8013d4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d7:	72 cc                	jb     8013a5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5f                   	pop    %edi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f0:	74 2a                	je     80141c <devcons_read+0x3b>
  8013f2:	eb 05                	jmp    8013f9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f4:	e8 3d ed ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f9:	e8 b9 ec ff ff       	call   8000b7 <sys_cgetc>
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 f2                	je     8013f4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801402:	85 c0                	test   %eax,%eax
  801404:	78 16                	js     80141c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801406:	83 f8 04             	cmp    $0x4,%eax
  801409:	74 0c                	je     801417 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80140b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140e:	88 02                	mov    %al,(%edx)
	return 1;
  801410:	b8 01 00 00 00       	mov    $0x1,%eax
  801415:	eb 05                	jmp    80141c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80142a:	6a 01                	push   $0x1
  80142c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	e8 64 ec ff ff       	call   800099 <sys_cputs>
}
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <getchar>:

int
getchar(void)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801440:	6a 01                	push   $0x1
  801442:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	6a 00                	push   $0x0
  801448:	e8 36 f2 ff ff       	call   800683 <read>
	if (r < 0)
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	85 c0                	test   %eax,%eax
  801452:	78 0f                	js     801463 <getchar+0x29>
		return r;
	if (r < 1)
  801454:	85 c0                	test   %eax,%eax
  801456:	7e 06                	jle    80145e <getchar+0x24>
		return -E_EOF;
	return c;
  801458:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80145c:	eb 05                	jmp    801463 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80145e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	ff 75 08             	pushl  0x8(%ebp)
  801472:	e8 a6 ef ff ff       	call   80041d <fd_lookup>
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 11                	js     80148f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80147e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801481:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801487:	39 10                	cmp    %edx,(%eax)
  801489:	0f 94 c0             	sete   %al
  80148c:	0f b6 c0             	movzbl %al,%eax
}
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <opencons>:

int
opencons(void)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	e8 2e ef ff ff       	call   8003ce <fd_alloc>
  8014a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 3e                	js     8014e7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a9:	83 ec 04             	sub    $0x4,%esp
  8014ac:	68 07 04 00 00       	push   $0x407
  8014b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b4:	6a 00                	push   $0x0
  8014b6:	e8 9a ec ff ff       	call   800155 <sys_page_alloc>
  8014bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8014be:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 23                	js     8014e7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	50                   	push   %eax
  8014dd:	e8 c5 ee ff ff       	call   8003a7 <fd2num>
  8014e2:	89 c2                	mov    %eax,%edx
  8014e4:	83 c4 10             	add    $0x10,%esp
}
  8014e7:	89 d0                	mov    %edx,%eax
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f9:	e8 19 ec ff ff       	call   800117 <sys_getenvid>
  8014fe:	83 ec 0c             	sub    $0xc,%esp
  801501:	ff 75 0c             	pushl  0xc(%ebp)
  801504:	ff 75 08             	pushl  0x8(%ebp)
  801507:	56                   	push   %esi
  801508:	50                   	push   %eax
  801509:	68 c0 23 80 00       	push   $0x8023c0
  80150e:	e8 b1 00 00 00       	call   8015c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801513:	83 c4 18             	add    $0x18,%esp
  801516:	53                   	push   %ebx
  801517:	ff 75 10             	pushl  0x10(%ebp)
  80151a:	e8 54 00 00 00       	call   801573 <vcprintf>
	cprintf("\n");
  80151f:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  801526:	e8 99 00 00 00       	call   8015c4 <cprintf>
  80152b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80152e:	cc                   	int3   
  80152f:	eb fd                	jmp    80152e <_panic+0x43>

00801531 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80153b:	8b 13                	mov    (%ebx),%edx
  80153d:	8d 42 01             	lea    0x1(%edx),%eax
  801540:	89 03                	mov    %eax,(%ebx)
  801542:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801545:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801549:	3d ff 00 00 00       	cmp    $0xff,%eax
  80154e:	75 1a                	jne    80156a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	68 ff 00 00 00       	push   $0xff
  801558:	8d 43 08             	lea    0x8(%ebx),%eax
  80155b:	50                   	push   %eax
  80155c:	e8 38 eb ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  801561:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801567:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80156a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80156e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80157c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801583:	00 00 00 
	b.cnt = 0;
  801586:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80158d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801590:	ff 75 0c             	pushl  0xc(%ebp)
  801593:	ff 75 08             	pushl  0x8(%ebp)
  801596:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	68 31 15 80 00       	push   $0x801531
  8015a2:	e8 54 01 00 00       	call   8016fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	e8 dd ea ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  8015bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015cd:	50                   	push   %eax
  8015ce:	ff 75 08             	pushl  0x8(%ebp)
  8015d1:	e8 9d ff ff ff       	call   801573 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	57                   	push   %edi
  8015dc:	56                   	push   %esi
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 1c             	sub    $0x1c,%esp
  8015e1:	89 c7                	mov    %eax,%edi
  8015e3:	89 d6                	mov    %edx,%esi
  8015e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015fc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015ff:	39 d3                	cmp    %edx,%ebx
  801601:	72 05                	jb     801608 <printnum+0x30>
  801603:	39 45 10             	cmp    %eax,0x10(%ebp)
  801606:	77 45                	ja     80164d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801608:	83 ec 0c             	sub    $0xc,%esp
  80160b:	ff 75 18             	pushl  0x18(%ebp)
  80160e:	8b 45 14             	mov    0x14(%ebp),%eax
  801611:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801614:	53                   	push   %ebx
  801615:	ff 75 10             	pushl  0x10(%ebp)
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161e:	ff 75 e0             	pushl  -0x20(%ebp)
  801621:	ff 75 dc             	pushl  -0x24(%ebp)
  801624:	ff 75 d8             	pushl  -0x28(%ebp)
  801627:	e8 94 09 00 00       	call   801fc0 <__udivdi3>
  80162c:	83 c4 18             	add    $0x18,%esp
  80162f:	52                   	push   %edx
  801630:	50                   	push   %eax
  801631:	89 f2                	mov    %esi,%edx
  801633:	89 f8                	mov    %edi,%eax
  801635:	e8 9e ff ff ff       	call   8015d8 <printnum>
  80163a:	83 c4 20             	add    $0x20,%esp
  80163d:	eb 18                	jmp    801657 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	56                   	push   %esi
  801643:	ff 75 18             	pushl  0x18(%ebp)
  801646:	ff d7                	call   *%edi
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 03                	jmp    801650 <printnum+0x78>
  80164d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801650:	83 eb 01             	sub    $0x1,%ebx
  801653:	85 db                	test   %ebx,%ebx
  801655:	7f e8                	jg     80163f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	56                   	push   %esi
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801661:	ff 75 e0             	pushl  -0x20(%ebp)
  801664:	ff 75 dc             	pushl  -0x24(%ebp)
  801667:	ff 75 d8             	pushl  -0x28(%ebp)
  80166a:	e8 81 0a 00 00       	call   8020f0 <__umoddi3>
  80166f:	83 c4 14             	add    $0x14,%esp
  801672:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801679:	50                   	push   %eax
  80167a:	ff d7                	call   *%edi
}
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5f                   	pop    %edi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80168a:	83 fa 01             	cmp    $0x1,%edx
  80168d:	7e 0e                	jle    80169d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80168f:	8b 10                	mov    (%eax),%edx
  801691:	8d 4a 08             	lea    0x8(%edx),%ecx
  801694:	89 08                	mov    %ecx,(%eax)
  801696:	8b 02                	mov    (%edx),%eax
  801698:	8b 52 04             	mov    0x4(%edx),%edx
  80169b:	eb 22                	jmp    8016bf <getuint+0x38>
	else if (lflag)
  80169d:	85 d2                	test   %edx,%edx
  80169f:	74 10                	je     8016b1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016a1:	8b 10                	mov    (%eax),%edx
  8016a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a6:	89 08                	mov    %ecx,(%eax)
  8016a8:	8b 02                	mov    (%edx),%eax
  8016aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016af:	eb 0e                	jmp    8016bf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016b1:	8b 10                	mov    (%eax),%edx
  8016b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b6:	89 08                	mov    %ecx,(%eax)
  8016b8:	8b 02                	mov    (%edx),%eax
  8016ba:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016c7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016cb:	8b 10                	mov    (%eax),%edx
  8016cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8016d0:	73 0a                	jae    8016dc <sprintputch+0x1b>
		*b->buf++ = ch;
  8016d2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016d5:	89 08                	mov    %ecx,(%eax)
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	88 02                	mov    %al,(%edx)
}
  8016dc:	5d                   	pop    %ebp
  8016dd:	c3                   	ret    

008016de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016e7:	50                   	push   %eax
  8016e8:	ff 75 10             	pushl  0x10(%ebp)
  8016eb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ee:	ff 75 08             	pushl  0x8(%ebp)
  8016f1:	e8 05 00 00 00       	call   8016fb <vprintfmt>
	va_end(ap);
}
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	57                   	push   %edi
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	83 ec 2c             	sub    $0x2c,%esp
  801704:	8b 75 08             	mov    0x8(%ebp),%esi
  801707:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80170d:	eb 12                	jmp    801721 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80170f:	85 c0                	test   %eax,%eax
  801711:	0f 84 89 03 00 00    	je     801aa0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	53                   	push   %ebx
  80171b:	50                   	push   %eax
  80171c:	ff d6                	call   *%esi
  80171e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801721:	83 c7 01             	add    $0x1,%edi
  801724:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801728:	83 f8 25             	cmp    $0x25,%eax
  80172b:	75 e2                	jne    80170f <vprintfmt+0x14>
  80172d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801731:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801738:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80173f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801746:	ba 00 00 00 00       	mov    $0x0,%edx
  80174b:	eb 07                	jmp    801754 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801750:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801754:	8d 47 01             	lea    0x1(%edi),%eax
  801757:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80175a:	0f b6 07             	movzbl (%edi),%eax
  80175d:	0f b6 c8             	movzbl %al,%ecx
  801760:	83 e8 23             	sub    $0x23,%eax
  801763:	3c 55                	cmp    $0x55,%al
  801765:	0f 87 1a 03 00 00    	ja     801a85 <vprintfmt+0x38a>
  80176b:	0f b6 c0             	movzbl %al,%eax
  80176e:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801778:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80177c:	eb d6                	jmp    801754 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801781:	b8 00 00 00 00       	mov    $0x0,%eax
  801786:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801789:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80178c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801790:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801793:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801796:	83 fa 09             	cmp    $0x9,%edx
  801799:	77 39                	ja     8017d4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80179b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80179e:	eb e9                	jmp    801789 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a3:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017a9:	8b 00                	mov    (%eax),%eax
  8017ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017b1:	eb 27                	jmp    8017da <vprintfmt+0xdf>
  8017b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017bd:	0f 49 c8             	cmovns %eax,%ecx
  8017c0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c6:	eb 8c                	jmp    801754 <vprintfmt+0x59>
  8017c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017cb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017d2:	eb 80                	jmp    801754 <vprintfmt+0x59>
  8017d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017de:	0f 89 70 ff ff ff    	jns    801754 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017f1:	e9 5e ff ff ff       	jmp    801754 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017fc:	e9 53 ff ff ff       	jmp    801754 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801801:	8b 45 14             	mov    0x14(%ebp),%eax
  801804:	8d 50 04             	lea    0x4(%eax),%edx
  801807:	89 55 14             	mov    %edx,0x14(%ebp)
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	53                   	push   %ebx
  80180e:	ff 30                	pushl  (%eax)
  801810:	ff d6                	call   *%esi
			break;
  801812:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801815:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801818:	e9 04 ff ff ff       	jmp    801721 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80181d:	8b 45 14             	mov    0x14(%ebp),%eax
  801820:	8d 50 04             	lea    0x4(%eax),%edx
  801823:	89 55 14             	mov    %edx,0x14(%ebp)
  801826:	8b 00                	mov    (%eax),%eax
  801828:	99                   	cltd   
  801829:	31 d0                	xor    %edx,%eax
  80182b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80182d:	83 f8 0f             	cmp    $0xf,%eax
  801830:	7f 0b                	jg     80183d <vprintfmt+0x142>
  801832:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801839:	85 d2                	test   %edx,%edx
  80183b:	75 18                	jne    801855 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80183d:	50                   	push   %eax
  80183e:	68 fb 23 80 00       	push   $0x8023fb
  801843:	53                   	push   %ebx
  801844:	56                   	push   %esi
  801845:	e8 94 fe ff ff       	call   8016de <printfmt>
  80184a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801850:	e9 cc fe ff ff       	jmp    801721 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801855:	52                   	push   %edx
  801856:	68 41 23 80 00       	push   $0x802341
  80185b:	53                   	push   %ebx
  80185c:	56                   	push   %esi
  80185d:	e8 7c fe ff ff       	call   8016de <printfmt>
  801862:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801865:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801868:	e9 b4 fe ff ff       	jmp    801721 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80186d:	8b 45 14             	mov    0x14(%ebp),%eax
  801870:	8d 50 04             	lea    0x4(%eax),%edx
  801873:	89 55 14             	mov    %edx,0x14(%ebp)
  801876:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801878:	85 ff                	test   %edi,%edi
  80187a:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80187f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801882:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801886:	0f 8e 94 00 00 00    	jle    801920 <vprintfmt+0x225>
  80188c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801890:	0f 84 98 00 00 00    	je     80192e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801896:	83 ec 08             	sub    $0x8,%esp
  801899:	ff 75 d0             	pushl  -0x30(%ebp)
  80189c:	57                   	push   %edi
  80189d:	e8 86 02 00 00       	call   801b28 <strnlen>
  8018a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a5:	29 c1                	sub    %eax,%ecx
  8018a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018aa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018ad:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b9:	eb 0f                	jmp    8018ca <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	53                   	push   %ebx
  8018bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c4:	83 ef 01             	sub    $0x1,%edi
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	85 ff                	test   %edi,%edi
  8018cc:	7f ed                	jg     8018bb <vprintfmt+0x1c0>
  8018ce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018d4:	85 c9                	test   %ecx,%ecx
  8018d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018db:	0f 49 c1             	cmovns %ecx,%eax
  8018de:	29 c1                	sub    %eax,%ecx
  8018e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e9:	89 cb                	mov    %ecx,%ebx
  8018eb:	eb 4d                	jmp    80193a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018f1:	74 1b                	je     80190e <vprintfmt+0x213>
  8018f3:	0f be c0             	movsbl %al,%eax
  8018f6:	83 e8 20             	sub    $0x20,%eax
  8018f9:	83 f8 5e             	cmp    $0x5e,%eax
  8018fc:	76 10                	jbe    80190e <vprintfmt+0x213>
					putch('?', putdat);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	ff 75 0c             	pushl  0xc(%ebp)
  801904:	6a 3f                	push   $0x3f
  801906:	ff 55 08             	call   *0x8(%ebp)
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	eb 0d                	jmp    80191b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80190e:	83 ec 08             	sub    $0x8,%esp
  801911:	ff 75 0c             	pushl  0xc(%ebp)
  801914:	52                   	push   %edx
  801915:	ff 55 08             	call   *0x8(%ebp)
  801918:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80191b:	83 eb 01             	sub    $0x1,%ebx
  80191e:	eb 1a                	jmp    80193a <vprintfmt+0x23f>
  801920:	89 75 08             	mov    %esi,0x8(%ebp)
  801923:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801926:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801929:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80192c:	eb 0c                	jmp    80193a <vprintfmt+0x23f>
  80192e:	89 75 08             	mov    %esi,0x8(%ebp)
  801931:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801934:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801937:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80193a:	83 c7 01             	add    $0x1,%edi
  80193d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801941:	0f be d0             	movsbl %al,%edx
  801944:	85 d2                	test   %edx,%edx
  801946:	74 23                	je     80196b <vprintfmt+0x270>
  801948:	85 f6                	test   %esi,%esi
  80194a:	78 a1                	js     8018ed <vprintfmt+0x1f2>
  80194c:	83 ee 01             	sub    $0x1,%esi
  80194f:	79 9c                	jns    8018ed <vprintfmt+0x1f2>
  801951:	89 df                	mov    %ebx,%edi
  801953:	8b 75 08             	mov    0x8(%ebp),%esi
  801956:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801959:	eb 18                	jmp    801973 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80195b:	83 ec 08             	sub    $0x8,%esp
  80195e:	53                   	push   %ebx
  80195f:	6a 20                	push   $0x20
  801961:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801963:	83 ef 01             	sub    $0x1,%edi
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	eb 08                	jmp    801973 <vprintfmt+0x278>
  80196b:	89 df                	mov    %ebx,%edi
  80196d:	8b 75 08             	mov    0x8(%ebp),%esi
  801970:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801973:	85 ff                	test   %edi,%edi
  801975:	7f e4                	jg     80195b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801977:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80197a:	e9 a2 fd ff ff       	jmp    801721 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80197f:	83 fa 01             	cmp    $0x1,%edx
  801982:	7e 16                	jle    80199a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801984:	8b 45 14             	mov    0x14(%ebp),%eax
  801987:	8d 50 08             	lea    0x8(%eax),%edx
  80198a:	89 55 14             	mov    %edx,0x14(%ebp)
  80198d:	8b 50 04             	mov    0x4(%eax),%edx
  801990:	8b 00                	mov    (%eax),%eax
  801992:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801995:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801998:	eb 32                	jmp    8019cc <vprintfmt+0x2d1>
	else if (lflag)
  80199a:	85 d2                	test   %edx,%edx
  80199c:	74 18                	je     8019b6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80199e:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a1:	8d 50 04             	lea    0x4(%eax),%edx
  8019a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a7:	8b 00                	mov    (%eax),%eax
  8019a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ac:	89 c1                	mov    %eax,%ecx
  8019ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b4:	eb 16                	jmp    8019cc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b9:	8d 50 04             	lea    0x4(%eax),%edx
  8019bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8019bf:	8b 00                	mov    (%eax),%eax
  8019c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c4:	89 c1                	mov    %eax,%ecx
  8019c6:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019db:	79 74                	jns    801a51 <vprintfmt+0x356>
				putch('-', putdat);
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	53                   	push   %ebx
  8019e1:	6a 2d                	push   $0x2d
  8019e3:	ff d6                	call   *%esi
				num = -(long long) num;
  8019e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019eb:	f7 d8                	neg    %eax
  8019ed:	83 d2 00             	adc    $0x0,%edx
  8019f0:	f7 da                	neg    %edx
  8019f2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019fa:	eb 55                	jmp    801a51 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8019ff:	e8 83 fc ff ff       	call   801687 <getuint>
			base = 10;
  801a04:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a09:	eb 46                	jmp    801a51 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a0b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0e:	e8 74 fc ff ff       	call   801687 <getuint>
			base = 8;
  801a13:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a18:	eb 37                	jmp    801a51 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a1a:	83 ec 08             	sub    $0x8,%esp
  801a1d:	53                   	push   %ebx
  801a1e:	6a 30                	push   $0x30
  801a20:	ff d6                	call   *%esi
			putch('x', putdat);
  801a22:	83 c4 08             	add    $0x8,%esp
  801a25:	53                   	push   %ebx
  801a26:	6a 78                	push   $0x78
  801a28:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2d:	8d 50 04             	lea    0x4(%eax),%edx
  801a30:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a33:	8b 00                	mov    (%eax),%eax
  801a35:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a3a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a3d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a42:	eb 0d                	jmp    801a51 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a44:	8d 45 14             	lea    0x14(%ebp),%eax
  801a47:	e8 3b fc ff ff       	call   801687 <getuint>
			base = 16;
  801a4c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a58:	57                   	push   %edi
  801a59:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5c:	51                   	push   %ecx
  801a5d:	52                   	push   %edx
  801a5e:	50                   	push   %eax
  801a5f:	89 da                	mov    %ebx,%edx
  801a61:	89 f0                	mov    %esi,%eax
  801a63:	e8 70 fb ff ff       	call   8015d8 <printnum>
			break;
  801a68:	83 c4 20             	add    $0x20,%esp
  801a6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a6e:	e9 ae fc ff ff       	jmp    801721 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a73:	83 ec 08             	sub    $0x8,%esp
  801a76:	53                   	push   %ebx
  801a77:	51                   	push   %ecx
  801a78:	ff d6                	call   *%esi
			break;
  801a7a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a80:	e9 9c fc ff ff       	jmp    801721 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a85:	83 ec 08             	sub    $0x8,%esp
  801a88:	53                   	push   %ebx
  801a89:	6a 25                	push   $0x25
  801a8b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	eb 03                	jmp    801a95 <vprintfmt+0x39a>
  801a92:	83 ef 01             	sub    $0x1,%edi
  801a95:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a99:	75 f7                	jne    801a92 <vprintfmt+0x397>
  801a9b:	e9 81 fc ff ff       	jmp    801721 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5f                   	pop    %edi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    

00801aa8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 18             	sub    $0x18,%esp
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801abb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801abe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	74 26                	je     801aef <vsnprintf+0x47>
  801ac9:	85 d2                	test   %edx,%edx
  801acb:	7e 22                	jle    801aef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801acd:	ff 75 14             	pushl  0x14(%ebp)
  801ad0:	ff 75 10             	pushl  0x10(%ebp)
  801ad3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad6:	50                   	push   %eax
  801ad7:	68 c1 16 80 00       	push   $0x8016c1
  801adc:	e8 1a fc ff ff       	call   8016fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	eb 05                	jmp    801af4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801afc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801aff:	50                   	push   %eax
  801b00:	ff 75 10             	pushl  0x10(%ebp)
  801b03:	ff 75 0c             	pushl  0xc(%ebp)
  801b06:	ff 75 08             	pushl  0x8(%ebp)
  801b09:	e8 9a ff ff ff       	call   801aa8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b16:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1b:	eb 03                	jmp    801b20 <strlen+0x10>
		n++;
  801b1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b24:	75 f7                	jne    801b1d <strlen+0xd>
		n++;
	return n;
}
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b31:	ba 00 00 00 00       	mov    $0x0,%edx
  801b36:	eb 03                	jmp    801b3b <strnlen+0x13>
		n++;
  801b38:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3b:	39 c2                	cmp    %eax,%edx
  801b3d:	74 08                	je     801b47 <strnlen+0x1f>
  801b3f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b43:	75 f3                	jne    801b38 <strnlen+0x10>
  801b45:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	53                   	push   %ebx
  801b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b53:	89 c2                	mov    %eax,%edx
  801b55:	83 c2 01             	add    $0x1,%edx
  801b58:	83 c1 01             	add    $0x1,%ecx
  801b5b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b5f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b62:	84 db                	test   %bl,%bl
  801b64:	75 ef                	jne    801b55 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b66:	5b                   	pop    %ebx
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	53                   	push   %ebx
  801b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b70:	53                   	push   %ebx
  801b71:	e8 9a ff ff ff       	call   801b10 <strlen>
  801b76:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b79:	ff 75 0c             	pushl  0xc(%ebp)
  801b7c:	01 d8                	add    %ebx,%eax
  801b7e:	50                   	push   %eax
  801b7f:	e8 c5 ff ff ff       	call   801b49 <strcpy>
	return dst;
}
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	8b 75 08             	mov    0x8(%ebp),%esi
  801b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b96:	89 f3                	mov    %esi,%ebx
  801b98:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b9b:	89 f2                	mov    %esi,%edx
  801b9d:	eb 0f                	jmp    801bae <strncpy+0x23>
		*dst++ = *src;
  801b9f:	83 c2 01             	add    $0x1,%edx
  801ba2:	0f b6 01             	movzbl (%ecx),%eax
  801ba5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba8:	80 39 01             	cmpb   $0x1,(%ecx)
  801bab:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bae:	39 da                	cmp    %ebx,%edx
  801bb0:	75 ed                	jne    801b9f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bb2:	89 f0                	mov    %esi,%eax
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc3:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc8:	85 d2                	test   %edx,%edx
  801bca:	74 21                	je     801bed <strlcpy+0x35>
  801bcc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd0:	89 f2                	mov    %esi,%edx
  801bd2:	eb 09                	jmp    801bdd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd4:	83 c2 01             	add    $0x1,%edx
  801bd7:	83 c1 01             	add    $0x1,%ecx
  801bda:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bdd:	39 c2                	cmp    %eax,%edx
  801bdf:	74 09                	je     801bea <strlcpy+0x32>
  801be1:	0f b6 19             	movzbl (%ecx),%ebx
  801be4:	84 db                	test   %bl,%bl
  801be6:	75 ec                	jne    801bd4 <strlcpy+0x1c>
  801be8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bed:	29 f0                	sub    %esi,%eax
}
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bfc:	eb 06                	jmp    801c04 <strcmp+0x11>
		p++, q++;
  801bfe:	83 c1 01             	add    $0x1,%ecx
  801c01:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c04:	0f b6 01             	movzbl (%ecx),%eax
  801c07:	84 c0                	test   %al,%al
  801c09:	74 04                	je     801c0f <strcmp+0x1c>
  801c0b:	3a 02                	cmp    (%edx),%al
  801c0d:	74 ef                	je     801bfe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c0f:	0f b6 c0             	movzbl %al,%eax
  801c12:	0f b6 12             	movzbl (%edx),%edx
  801c15:	29 d0                	sub    %edx,%eax
}
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	53                   	push   %ebx
  801c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c20:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c28:	eb 06                	jmp    801c30 <strncmp+0x17>
		n--, p++, q++;
  801c2a:	83 c0 01             	add    $0x1,%eax
  801c2d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c30:	39 d8                	cmp    %ebx,%eax
  801c32:	74 15                	je     801c49 <strncmp+0x30>
  801c34:	0f b6 08             	movzbl (%eax),%ecx
  801c37:	84 c9                	test   %cl,%cl
  801c39:	74 04                	je     801c3f <strncmp+0x26>
  801c3b:	3a 0a                	cmp    (%edx),%cl
  801c3d:	74 eb                	je     801c2a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3f:	0f b6 00             	movzbl (%eax),%eax
  801c42:	0f b6 12             	movzbl (%edx),%edx
  801c45:	29 d0                	sub    %edx,%eax
  801c47:	eb 05                	jmp    801c4e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c49:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c4e:	5b                   	pop    %ebx
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	8b 45 08             	mov    0x8(%ebp),%eax
  801c57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c5b:	eb 07                	jmp    801c64 <strchr+0x13>
		if (*s == c)
  801c5d:	38 ca                	cmp    %cl,%dl
  801c5f:	74 0f                	je     801c70 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c61:	83 c0 01             	add    $0x1,%eax
  801c64:	0f b6 10             	movzbl (%eax),%edx
  801c67:	84 d2                	test   %dl,%dl
  801c69:	75 f2                	jne    801c5d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    

00801c72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	8b 45 08             	mov    0x8(%ebp),%eax
  801c78:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c7c:	eb 03                	jmp    801c81 <strfind+0xf>
  801c7e:	83 c0 01             	add    $0x1,%eax
  801c81:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c84:	38 ca                	cmp    %cl,%dl
  801c86:	74 04                	je     801c8c <strfind+0x1a>
  801c88:	84 d2                	test   %dl,%dl
  801c8a:	75 f2                	jne    801c7e <strfind+0xc>
			break;
	return (char *) s;
}
  801c8c:	5d                   	pop    %ebp
  801c8d:	c3                   	ret    

00801c8e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c9a:	85 c9                	test   %ecx,%ecx
  801c9c:	74 36                	je     801cd4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca4:	75 28                	jne    801cce <memset+0x40>
  801ca6:	f6 c1 03             	test   $0x3,%cl
  801ca9:	75 23                	jne    801cce <memset+0x40>
		c &= 0xFF;
  801cab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801caf:	89 d3                	mov    %edx,%ebx
  801cb1:	c1 e3 08             	shl    $0x8,%ebx
  801cb4:	89 d6                	mov    %edx,%esi
  801cb6:	c1 e6 18             	shl    $0x18,%esi
  801cb9:	89 d0                	mov    %edx,%eax
  801cbb:	c1 e0 10             	shl    $0x10,%eax
  801cbe:	09 f0                	or     %esi,%eax
  801cc0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cc2:	89 d8                	mov    %ebx,%eax
  801cc4:	09 d0                	or     %edx,%eax
  801cc6:	c1 e9 02             	shr    $0x2,%ecx
  801cc9:	fc                   	cld    
  801cca:	f3 ab                	rep stos %eax,%es:(%edi)
  801ccc:	eb 06                	jmp    801cd4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd1:	fc                   	cld    
  801cd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd4:	89 f8                	mov    %edi,%eax
  801cd6:	5b                   	pop    %ebx
  801cd7:	5e                   	pop    %esi
  801cd8:	5f                   	pop    %edi
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	57                   	push   %edi
  801cdf:	56                   	push   %esi
  801ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce9:	39 c6                	cmp    %eax,%esi
  801ceb:	73 35                	jae    801d22 <memmove+0x47>
  801ced:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf0:	39 d0                	cmp    %edx,%eax
  801cf2:	73 2e                	jae    801d22 <memmove+0x47>
		s += n;
		d += n;
  801cf4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf7:	89 d6                	mov    %edx,%esi
  801cf9:	09 fe                	or     %edi,%esi
  801cfb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d01:	75 13                	jne    801d16 <memmove+0x3b>
  801d03:	f6 c1 03             	test   $0x3,%cl
  801d06:	75 0e                	jne    801d16 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d08:	83 ef 04             	sub    $0x4,%edi
  801d0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d0e:	c1 e9 02             	shr    $0x2,%ecx
  801d11:	fd                   	std    
  801d12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d14:	eb 09                	jmp    801d1f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d16:	83 ef 01             	sub    $0x1,%edi
  801d19:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d1c:	fd                   	std    
  801d1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d1f:	fc                   	cld    
  801d20:	eb 1d                	jmp    801d3f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	09 c2                	or     %eax,%edx
  801d26:	f6 c2 03             	test   $0x3,%dl
  801d29:	75 0f                	jne    801d3a <memmove+0x5f>
  801d2b:	f6 c1 03             	test   $0x3,%cl
  801d2e:	75 0a                	jne    801d3a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d30:	c1 e9 02             	shr    $0x2,%ecx
  801d33:	89 c7                	mov    %eax,%edi
  801d35:	fc                   	cld    
  801d36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d38:	eb 05                	jmp    801d3f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d3a:	89 c7                	mov    %eax,%edi
  801d3c:	fc                   	cld    
  801d3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d46:	ff 75 10             	pushl  0x10(%ebp)
  801d49:	ff 75 0c             	pushl  0xc(%ebp)
  801d4c:	ff 75 08             	pushl  0x8(%ebp)
  801d4f:	e8 87 ff ff ff       	call   801cdb <memmove>
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	56                   	push   %esi
  801d5a:	53                   	push   %ebx
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d61:	89 c6                	mov    %eax,%esi
  801d63:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d66:	eb 1a                	jmp    801d82 <memcmp+0x2c>
		if (*s1 != *s2)
  801d68:	0f b6 08             	movzbl (%eax),%ecx
  801d6b:	0f b6 1a             	movzbl (%edx),%ebx
  801d6e:	38 d9                	cmp    %bl,%cl
  801d70:	74 0a                	je     801d7c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d72:	0f b6 c1             	movzbl %cl,%eax
  801d75:	0f b6 db             	movzbl %bl,%ebx
  801d78:	29 d8                	sub    %ebx,%eax
  801d7a:	eb 0f                	jmp    801d8b <memcmp+0x35>
		s1++, s2++;
  801d7c:	83 c0 01             	add    $0x1,%eax
  801d7f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d82:	39 f0                	cmp    %esi,%eax
  801d84:	75 e2                	jne    801d68 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d8b:	5b                   	pop    %ebx
  801d8c:	5e                   	pop    %esi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	53                   	push   %ebx
  801d93:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d96:	89 c1                	mov    %eax,%ecx
  801d98:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9f:	eb 0a                	jmp    801dab <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da1:	0f b6 10             	movzbl (%eax),%edx
  801da4:	39 da                	cmp    %ebx,%edx
  801da6:	74 07                	je     801daf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da8:	83 c0 01             	add    $0x1,%eax
  801dab:	39 c8                	cmp    %ecx,%eax
  801dad:	72 f2                	jb     801da1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801daf:	5b                   	pop    %ebx
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	57                   	push   %edi
  801db6:	56                   	push   %esi
  801db7:	53                   	push   %ebx
  801db8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbe:	eb 03                	jmp    801dc3 <strtol+0x11>
		s++;
  801dc0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc3:	0f b6 01             	movzbl (%ecx),%eax
  801dc6:	3c 20                	cmp    $0x20,%al
  801dc8:	74 f6                	je     801dc0 <strtol+0xe>
  801dca:	3c 09                	cmp    $0x9,%al
  801dcc:	74 f2                	je     801dc0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dce:	3c 2b                	cmp    $0x2b,%al
  801dd0:	75 0a                	jne    801ddc <strtol+0x2a>
		s++;
  801dd2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd5:	bf 00 00 00 00       	mov    $0x0,%edi
  801dda:	eb 11                	jmp    801ded <strtol+0x3b>
  801ddc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de1:	3c 2d                	cmp    $0x2d,%al
  801de3:	75 08                	jne    801ded <strtol+0x3b>
		s++, neg = 1;
  801de5:	83 c1 01             	add    $0x1,%ecx
  801de8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ded:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df3:	75 15                	jne    801e0a <strtol+0x58>
  801df5:	80 39 30             	cmpb   $0x30,(%ecx)
  801df8:	75 10                	jne    801e0a <strtol+0x58>
  801dfa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dfe:	75 7c                	jne    801e7c <strtol+0xca>
		s += 2, base = 16;
  801e00:	83 c1 02             	add    $0x2,%ecx
  801e03:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e08:	eb 16                	jmp    801e20 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e0a:	85 db                	test   %ebx,%ebx
  801e0c:	75 12                	jne    801e20 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e13:	80 39 30             	cmpb   $0x30,(%ecx)
  801e16:	75 08                	jne    801e20 <strtol+0x6e>
		s++, base = 8;
  801e18:	83 c1 01             	add    $0x1,%ecx
  801e1b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e20:	b8 00 00 00 00       	mov    $0x0,%eax
  801e25:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e28:	0f b6 11             	movzbl (%ecx),%edx
  801e2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e2e:	89 f3                	mov    %esi,%ebx
  801e30:	80 fb 09             	cmp    $0x9,%bl
  801e33:	77 08                	ja     801e3d <strtol+0x8b>
			dig = *s - '0';
  801e35:	0f be d2             	movsbl %dl,%edx
  801e38:	83 ea 30             	sub    $0x30,%edx
  801e3b:	eb 22                	jmp    801e5f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e3d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e40:	89 f3                	mov    %esi,%ebx
  801e42:	80 fb 19             	cmp    $0x19,%bl
  801e45:	77 08                	ja     801e4f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e47:	0f be d2             	movsbl %dl,%edx
  801e4a:	83 ea 57             	sub    $0x57,%edx
  801e4d:	eb 10                	jmp    801e5f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e4f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e52:	89 f3                	mov    %esi,%ebx
  801e54:	80 fb 19             	cmp    $0x19,%bl
  801e57:	77 16                	ja     801e6f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e59:	0f be d2             	movsbl %dl,%edx
  801e5c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e62:	7d 0b                	jge    801e6f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e64:	83 c1 01             	add    $0x1,%ecx
  801e67:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e6b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e6d:	eb b9                	jmp    801e28 <strtol+0x76>

	if (endptr)
  801e6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e73:	74 0d                	je     801e82 <strtol+0xd0>
		*endptr = (char *) s;
  801e75:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e78:	89 0e                	mov    %ecx,(%esi)
  801e7a:	eb 06                	jmp    801e82 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e7c:	85 db                	test   %ebx,%ebx
  801e7e:	74 98                	je     801e18 <strtol+0x66>
  801e80:	eb 9e                	jmp    801e20 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e82:	89 c2                	mov    %eax,%edx
  801e84:	f7 da                	neg    %edx
  801e86:	85 ff                	test   %edi,%edi
  801e88:	0f 45 c2             	cmovne %edx,%eax
}
  801e8b:	5b                   	pop    %ebx
  801e8c:	5e                   	pop    %esi
  801e8d:	5f                   	pop    %edi
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	8b 75 08             	mov    0x8(%ebp),%esi
  801e98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e9e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ea0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ea5:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	50                   	push   %eax
  801eac:	e8 54 e4 ff ff       	call   800305 <sys_ipc_recv>

	if (from_env_store != NULL)
  801eb1:	83 c4 10             	add    $0x10,%esp
  801eb4:	85 f6                	test   %esi,%esi
  801eb6:	74 14                	je     801ecc <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801eb8:	ba 00 00 00 00       	mov    $0x0,%edx
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	78 09                	js     801eca <ipc_recv+0x3a>
  801ec1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ec7:	8b 52 74             	mov    0x74(%edx),%edx
  801eca:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ecc:	85 db                	test   %ebx,%ebx
  801ece:	74 14                	je     801ee4 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ed0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 09                	js     801ee2 <ipc_recv+0x52>
  801ed9:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801edf:	8b 52 78             	mov    0x78(%edx),%edx
  801ee2:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 08                	js     801ef0 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ee8:	a1 08 40 80 00       	mov    0x804008,%eax
  801eed:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    

00801ef7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	57                   	push   %edi
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f03:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f09:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f0b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f10:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f13:	ff 75 14             	pushl  0x14(%ebp)
  801f16:	53                   	push   %ebx
  801f17:	56                   	push   %esi
  801f18:	57                   	push   %edi
  801f19:	e8 c4 e3 ff ff       	call   8002e2 <sys_ipc_try_send>

		if (err < 0) {
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	85 c0                	test   %eax,%eax
  801f23:	79 1e                	jns    801f43 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f25:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f28:	75 07                	jne    801f31 <ipc_send+0x3a>
				sys_yield();
  801f2a:	e8 07 e2 ff ff       	call   800136 <sys_yield>
  801f2f:	eb e2                	jmp    801f13 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f31:	50                   	push   %eax
  801f32:	68 e0 26 80 00       	push   $0x8026e0
  801f37:	6a 49                	push   $0x49
  801f39:	68 ed 26 80 00       	push   $0x8026ed
  801f3e:	e8 a8 f5 ff ff       	call   8014eb <_panic>
		}

	} while (err < 0);

}
  801f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5f                   	pop    %edi
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f51:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f56:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f59:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5f:	8b 52 50             	mov    0x50(%edx),%edx
  801f62:	39 ca                	cmp    %ecx,%edx
  801f64:	75 0d                	jne    801f73 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f66:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f69:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6e:	8b 40 48             	mov    0x48(%eax),%eax
  801f71:	eb 0f                	jmp    801f82 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f73:	83 c0 01             	add    $0x1,%eax
  801f76:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7b:	75 d9                	jne    801f56 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    

00801f84 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8a:	89 d0                	mov    %edx,%eax
  801f8c:	c1 e8 16             	shr    $0x16,%eax
  801f8f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f96:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9b:	f6 c1 01             	test   $0x1,%cl
  801f9e:	74 1d                	je     801fbd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa0:	c1 ea 0c             	shr    $0xc,%edx
  801fa3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801faa:	f6 c2 01             	test   $0x1,%dl
  801fad:	74 0e                	je     801fbd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801faf:	c1 ea 0c             	shr    $0xc,%edx
  801fb2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb9:	ef 
  801fba:	0f b7 c0             	movzwl %ax,%eax
}
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
