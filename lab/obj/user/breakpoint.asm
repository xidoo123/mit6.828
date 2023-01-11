
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
  800085:	e8 2a 05 00 00       	call   8005b4 <close_all>
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
  8000fe:	68 aa 22 80 00       	push   $0x8022aa
  800103:	6a 23                	push   $0x23
  800105:	68 c7 22 80 00       	push   $0x8022c7
  80010a:	e8 1e 14 00 00       	call   80152d <_panic>

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
  80017f:	68 aa 22 80 00       	push   $0x8022aa
  800184:	6a 23                	push   $0x23
  800186:	68 c7 22 80 00       	push   $0x8022c7
  80018b:	e8 9d 13 00 00       	call   80152d <_panic>

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
  8001c1:	68 aa 22 80 00       	push   $0x8022aa
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 c7 22 80 00       	push   $0x8022c7
  8001cd:	e8 5b 13 00 00       	call   80152d <_panic>

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
  800203:	68 aa 22 80 00       	push   $0x8022aa
  800208:	6a 23                	push   $0x23
  80020a:	68 c7 22 80 00       	push   $0x8022c7
  80020f:	e8 19 13 00 00       	call   80152d <_panic>

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
  800245:	68 aa 22 80 00       	push   $0x8022aa
  80024a:	6a 23                	push   $0x23
  80024c:	68 c7 22 80 00       	push   $0x8022c7
  800251:	e8 d7 12 00 00       	call   80152d <_panic>

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
  800287:	68 aa 22 80 00       	push   $0x8022aa
  80028c:	6a 23                	push   $0x23
  80028e:	68 c7 22 80 00       	push   $0x8022c7
  800293:	e8 95 12 00 00       	call   80152d <_panic>

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
  8002c9:	68 aa 22 80 00       	push   $0x8022aa
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 c7 22 80 00       	push   $0x8022c7
  8002d5:	e8 53 12 00 00       	call   80152d <_panic>

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
  80032d:	68 aa 22 80 00       	push   $0x8022aa
  800332:	6a 23                	push   $0x23
  800334:	68 c7 22 80 00       	push   $0x8022c7
  800339:	e8 ef 11 00 00       	call   80152d <_panic>

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
  80038e:	68 aa 22 80 00       	push   $0x8022aa
  800393:	6a 23                	push   $0x23
  800395:	68 c7 22 80 00       	push   $0x8022c7
  80039a:	e8 8e 11 00 00       	call   80152d <_panic>

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

008003a7 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	57                   	push   %edi
  8003ab:	56                   	push   %esi
  8003ac:	53                   	push   %ebx
  8003ad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b5:	b8 10 00 00 00       	mov    $0x10,%eax
  8003ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c0:	89 df                	mov    %ebx,%edi
  8003c2:	89 de                	mov    %ebx,%esi
  8003c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	7e 17                	jle    8003e1 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ca:	83 ec 0c             	sub    $0xc,%esp
  8003cd:	50                   	push   %eax
  8003ce:	6a 10                	push   $0x10
  8003d0:	68 aa 22 80 00       	push   $0x8022aa
  8003d5:	6a 23                	push   $0x23
  8003d7:	68 c7 22 80 00       	push   $0x8022c7
  8003dc:	e8 4c 11 00 00       	call   80152d <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8003e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f4:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    

008003f9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	05 00 00 00 30       	add    $0x30000000,%eax
  800404:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800409:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800416:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80041b:	89 c2                	mov    %eax,%edx
  80041d:	c1 ea 16             	shr    $0x16,%edx
  800420:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800427:	f6 c2 01             	test   $0x1,%dl
  80042a:	74 11                	je     80043d <fd_alloc+0x2d>
  80042c:	89 c2                	mov    %eax,%edx
  80042e:	c1 ea 0c             	shr    $0xc,%edx
  800431:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800438:	f6 c2 01             	test   $0x1,%dl
  80043b:	75 09                	jne    800446 <fd_alloc+0x36>
			*fd_store = fd;
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 17                	jmp    80045d <fd_alloc+0x4d>
  800446:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80044b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800450:	75 c9                	jne    80041b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800452:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800458:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80045d:	5d                   	pop    %ebp
  80045e:	c3                   	ret    

0080045f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800465:	83 f8 1f             	cmp    $0x1f,%eax
  800468:	77 36                	ja     8004a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80046a:	c1 e0 0c             	shl    $0xc,%eax
  80046d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800472:	89 c2                	mov    %eax,%edx
  800474:	c1 ea 16             	shr    $0x16,%edx
  800477:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80047e:	f6 c2 01             	test   $0x1,%dl
  800481:	74 24                	je     8004a7 <fd_lookup+0x48>
  800483:	89 c2                	mov    %eax,%edx
  800485:	c1 ea 0c             	shr    $0xc,%edx
  800488:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80048f:	f6 c2 01             	test   $0x1,%dl
  800492:	74 1a                	je     8004ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800494:	8b 55 0c             	mov    0xc(%ebp),%edx
  800497:	89 02                	mov    %eax,(%edx)
	return 0;
  800499:	b8 00 00 00 00       	mov    $0x0,%eax
  80049e:	eb 13                	jmp    8004b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a5:	eb 0c                	jmp    8004b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ac:	eb 05                	jmp    8004b3 <fd_lookup+0x54>
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004b3:	5d                   	pop    %ebp
  8004b4:	c3                   	ret    

008004b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004b5:	55                   	push   %ebp
  8004b6:	89 e5                	mov    %esp,%ebp
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004be:	ba 54 23 80 00       	mov    $0x802354,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004c3:	eb 13                	jmp    8004d8 <dev_lookup+0x23>
  8004c5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004c8:	39 08                	cmp    %ecx,(%eax)
  8004ca:	75 0c                	jne    8004d8 <dev_lookup+0x23>
			*dev = devtab[i];
  8004cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	eb 2e                	jmp    800506 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004d8:	8b 02                	mov    (%edx),%eax
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	75 e7                	jne    8004c5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004de:	a1 08 40 80 00       	mov    0x804008,%eax
  8004e3:	8b 40 48             	mov    0x48(%eax),%eax
  8004e6:	83 ec 04             	sub    $0x4,%esp
  8004e9:	51                   	push   %ecx
  8004ea:	50                   	push   %eax
  8004eb:	68 d8 22 80 00       	push   $0x8022d8
  8004f0:	e8 11 11 00 00       	call   801606 <cprintf>
	*dev = 0;
  8004f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800506:	c9                   	leave  
  800507:	c3                   	ret    

00800508 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	56                   	push   %esi
  80050c:	53                   	push   %ebx
  80050d:	83 ec 10             	sub    $0x10,%esp
  800510:	8b 75 08             	mov    0x8(%ebp),%esi
  800513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800519:	50                   	push   %eax
  80051a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800520:	c1 e8 0c             	shr    $0xc,%eax
  800523:	50                   	push   %eax
  800524:	e8 36 ff ff ff       	call   80045f <fd_lookup>
  800529:	83 c4 08             	add    $0x8,%esp
  80052c:	85 c0                	test   %eax,%eax
  80052e:	78 05                	js     800535 <fd_close+0x2d>
	    || fd != fd2)
  800530:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800533:	74 0c                	je     800541 <fd_close+0x39>
		return (must_exist ? r : 0);
  800535:	84 db                	test   %bl,%bl
  800537:	ba 00 00 00 00       	mov    $0x0,%edx
  80053c:	0f 44 c2             	cmove  %edx,%eax
  80053f:	eb 41                	jmp    800582 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800547:	50                   	push   %eax
  800548:	ff 36                	pushl  (%esi)
  80054a:	e8 66 ff ff ff       	call   8004b5 <dev_lookup>
  80054f:	89 c3                	mov    %eax,%ebx
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	85 c0                	test   %eax,%eax
  800556:	78 1a                	js     800572 <fd_close+0x6a>
		if (dev->dev_close)
  800558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80055b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80055e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800563:	85 c0                	test   %eax,%eax
  800565:	74 0b                	je     800572 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	ff d0                	call   *%eax
  80056d:	89 c3                	mov    %eax,%ebx
  80056f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	56                   	push   %esi
  800576:	6a 00                	push   $0x0
  800578:	e8 5d fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	89 d8                	mov    %ebx,%eax
}
  800582:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800585:	5b                   	pop    %ebx
  800586:	5e                   	pop    %esi
  800587:	5d                   	pop    %ebp
  800588:	c3                   	ret    

00800589 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800589:	55                   	push   %ebp
  80058a:	89 e5                	mov    %esp,%ebp
  80058c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80058f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800592:	50                   	push   %eax
  800593:	ff 75 08             	pushl  0x8(%ebp)
  800596:	e8 c4 fe ff ff       	call   80045f <fd_lookup>
  80059b:	83 c4 08             	add    $0x8,%esp
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	78 10                	js     8005b2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	6a 01                	push   $0x1
  8005a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8005aa:	e8 59 ff ff ff       	call   800508 <fd_close>
  8005af:	83 c4 10             	add    $0x10,%esp
}
  8005b2:	c9                   	leave  
  8005b3:	c3                   	ret    

008005b4 <close_all>:

void
close_all(void)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	53                   	push   %ebx
  8005b8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005c0:	83 ec 0c             	sub    $0xc,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	e8 c0 ff ff ff       	call   800589 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c9:	83 c3 01             	add    $0x1,%ebx
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	83 fb 20             	cmp    $0x20,%ebx
  8005d2:	75 ec                	jne    8005c0 <close_all+0xc>
		close(i);
}
  8005d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005d7:	c9                   	leave  
  8005d8:	c3                   	ret    

