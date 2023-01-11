
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 2a 05 00 00       	call   8005b9 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 aa 22 80 00       	push   $0x8022aa
  800108:	6a 23                	push   $0x23
  80010a:	68 c7 22 80 00       	push   $0x8022c7
  80010f:	e8 1e 14 00 00       	call   801532 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 aa 22 80 00       	push   $0x8022aa
  800189:	6a 23                	push   $0x23
  80018b:	68 c7 22 80 00       	push   $0x8022c7
  800190:	e8 9d 13 00 00       	call   801532 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 aa 22 80 00       	push   $0x8022aa
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 c7 22 80 00       	push   $0x8022c7
  8001d2:	e8 5b 13 00 00       	call   801532 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 aa 22 80 00       	push   $0x8022aa
  80020d:	6a 23                	push   $0x23
  80020f:	68 c7 22 80 00       	push   $0x8022c7
  800214:	e8 19 13 00 00       	call   801532 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 aa 22 80 00       	push   $0x8022aa
  80024f:	6a 23                	push   $0x23
  800251:	68 c7 22 80 00       	push   $0x8022c7
  800256:	e8 d7 12 00 00       	call   801532 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 aa 22 80 00       	push   $0x8022aa
  800291:	6a 23                	push   $0x23
  800293:	68 c7 22 80 00       	push   $0x8022c7
  800298:	e8 95 12 00 00       	call   801532 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 aa 22 80 00       	push   $0x8022aa
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 c7 22 80 00       	push   $0x8022c7
  8002da:	e8 53 12 00 00       	call   801532 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 aa 22 80 00       	push   $0x8022aa
  800337:	6a 23                	push   $0x23
  800339:	68 c7 22 80 00       	push   $0x8022c7
  80033e:	e8 ef 11 00 00       	call   801532 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035b:	89 d1                	mov    %edx,%ecx
  80035d:	89 d3                	mov    %edx,%ebx
  80035f:	89 d7                	mov    %edx,%edi
  800361:	89 d6                	mov    %edx,%esi
  800363:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800373:	bb 00 00 00 00       	mov    $0x0,%ebx
  800378:	b8 0f 00 00 00       	mov    $0xf,%eax
  80037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800380:	8b 55 08             	mov    0x8(%ebp),%edx
  800383:	89 df                	mov    %ebx,%edi
  800385:	89 de                	mov    %ebx,%esi
  800387:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800389:	85 c0                	test   %eax,%eax
  80038b:	7e 17                	jle    8003a4 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	6a 0f                	push   $0xf
  800393:	68 aa 22 80 00       	push   $0x8022aa
  800398:	6a 23                	push   $0x23
  80039a:	68 c7 22 80 00       	push   $0x8022c7
  80039f:	e8 8e 11 00 00       	call   801532 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a7:	5b                   	pop    %ebx
  8003a8:	5e                   	pop    %esi
  8003a9:	5f                   	pop    %edi
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ba:	b8 10 00 00 00       	mov    $0x10,%eax
  8003bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	89 df                	mov    %ebx,%edi
  8003c7:	89 de                	mov    %ebx,%esi
  8003c9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003cb:	85 c0                	test   %eax,%eax
  8003cd:	7e 17                	jle    8003e6 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003cf:	83 ec 0c             	sub    $0xc,%esp
  8003d2:	50                   	push   %eax
  8003d3:	6a 10                	push   $0x10
  8003d5:	68 aa 22 80 00       	push   $0x8022aa
  8003da:	6a 23                	push   $0x23
  8003dc:	68 c7 22 80 00       	push   $0x8022c7
  8003e1:	e8 4c 11 00 00       	call   801532 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8003e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e9:	5b                   	pop    %ebx
  8003ea:	5e                   	pop    %esi
  8003eb:	5f                   	pop    %edi
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f9:	c1 e8 0c             	shr    $0xc,%eax
}
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    

008003fe <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	05 00 00 00 30       	add    $0x30000000,%eax
  800409:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80040e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800420:	89 c2                	mov    %eax,%edx
  800422:	c1 ea 16             	shr    $0x16,%edx
  800425:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042c:	f6 c2 01             	test   $0x1,%dl
  80042f:	74 11                	je     800442 <fd_alloc+0x2d>
  800431:	89 c2                	mov    %eax,%edx
  800433:	c1 ea 0c             	shr    $0xc,%edx
  800436:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043d:	f6 c2 01             	test   $0x1,%dl
  800440:	75 09                	jne    80044b <fd_alloc+0x36>
			*fd_store = fd;
  800442:	89 01                	mov    %eax,(%ecx)
			return 0;
  800444:	b8 00 00 00 00       	mov    $0x0,%eax
  800449:	eb 17                	jmp    800462 <fd_alloc+0x4d>
  80044b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800450:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800455:	75 c9                	jne    800420 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800457:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80045d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800462:	5d                   	pop    %ebp
  800463:	c3                   	ret    

00800464 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80046a:	83 f8 1f             	cmp    $0x1f,%eax
  80046d:	77 36                	ja     8004a5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80046f:	c1 e0 0c             	shl    $0xc,%eax
  800472:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800477:	89 c2                	mov    %eax,%edx
  800479:	c1 ea 16             	shr    $0x16,%edx
  80047c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800483:	f6 c2 01             	test   $0x1,%dl
  800486:	74 24                	je     8004ac <fd_lookup+0x48>
  800488:	89 c2                	mov    %eax,%edx
  80048a:	c1 ea 0c             	shr    $0xc,%edx
  80048d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800494:	f6 c2 01             	test   $0x1,%dl
  800497:	74 1a                	je     8004b3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800499:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049c:	89 02                	mov    %eax,(%edx)
	return 0;
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	eb 13                	jmp    8004b8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004aa:	eb 0c                	jmp    8004b8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b1:	eb 05                	jmp    8004b8 <fd_lookup+0x54>
  8004b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004b8:	5d                   	pop    %ebp
  8004b9:	c3                   	ret    

008004ba <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004ba:	55                   	push   %ebp
  8004bb:	89 e5                	mov    %esp,%ebp
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c3:	ba 54 23 80 00       	mov    $0x802354,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004c8:	eb 13                	jmp    8004dd <dev_lookup+0x23>
  8004ca:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004cd:	39 08                	cmp    %ecx,(%eax)
  8004cf:	75 0c                	jne    8004dd <dev_lookup+0x23>
			*dev = devtab[i];
  8004d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	eb 2e                	jmp    80050b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004dd:	8b 02                	mov    (%edx),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	75 e7                	jne    8004ca <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e3:	a1 08 40 80 00       	mov    0x804008,%eax
  8004e8:	8b 40 48             	mov    0x48(%eax),%eax
  8004eb:	83 ec 04             	sub    $0x4,%esp
  8004ee:	51                   	push   %ecx
  8004ef:	50                   	push   %eax
  8004f0:	68 d8 22 80 00       	push   $0x8022d8
  8004f5:	e8 11 11 00 00       	call   80160b <cprintf>
	*dev = 0;
  8004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80050b:	c9                   	leave  
  80050c:	c3                   	ret    

0080050d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	56                   	push   %esi
  800511:	53                   	push   %ebx
  800512:	83 ec 10             	sub    $0x10,%esp
  800515:	8b 75 08             	mov    0x8(%ebp),%esi
  800518:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80051b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051e:	50                   	push   %eax
  80051f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800525:	c1 e8 0c             	shr    $0xc,%eax
  800528:	50                   	push   %eax
  800529:	e8 36 ff ff ff       	call   800464 <fd_lookup>
  80052e:	83 c4 08             	add    $0x8,%esp
  800531:	85 c0                	test   %eax,%eax
  800533:	78 05                	js     80053a <fd_close+0x2d>
	    || fd != fd2)
  800535:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800538:	74 0c                	je     800546 <fd_close+0x39>
		return (must_exist ? r : 0);
  80053a:	84 db                	test   %bl,%bl
  80053c:	ba 00 00 00 00       	mov    $0x0,%edx
  800541:	0f 44 c2             	cmove  %edx,%eax
  800544:	eb 41                	jmp    800587 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80054c:	50                   	push   %eax
  80054d:	ff 36                	pushl  (%esi)
  80054f:	e8 66 ff ff ff       	call   8004ba <dev_lookup>
  800554:	89 c3                	mov    %eax,%ebx
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 c0                	test   %eax,%eax
  80055b:	78 1a                	js     800577 <fd_close+0x6a>
		if (dev->dev_close)
  80055d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800560:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800563:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800568:	85 c0                	test   %eax,%eax
  80056a:	74 0b                	je     800577 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80056c:	83 ec 0c             	sub    $0xc,%esp
  80056f:	56                   	push   %esi
  800570:	ff d0                	call   *%eax
  800572:	89 c3                	mov    %eax,%ebx
  800574:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	56                   	push   %esi
  80057b:	6a 00                	push   $0x0
  80057d:	e8 5d fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 d8                	mov    %ebx,%eax
}
  800587:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5d                   	pop    %ebp
  80058d:	c3                   	ret    

0080058e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80058e:	55                   	push   %ebp
  80058f:	89 e5                	mov    %esp,%ebp
  800591:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800594:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800597:	50                   	push   %eax
  800598:	ff 75 08             	pushl  0x8(%ebp)
  80059b:	e8 c4 fe ff ff       	call   800464 <fd_lookup>
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	78 10                	js     8005b7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	6a 01                	push   $0x1
  8005ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8005af:	e8 59 ff ff ff       	call   80050d <fd_close>
  8005b4:	83 c4 10             	add    $0x10,%esp
}
  8005b7:	c9                   	leave  
  8005b8:	c3                   	ret    

008005b9 <close_all>:

void
close_all(void)
{
  8005b9:	55                   	push   %ebp
  8005ba:	89 e5                	mov    %esp,%ebp
  8005bc:	53                   	push   %ebx
  8005bd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	e8 c0 ff ff ff       	call   80058e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ce:	83 c3 01             	add    $0x1,%ebx
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	83 fb 20             	cmp    $0x20,%ebx
  8005d7:	75 ec                	jne    8005c5 <close_all+0xc>
		close(i);
}
  8005d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005dc:	c9                   	leave  
  8005dd:	c3                   	ret    

