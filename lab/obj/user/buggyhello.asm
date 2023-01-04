
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
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800093:	e8 87 04 00 00       	call   80051f <close_all>
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
  80010c:	68 aa 1d 80 00       	push   $0x801daa
  800111:	6a 23                	push   $0x23
  800113:	68 c7 1d 80 00       	push   $0x801dc7
  800118:	e8 14 0f 00 00       	call   801031 <_panic>

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
  80018d:	68 aa 1d 80 00       	push   $0x801daa
  800192:	6a 23                	push   $0x23
  800194:	68 c7 1d 80 00       	push   $0x801dc7
  800199:	e8 93 0e 00 00       	call   801031 <_panic>

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
  8001cf:	68 aa 1d 80 00       	push   $0x801daa
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 c7 1d 80 00       	push   $0x801dc7
  8001db:	e8 51 0e 00 00       	call   801031 <_panic>

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
  800211:	68 aa 1d 80 00       	push   $0x801daa
  800216:	6a 23                	push   $0x23
  800218:	68 c7 1d 80 00       	push   $0x801dc7
  80021d:	e8 0f 0e 00 00       	call   801031 <_panic>

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
  800253:	68 aa 1d 80 00       	push   $0x801daa
  800258:	6a 23                	push   $0x23
  80025a:	68 c7 1d 80 00       	push   $0x801dc7
  80025f:	e8 cd 0d 00 00       	call   801031 <_panic>

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
  800295:	68 aa 1d 80 00       	push   $0x801daa
  80029a:	6a 23                	push   $0x23
  80029c:	68 c7 1d 80 00       	push   $0x801dc7
  8002a1:	e8 8b 0d 00 00       	call   801031 <_panic>

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
  8002d7:	68 aa 1d 80 00       	push   $0x801daa
  8002dc:	6a 23                	push   $0x23
  8002de:	68 c7 1d 80 00       	push   $0x801dc7
  8002e3:	e8 49 0d 00 00       	call   801031 <_panic>

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
  80033b:	68 aa 1d 80 00       	push   $0x801daa
  800340:	6a 23                	push   $0x23
  800342:	68 c7 1d 80 00       	push   $0x801dc7
  800347:	e8 e5 0c 00 00       	call   801031 <_panic>

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

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba 54 1e 80 00       	mov    $0x801e54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 d8 1d 80 00       	push   $0x801dd8
  80045b:	e8 aa 0c 00 00       	call   80110a <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 04 40 80 00       	mov    0x804004,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 19 1e 80 00       	push   $0x801e19
  800685:	e8 80 0a 00 00       	call   80110a <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 35 1e 80 00       	push   $0x801e35
  80075a:	e8 ab 09 00 00       	call   80110a <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 f8 1d 80 00       	push   $0x801df8
  80080f:	e8 f6 08 00 00       	call   80110a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 d6 01 00 00       	call   800aae <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 72 11 00 00       	call   801a91 <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 03 11 00 00       	call   801a3d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 8f 10 00 00       	call   8019d6 <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 bf 0c 00 00       	call   80168f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 0c             	sub    $0xc,%esp
  8009f9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ff:	8b 52 0c             	mov    0xc(%edx),%edx
  800a02:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a08:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a0d:	50                   	push   %eax
  800a0e:	ff 75 0c             	pushl  0xc(%ebp)
  800a11:	68 08 50 80 00       	push   $0x805008
  800a16:	e8 06 0e 00 00       	call   801821 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	b8 04 00 00 00       	mov    $0x4,%eax
  800a25:	e8 d9 fe ff ff       	call   800903 <fsipc>

}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4f:	e8 af fe ff ff       	call   800903 <fsipc>
  800a54:	89 c3                	mov    %eax,%ebx
  800a56:	85 c0                	test   %eax,%eax
  800a58:	78 4b                	js     800aa5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a5a:	39 c6                	cmp    %eax,%esi
  800a5c:	73 16                	jae    800a74 <devfile_read+0x48>
  800a5e:	68 64 1e 80 00       	push   $0x801e64
  800a63:	68 6b 1e 80 00       	push   $0x801e6b
  800a68:	6a 7c                	push   $0x7c
  800a6a:	68 80 1e 80 00       	push   $0x801e80
  800a6f:	e8 bd 05 00 00       	call   801031 <_panic>
	assert(r <= PGSIZE);
  800a74:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a79:	7e 16                	jle    800a91 <devfile_read+0x65>
  800a7b:	68 8b 1e 80 00       	push   $0x801e8b
  800a80:	68 6b 1e 80 00       	push   $0x801e6b
  800a85:	6a 7d                	push   $0x7d
  800a87:	68 80 1e 80 00       	push   $0x801e80
  800a8c:	e8 a0 05 00 00       	call   801031 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a91:	83 ec 04             	sub    $0x4,%esp
  800a94:	50                   	push   %eax
  800a95:	68 00 50 80 00       	push   $0x805000
  800a9a:	ff 75 0c             	pushl  0xc(%ebp)
  800a9d:	e8 7f 0d 00 00       	call   801821 <memmove>
	return r;
  800aa2:	83 c4 10             	add    $0x10,%esp
}
  800aa5:	89 d8                	mov    %ebx,%eax
  800aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	53                   	push   %ebx
  800ab2:	83 ec 20             	sub    $0x20,%esp
  800ab5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab8:	53                   	push   %ebx
  800ab9:	e8 98 0b 00 00       	call   801656 <strlen>
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac6:	7f 67                	jg     800b2f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac8:	83 ec 0c             	sub    $0xc,%esp
  800acb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ace:	50                   	push   %eax
  800acf:	e8 a7 f8 ff ff       	call   80037b <fd_alloc>
  800ad4:	83 c4 10             	add    $0x10,%esp
		return r;
  800ad7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	78 57                	js     800b34 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800add:	83 ec 08             	sub    $0x8,%esp
  800ae0:	53                   	push   %ebx
  800ae1:	68 00 50 80 00       	push   $0x805000
  800ae6:	e8 a4 0b 00 00       	call   80168f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aee:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af6:	b8 01 00 00 00       	mov    $0x1,%eax
  800afb:	e8 03 fe ff ff       	call   800903 <fsipc>
  800b00:	89 c3                	mov    %eax,%ebx
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	85 c0                	test   %eax,%eax
  800b07:	79 14                	jns    800b1d <open+0x6f>
		fd_close(fd, 0);
  800b09:	83 ec 08             	sub    $0x8,%esp
  800b0c:	6a 00                	push   $0x0
  800b0e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b11:	e8 5d f9 ff ff       	call   800473 <fd_close>
		return r;
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	89 da                	mov    %ebx,%edx
  800b1b:	eb 17                	jmp    800b34 <open+0x86>
	}

	return fd2num(fd);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	ff 75 f4             	pushl  -0xc(%ebp)
  800b23:	e8 2c f8 ff ff       	call   800354 <fd2num>
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	eb 05                	jmp    800b34 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b2f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b34:	89 d0                	mov    %edx,%eax
  800b36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4b:	e8 b3 fd ff ff       	call   800903 <fsipc>
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	ff 75 08             	pushl  0x8(%ebp)
  800b60:	e8 ff f7 ff ff       	call   800364 <fd2data>
  800b65:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b67:	83 c4 08             	add    $0x8,%esp
  800b6a:	68 97 1e 80 00       	push   $0x801e97
  800b6f:	53                   	push   %ebx
  800b70:	e8 1a 0b 00 00       	call   80168f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b75:	8b 46 04             	mov    0x4(%esi),%eax
  800b78:	2b 06                	sub    (%esi),%eax
  800b7a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b80:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b87:	00 00 00 
	stat->st_dev = &devpipe;
  800b8a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b91:	30 80 00 
	return 0;
}
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
  800b99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800baa:	53                   	push   %ebx
  800bab:	6a 00                	push   $0x0
  800bad:	e8 36 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb2:	89 1c 24             	mov    %ebx,(%esp)
  800bb5:	e8 aa f7 ff ff       	call   800364 <fd2data>
  800bba:	83 c4 08             	add    $0x8,%esp
  800bbd:	50                   	push   %eax
  800bbe:	6a 00                	push   $0x0
  800bc0:	e8 23 f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
  800bd0:	83 ec 1c             	sub    $0x1c,%esp
  800bd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bd8:	a1 04 40 80 00       	mov    0x804004,%eax
  800bdd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	ff 75 e0             	pushl  -0x20(%ebp)
  800be6:	e8 df 0e 00 00       	call   801aca <pageref>
  800beb:	89 c3                	mov    %eax,%ebx
  800bed:	89 3c 24             	mov    %edi,(%esp)
  800bf0:	e8 d5 0e 00 00       	call   801aca <pageref>
  800bf5:	83 c4 10             	add    $0x10,%esp
  800bf8:	39 c3                	cmp    %eax,%ebx
  800bfa:	0f 94 c1             	sete   %cl
  800bfd:	0f b6 c9             	movzbl %cl,%ecx
  800c00:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c03:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c09:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0c:	39 ce                	cmp    %ecx,%esi
  800c0e:	74 1b                	je     800c2b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c10:	39 c3                	cmp    %eax,%ebx
  800c12:	75 c4                	jne    800bd8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c14:	8b 42 58             	mov    0x58(%edx),%eax
  800c17:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c1a:	50                   	push   %eax
  800c1b:	56                   	push   %esi
  800c1c:	68 9e 1e 80 00       	push   $0x801e9e
  800c21:	e8 e4 04 00 00       	call   80110a <cprintf>
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	eb ad                	jmp    800bd8 <_pipeisclosed+0xe>
	}
}
  800c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 28             	sub    $0x28,%esp
  800c3f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c42:	56                   	push   %esi
  800c43:	e8 1c f7 ff ff       	call   800364 <fd2data>
  800c48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c52:	eb 4b                	jmp    800c9f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c54:	89 da                	mov    %ebx,%edx
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	e8 6d ff ff ff       	call   800bca <_pipeisclosed>
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	75 48                	jne    800ca9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c61:	e8 de f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c66:	8b 43 04             	mov    0x4(%ebx),%eax
  800c69:	8b 0b                	mov    (%ebx),%ecx
  800c6b:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6e:	39 d0                	cmp    %edx,%eax
  800c70:	73 e2                	jae    800c54 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c79:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7c:	89 c2                	mov    %eax,%edx
  800c7e:	c1 fa 1f             	sar    $0x1f,%edx
  800c81:	89 d1                	mov    %edx,%ecx
  800c83:	c1 e9 1b             	shr    $0x1b,%ecx
  800c86:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c89:	83 e2 1f             	and    $0x1f,%edx
  800c8c:	29 ca                	sub    %ecx,%edx
  800c8e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c92:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c96:	83 c0 01             	add    $0x1,%eax
  800c99:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9c:	83 c7 01             	add    $0x1,%edi
  800c9f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca2:	75 c2                	jne    800c66 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca7:	eb 05                	jmp    800cae <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 18             	sub    $0x18,%esp
  800cbf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc2:	57                   	push   %edi
  800cc3:	e8 9c f6 ff ff       	call   800364 <fd2data>
  800cc8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cca:	83 c4 10             	add    $0x10,%esp
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	eb 3d                	jmp    800d11 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd4:	85 db                	test   %ebx,%ebx
  800cd6:	74 04                	je     800cdc <devpipe_read+0x26>
				return i;
  800cd8:	89 d8                	mov    %ebx,%eax
  800cda:	eb 44                	jmp    800d20 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cdc:	89 f2                	mov    %esi,%edx
  800cde:	89 f8                	mov    %edi,%eax
  800ce0:	e8 e5 fe ff ff       	call   800bca <_pipeisclosed>
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	75 32                	jne    800d1b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce9:	e8 56 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cee:	8b 06                	mov    (%esi),%eax
  800cf0:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf3:	74 df                	je     800cd4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf5:	99                   	cltd   
  800cf6:	c1 ea 1b             	shr    $0x1b,%edx
  800cf9:	01 d0                	add    %edx,%eax
  800cfb:	83 e0 1f             	and    $0x1f,%eax
  800cfe:	29 d0                	sub    %edx,%eax
  800d00:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d0b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0e:	83 c3 01             	add    $0x1,%ebx
  800d11:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d14:	75 d8                	jne    800cee <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d16:	8b 45 10             	mov    0x10(%ebp),%eax
  800d19:	eb 05                	jmp    800d20 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d33:	50                   	push   %eax
  800d34:	e8 42 f6 ff ff       	call   80037b <fd_alloc>
  800d39:	83 c4 10             	add    $0x10,%esp
  800d3c:	89 c2                	mov    %eax,%edx
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	0f 88 2c 01 00 00    	js     800e72 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d46:	83 ec 04             	sub    $0x4,%esp
  800d49:	68 07 04 00 00       	push   $0x407
  800d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d51:	6a 00                	push   $0x0
  800d53:	e8 0b f4 ff ff       	call   800163 <sys_page_alloc>
  800d58:	83 c4 10             	add    $0x10,%esp
  800d5b:	89 c2                	mov    %eax,%edx
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	0f 88 0d 01 00 00    	js     800e72 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6b:	50                   	push   %eax
  800d6c:	e8 0a f6 ff ff       	call   80037b <fd_alloc>
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	83 c4 10             	add    $0x10,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	0f 88 e2 00 00 00    	js     800e60 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	68 07 04 00 00       	push   $0x407
  800d86:	ff 75 f0             	pushl  -0x10(%ebp)
  800d89:	6a 00                	push   $0x0
  800d8b:	e8 d3 f3 ff ff       	call   800163 <sys_page_alloc>
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	0f 88 c3 00 00 00    	js     800e60 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	ff 75 f4             	pushl  -0xc(%ebp)
  800da3:	e8 bc f5 ff ff       	call   800364 <fd2data>
  800da8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daa:	83 c4 0c             	add    $0xc,%esp
  800dad:	68 07 04 00 00       	push   $0x407
  800db2:	50                   	push   %eax
  800db3:	6a 00                	push   $0x0
  800db5:	e8 a9 f3 ff ff       	call   800163 <sys_page_alloc>
  800dba:	89 c3                	mov    %eax,%ebx
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	0f 88 89 00 00 00    	js     800e50 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcd:	e8 92 f5 ff ff       	call   800364 <fd2data>
  800dd2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd9:	50                   	push   %eax
  800dda:	6a 00                	push   $0x0
  800ddc:	56                   	push   %esi
  800ddd:	6a 00                	push   $0x0
  800ddf:	e8 c2 f3 ff ff       	call   8001a6 <sys_page_map>
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	83 c4 20             	add    $0x20,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	78 55                	js     800e42 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800ded:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e02:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e10:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1d:	e8 32 f5 ff ff       	call   800354 <fd2num>
  800e22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e25:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e27:	83 c4 04             	add    $0x4,%esp
  800e2a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2d:	e8 22 f5 ff ff       	call   800354 <fd2num>
  800e32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e35:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e40:	eb 30                	jmp    800e72 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e42:	83 ec 08             	sub    $0x8,%esp
  800e45:	56                   	push   %esi
  800e46:	6a 00                	push   $0x0
  800e48:	e8 9b f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e4d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	ff 75 f0             	pushl  -0x10(%ebp)
  800e56:	6a 00                	push   $0x0
  800e58:	e8 8b f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e5d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	ff 75 f4             	pushl  -0xc(%ebp)
  800e66:	6a 00                	push   $0x0
  800e68:	e8 7b f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e72:	89 d0                	mov    %edx,%eax
  800e74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e84:	50                   	push   %eax
  800e85:	ff 75 08             	pushl  0x8(%ebp)
  800e88:	e8 3d f5 ff ff       	call   8003ca <fd_lookup>
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	78 18                	js     800eac <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e94:	83 ec 0c             	sub    $0xc,%esp
  800e97:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9a:	e8 c5 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800e9f:	89 c2                	mov    %eax,%edx
  800ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea4:	e8 21 fd ff ff       	call   800bca <_pipeisclosed>
  800ea9:	83 c4 10             	add    $0x10,%esp
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebe:	68 b6 1e 80 00       	push   $0x801eb6
  800ec3:	ff 75 0c             	pushl  0xc(%ebp)
  800ec6:	e8 c4 07 00 00       	call   80168f <strcpy>
	return 0;
}
  800ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ede:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee9:	eb 2d                	jmp    800f18 <devcons_write+0x46>
		m = n - tot;
  800eeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eee:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ef8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efb:	83 ec 04             	sub    $0x4,%esp
  800efe:	53                   	push   %ebx
  800eff:	03 45 0c             	add    0xc(%ebp),%eax
  800f02:	50                   	push   %eax
  800f03:	57                   	push   %edi
  800f04:	e8 18 09 00 00       	call   801821 <memmove>
		sys_cputs(buf, m);
  800f09:	83 c4 08             	add    $0x8,%esp
  800f0c:	53                   	push   %ebx
  800f0d:	57                   	push   %edi
  800f0e:	e8 94 f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f13:	01 de                	add    %ebx,%esi
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	89 f0                	mov    %esi,%eax
  800f1a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1d:	72 cc                	jb     800eeb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f36:	74 2a                	je     800f62 <devcons_read+0x3b>
  800f38:	eb 05                	jmp    800f3f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f3a:	e8 05 f2 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f3f:	e8 81 f1 ff ff       	call   8000c5 <sys_cgetc>
  800f44:	85 c0                	test   %eax,%eax
  800f46:	74 f2                	je     800f3a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	78 16                	js     800f62 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f4c:	83 f8 04             	cmp    $0x4,%eax
  800f4f:	74 0c                	je     800f5d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f54:	88 02                	mov    %al,(%edx)
	return 1;
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	eb 05                	jmp    800f62 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f70:	6a 01                	push   $0x1
  800f72:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	e8 2c f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <getchar>:

int
getchar(void)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f86:	6a 01                	push   $0x1
  800f88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8b:	50                   	push   %eax
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 9d f6 ff ff       	call   800630 <read>
	if (r < 0)
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 0f                	js     800fa9 <getchar+0x29>
		return r;
	if (r < 1)
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	7e 06                	jle    800fa4 <getchar+0x24>
		return -E_EOF;
	return c;
  800f9e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa2:	eb 05                	jmp    800fa9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	ff 75 08             	pushl  0x8(%ebp)
  800fb8:	e8 0d f4 ff ff       	call   8003ca <fd_lookup>
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	78 11                	js     800fd5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcd:	39 10                	cmp    %edx,(%eax)
  800fcf:	0f 94 c0             	sete   %al
  800fd2:	0f b6 c0             	movzbl %al,%eax
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <opencons>:

int
opencons(void)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	e8 95 f3 ff ff       	call   80037b <fd_alloc>
  800fe6:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 3e                	js     80102d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fef:	83 ec 04             	sub    $0x4,%esp
  800ff2:	68 07 04 00 00       	push   $0x407
  800ff7:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 62 f1 ff ff       	call   800163 <sys_page_alloc>
  801001:	83 c4 10             	add    $0x10,%esp
		return r;
  801004:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801006:	85 c0                	test   %eax,%eax
  801008:	78 23                	js     80102d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80100a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801013:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801018:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	50                   	push   %eax
  801023:	e8 2c f3 ff ff       	call   800354 <fd2num>
  801028:	89 c2                	mov    %eax,%edx
  80102a:	83 c4 10             	add    $0x10,%esp
}
  80102d:	89 d0                	mov    %edx,%eax
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801036:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801039:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103f:	e8 e1 f0 ff ff       	call   800125 <sys_getenvid>
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	ff 75 0c             	pushl  0xc(%ebp)
  80104a:	ff 75 08             	pushl  0x8(%ebp)
  80104d:	56                   	push   %esi
  80104e:	50                   	push   %eax
  80104f:	68 c4 1e 80 00       	push   $0x801ec4
  801054:	e8 b1 00 00 00       	call   80110a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801059:	83 c4 18             	add    $0x18,%esp
  80105c:	53                   	push   %ebx
  80105d:	ff 75 10             	pushl  0x10(%ebp)
  801060:	e8 54 00 00 00       	call   8010b9 <vcprintf>
	cprintf("\n");
  801065:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  80106c:	e8 99 00 00 00       	call   80110a <cprintf>
  801071:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801074:	cc                   	int3   
  801075:	eb fd                	jmp    801074 <_panic+0x43>