008005d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005d9:	55                   	push   %ebp
  8005da:	89 e5                	mov    %esp,%ebp
  8005dc:	57                   	push   %edi
  8005dd:	56                   	push   %esi
  8005de:	53                   	push   %ebx
  8005df:	83 ec 2c             	sub    $0x2c,%esp
  8005e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005e8:	50                   	push   %eax
  8005e9:	ff 75 08             	pushl  0x8(%ebp)
  8005ec:	e8 6e fe ff ff       	call   80045f <fd_lookup>
  8005f1:	83 c4 08             	add    $0x8,%esp
  8005f4:	85 c0                	test   %eax,%eax
  8005f6:	0f 88 c1 00 00 00    	js     8006bd <dup+0xe4>
		return r;
	close(newfdnum);
  8005fc:	83 ec 0c             	sub    $0xc,%esp
  8005ff:	56                   	push   %esi
  800600:	e8 84 ff ff ff       	call   800589 <close>

	newfd = INDEX2FD(newfdnum);
  800605:	89 f3                	mov    %esi,%ebx
  800607:	c1 e3 0c             	shl    $0xc,%ebx
  80060a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800610:	83 c4 04             	add    $0x4,%esp
  800613:	ff 75 e4             	pushl  -0x1c(%ebp)
  800616:	e8 de fd ff ff       	call   8003f9 <fd2data>
  80061b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80061d:	89 1c 24             	mov    %ebx,(%esp)
  800620:	e8 d4 fd ff ff       	call   8003f9 <fd2data>
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80062b:	89 f8                	mov    %edi,%eax
  80062d:	c1 e8 16             	shr    $0x16,%eax
  800630:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800637:	a8 01                	test   $0x1,%al
  800639:	74 37                	je     800672 <dup+0x99>
  80063b:	89 f8                	mov    %edi,%eax
  80063d:	c1 e8 0c             	shr    $0xc,%eax
  800640:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800647:	f6 c2 01             	test   $0x1,%dl
  80064a:	74 26                	je     800672 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80064c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	25 07 0e 00 00       	and    $0xe07,%eax
  80065b:	50                   	push   %eax
  80065c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065f:	6a 00                	push   $0x0
  800661:	57                   	push   %edi
  800662:	6a 00                	push   $0x0
  800664:	e8 2f fb ff ff       	call   800198 <sys_page_map>
  800669:	89 c7                	mov    %eax,%edi
  80066b:	83 c4 20             	add    $0x20,%esp
  80066e:	85 c0                	test   %eax,%eax
  800670:	78 2e                	js     8006a0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800672:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800675:	89 d0                	mov    %edx,%eax
  800677:	c1 e8 0c             	shr    $0xc,%eax
  80067a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800681:	83 ec 0c             	sub    $0xc,%esp
  800684:	25 07 0e 00 00       	and    $0xe07,%eax
  800689:	50                   	push   %eax
  80068a:	53                   	push   %ebx
  80068b:	6a 00                	push   $0x0
  80068d:	52                   	push   %edx
  80068e:	6a 00                	push   $0x0
  800690:	e8 03 fb ff ff       	call   800198 <sys_page_map>
  800695:	89 c7                	mov    %eax,%edi
  800697:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80069a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80069c:	85 ff                	test   %edi,%edi
  80069e:	79 1d                	jns    8006bd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	6a 00                	push   $0x0
  8006a6:	e8 2f fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006b1:	6a 00                	push   $0x0
  8006b3:	e8 22 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	89 f8                	mov    %edi,%eax
}
  8006bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c0:	5b                   	pop    %ebx
  8006c1:	5e                   	pop    %esi
  8006c2:	5f                   	pop    %edi
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	53                   	push   %ebx
  8006c9:	83 ec 14             	sub    $0x14,%esp
  8006cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	53                   	push   %ebx
  8006d4:	e8 86 fd ff ff       	call   80045f <fd_lookup>
  8006d9:	83 c4 08             	add    $0x8,%esp
  8006dc:	89 c2                	mov    %eax,%edx
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	78 6d                	js     80074f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006e8:	50                   	push   %eax
  8006e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ec:	ff 30                	pushl  (%eax)
  8006ee:	e8 c2 fd ff ff       	call   8004b5 <dev_lookup>
  8006f3:	83 c4 10             	add    $0x10,%esp
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	78 4c                	js     800746 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006fd:	8b 42 08             	mov    0x8(%edx),%eax
  800700:	83 e0 03             	and    $0x3,%eax
  800703:	83 f8 01             	cmp    $0x1,%eax
  800706:	75 21                	jne    800729 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800708:	a1 08 40 80 00       	mov    0x804008,%eax
  80070d:	8b 40 48             	mov    0x48(%eax),%eax
  800710:	83 ec 04             	sub    $0x4,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	68 19 23 80 00       	push   $0x802319
  80071a:	e8 e7 0e 00 00       	call   801606 <cprintf>
		return -E_INVAL;
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800727:	eb 26                	jmp    80074f <read+0x8a>
	}
	if (!dev->dev_read)
  800729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072c:	8b 40 08             	mov    0x8(%eax),%eax
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 17                	je     80074a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800733:	83 ec 04             	sub    $0x4,%esp
  800736:	ff 75 10             	pushl  0x10(%ebp)
  800739:	ff 75 0c             	pushl  0xc(%ebp)
  80073c:	52                   	push   %edx
  80073d:	ff d0                	call   *%eax
  80073f:	89 c2                	mov    %eax,%edx
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	eb 09                	jmp    80074f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800746:	89 c2                	mov    %eax,%edx
  800748:	eb 05                	jmp    80074f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80074a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80074f:	89 d0                	mov    %edx,%eax
  800751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	57                   	push   %edi
  80075a:	56                   	push   %esi
  80075b:	53                   	push   %ebx
  80075c:	83 ec 0c             	sub    $0xc,%esp
  80075f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800762:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800765:	bb 00 00 00 00       	mov    $0x0,%ebx
  80076a:	eb 21                	jmp    80078d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80076c:	83 ec 04             	sub    $0x4,%esp
  80076f:	89 f0                	mov    %esi,%eax
  800771:	29 d8                	sub    %ebx,%eax
  800773:	50                   	push   %eax
  800774:	89 d8                	mov    %ebx,%eax
  800776:	03 45 0c             	add    0xc(%ebp),%eax
  800779:	50                   	push   %eax
  80077a:	57                   	push   %edi
  80077b:	e8 45 ff ff ff       	call   8006c5 <read>
		if (m < 0)
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	85 c0                	test   %eax,%eax
  800785:	78 10                	js     800797 <readn+0x41>
			return m;
		if (m == 0)
  800787:	85 c0                	test   %eax,%eax
  800789:	74 0a                	je     800795 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80078b:	01 c3                	add    %eax,%ebx
  80078d:	39 f3                	cmp    %esi,%ebx
  80078f:	72 db                	jb     80076c <readn+0x16>
  800791:	89 d8                	mov    %ebx,%eax
  800793:	eb 02                	jmp    800797 <readn+0x41>
  800795:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800797:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5f                   	pop    %edi
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	83 ec 14             	sub    $0x14,%esp
  8007a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ac:	50                   	push   %eax
  8007ad:	53                   	push   %ebx
  8007ae:	e8 ac fc ff ff       	call   80045f <fd_lookup>
  8007b3:	83 c4 08             	add    $0x8,%esp
  8007b6:	89 c2                	mov    %eax,%edx
  8007b8:	85 c0                	test   %eax,%eax
  8007ba:	78 68                	js     800824 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c2:	50                   	push   %eax
  8007c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c6:	ff 30                	pushl  (%eax)
  8007c8:	e8 e8 fc ff ff       	call   8004b5 <dev_lookup>
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	78 47                	js     80081b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007db:	75 21                	jne    8007fe <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8007e2:	8b 40 48             	mov    0x48(%eax),%eax
  8007e5:	83 ec 04             	sub    $0x4,%esp
  8007e8:	53                   	push   %ebx
  8007e9:	50                   	push   %eax
  8007ea:	68 35 23 80 00       	push   $0x802335
  8007ef:	e8 12 0e 00 00       	call   801606 <cprintf>
		return -E_INVAL;
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007fc:	eb 26                	jmp    800824 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800801:	8b 52 0c             	mov    0xc(%edx),%edx
  800804:	85 d2                	test   %edx,%edx
  800806:	74 17                	je     80081f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	ff 75 10             	pushl  0x10(%ebp)
  80080e:	ff 75 0c             	pushl  0xc(%ebp)
  800811:	50                   	push   %eax
  800812:	ff d2                	call   *%edx
  800814:	89 c2                	mov    %eax,%edx
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	eb 09                	jmp    800824 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	eb 05                	jmp    800824 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80081f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800824:	89 d0                	mov    %edx,%eax
  800826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <seek>:

int
seek(int fdnum, off_t offset)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800831:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800834:	50                   	push   %eax
  800835:	ff 75 08             	pushl  0x8(%ebp)
  800838:	e8 22 fc ff ff       	call   80045f <fd_lookup>
  80083d:	83 c4 08             	add    $0x8,%esp
  800840:	85 c0                	test   %eax,%eax
  800842:	78 0e                	js     800852 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800844:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800852:	c9                   	leave  
  800853:	c3                   	ret    

00800854 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	53                   	push   %ebx
  800858:	83 ec 14             	sub    $0x14,%esp
  80085b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800861:	50                   	push   %eax
  800862:	53                   	push   %ebx
  800863:	e8 f7 fb ff ff       	call   80045f <fd_lookup>
  800868:	83 c4 08             	add    $0x8,%esp
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 65                	js     8008d6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800877:	50                   	push   %eax
  800878:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087b:	ff 30                	pushl  (%eax)
  80087d:	e8 33 fc ff ff       	call   8004b5 <dev_lookup>
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	85 c0                	test   %eax,%eax
  800887:	78 44                	js     8008cd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800889:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800890:	75 21                	jne    8008b3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800892:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800897:	8b 40 48             	mov    0x48(%eax),%eax
  80089a:	83 ec 04             	sub    $0x4,%esp
  80089d:	53                   	push   %ebx
  80089e:	50                   	push   %eax
  80089f:	68 f8 22 80 00       	push   $0x8022f8
  8008a4:	e8 5d 0d 00 00       	call   801606 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008b1:	eb 23                	jmp    8008d6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008b6:	8b 52 18             	mov    0x18(%edx),%edx
  8008b9:	85 d2                	test   %edx,%edx
  8008bb:	74 14                	je     8008d1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	50                   	push   %eax
  8008c4:	ff d2                	call   *%edx
  8008c6:	89 c2                	mov    %eax,%edx
  8008c8:	83 c4 10             	add    $0x10,%esp
  8008cb:	eb 09                	jmp    8008d6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	eb 05                	jmp    8008d6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008d6:	89 d0                	mov    %edx,%eax
  8008d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	83 ec 14             	sub    $0x14,%esp
  8008e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ea:	50                   	push   %eax
  8008eb:	ff 75 08             	pushl  0x8(%ebp)
  8008ee:	e8 6c fb ff ff       	call   80045f <fd_lookup>
  8008f3:	83 c4 08             	add    $0x8,%esp
  8008f6:	89 c2                	mov    %eax,%edx
  8008f8:	85 c0                	test   %eax,%eax
  8008fa:	78 58                	js     800954 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800902:	50                   	push   %eax
  800903:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800906:	ff 30                	pushl  (%eax)
  800908:	e8 a8 fb ff ff       	call   8004b5 <dev_lookup>
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	85 c0                	test   %eax,%eax
  800912:	78 37                	js     80094b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800914:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800917:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80091b:	74 32                	je     80094f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80091d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800920:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800927:	00 00 00 
	stat->st_isdir = 0;
  80092a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800931:	00 00 00 
	stat->st_dev = dev;
  800934:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	53                   	push   %ebx
  80093e:	ff 75 f0             	pushl  -0x10(%ebp)
  800941:	ff 50 14             	call   *0x14(%eax)
  800944:	89 c2                	mov    %eax,%edx
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	eb 09                	jmp    800954 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80094b:	89 c2                	mov    %eax,%edx
  80094d:	eb 05                	jmp    800954 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80094f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800954:	89 d0                	mov    %edx,%eax
  800956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800960:	83 ec 08             	sub    $0x8,%esp
  800963:	6a 00                	push   $0x0
  800965:	ff 75 08             	pushl  0x8(%ebp)
  800968:	e8 d6 01 00 00       	call   800b43 <open>
  80096d:	89 c3                	mov    %eax,%ebx
  80096f:	83 c4 10             	add    $0x10,%esp
  800972:	85 c0                	test   %eax,%eax
  800974:	78 1b                	js     800991 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800976:	83 ec 08             	sub    $0x8,%esp
  800979:	ff 75 0c             	pushl  0xc(%ebp)
  80097c:	50                   	push   %eax
  80097d:	e8 5b ff ff ff       	call   8008dd <fstat>
  800982:	89 c6                	mov    %eax,%esi
	close(fd);
  800984:	89 1c 24             	mov    %ebx,(%esp)
  800987:	e8 fd fb ff ff       	call   800589 <close>
	return r;
  80098c:	83 c4 10             	add    $0x10,%esp
  80098f:	89 f0                	mov    %esi,%eax
}
  800991:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	89 c6                	mov    %eax,%esi
  80099f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009a1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009a8:	75 12                	jne    8009bc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009aa:	83 ec 0c             	sub    $0xc,%esp
  8009ad:	6a 01                	push   $0x1
  8009af:	e8 d9 15 00 00       	call   801f8d <ipc_find_env>
  8009b4:	a3 00 40 80 00       	mov    %eax,0x804000
  8009b9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009bc:	6a 07                	push   $0x7
  8009be:	68 00 50 80 00       	push   $0x805000
  8009c3:	56                   	push   %esi
  8009c4:	ff 35 00 40 80 00    	pushl  0x804000
  8009ca:	e8 6a 15 00 00       	call   801f39 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009cf:	83 c4 0c             	add    $0xc,%esp
  8009d2:	6a 00                	push   $0x0
  8009d4:	53                   	push   %ebx
  8009d5:	6a 00                	push   $0x0
  8009d7:	e8 f6 14 00 00       	call   801ed2 <ipc_recv>
}
  8009dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800a01:	b8 02 00 00 00       	mov    $0x2,%eax
  800a06:	e8 8d ff ff ff       	call   800998 <fsipc>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8b 40 0c             	mov    0xc(%eax),%eax
  800a19:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a23:	b8 06 00 00 00       	mov    $0x6,%eax
  800a28:	e8 6b ff ff ff       	call   800998 <fsipc>
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	83 ec 04             	sub    $0x4,%esp
  800a36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 05 00 00 00       	mov    $0x5,%eax
  800a4e:	e8 45 ff ff ff       	call   800998 <fsipc>
  800a53:	85 c0                	test   %eax,%eax
  800a55:	78 2c                	js     800a83 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a57:	83 ec 08             	sub    $0x8,%esp
  800a5a:	68 00 50 80 00       	push   $0x805000
  800a5f:	53                   	push   %ebx
  800a60:	e8 26 11 00 00       	call   801b8b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a65:	a1 80 50 80 00       	mov    0x805080,%eax
  800a6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a70:	a1 84 50 80 00       	mov    0x805084,%eax
  800a75:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a7b:	83 c4 10             	add    $0x10,%esp
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	83 ec 0c             	sub    $0xc,%esp
  800a8e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a91:	8b 55 08             	mov    0x8(%ebp),%edx
  800a94:	8b 52 0c             	mov    0xc(%edx),%edx
  800a97:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a9d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800aa2:	50                   	push   %eax
  800aa3:	ff 75 0c             	pushl  0xc(%ebp)
  800aa6:	68 08 50 80 00       	push   $0x805008
  800aab:	e8 6d 12 00 00       	call   801d1d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 04 00 00 00       	mov    $0x4,%eax
  800aba:	e8 d9 fe ff ff       	call   800998 <fsipc>

}
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    