008005de <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005de:	55                   	push   %ebp
  8005df:	89 e5                	mov    %esp,%ebp
  8005e1:	57                   	push   %edi
  8005e2:	56                   	push   %esi
  8005e3:	53                   	push   %ebx
  8005e4:	83 ec 2c             	sub    $0x2c,%esp
  8005e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ed:	50                   	push   %eax
  8005ee:	ff 75 08             	pushl  0x8(%ebp)
  8005f1:	e8 6e fe ff ff       	call   800464 <fd_lookup>
  8005f6:	83 c4 08             	add    $0x8,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	0f 88 c1 00 00 00    	js     8006c2 <dup+0xe4>
		return r;
	close(newfdnum);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	56                   	push   %esi
  800605:	e8 84 ff ff ff       	call   80058e <close>

	newfd = INDEX2FD(newfdnum);
  80060a:	89 f3                	mov    %esi,%ebx
  80060c:	c1 e3 0c             	shl    $0xc,%ebx
  80060f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800615:	83 c4 04             	add    $0x4,%esp
  800618:	ff 75 e4             	pushl  -0x1c(%ebp)
  80061b:	e8 de fd ff ff       	call   8003fe <fd2data>
  800620:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800622:	89 1c 24             	mov    %ebx,(%esp)
  800625:	e8 d4 fd ff ff       	call   8003fe <fd2data>
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800630:	89 f8                	mov    %edi,%eax
  800632:	c1 e8 16             	shr    $0x16,%eax
  800635:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80063c:	a8 01                	test   $0x1,%al
  80063e:	74 37                	je     800677 <dup+0x99>
  800640:	89 f8                	mov    %edi,%eax
  800642:	c1 e8 0c             	shr    $0xc,%eax
  800645:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80064c:	f6 c2 01             	test   $0x1,%dl
  80064f:	74 26                	je     800677 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800651:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800658:	83 ec 0c             	sub    $0xc,%esp
  80065b:	25 07 0e 00 00       	and    $0xe07,%eax
  800660:	50                   	push   %eax
  800661:	ff 75 d4             	pushl  -0x2c(%ebp)
  800664:	6a 00                	push   $0x0
  800666:	57                   	push   %edi
  800667:	6a 00                	push   $0x0
  800669:	e8 2f fb ff ff       	call   80019d <sys_page_map>
  80066e:	89 c7                	mov    %eax,%edi
  800670:	83 c4 20             	add    $0x20,%esp
  800673:	85 c0                	test   %eax,%eax
  800675:	78 2e                	js     8006a5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800677:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067a:	89 d0                	mov    %edx,%eax
  80067c:	c1 e8 0c             	shr    $0xc,%eax
  80067f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800686:	83 ec 0c             	sub    $0xc,%esp
  800689:	25 07 0e 00 00       	and    $0xe07,%eax
  80068e:	50                   	push   %eax
  80068f:	53                   	push   %ebx
  800690:	6a 00                	push   $0x0
  800692:	52                   	push   %edx
  800693:	6a 00                	push   $0x0
  800695:	e8 03 fb ff ff       	call   80019d <sys_page_map>
  80069a:	89 c7                	mov    %eax,%edi
  80069c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80069f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a1:	85 ff                	test   %edi,%edi
  8006a3:	79 1d                	jns    8006c2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 00                	push   $0x0
  8006ab:	e8 2f fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006b0:	83 c4 08             	add    $0x8,%esp
  8006b3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006b6:	6a 00                	push   $0x0
  8006b8:	e8 22 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	89 f8                	mov    %edi,%eax
}
  8006c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c5:	5b                   	pop    %ebx
  8006c6:	5e                   	pop    %esi
  8006c7:	5f                   	pop    %edi
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 14             	sub    $0x14,%esp
  8006d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006d7:	50                   	push   %eax
  8006d8:	53                   	push   %ebx
  8006d9:	e8 86 fd ff ff       	call   800464 <fd_lookup>
  8006de:	83 c4 08             	add    $0x8,%esp
  8006e1:	89 c2                	mov    %eax,%edx
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	78 6d                	js     800754 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ed:	50                   	push   %eax
  8006ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f1:	ff 30                	pushl  (%eax)
  8006f3:	e8 c2 fd ff ff       	call   8004ba <dev_lookup>
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	78 4c                	js     80074b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800702:	8b 42 08             	mov    0x8(%edx),%eax
  800705:	83 e0 03             	and    $0x3,%eax
  800708:	83 f8 01             	cmp    $0x1,%eax
  80070b:	75 21                	jne    80072e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80070d:	a1 08 40 80 00       	mov    0x804008,%eax
  800712:	8b 40 48             	mov    0x48(%eax),%eax
  800715:	83 ec 04             	sub    $0x4,%esp
  800718:	53                   	push   %ebx
  800719:	50                   	push   %eax
  80071a:	68 19 23 80 00       	push   $0x802319
  80071f:	e8 e7 0e 00 00       	call   80160b <cprintf>
		return -E_INVAL;
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80072c:	eb 26                	jmp    800754 <read+0x8a>
	}
	if (!dev->dev_read)
  80072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800731:	8b 40 08             	mov    0x8(%eax),%eax
  800734:	85 c0                	test   %eax,%eax
  800736:	74 17                	je     80074f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800738:	83 ec 04             	sub    $0x4,%esp
  80073b:	ff 75 10             	pushl  0x10(%ebp)
  80073e:	ff 75 0c             	pushl  0xc(%ebp)
  800741:	52                   	push   %edx
  800742:	ff d0                	call   *%eax
  800744:	89 c2                	mov    %eax,%edx
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	eb 09                	jmp    800754 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80074b:	89 c2                	mov    %eax,%edx
  80074d:	eb 05                	jmp    800754 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80074f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800754:	89 d0                	mov    %edx,%eax
  800756:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	57                   	push   %edi
  80075f:	56                   	push   %esi
  800760:	53                   	push   %ebx
  800761:	83 ec 0c             	sub    $0xc,%esp
  800764:	8b 7d 08             	mov    0x8(%ebp),%edi
  800767:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80076a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80076f:	eb 21                	jmp    800792 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800771:	83 ec 04             	sub    $0x4,%esp
  800774:	89 f0                	mov    %esi,%eax
  800776:	29 d8                	sub    %ebx,%eax
  800778:	50                   	push   %eax
  800779:	89 d8                	mov    %ebx,%eax
  80077b:	03 45 0c             	add    0xc(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	57                   	push   %edi
  800780:	e8 45 ff ff ff       	call   8006ca <read>
		if (m < 0)
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	85 c0                	test   %eax,%eax
  80078a:	78 10                	js     80079c <readn+0x41>
			return m;
		if (m == 0)
  80078c:	85 c0                	test   %eax,%eax
  80078e:	74 0a                	je     80079a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800790:	01 c3                	add    %eax,%ebx
  800792:	39 f3                	cmp    %esi,%ebx
  800794:	72 db                	jb     800771 <readn+0x16>
  800796:	89 d8                	mov    %ebx,%eax
  800798:	eb 02                	jmp    80079c <readn+0x41>
  80079a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80079c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079f:	5b                   	pop    %ebx
  8007a0:	5e                   	pop    %esi
  8007a1:	5f                   	pop    %edi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	83 ec 14             	sub    $0x14,%esp
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	53                   	push   %ebx
  8007b3:	e8 ac fc ff ff       	call   800464 <fd_lookup>
  8007b8:	83 c4 08             	add    $0x8,%esp
  8007bb:	89 c2                	mov    %eax,%edx
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	78 68                	js     800829 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cb:	ff 30                	pushl  (%eax)
  8007cd:	e8 e8 fc ff ff       	call   8004ba <dev_lookup>
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	78 47                	js     800820 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e0:	75 21                	jne    800803 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8007e7:	8b 40 48             	mov    0x48(%eax),%eax
  8007ea:	83 ec 04             	sub    $0x4,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	50                   	push   %eax
  8007ef:	68 35 23 80 00       	push   $0x802335
  8007f4:	e8 12 0e 00 00       	call   80160b <cprintf>
		return -E_INVAL;
  8007f9:	83 c4 10             	add    $0x10,%esp
  8007fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800801:	eb 26                	jmp    800829 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800803:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800806:	8b 52 0c             	mov    0xc(%edx),%edx
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 17                	je     800824 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80080d:	83 ec 04             	sub    $0x4,%esp
  800810:	ff 75 10             	pushl  0x10(%ebp)
  800813:	ff 75 0c             	pushl  0xc(%ebp)
  800816:	50                   	push   %eax
  800817:	ff d2                	call   *%edx
  800819:	89 c2                	mov    %eax,%edx
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	eb 09                	jmp    800829 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800820:	89 c2                	mov    %eax,%edx
  800822:	eb 05                	jmp    800829 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800824:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800829:	89 d0                	mov    %edx,%eax
  80082b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <seek>:

int
seek(int fdnum, off_t offset)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800836:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800839:	50                   	push   %eax
  80083a:	ff 75 08             	pushl  0x8(%ebp)
  80083d:	e8 22 fc ff ff       	call   800464 <fd_lookup>
  800842:	83 c4 08             	add    $0x8,%esp
  800845:	85 c0                	test   %eax,%eax
  800847:	78 0e                	js     800857 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800849:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	83 ec 14             	sub    $0x14,%esp
  800860:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800866:	50                   	push   %eax
  800867:	53                   	push   %ebx
  800868:	e8 f7 fb ff ff       	call   800464 <fd_lookup>
  80086d:	83 c4 08             	add    $0x8,%esp
  800870:	89 c2                	mov    %eax,%edx
  800872:	85 c0                	test   %eax,%eax
  800874:	78 65                	js     8008db <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087c:	50                   	push   %eax
  80087d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800880:	ff 30                	pushl  (%eax)
  800882:	e8 33 fc ff ff       	call   8004ba <dev_lookup>
  800887:	83 c4 10             	add    $0x10,%esp
  80088a:	85 c0                	test   %eax,%eax
  80088c:	78 44                	js     8008d2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80088e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800891:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800895:	75 21                	jne    8008b8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800897:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80089c:	8b 40 48             	mov    0x48(%eax),%eax
  80089f:	83 ec 04             	sub    $0x4,%esp
  8008a2:	53                   	push   %ebx
  8008a3:	50                   	push   %eax
  8008a4:	68 f8 22 80 00       	push   $0x8022f8
  8008a9:	e8 5d 0d 00 00       	call   80160b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008b6:	eb 23                	jmp    8008db <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008bb:	8b 52 18             	mov    0x18(%edx),%edx
  8008be:	85 d2                	test   %edx,%edx
  8008c0:	74 14                	je     8008d6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	ff 75 0c             	pushl  0xc(%ebp)
  8008c8:	50                   	push   %eax
  8008c9:	ff d2                	call   *%edx
  8008cb:	89 c2                	mov    %eax,%edx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	eb 09                	jmp    8008db <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d2:	89 c2                	mov    %eax,%edx
  8008d4:	eb 05                	jmp    8008db <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008db:	89 d0                	mov    %edx,%eax
  8008dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	83 ec 14             	sub    $0x14,%esp
  8008e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ef:	50                   	push   %eax
  8008f0:	ff 75 08             	pushl  0x8(%ebp)
  8008f3:	e8 6c fb ff ff       	call   800464 <fd_lookup>
  8008f8:	83 c4 08             	add    $0x8,%esp
  8008fb:	89 c2                	mov    %eax,%edx
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	78 58                	js     800959 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800907:	50                   	push   %eax
  800908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80090b:	ff 30                	pushl  (%eax)
  80090d:	e8 a8 fb ff ff       	call   8004ba <dev_lookup>
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	85 c0                	test   %eax,%eax
  800917:	78 37                	js     800950 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800919:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800920:	74 32                	je     800954 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800922:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800925:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80092c:	00 00 00 
	stat->st_isdir = 0;
  80092f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800936:	00 00 00 
	stat->st_dev = dev;
  800939:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80093f:	83 ec 08             	sub    $0x8,%esp
  800942:	53                   	push   %ebx
  800943:	ff 75 f0             	pushl  -0x10(%ebp)
  800946:	ff 50 14             	call   *0x14(%eax)
  800949:	89 c2                	mov    %eax,%edx
  80094b:	83 c4 10             	add    $0x10,%esp
  80094e:	eb 09                	jmp    800959 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800950:	89 c2                	mov    %eax,%edx
  800952:	eb 05                	jmp    800959 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800954:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800959:	89 d0                	mov    %edx,%eax
  80095b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800965:	83 ec 08             	sub    $0x8,%esp
  800968:	6a 00                	push   $0x0
  80096a:	ff 75 08             	pushl  0x8(%ebp)
  80096d:	e8 d6 01 00 00       	call   800b48 <open>
  800972:	89 c3                	mov    %eax,%ebx
  800974:	83 c4 10             	add    $0x10,%esp
  800977:	85 c0                	test   %eax,%eax
  800979:	78 1b                	js     800996 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80097b:	83 ec 08             	sub    $0x8,%esp
  80097e:	ff 75 0c             	pushl  0xc(%ebp)
  800981:	50                   	push   %eax
  800982:	e8 5b ff ff ff       	call   8008e2 <fstat>
  800987:	89 c6                	mov    %eax,%esi
	close(fd);
  800989:	89 1c 24             	mov    %ebx,(%esp)
  80098c:	e8 fd fb ff ff       	call   80058e <close>
	return r;
  800991:	83 c4 10             	add    $0x10,%esp
  800994:	89 f0                	mov    %esi,%eax
}
  800996:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	89 c6                	mov    %eax,%esi
  8009a4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009a6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009ad:	75 12                	jne    8009c1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009af:	83 ec 0c             	sub    $0xc,%esp
  8009b2:	6a 01                	push   $0x1
  8009b4:	e8 d9 15 00 00       	call   801f92 <ipc_find_env>
  8009b9:	a3 00 40 80 00       	mov    %eax,0x804000
  8009be:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009c1:	6a 07                	push   $0x7
  8009c3:	68 00 50 80 00       	push   $0x805000
  8009c8:	56                   	push   %esi
  8009c9:	ff 35 00 40 80 00    	pushl  0x804000
  8009cf:	e8 6a 15 00 00       	call   801f3e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009d4:	83 c4 0c             	add    $0xc,%esp
  8009d7:	6a 00                	push   $0x0
  8009d9:	53                   	push   %ebx
  8009da:	6a 00                	push   $0x0
  8009dc:	e8 f6 14 00 00       	call   801ed7 <ipc_recv>
}
  8009e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a01:	ba 00 00 00 00       	mov    $0x0,%edx
  800a06:	b8 02 00 00 00       	mov    $0x2,%eax
  800a0b:	e8 8d ff ff ff       	call   80099d <fsipc>
}
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a23:	ba 00 00 00 00       	mov    $0x0,%edx
  800a28:	b8 06 00 00 00       	mov    $0x6,%eax
  800a2d:	e8 6b ff ff ff       	call   80099d <fsipc>
}
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	53                   	push   %ebx
  800a38:	83 ec 04             	sub    $0x4,%esp
  800a3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 40 0c             	mov    0xc(%eax),%eax
  800a44:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	b8 05 00 00 00       	mov    $0x5,%eax
  800a53:	e8 45 ff ff ff       	call   80099d <fsipc>
  800a58:	85 c0                	test   %eax,%eax
  800a5a:	78 2c                	js     800a88 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	68 00 50 80 00       	push   $0x805000
  800a64:	53                   	push   %ebx
  800a65:	e8 26 11 00 00       	call   801b90 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a6a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a75:	a1 84 50 80 00       	mov    0x805084,%eax
  800a7a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a80:	83 c4 10             	add    $0x10,%esp
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	83 ec 0c             	sub    $0xc,%esp
  800a93:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
  800a99:	8b 52 0c             	mov    0xc(%edx),%edx
  800a9c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800aa2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800aa7:	50                   	push   %eax
  800aa8:	ff 75 0c             	pushl  0xc(%ebp)
  800aab:	68 08 50 80 00       	push   $0x805008
  800ab0:	e8 6d 12 00 00       	call   801d22 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aba:	b8 04 00 00 00       	mov    $0x4,%eax
  800abf:	e8 d9 fe ff ff       	call   80099d <fsipc>

}
  800ac4:	c9                   	leave  
  800ac5:	c3                   	ret    