00801077 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	53                   	push   %ebx
  80107b:	83 ec 04             	sub    $0x4,%esp
  80107e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801081:	8b 13                	mov    (%ebx),%edx
  801083:	8d 42 01             	lea    0x1(%edx),%eax
  801086:	89 03                	mov    %eax,(%ebx)
  801088:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801094:	75 1a                	jne    8010b0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	68 ff 00 00 00       	push   $0xff
  80109e:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a1:	50                   	push   %eax
  8010a2:	e8 00 f0 ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ad:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c9:	00 00 00 
	b.cnt = 0;
  8010cc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d6:	ff 75 0c             	pushl  0xc(%ebp)
  8010d9:	ff 75 08             	pushl  0x8(%ebp)
  8010dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e2:	50                   	push   %eax
  8010e3:	68 77 10 80 00       	push   $0x801077
  8010e8:	e8 54 01 00 00       	call   801241 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ed:	83 c4 08             	add    $0x8,%esp
  8010f0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	e8 a5 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801102:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801108:	c9                   	leave  
  801109:	c3                   	ret    

0080110a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801110:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801113:	50                   	push   %eax
  801114:	ff 75 08             	pushl  0x8(%ebp)
  801117:	e8 9d ff ff ff       	call   8010b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 1c             	sub    $0x1c,%esp
  801127:	89 c7                	mov    %eax,%edi
  801129:	89 d6                	mov    %edx,%esi
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801131:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801134:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801137:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801142:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801145:	39 d3                	cmp    %edx,%ebx
  801147:	72 05                	jb     80114e <printnum+0x30>
  801149:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114c:	77 45                	ja     801193 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	ff 75 18             	pushl  0x18(%ebp)
  801154:	8b 45 14             	mov    0x14(%ebp),%eax
  801157:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80115a:	53                   	push   %ebx
  80115b:	ff 75 10             	pushl  0x10(%ebp)
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	ff 75 e4             	pushl  -0x1c(%ebp)
  801164:	ff 75 e0             	pushl  -0x20(%ebp)
  801167:	ff 75 dc             	pushl  -0x24(%ebp)
  80116a:	ff 75 d8             	pushl  -0x28(%ebp)
  80116d:	e8 9e 09 00 00       	call   801b10 <__udivdi3>
  801172:	83 c4 18             	add    $0x18,%esp
  801175:	52                   	push   %edx
  801176:	50                   	push   %eax
  801177:	89 f2                	mov    %esi,%edx
  801179:	89 f8                	mov    %edi,%eax
  80117b:	e8 9e ff ff ff       	call   80111e <printnum>
  801180:	83 c4 20             	add    $0x20,%esp
  801183:	eb 18                	jmp    80119d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	56                   	push   %esi
  801189:	ff 75 18             	pushl  0x18(%ebp)
  80118c:	ff d7                	call   *%edi
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	eb 03                	jmp    801196 <printnum+0x78>
  801193:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801196:	83 eb 01             	sub    $0x1,%ebx
  801199:	85 db                	test   %ebx,%ebx
  80119b:	7f e8                	jg     801185 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	56                   	push   %esi
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b0:	e8 8b 0a 00 00       	call   801c40 <__umoddi3>
  8011b5:	83 c4 14             	add    $0x14,%esp
  8011b8:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  8011bf:	50                   	push   %eax
  8011c0:	ff d7                	call   *%edi
}
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011d0:	83 fa 01             	cmp    $0x1,%edx
  8011d3:	7e 0e                	jle    8011e3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011d5:	8b 10                	mov    (%eax),%edx
  8011d7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011da:	89 08                	mov    %ecx,(%eax)
  8011dc:	8b 02                	mov    (%edx),%eax
  8011de:	8b 52 04             	mov    0x4(%edx),%edx
  8011e1:	eb 22                	jmp    801205 <getuint+0x38>
	else if (lflag)
  8011e3:	85 d2                	test   %edx,%edx
  8011e5:	74 10                	je     8011f7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011e7:	8b 10                	mov    (%eax),%edx
  8011e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ec:	89 08                	mov    %ecx,(%eax)
  8011ee:	8b 02                	mov    (%edx),%eax
  8011f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f5:	eb 0e                	jmp    801205 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011f7:	8b 10                	mov    (%eax),%edx
  8011f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fc:	89 08                	mov    %ecx,(%eax)
  8011fe:	8b 02                	mov    (%edx),%eax
  801200:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80120d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801211:	8b 10                	mov    (%eax),%edx
  801213:	3b 50 04             	cmp    0x4(%eax),%edx
  801216:	73 0a                	jae    801222 <sprintputch+0x1b>
		*b->buf++ = ch;
  801218:	8d 4a 01             	lea    0x1(%edx),%ecx
  80121b:	89 08                	mov    %ecx,(%eax)
  80121d:	8b 45 08             	mov    0x8(%ebp),%eax
  801220:	88 02                	mov    %al,(%edx)
}
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80122a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80122d:	50                   	push   %eax
  80122e:	ff 75 10             	pushl  0x10(%ebp)
  801231:	ff 75 0c             	pushl  0xc(%ebp)
  801234:	ff 75 08             	pushl  0x8(%ebp)
  801237:	e8 05 00 00 00       	call   801241 <vprintfmt>
	va_end(ap);
}
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	57                   	push   %edi
  801245:	56                   	push   %esi
  801246:	53                   	push   %ebx
  801247:	83 ec 2c             	sub    $0x2c,%esp
  80124a:	8b 75 08             	mov    0x8(%ebp),%esi
  80124d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801250:	8b 7d 10             	mov    0x10(%ebp),%edi
  801253:	eb 12                	jmp    801267 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801255:	85 c0                	test   %eax,%eax
  801257:	0f 84 89 03 00 00    	je     8015e6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	53                   	push   %ebx
  801261:	50                   	push   %eax
  801262:	ff d6                	call   *%esi
  801264:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801267:	83 c7 01             	add    $0x1,%edi
  80126a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80126e:	83 f8 25             	cmp    $0x25,%eax
  801271:	75 e2                	jne    801255 <vprintfmt+0x14>
  801273:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801277:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80127e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801285:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80128c:	ba 00 00 00 00       	mov    $0x0,%edx
  801291:	eb 07                	jmp    80129a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801293:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801296:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129a:	8d 47 01             	lea    0x1(%edi),%eax
  80129d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a0:	0f b6 07             	movzbl (%edi),%eax
  8012a3:	0f b6 c8             	movzbl %al,%ecx
  8012a6:	83 e8 23             	sub    $0x23,%eax
  8012a9:	3c 55                	cmp    $0x55,%al
  8012ab:	0f 87 1a 03 00 00    	ja     8015cb <vprintfmt+0x38a>
  8012b1:	0f b6 c0             	movzbl %al,%eax
  8012b4:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  8012bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012be:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012c2:	eb d6                	jmp    80129a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012cf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012d2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012d6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012d9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012dc:	83 fa 09             	cmp    $0x9,%edx
  8012df:	77 39                	ja     80131a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012e4:	eb e9                	jmp    8012cf <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8012ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012ef:	8b 00                	mov    (%eax),%eax
  8012f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012f7:	eb 27                	jmp    801320 <vprintfmt+0xdf>
  8012f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801303:	0f 49 c8             	cmovns %eax,%ecx
  801306:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130c:	eb 8c                	jmp    80129a <vprintfmt+0x59>
  80130e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801311:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801318:	eb 80                	jmp    80129a <vprintfmt+0x59>
  80131a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80131d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801320:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801324:	0f 89 70 ff ff ff    	jns    80129a <vprintfmt+0x59>
				width = precision, precision = -1;
  80132a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80132d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801330:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801337:	e9 5e ff ff ff       	jmp    80129a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80133c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801342:	e9 53 ff ff ff       	jmp    80129a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801347:	8b 45 14             	mov    0x14(%ebp),%eax
  80134a:	8d 50 04             	lea    0x4(%eax),%edx
  80134d:	89 55 14             	mov    %edx,0x14(%ebp)
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	53                   	push   %ebx
  801354:	ff 30                	pushl  (%eax)
  801356:	ff d6                	call   *%esi
			break;
  801358:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80135e:	e9 04 ff ff ff       	jmp    801267 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801363:	8b 45 14             	mov    0x14(%ebp),%eax
  801366:	8d 50 04             	lea    0x4(%eax),%edx
  801369:	89 55 14             	mov    %edx,0x14(%ebp)
  80136c:	8b 00                	mov    (%eax),%eax
  80136e:	99                   	cltd   
  80136f:	31 d0                	xor    %edx,%eax
  801371:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801373:	83 f8 0f             	cmp    $0xf,%eax
  801376:	7f 0b                	jg     801383 <vprintfmt+0x142>
  801378:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  80137f:	85 d2                	test   %edx,%edx
  801381:	75 18                	jne    80139b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801383:	50                   	push   %eax
  801384:	68 ff 1e 80 00       	push   $0x801eff
  801389:	53                   	push   %ebx
  80138a:	56                   	push   %esi
  80138b:	e8 94 fe ff ff       	call   801224 <printfmt>
  801390:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801396:	e9 cc fe ff ff       	jmp    801267 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80139b:	52                   	push   %edx
  80139c:	68 7d 1e 80 00       	push   $0x801e7d
  8013a1:	53                   	push   %ebx
  8013a2:	56                   	push   %esi
  8013a3:	e8 7c fe ff ff       	call   801224 <printfmt>
  8013a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013ae:	e9 b4 fe ff ff       	jmp    801267 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b6:	8d 50 04             	lea    0x4(%eax),%edx
  8013b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013be:	85 ff                	test   %edi,%edi
  8013c0:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  8013c5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013cc:	0f 8e 94 00 00 00    	jle    801466 <vprintfmt+0x225>
  8013d2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013d6:	0f 84 98 00 00 00    	je     801474 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	ff 75 d0             	pushl  -0x30(%ebp)
  8013e2:	57                   	push   %edi
  8013e3:	e8 86 02 00 00       	call   80166e <strnlen>
  8013e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013eb:	29 c1                	sub    %eax,%ecx
  8013ed:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013f0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013f3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013fa:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013fd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ff:	eb 0f                	jmp    801410 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	53                   	push   %ebx
  801405:	ff 75 e0             	pushl  -0x20(%ebp)
  801408:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140a:	83 ef 01             	sub    $0x1,%edi
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	85 ff                	test   %edi,%edi
  801412:	7f ed                	jg     801401 <vprintfmt+0x1c0>
  801414:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801417:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80141a:	85 c9                	test   %ecx,%ecx
  80141c:	b8 00 00 00 00       	mov    $0x0,%eax
  801421:	0f 49 c1             	cmovns %ecx,%eax
  801424:	29 c1                	sub    %eax,%ecx
  801426:	89 75 08             	mov    %esi,0x8(%ebp)
  801429:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80142c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80142f:	89 cb                	mov    %ecx,%ebx
  801431:	eb 4d                	jmp    801480 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801433:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801437:	74 1b                	je     801454 <vprintfmt+0x213>
  801439:	0f be c0             	movsbl %al,%eax
  80143c:	83 e8 20             	sub    $0x20,%eax
  80143f:	83 f8 5e             	cmp    $0x5e,%eax
  801442:	76 10                	jbe    801454 <vprintfmt+0x213>
					putch('?', putdat);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	ff 75 0c             	pushl  0xc(%ebp)
  80144a:	6a 3f                	push   $0x3f
  80144c:	ff 55 08             	call   *0x8(%ebp)
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	eb 0d                	jmp    801461 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	ff 75 0c             	pushl  0xc(%ebp)
  80145a:	52                   	push   %edx
  80145b:	ff 55 08             	call   *0x8(%ebp)
  80145e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801461:	83 eb 01             	sub    $0x1,%ebx
  801464:	eb 1a                	jmp    801480 <vprintfmt+0x23f>
  801466:	89 75 08             	mov    %esi,0x8(%ebp)
  801469:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80146c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80146f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801472:	eb 0c                	jmp    801480 <vprintfmt+0x23f>
  801474:	89 75 08             	mov    %esi,0x8(%ebp)
  801477:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80147a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801480:	83 c7 01             	add    $0x1,%edi
  801483:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801487:	0f be d0             	movsbl %al,%edx
  80148a:	85 d2                	test   %edx,%edx
  80148c:	74 23                	je     8014b1 <vprintfmt+0x270>
  80148e:	85 f6                	test   %esi,%esi
  801490:	78 a1                	js     801433 <vprintfmt+0x1f2>
  801492:	83 ee 01             	sub    $0x1,%esi
  801495:	79 9c                	jns    801433 <vprintfmt+0x1f2>
  801497:	89 df                	mov    %ebx,%edi
  801499:	8b 75 08             	mov    0x8(%ebp),%esi
  80149c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149f:	eb 18                	jmp    8014b9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	53                   	push   %ebx
  8014a5:	6a 20                	push   $0x20
  8014a7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014a9:	83 ef 01             	sub    $0x1,%edi
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	eb 08                	jmp    8014b9 <vprintfmt+0x278>
  8014b1:	89 df                	mov    %ebx,%edi
  8014b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b9:	85 ff                	test   %edi,%edi
  8014bb:	7f e4                	jg     8014a1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c0:	e9 a2 fd ff ff       	jmp    801267 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014c5:	83 fa 01             	cmp    $0x1,%edx
  8014c8:	7e 16                	jle    8014e0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cd:	8d 50 08             	lea    0x8(%eax),%edx
  8014d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d3:	8b 50 04             	mov    0x4(%eax),%edx
  8014d6:	8b 00                	mov    (%eax),%eax
  8014d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014db:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014de:	eb 32                	jmp    801512 <vprintfmt+0x2d1>
	else if (lflag)
  8014e0:	85 d2                	test   %edx,%edx
  8014e2:	74 18                	je     8014fc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e7:	8d 50 04             	lea    0x4(%eax),%edx
  8014ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ed:	8b 00                	mov    (%eax),%eax
  8014ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f2:	89 c1                	mov    %eax,%ecx
  8014f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014fa:	eb 16                	jmp    801512 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ff:	8d 50 04             	lea    0x4(%eax),%edx
  801502:	89 55 14             	mov    %edx,0x14(%ebp)
  801505:	8b 00                	mov    (%eax),%eax
  801507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150a:	89 c1                	mov    %eax,%ecx
  80150c:	c1 f9 1f             	sar    $0x1f,%ecx
  80150f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801512:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801515:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801518:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80151d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801521:	79 74                	jns    801597 <vprintfmt+0x356>
				putch('-', putdat);
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	53                   	push   %ebx
  801527:	6a 2d                	push   $0x2d
  801529:	ff d6                	call   *%esi
				num = -(long long) num;
  80152b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80152e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801531:	f7 d8                	neg    %eax
  801533:	83 d2 00             	adc    $0x0,%edx
  801536:	f7 da                	neg    %edx
  801538:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80153b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801540:	eb 55                	jmp    801597 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801542:	8d 45 14             	lea    0x14(%ebp),%eax
  801545:	e8 83 fc ff ff       	call   8011cd <getuint>
			base = 10;
  80154a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80154f:	eb 46                	jmp    801597 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801551:	8d 45 14             	lea    0x14(%ebp),%eax
  801554:	e8 74 fc ff ff       	call   8011cd <getuint>
			base = 8;
  801559:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80155e:	eb 37                	jmp    801597 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	53                   	push   %ebx
  801564:	6a 30                	push   $0x30
  801566:	ff d6                	call   *%esi
			putch('x', putdat);
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	53                   	push   %ebx
  80156c:	6a 78                	push   $0x78
  80156e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801570:	8b 45 14             	mov    0x14(%ebp),%eax
  801573:	8d 50 04             	lea    0x4(%eax),%edx
  801576:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801579:	8b 00                	mov    (%eax),%eax
  80157b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801580:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801583:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801588:	eb 0d                	jmp    801597 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80158a:	8d 45 14             	lea    0x14(%ebp),%eax
  80158d:	e8 3b fc ff ff       	call   8011cd <getuint>
			base = 16;
  801592:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80159e:	57                   	push   %edi
  80159f:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a2:	51                   	push   %ecx
  8015a3:	52                   	push   %edx
  8015a4:	50                   	push   %eax
  8015a5:	89 da                	mov    %ebx,%edx
  8015a7:	89 f0                	mov    %esi,%eax
  8015a9:	e8 70 fb ff ff       	call   80111e <printnum>
			break;
  8015ae:	83 c4 20             	add    $0x20,%esp
  8015b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015b4:	e9 ae fc ff ff       	jmp    801267 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	51                   	push   %ecx
  8015be:	ff d6                	call   *%esi
			break;
  8015c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015c6:	e9 9c fc ff ff       	jmp    801267 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	53                   	push   %ebx
  8015cf:	6a 25                	push   $0x25
  8015d1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	eb 03                	jmp    8015db <vprintfmt+0x39a>
  8015d8:	83 ef 01             	sub    $0x1,%edi
  8015db:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015df:	75 f7                	jne    8015d8 <vprintfmt+0x397>
  8015e1:	e9 81 fc ff ff       	jmp    801267 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5f                   	pop    %edi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 18             	sub    $0x18,%esp
  8015f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015fd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801601:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801604:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80160b:	85 c0                	test   %eax,%eax
  80160d:	74 26                	je     801635 <vsnprintf+0x47>
  80160f:	85 d2                	test   %edx,%edx
  801611:	7e 22                	jle    801635 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801613:	ff 75 14             	pushl  0x14(%ebp)
  801616:	ff 75 10             	pushl  0x10(%ebp)
  801619:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	68 07 12 80 00       	push   $0x801207
  801622:	e8 1a fc ff ff       	call   801241 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801627:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80162a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80162d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb 05                	jmp    80163a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801635:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801642:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801645:	50                   	push   %eax
  801646:	ff 75 10             	pushl  0x10(%ebp)
  801649:	ff 75 0c             	pushl  0xc(%ebp)
  80164c:	ff 75 08             	pushl  0x8(%ebp)
  80164f:	e8 9a ff ff ff       	call   8015ee <vsnprintf>
	va_end(ap);

	return rc;
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80165c:	b8 00 00 00 00       	mov    $0x0,%eax
  801661:	eb 03                	jmp    801666 <strlen+0x10>
		n++;
  801663:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801666:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80166a:	75 f7                	jne    801663 <strlen+0xd>
		n++;
	return n;
}
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801674:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801677:	ba 00 00 00 00       	mov    $0x0,%edx
  80167c:	eb 03                	jmp    801681 <strnlen+0x13>
		n++;
  80167e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801681:	39 c2                	cmp    %eax,%edx
  801683:	74 08                	je     80168d <strnlen+0x1f>
  801685:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801689:	75 f3                	jne    80167e <strnlen+0x10>
  80168b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	53                   	push   %ebx
  801693:	8b 45 08             	mov    0x8(%ebp),%eax
  801696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801699:	89 c2                	mov    %eax,%edx
  80169b:	83 c2 01             	add    $0x1,%edx
  80169e:	83 c1 01             	add    $0x1,%ecx
  8016a1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016a5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016a8:	84 db                	test   %bl,%bl
  8016aa:	75 ef                	jne    80169b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016ac:	5b                   	pop    %ebx
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016b6:	53                   	push   %ebx
  8016b7:	e8 9a ff ff ff       	call   801656 <strlen>
  8016bc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016bf:	ff 75 0c             	pushl  0xc(%ebp)
  8016c2:	01 d8                	add    %ebx,%eax
  8016c4:	50                   	push   %eax
  8016c5:	e8 c5 ff ff ff       	call   80168f <strcpy>
	return dst;
}
  8016ca:	89 d8                	mov    %ebx,%eax
  8016cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	56                   	push   %esi
  8016d5:	53                   	push   %ebx
  8016d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016dc:	89 f3                	mov    %esi,%ebx
  8016de:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e1:	89 f2                	mov    %esi,%edx
  8016e3:	eb 0f                	jmp    8016f4 <strncpy+0x23>
		*dst++ = *src;
  8016e5:	83 c2 01             	add    $0x1,%edx
  8016e8:	0f b6 01             	movzbl (%ecx),%eax
  8016eb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016ee:	80 39 01             	cmpb   $0x1,(%ecx)
  8016f1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f4:	39 da                	cmp    %ebx,%edx
  8016f6:	75 ed                	jne    8016e5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016f8:	89 f0                	mov    %esi,%eax
  8016fa:	5b                   	pop    %ebx
  8016fb:	5e                   	pop    %esi
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	8b 75 08             	mov    0x8(%ebp),%esi
  801706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801709:	8b 55 10             	mov    0x10(%ebp),%edx
  80170c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80170e:	85 d2                	test   %edx,%edx
  801710:	74 21                	je     801733 <strlcpy+0x35>
  801712:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801716:	89 f2                	mov    %esi,%edx
  801718:	eb 09                	jmp    801723 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80171a:	83 c2 01             	add    $0x1,%edx
  80171d:	83 c1 01             	add    $0x1,%ecx
  801720:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801723:	39 c2                	cmp    %eax,%edx
  801725:	74 09                	je     801730 <strlcpy+0x32>
  801727:	0f b6 19             	movzbl (%ecx),%ebx
  80172a:	84 db                	test   %bl,%bl
  80172c:	75 ec                	jne    80171a <strlcpy+0x1c>
  80172e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801730:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801733:	29 f0                	sub    %esi,%eax
}
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80173f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801742:	eb 06                	jmp    80174a <strcmp+0x11>
		p++, q++;
  801744:	83 c1 01             	add    $0x1,%ecx
  801747:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80174a:	0f b6 01             	movzbl (%ecx),%eax
  80174d:	84 c0                	test   %al,%al
  80174f:	74 04                	je     801755 <strcmp+0x1c>
  801751:	3a 02                	cmp    (%edx),%al
  801753:	74 ef                	je     801744 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801755:	0f b6 c0             	movzbl %al,%eax
  801758:	0f b6 12             	movzbl (%edx),%edx
  80175b:	29 d0                	sub    %edx,%eax
}
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	8b 45 08             	mov    0x8(%ebp),%eax
  801766:	8b 55 0c             	mov    0xc(%ebp),%edx
  801769:	89 c3                	mov    %eax,%ebx
  80176b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80176e:	eb 06                	jmp    801776 <strncmp+0x17>
		n--, p++, q++;
  801770:	83 c0 01             	add    $0x1,%eax
  801773:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801776:	39 d8                	cmp    %ebx,%eax
  801778:	74 15                	je     80178f <strncmp+0x30>
  80177a:	0f b6 08             	movzbl (%eax),%ecx
  80177d:	84 c9                	test   %cl,%cl
  80177f:	74 04                	je     801785 <strncmp+0x26>
  801781:	3a 0a                	cmp    (%edx),%cl
  801783:	74 eb                	je     801770 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801785:	0f b6 00             	movzbl (%eax),%eax
  801788:	0f b6 12             	movzbl (%edx),%edx
  80178b:	29 d0                	sub    %edx,%eax
  80178d:	eb 05                	jmp    801794 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80178f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801794:	5b                   	pop    %ebx
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017a1:	eb 07                	jmp    8017aa <strchr+0x13>
		if (*s == c)
  8017a3:	38 ca                	cmp    %cl,%dl
  8017a5:	74 0f                	je     8017b6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017a7:	83 c0 01             	add    $0x1,%eax
  8017aa:	0f b6 10             	movzbl (%eax),%edx
  8017ad:	84 d2                	test   %dl,%dl
  8017af:	75 f2                	jne    8017a3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c2:	eb 03                	jmp    8017c7 <strfind+0xf>
  8017c4:	83 c0 01             	add    $0x1,%eax
  8017c7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017ca:	38 ca                	cmp    %cl,%dl
  8017cc:	74 04                	je     8017d2 <strfind+0x1a>
  8017ce:	84 d2                	test   %dl,%dl
  8017d0:	75 f2                	jne    8017c4 <strfind+0xc>
			break;
	return (char *) s;
}
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	57                   	push   %edi
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017e0:	85 c9                	test   %ecx,%ecx
  8017e2:	74 36                	je     80181a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017ea:	75 28                	jne    801814 <memset+0x40>
  8017ec:	f6 c1 03             	test   $0x3,%cl
  8017ef:	75 23                	jne    801814 <memset+0x40>
		c &= 0xFF;
  8017f1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017f5:	89 d3                	mov    %edx,%ebx
  8017f7:	c1 e3 08             	shl    $0x8,%ebx
  8017fa:	89 d6                	mov    %edx,%esi
  8017fc:	c1 e6 18             	shl    $0x18,%esi
  8017ff:	89 d0                	mov    %edx,%eax
  801801:	c1 e0 10             	shl    $0x10,%eax
  801804:	09 f0                	or     %esi,%eax
  801806:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801808:	89 d8                	mov    %ebx,%eax
  80180a:	09 d0                	or     %edx,%eax
  80180c:	c1 e9 02             	shr    $0x2,%ecx
  80180f:	fc                   	cld    
  801810:	f3 ab                	rep stos %eax,%es:(%edi)
  801812:	eb 06                	jmp    80181a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801814:	8b 45 0c             	mov    0xc(%ebp),%eax
  801817:	fc                   	cld    
  801818:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80181a:	89 f8                	mov    %edi,%eax
  80181c:	5b                   	pop    %ebx
  80181d:	5e                   	pop    %esi
  80181e:	5f                   	pop    %edi
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    