00800ac1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 40 0c             	mov    0xc(%eax),%eax
  800acf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ad4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ada:	ba 00 00 00 00       	mov    $0x0,%edx
  800adf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae4:	e8 af fe ff ff       	call   800998 <fsipc>
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	78 4b                	js     800b3a <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aef:	39 c6                	cmp    %eax,%esi
  800af1:	73 16                	jae    800b09 <devfile_read+0x48>
  800af3:	68 68 23 80 00       	push   $0x802368
  800af8:	68 6f 23 80 00       	push   $0x80236f
  800afd:	6a 7c                	push   $0x7c
  800aff:	68 84 23 80 00       	push   $0x802384
  800b04:	e8 24 0a 00 00       	call   80152d <_panic>
	assert(r <= PGSIZE);
  800b09:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b0e:	7e 16                	jle    800b26 <devfile_read+0x65>
  800b10:	68 8f 23 80 00       	push   $0x80238f
  800b15:	68 6f 23 80 00       	push   $0x80236f
  800b1a:	6a 7d                	push   $0x7d
  800b1c:	68 84 23 80 00       	push   $0x802384
  800b21:	e8 07 0a 00 00       	call   80152d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b26:	83 ec 04             	sub    $0x4,%esp
  800b29:	50                   	push   %eax
  800b2a:	68 00 50 80 00       	push   $0x805000
  800b2f:	ff 75 0c             	pushl  0xc(%ebp)
  800b32:	e8 e6 11 00 00       	call   801d1d <memmove>
	return r;
  800b37:	83 c4 10             	add    $0x10,%esp
}
  800b3a:	89 d8                	mov    %ebx,%eax
  800b3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	53                   	push   %ebx
  800b47:	83 ec 20             	sub    $0x20,%esp
  800b4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b4d:	53                   	push   %ebx
  800b4e:	e8 ff 0f 00 00       	call   801b52 <strlen>
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b5b:	7f 67                	jg     800bc4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b63:	50                   	push   %eax
  800b64:	e8 a7 f8 ff ff       	call   800410 <fd_alloc>
  800b69:	83 c4 10             	add    $0x10,%esp
		return r;
  800b6c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	78 57                	js     800bc9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b72:	83 ec 08             	sub    $0x8,%esp
  800b75:	53                   	push   %ebx
  800b76:	68 00 50 80 00       	push   $0x805000
  800b7b:	e8 0b 10 00 00       	call   801b8b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b88:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b90:	e8 03 fe ff ff       	call   800998 <fsipc>
  800b95:	89 c3                	mov    %eax,%ebx
  800b97:	83 c4 10             	add    $0x10,%esp
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	79 14                	jns    800bb2 <open+0x6f>
		fd_close(fd, 0);
  800b9e:	83 ec 08             	sub    $0x8,%esp
  800ba1:	6a 00                	push   $0x0
  800ba3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba6:	e8 5d f9 ff ff       	call   800508 <fd_close>
		return r;
  800bab:	83 c4 10             	add    $0x10,%esp
  800bae:	89 da                	mov    %ebx,%edx
  800bb0:	eb 17                	jmp    800bc9 <open+0x86>
	}

	return fd2num(fd);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	ff 75 f4             	pushl  -0xc(%ebp)
  800bb8:	e8 2c f8 ff ff       	call   8003e9 <fd2num>
  800bbd:	89 c2                	mov    %eax,%edx
  800bbf:	83 c4 10             	add    $0x10,%esp
  800bc2:	eb 05                	jmp    800bc9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bc4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bc9:	89 d0                	mov    %edx,%eax
  800bcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800be0:	e8 b3 fd ff ff       	call   800998 <fsipc>
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bed:	68 9b 23 80 00       	push   $0x80239b
  800bf2:	ff 75 0c             	pushl  0xc(%ebp)
  800bf5:	e8 91 0f 00 00       	call   801b8b <strcpy>
	return 0;
}
  800bfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	53                   	push   %ebx
  800c05:	83 ec 10             	sub    $0x10,%esp
  800c08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c0b:	53                   	push   %ebx
  800c0c:	e8 b5 13 00 00       	call   801fc6 <pageref>
  800c11:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c19:	83 f8 01             	cmp    $0x1,%eax
  800c1c:	75 10                	jne    800c2e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	ff 73 0c             	pushl  0xc(%ebx)
  800c24:	e8 c0 02 00 00       	call   800ee9 <nsipc_close>
  800c29:	89 c2                	mov    %eax,%edx
  800c2b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c2e:	89 d0                	mov    %edx,%eax
  800c30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c33:	c9                   	leave  
  800c34:	c3                   	ret    

00800c35 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c3b:	6a 00                	push   $0x0
  800c3d:	ff 75 10             	pushl  0x10(%ebp)
  800c40:	ff 75 0c             	pushl  0xc(%ebp)
  800c43:	8b 45 08             	mov    0x8(%ebp),%eax
  800c46:	ff 70 0c             	pushl  0xc(%eax)
  800c49:	e8 78 03 00 00       	call   800fc6 <nsipc_send>
}
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    

00800c50 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c56:	6a 00                	push   $0x0
  800c58:	ff 75 10             	pushl  0x10(%ebp)
  800c5b:	ff 75 0c             	pushl  0xc(%ebp)
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	ff 70 0c             	pushl  0xc(%eax)
  800c64:	e8 f1 02 00 00       	call   800f5a <nsipc_recv>
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c71:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c74:	52                   	push   %edx
  800c75:	50                   	push   %eax
  800c76:	e8 e4 f7 ff ff       	call   80045f <fd_lookup>
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	78 17                	js     800c99 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c85:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c8b:	39 08                	cmp    %ecx,(%eax)
  800c8d:	75 05                	jne    800c94 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c8f:	8b 40 0c             	mov    0xc(%eax),%eax
  800c92:	eb 05                	jmp    800c99 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c94:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 1c             	sub    $0x1c,%esp
  800ca3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ca5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca8:	50                   	push   %eax
  800ca9:	e8 62 f7 ff ff       	call   800410 <fd_alloc>
  800cae:	89 c3                	mov    %eax,%ebx
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	78 1b                	js     800cd2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cb7:	83 ec 04             	sub    $0x4,%esp
  800cba:	68 07 04 00 00       	push   $0x407
  800cbf:	ff 75 f4             	pushl  -0xc(%ebp)
  800cc2:	6a 00                	push   $0x0
  800cc4:	e8 8c f4 ff ff       	call   800155 <sys_page_alloc>
  800cc9:	89 c3                	mov    %eax,%ebx
  800ccb:	83 c4 10             	add    $0x10,%esp
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	79 10                	jns    800ce2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	56                   	push   %esi
  800cd6:	e8 0e 02 00 00       	call   800ee9 <nsipc_close>
		return r;
  800cdb:	83 c4 10             	add    $0x10,%esp
  800cde:	89 d8                	mov    %ebx,%eax
  800ce0:	eb 24                	jmp    800d06 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ce2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ceb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cf7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	e8 e6 f6 ff ff       	call   8003e9 <fd2num>
  800d03:	83 c4 10             	add    $0x10,%esp
}
  800d06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	e8 50 ff ff ff       	call   800c6b <fd2sockid>
		return r;
  800d1b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	78 1f                	js     800d40 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d21:	83 ec 04             	sub    $0x4,%esp
  800d24:	ff 75 10             	pushl  0x10(%ebp)
  800d27:	ff 75 0c             	pushl  0xc(%ebp)
  800d2a:	50                   	push   %eax
  800d2b:	e8 12 01 00 00       	call   800e42 <nsipc_accept>
  800d30:	83 c4 10             	add    $0x10,%esp
		return r;
  800d33:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d35:	85 c0                	test   %eax,%eax
  800d37:	78 07                	js     800d40 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d39:	e8 5d ff ff ff       	call   800c9b <alloc_sockfd>
  800d3e:	89 c1                	mov    %eax,%ecx
}
  800d40:	89 c8                	mov    %ecx,%eax
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	e8 19 ff ff ff       	call   800c6b <fd2sockid>
  800d52:	85 c0                	test   %eax,%eax
  800d54:	78 12                	js     800d68 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	ff 75 10             	pushl  0x10(%ebp)
  800d5c:	ff 75 0c             	pushl  0xc(%ebp)
  800d5f:	50                   	push   %eax
  800d60:	e8 2d 01 00 00       	call   800e92 <nsipc_bind>
  800d65:	83 c4 10             	add    $0x10,%esp
}
  800d68:	c9                   	leave  
  800d69:	c3                   	ret    

00800d6a <shutdown>:

int
shutdown(int s, int how)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	e8 f3 fe ff ff       	call   800c6b <fd2sockid>
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	78 0f                	js     800d8b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d7c:	83 ec 08             	sub    $0x8,%esp
  800d7f:	ff 75 0c             	pushl  0xc(%ebp)
  800d82:	50                   	push   %eax
  800d83:	e8 3f 01 00 00       	call   800ec7 <nsipc_shutdown>
  800d88:	83 c4 10             	add    $0x10,%esp
}
  800d8b:	c9                   	leave  
  800d8c:	c3                   	ret    

00800d8d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
  800d96:	e8 d0 fe ff ff       	call   800c6b <fd2sockid>
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	78 12                	js     800db1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	ff 75 10             	pushl  0x10(%ebp)
  800da5:	ff 75 0c             	pushl  0xc(%ebp)
  800da8:	50                   	push   %eax
  800da9:	e8 55 01 00 00       	call   800f03 <nsipc_connect>
  800dae:	83 c4 10             	add    $0x10,%esp
}
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    

00800db3 <listen>:

int
listen(int s, int backlog)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	e8 aa fe ff ff       	call   800c6b <fd2sockid>
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	78 0f                	js     800dd4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dc5:	83 ec 08             	sub    $0x8,%esp
  800dc8:	ff 75 0c             	pushl  0xc(%ebp)
  800dcb:	50                   	push   %eax
  800dcc:	e8 67 01 00 00       	call   800f38 <nsipc_listen>
  800dd1:	83 c4 10             	add    $0x10,%esp
}
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    

00800dd6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800ddc:	ff 75 10             	pushl  0x10(%ebp)
  800ddf:	ff 75 0c             	pushl  0xc(%ebp)
  800de2:	ff 75 08             	pushl  0x8(%ebp)
  800de5:	e8 3a 02 00 00       	call   801024 <nsipc_socket>
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	78 05                	js     800df6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800df1:	e8 a5 fe ff ff       	call   800c9b <alloc_sockfd>
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    

00800df8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 04             	sub    $0x4,%esp
  800dff:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e01:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e08:	75 12                	jne    800e1c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	6a 02                	push   $0x2
  800e0f:	e8 79 11 00 00       	call   801f8d <ipc_find_env>
  800e14:	a3 04 40 80 00       	mov    %eax,0x804004
  800e19:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e1c:	6a 07                	push   $0x7
  800e1e:	68 00 60 80 00       	push   $0x806000
  800e23:	53                   	push   %ebx
  800e24:	ff 35 04 40 80 00    	pushl  0x804004
  800e2a:	e8 0a 11 00 00       	call   801f39 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e2f:	83 c4 0c             	add    $0xc,%esp
  800e32:	6a 00                	push   $0x0
  800e34:	6a 00                	push   $0x0
  800e36:	6a 00                	push   $0x0
  800e38:	e8 95 10 00 00       	call   801ed2 <ipc_recv>
}
  800e3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e52:	8b 06                	mov    (%esi),%eax
  800e54:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e59:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5e:	e8 95 ff ff ff       	call   800df8 <nsipc>
  800e63:	89 c3                	mov    %eax,%ebx
  800e65:	85 c0                	test   %eax,%eax
  800e67:	78 20                	js     800e89 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	ff 35 10 60 80 00    	pushl  0x806010
  800e72:	68 00 60 80 00       	push   $0x806000
  800e77:	ff 75 0c             	pushl  0xc(%ebp)
  800e7a:	e8 9e 0e 00 00       	call   801d1d <memmove>
		*addrlen = ret->ret_addrlen;
  800e7f:	a1 10 60 80 00       	mov    0x806010,%eax
  800e84:	89 06                	mov    %eax,(%esi)
  800e86:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e89:	89 d8                	mov    %ebx,%eax
  800e8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	53                   	push   %ebx
  800e96:	83 ec 08             	sub    $0x8,%esp
  800e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ea4:	53                   	push   %ebx
  800ea5:	ff 75 0c             	pushl  0xc(%ebp)
  800ea8:	68 04 60 80 00       	push   $0x806004
  800ead:	e8 6b 0e 00 00       	call   801d1d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800eb2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800eb8:	b8 02 00 00 00       	mov    $0x2,%eax
  800ebd:	e8 36 ff ff ff       	call   800df8 <nsipc>
}
  800ec2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800edd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee2:	e8 11 ff ff ff       	call   800df8 <nsipc>
}
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <nsipc_close>:

int
nsipc_close(int s)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ef7:	b8 04 00 00 00       	mov    $0x4,%eax
  800efc:	e8 f7 fe ff ff       	call   800df8 <nsipc>
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	53                   	push   %ebx
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f15:	53                   	push   %ebx
  800f16:	ff 75 0c             	pushl  0xc(%ebp)
  800f19:	68 04 60 80 00       	push   $0x806004
  800f1e:	e8 fa 0d 00 00       	call   801d1d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f23:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f29:	b8 05 00 00 00       	mov    $0x5,%eax
  800f2e:	e8 c5 fe ff ff       	call   800df8 <nsipc>
}
  800f33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f49:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f53:	e8 a0 fe ff ff       	call   800df8 <nsipc>
}
  800f58:	c9                   	leave  
  800f59:	c3                   	ret    

