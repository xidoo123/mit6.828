
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 2a 05 00 00       	call   8005c2 <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 aa 22 80 00       	push   $0x8022aa
  800111:	6a 23                	push   $0x23
  800113:	68 c7 22 80 00       	push   $0x8022c7
  800118:	e8 1e 14 00 00       	call   80153b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 aa 22 80 00       	push   $0x8022aa
  800192:	6a 23                	push   $0x23
  800194:	68 c7 22 80 00       	push   $0x8022c7
  800199:	e8 9d 13 00 00       	call   80153b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 aa 22 80 00       	push   $0x8022aa
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 c7 22 80 00       	push   $0x8022c7
  8001db:	e8 5b 13 00 00       	call   80153b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 aa 22 80 00       	push   $0x8022aa
  800216:	6a 23                	push   $0x23
  800218:	68 c7 22 80 00       	push   $0x8022c7
  80021d:	e8 19 13 00 00       	call   80153b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 aa 22 80 00       	push   $0x8022aa
  800258:	6a 23                	push   $0x23
  80025a:	68 c7 22 80 00       	push   $0x8022c7
  80025f:	e8 d7 12 00 00       	call   80153b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 aa 22 80 00       	push   $0x8022aa
  80029a:	6a 23                	push   $0x23
  80029c:	68 c7 22 80 00       	push   $0x8022c7
  8002a1:	e8 95 12 00 00       	call   80153b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 aa 22 80 00       	push   $0x8022aa
  8002dc:	6a 23                	push   $0x23
  8002de:	68 c7 22 80 00       	push   $0x8022c7
  8002e3:	e8 53 12 00 00       	call   80153b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 aa 22 80 00       	push   $0x8022aa
  800340:	6a 23                	push   $0x23
  800342:	68 c7 22 80 00       	push   $0x8022c7
  800347:	e8 ef 11 00 00       	call   80153b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800364:	89 d1                	mov    %edx,%ecx
  800366:	89 d3                	mov    %edx,%ebx
  800368:	89 d7                	mov    %edx,%edi
  80036a:	89 d6                	mov    %edx,%esi
  80036c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800381:	b8 0f 00 00 00       	mov    $0xf,%eax
  800386:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800389:	8b 55 08             	mov    0x8(%ebp),%edx
  80038c:	89 df                	mov    %ebx,%edi
  80038e:	89 de                	mov    %ebx,%esi
  800390:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800392:	85 c0                	test   %eax,%eax
  800394:	7e 17                	jle    8003ad <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800396:	83 ec 0c             	sub    $0xc,%esp
  800399:	50                   	push   %eax
  80039a:	6a 0f                	push   $0xf
  80039c:	68 aa 22 80 00       	push   $0x8022aa
  8003a1:	6a 23                	push   $0x23
  8003a3:	68 c7 22 80 00       	push   $0x8022c7
  8003a8:	e8 8e 11 00 00       	call   80153b <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b0:	5b                   	pop    %ebx
  8003b1:	5e                   	pop    %esi
  8003b2:	5f                   	pop    %edi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	57                   	push   %edi
  8003b9:	56                   	push   %esi
  8003ba:	53                   	push   %ebx
  8003bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c3:	b8 10 00 00 00       	mov    $0x10,%eax
  8003c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ce:	89 df                	mov    %ebx,%edi
  8003d0:	89 de                	mov    %ebx,%esi
  8003d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	7e 17                	jle    8003ef <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d8:	83 ec 0c             	sub    $0xc,%esp
  8003db:	50                   	push   %eax
  8003dc:	6a 10                	push   $0x10
  8003de:	68 aa 22 80 00       	push   $0x8022aa
  8003e3:	6a 23                	push   $0x23
  8003e5:	68 c7 22 80 00       	push   $0x8022c7
  8003ea:	e8 4c 11 00 00       	call   80153b <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8003ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f2:	5b                   	pop    %ebx
  8003f3:	5e                   	pop    %esi
  8003f4:	5f                   	pop    %edi
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	05 00 00 00 30       	add    $0x30000000,%eax
  800402:	c1 e8 0c             	shr    $0xc,%eax
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
  80040d:	05 00 00 00 30       	add    $0x30000000,%eax
  800412:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800417:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80041c:	5d                   	pop    %ebp
  80041d:	c3                   	ret    

0080041e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800429:	89 c2                	mov    %eax,%edx
  80042b:	c1 ea 16             	shr    $0x16,%edx
  80042e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800435:	f6 c2 01             	test   $0x1,%dl
  800438:	74 11                	je     80044b <fd_alloc+0x2d>
  80043a:	89 c2                	mov    %eax,%edx
  80043c:	c1 ea 0c             	shr    $0xc,%edx
  80043f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800446:	f6 c2 01             	test   $0x1,%dl
  800449:	75 09                	jne    800454 <fd_alloc+0x36>
			*fd_store = fd;
  80044b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	eb 17                	jmp    80046b <fd_alloc+0x4d>
  800454:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800459:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80045e:	75 c9                	jne    800429 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800460:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800466:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80046b:	5d                   	pop    %ebp
  80046c:	c3                   	ret    

0080046d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800473:	83 f8 1f             	cmp    $0x1f,%eax
  800476:	77 36                	ja     8004ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800478:	c1 e0 0c             	shl    $0xc,%eax
  80047b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800480:	89 c2                	mov    %eax,%edx
  800482:	c1 ea 16             	shr    $0x16,%edx
  800485:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80048c:	f6 c2 01             	test   $0x1,%dl
  80048f:	74 24                	je     8004b5 <fd_lookup+0x48>
  800491:	89 c2                	mov    %eax,%edx
  800493:	c1 ea 0c             	shr    $0xc,%edx
  800496:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80049d:	f6 c2 01             	test   $0x1,%dl
  8004a0:	74 1a                	je     8004bc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a5:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ac:	eb 13                	jmp    8004c1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b3:	eb 0c                	jmp    8004c1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ba:	eb 05                	jmp    8004c1 <fd_lookup+0x54>
  8004bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004c1:	5d                   	pop    %ebp
  8004c2:	c3                   	ret    

008004c3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cc:	ba 54 23 80 00       	mov    $0x802354,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004d1:	eb 13                	jmp    8004e6 <dev_lookup+0x23>
  8004d3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004d6:	39 08                	cmp    %ecx,(%eax)
  8004d8:	75 0c                	jne    8004e6 <dev_lookup+0x23>
			*dev = devtab[i];
  8004da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004dd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004df:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e4:	eb 2e                	jmp    800514 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e6:	8b 02                	mov    (%edx),%eax
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	75 e7                	jne    8004d3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ec:	a1 08 40 80 00       	mov    0x804008,%eax
  8004f1:	8b 40 48             	mov    0x48(%eax),%eax
  8004f4:	83 ec 04             	sub    $0x4,%esp
  8004f7:	51                   	push   %ecx
  8004f8:	50                   	push   %eax
  8004f9:	68 d8 22 80 00       	push   $0x8022d8
  8004fe:	e8 11 11 00 00       	call   801614 <cprintf>
	*dev = 0;
  800503:	8b 45 0c             	mov    0xc(%ebp),%eax
  800506:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	83 ec 10             	sub    $0x10,%esp
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800527:	50                   	push   %eax
  800528:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80052e:	c1 e8 0c             	shr    $0xc,%eax
  800531:	50                   	push   %eax
  800532:	e8 36 ff ff ff       	call   80046d <fd_lookup>
  800537:	83 c4 08             	add    $0x8,%esp
  80053a:	85 c0                	test   %eax,%eax
  80053c:	78 05                	js     800543 <fd_close+0x2d>
	    || fd != fd2)
  80053e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800541:	74 0c                	je     80054f <fd_close+0x39>
		return (must_exist ? r : 0);
  800543:	84 db                	test   %bl,%bl
  800545:	ba 00 00 00 00       	mov    $0x0,%edx
  80054a:	0f 44 c2             	cmove  %edx,%eax
  80054d:	eb 41                	jmp    800590 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800555:	50                   	push   %eax
  800556:	ff 36                	pushl  (%esi)
  800558:	e8 66 ff ff ff       	call   8004c3 <dev_lookup>
  80055d:	89 c3                	mov    %eax,%ebx
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	78 1a                	js     800580 <fd_close+0x6a>
		if (dev->dev_close)
  800566:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800569:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80056c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800571:	85 c0                	test   %eax,%eax
  800573:	74 0b                	je     800580 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800575:	83 ec 0c             	sub    $0xc,%esp
  800578:	56                   	push   %esi
  800579:	ff d0                	call   *%eax
  80057b:	89 c3                	mov    %eax,%ebx
  80057d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	56                   	push   %esi
  800584:	6a 00                	push   $0x0
  800586:	e8 5d fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 d8                	mov    %ebx,%eax
}
  800590:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800593:	5b                   	pop    %ebx
  800594:	5e                   	pop    %esi
  800595:	5d                   	pop    %ebp
  800596:	c3                   	ret    

00800597 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80059d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005a0:	50                   	push   %eax
  8005a1:	ff 75 08             	pushl  0x8(%ebp)
  8005a4:	e8 c4 fe ff ff       	call   80046d <fd_lookup>
  8005a9:	83 c4 08             	add    $0x8,%esp
  8005ac:	85 c0                	test   %eax,%eax
  8005ae:	78 10                	js     8005c0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	6a 01                	push   $0x1
  8005b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8005b8:	e8 59 ff ff ff       	call   800516 <fd_close>
  8005bd:	83 c4 10             	add    $0x10,%esp
}
  8005c0:	c9                   	leave  
  8005c1:	c3                   	ret    

008005c2 <close_all>:

void
close_all(void)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	53                   	push   %ebx
  8005c6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005ce:	83 ec 0c             	sub    $0xc,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	e8 c0 ff ff ff       	call   800597 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d7:	83 c3 01             	add    $0x1,%ebx
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	83 fb 20             	cmp    $0x20,%ebx
  8005e0:	75 ec                	jne    8005ce <close_all+0xc>
		close(i);
}
  8005e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005e5:	c9                   	leave  
  8005e6:	c3                   	ret    