00801821 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	57                   	push   %edi
  801825:	56                   	push   %esi
  801826:	8b 45 08             	mov    0x8(%ebp),%eax
  801829:	8b 75 0c             	mov    0xc(%ebp),%esi
  80182c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80182f:	39 c6                	cmp    %eax,%esi
  801831:	73 35                	jae    801868 <memmove+0x47>
  801833:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801836:	39 d0                	cmp    %edx,%eax
  801838:	73 2e                	jae    801868 <memmove+0x47>
		s += n;
		d += n;
  80183a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80183d:	89 d6                	mov    %edx,%esi
  80183f:	09 fe                	or     %edi,%esi
  801841:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801847:	75 13                	jne    80185c <memmove+0x3b>
  801849:	f6 c1 03             	test   $0x3,%cl
  80184c:	75 0e                	jne    80185c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80184e:	83 ef 04             	sub    $0x4,%edi
  801851:	8d 72 fc             	lea    -0x4(%edx),%esi
  801854:	c1 e9 02             	shr    $0x2,%ecx
  801857:	fd                   	std    
  801858:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80185a:	eb 09                	jmp    801865 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80185c:	83 ef 01             	sub    $0x1,%edi
  80185f:	8d 72 ff             	lea    -0x1(%edx),%esi
  801862:	fd                   	std    
  801863:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801865:	fc                   	cld    
  801866:	eb 1d                	jmp    801885 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801868:	89 f2                	mov    %esi,%edx
  80186a:	09 c2                	or     %eax,%edx
  80186c:	f6 c2 03             	test   $0x3,%dl
  80186f:	75 0f                	jne    801880 <memmove+0x5f>
  801871:	f6 c1 03             	test   $0x3,%cl
  801874:	75 0a                	jne    801880 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801876:	c1 e9 02             	shr    $0x2,%ecx
  801879:	89 c7                	mov    %eax,%edi
  80187b:	fc                   	cld    
  80187c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187e:	eb 05                	jmp    801885 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801880:	89 c7                	mov    %eax,%edi
  801882:	fc                   	cld    
  801883:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801885:	5e                   	pop    %esi
  801886:	5f                   	pop    %edi
  801887:	5d                   	pop    %ebp
  801888:	c3                   	ret    