00800f5a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f62:	8b 45 08             	mov    0x8(%ebp),%eax
  800f65:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f6a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f70:	8b 45 14             	mov    0x14(%ebp),%eax
  800f73:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f78:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7d:	e8 76 fe ff ff       	call   800df8 <nsipc>
  800f82:	89 c3                	mov    %eax,%ebx
  800f84:	85 c0                	test   %eax,%eax
  800f86:	78 35                	js     800fbd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f88:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f8d:	7f 04                	jg     800f93 <nsipc_recv+0x39>
  800f8f:	39 c6                	cmp    %eax,%esi
  800f91:	7d 16                	jge    800fa9 <nsipc_recv+0x4f>
  800f93:	68 a7 23 80 00       	push   $0x8023a7
  800f98:	68 6f 23 80 00       	push   $0x80236f
  800f9d:	6a 62                	push   $0x62
  800f9f:	68 bc 23 80 00       	push   $0x8023bc
  800fa4:	e8 84 05 00 00       	call   80152d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	50                   	push   %eax
  800fad:	68 00 60 80 00       	push   $0x806000
  800fb2:	ff 75 0c             	pushl  0xc(%ebp)
  800fb5:	e8 63 0d 00 00       	call   801d1d <memmove>
  800fba:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fbd:	89 d8                	mov    %ebx,%eax
  800fbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc2:	5b                   	pop    %ebx
  800fc3:	5e                   	pop    %esi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	53                   	push   %ebx
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fd8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fde:	7e 16                	jle    800ff6 <nsipc_send+0x30>
  800fe0:	68 c8 23 80 00       	push   $0x8023c8
  800fe5:	68 6f 23 80 00       	push   $0x80236f
  800fea:	6a 6d                	push   $0x6d
  800fec:	68 bc 23 80 00       	push   $0x8023bc
  800ff1:	e8 37 05 00 00       	call   80152d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	53                   	push   %ebx
  800ffa:	ff 75 0c             	pushl  0xc(%ebp)
  800ffd:	68 0c 60 80 00       	push   $0x80600c
  801002:	e8 16 0d 00 00       	call   801d1d <memmove>
	nsipcbuf.send.req_size = size;
  801007:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80100d:	8b 45 14             	mov    0x14(%ebp),%eax
  801010:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801015:	b8 08 00 00 00       	mov    $0x8,%eax
  80101a:	e8 d9 fd ff ff       	call   800df8 <nsipc>
}
  80101f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
  80102d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801032:	8b 45 0c             	mov    0xc(%ebp),%eax
  801035:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80103a:	8b 45 10             	mov    0x10(%ebp),%eax
  80103d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801042:	b8 09 00 00 00       	mov    $0x9,%eax
  801047:	e8 ac fd ff ff       	call   800df8 <nsipc>
}
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    

0080104e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
  801053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	ff 75 08             	pushl  0x8(%ebp)
  80105c:	e8 98 f3 ff ff       	call   8003f9 <fd2data>
  801061:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801063:	83 c4 08             	add    $0x8,%esp
  801066:	68 d4 23 80 00       	push   $0x8023d4
  80106b:	53                   	push   %ebx
  80106c:	e8 1a 0b 00 00       	call   801b8b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801071:	8b 46 04             	mov    0x4(%esi),%eax
  801074:	2b 06                	sub    (%esi),%eax
  801076:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80107c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801083:	00 00 00 
	stat->st_dev = &devpipe;
  801086:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80108d:	30 80 00 
	return 0;
}
  801090:	b8 00 00 00 00       	mov    $0x0,%eax
  801095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010a6:	53                   	push   %ebx
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 2c f1 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010ae:	89 1c 24             	mov    %ebx,(%esp)
  8010b1:	e8 43 f3 ff ff       	call   8003f9 <fd2data>
  8010b6:	83 c4 08             	add    $0x8,%esp
  8010b9:	50                   	push   %eax
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 19 f1 ff ff       	call   8001da <sys_page_unmap>
}
  8010c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	57                   	push   %edi
  8010ca:	56                   	push   %esi
  8010cb:	53                   	push   %ebx
  8010cc:	83 ec 1c             	sub    $0x1c,%esp
  8010cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010d2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010d4:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	ff 75 e0             	pushl  -0x20(%ebp)
  8010e2:	e8 df 0e 00 00       	call   801fc6 <pageref>
  8010e7:	89 c3                	mov    %eax,%ebx
  8010e9:	89 3c 24             	mov    %edi,(%esp)
  8010ec:	e8 d5 0e 00 00       	call   801fc6 <pageref>
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	39 c3                	cmp    %eax,%ebx
  8010f6:	0f 94 c1             	sete   %cl
  8010f9:	0f b6 c9             	movzbl %cl,%ecx
  8010fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010ff:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801105:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801108:	39 ce                	cmp    %ecx,%esi
  80110a:	74 1b                	je     801127 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80110c:	39 c3                	cmp    %eax,%ebx
  80110e:	75 c4                	jne    8010d4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801110:	8b 42 58             	mov    0x58(%edx),%eax
  801113:	ff 75 e4             	pushl  -0x1c(%ebp)
  801116:	50                   	push   %eax
  801117:	56                   	push   %esi
  801118:	68 db 23 80 00       	push   $0x8023db
  80111d:	e8 e4 04 00 00       	call   801606 <cprintf>
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	eb ad                	jmp    8010d4 <_pipeisclosed+0xe>
	}
}
  801127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 28             	sub    $0x28,%esp
  80113b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80113e:	56                   	push   %esi
  80113f:	e8 b5 f2 ff ff       	call   8003f9 <fd2data>
  801144:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801146:	83 c4 10             	add    $0x10,%esp
  801149:	bf 00 00 00 00       	mov    $0x0,%edi
  80114e:	eb 4b                	jmp    80119b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801150:	89 da                	mov    %ebx,%edx
  801152:	89 f0                	mov    %esi,%eax
  801154:	e8 6d ff ff ff       	call   8010c6 <_pipeisclosed>
  801159:	85 c0                	test   %eax,%eax
  80115b:	75 48                	jne    8011a5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80115d:	e8 d4 ef ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801162:	8b 43 04             	mov    0x4(%ebx),%eax
  801165:	8b 0b                	mov    (%ebx),%ecx
  801167:	8d 51 20             	lea    0x20(%ecx),%edx
  80116a:	39 d0                	cmp    %edx,%eax
  80116c:	73 e2                	jae    801150 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80116e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801171:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801175:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801178:	89 c2                	mov    %eax,%edx
  80117a:	c1 fa 1f             	sar    $0x1f,%edx
  80117d:	89 d1                	mov    %edx,%ecx
  80117f:	c1 e9 1b             	shr    $0x1b,%ecx
  801182:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801185:	83 e2 1f             	and    $0x1f,%edx
  801188:	29 ca                	sub    %ecx,%edx
  80118a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80118e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801192:	83 c0 01             	add    $0x1,%eax
  801195:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801198:	83 c7 01             	add    $0x1,%edi
  80119b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80119e:	75 c2                	jne    801162 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a3:	eb 05                	jmp    8011aa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011a5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    

008011b2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	57                   	push   %edi
  8011b6:	56                   	push   %esi
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 18             	sub    $0x18,%esp
  8011bb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011be:	57                   	push   %edi
  8011bf:	e8 35 f2 ff ff       	call   8003f9 <fd2data>
  8011c4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ce:	eb 3d                	jmp    80120d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011d0:	85 db                	test   %ebx,%ebx
  8011d2:	74 04                	je     8011d8 <devpipe_read+0x26>
				return i;
  8011d4:	89 d8                	mov    %ebx,%eax
  8011d6:	eb 44                	jmp    80121c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011d8:	89 f2                	mov    %esi,%edx
  8011da:	89 f8                	mov    %edi,%eax
  8011dc:	e8 e5 fe ff ff       	call   8010c6 <_pipeisclosed>
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	75 32                	jne    801217 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011e5:	e8 4c ef ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011ea:	8b 06                	mov    (%esi),%eax
  8011ec:	3b 46 04             	cmp    0x4(%esi),%eax
  8011ef:	74 df                	je     8011d0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011f1:	99                   	cltd   
  8011f2:	c1 ea 1b             	shr    $0x1b,%edx
  8011f5:	01 d0                	add    %edx,%eax
  8011f7:	83 e0 1f             	and    $0x1f,%eax
  8011fa:	29 d0                	sub    %edx,%eax
  8011fc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801204:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801207:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80120a:	83 c3 01             	add    $0x1,%ebx
  80120d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801210:	75 d8                	jne    8011ea <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801212:	8b 45 10             	mov    0x10(%ebp),%eax
  801215:	eb 05                	jmp    80121c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80121c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5f                   	pop    %edi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	56                   	push   %esi
  801228:	53                   	push   %ebx
  801229:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	e8 db f1 ff ff       	call   800410 <fd_alloc>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	89 c2                	mov    %eax,%edx
  80123a:	85 c0                	test   %eax,%eax
  80123c:	0f 88 2c 01 00 00    	js     80136e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801242:	83 ec 04             	sub    $0x4,%esp
  801245:	68 07 04 00 00       	push   $0x407
  80124a:	ff 75 f4             	pushl  -0xc(%ebp)
  80124d:	6a 00                	push   $0x0
  80124f:	e8 01 ef ff ff       	call   800155 <sys_page_alloc>
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	89 c2                	mov    %eax,%edx
  801259:	85 c0                	test   %eax,%eax
  80125b:	0f 88 0d 01 00 00    	js     80136e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801261:	83 ec 0c             	sub    $0xc,%esp
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	e8 a3 f1 ff ff       	call   800410 <fd_alloc>
  80126d:	89 c3                	mov    %eax,%ebx
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	0f 88 e2 00 00 00    	js     80135c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	68 07 04 00 00       	push   $0x407
  801282:	ff 75 f0             	pushl  -0x10(%ebp)
  801285:	6a 00                	push   $0x0
  801287:	e8 c9 ee ff ff       	call   800155 <sys_page_alloc>
  80128c:	89 c3                	mov    %eax,%ebx
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	0f 88 c3 00 00 00    	js     80135c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801299:	83 ec 0c             	sub    $0xc,%esp
  80129c:	ff 75 f4             	pushl  -0xc(%ebp)
  80129f:	e8 55 f1 ff ff       	call   8003f9 <fd2data>
  8012a4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a6:	83 c4 0c             	add    $0xc,%esp
  8012a9:	68 07 04 00 00       	push   $0x407
  8012ae:	50                   	push   %eax
  8012af:	6a 00                	push   $0x0
  8012b1:	e8 9f ee ff ff       	call   800155 <sys_page_alloc>
  8012b6:	89 c3                	mov    %eax,%ebx
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	0f 88 89 00 00 00    	js     80134c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c9:	e8 2b f1 ff ff       	call   8003f9 <fd2data>
  8012ce:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012d5:	50                   	push   %eax
  8012d6:	6a 00                	push   $0x0
  8012d8:	56                   	push   %esi
  8012d9:	6a 00                	push   $0x0
  8012db:	e8 b8 ee ff ff       	call   800198 <sys_page_map>
  8012e0:	89 c3                	mov    %eax,%ebx
  8012e2:	83 c4 20             	add    $0x20,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 55                	js     80133e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012e9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012fe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801304:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801307:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	ff 75 f4             	pushl  -0xc(%ebp)
  801319:	e8 cb f0 ff ff       	call   8003e9 <fd2num>
  80131e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801321:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801323:	83 c4 04             	add    $0x4,%esp
  801326:	ff 75 f0             	pushl  -0x10(%ebp)
  801329:	e8 bb f0 ff ff       	call   8003e9 <fd2num>
  80132e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801331:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	ba 00 00 00 00       	mov    $0x0,%edx
  80133c:	eb 30                	jmp    80136e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80133e:	83 ec 08             	sub    $0x8,%esp
  801341:	56                   	push   %esi
  801342:	6a 00                	push   $0x0
  801344:	e8 91 ee ff ff       	call   8001da <sys_page_unmap>
  801349:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	ff 75 f0             	pushl  -0x10(%ebp)
  801352:	6a 00                	push   $0x0
  801354:	e8 81 ee ff ff       	call   8001da <sys_page_unmap>
  801359:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	ff 75 f4             	pushl  -0xc(%ebp)
  801362:	6a 00                	push   $0x0
  801364:	e8 71 ee ff ff       	call   8001da <sys_page_unmap>
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80136e:	89 d0                	mov    %edx,%eax
  801370:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801373:	5b                   	pop    %ebx
  801374:	5e                   	pop    %esi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801380:	50                   	push   %eax
  801381:	ff 75 08             	pushl  0x8(%ebp)
  801384:	e8 d6 f0 ff ff       	call   80045f <fd_lookup>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 18                	js     8013a8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	ff 75 f4             	pushl  -0xc(%ebp)
  801396:	e8 5e f0 ff ff       	call   8003f9 <fd2data>
	return _pipeisclosed(fd, p);
  80139b:	89 c2                	mov    %eax,%edx
  80139d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a0:	e8 21 fd ff ff       	call   8010c6 <_pipeisclosed>
  8013a5:	83 c4 10             	add    $0x10,%esp
}
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013ba:	68 f3 23 80 00       	push   $0x8023f3
  8013bf:	ff 75 0c             	pushl  0xc(%ebp)
  8013c2:	e8 c4 07 00 00       	call   801b8b <strcpy>
	return 0;
}
  8013c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013da:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013df:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013e5:	eb 2d                	jmp    801414 <devcons_write+0x46>
		m = n - tot;
  8013e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ea:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013ec:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013ef:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013f4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013f7:	83 ec 04             	sub    $0x4,%esp
  8013fa:	53                   	push   %ebx
  8013fb:	03 45 0c             	add    0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	57                   	push   %edi
  801400:	e8 18 09 00 00       	call   801d1d <memmove>
		sys_cputs(buf, m);
  801405:	83 c4 08             	add    $0x8,%esp
  801408:	53                   	push   %ebx
  801409:	57                   	push   %edi
  80140a:	e8 8a ec ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80140f:	01 de                	add    %ebx,%esi
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	89 f0                	mov    %esi,%eax
  801416:	3b 75 10             	cmp    0x10(%ebp),%esi
  801419:	72 cc                	jb     8013e7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80141b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141e:	5b                   	pop    %ebx
  80141f:	5e                   	pop    %esi
  801420:	5f                   	pop    %edi
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    