00800ac6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ad4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ad9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800adf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae9:	e8 af fe ff ff       	call   80099d <fsipc>
  800aee:	89 c3                	mov    %eax,%ebx
  800af0:	85 c0                	test   %eax,%eax
  800af2:	78 4b                	js     800b3f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800af4:	39 c6                	cmp    %eax,%esi
  800af6:	73 16                	jae    800b0e <devfile_read+0x48>
  800af8:	68 68 23 80 00       	push   $0x802368
  800afd:	68 6f 23 80 00       	push   $0x80236f
  800b02:	6a 7c                	push   $0x7c
  800b04:	68 84 23 80 00       	push   $0x802384
  800b09:	e8 24 0a 00 00       	call   801532 <_panic>
	assert(r <= PGSIZE);
  800b0e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b13:	7e 16                	jle    800b2b <devfile_read+0x65>
  800b15:	68 8f 23 80 00       	push   $0x80238f
  800b1a:	68 6f 23 80 00       	push   $0x80236f
  800b1f:	6a 7d                	push   $0x7d
  800b21:	68 84 23 80 00       	push   $0x802384
  800b26:	e8 07 0a 00 00       	call   801532 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b2b:	83 ec 04             	sub    $0x4,%esp
  800b2e:	50                   	push   %eax
  800b2f:	68 00 50 80 00       	push   $0x805000
  800b34:	ff 75 0c             	pushl  0xc(%ebp)
  800b37:	e8 e6 11 00 00       	call   801d22 <memmove>
	return r;
  800b3c:	83 c4 10             	add    $0x10,%esp
}
  800b3f:	89 d8                	mov    %ebx,%eax
  800b41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	53                   	push   %ebx
  800b4c:	83 ec 20             	sub    $0x20,%esp
  800b4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b52:	53                   	push   %ebx
  800b53:	e8 ff 0f 00 00       	call   801b57 <strlen>
  800b58:	83 c4 10             	add    $0x10,%esp
  800b5b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b60:	7f 67                	jg     800bc9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b68:	50                   	push   %eax
  800b69:	e8 a7 f8 ff ff       	call   800415 <fd_alloc>
  800b6e:	83 c4 10             	add    $0x10,%esp
		return r;
  800b71:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b73:	85 c0                	test   %eax,%eax
  800b75:	78 57                	js     800bce <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b77:	83 ec 08             	sub    $0x8,%esp
  800b7a:	53                   	push   %ebx
  800b7b:	68 00 50 80 00       	push   $0x805000
  800b80:	e8 0b 10 00 00       	call   801b90 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b88:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b90:	b8 01 00 00 00       	mov    $0x1,%eax
  800b95:	e8 03 fe ff ff       	call   80099d <fsipc>
  800b9a:	89 c3                	mov    %eax,%ebx
  800b9c:	83 c4 10             	add    $0x10,%esp
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	79 14                	jns    800bb7 <open+0x6f>
		fd_close(fd, 0);
  800ba3:	83 ec 08             	sub    $0x8,%esp
  800ba6:	6a 00                	push   $0x0
  800ba8:	ff 75 f4             	pushl  -0xc(%ebp)
  800bab:	e8 5d f9 ff ff       	call   80050d <fd_close>
		return r;
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	89 da                	mov    %ebx,%edx
  800bb5:	eb 17                	jmp    800bce <open+0x86>
	}

	return fd2num(fd);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	ff 75 f4             	pushl  -0xc(%ebp)
  800bbd:	e8 2c f8 ff ff       	call   8003ee <fd2num>
  800bc2:	89 c2                	mov    %eax,%edx
  800bc4:	83 c4 10             	add    $0x10,%esp
  800bc7:	eb 05                	jmp    800bce <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bc9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bce:	89 d0                	mov    %edx,%eax
  800bd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 08 00 00 00       	mov    $0x8,%eax
  800be5:	e8 b3 fd ff ff       	call   80099d <fsipc>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bf2:	68 9b 23 80 00       	push   $0x80239b
  800bf7:	ff 75 0c             	pushl  0xc(%ebp)
  800bfa:	e8 91 0f 00 00       	call   801b90 <strcpy>
	return 0;
}
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 10             	sub    $0x10,%esp
  800c0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c10:	53                   	push   %ebx
  800c11:	e8 b5 13 00 00       	call   801fcb <pageref>
  800c16:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c19:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c1e:	83 f8 01             	cmp    $0x1,%eax
  800c21:	75 10                	jne    800c33 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	ff 73 0c             	pushl  0xc(%ebx)
  800c29:	e8 c0 02 00 00       	call   800eee <nsipc_close>
  800c2e:	89 c2                	mov    %eax,%edx
  800c30:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c33:	89 d0                	mov    %edx,%eax
  800c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c40:	6a 00                	push   $0x0
  800c42:	ff 75 10             	pushl  0x10(%ebp)
  800c45:	ff 75 0c             	pushl  0xc(%ebp)
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4b:	ff 70 0c             	pushl  0xc(%eax)
  800c4e:	e8 78 03 00 00       	call   800fcb <nsipc_send>
}
  800c53:	c9                   	leave  
  800c54:	c3                   	ret    

00800c55 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c5b:	6a 00                	push   $0x0
  800c5d:	ff 75 10             	pushl  0x10(%ebp)
  800c60:	ff 75 0c             	pushl  0xc(%ebp)
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	ff 70 0c             	pushl  0xc(%eax)
  800c69:	e8 f1 02 00 00       	call   800f5f <nsipc_recv>
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c76:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c79:	52                   	push   %edx
  800c7a:	50                   	push   %eax
  800c7b:	e8 e4 f7 ff ff       	call   800464 <fd_lookup>
  800c80:	83 c4 10             	add    $0x10,%esp
  800c83:	85 c0                	test   %eax,%eax
  800c85:	78 17                	js     800c9e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c90:	39 08                	cmp    %ecx,(%eax)
  800c92:	75 05                	jne    800c99 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c94:	8b 40 0c             	mov    0xc(%eax),%eax
  800c97:	eb 05                	jmp    800c9e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c99:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 1c             	sub    $0x1c,%esp
  800ca8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800caa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cad:	50                   	push   %eax
  800cae:	e8 62 f7 ff ff       	call   800415 <fd_alloc>
  800cb3:	89 c3                	mov    %eax,%ebx
  800cb5:	83 c4 10             	add    $0x10,%esp
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	78 1b                	js     800cd7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cbc:	83 ec 04             	sub    $0x4,%esp
  800cbf:	68 07 04 00 00       	push   $0x407
  800cc4:	ff 75 f4             	pushl  -0xc(%ebp)
  800cc7:	6a 00                	push   $0x0
  800cc9:	e8 8c f4 ff ff       	call   80015a <sys_page_alloc>
  800cce:	89 c3                	mov    %eax,%ebx
  800cd0:	83 c4 10             	add    $0x10,%esp
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	79 10                	jns    800ce7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	56                   	push   %esi
  800cdb:	e8 0e 02 00 00       	call   800eee <nsipc_close>
		return r;
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	89 d8                	mov    %ebx,%eax
  800ce5:	eb 24                	jmp    800d0b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ce7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cfc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	e8 e6 f6 ff ff       	call   8003ee <fd2num>
  800d08:	83 c4 10             	add    $0x10,%esp
}
  800d0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	e8 50 ff ff ff       	call   800c70 <fd2sockid>
		return r;
  800d20:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	78 1f                	js     800d45 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d26:	83 ec 04             	sub    $0x4,%esp
  800d29:	ff 75 10             	pushl  0x10(%ebp)
  800d2c:	ff 75 0c             	pushl  0xc(%ebp)
  800d2f:	50                   	push   %eax
  800d30:	e8 12 01 00 00       	call   800e47 <nsipc_accept>
  800d35:	83 c4 10             	add    $0x10,%esp
		return r;
  800d38:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	78 07                	js     800d45 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d3e:	e8 5d ff ff ff       	call   800ca0 <alloc_sockfd>
  800d43:	89 c1                	mov    %eax,%ecx
}
  800d45:	89 c8                	mov    %ecx,%eax
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    

00800d49 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	e8 19 ff ff ff       	call   800c70 <fd2sockid>
  800d57:	85 c0                	test   %eax,%eax
  800d59:	78 12                	js     800d6d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d5b:	83 ec 04             	sub    $0x4,%esp
  800d5e:	ff 75 10             	pushl  0x10(%ebp)
  800d61:	ff 75 0c             	pushl  0xc(%ebp)
  800d64:	50                   	push   %eax
  800d65:	e8 2d 01 00 00       	call   800e97 <nsipc_bind>
  800d6a:	83 c4 10             	add    $0x10,%esp
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <shutdown>:

int
shutdown(int s, int how)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	e8 f3 fe ff ff       	call   800c70 <fd2sockid>
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	78 0f                	js     800d90 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d81:	83 ec 08             	sub    $0x8,%esp
  800d84:	ff 75 0c             	pushl  0xc(%ebp)
  800d87:	50                   	push   %eax
  800d88:	e8 3f 01 00 00       	call   800ecc <nsipc_shutdown>
  800d8d:	83 c4 10             	add    $0x10,%esp
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	e8 d0 fe ff ff       	call   800c70 <fd2sockid>
  800da0:	85 c0                	test   %eax,%eax
  800da2:	78 12                	js     800db6 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	ff 75 10             	pushl  0x10(%ebp)
  800daa:	ff 75 0c             	pushl  0xc(%ebp)
  800dad:	50                   	push   %eax
  800dae:	e8 55 01 00 00       	call   800f08 <nsipc_connect>
  800db3:	83 c4 10             	add    $0x10,%esp
}
  800db6:	c9                   	leave  
  800db7:	c3                   	ret    

00800db8 <listen>:

int
listen(int s, int backlog)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	e8 aa fe ff ff       	call   800c70 <fd2sockid>
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	78 0f                	js     800dd9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dca:	83 ec 08             	sub    $0x8,%esp
  800dcd:	ff 75 0c             	pushl  0xc(%ebp)
  800dd0:	50                   	push   %eax
  800dd1:	e8 67 01 00 00       	call   800f3d <nsipc_listen>
  800dd6:	83 c4 10             	add    $0x10,%esp
}
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    

00800ddb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800de1:	ff 75 10             	pushl  0x10(%ebp)
  800de4:	ff 75 0c             	pushl  0xc(%ebp)
  800de7:	ff 75 08             	pushl  0x8(%ebp)
  800dea:	e8 3a 02 00 00       	call   801029 <nsipc_socket>
  800def:	83 c4 10             	add    $0x10,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	78 05                	js     800dfb <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800df6:	e8 a5 fe ff ff       	call   800ca0 <alloc_sockfd>
}
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	53                   	push   %ebx
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e06:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e0d:	75 12                	jne    800e21 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	6a 02                	push   $0x2
  800e14:	e8 79 11 00 00       	call   801f92 <ipc_find_env>
  800e19:	a3 04 40 80 00       	mov    %eax,0x804004
  800e1e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e21:	6a 07                	push   $0x7
  800e23:	68 00 60 80 00       	push   $0x806000
  800e28:	53                   	push   %ebx
  800e29:	ff 35 04 40 80 00    	pushl  0x804004
  800e2f:	e8 0a 11 00 00       	call   801f3e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e34:	83 c4 0c             	add    $0xc,%esp
  800e37:	6a 00                	push   $0x0
  800e39:	6a 00                	push   $0x0
  800e3b:	6a 00                	push   $0x0
  800e3d:	e8 95 10 00 00       	call   801ed7 <ipc_recv>
}
  800e42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e45:	c9                   	leave  
  800e46:	c3                   	ret    

00800e47 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e57:	8b 06                	mov    (%esi),%eax
  800e59:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e63:	e8 95 ff ff ff       	call   800dfd <nsipc>
  800e68:	89 c3                	mov    %eax,%ebx
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	78 20                	js     800e8e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e6e:	83 ec 04             	sub    $0x4,%esp
  800e71:	ff 35 10 60 80 00    	pushl  0x806010
  800e77:	68 00 60 80 00       	push   $0x806000
  800e7c:	ff 75 0c             	pushl  0xc(%ebp)
  800e7f:	e8 9e 0e 00 00       	call   801d22 <memmove>
		*addrlen = ret->ret_addrlen;
  800e84:	a1 10 60 80 00       	mov    0x806010,%eax
  800e89:	89 06                	mov    %eax,(%esi)
  800e8b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e8e:	89 d8                	mov    %ebx,%eax
  800e90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	53                   	push   %ebx
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ea9:	53                   	push   %ebx
  800eaa:	ff 75 0c             	pushl  0xc(%ebp)
  800ead:	68 04 60 80 00       	push   $0x806004
  800eb2:	e8 6b 0e 00 00       	call   801d22 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800eb7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ebd:	b8 02 00 00 00       	mov    $0x2,%eax
  800ec2:	e8 36 ff ff ff       	call   800dfd <nsipc>
}
  800ec7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ee2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee7:	e8 11 ff ff ff       	call   800dfd <nsipc>
}
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <nsipc_close>:

int
nsipc_close(int s)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef7:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800efc:	b8 04 00 00 00       	mov    $0x4,%eax
  800f01:	e8 f7 fe ff ff       	call   800dfd <nsipc>
}
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 08             	sub    $0x8,%esp
  800f0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f1a:	53                   	push   %ebx
  800f1b:	ff 75 0c             	pushl  0xc(%ebp)
  800f1e:	68 04 60 80 00       	push   $0x806004
  800f23:	e8 fa 0d 00 00       	call   801d22 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f28:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f2e:	b8 05 00 00 00       	mov    $0x5,%eax
  800f33:	e8 c5 fe ff ff       	call   800dfd <nsipc>
}
  800f38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
  800f46:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f53:	b8 06 00 00 00       	mov    $0x6,%eax
  800f58:	e8 a0 fe ff ff       	call   800dfd <nsipc>
}
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f67:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f6f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f75:	8b 45 14             	mov    0x14(%ebp),%eax
  800f78:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f7d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f82:	e8 76 fe ff ff       	call   800dfd <nsipc>
  800f87:	89 c3                	mov    %eax,%ebx
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 35                	js     800fc2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f8d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f92:	7f 04                	jg     800f98 <nsipc_recv+0x39>
  800f94:	39 c6                	cmp    %eax,%esi
  800f96:	7d 16                	jge    800fae <nsipc_recv+0x4f>
  800f98:	68 a7 23 80 00       	push   $0x8023a7
  800f9d:	68 6f 23 80 00       	push   $0x80236f
  800fa2:	6a 62                	push   $0x62
  800fa4:	68 bc 23 80 00       	push   $0x8023bc
  800fa9:	e8 84 05 00 00       	call   801532 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	50                   	push   %eax
  800fb2:	68 00 60 80 00       	push   $0x806000
  800fb7:	ff 75 0c             	pushl  0xc(%ebp)
  800fba:	e8 63 0d 00 00       	call   801d22 <memmove>
  800fbf:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fc2:	89 d8                	mov    %ebx,%eax
  800fc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc7:	5b                   	pop    %ebx
  800fc8:	5e                   	pop    %esi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fdd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fe3:	7e 16                	jle    800ffb <nsipc_send+0x30>
  800fe5:	68 c8 23 80 00       	push   $0x8023c8
  800fea:	68 6f 23 80 00       	push   $0x80236f
  800fef:	6a 6d                	push   $0x6d
  800ff1:	68 bc 23 80 00       	push   $0x8023bc
  800ff6:	e8 37 05 00 00       	call   801532 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800ffb:	83 ec 04             	sub    $0x4,%esp
  800ffe:	53                   	push   %ebx
  800fff:	ff 75 0c             	pushl  0xc(%ebp)
  801002:	68 0c 60 80 00       	push   $0x80600c
  801007:	e8 16 0d 00 00       	call   801d22 <memmove>
	nsipcbuf.send.req_size = size;
  80100c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801012:	8b 45 14             	mov    0x14(%ebp),%eax
  801015:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	e8 d9 fd ff ff       	call   800dfd <nsipc>
}
  801024:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801027:	c9                   	leave  
  801028:	c3                   	ret    

00801029 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80102f:	8b 45 08             	mov    0x8(%ebp),%eax
  801032:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801037:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80103f:	8b 45 10             	mov    0x10(%ebp),%eax
  801042:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801047:	b8 09 00 00 00       	mov    $0x9,%eax
  80104c:	e8 ac fd ff ff       	call   800dfd <nsipc>
}
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	ff 75 08             	pushl  0x8(%ebp)
  801061:	e8 98 f3 ff ff       	call   8003fe <fd2data>
  801066:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801068:	83 c4 08             	add    $0x8,%esp
  80106b:	68 d4 23 80 00       	push   $0x8023d4
  801070:	53                   	push   %ebx
  801071:	e8 1a 0b 00 00       	call   801b90 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801076:	8b 46 04             	mov    0x4(%esi),%eax
  801079:	2b 06                	sub    (%esi),%eax
  80107b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801081:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801088:	00 00 00 
	stat->st_dev = &devpipe;
  80108b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801092:	30 80 00 
	return 0;
}
  801095:	b8 00 00 00 00       	mov    $0x0,%eax
  80109a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010ab:	53                   	push   %ebx
  8010ac:	6a 00                	push   $0x0
  8010ae:	e8 2c f1 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010b3:	89 1c 24             	mov    %ebx,(%esp)
  8010b6:	e8 43 f3 ff ff       	call   8003fe <fd2data>
  8010bb:	83 c4 08             	add    $0x8,%esp
  8010be:	50                   	push   %eax
  8010bf:	6a 00                	push   $0x0
  8010c1:	e8 19 f1 ff ff       	call   8001df <sys_page_unmap>
}
  8010c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c9:	c9                   	leave  
  8010ca:	c3                   	ret    

