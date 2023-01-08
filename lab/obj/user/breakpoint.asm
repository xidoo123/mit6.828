
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
  800085:	e8 a6 04 00 00       	call   800530 <close_all>
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
  8000fe:	68 2a 22 80 00       	push   $0x80222a
  800103:	6a 23                	push   $0x23
  800105:	68 47 22 80 00       	push   $0x802247
  80010a:	e8 9a 13 00 00       	call   8014a9 <_panic>

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
  80017f:	68 2a 22 80 00       	push   $0x80222a
  800184:	6a 23                	push   $0x23
  800186:	68 47 22 80 00       	push   $0x802247
  80018b:	e8 19 13 00 00       	call   8014a9 <_panic>

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
  8001c1:	68 2a 22 80 00       	push   $0x80222a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 47 22 80 00       	push   $0x802247
  8001cd:	e8 d7 12 00 00       	call   8014a9 <_panic>

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
  800203:	68 2a 22 80 00       	push   $0x80222a
  800208:	6a 23                	push   $0x23
  80020a:	68 47 22 80 00       	push   $0x802247
  80020f:	e8 95 12 00 00       	call   8014a9 <_panic>

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
  800245:	68 2a 22 80 00       	push   $0x80222a
  80024a:	6a 23                	push   $0x23
  80024c:	68 47 22 80 00       	push   $0x802247
  800251:	e8 53 12 00 00       	call   8014a9 <_panic>

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
  800287:	68 2a 22 80 00       	push   $0x80222a
  80028c:	6a 23                	push   $0x23
  80028e:	68 47 22 80 00       	push   $0x802247
  800293:	e8 11 12 00 00       	call   8014a9 <_panic>

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
  8002c9:	68 2a 22 80 00       	push   $0x80222a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 47 22 80 00       	push   $0x802247
  8002d5:	e8 cf 11 00 00       	call   8014a9 <_panic>

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
  80032d:	68 2a 22 80 00       	push   $0x80222a
  800332:	6a 23                	push   $0x23
  800334:	68 47 22 80 00       	push   $0x802247
  800339:	e8 6b 11 00 00       	call   8014a9 <_panic>

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

00800365 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800368:	8b 45 08             	mov    0x8(%ebp),%eax
  80036b:	05 00 00 00 30       	add    $0x30000000,%eax
  800370:	c1 e8 0c             	shr    $0xc,%eax
}
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	05 00 00 00 30       	add    $0x30000000,%eax
  800380:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800385:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800392:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 16             	shr    $0x16,%edx
  80039c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 11                	je     8003b9 <fd_alloc+0x2d>
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 0c             	shr    $0xc,%edx
  8003ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	75 09                	jne    8003c2 <fd_alloc+0x36>
			*fd_store = fd;
  8003b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	eb 17                	jmp    8003d9 <fd_alloc+0x4d>
  8003c2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003c7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cc:	75 c9                	jne    800397 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ce:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e1:	83 f8 1f             	cmp    $0x1f,%eax
  8003e4:	77 36                	ja     80041c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003e6:	c1 e0 0c             	shl    $0xc,%eax
  8003e9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 16             	shr    $0x16,%edx
  8003f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 24                	je     800423 <fd_lookup+0x48>
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 0c             	shr    $0xc,%edx
  800404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 1a                	je     80042a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800410:	8b 55 0c             	mov    0xc(%ebp),%edx
  800413:	89 02                	mov    %eax,(%edx)
	return 0;
  800415:	b8 00 00 00 00       	mov    $0x0,%eax
  80041a:	eb 13                	jmp    80042f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800421:	eb 0c                	jmp    80042f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800428:	eb 05                	jmp    80042f <fd_lookup+0x54>
  80042a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043a:	ba d4 22 80 00       	mov    $0x8022d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80043f:	eb 13                	jmp    800454 <dev_lookup+0x23>
  800441:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800444:	39 08                	cmp    %ecx,(%eax)
  800446:	75 0c                	jne    800454 <dev_lookup+0x23>
			*dev = devtab[i];
  800448:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	eb 2e                	jmp    800482 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800454:	8b 02                	mov    (%edx),%eax
  800456:	85 c0                	test   %eax,%eax
  800458:	75 e7                	jne    800441 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045a:	a1 08 40 80 00       	mov    0x804008,%eax
  80045f:	8b 40 48             	mov    0x48(%eax),%eax
  800462:	83 ec 04             	sub    $0x4,%esp
  800465:	51                   	push   %ecx
  800466:	50                   	push   %eax
  800467:	68 58 22 80 00       	push   $0x802258
  80046c:	e8 11 11 00 00       	call   801582 <cprintf>
	*dev = 0;
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
  800474:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	83 ec 10             	sub    $0x10,%esp
  80048c:	8b 75 08             	mov    0x8(%ebp),%esi
  80048f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800492:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800495:	50                   	push   %eax
  800496:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80049c:	c1 e8 0c             	shr    $0xc,%eax
  80049f:	50                   	push   %eax
  8004a0:	e8 36 ff ff ff       	call   8003db <fd_lookup>
  8004a5:	83 c4 08             	add    $0x8,%esp
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	78 05                	js     8004b1 <fd_close+0x2d>
	    || fd != fd2)
  8004ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004af:	74 0c                	je     8004bd <fd_close+0x39>
		return (must_exist ? r : 0);
  8004b1:	84 db                	test   %bl,%bl
  8004b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b8:	0f 44 c2             	cmove  %edx,%eax
  8004bb:	eb 41                	jmp    8004fe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c3:	50                   	push   %eax
  8004c4:	ff 36                	pushl  (%esi)
  8004c6:	e8 66 ff ff ff       	call   800431 <dev_lookup>
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	78 1a                	js     8004ee <fd_close+0x6a>
		if (dev->dev_close)
  8004d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004da:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	74 0b                	je     8004ee <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004e3:	83 ec 0c             	sub    $0xc,%esp
  8004e6:	56                   	push   %esi
  8004e7:	ff d0                	call   *%eax
  8004e9:	89 c3                	mov    %eax,%ebx
  8004eb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	56                   	push   %esi
  8004f2:	6a 00                	push   $0x0
  8004f4:	e8 e1 fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	89 d8                	mov    %ebx,%eax
}
  8004fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800501:	5b                   	pop    %ebx
  800502:	5e                   	pop    %esi
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050e:	50                   	push   %eax
  80050f:	ff 75 08             	pushl  0x8(%ebp)
  800512:	e8 c4 fe ff ff       	call   8003db <fd_lookup>
  800517:	83 c4 08             	add    $0x8,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	78 10                	js     80052e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	6a 01                	push   $0x1
  800523:	ff 75 f4             	pushl  -0xc(%ebp)
  800526:	e8 59 ff ff ff       	call   800484 <fd_close>
  80052b:	83 c4 10             	add    $0x10,%esp
}
  80052e:	c9                   	leave  
  80052f:	c3                   	ret    

00800530 <close_all>:

void
close_all(void)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	53                   	push   %ebx
  800534:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053c:	83 ec 0c             	sub    $0xc,%esp
  80053f:	53                   	push   %ebx
  800540:	e8 c0 ff ff ff       	call   800505 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800545:	83 c3 01             	add    $0x1,%ebx
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	83 fb 20             	cmp    $0x20,%ebx
  80054e:	75 ec                	jne    80053c <close_all+0xc>
		close(i);
}
  800550:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800553:	c9                   	leave  
  800554:	c3                   	ret    

00800555 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	57                   	push   %edi
  800559:	56                   	push   %esi
  80055a:	53                   	push   %ebx
  80055b:	83 ec 2c             	sub    $0x2c,%esp
  80055e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800561:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800564:	50                   	push   %eax
  800565:	ff 75 08             	pushl  0x8(%ebp)
  800568:	e8 6e fe ff ff       	call   8003db <fd_lookup>
  80056d:	83 c4 08             	add    $0x8,%esp
  800570:	85 c0                	test   %eax,%eax
  800572:	0f 88 c1 00 00 00    	js     800639 <dup+0xe4>
		return r;
	close(newfdnum);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	56                   	push   %esi
  80057c:	e8 84 ff ff ff       	call   800505 <close>

	newfd = INDEX2FD(newfdnum);
  800581:	89 f3                	mov    %esi,%ebx
  800583:	c1 e3 0c             	shl    $0xc,%ebx
  800586:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80058c:	83 c4 04             	add    $0x4,%esp
  80058f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800592:	e8 de fd ff ff       	call   800375 <fd2data>
  800597:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800599:	89 1c 24             	mov    %ebx,(%esp)
  80059c:	e8 d4 fd ff ff       	call   800375 <fd2data>
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a7:	89 f8                	mov    %edi,%eax
  8005a9:	c1 e8 16             	shr    $0x16,%eax
  8005ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b3:	a8 01                	test   $0x1,%al
  8005b5:	74 37                	je     8005ee <dup+0x99>
  8005b7:	89 f8                	mov    %edi,%eax
  8005b9:	c1 e8 0c             	shr    $0xc,%eax
  8005bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c3:	f6 c2 01             	test   $0x1,%dl
  8005c6:	74 26                	je     8005ee <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d7:	50                   	push   %eax
  8005d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005db:	6a 00                	push   $0x0
  8005dd:	57                   	push   %edi
  8005de:	6a 00                	push   $0x0
  8005e0:	e8 b3 fb ff ff       	call   800198 <sys_page_map>
  8005e5:	89 c7                	mov    %eax,%edi
  8005e7:	83 c4 20             	add    $0x20,%esp
  8005ea:	85 c0                	test   %eax,%eax
  8005ec:	78 2e                	js     80061c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f1:	89 d0                	mov    %edx,%eax
  8005f3:	c1 e8 0c             	shr    $0xc,%eax
  8005f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fd:	83 ec 0c             	sub    $0xc,%esp
  800600:	25 07 0e 00 00       	and    $0xe07,%eax
  800605:	50                   	push   %eax
  800606:	53                   	push   %ebx
  800607:	6a 00                	push   $0x0
  800609:	52                   	push   %edx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 87 fb ff ff       	call   800198 <sys_page_map>
  800611:	89 c7                	mov    %eax,%edi
  800613:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800616:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800618:	85 ff                	test   %edi,%edi
  80061a:	79 1d                	jns    800639 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 00                	push   $0x0
  800622:	e8 b3 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80062d:	6a 00                	push   $0x0
  80062f:	e8 a6 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	89 f8                	mov    %edi,%eax
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	53                   	push   %ebx
  800645:	83 ec 14             	sub    $0x14,%esp
  800648:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	53                   	push   %ebx
  800650:	e8 86 fd ff ff       	call   8003db <fd_lookup>
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	89 c2                	mov    %eax,%edx
  80065a:	85 c0                	test   %eax,%eax
  80065c:	78 6d                	js     8006cb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800664:	50                   	push   %eax
  800665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800668:	ff 30                	pushl  (%eax)
  80066a:	e8 c2 fd ff ff       	call   800431 <dev_lookup>
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	85 c0                	test   %eax,%eax
  800674:	78 4c                	js     8006c2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800676:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800679:	8b 42 08             	mov    0x8(%edx),%eax
  80067c:	83 e0 03             	and    $0x3,%eax
  80067f:	83 f8 01             	cmp    $0x1,%eax
  800682:	75 21                	jne    8006a5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800684:	a1 08 40 80 00       	mov    0x804008,%eax
  800689:	8b 40 48             	mov    0x48(%eax),%eax
  80068c:	83 ec 04             	sub    $0x4,%esp
  80068f:	53                   	push   %ebx
  800690:	50                   	push   %eax
  800691:	68 99 22 80 00       	push   $0x802299
  800696:	e8 e7 0e 00 00       	call   801582 <cprintf>
		return -E_INVAL;
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a3:	eb 26                	jmp    8006cb <read+0x8a>
	}
	if (!dev->dev_read)
  8006a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a8:	8b 40 08             	mov    0x8(%eax),%eax
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	74 17                	je     8006c6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006af:	83 ec 04             	sub    $0x4,%esp
  8006b2:	ff 75 10             	pushl  0x10(%ebp)
  8006b5:	ff 75 0c             	pushl  0xc(%ebp)
  8006b8:	52                   	push   %edx
  8006b9:	ff d0                	call   *%eax
  8006bb:	89 c2                	mov    %eax,%edx
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 09                	jmp    8006cb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c2:	89 c2                	mov    %eax,%edx
  8006c4:	eb 05                	jmp    8006cb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006cb:	89 d0                	mov    %edx,%eax
  8006cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    