008005e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  8005ea:	57                   	push   %edi
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	83 ec 2c             	sub    $0x2c,%esp
  8005f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005f6:	50                   	push   %eax
  8005f7:	ff 75 08             	pushl  0x8(%ebp)
  8005fa:	e8 6e fe ff ff       	call   80046d <fd_lookup>
  8005ff:	83 c4 08             	add    $0x8,%esp
  800602:	85 c0                	test   %eax,%eax
  800604:	0f 88 c1 00 00 00    	js     8006cb <dup+0xe4>
		return r;
	close(newfdnum);
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	56                   	push   %esi
  80060e:	e8 84 ff ff ff       	call   800597 <close>

	newfd = INDEX2FD(newfdnum);
  800613:	89 f3                	mov    %esi,%ebx
  800615:	c1 e3 0c             	shl    $0xc,%ebx
  800618:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80061e:	83 c4 04             	add    $0x4,%esp
  800621:	ff 75 e4             	pushl  -0x1c(%ebp)
  800624:	e8 de fd ff ff       	call   800407 <fd2data>
  800629:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80062b:	89 1c 24             	mov    %ebx,(%esp)
  80062e:	e8 d4 fd ff ff       	call   800407 <fd2data>
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800639:	89 f8                	mov    %edi,%eax
  80063b:	c1 e8 16             	shr    $0x16,%eax
  80063e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800645:	a8 01                	test   $0x1,%al
  800647:	74 37                	je     800680 <dup+0x99>
  800649:	89 f8                	mov    %edi,%eax
  80064b:	c1 e8 0c             	shr    $0xc,%eax
  80064e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800655:	f6 c2 01             	test   $0x1,%dl
  800658:	74 26                	je     800680 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80065a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	25 07 0e 00 00       	and    $0xe07,%eax
  800669:	50                   	push   %eax
  80066a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066d:	6a 00                	push   $0x0
  80066f:	57                   	push   %edi
  800670:	6a 00                	push   $0x0
  800672:	e8 2f fb ff ff       	call   8001a6 <sys_page_map>
  800677:	89 c7                	mov    %eax,%edi
  800679:	83 c4 20             	add    $0x20,%esp
  80067c:	85 c0                	test   %eax,%eax
  80067e:	78 2e                	js     8006ae <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800680:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800683:	89 d0                	mov    %edx,%eax
  800685:	c1 e8 0c             	shr    $0xc,%eax
  800688:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	25 07 0e 00 00       	and    $0xe07,%eax
  800697:	50                   	push   %eax
  800698:	53                   	push   %ebx
  800699:	6a 00                	push   $0x0
  80069b:	52                   	push   %edx
  80069c:	6a 00                	push   $0x0
  80069e:	e8 03 fb ff ff       	call   8001a6 <sys_page_map>
  8006a3:	89 c7                	mov    %eax,%edi
  8006a5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006a8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006aa:	85 ff                	test   %edi,%edi
  8006ac:	79 1d                	jns    8006cb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 00                	push   $0x0
  8006b4:	e8 2f fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006b9:	83 c4 08             	add    $0x8,%esp
  8006bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006bf:	6a 00                	push   $0x0
  8006c1:	e8 22 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	89 f8                	mov    %edi,%eax
}
  8006cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ce:	5b                   	pop    %ebx
  8006cf:	5e                   	pop    %esi
  8006d0:	5f                   	pop    %edi
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	53                   	push   %ebx
  8006d7:	83 ec 14             	sub    $0x14,%esp
  8006da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e0:	50                   	push   %eax
  8006e1:	53                   	push   %ebx
  8006e2:	e8 86 fd ff ff       	call   80046d <fd_lookup>
  8006e7:	83 c4 08             	add    $0x8,%esp
  8006ea:	89 c2                	mov    %eax,%edx
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	78 6d                	js     80075d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f6:	50                   	push   %eax
  8006f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006fa:	ff 30                	pushl  (%eax)
  8006fc:	e8 c2 fd ff ff       	call   8004c3 <dev_lookup>
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	85 c0                	test   %eax,%eax
  800706:	78 4c                	js     800754 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800708:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80070b:	8b 42 08             	mov    0x8(%edx),%eax
  80070e:	83 e0 03             	and    $0x3,%eax
  800711:	83 f8 01             	cmp    $0x1,%eax
  800714:	75 21                	jne    800737 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800716:	a1 08 40 80 00       	mov    0x804008,%eax
  80071b:	8b 40 48             	mov    0x48(%eax),%eax
  80071e:	83 ec 04             	sub    $0x4,%esp
  800721:	53                   	push   %ebx
  800722:	50                   	push   %eax
  800723:	68 19 23 80 00       	push   $0x802319
  800728:	e8 e7 0e 00 00       	call   801614 <cprintf>
		return -E_INVAL;
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800735:	eb 26                	jmp    80075d <read+0x8a>
	}
	if (!dev->dev_read)
  800737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073a:	8b 40 08             	mov    0x8(%eax),%eax
  80073d:	85 c0                	test   %eax,%eax
  80073f:	74 17                	je     800758 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800741:	83 ec 04             	sub    $0x4,%esp
  800744:	ff 75 10             	pushl  0x10(%ebp)
  800747:	ff 75 0c             	pushl  0xc(%ebp)
  80074a:	52                   	push   %edx
  80074b:	ff d0                	call   *%eax
  80074d:	89 c2                	mov    %eax,%edx
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	eb 09                	jmp    80075d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800754:	89 c2                	mov    %eax,%edx
  800756:	eb 05                	jmp    80075d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800758:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80075d:	89 d0                	mov    %edx,%eax
  80075f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	57                   	push   %edi
  800768:	56                   	push   %esi
  800769:	53                   	push   %ebx
  80076a:	83 ec 0c             	sub    $0xc,%esp
  80076d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800770:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800773:	bb 00 00 00 00       	mov    $0x0,%ebx
  800778:	eb 21                	jmp    80079b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	89 f0                	mov    %esi,%eax
  80077f:	29 d8                	sub    %ebx,%eax
  800781:	50                   	push   %eax
  800782:	89 d8                	mov    %ebx,%eax
  800784:	03 45 0c             	add    0xc(%ebp),%eax
  800787:	50                   	push   %eax
  800788:	57                   	push   %edi
  800789:	e8 45 ff ff ff       	call   8006d3 <read>
		if (m < 0)
  80078e:	83 c4 10             	add    $0x10,%esp
  800791:	85 c0                	test   %eax,%eax
  800793:	78 10                	js     8007a5 <readn+0x41>
			return m;
		if (m == 0)
  800795:	85 c0                	test   %eax,%eax
  800797:	74 0a                	je     8007a3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800799:	01 c3                	add    %eax,%ebx
  80079b:	39 f3                	cmp    %esi,%ebx
  80079d:	72 db                	jb     80077a <readn+0x16>
  80079f:	89 d8                	mov    %ebx,%eax
  8007a1:	eb 02                	jmp    8007a5 <readn+0x41>
  8007a3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5f                   	pop    %edi
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	53                   	push   %ebx
  8007b1:	83 ec 14             	sub    $0x14,%esp
  8007b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ba:	50                   	push   %eax
  8007bb:	53                   	push   %ebx
  8007bc:	e8 ac fc ff ff       	call   80046d <fd_lookup>
  8007c1:	83 c4 08             	add    $0x8,%esp
  8007c4:	89 c2                	mov    %eax,%edx
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	78 68                	js     800832 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d4:	ff 30                	pushl  (%eax)
  8007d6:	e8 e8 fc ff ff       	call   8004c3 <dev_lookup>
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 47                	js     800829 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e9:	75 21                	jne    80080c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007eb:	a1 08 40 80 00       	mov    0x804008,%eax
  8007f0:	8b 40 48             	mov    0x48(%eax),%eax
  8007f3:	83 ec 04             	sub    $0x4,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	50                   	push   %eax
  8007f8:	68 35 23 80 00       	push   $0x802335
  8007fd:	e8 12 0e 00 00       	call   801614 <cprintf>
		return -E_INVAL;
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080a:	eb 26                	jmp    800832 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80080c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80080f:	8b 52 0c             	mov    0xc(%edx),%edx
  800812:	85 d2                	test   %edx,%edx
  800814:	74 17                	je     80082d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800816:	83 ec 04             	sub    $0x4,%esp
  800819:	ff 75 10             	pushl  0x10(%ebp)
  80081c:	ff 75 0c             	pushl  0xc(%ebp)
  80081f:	50                   	push   %eax
  800820:	ff d2                	call   *%edx
  800822:	89 c2                	mov    %eax,%edx
  800824:	83 c4 10             	add    $0x10,%esp
  800827:	eb 09                	jmp    800832 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800829:	89 c2                	mov    %eax,%edx
  80082b:	eb 05                	jmp    800832 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80082d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800832:	89 d0                	mov    %edx,%eax
  800834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <seek>:

int
seek(int fdnum, off_t offset)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80083f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	ff 75 08             	pushl  0x8(%ebp)
  800846:	e8 22 fc ff ff       	call   80046d <fd_lookup>
  80084b:	83 c4 08             	add    $0x8,%esp
  80084e:	85 c0                	test   %eax,%eax
  800850:	78 0e                	js     800860 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800852:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800855:	8b 55 0c             	mov    0xc(%ebp),%edx
  800858:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	83 ec 14             	sub    $0x14,%esp
  800869:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086f:	50                   	push   %eax
  800870:	53                   	push   %ebx
  800871:	e8 f7 fb ff ff       	call   80046d <fd_lookup>
  800876:	83 c4 08             	add    $0x8,%esp
  800879:	89 c2                	mov    %eax,%edx
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 65                	js     8008e4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800885:	50                   	push   %eax
  800886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800889:	ff 30                	pushl  (%eax)
  80088b:	e8 33 fc ff ff       	call   8004c3 <dev_lookup>
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	85 c0                	test   %eax,%eax
  800895:	78 44                	js     8008db <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80089e:	75 21                	jne    8008c1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008a0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008a5:	8b 40 48             	mov    0x48(%eax),%eax
  8008a8:	83 ec 04             	sub    $0x4,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	50                   	push   %eax
  8008ad:	68 f8 22 80 00       	push   $0x8022f8
  8008b2:	e8 5d 0d 00 00       	call   801614 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008bf:	eb 23                	jmp    8008e4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008c4:	8b 52 18             	mov    0x18(%edx),%edx
  8008c7:	85 d2                	test   %edx,%edx
  8008c9:	74 14                	je     8008df <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	ff 75 0c             	pushl  0xc(%ebp)
  8008d1:	50                   	push   %eax
  8008d2:	ff d2                	call   *%edx
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	83 c4 10             	add    $0x10,%esp
  8008d9:	eb 09                	jmp    8008e4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008db:	89 c2                	mov    %eax,%edx
  8008dd:	eb 05                	jmp    8008e4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008e4:	89 d0                	mov    %edx,%eax
  8008e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	83 ec 14             	sub    $0x14,%esp
  8008f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008f8:	50                   	push   %eax
  8008f9:	ff 75 08             	pushl  0x8(%ebp)
  8008fc:	e8 6c fb ff ff       	call   80046d <fd_lookup>
  800901:	83 c4 08             	add    $0x8,%esp
  800904:	89 c2                	mov    %eax,%edx
  800906:	85 c0                	test   %eax,%eax
  800908:	78 58                	js     800962 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800910:	50                   	push   %eax
  800911:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800914:	ff 30                	pushl  (%eax)
  800916:	e8 a8 fb ff ff       	call   8004c3 <dev_lookup>
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	85 c0                	test   %eax,%eax
  800920:	78 37                	js     800959 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800922:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800925:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800929:	74 32                	je     80095d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80092b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80092e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800935:	00 00 00 
	stat->st_isdir = 0;
  800938:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80093f:	00 00 00 
	stat->st_dev = dev;
  800942:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800948:	83 ec 08             	sub    $0x8,%esp
  80094b:	53                   	push   %ebx
  80094c:	ff 75 f0             	pushl  -0x10(%ebp)
  80094f:	ff 50 14             	call   *0x14(%eax)
  800952:	89 c2                	mov    %eax,%edx
  800954:	83 c4 10             	add    $0x10,%esp
  800957:	eb 09                	jmp    800962 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800959:	89 c2                	mov    %eax,%edx
  80095b:	eb 05                	jmp    800962 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80095d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800962:	89 d0                	mov    %edx,%eax
  800964:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	56                   	push   %esi
  80096d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80096e:	83 ec 08             	sub    $0x8,%esp
  800971:	6a 00                	push   $0x0
  800973:	ff 75 08             	pushl  0x8(%ebp)
  800976:	e8 d6 01 00 00       	call   800b51 <open>
  80097b:	89 c3                	mov    %eax,%ebx
  80097d:	83 c4 10             	add    $0x10,%esp
  800980:	85 c0                	test   %eax,%eax
  800982:	78 1b                	js     80099f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800984:	83 ec 08             	sub    $0x8,%esp
  800987:	ff 75 0c             	pushl  0xc(%ebp)
  80098a:	50                   	push   %eax
  80098b:	e8 5b ff ff ff       	call   8008eb <fstat>
  800990:	89 c6                	mov    %eax,%esi
	close(fd);
  800992:	89 1c 24             	mov    %ebx,(%esp)
  800995:	e8 fd fb ff ff       	call   800597 <close>
	return r;
  80099a:	83 c4 10             	add    $0x10,%esp
  80099d:	89 f0                	mov    %esi,%eax
}
  80099f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	89 c6                	mov    %eax,%esi
  8009ad:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009af:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009b6:	75 12                	jne    8009ca <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009b8:	83 ec 0c             	sub    $0xc,%esp
  8009bb:	6a 01                	push   $0x1
  8009bd:	e8 d9 15 00 00       	call   801f9b <ipc_find_env>
  8009c2:	a3 00 40 80 00       	mov    %eax,0x804000
  8009c7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009ca:	6a 07                	push   $0x7
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	56                   	push   %esi
  8009d2:	ff 35 00 40 80 00    	pushl  0x804000
  8009d8:	e8 6a 15 00 00       	call   801f47 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009dd:	83 c4 0c             	add    $0xc,%esp
  8009e0:	6a 00                	push   $0x0
  8009e2:	53                   	push   %ebx
  8009e3:	6a 00                	push   $0x0
  8009e5:	e8 f6 14 00 00       	call   801ee0 <ipc_recv>
}
  8009ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a05:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0f:	b8 02 00 00 00       	mov    $0x2,%eax
  800a14:	e8 8d ff ff ff       	call   8009a6 <fsipc>
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 40 0c             	mov    0xc(%eax),%eax
  800a27:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a31:	b8 06 00 00 00       	mov    $0x6,%eax
  800a36:	e8 6b ff ff ff       	call   8009a6 <fsipc>
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	53                   	push   %ebx
  800a41:	83 ec 04             	sub    $0x4,%esp
  800a44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a52:	ba 00 00 00 00       	mov    $0x0,%edx
  800a57:	b8 05 00 00 00       	mov    $0x5,%eax
  800a5c:	e8 45 ff ff ff       	call   8009a6 <fsipc>
  800a61:	85 c0                	test   %eax,%eax
  800a63:	78 2c                	js     800a91 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a65:	83 ec 08             	sub    $0x8,%esp
  800a68:	68 00 50 80 00       	push   $0x805000
  800a6d:	53                   	push   %ebx
  800a6e:	e8 26 11 00 00       	call   801b99 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a73:	a1 80 50 80 00       	mov    0x805080,%eax
  800a78:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a7e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a83:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	83 ec 0c             	sub    $0xc,%esp
  800a9c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa2:	8b 52 0c             	mov    0xc(%edx),%edx
  800aa5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800aab:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800ab0:	50                   	push   %eax
  800ab1:	ff 75 0c             	pushl  0xc(%ebp)
  800ab4:	68 08 50 80 00       	push   $0x805008
  800ab9:	e8 6d 12 00 00       	call   801d2b <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800abe:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ac8:	e8 d9 fe ff ff       	call   8009a6 <fsipc>

}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	8b 40 0c             	mov    0xc(%eax),%eax
  800add:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ae2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 03 00 00 00       	mov    $0x3,%eax
  800af2:	e8 af fe ff ff       	call   8009a6 <fsipc>
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	85 c0                	test   %eax,%eax
  800afb:	78 4b                	js     800b48 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800afd:	39 c6                	cmp    %eax,%esi
  800aff:	73 16                	jae    800b17 <devfile_read+0x48>
  800b01:	68 68 23 80 00       	push   $0x802368
  800b06:	68 6f 23 80 00       	push   $0x80236f
  800b0b:	6a 7c                	push   $0x7c
  800b0d:	68 84 23 80 00       	push   $0x802384
  800b12:	e8 24 0a 00 00       	call   80153b <_panic>
	assert(r <= PGSIZE);
  800b17:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b1c:	7e 16                	jle    800b34 <devfile_read+0x65>
  800b1e:	68 8f 23 80 00       	push   $0x80238f
  800b23:	68 6f 23 80 00       	push   $0x80236f
  800b28:	6a 7d                	push   $0x7d
  800b2a:	68 84 23 80 00       	push   $0x802384
  800b2f:	e8 07 0a 00 00       	call   80153b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b34:	83 ec 04             	sub    $0x4,%esp
  800b37:	50                   	push   %eax
  800b38:	68 00 50 80 00       	push   $0x805000
  800b3d:	ff 75 0c             	pushl  0xc(%ebp)
  800b40:	e8 e6 11 00 00       	call   801d2b <memmove>
	return r;
  800b45:	83 c4 10             	add    $0x10,%esp
}
  800b48:	89 d8                	mov    %ebx,%eax
  800b4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	53                   	push   %ebx
  800b55:	83 ec 20             	sub    $0x20,%esp
  800b58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b5b:	53                   	push   %ebx
  800b5c:	e8 ff 0f 00 00       	call   801b60 <strlen>
  800b61:	83 c4 10             	add    $0x10,%esp
  800b64:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b69:	7f 67                	jg     800bd2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b71:	50                   	push   %eax
  800b72:	e8 a7 f8 ff ff       	call   80041e <fd_alloc>
  800b77:	83 c4 10             	add    $0x10,%esp
		return r;
  800b7a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	78 57                	js     800bd7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b80:	83 ec 08             	sub    $0x8,%esp
  800b83:	53                   	push   %ebx
  800b84:	68 00 50 80 00       	push   $0x805000
  800b89:	e8 0b 10 00 00       	call   801b99 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b91:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b99:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9e:	e8 03 fe ff ff       	call   8009a6 <fsipc>
  800ba3:	89 c3                	mov    %eax,%ebx
  800ba5:	83 c4 10             	add    $0x10,%esp
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	79 14                	jns    800bc0 <open+0x6f>
		fd_close(fd, 0);
  800bac:	83 ec 08             	sub    $0x8,%esp
  800baf:	6a 00                	push   $0x0
  800bb1:	ff 75 f4             	pushl  -0xc(%ebp)
  800bb4:	e8 5d f9 ff ff       	call   800516 <fd_close>
		return r;
  800bb9:	83 c4 10             	add    $0x10,%esp
  800bbc:	89 da                	mov    %ebx,%edx
  800bbe:	eb 17                	jmp    800bd7 <open+0x86>
	}

	return fd2num(fd);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	ff 75 f4             	pushl  -0xc(%ebp)
  800bc6:	e8 2c f8 ff ff       	call   8003f7 <fd2num>
  800bcb:	89 c2                	mov    %eax,%edx
  800bcd:	83 c4 10             	add    $0x10,%esp
  800bd0:	eb 05                	jmp    800bd7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bd2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bd7:	89 d0                	mov    %edx,%eax
  800bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 08 00 00 00       	mov    $0x8,%eax
  800bee:	e8 b3 fd ff ff       	call   8009a6 <fsipc>
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bfb:	68 9b 23 80 00       	push   $0x80239b
  800c00:	ff 75 0c             	pushl  0xc(%ebp)
  800c03:	e8 91 0f 00 00       	call   801b99 <strcpy>
	return 0;
}
  800c08:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	53                   	push   %ebx
  800c13:	83 ec 10             	sub    $0x10,%esp
  800c16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c19:	53                   	push   %ebx
  800c1a:	e8 b5 13 00 00       	call   801fd4 <pageref>
  800c1f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c27:	83 f8 01             	cmp    $0x1,%eax
  800c2a:	75 10                	jne    800c3c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	ff 73 0c             	pushl  0xc(%ebx)
  800c32:	e8 c0 02 00 00       	call   800ef7 <nsipc_close>
  800c37:	89 c2                	mov    %eax,%edx
  800c39:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c3c:	89 d0                	mov    %edx,%eax
  800c3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c49:	6a 00                	push   $0x0
  800c4b:	ff 75 10             	pushl  0x10(%ebp)
  800c4e:	ff 75 0c             	pushl  0xc(%ebp)
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	ff 70 0c             	pushl  0xc(%eax)
  800c57:	e8 78 03 00 00       	call   800fd4 <nsipc_send>
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c64:	6a 00                	push   $0x0
  800c66:	ff 75 10             	pushl  0x10(%ebp)
  800c69:	ff 75 0c             	pushl  0xc(%ebp)
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	ff 70 0c             	pushl  0xc(%eax)
  800c72:	e8 f1 02 00 00       	call   800f68 <nsipc_recv>
}
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    

00800c79 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c7f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c82:	52                   	push   %edx
  800c83:	50                   	push   %eax
  800c84:	e8 e4 f7 ff ff       	call   80046d <fd_lookup>
  800c89:	83 c4 10             	add    $0x10,%esp
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	78 17                	js     800ca7 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c93:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c99:	39 08                	cmp    %ecx,(%eax)
  800c9b:	75 05                	jne    800ca2 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c9d:	8b 40 0c             	mov    0xc(%eax),%eax
  800ca0:	eb 05                	jmp    800ca7 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800ca2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 1c             	sub    $0x1c,%esp
  800cb1:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800cb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cb6:	50                   	push   %eax
  800cb7:	e8 62 f7 ff ff       	call   80041e <fd_alloc>
  800cbc:	89 c3                	mov    %eax,%ebx
  800cbe:	83 c4 10             	add    $0x10,%esp
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	78 1b                	js     800ce0 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cc5:	83 ec 04             	sub    $0x4,%esp
  800cc8:	68 07 04 00 00       	push   $0x407
  800ccd:	ff 75 f4             	pushl  -0xc(%ebp)
  800cd0:	6a 00                	push   $0x0
  800cd2:	e8 8c f4 ff ff       	call   800163 <sys_page_alloc>
  800cd7:	89 c3                	mov    %eax,%ebx
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	79 10                	jns    800cf0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	56                   	push   %esi
  800ce4:	e8 0e 02 00 00       	call   800ef7 <nsipc_close>
		return r;
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	89 d8                	mov    %ebx,%eax
  800cee:	eb 24                	jmp    800d14 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cf0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cfe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d05:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	e8 e6 f6 ff ff       	call   8003f7 <fd2num>
  800d11:	83 c4 10             	add    $0x10,%esp
}
  800d14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d21:	8b 45 08             	mov    0x8(%ebp),%eax
  800d24:	e8 50 ff ff ff       	call   800c79 <fd2sockid>
		return r;
  800d29:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	78 1f                	js     800d4e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d2f:	83 ec 04             	sub    $0x4,%esp
  800d32:	ff 75 10             	pushl  0x10(%ebp)
  800d35:	ff 75 0c             	pushl  0xc(%ebp)
  800d38:	50                   	push   %eax
  800d39:	e8 12 01 00 00       	call   800e50 <nsipc_accept>
  800d3e:	83 c4 10             	add    $0x10,%esp
		return r;
  800d41:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	78 07                	js     800d4e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d47:	e8 5d ff ff ff       	call   800ca9 <alloc_sockfd>
  800d4c:	89 c1                	mov    %eax,%ecx
}
  800d4e:	89 c8                	mov    %ecx,%eax
  800d50:	c9                   	leave  
  800d51:	c3                   	ret    

00800d52 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	e8 19 ff ff ff       	call   800c79 <fd2sockid>
  800d60:	85 c0                	test   %eax,%eax
  800d62:	78 12                	js     800d76 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d64:	83 ec 04             	sub    $0x4,%esp
  800d67:	ff 75 10             	pushl  0x10(%ebp)
  800d6a:	ff 75 0c             	pushl  0xc(%ebp)
  800d6d:	50                   	push   %eax
  800d6e:	e8 2d 01 00 00       	call   800ea0 <nsipc_bind>
  800d73:	83 c4 10             	add    $0x10,%esp
}
  800d76:	c9                   	leave  
  800d77:	c3                   	ret    

00800d78 <shutdown>:

int
shutdown(int s, int how)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	e8 f3 fe ff ff       	call   800c79 <fd2sockid>
  800d86:	85 c0                	test   %eax,%eax
  800d88:	78 0f                	js     800d99 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d8a:	83 ec 08             	sub    $0x8,%esp
  800d8d:	ff 75 0c             	pushl  0xc(%ebp)
  800d90:	50                   	push   %eax
  800d91:	e8 3f 01 00 00       	call   800ed5 <nsipc_shutdown>
  800d96:	83 c4 10             	add    $0x10,%esp
}
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    

00800d9b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	e8 d0 fe ff ff       	call   800c79 <fd2sockid>
  800da9:	85 c0                	test   %eax,%eax
  800dab:	78 12                	js     800dbf <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	ff 75 10             	pushl  0x10(%ebp)
  800db3:	ff 75 0c             	pushl  0xc(%ebp)
  800db6:	50                   	push   %eax
  800db7:	e8 55 01 00 00       	call   800f11 <nsipc_connect>
  800dbc:	83 c4 10             	add    $0x10,%esp
}
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <listen>:

int
listen(int s, int backlog)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	e8 aa fe ff ff       	call   800c79 <fd2sockid>
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	78 0f                	js     800de2 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dd3:	83 ec 08             	sub    $0x8,%esp
  800dd6:	ff 75 0c             	pushl  0xc(%ebp)
  800dd9:	50                   	push   %eax
  800dda:	e8 67 01 00 00       	call   800f46 <nsipc_listen>
  800ddf:	83 c4 10             	add    $0x10,%esp
}
  800de2:	c9                   	leave  
  800de3:	c3                   	ret    

00800de4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dea:	ff 75 10             	pushl  0x10(%ebp)
  800ded:	ff 75 0c             	pushl  0xc(%ebp)
  800df0:	ff 75 08             	pushl  0x8(%ebp)
  800df3:	e8 3a 02 00 00       	call   801032 <nsipc_socket>
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	78 05                	js     800e04 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dff:	e8 a5 fe ff ff       	call   800ca9 <alloc_sockfd>
}
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e0f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e16:	75 12                	jne    800e2a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	6a 02                	push   $0x2
  800e1d:	e8 79 11 00 00       	call   801f9b <ipc_find_env>
  800e22:	a3 04 40 80 00       	mov    %eax,0x804004
  800e27:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e2a:	6a 07                	push   $0x7
  800e2c:	68 00 60 80 00       	push   $0x806000
  800e31:	53                   	push   %ebx
  800e32:	ff 35 04 40 80 00    	pushl  0x804004
  800e38:	e8 0a 11 00 00       	call   801f47 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e3d:	83 c4 0c             	add    $0xc,%esp
  800e40:	6a 00                	push   $0x0
  800e42:	6a 00                	push   $0x0
  800e44:	6a 00                	push   $0x0
  800e46:	e8 95 10 00 00       	call   801ee0 <ipc_recv>
}
  800e4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4e:	c9                   	leave  
  800e4f:	c3                   	ret    

00800e50 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e60:	8b 06                	mov    (%esi),%eax
  800e62:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e67:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6c:	e8 95 ff ff ff       	call   800e06 <nsipc>
  800e71:	89 c3                	mov    %eax,%ebx
  800e73:	85 c0                	test   %eax,%eax
  800e75:	78 20                	js     800e97 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e77:	83 ec 04             	sub    $0x4,%esp
  800e7a:	ff 35 10 60 80 00    	pushl  0x806010
  800e80:	68 00 60 80 00       	push   $0x806000
  800e85:	ff 75 0c             	pushl  0xc(%ebp)
  800e88:	e8 9e 0e 00 00       	call   801d2b <memmove>
		*addrlen = ret->ret_addrlen;
  800e8d:	a1 10 60 80 00       	mov    0x806010,%eax
  800e92:	89 06                	mov    %eax,(%esi)
  800e94:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e97:	89 d8                	mov    %ebx,%eax
  800e99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 08             	sub    $0x8,%esp
  800ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ead:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800eb2:	53                   	push   %ebx
  800eb3:	ff 75 0c             	pushl  0xc(%ebp)
  800eb6:	68 04 60 80 00       	push   $0x806004
  800ebb:	e8 6b 0e 00 00       	call   801d2b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ec0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ec6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ecb:	e8 36 ff ff ff       	call   800e06 <nsipc>
}
  800ed0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    

00800ed5 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800eeb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ef0:	e8 11 ff ff ff       	call   800e06 <nsipc>
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <nsipc_close>:

int
nsipc_close(int s)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f05:	b8 04 00 00 00       	mov    $0x4,%eax
  800f0a:	e8 f7 fe ff ff       	call   800e06 <nsipc>
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	53                   	push   %ebx
  800f15:	83 ec 08             	sub    $0x8,%esp
  800f18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f23:	53                   	push   %ebx
  800f24:	ff 75 0c             	pushl  0xc(%ebp)
  800f27:	68 04 60 80 00       	push   $0x806004
  800f2c:	e8 fa 0d 00 00       	call   801d2b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f31:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f37:	b8 05 00 00 00       	mov    $0x5,%eax
  800f3c:	e8 c5 fe ff ff       	call   800e06 <nsipc>
}
  800f41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    

00800f46 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f57:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f5c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f61:	e8 a0 fe ff ff       	call   800e06 <nsipc>
}
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
  800f6d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f70:	8b 45 08             	mov    0x8(%ebp),%eax
  800f73:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f78:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f81:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f86:	b8 07 00 00 00       	mov    $0x7,%eax
  800f8b:	e8 76 fe ff ff       	call   800e06 <nsipc>
  800f90:	89 c3                	mov    %eax,%ebx
  800f92:	85 c0                	test   %eax,%eax
  800f94:	78 35                	js     800fcb <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f96:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f9b:	7f 04                	jg     800fa1 <nsipc_recv+0x39>
  800f9d:	39 c6                	cmp    %eax,%esi
  800f9f:	7d 16                	jge    800fb7 <nsipc_recv+0x4f>
  800fa1:	68 a7 23 80 00       	push   $0x8023a7
  800fa6:	68 6f 23 80 00       	push   $0x80236f
  800fab:	6a 62                	push   $0x62
  800fad:	68 bc 23 80 00       	push   $0x8023bc
  800fb2:	e8 84 05 00 00       	call   80153b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	50                   	push   %eax
  800fbb:	68 00 60 80 00       	push   $0x806000
  800fc0:	ff 75 0c             	pushl  0xc(%ebp)
  800fc3:	e8 63 0d 00 00       	call   801d2b <memmove>
  800fc8:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 04             	sub    $0x4,%esp
  800fdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fe6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fec:	7e 16                	jle    801004 <nsipc_send+0x30>
  800fee:	68 c8 23 80 00       	push   $0x8023c8
  800ff3:	68 6f 23 80 00       	push   $0x80236f
  800ff8:	6a 6d                	push   $0x6d
  800ffa:	68 bc 23 80 00       	push   $0x8023bc
  800fff:	e8 37 05 00 00       	call   80153b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	53                   	push   %ebx
  801008:	ff 75 0c             	pushl  0xc(%ebp)
  80100b:	68 0c 60 80 00       	push   $0x80600c
  801010:	e8 16 0d 00 00       	call   801d2b <memmove>
	nsipcbuf.send.req_size = size;
  801015:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80101b:	8b 45 14             	mov    0x14(%ebp),%eax
  80101e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801023:	b8 08 00 00 00       	mov    $0x8,%eax
  801028:	e8 d9 fd ff ff       	call   800e06 <nsipc>
}
  80102d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801030:	c9                   	leave  
  801031:	c3                   	ret    

00801032 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801038:	8b 45 08             	mov    0x8(%ebp),%eax
  80103b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801040:	8b 45 0c             	mov    0xc(%ebp),%eax
  801043:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801048:	8b 45 10             	mov    0x10(%ebp),%eax
  80104b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801050:	b8 09 00 00 00       	mov    $0x9,%eax
  801055:	e8 ac fd ff ff       	call   800e06 <nsipc>
}
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	ff 75 08             	pushl  0x8(%ebp)
  80106a:	e8 98 f3 ff ff       	call   800407 <fd2data>
  80106f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801071:	83 c4 08             	add    $0x8,%esp
  801074:	68 d4 23 80 00       	push   $0x8023d4
  801079:	53                   	push   %ebx
  80107a:	e8 1a 0b 00 00       	call   801b99 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80107f:	8b 46 04             	mov    0x4(%esi),%eax
  801082:	2b 06                	sub    (%esi),%eax
  801084:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80108a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801091:	00 00 00 
	stat->st_dev = &devpipe;
  801094:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80109b:	30 80 00 
	return 0;
}
  80109e:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	53                   	push   %ebx
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010b4:	53                   	push   %ebx
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 2c f1 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010bc:	89 1c 24             	mov    %ebx,(%esp)
  8010bf:	e8 43 f3 ff ff       	call   800407 <fd2data>
  8010c4:	83 c4 08             	add    $0x8,%esp
  8010c7:	50                   	push   %eax
  8010c8:	6a 00                	push   $0x0
  8010ca:	e8 19 f1 ff ff       	call   8001e8 <sys_page_unmap>
}
  8010cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    