008010cb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	57                   	push   %edi
  8010cf:	56                   	push   %esi
  8010d0:	53                   	push   %ebx
  8010d1:	83 ec 1c             	sub    $0x1c,%esp
  8010d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010d7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010d9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010de:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8010e7:	e8 df 0e 00 00       	call   801fcb <pageref>
  8010ec:	89 c3                	mov    %eax,%ebx
  8010ee:	89 3c 24             	mov    %edi,(%esp)
  8010f1:	e8 d5 0e 00 00       	call   801fcb <pageref>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	39 c3                	cmp    %eax,%ebx
  8010fb:	0f 94 c1             	sete   %cl
  8010fe:	0f b6 c9             	movzbl %cl,%ecx
  801101:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801104:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80110a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80110d:	39 ce                	cmp    %ecx,%esi
  80110f:	74 1b                	je     80112c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801111:	39 c3                	cmp    %eax,%ebx
  801113:	75 c4                	jne    8010d9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801115:	8b 42 58             	mov    0x58(%edx),%eax
  801118:	ff 75 e4             	pushl  -0x1c(%ebp)
  80111b:	50                   	push   %eax
  80111c:	56                   	push   %esi
  80111d:	68 db 23 80 00       	push   $0x8023db
  801122:	e8 e4 04 00 00       	call   80160b <cprintf>
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	eb ad                	jmp    8010d9 <_pipeisclosed+0xe>
	}
}
  80112c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 28             	sub    $0x28,%esp
  801140:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801143:	56                   	push   %esi
  801144:	e8 b5 f2 ff ff       	call   8003fe <fd2data>
  801149:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80114b:	83 c4 10             	add    $0x10,%esp
  80114e:	bf 00 00 00 00       	mov    $0x0,%edi
  801153:	eb 4b                	jmp    8011a0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801155:	89 da                	mov    %ebx,%edx
  801157:	89 f0                	mov    %esi,%eax
  801159:	e8 6d ff ff ff       	call   8010cb <_pipeisclosed>
  80115e:	85 c0                	test   %eax,%eax
  801160:	75 48                	jne    8011aa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801162:	e8 d4 ef ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801167:	8b 43 04             	mov    0x4(%ebx),%eax
  80116a:	8b 0b                	mov    (%ebx),%ecx
  80116c:	8d 51 20             	lea    0x20(%ecx),%edx
  80116f:	39 d0                	cmp    %edx,%eax
  801171:	73 e2                	jae    801155 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801176:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80117a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	c1 fa 1f             	sar    $0x1f,%edx
  801182:	89 d1                	mov    %edx,%ecx
  801184:	c1 e9 1b             	shr    $0x1b,%ecx
  801187:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80118a:	83 e2 1f             	and    $0x1f,%edx
  80118d:	29 ca                	sub    %ecx,%edx
  80118f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801193:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801197:	83 c0 01             	add    $0x1,%eax
  80119a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80119d:	83 c7 01             	add    $0x1,%edi
  8011a0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011a3:	75 c2                	jne    801167 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a8:	eb 05                	jmp    8011af <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011aa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b2:	5b                   	pop    %ebx
  8011b3:	5e                   	pop    %esi
  8011b4:	5f                   	pop    %edi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	57                   	push   %edi
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 18             	sub    $0x18,%esp
  8011c0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011c3:	57                   	push   %edi
  8011c4:	e8 35 f2 ff ff       	call   8003fe <fd2data>
  8011c9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d3:	eb 3d                	jmp    801212 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011d5:	85 db                	test   %ebx,%ebx
  8011d7:	74 04                	je     8011dd <devpipe_read+0x26>
				return i;
  8011d9:	89 d8                	mov    %ebx,%eax
  8011db:	eb 44                	jmp    801221 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011dd:	89 f2                	mov    %esi,%edx
  8011df:	89 f8                	mov    %edi,%eax
  8011e1:	e8 e5 fe ff ff       	call   8010cb <_pipeisclosed>
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	75 32                	jne    80121c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011ea:	e8 4c ef ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011ef:	8b 06                	mov    (%esi),%eax
  8011f1:	3b 46 04             	cmp    0x4(%esi),%eax
  8011f4:	74 df                	je     8011d5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011f6:	99                   	cltd   
  8011f7:	c1 ea 1b             	shr    $0x1b,%edx
  8011fa:	01 d0                	add    %edx,%eax
  8011fc:	83 e0 1f             	and    $0x1f,%eax
  8011ff:	29 d0                	sub    %edx,%eax
  801201:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801209:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80120c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80120f:	83 c3 01             	add    $0x1,%ebx
  801212:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801215:	75 d8                	jne    8011ef <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801217:	8b 45 10             	mov    0x10(%ebp),%eax
  80121a:	eb 05                	jmp    801221 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80121c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	56                   	push   %esi
  80122d:	53                   	push   %ebx
  80122e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801231:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801234:	50                   	push   %eax
  801235:	e8 db f1 ff ff       	call   800415 <fd_alloc>
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	89 c2                	mov    %eax,%edx
  80123f:	85 c0                	test   %eax,%eax
  801241:	0f 88 2c 01 00 00    	js     801373 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	68 07 04 00 00       	push   $0x407
  80124f:	ff 75 f4             	pushl  -0xc(%ebp)
  801252:	6a 00                	push   $0x0
  801254:	e8 01 ef ff ff       	call   80015a <sys_page_alloc>
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	85 c0                	test   %eax,%eax
  801260:	0f 88 0d 01 00 00    	js     801373 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	e8 a3 f1 ff ff       	call   800415 <fd_alloc>
  801272:	89 c3                	mov    %eax,%ebx
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	0f 88 e2 00 00 00    	js     801361 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127f:	83 ec 04             	sub    $0x4,%esp
  801282:	68 07 04 00 00       	push   $0x407
  801287:	ff 75 f0             	pushl  -0x10(%ebp)
  80128a:	6a 00                	push   $0x0
  80128c:	e8 c9 ee ff ff       	call   80015a <sys_page_alloc>
  801291:	89 c3                	mov    %eax,%ebx
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	0f 88 c3 00 00 00    	js     801361 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80129e:	83 ec 0c             	sub    $0xc,%esp
  8012a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a4:	e8 55 f1 ff ff       	call   8003fe <fd2data>
  8012a9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ab:	83 c4 0c             	add    $0xc,%esp
  8012ae:	68 07 04 00 00       	push   $0x407
  8012b3:	50                   	push   %eax
  8012b4:	6a 00                	push   $0x0
  8012b6:	e8 9f ee ff ff       	call   80015a <sys_page_alloc>
  8012bb:	89 c3                	mov    %eax,%ebx
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	0f 88 89 00 00 00    	js     801351 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ce:	e8 2b f1 ff ff       	call   8003fe <fd2data>
  8012d3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012da:	50                   	push   %eax
  8012db:	6a 00                	push   $0x0
  8012dd:	56                   	push   %esi
  8012de:	6a 00                	push   $0x0
  8012e0:	e8 b8 ee ff ff       	call   80019d <sys_page_map>
  8012e5:	89 c3                	mov    %eax,%ebx
  8012e7:	83 c4 20             	add    $0x20,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 55                	js     801343 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012ee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801303:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80130e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801311:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801318:	83 ec 0c             	sub    $0xc,%esp
  80131b:	ff 75 f4             	pushl  -0xc(%ebp)
  80131e:	e8 cb f0 ff ff       	call   8003ee <fd2num>
  801323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801326:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801328:	83 c4 04             	add    $0x4,%esp
  80132b:	ff 75 f0             	pushl  -0x10(%ebp)
  80132e:	e8 bb f0 ff ff       	call   8003ee <fd2num>
  801333:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801336:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	ba 00 00 00 00       	mov    $0x0,%edx
  801341:	eb 30                	jmp    801373 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	56                   	push   %esi
  801347:	6a 00                	push   $0x0
  801349:	e8 91 ee ff ff       	call   8001df <sys_page_unmap>
  80134e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	ff 75 f0             	pushl  -0x10(%ebp)
  801357:	6a 00                	push   $0x0
  801359:	e8 81 ee ff ff       	call   8001df <sys_page_unmap>
  80135e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	ff 75 f4             	pushl  -0xc(%ebp)
  801367:	6a 00                	push   $0x0
  801369:	e8 71 ee ff ff       	call   8001df <sys_page_unmap>
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801373:	89 d0                	mov    %edx,%eax
  801375:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    

0080137c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	ff 75 08             	pushl  0x8(%ebp)
  801389:	e8 d6 f0 ff ff       	call   800464 <fd_lookup>
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	85 c0                	test   %eax,%eax
  801393:	78 18                	js     8013ad <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	ff 75 f4             	pushl  -0xc(%ebp)
  80139b:	e8 5e f0 ff ff       	call   8003fe <fd2data>
	return _pipeisclosed(fd, p);
  8013a0:	89 c2                	mov    %eax,%edx
  8013a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a5:	e8 21 fd ff ff       	call   8010cb <_pipeisclosed>
  8013aa:	83 c4 10             	add    $0x10,%esp
}
  8013ad:	c9                   	leave  
  8013ae:	c3                   	ret    

008013af <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013bf:	68 f3 23 80 00       	push   $0x8023f3
  8013c4:	ff 75 0c             	pushl  0xc(%ebp)
  8013c7:	e8 c4 07 00 00       	call   801b90 <strcpy>
	return 0;
}
  8013cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	57                   	push   %edi
  8013d7:	56                   	push   %esi
  8013d8:	53                   	push   %ebx
  8013d9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013df:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013e4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ea:	eb 2d                	jmp    801419 <devcons_write+0x46>
		m = n - tot;
  8013ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ef:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013f1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013f4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013f9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	53                   	push   %ebx
  801400:	03 45 0c             	add    0xc(%ebp),%eax
  801403:	50                   	push   %eax
  801404:	57                   	push   %edi
  801405:	e8 18 09 00 00       	call   801d22 <memmove>
		sys_cputs(buf, m);
  80140a:	83 c4 08             	add    $0x8,%esp
  80140d:	53                   	push   %ebx
  80140e:	57                   	push   %edi
  80140f:	e8 8a ec ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801414:	01 de                	add    %ebx,%esi
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	89 f0                	mov    %esi,%eax
  80141b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80141e:	72 cc                	jb     8013ec <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801420:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801433:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801437:	74 2a                	je     801463 <devcons_read+0x3b>
  801439:	eb 05                	jmp    801440 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80143b:	e8 fb ec ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801440:	e8 77 ec ff ff       	call   8000bc <sys_cgetc>
  801445:	85 c0                	test   %eax,%eax
  801447:	74 f2                	je     80143b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 16                	js     801463 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80144d:	83 f8 04             	cmp    $0x4,%eax
  801450:	74 0c                	je     80145e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801452:	8b 55 0c             	mov    0xc(%ebp),%edx
  801455:	88 02                	mov    %al,(%edx)
	return 1;
  801457:	b8 01 00 00 00       	mov    $0x1,%eax
  80145c:	eb 05                	jmp    801463 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80145e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80146b:	8b 45 08             	mov    0x8(%ebp),%eax
  80146e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801471:	6a 01                	push   $0x1
  801473:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	e8 22 ec ff ff       	call   80009e <sys_cputs>
}
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <getchar>:

int
getchar(void)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801487:	6a 01                	push   $0x1
  801489:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80148c:	50                   	push   %eax
  80148d:	6a 00                	push   $0x0
  80148f:	e8 36 f2 ff ff       	call   8006ca <read>
	if (r < 0)
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	78 0f                	js     8014aa <getchar+0x29>
		return r;
	if (r < 1)
  80149b:	85 c0                	test   %eax,%eax
  80149d:	7e 06                	jle    8014a5 <getchar+0x24>
		return -E_EOF;
	return c;
  80149f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014a3:	eb 05                	jmp    8014aa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014a5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	ff 75 08             	pushl  0x8(%ebp)
  8014b9:	e8 a6 ef ff ff       	call   800464 <fd_lookup>
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 11                	js     8014d6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014ce:	39 10                	cmp    %edx,(%eax)
  8014d0:	0f 94 c0             	sete   %al
  8014d3:	0f b6 c0             	movzbl %al,%eax
}
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    

008014d8 <opencons>:

int
opencons(void)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	e8 2e ef ff ff       	call   800415 <fd_alloc>
  8014e7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ea:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 3e                	js     80152e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014f0:	83 ec 04             	sub    $0x4,%esp
  8014f3:	68 07 04 00 00       	push   $0x407
  8014f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fb:	6a 00                	push   $0x0
  8014fd:	e8 58 ec ff ff       	call   80015a <sys_page_alloc>
  801502:	83 c4 10             	add    $0x10,%esp
		return r;
  801505:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801507:	85 c0                	test   %eax,%eax
  801509:	78 23                	js     80152e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80150b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801511:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801514:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801516:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801519:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801520:	83 ec 0c             	sub    $0xc,%esp
  801523:	50                   	push   %eax
  801524:	e8 c5 ee ff ff       	call   8003ee <fd2num>
  801529:	89 c2                	mov    %eax,%edx
  80152b:	83 c4 10             	add    $0x10,%esp
}
  80152e:	89 d0                	mov    %edx,%eax
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	56                   	push   %esi
  801536:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801537:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80153a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801540:	e8 d7 eb ff ff       	call   80011c <sys_getenvid>
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	ff 75 0c             	pushl  0xc(%ebp)
  80154b:	ff 75 08             	pushl  0x8(%ebp)
  80154e:	56                   	push   %esi
  80154f:	50                   	push   %eax
  801550:	68 00 24 80 00       	push   $0x802400
  801555:	e8 b1 00 00 00       	call   80160b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80155a:	83 c4 18             	add    $0x18,%esp
  80155d:	53                   	push   %ebx
  80155e:	ff 75 10             	pushl  0x10(%ebp)
  801561:	e8 54 00 00 00       	call   8015ba <vcprintf>
	cprintf("\n");
  801566:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  80156d:	e8 99 00 00 00       	call   80160b <cprintf>
  801572:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801575:	cc                   	int3   
  801576:	eb fd                	jmp    801575 <_panic+0x43>

00801578 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 04             	sub    $0x4,%esp
  80157f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801582:	8b 13                	mov    (%ebx),%edx
  801584:	8d 42 01             	lea    0x1(%edx),%eax
  801587:	89 03                	mov    %eax,(%ebx)
  801589:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80158c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801590:	3d ff 00 00 00       	cmp    $0xff,%eax
  801595:	75 1a                	jne    8015b1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	68 ff 00 00 00       	push   $0xff
  80159f:	8d 43 08             	lea    0x8(%ebx),%eax
  8015a2:	50                   	push   %eax
  8015a3:	e8 f6 ea ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8015a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015ae:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015ca:	00 00 00 
	b.cnt = 0;
  8015cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015d7:	ff 75 0c             	pushl  0xc(%ebp)
  8015da:	ff 75 08             	pushl  0x8(%ebp)
  8015dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	68 78 15 80 00       	push   $0x801578
  8015e9:	e8 54 01 00 00       	call   801742 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	e8 9b ea ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  801603:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801611:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801614:	50                   	push   %eax
  801615:	ff 75 08             	pushl  0x8(%ebp)
  801618:	e8 9d ff ff ff       	call   8015ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	57                   	push   %edi
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
  801625:	83 ec 1c             	sub    $0x1c,%esp
  801628:	89 c7                	mov    %eax,%edi
  80162a:	89 d6                	mov    %edx,%esi
  80162c:	8b 45 08             	mov    0x8(%ebp),%eax
  80162f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801632:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801635:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801638:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80163b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801640:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801643:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801646:	39 d3                	cmp    %edx,%ebx
  801648:	72 05                	jb     80164f <printnum+0x30>
  80164a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80164d:	77 45                	ja     801694 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80164f:	83 ec 0c             	sub    $0xc,%esp
  801652:	ff 75 18             	pushl  0x18(%ebp)
  801655:	8b 45 14             	mov    0x14(%ebp),%eax
  801658:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80165b:	53                   	push   %ebx
  80165c:	ff 75 10             	pushl  0x10(%ebp)
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	ff 75 e4             	pushl  -0x1c(%ebp)
  801665:	ff 75 e0             	pushl  -0x20(%ebp)
  801668:	ff 75 dc             	pushl  -0x24(%ebp)
  80166b:	ff 75 d8             	pushl  -0x28(%ebp)
  80166e:	e8 9d 09 00 00       	call   802010 <__udivdi3>
  801673:	83 c4 18             	add    $0x18,%esp
  801676:	52                   	push   %edx
  801677:	50                   	push   %eax
  801678:	89 f2                	mov    %esi,%edx
  80167a:	89 f8                	mov    %edi,%eax
  80167c:	e8 9e ff ff ff       	call   80161f <printnum>
  801681:	83 c4 20             	add    $0x20,%esp
  801684:	eb 18                	jmp    80169e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	56                   	push   %esi
  80168a:	ff 75 18             	pushl  0x18(%ebp)
  80168d:	ff d7                	call   *%edi
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	eb 03                	jmp    801697 <printnum+0x78>
  801694:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801697:	83 eb 01             	sub    $0x1,%ebx
  80169a:	85 db                	test   %ebx,%ebx
  80169c:	7f e8                	jg     801686 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	56                   	push   %esi
  8016a2:	83 ec 04             	sub    $0x4,%esp
  8016a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8016ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8016b1:	e8 8a 0a 00 00       	call   802140 <__umoddi3>
  8016b6:	83 c4 14             	add    $0x14,%esp
  8016b9:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  8016c0:	50                   	push   %eax
  8016c1:	ff d7                	call   *%edi
}
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5f                   	pop    %edi
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    