008006d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	57                   	push   %edi
  8006d6:	56                   	push   %esi
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 0c             	sub    $0xc,%esp
  8006db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e6:	eb 21                	jmp    800709 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e8:	83 ec 04             	sub    $0x4,%esp
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	29 d8                	sub    %ebx,%eax
  8006ef:	50                   	push   %eax
  8006f0:	89 d8                	mov    %ebx,%eax
  8006f2:	03 45 0c             	add    0xc(%ebp),%eax
  8006f5:	50                   	push   %eax
  8006f6:	57                   	push   %edi
  8006f7:	e8 45 ff ff ff       	call   800641 <read>
		if (m < 0)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	85 c0                	test   %eax,%eax
  800701:	78 10                	js     800713 <readn+0x41>
			return m;
		if (m == 0)
  800703:	85 c0                	test   %eax,%eax
  800705:	74 0a                	je     800711 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800707:	01 c3                	add    %eax,%ebx
  800709:	39 f3                	cmp    %esi,%ebx
  80070b:	72 db                	jb     8006e8 <readn+0x16>
  80070d:	89 d8                	mov    %ebx,%eax
  80070f:	eb 02                	jmp    800713 <readn+0x41>
  800711:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	83 ec 14             	sub    $0x14,%esp
  800722:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800725:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	53                   	push   %ebx
  80072a:	e8 ac fc ff ff       	call   8003db <fd_lookup>
  80072f:	83 c4 08             	add    $0x8,%esp
  800732:	89 c2                	mov    %eax,%edx
  800734:	85 c0                	test   %eax,%eax
  800736:	78 68                	js     8007a0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	ff 30                	pushl  (%eax)
  800744:	e8 e8 fc ff ff       	call   800431 <dev_lookup>
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	85 c0                	test   %eax,%eax
  80074e:	78 47                	js     800797 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800750:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800753:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800757:	75 21                	jne    80077a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800759:	a1 08 40 80 00       	mov    0x804008,%eax
  80075e:	8b 40 48             	mov    0x48(%eax),%eax
  800761:	83 ec 04             	sub    $0x4,%esp
  800764:	53                   	push   %ebx
  800765:	50                   	push   %eax
  800766:	68 b5 22 80 00       	push   $0x8022b5
  80076b:	e8 12 0e 00 00       	call   801582 <cprintf>
		return -E_INVAL;
  800770:	83 c4 10             	add    $0x10,%esp
  800773:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800778:	eb 26                	jmp    8007a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077d:	8b 52 0c             	mov    0xc(%edx),%edx
  800780:	85 d2                	test   %edx,%edx
  800782:	74 17                	je     80079b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800784:	83 ec 04             	sub    $0x4,%esp
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	50                   	push   %eax
  80078e:	ff d2                	call   *%edx
  800790:	89 c2                	mov    %eax,%edx
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 09                	jmp    8007a0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800797:	89 c2                	mov    %eax,%edx
  800799:	eb 05                	jmp    8007a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80079b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a0:	89 d0                	mov    %edx,%eax
  8007a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ad:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	ff 75 08             	pushl  0x8(%ebp)
  8007b4:	e8 22 fc ff ff       	call   8003db <fd_lookup>
  8007b9:	83 c4 08             	add    $0x8,%esp
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	78 0e                	js     8007ce <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 14             	sub    $0x14,%esp
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	53                   	push   %ebx
  8007df:	e8 f7 fb ff ff       	call   8003db <fd_lookup>
  8007e4:	83 c4 08             	add    $0x8,%esp
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 65                	js     800852 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	ff 30                	pushl  (%eax)
  8007f9:	e8 33 fc ff ff       	call   800431 <dev_lookup>
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 c0                	test   %eax,%eax
  800803:	78 44                	js     800849 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080c:	75 21                	jne    80082f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80080e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800813:	8b 40 48             	mov    0x48(%eax),%eax
  800816:	83 ec 04             	sub    $0x4,%esp
  800819:	53                   	push   %ebx
  80081a:	50                   	push   %eax
  80081b:	68 78 22 80 00       	push   $0x802278
  800820:	e8 5d 0d 00 00       	call   801582 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80082d:	eb 23                	jmp    800852 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80082f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800832:	8b 52 18             	mov    0x18(%edx),%edx
  800835:	85 d2                	test   %edx,%edx
  800837:	74 14                	je     80084d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	ff 75 0c             	pushl  0xc(%ebp)
  80083f:	50                   	push   %eax
  800840:	ff d2                	call   *%edx
  800842:	89 c2                	mov    %eax,%edx
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	eb 09                	jmp    800852 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800849:	89 c2                	mov    %eax,%edx
  80084b:	eb 05                	jmp    800852 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80084d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800852:	89 d0                	mov    %edx,%eax
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	83 ec 14             	sub    $0x14,%esp
  800860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800866:	50                   	push   %eax
  800867:	ff 75 08             	pushl  0x8(%ebp)
  80086a:	e8 6c fb ff ff       	call   8003db <fd_lookup>
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	89 c2                	mov    %eax,%edx
  800874:	85 c0                	test   %eax,%eax
  800876:	78 58                	js     8008d0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087e:	50                   	push   %eax
  80087f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800882:	ff 30                	pushl  (%eax)
  800884:	e8 a8 fb ff ff       	call   800431 <dev_lookup>
  800889:	83 c4 10             	add    $0x10,%esp
  80088c:	85 c0                	test   %eax,%eax
  80088e:	78 37                	js     8008c7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800893:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800897:	74 32                	je     8008cb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800899:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a3:	00 00 00 
	stat->st_isdir = 0;
  8008a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ad:	00 00 00 
	stat->st_dev = dev;
  8008b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8008bd:	ff 50 14             	call   *0x14(%eax)
  8008c0:	89 c2                	mov    %eax,%edx
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb 09                	jmp    8008d0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c7:	89 c2                	mov    %eax,%edx
  8008c9:	eb 05                	jmp    8008d0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d0:	89 d0                	mov    %edx,%eax
  8008d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	6a 00                	push   $0x0
  8008e1:	ff 75 08             	pushl  0x8(%ebp)
  8008e4:	e8 d6 01 00 00       	call   800abf <open>
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	78 1b                	js     80090d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	50                   	push   %eax
  8008f9:	e8 5b ff ff ff       	call   800859 <fstat>
  8008fe:	89 c6                	mov    %eax,%esi
	close(fd);
  800900:	89 1c 24             	mov    %ebx,(%esp)
  800903:	e8 fd fb ff ff       	call   800505 <close>
	return r;
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	89 f0                	mov    %esi,%eax
}
  80090d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	89 c6                	mov    %eax,%esi
  80091b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80091d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800924:	75 12                	jne    800938 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	6a 01                	push   $0x1
  80092b:	e8 d9 15 00 00       	call   801f09 <ipc_find_env>
  800930:	a3 00 40 80 00       	mov    %eax,0x804000
  800935:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800938:	6a 07                	push   $0x7
  80093a:	68 00 50 80 00       	push   $0x805000
  80093f:	56                   	push   %esi
  800940:	ff 35 00 40 80 00    	pushl  0x804000
  800946:	e8 6a 15 00 00       	call   801eb5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80094b:	83 c4 0c             	add    $0xc,%esp
  80094e:	6a 00                	push   $0x0
  800950:	53                   	push   %ebx
  800951:	6a 00                	push   $0x0
  800953:	e8 f6 14 00 00       	call   801e4e <ipc_recv>
}
  800958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 40 0c             	mov    0xc(%eax),%eax
  80096b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800970:	8b 45 0c             	mov    0xc(%ebp),%eax
  800973:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	b8 02 00 00 00       	mov    $0x2,%eax
  800982:	e8 8d ff ff ff       	call   800914 <fsipc>
}
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 40 0c             	mov    0xc(%eax),%eax
  800995:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a4:	e8 6b ff ff ff       	call   800914 <fsipc>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	83 ec 04             	sub    $0x4,%esp
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ca:	e8 45 ff ff ff       	call   800914 <fsipc>
  8009cf:	85 c0                	test   %eax,%eax
  8009d1:	78 2c                	js     8009ff <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d3:	83 ec 08             	sub    $0x8,%esp
  8009d6:	68 00 50 80 00       	push   $0x805000
  8009db:	53                   	push   %ebx
  8009dc:	e8 26 11 00 00       	call   801b07 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ec:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009f7:	83 c4 10             	add    $0x10,%esp
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 0c             	sub    $0xc,%esp
  800a0a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a10:	8b 52 0c             	mov    0xc(%edx),%edx
  800a13:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a19:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a1e:	50                   	push   %eax
  800a1f:	ff 75 0c             	pushl  0xc(%ebp)
  800a22:	68 08 50 80 00       	push   $0x805008
  800a27:	e8 6d 12 00 00       	call   801c99 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a31:	b8 04 00 00 00       	mov    $0x4,%eax
  800a36:	e8 d9 fe ff ff       	call   800914 <fsipc>

}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a50:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a56:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a60:	e8 af fe ff ff       	call   800914 <fsipc>
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	85 c0                	test   %eax,%eax
  800a69:	78 4b                	js     800ab6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a6b:	39 c6                	cmp    %eax,%esi
  800a6d:	73 16                	jae    800a85 <devfile_read+0x48>
  800a6f:	68 e8 22 80 00       	push   $0x8022e8
  800a74:	68 ef 22 80 00       	push   $0x8022ef
  800a79:	6a 7c                	push   $0x7c
  800a7b:	68 04 23 80 00       	push   $0x802304
  800a80:	e8 24 0a 00 00       	call   8014a9 <_panic>
	assert(r <= PGSIZE);
  800a85:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a8a:	7e 16                	jle    800aa2 <devfile_read+0x65>
  800a8c:	68 0f 23 80 00       	push   $0x80230f
  800a91:	68 ef 22 80 00       	push   $0x8022ef
  800a96:	6a 7d                	push   $0x7d
  800a98:	68 04 23 80 00       	push   $0x802304
  800a9d:	e8 07 0a 00 00       	call   8014a9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa2:	83 ec 04             	sub    $0x4,%esp
  800aa5:	50                   	push   %eax
  800aa6:	68 00 50 80 00       	push   $0x805000
  800aab:	ff 75 0c             	pushl  0xc(%ebp)
  800aae:	e8 e6 11 00 00       	call   801c99 <memmove>
	return r;
  800ab3:	83 c4 10             	add    $0x10,%esp
}
  800ab6:	89 d8                	mov    %ebx,%eax
  800ab8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 20             	sub    $0x20,%esp
  800ac6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac9:	53                   	push   %ebx
  800aca:	e8 ff 0f 00 00       	call   801ace <strlen>
  800acf:	83 c4 10             	add    $0x10,%esp
  800ad2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad7:	7f 67                	jg     800b40 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800adf:	50                   	push   %eax
  800ae0:	e8 a7 f8 ff ff       	call   80038c <fd_alloc>
  800ae5:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aea:	85 c0                	test   %eax,%eax
  800aec:	78 57                	js     800b45 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aee:	83 ec 08             	sub    $0x8,%esp
  800af1:	53                   	push   %ebx
  800af2:	68 00 50 80 00       	push   $0x805000
  800af7:	e8 0b 10 00 00       	call   801b07 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b07:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0c:	e8 03 fe ff ff       	call   800914 <fsipc>
  800b11:	89 c3                	mov    %eax,%ebx
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	85 c0                	test   %eax,%eax
  800b18:	79 14                	jns    800b2e <open+0x6f>
		fd_close(fd, 0);
  800b1a:	83 ec 08             	sub    $0x8,%esp
  800b1d:	6a 00                	push   $0x0
  800b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b22:	e8 5d f9 ff ff       	call   800484 <fd_close>
		return r;
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	89 da                	mov    %ebx,%edx
  800b2c:	eb 17                	jmp    800b45 <open+0x86>
	}

	return fd2num(fd);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	ff 75 f4             	pushl  -0xc(%ebp)
  800b34:	e8 2c f8 ff ff       	call   800365 <fd2num>
  800b39:	89 c2                	mov    %eax,%edx
  800b3b:	83 c4 10             	add    $0x10,%esp
  800b3e:	eb 05                	jmp    800b45 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b40:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b45:	89 d0                	mov    %edx,%eax
  800b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4a:	c9                   	leave  
  800b4b:	c3                   	ret    