00801423 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80142e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801432:	74 2a                	je     80145e <devcons_read+0x3b>
  801434:	eb 05                	jmp    80143b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801436:	e8 fb ec ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80143b:	e8 77 ec ff ff       	call   8000b7 <sys_cgetc>
  801440:	85 c0                	test   %eax,%eax
  801442:	74 f2                	je     801436 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801444:	85 c0                	test   %eax,%eax
  801446:	78 16                	js     80145e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801448:	83 f8 04             	cmp    $0x4,%eax
  80144b:	74 0c                	je     801459 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80144d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801450:	88 02                	mov    %al,(%edx)
	return 1;
  801452:	b8 01 00 00 00       	mov    $0x1,%eax
  801457:	eb 05                	jmp    80145e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801459:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801466:	8b 45 08             	mov    0x8(%ebp),%eax
  801469:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80146c:	6a 01                	push   $0x1
  80146e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	e8 22 ec ff ff       	call   800099 <sys_cputs>
}
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <getchar>:

int
getchar(void)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801482:	6a 01                	push   $0x1
  801484:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	6a 00                	push   $0x0
  80148a:	e8 36 f2 ff ff       	call   8006c5 <read>
	if (r < 0)
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 0f                	js     8014a5 <getchar+0x29>
		return r;
	if (r < 1)
  801496:	85 c0                	test   %eax,%eax
  801498:	7e 06                	jle    8014a0 <getchar+0x24>
		return -E_EOF;
	return c;
  80149a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80149e:	eb 05                	jmp    8014a5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014a0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b0:	50                   	push   %eax
  8014b1:	ff 75 08             	pushl  0x8(%ebp)
  8014b4:	e8 a6 ef ff ff       	call   80045f <fd_lookup>
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 11                	js     8014d1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c9:	39 10                	cmp    %edx,(%eax)
  8014cb:	0f 94 c0             	sete   %al
  8014ce:	0f b6 c0             	movzbl %al,%eax
}
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <opencons>:

int
opencons(void)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	e8 2e ef ff ff       	call   800410 <fd_alloc>
  8014e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 3e                	js     801529 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014eb:	83 ec 04             	sub    $0x4,%esp
  8014ee:	68 07 04 00 00       	push   $0x407
  8014f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f6:	6a 00                	push   $0x0
  8014f8:	e8 58 ec ff ff       	call   800155 <sys_page_alloc>
  8014fd:	83 c4 10             	add    $0x10,%esp
		return r;
  801500:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801502:	85 c0                	test   %eax,%eax
  801504:	78 23                	js     801529 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801506:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80150c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801511:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801514:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	50                   	push   %eax
  80151f:	e8 c5 ee ff ff       	call   8003e9 <fd2num>
  801524:	89 c2                	mov    %eax,%edx
  801526:	83 c4 10             	add    $0x10,%esp
}
  801529:	89 d0                	mov    %edx,%eax
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801532:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801535:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80153b:	e8 d7 eb ff ff       	call   800117 <sys_getenvid>
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	ff 75 0c             	pushl  0xc(%ebp)
  801546:	ff 75 08             	pushl  0x8(%ebp)
  801549:	56                   	push   %esi
  80154a:	50                   	push   %eax
  80154b:	68 00 24 80 00       	push   $0x802400
  801550:	e8 b1 00 00 00       	call   801606 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801555:	83 c4 18             	add    $0x18,%esp
  801558:	53                   	push   %ebx
  801559:	ff 75 10             	pushl  0x10(%ebp)
  80155c:	e8 54 00 00 00       	call   8015b5 <vcprintf>
	cprintf("\n");
  801561:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  801568:	e8 99 00 00 00       	call   801606 <cprintf>
  80156d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801570:	cc                   	int3   
  801571:	eb fd                	jmp    801570 <_panic+0x43>

00801573 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80157d:	8b 13                	mov    (%ebx),%edx
  80157f:	8d 42 01             	lea    0x1(%edx),%eax
  801582:	89 03                	mov    %eax,(%ebx)
  801584:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801587:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80158b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801590:	75 1a                	jne    8015ac <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	68 ff 00 00 00       	push   $0xff
  80159a:	8d 43 08             	lea    0x8(%ebx),%eax
  80159d:	50                   	push   %eax
  80159e:	e8 f6 ea ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8015a3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015a9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015ac:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015c5:	00 00 00 
	b.cnt = 0;
  8015c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015d2:	ff 75 0c             	pushl  0xc(%ebp)
  8015d5:	ff 75 08             	pushl  0x8(%ebp)
  8015d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	68 73 15 80 00       	push   $0x801573
  8015e4:	e8 54 01 00 00       	call   80173d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015e9:	83 c4 08             	add    $0x8,%esp
  8015ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	e8 9b ea ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  8015fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80160c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80160f:	50                   	push   %eax
  801610:	ff 75 08             	pushl  0x8(%ebp)
  801613:	e8 9d ff ff ff       	call   8015b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	57                   	push   %edi
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	83 ec 1c             	sub    $0x1c,%esp
  801623:	89 c7                	mov    %eax,%edi
  801625:	89 d6                	mov    %edx,%esi
  801627:	8b 45 08             	mov    0x8(%ebp),%eax
  80162a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801630:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801633:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801636:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80163e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801641:	39 d3                	cmp    %edx,%ebx
  801643:	72 05                	jb     80164a <printnum+0x30>
  801645:	39 45 10             	cmp    %eax,0x10(%ebp)
  801648:	77 45                	ja     80168f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80164a:	83 ec 0c             	sub    $0xc,%esp
  80164d:	ff 75 18             	pushl  0x18(%ebp)
  801650:	8b 45 14             	mov    0x14(%ebp),%eax
  801653:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801656:	53                   	push   %ebx
  801657:	ff 75 10             	pushl  0x10(%ebp)
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801660:	ff 75 e0             	pushl  -0x20(%ebp)
  801663:	ff 75 dc             	pushl  -0x24(%ebp)
  801666:	ff 75 d8             	pushl  -0x28(%ebp)
  801669:	e8 a2 09 00 00       	call   802010 <__udivdi3>
  80166e:	83 c4 18             	add    $0x18,%esp
  801671:	52                   	push   %edx
  801672:	50                   	push   %eax
  801673:	89 f2                	mov    %esi,%edx
  801675:	89 f8                	mov    %edi,%eax
  801677:	e8 9e ff ff ff       	call   80161a <printnum>
  80167c:	83 c4 20             	add    $0x20,%esp
  80167f:	eb 18                	jmp    801699 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	56                   	push   %esi
  801685:	ff 75 18             	pushl  0x18(%ebp)
  801688:	ff d7                	call   *%edi
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	eb 03                	jmp    801692 <printnum+0x78>
  80168f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801692:	83 eb 01             	sub    $0x1,%ebx
  801695:	85 db                	test   %ebx,%ebx
  801697:	7f e8                	jg     801681 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801699:	83 ec 08             	sub    $0x8,%esp
  80169c:	56                   	push   %esi
  80169d:	83 ec 04             	sub    $0x4,%esp
  8016a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8016a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8016ac:	e8 8f 0a 00 00       	call   802140 <__umoddi3>
  8016b1:	83 c4 14             	add    $0x14,%esp
  8016b4:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  8016bb:	50                   	push   %eax
  8016bc:	ff d7                	call   *%edi
}
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c4:	5b                   	pop    %ebx
  8016c5:	5e                   	pop    %esi
  8016c6:	5f                   	pop    %edi
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016cc:	83 fa 01             	cmp    $0x1,%edx
  8016cf:	7e 0e                	jle    8016df <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016d1:	8b 10                	mov    (%eax),%edx
  8016d3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016d6:	89 08                	mov    %ecx,(%eax)
  8016d8:	8b 02                	mov    (%edx),%eax
  8016da:	8b 52 04             	mov    0x4(%edx),%edx
  8016dd:	eb 22                	jmp    801701 <getuint+0x38>
	else if (lflag)
  8016df:	85 d2                	test   %edx,%edx
  8016e1:	74 10                	je     8016f3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016e3:	8b 10                	mov    (%eax),%edx
  8016e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016e8:	89 08                	mov    %ecx,(%eax)
  8016ea:	8b 02                	mov    (%edx),%eax
  8016ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f1:	eb 0e                	jmp    801701 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016f3:	8b 10                	mov    (%eax),%edx
  8016f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016f8:	89 08                	mov    %ecx,(%eax)
  8016fa:	8b 02                	mov    (%edx),%eax
  8016fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801709:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80170d:	8b 10                	mov    (%eax),%edx
  80170f:	3b 50 04             	cmp    0x4(%eax),%edx
  801712:	73 0a                	jae    80171e <sprintputch+0x1b>
		*b->buf++ = ch;
  801714:	8d 4a 01             	lea    0x1(%edx),%ecx
  801717:	89 08                	mov    %ecx,(%eax)
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	88 02                	mov    %al,(%edx)
}
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801726:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801729:	50                   	push   %eax
  80172a:	ff 75 10             	pushl  0x10(%ebp)
  80172d:	ff 75 0c             	pushl  0xc(%ebp)
  801730:	ff 75 08             	pushl  0x8(%ebp)
  801733:	e8 05 00 00 00       	call   80173d <vprintfmt>
	va_end(ap);
}
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	c9                   	leave  
  80173c:	c3                   	ret    