008016ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016d1:	83 fa 01             	cmp    $0x1,%edx
  8016d4:	7e 0e                	jle    8016e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016d6:	8b 10                	mov    (%eax),%edx
  8016d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016db:	89 08                	mov    %ecx,(%eax)
  8016dd:	8b 02                	mov    (%edx),%eax
  8016df:	8b 52 04             	mov    0x4(%edx),%edx
  8016e2:	eb 22                	jmp    801706 <getuint+0x38>
	else if (lflag)
  8016e4:	85 d2                	test   %edx,%edx
  8016e6:	74 10                	je     8016f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016e8:	8b 10                	mov    (%eax),%edx
  8016ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016ed:	89 08                	mov    %ecx,(%eax)
  8016ef:	8b 02                	mov    (%edx),%eax
  8016f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f6:	eb 0e                	jmp    801706 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016f8:	8b 10                	mov    (%eax),%edx
  8016fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016fd:	89 08                	mov    %ecx,(%eax)
  8016ff:	8b 02                	mov    (%edx),%eax
  801701:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80170e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801712:	8b 10                	mov    (%eax),%edx
  801714:	3b 50 04             	cmp    0x4(%eax),%edx
  801717:	73 0a                	jae    801723 <sprintputch+0x1b>
		*b->buf++ = ch;
  801719:	8d 4a 01             	lea    0x1(%edx),%ecx
  80171c:	89 08                	mov    %ecx,(%eax)
  80171e:	8b 45 08             	mov    0x8(%ebp),%eax
  801721:	88 02                	mov    %al,(%edx)
}
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80172b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80172e:	50                   	push   %eax
  80172f:	ff 75 10             	pushl  0x10(%ebp)
  801732:	ff 75 0c             	pushl  0xc(%ebp)
  801735:	ff 75 08             	pushl  0x8(%ebp)
  801738:	e8 05 00 00 00       	call   801742 <vprintfmt>
	va_end(ap);
}
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	57                   	push   %edi
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
  801748:	83 ec 2c             	sub    $0x2c,%esp
  80174b:	8b 75 08             	mov    0x8(%ebp),%esi
  80174e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801751:	8b 7d 10             	mov    0x10(%ebp),%edi
  801754:	eb 12                	jmp    801768 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801756:	85 c0                	test   %eax,%eax
  801758:	0f 84 89 03 00 00    	je     801ae7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80175e:	83 ec 08             	sub    $0x8,%esp
  801761:	53                   	push   %ebx
  801762:	50                   	push   %eax
  801763:	ff d6                	call   *%esi
  801765:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801768:	83 c7 01             	add    $0x1,%edi
  80176b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80176f:	83 f8 25             	cmp    $0x25,%eax
  801772:	75 e2                	jne    801756 <vprintfmt+0x14>
  801774:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801778:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80177f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801786:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80178d:	ba 00 00 00 00       	mov    $0x0,%edx
  801792:	eb 07                	jmp    80179b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801794:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801797:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179b:	8d 47 01             	lea    0x1(%edi),%eax
  80179e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017a1:	0f b6 07             	movzbl (%edi),%eax
  8017a4:	0f b6 c8             	movzbl %al,%ecx
  8017a7:	83 e8 23             	sub    $0x23,%eax
  8017aa:	3c 55                	cmp    $0x55,%al
  8017ac:	0f 87 1a 03 00 00    	ja     801acc <vprintfmt+0x38a>
  8017b2:	0f b6 c0             	movzbl %al,%eax
  8017b5:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8017bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017bf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017c3:	eb d6                	jmp    80179b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017d0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017d3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017d7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017da:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017dd:	83 fa 09             	cmp    $0x9,%edx
  8017e0:	77 39                	ja     80181b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017e2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017e5:	eb e9                	jmp    8017d0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8017ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017f0:	8b 00                	mov    (%eax),%eax
  8017f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017f8:	eb 27                	jmp    801821 <vprintfmt+0xdf>
  8017fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801804:	0f 49 c8             	cmovns %eax,%ecx
  801807:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80180d:	eb 8c                	jmp    80179b <vprintfmt+0x59>
  80180f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801812:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801819:	eb 80                	jmp    80179b <vprintfmt+0x59>
  80181b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80181e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801821:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801825:	0f 89 70 ff ff ff    	jns    80179b <vprintfmt+0x59>
				width = precision, precision = -1;
  80182b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80182e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801831:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801838:	e9 5e ff ff ff       	jmp    80179b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80183d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801840:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801843:	e9 53 ff ff ff       	jmp    80179b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801848:	8b 45 14             	mov    0x14(%ebp),%eax
  80184b:	8d 50 04             	lea    0x4(%eax),%edx
  80184e:	89 55 14             	mov    %edx,0x14(%ebp)
  801851:	83 ec 08             	sub    $0x8,%esp
  801854:	53                   	push   %ebx
  801855:	ff 30                	pushl  (%eax)
  801857:	ff d6                	call   *%esi
			break;
  801859:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80185f:	e9 04 ff ff ff       	jmp    801768 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801864:	8b 45 14             	mov    0x14(%ebp),%eax
  801867:	8d 50 04             	lea    0x4(%eax),%edx
  80186a:	89 55 14             	mov    %edx,0x14(%ebp)
  80186d:	8b 00                	mov    (%eax),%eax
  80186f:	99                   	cltd   
  801870:	31 d0                	xor    %edx,%eax
  801872:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801874:	83 f8 0f             	cmp    $0xf,%eax
  801877:	7f 0b                	jg     801884 <vprintfmt+0x142>
  801879:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  801880:	85 d2                	test   %edx,%edx
  801882:	75 18                	jne    80189c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801884:	50                   	push   %eax
  801885:	68 3b 24 80 00       	push   $0x80243b
  80188a:	53                   	push   %ebx
  80188b:	56                   	push   %esi
  80188c:	e8 94 fe ff ff       	call   801725 <printfmt>
  801891:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801897:	e9 cc fe ff ff       	jmp    801768 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80189c:	52                   	push   %edx
  80189d:	68 81 23 80 00       	push   $0x802381
  8018a2:	53                   	push   %ebx
  8018a3:	56                   	push   %esi
  8018a4:	e8 7c fe ff ff       	call   801725 <printfmt>
  8018a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018af:	e9 b4 fe ff ff       	jmp    801768 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b7:	8d 50 04             	lea    0x4(%eax),%edx
  8018ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8018bd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018bf:	85 ff                	test   %edi,%edi
  8018c1:	b8 34 24 80 00       	mov    $0x802434,%eax
  8018c6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018cd:	0f 8e 94 00 00 00    	jle    801967 <vprintfmt+0x225>
  8018d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018d7:	0f 84 98 00 00 00    	je     801975 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	ff 75 d0             	pushl  -0x30(%ebp)
  8018e3:	57                   	push   %edi
  8018e4:	e8 86 02 00 00       	call   801b6f <strnlen>
  8018e9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018ec:	29 c1                	sub    %eax,%ecx
  8018ee:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018f1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018f4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018fe:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801900:	eb 0f                	jmp    801911 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801902:	83 ec 08             	sub    $0x8,%esp
  801905:	53                   	push   %ebx
  801906:	ff 75 e0             	pushl  -0x20(%ebp)
  801909:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80190b:	83 ef 01             	sub    $0x1,%edi
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	85 ff                	test   %edi,%edi
  801913:	7f ed                	jg     801902 <vprintfmt+0x1c0>
  801915:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801918:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80191b:	85 c9                	test   %ecx,%ecx
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
  801922:	0f 49 c1             	cmovns %ecx,%eax
  801925:	29 c1                	sub    %eax,%ecx
  801927:	89 75 08             	mov    %esi,0x8(%ebp)
  80192a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80192d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801930:	89 cb                	mov    %ecx,%ebx
  801932:	eb 4d                	jmp    801981 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801934:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801938:	74 1b                	je     801955 <vprintfmt+0x213>
  80193a:	0f be c0             	movsbl %al,%eax
  80193d:	83 e8 20             	sub    $0x20,%eax
  801940:	83 f8 5e             	cmp    $0x5e,%eax
  801943:	76 10                	jbe    801955 <vprintfmt+0x213>
					putch('?', putdat);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	ff 75 0c             	pushl  0xc(%ebp)
  80194b:	6a 3f                	push   $0x3f
  80194d:	ff 55 08             	call   *0x8(%ebp)
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	eb 0d                	jmp    801962 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	ff 75 0c             	pushl  0xc(%ebp)
  80195b:	52                   	push   %edx
  80195c:	ff 55 08             	call   *0x8(%ebp)
  80195f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801962:	83 eb 01             	sub    $0x1,%ebx
  801965:	eb 1a                	jmp    801981 <vprintfmt+0x23f>
  801967:	89 75 08             	mov    %esi,0x8(%ebp)
  80196a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80196d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801970:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801973:	eb 0c                	jmp    801981 <vprintfmt+0x23f>
  801975:	89 75 08             	mov    %esi,0x8(%ebp)
  801978:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80197b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80197e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801981:	83 c7 01             	add    $0x1,%edi
  801984:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801988:	0f be d0             	movsbl %al,%edx
  80198b:	85 d2                	test   %edx,%edx
  80198d:	74 23                	je     8019b2 <vprintfmt+0x270>
  80198f:	85 f6                	test   %esi,%esi
  801991:	78 a1                	js     801934 <vprintfmt+0x1f2>
  801993:	83 ee 01             	sub    $0x1,%esi
  801996:	79 9c                	jns    801934 <vprintfmt+0x1f2>
  801998:	89 df                	mov    %ebx,%edi
  80199a:	8b 75 08             	mov    0x8(%ebp),%esi
  80199d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019a0:	eb 18                	jmp    8019ba <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	53                   	push   %ebx
  8019a6:	6a 20                	push   $0x20
  8019a8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019aa:	83 ef 01             	sub    $0x1,%edi
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	eb 08                	jmp    8019ba <vprintfmt+0x278>
  8019b2:	89 df                	mov    %ebx,%edi
  8019b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ba:	85 ff                	test   %edi,%edi
  8019bc:	7f e4                	jg     8019a2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019c1:	e9 a2 fd ff ff       	jmp    801768 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019c6:	83 fa 01             	cmp    $0x1,%edx
  8019c9:	7e 16                	jle    8019e1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ce:	8d 50 08             	lea    0x8(%eax),%edx
  8019d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d4:	8b 50 04             	mov    0x4(%eax),%edx
  8019d7:	8b 00                	mov    (%eax),%eax
  8019d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019df:	eb 32                	jmp    801a13 <vprintfmt+0x2d1>
	else if (lflag)
  8019e1:	85 d2                	test   %edx,%edx
  8019e3:	74 18                	je     8019fd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e8:	8d 50 04             	lea    0x4(%eax),%edx
  8019eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ee:	8b 00                	mov    (%eax),%eax
  8019f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019f3:	89 c1                	mov    %eax,%ecx
  8019f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8019f8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019fb:	eb 16                	jmp    801a13 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801a00:	8d 50 04             	lea    0x4(%eax),%edx
  801a03:	89 55 14             	mov    %edx,0x14(%ebp)
  801a06:	8b 00                	mov    (%eax),%eax
  801a08:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a0b:	89 c1                	mov    %eax,%ecx
  801a0d:	c1 f9 1f             	sar    $0x1f,%ecx
  801a10:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a13:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a16:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a19:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a1e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a22:	79 74                	jns    801a98 <vprintfmt+0x356>
				putch('-', putdat);
  801a24:	83 ec 08             	sub    $0x8,%esp
  801a27:	53                   	push   %ebx
  801a28:	6a 2d                	push   $0x2d
  801a2a:	ff d6                	call   *%esi
				num = -(long long) num;
  801a2c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a2f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a32:	f7 d8                	neg    %eax
  801a34:	83 d2 00             	adc    $0x0,%edx
  801a37:	f7 da                	neg    %edx
  801a39:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a3c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a41:	eb 55                	jmp    801a98 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a43:	8d 45 14             	lea    0x14(%ebp),%eax
  801a46:	e8 83 fc ff ff       	call   8016ce <getuint>
			base = 10;
  801a4b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a50:	eb 46                	jmp    801a98 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a52:	8d 45 14             	lea    0x14(%ebp),%eax
  801a55:	e8 74 fc ff ff       	call   8016ce <getuint>
			base = 8;
  801a5a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a5f:	eb 37                	jmp    801a98 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a61:	83 ec 08             	sub    $0x8,%esp
  801a64:	53                   	push   %ebx
  801a65:	6a 30                	push   $0x30
  801a67:	ff d6                	call   *%esi
			putch('x', putdat);
  801a69:	83 c4 08             	add    $0x8,%esp
  801a6c:	53                   	push   %ebx
  801a6d:	6a 78                	push   $0x78
  801a6f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a71:	8b 45 14             	mov    0x14(%ebp),%eax
  801a74:	8d 50 04             	lea    0x4(%eax),%edx
  801a77:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a7a:	8b 00                	mov    (%eax),%eax
  801a7c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a81:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a84:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a89:	eb 0d                	jmp    801a98 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a8b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a8e:	e8 3b fc ff ff       	call   8016ce <getuint>
			base = 16;
  801a93:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a9f:	57                   	push   %edi
  801aa0:	ff 75 e0             	pushl  -0x20(%ebp)
  801aa3:	51                   	push   %ecx
  801aa4:	52                   	push   %edx
  801aa5:	50                   	push   %eax
  801aa6:	89 da                	mov    %ebx,%edx
  801aa8:	89 f0                	mov    %esi,%eax
  801aaa:	e8 70 fb ff ff       	call   80161f <printnum>
			break;
  801aaf:	83 c4 20             	add    $0x20,%esp
  801ab2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ab5:	e9 ae fc ff ff       	jmp    801768 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	53                   	push   %ebx
  801abe:	51                   	push   %ecx
  801abf:	ff d6                	call   *%esi
			break;
  801ac1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ac4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ac7:	e9 9c fc ff ff       	jmp    801768 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801acc:	83 ec 08             	sub    $0x8,%esp
  801acf:	53                   	push   %ebx
  801ad0:	6a 25                	push   $0x25
  801ad2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	eb 03                	jmp    801adc <vprintfmt+0x39a>
  801ad9:	83 ef 01             	sub    $0x1,%edi
  801adc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ae0:	75 f7                	jne    801ad9 <vprintfmt+0x397>
  801ae2:	e9 81 fc ff ff       	jmp    801768 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ae7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5f                   	pop    %edi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 18             	sub    $0x18,%esp
  801af5:	8b 45 08             	mov    0x8(%ebp),%eax
  801af8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801afb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801afe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b02:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	74 26                	je     801b36 <vsnprintf+0x47>
  801b10:	85 d2                	test   %edx,%edx
  801b12:	7e 22                	jle    801b36 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b14:	ff 75 14             	pushl  0x14(%ebp)
  801b17:	ff 75 10             	pushl  0x10(%ebp)
  801b1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b1d:	50                   	push   %eax
  801b1e:	68 08 17 80 00       	push   $0x801708
  801b23:	e8 1a fc ff ff       	call   801742 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b2b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	eb 05                	jmp    801b3b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b43:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b46:	50                   	push   %eax
  801b47:	ff 75 10             	pushl  0x10(%ebp)
  801b4a:	ff 75 0c             	pushl  0xc(%ebp)
  801b4d:	ff 75 08             	pushl  0x8(%ebp)
  801b50:	e8 9a ff ff ff       	call   801aef <vsnprintf>
	va_end(ap);

	return rc;
}
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b62:	eb 03                	jmp    801b67 <strlen+0x10>
		n++;
  801b64:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b67:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b6b:	75 f7                	jne    801b64 <strlen+0xd>
		n++;
	return n;
}
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b75:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b78:	ba 00 00 00 00       	mov    $0x0,%edx
  801b7d:	eb 03                	jmp    801b82 <strnlen+0x13>
		n++;
  801b7f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b82:	39 c2                	cmp    %eax,%edx
  801b84:	74 08                	je     801b8e <strnlen+0x1f>
  801b86:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b8a:	75 f3                	jne    801b7f <strnlen+0x10>
  801b8c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	53                   	push   %ebx
  801b94:	8b 45 08             	mov    0x8(%ebp),%eax
  801b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b9a:	89 c2                	mov    %eax,%edx
  801b9c:	83 c2 01             	add    $0x1,%edx
  801b9f:	83 c1 01             	add    $0x1,%ecx
  801ba2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801ba6:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ba9:	84 db                	test   %bl,%bl
  801bab:	75 ef                	jne    801b9c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bad:	5b                   	pop    %ebx
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    