00800b4c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b52:	ba 00 00 00 00       	mov    $0x0,%edx
  800b57:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5c:	e8 b3 fd ff ff       	call   800914 <fsipc>
}
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	ff 75 08             	pushl  0x8(%ebp)
  800b71:	e8 ff f7 ff ff       	call   800375 <fd2data>
  800b76:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b78:	83 c4 08             	add    $0x8,%esp
  800b7b:	68 1b 23 80 00       	push   $0x80231b
  800b80:	53                   	push   %ebx
  800b81:	e8 81 0f 00 00       	call   801b07 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b86:	8b 46 04             	mov    0x4(%esi),%eax
  800b89:	2b 06                	sub    (%esi),%eax
  800b8b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b91:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b98:	00 00 00 
	stat->st_dev = &devpipe;
  800b9b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba2:	30 80 00 
	return 0;
}
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  800baa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbb:	53                   	push   %ebx
  800bbc:	6a 00                	push   $0x0
  800bbe:	e8 17 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc3:	89 1c 24             	mov    %ebx,(%esp)
  800bc6:	e8 aa f7 ff ff       	call   800375 <fd2data>
  800bcb:	83 c4 08             	add    $0x8,%esp
  800bce:	50                   	push   %eax
  800bcf:	6a 00                	push   $0x0
  800bd1:	e8 04 f6 ff ff       	call   8001da <sys_page_unmap>
}
  800bd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 1c             	sub    $0x1c,%esp
  800be4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be9:	a1 08 40 80 00       	mov    0x804008,%eax
  800bee:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf7:	e8 46 13 00 00       	call   801f42 <pageref>
  800bfc:	89 c3                	mov    %eax,%ebx
  800bfe:	89 3c 24             	mov    %edi,(%esp)
  800c01:	e8 3c 13 00 00       	call   801f42 <pageref>
  800c06:	83 c4 10             	add    $0x10,%esp
  800c09:	39 c3                	cmp    %eax,%ebx
  800c0b:	0f 94 c1             	sete   %cl
  800c0e:	0f b6 c9             	movzbl %cl,%ecx
  800c11:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c14:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c1a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c1d:	39 ce                	cmp    %ecx,%esi
  800c1f:	74 1b                	je     800c3c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c21:	39 c3                	cmp    %eax,%ebx
  800c23:	75 c4                	jne    800be9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c25:	8b 42 58             	mov    0x58(%edx),%eax
  800c28:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2b:	50                   	push   %eax
  800c2c:	56                   	push   %esi
  800c2d:	68 22 23 80 00       	push   $0x802322
  800c32:	e8 4b 09 00 00       	call   801582 <cprintf>
  800c37:	83 c4 10             	add    $0x10,%esp
  800c3a:	eb ad                	jmp    800be9 <_pipeisclosed+0xe>
	}
}
  800c3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 28             	sub    $0x28,%esp
  800c50:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c53:	56                   	push   %esi
  800c54:	e8 1c f7 ff ff       	call   800375 <fd2data>
  800c59:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5b:	83 c4 10             	add    $0x10,%esp
  800c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c63:	eb 4b                	jmp    800cb0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c65:	89 da                	mov    %ebx,%edx
  800c67:	89 f0                	mov    %esi,%eax
  800c69:	e8 6d ff ff ff       	call   800bdb <_pipeisclosed>
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	75 48                	jne    800cba <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c72:	e8 bf f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c77:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7a:	8b 0b                	mov    (%ebx),%ecx
  800c7c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7f:	39 d0                	cmp    %edx,%eax
  800c81:	73 e2                	jae    800c65 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8d:	89 c2                	mov    %eax,%edx
  800c8f:	c1 fa 1f             	sar    $0x1f,%edx
  800c92:	89 d1                	mov    %edx,%ecx
  800c94:	c1 e9 1b             	shr    $0x1b,%ecx
  800c97:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9a:	83 e2 1f             	and    $0x1f,%edx
  800c9d:	29 ca                	sub    %ecx,%edx
  800c9f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca7:	83 c0 01             	add    $0x1,%eax
  800caa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cad:	83 c7 01             	add    $0x1,%edi
  800cb0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb3:	75 c2                	jne    800c77 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb8:	eb 05                	jmp    800cbf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cba:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 18             	sub    $0x18,%esp
  800cd0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd3:	57                   	push   %edi
  800cd4:	e8 9c f6 ff ff       	call   800375 <fd2data>
  800cd9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cdb:	83 c4 10             	add    $0x10,%esp
  800cde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce3:	eb 3d                	jmp    800d22 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce5:	85 db                	test   %ebx,%ebx
  800ce7:	74 04                	je     800ced <devpipe_read+0x26>
				return i;
  800ce9:	89 d8                	mov    %ebx,%eax
  800ceb:	eb 44                	jmp    800d31 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ced:	89 f2                	mov    %esi,%edx
  800cef:	89 f8                	mov    %edi,%eax
  800cf1:	e8 e5 fe ff ff       	call   800bdb <_pipeisclosed>
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	75 32                	jne    800d2c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cfa:	e8 37 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cff:	8b 06                	mov    (%esi),%eax
  800d01:	3b 46 04             	cmp    0x4(%esi),%eax
  800d04:	74 df                	je     800ce5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d06:	99                   	cltd   
  800d07:	c1 ea 1b             	shr    $0x1b,%edx
  800d0a:	01 d0                	add    %edx,%eax
  800d0c:	83 e0 1f             	and    $0x1f,%eax
  800d0f:	29 d0                	sub    %edx,%eax
  800d11:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d1c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1f:	83 c3 01             	add    $0x1,%ebx
  800d22:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d25:	75 d8                	jne    800cff <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d27:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2a:	eb 05                	jmp    800d31 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d44:	50                   	push   %eax
  800d45:	e8 42 f6 ff ff       	call   80038c <fd_alloc>
  800d4a:	83 c4 10             	add    $0x10,%esp
  800d4d:	89 c2                	mov    %eax,%edx
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	0f 88 2c 01 00 00    	js     800e83 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d57:	83 ec 04             	sub    $0x4,%esp
  800d5a:	68 07 04 00 00       	push   $0x407
  800d5f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d62:	6a 00                	push   $0x0
  800d64:	e8 ec f3 ff ff       	call   800155 <sys_page_alloc>
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	89 c2                	mov    %eax,%edx
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	0f 88 0d 01 00 00    	js     800e83 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7c:	50                   	push   %eax
  800d7d:	e8 0a f6 ff ff       	call   80038c <fd_alloc>
  800d82:	89 c3                	mov    %eax,%ebx
  800d84:	83 c4 10             	add    $0x10,%esp
  800d87:	85 c0                	test   %eax,%eax
  800d89:	0f 88 e2 00 00 00    	js     800e71 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8f:	83 ec 04             	sub    $0x4,%esp
  800d92:	68 07 04 00 00       	push   $0x407
  800d97:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9a:	6a 00                	push   $0x0
  800d9c:	e8 b4 f3 ff ff       	call   800155 <sys_page_alloc>
  800da1:	89 c3                	mov    %eax,%ebx
  800da3:	83 c4 10             	add    $0x10,%esp
  800da6:	85 c0                	test   %eax,%eax
  800da8:	0f 88 c3 00 00 00    	js     800e71 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dae:	83 ec 0c             	sub    $0xc,%esp
  800db1:	ff 75 f4             	pushl  -0xc(%ebp)
  800db4:	e8 bc f5 ff ff       	call   800375 <fd2data>
  800db9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbb:	83 c4 0c             	add    $0xc,%esp
  800dbe:	68 07 04 00 00       	push   $0x407
  800dc3:	50                   	push   %eax
  800dc4:	6a 00                	push   $0x0
  800dc6:	e8 8a f3 ff ff       	call   800155 <sys_page_alloc>
  800dcb:	89 c3                	mov    %eax,%ebx
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	0f 88 89 00 00 00    	js     800e61 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dde:	e8 92 f5 ff ff       	call   800375 <fd2data>
  800de3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dea:	50                   	push   %eax
  800deb:	6a 00                	push   $0x0
  800ded:	56                   	push   %esi
  800dee:	6a 00                	push   $0x0
  800df0:	e8 a3 f3 ff ff       	call   800198 <sys_page_map>
  800df5:	89 c3                	mov    %eax,%ebx
  800df7:	83 c4 20             	add    $0x20,%esp
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	78 55                	js     800e53 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dfe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e07:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e13:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e21:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2e:	e8 32 f5 ff ff       	call   800365 <fd2num>
  800e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e36:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e38:	83 c4 04             	add    $0x4,%esp
  800e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3e:	e8 22 f5 ff ff       	call   800365 <fd2num>
  800e43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e46:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e49:	83 c4 10             	add    $0x10,%esp
  800e4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e51:	eb 30                	jmp    800e83 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	56                   	push   %esi
  800e57:	6a 00                	push   $0x0
  800e59:	e8 7c f3 ff ff       	call   8001da <sys_page_unmap>
  800e5e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	ff 75 f0             	pushl  -0x10(%ebp)
  800e67:	6a 00                	push   $0x0
  800e69:	e8 6c f3 ff ff       	call   8001da <sys_page_unmap>
  800e6e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	ff 75 f4             	pushl  -0xc(%ebp)
  800e77:	6a 00                	push   $0x0
  800e79:	e8 5c f3 ff ff       	call   8001da <sys_page_unmap>
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e83:	89 d0                	mov    %edx,%eax
  800e85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e95:	50                   	push   %eax
  800e96:	ff 75 08             	pushl  0x8(%ebp)
  800e99:	e8 3d f5 ff ff       	call   8003db <fd_lookup>
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	78 18                	js     800ebd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea5:	83 ec 0c             	sub    $0xc,%esp
  800ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  800eab:	e8 c5 f4 ff ff       	call   800375 <fd2data>
	return _pipeisclosed(fd, p);
  800eb0:	89 c2                	mov    %eax,%edx
  800eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb5:	e8 21 fd ff ff       	call   800bdb <_pipeisclosed>
  800eba:	83 c4 10             	add    $0x10,%esp
}
  800ebd:	c9                   	leave  
  800ebe:	c3                   	ret    

00800ebf <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ec5:	68 3a 23 80 00       	push   $0x80233a
  800eca:	ff 75 0c             	pushl  0xc(%ebp)
  800ecd:	e8 35 0c 00 00       	call   801b07 <strcpy>
	return 0;
}
  800ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	53                   	push   %ebx
  800edd:	83 ec 10             	sub    $0x10,%esp
  800ee0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800ee3:	53                   	push   %ebx
  800ee4:	e8 59 10 00 00       	call   801f42 <pageref>
  800ee9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800eec:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800ef1:	83 f8 01             	cmp    $0x1,%eax
  800ef4:	75 10                	jne    800f06 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	ff 73 0c             	pushl  0xc(%ebx)
  800efc:	e8 c0 02 00 00       	call   8011c1 <nsipc_close>
  800f01:	89 c2                	mov    %eax,%edx
  800f03:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f06:	89 d0                	mov    %edx,%eax
  800f08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f13:	6a 00                	push   $0x0
  800f15:	ff 75 10             	pushl  0x10(%ebp)
  800f18:	ff 75 0c             	pushl  0xc(%ebp)
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	ff 70 0c             	pushl  0xc(%eax)
  800f21:	e8 78 03 00 00       	call   80129e <nsipc_send>
}
  800f26:	c9                   	leave  
  800f27:	c3                   	ret    

