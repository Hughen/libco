/*
* Tencent is pleased to support the open source community by making Libco available.

* Copyright (C) 2014 THL A29 Limited, a Tencent company. All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); 
* you may not use this file except in compliance with the License. 
* You may obtain a copy of the License at
*
*	http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, 
* software distributed under the License is distributed on an "AS IS" BASIS, 
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
* See the License for the specific language governing permissions and 
* limitations under the License.
*/

.globl coctx_swap
#if !defined( __APPLE__ ) && !defined( __FreeBSD__ )
.type  coctx_swap, @function
#endif
coctx_swap:

// 摘抄自: http://kaiyuan.me/2017/07/10/libco/
#if defined(__i386__)
	leal 4(%esp), %eax //sp eax = old_esp + 4
	movl 4(%esp), %esp // 将 esp 的值设为 &ctx1
	leal 32(%esp), %esp //parm a : &regs[7] + sizeof(void*)  esp = (char*)&ctx1 + 32

	pushl %eax //esp ->parm a  ctx1->regs[EAX] = %eax

	pushl %ebp  // ctx1->regs[EBP] = %ebp
	pushl %esi  // ctx1->regs[ESI] = %esi
	pushl %edi  // ctx1->regs[EDI] = %edi
	pushl %edx  // ctx1->regs[EDX] = %edx
	pushl %ecx  // ctx1->regs[ECX] = %ecx
	pushl %ebx  // ctx1->regs[EBX] = %ebx
	pushl -4(%eax)  // ctx1->regs[EIP] = RA，注意: %eax-4=%old_esp

	
	movl 4(%eax), %esp //parm b -> &regs[0]  将 esp 的值设为 &ctx2，即ctx2的地址

	popl %eax  //ret func addr  %eax = ctx1->regs[EIP]，也就是 &pfn
	popl %ebx  // %ebx = ctx1->regs[EBP]
	popl %ecx  // %ecx = ctx1->regs[ECX]
	popl %edx  // %edx = ctx1->regs[EDX]
	popl %edi  // %edi = ctx1->regs[EDI]
	popl %esi  // %esi = ctx1->regs[ESI]
	popl %ebp  // %ebp = ctx1->regs[EBP]
	popl %esp  // %esp = ctx1->regs[ESP]，即(char*)(sp) - sizeof(void*)
	pushl %eax //set ret func addr  RA = %eax = &pfn，注意此时esp已经指向了新的esp

	xorl %eax, %eax  // reset eax
	ret

#elif defined(__x86_64__)
	leaq 8(%rsp),%rax
	leaq 112(%rdi),%rsp
	pushq %rax
	pushq %rbx
	pushq %rcx
	pushq %rdx

	pushq -8(%rax) //ret func addr

	pushq %rsi
	pushq %rdi
	pushq %rbp
	pushq %r8
	pushq %r9
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	
	movq %rsi, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %r9
	popq %r8
	popq %rbp
	popq %rdi
	popq %rsi
	popq %rax //ret func addr
	popq %rdx
	popq %rcx
	popq %rbx
	popq %rsp
	pushq %rax
	
	xorl %eax, %eax
	ret
#endif