00801889 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80188c:	ff 75 10             	pushl  0x10(%ebp)
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	ff 75 08             	pushl  0x8(%ebp)
  801895:	e8 87 ff ff ff       	call   801821 <memmove>
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	56                   	push   %esi
  8018a0:	53                   	push   %ebx
  8018a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a7:	89 c6                	mov    %eax,%esi
  8018a9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ac:	eb 1a                	jmp    8018c8 <memcmp+0x2c>
		if (*s1 != *s2)
  8018ae:	0f b6 08             	movzbl (%eax),%ecx
  8018b1:	0f b6 1a             	movzbl (%edx),%ebx
  8018b4:	38 d9                	cmp    %bl,%cl
  8018b6:	74 0a                	je     8018c2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018b8:	0f b6 c1             	movzbl %cl,%eax
  8018bb:	0f b6 db             	movzbl %bl,%ebx
  8018be:	29 d8                	sub    %ebx,%eax
  8018c0:	eb 0f                	jmp    8018d1 <memcmp+0x35>
		s1++, s2++;
  8018c2:	83 c0 01             	add    $0x1,%eax
  8018c5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c8:	39 f0                	cmp    %esi,%eax
  8018ca:	75 e2                	jne    8018ae <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d1:	5b                   	pop    %ebx
  8018d2:	5e                   	pop    %esi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	53                   	push   %ebx
  8018d9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018dc:	89 c1                	mov    %eax,%ecx
  8018de:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018e1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e5:	eb 0a                	jmp    8018f1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018e7:	0f b6 10             	movzbl (%eax),%edx
  8018ea:	39 da                	cmp    %ebx,%edx
  8018ec:	74 07                	je     8018f5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018ee:	83 c0 01             	add    $0x1,%eax
  8018f1:	39 c8                	cmp    %ecx,%eax
  8018f3:	72 f2                	jb     8018e7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018f5:	5b                   	pop    %ebx
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	57                   	push   %edi
  8018fc:	56                   	push   %esi
  8018fd:	53                   	push   %ebx
  8018fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801901:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801904:	eb 03                	jmp    801909 <strtol+0x11>
		s++;
  801906:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801909:	0f b6 01             	movzbl (%ecx),%eax
  80190c:	3c 20                	cmp    $0x20,%al
  80190e:	74 f6                	je     801906 <strtol+0xe>
  801910:	3c 09                	cmp    $0x9,%al
  801912:	74 f2                	je     801906 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801914:	3c 2b                	cmp    $0x2b,%al
  801916:	75 0a                	jne    801922 <strtol+0x2a>
		s++;
  801918:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80191b:	bf 00 00 00 00       	mov    $0x0,%edi
  801920:	eb 11                	jmp    801933 <strtol+0x3b>
  801922:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801927:	3c 2d                	cmp    $0x2d,%al
  801929:	75 08                	jne    801933 <strtol+0x3b>
		s++, neg = 1;
  80192b:	83 c1 01             	add    $0x1,%ecx
  80192e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801933:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801939:	75 15                	jne    801950 <strtol+0x58>
  80193b:	80 39 30             	cmpb   $0x30,(%ecx)
  80193e:	75 10                	jne    801950 <strtol+0x58>
  801940:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801944:	75 7c                	jne    8019c2 <strtol+0xca>
		s += 2, base = 16;
  801946:	83 c1 02             	add    $0x2,%ecx
  801949:	bb 10 00 00 00       	mov    $0x10,%ebx
  80194e:	eb 16                	jmp    801966 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801950:	85 db                	test   %ebx,%ebx
  801952:	75 12                	jne    801966 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801954:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801959:	80 39 30             	cmpb   $0x30,(%ecx)
  80195c:	75 08                	jne    801966 <strtol+0x6e>
		s++, base = 8;
  80195e:	83 c1 01             	add    $0x1,%ecx
  801961:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801966:	b8 00 00 00 00       	mov    $0x0,%eax
  80196b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80196e:	0f b6 11             	movzbl (%ecx),%edx
  801971:	8d 72 d0             	lea    -0x30(%edx),%esi
  801974:	89 f3                	mov    %esi,%ebx
  801976:	80 fb 09             	cmp    $0x9,%bl
  801979:	77 08                	ja     801983 <strtol+0x8b>
			dig = *s - '0';
  80197b:	0f be d2             	movsbl %dl,%edx
  80197e:	83 ea 30             	sub    $0x30,%edx
  801981:	eb 22                	jmp    8019a5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801983:	8d 72 9f             	lea    -0x61(%edx),%esi
  801986:	89 f3                	mov    %esi,%ebx
  801988:	80 fb 19             	cmp    $0x19,%bl
  80198b:	77 08                	ja     801995 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80198d:	0f be d2             	movsbl %dl,%edx
  801990:	83 ea 57             	sub    $0x57,%edx
  801993:	eb 10                	jmp    8019a5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801995:	8d 72 bf             	lea    -0x41(%edx),%esi
  801998:	89 f3                	mov    %esi,%ebx
  80199a:	80 fb 19             	cmp    $0x19,%bl
  80199d:	77 16                	ja     8019b5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80199f:	0f be d2             	movsbl %dl,%edx
  8019a2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019a5:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019a8:	7d 0b                	jge    8019b5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019aa:	83 c1 01             	add    $0x1,%ecx
  8019ad:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019b1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019b3:	eb b9                	jmp    80196e <strtol+0x76>

	if (endptr)
  8019b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019b9:	74 0d                	je     8019c8 <strtol+0xd0>
		*endptr = (char *) s;
  8019bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019be:	89 0e                	mov    %ecx,(%esi)
  8019c0:	eb 06                	jmp    8019c8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019c2:	85 db                	test   %ebx,%ebx
  8019c4:	74 98                	je     80195e <strtol+0x66>
  8019c6:	eb 9e                	jmp    801966 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019c8:	89 c2                	mov    %eax,%edx
  8019ca:	f7 da                	neg    %edx
  8019cc:	85 ff                	test   %edi,%edi
  8019ce:	0f 45 c2             	cmovne %edx,%eax
}
  8019d1:	5b                   	pop    %ebx
  8019d2:	5e                   	pop    %esi
  8019d3:	5f                   	pop    %edi
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	56                   	push   %esi
  8019da:	53                   	push   %ebx
  8019db:	8b 75 08             	mov    0x8(%ebp),%esi
  8019de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019e4:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019e6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019eb:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	50                   	push   %eax
  8019f2:	e8 1c e9 ff ff       	call   800313 <sys_ipc_recv>

	if (from_env_store != NULL)
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	85 f6                	test   %esi,%esi
  8019fc:	74 14                	je     801a12 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 09                	js     801a10 <ipc_recv+0x3a>
  801a07:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a0d:	8b 52 74             	mov    0x74(%edx),%edx
  801a10:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a12:	85 db                	test   %ebx,%ebx
  801a14:	74 14                	je     801a2a <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a16:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 09                	js     801a28 <ipc_recv+0x52>
  801a1f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a25:	8b 52 78             	mov    0x78(%edx),%edx
  801a28:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 08                	js     801a36 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a2e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a33:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a39:	5b                   	pop    %ebx
  801a3a:	5e                   	pop    %esi
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    