008010d4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
  8010da:	83 ec 1c             	sub    $0x1c,%esp
  8010dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010e0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f0:	e8 df 0e 00 00       	call   801fd4 <pageref>
  8010f5:	89 c3                	mov    %eax,%ebx
  8010f7:	89 3c 24             	mov    %edi,(%esp)
  8010fa:	e8 d5 0e 00 00       	call   801fd4 <pageref>
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	39 c3                	cmp    %eax,%ebx
  801104:	0f 94 c1             	sete   %cl
  801107:	0f b6 c9             	movzbl %cl,%ecx
  80110a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80110d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801113:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801116:	39 ce                	cmp    %ecx,%esi
  801118:	74 1b                	je     801135 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80111a:	39 c3                	cmp    %eax,%ebx
  80111c:	75 c4                	jne    8010e2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80111e:	8b 42 58             	mov    0x58(%edx),%eax
  801121:	ff 75 e4             	pushl  -0x1c(%ebp)
  801124:	50                   	push   %eax
  801125:	56                   	push   %esi
  801126:	68 db 23 80 00       	push   $0x8023db
  80112b:	e8 e4 04 00 00       	call   801614 <cprintf>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	eb ad                	jmp    8010e2 <_pipeisclosed+0xe>
	}
}
  801135:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	83 ec 28             	sub    $0x28,%esp
  801149:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80114c:	56                   	push   %esi
  80114d:	e8 b5 f2 ff ff       	call   800407 <fd2data>
  801152:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	bf 00 00 00 00       	mov    $0x0,%edi
  80115c:	eb 4b                	jmp    8011a9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80115e:	89 da                	mov    %ebx,%edx
  801160:	89 f0                	mov    %esi,%eax
  801162:	e8 6d ff ff ff       	call   8010d4 <_pipeisclosed>
  801167:	85 c0                	test   %eax,%eax
  801169:	75 48                	jne    8011b3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80116b:	e8 d4 ef ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801170:	8b 43 04             	mov    0x4(%ebx),%eax
  801173:	8b 0b                	mov    (%ebx),%ecx
  801175:	8d 51 20             	lea    0x20(%ecx),%edx
  801178:	39 d0                	cmp    %edx,%eax
  80117a:	73 e2                	jae    80115e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80117c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801183:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801186:	89 c2                	mov    %eax,%edx
  801188:	c1 fa 1f             	sar    $0x1f,%edx
  80118b:	89 d1                	mov    %edx,%ecx
  80118d:	c1 e9 1b             	shr    $0x1b,%ecx
  801190:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801193:	83 e2 1f             	and    $0x1f,%edx
  801196:	29 ca                	sub    %ecx,%edx
  801198:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80119c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011a0:	83 c0 01             	add    $0x1,%eax
  8011a3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011a6:	83 c7 01             	add    $0x1,%edi
  8011a9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011ac:	75 c2                	jne    801170 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b1:	eb 05                	jmp    8011b8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	57                   	push   %edi
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 18             	sub    $0x18,%esp
  8011c9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011cc:	57                   	push   %edi
  8011cd:	e8 35 f2 ff ff       	call   800407 <fd2data>
  8011d2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011dc:	eb 3d                	jmp    80121b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011de:	85 db                	test   %ebx,%ebx
  8011e0:	74 04                	je     8011e6 <devpipe_read+0x26>
				return i;
  8011e2:	89 d8                	mov    %ebx,%eax
  8011e4:	eb 44                	jmp    80122a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011e6:	89 f2                	mov    %esi,%edx
  8011e8:	89 f8                	mov    %edi,%eax
  8011ea:	e8 e5 fe ff ff       	call   8010d4 <_pipeisclosed>
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	75 32                	jne    801225 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011f3:	e8 4c ef ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011f8:	8b 06                	mov    (%esi),%eax
  8011fa:	3b 46 04             	cmp    0x4(%esi),%eax
  8011fd:	74 df                	je     8011de <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ff:	99                   	cltd   
  801200:	c1 ea 1b             	shr    $0x1b,%edx
  801203:	01 d0                	add    %edx,%eax
  801205:	83 e0 1f             	and    $0x1f,%eax
  801208:	29 d0                	sub    %edx,%eax
  80120a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80120f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801212:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801215:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801218:	83 c3 01             	add    $0x1,%ebx
  80121b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80121e:	75 d8                	jne    8011f8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801220:	8b 45 10             	mov    0x10(%ebp),%eax
  801223:	eb 05                	jmp    80122a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80122a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	56                   	push   %esi
  801236:	53                   	push   %ebx
  801237:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80123a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123d:	50                   	push   %eax
  80123e:	e8 db f1 ff ff       	call   80041e <fd_alloc>
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	89 c2                	mov    %eax,%edx
  801248:	85 c0                	test   %eax,%eax
  80124a:	0f 88 2c 01 00 00    	js     80137c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	68 07 04 00 00       	push   $0x407
  801258:	ff 75 f4             	pushl  -0xc(%ebp)
  80125b:	6a 00                	push   $0x0
  80125d:	e8 01 ef ff ff       	call   800163 <sys_page_alloc>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	89 c2                	mov    %eax,%edx
  801267:	85 c0                	test   %eax,%eax
  801269:	0f 88 0d 01 00 00    	js     80137c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80126f:	83 ec 0c             	sub    $0xc,%esp
  801272:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801275:	50                   	push   %eax
  801276:	e8 a3 f1 ff ff       	call   80041e <fd_alloc>
  80127b:	89 c3                	mov    %eax,%ebx
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	85 c0                	test   %eax,%eax
  801282:	0f 88 e2 00 00 00    	js     80136a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801288:	83 ec 04             	sub    $0x4,%esp
  80128b:	68 07 04 00 00       	push   $0x407
  801290:	ff 75 f0             	pushl  -0x10(%ebp)
  801293:	6a 00                	push   $0x0
  801295:	e8 c9 ee ff ff       	call   800163 <sys_page_alloc>
  80129a:	89 c3                	mov    %eax,%ebx
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	0f 88 c3 00 00 00    	js     80136a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012a7:	83 ec 0c             	sub    $0xc,%esp
  8012aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ad:	e8 55 f1 ff ff       	call   800407 <fd2data>
  8012b2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012b4:	83 c4 0c             	add    $0xc,%esp
  8012b7:	68 07 04 00 00       	push   $0x407
  8012bc:	50                   	push   %eax
  8012bd:	6a 00                	push   $0x0
  8012bf:	e8 9f ee ff ff       	call   800163 <sys_page_alloc>
  8012c4:	89 c3                	mov    %eax,%ebx
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	0f 88 89 00 00 00    	js     80135a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d7:	e8 2b f1 ff ff       	call   800407 <fd2data>
  8012dc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012e3:	50                   	push   %eax
  8012e4:	6a 00                	push   $0x0
  8012e6:	56                   	push   %esi
  8012e7:	6a 00                	push   $0x0
  8012e9:	e8 b8 ee ff ff       	call   8001a6 <sys_page_map>
  8012ee:	89 c3                	mov    %eax,%ebx
  8012f0:	83 c4 20             	add    $0x20,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 55                	js     80134c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012f7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801300:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801302:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801305:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80130c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801312:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801315:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801317:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801321:	83 ec 0c             	sub    $0xc,%esp
  801324:	ff 75 f4             	pushl  -0xc(%ebp)
  801327:	e8 cb f0 ff ff       	call   8003f7 <fd2num>
  80132c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801331:	83 c4 04             	add    $0x4,%esp
  801334:	ff 75 f0             	pushl  -0x10(%ebp)
  801337:	e8 bb f0 ff ff       	call   8003f7 <fd2num>
  80133c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	ba 00 00 00 00       	mov    $0x0,%edx
  80134a:	eb 30                	jmp    80137c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	56                   	push   %esi
  801350:	6a 00                	push   $0x0
  801352:	e8 91 ee ff ff       	call   8001e8 <sys_page_unmap>
  801357:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	ff 75 f0             	pushl  -0x10(%ebp)
  801360:	6a 00                	push   $0x0
  801362:	e8 81 ee ff ff       	call   8001e8 <sys_page_unmap>
  801367:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	ff 75 f4             	pushl  -0xc(%ebp)
  801370:	6a 00                	push   $0x0
  801372:	e8 71 ee ff ff       	call   8001e8 <sys_page_unmap>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80137c:	89 d0                	mov    %edx,%eax
  80137e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	ff 75 08             	pushl  0x8(%ebp)
  801392:	e8 d6 f0 ff ff       	call   80046d <fd_lookup>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 18                	js     8013b6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a4:	e8 5e f0 ff ff       	call   800407 <fd2data>
	return _pipeisclosed(fd, p);
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ae:	e8 21 fd ff ff       	call   8010d4 <_pipeisclosed>
  8013b3:	83 c4 10             	add    $0x10,%esp
}
  8013b6:	c9                   	leave  
  8013b7:	c3                   	ret    

008013b8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013c8:	68 f3 23 80 00       	push   $0x8023f3
  8013cd:	ff 75 0c             	pushl  0xc(%ebp)
  8013d0:	e8 c4 07 00 00       	call   801b99 <strcpy>
	return 0;
}
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	57                   	push   %edi
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013e8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ed:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013f3:	eb 2d                	jmp    801422 <devcons_write+0x46>
		m = n - tot;
  8013f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013f8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013fa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013fd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801402:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801405:	83 ec 04             	sub    $0x4,%esp
  801408:	53                   	push   %ebx
  801409:	03 45 0c             	add    0xc(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	57                   	push   %edi
  80140e:	e8 18 09 00 00       	call   801d2b <memmove>
		sys_cputs(buf, m);
  801413:	83 c4 08             	add    $0x8,%esp
  801416:	53                   	push   %ebx
  801417:	57                   	push   %edi
  801418:	e8 8a ec ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80141d:	01 de                	add    %ebx,%esi
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	89 f0                	mov    %esi,%eax
  801424:	3b 75 10             	cmp    0x10(%ebp),%esi
  801427:	72 cc                	jb     8013f5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801429:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5f                   	pop    %edi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80143c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801440:	74 2a                	je     80146c <devcons_read+0x3b>
  801442:	eb 05                	jmp    801449 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801444:	e8 fb ec ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801449:	e8 77 ec ff ff       	call   8000c5 <sys_cgetc>
  80144e:	85 c0                	test   %eax,%eax
  801450:	74 f2                	je     801444 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801452:	85 c0                	test   %eax,%eax
  801454:	78 16                	js     80146c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801456:	83 f8 04             	cmp    $0x4,%eax
  801459:	74 0c                	je     801467 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80145b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80145e:	88 02                	mov    %al,(%edx)
	return 1;
  801460:	b8 01 00 00 00       	mov    $0x1,%eax
  801465:	eb 05                	jmp    80146c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801467:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801474:	8b 45 08             	mov    0x8(%ebp),%eax
  801477:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80147a:	6a 01                	push   $0x1
  80147c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	e8 22 ec ff ff       	call   8000a7 <sys_cputs>
}
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <getchar>:

int
getchar(void)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801490:	6a 01                	push   $0x1
  801492:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	6a 00                	push   $0x0
  801498:	e8 36 f2 ff ff       	call   8006d3 <read>
	if (r < 0)
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 0f                	js     8014b3 <getchar+0x29>
		return r;
	if (r < 1)
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	7e 06                	jle    8014ae <getchar+0x24>
		return -E_EOF;
	return c;
  8014a8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014ac:	eb 05                	jmp    8014b3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014ae:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014b3:	c9                   	leave  
  8014b4:	c3                   	ret    

008014b5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	ff 75 08             	pushl  0x8(%ebp)
  8014c2:	e8 a6 ef ff ff       	call   80046d <fd_lookup>
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 11                	js     8014df <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014d7:	39 10                	cmp    %edx,(%eax)
  8014d9:	0f 94 c0             	sete   %al
  8014dc:	0f b6 c0             	movzbl %al,%eax
}
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <opencons>:

int
opencons(void)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ea:	50                   	push   %eax
  8014eb:	e8 2e ef ff ff       	call   80041e <fd_alloc>
  8014f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014f3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 3e                	js     801537 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	68 07 04 00 00       	push   $0x407
  801501:	ff 75 f4             	pushl  -0xc(%ebp)
  801504:	6a 00                	push   $0x0
  801506:	e8 58 ec ff ff       	call   800163 <sys_page_alloc>
  80150b:	83 c4 10             	add    $0x10,%esp
		return r;
  80150e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801510:	85 c0                	test   %eax,%eax
  801512:	78 23                	js     801537 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801514:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80151f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801522:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801529:	83 ec 0c             	sub    $0xc,%esp
  80152c:	50                   	push   %eax
  80152d:	e8 c5 ee ff ff       	call   8003f7 <fd2num>
  801532:	89 c2                	mov    %eax,%edx
  801534:	83 c4 10             	add    $0x10,%esp
}
  801537:	89 d0                	mov    %edx,%eax
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	56                   	push   %esi
  80153f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801540:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801543:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801549:	e8 d7 eb ff ff       	call   800125 <sys_getenvid>
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	ff 75 0c             	pushl  0xc(%ebp)
  801554:	ff 75 08             	pushl  0x8(%ebp)
  801557:	56                   	push   %esi
  801558:	50                   	push   %eax
  801559:	68 00 24 80 00       	push   $0x802400
  80155e:	e8 b1 00 00 00       	call   801614 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801563:	83 c4 18             	add    $0x18,%esp
  801566:	53                   	push   %ebx
  801567:	ff 75 10             	pushl  0x10(%ebp)
  80156a:	e8 54 00 00 00       	call   8015c3 <vcprintf>
	cprintf("\n");
  80156f:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  801576:	e8 99 00 00 00       	call   801614 <cprintf>
  80157b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80157e:	cc                   	int3   
  80157f:	eb fd                	jmp    80157e <_panic+0x43>