00800f28 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f2e:	6a 00                	push   $0x0
  800f30:	ff 75 10             	pushl  0x10(%ebp)
  800f33:	ff 75 0c             	pushl  0xc(%ebp)
  800f36:	8b 45 08             	mov    0x8(%ebp),%eax
  800f39:	ff 70 0c             	pushl  0xc(%eax)
  800f3c:	e8 f1 02 00 00       	call   801232 <nsipc_recv>
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f49:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f4c:	52                   	push   %edx
  800f4d:	50                   	push   %eax
  800f4e:	e8 88 f4 ff ff       	call   8003db <fd_lookup>
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	78 17                	js     800f71 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f5d:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800f63:	39 08                	cmp    %ecx,(%eax)
  800f65:	75 05                	jne    800f6c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f67:	8b 40 0c             	mov    0xc(%eax),%eax
  800f6a:	eb 05                	jmp    800f71 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f6c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 1c             	sub    $0x1c,%esp
  800f7b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	e8 06 f4 ff ff       	call   80038c <fd_alloc>
  800f86:	89 c3                	mov    %eax,%ebx
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	78 1b                	js     800faa <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800f8f:	83 ec 04             	sub    $0x4,%esp
  800f92:	68 07 04 00 00       	push   $0x407
  800f97:	ff 75 f4             	pushl  -0xc(%ebp)
  800f9a:	6a 00                	push   $0x0
  800f9c:	e8 b4 f1 ff ff       	call   800155 <sys_page_alloc>
  800fa1:	89 c3                	mov    %eax,%ebx
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 10                	jns    800fba <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	56                   	push   %esi
  800fae:	e8 0e 02 00 00       	call   8011c1 <nsipc_close>
		return r;
  800fb3:	83 c4 10             	add    $0x10,%esp
  800fb6:	89 d8                	mov    %ebx,%eax
  800fb8:	eb 24                	jmp    800fde <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc3:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800fcf:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	50                   	push   %eax
  800fd6:	e8 8a f3 ff ff       	call   800365 <fd2num>
  800fdb:	83 c4 10             	add    $0x10,%esp
}
  800fde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800feb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fee:	e8 50 ff ff ff       	call   800f43 <fd2sockid>
		return r;
  800ff3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 1f                	js     801018 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	ff 75 10             	pushl  0x10(%ebp)
  800fff:	ff 75 0c             	pushl  0xc(%ebp)
  801002:	50                   	push   %eax
  801003:	e8 12 01 00 00       	call   80111a <nsipc_accept>
  801008:	83 c4 10             	add    $0x10,%esp
		return r;
  80100b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 07                	js     801018 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801011:	e8 5d ff ff ff       	call   800f73 <alloc_sockfd>
  801016:	89 c1                	mov    %eax,%ecx
}
  801018:	89 c8                	mov    %ecx,%eax
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801022:	8b 45 08             	mov    0x8(%ebp),%eax
  801025:	e8 19 ff ff ff       	call   800f43 <fd2sockid>
  80102a:	85 c0                	test   %eax,%eax
  80102c:	78 12                	js     801040 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80102e:	83 ec 04             	sub    $0x4,%esp
  801031:	ff 75 10             	pushl  0x10(%ebp)
  801034:	ff 75 0c             	pushl  0xc(%ebp)
  801037:	50                   	push   %eax
  801038:	e8 2d 01 00 00       	call   80116a <nsipc_bind>
  80103d:	83 c4 10             	add    $0x10,%esp
}
  801040:	c9                   	leave  
  801041:	c3                   	ret    

00801042 <shutdown>:

int
shutdown(int s, int how)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801048:	8b 45 08             	mov    0x8(%ebp),%eax
  80104b:	e8 f3 fe ff ff       	call   800f43 <fd2sockid>
  801050:	85 c0                	test   %eax,%eax
  801052:	78 0f                	js     801063 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	ff 75 0c             	pushl  0xc(%ebp)
  80105a:	50                   	push   %eax
  80105b:	e8 3f 01 00 00       	call   80119f <nsipc_shutdown>
  801060:	83 c4 10             	add    $0x10,%esp
}
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80106b:	8b 45 08             	mov    0x8(%ebp),%eax
  80106e:	e8 d0 fe ff ff       	call   800f43 <fd2sockid>
  801073:	85 c0                	test   %eax,%eax
  801075:	78 12                	js     801089 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	ff 75 10             	pushl  0x10(%ebp)
  80107d:	ff 75 0c             	pushl  0xc(%ebp)
  801080:	50                   	push   %eax
  801081:	e8 55 01 00 00       	call   8011db <nsipc_connect>
  801086:	83 c4 10             	add    $0x10,%esp
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <listen>:

int
listen(int s, int backlog)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801091:	8b 45 08             	mov    0x8(%ebp),%eax
  801094:	e8 aa fe ff ff       	call   800f43 <fd2sockid>
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 0f                	js     8010ac <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	ff 75 0c             	pushl  0xc(%ebp)
  8010a3:	50                   	push   %eax
  8010a4:	e8 67 01 00 00       	call   801210 <nsipc_listen>
  8010a9:	83 c4 10             	add    $0x10,%esp
}
  8010ac:	c9                   	leave  
  8010ad:	c3                   	ret    

008010ae <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010b4:	ff 75 10             	pushl  0x10(%ebp)
  8010b7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ba:	ff 75 08             	pushl  0x8(%ebp)
  8010bd:	e8 3a 02 00 00       	call   8012fc <nsipc_socket>
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 05                	js     8010ce <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010c9:	e8 a5 fe ff ff       	call   800f73 <alloc_sockfd>
}
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8010d9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8010e0:	75 12                	jne    8010f4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	6a 02                	push   $0x2
  8010e7:	e8 1d 0e 00 00       	call   801f09 <ipc_find_env>
  8010ec:	a3 04 40 80 00       	mov    %eax,0x804004
  8010f1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8010f4:	6a 07                	push   $0x7
  8010f6:	68 00 60 80 00       	push   $0x806000
  8010fb:	53                   	push   %ebx
  8010fc:	ff 35 04 40 80 00    	pushl  0x804004
  801102:	e8 ae 0d 00 00       	call   801eb5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801107:	83 c4 0c             	add    $0xc,%esp
  80110a:	6a 00                	push   $0x0
  80110c:	6a 00                	push   $0x0
  80110e:	6a 00                	push   $0x0
  801110:	e8 39 0d 00 00       	call   801e4e <ipc_recv>
}
  801115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
  801125:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80112a:	8b 06                	mov    (%esi),%eax
  80112c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801131:	b8 01 00 00 00       	mov    $0x1,%eax
  801136:	e8 95 ff ff ff       	call   8010d0 <nsipc>
  80113b:	89 c3                	mov    %eax,%ebx
  80113d:	85 c0                	test   %eax,%eax
  80113f:	78 20                	js     801161 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801141:	83 ec 04             	sub    $0x4,%esp
  801144:	ff 35 10 60 80 00    	pushl  0x806010
  80114a:	68 00 60 80 00       	push   $0x806000
  80114f:	ff 75 0c             	pushl  0xc(%ebp)
  801152:	e8 42 0b 00 00       	call   801c99 <memmove>
		*addrlen = ret->ret_addrlen;
  801157:	a1 10 60 80 00       	mov    0x806010,%eax
  80115c:	89 06                	mov    %eax,(%esi)
  80115e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801161:	89 d8                	mov    %ebx,%eax
  801163:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	53                   	push   %ebx
  80116e:	83 ec 08             	sub    $0x8,%esp
  801171:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80117c:	53                   	push   %ebx
  80117d:	ff 75 0c             	pushl  0xc(%ebp)
  801180:	68 04 60 80 00       	push   $0x806004
  801185:	e8 0f 0b 00 00       	call   801c99 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80118a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801190:	b8 02 00 00 00       	mov    $0x2,%eax
  801195:	e8 36 ff ff ff       	call   8010d0 <nsipc>
}
  80119a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119d:	c9                   	leave  
  80119e:	c3                   	ret    

0080119f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011b5:	b8 03 00 00 00       	mov    $0x3,%eax
  8011ba:	e8 11 ff ff ff       	call   8010d0 <nsipc>
}
  8011bf:	c9                   	leave  
  8011c0:	c3                   	ret    

008011c1 <nsipc_close>:

int
nsipc_close(int s)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011cf:	b8 04 00 00 00       	mov    $0x4,%eax
  8011d4:	e8 f7 fe ff ff       	call   8010d0 <nsipc>
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	53                   	push   %ebx
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8011e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8011ed:	53                   	push   %ebx
  8011ee:	ff 75 0c             	pushl  0xc(%ebp)
  8011f1:	68 04 60 80 00       	push   $0x806004
  8011f6:	e8 9e 0a 00 00       	call   801c99 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8011fb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801201:	b8 05 00 00 00       	mov    $0x5,%eax
  801206:	e8 c5 fe ff ff       	call   8010d0 <nsipc>
}
  80120b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120e:	c9                   	leave  
  80120f:	c3                   	ret    

00801210 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801216:	8b 45 08             	mov    0x8(%ebp),%eax
  801219:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80121e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801221:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801226:	b8 06 00 00 00       	mov    $0x6,%eax
  80122b:	e8 a0 fe ff ff       	call   8010d0 <nsipc>
}
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	56                   	push   %esi
  801236:	53                   	push   %ebx
  801237:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
  80123d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801242:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801248:	8b 45 14             	mov    0x14(%ebp),%eax
  80124b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801250:	b8 07 00 00 00       	mov    $0x7,%eax
  801255:	e8 76 fe ff ff       	call   8010d0 <nsipc>
  80125a:	89 c3                	mov    %eax,%ebx
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 35                	js     801295 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801260:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801265:	7f 04                	jg     80126b <nsipc_recv+0x39>
  801267:	39 c6                	cmp    %eax,%esi
  801269:	7d 16                	jge    801281 <nsipc_recv+0x4f>
  80126b:	68 46 23 80 00       	push   $0x802346
  801270:	68 ef 22 80 00       	push   $0x8022ef
  801275:	6a 62                	push   $0x62
  801277:	68 5b 23 80 00       	push   $0x80235b
  80127c:	e8 28 02 00 00       	call   8014a9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	50                   	push   %eax
  801285:	68 00 60 80 00       	push   $0x806000
  80128a:	ff 75 0c             	pushl  0xc(%ebp)
  80128d:	e8 07 0a 00 00       	call   801c99 <memmove>
  801292:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801295:	89 d8                	mov    %ebx,%eax
  801297:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129a:	5b                   	pop    %ebx
  80129b:	5e                   	pop    %esi
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 04             	sub    $0x4,%esp
  8012a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ab:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012b0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012b6:	7e 16                	jle    8012ce <nsipc_send+0x30>
  8012b8:	68 67 23 80 00       	push   $0x802367
  8012bd:	68 ef 22 80 00       	push   $0x8022ef
  8012c2:	6a 6d                	push   $0x6d
  8012c4:	68 5b 23 80 00       	push   $0x80235b
  8012c9:	e8 db 01 00 00       	call   8014a9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012ce:	83 ec 04             	sub    $0x4,%esp
  8012d1:	53                   	push   %ebx
  8012d2:	ff 75 0c             	pushl  0xc(%ebp)
  8012d5:	68 0c 60 80 00       	push   $0x80600c
  8012da:	e8 ba 09 00 00       	call   801c99 <memmove>
	nsipcbuf.send.req_size = size;
  8012df:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8012e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8012ed:	b8 08 00 00 00       	mov    $0x8,%eax
  8012f2:	e8 d9 fd ff ff       	call   8010d0 <nsipc>
}
  8012f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801302:	8b 45 08             	mov    0x8(%ebp),%eax
  801305:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80130a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801312:	8b 45 10             	mov    0x10(%ebp),%eax
  801315:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80131a:	b8 09 00 00 00       	mov    $0x9,%eax
  80131f:	e8 ac fd ff ff       	call   8010d0 <nsipc>
}
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801336:	68 73 23 80 00       	push   $0x802373
  80133b:	ff 75 0c             	pushl  0xc(%ebp)
  80133e:	e8 c4 07 00 00       	call   801b07 <strcpy>
	return 0;
}
  801343:	b8 00 00 00 00       	mov    $0x0,%eax
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	57                   	push   %edi
  80134e:	56                   	push   %esi
  80134f:	53                   	push   %ebx
  801350:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801356:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80135b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801361:	eb 2d                	jmp    801390 <devcons_write+0x46>
		m = n - tot;
  801363:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801366:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801368:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80136b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801370:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801373:	83 ec 04             	sub    $0x4,%esp
  801376:	53                   	push   %ebx
  801377:	03 45 0c             	add    0xc(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	57                   	push   %edi
  80137c:	e8 18 09 00 00       	call   801c99 <memmove>
		sys_cputs(buf, m);
  801381:	83 c4 08             	add    $0x8,%esp
  801384:	53                   	push   %ebx
  801385:	57                   	push   %edi
  801386:	e8 0e ed ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138b:	01 de                	add    %ebx,%esi
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	89 f0                	mov    %esi,%eax
  801392:	3b 75 10             	cmp    0x10(%ebp),%esi
  801395:	72 cc                	jb     801363 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801397:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139a:	5b                   	pop    %ebx
  80139b:	5e                   	pop    %esi
  80139c:	5f                   	pop    %edi
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    

0080139f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ae:	74 2a                	je     8013da <devcons_read+0x3b>
  8013b0:	eb 05                	jmp    8013b7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013b2:	e8 7f ed ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013b7:	e8 fb ec ff ff       	call   8000b7 <sys_cgetc>
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	74 f2                	je     8013b2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 16                	js     8013da <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013c4:	83 f8 04             	cmp    $0x4,%eax
  8013c7:	74 0c                	je     8013d5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013cc:	88 02                	mov    %al,(%edx)
	return 1;
  8013ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8013d3:	eb 05                	jmp    8013da <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013e8:	6a 01                	push   $0x1
  8013ea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	e8 a6 ec ff ff       	call   800099 <sys_cputs>
}
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <getchar>:

int
getchar(void)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013fe:	6a 01                	push   $0x1
  801400:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801403:	50                   	push   %eax
  801404:	6a 00                	push   $0x0
  801406:	e8 36 f2 ff ff       	call   800641 <read>
	if (r < 0)
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 0f                	js     801421 <getchar+0x29>
		return r;
	if (r < 1)
  801412:	85 c0                	test   %eax,%eax
  801414:	7e 06                	jle    80141c <getchar+0x24>
		return -E_EOF;
	return c;
  801416:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80141a:	eb 05                	jmp    801421 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80141c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801429:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142c:	50                   	push   %eax
  80142d:	ff 75 08             	pushl  0x8(%ebp)
  801430:	e8 a6 ef ff ff       	call   8003db <fd_lookup>
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 11                	js     80144d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80143c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801445:	39 10                	cmp    %edx,(%eax)
  801447:	0f 94 c0             	sete   %al
  80144a:	0f b6 c0             	movzbl %al,%eax
}
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <opencons>:

int
opencons(void)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801455:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	e8 2e ef ff ff       	call   80038c <fd_alloc>
  80145e:	83 c4 10             	add    $0x10,%esp
		return r;
  801461:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801463:	85 c0                	test   %eax,%eax
  801465:	78 3e                	js     8014a5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801467:	83 ec 04             	sub    $0x4,%esp
  80146a:	68 07 04 00 00       	push   $0x407
  80146f:	ff 75 f4             	pushl  -0xc(%ebp)
  801472:	6a 00                	push   $0x0
  801474:	e8 dc ec ff ff       	call   800155 <sys_page_alloc>
  801479:	83 c4 10             	add    $0x10,%esp
		return r;
  80147c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 23                	js     8014a5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801482:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801490:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801497:	83 ec 0c             	sub    $0xc,%esp
  80149a:	50                   	push   %eax
  80149b:	e8 c5 ee ff ff       	call   800365 <fd2num>
  8014a0:	89 c2                	mov    %eax,%edx
  8014a2:	83 c4 10             	add    $0x10,%esp
}
  8014a5:	89 d0                	mov    %edx,%eax
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014b7:	e8 5b ec ff ff       	call   800117 <sys_getenvid>
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	ff 75 0c             	pushl  0xc(%ebp)
  8014c2:	ff 75 08             	pushl  0x8(%ebp)
  8014c5:	56                   	push   %esi
  8014c6:	50                   	push   %eax
  8014c7:	68 80 23 80 00       	push   $0x802380
  8014cc:	e8 b1 00 00 00       	call   801582 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014d1:	83 c4 18             	add    $0x18,%esp
  8014d4:	53                   	push   %ebx
  8014d5:	ff 75 10             	pushl  0x10(%ebp)
  8014d8:	e8 54 00 00 00       	call   801531 <vcprintf>
	cprintf("\n");
  8014dd:	c7 04 24 33 23 80 00 	movl   $0x802333,(%esp)
  8014e4:	e8 99 00 00 00       	call   801582 <cprintf>
  8014e9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014ec:	cc                   	int3   
  8014ed:	eb fd                	jmp    8014ec <_panic+0x43>

008014ef <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 04             	sub    $0x4,%esp
  8014f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014f9:	8b 13                	mov    (%ebx),%edx
  8014fb:	8d 42 01             	lea    0x1(%edx),%eax
  8014fe:	89 03                	mov    %eax,(%ebx)
  801500:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801503:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801507:	3d ff 00 00 00       	cmp    $0xff,%eax
  80150c:	75 1a                	jne    801528 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	68 ff 00 00 00       	push   $0xff
  801516:	8d 43 08             	lea    0x8(%ebx),%eax
  801519:	50                   	push   %eax
  80151a:	e8 7a eb ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  80151f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801525:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801528:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80152c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80153a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801541:	00 00 00 
	b.cnt = 0;
  801544:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80154b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80154e:	ff 75 0c             	pushl  0xc(%ebp)
  801551:	ff 75 08             	pushl  0x8(%ebp)
  801554:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	68 ef 14 80 00       	push   $0x8014ef
  801560:	e8 54 01 00 00       	call   8016b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801565:	83 c4 08             	add    $0x8,%esp
  801568:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80156e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	e8 1f eb ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  80157a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801588:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80158b:	50                   	push   %eax
  80158c:	ff 75 08             	pushl  0x8(%ebp)
  80158f:	e8 9d ff ff ff       	call   801531 <vcprintf>
	va_end(ap);

	return cnt;
}
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	57                   	push   %edi
  80159a:	56                   	push   %esi
  80159b:	53                   	push   %ebx
  80159c:	83 ec 1c             	sub    $0x1c,%esp
  80159f:	89 c7                	mov    %eax,%edi
  8015a1:	89 d6                	mov    %edx,%esi
  8015a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015af:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015ba:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015bd:	39 d3                	cmp    %edx,%ebx
  8015bf:	72 05                	jb     8015c6 <printnum+0x30>
  8015c1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015c4:	77 45                	ja     80160b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015c6:	83 ec 0c             	sub    $0xc,%esp
  8015c9:	ff 75 18             	pushl  0x18(%ebp)
  8015cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cf:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015d2:	53                   	push   %ebx
  8015d3:	ff 75 10             	pushl  0x10(%ebp)
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8015df:	ff 75 dc             	pushl  -0x24(%ebp)
  8015e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8015e5:	e8 96 09 00 00       	call   801f80 <__udivdi3>
  8015ea:	83 c4 18             	add    $0x18,%esp
  8015ed:	52                   	push   %edx
  8015ee:	50                   	push   %eax
  8015ef:	89 f2                	mov    %esi,%edx
  8015f1:	89 f8                	mov    %edi,%eax
  8015f3:	e8 9e ff ff ff       	call   801596 <printnum>
  8015f8:	83 c4 20             	add    $0x20,%esp
  8015fb:	eb 18                	jmp    801615 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	56                   	push   %esi
  801601:	ff 75 18             	pushl  0x18(%ebp)
  801604:	ff d7                	call   *%edi
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	eb 03                	jmp    80160e <printnum+0x78>
  80160b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80160e:	83 eb 01             	sub    $0x1,%ebx
  801611:	85 db                	test   %ebx,%ebx
  801613:	7f e8                	jg     8015fd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	56                   	push   %esi
  801619:	83 ec 04             	sub    $0x4,%esp
  80161c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161f:	ff 75 e0             	pushl  -0x20(%ebp)
  801622:	ff 75 dc             	pushl  -0x24(%ebp)
  801625:	ff 75 d8             	pushl  -0x28(%ebp)
  801628:	e8 83 0a 00 00       	call   8020b0 <__umoddi3>
  80162d:	83 c4 14             	add    $0x14,%esp
  801630:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  801637:	50                   	push   %eax
  801638:	ff d7                	call   *%edi
}
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801640:	5b                   	pop    %ebx
  801641:	5e                   	pop    %esi
  801642:	5f                   	pop    %edi
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801648:	83 fa 01             	cmp    $0x1,%edx
  80164b:	7e 0e                	jle    80165b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80164d:	8b 10                	mov    (%eax),%edx
  80164f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801652:	89 08                	mov    %ecx,(%eax)
  801654:	8b 02                	mov    (%edx),%eax
  801656:	8b 52 04             	mov    0x4(%edx),%edx
  801659:	eb 22                	jmp    80167d <getuint+0x38>
	else if (lflag)
  80165b:	85 d2                	test   %edx,%edx
  80165d:	74 10                	je     80166f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80165f:	8b 10                	mov    (%eax),%edx
  801661:	8d 4a 04             	lea    0x4(%edx),%ecx
  801664:	89 08                	mov    %ecx,(%eax)
  801666:	8b 02                	mov    (%edx),%eax
  801668:	ba 00 00 00 00       	mov    $0x0,%edx
  80166d:	eb 0e                	jmp    80167d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80166f:	8b 10                	mov    (%eax),%edx
  801671:	8d 4a 04             	lea    0x4(%edx),%ecx
  801674:	89 08                	mov    %ecx,(%eax)
  801676:	8b 02                	mov    (%edx),%eax
  801678:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801685:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801689:	8b 10                	mov    (%eax),%edx
  80168b:	3b 50 04             	cmp    0x4(%eax),%edx
  80168e:	73 0a                	jae    80169a <sprintputch+0x1b>
		*b->buf++ = ch;
  801690:	8d 4a 01             	lea    0x1(%edx),%ecx
  801693:	89 08                	mov    %ecx,(%eax)
  801695:	8b 45 08             	mov    0x8(%ebp),%eax
  801698:	88 02                	mov    %al,(%edx)
}
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016a5:	50                   	push   %eax
  8016a6:	ff 75 10             	pushl  0x10(%ebp)
  8016a9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ac:	ff 75 08             	pushl  0x8(%ebp)
  8016af:	e8 05 00 00 00       	call   8016b9 <vprintfmt>
	va_end(ap);
}
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    