00801a3d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	57                   	push   %edi
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a49:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a4f:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a51:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a56:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a59:	ff 75 14             	pushl  0x14(%ebp)
  801a5c:	53                   	push   %ebx
  801a5d:	56                   	push   %esi
  801a5e:	57                   	push   %edi
  801a5f:	e8 8c e8 ff ff       	call   8002f0 <sys_ipc_try_send>

		if (err < 0) {
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	85 c0                	test   %eax,%eax
  801a69:	79 1e                	jns    801a89 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a6b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a6e:	75 07                	jne    801a77 <ipc_send+0x3a>
				sys_yield();
  801a70:	e8 cf e6 ff ff       	call   800144 <sys_yield>
  801a75:	eb e2                	jmp    801a59 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a77:	50                   	push   %eax
  801a78:	68 e0 21 80 00       	push   $0x8021e0
  801a7d:	6a 49                	push   $0x49
  801a7f:	68 ed 21 80 00       	push   $0x8021ed
  801a84:	e8 a8 f5 ff ff       	call   801031 <_panic>
		}

	} while (err < 0);

}
  801a89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8c:	5b                   	pop    %ebx
  801a8d:	5e                   	pop    %esi
  801a8e:	5f                   	pop    %edi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a97:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a9c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a9f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aa5:	8b 52 50             	mov    0x50(%edx),%edx
  801aa8:	39 ca                	cmp    %ecx,%edx
  801aaa:	75 0d                	jne    801ab9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801aac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aaf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ab4:	8b 40 48             	mov    0x48(%eax),%eax
  801ab7:	eb 0f                	jmp    801ac8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab9:	83 c0 01             	add    $0x1,%eax
  801abc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ac1:	75 d9                	jne    801a9c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad0:	89 d0                	mov    %edx,%eax
  801ad2:	c1 e8 16             	shr    $0x16,%eax
  801ad5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801adc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae1:	f6 c1 01             	test   $0x1,%cl
  801ae4:	74 1d                	je     801b03 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ae6:	c1 ea 0c             	shr    $0xc,%edx
  801ae9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801af0:	f6 c2 01             	test   $0x1,%dl
  801af3:	74 0e                	je     801b03 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af5:	c1 ea 0c             	shr    $0xc,%edx
  801af8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801aff:	ef 
  801b00:	0f b7 c0             	movzwl %ax,%eax
}
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    
  801b05:	66 90                	xchg   %ax,%ax
  801b07:	66 90                	xchg   %ax,%ax
  801b09:	66 90                	xchg   %ax,%ax
  801b0b:	66 90                	xchg   %ax,%ax
  801b0d:	66 90                	xchg   %ax,%ax
  801b0f:	90                   	nop