00801bb0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	53                   	push   %ebx
  801bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bb7:	53                   	push   %ebx
  801bb8:	e8 9a ff ff ff       	call   801b57 <strlen>
  801bbd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bc0:	ff 75 0c             	pushl  0xc(%ebp)
  801bc3:	01 d8                	add    %ebx,%eax
  801bc5:	50                   	push   %eax
  801bc6:	e8 c5 ff ff ff       	call   801b90 <strcpy>
	return dst;
}
  801bcb:	89 d8                	mov    %ebx,%eax
  801bcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	56                   	push   %esi
  801bd6:	53                   	push   %ebx
  801bd7:	8b 75 08             	mov    0x8(%ebp),%esi
  801bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bdd:	89 f3                	mov    %esi,%ebx
  801bdf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801be2:	89 f2                	mov    %esi,%edx
  801be4:	eb 0f                	jmp    801bf5 <strncpy+0x23>
		*dst++ = *src;
  801be6:	83 c2 01             	add    $0x1,%edx
  801be9:	0f b6 01             	movzbl (%ecx),%eax
  801bec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bef:	80 39 01             	cmpb   $0x1,(%ecx)
  801bf2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bf5:	39 da                	cmp    %ebx,%edx
  801bf7:	75 ed                	jne    801be6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bf9:	89 f0                	mov    %esi,%eax
  801bfb:	5b                   	pop    %ebx
  801bfc:	5e                   	pop    %esi
  801bfd:	5d                   	pop    %ebp
  801bfe:	c3                   	ret    

00801bff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	56                   	push   %esi
  801c03:	53                   	push   %ebx
  801c04:	8b 75 08             	mov    0x8(%ebp),%esi
  801c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0a:	8b 55 10             	mov    0x10(%ebp),%edx
  801c0d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c0f:	85 d2                	test   %edx,%edx
  801c11:	74 21                	je     801c34 <strlcpy+0x35>
  801c13:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c17:	89 f2                	mov    %esi,%edx
  801c19:	eb 09                	jmp    801c24 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c1b:	83 c2 01             	add    $0x1,%edx
  801c1e:	83 c1 01             	add    $0x1,%ecx
  801c21:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c24:	39 c2                	cmp    %eax,%edx
  801c26:	74 09                	je     801c31 <strlcpy+0x32>
  801c28:	0f b6 19             	movzbl (%ecx),%ebx
  801c2b:	84 db                	test   %bl,%bl
  801c2d:	75 ec                	jne    801c1b <strlcpy+0x1c>
  801c2f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c34:	29 f0                	sub    %esi,%eax
}
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    

00801c3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c40:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c43:	eb 06                	jmp    801c4b <strcmp+0x11>
		p++, q++;
  801c45:	83 c1 01             	add    $0x1,%ecx
  801c48:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c4b:	0f b6 01             	movzbl (%ecx),%eax
  801c4e:	84 c0                	test   %al,%al
  801c50:	74 04                	je     801c56 <strcmp+0x1c>
  801c52:	3a 02                	cmp    (%edx),%al
  801c54:	74 ef                	je     801c45 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c56:	0f b6 c0             	movzbl %al,%eax
  801c59:	0f b6 12             	movzbl (%edx),%edx
  801c5c:	29 d0                	sub    %edx,%eax
}
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	53                   	push   %ebx
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c6f:	eb 06                	jmp    801c77 <strncmp+0x17>
		n--, p++, q++;
  801c71:	83 c0 01             	add    $0x1,%eax
  801c74:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c77:	39 d8                	cmp    %ebx,%eax
  801c79:	74 15                	je     801c90 <strncmp+0x30>
  801c7b:	0f b6 08             	movzbl (%eax),%ecx
  801c7e:	84 c9                	test   %cl,%cl
  801c80:	74 04                	je     801c86 <strncmp+0x26>
  801c82:	3a 0a                	cmp    (%edx),%cl
  801c84:	74 eb                	je     801c71 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c86:	0f b6 00             	movzbl (%eax),%eax
  801c89:	0f b6 12             	movzbl (%edx),%edx
  801c8c:	29 d0                	sub    %edx,%eax
  801c8e:	eb 05                	jmp    801c95 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c90:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c95:	5b                   	pop    %ebx
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ca2:	eb 07                	jmp    801cab <strchr+0x13>
		if (*s == c)
  801ca4:	38 ca                	cmp    %cl,%dl
  801ca6:	74 0f                	je     801cb7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ca8:	83 c0 01             	add    $0x1,%eax
  801cab:	0f b6 10             	movzbl (%eax),%edx
  801cae:	84 d2                	test   %dl,%dl
  801cb0:	75 f2                	jne    801ca4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    

00801cb9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cc3:	eb 03                	jmp    801cc8 <strfind+0xf>
  801cc5:	83 c0 01             	add    $0x1,%eax
  801cc8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801ccb:	38 ca                	cmp    %cl,%dl
  801ccd:	74 04                	je     801cd3 <strfind+0x1a>
  801ccf:	84 d2                	test   %dl,%dl
  801cd1:	75 f2                	jne    801cc5 <strfind+0xc>
			break;
	return (char *) s;
}
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	57                   	push   %edi
  801cd9:	56                   	push   %esi
  801cda:	53                   	push   %ebx
  801cdb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ce1:	85 c9                	test   %ecx,%ecx
  801ce3:	74 36                	je     801d1b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ce5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ceb:	75 28                	jne    801d15 <memset+0x40>
  801ced:	f6 c1 03             	test   $0x3,%cl
  801cf0:	75 23                	jne    801d15 <memset+0x40>
		c &= 0xFF;
  801cf2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cf6:	89 d3                	mov    %edx,%ebx
  801cf8:	c1 e3 08             	shl    $0x8,%ebx
  801cfb:	89 d6                	mov    %edx,%esi
  801cfd:	c1 e6 18             	shl    $0x18,%esi
  801d00:	89 d0                	mov    %edx,%eax
  801d02:	c1 e0 10             	shl    $0x10,%eax
  801d05:	09 f0                	or     %esi,%eax
  801d07:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d09:	89 d8                	mov    %ebx,%eax
  801d0b:	09 d0                	or     %edx,%eax
  801d0d:	c1 e9 02             	shr    $0x2,%ecx
  801d10:	fc                   	cld    
  801d11:	f3 ab                	rep stos %eax,%es:(%edi)
  801d13:	eb 06                	jmp    801d1b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d18:	fc                   	cld    
  801d19:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d1b:	89 f8                	mov    %edi,%eax
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    