0080173d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	57                   	push   %edi
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	83 ec 2c             	sub    $0x2c,%esp
  801746:	8b 75 08             	mov    0x8(%ebp),%esi
  801749:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80174c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80174f:	eb 12                	jmp    801763 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801751:	85 c0                	test   %eax,%eax
  801753:	0f 84 89 03 00 00    	je     801ae2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801759:	83 ec 08             	sub    $0x8,%esp
  80175c:	53                   	push   %ebx
  80175d:	50                   	push   %eax
  80175e:	ff d6                	call   *%esi
  801760:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801763:	83 c7 01             	add    $0x1,%edi
  801766:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80176a:	83 f8 25             	cmp    $0x25,%eax
  80176d:	75 e2                	jne    801751 <vprintfmt+0x14>
  80176f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801773:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80177a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801781:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801788:	ba 00 00 00 00       	mov    $0x0,%edx
  80178d:	eb 07                	jmp    801796 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801792:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801796:	8d 47 01             	lea    0x1(%edi),%eax
  801799:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80179c:	0f b6 07             	movzbl (%edi),%eax
  80179f:	0f b6 c8             	movzbl %al,%ecx
  8017a2:	83 e8 23             	sub    $0x23,%eax
  8017a5:	3c 55                	cmp    $0x55,%al
  8017a7:	0f 87 1a 03 00 00    	ja     801ac7 <vprintfmt+0x38a>
  8017ad:	0f b6 c0             	movzbl %al,%eax
  8017b0:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8017b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017ba:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017be:	eb d6                	jmp    801796 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017cb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017ce:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017d2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017d5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017d8:	83 fa 09             	cmp    $0x9,%edx
  8017db:	77 39                	ja     801816 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017dd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017e0:	eb e9                	jmp    8017cb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e5:	8d 48 04             	lea    0x4(%eax),%ecx
  8017e8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017eb:	8b 00                	mov    (%eax),%eax
  8017ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017f3:	eb 27                	jmp    80181c <vprintfmt+0xdf>
  8017f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017ff:	0f 49 c8             	cmovns %eax,%ecx
  801802:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801805:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801808:	eb 8c                	jmp    801796 <vprintfmt+0x59>
  80180a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80180d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801814:	eb 80                	jmp    801796 <vprintfmt+0x59>
  801816:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801819:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80181c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801820:	0f 89 70 ff ff ff    	jns    801796 <vprintfmt+0x59>
				width = precision, precision = -1;
  801826:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801829:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80182c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801833:	e9 5e ff ff ff       	jmp    801796 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801838:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80183e:	e9 53 ff ff ff       	jmp    801796 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801843:	8b 45 14             	mov    0x14(%ebp),%eax
  801846:	8d 50 04             	lea    0x4(%eax),%edx
  801849:	89 55 14             	mov    %edx,0x14(%ebp)
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	53                   	push   %ebx
  801850:	ff 30                	pushl  (%eax)
  801852:	ff d6                	call   *%esi
			break;
  801854:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801857:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80185a:	e9 04 ff ff ff       	jmp    801763 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80185f:	8b 45 14             	mov    0x14(%ebp),%eax
  801862:	8d 50 04             	lea    0x4(%eax),%edx
  801865:	89 55 14             	mov    %edx,0x14(%ebp)
  801868:	8b 00                	mov    (%eax),%eax
  80186a:	99                   	cltd   
  80186b:	31 d0                	xor    %edx,%eax
  80186d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80186f:	83 f8 0f             	cmp    $0xf,%eax
  801872:	7f 0b                	jg     80187f <vprintfmt+0x142>
  801874:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80187b:	85 d2                	test   %edx,%edx
  80187d:	75 18                	jne    801897 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80187f:	50                   	push   %eax
  801880:	68 3b 24 80 00       	push   $0x80243b
  801885:	53                   	push   %ebx
  801886:	56                   	push   %esi
  801887:	e8 94 fe ff ff       	call   801720 <printfmt>
  80188c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80188f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801892:	e9 cc fe ff ff       	jmp    801763 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801897:	52                   	push   %edx
  801898:	68 81 23 80 00       	push   $0x802381
  80189d:	53                   	push   %ebx
  80189e:	56                   	push   %esi
  80189f:	e8 7c fe ff ff       	call   801720 <printfmt>
  8018a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018aa:	e9 b4 fe ff ff       	jmp    801763 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018af:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b2:	8d 50 04             	lea    0x4(%eax),%edx
  8018b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018ba:	85 ff                	test   %edi,%edi
  8018bc:	b8 34 24 80 00       	mov    $0x802434,%eax
  8018c1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018c8:	0f 8e 94 00 00 00    	jle    801962 <vprintfmt+0x225>
  8018ce:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018d2:	0f 84 98 00 00 00    	je     801970 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d8:	83 ec 08             	sub    $0x8,%esp
  8018db:	ff 75 d0             	pushl  -0x30(%ebp)
  8018de:	57                   	push   %edi
  8018df:	e8 86 02 00 00       	call   801b6a <strnlen>
  8018e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018e7:	29 c1                	sub    %eax,%ecx
  8018e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018ec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018f6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018f9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018fb:	eb 0f                	jmp    80190c <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018fd:	83 ec 08             	sub    $0x8,%esp
  801900:	53                   	push   %ebx
  801901:	ff 75 e0             	pushl  -0x20(%ebp)
  801904:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801906:	83 ef 01             	sub    $0x1,%edi
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 ff                	test   %edi,%edi
  80190e:	7f ed                	jg     8018fd <vprintfmt+0x1c0>
  801910:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801913:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801916:	85 c9                	test   %ecx,%ecx
  801918:	b8 00 00 00 00       	mov    $0x0,%eax
  80191d:	0f 49 c1             	cmovns %ecx,%eax
  801920:	29 c1                	sub    %eax,%ecx
  801922:	89 75 08             	mov    %esi,0x8(%ebp)
  801925:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801928:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80192b:	89 cb                	mov    %ecx,%ebx
  80192d:	eb 4d                	jmp    80197c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80192f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801933:	74 1b                	je     801950 <vprintfmt+0x213>
  801935:	0f be c0             	movsbl %al,%eax
  801938:	83 e8 20             	sub    $0x20,%eax
  80193b:	83 f8 5e             	cmp    $0x5e,%eax
  80193e:	76 10                	jbe    801950 <vprintfmt+0x213>
					putch('?', putdat);
  801940:	83 ec 08             	sub    $0x8,%esp
  801943:	ff 75 0c             	pushl  0xc(%ebp)
  801946:	6a 3f                	push   $0x3f
  801948:	ff 55 08             	call   *0x8(%ebp)
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	eb 0d                	jmp    80195d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	ff 75 0c             	pushl  0xc(%ebp)
  801956:	52                   	push   %edx
  801957:	ff 55 08             	call   *0x8(%ebp)
  80195a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80195d:	83 eb 01             	sub    $0x1,%ebx
  801960:	eb 1a                	jmp    80197c <vprintfmt+0x23f>
  801962:	89 75 08             	mov    %esi,0x8(%ebp)
  801965:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801968:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80196b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80196e:	eb 0c                	jmp    80197c <vprintfmt+0x23f>
  801970:	89 75 08             	mov    %esi,0x8(%ebp)
  801973:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801976:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801979:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80197c:	83 c7 01             	add    $0x1,%edi
  80197f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801983:	0f be d0             	movsbl %al,%edx
  801986:	85 d2                	test   %edx,%edx
  801988:	74 23                	je     8019ad <vprintfmt+0x270>
  80198a:	85 f6                	test   %esi,%esi
  80198c:	78 a1                	js     80192f <vprintfmt+0x1f2>
  80198e:	83 ee 01             	sub    $0x1,%esi
  801991:	79 9c                	jns    80192f <vprintfmt+0x1f2>
  801993:	89 df                	mov    %ebx,%edi
  801995:	8b 75 08             	mov    0x8(%ebp),%esi
  801998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80199b:	eb 18                	jmp    8019b5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80199d:	83 ec 08             	sub    $0x8,%esp
  8019a0:	53                   	push   %ebx
  8019a1:	6a 20                	push   $0x20
  8019a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019a5:	83 ef 01             	sub    $0x1,%edi
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	eb 08                	jmp    8019b5 <vprintfmt+0x278>
  8019ad:	89 df                	mov    %ebx,%edi
  8019af:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019b5:	85 ff                	test   %edi,%edi
  8019b7:	7f e4                	jg     80199d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019bc:	e9 a2 fd ff ff       	jmp    801763 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019c1:	83 fa 01             	cmp    $0x1,%edx
  8019c4:	7e 16                	jle    8019dc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c9:	8d 50 08             	lea    0x8(%eax),%edx
  8019cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8019cf:	8b 50 04             	mov    0x4(%eax),%edx
  8019d2:	8b 00                	mov    (%eax),%eax
  8019d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019da:	eb 32                	jmp    801a0e <vprintfmt+0x2d1>
	else if (lflag)
  8019dc:	85 d2                	test   %edx,%edx
  8019de:	74 18                	je     8019f8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e3:	8d 50 04             	lea    0x4(%eax),%edx
  8019e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e9:	8b 00                	mov    (%eax),%eax
  8019eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ee:	89 c1                	mov    %eax,%ecx
  8019f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8019f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019f6:	eb 16                	jmp    801a0e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019fb:	8d 50 04             	lea    0x4(%eax),%edx
  8019fe:	89 55 14             	mov    %edx,0x14(%ebp)
  801a01:	8b 00                	mov    (%eax),%eax
  801a03:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a06:	89 c1                	mov    %eax,%ecx
  801a08:	c1 f9 1f             	sar    $0x1f,%ecx
  801a0b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a0e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a11:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a14:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a19:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a1d:	79 74                	jns    801a93 <vprintfmt+0x356>
				putch('-', putdat);
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	53                   	push   %ebx
  801a23:	6a 2d                	push   $0x2d
  801a25:	ff d6                	call   *%esi
				num = -(long long) num;
  801a27:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a2a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a2d:	f7 d8                	neg    %eax
  801a2f:	83 d2 00             	adc    $0x0,%edx
  801a32:	f7 da                	neg    %edx
  801a34:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a37:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a3c:	eb 55                	jmp    801a93 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a3e:	8d 45 14             	lea    0x14(%ebp),%eax
  801a41:	e8 83 fc ff ff       	call   8016c9 <getuint>
			base = 10;
  801a46:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a4b:	eb 46                	jmp    801a93 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a4d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a50:	e8 74 fc ff ff       	call   8016c9 <getuint>
			base = 8;
  801a55:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a5a:	eb 37                	jmp    801a93 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	53                   	push   %ebx
  801a60:	6a 30                	push   $0x30
  801a62:	ff d6                	call   *%esi
			putch('x', putdat);
  801a64:	83 c4 08             	add    $0x8,%esp
  801a67:	53                   	push   %ebx
  801a68:	6a 78                	push   $0x78
  801a6a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6f:	8d 50 04             	lea    0x4(%eax),%edx
  801a72:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a75:	8b 00                	mov    (%eax),%eax
  801a77:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a7c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a7f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a84:	eb 0d                	jmp    801a93 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a86:	8d 45 14             	lea    0x14(%ebp),%eax
  801a89:	e8 3b fc ff ff       	call   8016c9 <getuint>
			base = 16;
  801a8e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a9a:	57                   	push   %edi
  801a9b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a9e:	51                   	push   %ecx
  801a9f:	52                   	push   %edx
  801aa0:	50                   	push   %eax
  801aa1:	89 da                	mov    %ebx,%edx
  801aa3:	89 f0                	mov    %esi,%eax
  801aa5:	e8 70 fb ff ff       	call   80161a <printnum>
			break;
  801aaa:	83 c4 20             	add    $0x20,%esp
  801aad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ab0:	e9 ae fc ff ff       	jmp    801763 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ab5:	83 ec 08             	sub    $0x8,%esp
  801ab8:	53                   	push   %ebx
  801ab9:	51                   	push   %ecx
  801aba:	ff d6                	call   *%esi
			break;
  801abc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801abf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ac2:	e9 9c fc ff ff       	jmp    801763 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ac7:	83 ec 08             	sub    $0x8,%esp
  801aca:	53                   	push   %ebx
  801acb:	6a 25                	push   $0x25
  801acd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	eb 03                	jmp    801ad7 <vprintfmt+0x39a>
  801ad4:	83 ef 01             	sub    $0x1,%edi
  801ad7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801adb:	75 f7                	jne    801ad4 <vprintfmt+0x397>
  801add:	e9 81 fc ff ff       	jmp    801763 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5f                   	pop    %edi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 18             	sub    $0x18,%esp
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801af6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801af9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801afd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b07:	85 c0                	test   %eax,%eax
  801b09:	74 26                	je     801b31 <vsnprintf+0x47>
  801b0b:	85 d2                	test   %edx,%edx
  801b0d:	7e 22                	jle    801b31 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b0f:	ff 75 14             	pushl  0x14(%ebp)
  801b12:	ff 75 10             	pushl  0x10(%ebp)
  801b15:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b18:	50                   	push   %eax
  801b19:	68 03 17 80 00       	push   $0x801703
  801b1e:	e8 1a fc ff ff       	call   80173d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b23:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b26:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	eb 05                	jmp    801b36 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b3e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b41:	50                   	push   %eax
  801b42:	ff 75 10             	pushl  0x10(%ebp)
  801b45:	ff 75 0c             	pushl  0xc(%ebp)
  801b48:	ff 75 08             	pushl  0x8(%ebp)
  801b4b:	e8 9a ff ff ff       	call   801aea <vsnprintf>
	va_end(ap);

	return rc;
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5d:	eb 03                	jmp    801b62 <strlen+0x10>
		n++;
  801b5f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b62:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b66:	75 f7                	jne    801b5f <strlen+0xd>
		n++;
	return n;
}
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b70:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b73:	ba 00 00 00 00       	mov    $0x0,%edx
  801b78:	eb 03                	jmp    801b7d <strnlen+0x13>
		n++;
  801b7a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b7d:	39 c2                	cmp    %eax,%edx
  801b7f:	74 08                	je     801b89 <strnlen+0x1f>
  801b81:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b85:	75 f3                	jne    801b7a <strnlen+0x10>
  801b87:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	53                   	push   %ebx
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b95:	89 c2                	mov    %eax,%edx
  801b97:	83 c2 01             	add    $0x1,%edx
  801b9a:	83 c1 01             	add    $0x1,%ecx
  801b9d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801ba1:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ba4:	84 db                	test   %bl,%bl
  801ba6:	75 ef                	jne    801b97 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ba8:	5b                   	pop    %ebx
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	53                   	push   %ebx
  801baf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bb2:	53                   	push   %ebx
  801bb3:	e8 9a ff ff ff       	call   801b52 <strlen>
  801bb8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bbb:	ff 75 0c             	pushl  0xc(%ebp)
  801bbe:	01 d8                	add    %ebx,%eax
  801bc0:	50                   	push   %eax
  801bc1:	e8 c5 ff ff ff       	call   801b8b <strcpy>
	return dst;
}
  801bc6:	89 d8                	mov    %ebx,%eax
  801bc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd8:	89 f3                	mov    %esi,%ebx
  801bda:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bdd:	89 f2                	mov    %esi,%edx
  801bdf:	eb 0f                	jmp    801bf0 <strncpy+0x23>
		*dst++ = *src;
  801be1:	83 c2 01             	add    $0x1,%edx
  801be4:	0f b6 01             	movzbl (%ecx),%eax
  801be7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bea:	80 39 01             	cmpb   $0x1,(%ecx)
  801bed:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bf0:	39 da                	cmp    %ebx,%edx
  801bf2:	75 ed                	jne    801be1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bf4:	89 f0                	mov    %esi,%eax
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    