00801b10 <__udivdi3>:
  801b10:	55                   	push   %ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 1c             	sub    $0x1c,%esp
  801b17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b27:	85 f6                	test   %esi,%esi
  801b29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b2d:	89 ca                	mov    %ecx,%edx
  801b2f:	89 f8                	mov    %edi,%eax
  801b31:	75 3d                	jne    801b70 <__udivdi3+0x60>
  801b33:	39 cf                	cmp    %ecx,%edi
  801b35:	0f 87 c5 00 00 00    	ja     801c00 <__udivdi3+0xf0>
  801b3b:	85 ff                	test   %edi,%edi
  801b3d:	89 fd                	mov    %edi,%ebp
  801b3f:	75 0b                	jne    801b4c <__udivdi3+0x3c>
  801b41:	b8 01 00 00 00       	mov    $0x1,%eax
  801b46:	31 d2                	xor    %edx,%edx
  801b48:	f7 f7                	div    %edi
  801b4a:	89 c5                	mov    %eax,%ebp
  801b4c:	89 c8                	mov    %ecx,%eax
  801b4e:	31 d2                	xor    %edx,%edx
  801b50:	f7 f5                	div    %ebp
  801b52:	89 c1                	mov    %eax,%ecx
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	89 cf                	mov    %ecx,%edi
  801b58:	f7 f5                	div    %ebp
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	89 d8                	mov    %ebx,%eax
  801b5e:	89 fa                	mov    %edi,%edx
  801b60:	83 c4 1c             	add    $0x1c,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    
  801b68:	90                   	nop
  801b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b70:	39 ce                	cmp    %ecx,%esi
  801b72:	77 74                	ja     801be8 <__udivdi3+0xd8>
  801b74:	0f bd fe             	bsr    %esi,%edi
  801b77:	83 f7 1f             	xor    $0x1f,%edi
  801b7a:	0f 84 98 00 00 00    	je     801c18 <__udivdi3+0x108>
  801b80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b85:	89 f9                	mov    %edi,%ecx
  801b87:	89 c5                	mov    %eax,%ebp
  801b89:	29 fb                	sub    %edi,%ebx
  801b8b:	d3 e6                	shl    %cl,%esi
  801b8d:	89 d9                	mov    %ebx,%ecx
  801b8f:	d3 ed                	shr    %cl,%ebp
  801b91:	89 f9                	mov    %edi,%ecx
  801b93:	d3 e0                	shl    %cl,%eax
  801b95:	09 ee                	or     %ebp,%esi
  801b97:	89 d9                	mov    %ebx,%ecx
  801b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b9d:	89 d5                	mov    %edx,%ebp
  801b9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ba3:	d3 ed                	shr    %cl,%ebp
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	d3 e2                	shl    %cl,%edx
  801ba9:	89 d9                	mov    %ebx,%ecx
  801bab:	d3 e8                	shr    %cl,%eax
  801bad:	09 c2                	or     %eax,%edx
  801baf:	89 d0                	mov    %edx,%eax
  801bb1:	89 ea                	mov    %ebp,%edx
  801bb3:	f7 f6                	div    %esi
  801bb5:	89 d5                	mov    %edx,%ebp
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	f7 64 24 0c          	mull   0xc(%esp)
  801bbd:	39 d5                	cmp    %edx,%ebp
  801bbf:	72 10                	jb     801bd1 <__udivdi3+0xc1>
  801bc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	d3 e6                	shl    %cl,%esi
  801bc9:	39 c6                	cmp    %eax,%esi
  801bcb:	73 07                	jae    801bd4 <__udivdi3+0xc4>
  801bcd:	39 d5                	cmp    %edx,%ebp
  801bcf:	75 03                	jne    801bd4 <__udivdi3+0xc4>
  801bd1:	83 eb 01             	sub    $0x1,%ebx
  801bd4:	31 ff                	xor    %edi,%edi
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	89 fa                	mov    %edi,%edx
  801bda:	83 c4 1c             	add    $0x1c,%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    
  801be2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801be8:	31 ff                	xor    %edi,%edi
  801bea:	31 db                	xor    %ebx,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	89 d8                	mov    %ebx,%eax
  801c02:	f7 f7                	div    %edi
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 c3                	mov    %eax,%ebx
  801c08:	89 d8                	mov    %ebx,%eax
  801c0a:	89 fa                	mov    %edi,%edx
  801c0c:	83 c4 1c             	add    $0x1c,%esp
  801c0f:	5b                   	pop    %ebx
  801c10:	5e                   	pop    %esi
  801c11:	5f                   	pop    %edi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	39 ce                	cmp    %ecx,%esi
  801c1a:	72 0c                	jb     801c28 <__udivdi3+0x118>
  801c1c:	31 db                	xor    %ebx,%ebx
  801c1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c22:	0f 87 34 ff ff ff    	ja     801b5c <__udivdi3+0x4c>
  801c28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c2d:	e9 2a ff ff ff       	jmp    801b5c <__udivdi3+0x4c>
  801c32:	66 90                	xchg   %ax,%ax
  801c34:	66 90                	xchg   %ax,%ax
  801c36:	66 90                	xchg   %ax,%ax
  801c38:	66 90                	xchg   %ax,%ax
  801c3a:	66 90                	xchg   %ax,%ax
  801c3c:	66 90                	xchg   %ax,%ax
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <__umoddi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c57:	85 d2                	test   %edx,%edx
  801c59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c61:	89 f3                	mov    %esi,%ebx
  801c63:	89 3c 24             	mov    %edi,(%esp)
  801c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6a:	75 1c                	jne    801c88 <__umoddi3+0x48>
  801c6c:	39 f7                	cmp    %esi,%edi
  801c6e:	76 50                	jbe    801cc0 <__umoddi3+0x80>
  801c70:	89 c8                	mov    %ecx,%eax
  801c72:	89 f2                	mov    %esi,%edx
  801c74:	f7 f7                	div    %edi
  801c76:	89 d0                	mov    %edx,%eax
  801c78:	31 d2                	xor    %edx,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	89 d0                	mov    %edx,%eax
  801c8c:	77 52                	ja     801ce0 <__umoddi3+0xa0>
  801c8e:	0f bd ea             	bsr    %edx,%ebp
  801c91:	83 f5 1f             	xor    $0x1f,%ebp
  801c94:	75 5a                	jne    801cf0 <__umoddi3+0xb0>
  801c96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c9a:	0f 82 e0 00 00 00    	jb     801d80 <__umoddi3+0x140>
  801ca0:	39 0c 24             	cmp    %ecx,(%esp)
  801ca3:	0f 86 d7 00 00 00    	jbe    801d80 <__umoddi3+0x140>
  801ca9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cb1:	83 c4 1c             	add    $0x1c,%esp
  801cb4:	5b                   	pop    %ebx
  801cb5:	5e                   	pop    %esi
  801cb6:	5f                   	pop    %edi
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	85 ff                	test   %edi,%edi
  801cc2:	89 fd                	mov    %edi,%ebp
  801cc4:	75 0b                	jne    801cd1 <__umoddi3+0x91>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f7                	div    %edi
  801ccf:	89 c5                	mov    %eax,%ebp
  801cd1:	89 f0                	mov    %esi,%eax
  801cd3:	31 d2                	xor    %edx,%edx
  801cd5:	f7 f5                	div    %ebp
  801cd7:	89 c8                	mov    %ecx,%eax
  801cd9:	f7 f5                	div    %ebp
  801cdb:	89 d0                	mov    %edx,%eax
  801cdd:	eb 99                	jmp    801c78 <__umoddi3+0x38>
  801cdf:	90                   	nop
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	83 c4 1c             	add    $0x1c,%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5f                   	pop    %edi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    
  801cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	8b 34 24             	mov    (%esp),%esi
  801cf3:	bf 20 00 00 00       	mov    $0x20,%edi
  801cf8:	89 e9                	mov    %ebp,%ecx
  801cfa:	29 ef                	sub    %ebp,%edi
  801cfc:	d3 e0                	shl    %cl,%eax
  801cfe:	89 f9                	mov    %edi,%ecx
  801d00:	89 f2                	mov    %esi,%edx
  801d02:	d3 ea                	shr    %cl,%edx
  801d04:	89 e9                	mov    %ebp,%ecx
  801d06:	09 c2                	or     %eax,%edx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 14 24             	mov    %edx,(%esp)
  801d0d:	89 f2                	mov    %esi,%edx
  801d0f:	d3 e2                	shl    %cl,%edx
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	89 e9                	mov    %ebp,%ecx
  801d1f:	89 c6                	mov    %eax,%esi
  801d21:	d3 e3                	shl    %cl,%ebx
  801d23:	89 f9                	mov    %edi,%ecx
  801d25:	89 d0                	mov    %edx,%eax
  801d27:	d3 e8                	shr    %cl,%eax
  801d29:	89 e9                	mov    %ebp,%ecx
  801d2b:	09 d8                	or     %ebx,%eax
  801d2d:	89 d3                	mov    %edx,%ebx
  801d2f:	89 f2                	mov    %esi,%edx
  801d31:	f7 34 24             	divl   (%esp)
  801d34:	89 d6                	mov    %edx,%esi
  801d36:	d3 e3                	shl    %cl,%ebx
  801d38:	f7 64 24 04          	mull   0x4(%esp)
  801d3c:	39 d6                	cmp    %edx,%esi
  801d3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d42:	89 d1                	mov    %edx,%ecx
  801d44:	89 c3                	mov    %eax,%ebx
  801d46:	72 08                	jb     801d50 <__umoddi3+0x110>
  801d48:	75 11                	jne    801d5b <__umoddi3+0x11b>
  801d4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d4e:	73 0b                	jae    801d5b <__umoddi3+0x11b>
  801d50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d54:	1b 14 24             	sbb    (%esp),%edx
  801d57:	89 d1                	mov    %edx,%ecx
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d5f:	29 da                	sub    %ebx,%edx
  801d61:	19 ce                	sbb    %ecx,%esi
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	d3 e0                	shl    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	d3 ea                	shr    %cl,%edx
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	d3 ee                	shr    %cl,%esi
  801d71:	09 d0                	or     %edx,%eax
  801d73:	89 f2                	mov    %esi,%edx
  801d75:	83 c4 1c             	add    $0x1c,%esp
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    
  801d7d:	8d 76 00             	lea    0x0(%esi),%esi
  801d80:	29 f9                	sub    %edi,%ecx
  801d82:	19 d6                	sbb    %edx,%esi
  801d84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d8c:	e9 18 ff ff ff       	jmp    801ca9 <__umoddi3+0x69>