008016b9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	57                   	push   %edi
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 2c             	sub    $0x2c,%esp
  8016c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8016c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016c8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016cb:	eb 12                	jmp    8016df <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	0f 84 89 03 00 00    	je     801a5e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	53                   	push   %ebx
  8016d9:	50                   	push   %eax
  8016da:	ff d6                	call   *%esi
  8016dc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016df:	83 c7 01             	add    $0x1,%edi
  8016e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016e6:	83 f8 25             	cmp    $0x25,%eax
  8016e9:	75 e2                	jne    8016cd <vprintfmt+0x14>
  8016eb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016ef:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801704:	ba 00 00 00 00       	mov    $0x0,%edx
  801709:	eb 07                	jmp    801712 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80170e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801712:	8d 47 01             	lea    0x1(%edi),%eax
  801715:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801718:	0f b6 07             	movzbl (%edi),%eax
  80171b:	0f b6 c8             	movzbl %al,%ecx
  80171e:	83 e8 23             	sub    $0x23,%eax
  801721:	3c 55                	cmp    $0x55,%al
  801723:	0f 87 1a 03 00 00    	ja     801a43 <vprintfmt+0x38a>
  801729:	0f b6 c0             	movzbl %al,%eax
  80172c:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  801733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801736:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80173a:	eb d6                	jmp    801712 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80173f:	b8 00 00 00 00       	mov    $0x0,%eax
  801744:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801747:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80174a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80174e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801751:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801754:	83 fa 09             	cmp    $0x9,%edx
  801757:	77 39                	ja     801792 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801759:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80175c:	eb e9                	jmp    801747 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80175e:	8b 45 14             	mov    0x14(%ebp),%eax
  801761:	8d 48 04             	lea    0x4(%eax),%ecx
  801764:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801767:	8b 00                	mov    (%eax),%eax
  801769:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80176c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80176f:	eb 27                	jmp    801798 <vprintfmt+0xdf>
  801771:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801774:	85 c0                	test   %eax,%eax
  801776:	b9 00 00 00 00       	mov    $0x0,%ecx
  80177b:	0f 49 c8             	cmovns %eax,%ecx
  80177e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801784:	eb 8c                	jmp    801712 <vprintfmt+0x59>
  801786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801789:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801790:	eb 80                	jmp    801712 <vprintfmt+0x59>
  801792:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801795:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801798:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80179c:	0f 89 70 ff ff ff    	jns    801712 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017af:	e9 5e ff ff ff       	jmp    801712 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017b4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017ba:	e9 53 ff ff ff       	jmp    801712 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c2:	8d 50 04             	lea    0x4(%eax),%edx
  8017c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	53                   	push   %ebx
  8017cc:	ff 30                	pushl  (%eax)
  8017ce:	ff d6                	call   *%esi
			break;
  8017d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017d6:	e9 04 ff ff ff       	jmp    8016df <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017db:	8b 45 14             	mov    0x14(%ebp),%eax
  8017de:	8d 50 04             	lea    0x4(%eax),%edx
  8017e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8017e4:	8b 00                	mov    (%eax),%eax
  8017e6:	99                   	cltd   
  8017e7:	31 d0                	xor    %edx,%eax
  8017e9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017eb:	83 f8 0f             	cmp    $0xf,%eax
  8017ee:	7f 0b                	jg     8017fb <vprintfmt+0x142>
  8017f0:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8017f7:	85 d2                	test   %edx,%edx
  8017f9:	75 18                	jne    801813 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8017fb:	50                   	push   %eax
  8017fc:	68 bb 23 80 00       	push   $0x8023bb
  801801:	53                   	push   %ebx
  801802:	56                   	push   %esi
  801803:	e8 94 fe ff ff       	call   80169c <printfmt>
  801808:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80180e:	e9 cc fe ff ff       	jmp    8016df <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801813:	52                   	push   %edx
  801814:	68 01 23 80 00       	push   $0x802301
  801819:	53                   	push   %ebx
  80181a:	56                   	push   %esi
  80181b:	e8 7c fe ff ff       	call   80169c <printfmt>
  801820:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801823:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801826:	e9 b4 fe ff ff       	jmp    8016df <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80182b:	8b 45 14             	mov    0x14(%ebp),%eax
  80182e:	8d 50 04             	lea    0x4(%eax),%edx
  801831:	89 55 14             	mov    %edx,0x14(%ebp)
  801834:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801836:	85 ff                	test   %edi,%edi
  801838:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  80183d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801840:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801844:	0f 8e 94 00 00 00    	jle    8018de <vprintfmt+0x225>
  80184a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80184e:	0f 84 98 00 00 00    	je     8018ec <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	ff 75 d0             	pushl  -0x30(%ebp)
  80185a:	57                   	push   %edi
  80185b:	e8 86 02 00 00       	call   801ae6 <strnlen>
  801860:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801863:	29 c1                	sub    %eax,%ecx
  801865:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801868:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80186b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80186f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801872:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801875:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801877:	eb 0f                	jmp    801888 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801879:	83 ec 08             	sub    $0x8,%esp
  80187c:	53                   	push   %ebx
  80187d:	ff 75 e0             	pushl  -0x20(%ebp)
  801880:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801882:	83 ef 01             	sub    $0x1,%edi
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 ff                	test   %edi,%edi
  80188a:	7f ed                	jg     801879 <vprintfmt+0x1c0>
  80188c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80188f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801892:	85 c9                	test   %ecx,%ecx
  801894:	b8 00 00 00 00       	mov    $0x0,%eax
  801899:	0f 49 c1             	cmovns %ecx,%eax
  80189c:	29 c1                	sub    %eax,%ecx
  80189e:	89 75 08             	mov    %esi,0x8(%ebp)
  8018a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018a7:	89 cb                	mov    %ecx,%ebx
  8018a9:	eb 4d                	jmp    8018f8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018af:	74 1b                	je     8018cc <vprintfmt+0x213>
  8018b1:	0f be c0             	movsbl %al,%eax
  8018b4:	83 e8 20             	sub    $0x20,%eax
  8018b7:	83 f8 5e             	cmp    $0x5e,%eax
  8018ba:	76 10                	jbe    8018cc <vprintfmt+0x213>
					putch('?', putdat);
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	ff 75 0c             	pushl  0xc(%ebp)
  8018c2:	6a 3f                	push   $0x3f
  8018c4:	ff 55 08             	call   *0x8(%ebp)
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	eb 0d                	jmp    8018d9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	ff 75 0c             	pushl  0xc(%ebp)
  8018d2:	52                   	push   %edx
  8018d3:	ff 55 08             	call   *0x8(%ebp)
  8018d6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018d9:	83 eb 01             	sub    $0x1,%ebx
  8018dc:	eb 1a                	jmp    8018f8 <vprintfmt+0x23f>
  8018de:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018ea:	eb 0c                	jmp    8018f8 <vprintfmt+0x23f>
  8018ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018f8:	83 c7 01             	add    $0x1,%edi
  8018fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018ff:	0f be d0             	movsbl %al,%edx
  801902:	85 d2                	test   %edx,%edx
  801904:	74 23                	je     801929 <vprintfmt+0x270>
  801906:	85 f6                	test   %esi,%esi
  801908:	78 a1                	js     8018ab <vprintfmt+0x1f2>
  80190a:	83 ee 01             	sub    $0x1,%esi
  80190d:	79 9c                	jns    8018ab <vprintfmt+0x1f2>
  80190f:	89 df                	mov    %ebx,%edi
  801911:	8b 75 08             	mov    0x8(%ebp),%esi
  801914:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801917:	eb 18                	jmp    801931 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801919:	83 ec 08             	sub    $0x8,%esp
  80191c:	53                   	push   %ebx
  80191d:	6a 20                	push   $0x20
  80191f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801921:	83 ef 01             	sub    $0x1,%edi
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	eb 08                	jmp    801931 <vprintfmt+0x278>
  801929:	89 df                	mov    %ebx,%edi
  80192b:	8b 75 08             	mov    0x8(%ebp),%esi
  80192e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801931:	85 ff                	test   %edi,%edi
  801933:	7f e4                	jg     801919 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801935:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801938:	e9 a2 fd ff ff       	jmp    8016df <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80193d:	83 fa 01             	cmp    $0x1,%edx
  801940:	7e 16                	jle    801958 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801942:	8b 45 14             	mov    0x14(%ebp),%eax
  801945:	8d 50 08             	lea    0x8(%eax),%edx
  801948:	89 55 14             	mov    %edx,0x14(%ebp)
  80194b:	8b 50 04             	mov    0x4(%eax),%edx
  80194e:	8b 00                	mov    (%eax),%eax
  801950:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801953:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801956:	eb 32                	jmp    80198a <vprintfmt+0x2d1>
	else if (lflag)
  801958:	85 d2                	test   %edx,%edx
  80195a:	74 18                	je     801974 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80195c:	8b 45 14             	mov    0x14(%ebp),%eax
  80195f:	8d 50 04             	lea    0x4(%eax),%edx
  801962:	89 55 14             	mov    %edx,0x14(%ebp)
  801965:	8b 00                	mov    (%eax),%eax
  801967:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196a:	89 c1                	mov    %eax,%ecx
  80196c:	c1 f9 1f             	sar    $0x1f,%ecx
  80196f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801972:	eb 16                	jmp    80198a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801974:	8b 45 14             	mov    0x14(%ebp),%eax
  801977:	8d 50 04             	lea    0x4(%eax),%edx
  80197a:	89 55 14             	mov    %edx,0x14(%ebp)
  80197d:	8b 00                	mov    (%eax),%eax
  80197f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801982:	89 c1                	mov    %eax,%ecx
  801984:	c1 f9 1f             	sar    $0x1f,%ecx
  801987:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80198a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80198d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801990:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801995:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801999:	79 74                	jns    801a0f <vprintfmt+0x356>
				putch('-', putdat);
  80199b:	83 ec 08             	sub    $0x8,%esp
  80199e:	53                   	push   %ebx
  80199f:	6a 2d                	push   $0x2d
  8019a1:	ff d6                	call   *%esi
				num = -(long long) num;
  8019a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019a9:	f7 d8                	neg    %eax
  8019ab:	83 d2 00             	adc    $0x0,%edx
  8019ae:	f7 da                	neg    %edx
  8019b0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019b8:	eb 55                	jmp    801a0f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8019bd:	e8 83 fc ff ff       	call   801645 <getuint>
			base = 10;
  8019c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019c7:	eb 46                	jmp    801a0f <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8019c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8019cc:	e8 74 fc ff ff       	call   801645 <getuint>
			base = 8;
  8019d1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019d6:	eb 37                	jmp    801a0f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	53                   	push   %ebx
  8019dc:	6a 30                	push   $0x30
  8019de:	ff d6                	call   *%esi
			putch('x', putdat);
  8019e0:	83 c4 08             	add    $0x8,%esp
  8019e3:	53                   	push   %ebx
  8019e4:	6a 78                	push   $0x78
  8019e6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019eb:	8d 50 04             	lea    0x4(%eax),%edx
  8019ee:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019f1:	8b 00                	mov    (%eax),%eax
  8019f3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019f8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019fb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a00:	eb 0d                	jmp    801a0f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a02:	8d 45 14             	lea    0x14(%ebp),%eax
  801a05:	e8 3b fc ff ff       	call   801645 <getuint>
			base = 16;
  801a0a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a0f:	83 ec 0c             	sub    $0xc,%esp
  801a12:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a16:	57                   	push   %edi
  801a17:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1a:	51                   	push   %ecx
  801a1b:	52                   	push   %edx
  801a1c:	50                   	push   %eax
  801a1d:	89 da                	mov    %ebx,%edx
  801a1f:	89 f0                	mov    %esi,%eax
  801a21:	e8 70 fb ff ff       	call   801596 <printnum>
			break;
  801a26:	83 c4 20             	add    $0x20,%esp
  801a29:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a2c:	e9 ae fc ff ff       	jmp    8016df <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a31:	83 ec 08             	sub    $0x8,%esp
  801a34:	53                   	push   %ebx
  801a35:	51                   	push   %ecx
  801a36:	ff d6                	call   *%esi
			break;
  801a38:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a3e:	e9 9c fc ff ff       	jmp    8016df <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	53                   	push   %ebx
  801a47:	6a 25                	push   $0x25
  801a49:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	eb 03                	jmp    801a53 <vprintfmt+0x39a>
  801a50:	83 ef 01             	sub    $0x1,%edi
  801a53:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a57:	75 f7                	jne    801a50 <vprintfmt+0x397>
  801a59:	e9 81 fc ff ff       	jmp    8016df <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a61:	5b                   	pop    %ebx
  801a62:	5e                   	pop    %esi
  801a63:	5f                   	pop    %edi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 18             	sub    $0x18,%esp
  801a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a75:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a79:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a83:	85 c0                	test   %eax,%eax
  801a85:	74 26                	je     801aad <vsnprintf+0x47>
  801a87:	85 d2                	test   %edx,%edx
  801a89:	7e 22                	jle    801aad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a8b:	ff 75 14             	pushl  0x14(%ebp)
  801a8e:	ff 75 10             	pushl  0x10(%ebp)
  801a91:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a94:	50                   	push   %eax
  801a95:	68 7f 16 80 00       	push   $0x80167f
  801a9a:	e8 1a fc ff ff       	call   8016b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aa2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	eb 05                	jmp    801ab2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801aba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801abd:	50                   	push   %eax
  801abe:	ff 75 10             	pushl  0x10(%ebp)
  801ac1:	ff 75 0c             	pushl  0xc(%ebp)
  801ac4:	ff 75 08             	pushl  0x8(%ebp)
  801ac7:	e8 9a ff ff ff       	call   801a66 <vsnprintf>
	va_end(ap);

	return rc;
}
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ad4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad9:	eb 03                	jmp    801ade <strlen+0x10>
		n++;
  801adb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ade:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ae2:	75 f7                	jne    801adb <strlen+0xd>
		n++;
	return n;
}
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aec:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	eb 03                	jmp    801af9 <strnlen+0x13>
		n++;
  801af6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801af9:	39 c2                	cmp    %eax,%edx
  801afb:	74 08                	je     801b05 <strnlen+0x1f>
  801afd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b01:	75 f3                	jne    801af6 <strnlen+0x10>
  801b03:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	53                   	push   %ebx
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b11:	89 c2                	mov    %eax,%edx
  801b13:	83 c2 01             	add    $0x1,%edx
  801b16:	83 c1 01             	add    $0x1,%ecx
  801b19:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b1d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b20:	84 db                	test   %bl,%bl
  801b22:	75 ef                	jne    801b13 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b24:	5b                   	pop    %ebx
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	53                   	push   %ebx
  801b2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b2e:	53                   	push   %ebx
  801b2f:	e8 9a ff ff ff       	call   801ace <strlen>
  801b34:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b37:	ff 75 0c             	pushl  0xc(%ebp)
  801b3a:	01 d8                	add    %ebx,%eax
  801b3c:	50                   	push   %eax
  801b3d:	e8 c5 ff ff ff       	call   801b07 <strcpy>
	return dst;
}
  801b42:	89 d8                	mov    %ebx,%eax
  801b44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	8b 75 08             	mov    0x8(%ebp),%esi
  801b51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b54:	89 f3                	mov    %esi,%ebx
  801b56:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b59:	89 f2                	mov    %esi,%edx
  801b5b:	eb 0f                	jmp    801b6c <strncpy+0x23>
		*dst++ = *src;
  801b5d:	83 c2 01             	add    $0x1,%edx
  801b60:	0f b6 01             	movzbl (%ecx),%eax
  801b63:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b66:	80 39 01             	cmpb   $0x1,(%ecx)
  801b69:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b6c:	39 da                	cmp    %ebx,%edx
  801b6e:	75 ed                	jne    801b5d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b70:	89 f0                	mov    %esi,%eax
  801b72:	5b                   	pop    %ebx
  801b73:	5e                   	pop    %esi
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	56                   	push   %esi
  801b7a:	53                   	push   %ebx
  801b7b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b81:	8b 55 10             	mov    0x10(%ebp),%edx
  801b84:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b86:	85 d2                	test   %edx,%edx
  801b88:	74 21                	je     801bab <strlcpy+0x35>
  801b8a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801b8e:	89 f2                	mov    %esi,%edx
  801b90:	eb 09                	jmp    801b9b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801b92:	83 c2 01             	add    $0x1,%edx
  801b95:	83 c1 01             	add    $0x1,%ecx
  801b98:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b9b:	39 c2                	cmp    %eax,%edx
  801b9d:	74 09                	je     801ba8 <strlcpy+0x32>
  801b9f:	0f b6 19             	movzbl (%ecx),%ebx
  801ba2:	84 db                	test   %bl,%bl
  801ba4:	75 ec                	jne    801b92 <strlcpy+0x1c>
  801ba6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ba8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bab:	29 f0                	sub    %esi,%eax
}
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bba:	eb 06                	jmp    801bc2 <strcmp+0x11>
		p++, q++;
  801bbc:	83 c1 01             	add    $0x1,%ecx
  801bbf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bc2:	0f b6 01             	movzbl (%ecx),%eax
  801bc5:	84 c0                	test   %al,%al
  801bc7:	74 04                	je     801bcd <strcmp+0x1c>
  801bc9:	3a 02                	cmp    (%edx),%al
  801bcb:	74 ef                	je     801bbc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801bcd:	0f b6 c0             	movzbl %al,%eax
  801bd0:	0f b6 12             	movzbl (%edx),%edx
  801bd3:	29 d0                	sub    %edx,%eax
}
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	53                   	push   %ebx
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be1:	89 c3                	mov    %eax,%ebx
  801be3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801be6:	eb 06                	jmp    801bee <strncmp+0x17>
		n--, p++, q++;
  801be8:	83 c0 01             	add    $0x1,%eax
  801beb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bee:	39 d8                	cmp    %ebx,%eax
  801bf0:	74 15                	je     801c07 <strncmp+0x30>
  801bf2:	0f b6 08             	movzbl (%eax),%ecx
  801bf5:	84 c9                	test   %cl,%cl
  801bf7:	74 04                	je     801bfd <strncmp+0x26>
  801bf9:	3a 0a                	cmp    (%edx),%cl
  801bfb:	74 eb                	je     801be8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801bfd:	0f b6 00             	movzbl (%eax),%eax
  801c00:	0f b6 12             	movzbl (%edx),%edx
  801c03:	29 d0                	sub    %edx,%eax
  801c05:	eb 05                	jmp    801c0c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c0c:	5b                   	pop    %ebx
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	8b 45 08             	mov    0x8(%ebp),%eax
  801c15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c19:	eb 07                	jmp    801c22 <strchr+0x13>
		if (*s == c)
  801c1b:	38 ca                	cmp    %cl,%dl
  801c1d:	74 0f                	je     801c2e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c1f:	83 c0 01             	add    $0x1,%eax
  801c22:	0f b6 10             	movzbl (%eax),%edx
  801c25:	84 d2                	test   %dl,%dl
  801c27:	75 f2                	jne    801c1b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
  801c36:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c3a:	eb 03                	jmp    801c3f <strfind+0xf>
  801c3c:	83 c0 01             	add    $0x1,%eax
  801c3f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c42:	38 ca                	cmp    %cl,%dl
  801c44:	74 04                	je     801c4a <strfind+0x1a>
  801c46:	84 d2                	test   %dl,%dl
  801c48:	75 f2                	jne    801c3c <strfind+0xc>
			break;
	return (char *) s;
}
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	57                   	push   %edi
  801c50:	56                   	push   %esi
  801c51:	53                   	push   %ebx
  801c52:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c58:	85 c9                	test   %ecx,%ecx
  801c5a:	74 36                	je     801c92 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c5c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c62:	75 28                	jne    801c8c <memset+0x40>
  801c64:	f6 c1 03             	test   $0x3,%cl
  801c67:	75 23                	jne    801c8c <memset+0x40>
		c &= 0xFF;
  801c69:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c6d:	89 d3                	mov    %edx,%ebx
  801c6f:	c1 e3 08             	shl    $0x8,%ebx
  801c72:	89 d6                	mov    %edx,%esi
  801c74:	c1 e6 18             	shl    $0x18,%esi
  801c77:	89 d0                	mov    %edx,%eax
  801c79:	c1 e0 10             	shl    $0x10,%eax
  801c7c:	09 f0                	or     %esi,%eax
  801c7e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	09 d0                	or     %edx,%eax
  801c84:	c1 e9 02             	shr    $0x2,%ecx
  801c87:	fc                   	cld    
  801c88:	f3 ab                	rep stos %eax,%es:(%edi)
  801c8a:	eb 06                	jmp    801c92 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8f:	fc                   	cld    
  801c90:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c92:	89 f8                	mov    %edi,%eax
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	57                   	push   %edi
  801c9d:	56                   	push   %esi
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ca4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ca7:	39 c6                	cmp    %eax,%esi
  801ca9:	73 35                	jae    801ce0 <memmove+0x47>
  801cab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cae:	39 d0                	cmp    %edx,%eax
  801cb0:	73 2e                	jae    801ce0 <memmove+0x47>
		s += n;
		d += n;
  801cb2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cb5:	89 d6                	mov    %edx,%esi
  801cb7:	09 fe                	or     %edi,%esi
  801cb9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cbf:	75 13                	jne    801cd4 <memmove+0x3b>
  801cc1:	f6 c1 03             	test   $0x3,%cl
  801cc4:	75 0e                	jne    801cd4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801cc6:	83 ef 04             	sub    $0x4,%edi
  801cc9:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ccc:	c1 e9 02             	shr    $0x2,%ecx
  801ccf:	fd                   	std    
  801cd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cd2:	eb 09                	jmp    801cdd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801cd4:	83 ef 01             	sub    $0x1,%edi
  801cd7:	8d 72 ff             	lea    -0x1(%edx),%esi
  801cda:	fd                   	std    
  801cdb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801cdd:	fc                   	cld    
  801cde:	eb 1d                	jmp    801cfd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ce0:	89 f2                	mov    %esi,%edx
  801ce2:	09 c2                	or     %eax,%edx
  801ce4:	f6 c2 03             	test   $0x3,%dl
  801ce7:	75 0f                	jne    801cf8 <memmove+0x5f>
  801ce9:	f6 c1 03             	test   $0x3,%cl
  801cec:	75 0a                	jne    801cf8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801cee:	c1 e9 02             	shr    $0x2,%ecx
  801cf1:	89 c7                	mov    %eax,%edi
  801cf3:	fc                   	cld    
  801cf4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cf6:	eb 05                	jmp    801cfd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801cf8:	89 c7                	mov    %eax,%edi
  801cfa:	fc                   	cld    
  801cfb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801cfd:	5e                   	pop    %esi
  801cfe:	5f                   	pop    %edi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d04:	ff 75 10             	pushl  0x10(%ebp)
  801d07:	ff 75 0c             	pushl  0xc(%ebp)
  801d0a:	ff 75 08             	pushl  0x8(%ebp)
  801d0d:	e8 87 ff ff ff       	call   801c99 <memmove>
}
  801d12:	c9                   	leave  
  801d13:	c3                   	ret    