00801bfa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	56                   	push   %esi
  801bfe:	53                   	push   %ebx
  801bff:	8b 75 08             	mov    0x8(%ebp),%esi
  801c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c05:	8b 55 10             	mov    0x10(%ebp),%edx
  801c08:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c0a:	85 d2                	test   %edx,%edx
  801c0c:	74 21                	je     801c2f <strlcpy+0x35>
  801c0e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c12:	89 f2                	mov    %esi,%edx
  801c14:	eb 09                	jmp    801c1f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c16:	83 c2 01             	add    $0x1,%edx
  801c19:	83 c1 01             	add    $0x1,%ecx
  801c1c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c1f:	39 c2                	cmp    %eax,%edx
  801c21:	74 09                	je     801c2c <strlcpy+0x32>
  801c23:	0f b6 19             	movzbl (%ecx),%ebx
  801c26:	84 db                	test   %bl,%bl
  801c28:	75 ec                	jne    801c16 <strlcpy+0x1c>
  801c2a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c2c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c2f:	29 f0                	sub    %esi,%eax
}
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c3e:	eb 06                	jmp    801c46 <strcmp+0x11>
		p++, q++;
  801c40:	83 c1 01             	add    $0x1,%ecx
  801c43:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c46:	0f b6 01             	movzbl (%ecx),%eax
  801c49:	84 c0                	test   %al,%al
  801c4b:	74 04                	je     801c51 <strcmp+0x1c>
  801c4d:	3a 02                	cmp    (%edx),%al
  801c4f:	74 ef                	je     801c40 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c51:	0f b6 c0             	movzbl %al,%eax
  801c54:	0f b6 12             	movzbl (%edx),%edx
  801c57:	29 d0                	sub    %edx,%eax
}
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	53                   	push   %ebx
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c65:	89 c3                	mov    %eax,%ebx
  801c67:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c6a:	eb 06                	jmp    801c72 <strncmp+0x17>
		n--, p++, q++;
  801c6c:	83 c0 01             	add    $0x1,%eax
  801c6f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c72:	39 d8                	cmp    %ebx,%eax
  801c74:	74 15                	je     801c8b <strncmp+0x30>
  801c76:	0f b6 08             	movzbl (%eax),%ecx
  801c79:	84 c9                	test   %cl,%cl
  801c7b:	74 04                	je     801c81 <strncmp+0x26>
  801c7d:	3a 0a                	cmp    (%edx),%cl
  801c7f:	74 eb                	je     801c6c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c81:	0f b6 00             	movzbl (%eax),%eax
  801c84:	0f b6 12             	movzbl (%edx),%edx
  801c87:	29 d0                	sub    %edx,%eax
  801c89:	eb 05                	jmp    801c90 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c8b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c90:	5b                   	pop    %ebx
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	8b 45 08             	mov    0x8(%ebp),%eax
  801c99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c9d:	eb 07                	jmp    801ca6 <strchr+0x13>
		if (*s == c)
  801c9f:	38 ca                	cmp    %cl,%dl
  801ca1:	74 0f                	je     801cb2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ca3:	83 c0 01             	add    $0x1,%eax
  801ca6:	0f b6 10             	movzbl (%eax),%edx
  801ca9:	84 d2                	test   %dl,%dl
  801cab:	75 f2                	jne    801c9f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cbe:	eb 03                	jmp    801cc3 <strfind+0xf>
  801cc0:	83 c0 01             	add    $0x1,%eax
  801cc3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cc6:	38 ca                	cmp    %cl,%dl
  801cc8:	74 04                	je     801cce <strfind+0x1a>
  801cca:	84 d2                	test   %dl,%dl
  801ccc:	75 f2                	jne    801cc0 <strfind+0xc>
			break;
	return (char *) s;
}
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	57                   	push   %edi
  801cd4:	56                   	push   %esi
  801cd5:	53                   	push   %ebx
  801cd6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cdc:	85 c9                	test   %ecx,%ecx
  801cde:	74 36                	je     801d16 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ce0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ce6:	75 28                	jne    801d10 <memset+0x40>
  801ce8:	f6 c1 03             	test   $0x3,%cl
  801ceb:	75 23                	jne    801d10 <memset+0x40>
		c &= 0xFF;
  801ced:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cf1:	89 d3                	mov    %edx,%ebx
  801cf3:	c1 e3 08             	shl    $0x8,%ebx
  801cf6:	89 d6                	mov    %edx,%esi
  801cf8:	c1 e6 18             	shl    $0x18,%esi
  801cfb:	89 d0                	mov    %edx,%eax
  801cfd:	c1 e0 10             	shl    $0x10,%eax
  801d00:	09 f0                	or     %esi,%eax
  801d02:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d04:	89 d8                	mov    %ebx,%eax
  801d06:	09 d0                	or     %edx,%eax
  801d08:	c1 e9 02             	shr    $0x2,%ecx
  801d0b:	fc                   	cld    
  801d0c:	f3 ab                	rep stos %eax,%es:(%edi)
  801d0e:	eb 06                	jmp    801d16 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d13:	fc                   	cld    
  801d14:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d16:	89 f8                	mov    %edi,%eax
  801d18:	5b                   	pop    %ebx
  801d19:	5e                   	pop    %esi
  801d1a:	5f                   	pop    %edi
  801d1b:	5d                   	pop    %ebp
  801d1c:	c3                   	ret    

00801d1d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	57                   	push   %edi
  801d21:	56                   	push   %esi
  801d22:	8b 45 08             	mov    0x8(%ebp),%eax
  801d25:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d2b:	39 c6                	cmp    %eax,%esi
  801d2d:	73 35                	jae    801d64 <memmove+0x47>
  801d2f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d32:	39 d0                	cmp    %edx,%eax
  801d34:	73 2e                	jae    801d64 <memmove+0x47>
		s += n;
		d += n;
  801d36:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d39:	89 d6                	mov    %edx,%esi
  801d3b:	09 fe                	or     %edi,%esi
  801d3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d43:	75 13                	jne    801d58 <memmove+0x3b>
  801d45:	f6 c1 03             	test   $0x3,%cl
  801d48:	75 0e                	jne    801d58 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d4a:	83 ef 04             	sub    $0x4,%edi
  801d4d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d50:	c1 e9 02             	shr    $0x2,%ecx
  801d53:	fd                   	std    
  801d54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d56:	eb 09                	jmp    801d61 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d58:	83 ef 01             	sub    $0x1,%edi
  801d5b:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d5e:	fd                   	std    
  801d5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d61:	fc                   	cld    
  801d62:	eb 1d                	jmp    801d81 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d64:	89 f2                	mov    %esi,%edx
  801d66:	09 c2                	or     %eax,%edx
  801d68:	f6 c2 03             	test   $0x3,%dl
  801d6b:	75 0f                	jne    801d7c <memmove+0x5f>
  801d6d:	f6 c1 03             	test   $0x3,%cl
  801d70:	75 0a                	jne    801d7c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d72:	c1 e9 02             	shr    $0x2,%ecx
  801d75:	89 c7                	mov    %eax,%edi
  801d77:	fc                   	cld    
  801d78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d7a:	eb 05                	jmp    801d81 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d7c:	89 c7                	mov    %eax,%edi
  801d7e:	fc                   	cld    
  801d7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d88:	ff 75 10             	pushl  0x10(%ebp)
  801d8b:	ff 75 0c             	pushl  0xc(%ebp)
  801d8e:	ff 75 08             	pushl  0x8(%ebp)
  801d91:	e8 87 ff ff ff       	call   801d1d <memmove>
}
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	56                   	push   %esi
  801d9c:	53                   	push   %ebx
  801d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801da0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da3:	89 c6                	mov    %eax,%esi
  801da5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801da8:	eb 1a                	jmp    801dc4 <memcmp+0x2c>
		if (*s1 != *s2)
  801daa:	0f b6 08             	movzbl (%eax),%ecx
  801dad:	0f b6 1a             	movzbl (%edx),%ebx
  801db0:	38 d9                	cmp    %bl,%cl
  801db2:	74 0a                	je     801dbe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801db4:	0f b6 c1             	movzbl %cl,%eax
  801db7:	0f b6 db             	movzbl %bl,%ebx
  801dba:	29 d8                	sub    %ebx,%eax
  801dbc:	eb 0f                	jmp    801dcd <memcmp+0x35>
		s1++, s2++;
  801dbe:	83 c0 01             	add    $0x1,%eax
  801dc1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dc4:	39 f0                	cmp    %esi,%eax
  801dc6:	75 e2                	jne    801daa <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	53                   	push   %ebx
  801dd5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dd8:	89 c1                	mov    %eax,%ecx
  801dda:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801ddd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801de1:	eb 0a                	jmp    801ded <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801de3:	0f b6 10             	movzbl (%eax),%edx
  801de6:	39 da                	cmp    %ebx,%edx
  801de8:	74 07                	je     801df1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dea:	83 c0 01             	add    $0x1,%eax
  801ded:	39 c8                	cmp    %ecx,%eax
  801def:	72 f2                	jb     801de3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801df1:	5b                   	pop    %ebx
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    

00801df4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	57                   	push   %edi
  801df8:	56                   	push   %esi
  801df9:	53                   	push   %ebx
  801dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e00:	eb 03                	jmp    801e05 <strtol+0x11>
		s++;
  801e02:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e05:	0f b6 01             	movzbl (%ecx),%eax
  801e08:	3c 20                	cmp    $0x20,%al
  801e0a:	74 f6                	je     801e02 <strtol+0xe>
  801e0c:	3c 09                	cmp    $0x9,%al
  801e0e:	74 f2                	je     801e02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e10:	3c 2b                	cmp    $0x2b,%al
  801e12:	75 0a                	jne    801e1e <strtol+0x2a>
		s++;
  801e14:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e17:	bf 00 00 00 00       	mov    $0x0,%edi
  801e1c:	eb 11                	jmp    801e2f <strtol+0x3b>
  801e1e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e23:	3c 2d                	cmp    $0x2d,%al
  801e25:	75 08                	jne    801e2f <strtol+0x3b>
		s++, neg = 1;
  801e27:	83 c1 01             	add    $0x1,%ecx
  801e2a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e2f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e35:	75 15                	jne    801e4c <strtol+0x58>
  801e37:	80 39 30             	cmpb   $0x30,(%ecx)
  801e3a:	75 10                	jne    801e4c <strtol+0x58>
  801e3c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e40:	75 7c                	jne    801ebe <strtol+0xca>
		s += 2, base = 16;
  801e42:	83 c1 02             	add    $0x2,%ecx
  801e45:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e4a:	eb 16                	jmp    801e62 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e4c:	85 db                	test   %ebx,%ebx
  801e4e:	75 12                	jne    801e62 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e50:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e55:	80 39 30             	cmpb   $0x30,(%ecx)
  801e58:	75 08                	jne    801e62 <strtol+0x6e>
		s++, base = 8;
  801e5a:	83 c1 01             	add    $0x1,%ecx
  801e5d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e62:	b8 00 00 00 00       	mov    $0x0,%eax
  801e67:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e6a:	0f b6 11             	movzbl (%ecx),%edx
  801e6d:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e70:	89 f3                	mov    %esi,%ebx
  801e72:	80 fb 09             	cmp    $0x9,%bl
  801e75:	77 08                	ja     801e7f <strtol+0x8b>
			dig = *s - '0';
  801e77:	0f be d2             	movsbl %dl,%edx
  801e7a:	83 ea 30             	sub    $0x30,%edx
  801e7d:	eb 22                	jmp    801ea1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e7f:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e82:	89 f3                	mov    %esi,%ebx
  801e84:	80 fb 19             	cmp    $0x19,%bl
  801e87:	77 08                	ja     801e91 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e89:	0f be d2             	movsbl %dl,%edx
  801e8c:	83 ea 57             	sub    $0x57,%edx
  801e8f:	eb 10                	jmp    801ea1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e91:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e94:	89 f3                	mov    %esi,%ebx
  801e96:	80 fb 19             	cmp    $0x19,%bl
  801e99:	77 16                	ja     801eb1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e9b:	0f be d2             	movsbl %dl,%edx
  801e9e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ea1:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ea4:	7d 0b                	jge    801eb1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ea6:	83 c1 01             	add    $0x1,%ecx
  801ea9:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ead:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801eaf:	eb b9                	jmp    801e6a <strtol+0x76>

	if (endptr)
  801eb1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eb5:	74 0d                	je     801ec4 <strtol+0xd0>
		*endptr = (char *) s;
  801eb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eba:	89 0e                	mov    %ecx,(%esi)
  801ebc:	eb 06                	jmp    801ec4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ebe:	85 db                	test   %ebx,%ebx
  801ec0:	74 98                	je     801e5a <strtol+0x66>
  801ec2:	eb 9e                	jmp    801e62 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ec4:	89 c2                	mov    %eax,%edx
  801ec6:	f7 da                	neg    %edx
  801ec8:	85 ff                	test   %edi,%edi
  801eca:	0f 45 c2             	cmovne %edx,%eax
}
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5f                   	pop    %edi
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	56                   	push   %esi
  801ed6:	53                   	push   %ebx
  801ed7:	8b 75 08             	mov    0x8(%ebp),%esi
  801eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ee0:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ee2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ee7:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	50                   	push   %eax
  801eee:	e8 12 e4 ff ff       	call   800305 <sys_ipc_recv>

	if (from_env_store != NULL)
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	85 f6                	test   %esi,%esi
  801ef8:	74 14                	je     801f0e <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801efa:	ba 00 00 00 00       	mov    $0x0,%edx
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 09                	js     801f0c <ipc_recv+0x3a>
  801f03:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f09:	8b 52 74             	mov    0x74(%edx),%edx
  801f0c:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f0e:	85 db                	test   %ebx,%ebx
  801f10:	74 14                	je     801f26 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f12:	ba 00 00 00 00       	mov    $0x0,%edx
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 09                	js     801f24 <ipc_recv+0x52>
  801f1b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f21:	8b 52 78             	mov    0x78(%edx),%edx
  801f24:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 08                	js     801f32 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f2a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f2f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5e                   	pop    %esi
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    