00801d22 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	57                   	push   %edi
  801d26:	56                   	push   %esi
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d30:	39 c6                	cmp    %eax,%esi
  801d32:	73 35                	jae    801d69 <memmove+0x47>
  801d34:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d37:	39 d0                	cmp    %edx,%eax
  801d39:	73 2e                	jae    801d69 <memmove+0x47>
		s += n;
		d += n;
  801d3b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d3e:	89 d6                	mov    %edx,%esi
  801d40:	09 fe                	or     %edi,%esi
  801d42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d48:	75 13                	jne    801d5d <memmove+0x3b>
  801d4a:	f6 c1 03             	test   $0x3,%cl
  801d4d:	75 0e                	jne    801d5d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d4f:	83 ef 04             	sub    $0x4,%edi
  801d52:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d55:	c1 e9 02             	shr    $0x2,%ecx
  801d58:	fd                   	std    
  801d59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d5b:	eb 09                	jmp    801d66 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d5d:	83 ef 01             	sub    $0x1,%edi
  801d60:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d63:	fd                   	std    
  801d64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d66:	fc                   	cld    
  801d67:	eb 1d                	jmp    801d86 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d69:	89 f2                	mov    %esi,%edx
  801d6b:	09 c2                	or     %eax,%edx
  801d6d:	f6 c2 03             	test   $0x3,%dl
  801d70:	75 0f                	jne    801d81 <memmove+0x5f>
  801d72:	f6 c1 03             	test   $0x3,%cl
  801d75:	75 0a                	jne    801d81 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d77:	c1 e9 02             	shr    $0x2,%ecx
  801d7a:	89 c7                	mov    %eax,%edi
  801d7c:	fc                   	cld    
  801d7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d7f:	eb 05                	jmp    801d86 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d81:	89 c7                	mov    %eax,%edi
  801d83:	fc                   	cld    
  801d84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d86:	5e                   	pop    %esi
  801d87:	5f                   	pop    %edi
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    

00801d8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d8d:	ff 75 10             	pushl  0x10(%ebp)
  801d90:	ff 75 0c             	pushl  0xc(%ebp)
  801d93:	ff 75 08             	pushl  0x8(%ebp)
  801d96:	e8 87 ff ff ff       	call   801d22 <memmove>
}
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da8:	89 c6                	mov    %eax,%esi
  801daa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dad:	eb 1a                	jmp    801dc9 <memcmp+0x2c>
		if (*s1 != *s2)
  801daf:	0f b6 08             	movzbl (%eax),%ecx
  801db2:	0f b6 1a             	movzbl (%edx),%ebx
  801db5:	38 d9                	cmp    %bl,%cl
  801db7:	74 0a                	je     801dc3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801db9:	0f b6 c1             	movzbl %cl,%eax
  801dbc:	0f b6 db             	movzbl %bl,%ebx
  801dbf:	29 d8                	sub    %ebx,%eax
  801dc1:	eb 0f                	jmp    801dd2 <memcmp+0x35>
		s1++, s2++;
  801dc3:	83 c0 01             	add    $0x1,%eax
  801dc6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dc9:	39 f0                	cmp    %esi,%eax
  801dcb:	75 e2                	jne    801daf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	53                   	push   %ebx
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801ddd:	89 c1                	mov    %eax,%ecx
  801ddf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801de2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801de6:	eb 0a                	jmp    801df2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801de8:	0f b6 10             	movzbl (%eax),%edx
  801deb:	39 da                	cmp    %ebx,%edx
  801ded:	74 07                	je     801df6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801def:	83 c0 01             	add    $0x1,%eax
  801df2:	39 c8                	cmp    %ecx,%eax
  801df4:	72 f2                	jb     801de8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801df6:	5b                   	pop    %ebx
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    

00801df9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	57                   	push   %edi
  801dfd:	56                   	push   %esi
  801dfe:	53                   	push   %ebx
  801dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e05:	eb 03                	jmp    801e0a <strtol+0x11>
		s++;
  801e07:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e0a:	0f b6 01             	movzbl (%ecx),%eax
  801e0d:	3c 20                	cmp    $0x20,%al
  801e0f:	74 f6                	je     801e07 <strtol+0xe>
  801e11:	3c 09                	cmp    $0x9,%al
  801e13:	74 f2                	je     801e07 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e15:	3c 2b                	cmp    $0x2b,%al
  801e17:	75 0a                	jne    801e23 <strtol+0x2a>
		s++;
  801e19:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e1c:	bf 00 00 00 00       	mov    $0x0,%edi
  801e21:	eb 11                	jmp    801e34 <strtol+0x3b>
  801e23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e28:	3c 2d                	cmp    $0x2d,%al
  801e2a:	75 08                	jne    801e34 <strtol+0x3b>
		s++, neg = 1;
  801e2c:	83 c1 01             	add    $0x1,%ecx
  801e2f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e3a:	75 15                	jne    801e51 <strtol+0x58>
  801e3c:	80 39 30             	cmpb   $0x30,(%ecx)
  801e3f:	75 10                	jne    801e51 <strtol+0x58>
  801e41:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e45:	75 7c                	jne    801ec3 <strtol+0xca>
		s += 2, base = 16;
  801e47:	83 c1 02             	add    $0x2,%ecx
  801e4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e4f:	eb 16                	jmp    801e67 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e51:	85 db                	test   %ebx,%ebx
  801e53:	75 12                	jne    801e67 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e55:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e5a:	80 39 30             	cmpb   $0x30,(%ecx)
  801e5d:	75 08                	jne    801e67 <strtol+0x6e>
		s++, base = 8;
  801e5f:	83 c1 01             	add    $0x1,%ecx
  801e62:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e67:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e6f:	0f b6 11             	movzbl (%ecx),%edx
  801e72:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e75:	89 f3                	mov    %esi,%ebx
  801e77:	80 fb 09             	cmp    $0x9,%bl
  801e7a:	77 08                	ja     801e84 <strtol+0x8b>
			dig = *s - '0';
  801e7c:	0f be d2             	movsbl %dl,%edx
  801e7f:	83 ea 30             	sub    $0x30,%edx
  801e82:	eb 22                	jmp    801ea6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e84:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e87:	89 f3                	mov    %esi,%ebx
  801e89:	80 fb 19             	cmp    $0x19,%bl
  801e8c:	77 08                	ja     801e96 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e8e:	0f be d2             	movsbl %dl,%edx
  801e91:	83 ea 57             	sub    $0x57,%edx
  801e94:	eb 10                	jmp    801ea6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e96:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e99:	89 f3                	mov    %esi,%ebx
  801e9b:	80 fb 19             	cmp    $0x19,%bl
  801e9e:	77 16                	ja     801eb6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ea0:	0f be d2             	movsbl %dl,%edx
  801ea3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ea6:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ea9:	7d 0b                	jge    801eb6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801eab:	83 c1 01             	add    $0x1,%ecx
  801eae:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eb2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801eb4:	eb b9                	jmp    801e6f <strtol+0x76>

	if (endptr)
  801eb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eba:	74 0d                	je     801ec9 <strtol+0xd0>
		*endptr = (char *) s;
  801ebc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ebf:	89 0e                	mov    %ecx,(%esi)
  801ec1:	eb 06                	jmp    801ec9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ec3:	85 db                	test   %ebx,%ebx
  801ec5:	74 98                	je     801e5f <strtol+0x66>
  801ec7:	eb 9e                	jmp    801e67 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ec9:	89 c2                	mov    %eax,%edx
  801ecb:	f7 da                	neg    %edx
  801ecd:	85 ff                	test   %edi,%edi
  801ecf:	0f 45 c2             	cmovne %edx,%eax
}
  801ed2:	5b                   	pop    %ebx
  801ed3:	5e                   	pop    %esi
  801ed4:	5f                   	pop    %edi
  801ed5:	5d                   	pop    %ebp
  801ed6:	c3                   	ret    

00801ed7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	56                   	push   %esi
  801edb:	53                   	push   %ebx
  801edc:	8b 75 08             	mov    0x8(%ebp),%esi
  801edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ee5:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ee7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eec:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eef:	83 ec 0c             	sub    $0xc,%esp
  801ef2:	50                   	push   %eax
  801ef3:	e8 12 e4 ff ff       	call   80030a <sys_ipc_recv>

	if (from_env_store != NULL)
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	85 f6                	test   %esi,%esi
  801efd:	74 14                	je     801f13 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801eff:	ba 00 00 00 00       	mov    $0x0,%edx
  801f04:	85 c0                	test   %eax,%eax
  801f06:	78 09                	js     801f11 <ipc_recv+0x3a>
  801f08:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f0e:	8b 52 74             	mov    0x74(%edx),%edx
  801f11:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f13:	85 db                	test   %ebx,%ebx
  801f15:	74 14                	je     801f2b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f17:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	78 09                	js     801f29 <ipc_recv+0x52>
  801f20:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f26:	8b 52 78             	mov    0x78(%edx),%edx
  801f29:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	78 08                	js     801f37 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f2f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f34:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f3a:	5b                   	pop    %ebx
  801f3b:	5e                   	pop    %esi
  801f3c:	5d                   	pop    %ebp
  801f3d:	c3                   	ret    

00801f3e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 0c             	sub    $0xc,%esp
  801f47:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f50:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f52:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f57:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f5a:	ff 75 14             	pushl  0x14(%ebp)
  801f5d:	53                   	push   %ebx
  801f5e:	56                   	push   %esi
  801f5f:	57                   	push   %edi
  801f60:	e8 82 e3 ff ff       	call   8002e7 <sys_ipc_try_send>

		if (err < 0) {
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	79 1e                	jns    801f8a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f6c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f6f:	75 07                	jne    801f78 <ipc_send+0x3a>
				sys_yield();
  801f71:	e8 c5 e1 ff ff       	call   80013b <sys_yield>
  801f76:	eb e2                	jmp    801f5a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f78:	50                   	push   %eax
  801f79:	68 20 27 80 00       	push   $0x802720
  801f7e:	6a 49                	push   $0x49
  801f80:	68 2d 27 80 00       	push   $0x80272d
  801f85:	e8 a8 f5 ff ff       	call   801532 <_panic>
		}

	} while (err < 0);

}
  801f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f9d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fa0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fa6:	8b 52 50             	mov    0x50(%edx),%edx
  801fa9:	39 ca                	cmp    %ecx,%edx
  801fab:	75 0d                	jne    801fba <ipc_find_env+0x28>
			return envs[i].env_id;
  801fad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fb0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fb5:	8b 40 48             	mov    0x48(%eax),%eax
  801fb8:	eb 0f                	jmp    801fc9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fba:	83 c0 01             	add    $0x1,%eax
  801fbd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fc2:	75 d9                	jne    801f9d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc9:	5d                   	pop    %ebp
  801fca:	c3                   	ret    

00801fcb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd1:	89 d0                	mov    %edx,%eax
  801fd3:	c1 e8 16             	shr    $0x16,%eax
  801fd6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fdd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe2:	f6 c1 01             	test   $0x1,%cl
  801fe5:	74 1d                	je     802004 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fe7:	c1 ea 0c             	shr    $0xc,%edx
  801fea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ff1:	f6 c2 01             	test   $0x1,%dl
  801ff4:	74 0e                	je     802004 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ff6:	c1 ea 0c             	shr    $0xc,%edx
  801ff9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802000:	ef 
  802001:	0f b7 c0             	movzwl %ax,%eax
}
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

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