00801d14 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1f:	89 c6                	mov    %eax,%esi
  801d21:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d24:	eb 1a                	jmp    801d40 <memcmp+0x2c>
		if (*s1 != *s2)
  801d26:	0f b6 08             	movzbl (%eax),%ecx
  801d29:	0f b6 1a             	movzbl (%edx),%ebx
  801d2c:	38 d9                	cmp    %bl,%cl
  801d2e:	74 0a                	je     801d3a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d30:	0f b6 c1             	movzbl %cl,%eax
  801d33:	0f b6 db             	movzbl %bl,%ebx
  801d36:	29 d8                	sub    %ebx,%eax
  801d38:	eb 0f                	jmp    801d49 <memcmp+0x35>
		s1++, s2++;
  801d3a:	83 c0 01             	add    $0x1,%eax
  801d3d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d40:	39 f0                	cmp    %esi,%eax
  801d42:	75 e2                	jne    801d26 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d49:	5b                   	pop    %ebx
  801d4a:	5e                   	pop    %esi
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    

00801d4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	53                   	push   %ebx
  801d51:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d54:	89 c1                	mov    %eax,%ecx
  801d56:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d59:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d5d:	eb 0a                	jmp    801d69 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d5f:	0f b6 10             	movzbl (%eax),%edx
  801d62:	39 da                	cmp    %ebx,%edx
  801d64:	74 07                	je     801d6d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d66:	83 c0 01             	add    $0x1,%eax
  801d69:	39 c8                	cmp    %ecx,%eax
  801d6b:	72 f2                	jb     801d5f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d6d:	5b                   	pop    %ebx
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	57                   	push   %edi
  801d74:	56                   	push   %esi
  801d75:	53                   	push   %ebx
  801d76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d7c:	eb 03                	jmp    801d81 <strtol+0x11>
		s++;
  801d7e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d81:	0f b6 01             	movzbl (%ecx),%eax
  801d84:	3c 20                	cmp    $0x20,%al
  801d86:	74 f6                	je     801d7e <strtol+0xe>
  801d88:	3c 09                	cmp    $0x9,%al
  801d8a:	74 f2                	je     801d7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d8c:	3c 2b                	cmp    $0x2b,%al
  801d8e:	75 0a                	jne    801d9a <strtol+0x2a>
		s++;
  801d90:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801d93:	bf 00 00 00 00       	mov    $0x0,%edi
  801d98:	eb 11                	jmp    801dab <strtol+0x3b>
  801d9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801d9f:	3c 2d                	cmp    $0x2d,%al
  801da1:	75 08                	jne    801dab <strtol+0x3b>
		s++, neg = 1;
  801da3:	83 c1 01             	add    $0x1,%ecx
  801da6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801db1:	75 15                	jne    801dc8 <strtol+0x58>
  801db3:	80 39 30             	cmpb   $0x30,(%ecx)
  801db6:	75 10                	jne    801dc8 <strtol+0x58>
  801db8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dbc:	75 7c                	jne    801e3a <strtol+0xca>
		s += 2, base = 16;
  801dbe:	83 c1 02             	add    $0x2,%ecx
  801dc1:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dc6:	eb 16                	jmp    801dde <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801dc8:	85 db                	test   %ebx,%ebx
  801dca:	75 12                	jne    801dde <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801dcc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801dd1:	80 39 30             	cmpb   $0x30,(%ecx)
  801dd4:	75 08                	jne    801dde <strtol+0x6e>
		s++, base = 8;
  801dd6:	83 c1 01             	add    $0x1,%ecx
  801dd9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801dde:	b8 00 00 00 00       	mov    $0x0,%eax
  801de3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801de6:	0f b6 11             	movzbl (%ecx),%edx
  801de9:	8d 72 d0             	lea    -0x30(%edx),%esi
  801dec:	89 f3                	mov    %esi,%ebx
  801dee:	80 fb 09             	cmp    $0x9,%bl
  801df1:	77 08                	ja     801dfb <strtol+0x8b>
			dig = *s - '0';
  801df3:	0f be d2             	movsbl %dl,%edx
  801df6:	83 ea 30             	sub    $0x30,%edx
  801df9:	eb 22                	jmp    801e1d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801dfb:	8d 72 9f             	lea    -0x61(%edx),%esi
  801dfe:	89 f3                	mov    %esi,%ebx
  801e00:	80 fb 19             	cmp    $0x19,%bl
  801e03:	77 08                	ja     801e0d <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e05:	0f be d2             	movsbl %dl,%edx
  801e08:	83 ea 57             	sub    $0x57,%edx
  801e0b:	eb 10                	jmp    801e1d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e10:	89 f3                	mov    %esi,%ebx
  801e12:	80 fb 19             	cmp    $0x19,%bl
  801e15:	77 16                	ja     801e2d <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e17:	0f be d2             	movsbl %dl,%edx
  801e1a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e20:	7d 0b                	jge    801e2d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e22:	83 c1 01             	add    $0x1,%ecx
  801e25:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e29:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e2b:	eb b9                	jmp    801de6 <strtol+0x76>

	if (endptr)
  801e2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e31:	74 0d                	je     801e40 <strtol+0xd0>
		*endptr = (char *) s;
  801e33:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e36:	89 0e                	mov    %ecx,(%esi)
  801e38:	eb 06                	jmp    801e40 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e3a:	85 db                	test   %ebx,%ebx
  801e3c:	74 98                	je     801dd6 <strtol+0x66>
  801e3e:	eb 9e                	jmp    801dde <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e40:	89 c2                	mov    %eax,%edx
  801e42:	f7 da                	neg    %edx
  801e44:	85 ff                	test   %edi,%edi
  801e46:	0f 45 c2             	cmovne %edx,%eax
}
  801e49:	5b                   	pop    %ebx
  801e4a:	5e                   	pop    %esi
  801e4b:	5f                   	pop    %edi
  801e4c:	5d                   	pop    %ebp
  801e4d:	c3                   	ret    