00801f39 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	57                   	push   %edi
  801f3d:	56                   	push   %esi
  801f3e:	53                   	push   %ebx
  801f3f:	83 ec 0c             	sub    $0xc,%esp
  801f42:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f45:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f4b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f4d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f52:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f55:	ff 75 14             	pushl  0x14(%ebp)
  801f58:	53                   	push   %ebx
  801f59:	56                   	push   %esi
  801f5a:	57                   	push   %edi
  801f5b:	e8 82 e3 ff ff       	call   8002e2 <sys_ipc_try_send>

		if (err < 0) {
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	85 c0                	test   %eax,%eax
  801f65:	79 1e                	jns    801f85 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f67:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f6a:	75 07                	jne    801f73 <ipc_send+0x3a>
				sys_yield();
  801f6c:	e8 c5 e1 ff ff       	call   800136 <sys_yield>
  801f71:	eb e2                	jmp    801f55 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f73:	50                   	push   %eax
  801f74:	68 20 27 80 00       	push   $0x802720
  801f79:	6a 49                	push   $0x49
  801f7b:	68 2d 27 80 00       	push   $0x80272d
  801f80:	e8 a8 f5 ff ff       	call   80152d <_panic>
		}

	} while (err < 0);

}
  801f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f88:	5b                   	pop    %ebx
  801f89:	5e                   	pop    %esi
  801f8a:	5f                   	pop    %edi
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    

00801f8d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f98:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f9b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fa1:	8b 52 50             	mov    0x50(%edx),%edx
  801fa4:	39 ca                	cmp    %ecx,%edx
  801fa6:	75 0d                	jne    801fb5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fa8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fb0:	8b 40 48             	mov    0x48(%eax),%eax
  801fb3:	eb 0f                	jmp    801fc4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fb5:	83 c0 01             	add    $0x1,%eax
  801fb8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fbd:	75 d9                	jne    801f98 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    

00801fc6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fcc:	89 d0                	mov    %edx,%eax
  801fce:	c1 e8 16             	shr    $0x16,%eax
  801fd1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fdd:	f6 c1 01             	test   $0x1,%cl
  801fe0:	74 1d                	je     801fff <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fe2:	c1 ea 0c             	shr    $0xc,%edx
  801fe5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fec:	f6 c2 01             	test   $0x1,%dl
  801fef:	74 0e                	je     801fff <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ff1:	c1 ea 0c             	shr    $0xc,%edx
  801ff4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ffb:	ef 
  801ffc:	0f b7 c0             	movzwl %ax,%eax
}
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    
  802001:	66 90                	xchg   %ax,%ax
  802003:	66 90                	xchg   %ax,%ax
  802005:	66 90                	xchg   %ax,%ax
  802007:	66 90                	xchg   %ax,%ax
  802009:	66 90                	xchg   %ax,%ax
  80200b:	66 90                	xchg   %ax,%ax
  80200d:	66 90                	xchg   %ax,%ax
  80200f:	90                   	nop

00802010 <__udivdi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80201b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80201f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 f6                	test   %esi,%esi
  802029:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202d:	89 ca                	mov    %ecx,%edx
  80202f:	89 f8                	mov    %edi,%eax
  802031:	75 3d                	jne    802070 <__udivdi3+0x60>
  802033:	39 cf                	cmp    %ecx,%edi
  802035:	0f 87 c5 00 00 00    	ja     802100 <__udivdi3+0xf0>
  80203b:	85 ff                	test   %edi,%edi
  80203d:	89 fd                	mov    %edi,%ebp
  80203f:	75 0b                	jne    80204c <__udivdi3+0x3c>
  802041:	b8 01 00 00 00       	mov    $0x1,%eax
  802046:	31 d2                	xor    %edx,%edx
  802048:	f7 f7                	div    %edi
  80204a:	89 c5                	mov    %eax,%ebp
  80204c:	89 c8                	mov    %ecx,%eax
  80204e:	31 d2                	xor    %edx,%edx
  802050:	f7 f5                	div    %ebp
  802052:	89 c1                	mov    %eax,%ecx
  802054:	89 d8                	mov    %ebx,%eax
  802056:	89 cf                	mov    %ecx,%edi
  802058:	f7 f5                	div    %ebp
  80205a:	89 c3                	mov    %eax,%ebx
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
  802070:	39 ce                	cmp    %ecx,%esi
  802072:	77 74                	ja     8020e8 <__udivdi3+0xd8>
  802074:	0f bd fe             	bsr    %esi,%edi
  802077:	83 f7 1f             	xor    $0x1f,%edi
  80207a:	0f 84 98 00 00 00    	je     802118 <__udivdi3+0x108>
  802080:	bb 20 00 00 00       	mov    $0x20,%ebx
  802085:	89 f9                	mov    %edi,%ecx
  802087:	89 c5                	mov    %eax,%ebp
  802089:	29 fb                	sub    %edi,%ebx
  80208b:	d3 e6                	shl    %cl,%esi
  80208d:	89 d9                	mov    %ebx,%ecx
  80208f:	d3 ed                	shr    %cl,%ebp
  802091:	89 f9                	mov    %edi,%ecx
  802093:	d3 e0                	shl    %cl,%eax
  802095:	09 ee                	or     %ebp,%esi
  802097:	89 d9                	mov    %ebx,%ecx
  802099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209d:	89 d5                	mov    %edx,%ebp
  80209f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020a3:	d3 ed                	shr    %cl,%ebp
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e2                	shl    %cl,%edx
  8020a9:	89 d9                	mov    %ebx,%ecx
  8020ab:	d3 e8                	shr    %cl,%eax
  8020ad:	09 c2                	or     %eax,%edx
  8020af:	89 d0                	mov    %edx,%eax
  8020b1:	89 ea                	mov    %ebp,%edx
  8020b3:	f7 f6                	div    %esi
  8020b5:	89 d5                	mov    %edx,%ebp
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	f7 64 24 0c          	mull   0xc(%esp)
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	72 10                	jb     8020d1 <__udivdi3+0xc1>
  8020c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e6                	shl    %cl,%esi
  8020c9:	39 c6                	cmp    %eax,%esi
  8020cb:	73 07                	jae    8020d4 <__udivdi3+0xc4>
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	75 03                	jne    8020d4 <__udivdi3+0xc4>
  8020d1:	83 eb 01             	sub    $0x1,%ebx
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 d8                	mov    %ebx,%eax
  8020d8:	89 fa                	mov    %edi,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	31 ff                	xor    %edi,%edi
  8020ea:	31 db                	xor    %ebx,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 d8                	mov    %ebx,%eax
  802102:	f7 f7                	div    %edi
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 c3                	mov    %eax,%ebx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 fa                	mov    %edi,%edx
  80210c:	83 c4 1c             	add    $0x1c,%esp
  80210f:	5b                   	pop    %ebx
  802110:	5e                   	pop    %esi
  802111:	5f                   	pop    %edi
  802112:	5d                   	pop    %ebp
  802113:	c3                   	ret    
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	39 ce                	cmp    %ecx,%esi
  80211a:	72 0c                	jb     802128 <__udivdi3+0x118>
  80211c:	31 db                	xor    %ebx,%ebx
  80211e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802122:	0f 87 34 ff ff ff    	ja     80205c <__udivdi3+0x4c>
  802128:	bb 01 00 00 00       	mov    $0x1,%ebx
  80212d:	e9 2a ff ff ff       	jmp    80205c <__udivdi3+0x4c>
  802132:	66 90                	xchg   %ax,%ax
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 1c             	sub    $0x1c,%esp
  802147:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80214b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80214f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802157:	85 d2                	test   %edx,%edx
  802159:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f3                	mov    %esi,%ebx
  802163:	89 3c 24             	mov    %edi,(%esp)
  802166:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216a:	75 1c                	jne    802188 <__umoddi3+0x48>
  80216c:	39 f7                	cmp    %esi,%edi
  80216e:	76 50                	jbe    8021c0 <__umoddi3+0x80>
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	f7 f7                	div    %edi
  802176:	89 d0                	mov    %edx,%eax
  802178:	31 d2                	xor    %edx,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	39 f2                	cmp    %esi,%edx
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	77 52                	ja     8021e0 <__umoddi3+0xa0>
  80218e:	0f bd ea             	bsr    %edx,%ebp
  802191:	83 f5 1f             	xor    $0x1f,%ebp
  802194:	75 5a                	jne    8021f0 <__umoddi3+0xb0>
  802196:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80219a:	0f 82 e0 00 00 00    	jb     802280 <__umoddi3+0x140>
  8021a0:	39 0c 24             	cmp    %ecx,(%esp)
  8021a3:	0f 86 d7 00 00 00    	jbe    802280 <__umoddi3+0x140>
  8021a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021b1:	83 c4 1c             	add    $0x1c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	85 ff                	test   %edi,%edi
  8021c2:	89 fd                	mov    %edi,%ebp
  8021c4:	75 0b                	jne    8021d1 <__umoddi3+0x91>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f7                	div    %edi
  8021cf:	89 c5                	mov    %eax,%ebp
  8021d1:	89 f0                	mov    %esi,%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	f7 f5                	div    %ebp
  8021d7:	89 c8                	mov    %ecx,%eax
  8021d9:	f7 f5                	div    %ebp
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	eb 99                	jmp    802178 <__umoddi3+0x38>
  8021df:	90                   	nop
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	83 c4 1c             	add    $0x1c,%esp
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5f                   	pop    %edi
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	8b 34 24             	mov    (%esp),%esi
  8021f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021f8:	89 e9                	mov    %ebp,%ecx
  8021fa:	29 ef                	sub    %ebp,%edi
  8021fc:	d3 e0                	shl    %cl,%eax
  8021fe:	89 f9                	mov    %edi,%ecx
  802200:	89 f2                	mov    %esi,%edx
  802202:	d3 ea                	shr    %cl,%edx
  802204:	89 e9                	mov    %ebp,%ecx
  802206:	09 c2                	or     %eax,%edx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 14 24             	mov    %edx,(%esp)
  80220d:	89 f2                	mov    %esi,%edx
  80220f:	d3 e2                	shl    %cl,%edx
  802211:	89 f9                	mov    %edi,%ecx
  802213:	89 54 24 04          	mov    %edx,0x4(%esp)
  802217:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	89 c6                	mov    %eax,%esi
  802221:	d3 e3                	shl    %cl,%ebx
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 d0                	mov    %edx,%eax
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	09 d8                	or     %ebx,%eax
  80222d:	89 d3                	mov    %edx,%ebx
  80222f:	89 f2                	mov    %esi,%edx
  802231:	f7 34 24             	divl   (%esp)
  802234:	89 d6                	mov    %edx,%esi
  802236:	d3 e3                	shl    %cl,%ebx
  802238:	f7 64 24 04          	mull   0x4(%esp)
  80223c:	39 d6                	cmp    %edx,%esi
  80223e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802242:	89 d1                	mov    %edx,%ecx
  802244:	89 c3                	mov    %eax,%ebx
  802246:	72 08                	jb     802250 <__umoddi3+0x110>
  802248:	75 11                	jne    80225b <__umoddi3+0x11b>
  80224a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80224e:	73 0b                	jae    80225b <__umoddi3+0x11b>
  802250:	2b 44 24 04          	sub    0x4(%esp),%eax
  802254:	1b 14 24             	sbb    (%esp),%edx
  802257:	89 d1                	mov    %edx,%ecx
  802259:	89 c3                	mov    %eax,%ebx
  80225b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80225f:	29 da                	sub    %ebx,%edx
  802261:	19 ce                	sbb    %ecx,%esi
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 f0                	mov    %esi,%eax
  802267:	d3 e0                	shl    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	d3 ea                	shr    %cl,%edx
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	d3 ee                	shr    %cl,%esi
  802271:	09 d0                	or     %edx,%eax
  802273:	89 f2                	mov    %esi,%edx
  802275:	83 c4 1c             	add    $0x1c,%esp
  802278:	5b                   	pop    %ebx
  802279:	5e                   	pop    %esi
  80227a:	5f                   	pop    %edi
  80227b:	5d                   	pop    %ebp
  80227c:	c3                   	ret    
  80227d:	8d 76 00             	lea    0x0(%esi),%esi
  802280:	29 f9                	sub    %edi,%ecx
  802282:	19 d6                	sbb    %edx,%esi
  802284:	89 74 24 04          	mov    %esi,0x4(%esp)
  802288:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80228c:	e9 18 ff ff ff       	jmp    8021a9 <__umoddi3+0x69>