00801581 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	53                   	push   %ebx
  801585:	83 ec 04             	sub    $0x4,%esp
  801588:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80158b:	8b 13                	mov    (%ebx),%edx
  80158d:	8d 42 01             	lea    0x1(%edx),%eax
  801590:	89 03                	mov    %eax,(%ebx)
  801592:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801595:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801599:	3d ff 00 00 00       	cmp    $0xff,%eax
  80159e:	75 1a                	jne    8015ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	68 ff 00 00 00       	push   $0xff
  8015a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8015ab:	50                   	push   %eax
  8015ac:	e8 f6 ea ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8015b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015d3:	00 00 00 
	b.cnt = 0;
  8015d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015e0:	ff 75 0c             	pushl  0xc(%ebp)
  8015e3:	ff 75 08             	pushl  0x8(%ebp)
  8015e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	68 81 15 80 00       	push   $0x801581
  8015f2:	e8 54 01 00 00       	call   80174b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015f7:	83 c4 08             	add    $0x8,%esp
  8015fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801600:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	e8 9b ea ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  80160c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80161a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80161d:	50                   	push   %eax
  80161e:	ff 75 08             	pushl  0x8(%ebp)
  801621:	e8 9d ff ff ff       	call   8015c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	57                   	push   %edi
  80162c:	56                   	push   %esi
  80162d:	53                   	push   %ebx
  80162e:	83 ec 1c             	sub    $0x1c,%esp
  801631:	89 c7                	mov    %eax,%edi
  801633:	89 d6                	mov    %edx,%esi
  801635:	8b 45 08             	mov    0x8(%ebp),%eax
  801638:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80163e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801641:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801644:	bb 00 00 00 00       	mov    $0x0,%ebx
  801649:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80164c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80164f:	39 d3                	cmp    %edx,%ebx
  801651:	72 05                	jb     801658 <printnum+0x30>
  801653:	39 45 10             	cmp    %eax,0x10(%ebp)
  801656:	77 45                	ja     80169d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	ff 75 18             	pushl  0x18(%ebp)
  80165e:	8b 45 14             	mov    0x14(%ebp),%eax
  801661:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801664:	53                   	push   %ebx
  801665:	ff 75 10             	pushl  0x10(%ebp)
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80166e:	ff 75 e0             	pushl  -0x20(%ebp)
  801671:	ff 75 dc             	pushl  -0x24(%ebp)
  801674:	ff 75 d8             	pushl  -0x28(%ebp)
  801677:	e8 94 09 00 00       	call   802010 <__udivdi3>
  80167c:	83 c4 18             	add    $0x18,%esp
  80167f:	52                   	push   %edx
  801680:	50                   	push   %eax
  801681:	89 f2                	mov    %esi,%edx
  801683:	89 f8                	mov    %edi,%eax
  801685:	e8 9e ff ff ff       	call   801628 <printnum>
  80168a:	83 c4 20             	add    $0x20,%esp
  80168d:	eb 18                	jmp    8016a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	56                   	push   %esi
  801693:	ff 75 18             	pushl  0x18(%ebp)
  801696:	ff d7                	call   *%edi
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	eb 03                	jmp    8016a0 <printnum+0x78>
  80169d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016a0:	83 eb 01             	sub    $0x1,%ebx
  8016a3:	85 db                	test   %ebx,%ebx
  8016a5:	7f e8                	jg     80168f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	56                   	push   %esi
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8016b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8016b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8016ba:	e8 81 0a 00 00       	call   802140 <__umoddi3>
  8016bf:	83 c4 14             	add    $0x14,%esp
  8016c2:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  8016c9:	50                   	push   %eax
  8016ca:	ff d7                	call   *%edi
}
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d2:	5b                   	pop    %ebx
  8016d3:	5e                   	pop    %esi
  8016d4:	5f                   	pop    %edi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016da:	83 fa 01             	cmp    $0x1,%edx
  8016dd:	7e 0e                	jle    8016ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016df:	8b 10                	mov    (%eax),%edx
  8016e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016e4:	89 08                	mov    %ecx,(%eax)
  8016e6:	8b 02                	mov    (%edx),%eax
  8016e8:	8b 52 04             	mov    0x4(%edx),%edx
  8016eb:	eb 22                	jmp    80170f <getuint+0x38>
	else if (lflag)
  8016ed:	85 d2                	test   %edx,%edx
  8016ef:	74 10                	je     801701 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016f1:	8b 10                	mov    (%eax),%edx
  8016f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016f6:	89 08                	mov    %ecx,(%eax)
  8016f8:	8b 02                	mov    (%edx),%eax
  8016fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ff:	eb 0e                	jmp    80170f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801701:	8b 10                	mov    (%eax),%edx
  801703:	8d 4a 04             	lea    0x4(%edx),%ecx
  801706:	89 08                	mov    %ecx,(%eax)
  801708:	8b 02                	mov    (%edx),%eax
  80170a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    

00801711 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801717:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80171b:	8b 10                	mov    (%eax),%edx
  80171d:	3b 50 04             	cmp    0x4(%eax),%edx
  801720:	73 0a                	jae    80172c <sprintputch+0x1b>
		*b->buf++ = ch;
  801722:	8d 4a 01             	lea    0x1(%edx),%ecx
  801725:	89 08                	mov    %ecx,(%eax)
  801727:	8b 45 08             	mov    0x8(%ebp),%eax
  80172a:	88 02                	mov    %al,(%edx)
}
  80172c:	5d                   	pop    %ebp
  80172d:	c3                   	ret    

0080172e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801734:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801737:	50                   	push   %eax
  801738:	ff 75 10             	pushl  0x10(%ebp)
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	ff 75 08             	pushl  0x8(%ebp)
  801741:	e8 05 00 00 00       	call   80174b <vprintfmt>
	va_end(ap);
}
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	57                   	push   %edi
  80174f:	56                   	push   %esi
  801750:	53                   	push   %ebx
  801751:	83 ec 2c             	sub    $0x2c,%esp
  801754:	8b 75 08             	mov    0x8(%ebp),%esi
  801757:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80175a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80175d:	eb 12                	jmp    801771 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80175f:	85 c0                	test   %eax,%eax
  801761:	0f 84 89 03 00 00    	je     801af0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	53                   	push   %ebx
  80176b:	50                   	push   %eax
  80176c:	ff d6                	call   *%esi
  80176e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801771:	83 c7 01             	add    $0x1,%edi
  801774:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801778:	83 f8 25             	cmp    $0x25,%eax
  80177b:	75 e2                	jne    80175f <vprintfmt+0x14>
  80177d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801781:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801788:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80178f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	eb 07                	jmp    8017a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a4:	8d 47 01             	lea    0x1(%edi),%eax
  8017a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017aa:	0f b6 07             	movzbl (%edi),%eax
  8017ad:	0f b6 c8             	movzbl %al,%ecx
  8017b0:	83 e8 23             	sub    $0x23,%eax
  8017b3:	3c 55                	cmp    $0x55,%al
  8017b5:	0f 87 1a 03 00 00    	ja     801ad5 <vprintfmt+0x38a>
  8017bb:	0f b6 c0             	movzbl %al,%eax
  8017be:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8017c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017cc:	eb d6                	jmp    8017a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017e6:	83 fa 09             	cmp    $0x9,%edx
  8017e9:	77 39                	ja     801824 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017ee:	eb e9                	jmp    8017d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8017f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017f9:	8b 00                	mov    (%eax),%eax
  8017fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801801:	eb 27                	jmp    80182a <vprintfmt+0xdf>
  801803:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801806:	85 c0                	test   %eax,%eax
  801808:	b9 00 00 00 00       	mov    $0x0,%ecx
  80180d:	0f 49 c8             	cmovns %eax,%ecx
  801810:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801813:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801816:	eb 8c                	jmp    8017a4 <vprintfmt+0x59>
  801818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80181b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801822:	eb 80                	jmp    8017a4 <vprintfmt+0x59>
  801824:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801827:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80182a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80182e:	0f 89 70 ff ff ff    	jns    8017a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  801834:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801837:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80183a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801841:	e9 5e ff ff ff       	jmp    8017a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801846:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801849:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80184c:	e9 53 ff ff ff       	jmp    8017a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801851:	8b 45 14             	mov    0x14(%ebp),%eax
  801854:	8d 50 04             	lea    0x4(%eax),%edx
  801857:	89 55 14             	mov    %edx,0x14(%ebp)
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	53                   	push   %ebx
  80185e:	ff 30                	pushl  (%eax)
  801860:	ff d6                	call   *%esi
			break;
  801862:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801865:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801868:	e9 04 ff ff ff       	jmp    801771 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80186d:	8b 45 14             	mov    0x14(%ebp),%eax
  801870:	8d 50 04             	lea    0x4(%eax),%edx
  801873:	89 55 14             	mov    %edx,0x14(%ebp)
  801876:	8b 00                	mov    (%eax),%eax
  801878:	99                   	cltd   
  801879:	31 d0                	xor    %edx,%eax
  80187b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80187d:	83 f8 0f             	cmp    $0xf,%eax
  801880:	7f 0b                	jg     80188d <vprintfmt+0x142>
  801882:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  801889:	85 d2                	test   %edx,%edx
  80188b:	75 18                	jne    8018a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80188d:	50                   	push   %eax
  80188e:	68 3b 24 80 00       	push   $0x80243b
  801893:	53                   	push   %ebx
  801894:	56                   	push   %esi
  801895:	e8 94 fe ff ff       	call   80172e <printfmt>
  80189a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018a0:	e9 cc fe ff ff       	jmp    801771 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018a5:	52                   	push   %edx
  8018a6:	68 81 23 80 00       	push   $0x802381
  8018ab:	53                   	push   %ebx
  8018ac:	56                   	push   %esi
  8018ad:	e8 7c fe ff ff       	call   80172e <printfmt>
  8018b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018b8:	e9 b4 fe ff ff       	jmp    801771 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c0:	8d 50 04             	lea    0x4(%eax),%edx
  8018c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018c8:	85 ff                	test   %edi,%edi
  8018ca:	b8 34 24 80 00       	mov    $0x802434,%eax
  8018cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018d6:	0f 8e 94 00 00 00    	jle    801970 <vprintfmt+0x225>
  8018dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018e0:	0f 84 98 00 00 00    	je     80197e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8018ec:	57                   	push   %edi
  8018ed:	e8 86 02 00 00       	call   801b78 <strnlen>
  8018f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018f5:	29 c1                	sub    %eax,%ecx
  8018f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801901:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801904:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801907:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801909:	eb 0f                	jmp    80191a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	53                   	push   %ebx
  80190f:	ff 75 e0             	pushl  -0x20(%ebp)
  801912:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801914:	83 ef 01             	sub    $0x1,%edi
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 ff                	test   %edi,%edi
  80191c:	7f ed                	jg     80190b <vprintfmt+0x1c0>
  80191e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801921:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801924:	85 c9                	test   %ecx,%ecx
  801926:	b8 00 00 00 00       	mov    $0x0,%eax
  80192b:	0f 49 c1             	cmovns %ecx,%eax
  80192e:	29 c1                	sub    %eax,%ecx
  801930:	89 75 08             	mov    %esi,0x8(%ebp)
  801933:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801936:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801939:	89 cb                	mov    %ecx,%ebx
  80193b:	eb 4d                	jmp    80198a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80193d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801941:	74 1b                	je     80195e <vprintfmt+0x213>
  801943:	0f be c0             	movsbl %al,%eax
  801946:	83 e8 20             	sub    $0x20,%eax
  801949:	83 f8 5e             	cmp    $0x5e,%eax
  80194c:	76 10                	jbe    80195e <vprintfmt+0x213>
					putch('?', putdat);
  80194e:	83 ec 08             	sub    $0x8,%esp
  801951:	ff 75 0c             	pushl  0xc(%ebp)
  801954:	6a 3f                	push   $0x3f
  801956:	ff 55 08             	call   *0x8(%ebp)
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	eb 0d                	jmp    80196b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	ff 75 0c             	pushl  0xc(%ebp)
  801964:	52                   	push   %edx
  801965:	ff 55 08             	call   *0x8(%ebp)
  801968:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80196b:	83 eb 01             	sub    $0x1,%ebx
  80196e:	eb 1a                	jmp    80198a <vprintfmt+0x23f>
  801970:	89 75 08             	mov    %esi,0x8(%ebp)
  801973:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801976:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801979:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80197c:	eb 0c                	jmp    80198a <vprintfmt+0x23f>
  80197e:	89 75 08             	mov    %esi,0x8(%ebp)
  801981:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801984:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801987:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80198a:	83 c7 01             	add    $0x1,%edi
  80198d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801991:	0f be d0             	movsbl %al,%edx
  801994:	85 d2                	test   %edx,%edx
  801996:	74 23                	je     8019bb <vprintfmt+0x270>
  801998:	85 f6                	test   %esi,%esi
  80199a:	78 a1                	js     80193d <vprintfmt+0x1f2>
  80199c:	83 ee 01             	sub    $0x1,%esi
  80199f:	79 9c                	jns    80193d <vprintfmt+0x1f2>
  8019a1:	89 df                	mov    %ebx,%edi
  8019a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8019a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019a9:	eb 18                	jmp    8019c3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	53                   	push   %ebx
  8019af:	6a 20                	push   $0x20
  8019b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019b3:	83 ef 01             	sub    $0x1,%edi
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	eb 08                	jmp    8019c3 <vprintfmt+0x278>
  8019bb:	89 df                	mov    %ebx,%edi
  8019bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019c3:	85 ff                	test   %edi,%edi
  8019c5:	7f e4                	jg     8019ab <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019ca:	e9 a2 fd ff ff       	jmp    801771 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019cf:	83 fa 01             	cmp    $0x1,%edx
  8019d2:	7e 16                	jle    8019ea <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d7:	8d 50 08             	lea    0x8(%eax),%edx
  8019da:	89 55 14             	mov    %edx,0x14(%ebp)
  8019dd:	8b 50 04             	mov    0x4(%eax),%edx
  8019e0:	8b 00                	mov    (%eax),%eax
  8019e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019e8:	eb 32                	jmp    801a1c <vprintfmt+0x2d1>
	else if (lflag)
  8019ea:	85 d2                	test   %edx,%edx
  8019ec:	74 18                	je     801a06 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f1:	8d 50 04             	lea    0x4(%eax),%edx
  8019f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8019f7:	8b 00                	mov    (%eax),%eax
  8019f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019fc:	89 c1                	mov    %eax,%ecx
  8019fe:	c1 f9 1f             	sar    $0x1f,%ecx
  801a01:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a04:	eb 16                	jmp    801a1c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a06:	8b 45 14             	mov    0x14(%ebp),%eax
  801a09:	8d 50 04             	lea    0x4(%eax),%edx
  801a0c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a0f:	8b 00                	mov    (%eax),%eax
  801a11:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a14:	89 c1                	mov    %eax,%ecx
  801a16:	c1 f9 1f             	sar    $0x1f,%ecx
  801a19:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a1c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a1f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a22:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a27:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a2b:	79 74                	jns    801aa1 <vprintfmt+0x356>
				putch('-', putdat);
  801a2d:	83 ec 08             	sub    $0x8,%esp
  801a30:	53                   	push   %ebx
  801a31:	6a 2d                	push   $0x2d
  801a33:	ff d6                	call   *%esi
				num = -(long long) num;
  801a35:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a38:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a3b:	f7 d8                	neg    %eax
  801a3d:	83 d2 00             	adc    $0x0,%edx
  801a40:	f7 da                	neg    %edx
  801a42:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a45:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a4a:	eb 55                	jmp    801aa1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a4c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a4f:	e8 83 fc ff ff       	call   8016d7 <getuint>
			base = 10;
  801a54:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a59:	eb 46                	jmp    801aa1 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a5b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a5e:	e8 74 fc ff ff       	call   8016d7 <getuint>
			base = 8;
  801a63:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a68:	eb 37                	jmp    801aa1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a6a:	83 ec 08             	sub    $0x8,%esp
  801a6d:	53                   	push   %ebx
  801a6e:	6a 30                	push   $0x30
  801a70:	ff d6                	call   *%esi
			putch('x', putdat);
  801a72:	83 c4 08             	add    $0x8,%esp
  801a75:	53                   	push   %ebx
  801a76:	6a 78                	push   $0x78
  801a78:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a7a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7d:	8d 50 04             	lea    0x4(%eax),%edx
  801a80:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a83:	8b 00                	mov    (%eax),%eax
  801a85:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a8a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a8d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a92:	eb 0d                	jmp    801aa1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a94:	8d 45 14             	lea    0x14(%ebp),%eax
  801a97:	e8 3b fc ff ff       	call   8016d7 <getuint>
			base = 16;
  801a9c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801aa8:	57                   	push   %edi
  801aa9:	ff 75 e0             	pushl  -0x20(%ebp)
  801aac:	51                   	push   %ecx
  801aad:	52                   	push   %edx
  801aae:	50                   	push   %eax
  801aaf:	89 da                	mov    %ebx,%edx
  801ab1:	89 f0                	mov    %esi,%eax
  801ab3:	e8 70 fb ff ff       	call   801628 <printnum>
			break;
  801ab8:	83 c4 20             	add    $0x20,%esp
  801abb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801abe:	e9 ae fc ff ff       	jmp    801771 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ac3:	83 ec 08             	sub    $0x8,%esp
  801ac6:	53                   	push   %ebx
  801ac7:	51                   	push   %ecx
  801ac8:	ff d6                	call   *%esi
			break;
  801aca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801acd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ad0:	e9 9c fc ff ff       	jmp    801771 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ad5:	83 ec 08             	sub    $0x8,%esp
  801ad8:	53                   	push   %ebx
  801ad9:	6a 25                	push   $0x25
  801adb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	eb 03                	jmp    801ae5 <vprintfmt+0x39a>
  801ae2:	83 ef 01             	sub    $0x1,%edi
  801ae5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ae9:	75 f7                	jne    801ae2 <vprintfmt+0x397>
  801aeb:	e9 81 fc ff ff       	jmp    801771 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801af0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af3:	5b                   	pop    %ebx
  801af4:	5e                   	pop    %esi
  801af5:	5f                   	pop    %edi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	83 ec 18             	sub    $0x18,%esp
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b04:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b07:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b0b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b15:	85 c0                	test   %eax,%eax
  801b17:	74 26                	je     801b3f <vsnprintf+0x47>
  801b19:	85 d2                	test   %edx,%edx
  801b1b:	7e 22                	jle    801b3f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b1d:	ff 75 14             	pushl  0x14(%ebp)
  801b20:	ff 75 10             	pushl  0x10(%ebp)
  801b23:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b26:	50                   	push   %eax
  801b27:	68 11 17 80 00       	push   $0x801711
  801b2c:	e8 1a fc ff ff       	call   80174b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b34:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	eb 05                	jmp    801b44 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b4c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b4f:	50                   	push   %eax
  801b50:	ff 75 10             	pushl  0x10(%ebp)
  801b53:	ff 75 0c             	pushl  0xc(%ebp)
  801b56:	ff 75 08             	pushl  0x8(%ebp)
  801b59:	e8 9a ff ff ff       	call   801af8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6b:	eb 03                	jmp    801b70 <strlen+0x10>
		n++;
  801b6d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b74:	75 f7                	jne    801b6d <strlen+0xd>
		n++;
	return n;
}
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b81:	ba 00 00 00 00       	mov    $0x0,%edx
  801b86:	eb 03                	jmp    801b8b <strnlen+0x13>
		n++;
  801b88:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b8b:	39 c2                	cmp    %eax,%edx
  801b8d:	74 08                	je     801b97 <strnlen+0x1f>
  801b8f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b93:	75 f3                	jne    801b88 <strnlen+0x10>
  801b95:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b97:	5d                   	pop    %ebp
  801b98:	c3                   	ret    