00801e4e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	56                   	push   %esi
  801e52:	53                   	push   %ebx
  801e53:	8b 75 08             	mov    0x8(%ebp),%esi
  801e56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e5c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e5e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e63:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	50                   	push   %eax
  801e6a:	e8 96 e4 ff ff       	call   800305 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	85 f6                	test   %esi,%esi
  801e74:	74 14                	je     801e8a <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e76:	ba 00 00 00 00       	mov    $0x0,%edx
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	78 09                	js     801e88 <ipc_recv+0x3a>
  801e7f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e85:	8b 52 74             	mov    0x74(%edx),%edx
  801e88:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e8a:	85 db                	test   %ebx,%ebx
  801e8c:	74 14                	je     801ea2 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801e93:	85 c0                	test   %eax,%eax
  801e95:	78 09                	js     801ea0 <ipc_recv+0x52>
  801e97:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e9d:	8b 52 78             	mov    0x78(%edx),%edx
  801ea0:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 08                	js     801eae <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ea6:	a1 08 40 80 00       	mov    0x804008,%eax
  801eab:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    

00801eb5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	57                   	push   %edi
  801eb9:	56                   	push   %esi
  801eba:	53                   	push   %ebx
  801ebb:	83 ec 0c             	sub    $0xc,%esp
  801ebe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ec7:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ec9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ece:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ed1:	ff 75 14             	pushl  0x14(%ebp)
  801ed4:	53                   	push   %ebx
  801ed5:	56                   	push   %esi
  801ed6:	57                   	push   %edi
  801ed7:	e8 06 e4 ff ff       	call   8002e2 <sys_ipc_try_send>

		if (err < 0) {
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	79 1e                	jns    801f01 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ee3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee6:	75 07                	jne    801eef <ipc_send+0x3a>
				sys_yield();
  801ee8:	e8 49 e2 ff ff       	call   800136 <sys_yield>
  801eed:	eb e2                	jmp    801ed1 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801eef:	50                   	push   %eax
  801ef0:	68 a0 26 80 00       	push   $0x8026a0
  801ef5:	6a 49                	push   $0x49
  801ef7:	68 ad 26 80 00       	push   $0x8026ad
  801efc:	e8 a8 f5 ff ff       	call   8014a9 <_panic>
		}

	} while (err < 0);

}
  801f01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f04:	5b                   	pop    %ebx
  801f05:	5e                   	pop    %esi
  801f06:	5f                   	pop    %edi
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f0f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f14:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f17:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f1d:	8b 52 50             	mov    0x50(%edx),%edx
  801f20:	39 ca                	cmp    %ecx,%edx
  801f22:	75 0d                	jne    801f31 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f24:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f27:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f2c:	8b 40 48             	mov    0x48(%eax),%eax
  801f2f:	eb 0f                	jmp    801f40 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f31:	83 c0 01             	add    $0x1,%eax
  801f34:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f39:	75 d9                	jne    801f14 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f48:	89 d0                	mov    %edx,%eax
  801f4a:	c1 e8 16             	shr    $0x16,%eax
  801f4d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f54:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f59:	f6 c1 01             	test   $0x1,%cl
  801f5c:	74 1d                	je     801f7b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f5e:	c1 ea 0c             	shr    $0xc,%edx
  801f61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f68:	f6 c2 01             	test   $0x1,%dl
  801f6b:	74 0e                	je     801f7b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f6d:	c1 ea 0c             	shr    $0xc,%edx
  801f70:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f77:	ef 
  801f78:	0f b7 c0             	movzwl %ax,%eax
}
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    
  801f7d:	66 90                	xchg   %ax,%ax
  801f7f:	90                   	nop

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 f6                	test   %esi,%esi
  801f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9d:	89 ca                	mov    %ecx,%edx
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	75 3d                	jne    801fe0 <__udivdi3+0x60>
  801fa3:	39 cf                	cmp    %ecx,%edi
  801fa5:	0f 87 c5 00 00 00    	ja     802070 <__udivdi3+0xf0>
  801fab:	85 ff                	test   %edi,%edi
  801fad:	89 fd                	mov    %edi,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f7                	div    %edi
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 c8                	mov    %ecx,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	89 cf                	mov    %ecx,%edi
  801fc8:	f7 f5                	div    %ebp
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 1c             	add    $0x1c,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	90                   	nop
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 ce                	cmp    %ecx,%esi
  801fe2:	77 74                	ja     802058 <__udivdi3+0xd8>
  801fe4:	0f bd fe             	bsr    %esi,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0x108>
  801ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	29 fb                	sub    %edi,%ebx
  801ffb:	d3 e6                	shl    %cl,%esi
  801ffd:	89 d9                	mov    %ebx,%ecx
  801fff:	d3 ed                	shr    %cl,%ebp
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e0                	shl    %cl,%eax
  802005:	09 ee                	or     %ebp,%esi
  802007:	89 d9                	mov    %ebx,%ecx
  802009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200d:	89 d5                	mov    %edx,%ebp
  80200f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802013:	d3 ed                	shr    %cl,%ebp
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 d9                	mov    %ebx,%ecx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	09 c2                	or     %eax,%edx
  80201f:	89 d0                	mov    %edx,%eax
  802021:	89 ea                	mov    %ebp,%edx
  802023:	f7 f6                	div    %esi
  802025:	89 d5                	mov    %edx,%ebp
  802027:	89 c3                	mov    %eax,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	72 10                	jb     802041 <__udivdi3+0xc1>
  802031:	8b 74 24 08          	mov    0x8(%esp),%esi
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e6                	shl    %cl,%esi
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	73 07                	jae    802044 <__udivdi3+0xc4>
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	75 03                	jne    802044 <__udivdi3+0xc4>
  802041:	83 eb 01             	sub    $0x1,%ebx
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 d8                	mov    %ebx,%eax
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	31 db                	xor    %ebx,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	f7 f7                	div    %edi
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 c3                	mov    %eax,%ebx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	39 ce                	cmp    %ecx,%esi
  80208a:	72 0c                	jb     802098 <__udivdi3+0x118>
  80208c:	31 db                	xor    %ebx,%ebx
  80208e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802092:	0f 87 34 ff ff ff    	ja     801fcc <__udivdi3+0x4c>
  802098:	bb 01 00 00 00       	mov    $0x1,%ebx
  80209d:	e9 2a ff ff ff       	jmp    801fcc <__udivdi3+0x4c>
  8020a2:	66 90                	xchg   %ax,%ax
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 d2                	test   %edx,%edx
  8020c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f3                	mov    %esi,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	75 1c                	jne    8020f8 <__umoddi3+0x48>
  8020dc:	39 f7                	cmp    %esi,%edi
  8020de:	76 50                	jbe    802130 <__umoddi3+0x80>
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	f7 f7                	div    %edi
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	89 d0                	mov    %edx,%eax
  8020fc:	77 52                	ja     802150 <__umoddi3+0xa0>
  8020fe:	0f bd ea             	bsr    %edx,%ebp
  802101:	83 f5 1f             	xor    $0x1f,%ebp
  802104:	75 5a                	jne    802160 <__umoddi3+0xb0>
  802106:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80210a:	0f 82 e0 00 00 00    	jb     8021f0 <__umoddi3+0x140>
  802110:	39 0c 24             	cmp    %ecx,(%esp)
  802113:	0f 86 d7 00 00 00    	jbe    8021f0 <__umoddi3+0x140>
  802119:	8b 44 24 08          	mov    0x8(%esp),%eax
  80211d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	85 ff                	test   %edi,%edi
  802132:	89 fd                	mov    %edi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f7                	div    %edi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f5                	div    %ebp
  802147:	89 c8                	mov    %ecx,%eax
  802149:	f7 f5                	div    %ebp
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	eb 99                	jmp    8020e8 <__umoddi3+0x38>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 34 24             	mov    (%esp),%esi
  802163:	bf 20 00 00 00       	mov    $0x20,%edi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ef                	sub    %ebp,%edi
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 f9                	mov    %edi,%ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	d3 ea                	shr    %cl,%edx
  802174:	89 e9                	mov    %ebp,%ecx
  802176:	09 c2                	or     %eax,%edx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 14 24             	mov    %edx,(%esp)
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	89 f9                	mov    %edi,%ecx
  802183:	89 54 24 04          	mov    %edx,0x4(%esp)
  802187:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	89 c6                	mov    %eax,%esi
  802191:	d3 e3                	shl    %cl,%ebx
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 d0                	mov    %edx,%eax
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	09 d8                	or     %ebx,%eax
  80219d:	89 d3                	mov    %edx,%ebx
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	f7 34 24             	divl   (%esp)
  8021a4:	89 d6                	mov    %edx,%esi
  8021a6:	d3 e3                	shl    %cl,%ebx
  8021a8:	f7 64 24 04          	mull   0x4(%esp)
  8021ac:	39 d6                	cmp    %edx,%esi
  8021ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	72 08                	jb     8021c0 <__umoddi3+0x110>
  8021b8:	75 11                	jne    8021cb <__umoddi3+0x11b>
  8021ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021be:	73 0b                	jae    8021cb <__umoddi3+0x11b>
  8021c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021c4:	1b 14 24             	sbb    (%esp),%edx
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021cf:	29 da                	sub    %ebx,%edx
  8021d1:	19 ce                	sbb    %ecx,%esi
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e0                	shl    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	09 d0                	or     %edx,%eax
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	83 c4 1c             	add    $0x1c,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	29 f9                	sub    %edi,%ecx
  8021f2:	19 d6                	sbb    %edx,%esi
  8021f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fc:	e9 18 ff ff ff       	jmp    802119 <__umoddi3+0x69>