00801b99 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	53                   	push   %ebx
  801b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ba3:	89 c2                	mov    %eax,%edx
  801ba5:	83 c2 01             	add    $0x1,%edx
  801ba8:	83 c1 01             	add    $0x1,%ecx
  801bab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801baf:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bb2:	84 db                	test   %bl,%bl
  801bb4:	75 ef                	jne    801ba5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bb6:	5b                   	pop    %ebx
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    

00801bb9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	53                   	push   %ebx
  801bbd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bc0:	53                   	push   %ebx
  801bc1:	e8 9a ff ff ff       	call   801b60 <strlen>
  801bc6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bc9:	ff 75 0c             	pushl  0xc(%ebp)
  801bcc:	01 d8                	add    %ebx,%eax
  801bce:	50                   	push   %eax
  801bcf:	e8 c5 ff ff ff       	call   801b99 <strcpy>
	return dst;
}
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	8b 75 08             	mov    0x8(%ebp),%esi
  801be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be6:	89 f3                	mov    %esi,%ebx
  801be8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801beb:	89 f2                	mov    %esi,%edx
  801bed:	eb 0f                	jmp    801bfe <strncpy+0x23>
		*dst++ = *src;
  801bef:	83 c2 01             	add    $0x1,%edx
  801bf2:	0f b6 01             	movzbl (%ecx),%eax
  801bf5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bf8:	80 39 01             	cmpb   $0x1,(%ecx)
  801bfb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bfe:	39 da                	cmp    %ebx,%edx
  801c00:	75 ed                	jne    801bef <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c02:	89 f0                	mov    %esi,%eax
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c13:	8b 55 10             	mov    0x10(%ebp),%edx
  801c16:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c18:	85 d2                	test   %edx,%edx
  801c1a:	74 21                	je     801c3d <strlcpy+0x35>
  801c1c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c20:	89 f2                	mov    %esi,%edx
  801c22:	eb 09                	jmp    801c2d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c24:	83 c2 01             	add    $0x1,%edx
  801c27:	83 c1 01             	add    $0x1,%ecx
  801c2a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c2d:	39 c2                	cmp    %eax,%edx
  801c2f:	74 09                	je     801c3a <strlcpy+0x32>
  801c31:	0f b6 19             	movzbl (%ecx),%ebx
  801c34:	84 db                	test   %bl,%bl
  801c36:	75 ec                	jne    801c24 <strlcpy+0x1c>
  801c38:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c3a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c3d:	29 f0                	sub    %esi,%eax
}
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c49:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c4c:	eb 06                	jmp    801c54 <strcmp+0x11>
		p++, q++;
  801c4e:	83 c1 01             	add    $0x1,%ecx
  801c51:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c54:	0f b6 01             	movzbl (%ecx),%eax
  801c57:	84 c0                	test   %al,%al
  801c59:	74 04                	je     801c5f <strcmp+0x1c>
  801c5b:	3a 02                	cmp    (%edx),%al
  801c5d:	74 ef                	je     801c4e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c5f:	0f b6 c0             	movzbl %al,%eax
  801c62:	0f b6 12             	movzbl (%edx),%edx
  801c65:	29 d0                	sub    %edx,%eax
}
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	53                   	push   %ebx
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c70:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c73:	89 c3                	mov    %eax,%ebx
  801c75:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c78:	eb 06                	jmp    801c80 <strncmp+0x17>
		n--, p++, q++;
  801c7a:	83 c0 01             	add    $0x1,%eax
  801c7d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c80:	39 d8                	cmp    %ebx,%eax
  801c82:	74 15                	je     801c99 <strncmp+0x30>
  801c84:	0f b6 08             	movzbl (%eax),%ecx
  801c87:	84 c9                	test   %cl,%cl
  801c89:	74 04                	je     801c8f <strncmp+0x26>
  801c8b:	3a 0a                	cmp    (%edx),%cl
  801c8d:	74 eb                	je     801c7a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c8f:	0f b6 00             	movzbl (%eax),%eax
  801c92:	0f b6 12             	movzbl (%edx),%edx
  801c95:	29 d0                	sub    %edx,%eax
  801c97:	eb 05                	jmp    801c9e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c99:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c9e:	5b                   	pop    %ebx
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cab:	eb 07                	jmp    801cb4 <strchr+0x13>
		if (*s == c)
  801cad:	38 ca                	cmp    %cl,%dl
  801caf:	74 0f                	je     801cc0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cb1:	83 c0 01             	add    $0x1,%eax
  801cb4:	0f b6 10             	movzbl (%eax),%edx
  801cb7:	84 d2                	test   %dl,%dl
  801cb9:	75 f2                	jne    801cad <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ccc:	eb 03                	jmp    801cd1 <strfind+0xf>
  801cce:	83 c0 01             	add    $0x1,%eax
  801cd1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cd4:	38 ca                	cmp    %cl,%dl
  801cd6:	74 04                	je     801cdc <strfind+0x1a>
  801cd8:	84 d2                	test   %dl,%dl
  801cda:	75 f2                	jne    801cce <strfind+0xc>
			break;
	return (char *) s;
}
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ce7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cea:	85 c9                	test   %ecx,%ecx
  801cec:	74 36                	je     801d24 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cf4:	75 28                	jne    801d1e <memset+0x40>
  801cf6:	f6 c1 03             	test   $0x3,%cl
  801cf9:	75 23                	jne    801d1e <memset+0x40>
		c &= 0xFF;
  801cfb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cff:	89 d3                	mov    %edx,%ebx
  801d01:	c1 e3 08             	shl    $0x8,%ebx
  801d04:	89 d6                	mov    %edx,%esi
  801d06:	c1 e6 18             	shl    $0x18,%esi
  801d09:	89 d0                	mov    %edx,%eax
  801d0b:	c1 e0 10             	shl    $0x10,%eax
  801d0e:	09 f0                	or     %esi,%eax
  801d10:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d12:	89 d8                	mov    %ebx,%eax
  801d14:	09 d0                	or     %edx,%eax
  801d16:	c1 e9 02             	shr    $0x2,%ecx
  801d19:	fc                   	cld    
  801d1a:	f3 ab                	rep stos %eax,%es:(%edi)
  801d1c:	eb 06                	jmp    801d24 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d21:	fc                   	cld    
  801d22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d24:	89 f8                	mov    %edi,%eax
  801d26:	5b                   	pop    %ebx
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	57                   	push   %edi
  801d2f:	56                   	push   %esi
  801d30:	8b 45 08             	mov    0x8(%ebp),%eax
  801d33:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d39:	39 c6                	cmp    %eax,%esi
  801d3b:	73 35                	jae    801d72 <memmove+0x47>
  801d3d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d40:	39 d0                	cmp    %edx,%eax
  801d42:	73 2e                	jae    801d72 <memmove+0x47>
		s += n;
		d += n;
  801d44:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d47:	89 d6                	mov    %edx,%esi
  801d49:	09 fe                	or     %edi,%esi
  801d4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d51:	75 13                	jne    801d66 <memmove+0x3b>
  801d53:	f6 c1 03             	test   $0x3,%cl
  801d56:	75 0e                	jne    801d66 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d58:	83 ef 04             	sub    $0x4,%edi
  801d5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d5e:	c1 e9 02             	shr    $0x2,%ecx
  801d61:	fd                   	std    
  801d62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d64:	eb 09                	jmp    801d6f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d66:	83 ef 01             	sub    $0x1,%edi
  801d69:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d6c:	fd                   	std    
  801d6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d6f:	fc                   	cld    
  801d70:	eb 1d                	jmp    801d8f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	09 c2                	or     %eax,%edx
  801d76:	f6 c2 03             	test   $0x3,%dl
  801d79:	75 0f                	jne    801d8a <memmove+0x5f>
  801d7b:	f6 c1 03             	test   $0x3,%cl
  801d7e:	75 0a                	jne    801d8a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d80:	c1 e9 02             	shr    $0x2,%ecx
  801d83:	89 c7                	mov    %eax,%edi
  801d85:	fc                   	cld    
  801d86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d88:	eb 05                	jmp    801d8f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d8a:	89 c7                	mov    %eax,%edi
  801d8c:	fc                   	cld    
  801d8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d96:	ff 75 10             	pushl  0x10(%ebp)
  801d99:	ff 75 0c             	pushl  0xc(%ebp)
  801d9c:	ff 75 08             	pushl  0x8(%ebp)
  801d9f:	e8 87 ff ff ff       	call   801d2b <memmove>
}
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	56                   	push   %esi
  801daa:	53                   	push   %ebx
  801dab:	8b 45 08             	mov    0x8(%ebp),%eax
  801dae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db1:	89 c6                	mov    %eax,%esi
  801db3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801db6:	eb 1a                	jmp    801dd2 <memcmp+0x2c>
		if (*s1 != *s2)
  801db8:	0f b6 08             	movzbl (%eax),%ecx
  801dbb:	0f b6 1a             	movzbl (%edx),%ebx
  801dbe:	38 d9                	cmp    %bl,%cl
  801dc0:	74 0a                	je     801dcc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801dc2:	0f b6 c1             	movzbl %cl,%eax
  801dc5:	0f b6 db             	movzbl %bl,%ebx
  801dc8:	29 d8                	sub    %ebx,%eax
  801dca:	eb 0f                	jmp    801ddb <memcmp+0x35>
		s1++, s2++;
  801dcc:	83 c0 01             	add    $0x1,%eax
  801dcf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dd2:	39 f0                	cmp    %esi,%eax
  801dd4:	75 e2                	jne    801db8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    

00801ddf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	53                   	push   %ebx
  801de3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801de6:	89 c1                	mov    %eax,%ecx
  801de8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801deb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801def:	eb 0a                	jmp    801dfb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801df1:	0f b6 10             	movzbl (%eax),%edx
  801df4:	39 da                	cmp    %ebx,%edx
  801df6:	74 07                	je     801dff <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801df8:	83 c0 01             	add    $0x1,%eax
  801dfb:	39 c8                	cmp    %ecx,%eax
  801dfd:	72 f2                	jb     801df1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dff:	5b                   	pop    %ebx
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	57                   	push   %edi
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e0e:	eb 03                	jmp    801e13 <strtol+0x11>
		s++;
  801e10:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e13:	0f b6 01             	movzbl (%ecx),%eax
  801e16:	3c 20                	cmp    $0x20,%al
  801e18:	74 f6                	je     801e10 <strtol+0xe>
  801e1a:	3c 09                	cmp    $0x9,%al
  801e1c:	74 f2                	je     801e10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e1e:	3c 2b                	cmp    $0x2b,%al
  801e20:	75 0a                	jne    801e2c <strtol+0x2a>
		s++;
  801e22:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e25:	bf 00 00 00 00       	mov    $0x0,%edi
  801e2a:	eb 11                	jmp    801e3d <strtol+0x3b>
  801e2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e31:	3c 2d                	cmp    $0x2d,%al
  801e33:	75 08                	jne    801e3d <strtol+0x3b>
		s++, neg = 1;
  801e35:	83 c1 01             	add    $0x1,%ecx
  801e38:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e43:	75 15                	jne    801e5a <strtol+0x58>
  801e45:	80 39 30             	cmpb   $0x30,(%ecx)
  801e48:	75 10                	jne    801e5a <strtol+0x58>
  801e4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e4e:	75 7c                	jne    801ecc <strtol+0xca>
		s += 2, base = 16;
  801e50:	83 c1 02             	add    $0x2,%ecx
  801e53:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e58:	eb 16                	jmp    801e70 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e5a:	85 db                	test   %ebx,%ebx
  801e5c:	75 12                	jne    801e70 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e63:	80 39 30             	cmpb   $0x30,(%ecx)
  801e66:	75 08                	jne    801e70 <strtol+0x6e>
		s++, base = 8;
  801e68:	83 c1 01             	add    $0x1,%ecx
  801e6b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e70:	b8 00 00 00 00       	mov    $0x0,%eax
  801e75:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e78:	0f b6 11             	movzbl (%ecx),%edx
  801e7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e7e:	89 f3                	mov    %esi,%ebx
  801e80:	80 fb 09             	cmp    $0x9,%bl
  801e83:	77 08                	ja     801e8d <strtol+0x8b>
			dig = *s - '0';
  801e85:	0f be d2             	movsbl %dl,%edx
  801e88:	83 ea 30             	sub    $0x30,%edx
  801e8b:	eb 22                	jmp    801eaf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e90:	89 f3                	mov    %esi,%ebx
  801e92:	80 fb 19             	cmp    $0x19,%bl
  801e95:	77 08                	ja     801e9f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e97:	0f be d2             	movsbl %dl,%edx
  801e9a:	83 ea 57             	sub    $0x57,%edx
  801e9d:	eb 10                	jmp    801eaf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ea2:	89 f3                	mov    %esi,%ebx
  801ea4:	80 fb 19             	cmp    $0x19,%bl
  801ea7:	77 16                	ja     801ebf <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ea9:	0f be d2             	movsbl %dl,%edx
  801eac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801eaf:	3b 55 10             	cmp    0x10(%ebp),%edx
  801eb2:	7d 0b                	jge    801ebf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801eb4:	83 c1 01             	add    $0x1,%ecx
  801eb7:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ebb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ebd:	eb b9                	jmp    801e78 <strtol+0x76>

	if (endptr)
  801ebf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ec3:	74 0d                	je     801ed2 <strtol+0xd0>
		*endptr = (char *) s;
  801ec5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec8:	89 0e                	mov    %ecx,(%esi)
  801eca:	eb 06                	jmp    801ed2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ecc:	85 db                	test   %ebx,%ebx
  801ece:	74 98                	je     801e68 <strtol+0x66>
  801ed0:	eb 9e                	jmp    801e70 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ed2:	89 c2                	mov    %eax,%edx
  801ed4:	f7 da                	neg    %edx
  801ed6:	85 ff                	test   %edi,%edi
  801ed8:	0f 45 c2             	cmovne %edx,%eax
}
  801edb:	5b                   	pop    %ebx
  801edc:	5e                   	pop    %esi
  801edd:	5f                   	pop    %edi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    

00801ee0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	56                   	push   %esi
  801ee4:	53                   	push   %ebx
  801ee5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801eee:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ef0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ef5:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ef8:	83 ec 0c             	sub    $0xc,%esp
  801efb:	50                   	push   %eax
  801efc:	e8 12 e4 ff ff       	call   800313 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	85 f6                	test   %esi,%esi
  801f06:	74 14                	je     801f1c <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f08:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	78 09                	js     801f1a <ipc_recv+0x3a>
  801f11:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f17:	8b 52 74             	mov    0x74(%edx),%edx
  801f1a:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f1c:	85 db                	test   %ebx,%ebx
  801f1e:	74 14                	je     801f34 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f20:	ba 00 00 00 00       	mov    $0x0,%edx
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 09                	js     801f32 <ipc_recv+0x52>
  801f29:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f2f:	8b 52 78             	mov    0x78(%edx),%edx
  801f32:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f34:	85 c0                	test   %eax,%eax
  801f36:	78 08                	js     801f40 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f38:	a1 08 40 80 00       	mov    0x804008,%eax
  801f3d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    

00801f47 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	57                   	push   %edi
  801f4b:	56                   	push   %esi
  801f4c:	53                   	push   %ebx
  801f4d:	83 ec 0c             	sub    $0xc,%esp
  801f50:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f53:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f59:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f5b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f60:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f63:	ff 75 14             	pushl  0x14(%ebp)
  801f66:	53                   	push   %ebx
  801f67:	56                   	push   %esi
  801f68:	57                   	push   %edi
  801f69:	e8 82 e3 ff ff       	call   8002f0 <sys_ipc_try_send>

		if (err < 0) {
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	85 c0                	test   %eax,%eax
  801f73:	79 1e                	jns    801f93 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f75:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f78:	75 07                	jne    801f81 <ipc_send+0x3a>
				sys_yield();
  801f7a:	e8 c5 e1 ff ff       	call   800144 <sys_yield>
  801f7f:	eb e2                	jmp    801f63 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f81:	50                   	push   %eax
  801f82:	68 20 27 80 00       	push   $0x802720
  801f87:	6a 49                	push   $0x49
  801f89:	68 2d 27 80 00       	push   $0x80272d
  801f8e:	e8 a8 f5 ff ff       	call   80153b <_panic>
		}

	} while (err < 0);

}
  801f93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f96:	5b                   	pop    %ebx
  801f97:	5e                   	pop    %esi
  801f98:	5f                   	pop    %edi
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    

00801f9b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fa9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801faf:	8b 52 50             	mov    0x50(%edx),%edx
  801fb2:	39 ca                	cmp    %ecx,%edx
  801fb4:	75 0d                	jne    801fc3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fb6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fb9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fbe:	8b 40 48             	mov    0x48(%eax),%eax
  801fc1:	eb 0f                	jmp    801fd2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fc3:	83 c0 01             	add    $0x1,%eax
  801fc6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fcb:	75 d9                	jne    801fa6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    

00801fd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fda:	89 d0                	mov    %edx,%eax
  801fdc:	c1 e8 16             	shr    $0x16,%eax
  801fdf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fe6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801feb:	f6 c1 01             	test   $0x1,%cl
  801fee:	74 1d                	je     80200d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ff0:	c1 ea 0c             	shr    $0xc,%edx
  801ff3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ffa:	f6 c2 01             	test   $0x1,%dl
  801ffd:	74 0e                	je     80200d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fff:	c1 ea 0c             	shr    $0xc,%edx
  802002:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802009:	ef 
  80200a:	0f b7 c0             	movzwl %ax,%eax
}
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    
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
